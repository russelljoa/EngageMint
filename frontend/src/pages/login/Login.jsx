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
            setIsAuthenticated(true);
            navigate('/home');
        },
        onError: error => {
            console.error('Login failed', error);
        }
    });

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