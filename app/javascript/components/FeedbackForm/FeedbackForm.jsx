import React, { useState } from 'react';

import { currentLocale, csrfToken } from '../../helpers';
import { strings } from '../../locales';

import { Modal } from '../../components/atoms';
import { apiRequest } from '../../requests/helpers/apiRequest';

strings.setLanguage(currentLocale);

export const FeedbackForm = () => {
  const [pageState, setPageState] = useState({
    isOpen: false,
    title: '',
    description: '',
    errors: []
  });

  const onSubmit = async () => {
    const result = await apiRequest({
      url: '/api/frontend/feedback.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ feedback: { title: pageState.title, description: pageState.description } }),
      },
    });

    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({ ...pageState, isOpen: false });
  };

  return (
    <>
      <p
        className="user-navigation-link cursor-pointer"
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      >{strings.feedbackForm.create}</p>
      <Modal
        show={pageState.isOpen}
        onClose={() => setPageState({ ...pageState, isOpen: false })}
      >
        <h1 className="mb-8">{strings.feedbackForm.new}</h1>
        <p className="mb-4">{strings.feedbackForm.send}<a href="https://t.me/kortirso" target="_blank" rel="noopener noreferrer" className="simple-link">Telegram</a>{strings.feedbackForm.leave}</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <label className="form-label">{strings.feedbackForm.title}</label>
            <input
              className="form-value w-full"
              value={pageState.title}
              onChange={(e) => setPageState({ ...pageState, title: e.target.value })}
            />
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">{strings.feedbackForm.description}</label>
              <sup className="leading-4">*</sup>
            </p>
            <textarea
              rows="7"
              className="form-value w-full"
              value={pageState.description}
              onChange={(e) => setPageState({ ...pageState, description: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onSubmit}>{strings.feedbackForm.save}</p>
        </section>
      </Modal>
    </>
  );
};
