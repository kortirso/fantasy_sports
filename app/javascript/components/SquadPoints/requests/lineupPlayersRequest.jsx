import { apiRequest } from '../../../requests/helpers/apiRequest';

export const lineupPlayersRequest = async (lineupUuid) => {
  if (lineupUuid === null) return [];

  const result = await apiRequest({ url: `/api/frontend/lineups/${lineupUuid}/players.json` });
  return result.lineup_players.data.map((element) => element.attributes);
};
