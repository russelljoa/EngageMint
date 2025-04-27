import { useState } from 'react'
import './Home.css';
import NavBar from '../../NavBar';
import EngageMintFullLogo from '../../assets/EngageMintFullLogo.png';

const Home = () => {
    return (
        <>
            <NavBar />
            <div className="home_container">
                <img src={EngageMintFullLogo}
                    alt="Logo"
                    className="home_logo"
                ></img>
            </div>
        </>
    )
}

export default Home