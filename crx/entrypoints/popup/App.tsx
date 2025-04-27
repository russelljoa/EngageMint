import { useState } from 'react';
import {
	HashRouter as Router,
	Routes,
	Route,
	Navigate,
} from "react-router-dom";
import Home from "./pages/home/Home";
import './App.css';

function App() {
	return (
		<Home />
	);
}

export default App;
