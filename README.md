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
```

## Tasks

Check translations

```bash
$ i18n-tasks health
```

## Testing

### Unit tests

```bash
$ rspec
```

### E2E tests

With browser
```bash
$ rails server -e test -p 5002
$ yarn cypress open --project ./spec/e2e
```

Headless
```bash
$ rails server -e test -p 5002
$ yarn run cypress run --project ./spec/e2e
```

### Sensitive information leaks

```bash
$ bearer scan .
```

## Process

### Starting new week

```ruby
  Weeks::ChangeService.call(week_id: week.id)
```
week - coming week that must start

### Fetching data for game

```ruby
  Games::FetchService.call(game: game)
```
game - game for fetching data

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. Please see the [LICENSE](./LICENSE.md) file in our repository for the full text.
