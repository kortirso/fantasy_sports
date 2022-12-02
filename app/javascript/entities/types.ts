export const componentTypes = ['Achievements', 'SportRules', 'Squad', 'SquadPoints', 'Transfers', 'TransfersStatus', 'ProfileDropdown'] as const;

export type ComponentType = typeof componentTypes[number];

export type KeyValue = {
  [key in string]: string;
};

export type TeamNames = {
  [key in number]: {
    name: KeyValue;
    short_name: string;
  };
};

export interface Attribute {
  attributes: any;
}

export interface Team {
  uuid: string;
  opposite_team_ids: number[];
  attributes: {
    name: KeyValue;
    short_name: string;
  };
}

export interface SportPosition {
  name: KeyValue;
}

export interface Player {
  name: KeyValue;
  points: number;
  position_kind: string;
  statistic: KeyValue;
}

export interface LineupPlayer {
  uuid: string;
  player: Player;
  team: Team;
  active: boolean;
  change_order: number;
  status: string;
  points: string;
  teams_player: { uuid: string };
}

export interface GamesPlayer {
  attributes: {
    uuid: string;
    points: number | null;
    week: any;
  };
}

export interface TeamsPlayer {
  uuid: string;
  player: Player;
  price: number;
  form: number;
  team: Team;
  active: boolean;
  change_order: number;
  games_players: {
    data: GamesPlayer[];
  };
}

export interface SportValues {
  name: KeyValue;
  max_players: number;
  max_active_players: number;
  max_team_players: number;
  free_transfers_per_week: number;
  points_per_transfer: number;
  changes: boolean;
  captain: boolean;
}

export interface PositionValues {
  name: KeyValue;
  short_name: KeyValue;
  total_amount: number;
  default_amount: number;
  min_game_amount: number;
  max_game_amount: number;
}

export interface Week {
  uuid: string;
  position: number;
  next: { uuid: string; };
  previous: { uuid: string; };
  date_deadline_at: string;
  time_deadline_at: string;
}

export interface Game {
  uuid: string;
  date_start_at: string;
  time_start_at: string;
  home_team: { uuid: string; };
  visitor_team: { uuid: string; };
  points: number[];
}

export interface SportsData {
  sports: {
    [key in string]: SportValues;
  };
  positions: {
    [key in string]: {
      [key in string]: PositionValues;
    };
  };
}
