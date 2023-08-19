import React, { useState } from 'react';

interface ToggleProps {
  header: React.ReactNode;
  children: React.ReactNode;
}

export const Toggle = ({ header, children }: ToggleProps): JSX.Element => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="toggle-container">
      <div className="toggle-header" onClick={() => setIsOpen(!isOpen)}>
        {header}
      </div>
      {isOpen ? <div className="toggle-content">{children}</div> : null}
    </div>
  );
};
