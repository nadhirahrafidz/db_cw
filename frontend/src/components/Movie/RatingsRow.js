import ProgressBar from "react-bootstrap/ProgressBar";
import "./Ratings.css";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";

function RatingsRow(props) {
  return (
    <Row className="rating-row">
      <Col xs={2} className="rating-label">
        <span>{props.star} Stars</span>
      </Col>
      <Col style={{ display: "flex" }}>
        <ProgressBar variant="warning" now={props.value} />
      </Col>
      <Col xs={1} className="rating-label">
        <span>{Math.round(props.value)}%</span>
      </Col>
    </Row>
  );
}

export default RatingsRow;
