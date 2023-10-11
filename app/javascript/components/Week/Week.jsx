import React, { useState, useEffect } from 'react';

import { currentLocale, convertDateTime, convertDate } from '../../helpers';
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
    const fetchWeek = async () => await weekRequest(weekUuid);

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
    <div>
      <div className="flex justify-between items-center my-4 mx-0">
        <div className="w-48">
          {pageState.week.previous.uuid ? (
            <button
              className="btn-primary btn-small w-full"
              onClick={() => setWeekUuid(pageState.week.previous.uuid)}
            >
              {strings.week.previous}
            </button>
          ) : null}
        </div>
        <p>
          {strings.week.gameweek} {pageState.week.position} - {convertDateTime(pageState.week.deadline_at)}
        </p>
        <div className="w-48">
          {pageState.week.next.uuid ? (
            <button
              className="btn-primary btn-small w-full"
              onClick={() => setWeekUuid(pageState.week.next.uuid)}
            >
              {strings.week.next}
            </button>
          ) : null}
        </div>
      </div>
      <div className="mb-4">
        {pageState.games.map((item, index) => (
          <div key={index}>
            {index === 0 || convertDate(item.start_at) !== convertDate(pageState.games[index - 1].start_at) ? (
              <div className="py-1 px-0 bg-gray-200 text-center">
                <p>{convertDate(item.start_at)}</p>
              </div>
            ) : null}
            <Game item={item} teamNames={teamNames} />
          </div>
        ))}
      </div>
    </div>
  );
};
