import React, { useState, useEffect } from 'react';

import type { TeamNames } from 'entities';
import { SportPosition, LineupPlayer } from 'entities';
import { sportsData } from 'data';
import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { Week, PlayerModal, PlayerCard } from 'components';

import { teamsRequest } from 'requests/teamsRequest';
import { lineupPlayersRequest } from './requests/lineupPlayersRequest';

interface SquadPointsProps {
  seasonUuid: string;
  sportKind: string;
  lineupUuid: string;
  weekUuid: string;
  weekPosition: number;
  points: number;
  averagePoints: number;
  maxPoints: number;
  previousPointsUrl: string | null;
  nextPointsUrl: string | null;
}

strings.setLanguage(currentLocale);

export const SquadPoints = ({
  seasonUuid,
  sportKind,
  lineupUuid,
  weekUuid,
  weekPosition,
  points,
  averagePoints,
  maxPoints,
  previousPointsUrl,
  nextPointsUrl,
}: SquadPointsProps): JSX.Element => {
  // static data
  const [teamNames, setTeamNames] = useState<TeamNames>({});
  const [lineupPlayers, setLineupPlayers] = useState<LineupPlayer[]>([]);
  // main data
  const [playerUuid, setPlayerUuid] = useState<string | undefined>();

  console.log(previousPointsUrl);
  console.log(nextPointsUrl);

  useEffect(() => {
    const fetchTeams = async () => {
      const data = await teamsRequest(seasonUuid);
      setTeamNames(data);
    };

    const fetchLineupPlayers = async () => {
      const data = await lineupPlayersRequest(lineupUuid);
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
      <div className="deadline flex items-center justify-center">
        <span>{strings.formatString(strings.squadPoints.week, { number: weekPosition })}</span>
      </div>
      <div className="flex flex-row justify-between transfers-stats">
        <div className="transfers-stat flex items-center justify-between">
          <p>{strings.squadPoints.totalPoints}</p>
          <p>{points}</p>
        </div>
        <div className="transfers-stat flex items-center justify-between">
          <p>{strings.squadPoints.averagePoints}</p>
          <p>{averagePoints}</p>
        </div>
        <div className="transfers-stat flex items-center justify-between">
          <p>{strings.squadPoints.hightestPoints}</p>
          <p>{maxPoints}</p>
        </div>
      </div>
      <div className="points-header flex justify-between items-center">
        <div>
          {previousPointsUrl ? (
            <a className="button small" href={ previousPointsUrl }>
              {strings.week.previous}
            </a>
          ) : null}
        </div>
        <div></div>
        <div>
          {nextPointsUrl ? (
            <a className="button small" href={ nextPointsUrl }>
              {strings.week.next}
            </a>
          ) : null}
        </div>
      </div>
      <div id="team-players-by-positions" className={sportKind}>
        {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
          <div
            className={`sport-position ${sportPositionName(sportPosition as SportPosition)}`}
            key={positionKind}
          >
            {activePlayersByPosition(positionKind).map((item: LineupPlayer) => (
              <PlayerCard
                key={item.uuid}
                teamName={teamNames[item.team.uuid]?.short_name}
                name={localizeValue(item.player.name).split(' ')[0]}
                value={item.points}
                onInfoClick={() => setPlayerUuid(item.teams_player.uuid)}
              />
            ))}
          </div>
        ))}
      </div>
      {sport.changes && (
        <div className="substitutions">
          {reservePlayers().map((item: LineupPlayer) => (
            <PlayerCard
              key={item.uuid}
              teamName={teamNames[item.team.uuid]?.short_name}
              name={localizeValue(item.player.name).split(' ')[0]}
              value={item.points}
              onInfoClick={() => setPlayerUuid(item.teams_player.uuid)}
            />
          ))}
        </div>
      )}
      {Object.keys(teamNames).length > 0 ? <Week uuid={weekUuid} teamNames={teamNames} /> : null}
      <PlayerModal
        sportKind={sportKind}
        seasonUuid={seasonUuid}
        playerUuid={playerUuid}
        teamNames={teamNames}
        onClose={() => setPlayerUuid(undefined)}
      />
    </>
  );
};
