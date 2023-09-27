import React, { useState } from 'react';

export const Toggle = ({ header, children }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="toggle-container">
      <div className="toggle-header" onClick={() => setIsOpen(!isOpen)}>
        {header}
      </div>
      {children && isOpen ? <div className="toggle-content">{children}</div> : null}
    </div>
  );
};
