import React, { useState, useEffect } from 'react';

import { currentLocale, localizeValue } from '../../helpers';
import { strings } from '../../locales';
import { sportsData } from '../../data';

import { PlayerModal } from '../../components';
import { teamsRequest } from '../../requests/teamsRequest';

import { weekTransfersRequest } from './requests/weekTransfersRequest';

strings.setLanguage(currentLocale);

export const TransfersStatus = ({ weekUuid, seasonUuid, sportKind }) => {
  const [pageState, setPageState] = useState({
    loading: true,
    teamNames: {},
    weekTransfers: { transfers_in: [], transfers_out: [] },
  });
  const [playerUuid, setPlayerUuid] = useState();

  const sportPositions = sportsData.positions[sportKind];

  useEffect(() => {
    const fetchTeams = async () => await teamsRequest(seasonUuid);
    const fetchWeekTransfers = async () => await weekTransfersRequest(weekUuid);

    Promise.all([fetchTeams(), fetchWeekTransfers()]).then(([teamsData, fetchWeekTransfersData]) =>
      setPageState({
        loading: false,
        teamNames: teamsData,
        weekTransfers: fetchWeekTransfersData,
      }),
    );
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  if (pageState.loading) return <></>;

  const renderTransfersData = (transfers) => {
    if (!transfers || transfers.length === 0) return <></>;

    return (
      <table className="table">
        <thead>
          <tr>
            <th></th>
            <th>{strings.transfersStatus.position}</th>
            <th>{strings.transfersStatus.player}</th>
            <th>{strings.transfersStatus.team}</th>
            <th>{strings.transfersStatus.amount}</th>
          </tr>
        </thead>
        <tbody>
          {transfers.map((item, index) => (
            <tr key={index}>
              <td
                className="cursor-pointer"
                onClick={() => setPlayerUuid(item[0].data.attributes.uuid)}
              >i</td>
              <td>{localizeValue(sportPositions[item[0].data.attributes.player.position_kind].name)}</td>
              <td>{localizeValue(item[0].data.attributes.player.name).split(' ')[0]}</td>
              <td>{item[0].data.attributes.team.name}</td>
              <td>{item[1]}</td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  };

  return (
    <section className="grid grid-cols-2 gap-8">
      <div>
        <h2>{strings.transfersStatus.transfersIn}</h2>
        {renderTransfersData(pageState?.weekTransfers.transfers_in)}
      </div>
      <div>
        <h2>{strings.transfersStatus.transfersOut}</h2>
        {renderTransfersData(pageState?.weekTransfers.transfers_out)}
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
