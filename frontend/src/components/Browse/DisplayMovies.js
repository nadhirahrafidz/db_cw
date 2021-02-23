import React, { useEffect, useState } from "react";

import Spinner from "react-bootstrap/Spinner";
import MovieStrip from "./MovieStrip";
import "./Browse.css";
import MoviePagination from "./MoviePagination";

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
      offset: (props.pageNo - 1) * 10,
    };
    if (props.search !== "") {
      params.search = props.search;
    }
    if (props.genres.length > 0) {
      params.genres = JSON.stringify(props.genres);
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
        console.log(url);
        console.log(err);
      });
  }, [props.genres, props.search, props.pageNo]);

  var invalidPageNo = true;
  if (dataLoaded && props.pageNo > 0) {
    const lastPage = Math.ceil(noOfResults / 10);
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
        <div className="movies">
          {movies.map((movie, index) => {
            return <MovieStrip key={index} movie={movie}></MovieStrip>;
          })}
        </div>
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
        <Spinner animation="border" />
      </div>
    );
  }
}

export default DisplayMovies;
