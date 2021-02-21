import Form from "react-bootstrap/Form";
import Row from "react-bootstrap/Row";

function GenreSelector(props) {
  if (!props.labels) {
    return <div />;
  } else {
    return (
      <div>
        Genres:
        <Form.Group as={Row}>
          {props.labels.map((input, index) => (
            <Form.Check
              data-index={index}
              key={input}
              checked={props.genresSelected[index]}
              label={input}
              type="checkbox"
              onChange={(e) => props.handleCheck(e)}
              style={{ marginLeft: "20px" }}
            />
          ))}
        </Form.Group>
      </div>
    );
  }
}

export default GenreSelector;
