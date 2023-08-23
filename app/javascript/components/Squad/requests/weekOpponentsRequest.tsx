import { apiRequest } from 'requests/helpers/apiRequest';

export const weekOpponentsRequest = async (weekUuid: string) => {
  const result = await apiRequest({ url: `/weeks/${weekUuid}/opponents.json` });
  return result.opponents;
};
