import React, { useState, useEffect } from 'react';

import { currentLocale, localizeValue } from 'helpers';
import { strings } from 'locales';

interface ProfileDropdownProps {
  logoutLink: React.ReactNode;
}

export const ProfileDropdown = ({ logoutLink }: ProfileDropdownProps): JSX.Element => {
  const [isOpen, setIsOpen] = useState<boolean>(false);

  useEffect(() => {
    strings.setLanguage(currentLocale);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <div id="profile-dropdown">
      <div className="action" onClick={() => setIsOpen(!isOpen)}>{strings.profileDropdown.profile}</div>
      {isOpen && (
        <ul className="profile-dropdown-list">
          <li><a href='#'>{strings.profileDropdown.achievements}</a></li>
          <div className="separator"></div>
          <li><a href={logoutLink}>{strings.profileDropdown.logout}</a></li>
        </ul>
      )}
    </div>
  );
};
