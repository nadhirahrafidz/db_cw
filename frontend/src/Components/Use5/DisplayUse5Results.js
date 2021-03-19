import "./Use5Form.css";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import "./DisplayUse5Results.css";

function DisplayUse5Results(props) {
  if (!props.predictions || !props.actualRating) {
    return <div />;
  }

  function round(number) {
    return Math.round(number * 100) / 100;
  }

  function averageRating() {
    var sum = 0;
    props.predictions.forEach((item) => {
      sum += item;
    });
    return round(sum / props.predictions.length);
  }

  return (
    <div style={{ color: "white" }}>
      <Row style={{ paddingTop: "5px" }}>
        <Col>
          <h2>
            {"Actual Rating: "}
            <span className="white">{round(props.actualRating)}</span>
            {" / 5"}
          </h2>
        </Col>
      </Row>
      <Row>
        <Col>
          <h2>
            {"Average Predicted Rating: "}
            <span className="white">{averageRating()}</span>
            {" / 5"}
          </h2>
        </Col>
      </Row>
      <div className="rating-prediction-table">
        <Row>
          <Col className="runs-col" xs={5} style={{ color: "white" }}>
            <span>Run Number</span>
          </Col>
          <Col xs={2}>Predicted Rating</Col>
          <Col xs={2}>Difference</Col>
        </Row>
        {props.predictions.map((item, index) => (
          <Row key={index}>
            <Col className="runs-col" xs={5}>
              <span>{index + 1}</span>
            </Col>
            <Col xs={2}>{round(item)}</Col>
            <Col
              style={{
                color:
                  round(item - props.actualRating) === 0
                    ? "white"
                    : round(item - props.actualRating) > 0
                    ? "green"
                    : "red",
              }}
              xs={2}
            >
              {round(Math.abs(item - props.actualRating))}
            </Col>
          </Row>
        ))}
      </div>
    </div>
  );
}

export default DisplayUse5Results;
