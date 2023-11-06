import React, { useState, useMemo, useEffect } from 'react';

import { sportsData } from '../../data';
import { currentLocale, localizeValue, csrfToken, convertDateTime } from '../../helpers';
import { strings } from '../../locales';

import { Dropdown, Modal, Flash } from '../../components/atoms';
import { Week, PlayerModal, PlayerCard } from '../../components';

import { apiRequest } from '../../requests/helpers/apiRequest';
import { teamsRequest } from '../../requests/teamsRequest';
import { fantasyTeamPlayersRequest } from './requests/fantasyTeamPlayersRequest';
import { seasonPlayersRequest } from './requests/seasonPlayersRequest';

// these sorting params belong to teams_player.player
// other sorting params belong to teams_player
const TEAM_SORT_PARAMS = ['price'];
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
    visibleMode: window.innerWidth >= 1280 ? 'all' : 'lineup',
    defaultTeamMembers: [],
    teamMembers: [],
    budget: fantasyTeamBudget,
    freeTransfersAmount: freeTransfers,
    alerts: {}
  });

  // fields for initial squad
  const [teamName, setTeamName] = useState('');
  const [favouriteTeamUuid, setFavouriteTeamUuid] = useState(null);
  // other fields
  const [playerUuid, setPlayerUuid] = useState(); // for PlayerModal
  const [playersByPosition, setPlayersByPosition] = useState({}); // for rendering players on the field
  const [transfersData, setTransfersData] = useState(null); // for transfers modal
  // filters state
  const [filterByPosition, setFilterByPosition] = useState('all');
  const [filterByTeam, setFilterByTeam] = useState('all');
  const [sortBy, setSortBy] = useState('points');
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState('');

  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  useEffect(() => {
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchSeasonPlayers = async () => await seasonPlayersRequest(seasonUuid);

    const fetchFantasyTeamPlayers = async () => {
      if (!fantasyTeamCompleted) return [];

      const data = await fantasyTeamPlayersRequest(fantasyTeamUuid);
      return data;
    };

    Promise.all([fetchTeams(), fetchSeasonPlayers(), fetchFantasyTeamPlayers()]).then(
      ([teamsData, seasonPlayersData, fantasyTeamPlayers]) =>
        setPageState({
          loading: false,
          teamNames: teamsData,
          seasonPlayers: seasonPlayersData,
          visibleMode: window.innerWidth >= 1280 ? 'all' : 'lineup',
          defaultTeamMembers: fantasyTeamPlayers,
          teamMembers: fantasyTeamPlayers,
          budget: fantasyTeamBudget,
          freeTransfersAmount: freeTransfers,
          alerts: {}
        }),
    );
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    setPlayersByPosition(
      Object.keys(sportPositions).reduce((result, sportPosition) => {
        result[sportPosition] = pageState.teamMembers.filter((item) => {
          return item.player.position_kind === sportPosition;
        });
        return result;
      }, {}),
    );
  }, [sportPositions, pageState.teamMembers]);

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
        if (TEAM_SORT_PARAMS.includes(sortBy)) {
          return a.team[sortBy] < b.team[sortBy] ? 1 : -1;
        } else {
          return a[sortBy] < b[sortBy] ? 1 : -1;
        }
      });
  }, [pageState.seasonPlayers, filterByPosition, filterByTeam, sortBy, search]);

  const filteredSlicedPlayers = useMemo(() => {
    return filteredPlayers.slice(page * PER_PAGE, page * PER_PAGE + PER_PAGE);
  }, [filteredPlayers, page]);

  const lastPageIndex = useMemo(() => {
    return Math.trunc(filteredPlayers.length / (PER_PAGE + 1)) + 1;
  }, [filteredPlayers]);

  const penaltyPoints = useMemo(() => {
    if (!transfersLimited) return 0;

    let count = 0
    pageState.defaultTeamMembers.forEach((defaultElement) => {
      if (!pageState.teamMembers.find((element) => element.uuid === defaultElement.uuid)) count += 1;
    });
    if (pageState.freeTransfersAmount >= count) return 0;

    return (pageState.freeTransfersAmount - count) * sport.points_per_transfer;
  }, [transfersLimited, pageState.freeTransfersAmount, pageState.defaultTeamMembers, pageState.teamMembers, sport.points_per_transfer]);

  const pageDown = () => {
    if (page !== 0) setPage(page - 1);
  };

  const pageUp = () => {
    if (page !== lastPageIndex - 1) setPage(page + 1);
  };

  const addTeamMember = (item) => {
    // if fantasy team is full
    if (pageState.teamMembers.length === sport.max_players)
      return setPageState({ ...pageState, alerts: { alert: strings.transfers.teamFull } });
    // if player is already in team
    if (pageState.teamMembers.find((element) => element.uuid === item.uuid))
      return setPageState({ ...pageState, alerts: { alert: strings.transfers.playerInTeam } });
    // if all position already in use
    const positionKind = item.player.position_kind;
    const positionsLeft =
      sportPositions[positionKind].total_amount - playersByPosition[positionKind].length;
    if (positionsLeft === 0)
      return setPageState({ ...pageState, alerts: { alert: strings.transfers.noPositions } });
    // if there are already max_team_players
    const playersFromTeam = pageState.teamMembers.filter((element) => {
      return element.team.uuid === item.team.uuid;
    });
    if (playersFromTeam.length >= sport.max_team_players) {
      const alert = strings.formatString(strings.transfers.maxTeamPlayers, {
        number: sport.max_team_players,
      })
      return setPageState({ ...pageState, alerts: { alert: alert } });
    }

    setPageState({
      ...pageState,
      teamMembers: pageState.teamMembers.concat(item),
      budget: pageState.budget - item.team.price
    })
  };

  const sportPositionName = (sportPosition) => sportPosition.name.en.split(' ').join('-');

  const removeTeamMember = (element) => {
    setPageState({
      ...pageState,
      teamMembers: pageState.teamMembers.filter((item) => item.uuid !== element.uuid),
      budget: pageState.budget + element.team.price
    })
  };

  const renderEmptySlots = (positionKind) => {
    if (!playersByPosition[positionKind]) return null;

    const emptySlots =
      sportPositions[positionKind].total_amount - playersByPosition[positionKind].length;
    return [...Array(emptySlots).keys()].map((item) => {
      return <PlayerCard key={item} />;
    });
  };

  const renderChangeButton = (item) => {
    const existingTeamMember = pageState.teamMembers.find((teamMember) => teamMember.uuid === item.uuid)

    if (!existingTeamMember) return <div className="btn-transfer" onClick={() => addTeamMember(item)}>+</div>;
    return <div className="btn-transfer-remove" onClick={() => removeTeamMember(item)}>-</div>;
  };

  const submit = async () => {
    const payload = {
      fantasy_team: {
        name: teamName,
        budget_cents: pageState.budget * 100,
        favourite_team_uuid: favouriteTeamUuid,
        players_seasons_uuids: pageState.teamMembers.map((element) => element.uuid),
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
      setPageState({ ...pageState, alerts: { alert: submitResult.errors } });
    }
  };

  const onSubmitTransfers = () => {
    submitCompleted(false);
    setTransfersData(null);
  };

  const submitCompleted = async (onlyValidate) => {
    const payload = {
      fantasy_team: {
        players_seasons_uuids: pageState.teamMembers.map((element) => element.uuid),
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
        setPageState({ ...pageState, alerts: { alert: submitResult.errors } });
      }
    } else {
      if (submitResult.result) {
        if (transfersLimited) {
          let count = 0 // amount of transfers
          pageState.defaultTeamMembers.forEach((defaultElement) => {
            if (!pageState.teamMembers.find((element) => element.uuid === defaultElement.uuid)) count += 1;
          });

          setPageState({
            ...pageState,
            defaultTeamMembers: pageState.teamMembers,
            freeTransfersAmount: count >= pageState.freeTransfersAmount ? 0 : (pageState.freeTransfersAmount - count),
            alerts: { notice: submitResult.result }
          })
        } else {
          setPageState({ ...pageState, alerts: { notice: submitResult.result } });
        }
      } else {
        setPageState({ ...pageState, alerts: { alert: submitResult.errors } });
      }
    }
  };

  return (
    <div className="max-w-7xl mx-auto xl:grid xl:grid-cols-10 xl:gap-8">
      <div className="xl:col-span-7">
        <span className="badge-dark inline-block">
          {strings.formatString(strings.transfers.week, { number: weekPosition })}
        </span>
        <h1>{strings.transfers.selection}</h1>
        {!fantasyTeamCompleted && (
          <div class="flex flex-col sm:flex-row">
            <div className="form-field mr-4">
              <label className="form-label">{strings.transfers.name} *</label>
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
                placeholder={strings.transfers.selectFavouriteTeam}
              />
            </div>
          </div>
        )}
        <div className="flex flex-col md:flex-row justify-between mt-2 bg-stone-200 border border-stone-300 rounded mb-4">
          <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10 border-b md:border-b-0 md:border-r border-stone-300">
            <p className="text-center">{strings.transfers.free}</p>
            <p className="ml-4 md:ml-0 text-xl">{transfersLimited ? pageState.freeTransfersAmount : strings.transfers.unlimited}</p>
          </div>
          <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10 border-b md:border-b-0 md:border-r border-stone-300">
            <p className="text-center">{strings.transfers.cost}</p>
            <p className="ml-4 md:ml-0 text-xl">{penaltyPoints}</p>
          </div>
          <div className="flex flex-row md:flex-col items-center justify-center md:justify-between flex-1 py-2 px-10">
            <p className="text-center">{strings.transfers.remaining}</p>
            <p className="ml-4 md:ml-0 text-xl">{pageState.budget.toFixed(1)}</p>
          </div>
        </div>
        {pageState.visibleMode === 'all' || pageState.visibleMode === 'lineup' ? (
          <div className={`${sportKind}-field`}>
            <div className="flex flex-col relative bg-no-repeat bg-cover bg-center field">
              <p className="badge-danger absolute left-4 top-4">
                {strings.formatString(strings.squad.deadline, { value: convertDateTime(weekDeadlineAt) })}
              </p>
              {pageState.visibleMode === 'lineup' ? (
                <p
                  className="absolute right-4 top-4 bg-amber-200 hover:bg-amber-300 border border-amber-300 text-sm py-1 px-2 rounded shadow cursor-pointer"
                  onClick={() => setPageState({ ...pageState, visibleMode: 'seasonPlayers' })}
                >
                  {strings.transfers.showSeasonPlayers}
                </p>
              ) : null}
              {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
                <div
                  className={`sport-position ${sportPositionName(sportPosition)}`}
                  key={positionKind}
                >
                  {playersByPosition[positionKind]?.map((item) => (
                    <PlayerCard
                      key={item.uuid}
                      teamName={pageState.teamNames[item.team.uuid]?.short_name}
                      name={localizeValue(item.player.shirt_name)}
                      value={item.team.price}
                      number={item.team.shirt_number}
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
        ) : null}
      </div>
      {pageState.visibleMode === 'all' || pageState.visibleMode === 'seasonPlayers' ? (
        <div className="lg:col-span-3">
          {pageState.visibleMode === 'seasonPlayers' ? (
            <span
              className="inline-block mb-2 bg-amber-200 hover:bg-amber-300 border border-amber-300 text-sm py-1 px-2 rounded shadow cursor-pointer"
              onClick={() => setPageState({ ...pageState, visibleMode: 'lineup' })}
            >
              {strings.transfers.showLineup}
            </span>
          ) : null}
          <div className="sm:grid sm:grid-cols-2 xl:grid-cols-1 sm:gap-x-4 sm:mb-4">
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
            <div className="form-field mb-4">
              <label className="form-label">{strings.transfers.search}</label>
              <input
                className="form-value w-full"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>
          {filteredSlicedPlayers.map((item) => (
            <div className="flex flex-row items-center pt-0 px-1 pb-1 mb-1 border-b border-stone-200" key={item.uuid}>
              <div
                className="flex items-center justify-center mr-2 btn-info btn-small text-black py-0 leading-6"
                onClick={() => setPlayerUuid(item.uuid)}
              >
                ?
              </div>
              <div className="flex-1">
                <span className="text-lg mr-4">
                  {localizeValue(item.player.shirt_name)}
                </span>
                {false ? (
                  <span className="uppercase text-sm mr-4">{pageState.teamNames[item.team.uuid]?.short_name}</span>
                ) : null}
                <span className="text-sm">
                  {localizeValue(sportPositions[item.player.position_kind].short_name)}
                </span>
              </div>
              <div className="w-12 flex flex-row items-center justify-center">{item.team.price}</div>
              <div className="w-12 flex flex-row items-center justify-center">
                {TEAM_SORT_PARAMS.includes(sortBy) ? item.team[sortBy] : item[sortBy]}
              </div>
              {renderChangeButton(item)}
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
      ) : null}
      <PlayerModal
        sportKind={sportKind}
        seasonUuid={seasonUuid}
        playerUuid={playerUuid}
        teamNames={pageState.teamNames}
        onClose={() => setPlayerUuid(undefined)}
      />
      <Flash content={pageState.alerts} />
      <Modal show={!!transfersData} onClose={() => setTransfersData(null)}>
        <div className="transfers-header">
          <h2>{strings.transfers.confirmationScreen}</h2>
          <p className="text-center mb-8">
            {strings.transfers.penaltyPoints} - {transfersData?.penalty_points}
          </p>
          <div className="flex flex-col sm:flex-row justify-between mb-8">
            <div className="flex-1 py-3 px-0 flex flex-col items-center sm:border-r border-gray-200">
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
