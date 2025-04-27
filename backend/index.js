const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const bodyParser = require('body-parser');
const { MongoClient } = require('mongodb');

const app = express();
dotenv.config();
app.use(cors());
app.use(bodyParser.json());

const MONGO_URI = process.env.MONGO_URI;
const client = new MongoClient(MONGO_URI);

const PORT = process.env.PORT || 5000;

app.post('/inputuser', async (req, res) => {
    const userInput = req.body;
    try {
        const db = client.db('EngageMint');
        const collection = db.collection('users');
        const inputData = {
            email: userInput.email,
            wallet: "",
        };
        const existingUser = await collection.findOne({ email: userInput.email });
        if (!existingUser) {
            await collection.insertOne(inputData);
        }
        res.status(200).json({ message: 'Input received successfully' });
    } catch (error) {
        console.error('Error inserting data:', error);
        res.status(500).json({ message: 'Error inserting data' });
    }
});

app.post('/checkUser', async (req, res) => {
    const email = req.body;
    try {
        const db = client.db('EngageMint');
        const collection = db.collection('users');
        const existingUser = await collection.findOne({ email: email.email });
        if (existingUser) {
            res.status(200).json({ message: 'User exists' });
        } else {
            res.status(404).json({ message: 'User does not exist' });
        }
    } catch (error) {
        console.error('Error checking user:', error);
        res.status(500).json({ message: 'Error checking user' });
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});