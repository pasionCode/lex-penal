export function getMissingRequiredChecklistBlocks(checklist = []) {
  return checklist.filter((block) => block.required && !block.completed);
}

export function canAdvanceToClosure(checklist = []) {
  return getMissingRequiredChecklistBlocks(checklist).length === 0;
}
