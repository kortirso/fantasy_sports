import React from 'react';

import { Chevron } from '../../assets';

export const Dropdown = ({
  title,
  items,
  isOpen,
  onOpen,
  onClose,
  onSelect,
  selectedValue,
  placeholder = ''
}) => (
  <div className="form-field">
    <label className="form-label">{title}</label>
    <div className="relative cursor-pointer">
      <div className="form-value flex justify-between items-center" onClick={() => isOpen ? onClose() : onOpen()}>
        {selectedValue ? items[selectedValue] : placeholder}
        <Chevron rotated={isOpen} />
      </div>
      {isOpen && (
        <ul className="form-dropdown">
          {Object.entries(items).map(([key, value]) => (
            <li
              className="bg-white hover:bg-stone-200 py-2 px-3"
              onClick={() => onSelect(key)}
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
