import React, { useEffect, useState } from 'react';

import type { TeamNames } from 'entities';
import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { TeamsPlayer } from 'entities';
import { statisticsOrder } from 'data/players';
import { Modal } from 'components/atoms';

import { seasonPlayerRequest } from './requests/seasonPlayerRequest';

interface PlayerModalProps {
  sportKind: string;
  seasonUuid: string;
  playerUuid?: string;
  teamNames: TeamNames;
  onClose: () => void;
}

strings.setLanguage(currentLocale);

export const PlayerModal = ({
  sportKind,
  seasonUuid,
  playerUuid,
  teamNames,
  onClose,
}: PlayerModalProps): JSX.Element => {
  const [seasonPlayer, setSeasonPlayer] = useState<TeamsPlayer | undefined>();

  useEffect(() => {
    const fetchSeasonPlayer = async () => {
      const data = await seasonPlayerRequest(seasonUuid, playerUuid);
      setSeasonPlayer(data);
    };

    if (playerUuid) fetchSeasonPlayer();
  }, [seasonUuid, playerUuid]);

  if (!seasonPlayer) return <></>;

  const lastPoints = () => {
    const data = seasonPlayer.games_players.data;
    const lastGameData = data[data.length - 1];

    return lastGameData.attributes.points;
  };

  const renderSeasonGames = () => {
    return seasonPlayer.games_players.data.map((item) => {
      return (
        <tr key={item.attributes.uuid}>
          <td>{item.attributes.week.position}</td>
          <td>{localizeValue(teamNames[item.attributes.opponent_team.uuid].name)}</td>
          <td>{item.attributes.points}</td>
          {Object.keys(statisticsOrder[sportKind]).map((stat: string) => (
            <td key={stat}>{item.attributes.statistic[stat]}</td>
          ))}
          <td></td>
        </tr>
      );
    });
  };

  return (
    <Modal show={!!playerUuid}>
      <div className="button small modal-close" onClick={onClose}>
        X
      </div>
      <div className="player-header">
        <h2>{localizeValue(seasonPlayer.player.name)}</h2>
      </div>
      <div className="flex justify-between player-stats">
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.form}</p>
          <p>{seasonPlayer.form}</p>
        </div>
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.lastWeek}</p>
          <p>{lastPoints()}</p>
        </div>
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.totalPoints}</p>
          <p>{seasonPlayer.player.points}</p>
        </div>
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.price}</p>
          <p>{seasonPlayer.price}</p>
        </div>
        <div className="player-stat flex flex-col items-center">
          <p>{strings.player.teamsSelectedBy}</p>
          <p>{seasonPlayer.teams_selected_by}%</p>
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
      {false ? <h3>{strings.player.previousSeasons}</h3> : null}
    </Modal>
  );
};
