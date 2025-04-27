import './NavBar.css';
import { useNavigate } from 'react-router-dom';
import EngageMintLogo from './assets/EngageMintLogo.png';


function NavBar(){
    const navigate = useNavigate();
    const openHome = () => {
        navigate('/home');
    }

    const openExclusiveContent = () => {
        navigate('/exclusiveContent');
    }

    const openGatedContent = () => {
        navigate('/gatedContent');
    }

    return (
        <div className="header">
            <div className="brand">
                <img src={EngageMintLogo} alt="Logo"
                    className="logo"
                    onClick={openHome}
                />
                <h1 className="title"
                    onClick={openHome}
                >EngageMint</h1>
            </div>
            <h1 className="exclusive_content"
                onClick={openExclusiveContent}
            >Merch</h1>
            <h1 className="gated_content"
                onClick={openGatedContent}
            >Gated Content</h1>
        </div>
    );
}

export default NavBar;