import Form from "react-bootstrap/Form";
import "./GenreSelector.css";

function GenreSelector(props) {
  if (!props.labels) {
    return <div />;
  } else {
    return (
      <div className="genre-options">
        <span>Genres:</span>
        <Form.Group>
          {props.labels.map((input, index) => (
            <Form.Check
              data-index={index}
              key={input}
              checked={props.genresSelected[index]}
              label={input}
              type="checkbox"
              onChange={(e) => props.handleCheck(e)}
              style={{ flexBasis: "130px" }}
            />
          ))}
        </Form.Group>
      </div>
    );
  }
}

export default GenreSelector;
