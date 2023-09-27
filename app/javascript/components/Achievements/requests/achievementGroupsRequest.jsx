import { apiRequest } from '../../../requests/helpers/apiRequest';

export const achievementGroupsRequest = async () => {
  const result = await apiRequest({
    url: '/achievement_groups.json',
  });
  return result.achievement_groups.data.map((element) => element.attributes);
};
