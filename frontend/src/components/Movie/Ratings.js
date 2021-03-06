import { useEffect, useState } from "react";
import RatingsRow from "./RatingsRow";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import "./Ratings.css";

function Rating(props) {
  const [data, setData] = useState();

  useEffect(() => {
    const url =
      "http://localhost/getRatingBreakdown.php?" +
      new URLSearchParams({ movie_id: props.movieID });
    fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((dataReceived) => {
        var a = [1, 2, 3, 4, 5];
        var breakdown = [];
        a.forEach((item, index) => {
          var current = dataReceived.breakdown.filter(
            (value) => value.rating_idx === item
          );
          if (current.length === 0) {
            breakdown[index] = { rating_idx: item, rating_count: 0 };
          } else {
            breakdown[index] = current[0];
          }
        });
        dataReceived.breakdown = breakdown;
        setData(dataReceived);
      })
      .catch((err) => {
        console.log(url);
        console.log(err);
      });
  }, []);

  if (data) {
    console.log(data.summary.average);
    return (
      <Container className="ratings-breakdown">
        <Row className="rating-summary">
          <Col xs={12}>
            <span>
              Rating:{" "}
              <span className="actual-rating">{data.summary[0].average} </span>/
              5
            </span>
          </Col>
          <Col>
            <span>({data.summary[0].count} Ratings)</span>
          </Col>
        </Row>
        {data.breakdown.map((item, index) => (
          <RatingsRow
            key={index}
            value={(item.rating_count / data.summary[0].count) * 100}
            star={item.rating_idx}
          />
        ))}
      </Container>
    );
  } else {
    return <div></div>;
  }
}

export default Rating;
