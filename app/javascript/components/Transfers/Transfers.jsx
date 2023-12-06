import React, { useState, useMemo, useEffect } from 'react';

import { sportsData } from '../../data';
import { currentLocale, localizeValue, csrfToken, convertDateTime, currentWatches } from '../../helpers';
import { strings } from '../../locales';

import { Dropdown, Modal, Flash, Checkbox } from '../../components/atoms';
import { Week, PlayerModal, PlayerCard } from '../../components';

import { apiRequest } from '../../requests/helpers/apiRequest';
import { teamsRequest } from '../../requests/teamsRequest';
import { fantasyTeamPlayersRequest } from './requests/fantasyTeamPlayersRequest';
import { seasonPlayersRequest } from './requests/seasonPlayersRequest';

// these sorting params belong to teams_player.player
// other sorting params belong to teams_player
const TEAM_SORT_PARAMS = ['price'];
const STATISTIC_SORT_PARAM = ['MP', 'P', 'REB', 'A', 'BLK', 'STL', 'GS', 'CS'];
const PER_PAGE = 20;
const SORT_PARAMS = {
  'price': { 'en': 'Price', 'ru': 'Цена' },
  'points': { 'en': 'Pts', 'ru': 'Очки' },
  'form': { 'en': 'Form', 'ru': 'Форма' }
}

const BASKETBALL_SORT_PARAMS = {
  'MP': { 'en': 'Minutes played', 'ru': 'Сыграно минут' },
  'P': { 'en': 'Game points', 'ru': 'Игровые очки' },
  'REB': { 'en': 'Rebounds', 'ru': 'Подробы' },
  'A': { 'en': 'Assists', 'ru': 'Передачи' },
  'BLK': { 'en': 'Blocks', 'ru': 'Блоки' },
  'STL': { 'en': 'Steals', 'ru': 'Перехваты' }
}

const FOOTBALL_SORT_PARAMS = {
  'MP': { 'en': 'Minutes played', 'ru': 'Сыграно минут' },
  'GS': { 'en': 'Goals scored', 'ru': 'Забито голов' },
  'A': { 'en': 'Assists', 'ru': 'Передачи' },
  'CS': { 'en': 'Clean sheets', 'ru': 'Сухие игры' }
}

strings.setLanguage(currentLocale);

export const Transfers = ({
  seasonUuid,
  sportKind,
  fantasyTeamUuid,
  fantasyTeamCompleted,
  fantasyTeamBudgetCents,
  weekUuid,
  weekPosition,
  weekDeadlineAt,
  transfersLimited,
  freeTransfers,
  activeChips,
  lineupUuid,
  availableChips,
}) => {
  const generateSortParams = () => {
    if (sportKind === 'basketball') return { ...SORT_PARAMS, ...BASKETBALL_SORT_PARAMS };
    if (sportKind === 'football') return { ...SORT_PARAMS, ...FOOTBALL_SORT_PARAMS };

    return SORT_PARAMS;
  };

  const generateSortItems = () => {
    const basis = {
      points: strings.transfers.sortByPoints,
      price: strings.transfers.sortByPrice,
      form: strings.transfers.sortByForm,
    };

    return Object.entries(sportKind === 'football' ? FOOTBALL_SORT_PARAMS : BASKETBALL_SORT_PARAMS).reduce((result, [key, value]) => {
      result[key] = localizeValue(value);
      return result;
    }, basis);
  };

  const [pageState, setPageState] = useState({
    loading: true,
    teamNames: {},
    seasonPlayers: [],
    visibleMode: window.innerWidth >= 1280 ? 'all' : 'lineup',
    viewMode: 'field', // options - 'field', 'list'
    defaultTeamMembers: [],
    teamMembers: [],
    budgetCents: fantasyTeamBudgetCents,
    freeTransfersAmount: freeTransfers,
    alerts: {},
    sortParams: generateSortParams(),
    sortItems: generateSortItems(),
    wildcardModalIsOpen: false
  });

  const [filterState, setFilterState] = useState({
    position: 'all',
    team: 'all',
    sortBy: 'points',
    page: 0,
    search: '',
    openDropdown: null,
    onlyWatched: false
  });

  const [teamState, setTeamState] = useState({
    uuid: null,
    openDropdown: false
  })

  // fields for initial squad
  const [teamName, setTeamName] = useState('');
  // other fields
  const [playerUuid, setPlayerUuid] = useState(); // for PlayerModal
  const [playersByPosition, setPlayersByPosition] = useState({}); // for rendering players on the field
  const [transfersData, setTransfersData] = useState(null); // for transfers modal

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
          ...pageState,
          loading: false,
          teamNames: teamsData,
          seasonPlayers: seasonPlayersData,
          defaultTeamMembers: fantasyTeamPlayers,
          teamMembers: fantasyTeamPlayers
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
        if (filterState.position !== 'all' && filterState.position !== element.player.position_kind) return false;
        if (element.team.uuid === null) return false;
        if (filterState.team !== 'all' && filterState.team !== element.team.uuid) return false;
        if (filterState.onlyWatched && !currentWatches.includes(element.uuid)) return false;

        return true;
      })
      .filter((element) => {
        if (filterState.search === '') return true;

        return Object.values(element.player.name).find((element) => { return element.toLowerCase().includes(filterState.search) })
      })
      .sort((a, b) => {
        if (TEAM_SORT_PARAMS.includes(filterState.sortBy)) {
          return a.team[filterState.sortBy] < b.team[filterState.sortBy] ? 1 : -1;
        } else if (STATISTIC_SORT_PARAM.includes(filterState.sortBy)) {
          const aStatistic = a.statistic[filterState.sortBy] ? a.statistic[filterState.sortBy] : 0;
          const bStatistic = b.statistic[filterState.sortBy] ? b.statistic[filterState.sortBy] : 0;

          return aStatistic < bStatistic ? 1 : -1;
        } else {
          return a[filterState.sortBy] < b[filterState.sortBy] ? 1 : -1;
        }
      });
  }, [pageState.seasonPlayers, filterState]);

  const filteredSlicedPlayers = useMemo(() => {
    return filteredPlayers.slice(filterState.page * PER_PAGE, filterState.page * PER_PAGE + PER_PAGE);
  }, [filteredPlayers, filterState.page]);

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
    if (filterState.page !== 0) setFilterState({ ...filterState, page: filterState.page - 1 });
  };

  const pageUp = () => {
    if (filterState.page !== lastPageIndex - 1) setFilterState({ ...filterState, page: filterState.page + 1 });
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
      budgetCents: pageState.budgetCents - item.team.price_cents
    })
  };

  const sportPositionName = (sportPosition) => sportPosition.name.en.split(' ').join('-');

  const removeTeamMember = (element) => {
    setPageState({
      ...pageState,
      teamMembers: pageState.teamMembers.filter((item) => item.uuid !== element.uuid),
      budgetCents: pageState.budgetCents + element.team.price_cents
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

  const isExistingTeamMember = (item) => pageState.teamMembers.find((teamMember) => teamMember.uuid === item.uuid);

  const renderChangeButton = (item) => {
    if (!isExistingTeamMember(item)) return <div className="btn-transfer" onClick={() => addTeamMember(item)}>+</div>;
    return <div className="btn-transfer" onClick={() => removeTeamMember(item)}>-</div>;
  };

  const sortValue = (item) => {
    if (TEAM_SORT_PARAMS.includes(filterState.sortBy)) return item.team[filterState.sortBy];
    if (STATISTIC_SORT_PARAM.includes(filterState.sortBy)) return item.statistic[filterState.sortBy];

    return item[filterState.sortBy];
  };

  const renderShortSortBy = () => {
    if (STATISTIC_SORT_PARAM.includes(filterState.sortBy)) return filterState.sortBy;

    return localizeValue(pageState.sortParams[filterState.sortBy])
  };

  const injuryLevelClass = (injury) => {
    if (injury === null) return 'player-info';

    const data = injury.data.attributes;
    if (data.status === 0) return 'player-info-alert';
    return 'player-info-warning';
  };

  const renderWildcardStatus = () => {
    if (activeChips.includes('wildcard')) return 'btn-primary btn-small mr-2 bg-amber-400';
    if (availableChips.wildcard === 0 && !activeChips.includes('wildcard')) return 'btn-disabled btn-small mr-2';
    return 'btn-primary btn-small mr-2';
  };

  const renderWildcardTooltip = () => {
    if (activeChips.includes('wildcard')) return <p className="mt-2 text-orange-700">{strings.transfers.wildcardIsActive}</p>;
    if (availableChips.wildcard === 0) return <p className="mt-2 text-orange-700">{strings.transfers.wildcardIsNotAvailable}</p>;
    if (activeChips.length > 0 && !activeChips.includes('wildcard')) return <p className="mt-2 text-orange-700">{strings.transfers.anotherChip}</p>;

    return (
      <div>
        <p className="my-2">{strings.transfers.canBeActivated}</p>
        <button
          className="btn-primary"
          onClick={() => toggleChip()}
        >
          {strings.transfers.activate}
        </button>
      </div>
    );
  };

  const toggleChip = async () => {
    const payload = { active_chips: ['wildcard'] };

    const requestOptions = {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ lineup: payload }),
    };

    const result = await apiRequest({
      url: `/lineups/${lineupUuid}.json`,
      options: requestOptions,
    });
    if (result.message) window.location.reload();
    else setPageState({ ...pageState, alerts: { alert: result.errors } });
  };

  const submit = async () => {
    const payload = {
      fantasy_team: {
        name: teamName,
        favourite_team_uuid: teamState.uuid,
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

  const renderDifficulty = (value) => {
    if (value === 5) return <span className="bg-orange-700 border border-orange-800 py-1 px-2 rounded text-sm text-white mr-1">{value}</span>;
    if (value === 4) return <span className="bg-amber-300 border border-amber-400 py-1 px-2 rounded text-sm mr-1">{value}</span>;
    if (value === 3) return <span className="bg-stone-300 border border-stone-400 py-1 px-2 rounded text-sm mr-1">{value}</span>;
    if (value === 2) return <span className="bg-green-300 border border-green-400 py-1 px-2 rounded text-sm mr-1">{value}</span>;
  };

  const renderPlayersList = () => {
    return Object.entries(sportPositions).map(([positionKind, sportPosition]) => {
      return playersByPosition[positionKind]?.map((item) => (
        <tr key={item.uuid}>
          <td>
            <div className="flex justify-center items-center">
              <span
                className={injuryLevelClass(item.injury)}
                onClick={() => setPlayerUuid(item.uuid)}
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
          <td>{item.last_points}</td>
          <td>{item.form}</td>
          <td>{item.points}</td>
          <td>{item.team.price}</td>
          <td>
            {item.fixtures?.map((fixture) => renderDifficulty(fixture))}
          </td>
          <td>
            <div className="flex justify-center items-center">
              <span
                className="cursor-pointer border border-stone-200 hover:bg-stone-100 rounded px-1"
                onClick={() => removeTeamMember(item)}
              >
                +/-
              </span>
            </div>
          </td>
        </tr>
      ));
    });
  };

  return (
    <div className="max-w-7xl mx-auto xl:grid xl:grid-cols-10 xl:gap-8">
      <div className="xl:col-span-7">
        <span className="badge-dark inline-block">
          {strings.formatString(strings.transfers.week, { number: weekPosition })}
        </span>
        <h1 className="mb-2">{strings.transfers.selection}</h1>
        <p className="mb-4">{strings.transfers.description}</p>
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
                isOpen={teamState.openDropdown}
                onOpen={() => setTeamState({ ...teamState, openDropdown: true })}
                onClose={() => setTeamState({ ...teamState, openDropdown: false })}
                onSelect={(value) => setTeamState({ ...teamState, uuid: value, openDropdown: false })}
                selectedValue={teamState.uuid}
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
            <p className="ml-4 md:ml-0 text-xl">{(pageState.budgetCents / 100).toFixed(1)}</p>
          </div>
        </div>
        {pageState.visibleMode === 'all' || pageState.visibleMode === 'lineup' ? (
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
                  <p
                    className="badge-danger absolute left-4 top-4"
                    title={strings.transfers.deadlineDescription}
                  >
                    {strings.formatString(strings.squad.deadline, { value: convertDateTime(weekDeadlineAt) })}
                  </p>
                  {pageState.visibleMode === 'lineup' ? (
                    <p
                      className="absolute right-4 top-4 bg-amber-200 hover:bg-amber-300 border border-amber-300 text-sm py-1 px-2 rounded cursor-pointer"
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
                          injury={item.injury}
                          onActionClick={() => removeTeamMember(item)}
                          onInfoClick={() => setPlayerUuid(item.uuid)}
                        />
                      ))}
                      {renderEmptySlots(positionKind)}
                    </div>
                  ))}
                </div>
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
                      <th className="py-2 px-4"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {renderPlayersList()}
                  </tbody>
                </table>
              </div>
            ) : null}
            {lineupUuid && availableChips.wildcard !== null ? (
              <div className="my-8">
                <div className="mb-2">
                  <h3 className="text-center">{strings.squad.chips}</h3>
                  <div className="flex justify-center">
                    <button
                      className={renderWildcardStatus()}
                      onClick={() => setPageState({ ...pageState, wildcardModalIsOpen: true })}
                    >
                      {strings.transfers.wildcard}
                    </button>
                  </div>
                </div>
                <p className="px-4 md:px-12">{strings.squad.bonusesHelp}</p>
              </div>
            ) : null}
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
          </section>
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
              isOpen={filterState.openDropdown === 'position'}
              onOpen={() => setFilterState({ ...filterState, openDropdown: 'position' })}
              onClose={() => setFilterState({ ...filterState, openDropdown: null })}
              onSelect={(value) => setFilterState({ ...filterState, position: value, page: 0, openDropdown: null })}
              selectedValue={filterState.position}
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
              isOpen={filterState.openDropdown === 'team'}
              onOpen={() => setFilterState({ ...filterState, openDropdown: 'team' })}
              onClose={() => setFilterState({ ...filterState, openDropdown: null })}
              onSelect={(value) => setFilterState({ ...filterState, team: value, page: 0, openDropdown: null })}
              selectedValue={filterState.team}
            />
            <Dropdown
              title={strings.transfers.sort}
              items={pageState.sortItems}
              isOpen={filterState.openDropdown === 'sortBy'}
              onOpen={() => setFilterState({ ...filterState, openDropdown: 'sortBy' })}
              onClose={() => setFilterState({ ...filterState, openDropdown: null })}
              onSelect={(value) => setFilterState({ ...filterState, sortBy: value, page: 0, openDropdown: null })}
              selectedValue={filterState.sortBy}
            />
            <div className="form-field mb-4">
              <label className="form-label">{strings.transfers.search}</label>
              <input
                className="form-value w-full"
                value={filterState.search}
                onChange={(e) => setFilterState({ ...filterState, search: e.target.value, page: 0 })}
              />
            </div>
            <div>
              <Checkbox
                id="watchlist"
                label={strings.transfers.fromWatchlist}
                onClick={() => setFilterState({ ...filterState, onlyWatched: !filterState.onlyWatched })}
              />
            </div>
          </div>
          <div className="flex flex-row items-center pt-0 px-1 pb-1 mb-1">
            <div className="flex-1"></div>
            <div className="w-12 flex flex-row items-center justify-center text-sm">
              {filterState.sortBy === 'price' ? strings.transfers.points : strings.transfers.price}
            </div>
            <div className="w-12 flex flex-row items-center justify-center text-sm">
              {renderShortSortBy()}
            </div>
            <div className="w-6"></div>
          </div>
          {filteredSlicedPlayers.map((item) => (
            <div
              className={`flex flex-row items-center px-1 py-1 border-b border-stone-200 ${isExistingTeamMember(item) ? 'bg-stone-100' : ''}`}
              key={item.uuid}
            >
              <div
                className={`mr-2 ${injuryLevelClass(item.injury)}`}
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
              <div className="w-12 flex flex-row items-center justify-center">
                {filterState.sortBy === 'price' ? item.points : item.team.price}
              </div>
              <div className="w-12 flex flex-row items-center justify-center">
                {sortValue(item)}
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
              <span className="mx-4">{`${filterState.page + 1} of ${lastPageIndex}`}</span>
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
          <h2 className="pr-8">{strings.transfers.confirmationScreen}</h2>
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
      {lineupUuid && availableChips.wildcard !== null ? (
        <Modal
          show={pageState.wildcardModalIsOpen}
          onClose={() => setPageState({ ...pageState, wildcardModalIsOpen: false })}
        >
          <h2 className="pr-8">{strings.transfers.activating}</h2>
          <p>{strings.transfers.wildcardDescription}</p>
          {renderWildcardTooltip()}
        </Modal>
      ) : null}
    </div>
  );
};
