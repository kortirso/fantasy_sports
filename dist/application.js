import React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import { Welcome } from './components/Welcome';
const components = { Welcome };
document.addEventListener('DOMContentLoaded', () => {
    const mountPoints = document.querySelectorAll('[data-react-component]');
    mountPoints.forEach((mountPoint) => {
        const dataset = mountPoint.dataset;
        const componentName = dataset['reactComponent'];
        const Component = components[componentName];
        if (Component) {
            const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
            const root = ReactDOMClient.createRoot(mountPoint);
            root.render(React.createElement(Component, Object.assign({}, props)));
        }
    });
});
//# sourceMappingURL=application.js.map