import React, { useEffect, useState } from "react";

import "./Page.css";
import DisplayPopularMovies from "../Components/Popular/DisplayPopularMovies";
import { useLocation } from "react-router-dom";
import CustomNavbar from "../Components/Navigation/CustomNavbar";
import Button from "react-bootstrap/Button";
import Row from "react-bootstrap/esm/Row";
import Col from "react-bootstrap/esm/Col";
import GenreSelector from "../Components/Popular/GenreSelector";

const timescaleOptions = [30, 365, 0];

function Polarising() {
  const [genre, setGenre] = useState(0);
  const [pageNo, setPageNo] = useState(1);
  const [timescale, setTimescale] = useState(30);
  const [labels, setLabels] = useState();

  useEffect(() => {
    const url = "http://localhost/getAllGenres.php?";
    fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setLabels(data);
      })
      .catch((err) => {
        console.log(err);
      });
  }, []);

  function pageChange(newPageNo) {
    setPageNo(newPageNo);
  }

  return (
    <div className="body">
      <CustomNavbar />
      <h1 className="header">Polarising</h1>
      <Row style={{ justifyContent: "center" }}>
        <Col xs={3}>
          {timescaleOptions.map((option, index) => (
            <Button
              key={index}
              variant={option === timescale ? "primary" : "outline-primary"}
              onClick={() => {
                setTimescale(option);
                setPageNo(1);
              }}
            >
              {option === 0 ? "All Time" : option}
            </Button>
          ))}
        </Col>
      </Row>
      <Row style={{ justifyContent: "center" }}>
        <Col xs={8}>
          <GenreSelector labels={labels} setGenre={setGenre} />
        </Col>
      </Row>
      <div className="browse-movies">
        <DisplayPopularMovies
          type="polarising"
          pageChange={pageChange}
          genre={genre}
          popularityTimescale={timescale}
          pageNo={pageNo}
        />
      </div>
    </div>
  );
}

export default Polarising;
