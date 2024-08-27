import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LoginSignup from "./components/LoginSignup/LoginSignup";
import Dashboard from "./components/Dashboard/Dashboard";
import PrivateRoutes from "./utils/PrivateRoutes";
import "./App.css";

function App() {
  return (
    <Router>
      <Routes>
   
        <Route path="/login" element={<LoginSignup />} />
        
  
        <Route element={<PrivateRoutes />}>
          <Route path="/home" element={<Dashboard />} />
        </Route>

      </Routes>
    </Router>
  );
}

export default App;
