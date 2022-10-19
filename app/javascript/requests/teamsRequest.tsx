import type { TeamNames } from 'entities';
import { Team } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = (seasonUuid: string) => {
  const searchParams = new URLSearchParams();
  searchParams.append('season_uuid', seasonUuid);
  return searchParams;
};

export const teamsRequest = async (seasonUuid: string) => {
  const result = await apiRequest({ url: `/teams.json?${encodeParams(seasonUuid)}` });
  return (
    result.teams.data.reduce((result: TeamNames, item: Team) => {
      result[item.id] = item.attributes;
      return result;
    }, {}) || {}
  );
};
