import React, { useEffect, useMemo, useState } from 'react';
import CasesPanel from '../features/cases/CasesPanel.jsx';
import ChecklistPanel from '../features/checklist/ChecklistPanel.jsx';
import ReportPanel from '../features/reports/ReportPanel.jsx';
import { createCaseRequest, getCaseChecklistRequest, getCaseReportRequest, listCasesRequest, saveCaseChecklistRequest } from '../services/api/client.js';

export default function CasesPage() {
  const [cases, setCases] = useState([]);
  const [selectedCaseId, setSelectedCaseId] = useState('');
  const [checklist, setChecklist] = useState([]);
  const [report, setReport] = useState('');

  async function loadCases() {
    const data = await listCasesRequest();
    setCases(data);
    if (!selectedCaseId && data[0]) setSelectedCaseId(data[0].id);
  }

  useEffect(() => { loadCases().catch(console.error); }, []);

  useEffect(() => {
    async function loadCaseArtifacts() {
      if (!selectedCaseId) return;
      setChecklist(await getCaseChecklistRequest(selectedCaseId));
      const reportData = await getCaseReportRequest(selectedCaseId);
      setReport(reportData.content);
    }
    loadCaseArtifacts().catch(console.error);
  }, [selectedCaseId]);

  async function handleCreate(payload) {
    await createCaseRequest(payload);
    await loadCases();
  }

  async function handleSaveChecklist(updatedChecklist) {
    setChecklist(updatedChecklist);
    await saveCaseChecklistRequest(selectedCaseId, updatedChecklist);
    const reportData = await getCaseReportRequest(selectedCaseId);
    setReport(reportData.content);
  }

  const selectedCase = useMemo(() => cases.find((item) => item.id === selectedCaseId), [cases, selectedCaseId]);

  return (
    <section className="grid cases-grid">
      <CasesPanel cases={cases} selectedCaseId={selectedCaseId} onSelect={setSelectedCaseId} onCreate={handleCreate} />
      <div className="grid">
        <div className="card"><h2>Detalle</h2><pre>{JSON.stringify(selectedCase, null, 2)}</pre></div>
        <ChecklistPanel checklist={checklist} onSave={handleSaveChecklist} />
        <ReportPanel report={report} />
      </div>
    </section>
  );
}
