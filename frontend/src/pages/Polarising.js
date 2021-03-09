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
  const [genre, setGenre] = useState("");
  const [pageNo, setPageNo] = useState(-1);
  const [timescale, setTimescale] = useState(30);
  const [labels, setLabels] = useState();
  let location = useLocation();

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const pathPageNo =
      urlParams.get("page") === null ? 1 : urlParams.get("page");
    // const pathGenres =
    //   urlParams.get("genre") === null ? "" : urlParams.get("genre");
    if (
      pageNo != pathPageNo
      // || genre != pathGenres
    ) {
      setPageNo(pathPageNo);
      // setGenre(pathGenres);
    }
  }, [location]);

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
        setLabels(data.map((data) => data[0].trim()));
      })
      .catch((err) => {
        console.log(err);
      });
  }, []);

  function pushURL(newGenres, newPageNo) {
    var params = {
      page: newPageNo,
    };
    // if (newGenres.length > 0) {
    //   params.genres = newGenres.join();
    // }
    window.history.pushState(
      "pageNumber",
      "Title",
      "/polarising?" + new URLSearchParams(params)
    );
  }

  function pageChange(newPageNo) {
    setPageNo(newPageNo);
    pushURL(genre, newPageNo);
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
