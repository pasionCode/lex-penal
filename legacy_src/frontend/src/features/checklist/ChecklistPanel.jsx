import React from 'react';

export default function ChecklistPanel({ checklist, onSave }) {
  function toggle(key) {
    const updated = checklist.map((block) => block.key === key ? { ...block, completed: !block.completed } : block);
    onSave(updated);
  }

  return (
    <div className="card">
      <h2>Checklist vinculante</h2>
      <div className="grid">
        {checklist.map((block) => (
          <label key={block.key} className="check-item">
            <input type="checkbox" checked={Boolean(block.completed)} onChange={() => toggle(block.key)} />
            <span>{block.label}</span>
          </label>
        ))}
      </div>
    </div>
  );
}
