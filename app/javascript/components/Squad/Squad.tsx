import React, { useState, useEffect } from 'react';

import type { TeamNames, TeamOpponents } from 'entities';
import { SportPosition, LineupPlayer, Lineup } from 'entities';
import { sportsData } from 'data';
import { currentLocale, localizeValue, csrfToken } from 'helpers';
import { strings } from 'locales';

import { Flash } from 'components/atoms';
import { Week, PlayerModal, PlayerActionsModal, PlayerCard } from 'components';

import { apiRequest } from 'requests/helpers/apiRequest';
import { teamsRequest } from 'requests/teamsRequest';
import { lineupRequest } from './requests/lineupRequest';
import { lineupPlayersRequest } from './requests/lineupPlayersRequest';
import { weekOpponentsRequest } from './requests/weekOpponentsRequest';

interface SquadProps {
  seasonUuid: string;
  sportKind: string;
  lineupUuid: string;
  weekUuid: string;
  weekPosition: number;
  weekDeadlineAt: string;
}

interface PageState {
  loading: boolean;
  lineup: Lineup;
  teamNames: TeamNames;
  lineupPlayers: LineupPlayer[];
  teamOpponents: TeamOpponents;
}

strings.setLanguage(currentLocale);

export const Squad = ({
  seasonUuid,
  sportKind,
  lineupUuid,
  weekUuid,
  weekPosition,
  weekDeadlineAt,
}: SquadProps): JSX.Element => {
  const [pageState, setPageState] = useState<PageState>({
    loading: true,
    lineup: { uuid: '', active_chips: [], fantasy_team: { available_chips: {} } },
    teamNames: {},
    lineupPlayers: [],
    teamOpponents: {},
  });
  // main data
  const [playerUuid, setPlayerUuid] = useState<string>();
  const [playerActionsUuid, setPlayerActionsUuid] = useState<string>();
  const [alerts, setAlerts] = useState({});
  // dynamic data
  const [playerUuidForChange, setPlayerUuidForChange] = useState<string | null>(null);
  const [playerUuidsToChange, setPlayerUuidsToChange] = useState<string[]>([]);
  const [changeOrder, setChangeOrder] = useState<number>(0);

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

  const sportPositionName = (sportPosition: SportPosition) => {
    return sportPosition.name.en.split(' ').join('-');
  };

  const activePlayersByPosition = (positionKind: string) => {
    return pageState.lineupPlayers.filter(
      (element: LineupPlayer) => element.active && element.player.position_kind === positionKind,
    );
  };

  const reservePlayers = () => {
    return pageState.lineupPlayers
      .filter((element: LineupPlayer) => {
        return !element.active;
      })
      .sort((a: LineupPlayer, b: LineupPlayer) => {
        return a.change_order > b.change_order ? 1 : -1;
      });
  };

  const oppositeTeamNames = (item: LineupPlayer) => {
    if (Object.keys(pageState.teamNames).length === 0) return '-';

    const values = pageState.teamOpponents[item.team.uuid as keyof TeamOpponents] as
      | string[]
      | undefined;
    if (values === undefined) return '-';
    if (values.length === 0) return '-';

    return values.map((element: string) => pageState.teamNames[element].short_name).join(', ');
  };

  const changePlayer = (item: LineupPlayer, isActive: boolean) => {
    if (playerUuidForChange === null) {
      // beginning of change selection
      const positionKind = item.player.position_kind;
      const playersToChange = isActive ? reservePlayers() : pageState.lineupPlayers;

      let activePlayersOnPosition = isActive ? activePlayersByPosition(positionKind).length : 0;
      let activePlayersOnNextPosition = isActive ? 0 : activePlayersByPosition(positionKind).length;

      const result = playersToChange
        .map((element: LineupPlayer) => {
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
        .filter((element: string | null) => element);

      setPlayerUuidsToChange(result as string[]);
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

  const changePlayers = (
    playerUuidToChange: string,
    stateForInitialPlayer: boolean,
    changeOrderValue: number,
  ) => {
    // playerUuidToChange - id of changeable player
    // playerUuidForChange - id of initial player
    // stateForInitialPlayer - new state for initial player
    const changedLineupPlayers = pageState.lineupPlayers.map((element: LineupPlayer) => {
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

  const changeCaptain = (lineupPlayerUuid: string, status: string) => {
    // lineupPlayerUuid - id of changeable player
    // status - captain or assistant
    const changedLineupPlayers = pageState.lineupPlayers.map((element: LineupPlayer) => {
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

  const classListForPlayerCard = (uuid: string) => {
    return [
      'player-card',
      playerUuidForChange === uuid ? 'for-change' : '',
      playerUuidsToChange.includes(uuid) ? 'to-change' : '',
    ].join(' ');
  };

  const submit = async () => {
    const payload = {
      data: pageState.lineupPlayers.map((element: LineupPlayer) => {
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

  const toggleChip = async (value: string) => {
    let activeChips = pageState.lineup.active_chips;
    if (activeChips.length === sport.max_chips_per_week && !activeChips.includes(value)) {
      return setAlerts({ alert: strings.squad.chipsLimit });
    }

    if (activeChips.includes(value)) {
      activeChips = activeChips.filter((element: string) => element !== value);
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
      <div className="deadline flex items-center justify-center">
        <span>{strings.formatString(strings.transfers.week, { number: weekPosition })}</span>
        <span>{weekDeadlineAt}</span>
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
        <div className="substitutions">
          {reservePlayers().map((item: LineupPlayer) => (
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
        <div className="chips">
          <h3>{strings.squad.chips}</h3>
          <div className="flex justify-center">
            <button
              className={
                pageState.lineup.active_chips.includes('bench_boost')
                  ? 'button active'
                  : 'button inactive'
              }
              onClick={() => toggleChip('bench_boost')}
            >
              {strings.squad.benchBoost}
            </button>
            <button
              className={
                pageState.lineup.active_chips.includes('triple_captain')
                  ? 'button active'
                  : 'button inactive'
              }
              onClick={() => toggleChip('triple_captain')}
            >
              {strings.squad.tripleCaptain}
            </button>
          </div>
        </div>
      ) : null}
      {sport?.changes ? (
        <div id="submit-button">
          <button className="button" onClick={submit}>
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
