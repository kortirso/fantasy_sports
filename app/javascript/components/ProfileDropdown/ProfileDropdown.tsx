import React, { useState, useEffect } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

interface ProfileDropdownProps {
  logoutLink: React.ReactNode;
  unreadAchievementsCount: number;
  achievementsLink: React.ReactNode;
}

strings.setLanguage(currentLocale);

export const ProfileDropdown = ({
  logoutLink,
  unreadAchievementsCount,
  achievementsLink
}: ProfileDropdownProps): JSX.Element => {
  const [isOpen, setIsOpen] = useState<boolean>(false);

  const renderUnreadAchievementsBadge = () => {
    if (unreadAchievementsCount === 0) return null;

    return <span className="achievements-badge">{unreadAchievementsCount}</span>;
  };

  return (
    <div id="profile-dropdown">
      <div className="action" onClick={() => setIsOpen(!isOpen)}>
        {strings.profileDropdown.title}
      </div>
      {isOpen && (
        <ul className="profile-dropdown-list">
          <li>
            <a href={achievementsLink}>{strings.profileDropdown.achievements}{renderUnreadAchievementsBadge()}</a>
          </li>
          <div className="separator"></div>
          <li>
            <a href={logoutLink}>{strings.profileDropdown.logout}</a>
          </li>
        </ul>
      )}
    </div>
  );
};
