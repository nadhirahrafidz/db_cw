import React, { useEffect, useState } from "react";

import "./Page.css";
import MovieSearchForm from "../Components/Browse/MovieSearchForm";
import DisplayMovies from "../Components/Browse/DisplayMovies";
import CustomNavbar from "../Components/Navigation/CustomNavbar";

function Browse() {
  const [search, setSearch] = useState("");
  const [genre, setGenre] = useState();
  const [pageNo, setPageNo] = useState(1);
  const [sortOption, setSortOption] = useState(0);

  function handleSubmit(newSearch, newGenre, newSortOption) {
    setSearch(newSearch);
    setGenre(newGenre);
    setPageNo(1);
    setSortOption(newSortOption);
  }

  function pageChange(newPageNo) {
    setPageNo(newPageNo);
  }

  return (
    <div className="body">
      <CustomNavbar />
      <h1 className="header">Browse Movies</h1>
      <div className="browse-movies">
        <MovieSearchForm
          onSubmit={handleSubmit}
          setSortOption={setSortOption}
        />
        <DisplayMovies
          pageChange={pageChange}
          genre={genre}
          search={search}
          pageNo={pageNo}
          sortOption={sortOption}
        />
      </div>
    </div>
  );
}

export default Browse;
