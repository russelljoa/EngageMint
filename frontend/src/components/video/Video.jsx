import './Video.css';

const Video = (props) => {

    return (
        <>
        
            <div className="video_container">
                <h1 className="video_title">{props.title}</h1>
                <img src={props.thumbnail} alt="Video" className="thumbnail" />
                <p className="video_description">{props.description}</p>
            </div>
        </>
    )

}

export default Video