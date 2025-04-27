import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useGoogleLogin } from '@react-oauth/google';
import './Login.css';

const Login = ({ setIsAuthenticated }: { setIsAuthenticated: (value: boolean) => void }) => {
    const navigate = useNavigate();
    const [email, setEmail] = useState('');

    const handleSubmit = async () => {
        try {
            const response = await fetch('http://localhost:5000/checkUser', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email })
            });
            const result = await response.json();
            console.log(result);
            if (result) {
                setIsAuthenticated(true);
                navigate('/home');
            } else {
                alert('User not found');
            }
        } catch (error) {
            console.error('Error checking user:', error);
        }
    };

    return (
        <div className="login_container">
            <form onSubmit={handleSubmit}>
                <input
                    type="text"
                    placeholder="Enter Email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                />
                <button type="submit" onClick={() => handleSubmit()}>Login</button>
            </form>
        </div>
    )
}

export default Login;