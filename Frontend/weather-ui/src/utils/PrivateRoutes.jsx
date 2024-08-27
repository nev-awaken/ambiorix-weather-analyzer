import { Outlet, Navigate } from 'react-router-dom';

const PrivateRoutes = () => {
  const isUserAuthenticated = localStorage.getItem('isUserAuthenticated') === 'true';
  return isUserAuthenticated ? <Outlet /> : <Navigate to="/login" />;
};

export default PrivateRoutes;
