#![cfg_attr(not(feature = "std"), no_std, no_main)]
#![allow(unexpected_cfgs)]

#[ink::contract]
mod ishowspeed_token {
    use ink::storage::Mapping;

    /// The IShowSpeed token contract struct
    #[ink(storage)]
    pub struct IshowspeedToken {
        /// Total token supply
        total_supply: Balance,
        /// Balances for each account
        balances: Mapping<AccountId, Balance>,
        /// Owner of the contract
        developer: AccountId,
        /// Admin addresses that can perform privileged actions
        admins: Mapping<AccountId, ()>,
    }

    /// Events emitted by the contract
    #[ink(event)]
    pub struct Transfer {
        #[ink(topic)]
        from: Option<AccountId>,
        #[ink(topic)]
        to: Option<AccountId>,
        value: Balance,
    }

    /// Error types
    #[repr(u8)]
    #[derive(Debug, PartialEq, Eq, scale::Encode, scale::Decode)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub enum Error {
        /// Returned if the transfer is not allowed
        TransferNotAllowed,
        /// Returned if the caller is not authorized
        NotAuthorized,
        /// Returned if the account has insufficient balance
        InsufficientBalance,
    }

    /// Type alias for the contract's result type
    pub type Result<T> = core::result::Result<T, Error>;

    impl IshowspeedToken {
        /// Constructor to initialize the token
        #[ink(constructor)]
        pub fn new(initial_supply: Balance) -> Self {
            let caller = Self::env().caller();
            let mut balances = Mapping::default();
            
            // Assign initial supply to the contract creator
            balances.insert(caller, &initial_supply);
            
            // Emit a Transfer event for the initial supply
            Self::env().emit_event(Transfer {
                from: None,
                to: Some(caller),
                value: initial_supply,
            });

            let mut admins = Mapping::default();
            // Developer is also an admin by default
            admins.insert(caller, &());

            Self {
                total_supply: initial_supply,
                balances,
                developer: caller,
                admins,
            }
            }
        }

        /// Returns the total supply of tokens
        #[ink(message)]
        pub fn total_supply(&self) -> Balance {
            self.total_supply
        }

        /// Returns the balance of the specified account
        #[ink(message)]
        pub fn balance_of(&self, owner: AccountId) -> Balance {
            self.balances.get(owner).unwrap_or(0)
        }

        /// Checks if an account is the developer
        #[ink(message)]
        pub fn is_developer(&self, account: AccountId) -> bool {
            account == self.developer
        }

        /// Checks if an account is an admin
        #[ink(message)]
        pub fn is_admin(&self, account: AccountId) -> bool {
            self.admins.get(account).is_some()
        }

        /// Add an address as admin
        #[ink(message)]
        pub fn add_admin(&mut self, account: AccountId) -> Result<()> {
            let caller = self.env().caller();
            // Only the developer can add admins
            if caller != self.developer {
                return Err(Error::NotAuthorized);
            }
            
            self.admins.insert(account, &());
            Ok(())
        }

        /// Remove an admin
        #[ink(message)]
        pub fn remove_admin(&mut self, account: AccountId) -> Result<()> {
            let caller = self.env().caller();
            // Only the developer can remove admins
            if caller != self.developer {
                return Err(Error::NotAuthorized);
            }
            
            self.admins.remove(account);
            Ok(())
        }

        /// Transfers tokens with restrictions
        /// - Can only transfer to the zero address (burn)
        /// - Only developer or admins can transfer from any account
        #[ink(message)]
        pub fn transfer(&mut self, to: AccountId, value: Balance) -> Result<()> {
            let from = self.env().caller();
            self.transfer_from_to(from, to, value)
        }

        /// Transfer implementation
        #[allow(clippy::arithmetic_side_effects)]
        fn transfer_from_to(
            &mut self,
            from: AccountId,
            to: AccountId,
            value: Balance,
        ) -> Result<()> {
            let caller = self.env().caller();
            
            // Check if this is a burn operation (transfer to zero address)
            let is_burn = to == AccountId::from([0u8; 32]);
            
            // Check authorization: must be developer, admin or a burn operation
            let is_authorized = self.is_developer(caller) || self.admins.get(caller).is_some();
            
            // Only allow transfers that are:
            // 1. Burns (to zero address)
            // 2. From developer or admin wallets
            if !is_burn && !is_authorized {
                return Err(Error::TransferNotAllowed);
            }
            
            let from_balance = self.balance_of(from);
            if from_balance < value {
                return Err(Error::InsufficientBalance);
            }

            self.balances.insert(from, &(from_balance - value));
            
            // In case of burn, don't increase the recipient's balance
            if !is_burn {
                let to_balance = self.balance_of(to);
                self.balances.insert(to, &(to_balance + value));
            } else {
                // Update total supply when tokens are burned
                self.total_supply -= value;
            }

            // Emit the transfer event
            self.env().emit_event(Transfer {
                from: Some(from),
                to: Some(to),
                value,
            });

            Ok(())
        }
        
        /// Burns a specific amount of tokens from the caller's account
        #[ink(message)]
        pub fn burn(&mut self, value: Balance) -> Result<()> {
            let caller = self.env().caller();
            let zero_address = AccountId::from([0u8; 32]);
            
            self.transfer_from_to(caller, zero_address, value)
        }
        
        /// Burns tokens from a specified account
        /// Can only be called by developer or admin
        #[ink(message)]
        pub fn burn_from(&mut self, from: AccountId, value: Balance) -> Result<()> {
            let caller = self.env().caller();
            let zero_address = AccountId::from([0u8; 32]);

            // Ensure only developer or admin can call this
            if !self.is_developer(caller) && !self.is_admin(caller) {
                return Err(Error::NotAuthorized);
            }

            self.transfer_from_to(from, zero_address, value)
        }
        
        // #[cfg(test)]
        // mod tests {
        //     use super::*;

        //     #[ink::test]
        //     fn burn_works() {
        //         let mut contract = IshowspeedToken::new(100);
        //         let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

        //         // Alice burns 10 tokens
        //         ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
        //         assert_eq!(contract.burn(10), Ok(()));
        //         assert_eq!(contract.balance_of(accounts.alice), 90);
        //         assert_eq!(contract.total_supply(), 90);
        //     }

        //     #[ink::test]
        //     fn burn_from_works() {
        //         let mut contract = IshowspeedToken::new(100);
        //         let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

        //         // Alice adds Bob as admin
        //         ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
        //         assert_eq!(contract.add_admin(accounts.bob), Ok(()));

        //         // Bob burns 10 tokens from Alice's account
        //         ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.bob);
        //         assert_eq!(contract.burn_from(accounts.alice, 10), Ok(()));
        //         assert_eq!(contract.balance_of(accounts.alice), 90);
        //         assert_eq!(contract.total_supply(), 90);
        //     }

        //     #[ink::test]
        //     fn insufficient_balance_prevents_burn() {
        //         let mut contract = IshowspeedToken::new(100);
        //         let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

        //         // Alice tries to burn more tokens than she owns
        //         ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
        //         assert_eq!(contract.burn(200), Err(Error::InsufficientBalance));
        //     }

        //     #[ink::test]
        //     fn unauthorized_burn_from_fails() {
        //         let mut contract = IshowspeedToken::new(100);
        //         let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

        //         // Charlie (not an admin) tries to burn tokens from Alice's account
        //         ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.charlie);
        //         assert_eq!(contract.burn_from(accounts.alice, 10), Err(Error::NotAuthorized));
        //     }

        //     #[ink::test]
        //     fn remove_admin_works() {
        //         let mut contract = IshowspeedToken::new(100);
        //         let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

        //         // Alice adds Bob as admin
        //         ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
        //         assert_eq!(contract.add_admin(accounts.bob), Ok(()));
        //         assert!(contract.is_admin(accounts.bob));

        //         // Alice removes Bob as admin
        //         assert_eq!(contract.remove_admin(accounts.bob), Ok(()));
        //         assert!(!contract.is_admin(accounts.bob));
        //     }
        // }
    }
}