import React from 'react';

export const PlayerCard = ({
  className = 'player-card',
  teamName,
  name,
  value,
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
    <div>
      <div
        className={`relative flex flex-col w-32 overflow-hidden rounded mr-2 py-2 px-0 ${className}`}
        onClick={onCardClick ? onCardClick : undefined}
      >
        <p className={`player-jersey bg-no-repeat bg-contain bg-center h-20 mb-2 ${teamName}`}></p>
        <p className={`text-center text-white py-1 min-h-6 leading-4 text-sm ${name === '' ? 'bg-gray-300' : 'bg-green-600'}`}>{name}</p>
        <p className={`text-center py-1 min-h-6 leading-4 text-sm ${value === '' ? 'bg-gray-200' : 'bg-green-400'}`}>{value}</p>
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
    </div>
  );
};
