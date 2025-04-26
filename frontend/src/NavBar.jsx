import './NavBar.css';
import EngageMintLogo from './assets/EngageMintLogo.png';


function NavBar(){

    const openHome = () => {
        Navigate('/home');
    }

    const openExclusiveContent = () => {
        Navigate('/exclusiveContent');
    }

    return (
        <div className="header">
            <img src={EngageMintLogo} alt="Logo"
                className="logo"
                onClick={openHome}
            />
            <h1 className="title"
                onClick={openHome}
            >EngageMint</h1>
            <h1 className="exclusiveContent"
                onClick={openExclusiveContent}
            >ExclusiveContent</h1>

        </div>
    );
}

export default NavBar;