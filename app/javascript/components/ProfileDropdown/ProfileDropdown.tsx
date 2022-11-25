import React, { useState, useEffect } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

interface ProfileDropdownProps {
  logoutLink: React.ReactNode;
  unreadAchievementsCount: number;
}

export const ProfileDropdown = ({ logoutLink, unreadAchievementsCount }: ProfileDropdownProps): JSX.Element => {
  const [isOpen, setIsOpen] = useState<boolean>(false);

  useEffect(() => {
    strings.setLanguage(currentLocale);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const renderUnreadAchievementsBadge = () => {
    if (unreadAchievementsCount === 0) return null;

    return <span className="achievements-badge">{unreadAchievementsCount}</span>;
  };

  return (
    <div id="profile-dropdown">
      <div className="action" onClick={() => setIsOpen(!isOpen)}>{strings.profileDropdown.profile}</div>
      {isOpen && (
        <ul className="profile-dropdown-list">
          <li><a href='#'>{strings.profileDropdown.achievements}{renderUnreadAchievementsBadge()}</a></li>
          <div className="separator"></div>
          <li><a href={logoutLink}>{strings.profileDropdown.logout}</a></li>
        </ul>
      )}
    </div>
  );
};
