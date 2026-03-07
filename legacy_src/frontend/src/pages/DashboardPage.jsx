import React, { useEffect, useState } from 'react';
import { getHealth, listCasesRequest } from '../services/api/client.js';

export default function DashboardPage() {
  const [health, setHealth] = useState(null);
  const [count, setCount] = useState(0);

  useEffect(() => {
    async function load() {
      setHealth(await getHealth());
      setCount((await listCasesRequest()).length);
    }
    load().catch(console.error);
  }, []);

  return (
    <section className="grid two-columns">
      <div className="card">
        <h2>Estado del backend</h2>
        <p className="muted">Verificacion basica de servicio y base de datos.</p>
        <pre>{JSON.stringify(health, null, 2)}</pre>
      </div>
      <div className="card">
        <h2>Resumen rapido</h2>
        <p>Total de casos visibles: <strong>{count}</strong></p>
        <p>Checklist vinculante: activo por reglas del backend.</p>
        <p>Proveedor IA: stub desacoplado para futuras integraciones.</p>
      </div>
    </section>
  );
}
