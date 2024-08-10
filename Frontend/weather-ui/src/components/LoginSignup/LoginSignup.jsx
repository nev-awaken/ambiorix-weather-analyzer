import React, { useState } from "react";
import "./LoginSignup.css";
import "bootstrap-icons/font/bootstrap-icons.css";
import "bootstrap/dist/css/bootstrap.min.css";
import axios from "axios"

const LoginSignup = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  function handleSubmit(event) {
    event.preventDefault();
    
    const API_URL = "http://127.0.0.1:1001"; 
    axios
      .post(`${API_URL}/login`, 
        { email, password }, 
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      )
      .then((res) => console.log(res))
      .catch((err) => {
        console.error("Error details:", err.response ? err.response.data : err.message);
      });
  }

  return (
    <div className="d-flex vh-100 justify-content-center align-items-center ">
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
        </form>

      </div>
    </div>
  );
};

export default LoginSignup;
