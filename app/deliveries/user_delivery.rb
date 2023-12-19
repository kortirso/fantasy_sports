# frozen_string_literal: true

class UserDelivery < ApplicationDelivery
  before_notify :ensure_mailer_enabled, on: :mailer
  before_notify :ensure_telegram_enabled, on: :telegram

  delivers :deadline_report

  private

  def ensure_mailer_enabled = false

  def ensure_telegram_enabled
    return false if notification_targets.exclude?(Notification::TELEGRAM)

    true
  end

  def notification_targets
    @notification_targets ||= user.notifications.where(notification_type: notification_type).pluck(:target)
  end

  def notification_type
    case notification_name
    when :deadline_report then Notification::DEADLINE_DATA
    end
  end

  def user = params[:user]
  def fantasy_team = params[:fantasy_team]
  def week = params[:week]
end
