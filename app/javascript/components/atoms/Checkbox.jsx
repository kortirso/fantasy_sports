import React from 'react';

export const Checkbox = ({ id, labelPosition = 'right', checked = false, label, onClick }) => {
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
      {label && labelPosition === 'left' ? renderLabel('mr-2') : null}
      <div className="toggle" onClick={onClick}>
        <input
          checked={checked}
          id={id}
          type="checkbox"
          className="toggle-checkbox"
        />
        <label
          for={id}
          role="switch"
          aria-checked="mixed"
          class="toggle-label"
        />
      </div>
      {label && labelPosition === 'right' ? renderLabel('ml-2') : null}
    </div>
  );
};
