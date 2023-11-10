import React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import { QueryClient, QueryClientProvider } from 'react-query';

import {
  Achievements,
  Squad,
  SquadPoints,
  Transfers,
  TransfersStatus,
  BestPlayers,
  FantasyLeagueForm,
  FeedbackForm,
} from './components';
import { Flash, Toggle } from './components/atoms';

const components = {
  Achievements,
  Flash,
  Squad,
  SquadPoints,
  Toggle,
  Transfers,
  TransfersStatus,
  BestPlayers,
  FantasyLeagueForm,
  FeedbackForm,
};
const queryClient = new QueryClient();

document.addEventListener('DOMContentLoaded', () => {
  const mountPoints = document.querySelectorAll('[data-react-component]');
  mountPoints.forEach((mountPoint) => {
    const dataset = mountPoint.dataset;
    const componentName = dataset['reactComponent'];
    const Component = components[componentName];

    if (Component) {
      const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
      const childrenData = dataset['children'] ? JSON.parse(dataset['children']) : null;
      const root = ReactDOMClient.createRoot(mountPoint);
      root.render(
        <QueryClientProvider client={queryClient}>
          <Component {...props}>{childrenData}</Component>
        </QueryClientProvider>,
      );
    }
  });
});
