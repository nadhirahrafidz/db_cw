import Form from "react-bootstrap/Form";

function GenreSelector(props) {
  if (!props.labels) {
    return <div />;
  } else {
    return (
      <Form.Group>
        {props.labels.map((input, index) => (
          <Form.Check
            // checked={props.enabled[index] && status[index]}
            // disabled={!props.enabled[index]}
            data-index={index}
            key={input}
            label={input}
            type="checkbox"
            onChange={(e) => props.handleCheck(e)}
            style={{ marginLeft: "20px" }}
          />
        ))}
      </Form.Group>
    );
  }
}

export default GenreSelector;
