import React, { useState, useEffect, useMemo } from 'react';

import { currentLocale, localizeValue, convertTime } from '../../helpers';
import { strings } from '../../locales';

import { gameStatisticsRequest } from './requests/gameStatisticsRequest';

const STATS_VALUES = {
  GS: { en: 'Goals scored', ru: 'Забитые голы' },
  A: { en: 'Assists', ru: 'Передачи' },
  YC: { en: 'Yellow cards', ru: 'Жёлтые карточки' },
  RC: { en: 'Red cards', ru: 'Красные карточки' },
  S: { en: 'Saves', ru: 'Спасения' },
  B: { en: 'Bonus', ru: 'Бонусы' },
  P: { en: 'Points', ru: 'Набранные очки' },
  REB: { en: 'Rebounds', ru: 'Подборы' },
  BLK: { en: 'Blocks', ru: 'Блокшоты' },
  STL: { en: 'Steals', ru: 'Перехваты' },
  TO: { en: 'Turnovers', ru: 'Потери' },
};

strings.setLanguage(currentLocale);

export const Game = ({ item, teamNames, last }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [gameStatistics, setGameStatistics] = useState();

  useEffect(() => {
    const fetchGameStatistics = async () => {
      const data = await gameStatisticsRequest(item.uuid);
      setGameStatistics(data);
    };

    if (isOpen && !gameStatistics) fetchGameStatistics();
  }, [isOpen, item.uuid, gameStatistics]);

  const expandeable = useMemo(() => {
    return item.points.length > 0;
  }, [item.points]);

  const renderStatistics = (element, index) => {
    if (element.home_team.length === 0 && element.visitor_team.length === 0) return null;

    return (
      <li className="mt-0 mx-auto pb-4 md:w-1/2 px-4" key={`fixture-${index}`}>
        <h5 className="text-center bg-stone-300 py-1 px-2 mb-1 rounded shadow">{localizeValue(STATS_VALUES[element.key])}</h5>
        <div className="flex">
          <div className="flex-1 py-0 px-2 text-right border-r border-stone-200">
            {element.home_team.map((player, index) => (
              <p key={`home-team-player-${index}`}>
                {localizeValue(player[0]).split(' ')[0]} ({player[1]})
              </p>
            ))}
          </div>
          <div className="flex-1 py-0 px-2">
            {element.visitor_team.map((player, index) => (
              <p key={`visitor-team-player-${index}`}>
                {localizeValue(player[0]).split(' ')[0]} ({player[1]})
              </p>
            ))}
          </div>
        </div>
      </li>
    );
  };

  return (
    <>
      <div
        className={`flex justify-center items-center p-2 ${expandeable ? 'cursor-pointer' : ''} ${!isOpen && !last ? 'border-b border-stone-200' : ''}`}
        onClick={() => expandeable ? setIsOpen(!isOpen) : null}
      >
        <p className="lg:text-lg flex-1 text-right">{localizeValue(teamNames[item.home_team.uuid].name)}</p>
        {expandeable ? (
          <p className="py-1 px-3 bg-stone-700 border border-stone-800 text-white text-lg mx-4 rounded">
            {item.points[0]} - {item.points[1]}
          </p>
        ) : (
          <p className="py-2 px-4 border border-stone-200 rounded mx-4">{convertTime(item.start_at)}</p>
        )}
        <p className="lg:text-lg flex-1">{localizeValue(teamNames[item.visitor_team.uuid].name)}</p>
      </div>
      {isOpen && item.points.length > 0 && gameStatistics ? (
        <ul className={`list-none p-0 pt-4 ${!last ? 'border-b border-stone-200' : ''}`}>
          {gameStatistics.map((element, index) => renderStatistics(element, index))}
        </ul>
      ) : null}
    </>
  );
};
