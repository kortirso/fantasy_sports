import { useQuery } from 'react-query';

import type { KeyValue, TeamNames } from 'entities';
import { Team } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = (seasonId: string) => {
  const searchParams = new URLSearchParams();
  searchParams.append('season_id', seasonId);
  return searchParams;
};

export const useTeams = (seasonId: string) => {
  const result = useQuery({
    queryKey: ['teams', seasonId],
    queryFn: () => apiRequest({ url: `/teams.json?${encodeParams(seasonId)}` }),
    refetchOnWindowFocus: false,
  });
  return (
    result?.data?.teams?.data?.reduce((result: TeamNames, item: Team) => {
      result[item.id] = item.attributes.name;
      return result;
    }, {}) || {}
  );
};
