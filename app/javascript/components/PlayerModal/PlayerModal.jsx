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
    else setSeasonPlayer(undefined);
  }, [seasonUuid, playerUuid]);

  if (!seasonPlayer) return <></>;

  const gameHomeLabel = (item) => item.attributes.team.is_home_game ? 'H' : 'A';

  const gamePoints = (item) => {
    const points = item.attributes.team.points;

    if (points.length === 0) return '';
    else return `${item.attributes.team.points[0]} - ${item.attributes.team.points[1]}`;
  }

  const gameResult = (item) => {
    const game_result = item.attributes.team.game_result;

    if (game_result === null) return '';
    if (game_result === 'W') return <span className="px-1 rounded bg-green-400 border border-green-500 text-white text-sm">W</span>;
    if (game_result === 'L') return <span className="px-1 rounded bg-red-400 border border-red-500 text-white text-sm">L</span>;
    if (game_result === 'D') return <span className="px-1 rounded bg-stone-400 border border-stone-500 text-white text-sm">D</span>;
  }

  const renderSeasonGames = () => {
    return seasonPlayer.games_players.data.map((item) => {
      return (
        <tr key={item.attributes.uuid}>
          <td className="text-center border-b border-stone-200 py-2 px-4">{item.attributes.week.position}</td>
          <td className="text-center border-b border-stone-200 py-2 px-4 whitespace-nowrap">
            {localizeValue(teamNames[item.attributes.opponent_team.uuid].name)} ({gameHomeLabel(item)}) {gamePoints(item)}
          </td>
          <td className="text-center border-b border-stone-200 py-2 px-1">{gameResult(item)}</td>
          <td className="text-center border-b border-stone-200 py-2 px-4">{item.attributes.points}</td>
          {Object.keys(statisticsOrder[sportKind]).map((stat) => (
            <td className="text-center border-b border-stone-200 py-2 px-4" key={stat}>{item.attributes.statistic[stat]}</td>
          ))}
        </tr>
      );
    });
  };

  const renderOverallStatistic = () => (
    <tr key={`overall-${seasonPlayer.uuid}`}>
      <td className="text-center border-b border-stone-200 py-2 px-4"></td>
      <td className="text-center border-b border-stone-200 py-2 px-4 whitespace-nowrap">{strings.player.total}</td>
      <td className="text-center border-b border-stone-200 py-2 px-1"></td>
      <td className="text-center border-b border-stone-200 py-2 px-4">{seasonPlayer.points}</td>
      {Object.keys(statisticsOrder[sportKind]).map((stat) => (
        <td className="text-center border-b border-stone-200 py-2 px-4" key={stat}>{seasonPlayer.statistic[stat]}</td>
      ))}
    </tr>
  )

  return (
    <Modal show={!!playerUuid} onClose={onClose}>
      <div className="mb-2">
        <span className="badge-dark inline-block mb-2">{localizeValue(sportPositions[seasonPlayer.player.position_kind].name)}</span>
        <h2 className="mb-2">{localizeValue(seasonPlayer.player.name)}</h2>
        <p className="text-sm">{localizeValue(seasonPlayer.team.name)}</p>
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-5 justify-between mb-8 bg-stone-200 border border-stone-300 rounded">
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.form}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{seasonPlayer.form}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 md:border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.poinstPerGame}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{seasonPlayer.average_points}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.totalPoints}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{seasonPlayer.points}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 md:border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.price}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{seasonPlayer.team.price}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b-0 border-r lg:border-r-0 border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.teamsSelectedBy}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{seasonPlayer.teams_selected_by}%</p>
        </div>
      </div>
      <div className="w-full overflow-x-scroll">
        <h3>{strings.player.thisSeason}</h3>
        {seasonPlayer.games_players.data.length === 0 ? (
          <p>{strings.player.noSeasonGames}</p>
        ) : (
          <table cellSpacing="0" className="min-w-full">
            <thead>
              <tr className="bg-stone-200">
                <th className="text-sm py-2 px-4">{strings.player.week}</th>
                <th className="text-sm py-2 px-4">{strings.player.opponent}</th>
                <th></th>
                <th className="text-sm py-2 px-4">{strings.player.pts}</th>
                {Object.entries(statisticsOrder[sportKind]).map(([stat, value]) => (
                  <th className="tooltip text-sm py-2 px-4" key={stat}>
                    {stat}
                    <span className="tooltiptext">{localizeValue(value)}</span>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {renderSeasonGames()}
              {renderOverallStatistic()}
            </tbody>
          </table>
        )}
      </div>
      {false ? <h3>{strings.player.previousSeasons}</h3> : null}
    </Modal>
  );
};
