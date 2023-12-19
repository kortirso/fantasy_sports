import React, { useState, useMemo } from 'react';

import { Checkbox } from '../../components/atoms';
import { currentLocale, csrfToken } from '../../helpers';
import { strings } from '../../locales';

import { apiRequest } from '../../requests/helpers/apiRequest';

strings.setLanguage(currentLocale);

const NOTIFICATION_SOURCES = ['telegram'];

export const Notifications = ({ notifications, identities }) => {
  const [pageState, setPageState] = useState({
    errors: [],
    notifications: notifications,
    telegramEnabled: identities.find((item) => item.provider === 'telegram') !== undefined,
  });

  const notificationTargets = useMemo(() => {
    return pageState.notifications.reduce((acc, item) => {
      if (acc[item.notification_type]) acc[item.notification_type].push(item.target);
      else acc[item.notification_type] = [item.target];

      return acc;
    }, {});
  }, [pageState.notifications]);

  const onChangeNotification = async (notification_type, target, method) => {
    const result = await apiRequest({
      url: `/api/frontend/notifications.json`,
      options: {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ notification: { notification_type: notification_type, target: target } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      notifications: result.result
    });
  };

  const changeNotification = (notification_type, target) => {
     onChangeNotification(
      notification_type,
      target,
      notificationTargets[notification_type]?.includes(target) ? 'DELETE' : 'POST'
    );
  };

  const renderNotificationType = (title, notification_type) => (
    <tr>
      <td>
        <span className="pr-8">{title}</span>
      </td>
      {NOTIFICATION_SOURCES.map((target) => (
        <td key={`${notification_type}-${target}`}>
          <div className="flex justify-center">
            <Checkbox
              checked={pageState.telegramEnabled && notificationTargets[notification_type]?.includes(target)}
              onClick={() => pageState.telegramEnabled ? changeNotification(notification_type, target) : null}
            />
          </div>
        </td>
      ))}
    </tr>
  );

  return (
    <>
      <table className="table zebra mt-4 w-auto">
        <thead>
          <tr>
            <th></th>
            <th className={`${pageState.telegramEnabled ? '' : 'opacity-50'}`}>Telegram</th>
          </tr>
        </thead>
        <tbody>
          {renderNotificationType(strings.profile.deadlinesData, 'deadline_data')}
        </tbody>
      </table>
    </>
  );
};
