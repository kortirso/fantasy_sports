import { apiRequest } from 'requests/helpers/apiRequest';

const encodeParams = () => {
  const searchParams = new URLSearchParams();
  searchParams.append('fields', 'games,previous,next');
  return searchParams;
};

export const weekRequest = async (id: number) => {
  const result = await apiRequest({ url: `/weeks/${id}.json?${encodeParams()}` });
  return result.week.data.attributes;
};
