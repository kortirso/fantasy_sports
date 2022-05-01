import { Element } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'opposite_teams');
  return searchParams;
};

export const lineupPlayersRequest = async (lineupId: string) => {
  const result = await apiRequest({ url: `/lineups/${lineupId}/players.json?${encodeParams()}` });
  return result.lineup_players.data.map((element: Element) => element.attributes);
};
