# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- encrypting sensitive data

### Modified
- LICENSE

## [1.2.6] - 2024-04-17
### Added
- editing cups rounds for admins
- disable transfers for finishing season

### Fixed
- bug with creating oracul

## [1.2.5] - 2024-04-03
### Added
- create users with only username
- caching for frontend

## [1.2.4] - 2024-03-28
### Added
- best_of elimination kind for cups pairs
- likes for seasons/cups for better ordering
- scraping injuries

## [1.2.3] - 2024-03-21
### Added
- api endpoint for deleting user
- api endpoint for updating user

## [1.2.2] - 2024-03-18
### Added
- url localization
- api v1 endpoints for user login
- api v1 endpoints for forecasts

### Modified
- user navigation
- icons for fantasy teams in navigation

## [1.2.1] - 2024-02-29
### Added
- cups competitions for match prediction
- footer

### Fixed
- bug with rendering oracul page without lineup

## [1.2.0] - 2024-02-28
### Added
- match predictions mode

### Modified
- redesign

### Fixed
- creating user with Google oauth

## [1.1.7] - 2024-02-15
### Added
- recaptcha for users registration

### Modified
- navigation styles for better mobile
- closing dropdowns after outside click

## [1.1.6] - 2024-02-06
### Added
- google auth
- allow to restore password only for confirmed users
- hour limit for re-restoring password
- BannedEmail model for saving banned emails
- disabling access for banned users
- editing game start_at for admins
- editing week deadline_at for admins
- basis for E2E tests with Cypress

### Modified
- saving games without week
- rendering championships data

### Fixed
- rendering last points for list view at squad page

## [1.1.5] - 2023-12-29
### Added
- table view for squad views
- precalculating of selected by teams ratio for players
- multiple external ids for games
- telegram integration
- notifications layer
- clearing games_players if game moved to inactive week

### Modified
- RefreshSelectedService
- removed redundant db fields

### Fixed
- checkbox clicking

## [1.1.4] - 2023-11-30
### Added
- more sort options
- injuries

### Modified
- calculating form for players that didnt play game

### Fixed
- rendering statistics table tooltip
- refresh lineup players status after transfers

## [1.1.3] - 2023-11-17
### Added
- making substitutions after 1 day of last game
- destroying fantasy teams
- watchlist

### Modified
- open only 1 dropdown at time on Transfers page

## [1.1.2] - 2023-11-17
### Added
- collapsing games list for previous days
- calculating game difficulty for teams
- remembering invite code during sign up
- rendering active bench boost bonus at points page
- rendering wasted chips
- precalculating places in leagues

### Fixed
- bug with changing captain/assistant
- tracking red cards

## [1.1.1] - 2023-11-10
### Added
- render game results in PlayerModal
- headers for transfers table
- feedback form

### Modified
- refresh free transfers amount after approving transfers

### Fixed
- bug with scraping own goals for Sourceable::Sports
- bug with correcting prices

## [1.1.0] - 2023-11-05
### Added
- basketball achievements
- service for correcting prices
- show unreceived achievements

### Modified
- design

### Fixed
- rendering week fantasy leagues

## [1.0.6] - 2023-10-29
### Added
- save user session in cookies
- removing expired users sessions

### Modified
- change price for transfer in basketball

### Fixed
- transfers page

## [1.0.5] - 2023-10-29
### Added
- game week's fantasy leagues
- overall statistic for players modal

### Modified
- shirt_number of players to string
- calculating and using players season statistic

### Fixed
- updating game statistics through admin panel

## [1.0.4] - 2023-10-26
### Modified
- sync games once after 3 hours from start_at
- players synscronization
- players modal

## [1.0.3] - 2023-10-25
### Added
- links to other player's fantasy teams

### Modified
- basketball rules page
- performance for searching best players
- rendering player statistics

### Fixed
- sorting players by points

## [1.0.2] - 2023-10-22
### Modified
- for first week status calculate transfers in by final amount of teams players
- UI for mobile friendly

### Fixed
- passing children to js components

## [1.0.1] - 2023-10-21
### Added
- translations health check

### Modified
- remove locale from url
- welcome page translation

### Fixed
- transfers page error handling

## [1.0.0] - 2023-10-20
### Added
- release 1.0.0
