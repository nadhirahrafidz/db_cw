import { useHistory } from "react-router-dom";
import Col from "react-bootstrap/Col";
import "./MovieStrip.css";

function MovieStrip(props) {
  const genres = !props.movie.stars ? [] : props.movie.genres.split(",");
  const stars = !props.movie.stars ? (
    <div />
  ) : (
    <div>{"Stars: " + props.movie.stars}</div>
  );
  const history = useHistory();

  function getTags() {
    if (!props.movie.tags) {
      return;
    }
    let displayTags =
      props.movie.tags.length > 50
        ? props.movie.tags.substring(0, 50) + "..."
        : props.movie.tags;
    return <div>{"Tags: " + displayTags}</div>;
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

  function getRatingsInfo() {
    return (
      <div className="rating">
        <div className="rating-box">{props.movie.rating}</div>
      </div>
    );
  }

  function getGenres() {
    return (
      <p className="genres">
        {genres.map((genre, index) => (
          <span
            className="genre-list-item"
            key={index}
            onClick={() => routeToGenre(genre)}
          >
            {genre.trim()}
            {index === genres.length - 1 ? "" : ","}&nbsp;
          </span>
        ))}
      </p>
    );
  }

  return (
    <Col xs={12} sm={6} md={6} lg={4} xl={3}>
      <div className="movie-image-div">
        <img
          className="movie-image"
          src={props.movie.movieURL}
          onClick={() => routeToMovie(props.movie.movie_id)}
        />
        <div style={{ position: "absolute", top: "0", width: "100%" }}>
          {getRatingsInfo()}
        </div>
      </div>

      <div className="movie-info">
        <p
          className="movie-title"
          onClick={() => routeToMovie(props.movie.movie_id)}
        >
          {props.movie.title}
        </p>
        {getGenres()}
        {/* {stars} */}
        {/* {getTags()} */}
      </div>
    </Col>
  );
}

export default MovieStrip;
