import React, { useEffect, useState } from 'react';

import { currentLocale, localizeValue, convertDateTime, convertDate, currentWatches, csrfToken } from '../../helpers';
import { strings } from '../../locales';
import { sportsData, statisticsOrder } from '../../data';

import { Modal } from '../../components/atoms';

import { seasonPlayerRequest } from './requests/seasonPlayerRequest';
import { apiRequest } from '../../requests/helpers/apiRequest';

strings.setLanguage(currentLocale);

export const PlayerModal = ({ sportKind, seasonUuid, playerUuid, teamNames, onClose }) => {
  const [pageState, setPageState] = useState({
    seasonPlayer: undefined,
    renderMode: 'history',
    watches: currentWatches,
    errors: []
  });

  const sportPositions = sportsData.positions[sportKind];

  useEffect(() => {
    const fetchSeasonPlayer = async () => {
      const data = await seasonPlayerRequest(seasonUuid, playerUuid);
      setPageState({ ...pageState, seasonPlayer: data, renderMode: 'history' });
    };

    if (playerUuid) fetchSeasonPlayer();
    else setPageState({ ...pageState, seasonPlayer: undefined, renderMode: 'history' });
  }, [seasonUuid, playerUuid]); // eslint-disable-line react-hooks/exhaustive-deps

  if (!pageState.seasonPlayer) return <></>;

  const addToWatchlist = async (uuid) => {
    const result = await apiRequest({
      url: `/api/frontend/players_seasons/${uuid}/watches.json`,
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        }
      },
    });

    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({ ...pageState, watches: pageState.watches.concat(uuid) });
  };

  const removeFromWatchlist = async (uuid) => {
    const result = await apiRequest({
      url: `/api/frontend/players_seasons/${uuid}/watches.json`,
      options: {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        }
      },
    });

    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({ ...pageState, watches: pageState.watches.filter((item) => item !== uuid) });
  };

  const gameHomeLabel = (is_home_game) => is_home_game ? 'H' : 'A';

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
    return pageState.seasonPlayer.games_players.data.map((item) => {
      return (
        <tr key={item.attributes.uuid}>
          <td className="text-center border-b border-stone-200 py-2 px-4">{item.attributes.week.position}</td>
          <td className="text-center border-b border-stone-200 py-2 px-4 whitespace-nowrap">
            {localizeValue(teamNames[item.attributes.opponent_team.uuid].name)} ({gameHomeLabel(item.attributes.team.is_home_game)}) {gamePoints(item)}
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
    <tr key={`overall-${pageState.seasonPlayer.uuid}`}>
      <td className="text-center border-b border-stone-200 py-2 px-4"></td>
      <td className="text-center border-b border-stone-200 py-2 px-4 whitespace-nowrap">{strings.player.total}</td>
      <td className="text-center border-b border-stone-200 py-2 px-1"></td>
      <td className="text-center border-b border-stone-200 py-2 px-4">{pageState.seasonPlayer.points}</td>
      {Object.keys(statisticsOrder[sportKind]).map((stat) => (
        <td className="text-center border-b border-stone-200 py-2 px-4" key={stat}>{pageState.seasonPlayer.statistic[stat]}</td>
      ))}
    </tr>
  );

  const renderFixtures = () => {
    return pageState.seasonPlayer.fixtures.map((item) => {
      return (
        <tr key={item.uuid}>
          <td className="text-center border-b border-stone-200 py-2 px-4">{convertDateTime(item.start_at)}</td>
          <td className="text-center border-b border-stone-200 py-2 px-4">{item.week_position}</td>
          <td className="text-center border-b border-stone-200 py-2 px-4 whitespace-nowrap">
            {localizeValue(teamNames[item.opponent_team_uuid].name)} ({gameHomeLabel(item.is_home_game)})
          </td>
          <td className="text-center border-b border-stone-200 py-1 px-2">{renderDifficulty(item.difficulty)}</td>
        </tr>
      );
    });
  };

  const renderDifficulty = (value) => {
    if (value === 5) return <span className="bg-orange-700 border border-orange-800 py-1 px-2 rounded text-sm text-white">{value}</span>;
    if (value === 4) return <span className="bg-amber-300 border border-amber-400 py-1 px-2 rounded text-sm">{value}</span>;
    if (value === 3) return <span className="bg-stone-300 border border-stone-400 py-1 px-2 rounded text-sm">{value}</span>;
    if (value === 2) return <span className="bg-green-300 border border-green-400 py-1 px-2 rounded text-sm">{value}</span>;
  };

  const injuryLevelClass = (data) => {
    if (data.status === 0) return 'bg-orange-700 border border-orange-800 text-white';
    return 'bg-amber-200 border border-amber-300';
  }

  const renderReturnAt = (data) => {
    if (data.return_at === null) return <></>;

    return `, ${strings.player.expected} ${convertDate(data.return_at)}`;
  };

  const renderInjury = () => {
    if (pageState.seasonPlayer.injury === null) return <></>;

    const data = pageState.seasonPlayer.injury.data.attributes;
    return (
      <div className={`text-center mb-2 py-1 px-4 rounded ${injuryLevelClass(data)}`}>
        {localizeValue(data.reason)}, {data.status}{strings.player.chance}{renderReturnAt(data)}
      </div>
    )
  };

  return (
    <Modal show={!!playerUuid} size='player' onClose={onClose}>
      <div className="relative mb-2">
        {renderInjury()}
        <span className="badge-dark inline-block mb-2">{localizeValue(sportPositions[pageState.seasonPlayer.player.position_kind].name)}</span>
        <h2 className="mb-2">{localizeValue(pageState.seasonPlayer.player.name)}</h2>
        <p className="text-sm">{localizeValue(pageState.seasonPlayer.team.name)}</p>
        {pageState.watches.includes(pageState.seasonPlayer.uuid) ? (
          <p
            className="btn-primary btn-small absolute right-0 bottom-0"
            onClick={() => removeFromWatchlist(pageState.seasonPlayer.uuid)}
          >{strings.player.removeFromWatchlist}</p>
        ) : (
          <p
            className="btn-primary btn-small absolute right-0 bottom-0"
            onClick={() => addToWatchlist(pageState.seasonPlayer.uuid)}
          >{strings.player.addToWatchlist}</p>
        )}
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-5 justify-between mb-8 bg-stone-200 border border-stone-300 rounded">
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.form}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{pageState.seasonPlayer.form}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 md:border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.poinstPerGame}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{pageState.seasonPlayer.average_points}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.totalPoints}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{pageState.seasonPlayer.points}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b lg:border-b-0 md:border-r border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.price}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{pageState.seasonPlayer.team.price}</p>
        </div>
        <div className="flex-1 py-3 px-0 border-b-0 border-r lg:border-r-0 border-stone-300 flex lg:flex-col justify-center items-center">
          <p className="text-xs sm:text-sm">{strings.player.teamsSelectedBy}</p>
          <p className="ml-2 lg:ml-0 lg:mt-1 text-sm sm:text-base">{pageState.seasonPlayer.teams_selected_by}%</p>
        </div>
      </div>
      <div className="w-full">
        <div className="flex flex-row">
          <h3
            className={`cursor-pointer mr-4 ${pageState.renderMode === 'history' ? 'underline' : ''}`}
            onClick={() => setPageState({ ...pageState, renderMode: 'history' })}
          >
            {strings.player.thisSeason}
          </h3>
          <h3
            className={`cursor-pointer ${pageState.renderMode === 'fixtures' ? 'underline' : ''}`}
            onClick={() => setPageState({ ...pageState, renderMode: 'fixtures' })}
          >
            {strings.player.fixtures}
          </h3>
        </div>
        {pageState.renderMode === 'history' ? (
          <div className="w-full overflow-x-scroll">
            {pageState.seasonPlayer.games_players.data.length === 0 ? (
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
        ) : null}
        {pageState.renderMode === 'fixtures' ? (
          <div className="w-full overflow-x-scroll">
            {pageState.seasonPlayer.fixtures.length === 0 ? (
              <p>{strings.player.noFixtures}</p>
            ) : (
              <table cellSpacing="0" className="min-w-full">
                <thead>
                  <tr className="bg-stone-200">
                    <th className="text-sm py-2 px-4">{strings.player.startAt}</th>
                    <th className="text-sm py-2 px-4">{strings.player.week}</th>
                    <th className="text-sm py-2 px-4">{strings.player.opponent}</th>
                    <th className="text-sm py-2 px-4">{strings.player.difficulty}</th>
                  </tr>
                </thead>
                <tbody>
                  {renderFixtures()}
                </tbody>
              </table>
            )}
          </div>
        ) : null}
      </div>
      {false ? <h3>{strings.player.previousSeasons}</h3> : null}
    </Modal>
  );
};
