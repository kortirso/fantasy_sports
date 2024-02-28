import { apiRequest } from '../../../requests/helpers/apiRequest';

export const forecastsRequest = async (uuid) => {
  const result = await apiRequest({ url: `/api/frontend/oraculs/forecasts.json?oraculs_lineup_id=${uuid}`});
  return result.forecasts.data.map((element) => element.attributes);
};
