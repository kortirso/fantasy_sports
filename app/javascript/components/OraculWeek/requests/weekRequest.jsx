import { apiRequest } from '../../../requests/helpers/apiRequest';

export const weekRequest = async (weekId) => {
  const result = await apiRequest({ url: `/api/frontend/games.json?week_id=${weekId}` });
  return result.games.data.map((element) => element.attributes);
};
