import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './LoginSignup.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import 'bootstrap/dist/css/bootstrap.min.css';

const LoginSignup = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState('');
  const navigate = useNavigate();

  const handleSubmit = (event) => {
    event.preventDefault();

    const API_URL = process.env.REACT_APP_AMBIORIX_BACKEND_URL;
    axios
      .post(
        `${API_URL}/login`,
        { email, password },
        { headers: { 'Content-Type': 'application/json' } }
      )
      .then((res) => {
        console.log("Response received:", res.data);

        if (res.data.success) {
          // Store authentication flag in local storage
          localStorage.setItem('isUserAuthenticated', 'true');
          console.log("Authentication successful");
          // Redirect to the home page
          navigate('/home');
        } else {
          console.log("Authentication failed:", res.data.message);
          setMessage(res.data.message);
        }
      })
      .catch((err) => {
        console.error("Request error:", err.response ? err.response.data : err.message);
        setMessage(err.response ? err.response.data.message : err.message);
      });
  };

  return (
    <div className="d-flex vh-100 justify-content-center align-items-center">
      <div className="p-4 bg-white w-25 rounded">
        <form onSubmit={handleSubmit}>
          <div className="mb-3">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              placeholder="Enter Email"
              className="form-control"
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div className="mb-3">
            <label htmlFor="password">Password</label>
            <input
              type="password"
              placeholder="Enter Password"
              className="form-control"
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <button className="btn btn-success">Login</button>
          <p>{message}</p>
        </form>
      </div>
    </div>
  );
};

export default LoginSignup;
