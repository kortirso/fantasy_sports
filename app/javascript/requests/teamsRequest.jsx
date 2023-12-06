import { apiRequest } from './helpers/apiRequest';
import Cookies from 'js-cookie';

const encodeParams = (seasonUuid) => {
  const searchParams = new URLSearchParams();
  searchParams.append('season_uuid', seasonUuid);
  return searchParams;
};

export const teamsRequest = async (seasonUuid) => {
  const storageKey = `fantasy_sports_seasons_teams_${seasonUuid}`;
  const valueFromCookies = Cookies.get(storageKey);

  if (valueFromCookies) {
    const valueFromStorage = JSON.parse(localStorage.getItem(storageKey));

    if (valueFromStorage) return valueFromStorage;
  };

  const result = await apiRequest({ url: `/teams.json?${encodeParams(seasonUuid)}` });
  const representedResult = result.teams.data.reduce((result, item) => {
    result[item.id] = item.attributes;
    return result;
  }, {}) || {};

  // cookies define lifetime of data in localStorage
  Cookies.set(storageKey, storageKey, { expires: 7 });
  localStorage.setItem(storageKey, JSON.stringify(representedResult));

  return representedResult;
};
