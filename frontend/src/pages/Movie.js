import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Row from "react-bootstrap/Row";
import CustomNavbar from "../navigation/CustomNavbar";
import Col from "react-bootstrap/Col";
import Container from "react-bootstrap/Container";
import "./Movie.css";

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
    return (
      <div className="body">
        <CustomNavbar />
        <div className="poster-container">
          <div
            style={{
              backgroundImage: "url(" + movie.movieURL + ")",
            }}
            className="bg-image"
          ></div>
        </div>
        <Container className="content" fluid>
          <Row style={{ width: "100%" }}>
            <Col sm={1} md={2} lg={3} />
            <Col sm={4} md={4} lg={3}>
              <img className="movie-movie-image" src={movie.movieURL} />
            </Col>
            <Col sm={7} md={6}>
              <p className="movie-movie-title">{movie.title}</p>
            </Col>
          </Row>
        </Container>
      </div>
    );
  }
  return <div>{movieID}</div>;
}

export default Movie;