import React, { useState, useEffect } from 'react';

import type { KeyValue } from 'entities';

interface FlashProps {
  values: KeyValue;
}

export const Flash = ({ values }: FlashProps): JSX.Element => {
  const [messages, setMessages] = useState<KeyValue>({});

  useEffect(() => {
    setMessages(values);
  }, [values]);

  return (
    <div id="alerts" className="flash-block">
      {Object.entries(messages).map(([key, value], index: number) => (
        <div className={`flash ${key}`} key={index}>
          <p>{value}</p>
        </div>
      ))}
    </div>
  );
};
