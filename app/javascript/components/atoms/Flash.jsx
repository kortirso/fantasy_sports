import React, { useState, useEffect } from 'react';

export const Flash = ({ content }) => {
  const [messages, setMessages] = useState({});

  useEffect(() => {
    setMessages(content);

    setTimeout(() => setMessages({}), 4000);
  }, [content]); // eslint-disable-line react-hooks/exhaustive-deps

  const flashBackground = (value) => {
    if (value === 'notice') return 'bg-green-400';

    return 'bg-red-400';
  };

  const closeMessageFromList = (key, value) => {
    const result = messages[key].filter((element) => element !== value);
    setMessages({ ...messages, [key]: result });
  }

  const closeMessage = (key) => setMessages(Object.entries(messages).filter(([elementKey, value]) => elementKey !== key));

  const renderValues = (key, values) => {
    if (Array.isArray(values)) {
      return values.map((value, index) => (
        <div
          className={`relative mb-2 py-4 pl-8 pr-12 rounded shadow ${flashBackground(key)}`}
          key={`${key}-${index}`}
        >
          <p>{value}</p>
          <span
            className="absolute top-1 right-1 cursor-pointer p-2"
            onClick={() => closeMessageFromList(key, value)}
          >x</span>
        </div>
      ))
    } else {
      return (
        <div
          className={`relative mb-2 py-4 pl-8 pr-12 rounded shadow ${flashBackground(key)}`}
          key={key}
        >
          <p>{values}</p>
          <span
            className="absolute top-1 right-1 cursor-pointer p-2"
            onClick={() => closeMessage(key)}
          >x</span>
        </div>
      )
    }
  }

  return (
    <div className="fixed top-12 right-8">
      {Object.entries(messages).map(([key, values], index) => renderValues(key, values))}
    </div>
  );
};
