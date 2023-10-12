import { apiRequest } from '../../../requests/helpers/apiRequest';

export const bestSeasonPlayersRequest = async (seasonUuid) => {
  return await apiRequest({ url: `/seasons/${seasonUuid}/best_players.json` });
};

export const bestWeekPlayersRequest = async (seasonUuid, weekUuid) => {
  return await apiRequest({ url: `/seasons/${seasonUuid}/best_players.json?week_uuid=${weekUuid}` });
};
