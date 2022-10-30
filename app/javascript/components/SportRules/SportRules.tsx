import React, { useEffect } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';
import { sportsData } from 'data';
import { Toggle } from 'components/atoms';

interface SportRulesProps {
  sportKind: string;
}

export const SportRules = ({ sportKind }: SportRulesProps): JSX.Element => {
  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  useEffect(() => {
    strings.setLanguage(currentLocale);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <>
      <h1>{strings.sportRules.title}</h1>
      <Toggle header={strings.sportRules.selectSquad}>
        <>
          <h4>{strings.sportRules.squadSizeHeader}</h4>
          <p>{strings.formatString(strings.sportRules.maxPlayers, { number: sport.max_players })}</p>
          <ul>
            {Object.entries(sportPositions).map(([key, value]) => (
              <li key={key}>
                {localizeValue(value.name)} - {value.total_amount}
              </li>
            ))}
          </ul>
          <h4>{strings.sportRules.budgetHeader}</h4>
          <p>{strings.sportRules.budgetDescription}</p>
          <h4>{strings.sportRules.perTeamHeader}</h4>
          <p>{strings.formatString(strings.sportRules.maxTeamPlayers, { number: sport.max_team_players })}</p>
        </>
      </Toggle>
      <Toggle header={strings.sportRules.transfers}>
      </Toggle>
      <Toggle header={strings.sportRules.deadlines}>
      </Toggle>
      <Toggle header={strings.sportRules.scoring}>
      </Toggle>
    </>
  );
};
