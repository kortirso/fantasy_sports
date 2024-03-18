import { apiRequest } from '../../../requests/helpers/apiRequest';

export const forecastsRequest = async (id) => {
  if (id === null) return [];

  const result = await apiRequest({ url: `/api/frontend/oraculs/forecasts.json?oraculs_lineup_id=${id}`});
  return result.forecasts.data.map((element) => element.attributes);
};
