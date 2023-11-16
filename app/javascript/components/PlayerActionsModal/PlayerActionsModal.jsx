import React from 'react';

import { currentLocale, localizeValue } from '../../helpers';
import { strings } from '../../locales';

import { Modal } from '../../components/atoms';

strings.setLanguage(currentLocale);

export const PlayerActionsModal = ({ lineupPlayer, onMakeCaptain, onClose }) => {
  if (!lineupPlayer) return <></>;

  return (
    <Modal show={!!lineupPlayer} onClose={onClose}>
      <h2 className="pr-8">{localizeValue(lineupPlayer.player.name)}</h2>
      {onMakeCaptain ? (
        <div className="flex flex-col items-start">
          <button className="btn-primary mb-2" onClick={() => onMakeCaptain(lineupPlayer, 'captain')}>
            {strings.playerActions.makeCaptain}
          </button>
          <button className="btn-primary" onClick={() => onMakeCaptain(lineupPlayer, 'assistant')}>
            {strings.playerActions.makeAssistant}
          </button>
        </div>
      ) : null}
    </Modal>
  );
};
