import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Fade from "./Fade";
import { useEffect, useState } from "react";
import Spinner from "react-bootstrap/Spinner";
import "./AudienceSegmentation.css";

function AudienceSegmentation(props) {
  const [data, setData] = useState();
  const [dataLoaded, setDataLoaded] = useState(false);

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
        console.log(data[0]);
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
    return (
      <div className="ratings-menu2">
        <Row className="rating-container2">
          <Fade>
            <Col xs={9}>
              <h1>
                <span className="key-info">{data.pCountMostLikely}</span> users
                that have <span className="key-info">not</span> yet rated this
                movie are
                <span className="very-likely">
                  <span className="bold"> very </span>likely to enjoy
                </span>{" "}
                this movie
              </h1>
              <p className="emoji">&#128513;</p>
            </Col>
          </Fade>
          <Fade>
            <Col xs={9}>
              <h1>
                <span className="key-info">{data.pCountLikely}</span> other
                users that have <span className="key-info">not</span> yet rated
                this movie are <span className="likely">likely to enjoy </span>
                this movie
              </h1>
              <p className="emoji">&#128522;</p>
            </Col>
          </Fade>
          <Fade>
            <Col xs={9}>
              <h1>
                <span className="key-info">{data.pCountLeastLikely}</span> users
                that have <span className="key-info">not</span> yet rated this
                movie are <span className="unlikely">unlikely to enjoy </span>
                this movie
              </h1>

              <p className="emoji">&#128542;</p>
            </Col>
          </Fade>
          <Fade>
            <Col xs={9}>
              <h1>
                <span className="key-info">{data.pCountUsuallyHigh}</span> users
                that <span className="key-info">usually enjoy</span> similar
                movies did <span className="unlikely">not enjoy</span> this
                movie
              </h1>
              <p className="emoji">&#128546;</p>
            </Col>
          </Fade>
          <Fade>
            <Col xs={9}>
              <h1>
                <span className="key-info">{data.pCountUsuallyLow}</span> users
                that <span className="key-info">usually don't enjoy</span>{" "}
                similar movies <span className="very-likely">did enjoy </span>
                this movie
              </h1>
              <p className="emoji">&#129321;</p>
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
