import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Badge from "react-bootstrap/Badge";
import { useState, useEffect } from "react";
import GenreSelector from "./GenreSelector";
import { useLocation } from "react-router-dom";

function MovieSearchForm(props) {
  const [search, setSearch] = useState("");
  const [labels, setLabels] = useState();
  const [genresSelected, setGenresSelected] = useState([]);
  const [moreFilters, setMoreFilters] = useState(false);
  let location = useLocation();

  function handleCheck(e) {
    const indexOfChange = e.target.getAttribute("data-index");
    setGenresSelected(
      genresSelected.map((selected, index) =>
        index == indexOfChange ? e.target.checked : selected
      )
    );
  }

  function handleSubmit(e) {
    e.preventDefault();
    const genres = labels.filter((_, index) => genresSelected[index]);
    props.onSubmit(search, genres);
  }

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    setMoreFilters(urlParams.get("genres") !== null);
  }, [location]);

  useEffect(() => {
    getData();
  }, []);

  useEffect(() => {
    if (genresSelected.length > 0) {
      var a = genresSelected.map((selected, index) =>
        props.genres.includes(labels[index])
      );
      setGenresSelected(a);
    }
  }, [props.genres]);

  function getData() {
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
        setGenresSelected(new Array(data.length).fill(false));
      })
      .catch((err) => {
        console.log(err);
      });
  }

  function toggleMoreFilters(isOn) {
    if (!isOn) {
      setGenresSelected(new Array(labels.length).fill(false));
    }
    setMoreFilters(isOn);
  }

  if (genresSelected.length > 0) {
    return (
      <div className="search">
        <Form onSubmit={handleSubmit}>
          <Form.Group controlId="formBasicSearch">
            <Form.Label>Search for a movie</Form.Label>
            <Form.Control
              placeholder="Enter Search"
              onChange={(e) => setSearch(e.target.value)}
            />
            <Badge
              pill
              variant={moreFilters ? "danger" : "success"}
              onClick={() => toggleMoreFilters(!moreFilters)}
            >
              {moreFilters ? "Less Filters -" : "More Filters +"}
            </Badge>
            <div style={moreFilters ? {} : { display: "None" }}>
              <GenreSelector
                labels={labels}
                handleCheck={handleCheck}
                genresSelected={genresSelected}
              />
            </div>
          </Form.Group>
          <div style={{ textAlign: "right" }}>
            <Button variant="primary" type="submit">
              Submit
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
