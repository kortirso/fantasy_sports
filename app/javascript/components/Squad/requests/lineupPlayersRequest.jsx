import { apiRequest } from '../../../requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'fixtures,last_points');
  return searchParams;
};

export const lineupPlayersRequest = async (lineupUuid) => {
  const result = await apiRequest({ url: `/api/frontend/lineups/${lineupUuid}/players.json?${encodeParams()}` });
  return result.lineup_players.data.map((element) => element.attributes);
};
