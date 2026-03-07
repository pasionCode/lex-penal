export const DEFAULT_CHECKLIST_BLOCKS = [
  { key: 'ficha', label: 'Ficha del caso', required: true, completed: false, notes: '' },
  { key: 'hechos', label: 'Hechos juridicamente relevantes', required: true, completed: false, notes: '' },
  { key: 'pruebas', label: 'Inventario y valoracion preliminar de pruebas', required: true, completed: false, notes: '' },
  { key: 'calificacion', label: 'Calificacion juridica provisional', required: true, completed: false, notes: '' },
  { key: 'estrategia', label: 'Hipotesis y estrategia de defensa', required: true, completed: false, notes: '' },
  { key: 'riesgos', label: 'Riesgos y contingencias', required: true, completed: false, notes: '' },
  { key: 'informe', label: 'Informe final revisado', required: true, completed: false, notes: '' }
];

export function cloneDefaultChecklist() {
  return DEFAULT_CHECKLIST_BLOCKS.map((block) => ({ ...block }));
}
