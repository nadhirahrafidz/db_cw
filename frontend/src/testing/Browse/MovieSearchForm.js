import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Badge from "react-bootstrap/Badge";
import { useState, useEffect } from "react";
import GenreSelector from "../Popular/GenreSelector";
import SortByDropdown from "./SortByDropdown";
import "./MovieSearchForm.css";

const sortingOptions = [
  "Default",
  "Name (ascending)",
  "Name (descending)",
  "Rating",
  "Recently Added",
];

function MovieSearchForm(props) {
  const [search, setSearch] = useState("");
  const [labels, setLabels] = useState();
  const [genreSelected, setGenreSelected] = useState();
  const [currentOption, setCurrentOption] = useState(0);

  function handleSubmit(e) {
    e.preventDefault();
    props.onSubmit(search, genreSelected, currentOption);
  }

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

  if (labels) {
    return (
      <div className="search">
        <Form onSubmit={handleSubmit}>
          <Form.Group>
            <Form.Label>Search for a movie</Form.Label>
            <Form.Control
              placeholder="Enter Search"
              onChange={(e) => setSearch(e.target.value)}
            />
            <div
              style={{
                display: "flex",
                justifyContent: "flex-end",
                paddingTop: "5px",
                width: "100%",
              }}
            ></div>

            <div>
              <GenreSelector
                labels={labels}
                setGenre={setGenreSelected}
                genresSelected={genreSelected}
              />
            </div>
          </Form.Group>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <SortByDropdown
              options={sortingOptions}
              currentOption={currentOption}
              setCurrentOption={setCurrentOption}
            />
            <Button variant="primary" type="submit">
              Search
            </Button>
          </div>
        </Form>
      </div>
    );
  } else {
    return <div></div>;
  }
}

export default MovieSearchForm;
