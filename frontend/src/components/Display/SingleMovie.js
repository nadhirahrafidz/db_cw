import React from "react";

import SingleMovieData from "../../Data/SingleMovie";
import Title from "../Title";
import "./SingleMovie.css";

class SingleMovie extends React.Component {
  constructor(props) {
    super(props);

    const data = this.getData(props.id);

    this.state = {
      movieDetails: data
    };
  }


  getData(id) {
    //make the api call with the desired id
    return SingleMovieData;
  }

  render() {
    return (
      <div>
        <Title name={this.state.movieDetails.name}></Title>
        <h2>{this.state.movieDetails.name}</h2>
        <div className="leadingimage">
          <img src={this.state.movieDetails.image}></img>
        </div>
        <div className="body">
            <div className="userseg">
                {/* <img src="https://spark.adobe.com/sprout/api/images/978c76de-15ac-4f1f-8a13-55cda19813e0"></img> */}
                <p>{this.state.movieDetails.audienceseg}</p>
            </div>
        </div>
        <div>
            <button onClick={this.props.back}>Back</button>
        </div>
      </div>
    );
  }
}


export default SingleMovie;