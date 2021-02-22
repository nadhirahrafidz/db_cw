import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

function Movie() {
  const { id } = useParams();
  const [movieID, _] = useState(id);
  const [movie, setMovie] = useState();
  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    const url =
      "http://localhost/getSingleMovie.php?" +
      new URLSearchParams({ movie_id: movieID });
    fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setMovie(data[0]);
        setDataLoaded(true);
      })
      .catch((err) => {
        console.log(url);
        console.log(err);
      });
  }, []);

  if (dataLoaded) {
    const genres = movie.genres.split(",");
    const stars = movie.stars.split(",");
    return (
      <div className="moviestrip">
        <img className="stripimage" src={movie.movieURL} />

        <div className="details">
          <h2>{movie.title}</h2>
          <br />
          <div>
            {"Genres: "}
            {genres.map((genre, index) => (
              <p className="list" key={index}>
                {genre.trim()}
                {index === movie.genres.length - 1 ? "" : ", "}
              </p>
            ))}
          </div>
          <br />
          <div>
            {"Stars: "}
            {stars.map((star, index) => (
              <p className="list" key={index}>
                {star}
                {index === movie.stars.length - 1 ? "" : ", "}
              </p>
            ))}
          </div>
          <br />
          <div>{"Average Rating: " + movie.rating}</div>
        </div>
      </div>
    );
  }
  return <div>{movieID}</div>;
}

export default Movie;
