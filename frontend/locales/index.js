import { addLocale, useLocale } from "ttag"

const locale = document.getElementById("current_locale").value || "en"

if (locale !== "en") {
  const translationObj = require(`./${locale}.po.json`)
  addLocale(locale, translationObj)
  useLocale(locale)
}
