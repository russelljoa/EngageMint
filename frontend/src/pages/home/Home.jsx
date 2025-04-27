import { useState } from 'react'
import './Home.css';
import { LineChart } from '@mui/x-charts/LineChart';
import NavBar from '../../components/navBar/NavBar';
import EngageMintFullLogo from '/EngageMintFullLogo.png';
import Footer from '../../components/footer/Footer';

const Home = () => {
    // Token statistics data with percent changes
    const tokenStats = {
        holders: { value: "14,876", change: "+5.3%" },
        circulation: { value: "923,453", change: "+2.1%" },
        burned: { value: "342,651", change: "+8.7%" },
        topHolder: { value: "7,890", change: "+0.5%" }
    };

    // YouTube engagement statistics with percent changes
    const youtubeStats = [
        { label: "Views", value: "4.2B", change: "+8.4%" },
        { label: "Watch Time", value: "156K hrs", change: "+8.7%" },
        { label: "Subscribers", value: "39.2M", change: "+13.1%" },
        { label: "Comments", value: "94.6K", change: "+15.9%" }
    ];

    return (
        <>
            <NavBar />
            <div className="home_container">
                <div className="stats_container">
                    <div className="token_stats_card">
                        <h2>Token Statistics</h2>
                        <div className="token_chart">
                            <LineChart
                                xAxis={[

                                    {
                                        data: [
                                            49, 50, 51, 52, 53, 54, 55, 56, 57, 58,
                                            59, 60, 61, 62, 63, 64, 65, 66, 67, 68,
                                            69, 70, 71, 72, 73, 74, 75, 76, 77, 78,
                                            79, 80, 81, 82, 83, 84, 85, 86, 87, 88,
                                            89, 90, 91, 92, 93, 94, 95, 96, 97, 98,
                                            99, 100, 101, 102, 103, 104, 105, 106, 107, 108,
                                            109, 110, 111, 112, 113, 114, 115, 116, 117, 118,
                                            119, 120, 121, 122, 123, 124, 125, 126, 127, 128,
                                            129, 130, 131, 132, 133, 134, 135, 136, 137, 138,
                                            139, 140, 141, 142, 143, 144, 145, 146, 147, 148
                                        ]
                                    },
                                ]}
                                series={[
                                    {
                                        curve: "linear",
                                        stack: 'total',
                                        area: false,
                                        showMark: false,
                                        data: [
                                            3200.00, 3215.56, 3186.84, 3225.73, 3212.69, 3241.41, 3226.39, 3259.62, 3267.01, 3294.89,
                                            3279.47, 3312.40, 3295.69, 3331.46, 3361.59, 3347.87, 3385.59, 3396.98, 3364.34, 3365.05,
                                            3389.50, 3404.06, 3433.31, 3419.05, 3467.46, 3491.16, 3586.88, 3518.12, 3498.74, 3520.29,
                                            3549.80, 3509.65, 3536.16, 3577.46, 3611.56, 3542.74, 3623.76, 3658.46, 3647.65, 3674.90,
                                            3698.12, 3711.46, 3731.22, 3696.28, 3743.84, 3559.42, 3569.81, 3565.72, 3591.89, 3770.50,
                                            3806.27, 3828.63, 3854.11, 3829.09, 3885.22, 3909.75, 3952.79, 3982.00, 3940.28, 3986.10,
                                            4014.54, 4042.51, 4010.37, 4354.73, 4086.23, 4314.76, 4095.34, 4338.18, 4362.17, 4390.21,
                                            4173.26, 4210.50, 4240.54, 4253.43, 4227.88, 4246.27, 4271.09, 4268.54, 4296.03, 4269.39,
                                            4316.71, 4349.44, 4336.78, 4369.30, 4397.51, 4412.46, 4375.17, 4401.09, 4433.51, 4468.45,
                                            4892.95, 4879.12, 4814.46, 5431.24, 5461.28, 5492.67, 5401.38, 5421.67, 5444.55, 5476.44
                                        ],
                                        color: '#3FBB9B',
                                    },
                                ]}
                                height={200}
                                width={400}
                                sx={{
                                    backgroundColor: '#FFFDF5',
                                    paddingRight: '20px',
                                    marginBottom: '20px',
                                }}
                            />
                        </div>
                        <div className="token_metrics">
                            <div className="metric_item">
                                <h3>Holders</h3>
                                <p className="metric_value">{tokenStats.holders.value}</p>
                                <p className="metric_change positive">{tokenStats.holders.change}</p>
                            </div>
                            <div className="metric_item">
                                <h3>In Circulation</h3>
                                <p className="metric_value">{tokenStats.circulation.value}</p>
                                <p className="metric_change positive">{tokenStats.circulation.change}</p>
                            </div>
                            <div className="metric_item">
                                <h3>Burned</h3>
                                <p className="metric_value">{tokenStats.burned.value}</p>
                                <p className="metric_change positive">{tokenStats.burned.change}</p>
                            </div>
                            <div className="metric_item">
                                <h3>Top Holder</h3>
                                <p className="metric_value">{tokenStats.topHolder.value}</p>
                                <p className="metric_change positive">{tokenStats.topHolder.change}</p>
                            </div>
                        </div>
                    </div>
                    
                    <div className="youtube_stats_card">
                        <h2>YouTube Engagement</h2>
                        <div className="platform_logo">
                            <img src={EngageMintFullLogo} alt="EngageMint Logo" className="home_logo" />
                        </div>
                        <div className="youtube_metrics">
                            {youtubeStats.map((stat, index) => (
                                <div className="metric_item" key={index}>
                                    <h3>{stat.label}</h3>
                                    <p className="metric_value">{stat.value}</p>
                                    <p className="metric_change positive">{stat.change}</p>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
            <Footer />
        </>
    )
}

export default Home