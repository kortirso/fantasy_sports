import React, { useState } from 'react';

import { currentLocale, csrfToken } from '../../helpers';
import { strings } from '../../locales';

import { Modal } from '../../components/atoms';
import { apiRequest } from '../../requests/helpers/apiRequest';

strings.setLanguage(currentLocale);

export const FantasyLeagueForm = ({ uuid }) => {
  const [pageState, setPageState] = useState({
    isOpen: false,
    name: '',
    errors: []
  });

  const onSubmit = async () => {
    const result = await apiRequest({
      url: `/api/frontend/fantasy_teams/${uuid}/fantasy_leagues.json`,
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ fantasy_league: { name: pageState.name } }),
      },
    });

    if (result.errors.length > 0) setPageState({ ...pageState, errors: result.errors });
    else window.location = `/fantasy_teams/${uuid}/fantasy_leagues`;
  };

  return (
    <>
      <p
        className="btn-primary mt-4"
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      >{strings.fantasyLeagueForm.create}</p>
      <Modal
        size="auto"
        show={pageState.isOpen}
        onClose={() => setPageState({ ...pageState, isOpen: false })}
      >
        <h1 className="mb-8 pr-8">{strings.fantasyLeagueForm.new}</h1>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">{strings.fantasyLeagueForm.name}</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.name}
              onChange={(e) => setPageState({ ...pageState, name: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onSubmit}>{strings.fantasyLeagueForm.save}</p>
        </section>
      </Modal>
    </>
  );
};
