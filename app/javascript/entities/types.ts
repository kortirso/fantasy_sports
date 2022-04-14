export const componentTypes = ['Welcome', 'Squad', 'Transfers'] as const;

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
  id: number;
  attributes: {
    name: KeyValue;
    short_name: string;
  };
}

export interface SportPosition {
  name: KeyValue;
}

export interface Team {
  id: number;
}

export interface Player {
  name: KeyValue;
  points: number;
  position_kind: string;
  statistic: KeyValue;
}

export interface LineupPlayer {
  id: number;
  player: Player;
  team: Team;
  active: boolean;
  change_order: number;
  points: string;
}

export interface TeamsPlayer {
  id: number;
  player: Player;
  price: number;
  team: Team;
  active: boolean;
  change_order: number;
}

export interface SportValues {
  name: KeyValue;
  max_players: number;
  max_active_players: number;
  max_team_players: number;
  free_transfers_per_week: number;
  points_per_transfer: number;
  changes: boolean;
}

export interface PositionValues {
  name: KeyValue;
  short_name: KeyValue;
  total_amount: number;
  default_amount: number;
  min_game_amount: number;
  max_game_amount: number;
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
