import './ExclusiveContent.css';
import Item from '../../components/item/Item';
import NavBar from '../../components/navBar/NavBar';
import shirt1 from '../../assets/shirt1.png';
import shirt2 from '../../assets/shirt2.png';
import hoodie1 from '../../assets/hoodie1.png';
import hoodie2 from '../../assets/hoodie2.png';
import hat1 from '../../assets/hat1.png';
import hat2 from '../../assets/hat2.png';
import pants1 from '../../assets/pants1.png';
import hoodie3 from '../../assets/hoodie3.png';
import shirt3 from '../../assets/shirt3.png';
import shirt4 from '../../assets/shirt4.png';

const ExclusiveContent = () => {
    return (
        <>
            <NavBar />
            <h1 className='head'>Merch</h1>
            <div className='merch_container'>
                <Item image={shirt1}
                    name='Blurred Photo White Tee'
                    price='1080'
                />
                <Item image={shirt2}
                    name='Green Apple Black Tee'
                    price='940'
                />
                <Item image={hoodie1}
                    name='Racing Royal Hoodie'
                    price='3070'
                />
                <Item image={hoodie2}
                    name='Stars Space Grey Pullover'
                    price='3300'
                />
                <Item image={hat1}
                    name='Spider Web Black Trucker Hat'
                    price='480'
                />
                <Item image={hat2}
                    name='Racing Royal Trucker Hat'
                    price='440'
                />
                <Item image={pants1}
                    name='Spider Web Black Sweatpants'
                    price='2640'
                />
                <Item image={hoodie3}
                    name='Gold Logo Black Pullover'
                    price='2980'
                />
                <Item image={shirt3}
                    name='Gold Logo Black Tee'
                    price='820'
                />
                <Item image={shirt4}
                    name='Warp Black Tee'
                    price='1200'
                />
            </div>
        </>
    )
}

export default ExclusiveContent;