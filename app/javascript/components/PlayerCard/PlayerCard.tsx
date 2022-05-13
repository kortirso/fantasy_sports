import React from 'react';

interface PlayerCardProps {
  className?: string;
  teamName?: string;
  name?: string;
  value?: string | number;
  onActionClick?: () => void;
  onInfoClick?: () => void;
}

export const PlayerCard = ({
  className = 'player-card',
  teamName,
  name,
  value,
  onActionClick,
  onInfoClick,
}: PlayerCardProps): JSX.Element => (
  <div className="player-card-box">
    <div className={className}>
      <p className="player-team-name">{teamName}</p>
      <p className="player-name">{name}</p>
      <p className="player-value">{value}</p>
      {onActionClick ? (
        <div className="action" onClick={onActionClick}>
          +/-
        </div>
      ) : null}
      {onInfoClick ? (
        <div className="info" onClick={onInfoClick}>
          ?
        </div>
      ) : null}
    </div>
  </div>
);
