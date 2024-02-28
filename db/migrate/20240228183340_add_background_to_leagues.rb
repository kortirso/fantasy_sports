class AddBackgroundToLeagues < ActiveRecord::Migration[7.1]
  def change
    add_column :leagues, :background_url, :string, null: false, default: ''

    League.find_each do |league|
      background_url =
        case league.name['en']
        when 'English Premier League', 'Premier League' then 'leagues/epl.webp'
        when 'Russian Premier League' then 'leagues/rpl.webp'
        when 'Seria A' then 'leagues/seria_a.webp'
        when 'La Liga' then 'leagues/la_liga.webp'
        when 'Bundesliga' then 'leagues/bundesliga.webp'
        when 'NBA' then 'leagues/nba.webp'
        when 'Champions League' then 'leagues/champions_league.webp'
        else ''
        end

      league.update(background_url: background_url)
    end
  end
end
