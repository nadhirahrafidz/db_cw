import React, { Component } from "react";
import CardDeck from "react-bootstrap/CardDeck";
import AllMovies from "../../Data/AllMovies";
import MovieColumn from "./MovieColumn";

class Polarising extends React.Component {
  constructor(props) {
    super(props);

    const polarising = this.getData();
    this.state = {
      selected: false,
      movies: polarising["movies"],
    };
  }

  getData() {
    return AllMovies;
  }

  render() {
    return (
      <div>
        <div className="Body">
          <CardDeck>
            {this.state.movies.map((movie) => (
              <MovieColumn name={movie.name} image={movie.image}></MovieColumn>
            ))}
          </CardDeck>
        </div>
      </div>
    );
  }
}

export default Polarising;
