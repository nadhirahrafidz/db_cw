import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import { useState } from "react";

function MovieSearchForm(props) {
  const [search, setSearch] = useState("");

  function handleSubmit(e) {
    e.preventDefault();
    props.onSubmit(search);
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
        </Form.Group>
        <Button variant="primary" type="submit">
          Submit
        </Button>
      </Form>
    </div>
  );
}

export default MovieSearchForm;
