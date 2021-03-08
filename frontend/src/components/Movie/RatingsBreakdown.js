import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Fade from "./Fade";
import Ratings from "./Ratings";
import "./RatingsBreakdown.css";

function RatingsBreakdown(props) {
  return (
    <div className="ratings-menu">
      <Fade>
        <Row className="rating-container">
          <Col xs={9}>
            <Ratings movieID={props.movieID} />
          </Col>
        </Row>
      </Fade>
    </div>
  );
}

export default RatingsBreakdown;
