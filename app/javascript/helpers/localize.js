const DEFAULT_LOCALE = 'en';

export const currentLocale = document.getElementById('current_locale').value || DEFAULT_LOCALE;

export const localizeValue = (value) => {
  if (!value) return '';

  return value[currentLocale] || value[DEFAULT_LOCALE];
};
