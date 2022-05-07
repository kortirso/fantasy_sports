import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'season_statistic');
  return searchParams;
};

export const seasonPlayerRequest = async (seasonId: string, playerId?: number) => {
  const result = await apiRequest({
    url: `/seasons/${seasonId}/players/${playerId}.json?${encodeParams()}`,
  });
  return result.season_player.data.attributes;
};
