import React from "react";
import { useHistory } from "react-router-dom";
import "./MovieStrip.css";

function MovieStrip(props) {
  const genres = props.movie.genres.split(",");
  const stars = props.movie.stars.split(",");
  const history = useHistory();

  function routeToMovie(movie_id) {
    let path = "/movie/" + movie_id;
    history.push(path);
  }

  function routeToGenre(genre) {
    let path = "/browse?genres=" + genre;
    history.push(path);
  }

  return (
    <div className="moviestrip">
      <img
        className="stripimage"
        src={props.movie.movieURL}
        style={{ cursor: "pointer" }}
        onClick={() => routeToMovie(props.movie.movie_id)}
      />

      <div className="details">
        <h2
          // text-decoration: underline overline wavy blue;
          onClick={() => routeToMovie(props.movie.movie_id)}
          style={{
            color: "blue",
            cursor: "pointer",
            textDecoration: "underline",
            paddingLeft: "5px",
          }}
        >
          {props.movie.title}
        </h2>
        <br />
        <div>
          {"Genres: "}
          {genres.map((genre, index) => (
            <p
              className="list"
              key={index}
              onClick={() => routeToGenre(genre)}
              style={{ cursor: "pointer", color: "blue" }}
            >
              {genre.trim()}
              {index === genres.length - 1 ? "" : ", "}
            </p>
          ))}
        </div>
        <br />
        <div>
          {"Stars: "}
          {stars.map((star, index) => (
            <p className="list" key={index}>
              {star}
              {index === stars.length - 1 ? "" : ", "}
            </p>
          ))}
        </div>
        <br />
        <div>{"Average Rating: " + props.movie.rating}</div>
      </div>
    </div>
  );
}

export default MovieStrip;
