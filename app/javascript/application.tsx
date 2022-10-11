import React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import { QueryClient, QueryClientProvider } from 'react-query';

import { Squad, SquadPoints, Transfers } from 'components';
import type { ComponentType } from 'entities';

const components = { Squad, SquadPoints, Transfers };
const queryClient = new QueryClient();

document.addEventListener('DOMContentLoaded', () => {
  const mountPoints = document.querySelectorAll('[data-react-component]');
  mountPoints.forEach((mountPoint) => {
    const dataset = (mountPoint as HTMLElement).dataset;
    const componentName = dataset['reactComponent'] as ComponentType;
    const Component = components[componentName!];

    if (Component) {
      const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
      const root = ReactDOMClient.createRoot(mountPoint);
      root.render(
        <QueryClientProvider client={queryClient}>
          <Component {...props} />
        </QueryClientProvider>,
      );
    }
  });
});
