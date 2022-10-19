import { apiRequest } from 'requests/helpers/apiRequest';

export const seasonPlayerRequest = async (seasonUuid: string, playerUuid?: string) => {
  const result = await apiRequest({
    url: `/seasons/${seasonUuid}/players/${playerUuid}.json?`,
  });
  return result.season_player.data.attributes;
};
