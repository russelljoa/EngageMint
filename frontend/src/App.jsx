import { useState } from 'react'
import {
	BrowserRouter as Router,
	Routes,
	Route,
	Navigate,
} from "react-router-dom";
import Login from './pages/login/Login';
import Home from './pages/home/Home';
import GatedContent from './pages/posts/Posts';
import ExclusiveContent from './pages/exclusiveContent/ExclusiveContent';
import Community from './pages/community/Community';
import Videos from './pages/videos/Videos';

import './App.css'
import ExclusiveContent from './pages/exclusiveContent/ExclusiveContent';
import Community from './pages/community/Community';
import Videos from './pages/videos/Videos';

function App() {
	const [isAuthenticated, setIsAuthenticated] = useState(() => {
			return !!sessionStorage.getItem("authToken");
		});

	function ErrorBoundary() {
			const localLink = window.location.href.substring(
				window.location.href.lastIndexOf("/")
			);
			return (
				<>
					<h1 style={{ textAlign: "center", marginTop: "5rem" }}>
						Error 404: Page Not Found
					</h1>
					<h2 style={{ textAlign: "center", marginBottom: "5rem" }}>
						The requested URL {localLink} was not found on this server.
					</h2>
				</>
			);
		}

	return (
		<Router>
			<Routes>
				<Route
				path="/"
				element={
				isAuthenticated ? (
					<Navigate to="/home" replace />
				) : (
					<Login setIsAuthenticated={setIsAuthenticated} />
				)
				}
				/>
				<Route
					path="/videos"
					element={
						isAuthenticated ? <Videos /> : <Navigate to="/" replace />
					}
				/>
				<Route
					path="/community"
					element={
						isAuthenticated ? <Community /> : <Navigate to="/" replace />
					}
				/>
				<Route
					path="/exclusiveContent"
					element={
						isAuthenticated ? <ExclusiveContent /> : <Navigate to="/" replace />
					}
				/>
				<Route
					path="/home"
					element={
					isAuthenticated ? <Home /> : <Navigate to="/" replace />
					}
				/>
				<Route path="*" element={<ErrorBoundary />} />
				<Route
					path="/"
					element={
						isAuthenticated ? <Home /> : <Navigate to="/" replace />
					}
				/>
				<Route path="*" element={<ErrorBoundary />} />
				<Route
					path="/"
					element={
						isAuthenticated ? <Home /> : <Navigate to="/" replace />
					}
				/>
				<Route path="*" element={<ErrorBoundary />} />
			</Routes>
		</Router>
	)}

export default App
