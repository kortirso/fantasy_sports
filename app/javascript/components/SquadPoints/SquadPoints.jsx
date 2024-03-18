import React, { useState, useEffect } from 'react';

import { sportsData } from '../../data';
import { currentLocale, localizeValue } from '../../helpers';
import { strings } from '../../locales';
import { statisticsOrder } from '../../data';

import { Week, PlayerModal, PlayerCard } from '../../components';
import { teamsRequest } from '../../requests/teamsRequest';

import { lineupPlayersRequest } from './requests/lineupPlayersRequest';

strings.setLanguage(currentLocale);

export const SquadPoints = ({
  seasonUuid,
  sportKind,
  lineupUuid,
  activeChips,
  weekId,
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
    viewMode: 'field', // options - 'field', 'list'
  });
  const [playerUuid, setPlayerUuid] = useState();

  useEffect(() => {
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchLineupPlayers = async () => await lineupPlayersRequest(lineupUuid);

    Promise.all([fetchTeams(), fetchLineupPlayers()]).then(
      ([teamsData, lineupPlayersData]) =>
        setPageState({
          ...pageState,
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

  const renderActiveChip = () => {
    if (activeChips.includes('bench_boost')) return strings.squadPoints.benchBoostIsActive;
    if (activeChips.includes('triple_captain')) return strings.squadPoints.tripleCaptainIsActive;

    return null;
  };

  const injuryLevelClass = (injury) => {
    if (injury === null) return 'player-info';

    const data = injury.data.attributes;
    if (data.status === 0) return 'player-info-alert';
    return 'player-info-warning';
  };

  const renderActivePlayers = () => {
    return Object.entries(sportPositions).map(([positionKind, sportPosition]) => {
      return activePlayersByPosition(positionKind).map((item) => (
        <tr key={item.uuid}>
          <td>
            <div className="flex justify-center items-center">
              <span
                className={injuryLevelClass(item.player.injury)}
                onClick={() => setPlayerUuid(item.player.uuid)}
              >
                ?
              </span>
            </div>
          </td>
          <td>
            <p className="text-sm">{localizeValue(item.player.shirt_name)}</p>
            <p className="text-xs">{pageState.teamNames[item.team.uuid]?.short_name}</p>
          </td>
          <td className="text-sm">{localizeValue(sportPositions[item.player.position_kind].short_name)}</td>
          <td>{item.points}</td>
          {Object.keys(statisticsOrder[sportKind]).map((stat) => (
            <td key={stat}>
              {item.week_statistic[stat]}
            </td>
          ))}
        </tr>
      ));
    });
  };

  const renderReservePlayers = () => {
    return reservePlayers().map((item) => (
      <tr key={item.uuid}>
        <td>
          <div className="flex justify-center items-center">
            <span
              className={injuryLevelClass(item.player.injury)}
              onClick={() => setPlayerUuid(item.player.uuid)}
            >
              ?
            </span>
          </div>
        </td>
        <td>
          <p className="text-sm">{localizeValue(item.player.shirt_name)}</p>
          <p className="text-xs">{pageState.teamNames[item.team.uuid]?.short_name}</p>
        </td>
        <td className="text-sm">{localizeValue(sportPositions[item.player.position_kind].short_name)}</td>
        <td>{item.points}</td>
        {Object.keys(statisticsOrder[sportKind]).map((stat) => (
          <td key={stat}>
            {item.week_statistic[stat]}
          </td>
        ))}
      </tr>
    ));
  };

  return (
    <>
      <span className="badge-dark inline-block">
        {strings.formatString(strings.squadPoints.week, { number: weekPosition })}
      </span>
      <h1 className="mb-2">{strings.squadPoints.title}</h1>
      <p className="mb-4">{strings.squadPoints.description}</p>
      {lineupUuid ? (
        <div className="flex flex-col md:flex-row justify-between mt-2 bg-stone-200 border border-stone-300 rounded mb-4">
          <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10 border-b md:border-b-0 md:border-r border-stone-300">
            <p className="text-center">{strings.squadPoints.totalPoints}</p>
            <p className="ml-4 md:ml-0 text-xl">{points}</p>
          </div>
          <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10 border-b md:border-b-0 md:border-r border-stone-300">
            <p className="text-center">{strings.squadPoints.averagePoints}</p>
            <p className="ml-4 md:ml-0 text-xl">{averagePoints}</p>
          </div>
          <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10">
            <p className="text-center">{strings.squadPoints.hightestPoints}</p>
            <p className="ml-4 md:ml-0 text-xl">{maxPoints}</p>
          </div>
        </div>
      ) : (
        <div className="mb-4">
          <span className="badge-dark">{strings.squadPoints.noLineup}</span>
        </div>
      )}
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
      {lineupUuid ? (
        <section className="relative">
          <div className="absolute w-full top-0 flex flex-row justify-center">
            <p
              className="btn-primary btn-small mr-2"
              onClick={() => setPageState({ ...pageState, viewMode: 'field' })}
            >
              {strings.squadPoints.fieldView}
            </p>
            <p
              className="btn-primary btn-small"
              onClick={() => setPageState({ ...pageState, viewMode: 'list' })}
            >
              {strings.squadPoints.listView}
            </p>
          </div>
          {pageState.viewMode === 'field' ? (
            <div className={`${sportKind}-field pt-10`}>
              <div className="flex flex-col relative bg-no-repeat bg-cover bg-center field">
                {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
                  <div
                    className={`sport-position ${sportPositionName(sportPosition)}`}
                    key={positionKind}
                  >
                    {activePlayersByPosition(positionKind).map((item) => (
                      <PlayerCard
                        key={item.uuid}
                        teamName={pageState.teamNames[item.team.uuid]?.short_name}
                        name={localizeValue(item.player.shirt_name)}
                        value={item.points}
                        number={item.teams_player.shirt_number}
                        status={item.status}
                        injury={item.player.injury}
                        onInfoClick={() => setPlayerUuid(item.player.uuid)}
                      />
                    ))}
                  </div>
                ))}
              </div>
              {sport.changes ? (
                <div className="changes">
                  <div className="flex flex-row justify-center items-center">
                    {reservePlayers().map((item) => (
                      <PlayerCard
                        key={item.uuid}
                        teamName={pageState.teamNames[item.team.uuid]?.short_name}
                        name={localizeValue(item.player.shirt_name)}
                        value={item.points}
                        number={item.teams_player.shirt_number}
                        status={item.status}
                        injury={item.player.injury}
                        onInfoClick={() => setPlayerUuid(item.player.uuid)}
                      />
                    ))}
                    {activeChips.length > 0 ? (
                      <div className="badge-dark absolute top-2 left-2">{renderActiveChip()}</div>
                    ) : null}
                  </div>
                </div>
              ) : null}
            </div>
          ) : null}
          {pageState.viewMode === 'list' ? (
            <div className="w-full overflow-x-scroll pt-10">
              <table cellSpacing="0" className="table w-full">
                <thead>
                  <tr className="bg-stone-200">
                    <th className="py-2 px-4"></th>
                    <th className="py-2 px-4"></th>
                    <th className="py-2 px-4"></th>
                    <th className="text-sm py-2 px-4">{strings.player.pts}</th>
                    {Object.entries(statisticsOrder[sportKind]).map(([stat, value]) => (
                      <th className="tooltip text-sm py-2 px-4" key={stat}>
                        {stat}
                        <span className="tooltiptext">{localizeValue(value)}</span>
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {renderActivePlayers()}
                  {renderReservePlayers()}
                </tbody>
              </table>
            </div>
          ) : null}
        </section>
      ) : null}
      {Object.keys(pageState.teamNames).length > 0 ? (
        <Week id={weekId} teamNames={pageState.teamNames} />
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
