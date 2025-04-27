import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useGoogleLogin } from '@react-oauth/google';
import { web3Enable, web3Accounts } from '@polkadot/extension-dapp';
import './Login.css';

const Login = ({ setIsAuthenticated }: { setIsAuthenticated: (value: boolean) => void }) => {
    const [walletAddress, setWalletAddress] = useState("");
    
    const connectWallet = async () => {
        try {
            // Enable the Polkadot extension using web3Enable
            // Request access to accounts using the Polkadot extension's API
            const enabled = await web3Enable('EngageMint');
            console.log("Enabled extensions:", enabled);
            if (!enabled.length) {
            alert("Access to the Polkadot wallet was not granted.");
            return;
            }
            
            const accounts = await web3Accounts();
            if (accounts.length === 0) {
            alert("No accounts found. Please create or import an account in your Polkadot wallet.");
            return;
            }
            
            // Set the wallet address to the first account found
            const address = accounts[0].address;
            setWalletAddress(address);
            setIsAuthenticated(true);
            console.log("Connected:", address);
        } catch (error) {
            console.error("Error connecting to Polkadot wallet:", error);
        }
    };

    return (
        <div className="login_page_container">
            <div>
                <button className="btn btn-primary" onClick={connectWallet}>
                    {walletAddress ? "Connected: " + walletAddress : "Connect Wallet"}
                </button>
            </div>
            <div>
                
            </div>
            
        </div>
    )
}

export default Login;