import { Attribute } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

export const seasonPlayersRequest = async (seasonUuid: string) => {
  const result = await apiRequest({ url: `/seasons/${seasonUuid}/players.json?` });
  return result.season_players.data.map((element: Attribute) => element.attributes);
};
