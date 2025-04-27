import { useState } from 'react';
import './Navbar.css';

const Navbar = () => {
    return (
        <div className="navbar_container">
            <span id="engage">ENGAGE</span>
            <img src="/EngageMintLogo.png" alt="EngageMintLogo" className="logo" />
            <span id="mint">MINT</span>
        </div>
    )
}

export default Navbar;