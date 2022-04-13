import React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import { QueryClient, QueryClientProvider } from 'react-query';
import { Welcome, Squad, Transfers } from './components';
const components = { Welcome, Squad, Transfers };
const queryClient = new QueryClient();
document.addEventListener('DOMContentLoaded', () => {
    const mountPoints = document.querySelectorAll('[data-react-component]');
    mountPoints.forEach((mountPoint) => {
        const dataset = mountPoint.dataset;
        const componentName = dataset['reactComponent'];
        const Component = components[componentName];
        if (Component) {
            const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
            const root = ReactDOMClient.createRoot(mountPoint);
            root.render(React.createElement(QueryClientProvider, { client: queryClient },
                React.createElement(Component, Object.assign({}, props))));
        }
    });
});
