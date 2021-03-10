import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Container from "react-bootstrap/Container";
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

  function percentage(number1, number2) {
    if (number2 === 0) {
      return "0% ";
    }
    return Math.round((number1 / number2) * 1000) / 10 + "% ";
  }

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
    console.log(data);
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
            <Row style={{ justifyContent: "center" }}>
              <Col xs={2} />
              <Col xs={8} style={{ paddingBottom: "3%" }}>
                <h1>
                  There are{" "}
                  <span className="key-info">
                    {data[type + "CountUsersRatedSimilar"]}
                  </span>{" "}
                  users in total that can be segmented based on this movie's
                  <span className="key-info">
                    {type === "g" ? " Genres" : " Tags"}
                  </span>
                  .
                </h1>
              </Col>
              <Col xs={2} />
              <Col xs={4} className="audience-sub-heading">
                <h1>
                  <span className="key-info">
                    {data[type + "HaveNotRated"]}
                  </span>{" "}
                  users have <span className="key-info"> not </span> yet rated
                  this movie.
                </h1>
              </Col>
              <Col xs={1} />
              <Col xs={4} className="audience-sub-heading">
                <h1>
                  <span className="key-info">{data[type + "HaveRated"]}</span>{" "}
                  users have <span className="key-info"> already </span> rated
                  this movie.
                </h1>
              </Col>
            </Row>
          </Fade>
          <Fade>
            <Container style={{ margin: "none", minWidth: "100%" }}>
              <Row style={{ justifyContent: "center" }}>
                <Col xs={4}>
                  <h1>
                    <span className="key-info">
                      {percentage(
                        data[type + "WouldLike"],
                        data[type + "HaveNotRated"]
                      )}
                    </span>
                    of users that have <span className="key-info">not</span> yet
                    rated this movie are
                    <span className="likely"> likely to enjoy</span> this movie
                  </h1>
                </Col>
                <Col xs={1} className="vertical-separator" />
                <Col xs={4}>
                  <h1>
                    <span className="key-info">
                      {percentage(
                        data[type + "WouldDislikeDidLike"],
                        data[type + "HaveRated"]
                      )}
                    </span>{" "}
                    users that
                    <span className="key-info"> usually don't enjoy </span>
                    similar movies <span className="likely">did enjoy </span>
                    this movie
                  </h1>
                </Col>
              </Row>
              <Row style={{ justifyContent: "center" }}>
                <Col xs={4}>
                  <p className="emoji">&#128513;</p>
                </Col>
                <Col xs={1} className="vertical-separator" />
                <Col xs={4}>
                  <p className="emoji">&#129321;</p>
                </Col>
              </Row>
            </Container>
          </Fade>
          <Fade>
            <Container style={{ margin: "none", minWidth: "100%" }}>
              <Row style={{ justifyContent: "center" }}>
                <Col xs={4}>
                  <h1>
                    <span className="key-info">
                      {percentage(
                        data[type + "WouldDislike"],
                        data[type + "HaveNotRated"]
                      )}
                    </span>{" "}
                    users that have <span className="key-info">not</span> yet
                    rated this movie are{" "}
                    <span className="unlikely">unlikely to enjoy </span>
                    this movie
                  </h1>
                </Col>
                <Col xs={1} className="vertical-separator" />
                <Col xs={4}>
                  <h1>
                    <span className="key-info">
                      {percentage(
                        data[type + "WouldDislikeDidDislike"],
                        data[type + "HaveRated"]
                      )}
                    </span>{" "}
                    users that <span className="key-info">usually enjoy</span>{" "}
                    similar movies did{" "}
                    <span className="unlikely">not enjoy</span> this movie
                  </h1>
                </Col>
              </Row>
              <Row style={{ justifyContent: "center" }}>
                <Col xs={4}>
                  <p className="emoji">&#128542;</p>
                </Col>
                <Col xs={1} className="vertical-separator" />
                <Col xs={4}>
                  <p className="emoji">&#128546;</p>
                </Col>
              </Row>
            </Container>
          </Fade>
        </Row>
      </div>
    );
  } else {
    return <div />;
  }
}

export default AudienceSegmentation;
