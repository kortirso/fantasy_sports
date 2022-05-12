import React, { useEffect, useState } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { TeamsPlayer } from 'entities';
import { statisticsOrder } from 'data/players';
import { Modal } from 'components/atoms';

import { seasonPlayerRequest } from './requests/seasonPlayerRequest';

interface PlayerModalProps {
  sportKind: string;
  seasonId: string;
  playerId?: number;
  onClose: () => void;
}

export const PlayerModal = ({
  sportKind,
  seasonId,
  playerId,
  onClose,
}: PlayerModalProps): JSX.Element => {
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

  const renderSeasonGames = () => {
    return seasonPlayer?.games_players?.data?.map((item) => {
      return (
        <tr key={item.attributes.id}>
          <td>{item.attributes.week.position}</td>
          <td></td>
          <td>{item.attributes.points}</td>
          {Object.keys(statisticsOrder[sportKind]).map((stat: string) => (
            <td key={stat}>{item.attributes.statistic[stat]}</td>
          ))}
          <td></td>
        </tr>
      );
    });
  };

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
      <div className="player-modal-table">
        <h3>{strings.player.thisSeason}</h3>
        {seasonPlayer.games_players.data.length === 0 ? (
          <p>{strings.player.noSeasonGames}</p>
        ) : (
          <table cellSpacing="0">
            <thead>
              <tr>
                <th>GW</th>
                <th>Opponent</th>
                <th>Pts</th>
                {Object.entries(statisticsOrder[sportKind]).map(([stat, value]) => (
                  <th className="tooltip" key={stat}>
                    {stat}
                    <span className="tooltiptext">{value}</span>
                  </th>
                ))}
                <th>Price</th>
              </tr>
            </thead>
            <tbody>{renderSeasonGames()}</tbody>
          </table>
        )}
      </div>
      <h3>{strings.player.previousSeasons}</h3>
    </Modal>
  );
};
