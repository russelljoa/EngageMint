import React from 'react';
import EngageMintLogo from '../../assets/EngageMintLogo.png';
import './Footer.css';

const Footer = () => {
    return (
        <footer className="footer">
            <div className="footer-names">
                <span>Person 1</span>
                <span>Person 2</span>
                <span>Person 3</span>
            </div>
            <img src={EngageMintLogo} alt="EngageMint Logo" className="footer-logo" />
        </footer>
    );
}

export default Footer;