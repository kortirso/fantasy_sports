import { apiRequest } from '../../../requests/helpers/apiRequest';

export const gamesRequest = async (weekId) => {
  const result = await apiRequest({ url: `/api/frontend/games.json?week_id=${weekId}` });
  return result.games.data.map((element) => element.attributes);
};
