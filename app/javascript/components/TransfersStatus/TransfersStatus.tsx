import React, { useState, useEffect } from 'react';

import type { WeekTransfer } from 'entities';
import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { weekTransfersRequest } from './requests/weekTransfersRequest';

interface TransfersStatusProps {
  weekUuid: string;
}

interface PageState {
  loading: boolean;
  weekTransfers: {
    transfers_in: WeekTransfer[];
    transfers_out: WeekTransfer[];
  };
}

strings.setLanguage(currentLocale);

export const TransfersStatus = ({ weekUuid }: TransfersStatusProps): JSX.Element => {
  const [pageState, setPageState] = useState<PageState>({
    loading: true,
    weekTransfers: { transfers_in: [], transfers_out: [] },
  });

  useEffect(() => {
    const fetchWeekTransfers = async () => {
      return await weekTransfersRequest(weekUuid);
    };

    Promise.all([fetchWeekTransfers()]).then(([fetchWeekTransfersData]) =>
      setPageState({
        loading: false,
        weekTransfers: fetchWeekTransfersData,
      }),
    );
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  if (pageState.loading) return <></>;

  const renderTransfersData = (transfers?: WeekTransfer[]) => {
    if (!transfers || transfers.length === 0) return <></>;

    return (
      <table className="table full-width">
        <thead>
          <tr>
            <th></th>
            <th>{strings.transfersStatus.position}</th>
            <th>{strings.transfersStatus.player}</th>
            <th>{strings.transfersStatus.team}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {transfers.map((item: WeekTransfer, index: number) => (
            <tr key={index}>
              <td></td>
              <td>{item[0].data.attributes.player.position_kind}</td>
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
    <section className="main-container">
      <div className="half-container">
        <h2>{strings.transfersStatus.transfersIn}</h2>
        {renderTransfersData(pageState?.weekTransfers.transfers_in)}
      </div>
      <div className="half-container">
        <h2>{strings.transfersStatus.transfersOut}</h2>
        {renderTransfersData(pageState?.weekTransfers.transfers_out)}
      </div>
    </section>
  );
};
