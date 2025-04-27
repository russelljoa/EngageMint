import './Post.css';
import Comment from './Comment';

const Post = (props) => {

    return (
        <>
            <h1 className="subject">{props.sub}</h1>
            <div className="post_container">
                <p className="post">{props.post}</p>
            </div>
            <input type="text" className="comment_input" placeholder="What's on your mind" />
            <button className="comment_button">Burn 10 Tokens</button>
            <div className="comment_container">
                {props.comments && props.comments.map((c, i) => (
                    <Comment key={i} com={c} />
                ))}
            </div>

        </>
    )

}

export default Post