import { apiRequest } from 'requests/helpers/apiRequest';

export const weekTransfersRequest = async (weekUuid: string) => {
  return await apiRequest({ url: `/weeks/${weekUuid}/transfers.json` });
};
