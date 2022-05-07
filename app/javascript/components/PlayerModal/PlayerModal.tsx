import React, { useEffect, useState } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { TeamsPlayer } from 'entities';
import { Modal } from 'components/atoms';

import { seasonPlayerRequest } from './requests/seasonPlayerRequest';

interface PlayerModalProps {
  seasonId: string;
  playerId?: number;
  onClose: () => void;
}

export const PlayerModal = ({ seasonId, playerId, onClose }: PlayerModalProps): JSX.Element => {
  const [seasonPlayer, setSeasonPlayer] = useState<TeamsPlayer | undefined>();

  useEffect(() => {
    strings.setLanguage(currentLocale);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    const fetchSeasonPlayer = async () => {
      const data = await seasonPlayerRequest(seasonId, playerId);
      setSeasonPlayer(data);
    };

    if (playerId) fetchSeasonPlayer();
  }, [seasonId, playerId]);

  if (!seasonPlayer) return <></>;

  return (
    <Modal show={!!playerId}>
      <div className="button small modal-close" onClick={onClose}>
        X
      </div>
      <div className="player-header">
        <h2>{localizeValue(seasonPlayer.player.name)}</h2>
      </div>
      <div className="flex justify-between player-stats">
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.form}</p>
          <p>-</p>
        </div>
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.lastWeek}</p>
          <p>-</p>
        </div>
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.totalPoints}</p>
          <p>{seasonPlayer.player.points}</p>
        </div>
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.price}</p>
          <p>{seasonPlayer.price}</p>
        </div>
      </div>
      <h3>{strings.player.thisSeason}</h3>
      <h3>{strings.player.previousSeasons}</h3>
    </Modal>
  );
};
