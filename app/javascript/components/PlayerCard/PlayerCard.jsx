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
    <div className="player-card-box">
      <div className={className} onClick={onCardClick ? onCardClick : undefined}>
        <p className={`player-team-name ${teamName}`}></p>
        <p className="player-name">{name}</p>
        <p className="player-value">{value}</p>
        {onActionClick ? (
          <div
            className="action"
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
            className="info"
            onClick={(e) => {
              e.stopPropagation();
              onInfoClick();
            }}
          >
            ?
          </div>
        ) : null}
        {status && status !== 'regular' ? (
          <div className="captain">{renderStatusIcon()}</div>
        ) : null}
      </div>
    </div>
  );
};
