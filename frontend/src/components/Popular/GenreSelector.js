import Button from "react-bootstrap/Button";
import "./GenreSelector.css";
import { useState } from "react";

function GenreSelector(props) {
  const [selected, setSelected] = useState();

  function handleClick(newSelected) {
    setSelected(newSelected);
    props.setGenre(newSelected);
  }

  if (!props.labels) {
    return <div />;
  } else {
    return (
      <div className="genre-button-group">
        {props.labels.map((input) => (
          <div className="genre-button" key={input}>
            <Button
              disabled={props.loading}
              onClick={() => handleClick(input[1])}
              variant={(selected === input[1] ? "" : "outline-") + "primary"}
            >
              {input[0]}
            </Button>
          </div>
        ))}
        <div className="clear-genre-button">
          <Button onClick={() => handleClick(0)}>Clear</Button>
        </div>
      </div>
    );
  }
}

export default GenreSelector;
