import React, { useState } from 'react';

import { currentLocale, csrfToken } from '../../helpers';
import { strings } from '../../locales';

import { Modal } from '../../components/atoms';
import { apiRequest } from '../../requests/helpers/apiRequest';

strings.setLanguage(currentLocale);

export const OraculForm = ({ placeName, placeId, leagueBackground, sportKind }) => {
  const [pageState, setPageState] = useState({
    isOpen: false,
    name: '',
    errors: []
  });

  const onSubmit = async () => {
    const result = await apiRequest({
      url: '/api/frontend/oracul.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ oracul: { name: pageState.name }, oracul_place_id: placeId }),
      },
    });

    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else window.location.reload();
  };

  return (
    <>
      <div
        className="season-link flex flex-col justify-between bg-white rounded overflow-hidden border border-stone-300 cursor-pointer"
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      >
        <img src={leagueBackground} alt="league-background" className="season-link-background" />
        <div className="season-link-content">
          <img src={sportKind} alt="league-background" className="season-link-sport" />
        </div>
        <div class="text-center py-1 border-t border-stone-300">
          <strong>{placeName}</strong>
        </div>
      </div>
      <Modal
        show={pageState.isOpen}
        onClose={() => setPageState({ ...pageState, isOpen: false })}
      >
        <h1 className="mb-8">{strings.oraculForm.new}</h1>
        <p className="mb-4">{strings.oraculForm.description}</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <label className="form-label">{strings.oraculForm.name}</label>
            <input
              className="form-value w-full"
              value={pageState.name}
              onChange={(e) => setPageState({ ...pageState, name: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onSubmit}>{strings.oraculForm.save}</p>
        </section>
      </Modal>
    </>
  );
};
