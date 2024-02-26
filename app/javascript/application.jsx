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
  FantasyTeamDestroyForm,
  Notifications,
  OraculForm,
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
  FantasyTeamDestroyForm,
  Notifications,
  OraculForm,
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

  // mobile navigation toggle
  const mobileMenuButton = document.querySelector('.mobile-menu-button');
  if (mobileMenuButton) {
    mobileMenuButton.addEventListener('click', () => {
      document.querySelector('.navigation-menu').classList.toggle('hidden');
    });
  };

  const mobileMenuCloseButton = document.querySelector('#navigation-menu-close-button');
  if (mobileMenuCloseButton) {
    mobileMenuCloseButton.addEventListener('click', () => {
      document.querySelector('.navigation-menu').classList.toggle('hidden');
    });
  };

  const mobileMenuBackground = document.querySelector('.navigation-menu-background');
  if (mobileMenuBackground) {
    mobileMenuBackground.addEventListener('click', () => {
      document.querySelector('.navigation-menu').classList.toggle('hidden');
    });
  };

  // Clicking outside of an open dropdown menu closes it
  window.addEventListener('click', function (e) {
    if (!e.target.matches('.dropdown-toggle')) {
      document.querySelectorAll('.dropdown.opened').forEach((form) => {
        if (!form.contains(e.target)) {
          form.classList.remove('opened')
        }
      })
    }
  })
});
