import { localizeRoute } from 'helpers';

export interface apiRequestOptions {
  method?: string;
  headers?: {
    [key: string]: string;
  };
  body?: string;
}

interface apiRequestProps {
  url: string;
  options?: apiRequestOptions;
}

export const apiRequest = ({ url, options }: apiRequestProps) =>
  fetch(localizeRoute(url), options)
    .then((response) => response.json())
    .then((data) => data);
