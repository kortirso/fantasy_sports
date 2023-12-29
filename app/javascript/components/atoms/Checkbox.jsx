import React from 'react';

export const Checkbox = ({ labelPosition = 'right', checked = false, label, onClick }) => {
  const renderLabel = (className) => {
    return (
      <label
        className={`cursor-pointer ${className}`}
        onClick={onClick}
      >{label}</label>
    )
  };

  return (
    <div className="flex items-center">
      {label && labelPosition === 'left' ? renderLabel('mr-2') : null}
      <div className="toggle" onClick={onClick}>
        <input
          checked={checked}
          type="checkbox"
          className="toggle-checkbox"
        />
        <label className="toggle-label" />
      </div>
      {label && labelPosition === 'right' ? renderLabel('ml-2') : null}
    </div>
  );
};
