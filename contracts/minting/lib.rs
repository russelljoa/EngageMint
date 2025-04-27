#![cfg_attr(not(feature = "std"), no_std, no_main)]

#[ink::contract]
mod minting {
    use ink::storage::Mapping;

    /// The minting contract struct
    #[ink(storage)]
    pub struct Minting {
        /// Reference to the token contract
        token_address: AccountId,
        /// Developer address
        developer: AccountId,
        /// Admin addresses that can mint tokens
        admins: Mapping<AccountId, ()>,
        /// Total minted by this contract
        total_minted: Balance,
        /// Minting limits per wallet
        minting_limits: Mapping<AccountId, Balance>,
    }

    /// Events emitted by the contract
    #[ink(event)]
    pub struct TokensMinted {
        #[ink(topic)]
        to: AccountId,
        #[ink(topic)]
        by: AccountId,
        amount: Balance,
    }

    #[ink(event)]
    pub struct MintingLimitSet {
        #[ink(topic)]
        for_account: AccountId,
        #[ink(topic)]
        by: AccountId,
        limit: Balance,
    }

    /// Error types
    #[derive(Debug, PartialEq, Eq, scale::Encode, scale::Decode)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub enum Error {
        /// Returned if the caller is not authorized
        NotAuthorized,
        /// Returned if the minting operation failed
        MintingFailed,
        /// Returned if the minting limit is exceeded
        MintingLimitExceeded,
    }

    /// Type alias for the contract's result type
    pub type Result<T> = core::result::Result<T, Error>;

    impl Minting {
        /// Constructor to initialize the minting contract
        #[ink(constructor)]
        pub fn new(token_address: AccountId) -> Self {
            let caller = Self::env().caller();
            let mut admins = Mapping::default();
            // Developer is also an admin by default
            admins.insert(caller, &());
            
            Self {
                token_address,
                developer: caller,
                admins,
                total_minted: 0,
                minting_limits: Mapping::default(),
            }
        }

        /// Internal function to check if caller is an admin or developer
        fn is_authorized(&self, caller: AccountId) -> bool {
            caller == self.developer || self.admins.contains(caller)
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
        
        /// Set minting limit for an account
        #[ink(message)]
        pub fn set_minting_limit(&mut self, account: AccountId, limit: Balance) -> Result<()> {
            let caller = self.env().caller();
            
            // Check if caller is authorized
            if !self.is_authorized(caller) {
                return Err(Error::NotAuthorized);
            }
            
            // Set the minting limit for the account
            self.minting_limits.insert(account, &limit);
            
            // Emit event
            self.env().emit_event(MintingLimitSet {
                for_account: account,
                by: caller,
                limit,
            });
            
            Ok(())
        }
        
        /// Get minting limit for an account
        #[ink(message)]
        pub fn get_minting_limit(&self, account: AccountId) -> Balance {
            self.minting_limits.get(account).unwrap_or(0)
        }
        
        /// Mint tokens to a specified address
        /// Can only be called by developer or admins
        #[ink(message)]
        pub fn mint(&mut self, to: AccountId, amount: Balance) -> Result<()> {
            let caller = self.env().caller();
            
            // Check if caller is authorized
            if !self.is_authorized(caller) {
                return Err(Error::NotAuthorized);
            }
            
            // Check minting limits if they exist for this caller
            let limit = self.minting_limits.get(caller).unwrap_or(Balance::MAX);
            if self.total_minted + amount > limit {
                return Err(Error::MintingLimitExceeded);
            }
            
            // Call the token contract to mint new tokens
            // In a real implementation, we would need to have a mint function in the token contract
            // This is a simplified version that assumes the token contract has a mint function
            if !self.call_token_mint(to, amount) {
                return Err(Error::MintingFailed);
            }
            
            // Update the total minted amount
            self.total_minted += amount;
            
            // Emit event
            self.env().emit_event(TokensMinted {
                to,
                by: caller,
                amount,
            });
            
            Ok(())
        }
        
        /// Wrapper for the token contract's mint function
        /// This would need to call an actual mint function in the token contract
        fn call_token_mint(&mut self, to: AccountId, amount: Balance) -> bool {
            use ishowspeed_token::IshowspeedTokenRef;
            
            // In a real implementation, we would call the token contract's mint function
            // For now, we'll assume it succeeds as we don't have an actual mint function in our token contract
            // In practice, you would need to add a mint function to the token contract that can only be called
            // by authorized contracts like this one
            
            // This is just a placeholder to show the concept
            // A real implementation would be something like:
            // let token_instance: IshowspeedTokenRef = 
            //     ink::env::call::FromAccountId::from_account_id(self.token_address);
            // token_instance.mint(to, amount)
            
            true
        }

        /// Returns the total amount minted by this contract
        #[ink(message)]
        pub fn total_minted(&self) -> Balance {
            self.total_minted
        }

        /// Checks if an account is the developer
        #[ink(message)]
        pub fn is_developer(&self, account: AccountId) -> bool {
            account == self.developer
        }

        /// Checks if an account is an admin
        #[ink(message)]
        pub fn is_admin(&self, account: AccountId) -> bool {
            self.admins.contains(account)
        }
    }

    /// Unit tests
    #[cfg(test)]
    mod tests {
        use super::*;
        use ink::env::test;
        
        #[ink::test]
        fn minting_works() {
            let accounts = test::default_accounts::<ink::env::DefaultEnvironment>();
            
            // Create a new minting contract
            let mut minting = Minting::new(accounts.alice);
            
            // Alice is developer (created the contract)
            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
            
            // Test minting tokens
            assert_eq!(minting.mint(accounts.bob, 100), Ok(()));
            assert_eq!(minting.total_minted(), 100);
        }
        
        #[ink::test]
        fn admin_management_works() {
            let accounts = test::default_accounts::<ink::env::DefaultEnvironment>();
            
            // Create a new minting contract
            let mut minting = Minting::new(accounts.alice);
            
            // Alice is developer (created the contract)
            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
            
            // Add Bob as admin
            assert_eq!(minting.add_admin(accounts.bob), Ok(()));
            assert!(minting.is_admin(accounts.bob));
            
            // Bob can now mint tokens
            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.bob);
            assert_eq!(minting.mint(accounts.charlie, 50), Ok(()));
            
            // Remove Bob as admin
            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
            assert_eq!(minting.remove_admin(accounts.bob), Ok(()));
            assert!(!minting.is_admin(accounts.bob));
            
            // Bob can no longer mint tokens
            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.bob);
            assert_eq!(minting.mint(accounts.charlie, 50), Err(Error::NotAuthorized));
        }
        
        #[ink::test]
        fn minting_limits_work() {
            let accounts = test::default_accounts::<ink::env::DefaultEnvironment>();
            
            // Create a new minting contract
            let mut minting = Minting::new(accounts.alice);
            
            // Alice is developer (created the contract)
            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.alice);
            
            // Add Bob as admin with a limit
            assert_eq!(minting.add_admin(accounts.bob), Ok(()));
            assert_eq!(minting.set_minting_limit(accounts.bob, 100), Ok(()));
            
            // Bob can mint up to his limit
            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.bob);
            assert_eq!(minting.mint(accounts.charlie, 100), Ok(()));
            
            // Bob cannot exceed his limit
            assert_eq!(minting.mint(accounts.charlie, 1), Err(Error::MintingLimitExceeded));
        }
    }
}