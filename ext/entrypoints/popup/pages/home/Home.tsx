import { useState } from 'react';
import Navbar from '../../components/navbar/Navbar';
import Footer from '../../components/footer/Footer.tsx';
import './Home.css';

const Home = () => {
    return (
        <div className="home_container">
            <Navbar />
            <Footer />
        </div>
    )
}

export default Home;