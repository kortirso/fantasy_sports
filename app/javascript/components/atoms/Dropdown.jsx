import React, { useRef } from 'react';

import { Chevron } from '../../assets';

export const Dropdown = ({
  title,
  items,
  onSelect,
  selectedValue,
  placeholder = ''
}) => {
  const dropdownRef = useRef();

  const onDropdownToggle = () => {
    const currentState = Array.from(dropdownRef.current.classList).includes('opened');

    // close opened dropdowns
    document.querySelectorAll('.dropdown.opened').forEach((form) => form.classList.remove('opened'));

    // open current dropdown if it was closed
    if (!currentState) dropdownRef.current.classList.toggle('opened')
  };

  const onDropdownSelect = (value) => {
    dropdownRef.current.classList.toggle('opened');
    onSelect(value);
  };

  return (
    <div
      ref={dropdownRef}
      className="dropdown form-field"
    >
      <label className="form-label">{title}</label>
      <div className="relative cursor-pointer">
        <div
          className="dropdown-toggle form-value flex justify-between items-center"
          onClick={() => onDropdownToggle()}
        >
          {selectedValue ? items[selectedValue] : placeholder}
          <Chevron className='dropdown-toggle-icon' />
        </div>
        <ul className="dropdown-content">
          {Object.entries(items).map(([key, value]) => (
            <li
              className="bg-white hover:bg-stone-200 py-2 px-3"
              onClick={() => onDropdownSelect(key)}
              key={key}
            >
              {value}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};
