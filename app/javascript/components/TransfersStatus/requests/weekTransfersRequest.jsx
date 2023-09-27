import { apiRequest } from '../../../requests/helpers/apiRequest';

export const weekTransfersRequest = async (weekUuid) => {
  return await apiRequest({ url: `/weeks/${weekUuid}/transfers.json` });
};
