import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import MovieStrip from "./Browse/MovieStrip";

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
    return <MovieStrip movie={movie} />;
  }
  return <div>{movieID}</div>;
}

export default Movie;
