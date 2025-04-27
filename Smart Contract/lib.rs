#![cfg_attr(not(feature = "std"), no_std, no_main)]
// Allow clippy false positives for enums
#![allow(clippy::cast_possible_truncation)]

#[ink::contract]
mod ishowspeed_token {
    use ink::storage::Mapping;

    /// The $ishowspeed token contract.
    #[ink(storage)]
    pub struct IshowspeedToken {
        /// Total token supply.
        total_supply: Balance,
        /// Mapping from owner to balance.
        balances: Mapping<AccountId, Balance>,
        /// The fixed admin address that can mint tokens.
        admin: AccountId,
    }

    /// Event emitted when tokens are transferred.
    #[ink(event)]
    pub struct Transfer {
        #[ink(topic)]
        from: Option<AccountId>,
        #[ink(topic)]
        to: Option<AccountId>,
        value: Balance,
    }

    /// Errors that can occur during token operations.
    #[derive(Debug, PartialEq, Eq, scale::Encode, scale::Decode)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub enum Error {
        /// Insufficient balance for operation.
        InsufficientBalance,
        /// Only the admin can mint tokens.
        NotAdmin,
        /// Arithmetic overflow/underflow error.
        ArithmeticError,
    }

    /// Type alias for the contract's result type.
    pub type Result<T> = core::result::Result<T, Error>;

    // Implementing Default trait as suggested by clippy
    impl Default for IshowspeedToken {
        fn default() -> Self {
            Self::new()
        }
    }

    impl IshowspeedToken {
        /// Creates a new $ishowspeed token contract.
        /// 
        /// The admin (who has minting rights) is set to the caller of this constructor.
        /// The admin cannot be changed after deployment.
        #[ink(constructor)]
        pub fn new() -> Self {
            let caller = Self::env().caller();
            Self {
                total_supply: 0,
                balances: Mapping::default(),
                admin: caller,
            }
        }

        /// Returns the total supply of the token.
        #[ink(message)]
        pub fn total_supply(&self) -> Balance {
            self.total_supply
        }

        /// Returns the balance of the specified account.
        #[ink(message)]
        pub fn balance_of(&self, owner: AccountId) -> Balance {
            self.balances.get(owner).unwrap_or(0)
        }

        /// Returns the admin account with minting privileges.
        #[ink(message)]
        pub fn get_admin(&self) -> AccountId {
            self.admin
        }

        /// Transfers tokens from the caller to the recipient.
        #[ink(message)]
        pub fn transfer(&mut self, to: AccountId, value: Balance) -> Result<()> {
            let from = self.env().caller();
            self.transfer_from_to(from, to, value)
        }

        /// Creates new tokens and assigns them to the specified recipient.
        /// Only the admin can call this function.
        #[ink(message)]
        pub fn mint(&mut self, to: AccountId, value: Balance) -> Result<()> {
            let caller = self.env().caller();
            
            // Check that only the admin can mint tokens
            if caller != self.admin {
                return Err(Error::NotAdmin);
            }

            // Update the recipient's balance with safe math
            let to_balance = self.balance_of(to);
            let new_to_balance = to_balance.checked_add(value).ok_or(Error::ArithmeticError)?;
            self.balances.insert(to, &new_to_balance);
            
            // Update total supply with safe math
            self.total_supply = self.total_supply.checked_add(value).ok_or(Error::ArithmeticError)?;

            // Emit Transfer event
            self.env().emit_event(Transfer {
                from: None,
                to: Some(to),
                value,
            });

            Ok(())
        }

        /// Internal transfer function used by transfer.
        fn transfer_from_to(
            &mut self,
            from: AccountId,
            to: AccountId,
            value: Balance,
        ) -> Result<()> {
            let from_balance = self.balance_of(from);
            if from_balance < value {
                return Err(Error::InsufficientBalance);
            }

            // Safe math operations
            let new_from_balance = from_balance.checked_sub(value).ok_or(Error::ArithmeticError)?;
            self.balances.insert(from, &new_from_balance);
            
            let to_balance = self.balance_of(to);
            let new_to_balance = to_balance.checked_add(value).ok_or(Error::ArithmeticError)?;
            self.balances.insert(to, &new_to_balance);

            self.env().emit_event(Transfer {
                from: Some(from),
                to: Some(to),
                value,
            });

            Ok(())
        }
    }

    #[cfg(test)]
    mod tests {
        use super::*;
        use ink::env::DefaultEnvironment;
        
        #[ink::test]
        fn new_contract_works() {
            // Given
            let accounts = test::default_accounts::<DefaultEnvironment>();
            
            // When
            let contract = IshowspeedToken::new();
            
            // Then
            assert_eq!(contract.total_supply(), 0);
            assert_eq!(contract.balance_of(accounts.alice), 0);
            assert_eq!(contract.get_admin(), accounts.alice);
        }
        
        #[ink::test]
        fn minting_works() {
            // Given
            let accounts = test::default_accounts::<DefaultEnvironment>();
            
            // When
            let mut contract = IshowspeedToken::new();
            assert_eq!(contract.mint(accounts.bob, 100), Ok(()));
            
            // Then
            assert_eq!(contract.total_supply(), 100);
            assert_eq!(contract.balance_of(accounts.bob), 100);
        }
        
        #[ink::test]
        fn only_admin_can_mint() {
            // Given
            let accounts = test::default_accounts::<DefaultEnvironment>();
            let mut contract = IshowspeedToken::new();
            
            // When
            ink::env::test::set_caller::<DefaultEnvironment>(accounts.bob);
            
            // Then
            assert_eq!(contract.mint(accounts.bob, 100), Err(Error::NotAdmin));
            assert_eq!(contract.total_supply(), 0);
        }
        
        #[ink::test]
        fn transfer_works() {
            // Given
            let accounts = test::default_accounts::<DefaultEnvironment>();
            let mut contract = IshowspeedToken::new();
            assert_eq!(contract.mint(accounts.alice, 100), Ok(()));
            
            // When
            assert_eq!(contract.transfer(accounts.bob, 10), Ok(()));
            
            // Then
            assert_eq!(contract.balance_of(accounts.alice), 90);
            assert_eq!(contract.balance_of(accounts.bob), 10);
        }
        
        #[ink::test]
        fn transfer_fails_insufficient_balance() {
            // Given
            let accounts = test::default_accounts::<DefaultEnvironment>();
            let mut contract = IshowspeedToken::new();
            assert_eq!(contract.mint(accounts.alice, 100), Ok(()));
            
            // When & Then
            assert_eq!(contract.transfer(accounts.bob, 200), Err(Error::InsufficientBalance));
        }
    }

    // Fix the e2e-tests section to match our contract functions
    #[cfg(all(test, feature = "e2e-tests"))]
    mod e2e_tests {


        /// The End-to-End test `Result` type.
        type E2EResult<T> = std::result::Result<T, Box<dyn std::error::Error>>;

        /// We test that we can upload and instantiate the contract using its default constructor.
        #[ink_e2e::test]
        async fn default_works(mut client: ink_e2e::Client<C, E>) -> E2EResult<()> {
            // Given
            let constructor = IshowspeedTokenRef::new();

            // When
            let contract = client
                .instantiate("ishowspeed_token", &ink_e2e::alice(), &constructor)
                .submit()
                .await
                .expect("instantiate failed");
            let call_builder = contract.call_builder::<IshowspeedToken>();

            // Then
            let admin = call_builder.get_admin();
            let admin_result = client.call(&ink_e2e::alice(), &admin).dry_run().await?;
            assert_eq!(admin_result.return_value(), client.account_id(&ink_e2e::alice()));

            Ok(())
        }

        /// We test that we can mint tokens with the admin account.
        #[ink_e2e::test]
        async fn mint_works(mut client: ink_e2e::Client<C, E>) -> E2EResult<()> {
            // Given
            let constructor = IshowspeedTokenRef::new();
            let contract = client
                .instantiate("ishowspeed_token", &ink_e2e::alice(), &constructor)
                .submit()
                .await
                .expect("instantiate failed");
            let call_builder = contract.call_builder::<IshowspeedToken>();

            // When
            let mint = call_builder.mint(client.account_id(&ink_e2e::bob()), 100);
            let _mint_result = client
                .call(&ink_e2e::alice(), &mint)
                .submit()
                .await
                .expect("mint failed");

            // Then
            let balance = call_builder.balance_of(client.account_id(&ink_e2e::bob()));
            let balance_result = client.call(&ink_e2e::alice(), &balance).dry_run().await?;
            assert_eq!(balance_result.return_value(), 100);

            Ok(())
        }
    }
}
