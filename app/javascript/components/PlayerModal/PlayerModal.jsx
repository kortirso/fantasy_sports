import React, { useEffect, useState } from 'react';

import { currentLocale, localizeValue } from '../../helpers';
import { strings } from '../../locales';
import { sportsData, statisticsOrder } from '../../data';

import { Modal } from '../../components/atoms';

import { seasonPlayerRequest } from './requests/seasonPlayerRequest';

strings.setLanguage(currentLocale);

export const PlayerModal = ({ sportKind, seasonUuid, playerUuid, teamNames, onClose }) => {
  const [seasonPlayer, setSeasonPlayer] = useState();
  const sportPositions = sportsData.positions[sportKind];

  useEffect(() => {
    const fetchSeasonPlayer = async () => {
      const data = await seasonPlayerRequest(seasonUuid, playerUuid);
      setSeasonPlayer(data);
    };

    if (playerUuid) fetchSeasonPlayer();
  }, [seasonUuid, playerUuid]);

  if (!seasonPlayer) return <></>;

  const perGamePoints = () => {
    const gamesAmount = seasonPlayer.games_players.data.length;
    if (gamesAmount === 0) return 0;

    const pointsAmount = seasonPlayer.games_players.data.map((game) => game.attributes.points).reduce((result, item) => result + item, 0)

    return Math.round(pointsAmount / gamesAmount);
  };

  const lastPoints = () => {
    const data = seasonPlayer.games_players.data;
    const lastGameData = data[data.length - 1];

    return lastGameData ? lastGameData.attributes.points : '-';
  };

  const renderSeasonGames = () => {
    return seasonPlayer.games_players.data.map((item) => {
      return (
        <tr key={item.attributes.uuid}>
          <td className="text-center border-b border-gray-200 py-2 px-4">{item.attributes.week.position}</td>
          <td className="text-center border-b border-gray-200 py-2 px-4">{localizeValue(teamNames[item.attributes.opponent_team.uuid].name)}</td>
          <td className="text-center border-b border-gray-200 py-2 px-4">{item.attributes.points}</td>
          {Object.keys(statisticsOrder[sportKind]).map((stat) => (
            <td className="text-center border-b border-gray-200 py-2 px-4" key={stat}>{item.attributes.statistic[stat]}</td>
          ))}
        </tr>
      );
    });
  };

  return (
    <Modal show={!!playerUuid} onClose={onClose}>
      <div className="mb-2">
        <span className="inline-block bg-zinc-800 text-white text-sm py-1 px-2 rounded mb-2">{localizeValue(sportPositions[seasonPlayer.player.position_kind].name)}</span>
        <h2 className="mb-2">{localizeValue(seasonPlayer.player.name)}</h2>
        <p className="text-sm">{localizeValue(seasonPlayer.team.name)}</p>
      </div>
      <div className="flex justify-between mb-8 bg-gray-200 rounded shadow">
        <div className="flex-1 py-3 px-0 border-r border-gray-300 flex flex-col items-center">
          <p className="text-sm">{strings.player.form}</p>
          <p className="mt-1">{seasonPlayer.form}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-r border-gray-300 flex flex-col items-center">
          <p className="text-sm">{strings.player.poinstPerGame}</p>
          <p className="mt-1">{perGamePoints()}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-r border-gray-300 flex flex-col items-center">
          <p className="text-sm">{strings.player.lastWeek}</p>
          <p className="mt-1">{lastPoints()}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-r border-gray-300 flex flex-col items-center">
          <p className="text-sm">{strings.player.totalPoints}</p>
          <p className="mt-1">{seasonPlayer.player.points}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-r border-gray-300 flex flex-col items-center">
          <p className="text-sm">{strings.player.price}</p>
          <p className="mt-1">{seasonPlayer.price}</p>
        </div>
        <div className="flex-1 py-3 px-0 flex flex-col items-center">
          <p className="text-sm">{strings.player.teamsSelectedBy}</p>
          <p className="mt-1">{seasonPlayer.teams_selected_by}%</p>
        </div>
      </div>
      <div className="w-full overflow-x-scroll">
        <h3>{strings.player.thisSeason}</h3>
        {seasonPlayer.games_players.data.length === 0 ? (
          <p>{strings.player.noSeasonGames}</p>
        ) : (
          <table cellSpacing="0" className="min-w-full">
            <thead>
              <tr className="bg-gray-200">
                <th className="text-sm py-2 px-4">{strings.player.week}</th>
                <th className="text-sm py-2 px-4">{strings.player.opponent}</th>
                <th className="text-sm py-2 px-4">{strings.player.pts}</th>
                {Object.entries(statisticsOrder[sportKind]).map(([stat, value]) => (
                  <th className="tooltip text-sm py-2 px-4" key={stat}>
                    {stat}
                    <span className="tooltiptext">{localizeValue(value)}</span>
                  </th>
                ))}
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
