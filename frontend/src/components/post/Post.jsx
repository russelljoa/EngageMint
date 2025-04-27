import { useState } from 'react';
import './Post.css';
import Comment from '../comment/Comment';

const Post = (props) => {
    const [showAll, setShowAll] = useState(false);
    const maxToShow = 3;
    const comments = props.comments || [];
    const visibleComments = showAll ? comments : comments.slice(0, maxToShow);
    const hasMore = comments.length > maxToShow;
    const canSeeLess = showAll && hasMore;

    return (
        <>
            <div className="post_section">
                <h1 className="subject">{props.sub}</h1>
                <div className="post_container">
                    <p className="post">{props.post}</p>
                </div>
            </div>
            <input type="text" className="comment_input" placeholder="What's on your mind" />
            <button className="comment_button">Burn 10 Tokens</button>
            <div className="comment_section">
                {visibleComments.map((c, i) => (
                    <Comment key={i} com={c} />
                ))}
                <div style={{ display: 'flex', gap: '12px', marginTop: hasMore ? 0 : undefined }}>
                    {hasMore && !showAll && (
                        <button className="see_more_button" onClick={() => setShowAll(true)}>
                            See more comments
                        </button>
                    )}
                    {canSeeLess && (
                        <button className="see_less_button" onClick={() => setShowAll(false)}>
                            See less comments
                        </button>
                    )}
                </div>
            </div>
        </>
    )
}

export default Post;