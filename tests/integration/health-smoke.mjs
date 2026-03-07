const baseUrl = process.env.LEXPENAL_API_URL || 'http://localhost:8080/api/v1';
const response = await fetch(`${baseUrl}/health`);
const payload = await response.json();
if (!response.ok || payload.ok !== true) {
  console.error('Health check fallido', payload);
  process.exit(1);
}
console.log('Health check OK', payload);
