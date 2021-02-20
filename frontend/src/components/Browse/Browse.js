import React, { useEffect, useState } from "react";
import Spinner from "react-bootstrap/Spinner";

import Title from "../Title";
import MovieStrip from "./MovieStrip";
import SingleMovie from "../Display/SingleMovie";
import "./Browse.css";
import MovieSearchForm from "./MovieSearchForm";
import MoviePagination from "./MoviePagination";

function Browse() {
  const [singleDisplay, setSingleDisplay] = useState(false);
  const [selectedMovie, setSelectedMovie] = useState(null);
  const [noOfResults, setNoOfResults] = useState(0);
  const [dataLoaded, setDataLoaded] = useState(false);
  const [search, setSearch] = useState("");
  const [movies, setMovies] = useState([]);
  const [pageNo, setPageNo] = useState(1);

  useEffect(() => {
    getData();
  }, [pageNo, search]);

  function getData() {
    var params = {
      offset: (pageNo - 1) * 10,
    };

    if (search !== "") {
      params.search = search;
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
  }

  function handleClick(movieID) {
    setSingleDisplay(true);
    setSelectedMovie(movieID);
  }

  function back() {
    setSingleDisplay(false);
  }

  function pageChange(number) {
    setDataLoaded(false);
    setPageNo(number);
  }

  var displayedMovies;
  if (dataLoaded) {
    displayedMovies = (
      <>
        <div className="movies">
          {movies.map((movie, index) => {
            return (
              <MovieStrip
                key={index}
                name={movie.title}
                image={movie.movieURL}
                genres={movie.genres}
                stars={movie.stars}
                click={handleClick}
              ></MovieStrip>
            );
          })}
        </div>
        <div className="pagination">
          <MoviePagination
            pageChange={pageChange}
            pageNo={pageNo}
            setPageNo={setPageNo}
            noOfResults={noOfResults}
          />
        </div>
      </>
    );
  } else {
    displayedMovies = (
      <div style={{ textAlign: "center" }}>
        <Spinner animation="border" />
      </div>
    );
  }

  if (singleDisplay) {
    return (
      <div>
        <SingleMovie back={back}></SingleMovie>
      </div>
    );
  } else {
    return (
      <div>
        <Title text="Movies database"></Title>
        <div className="Body">
          <MovieSearchForm onSubmit={setSearch} />
          {displayedMovies}
        </div>
      </div>
    );
  }
}

export default Browse;
