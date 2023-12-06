import React, { useState, useEffect } from 'react';

import { sportsData } from '../../data';
import { currentLocale, localizeValue, csrfToken, convertDateTime } from '../../helpers';
import { strings } from '../../locales';

import { Flash } from '../../components/atoms';
import { Week, PlayerModal, PlayerActionsModal, PlayerCard } from '../../components';

import { apiRequest } from '../../requests/helpers/apiRequest';
import { teamsRequest } from '../../requests/teamsRequest';

import { lineupRequest } from './requests/lineupRequest';
import { lineupPlayersRequest } from './requests/lineupPlayersRequest';
import { weekOpponentsRequest } from './requests/weekOpponentsRequest';

strings.setLanguage(currentLocale);

export const Squad = ({
  seasonUuid,
  sportKind,
  lineupUuid,
  activeChips,
  weekUuid,
  weekPosition,
  weekDeadlineAt,
}) => {
  const [pageState, setPageState] = useState({
    loading: true,
    lineup: { uuid: '', active_chips: [], fantasy_team: { available_chips: {} } },
    teamNames: {},
    lineupPlayers: [],
    teamOpponents: {},
    viewMode: 'field', // options - 'field', 'list'
  });
  // main data
  const [playerUuid, setPlayerUuid] = useState();
  const [playerActionsUuid, setPlayerActionsUuid] = useState();
  const [alerts, setAlerts] = useState({});
  // dynamic data
  const [changes, setChanges] = useState({
    playerUuidForChange: null,
    playerUuidsToChange: [],
    changeActive: false,
    changeOrder: 0
  })

  useEffect(() => {
    const fetchLineup = async () => await lineupRequest(lineupUuid);
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchLineupPlayers = async () => await lineupPlayersRequest(lineupUuid);
    const fetchWeekOpponents = async () => await weekOpponentsRequest(weekUuid);

    Promise.all([fetchLineup(), fetchTeams(), fetchLineupPlayers(), fetchWeekOpponents()]).then(
      ([lineupData, teamsData, lineupPlayersData, weekOpponentsData]) =>
        setPageState({
          ...pageState,
          loading: false,
          lineup: lineupData,
          teamNames: teamsData,
          lineupPlayers: lineupPlayersData,
          teamOpponents: weekOpponentsData,
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
      .filter((element) => {
        return !element.active;
      })
      .sort((a, b) => {
        return a.change_order > b.change_order ? 1 : -1;
      });
  };

  const oppositeTeamNames = (item) => {
    if (Object.keys(pageState.teamNames).length === 0) return '-';

    const values = pageState.teamOpponents[item.team.uuid];
    if (values === undefined) return '-';
    if (values.length === 0) return '-';

    return values.map((element) => pageState.teamNames[element].short_name).join(', ');
  };

  const changePlayer = (item, isActive) => {
    if (changes.playerUuidForChange === null) {
      let positionKind = isActive ? item.player.position_kind : null; // position who left field
      let nextPositionKind = isActive ? null : item.player.position_kind; // added to position
      const playersToChange = isActive ? reservePlayers() : pageState.lineupPlayers;

      const result = playersToChange
        .map((element) => {
          // skip for the same player
          if (element.uuid === item.uuid) return null;

          // allow for reserve players change with each other (except goalkeeper)
          if (element.change_order > 1 && item.change_order > 1) return element.uuid;

          if (isActive) nextPositionKind = element.player.position_kind;
          else positionKind = element.player.position_kind;
          // allow change for player on the same position
          if (nextPositionKind === positionKind) return element.uuid;

          // skip change if current position player amount will left less than minimum
          if (activePlayersByPosition(positionKind).length === sportPositions[positionKind].min_game_amount) return null;
          // skip change if next position player amount will be more than maximum
          if (activePlayersByPosition(nextPositionKind).length === sportPositions[nextPositionKind].max_game_amount) return null;

          // allow change for player
          return element.uuid;
        })
        .filter((element) => element);

      if (result.length > 0) {
        setChanges({
          playerUuidForChange: item.uuid,
          playerUuidsToChange: result,
          changeActive: item.active,
          changeOrder: item.change_order
        });
      } else {
        setChanges({ ...changes, playerUuidsToChange: result });
      }
    } else {
      if (changes.playerUuidsToChange.includes(item.uuid)) changePlayers(item.uuid, item.active, item.change_order);

      setChanges({
        playerUuidForChange: null,
        playerUuidsToChange: [],
        changeActive: false,
        changeOrder: 0
      });
    }
  };

  const changePlayers = (uuid, active, changeOrder) => {
    // item - changeable player
    const changedLineupPlayers = pageState.lineupPlayers.map((element) => {
      // for changleable player set remembered active and order
      if (element.uuid === uuid) {
        element.active = changes.changeActive;
        element.change_order = changes.changeOrder;
      }
      // for remembered player set current player's active and order
      if (element.uuid === changes.playerUuidForChange) {
        element.active = active;
        element.change_order = changeOrder;
      }
      return element;
    });

    setPageState({
      ...pageState,
      lineupPlayers: changedLineupPlayers,
    });
  };

  const changeCaptain = (lineupPlayer, status) => {
    // lineupPlayer - changeable player
    // status - captain or assistant
    const oldStatus = lineupPlayer.status; // captain, assistant or regular
    const changedLineupPlayers = pageState.lineupPlayers.map((element) => {
      // for current player -> change to status
      if (element.uuid === lineupPlayer.uuid) {
        element.status = status;
      }
      // for another player with such status -> change
      if (element.uuid !== lineupPlayer.uuid && element.status === status) {
        if (status === 'captain' && oldStatus === 'assistant') element.status = 'assistant';
        else if (status === 'assistant' && oldStatus === 'captain') element.status = 'captain';
        else element.status = 'regular';
      }
      return element;
    });
    setPageState({
      ...pageState,
      lineupPlayers: changedLineupPlayers,
    });
    setPlayerActionsUuid(undefined);
  };

  const classListForPlayerCard = (uuid) => {
    return [
      changes.playerUuidForChange === uuid ? 'bg-red-400/75' : '',
      changes.playerUuidsToChange.includes(uuid) ? 'bg-green-400/75' : '',
    ].join(' ');
  };

  const submit = async () => {
    const payload = {
      data: pageState.lineupPlayers.map((element) => {
        return {
          uuid: element.uuid,
          active: element.active,
          change_order: element.change_order,
          status: element.status,
        };
      }),
    };

    const requestOptions = {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ lineup_players: payload }),
    };

    const submitResult = await apiRequest({
      url: `/lineups/${lineupUuid}/players.json`,
      options: requestOptions,
    });
    if (submitResult.message) {
      setAlerts({ notice: submitResult.message });
    } else {
      setAlerts({ alert: submitResult.errors });
    }
  };

  const toggleChip = async (value) => {
    let activeChips = pageState.lineup.active_chips;
    if (activeChips.length === sport.max_chips_per_week && !activeChips.includes(value)) {
      return setAlerts({ alert: strings.squad.chipsLimit });
    }

    if (activeChips.includes(value)) {
      activeChips = activeChips.filter((element) => element !== value);
    } else {
      activeChips.push(value);
    }

    const payload = { active_chips: activeChips };

    const requestOptions = {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ lineup: payload }),
    };

    const toggleResultResult = await apiRequest({
      url: `/lineups/${lineupUuid}.json`,
      options: requestOptions,
    });
    if (toggleResultResult.message) {
      const updatedLineup = { ...pageState.lineup, active_chips: activeChips };
      setPageState({
        ...pageState,
        lineup: updatedLineup,
      });
      setAlerts({ notice: toggleResultResult.message });
    } else {
      setAlerts({ alert: toggleResultResult.errors });
    }
  };

  const renderBenchBoostStatus = () => {
    if (pageState.lineup.active_chips.includes('bench_boost')) return 'btn-primary btn-small mr-2 bg-amber-400';
    if (pageState.lineup.fantasy_team.available_chips.bench_boost === 0 && !activeChips.includes('bench_boost')) return 'btn-disabled btn-small mr-2';
    return 'btn-primary btn-small mr-2';
  };

  const renderTripleCaptainStatus = () => {
    if (pageState.lineup.active_chips.includes('triple_captain')) return 'btn-primary btn-small bg-amber-400';
    if (pageState.lineup.fantasy_team.available_chips.triple_captain === 0 && !activeChips.includes('triple_captain')) return 'btn-disabled btn-small';
    return 'btn-primary btn-small';
  };

  const injuryLevelClass = (injury) => {
    if (injury === null) return 'player-info';

    const data = injury.data.attributes;
    if (data.status === 0) return 'player-info-alert';
    return 'player-info-warning';
  };

  const renderDifficulty = (value) => {
    if (value === 5) return <span className="bg-orange-700 border border-orange-800 py-1 px-2 rounded text-sm text-white mr-1">{value}</span>;
    if (value === 4) return <span className="bg-amber-300 border border-amber-400 py-1 px-2 rounded text-sm mr-1">{value}</span>;
    if (value === 3) return <span className="bg-stone-300 border border-stone-400 py-1 px-2 rounded text-sm mr-1">{value}</span>;
    if (value === 2) return <span className="bg-green-300 border border-green-400 py-1 px-2 rounded text-sm mr-1">{value}</span>;
  };

  const renderActivePlayers = () => {
    return Object.entries(sportPositions).map(([positionKind, sportPosition]) => {
      return activePlayersByPosition(positionKind).map((item) => (
        <tr key={item.uuid} className={classListForPlayerCard(item.uuid)}>
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
            <p>{localizeValue(item.player.shirt_name)}</p>
            <p className="text-xs">{pageState.teamNames[item.team.uuid]?.short_name}</p>
          </td>
          <td className="text-sm">{localizeValue(sportPositions[item.player.position_kind].short_name)}</td>
          <td>{item.last_points ? item.last_points.points : null}</td>
          <td>{item.player.form}</td>
          <td>{item.player.points}</td>
          <td>{item.player.price}</td>
          <td>
            {item.fixtures.map((fixture) => renderDifficulty(fixture))}
          </td>
          {sport.changes ? (
            <td>
              <div className="flex justify-center items-center">
                <span
                  className="cursor-pointer bg-white border border-stone-200 hover:bg-stone-100 rounded px-1"
                  onClick={() => changePlayer(item, true)}
                >
                  +/-
                </span>
              </div>
            </td>
          ) : null}
        </tr>
      ));
    });
  };

  const renderReservePlayers = () => {
    return reservePlayers().map((item) => (
      <tr key={item.uuid} className={classListForPlayerCard(item.uuid)}>
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
          <p>{localizeValue(item.player.shirt_name)}</p>
          <p className="text-xs">{pageState.teamNames[item.team.uuid]?.short_name}</p>
        </td>
        <td className="text-sm">{localizeValue(sportPositions[item.player.position_kind].short_name)}</td>
        <td>{item.last_points ? item.last_points.points : null}</td>
        <td>{item.player.form}</td>
        <td>{item.player.points}</td>
        <td>{item.player.price}</td>
        <td>
          {item.fixtures.map((fixture) => renderDifficulty(fixture))}
        </td>
        {sport.changes ? (
          <td>
            <div className="flex justify-center items-center">
              <span
                className="cursor-pointer bg-white border border-stone-200 hover:bg-stone-100 rounded px-1"
                onClick={() => changePlayer(item, false)}
              >
                +/-
              </span>
            </div>
          </td>
        ) : null}
      </tr>
    ));
  };

  return (
    <>
      <span className="badge-dark inline-block mr-2">
        {strings.formatString(strings.squadPoints.week, { number: weekPosition })}
      </span>
      <h1 className="mb-2">{strings.squad.title}</h1>
      <p className="mb-4">{strings.squad.description}</p>
      <section className="relative">
        <div className="absolute w-full top-0 flex flex-row justify-center">
          <p
            className="bg-amber-200 hover:bg-amber-300 border border-amber-300 text-sm py-1 px-2 rounded cursor-pointer mr-2"
            onClick={() => setPageState({ ...pageState, viewMode: 'field' })}
          >
            {strings.squadPoints.fieldView}
          </p>
          <p
            className="bg-amber-200 hover:bg-amber-300 border border-amber-300 text-sm py-1 px-2 rounded cursor-pointer"
            onClick={() => setPageState({ ...pageState, viewMode: 'list' })}
          >
            {strings.squadPoints.listView}
          </p>
        </div>
        {pageState.viewMode === 'field' ? (
          <div className={`${sportKind}-field pt-10`}>
            <div className="flex flex-col relative bg-no-repeat bg-cover bg-center field">
              {sport.changes ? (
                <span className="badge-danger absolute left-4 top-4">
                  <span>{strings.formatString(strings.squad.deadline, { value: convertDateTime(weekDeadlineAt) })}</span>
                </span>
              ) : null }
              {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
                <div
                  className={`sport-position ${sportPositionName(sportPosition)}`}
                  key={positionKind}
                >
                  {activePlayersByPosition(positionKind).map((item) => (
                    <PlayerCard
                      key={item.uuid}
                      className={classListForPlayerCard(item.uuid)}
                      teamName={pageState.teamNames[item.team.uuid]?.short_name}
                      name={localizeValue(item.player.shirt_name)}
                      value={oppositeTeamNames(item)}
                      number={item.teams_player.shirt_number}
                      status={item.status}
                      injury={item.player.injury}
                      onCardClick={sport.captain ? () => setPlayerActionsUuid(item.uuid) : undefined}
                      onActionClick={sport.changes ? () => changePlayer(item, true) : undefined}
                      onInfoClick={() => setPlayerUuid(item.player.uuid)}
                    />
                  ))}
                </div>
              ))}
            </div>
            {sport.changes ? (
              <div className="changes">
                <div className="flex flex-row justify-center items-center mb-2">
                  {reservePlayers().map((item) => (
                    <PlayerCard
                      key={item.uuid}
                      className={classListForPlayerCard(item.uuid)}
                      teamName={pageState.teamNames[item.team.uuid]?.short_name}
                      name={localizeValue(item.player.shirt_name)}
                      value={oppositeTeamNames(item)}
                      number={item.teams_player.shirt_number}
                      status={item.status}
                      injury={item.player.injury}
                      onCardClick={sport.captain ? () => setPlayerActionsUuid(item.uuid) : undefined}
                      onActionClick={() => changePlayer(item, false)}
                      onInfoClick={() => setPlayerUuid(item.player.uuid)}
                    />
                  ))}
                </div>
                <p className="px-4 md:px-12">{strings.squad.reservePriority}</p>
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
                  <th className="text-sm py-2 px-4">{strings.squad.lastPoints}</th>
                  <th className="text-sm py-2 px-4">{strings.player.form}</th>
                  <th className="text-sm py-2 px-4">{strings.squad.pts}</th>
                  <th className="text-sm py-2 px-4">{strings.player.price}</th>
                  <th className="text-sm py-2 px-4">{strings.player.difficulty}</th>
                  {sport.changes ? (
                    <th className="py-2 px-4"></th>
                  ) : null}
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
      {pageState.lineup?.fantasy_team && Object.entries(pageState.lineup.fantasy_team.available_chips).length > 0 ? (
        <div className="my-8">
          <div className="mb-2">
            <h3 className="text-center">{strings.squad.chips}</h3>
            <div className="flex justify-center">
              <button
                className={renderBenchBoostStatus()}
                onClick={pageState.lineup.fantasy_team.available_chips.bench_boost > 0 || activeChips.includes('bench_boost') ? (() => toggleChip('bench_boost')) : null}
              >
                {strings.squad.benchBoost}
              </button>
              <button
                className={renderTripleCaptainStatus()}
                onClick={pageState.lineup.fantasy_team.available_chips.triple_captain > 0 || activeChips.includes('triple_captain') ? (() => toggleChip('triple_captain')) : null}
              >
                {strings.squad.tripleCaptain}
              </button>
            </div>
          </div>
          <p className="px-4 md:px-12">{strings.squad.bonusesHelp}</p>
        </div>
      ) : null}
      {sport?.changes ? (
        <div className="text-center mb-8">
          <button className="btn-primary" onClick={submit}>
            {strings.squad.save}
          </button>
        </div>
      ) : null}
      {Object.keys(pageState.teamNames).length > 0 ? (
        <Week uuid={weekUuid} teamNames={pageState.teamNames} />
      ) : null}
      <Flash content={alerts} />
      <PlayerModal
        sportKind={sportKind}
        seasonUuid={seasonUuid}
        playerUuid={playerUuid}
        teamNames={pageState.teamNames}
        onClose={() => setPlayerUuid(undefined)}
      />
      {sport.captain ? (
        <PlayerActionsModal
          lineupPlayer={pageState.lineupPlayers.find((item) => item.uuid === playerActionsUuid)}
          onMakeCaptain={changeCaptain}
          onClose={() => setPlayerActionsUuid(undefined)}
        />
      ) : null}
    </>
  );
};
