import './Item.css';

const Item = (props) => {

    return (
        <>
            <div className='item_container'>
                <img src={props.image} alt="Item" className="item_image" />
                <h3 className="item_title">{props.name}</h3>
                <div className="item_footer">
                    <h4 className="item_price">{props.price} Tokens</h4>
                    <button className="burn_button">Burn</button>
                </div>
            </div>
        </>
    )

}

export default Item;