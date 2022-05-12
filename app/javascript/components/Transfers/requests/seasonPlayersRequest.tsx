import { Attribute } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

export const seasonPlayersRequest = async (seasonId: string) => {
  const result = await apiRequest({ url: `/seasons/${seasonId}/players.json?` });
  return result.season_players.data.map((element: Attribute) => element.attributes);
};
