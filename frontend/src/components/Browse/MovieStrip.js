import React from "react";
import "./MovieStrip.css";

function MovieStrip(props) {
  var genres = props.genres.split(",");

  return (
    <div className="moviestrip">
      <img className="stripimage" src={props.image} />

      <div className="details">
        <h2 onClick={props.click}>{props.name}</h2>
        <br />

        <div>
          {"Genres: "}
          {genres.map((genre, index) => (
            <p className="list" key={index}>
              {genre.trim()}
              {", "}
            </p>
          ))}
        </div>
        <br />
        <div>
          stars:
          {props.stars.map((star, index) => (
            <p className="list" key={index}>
              {star}
            </p>
          ))}
        </div>
      </div>
    </div>
  );
}

export default MovieStrip;
