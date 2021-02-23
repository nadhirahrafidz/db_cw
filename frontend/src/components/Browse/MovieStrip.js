import React from "react";
import { useHistory } from "react-router-dom";
import "./MovieStrip.css";

function MovieStrip(props) {
  const genres = props.movie.genres.split(",");
  const stars = props.movie.stars.split(",");
  const history = useHistory();

  function getTags(tags) {
    if (!tags) {
      return;
    } else {
      let displayTags =
        props.movie.tags.length > 50
          ? props.movie.tags.substring(0, 50) + "..."
          : props.movie.tags;
      return "Tags: " + displayTags;
    }
    {
      /* {"Tags: "} */
    }
    {
      /* {props.movie.tags.length > 50
          ? props.movie.tags.substring(0, 50) + "..."
          : props.movie.tags} */
    }
  }

  function routeToMovie(movie_id) {
    let path = "/movie/" + movie_id;
    history.push(path);
  }

  function routeToGenre(genre) {
    let path = "/browse?genres=" + genre;
    history.push(path);
  }

  function ratings_stars(rating) {
    var count = 1;
    var rating_star = "";
    while (count < 6) {
      if (rating >= count) {
        rating_star = rating_star + "★";
      } else {
        rating_star = rating_star + "☆";
      }
      count = count + 1;
    }
    return rating_star;
  }

  return (
    <div className="moviestrip">
      <img
        className="stripimage"
        src={props.movie.movieURL}
        style={{ cursor: "pointer" }}
        onClick={() => routeToMovie(props.movie.movie_id)}
      />

      <div className="details" style={{ paddingLeft: "5px" }}>
        <h2
          // text-decoration: underline overline wavy blue;
          onClick={() => routeToMovie(props.movie.movie_id)}
          style={{
            color: "blue",
            cursor: "pointer",
            textDecoration: "underline",
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
        <div>
          {props.movie.rating +
            " " +
            ratings_stars(props.movie.rating) +
            " (" +
            props.movie.no_of_ratings +
            " ratings)"}
        </div>
        <br />
        {getTags(props.movie.tags)}
        {/* {"Tags: "} */}
        {/* {props.movie.tags.length > 50
          ? props.movie.tags.substring(0, 50) + "..."
          : props.movie.tags} */}
      </div>
    </div>
  );
}

export default MovieStrip;
