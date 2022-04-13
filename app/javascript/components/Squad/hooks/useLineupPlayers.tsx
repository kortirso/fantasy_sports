import { useQuery } from 'react-query';

import { Attribute } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'opposite_teams');
  return searchParams;
};

export const useLineupPlayers = (lineupId: string) => {
  const result = useQuery({
    queryKey: ['lineupPlayers', lineupId],
    queryFn: () => apiRequest({ url: `/lineups/${lineupId}/players.json?${encodeParams()}` }),
    refetchOnWindowFocus: false,
  });
  return result?.data?.lineup_players?.data?.map((element: Attribute) => element.attributes) || [];
};
