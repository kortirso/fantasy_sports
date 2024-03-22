class AddSlugToLeagues < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      add_column :leagues, :slug, :string, null: false, default: ''

      League.find_each do |league|
        slug =
          case league.name['en']
          when 'English Premier League', 'Premier League' then 'epl'
          when 'Russian Premier League' then 'rpl'
          when 'Seria A' then 'seria_a'
          when 'La Liga' then 'la_liga'
          when 'Bundesliga' then 'bundesliga'
          when 'NBA' then 'nba'
          when 'Champions League' then 'champions_league'
          else ''
          end

        league.update(slug: slug)
      end

      remove_column :leagues, :background_url
    end
  end
end
