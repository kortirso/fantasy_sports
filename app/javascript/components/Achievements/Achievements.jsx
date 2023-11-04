import React, { useEffect, useState } from 'react';

import { currentLocale, localizeValue, convertDate } from '../../helpers';
import { strings } from '../../locales';

import { achievementGroupsRequest } from './requests/achievementGroupsRequest';
import { achievementsRequest } from './requests/achievementsRequest';

strings.setLanguage(currentLocale);

export const Achievements = () => {
  const [achievementGroups, setAchievementGroups] = useState([]);
  const [achievements, setAchievements] = useState({ received: [], unreceived: [], points: 0 });
  const [activeGroupUuid, setActiveGroupUuid] = useState();

  useEffect(() => {
    const fetchAchievementGroups = async () => {
      const data = await achievementGroupsRequest();
      setAchievementGroups(data);
    };

    fetchAchievementGroups();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    const fetchAchievements = async (groupUuid) => {
      const data = await achievementsRequest(groupUuid);
      setAchievements({
        received: data.received.data.map((element) => element.attributes),
        unreceived: data.unreceived.data.map((element) => element.attributes),
        points: data.achievements_points
      });
    };

    fetchAchievements(activeGroupUuid);
  }, [activeGroupUuid]);

  return (
    <section className="flex flex-col md:flex-row">
      <div className="py-2 pr-2 md:w-60">
        <p className="text-xl mb-4">{strings.achievements.points} - {achievements.points}</p>
        <div className="flex flex-row md:flex-col flex-wrap">
          <div
            className={`mr-2 md:mr-0 mb-2 py-2 px-4 rounded cursor-pointer text-white ${
              activeGroupUuid === undefined ? 'bg-green-600' : 'bg-green-400'
            }`}
            onClick={() => setActiveGroupUuid(undefined)}
            key="group-summary"
          >
            {strings.achievements.summary}
          </div>
          {achievementGroups.map((group) => (
            <div
              className={`mr-2 md:mr-0 mb-2 py-2 px-4 rounded cursor-pointer text-white ${
                activeGroupUuid === group.uuid ? 'bg-green-600' : 'bg-green-400'
              }`}
              onClick={() => setActiveGroupUuid(group.uuid)}
              key={`group-${group.uuid}`}
            >
              {localizeValue(group.name)}
            </div>
          ))}
        </div>
      </div>
      <div className="flex-1 p-2">
        {achievements.received.map((achievement, index) => (
          <div className="mb-2 rounded relative overflow-hidden" key={index}>
            <div className="relative text-center bg-green-600 text-white py-1 pl-4 pr-16 sm:px-16">
              <p className="text-xl">{localizeValue(achievement.title)}</p>
              <span className="hidden sm:block absolute top-2 right-20">{convertDate(achievement.updated_at)}</span>
            </div>
            <div className="text-center bg-green-200 py-1 pl-4 pr-16 sm:px-16">{localizeValue(achievement.description)}</div>
            <div className="achievement-icon"></div>
            <div className="absolute top-3 right-3 w-12 h-12 bg-orange-400 rounded flex justify-center items-center font-semibold text-xl">{achievement.points}</div>
          </div>
        ))}
        {achievements.unreceived.map((achievement, index) => (
          <div className="mb-2 rounded relative overflow-hidden opacity-75" key={index}>
            <div className="relative text-center bg-gray-400 text-white py-1 pl-4 pr-16 sm:px-16">
              <p className="text-xl">{localizeValue(achievement.title)}</p>
              <span className="hidden sm:block absolute top-2 right-20">{convertDate(achievement.updated_at)}</span>
            </div>
            <div className="text-center bg-gray-200 py-1 pl-4 pr-16 sm:px-16">{localizeValue(achievement.description)}</div>
            <div className="achievement-icon"></div>
            <div className="absolute top-3 right-3 w-12 h-12 bg-white rounded flex justify-center items-center font-semibold text-xl">{achievement.points}</div>
          </div>
        ))}
      </div>
    </section>
  );
};
