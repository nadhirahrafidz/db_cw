import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Fade from "./Fade";
import Button from "react-bootstrap/Button";
import { useEffect, useState } from "react";
import Spinner from "react-bootstrap/Spinner";
import "./AudienceSegmentation.css";

function AudienceSegmentation(props) {
  const [data, setData] = useState();
  const [dataLoaded, setDataLoaded] = useState(false);
  // g means genre, t means tags
  const [type, setType] = useState("g");

  useEffect(() => {
    if (!props.show) {
      return;
    }
    const url =
      "http://localhost/getAudienceSegmentation.php?" +
      new URLSearchParams({ movie_id: props.movieID });
    fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setData(data[0]);
        setDataLoaded(true);
      })
      .catch((err) => {
        console.log(url);
        console.log(err);
      });
  }, [props.show]);

  if (props.show) {
    if (!dataLoaded) {
      return (
        <div
          style={{
            display: "flex",
            height: "8vh",
            justifyContent: "center",
          }}
        >
          <Spinner variant="primary" animation="border" />
        </div>
      );
    }
    const buttonText = type === "g" ? "Switch to Tags" : "Switch to Genres";
    return (
      <div className="audience-segmentation">
        <Row className="audience-segmentation-container">
          <Fade>
            <div className="switch-segmentation-type-button">
              <Button onClick={() => setType(type === "g" ? "t" : "g")}>
                {buttonText}
              </Button>
            </div>
          </Fade>
          <Fade>
            <Col xs={8}>
              <h1>
                <span className="key-info">{data[type + "WouldLike"]}</span>{" "}
                users that have <span className="key-info">not</span> yet rated
                this movie are
                <span className="likely"> likely to enjoy</span> this movie
              </h1>
              <p className="emoji">&#128513;</p>
            </Col>
          </Fade>
          <Fade>
            <Col xs={8}>
              <h1>
                <span className="key-info">
                  {data[type + "WouldDislikeDidLike"]}
                </span>{" "}
                users that
                <span className="key-info"> usually don't enjoy </span>
                similar movies <span className="likely">did enjoy </span>
                this movie
              </h1>
              <p className="emoji">&#129321;</p>
            </Col>
          </Fade>
          <Fade>
            <Col xs={8}>
              <h1>
                <span className="key-info">{data[type + "WouldDislike"]}</span>{" "}
                users that have <span className="key-info">not</span> yet rated
                this movie are{" "}
                <span className="unlikely">unlikely to enjoy </span>
                this movie
              </h1>
              <p className="emoji">&#128542;</p>
            </Col>
          </Fade>
          <Fade>
            <Col xs={8}>
              <h1>
                <span className="key-info">
                  {data[type + "WouldLikeDidDislike"]}
                </span>{" "}
                users that <span className="key-info">usually enjoy</span>{" "}
                similar movies did <span className="unlikely">not enjoy</span>{" "}
                this movie
              </h1>
              <p className="emoji">&#128546;</p>
            </Col>
          </Fade>
        </Row>
      </div>
    );
  } else {
    return <div />;
  }
}

export default AudienceSegmentation;
