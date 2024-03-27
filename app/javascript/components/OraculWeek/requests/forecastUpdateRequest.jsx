import { apiRequest } from '../../../requests/helpers/apiRequest';
import { csrfToken } from '../../../helpers';

export const forecastUpdateRequest = async (id, params) => {
  const requestOptions = {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': csrfToken(),
    },
    body: JSON.stringify({ oraculs_forecast: params }),
  };

  return await apiRequest({
    url: `/api/frontend/oraculs/forecasts/${id}.json`,
    options: requestOptions,
  });
};
