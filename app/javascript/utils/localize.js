const currentLocale = document.getElementById("current_locale").value

function localizeValue(value) {
  if (value) return value[currentLocale] || value["en"]

  return value
}

function localizeRoute(value) {
  if (currentLocale === "en") return value

  return `/${currentLocale}${value}`
}

export { localizeValue, localizeRoute }
