import React from 'react';

export default function ReportPanel({ report }) {
  return (
    <div className="card">
      <h2>Informe</h2>
      <pre className="report-box">{report || 'Seleccione un caso para cargar el informe.'}</pre>
    </div>
  );
}
