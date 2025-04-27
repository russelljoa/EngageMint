import NavBar from '../../components/navBar/NavBar';
import Post from '../../components/post/Post';
import Footer from '../../components/footer/Footer';
import './Community.css';

const Community = () => {

    return (
        <>
            <NavBar />
            <div className="community_container">
                <h1 className="community_header">Community</h1>
                
                <Post sub="Harvard Hackathon"
                    post="CHAT I JUST PULLED UP TO HARVARD FOR THE HACKATHON TO SUPPORT MY BOYS NEW PROJECT"
                    comments={[
                        "Good luck at the hackathon! Hope you and your team build something amazing. Keep us posted on your progress!",
                        "Let us know how it goes. Hackathons are always a great place to meet new people and learn new things.",
                        "Harvard is wild this weekend! The energy must be incredible. Don’t forget to network and have fun!",
                        "What’s the project about? Super curious to hear more details!",
                        "Are there any cool prizes for the winners? Rooting for you!",
                        "Don’t forget to grab some Harvard merch while you’re there!",
                        "How long is the hackathon? Hope you get some rest too!",
                        "Met any cool people yet?",
                        "Share some pics of the campus!",
                        "Best of luck to your team!"
                    ]}
                />
                <Post sub="CHINAAAAAA"
                    post="HEY CHAT I'M IN CHINA RIGHT NOW CHECKING OUT THE NEW CARS THEY SO TUFF"
                    comments={[
                        "That sounds awesome! I wish I could visit China someday and see all the new tech and cars in person. Let us know what your favorite car is!",
                        "Take some pics! Would love to see what the car scene is like over there. Hope you’re having a great time!",
                        "Speed in China goes crazy 😂. Don’t forget to try the street food and share your experience with us!",
                        "Did you get to drive any of the new cars? Would love to hear your thoughts on the latest models.",
                        "How’s the weather in China right now? Perfect for car spotting?",
                        "Any cool car mods you’ve seen so far? Post some photos if you can!",
                        "What city are you in? I heard Shanghai has some wild car meets.",
                        "Are you planning to visit any car factories or museums?",
                        "Hope you’re staying safe and having fun!",
                        "Can’t wait for you to stream from there!"
                    ]}
                />
            </div>
            <Footer />
        </>
    )

}

export default Community