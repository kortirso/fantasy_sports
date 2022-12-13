import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom';

export const Flash = ({ values }): JSX.Element => {
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    setMessages(values);
  }, [values]);

  const renderMessagesBody = (values) => {
    return values.map((value, index) => (
      <p key={index}>{message[1]}</p>
    ));
  };

  const renderMessages = () => {
    return messages.map((message, index) => {
      return (
        <div className={`flash ${message[0]}`} key={index}>
          {Array.isArray(message[1]) ? renderMessagesBody(message[1]) : (
            <p>{message[1]}</p>
          )}
        </div>
      );
    });
  };

  return (
    <div id="alerts" className="flash-block">
      {renderMessages()}
    </div>
  );
};
