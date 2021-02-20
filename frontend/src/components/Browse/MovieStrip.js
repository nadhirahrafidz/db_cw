import React from "react";
import "./MovieStrip.css";

function MovieStrip(props) {
  var genres = props.genres.split(",");
  var stars = props.stars.split(",");

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
      </div>
    </div>
  );
}

export default MovieStrip;
