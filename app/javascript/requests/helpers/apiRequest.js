import { localizeRoute } from '../../helpers';

export const apiRequest = ({ url, options }) =>
  fetch(localizeRoute(url), options)
    .then((response) => response.json())
    .then((data) => data);
