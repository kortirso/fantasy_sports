import React from 'react';
import ReactDOM from 'react-dom';

export const Modal = ({ show, children }) => {
  const modalContent = show ? (
    <div className="fixed top-0 left-0 right-0 bottom-0 z-50 bg-black/75 flex items-center justify-center">
      <div className="absolute p-8 bg-white rounded w-3/5">{children}</div>
    </div>
  ) : null;

  if (modalContent) {
    return ReactDOM.createPortal(modalContent, window.document.getElementById('modal-root'));
  } else {
    return <></>;
  }
};
