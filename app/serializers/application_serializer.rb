# frozen_string_literal: true

class ApplicationSerializer
  include JSONAPI::Serializer

  set_id :uuid

  def self.params_with_field?(params, field_name)
    params[:fields].present? && params[:fields]&.include?(field_name)
  end
end
