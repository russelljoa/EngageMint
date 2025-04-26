import { useState } from 'react'
import { useNavigate } from 'react-router-dom';
import { useGoogleLogin } from '@react-oauth/google';
import './Login.css';

const Login = ({ setIsAuthenticated }) => {
    const navigate = useNavigate();

    const oauth = useGoogleLogin({
        onSuccess: tokenResponse => {
            console.log(tokenResponse);
            const token = tokenResponse.access_token || tokenResponse.credential;
            sessionStorage.setItem('authToken', token);
            
            // Fetch user information to get the email
            fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            })
                .then(res => res.json())
                .then(user => {
                    console.log(user);
                    addUser(user.email);
                    setIsAuthenticated(true);
                    navigate('/home');
                })
                .catch(err => {
                    console.error('Fetching user info failed', err);
                });
        },
        onError: error => {
            console.error('Login failed', error);
        }
    });

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
            Hello World
            <button className="login_button" onClick={oauth}>
                {/* <img className="login_googleLogo" src={GoogleLogo} alt="Google Logo" /> */}
                Login with Google
            </button>
        </div>
    )
}

export default Login