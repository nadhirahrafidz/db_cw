import Button from "react-bootstrap/esm/Button";
import Form from "react-bootstrap/Form";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import "./Use6Form.css";

const movieIDs = [1, 2, 3];

function Use6Form(props) {
  function handleSubmit(e) {
    e.preventDefault();
    const movie1ID = e.target.movie1ID.value;
    const movie2ID = e.target.movie2ID.value;
    const movie3ID = e.target.movie3ID.value;
    var ids = [movie1ID, movie2ID, movie3ID];
    ids = ids.filter((item) => item);
    props.handleSubmit(ids);
  }

  return (
    <Form className="use6-form" onSubmit={handleSubmit}>
      {movieIDs.map((item, index) => (
        <Row className="justify-content-center" key={index}>
          <Form.Label column xs="auto">
            {"Movie " + item + " ID"}
          </Form.Label>
          <Col xs={3}>
            <Form.Control
              required={index === 0}
              type="number"
              name={"movie" + item + "ID"}
            />
          </Col>
        </Row>
      ))}

      <Row className="justify-content-center">
        <Button
          disabled={props.loading}
          className="use6-submit-button"
          type="submit"
        >
          Submit
        </Button>
      </Row>
    </Form>
  );
}

export default Use6Form;
