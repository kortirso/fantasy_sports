function showAlerts(status, message) {
  const alert = document.createElement("div")
  alert.classList.add("flash")
  alert.classList.add(status)
  alert.innerHTML = message
  document.getElementById("alerts").append(alert)
  setTimeout(() => alert.remove(), 2500)
}

export { showAlerts }
