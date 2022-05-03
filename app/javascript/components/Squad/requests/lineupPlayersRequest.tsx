import { Attribute } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

export const lineupPlayersRequest = async (lineupId: string) => {
  const result = await apiRequest({ url: `/lineups/${lineupId}/players.json` });
  return result.lineup_players.data.map((element: Attribute) => element.attributes);
};
