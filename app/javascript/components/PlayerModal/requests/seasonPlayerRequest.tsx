import { apiRequest } from 'requests/helpers/apiRequest';

export const seasonPlayerRequest = async (seasonId: string, playerId?: number) => {
  const result = await apiRequest({
    url: `/seasons/${seasonId}/players/${playerId}.json?`,
  });
  return result.season_player.data.attributes;
};
