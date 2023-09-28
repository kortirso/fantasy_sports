import React, { useState } from 'react';

export const Dropdown = ({ title, items, onSelect, selectedValue }) => {
  const [isOpen, setIsOpen] = useState(false);

  const selectValue = (value) => {
    onSelect(value);
    setIsOpen(false);
  };

  return (
    <div className="form-field">
      <label className="form-label">{title}</label>
      <div className="relative cursor-pointer">
        <div className="form-value" onClick={() => setIsOpen(!isOpen)}>
          {selectedValue ? items[selectedValue] : ''}
        </div>
        {isOpen && (
          <ul className="form-dropdown">
            {Object.entries(items).map(([key, value]) => (
              <li
                className="bg-white hover:bg-gray-200 py-2 px-3"
                onClick={() => selectValue(key)}
                key={key}
              >
                {value}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
};
