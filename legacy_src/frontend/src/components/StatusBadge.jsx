import React from 'react';

export default function StatusBadge({ value }) {
  return <span className={`badge badge-${value || 'draft'}`}>{value}</span>;
}
