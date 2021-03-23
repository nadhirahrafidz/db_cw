import "./Use5Form.css";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
function Use5Form(props) {
  function handleSubmit(e) {
    e.preventDefault();
    const movieID = e.target.movieID.value;
    const panelSize = e.target.panelSize.value;
    const runs = e.target.runs.value;

    props.handleSubmit(movieID, panelSize, runs);
  }

  return (
    <Form className="use5-form" onSubmit={handleSubmit}>
      <Form.Row>
        <Form.Label column xs={4}>
          Movie ID
        </Form.Label>
        <Col>
          <Form.Control
            required
            type="number"
            name="movieID"
            placeholder="MovieID"
          />
        </Col>
      </Form.Row>
      <Form.Row>
        <Form.Label column xs={4}>
          Panel Size
        </Form.Label>
        <Col>
          <Form.Control
            required
            type="number"
            name="panelSize"
            placeholder="Panel Size"
          />
        </Col>
      </Form.Row>
      <Form.Row>
        <Form.Label column xs={4}>
          Number of Runs
        </Form.Label>
        <Col>
          <Form.Control type="number" name="runs" placeholder="NumberOfRuns" />
        </Col>
      </Form.Row>
      <Button
        disabled={props.loading}
        type="submit"
        className="use5-submit-button"
      >
        Submit
      </Button>
    </Form>
  );
}

export default Use5Form;
