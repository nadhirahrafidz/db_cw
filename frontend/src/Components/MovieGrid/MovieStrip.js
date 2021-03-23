import { useHistory } from "react-router-dom";
import Col from "react-bootstrap/Col";
import "./MovieStrip.css";

function MovieStrip(props) {
  const genres = !props.movie.genres ? [] : props.movie.genres.split(",");
  const history = useHistory();

  function routeToMovie(movie_id) {
    let path = "/movie/" + movie_id;
    history.push(path);
  }

  function routeToGenre(genre) {
    let path = "/browse?genres=" + genre;
    history.push(path);
  }

  function getGenres() {
    return (
      <p className="genres">
        {genres.map((genre, index) => (
          <span key={index}>
            <span
              className="genre-list-item"
              onClick={() => routeToGenre(genre)}
            >
              {genre.trim()}
            </span>
            {index === genres.length - 1 ? "" : ","}&nbsp;
          </span>
        ))}
      </p>
    );
  }
  console.log("rating-box " + props.type);

  return (
    <Col xs={12} sm={6} md={6} lg={4} xl={3}>
      <div className="movie-image-div">
        <img
          className="movie-image"
          src={props.movie.movieURL}
          onClick={() => routeToMovie(props.movie.movie_id)}
        />
        <div className="rating">
          <div className={"rating-box " + props.type}>{props.movie.rating}</div>
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
      </div>
    </Col>
  );
}

export default MovieStrip;
