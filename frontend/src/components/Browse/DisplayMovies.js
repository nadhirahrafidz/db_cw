import React, { useEffect, useState } from "react";

import Spinner from "react-bootstrap/Spinner";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import MovieStrip from "../MovieGrid/MovieStrip";
import "../../pages/Page.css";
import MoviePagination from "../Navigation/MoviePagination";

function DisplayMovies(props) {
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
    };
    if (props.search !== "") {
      params.search = props.search;
    }
    if (props.genre) {
      params.genre = props.genre;
    }
    if (props.sortOption !== 0) {
      params.sort = props.sortOption;
    }
    const url = "http://localhost/getMovies.php?" + new URLSearchParams(params);

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
        console.log(err);
      });
  }, [props.genre, props.search, props.pageNo, props.sortOption]);

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
              return <MovieStrip key={index} movie={movie}></MovieStrip>;
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

export default DisplayMovies;
