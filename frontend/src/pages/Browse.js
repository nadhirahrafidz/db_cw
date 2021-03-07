import React, { useEffect, useState } from "react";

import "./Browse.css";
import MovieSearchForm from "../Components/Browse/MovieSearchForm";
import DisplayMovies from "../Components/Browse/DisplayMovies.js";
import { useLocation } from "react-router-dom";
import CustomNavbar from "../navigation/CustomNavbar";

function Browse() {
  const [search, setSearch] = useState("");
  const [genres, setGenres] = useState([]);
  const [pageNo, setPageNo] = useState(-1);
  const [sortOption, setSortOption] = useState(0);
  let location = useLocation();

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const pathPageNo =
      urlParams.get("page") === null ? 1 : urlParams.get("page");
    const pathSearch =
      urlParams.get("search") === null ? "" : urlParams.get("search");
    const pathGenres =
      urlParams.get("genres") === null
        ? []
        : urlParams.get("genres").split(",");
    if (pageNo != pathPageNo || search != pathSearch || genres != pathGenres) {
      setPageNo(pathPageNo);
      setGenres(pathGenres);
      setSearch(pathSearch);
    }
  }, [location]);

  function pushURL(newSearch, newGenres, newPageNo) {
    var params = {
      page: newPageNo,
    };
    if (newSearch !== "") {
      params.search = newSearch;
    }
    if (newGenres.length > 0) {
      params.genres = newGenres.join();
    }
    window.history.pushState(
      "pageNumber",
      "Title",
      "/browse?" + new URLSearchParams(params)
    );
  }

  function handleSubmit(newSearch, newGenres, newSortOption) {
    setSearch(newSearch);
    setGenres(newGenres);
    setPageNo(1);
    setSortOption(newSortOption);

    pushURL(newSearch, newGenres, 1);
  }

  function pageChange(newPageNo) {
    setPageNo(newPageNo);
    pushURL(search, genres, newPageNo);
  }

  return (
    <div className="body">
      <CustomNavbar />
      <h1 className="header">Browse Movies</h1>
      <div className="browse-movies">
        <MovieSearchForm
          genres={genres}
          onSubmit={handleSubmit}
          setSortOption={setSortOption}
        />
        <DisplayMovies
          pageChange={pageChange}
          genres={genres}
          search={search}
          pageNo={pageNo}
          sortOption={sortOption}
        />
      </div>
    </div>
  );
}

export default Browse;
