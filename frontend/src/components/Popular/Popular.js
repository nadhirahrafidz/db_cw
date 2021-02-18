import React, { Component } from "react";
import CardDeck from "react-bootstrap/CardDeck"

import Title from "../Title";
import AllMovies from "../../Data/AllMovies";
import MovieColumn from "./MovieColumn"

class Popular extends React.Component {
  constructor(props) {
    super(props);

    const popularmovies = this.getPopularMovies();

    this.state = {
      movies: popularmovies["movies"],
      selected: false,
      selectedmovie: null
    };
  }

  //replace with api call later
  getPopularMovies() {
    return AllMovies;
  }

  render() {
    if (this.state.selected) {
      return <div></div>;
    } else {
      return (
        <div>
          <Title text="Popular movies now"></Title>
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
}

export default Popular;
