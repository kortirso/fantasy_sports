import { apiRequest } from 'requests/helpers/apiRequest';

export const gameStatisticsRequest = async (uuid: number) => {
  const result = await apiRequest({ url: `/games/${uuid}/statistics.json` });
  return result.game;
};
