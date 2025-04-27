#![cfg_attr(not(feature = "std"), no_std, no_main)]

#[ink::contract]
mod governance {
    use ink::storage::{Mapping, traits::SpreadAllocate};
    use scale::{Encode, Decode};

    /// A poll created by an admin or developer
    #[derive(Debug, Clone, scale::Encode, scale::Decode, SpreadAllocate)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub struct Poll {
        /// Creator of the poll
        creator: AccountId,
        /// Description or question of the poll
        description: String,
        /// List of options that can be voted on
        options: Vec<String>,
        /// Votes received for each option
        votes: Vec<u32>,
        /// Whether the poll is still active
        active: bool,
        /// Timestamp when the poll was created
        created_at: Timestamp,
        /// Optional end time for the poll
        end_time: Option<Timestamp>,
    }

    /// The governance contract struct
    #[ink(storage)]
    #[derive(SpreadAllocate)]
    pub struct Governance {
        /// Reference to the token contract for permission checks
        token_address: AccountId,
        /// Developer address
        developer: AccountId,
        /// Mapping from poll ID to Poll
        polls: Mapping<u32, Poll>,
        /// The next available poll ID
        next_poll_id: u32,
        /// Tracks which addresses have voted on which polls
        voted: Mapping<(AccountId, u32), bool>,
    }

    /// Events emitted by the contract
    #[ink(event)]
    pub struct PollCreated {
        #[ink(topic)]
        poll_id: u32,
        #[ink(topic)]
        creator: AccountId,
        description: String,
    }

    #[ink(event)]
    pub struct VoteCast {
        #[ink(topic)]
        poll_id: u32,
        #[ink(topic)]
        voter: AccountId,
        option_index: u32,
    }

    #[ink(event)]
    pub struct PollEnded {
        #[ink(topic)]
        poll_id: u32,
        results: Vec<u32>,
    }

    /// Error types
    #[derive(Debug, PartialEq, Eq, scale::Encode, scale::Decode)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub enum Error {
        /// Returned if the caller is not authorized
        NotAuthorized,
        /// Returned if the poll does not exist
        PollNotFound,
        /// Returned if the poll is no longer active
        PollNotActive,
        /// Returned if the option index is out of bounds
        InvalidOptionIndex,
        /// Returned if the user has already voted
        AlreadyVoted,
        /// Returned if an empty poll is attempted to be created
        InvalidPollOptions,
    }

    /// Type alias for the contract's result type
    pub type Result<T> = core::result::Result<T, Error>;

    impl Governance {
        /// Constructor to initialize the governance contract
        #[ink(constructor)]
        pub fn new(token_address: AccountId) -> Self {
            // Initialize contract storage using the default values
            ink::utils::initialize_contract(|contract: &mut Self| {
                contract.token_address = token_address;
                contract.developer = Self::env().caller();
                contract.next_poll_id = 1;
            })
        }

        /// Internal function to check if caller is an admin or developer
        fn is_authorized(&self, caller: AccountId) -> bool {
            // Import and call the token contract to check admin status
            use ishowspeed_token::IshowspeedTokenRef;
            
            let token_instance: IshowspeedTokenRef = 
                ink::env::call::FromAccountId::from_account_id(self.token_address);
                
            token_instance.is_admin(caller) || token_instance.is_developer(caller)
        }

        /// Creates a new poll with the given description and options
        #[ink(message)]
        pub fn create_poll(
            &mut self, 
            description: String, 
            options: Vec<String>,
            end_time: Option<Timestamp>,
        ) -> Result<u32> {
            let caller = self.env().caller();
            
            // Check if caller is authorized
            if !self.is_authorized(caller) {
                return Err(Error::NotAuthorized);
            }
            
            // Validate poll options
            if options.is_empty() || options.len() > 10 {
                return Err(Error::InvalidPollOptions);
            }
            
            // Create a new poll
            let poll_id = self.next_poll_id;
            let now = self.env().block_timestamp();
            
            let poll = Poll {
                creator: caller,
                description,
                votes: vec![0; options.len()],
                options,
                active: true,
                created_at: now,
                end_time,
            };
            
            // Store the poll
            self.polls.insert(poll_id, &poll);
            self.next_poll_id += 1;
            
            // Emit event
            self.env().emit_event(PollCreated {
                poll_id,
                creator: caller,
                description: poll.description.clone(),
            });
            
            Ok(poll_id)
        }

        /// Get information about a specific poll
        #[ink(message)]
        pub fn get_poll(&self, poll_id: u32) -> Option<Poll> {
            self.polls.get(poll_id)
        }

        /// Cast a vote on a poll
        #[ink(message)]
        pub fn vote(&mut self, poll_id: u32, option_index: u32) -> Result<()> {
            let caller = self.env().caller();
            
            // Check if the poll exists
            let mut poll = self.polls.get(poll_id).ok_or(Error::PollNotFound)?;
            
            // Check if the poll is still active
            if !poll.active {
                return Err(Error::PollNotActive);
            }
            
            // Check if the poll has expired (if end_time was set)
            if let Some(end_time) = poll.end_time {
                if self.env().block_timestamp() > end_time {
                    poll.active = false;
                    self.polls.insert(poll_id, &poll);
                    return Err(Error::PollNotActive);
                }
            }
            
            // Check if the option index is valid
            if option_index as usize >= poll.options.len() {
                return Err(Error::InvalidOptionIndex);
            }
            
            // Check if the user has already voted
            if self.voted.get((caller, poll_id)).is_some() {
                return Err(Error::AlreadyVoted);
            }
            
            // Record the vote
            poll.votes[option_index as usize] += 1;
            self.polls.insert(poll_id, &poll);
            self.voted.insert((caller, poll_id), &true);
            
            // Emit event
            self.env().emit_event(VoteCast {
                poll_id,
                voter: caller,
                option_index,
            });
            
            Ok(())
        }

        /// End an active poll (only accessible by admins or the poll creator)
        #[ink(message)]
        pub fn end_poll(&mut self, poll_id: u32) -> Result<()> {
            let caller = self.env().caller();
            
            // Check if the poll exists
            let mut poll = self.polls.get(poll_id).ok_or(Error::PollNotFound)?;
            
            // Check if the poll is still active
            if !poll.active {
                return Err(Error::PollNotActive);
            }
            
            // Check if caller is authorized (admin, developer, or the poll creator)
            if !self.is_authorized(caller) && caller != poll.creator {
                return Err(Error::NotAuthorized);
            }
            
            // End the poll
            poll.active = false;
            self.polls.insert(poll_id, &poll);
            
            // Emit event
            self.env().emit_event(PollEnded {
                poll_id,
                results: poll.votes.clone(),
            });
            
            Ok(())
        }

        /// Get the number of polls that have been created
        #[ink(message)]
        pub fn get_poll_count(&self) -> u32 {
            self.next_poll_id - 1
        }

        /// Get the results of a poll
        #[ink(message)]
        pub fn get_poll_results(&self, poll_id: u32) -> Result<Vec<u32>> {
            let poll = self.polls.get(poll_id).ok_or(Error::PollNotFound)?;
            Ok(poll.votes.clone())
        }
    }

    /// Unit tests
    #[cfg(test)]
    mod tests {
        use super::*;
        use ink::env::test;

        /// We need to mock the IShowSpeed token contract
        #[ink::test]
        fn create_poll_works() {
            // TODO: Implement mock for token contract
            // For now, let's assume the caller is authorized
            
            let accounts = test::default_accounts::<ink::env::DefaultEnvironment>();
            
            // Create a new governance contract
            let mut governance = Governance::new(accounts.alice);
            
            // Create a poll with options
            let description = String::from("What should we build next?");
            let options = vec![
                String::from("Mobile app"), 
                String::from("Web dashboard"),
                String::from("API integration")
            ];
            
            let poll_id = governance.create_poll(description, options.clone(), None).unwrap();
            assert_eq!(poll_id, 1);
            
            // Get the poll and verify its contents
            let poll = governance.get_poll(poll_id).unwrap();
            assert_eq!(poll.description, "What should we build next?");
            assert_eq!(poll.options.len(), 3);
            assert_eq!(poll.votes, vec![0, 0, 0]);
            assert!(poll.active);
        }
    }
}