import React from 'react';

interface WeekProps {
  gameweekId: string;
}

export const Week = ({ gameweekId }: WeekProps): JSX.Element => {
  return (
    <div className="week">
      <div className="week-header flex justify-between items-center">
        <p></p>
        <p>Gameweek 1 - 01.01.2022</p>
        <p></p>
      </div>
      <div className="week-day">
        <div className="week-day-header">
          <p>01.01.2022</p>
        </div>
        <div className="game flex justify-center items-center">
          <p className="team-name">Team 1</p>
          <p className="game-start">14:30</p>
          <p className="team-name">Team 2</p>
        </div>
        <div className="game flex justify-center items-center">
          <p className="team-name">Team 3</p>
          <p className="game-start">15:30</p>
          <p className="team-name">Team 4</p>
        </div>
      </div>
      <div className="week-day">
        <div className="week-day-header">
          <p>02.01.2022</p>
        </div>
        <div className="game flex justify-center items-center">
          <p className="team-name">Team 5</p>
          <p className="game-start">14:30</p>
          <p className="team-name">Team 6</p>
        </div>
        <div className="game flex justify-center items-center">
          <p className="team-name">Team 7</p>
          <p className="game-start">15:30</p>
          <p className="team-name">Team 8</p>
        </div>
      </div>
    </div>
  );
};
