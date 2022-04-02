import React from 'react';
import * as ReactDOMClient from 'react-dom/client';

import { Welcome } from './components/Welcome';

import type { ComponentType } from './types';

const components = { Welcome };

document.addEventListener('DOMContentLoaded', () => {
  const mountPoints = document.querySelectorAll('[data-react-component]');
  mountPoints.forEach((mountPoint) => {
    const dataset = (mountPoint as HTMLElement).dataset;
    const componentName = dataset['reactComponent'] as ComponentType;
    const Component = components[componentName!];

    if (Component) {
      const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
      const root = ReactDOMClient.createRoot(mountPoint);
      root.render(<Component {...props} />);
    }
  });
});
