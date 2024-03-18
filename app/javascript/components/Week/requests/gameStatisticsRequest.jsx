import { apiRequest } from '../../../requests/helpers/apiRequest';

export const gameStatisticsRequest = async (id) => {
  const result = await apiRequest({ url: `/api/frontend/games/${id}/statistics.json` });
  return result.game;
};
