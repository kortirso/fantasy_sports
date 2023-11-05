import React from 'react';

export const PlayerCard = ({
  className = 'player-card',
  teamName = '',
  name = '',
  value = '',
  number = '',
  status,
  onCardClick,
  onActionClick,
  onInfoClick,
}) => {
  const renderStatusIcon = () => {
    if (status === 'captain') return 'C';
    return 'A';
  };

  return (
    <div
      className={`player-card relative flex flex-col w-32 overflow-hidden rounded md:mx-2 ${onCardClick ? 'cursor-pointer' : null} ${className}`}
      onClick={onCardClick ? onCardClick : undefined}
    >
      <p className={`player-jersey bg-no-repeat bg-contain bg-center h-20 mb-2 flex justify-center items-center ${teamName}`}>
        {name === '' ? null : (
          <span className="text-2xl">{number}</span>
        )}
      </p>
      <p
        className={`truncate text-center text-white py-1 px-2 h-6 leading-4 text-sm ${name === '' ? 'bg-stone-300' : 'bg-stone-500 text-amber-200'}`}
      >
        {name}
      </p>
      <p className={`text-center py-1 min-h-6 leading-4 text-sm ${value === '' ? 'bg-stone-200' : 'bg-amber-200'}`}>{value}</p>
      {onActionClick ? (
        <div
          className="player-card-action"
          onClick={(e) => {
            e.stopPropagation();
            onActionClick();
          }}
        >
          +/-
        </div>
      ) : null}
      {onInfoClick ? (
        <div
          className="player-card-action info"
          onClick={(e) => {
            e.stopPropagation();
            onInfoClick();
          }}
        >
          ?
        </div>
      ) : null}
      {status && status !== 'regular' ? (
        <div className="player-card-action captain">{renderStatusIcon()}</div>
      ) : null}
    </div>
  );
};
