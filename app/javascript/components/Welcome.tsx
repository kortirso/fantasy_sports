import React, { forwardRef } from 'react';

const WelcomeComponent = () => <div>Hello, Rails 7!</div>;

export const Welcome = forwardRef(WelcomeComponent);
