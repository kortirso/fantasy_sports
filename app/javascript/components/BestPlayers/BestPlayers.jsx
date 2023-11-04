import React, { useState, useEffect } from 'react';

import { currentLocale, localizeValue } from '../../helpers';
import { strings } from '../../locales';
import { sportsData } from '../../data';

import { PlayerModal } from '../../components';
import { teamsRequest } from '../../requests/teamsRequest';

import { bestSeasonPlayersRequest, bestWeekPlayersRequest } from './requests/bestPlayersRequest';

strings.setLanguage(currentLocale);

export const BestPlayers = ({ weekUuid, seasonUuid, sportKind }) => {
  const [pageState, setPageState] = useState({
    loading: true,
    teamNames: {},
    bestSeasonPlayers: [],
    bestWeekPlayers: [],
  });
  const [playerUuid, setPlayerUuid] = useState();

  const sportPositions = sportsData.positions[sportKind];

  useEffect(() => {
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchBestSeasonPlayers = async () => await bestSeasonPlayersRequest(seasonUuid);
    const fetchBestWeekPlayers = async () => await bestWeekPlayersRequest(seasonUuid, weekUuid);

    Promise.all([fetchTeams(), fetchBestSeasonPlayers(), fetchBestWeekPlayers()]).then(([teamsData, bestSeasonPlayers, bestWeekPlayers]) =>
      setPageState({
        loading: false,
        teamNames: teamsData,
        bestSeasonPlayers: bestSeasonPlayers,
        bestWeekPlayers: bestWeekPlayers,
      }),
    );
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  if (pageState.loading) return <></>;

  const renderPlayersData = (players) => {
    if (!players || players.length === 0) return <></>;

    return (
      <table className="table">
        <thead>
          <tr>
            <th></th>
            <th>{strings.bestPlayers.player}</th>
            <th>{strings.bestPlayers.position}</th>
            <th>{strings.bestPlayers.team}</th>
            <th>{strings.bestPlayers.points}</th>
          </tr>
        </thead>
        <tbody>
          {players.map((item, index) => (
            <tr key={index}>
              <td
                className="cursor-pointer"
                onClick={() => setPlayerUuid(item[0].data.attributes.players_season.uuid)}
              >i</td>
              <td>{localizeValue(item[0].data.attributes.player.shirt_name)}</td>
              <td>{localizeValue(sportPositions[item[0].data.attributes.player.position_kind].name)}</td>
              <td>{item[0].data.attributes.team.name}</td>
              <td>{item[1]}</td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  };

  return (
    <section className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
      <div>
        <h2>{strings.bestPlayers.week}</h2>
        {renderPlayersData(pageState.bestWeekPlayers)}
      </div>
      <div>
        <h2>{strings.bestPlayers.total}</h2>
        {renderPlayersData(pageState.bestSeasonPlayers)}
      </div>
      <PlayerModal
        sportKind={sportKind}
        seasonUuid={seasonUuid}
        playerUuid={playerUuid}
        teamNames={pageState.teamNames}
        onClose={() => setPlayerUuid(undefined)}
      />
    </section>
  );
};
