import React, { useState, useMemo, useEffect } from 'react';

import type { TeamNames } from 'entities';
import { SportPosition, Player, TeamsPlayer, KeyValue } from 'entities';
import { sportsData } from 'data';
import { currentLocale, localizeValue, showAlert, csrfToken } from 'helpers';
import { strings } from 'locales';

import { Dropdown, Modal } from 'components/atoms';
import { Week, PlayerModal, PlayerCard } from 'components';

import { apiRequest } from 'requests/helpers/apiRequest';
import { teamsRequest } from 'requests/teamsRequest';
import { fantasyTeamPlayersRequest } from './requests/fantasyTeamPlayersRequest';
import { seasonPlayersRequest } from './requests/seasonPlayersRequest';

interface TransfersProps {
  seasonId: string;
  sportKind: string;
  fantasyTeamUuid: string;
  fantasyTeamCompleted: boolean;
  fantasyTeamBudget: number;
  weekId: number;
  weekPosition: number;
  weekDeadlineAt: string;
  transfersLimited: boolean;
  freeTransfers: number;
}

interface TransfersData {
  in_names: KeyValue[];
  out_names: KeyValue[];
  points_penalty: number;
}

const playerSortParams = ['points'];

const PER_PAGE = 20;

export const Transfers = ({
  seasonId,
  sportKind,
  fantasyTeamUuid,
  fantasyTeamCompleted,
  fantasyTeamBudget,
  weekId,
  weekPosition,
  weekDeadlineAt,
  transfersLimited,
  freeTransfers
}: TransfersProps): JSX.Element => {
  // static data
  const [teamNames, setTeamNames] = useState<TeamNames>({});
  const [seasonPlayers, setSeasonPlayers] = useState<TeamsPlayer[]>([]);
  // main data
  const [teamMembers, setTeamMembers] = useState<TeamsPlayer[]>([]);
  const [budget, setBudget] = useState<number>(fantasyTeamBudget);
  const [teamName, setTeamName] = useState<string>('');
  const [playerId, setPlayerId] = useState<number | undefined>();
  const [playersByPosition, setPlayersByPosition] = useState({});
  const [favouriteTeamId, setFavouriteTeamId] = useState<string | null>(null);
  const [transfersData, setTransfersData] = useState<TransfersData | null>(null);
  // filters state
  const [filterByPosition, setFilterByPosition] = useState<string>('all');
  const [filterByTeam, setFilterByTeam] = useState<string>('all');
  const [sortBy, setSortBy] = useState<string>('points');
  const [page, setPage] = useState<number>(0);

  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  useEffect(() => {
    const fetchTeams = async () => {
      const data = await teamsRequest(seasonId);
      setTeamNames(data);
    };

    const fetchSeasonPlayers = async () => {
      const data = await seasonPlayersRequest(seasonId);
      setSeasonPlayers(data);
    };

    const fetchFantasyTeamPlayers = async () => {
      const data = await fantasyTeamPlayersRequest(fantasyTeamUuid);
      setTeamMembers(data);
    };

    strings.setLanguage(currentLocale);
    fetchTeams();
    fetchSeasonPlayers();
    if (fantasyTeamCompleted) fetchFantasyTeamPlayers();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    setPlayersByPosition(
      Object.keys(sportPositions).reduce(
        (result, sportPosition) => {
          result[sportPosition] = teamMembers.filter((item: TeamsPlayer) => {
            return item.player.position_kind === sportPosition;
          });
          return result;
        },
        {} as KeyValue,
      )
    );
  }, [sportPositions, teamMembers]);

  const filteredPlayers = useMemo(() => {
    return seasonPlayers
      .filter((element: TeamsPlayer) => {
        if (filterByPosition !== 'all' && filterByPosition !== element.player.position_kind)
          return false;
        if (filterByTeam !== 'all' && filterByTeam !== element.team.id.toString()) return false;

        return true;
      })
      .sort((a: TeamsPlayer, b: TeamsPlayer) => {
        if (playerSortParams.includes(sortBy)) {
          return a.player[sortBy as keyof Player] < b.player[sortBy as keyof Player] ? 1 : -1;
        } else {
          return a[sortBy as keyof TeamsPlayer] < b[sortBy as keyof TeamsPlayer] ? 1 : -1;
        }
      })
      .slice(page * PER_PAGE, page * PER_PAGE + PER_PAGE);
  }, [seasonPlayers, filterByPosition, filterByTeam, page, sortBy]);

  const lastPageIndex = useMemo(() => {
    return Math.trunc(filteredPlayers.length / PER_PAGE) + 1;
  }, [filteredPlayers]);

  const pageDown = () => {
    if (page !== 0) setPage(page - 1);
  };

  const pageUp = () => {
    if (page !== lastPageIndex - 1) setPage(page + 1);
  };

  const addTeamMember = (item: TeamsPlayer) => {
    // if fantasy team is full
    if (teamMembers.length === sport.max_players) return showAlert('alert', `<p>${strings.transfers.teamFull}</p>`);
    // if player is already in team
    if (teamMembers.find((element: TeamsPlayer) => element.id === item.id)) return showAlert('alert', `<p>${strings.transfers.playerInTeam}</p>`);
    // if all position already in use
    const positionKind = item.player.position_kind;
    const positionsLeft =
      sportPositions[positionKind].total_amount - playersByPosition[positionKind].length;
    if (positionsLeft === 0) return showAlert('alert', `<p>${strings.transfers.noPositions}</p>`);
    // if there are already max_team_players
    const playersFromTeam = teamMembers.filter((element: TeamsPlayer) => {
      return element.team.id === item.team.id;
    });
    if (playersFromTeam.length >= sport.max_team_players) return showAlerts('alert', `<p>${strings.formatString(strings.transfers.maxTeamPlayers, { number: sport.max_team_players })}</p>`);

    setTeamMembers(teamMembers.concat(item));
    setBudget(budget - item.price);
  };

  const sportPositionName = (sportPosition: SportPosition) => {
    return sportPosition.name.en.split(' ').join('-');
  };

  const removeTeamMember = (element: TeamsPlayer) => {
    setTeamMembers(teamMembers.filter((item: TeamsPlayer) => item.id !== element.id));
    setBudget(budget + element.price);
  };

  const renderEmptySlots = (positionKind: string) => {
    if (!playersByPosition[positionKind]) return null;

    const emptySlots = sportPositions[positionKind].total_amount - playersByPosition[positionKind].length;
    return [...Array(emptySlots).keys()].map((item: number) => {
      return (
        <PlayerCard
          key={item}
          name=''
          value=''
        />
      )
    });
  }

  const submit = async () => {
    const payload = {
      fantasy_team: {
        name: teamName,
        budget_cents: budget * 100,
        favourite_team_id: favouriteTeamId ? parseInt(favouriteTeamId, 10) : null,
        teams_players_ids: teamMembers.map((element: TeamsPlayer) => element.id),
      },
    };

    const requestOptions = {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify(payload),
    };

    const submitResult = await apiRequest({
      url: `/fantasy_teams/${fantasyTeamUuid}.json`,
      options: requestOptions,
    });
    if (submitResult.redirect_path) {
      window.location = submitResult.redirect_path;
    } else {
      submitResult.errors.forEach((error: string) => showAlert('alert', `<p>${error}</p>`));
    }
  };

  const onSubmitTransfers = () => {
    submitCompleted(false);
    setTransfersData(null);
  };

  const submitCompleted = async (onlyValidate: boolean) => {
    const payload = {
      fantasy_team: {
        teams_players_ids: teamMembers.map((element: TeamsPlayer) => element.id),
        only_validate: onlyValidate,
      },
    };

    const requestOptions = {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify(payload),
    };

    const submitResult = await apiRequest({
      url: `/fantasy_teams/${fantasyTeamUuid}/transfers.json`,
      options: requestOptions,
    });
    if (onlyValidate) {
      if (submitResult.result) {
        setTransfersData(submitResult.result);
      } else {
        submitResult.errors.forEach((error: string) => showAlert('alert', `<p>${error}</p>`));
      }
    } else {
      if (submitResult.result) {
        showAlert('notice', `<p>${submitResult.result}</p>`);
      } else {
        submitResult.errors.forEach((error: string) => showAlert('alert', `<p>${error}</p>`));
      }
    }
  };

  return (
    <div id="fantasy-team-transfers" className="main-container">
      <div id="fantasy-team-members" className="left-container">
        <h1>{strings.transfers.title}</h1>
        {!fantasyTeamCompleted && (
          <>
            <div className="form-field">
              <label className="form-label">{strings.transfers.name}</label>
              <input
                className="form-value"
                value={teamName}
                onChange={(e) => setTeamName(e.target.value)}
              />
            </div>
            <Dropdown
              title={strings.transfers.favouriteTeam}
              items={Object.entries(teamNames).reduce(
                (result, [key, values]) => {
                  result[key] = localizeValue(values.name);
                  return result;
                },
                {} as KeyValue,
              )}
              onSelect={(value) => setFavouriteTeamId(value)}
              selectedValue={favouriteTeamId}
            />
          </>
        )}
        <div className="deadline flex items-center justify-center">
          <span>{strings.formatString(strings.transfers.week, { number: weekPosition })}</span>
          <span>{weekDeadlineAt}</span>
        </div>
        <div className="flex justify-between transfers-stats">
          <div className="transfers-stat flex flex-col items-center">
            <p>{strings.transfers.free}</p>
            <p>{transfersLimited ? freeTransfers : strings.transfers.unlimited}</p>
          </div>
          <div className="transfers-stat flex flex-col items-center">
            <p>{strings.transfers.cost}</p>
            <p>0</p>
          </div>
          <div className="transfers-stat flex flex-col items-center">
            <p>{strings.transfers.remaining}</p>
            <p>{budget}</p>
          </div>
        </div>
        <div id="team-players-by-positions" className={sportKind}>
          {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
            <div
              className={`sport-position ${sportPositionName(sportPosition as SportPosition)}`}
              key={positionKind}
            >
              {playersByPosition[positionKind]?.map((item: TeamsPlayer) => (
                <PlayerCard
                  key={item.id}
                  teamName={teamNames[item.team.id]?.short_name}
                  name={localizeValue(item.player.name).split(' ')[0]}
                  value={item.price}
                  onActionClick={() => removeTeamMember(item)}
                  onInfoClick={() => setPlayerId(item.id)}
                />
              ))}
              {renderEmptySlots(positionKind)}
            </div>
          ))}
        </div>
        <div id="submit-button">
          <button
            className="button"
            onClick={() => (fantasyTeamCompleted ? submitCompleted(true) : submit())}
          >
            {fantasyTeamCompleted ? strings.transfers.makeTransfers : strings.transfers.save}
          </button>
        </div>
        {Object.keys(teamNames).length > 0 ? <Week id={weekId} teamNames={teamNames} /> : null}
      </div>
      <div id="fantasy-players" className="right-container">
        <h2>{strings.transfers.selection}</h2>
        <Dropdown
          title={strings.transfers.positionView}
          items={Object.entries(sportPositions).reduce(
            (result, [key, values]) => {
              result[key] = localizeValue(values.name);
              return result;
            },
            { all: strings.transfers.allPlayers } as KeyValue,
          )}
          onSelect={(value) => setFilterByPosition(value)}
          selectedValue={filterByPosition}
        />
        <Dropdown
          title={strings.transfers.teamView}
          items={Object.entries(teamNames).reduce(
            (result, [key, values]) => {
              result[key] = localizeValue(values.name);
              return result;
            },
            { all: strings.transfers.allTeams } as KeyValue,
          )}
          onSelect={(value) => setFilterByTeam(value)}
          selectedValue={filterByTeam}
        />
        <Dropdown
          title={strings.transfers.sort}
          items={{
            points: strings.transfers.sortByPoints,
            price: strings.transfers.sortByPrice,
          }}
          onSelect={(value) => setSortBy(value)}
          selectedValue={sortBy}
        />
        {filteredPlayers.map((item: TeamsPlayer) => (
          <div className="team-player" key={item.id}>
            <div
              className="team-player-stats flex items-center justify-center button small"
              onClick={() => setPlayerId(item.id)}
            >
              ?
            </div>
            <div className="team-player-info">
              <p className="team-player-name">{localizeValue(item.player.name)?.split(' ')[0]}</p>
              <div className="team-player-stats">
                <span className="team-name">{teamNames[item.team.id]?.short_name}</span>
                <span className="position-name">
                  {localizeValue(sportPositions[item.player.position_kind].short_name)}
                </span>
              </div>
            </div>
            <div className="team-player-price">{item.price}</div>
            <div className="team-player-price">{item.player.points}</div>
            <div className="action" onClick={() => addTeamMember(item)}>
              +
            </div>
          </div>
        ))}
        {seasonPlayers.length > PER_PAGE && (
          <div className="pagination flex flex-row justify-center items-center">
            <span
              className="pagination-nav flex flex-row justify-center items-center"
              onClick={pageDown}
            >
              -
            </span>
            <span className="pagination-counter">{`${page + 1} of ${lastPageIndex}`}</span>
            <span
              className="pagination-nav flex flex-row justify-center items-center"
              onClick={pageUp}
            >
              +
            </span>
          </div>
        )}
      </div>
      <PlayerModal
        sportKind={sportKind}
        seasonId={seasonId}
        playerId={playerId}
        onClose={() => setPlayerId(undefined)}
      />
      <Modal show={transfersData}>
        <div className="button small modal-close" onClick={() => setTransfersData(null)}>
          X
        </div>
        <div className="transfers-header">
          <h2>{strings.transfers.confirmationScreen}</h2>
          <p className="transfers-points">{strings.transfers.pointsPenalty} - {transfersData?.points_penalty}</p>
          <div className="flex justify-between transfers-list">
            <div className="transfers-block flex flex-col items-center">
              <h4>{strings.transfers.income}</h4>
              {transfersData?.in_names?.map((item, index) => (
                <p key={index}>{localizeValue(item)}</p>
              ))}
            </div>
            <div className="transfers-block flex flex-col items-center">
              <h4>{strings.transfers.income}</h4>
              {transfersData?.out_names?.map((item, index) => (
                <p key={index}>{localizeValue(item)}</p>
              ))}
            </div>
          </div>
          {transfersData?.out_names?.length > 0 ? (
            <div className="flex justify-center items-center">
              <button
                className="button"
                onClick={() => setTransfersData(null)}
              >
                {strings.transfers.cancel}
              </button>
              <button
                className="button"
                onClick={onSubmitTransfers}
              >
                {strings.transfers.approve}
              </button>
            </div>
          ) : null}
        </div>
      </Modal>
    </div>
  );
};
