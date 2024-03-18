import React, { useState, useEffect } from 'react';

import { currentLocale, convertDate, localizeValue } from '../../helpers';
import { strings } from '../../locales';
import { Arrow } from '../../assets';

import { Game } from './Game';
import { weekRequest } from './requests/weekRequest';
import { cupsRoundRequest } from './requests/cupsRoundRequest';
import { forecastsRequest } from './requests/forecastsRequest';

strings.setLanguage(currentLocale);

export const OraculWeek = ({ periodableId, lineupId, isForWeek }) => {
  const [pageState, setPageState] = useState({
    loading: true,
    games: [],
    collapseData: {},
    forecasts: []
  });

  useEffect(() => {
    const fetchGames = async () => await (isForWeek ? weekRequest(periodableId) : cupsRoundRequest(periodableId));
    const fetchForecasts = async () => await forecastsRequest(lineupId);

    Promise.all([fetchGames(), fetchForecasts()]).then(([gamesData, forecastsData]) => {
      const groupedGames = gamesData.reduce((result, game) => {
        const convertedTime = game.start_at ? convertDate(game.start_at) : localizeValue({ en: 'unknown', ru: 'Неизвестно' });

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
      });

      setPageState({
        loading: false,
        games: groupedGames,
        collapseData: collapseData,
        forecasts: forecastsData
      });
    });
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const renderGames = (games) => {
    return games.map((game, index) => {
      return (
        <Game
          item={game}
          isForWeek={isForWeek}
          forecast={pageState.forecasts.find((element) => element.forecastable_id === game.id)}
          last={index === games.length - 1}
        />
      );
    });
  };

  const toggleGameDay = (key) => {
    setPageState({ ...pageState, collapseData: { ...pageState.collapseData, [key]: !pageState.collapseData[key] } });
  };

  if (pageState.loading) return <></>;

  return (
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
  );
};
