import { useState, useRef, useEffect } from 'react';
import './Comment.css';

const Comment = (props) => {
    const [expanded, setExpanded] = useState(false);
    const [isOverflowing, setIsOverflowing] = useState(false);
    const commentRef = useRef(null);

    useEffect(() => {
        if (commentRef.current) {
            setIsOverflowing(commentRef.current.scrollWidth > commentRef.current.clientWidth);
        }
    }, [props.com]);

    return (
        <div className="comment_container">
            <p
                className={expanded ? "post expanded" : "post"}
                ref={commentRef}
                style={expanded ? {whiteSpace: 'normal', overflow: 'visible', textOverflow: 'unset'} : {}}
            >
                {props.com}
            </p>
            {isOverflowing && !expanded && (
                <button className="comment_view_more_button" onClick={() => setExpanded(true)}>
                    View more
                </button>
            )}
            {expanded && (
                <button className="comment_view_more_button" onClick={() => setExpanded(false)}>
                    View less
                </button>
            )}
        </div>
    )
}

export default Comment;