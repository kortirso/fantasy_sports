import React, { useState, useEffect } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { weekTransfersRequest } from './requests/weekTransfersRequest';

interface TransfersStatusProps {
  weekUuid: string;
}

strings.setLanguage(currentLocale);

export const TransfersStatus = ({ weekUuid }: TransfersStatusProps): JSX.Element => {
  const [weekTransfers, setWeekTransfers] = useState();

  useEffect(() => {
    const fetchWeekTransfers = async () => {
      const data = await weekTransfersRequest(weekUuid);
      setWeekTransfers(data);
    };

    fetchWeekTransfers();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const renderTransfersData = (transfers) => {
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
          {transfers.map((item, index) => (
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
        {renderTransfersData(weekTransfers?.transfers_in)}
      </div>
      <div className="half-container">
        <h2>{strings.transfersStatus.transfersOut}</h2>
        {renderTransfersData(weekTransfers?.transfers_out)}
      </div>
    </section>
  );
};
