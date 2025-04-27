import './Comment.css';

const Comment = (props) => {

    return (
        <>
            <div className="comment_container">
                <p className="post">{props.com}</p>
            </div>

        </>
    )

}

export default Comment