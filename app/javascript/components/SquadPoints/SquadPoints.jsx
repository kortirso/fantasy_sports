import React, { useState, useEffect } from 'react';

import { sportsData } from '../../data';
import { currentLocale, localizeValue } from '../../helpers';
import { strings } from '../../locales';

import { Week, PlayerModal, PlayerCard } from '../../components';
import { teamsRequest } from '../../requests/teamsRequest';

import { lineupPlayersRequest } from './requests/lineupPlayersRequest';

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
}) => {
  const [pageState, setPageState] = useState({
    loading: true,
    teamNames: {},
    lineupPlayers: [],
  });
  const [playerUuid, setPlayerUuid] = useState();

  useEffect(() => {
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchLineupPlayers = async () => await lineupPlayersRequest(lineupUuid);

    Promise.all([fetchTeams(), fetchLineupPlayers()]).then(
      ([teamsData, lineupPlayersData]) =>
        setPageState({
          loading: false,
          teamNames: teamsData,
          lineupPlayers: lineupPlayersData,
        }),
    );
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  if (pageState.loading) return <></>;

  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  const sportPositionName = (sportPosition) => sportPosition.name.en.split(' ').join('-');

  const activePlayersByPosition = (positionKind) => {
    return pageState.lineupPlayers.filter(
      (element) => element.active && element.player.position_kind === positionKind,
    );
  };

  const reservePlayers = () => {
    return pageState.lineupPlayers
      .filter((element) => !element.active)
      .sort((a, b) => a.change_order > b.change_order ? 1 : -1);
  };

  return (
    <>
      <span className="inline-block bg-zinc-800 text-white text-sm py-1 px-2 rounded">
        {strings.formatString(strings.squadPoints.week, { number: weekPosition })}
      </span>
      <h1>{strings.squadPoints.title}</h1>
      <div className="flex flex-col md:flex-row justify-between mt-2 bg-gray-200 rounded shadow mb-4">
        <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10 border-b md:border-b-0 md:border-r border-gray-300">
          <p className="text-center">{strings.squadPoints.totalPoints}</p>
          <p className="ml-4 md:ml-0 text-xl">{points}</p>
        </div>
        <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10 border-b md:border-b-0 md:border-r border-gray-300">
          <p className="text-center">{strings.squadPoints.averagePoints}</p>
          <p className="ml-4 md:ml-0 text-xl">{averagePoints}</p>
        </div>
        <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10">
          <p className="text-center">{strings.squadPoints.hightestPoints}</p>
          <p className="ml-4 md:ml-0 text-xl">{maxPoints}</p>
        </div>
      </div>
      <div className="flex justify-between items-center mb-4">
        <div>
          {previousPointsUrl ? (
            <a className="btn-primary btn-small" href={previousPointsUrl}>
              {strings.week.previous}
            </a>
          ) : null}
        </div>
        <div></div>
        <div>
          {nextPointsUrl ? (
            <a className="btn-primary btn-small" href={nextPointsUrl}>
              {strings.week.next}
            </a>
          ) : null}
        </div>
      </div>
      <div className={`flex flex-col relative bg-no-repeat bg-cover bg-center ${sportKind}-field`}>
        {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
          <div
            className={`sport-position ${sportPositionName(sportPosition)}`}
            key={positionKind}
          >
            {activePlayersByPosition(positionKind).map((item) => (
              <PlayerCard
                key={item.uuid}
                teamName={pageState.teamNames[item.team.uuid]?.short_name}
                name={localizeValue(item.player.name).split(' ')[0]}
                value={item.points}
                number={item.teams_player.shirt_number}
                onInfoClick={() => setPlayerUuid(item.player.uuid)}
              />
            ))}
          </div>
        ))}
      </div>
      {sport.changes && (
        <div className="flex flex-row justify-center mt-4 mb-8">
          {reservePlayers().map((item) => (
            <PlayerCard
              key={item.uuid}
              teamName={pageState.teamNames[item.team.uuid]?.short_name}
              name={localizeValue(item.player.name).split(' ')[0]}
              value={item.points}
              number={item.teams_player.shirt_number}
              onInfoClick={() => setPlayerUuid(item.player.uuid)}
            />
          ))}
        </div>
      )}
      {Object.keys(pageState.teamNames).length > 0 ? (
        <Week uuid={weekUuid} teamNames={pageState.teamNames} />
      ) : null}
      <PlayerModal
        sportKind={sportKind}
        seasonUuid={seasonUuid}
        playerUuid={playerUuid}
        teamNames={pageState.teamNames}
        onClose={() => setPlayerUuid(undefined)}
      />
    </>
  );
};
