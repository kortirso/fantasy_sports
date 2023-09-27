import React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import { QueryClient, QueryClientProvider } from 'react-query';

import {
  Achievements,
  SportRules,
  Squad,
  SquadPoints,
  Transfers,
  TransfersStatus,
} from './components';
import { Flash } from './components/atoms';

const components = {
  Achievements,
  Flash,
  SportRules,
  Squad,
  SquadPoints,
  Transfers,
  TransfersStatus,
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
      const childrenData = mountPoint.firstChild?.data
        ? JSON.parse(mountPoint.firstChild?.data)
        : null;
      const root = ReactDOMClient.createRoot(mountPoint);
      root.render(
        <QueryClientProvider client={queryClient}>
          <Component {...props}>{childrenData}</Component>
        </QueryClientProvider>,
      );
    }
  });
});
