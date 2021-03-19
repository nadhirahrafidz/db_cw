import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import "./ExtraMovieInfo.css";
function ExtraMovieInfo(props) {
  const movie = props.movie;
  return (
    <Row className="extra-movie-info-container">
      <Col xs="4" className="info-label">
        User Rating:
      </Col>
      <Col xs="8" className="key-info">
        {movie.rating}
      </Col>
      <Col xs="4" className="info-label">
        Genres:
      </Col>
      <Col xs="8" className="key-info">
        {movie.genres}
      </Col>
      <Col xs="4" className="info-label">
        Stars:
      </Col>
      <Col xs="8" className="key-info">
        {movie.stars}
      </Col>
      <Col xs="4" className="info-label">
        Director:
      </Col>
      <Col xs="8" className="key-info">
        {movie.director}
      </Col>
      <Col xs="4" className="info-label">
        Runtime (mins):
      </Col>
      <Col xs="8" className="key-info">
        {movie.runtime}
      </Col>
      <Col xs="4" className="info-label">
        Tags:
      </Col>
      <Col xs="8" className="key-info">
        {movie.tags}
      </Col>
    </Row>
  );
}

export default ExtraMovieInfo;
