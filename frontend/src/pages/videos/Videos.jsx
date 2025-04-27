import NavBar from '../../NavBar';
import './Videos.css';
import Video from '../../Video';
import hockey from  '../../assets/hockey.png';
import korea from  '../../assets/korea.png';
import disguise from  '../../assets/disguise.png';
import cricket from  '../../assets/cricket.png';
import cheese from  '../../assets/cheese.png';
import asia from '../../assets/asia.png';

const Videos = () => {

    return (
        <>
            <NavBar />
            <Video title="iShowSpeed Learns Hocket with Cole Caufield"
                thumbnail={hockey}
                description="4m views"
            />
            <Video title="iShowSpeed's Life In Korea🇰🇷🇰🇵"
                thumbnail={korea}
                description="2.7m views"
            />
            <Video title="iShowSpeed IN DISGUISE"
                thumbnail={disguise}
                description="8.2m views"
            />
            <Video title="SPEED India VS Pakistan Cricket Match!"
                thumbnail={cricket}
                description="7.2m views"
            />
            <Video title="iShowSpeed vs CHEESE ROLLING"
                thumbnail={cheese}
                description="970k views"
            />
            <Video title="I Spent 14 Days In SoutEast Asia"
                thumbnail={asia}
                description="11.2m views"
            />
        </>
    )

}

export default Videos