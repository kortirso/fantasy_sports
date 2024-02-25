# frozen_string_literal: true

module Admin
  class BannedEmailsController < Admin::BaseController
    include Deps[
      create_form: 'forms.banned_emails.create',
      update_service: 'services.persisters.users.update'
    ]

    before_action :find_banned_emails, only: %i[index]
    before_action :find_banned_email, only: %i[destroy]

    def index; end

    def new
      @banned_email = BannedEmail.new
    end

    def create
      # commento: banned_emails.value, banned_emails.reason
      case create_form.call(params: banned_email_params)
      in { errors: errors } then redirect_to new_admin_banned_email_path, alert: errors
      else redirect_to admin_banned_emails_path, notice: t('controllers.admin.banned_emails.create.success')
      end
    end

    def destroy
      @banned_email.destroy
      restore_user
      redirect_to admin_banned_emails_path, notice: t('controllers.admin.banned_emails.destroy.success')
    end

    private

    def find_banned_emails
      @banned_emails = BannedEmail.order(id: :desc)
    end

    def find_banned_email
      @banned_email = BannedEmail.find(params[:id])
    end

    def restore_user
      user = User.find_by(email: @banned_email.value)
      return unless user

      # commento: users.banned_at
      update_service.call(user: user, params: { banned_at: nil })
    end

    def banned_email_params
      params.require(:banned_email).permit(:value, :reason)
    end
  end
end
