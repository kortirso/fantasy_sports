import React from 'react';
import ReactDOM from 'react-dom';

export const Modal = ({ show, children }) => {
  const modalContent = show ? (
    <div className="modal-container flex items-center justify-center">
      <div className="modal-content">{children}</div>
    </div>
  ) : null;

  if (modalContent) {
    return ReactDOM.createPortal(modalContent, window.document.getElementById('modal-root'));
  } else {
    return <></>;
  }
};
