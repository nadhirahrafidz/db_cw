import "./Page.css";
import "./Use6.css";
import CustomNavbar from "../Components/Navigation/CustomNavbar";
import { useState } from "react";
import DisplayUse6Results from "../Components/Use6/DisplayUse6Results";
import Use6Form from "../Components/Use6/Use6Form";

function Use6() {
  const [loading, setLoading] = useState(false);
  const [predictions, setPredictions] = useState();

  function getPersonalityPredictions(movieID) {
    setLoading(true);
    var predictionParams = {
      movie_id: JSON.stringify(movieID),
    };

    const predictionUrl =
      "http://localhost/getPersonalityPrediction.php?" +
      new URLSearchParams(predictionParams);
    console.log(predictionUrl);
    fetch(predictionUrl, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setLoading(false);
        setPredictions(data);
      })
      .catch((err) => {
        console.log(err);
      });
  }

  function handleSubmit(movieID) {
    setPredictions();
    getPersonalityPredictions(movieID);
  }

  return (
    <div className="body">
      <CustomNavbar />
      <h1 className="header">Use Case 6</h1>
      <div className="use6-form-container">
        <Use6Form handleSubmit={handleSubmit} loading={loading} />
      </div>
      <DisplayUse6Results data={predictions} />
    </div>
  );
}

export default Use6;
