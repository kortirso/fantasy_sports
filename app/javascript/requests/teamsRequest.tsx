import type { KeyValue, TeamNames } from 'entities';
import { Team } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = (seasonId: string) => {
  const searchParams = new URLSearchParams();
  searchParams.append('season_id', seasonId);
  return searchParams;
};

export const teamsRequest = async (seasonId: string) => {
  const result = await apiRequest({ url: `/teams.json?${encodeParams(seasonId)}` });
  return result.teams.data.reduce((result: TeamNames, item: Team) => {
    result[item.id] = item.attributes;
    return result;
  }, {}) || {};
};
