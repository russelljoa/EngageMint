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

    const openCommunity = () => {
        navigate('/community');
    }

    const openVideos = () => {
        navigate('/videos');
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
            <h1 className="community"
                onClick={openCommunity}
            >Community</h1>
            <h1 className="videos"
                onClick={openVideos}
            >Videos</h1>
        </div>
    );
}

export default NavBar;