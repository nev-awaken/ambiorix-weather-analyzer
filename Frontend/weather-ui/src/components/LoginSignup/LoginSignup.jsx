import React, { useState } from "react";
import "./LoginSignup.css";
import "bootstrap-icons/font/bootstrap-icons.css";
import "bootstrap/dist/css/bootstrap.min.css";
import axios from "axios";

const LoginSignup = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");


  function handleSubmit(event) {
    event.preventDefault();

    const API_URL = process.env.REACT_APP_AMBIORIX_BACKEND_URL;
    console.log("API_URL : " + API_URL);
    
    axios
      .post(
        `${API_URL}/login`,
        { email, password },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      )
      .then((res) => {
        console.log("Response status:", res.status); 
        console.log("Response data:", res.data);   
        setMessage(res.data.message);
      })
      .catch((err) => {
        console.error(
          "Error details:",
          err.response ? err.response.data : err.message
        );
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
          <p>{message}</p>
        </form>
      </div>
    </div>
  );
};

export default LoginSignup;
