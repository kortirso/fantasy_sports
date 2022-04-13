import React, { forwardRef } from 'react';

import { sportsData, SportPosition, LineupPlayer } from 'entities';
import { localizeValue } from 'helpers';

import { useTeams } from 'hooks/useTeams';
import { useLineupPlayers } from './hooks/useLineupPlayers';

interface SquadProps {
  seasonId: string;
  sportKind: string;
  lineupId: string;
}

const SquadComponent = (
  { seasonId, sportKind, lineupId }: SquadProps,
  ref: React.Ref<HTMLDivElement>,
) => {
  const teamNames = useTeams(seasonId);
  const players = useLineupPlayers(lineupId);
  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  const sportPositionName = (sportPosition: SportPosition) => {
    return sportPosition.name.en.split(' ').join('-');
  };

  const activePlayersByPosition = (positionKind: string) => {
    return players.filter(
      (element: LineupPlayer) => element.active && element.player.position_kind === positionKind,
    );
  };

  const reservePlayers = () => {
    return players
      .filter((element: LineupPlayer) => {
        return !element.active;
      })
      .sort((a: LineupPlayer, b: LineupPlayer) => {
        return a.change_order > b.change_order ? 1 : -1;
      });
  };

  return (
    <div>
      <div id="team-players-by-positions" className={sportKind}>
        {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
          <div
            className={`sport-position ${sportPositionName(sportPosition as SportPosition)}`}
            key={positionKind}
          >
            {activePlayersByPosition(positionKind).map((item: LineupPlayer) => (
              <div className="player-card-box" key={item.id}>
                <div className="player-card">
                  <p className="player-team-name">{localizeValue(teamNames[item.team.id])}</p>
                  <p className="player-name">{localizeValue(item.player.name).split(' ')[0]}</p>
                  <p className="player-value"></p>
                  {sport.changes && <div className="action">+/-</div>}
                </div>
              </div>
            ))}
          </div>
        ))}
        {sport.changes && (
          <div className="sport-position substitution">
            {reservePlayers().map((item: LineupPlayer) => (
              <div className="player-card-box" key={item.id}>
                <div className="player-card">
                  <p className="player-team-name">{localizeValue(teamNames[item.team.id])}</p>
                  <p className="player-name">{localizeValue(item.player.name).split(' ')[0]}</p>
                  <p className="player-value"></p>
                  <div className="action">+/-</div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export const Squad = forwardRef(SquadComponent);
