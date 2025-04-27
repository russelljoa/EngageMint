import React from 'react';
import EngageMintLogo from '../../assets/EngageMintLogo.png';
import './Footer.css';

const Footer = () => {
    return (
        <footer className="footer">
            <div className="footer-names">
                <span>By:</span>
                <span>Brady Cieslak</span>
                <span>Russell Joarder</span>
                <span>Patrick Fish</span>
            </div>
            <img src={EngageMintLogo} alt="EngageMint Logo" className="footer-logo" />
        </footer>
    );
}

export default Footer;