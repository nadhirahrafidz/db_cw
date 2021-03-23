import Col from "react-bootstrap/esm/Col";
import ProgressBar from "react-bootstrap/ProgressBar";
import "./PredictionsVsAverage.css";

const variants = ["primary", "success", "warning"];

function PredictionsVsAverage(props) {
  function normalise(value) {
    return (value / 7) * 100;
  }

  return (
    <div className="use6-graph">
      <Col>
        {props.trait}
        {props.predictions.map((item, index) => (
          <Col key={index} className="use6-bar">
            <ProgressBar
              variant={[variants[index]]}
              label={"Movie " + (index + 1) + " Prediction"}
              now={normalise(item[props.trait])}
            />
          </Col>
        ))}
        <Col className="use6-bar">
          <ProgressBar
            variant={"secondary"}
            label={"Average"}
            now={normalise(props.average["average_" + props.trait])}
          />
        </Col>
      </Col>
    </div>
  );
}

export default PredictionsVsAverage;
