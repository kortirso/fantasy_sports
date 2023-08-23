export const componentTypes = [
  'Achievements',
  'Flash',
  'SportRules',
  'Squad',
  'SquadPoints',
  'Transfers',
  'TransfersStatus',
] as const;

export type ComponentType = (typeof componentTypes)[number];

export type KeyValue = {
  [key in string]: string;
};

export type KeyValueNumberable = {
  [key in string]: number;
};

export type TeamPlayerStatistic = [KeyValue, number];
export type TransferData = {
  data: {
    attributes: {
      player: {
        name: KeyValue;
        position_kind: string;
      };
      team: {
        name: string;
      };
    };
  };
};
export type WeekTransfer = [TransferData, number];

export type TeamNames = {
  [key in string]: {
    name: KeyValue;
    short_name: string;
  };
};

export type TeamOpponents = {
  [key in string]: string[];
};

export type StatisticsOrder = {
  [key in string]: KeyValue;
};

export interface Attribute {
  attributes: any;
}

export interface Team {
  id: string;
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

export interface Lineup {
  uuid: string;
  active_chips: string[];
  fantasy_team: { available_chips: KeyValueNumberable };
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
    opponent_team: { uuid: string };
    statistic: KeyValue;
  };
}

export interface TeamsPlayer {
  uuid: string;
  player: Player;
  price: number;
  teams_selected_by: number;
  form: number;
  team: Team;
  active: boolean;
  change_order: number;
  games_players: {
    data: GamesPlayer[];
  };
}

export interface ChipValues {
  bench_boost?: number;
  triple_captain?: number;
  free_hit?: number;
  wildcard?: number;
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
  chips: ChipValues;
  max_chips_per_week: number;
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
  next: { uuid: string } | null;
  previous: { uuid: string } | null;
  date_deadline_at: string;
  time_deadline_at: string;
}

export interface Game {
  uuid: string;
  date_start_at: string;
  time_start_at: string;
  home_team: { uuid: string };
  visitor_team: { uuid: string };
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

export interface AchievementGroup {
  uuid: string;
  name: KeyValue;
}

export interface Achievement {
  description: KeyValue;
  title: KeyValue;
  points: number;
  updated_at: string;
}

export interface GameStatistic {
  key: string;
  home_team: TeamPlayerStatistic[];
  visitor_team: TeamPlayerStatistic[];
}
