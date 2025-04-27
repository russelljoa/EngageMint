import { useState } from 'react'
import './Home.css';
import { LineChart } from '@mui/x-charts/LineChart';
import NavBar from '../../components/navBar/NavBar';
import EngageMintFullLogo from '/EngageMintFullLogo.png';

const Home = () => {
    // Token statistics data with percent changes
    const tokenStats = {
        holders: { value: "14,876", change: "+5.3%" },
        circulation: { value: "923,453", change: "+2.1%" },
        burned: { value: "342,651", change: "+8.7%" },
        topHolder: { value: "567,890", change: "+0.5%" }
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
                                            0.00, 10.10, 20.20, 30.30, 40.40, 50.51, 60.61, 70.71, 80.81, 90.91,
                                            101.01, 111.11, 121.21, 131.31, 141.41, 151.52, 161.62, 171.72, 181.82, 191.92,
                                            202.02, 212.12, 222.22, 232.32, 242.42, 252.53, 262.63, 272.73, 282.83, 292.93,
                                            303.03, 313.13, 323.23, 333.33, 343.43, 353.54, 363.64, 373.74, 383.84, 393.94,
                                            404.04, 414.14, 424.24, 434.34, 444.44, 454.55, 464.65, 474.75, 484.85, 494.95,
                                            505.05, 515.15, 525.25, 535.35, 545.45, 555.56, 565.66, 575.76, 585.86, 595.96,
                                            606.06, 616.16, 626.26, 636.36, 646.46, 656.57, 666.67, 676.77, 686.87, 696.97,
                                            707.07, 717.17, 727.27, 737.37, 747.47, 757.58, 767.68, 777.78, 787.88, 797.98,
                                            808.08, 818.18, 828.28, 838.38, 848.48, 858.59, 868.69, 878.79, 888.89, 898.99,
                                            909.09, 919.19, 929.29, 939.39, 949.49, 959.60, 969.70, 979.80, 989.90, 1000.00
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
        </>
    )
}

export default Home