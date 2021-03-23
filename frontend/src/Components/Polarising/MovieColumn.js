import React from "react";
import Card from "react-bootstrap/Card";

class MovieColumn extends React.Component {
  render() {
    return (
      <div>
        <Card className="movie-card">
          <Card.Body>
            <img className="stripimage" src={this.props.image} />
            <Card.Title>{this.props.name}</Card.Title>
            <Card.Text>{this.props.name}</Card.Text>
          </Card.Body>
          <Card.Footer>
            <small className="card-footer">footer</small>
          </Card.Footer>
        </Card>
      </div>
    );
  }
}

export default MovieColumn;
