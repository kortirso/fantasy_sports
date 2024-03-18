import { apiRequest } from '../../../requests/helpers/apiRequest';

export const cupsRoundRequest = async (cupsRoundId) => {
  const result = await apiRequest({ url: `/api/frontend/cups/pairs.json?cups_round_id=${cupsRoundId}` });
  return result.cups_pairs.data.map((element) => element.attributes);
};
