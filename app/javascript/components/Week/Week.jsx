import React, { useState, useEffect } from 'react';

import { currentLocale, convertDateTime, convertDate, fetchFromCache } from '../../helpers';
import { strings } from '../../locales';
import { Arrow } from '../../assets';

import { Game } from './Game';
import { weekRequest } from './requests/weekRequest';
import { gamesRequest } from './requests/gamesRequest';

strings.setLanguage(currentLocale);

export const Week = ({ id, teamNames }) => {
  const [pageState, setPageState] = useState({
    loading: true,
    week: null,
    games: [],
    collapseData: {},
  });
  const [weekId, setWeekId] = useState(id);

  useEffect(() => {
    const fetchWeek = async () =>
      await fetchFromCache(`week_${weekId}`, () =>
        weekRequest(weekId)
      );

    const fetchGames = async () => gamesRequest(weekId);

    Promise.all([fetchWeek(), fetchGames()]).then(([weekData, gamesData]) => {
      const groupedGames = gamesData.reduce((result, game) => {
        const convertedTime = convertDate(game.start_at);

        if (result[convertedTime] === undefined) result[convertedTime] = [game];
        else result[convertedTime].push(game);
        return result;
      }, {});

      const collapseData = {}
      let previousKey = null;
      Object.entries(groupedGames).forEach(([key, games], index) => {
        collapseData[key] = false;

        if (index > 0) {
          if (games[0].points.length > 0) {
            collapseData[previousKey] = true;
          }
        }
        previousKey = key;
      })

      setPageState({
        loading: false,
        week: weekData,
        games: groupedGames,
        collapseData: collapseData
      })
    });
  }, [weekId]);

  const renderGames = (games) => {
    return games.map((game, index) => <Game item={game} teamNames={teamNames} last={index === games.length - 1} />);
  };

  const toggleGameDay = (key) => {
    setPageState({ ...pageState, collapseData: { ...pageState.collapseData, [key]: !pageState.collapseData[key] } });
  };

  if (pageState.loading || pageState.week === null) return <></>;

  return (
    <div>
      <div className="flex justify-between items-center my-4 mx-0">
        <div className="w-48">
          {pageState.week.previous_id ? (
            <button
              className="btn-primary btn-small w-full"
              onClick={() => setWeekId(pageState.week.previous_id)}
            >
              {strings.week.previous}
            </button>
          ) : null}
        </div>
        <div className="text-center">
          <p>
            <span className="font-semibold">{strings.week.gameweek} {pageState.week.position}</span>: {convertDateTime(pageState.week.deadline_at)}
          </p>
          <p className="text-sm">{strings.week.localTime}</p>
        </div>
        <div className="w-48">
          {pageState.week.next_id ? (
            <button
              className="btn-primary btn-small w-full"
              onClick={() => setWeekId(pageState.week.next_id)}
            >
              {strings.week.next}
            </button>
          ) : null}
        </div>
      </div>
      <div>
        {Object.entries(pageState.games).map(([key, games]) => (
          <div key={key}>
            <div
              className={`py-1 px-0 bg-stone-200 border border-stone-300 flex justify-between items-center rounded cursor-pointer ${pageState.collapseData[key] ? 'mb-2' : null}`}
              onClick={() => toggleGameDay(key)}
            >
              <p className="w-10"></p>
              <p>{key}</p>
              <p className="w-10">
                <Arrow rotated={!pageState.collapseData[key]} />
              </p>
            </div>
            {pageState.collapseData[key] ? null : renderGames(games)}
          </div>
        ))}
      </div>
    </div>
  );
};
