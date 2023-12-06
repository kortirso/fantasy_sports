import { apiRequest } from '../../../requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'week_statistic');
  return searchParams;
};

export const lineupPlayersRequest = async (lineupUuid) => {
  if (lineupUuid === null) return [];

  const result = await apiRequest({ url: `/api/frontend/lineups/${lineupUuid}/players.json?${encodeParams()}` });
  return result.lineup_players.data.map((element) => element.attributes);
};
