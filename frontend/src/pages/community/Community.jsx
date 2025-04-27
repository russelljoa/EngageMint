import NavBar from '../../NavBar';
import Post from '../../Post';
import './Community.css';

const Community = () => {

    return (
        <>
            <NavBar />
            <Post sub="CHINAAAAAA"
                post="HEY CHAT *BARK* *BARK* I'M IN CHINA RIGHT NOW CHECKING OUT THE NEW CARS THEY SO TUFF"
                comments={["That sounds awesome!", "Take some pics!", "Speed in China goes crazy 😂"]}
            />
            <Post sub="Harvard Hackathon"
                post="CHAT I JUST PULLED UP TO HARVARD FOR THE HACKATHON TO SUPPORT MY BOYS NEW PROJECT"
                comments={["Good luck at the hackathon!", "Let us know how it goes.", "Harvard is wild this weekend!"]}
            />
        </>
    )

}

export default Community