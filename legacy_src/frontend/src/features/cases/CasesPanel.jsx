import React, { useState } from 'react';
import StatusBadge from '../../components/StatusBadge.jsx';

export default function CasesPanel({ cases, selectedCaseId, onSelect, onCreate }) {
  const [form, setForm] = useState({ title: '', client_name: '', risk_level: 'medium' });

  async function handleSubmit(event) {
    event.preventDefault();
    if (!form.title || !form.client_name) return;
    await onCreate(form);
    setForm({ title: '', client_name: '', risk_level: 'medium' });
  }

  return (
    <div className="card">
      <h2>Casos</h2>
      <form onSubmit={handleSubmit} className="grid">
        <label>Titulo<input value={form.title} onChange={(e) => setForm((prev) => ({ ...prev, title: e.target.value }))} /></label>
        <label>Cliente<input value={form.client_name} onChange={(e) => setForm((prev) => ({ ...prev, client_name: e.target.value }))} /></label>
        <label>Riesgo<select value={form.risk_level} onChange={(e) => setForm((prev) => ({ ...prev, risk_level: e.target.value }))}>
          <option value="low">low</option>
          <option value="medium">medium</option>
          <option value="high">high</option>
          <option value="critical">critical</option>
        </select></label>
        <button type="submit">Crear caso</button>
      </form>
      <div className="list">
        {cases.map((item) => (
          <button key={item.id} className={`list-item ${selectedCaseId === item.id ? 'active' : ''}`} onClick={() => onSelect(item.id)}>
            <div><strong>{item.code}</strong><p>{item.title}</p><small>{item.client_name}</small></div>
            <StatusBadge value={item.status} />
          </button>
        ))}
      </div>
    </div>
  );
}
