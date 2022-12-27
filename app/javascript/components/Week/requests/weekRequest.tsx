import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'games,previous,next');
  return searchParams;
};

export const weekRequest = async (uuid: string) => {
  const result = await apiRequest({ url: `/weeks/${uuid}.json?${encodeParams()}` });
  return result.week.data.attributes;
};
