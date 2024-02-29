import { apiRequest } from '../../../requests/helpers/apiRequest';

export const cupsRoundRequest = async (uuid) => {
  const result = await apiRequest({ url: `/api/frontend/cups/rounds/${uuid}.json` });
  return result.cups_round.data.attributes;
};
