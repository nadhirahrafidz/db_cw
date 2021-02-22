import Form from "react-bootstrap/Form";

function GenreSelector(props) {
  if (!props.labels) {
    return <div />;
  } else {
    return (
      <>
        Genres:
        <Form.Group>
          <div
            style={{
              display: "flex",
              flexWrap: "wrap",
              justifyContent: "flex-start",
            }}
          >
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
          </div>
        </Form.Group>
      </>
    );
  }
}

export default GenreSelector;
