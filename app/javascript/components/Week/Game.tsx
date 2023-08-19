import React, { useState, useEffect } from 'react';

import { Game as GameInterface, GameStatistic, TeamNames, TeamStatistic } from 'entities';
import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { gameStatisticsRequest } from './requests/gameStatisticsRequest';

interface GameProps {
  item: GameInterface;
  teamNames: TeamNames;
}

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

export const Game = ({ item, teamNames }: GameProps): JSX.Element => {
  const [isOpen, setIsOpen] = useState(false);
  const [gameStatistics, setGameStatistics] = useState<GameStatistic[] | undefined>();

  useEffect(() => {
    const fetchGameStatistics = async () => {
      const data = await gameStatisticsRequest(item.uuid);
      setGameStatistics(data);
    };

    if (isOpen && !gameStatistics) fetchGameStatistics();
  }, [isOpen, item.uuid, gameStatistics]);

  const renderStatistics = (element: GameStatistic, index: number) => {
    if (element.home_team.length === 0 && element.visitor_team.length === 0) return null;

    return (
      <li className="fixture" key={`fixture-${index}`}>
        <h5>{localizeValue(STATS_VALUES[element.key])}</h5>
        <div className="fixture-values">
          <div className="fixture-value">
            {element.home_team.map((player: TeamStatistic, i: number) => (
              <p key={`home-team-player-${i}`}>
                {localizeValue(player[0]).split(' ')[0]} ({player[1]})
              </p>
            ))}
          </div>
          <div className="fixture-value">
            {element.visitor_team.map((player: TeamStatistic, i: number) => (
              <p key={`visitor-team-player-${i}`}>
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
        className="game expandable flex justify-center items-center"
        onClick={() => setIsOpen(!isOpen)}
      >
        <p className="team-name right-side">{localizeValue(teamNames[item.home_team.uuid].name)}</p>
        {item.points.length > 0 ? (
          <p className="game-points">
            {item.points[0]} - {item.points[1]}
          </p>
        ) : (
          <p className="game-start">{item.time_start_at}</p>
        )}
        <p className="team-name">{localizeValue(teamNames[item.visitor_team.uuid].name)}</p>
      </div>
      {isOpen && item.points.length > 0 && gameStatistics ? (
        <ul className="fixtures">
          {gameStatistics.map((element: GameStatistic, index: number) =>
            renderStatistics(element, index),
          )}
        </ul>
      ) : null}
    </>
  );
};
