import React, { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import Button from "react-bootstrap/Button";
import "./SingleMovieLayout.css";
import CardDeck from "react-bootstrap/CardDeck";
import DataCard from "./DataCard";

function SingleMovieLayout(props) {
  const genres = !props.movie.stars ? [] : props.movie.genres.split(",");
  const stars = !props.movie.stars ? "" : "Stars: " + props.movie.stars;
  const history = useHistory();
  const [show, setShow] = useState(false);
  const [data, setData] = useState(null);

  console.log(props);

  function getTags(tags) {
    if (!tags) {
      return;
    }
    let displayTags =
      props.movie.tags.length > 50
        ? props.movie.tags.substring(0, 50) + "..."
        : props.movie.tags;
    return "Tags: " + displayTags;
  }

  function routeToMovie(movie_id) {
    let path = "/movie/" + movie_id;
    history.push(path);
  }

  function routeToGenre(genre) {
    let path = "/browse?genres=" + genre;
    history.push(path);
  }

  function ratings_stars(rating) {
    var count = 1;
    var rating_star = "";
    while (count < 6) {
      if (rating >= count) {
        rating_star = rating_star + "★";
      } else {
        rating_star = rating_star + "☆";
      }
      count = count + 1;
    }
    return rating_star;
  }

  function genreStrings(){
    
  }

  function handleSubmit() {
    //make the api call here to use case 4
    console.log(props.movie.movie_id);

    //fetch the actual data
    const url =
      "http://localhost/getAudienceSegmentation.php?" +
      new URLSearchParams({ movie_id: props.movie.movie_id });
    fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
    })
      .then(response => response.json())
      .then(data => {
        //set a local indicator variable to true
        //set a local variable to the state returned
        //change the integers to strings
        
        setData({
          genres_string: data[0].genres_string,
          tags_string: data[0].tags_string,
          pCountMostLikely: data[0].pCountMostLikely,
          pCountLikely: data[0].pCountLikely,
          pCountLeastLikely: data[0].pCountLeastLikely,
          pCountUsuallyHigh: data[0].pCountUsuallyHigh,
          pCountUsuallyLow: data[0].pCountUsuallyLow,
          pTagsMostLikely: data[0].pTagsMostLikely,
          pTagsLeastLikely: data[0].pTagsLeastLikely
        });
        setShow(true);
        console.log(url);
        console.log("data here:");
        console.log(data);
      })
      .catch(err => {
        console.log(url);
        console.log(err);
      });
  }

  let additionalDisplay;
  if (show) {
    additionalDisplay = (
      <div className="decks">
        <CardDeck className="deck">
          <DataCard
            title="Similar genres"
            text="People who viewed this are also interested in the following genres"
            data={data.genres_string}
          ></DataCard>
          <DataCard
            title="pCountMostLikely"
            text="Whatever the pcount most likey is has the value "
            data={data.pCountMostLikely}
          ></DataCard>
          <DataCard
            title="pCountLikely"
            text="Whatever the pcount likey is has the value "
            data={data.pCountLikely}
          ></DataCard>
        </CardDeck>

        <CardDeck className="deck">
          <DataCard
            title="pCountLeastLikely"
            text="Whatever the pCountLeastLikely is has the value "
            data={data.pCountLeastLikely}
          ></DataCard>
          <DataCard
            title="pCountUsuallyHigh"
            text="Whatever the pCountUsuallyHigh is has the value "
            data={data.pCountUsuallyHigh}
          ></DataCard>
          <DataCard
            title="pCountUsuallyLow"
            text="Whatever the pCountUsuallyLow is has the value "
            data={data.pCountUsuallyLow}
          ></DataCard>
        </CardDeck>

        <CardDeck className="deck">
          <DataCard
            title="pTagsMostLikely"
            text="Whatever the pTagsMostLikely is has the value "
            data={data.pTagsMostLikely}
          ></DataCard>
          <DataCard
            title="pTagsLeastLikely"
            text="Whatever the pTagsLeastLikely is has the value "
            data={data.pTagsLeastLikely}
          ></DataCard>
          <DataCard
            title="pTagsLeastLikely"
            text="Whatever the pTagsLeastLikely is has the value "
            data={data.pTagsLeastLikely}
          ></DataCard>
        </CardDeck>
      </div>
    );
  } else {
    additionalDisplay = <div></div>;
  }

  return (
    <div className="singlemovielayout">
      <div className="movietitle">
        <h2>{props.movie.title}</h2>
      </div>
      <div className="movieimagediv">
        <img className="movieimage" src={props.movie.movieURL} />
      </div>

      <div className="basicdetails">
        <h3>Overview</h3>
        <div>
          {genres.length > 0 ? "Genres: " : ""}
          {genres.map((genre, index) => (
            <p
              className="list"
              key={index}
              onClick={() => routeToGenre(genre)}
              style={{ cursor: "pointer", color: "blue" }}
            >
              {genre.trim()}
              {index === genres.length - 1 ? "" : ", "}
            </p>
          ))}
        </div>

        <div>{stars}</div>
        <div>
          {props.movie.rating +
            " " +
            ratings_stars(props.movie.rating) +
            " (" +
            props.movie.no_of_ratings +
            " ratings)"}
        </div>
        {getTags(props.movie.tags)}

        <br></br>
        <br></br>
        <br></br>
        <br></br>
        <br></br>
        <br></br>
        <p>possible pie chart later</p>
      </div>

      <div className="extendeddetails">
        <div className="audiencebutton">
          <Button onClick={handleSubmit}>Audience Segmentation</Button>
        </div>

        {additionalDisplay}
      </div>
    </div>
  );
}

export default SingleMovieLayout;
