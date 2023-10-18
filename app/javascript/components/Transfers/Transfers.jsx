import React, { useState, useMemo, useEffect } from 'react';

import { sportsData } from '../../data';
import { currentLocale, localizeValue, csrfToken } from '../../helpers';
import { strings } from '../../locales';

import { Dropdown, Modal, Flash } from '../../components/atoms';
import { Week, PlayerModal, PlayerCard } from '../../components';

import { apiRequest } from '../../requests/helpers/apiRequest';
import { teamsRequest } from '../../requests/teamsRequest';
import { fantasyTeamPlayersRequest } from './requests/fantasyTeamPlayersRequest';
import { seasonPlayersRequest } from './requests/seasonPlayersRequest';

// these sorting params belong to teams_player.player
// other sorting params belong to teams_player
const PLAYER_SORT_PARAMS = ['points'];
const PER_PAGE = 20;

strings.setLanguage(currentLocale);

export const Transfers = ({
  seasonUuid,
  sportKind,
  fantasyTeamUuid,
  fantasyTeamCompleted,
  fantasyTeamBudget,
  weekUuid,
  weekPosition,
  weekDeadlineAt,
  transfersLimited,
  freeTransfers,
}) => {
  const [pageState, setPageState] = useState({
    loading: true,
    teamNames: {},
    seasonPlayers: [],
  });

  const [teamMembers, setTeamMembers] = useState([]);
  const [budget, setBudget] = useState(fantasyTeamBudget);
  const [teamName, setTeamName] = useState('');
  const [search, setSearch] = useState('');
  const [playerUuid, setPlayerUuid] = useState();
  const [playersByPosition, setPlayersByPosition] = useState({});
  const [favouriteTeamUuid, setFavouriteTeamUuid] = useState(null);
  const [transfersData, setTransfersData] = useState(null);
  const [alerts, setAlerts] = useState({});
  // filters state
  const [filterByPosition, setFilterByPosition] = useState('all');
  const [filterByTeam, setFilterByTeam] = useState('all');
  const [sortBy, setSortBy] = useState('points');
  const [page, setPage] = useState(0);

  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  useEffect(() => {
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchSeasonPlayers = async () => await seasonPlayersRequest(seasonUuid);

    const fetchFantasyTeamPlayers = async () => {
      const data = await fantasyTeamPlayersRequest(fantasyTeamUuid);
      setTeamMembers(data);
    };

    Promise.all([fetchTeams(), fetchSeasonPlayers()]).then(
      ([fetchTeamsData, fetchSeasonPlayersData]) =>
        setPageState({
          loading: false,
          teamNames: fetchTeamsData,
          seasonPlayers: fetchSeasonPlayersData,
        }),
    );

    if (fantasyTeamCompleted) fetchFantasyTeamPlayers();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    setPlayersByPosition(
      Object.keys(sportPositions).reduce((result, sportPosition) => {
        result[sportPosition] = teamMembers.filter((item) => {
          return item.player.position_kind === sportPosition;
        });
        return result;
      }, {}),
    );
  }, [sportPositions, teamMembers]);

  const filteredPlayers = useMemo(() => {
    return pageState.seasonPlayers
      .filter((element) => {
        if (filterByPosition !== 'all' && filterByPosition !== element.player.position_kind)
          return false;
        if (filterByTeam !== 'all' && filterByTeam !== element.team.uuid.toString()) return false;

        return true;
      })
      .filter((element) => {
        if (search === '') return true;

        return Object.values(element.player.name).find((element) => { return element.toLowerCase().includes(search) })
      })
      .sort((a, b) => {
        if (PLAYER_SORT_PARAMS.includes(sortBy)) {
          return a.player[sortBy] < b.player[sortBy] ? 1 : -1;
        } else {
          return a[sortBy] < b[sortBy] ? 1 : -1;
        }
      });
  }, [pageState.seasonPlayers, filterByPosition, filterByTeam, sortBy, search]);

  const filteredSlicedPlayers = useMemo(() => {
    return filteredPlayers.slice(page * PER_PAGE, page * PER_PAGE + PER_PAGE);
  }, [filteredPlayers, page]);

  const lastPageIndex = useMemo(() => {
    return Math.trunc(filteredPlayers.length / PER_PAGE) + 1;
  }, [filteredPlayers]);

  const pageDown = () => {
    if (page !== 0) setPage(page - 1);
  };

  const pageUp = () => {
    if (page !== lastPageIndex - 1) setPage(page + 1);
  };

  const addTeamMember = (item) => {
    // if fantasy team is full
    if (teamMembers.length === sport.max_players)
      return setAlerts({ alert: strings.transfers.teamFull });
    // if player is already in team
    if (teamMembers.find((element) => element.uuid === item.uuid))
      return setAlerts({ alert: strings.transfers.playerInTeam });
    // if all position already in use
    const positionKind = item.player.position_kind;
    const positionsLeft =
      sportPositions[positionKind].total_amount - playersByPosition[positionKind].length;
    if (positionsLeft === 0) return setAlerts({ alert: strings.transfers.noPositions });
    // if there are already max_team_players
    const playersFromTeam = teamMembers.filter((element) => {
      return element.team.uuid === item.team.uuid;
    });
    if (playersFromTeam.length >= sport.max_team_players)
      return setAlerts({
        alert: strings.formatString(strings.transfers.maxTeamPlayers, {
          number: sport.max_team_players,
        }),
      });

    setTeamMembers(teamMembers.concat(item));
    setBudget(budget - item.price);
  };

  const sportPositionName = (sportPosition) => {
    return sportPosition.name.en.split(' ').join('-');
  };

  const removeTeamMember = (element) => {
    setTeamMembers(teamMembers.filter((item) => item.uuid !== element.uuid));
    setBudget(budget + element.price);
  };

  const renderEmptySlots = (positionKind) => {
    if (!playersByPosition[positionKind]) return null;

    const emptySlots =
      sportPositions[positionKind].total_amount - playersByPosition[positionKind].length;
    return [...Array(emptySlots).keys()].map((item) => {
      return <PlayerCard key={item} />;
    });
  };

  const submit = async () => {
    const payload = {
      fantasy_team: {
        name: teamName,
        budget_cents: budget * 100,
        favourite_team_uuid: favouriteTeamUuid,
        teams_players_uuids: teamMembers.map((element) => element.uuid),
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
      setAlerts({ alert: submitResult.errors });
    }
  };

  const onSubmitTransfers = () => {
    submitCompleted(false);
    setTransfersData(null);
  };

  const submitCompleted = async (onlyValidate) => {
    const payload = {
      fantasy_team: {
        teams_players_uuids: teamMembers.map((element) => element.uuid),
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
        setAlerts({ alert: submitResult.errors });
      }
    } else {
      if (submitResult.result) {
        setAlerts({ notice: submitResult.result });
      } else {
        setAlerts({ alert: submitResult.errors });
      }
    }
  };

  return (
    <div className="grid grid-cols-4 gap-8">
      <div className="col-span-3">
        <span className="inline-block bg-zinc-800 text-white text-sm py-1 px-2 rounded mr-2">
          {strings.formatString(strings.transfers.week, { number: weekPosition })}
        </span>
        <h1>{strings.transfers.selection}</h1>
        {!fantasyTeamCompleted && (
          <div class="flex">
            <div className="form-field mr-4">
              <label className="form-label">{strings.transfers.name}</label>
              <input
                className="form-value"
                value={teamName}
                onChange={(e) => setTeamName(e.target.value)}
              />
            </div>
            <div class="flex-1">
              <Dropdown
                title={strings.transfers.favouriteTeam}
                items={Object.entries(pageState.teamNames).reduce((result, [key, values]) => {
                  result[key] = localizeValue(values.name);
                  return result;
                }, {})}
                onSelect={(value) => setFavouriteTeamUuid(value)}
                selectedValue={favouriteTeamUuid}
              />
            </div>
          </div>
        )}
        <div className="flex flex-row justify-between mt-2 bg-gray-200 rounded shadow mb-4">
          <div className="flex flex-col items-center justify-between flex-1 py-2 px-10 border-r border-gray-300">
            <p>{strings.transfers.free}</p>
            <p className="text-xl">{transfersLimited ? freeTransfers : strings.transfers.unlimited}</p>
          </div>
          <div className="flex flex-col items-center justify-between flex-1 py-2 px-10 border-r border-gray-300">
            <p>{strings.transfers.cost}</p>
            <p className="text-xl">0</p>
          </div>
          <div className="flex flex-col items-center justify-between flex-1 py-2 px-10">
            <p>{strings.transfers.remaining}</p>
            <p className="text-xl">{budget}</p>
          </div>
        </div>
        <div className={`flex flex-col relative bg-no-repeat bg-contain bg-center ${sportKind}-field`}>
          <span className="absolute left-16 top-4 inline-block bg-red-600 text-white text-sm py-1 px-2 rounded mb-4">
            <span>{strings.formatString(strings.squad.deadline, { value: weekDeadlineAt })}</span>
          </span>
          {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
            <div
              className={`flex flex-row justify-center sport-position ${sportPositionName(sportPosition)}`}
              key={positionKind}
            >
              {playersByPosition[positionKind]?.map((item) => (
                <PlayerCard
                  key={item.uuid}
                  teamName={pageState.teamNames[item.team.uuid]?.short_name}
                  name={localizeValue(item.player.name).split(' ')[0]}
                  value={item.price}
                  number={item.shirt_number}
                  onActionClick={() => removeTeamMember(item)}
                  onInfoClick={() => setPlayerUuid(item.uuid)}
                />
              ))}
              {renderEmptySlots(positionKind)}
            </div>
          ))}
        </div>
        <div className="my-8 mx-auto text-center">
          <button
            className="btn-primary"
            onClick={() => (fantasyTeamCompleted ? submitCompleted(true) : submit())}
          >
            {fantasyTeamCompleted ? strings.transfers.makeTransfers : strings.transfers.save}
          </button>
        </div>
        {Object.keys(pageState.teamNames).length > 0 ? (
          <Week uuid={weekUuid} teamNames={pageState.teamNames} />
        ) : null}
      </div>
      <div>
        <Dropdown
          title={strings.transfers.positionView}
          items={Object.entries(sportPositions).reduce(
            (result, [key, values]) => {
              result[key] = localizeValue(values.name);
              return result;
            },
            { all: strings.transfers.allPlayers },
          )}
          onSelect={(value) => {
            setFilterByPosition(value);
            setPage(0);
          }}
          selectedValue={filterByPosition}
        />
        <Dropdown
          title={strings.transfers.teamView}
          items={Object.entries(pageState.teamNames).reduce(
            (result, [key, values]) => {
              result[key] = localizeValue(values.name);
              return result;
            },
            { all: strings.transfers.allTeams },
          )}
          onSelect={(value) => {
            setFilterByTeam(value);
            setPage(0);
          }}
          selectedValue={filterByTeam}
        />
        <Dropdown
          title={strings.transfers.sort}
          items={{
            points: strings.transfers.sortByPoints,
            price: strings.transfers.sortByPrice,
            form: strings.transfers.sortByForm,
          }}
          onSelect={(value) => setSortBy(value)}
          selectedValue={sortBy}
        />
        <div className="form-field my-4">
          <label className="form-label">Search by name</label>
          <input
            className="form-value w-full"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        {filteredSlicedPlayers.map((item) => (
          <div className="flex flex-row items-center pt-0 px-1 pb-1 mb-1 border-b border-gray-200" key={item.uuid}>
            <div
              className="flex items-center justify-center mr-2 btn-info btn-small text-black py-0 leading-6"
              onClick={() => setPlayerUuid(item.uuid)}
            >
              ?
            </div>
            <div className="flex-1">
              <span className="text-lg mr-4">
                {localizeValue(item.player.name)?.split(' ')[0]}
              </span>
              {false ? (
                <span className="uppercase text-sm mr-4">{pageState.teamNames[item.team.uuid]?.short_name}</span>
              ) : null}
              <span className="text-sm">
                {localizeValue(sportPositions[item.player.position_kind].short_name)}
              </span>
            </div>
            <div className="w-12 flex flex-row items-center justify-center">{item.price}</div>
            <div className="w-12 flex flex-row items-center justify-center">
              {PLAYER_SORT_PARAMS.includes(sortBy) ? item.player[sortBy] : item[sortBy]}
            </div>
            <div className="btn-primary btn-small py-0 leading-6" onClick={() => addTeamMember(item)}>
              +
            </div>
          </div>
        ))}
        {pageState.seasonPlayers.length > PER_PAGE && (
          <div className="py-2 px-0 flex flex-row justify-center items-center">
            <span
              className="w-8 h-8 rounded-full cursor-pointer bg-white border border-gray-200 flex flex-row justify-center items-center"
              onClick={pageDown}
            >
              -
            </span>
            <span className="mx-4">{`${page + 1} of ${lastPageIndex}`}</span>
            <span
              className="w-8 h-8 rounded-full cursor-pointer bg-white border border-gray-200 flex flex-row justify-center items-center"
              onClick={pageUp}
            >
              +
            </span>
          </div>
        )}
      </div>
      <PlayerModal
        sportKind={sportKind}
        seasonUuid={seasonUuid}
        playerUuid={playerUuid}
        teamNames={pageState.teamNames}
        onClose={() => setPlayerUuid(undefined)}
      />
      <Flash values={alerts} />
      <Modal show={!!transfersData} onClose={() => setTransfersData(null)}>
        <div className="transfers-header">
          <h2>{strings.transfers.confirmationScreen}</h2>
          <p className="text-center mb-8">
            {strings.transfers.penaltyPoints} - {transfersData?.penalty_points}
          </p>
          <div className="flex justify-between mb-8">
            <div className="flex-1 py-3 px-0 flex flex-col items-center border-r border-gray-200">
              <h4>{strings.transfers.income}</h4>
              {transfersData?.in_names?.map((item, index) => (
                <p key={index}>{localizeValue(item)}</p>
              ))}
            </div>
            <div className="flex-1 py-3 px-0 flex flex-col items-center">
              <h4>{strings.transfers.outcome}</h4>
              {transfersData?.out_names?.map((item, index) => (
                <p key={index}>{localizeValue(item)}</p>
              ))}
            </div>
          </div>
          {transfersData?.out_names && transfersData?.out_names.length > 0 ? (
            <div className="flex justify-center items-center">
              <button className="btn-primary mx-4 w-40" onClick={() => setTransfersData(null)}>
                {strings.transfers.cancel}
              </button>
              <button className="btn-primary mx-4 w-40" onClick={onSubmitTransfers}>
                {strings.transfers.approve}
              </button>
            </div>
          ) : null}
        </div>
      </Modal>
    </div>
  );
};
