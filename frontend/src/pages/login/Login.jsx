import { useState } from 'react'
import { useNavigate } from 'react-router-dom';
import { useGoogleLogin } from '@react-oauth/google';
import { web3Enable, web3Accounts } from '@polkadot/extension-dapp';
import './Login.css';

const Login = ({ setIsAuthenticated }) => {
    const [walletAddress, setWalletAddress] = useState("");
    const navigate = useNavigate();

    const connectWallet = async () => {
        try {
            // Enable the Polkadot extension using web3Enable
            const enabled = await web3Enable('EngageMint');
            console.log("Enabled extensions:", enabled);
            if (!enabled.length) {
                alert("Access to the Polkadot wallet was not granted. Please ensure the Polkadot extension is installed and enabled in your browser.");
                return;
            }

            // Request access to accounts using the Polkadot extension's API
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

            // Redirect to home page after successful connection
            navigate('/home');
        } catch (error) {
            console.error("Error connecting to Polkadot wallet:", error);
            alert("An error occurred while connecting to the Polkadot wallet. Please try again.");
        }
    };

    const addUser = async (email) => {
        try {
            const response = await fetch('http://localhost:5000/inputuser', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email })
            });
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            const data = await response.json();
            console.log(data);
        }
        catch (error) {
            console.error('Error adding user:', error);
        }
    }

    return (
        <div className="login_container">
            <button className="btn btn-primary" onClick={connectWallet}>
                {walletAddress ? "Connected: " + walletAddress : "Connect Wallet"}
            </button>
        </div>
    )
}

export default Login