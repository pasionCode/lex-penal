import { getSession } from '../../store/auth-store.js';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api/v1';

async function request(path, options = {}) {
  const session = getSession();
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (session?.token) headers.Authorization = `Bearer ${session.token}`;

  const response = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  const data = await response.json();
  if (!response.ok) throw new Error(data.message || 'Error en la solicitud');
  return data.data ?? data;
}

export const loginRequest = (payload) => request('/auth/login', { method: 'POST', body: JSON.stringify(payload) });
export const getHealth = () => request('/health');
export const listCasesRequest = () => request('/cases');
export const createCaseRequest = (payload) => request('/cases', { method: 'POST', body: JSON.stringify(payload) });
export const getCaseChecklistRequest = (caseId) => request(`/checklist/${caseId}`);
export const saveCaseChecklistRequest = (caseId, payload) => request(`/checklist/${caseId}`, { method: 'PUT', body: JSON.stringify(payload) });
export const getCaseReportRequest = (caseId) => request(`/reports/${caseId}`);
