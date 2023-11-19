import React from 'react';

export const Checkbox = ({ id, labelPosition = 'right', label, onClick }) => {
  const renderLabel = (className) => {
    return (
      <label
        for={`${id}`}
        className={`cursor-pointer ${className}`}
      >{label}</label>
    )
  };

  return (
    <div className="flex items-center">
      {labelPosition === 'left' ? renderLabel('mr-2') : null}
      <div className="toggle">
        <input id={`${id}`} type="checkbox" className="toggle-checkbox" onClick={onClick} />
        <label
          for={`${id}`}
          role="switch"
          aria-checked="mixed"
          class="toggle-label"
        />
      </div>
      {labelPosition === 'right' ? renderLabel('ml-2') : null}
    </div>
  );
};
