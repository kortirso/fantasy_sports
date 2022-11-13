# frozen_string_literal: true

LineupSchema = Dry::Schema.Params do
  optional(:active_chips).maybe(:array) do
    each(:string)
      .value(included_in?: [Chipable::BENCH_BOOST, Chipable::TRIPLE_CAPTAIN, Chipable::FREE_HIT, Chipable::WILDCARD])
  end
end
