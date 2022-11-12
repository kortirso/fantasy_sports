import { apiRequest } from 'requests/helpers/apiRequest';

export const lineupRequest = async (lineupUuid: string) => {
  const result = await apiRequest({ url: `/lineups/${lineupUuid}.json` });
  return result.lineup.data.attributes;
};
