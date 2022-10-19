import { Attribute } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

export const lineupPlayersRequest = async (lineupUuid: string) => {
  const result = await apiRequest({ url: `/lineups/${lineupUuid}/players.json` });
  return result.lineup_players.data.map((element: Attribute) => element.attributes);
};
