# Fantasy Sports

Web application for creating and maintaining fantasy leagues for different kinds of sport competitions.

## Installation

```bash
$ bundle install
$ rails db:create
$ rails db:schema:load
$ rails db:seed
$ yarn install
```

## Running web application

```bash
$ foreman s
$ que
```

## Process

### Starting new week

```ruby
  Weeks::RefreshOperator.call(week: week)
```
week - coming week that must start

### Fetching data for game

```ruby
  Games::FetchService.call(game: game)
```
game - game for fetching data
