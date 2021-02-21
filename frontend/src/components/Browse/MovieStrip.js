import React from "react";
import "./MovieStrip.css";

function MovieStrip(props) {
  const genres = props.movie.genres.split(",");
  const stars = props.movie.stars.split(",");

  return (
    <div className="moviestrip">
      <img className="stripimage" src={props.movie.movieURL} />

      <div className="details">
        <h2>{props.movie.title}</h2>
        <br />
        <div>
          {"Genres: "}
          {genres.map((genre, index) => (
            <p className="list" key={index}>
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
