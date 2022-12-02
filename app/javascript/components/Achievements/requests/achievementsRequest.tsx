import { Attribute } from 'entities';
import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = (groupUuid?: string) => {
  if (!groupUuid) return '';

  const searchParams = new URLSearchParams();
  searchParams.append('group_uuid', groupUuid);
  return `?${searchParams}`;
};

export const achievementsRequest = async (groupUuid?: string) => {
  const result = await apiRequest({
    url: `/achievements.json${encodeParams(groupUuid)}`,
  });
  return result.achievements.data.map((element: Attribute) => element.attributes);
};
