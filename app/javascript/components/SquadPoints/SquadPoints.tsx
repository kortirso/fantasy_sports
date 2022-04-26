import React, { useState, useEffect } from 'react';

import type { TeamNames } from 'entities';
import { sportsData, SportPosition, LineupPlayer } from 'entities';
import { localizeValue } from 'helpers';

import { Week } from 'components';

import { teamsRequest } from 'requests/teamsRequest';
import { lineupPlayersRequest } from './requests/lineupPlayersRequest';

interface SquadPointsProps {
  seasonId: string;
  sportKind: string;
  lineupId: string;
  weekId: number;
  points: number;
}

export const SquadPoints = ({
  seasonId,
  sportKind,
  lineupId,
  weekId,
  points,
}: SquadPointsProps): JSX.Element => {
  // static data
  const [teamNames, setTeamNames] = useState<TeamNames>({});
  const [lineupPlayers, setLineupPlayers] = useState<LineupPlayer[]>([]);

  useEffect(() => {
    const fetchTeams = async () => {
      const data = await teamsRequest(seasonId);
      setTeamNames(data);
    };

    const fetchLineupPlayers = async () => {
      const data = await lineupPlayersRequest(lineupId);
      setLineupPlayers(data);
    };

    fetchTeams();
    fetchLineupPlayers();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  const sportPositionName = (sportPosition: SportPosition) => {
    return sportPosition.name.en.split(' ').join('-');
  };

  const activePlayersByPosition = (positionKind: string) => {
    return lineupPlayers.filter(
      (element: LineupPlayer) => element.active && element.player.position_kind === positionKind,
    );
  };

  const reservePlayers = () => {
    return lineupPlayers
      .filter((element: LineupPlayer) => {
        return !element.active;
      })
      .sort((a: LineupPlayer, b: LineupPlayer) => {
        return a.change_order > b.change_order ? 1 : -1;
      });
  };

  return (
    <>
      <h1>Points</h1>
      <div className="flex justify-between transfers-stats">
        <div className="transfers-stat flex flex-col items-center">
          <p>Total points</p>
          <p>{points}</p>
        </div>
        <div className="transfers-stat flex flex-col items-center">
          <p>Average points</p>
          <p></p>
        </div>
        <div className="transfers-stat flex flex-col items-center">
          <p>Hightest points</p>
          <p></p>
        </div>
      </div>
      <div id="team-players-by-positions" className={sportKind}>
        {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
          <div
            className={`sport-position ${sportPositionName(sportPosition as SportPosition)}`}
            key={positionKind}
          >
            {activePlayersByPosition(positionKind).map((item: LineupPlayer) => (
              <div className="player-card-box" key={item.id}>
                <div className="player-card">
                  <p className="player-team-name">{teamNames[item.team.id]?.short_name}</p>
                  <p className="player-name">{localizeValue(item.player.name).split(' ')[0]}</p>
                  <p className="player-value">{item.points}</p>
                </div>
              </div>
            ))}
          </div>
        ))}
      </div>
      {sport.changes && (
        <div className="substitutions">
          {reservePlayers().map((item: LineupPlayer) => (
            <div className="player-card-box" key={item.id}>
              <div className="player-card">
                <p className="player-team-name">{teamNames[item.team.id]?.short_name}</p>
                <p className="player-name">{localizeValue(item.player.name).split(' ')[0]}</p>
                <p className="player-value">{item.points}</p>
              </div>
            </div>
          ))}
        </div>
      )}
      {Object.keys(teamNames).length > 0 ? <Week id={weekId} teamNames={teamNames} /> : null}
    </>
  );
};
