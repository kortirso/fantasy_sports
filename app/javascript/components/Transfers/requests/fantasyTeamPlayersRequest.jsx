import { apiRequest } from '../../../requests/helpers/apiRequest';

export const fantasyTeamPlayersRequest = async (fantasyTeamUuid) => {
  const result = await apiRequest({ url: `/fantasy_teams/${fantasyTeamUuid}/players.json` });
  return result.teams_players.data.map((element) => element.attributes);
};
