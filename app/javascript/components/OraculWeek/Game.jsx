import React, { useEffect, useState, useMemo } from 'react';

import { currentLocale, localizeValue, convertTime, csrfToken } from '../../helpers';
import { strings } from '../../locales';

import { apiRequest } from '../../requests/helpers/apiRequest';

strings.setLanguage(currentLocale);

export const Game = ({ item, isForWeek, forecast, last }) => {
  const [homeForecast, setHomeForecast] = useState(
    forecast === undefined || forecast.value.length === 0 ? null : forecast.value[0]
  );
  const [visitorForecast, setVisitorForecast] = useState(
    forecast === undefined || forecast.value.length === 0 ? null : forecast.value[1]
  );

  const localizeTeamName = (team, name) => {
    if (isForWeek) return localizeValue(team.name);
    return localizeValue(name) || localizeValue({ en: 'unknown', ru: 'Неизвестно' });
  }

  useEffect(() => {
    if (parseInt(homeForecast) >= 0 && parseInt(visitorForecast) >= 0) {
      const requestOptions = {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ oraculs_forecast: { value: [parseInt(homeForecast), parseInt(visitorForecast)] } }),
      };

      apiRequest({
        url: `/api/frontend/oraculs/forecasts/${forecast.uuid}.json`,
        options: requestOptions,
      });
    };
  }, [homeForecast, visitorForecast, forecast.uuid]);

  const homeTeamName = useMemo(() => localizeTeamName(item.home_team, item.home_name), [item]); // eslint-disable-line react-hooks/exhaustive-deps
  const visitorTeamName = useMemo(() => localizeTeamName(item.visitor_team, item.visitor_name), [item]); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <>
      <div className={`flex justify-center items-center p-2 ${last ? '' : 'border-b border-stone-200'}`}>
        <p className="lg:text-lg flex-1 text-right">{homeTeamName}</p>
        <div className="mx-4 flex items-end gap-2">
          {item.points.length > 0 ? (
            <div>
              <p className="py-1 px-3 bg-stone-700 border border-stone-800 text-white text-lg rounded">
                {item.points[0]} - {item.points[1]}
              </p>
            </div>
          ) : (
            <p className="py-2 px-4 border border-stone-200 rounded">{convertTime(item.start_at)}</p>
          )}
          {item.predictable && forecast && forecast.owner ? (
            <div className="flex flex-col justify-center ml-2">
              <span className="text-xs text-center">{strings.oraculWeek.forecast}</span>
              <div className="flex items-center">
                <input
                  className="w-7 py-0 px-1 border border-stone-200 rounded text-center"
                  value={homeForecast}
                  onChange={(e) => setHomeForecast(e.target.value)}
                />
                <span className="mx-1">-</span>
                <input
                  className="w-7 py-0 px-1 border border-stone-200 rounded text-center"
                  value={visitorForecast}
                  onChange={(e) => setVisitorForecast(e.target.value)}
                />
              </div>
            </div>
          ) : null}
          {!item.predictable && forecast && forecast.value.length > 0 ? (
            <div className="flex flex-col justify-center ml-2">
              <span className="text-xs text-center">{strings.oraculWeek.forecast}</span>
              <p className="py-0 px-4 border border-stone-200 rounded bg-stone-100">{homeForecast} - {visitorForecast}</p>
            </div>
          ) : null}
        </div>
        <p className="lg:text-lg flex-1">{visitorTeamName}</p>
      </div>
    </>
  );
};
