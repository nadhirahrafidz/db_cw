import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

import Title from "../Title";
import MovieStrip from "./MovieStrip";
import AllMovies from "../../Data/AllMovies";
import SingleMovie from "../Display/SingleMovie"
import "./Browse.css";


class Browse extends React.Component {
  constructor(props) {
    super(props);

    //make sure to make the api call before the component is rendered. Compoment will mount is depreciated
    const movielist = this.getData();

    this.state = {
      movies: movielist['movies'],
      singleDisplay: false,
      selectedMovie: null
    };

    this.handleClick = this.handleClick.bind(this);
    this.back = this.back.bind(this); 
  }

  handleClick(movieID){
    this.setState({
      singleDisplay:true,
      selectedMovie:movieID
    })
  }

  back(){
    this.setState({
      singleDisplay:false
    })
  }

  //function to make api call. For now uses dummy data
  getData() {
    //can use fetch() then promise chaining
    return AllMovies;
  }

  render() {
    if (this.state.singleDisplay) {
      return (
      <div>
        <SingleMovie back={this.back}></SingleMovie>
      </div>)
    } else {
      return (
        <div>
          <Title text="Movies database"></Title>

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
              {this.state.movies.map((movie) => (
                <MovieStrip
                  name={movie.name}
                  image={movie.image}
                  genres={movie.genres}
                  stars={movie.stars}
                  click={this.handleClick}
                ></MovieStrip>
              ))}
            </div>
          </div>
        </div>
      );
    }
  }
}

export default Browse;
