import Button from "react-bootstrap/esm/Button";
import Form from "react-bootstrap/Form";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import "./Use6Form.css";

function Use6Form(props) {
  function handleSubmit(e) {
    e.preventDefault();
    const movieID = e.target.movieID.value;
    props.handleSubmit(movieID);
  }

  return (
    <Form className="use6-form" onSubmit={handleSubmit}>
      <Row className="justify-content-center">
        <Form.Label column xs="auto">
          Movie ID
        </Form.Label>
        <Col xs={3}>
          <Form.Control
            required
            type="number"
            name="movieID"
            placeholder="MovieID"
          />
        </Col>
      </Row>
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
