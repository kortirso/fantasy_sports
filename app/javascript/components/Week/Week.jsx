import React, { useState, useEffect } from 'react';

import { currentLocale } from '../../helpers';
import { strings } from '../../locales';

import { Game } from './Game';
import { weekRequest } from './requests/weekRequest';

strings.setLanguage(currentLocale);

export const Week = ({ uuid, teamNames }) => {
  const [pageState, setPageState] = useState({
    loading: true,
    week: null,
    games: [],
  });
  const [weekUuid, setWeekUuid] = useState(uuid);

  useEffect(() => {
    const fetchWeek = async () => {
      return await weekRequest(weekUuid);
    };

    Promise.all([fetchWeek()]).then(([fetchWeekData]) =>
      setPageState({
        loading: false,
        week: fetchWeekData,
        games: fetchWeekData.games.data.map((element) => element.attributes),
      }),
    );
  }, [weekUuid]);

  if (pageState.loading || pageState.week === null) return <></>;

  return (
    <div className="week">
      <div className="week-header flex justify-between items-center">
        <div className="week-link-container">
          {pageState.week.previous ? (
            <button
              className="button"
              onClick={() =>
                setWeekUuid(pageState.week?.previous ? pageState.week.previous.uuid : '')
              }
            >
              {strings.week.previous}
            </button>
          ) : null}
        </div>
        <p>
          {strings.week.gameweek} {pageState.week.position} - {pageState.week.date_deadline_at}{' '}
          {pageState.week.time_deadline_at}
        </p>
        <div className="week-link-container">
          {pageState.week.next ? (
            <button
              className="button"
              onClick={() => setWeekUuid(pageState.week?.next ? pageState.week.next.uuid : '')}
            >
              {strings.week.next}
            </button>
          ) : null}
        </div>
      </div>
      <div className="week-day">
        {pageState.games.map((item, index) => (
          <div key={index}>
            {index === 0 || item.date_start_at !== pageState.games[index - 1].date_start_at ? (
              <div className="week-day-header">
                <p>{item.date_start_at}</p>
              </div>
            ) : null}
            <Game item={item} teamNames={teamNames} />
          </div>
        ))}
      </div>
    </div>
  );
};
