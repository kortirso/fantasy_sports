import React, { useState } from 'react';

import { Chevron } from '../../assets';

export const Toggle = ({ header, children }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="bg-white rounded shadow">
      <div className="py-2 px-4 cursor-pointer flex justify-between items-center" onClick={() => setIsOpen(!isOpen)}>
        <h3 className="m-0 text-lg">{header}</h3>
        <Chevron rotated={isOpen} />
      </div>
      {children && isOpen ? (
        <div dangerouslySetInnerHTML={{ __html: children }} className="px-4 pb-4 border-t border-gray-200"></div>
      ) : null}
    </div>
  );
};
