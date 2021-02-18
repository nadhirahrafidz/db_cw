import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

import Title from "../Title";
import FutureMovies from "../../Data/FutureMovies";
import MovieStrip from "./MovieStrip";

class Released extends React.Component {
  constructor(props) {
    super(props);

    const latestrelease = this.getData();
    this.state = {
      latest: latestrelease["movies"],
      singleDisplay: false,
      selectedMovie: null
    };
  }

  getData() {
    return FutureMovies;
  }

  render() {
    return (
      <div>
        <Title text="Future releases"></Title>
        <div className="Body">
          <div className="search">
            <Form>
              <Form.Group controlId="formBasicSearch">
                <Form.Label>Search for a movie</Form.Label>
                <Form.Control placeholder="Enter Search" />
              </Form.Group>
              <Button variant="primary" type="submit">
                Submit
              </Button>
            </Form>
          </div>

          <div className="movies">
              {this.state.latest.map((movie) => (
                <MovieStrip
                  name={movie.name}
                  image={movie.image}
                  genres={movie.genres}
                  stars={movie.stars}
                ></MovieStrip>
              ))}
            </div>
        </div>
      </div>
    );
  }
}

export default Released;
