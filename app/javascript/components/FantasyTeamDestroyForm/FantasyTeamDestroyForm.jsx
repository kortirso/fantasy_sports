import React, { useState } from 'react';

import { currentLocale, csrfToken } from '../../helpers';
import { strings } from '../../locales';

import { Modal } from '../../components/atoms';
import { apiRequest } from '../../requests/helpers/apiRequest';

strings.setLanguage(currentLocale);

export const FantasyTeamDestroyForm = ({ uuid }) => {
  const [pageState, setPageState] = useState({
    isOpen: false,
    errors: []
  });

  const onSubmit = async () => {
    const result = await apiRequest({
      url: `/api/frontend/fantasy_teams/${uuid}.json`,
      options: {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        }
      },
    });

    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else window.location = result.redirect_path;
  };

  return (
    <>
      <p
        className="btn-primary mt-4"
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      >{strings.fantasyTeamDestroyForm.button}</p>
      <Modal
        show={pageState.isOpen}
        onClose={() => setPageState({ ...pageState, isOpen: false })}
      >
        <h1 className="mb-4 pr-8">{strings.fantasyTeamDestroyForm.title}</h1>
        <p className="pr-8">{strings.fantasyTeamDestroyForm.description}</p>
        {pageState.errors.length > 0 ? (
          <p className="text-sm text-orange-600">{pageState.errors}</p>
        ) : null}
        <p className="btn-primary mt-4" onClick={onSubmit}>
          {strings.fantasyTeamDestroyForm.destroy}
        </p>
      </Modal>
    </>
  );
};
