import React from 'react';
import { Link, Outlet, useNavigate } from 'react-router-dom';
import { clearSession, getSession } from '../store/auth-store.js';

export default function AppLayout() {
  const navigate = useNavigate();
  const session = getSession();

  function handleLogout() {
    clearSession();
    navigate('/login');
  }

  return (
    <div className="shell">
      <aside className="sidebar">
        <h1>LexPenal</h1>
        <p className="muted">{session?.user?.email}</p>
        <nav>
          <Link to="/dashboard">Dashboard</Link>
          <Link to="/cases">Casos</Link>
        </nav>
        <button className="secondary" onClick={handleLogout}>Cerrar sesion</button>
      </aside>
      <main className="content"><Outlet /></main>
    </div>
  );
}
