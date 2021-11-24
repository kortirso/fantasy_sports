const currentLocale = document.getElementById("current_locale").value

function localizeValue(value) {
  return value[currentLocale] || value['en']
}

export { localizeValue }
