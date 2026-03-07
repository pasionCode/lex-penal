import React from 'react';
import { Navigate } from 'react-router-dom';
import { getSession } from '../store/auth-store.js';

export default function ProtectedRoute({ children }) {
  const session = getSession();
  return session?.token ? children : <Navigate to="/login" replace />;
}
