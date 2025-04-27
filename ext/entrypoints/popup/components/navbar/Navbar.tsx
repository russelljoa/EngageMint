import { useState } from 'react';
import './Navbar.css';

const Navbar = () => {
    return (
        <div className="navbar_container">
            <div><span id="engage">ENGAGE</span><span id="mint">MINT</span></div>
            <img src="/EngageMintLogo.png" alt="EngageMintLogo" className="logo" />
        </div>
    )
}

export default Navbar;