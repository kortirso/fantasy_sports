import { i18n } from '@lingui/core';
import { messages as messagesEn } from 'locales/en/messages.js';
import { messages as messagesRu } from 'locales/ru/messages.js';
import { en, ru } from 'make-plural/plurals';

import { currentLocale } from 'helpers';

i18n.load({
  en: messagesEn,
  ru: messagesRu,
});

i18n.loadLocaleData({
  en: { plurals: en },
  ru: { plurals: ru },
});

i18n.activate(currentLocale);

export default i18n;
