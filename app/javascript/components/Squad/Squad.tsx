import React, { useState, useEffect } from 'react';

import type { TeamNames } from 'entities';
import { SportPosition, LineupPlayer } from 'entities';
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
  weekUuid: number;
  weekPosition: number;
  weekDeadlineAt: string;
}

export const Squad = ({
  seasonUuid,
  sportKind,
  lineupUuid,
  weekUuid,
  weekPosition,
  weekDeadlineAt,
}: SquadProps): JSX.Element => {
  // static data
  const [lineup, setLineup] = useState<TeamNames>({});
  const [teamNames, setTeamNames] = useState<TeamNames>({});
  const [lineupPlayers, setLineupPlayers] = useState<LineupPlayer[]>([]);
  const [teamOpponents, setTeamOpponents] = useState({});
  // main data
  const [playerUuid, setPlayerUuid] = useState<string | undefined>();
  const [playerActionsUuid, setPlayerActionsUuid] = useState<string | undefined>();
  const [alerts, setAlerts] = useState([]);
  // dynamic data
  const [playerUuidForChange, setPlayerUuidForChange] = useState<string | null>(null);
  const [playerUuidsToChange, setPlayerUuidsToChange] = useState<string[]>([]);
  const [changeOrder, setChangeOrder] = useState<number>(0);

  useEffect(() => {
    const fetchLineup = async () => {
      const data = await lineupRequest(lineupUuid);
      setLineup(data);
    };

    const fetchTeams = async () => {
      const data = await teamsRequest(seasonUuid);
      setTeamNames(data);
    };

    const fetchLineupPlayers = async () => {
      const data = await lineupPlayersRequest(lineupUuid);
      setLineupPlayers(data);
    };

    const fetchWeekOpponents = async () => {
      const data = await weekOpponentsRequest(weekUuid);
      setTeamOpponents(data);
    };

    strings.setLanguage(currentLocale);
    fetchLineup();
    fetchTeams();
    fetchLineupPlayers();
    fetchWeekOpponents();
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

  const oppositeTeamNames = (item: LineupPlayer) => {
    if (Object.keys(teamNames).length === 0) return '-';

    const values = teamOpponents[item.team.uuid];
    if (!values || values.length === 0) return '-';

    return values.map((element: number) => teamNames[element].short_name).join(', ');
  };

  const changePlayer = (item: LineupPlayer, isActive: boolean) => {
    if (playerUuidForChange === null) {
      // beginning of change selection
      const positionKind = item.player.position_kind;
      const playersToChange = isActive ? reservePlayers() : lineupPlayers;

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
        .filter((element: number | null) => element);

      setPlayerUuidsToChange(result as number[]);
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
    playerUuidToChange: number,
    stateForInitialPlayer: boolean,
    changeOrderValue: number,
  ) => {
    // playerUuidToChange - id of changeable player
    // playerUuidForChange - id of initial player
    // stateForInitialPlayer - new state for initial player
    setLineupPlayers(
      lineupPlayers.map((element: LineupPlayer) => {
        if (element.uuid === playerUuidToChange) {
          element.active = stateForInitialPlayer;
          element.change_order = stateForInitialPlayer ? 0 : changeOrderValue;
        }
        if (element.uuid === playerUuidForChange) {
          element.active = !stateForInitialPlayer;
          element.change_order = stateForInitialPlayer ? changeOrderValue : 0;
        }
        return element;
      }),
    );
  };

  const changeCaptain = (
    playerUuidToChange: number,
    status: string,
  ) => {
    // playerUuidToChange - id of changeable player
    // status - captain or assistant
    setLineupPlayers(
      lineupPlayers.map((element: LineupPlayer) => {
        if (element.uuid === playerUuidToChange) {
          element.status = status;
        }
        if (element.uuid !== playerUuidToChange && element.status === status) {
          element.status = 'regular';
        }
        return element;
      }),
    );
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
      data: lineupPlayers.map((element: LineupPlayer) => {
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
      setAlerts([['notice', submitResult.message]]);
    } else {
      setAlerts([['alert', submitResult.errors]]);
    }
  };

  const toggleChip = async (value: string) => {
    let activeChips = lineup.active_chips;
    if (activeChips.length === sport.max_chips_per_week && !activeChips.includes(value)) {
      return setAlerts([['alert', strings.squad.chipsLimit]]);
    }

    if (activeChips.includes(value)) {
      activeChips = activeChips.filter((element: string) => element !== value);
    } else {
      activeChips.push(value);
    };

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
      setLineup({
        ...lineup,
        active_chips: activeChips,
      });
      setAlerts([['notice', toggleResultResult.message]]);
    } else {
      setAlerts([['alert', toggleResultResult.errors]]);
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
                className={classListForPlayerCard(item.id)}
                teamName={teamNames[item.team.uuid]?.short_name}
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
              className={classListForPlayerCard(item.id)}
              teamName={teamNames[item.team.uuid]?.short_name}
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
      {lineup?.fantasy_team && Object.entries(lineup.fantasy_team.available_chips).length > 0 ? (
        <div className="chips">
          <h3>{strings.squad.chips}</h3>
          <div className="flex justify-center">
            <button
              className={lineup.active_chips.includes('bench_boost') ? 'button active' : 'button inactive'}
              onClick={() => toggleChip('bench_boost')}
            >
              {strings.squad.benchBoost}
            </button>
            <button
              className={lineup.active_chips.includes('triple_captain') ? 'button active' : 'button inactive'}
              onClick={() => toggleChip('triple_captain')}
            >
              {strings.squad.tripleCaptain}
            </button>
          </div>
        </div>
      ) : null}
      <div id="submit-button">
        <button className="button" onClick={submit}>
          {strings.squad.save}
        </button>
      </div>
      {Object.keys(teamNames).length > 0 ? <Week uuid={weekUuid} teamNames={teamNames} /> : null}
      <Flash values={alerts} />
      <PlayerModal
        sportKind={sportKind}
        seasonUuid={seasonUuid}
        playerUuid={playerUuid}
        teamNames={teamNames}
        onClose={() => setPlayerUuid(undefined)}
      />
      {sport.captain ? (
        <PlayerActionsModal
          lineupPlayer={lineupPlayers.find((item) => item.uuid === playerActionsUuid)}
          onMakeCaptain={changeCaptain}
          onClose={() => setPlayerActionsUuid(undefined)}
        />
      ) : null}
    </>
  );
};
