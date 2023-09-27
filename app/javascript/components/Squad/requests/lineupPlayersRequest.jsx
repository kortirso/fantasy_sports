import { apiRequest } from '../../../requests/helpers/apiRequest';

export const lineupPlayersRequest = async (lineupUuid) => {
  const result = await apiRequest({ url: `/lineups/${lineupUuid}/players.json` });
  return result.lineup_players.data.map((element) => element.attributes);
};
