import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { loginRequest } from '../services/api/client.js';
import { saveSession } from '../store/auth-store.js';

export default function LoginPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ email: 'admin@lexpenal.local', password: 'ChangeMe123!' });
  const [error, setError] = useState('');

  async function handleSubmit(event) {
    event.preventDefault();
    setError('');
    try {
      const result = await loginRequest(form);
      saveSession(result);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message || 'No fue posible iniciar sesion');
    }
  }

  return (
    <div className="centered-card">
      <div className="card">
        <h1>Ingreso LexPenal</h1>
        <p className="muted">Bootstrap funcional del sistema.</p>
        <form onSubmit={handleSubmit} className="grid">
          <label>Correo<input value={form.email} onChange={(e) => setForm((prev) => ({ ...prev, email: e.target.value }))} /></label>
          <label>Clave<input type="password" value={form.password} onChange={(e) => setForm((prev) => ({ ...prev, password: e.target.value }))} /></label>
          {error ? <div className="error-box">{error}</div> : null}
          <button type="submit">Ingresar</button>
        </form>
      </div>
    </div>
  );
}
