import React from 'react';

import { LineupPlayer } from 'entities';
import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { Modal } from 'components/atoms';

interface PlayerActionsModalProps {
  lineupPlayer?: LineupPlayer;
  onMakeCaptain?: (lineupPlayerUuid: string, status: string) => void;
  onClose: () => void;
}

strings.setLanguage(currentLocale);

export const PlayerActionsModal = ({
  lineupPlayer,
  onMakeCaptain,
  onClose,
}: PlayerActionsModalProps): JSX.Element => {
  if (!lineupPlayer) return <></>;

  return (
    <Modal show={!!lineupPlayer}>
      <div className="button small modal-close" onClick={onClose}>
        X
      </div>
      <div className="player-header">
        <h2>{localizeValue(lineupPlayer.player.name)}</h2>
      </div>
      {onMakeCaptain ? (
        <div className="flex flex-col items-start">
          <button className="button" onClick={() => onMakeCaptain(lineupPlayer.uuid, 'captain')}>
            Make captain
          </button>
          <button className="button" onClick={() => onMakeCaptain(lineupPlayer.uuid, 'assistant')}>
            Make captain assistant
          </button>
        </div>
      ) : null}
    </Modal>
  );
};
