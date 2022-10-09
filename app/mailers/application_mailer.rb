# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Emailbutler::Mailers::Helpers

  default from: 'from@example.com'
  layout 'mailer'
end
