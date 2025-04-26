import { useState } from 'react';
import './Login.css';

const Login = ({ setIsAuthenticated }: { setIsAuthenticated: (value: boolean) => void }) => {
    return (
        <div>
            <button onClick={() => setIsAuthenticated(true)}>Log In</button>
        </div>
    )
}

export default Login;