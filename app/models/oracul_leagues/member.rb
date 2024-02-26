# frozen_string_literal: true

module OraculLeagues
  class Member < ApplicationRecord
    self.table_name = :oracul_leagues_members

    belongs_to :oracul, class_name: '::Oracul', foreign_key: :oracul_id
    belongs_to :oracul_league,
               class_name: '::OraculLeague',
               foreign_key: :oracul_league_id,
               counter_cache: :oracul_leagues_members_count
  end
end
