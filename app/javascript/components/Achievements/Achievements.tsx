import React, { useEffect, useState } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

import { achievementGroupsRequest } from './requests/achievementGroupsRequest';
import { achievementsRequest } from './requests/achievementsRequest';

export const Achievements = (): JSX.Element => {
  const [achievementGroups, setAchievementGroups] = useState([]);
  const [achievements, setAchievements] = useState([]);
  const [activeGroupUuid, setActiveGroupUuid] = useState();

  const fetchAchievements = async (groupUuid?: string) => {
    const data = await achievementsRequest(groupUuid);
    setAchievements(data);
  };

  useEffect(() => {
    const fetchAchievementGroups = async () => {
      const data = await achievementGroupsRequest();
      setAchievementGroups(data);
    };

    strings.setLanguage(currentLocale);
    fetchAchievementGroups();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    fetchAchievements(activeGroupUuid);
  }, [activeGroupUuid]);

  return (
    <section id="achievements-box">
      <div className="achievement-groups">
        <div
          className={`${activeGroupUuid === undefined ? 'achievement-group active' : 'achievement-group'}`}
          onClick={() => setActiveGroupUuid(undefined)}
          key='group-summary'
        >
          {strings.achievements.summary}
        </div>
        {achievementGroups.map((group) => (
          <div
            className={`${activeGroupUuid === group.uuid ? 'achievement-group active' : 'achievement-group'}`}
            onClick={() => setActiveGroupUuid(group.uuid)}
            key={`group-${group.uuid}`}
          >
            {localizeValue(group.name)}
          </div>
        ))}
      </div>
      <div className="achievements">
        {achievements.map((achievement, index) => (
          <div className="achievement" key={index}>
            <div className="achievement-name">
              <p>{localizeValue(achievement.title)}</p>
              <span className="achievement-earned">
                {achievement.updated_at}
              </span>
            </div>
            <div className="achievement-description">
              {localizeValue(achievement.description)}
            </div>
            <div className="achievement-icon"></div>
            <div className="achievement-points">
              {achievement.points}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
};
