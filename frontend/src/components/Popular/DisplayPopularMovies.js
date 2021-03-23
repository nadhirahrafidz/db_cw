import React, { useEffect, useState } from "react";

import Spinner from "react-bootstrap/Spinner";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import MovieStrip from "../MovieGrid/MovieStrip";
import "../../pages/Page.css";
import MoviePagination from "../Navigation/MoviePagination";
import "./DisplayPopularMovies.css";

function DisplayPopularMovies(props) {
  const [noOfResults, setNoOfResults] = useState(-1);
  const [dataLoaded, setDataLoaded] = useState(false);
  const [movies, setMovies] = useState([]);

  useEffect(() => {
    if (props.pageNo < 0) {
      return;
    }
    setDataLoaded(false);
    var params = {
      offset: (props.pageNo - 1) * 12,
      timescale: props.popularityTimescale,
    };
    if (props.genre) {
      params.genre = props.genre;
    }
    var url;
    if (props.type === "popular") {
      url =
        "http://localhost/getPopularMovies.php?" + new URLSearchParams(params);
    } else if (props.type === "polarising") {
      url =
        "http://localhost/getPolarisingMovies.php?" +
        new URLSearchParams(params);
    }
    fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setNoOfResults(data.total);
        setMovies(data.movies);
        setDataLoaded(true);
      })
      .catch((err) => {
        console.log(url);
        console.log(err);
      });
  }, [props.pageNo, props.popularityTimescale, props.genre]);

  var invalidPageNo = true;
  if (dataLoaded && props.pageNo > 0) {
    const lastPage = Math.ceil(noOfResults / 12);
    if (props.pageNo <= lastPage) {
      invalidPageNo = false;
    }
  }

  if (noOfResults == 0) {
    return <div>No Results</div>;
  }

  if (!invalidPageNo) {
    return (
      <>
        <Container>
          <Row>
            {movies.map((movie, index) => {
              return (
                <MovieStrip
                  type={props.type}
                  key={index}
                  movie={movie}
                ></MovieStrip>
              );
            })}
          </Row>
        </Container>
        <div className="pagination">
          <MoviePagination
            pageChange={props.pageChange}
            pageNo={props.pageNo}
            noOfResults={noOfResults}
          />
        </div>
      </>
    );
  } else {
    return (
      <div style={{ textAlign: "center" }}>
        <Spinner variant="primary" animation="border" />
      </div>
    );
  }
}

export default DisplayPopularMovies;
