import "./Page.css";
import "./Use5.css";
import CustomNavbar from "../Components/Navigation/CustomNavbar";
import Use5Form from "../Components/Use5/Use5Form";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import { useState } from "react";
import DisplayUse5Results from "../Components/Use5/DisplayUse5Results";

function Use5() {
  const [predictionLoading, setPredictionLoading] = useState(false);
  const [ratingLoading, setRatingLoading] = useState(false);
  const [predictions, setPredictions] = useState();
  const [actualRating, setActualRating] = useState();

  function getPredictions(movieID, panelSize, runs) {
    setPredictionLoading(true);
    var predictionParams = {
      movie_id: movieID,
      panel_size: panelSize,
      runs: runs ? runs : 1,
    };

    const predictionUrl =
      "http://localhost/getMovieRatingPrediction.php?" +
      new URLSearchParams(predictionParams);

    fetch(predictionUrl, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setPredictionLoading(false);
        setPredictions(data);
      })
      .catch((err) => {
        console.log(err);
      });
  }

  function getActualRating(movieID) {
    setRatingLoading(true);
    var params = {
      movie_id: movieID,
    };

    const url =
      "http://localhost/getMovieRating.php?" + new URLSearchParams(params);

    fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setRatingLoading(false);
        setActualRating(data);
      })
      .catch((err) => {
        console.log(err);
      });
  }

  function handleSubmit(movieID, panelSize, runs) {
    setPredictionLoading(true);
    setRatingLoading(true);
    setPredictions();
    getPredictions(movieID, panelSize, runs);
    getActualRating(movieID);
  }

  return (
    <div className="body">
      <CustomNavbar />
      <h1 className="header">Use Case 5</h1>
      <Row className="use5-form-container">
        <Col xs={10} sm={8} md={6} lg={4}>
          <Use5Form
            handleSubmit={handleSubmit}
            loading={predictionLoading || ratingLoading}
          />
        </Col>
      </Row>
      <DisplayUse5Results
        actualRating={actualRating}
        predictions={predictions}
      />
    </div>
  );
}

export default Use5;
