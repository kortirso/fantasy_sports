# frozen_string_literal: true

class ApplicationSerializer
  include JSONAPI::Serializer

  def self.params_with_field?(params, field_name)
    !params[:fields].blank? || params[:fields]&.include?(field_name)
  end
end
