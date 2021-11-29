const currentLocale = document.getElementById("current_locale").value

function localizeValue(value) {
  if (value) return value[currentLocale] || value['en']
  return value
}

export { localizeValue }
