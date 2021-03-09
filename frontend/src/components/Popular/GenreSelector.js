import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import "./GenreSelector.css";
import { useState } from "react";

function GenreSelector(props) {
  const [selected, setSelected] = useState("");

  function handleClick(newSelected) {
    setSelected(newSelected);
    props.setGenre(newSelected);
  }

  if (!props.labels) {
    return <div />;
  } else {
    return (
      <div>
        <span>Genres:</span>
        <Form.Group className="genre-button-group">
          {props.labels.map((input) => (
            <div className="genre-button" key={input}>
              <Button
                onClick={() => handleClick(input)}
                variant={(selected === input ? "" : "outline-") + "primary"}
              >
                {input}
              </Button>
            </div>
          ))}
          <div className="clear-genre-button">
            <Button onClick={() => handleClick("")}>Clear</Button>
          </div>
        </Form.Group>
      </div>
    );
  }
}

export default GenreSelector;
