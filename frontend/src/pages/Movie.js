import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import CustomNavbar from "../navigation/CustomNavbar";
import Container from "react-bootstrap/Container";
import "./Movie.css";
import ExtraMovieInfo from "../Components/Movie/ExtraMovieInfo";
import RatingsBreakdown from "../Components/Movie/RatingsBreakdown";
import Fade from "../Components/Movie/Fade";
import AudienceSegmentation from "../Components/Movie/AudienceSegmentation";

function Movie() {
  const { id } = useParams();
  const [movieID, _] = useState(id);
  const [movie, setMovie] = useState();
  const [dataLoaded, setDataLoaded] = useState(false);
  const [showMore, setShowMore] = useState(false);

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
            <Row>
              <Col sm={1} md={2} lg={3} />
              <Col sm={4} md={4} lg={3}>
                <img className="movie-movie-image" src={movie.movieURL} />
              </Col>
              <Col sm={7} md={6}>
                <p className="movie-movie-title">{movie.title}</p>
              </Col>
            </Row>
            <Fade>
              <ExtraMovieInfo movie={movie} />
            </Fade>
          </Container>
        </div>
        <RatingsBreakdown movieID={movieID} />
        <div
          className="show-more"
          style={{ display: showMore ? "none" : "flex" }}
        >
          <Fade>
            <Button onClick={() => setShowMore(true)}>
              Show Audience Segmentation
            </Button>
          </Fade>
        </div>

        <AudienceSegmentation show={showMore} movieID={movieID} />
      </div>
    );
  }
  return <div>{movieID}</div>;
}

export default Movie;
