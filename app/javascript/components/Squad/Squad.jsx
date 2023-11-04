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
  });
  // main data
  const [playerUuid, setPlayerUuid] = useState();
  const [playerActionsUuid, setPlayerActionsUuid] = useState();
  const [alerts, setAlerts] = useState({});
  // dynamic data
  const [changes, setChanges] = useState({
    playerUuidForChange: null,
    playerUuidsToChange: [],
    changeOrder: 0
  })

  useEffect(() => {
    const fetchLineup = async () => await lineupRequest(lineupUuid);
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchLineupPlayers = async () => await lineupPlayersRequest(lineupUuid);
    const fetchWeekOpponents = async () => await weekOpponentsRequest(weekUuid);

    Promise.all([fetchLineup(), fetchTeams(), fetchLineupPlayers(), fetchWeekOpponents()]).then(
      ([fetchLineupData, fetchTeamsData, fetchLineupPlayersData, fetchWeekOpponentsData]) =>
        setPageState({
          loading: false,
          lineup: fetchLineupData,
          teamNames: fetchTeamsData,
          lineupPlayers: fetchLineupPlayersData,
          teamOpponents: fetchWeekOpponentsData,
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

          // skip for players on substitution
          if (!isActive && element.active === false) return null;

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
          changeOrder: item.change_order
        });
      } else {
        setChanges({ ...changes, playerUuidsToChange: result });
      }
    } else {
      if (changes.playerUuidsToChange.includes(item.uuid)) changePlayers(item.uuid, !isActive, Math.max(item.change_order, changes.changeOrder));

      setChanges({
        playerUuidForChange: null,
        playerUuidsToChange: [],
        changeOrder: 0
      });
    }
  };

  const changePlayers = (playerUuidToChange, stateForInitialPlayer, changeOrderValue) => {
    // playerUuidToChange - id of changeable player
    // playerUuidForChange - id of initial player
    // stateForInitialPlayer - new state for initial player
    const changedLineupPlayers = pageState.lineupPlayers.map((element) => {
      if (element.uuid === playerUuidToChange) {
        element.active = stateForInitialPlayer;
        element.change_order = stateForInitialPlayer ? 0 : changeOrderValue;
      }
      if (element.uuid === changes.playerUuidForChange) {
        element.active = !stateForInitialPlayer;
        element.change_order = stateForInitialPlayer ? changeOrderValue : 0;
      }
      return element;
    });

    setPageState({
      ...pageState,
      lineupPlayers: changedLineupPlayers,
    });
  };

  const changeCaptain = (lineupPlayerUuid, status) => {
    // lineupPlayerUuid - id of changeable player
    // status - captain or assistant
    const changedLineupPlayers = pageState.lineupPlayers.map((element) => {
      if (element.uuid === lineupPlayerUuid) {
        element.status = status;
      }
      if (element.uuid !== lineupPlayerUuid && element.status === status) {
        element.status = 'regular';
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

  return (
    <>
      <span className="inline-block bg-zinc-800 text-white text-sm py-1 px-2 rounded mr-2">
        {strings.formatString(strings.squadPoints.week, { number: weekPosition })}
      </span>
      <h1>{strings.squad.title}</h1>
      <div className={`${sportKind}-field`}>
        <div className="flex flex-col relative bg-no-repeat bg-cover bg-center field">
          {sport.changes ? (
            <span className="absolute left-4 top-4 bg-red-600 text-white text-sm py-1 px-2 rounded shadow">
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
                  onCardClick={sport.captain ? () => setPlayerActionsUuid(item.uuid) : undefined}
                  onActionClick={sport.changes ? () => changePlayer(item, true) : undefined}
                  onInfoClick={() => setPlayerUuid(item.player.uuid)}
                />
              ))}
            </div>
          ))}
        </div>
        {sport.changes ? (
          <div className="changes flex flex-row justify-center items-center sm:py-4 bg-green-400/50 mb-4">
            {reservePlayers().map((item) => (
              <PlayerCard
                key={item.uuid}
                className={classListForPlayerCard(item.uuid)}
                teamName={pageState.teamNames[item.team.uuid]?.short_name}
                name={localizeValue(item.player.shirt_name)}
                value={oppositeTeamNames(item)}
                number={item.teams_player.shirt_number}
                status={item.status}
                onCardClick={sport.captain ? () => setPlayerActionsUuid(item.uuid) : undefined}
                onActionClick={() => changePlayer(item, false)}
                onInfoClick={() => setPlayerUuid(item.player.uuid)}
              />
            ))}
          </div>
        ) : null}
      </div>
      {pageState.lineup?.fantasy_team && Object.entries(pageState.lineup.fantasy_team.available_chips).length > 0 ? (
        <div className="mb-4">
          <h3 className="text-center">{strings.squad.chips}</h3>
          <div className="flex justify-center">
            <button
              className={
                pageState.lineup.active_chips.includes('bench_boost')
                  ? 'btn-primary btn-small mr-2 bg-green-800'
                  : 'btn-primary btn-small mr-2'
              }
              onClick={() => toggleChip('bench_boost')}
            >
              {strings.squad.benchBoost}
            </button>
            <button
              className={
                pageState.lineup.active_chips.includes('triple_captain')
                  ? 'btn-primary btn-small bg-green-800'
                  : 'btn-primary btn-small'
              }
              onClick={() => toggleChip('triple_captain')}
            >
              {strings.squad.tripleCaptain}
            </button>
          </div>
        </div>
      ) : null}
      {sport?.changes ? (
        <div>
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
