import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import { useState, useEffect } from "react";
import GenreSelector from "./GenreSelector";

function MovieSearchForm(props) {
  const [search, setSearch] = useState("");
  const [labels, setLabels] = useState();
  const [genresSelected, setGenresSelected] = useState();

  function handleCheck(e) {
    genresSelected[e.target.getAttribute("data-index")] = e.target.checked;
  }

  function handleSubmit(e) {
    e.preventDefault();
    const genres = labels.filter((label, index) => genresSelected[index]);
    props.onSubmit(search, genres);
  }

  useEffect(() => {
    getData();
  }, []);

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

  return (
    <div className="search">
      <Form onSubmit={handleSubmit}>
        <Form.Group controlId="formBasicSearch">
          <Form.Label>Search for a movie</Form.Label>
          <Form.Control
            placeholder="Enter Search"
            onChange={(e) => setSearch(e.target.value)}
          />
          <GenreSelector labels={labels} handleCheck={handleCheck} />
        </Form.Group>
        <Button variant="primary" type="submit">
          Submit
        </Button>
      </Form>
    </div>
  );
}

export default MovieSearchForm;
