import React, { useState, useEffect } from 'react';

export const Flash = ({ values }) => {
  const [messages, setMessages] = useState({});

  useEffect(() => {
    setMessages(values);
  }, [values]);

  return (
    <div id="alerts" className="flash-block">
      {Object.entries(messages).map(([key, value], index) => (
        <div className={`flash ${key}`} key={index}>
          <p>{value}</p>
        </div>
      ))}
    </div>
  );
};
