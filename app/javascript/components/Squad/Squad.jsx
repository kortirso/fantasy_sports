import React, { useState, useEffect } from 'react';

import { sportsData } from '../../data';
import { currentLocale, localizeValue, csrfToken } from '../../helpers';
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
  const [playerUuidForChange, setPlayerUuidForChange] = useState(null);
  const [playerUuidsToChange, setPlayerUuidsToChange] = useState([]);
  const [changeOrder, setChangeOrder] = useState(0);

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

  const sportPositionName = (sportPosition) => {
    return sportPosition.name.en.split(' ').join('-');
  };

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
    if (playerUuidForChange === null) {
      // beginning of change selection
      const positionKind = item.player.position_kind;
      const playersToChange = isActive ? reservePlayers() : pageState.lineupPlayers;

      let activePlayersOnPosition = isActive ? activePlayersByPosition(positionKind).length : 0;
      let activePlayersOnNextPosition = isActive ? 0 : activePlayersByPosition(positionKind).length;

      const result = playersToChange
        .map((element) => {
          // skip for the same player
          if (element.uuid === item.uuid) return null;

          const nextPositionKind = element.player.position_kind;
          // allow change for player on the same position
          if (nextPositionKind === positionKind) return element.uuid;

          // skip change if current position player amount will left less than minimum
          if (!isActive) activePlayersOnPosition = activePlayersByPosition(nextPositionKind).length;
          if (activePlayersOnPosition === sportPositions[positionKind].min_game_amount) return null;
          // skip change if change position player amount will be more than maximum
          if (isActive)
            activePlayersOnNextPosition = activePlayersByPosition(nextPositionKind).length;
          if (activePlayersOnNextPosition === sportPositions[nextPositionKind].max_game_amount)
            return null;
          // allow change for player
          return element.uuid;
        })
        .filter((element) => element);

      setPlayerUuidsToChange(result);
      if (result.length > 0) {
        setChangeOrder(item.change_order);
        setPlayerUuidForChange(item.uuid);
      }
    } else {
      if (playerUuidsToChange.includes(item.uuid))
        changePlayers(item.uuid, !isActive, Math.max(item.change_order, changeOrder));

      setChangeOrder(0);
      setPlayerUuidForChange(null);
      setPlayerUuidsToChange([]);
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
      if (element.uuid === playerUuidForChange) {
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
      playerUuidForChange === uuid ? 'bg-red-400/75' : '',
      playerUuidsToChange.includes(uuid) ? 'bg-green-400/75' : '',
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
      <div className={`flex flex-col relative bg-no-repeat bg-contain bg-center ${sportKind}-field`}>
        {sport.changes ? (
          <span className="absolute left-16 top-4 inline-block bg-red-600 text-white text-sm py-1 px-2 rounded mb-4">
            <span>{strings.formatString(strings.squad.deadline, { value: weekDeadlineAt })}</span>
          </span>
        ) : null }
        {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
          <div
            className={`flex flex-row justify-center sport-position ${sportPositionName(sportPosition)}`}
            key={positionKind}
          >
            {activePlayersByPosition(positionKind).map((item) => (
              <PlayerCard
                key={item.uuid}
                className={classListForPlayerCard(item.uuid)}
                teamName={pageState.teamNames[item.team.uuid]?.short_name}
                name={localizeValue(item.player.name).split(' ')[0]}
                value={oppositeTeamNames(item)}
                status={item.status}
                onCardClick={sport.captain ? () => setPlayerActionsUuid(item.uuid) : undefined}
                onActionClick={sport.changes ? () => changePlayer(item, true) : undefined}
                onInfoClick={() => setPlayerUuid(item.teams_player.uuid)}
              />
            ))}
          </div>
        ))}
      </div>
      {sport.changes ? (
        <div className="flex flex-row justify-center mt-4 mb-8">
          {reservePlayers().map((item) => (
            <PlayerCard
              key={item.uuid}
              className={classListForPlayerCard(item.uuid)}
              teamName={pageState.teamNames[item.team.uuid]?.short_name}
              name={localizeValue(item.player.name).split(' ')[0]}
              value={oppositeTeamNames(item)}
              status={item.status}
              onCardClick={sport.captain ? () => setPlayerActionsUuid(item.uuid) : undefined}
              onActionClick={() => changePlayer(item, false)}
              onInfoClick={() => setPlayerUuid(item.teams_player.uuid)}
            />
          ))}
        </div>
      ) : null}
      {pageState.lineup?.fantasy_team &&
      Object.entries(pageState.lineup.fantasy_team.available_chips).length > 0 ? (
        <div>
          <h3 className="text-center">{strings.squad.chips}</h3>
          <div className="flex justify-center">
            <button
              className={
                pageState.lineup.active_chips.includes('bench_boost')
                  ? 'btn-primary btn-small mr-2 bg-blue-800'
                  : 'btn-primary btn-small'
              }
              onClick={() => toggleChip('bench_boost')}
            >
              {strings.squad.benchBoost}
            </button>
            <button
              className={
                pageState.lineup.active_chips.includes('triple_captain')
                  ? 'btn-primary btn-small mr-2 bg-blue-800'
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
      <Flash values={alerts} />
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