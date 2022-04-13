export const showAlert = (status: string, message: string) => {
  const rootElement = document.getElementById('alerts');
  if (!rootElement) return;

  const alert = document.createElement('div');
  alert.classList.add('flash');
  alert.classList.add(status);
  alert.innerHTML = message;
  rootElement.append(alert);
  setTimeout(() => alert.remove(), 2500);
}
