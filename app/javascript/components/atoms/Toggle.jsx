import React, { useState } from 'react';

import { Chevron } from '../../assets';

export const Toggle = ({ header, children }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="bg-stone-200 border-b border-stone-300">
      <div className="py-2 px-4 cursor-pointer flex justify-between items-center" onClick={() => setIsOpen(!isOpen)}>
        <h3 className="m-0 text-lg">{header}</h3>
        <Chevron rotated={isOpen} />
      </div>
      {children && isOpen ? (
        <div dangerouslySetInnerHTML={{ __html: children }} className="px-4 pb-4 bg-white border-t border-stone-300"></div>
      ) : null}
    </div>
  );
};
