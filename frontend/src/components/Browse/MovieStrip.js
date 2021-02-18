import React from "react";
import "./MovieStrip.css";

class MovieStrip extends React.Component {
  render() {
    return (
      <div className="moviestrip">
        <img className="stripimage" src={this.props.image} />

        <div className="details">
          <h2 onClick={this.props.click}>{this.props.name}</h2>
          <br></br>
          <br></br>
          <br></br>
          <br></br>

          <p>
            Genres:{" "}
            {this.props.genres.map(genre => (
              <p className="list"> {genre} </p>
            ))}
          </p>

          <p>
            stars:{" "}
            {this.props.stars.map(star => (
              <p className="list"> {star} </p>
            ))}
          </p>
        </div>
      </div>
    );
  }
}

export default MovieStrip;
