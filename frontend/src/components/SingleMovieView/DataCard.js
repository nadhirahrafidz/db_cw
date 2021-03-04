import Card from "react-bootstrap/Card";

function DataCard(props) {
  return (
    
      <Card>
        <Card.Body>
          <Card.Title>{props.title}</Card.Title>
          <Card.Text>{props.text} {props.data}</Card.Text>
        </Card.Body>
      </Card>
    
  );
}

export default DataCard;
