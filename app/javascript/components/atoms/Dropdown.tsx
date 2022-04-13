import React, { useState } from 'react';

import type { KeyValue } from 'entities';

interface DropdownProps {
  title: string;
  items: KeyValue;
  onSelect: (value: string) => void;
  selectedValue: string;
}

export const Dropdown = ({ title, items, onSelect, selectedValue }: DropdownProps): JSX.Element => {
  const [isOpen, setIsOpen] = useState<boolean>(false);

  const selectValue = (value: string) => {
    onSelect(value);
    setIsOpen(false);
  };

  return (
    <div className="form-field">
      <label className="form-label">{title}</label>
      <div className="form-select">
        <div className="form-value" onClick={() => setIsOpen(!isOpen)}>
          {items[selectedValue]}
        </div>
        {isOpen && (
          <ul className="form-select-dropdown">
            {Object.entries(items).map(([key, value]) => (
              <li onClick={() => selectValue(key)} key={key}>
                {value}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
};
