import { useState, useEffect } from 'react';
import Navbar from '../../components/navbar/Navbar';
import Footer from '../../components/footer/Footer.tsx';

import './Home.css';

const Home = () => {
    const [tokens, setTokens] = useState(1000);
    const [earned, setEarned] = useState(0);

    useEffect(() => {
        addEarned();
    }, []);

    const withdrawTokens = () => {
        setTokens(tokens + earned);
        setEarned(0);
    }

    const logout = () => {
        sessionStorage.removeItem("authToken");
        window.close();
    }

    const addEarned = () => {
        setInterval(() => {
            setEarned(prevEarned => (prevEarned + 1));
        }, 2000);
    }
    

    return (
        <div className="home_container">
            <Navbar />
            <div className="home_content">
                <div className="body_container">
                    <div className="body_text">
                        <span>Current Balance: {tokens} Token</span>
                        <span>Earned: {earned} Token</span>
                        <div className="button_container">
                            <button className="withdraw_button" onClick={withdrawTokens}>Withdraw</button>
                            <button className="logout_button" onClick={logout}>Logout</button>
                        </div>
                    </div>
                    
                </div>
            </div>
            
            <Footer />
        </div>
    )
}

export default Home;