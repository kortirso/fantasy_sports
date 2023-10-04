import React, { useState, useEffect } from 'react';

export const Flash = ({ values }) => {
  const [messages, setMessages] = useState({});

  useEffect(() => {
    setMessages(values);
  }, [values]);

  const flashBackground = (value) => {
    if (value === 'notice') return 'bg-green-400';

    return 'bg-red-400';
  };

  return (
    <div className="fixed top-12 right-8">
      {Object.entries(messages).map(([key, value], index) => (
        <div className={`mb-2 py-2 px-4 rounded shadow ${flashBackground(key)}`} key={index}>
          <p>{value}</p>
        </div>
      ))}
    </div>
  );
};
