import { apiRequest } from './helpers/apiRequest';

const encodeParams = (seasonUuid) => {
  const searchParams = new URLSearchParams();
  searchParams.append('season_uuid', seasonUuid);
  return searchParams;
};

export const teamsRequest = async (seasonUuid) => {
  const result = await apiRequest({ url: `/teams.json?${encodeParams(seasonUuid)}` });
  return (
    result.teams.data.reduce((result, item) => {
      result[item.id] = item.attributes;
      return result;
    }, {}) || {}
  );
};
