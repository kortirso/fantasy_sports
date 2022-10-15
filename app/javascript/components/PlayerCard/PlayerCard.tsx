import React from 'react';

interface PlayerCardProps {
  className?: string;
  teamName?: string;
  name?: string;
  value?: string | number;
  status?: string;
  onCardClick?: () => void;
  onActionClick?: () => void;
  onInfoClick?: () => void;
}

export const PlayerCard = ({
  className = 'player-card',
  teamName,
  name,
  value,
  status,
  onCardClick,
  onActionClick,
  onInfoClick,
}: PlayerCardProps): JSX.Element => {
  const renderStatusIcon = () => {
    if (status === 'captain') return 'C';
    return 'A';
  };

  return (
    <div className="player-card-box">
      <div className={className} onClick={onCardClick ? onCardClick : undefined}>
        <p className="player-team-name">{teamName}</p>
        <p className="player-name">{name}</p>
        <p className="player-value">{value}</p>
        {onActionClick ? (
          <div className="action" onClick={(e) => { e.stopPropagation(); onActionClick() }}>
            +/-
          </div>
        ) : null}
        {onInfoClick ? (
          <div className="info" onClick={(e) => { e.stopPropagation(); onInfoClick() }}>
            ?
          </div>
        ) : null}
        {status && status !== 'regular' ? (
          <div className="captain">
            {renderStatusIcon()}
          </div>
        ) : null}
      </div>
    </div>
  );
};
