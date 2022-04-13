import { Attribute } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'season_statistic');
  return searchParams;
};

export const seasonPlayersRequest = async (seasonId: string) => {
  const result = await apiRequest({ url: `/seasons/${seasonId}/players.json?${encodeParams()}` });
  return result.season_players.data.map((element: Attribute) => element.attributes);
};
