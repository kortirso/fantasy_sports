import React, { useState, useEffect } from 'react';

import type { TeamNames } from 'entities';
import { Attribute, Week as WeekInterface, Game } from 'entities';
import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { weekRequest } from './requests/weekRequest';

interface WeekProps {
  uuid: string;
  teamNames: TeamNames;
}

export const Week = ({ uuid, teamNames }: WeekProps): JSX.Element => {
  const [weekUuid, setWeekUuid] = useState<number>(uuid);
  const [week, setWeek] = useState<WeekInterface | null>(null);
  const [games, setGames] = useState<Game[]>([]);

  useEffect(() => {
    const fetchWeek = async () => {
      const data = await weekRequest(weekUuid);
      setWeek(data);
      setGames(data.games.data.map((element: Attribute) => element.attributes));
    };

    strings.setLanguage(currentLocale);
    fetchWeek();
  }, [weekUuid]);

  if (!week) return <></>;

  console.log(games);

  return (
    <div className="week">
      <div className="week-header flex justify-between items-center">
        <div className="week-link-container">
          {week.previous.id ? (
            <button className="button" onClick={() => setWeekUuid(week.previous.uuid)}>
              {strings.week.previous}
            </button>
          ) : null}
        </div>
        <p>
          {strings.week.gameweek} {week.position} - {week.date_deadline_at} {week.time_deadline_at}
        </p>
        <div className="week-link-container">
          {week.next.id ? (
            <button className="button" onClick={() => setWeekUuid(week.next.uuid)}>
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
                {localizeValue(teamNames[item.home_team.uuid].name)}
              </p>
              {item.points.length > 0 ? (
                <p className="game-points">{item.points[0]} - {item.points[1]}</p>
              ) : (
                <p className="game-start">{item.time_start_at}</p>
              )}
              <p className="team-name">{localizeValue(teamNames[item.visitor_team.uuid].name)}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
