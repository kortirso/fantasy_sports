import { apiRequest } from '../../../requests/helpers/apiRequest';

export const weekRequest = async (id) => {
  const result = await apiRequest({ url: `/api/frontend/weeks/${id}.json` });
  return result.week.data.attributes;
};
