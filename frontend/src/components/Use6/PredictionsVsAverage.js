import Col from "react-bootstrap/esm/Col";
import ProgressBar from "react-bootstrap/ProgressBar";
import "./PredictionsVsAverage.css";

function PredictionsVsAverage(props) {
  function normalise(value) {
    return (value / 7) * 100;
  }

  return (
    <div className="use6-graph">
      <Col>
        {props.trait}
        <Col>
          <ProgressBar label="Prediction" now={normalise(props.prediction)} />
          <ProgressBar
            label="Average"
            variant="secondary"
            now={normalise(props.average)}
          />
        </Col>
      </Col>
    </div>
  );
}

export default PredictionsVsAverage;
