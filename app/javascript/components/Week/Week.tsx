import React, { useState, useEffect } from 'react';

import type { TeamNames } from 'entities';
import { Attribute, Week as WeekInterface, Game } from 'entities';
import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { weekRequest } from './requests/weekRequest';

interface WeekProps {
  id: number;
  teamNames: TeamNames;
}

export const Week = ({ id, teamNames }: WeekProps): JSX.Element => {
  const [weekId, setWeekId] = useState<number>(id);
  const [week, setWeek] = useState<WeekInterface | null>(null);
  const [games, setGames] = useState<Game[]>([]);

  useEffect(() => {
    const fetchWeek = async () => {
      const data = await weekRequest(weekId);
      setWeek(data);
      setGames(data.games.data.map((element: Attribute) => element.attributes));
    };

    strings.setLanguage(currentLocale);
    fetchWeek();
  }, [weekId]);

  if (!week) return <></>;

  return (
    <div className="week">
      <div className="week-header flex justify-between items-center">
        <div className="week-link-container">
          {week.previous.id ? (
            <button className="button" onClick={() => setWeekId(week.previous.id)}>
              {strings.week.previous}
            </button>
          ) : null}
        </div>
        <p>
          {strings.week.gameweek} {week.position} - {week.date_deadline_at} {week.time_deadline_at}
        </p>
        <div className="week-link-container">
          {week.next.id ? (
            <button className="button" onClick={() => setWeekId(week.next.id)}>
              {strings.week.next}
            </button>
          ) : null}
        </div>
      </div>
      <div className="week-day">
        {games.map((item: Game, index: number) => (
          <div key={index}>
            {index === 0 || item.date_start_at !== games[index - 1].date_start_at ? (
              <div className="week-day-header">
                <p>{item.date_start_at}</p>
              </div>
            ) : null}
            <div className="game flex justify-center items-center">
              <p className="team-name right-side">
                {localizeValue(teamNames[item.home_team.id].name)}
              </p>
              <p className="game-start">{item.time_start_at}</p>
              <p className="team-name">{localizeValue(teamNames[item.visitor_team.id].name)}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
