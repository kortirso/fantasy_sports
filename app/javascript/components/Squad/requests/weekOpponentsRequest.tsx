import { apiRequest } from 'requests/helpers/apiRequest';

export const weekOpponentsRequest = async (weekId: number) => {
  const result = await apiRequest({ url: `/weeks/${weekId}/opponents.json` });
  return result.opponents;
};
