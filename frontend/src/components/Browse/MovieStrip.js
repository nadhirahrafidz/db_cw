import React, { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import "./MovieStrip.css";
import Button from "react-bootstrap/Button";

function MovieStrip(props) {
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
        "Content-Type": "application/json",
        
      }
    })
      .then(response => 
        response.json()
      )
      .then(data => {
        //set a local indicator variable to true
        //set a local variable to the state returned
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
        console.log(url)
        console.log("data here:")
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
      <div>
        <p>{data.genres_string}</p>
        <p>{data.tags_string}</p>
        <p>{data.pCountMostLikely}</p>
        <p>{data.pCountLikely}</p>
        <p>{data.pCountLeastLikely}</p>
        <p>{data.pCountUsuallyHigh}</p>
        <p>{data.pCountUsuallyLow}</p>
        <p>{data.pTagsMostLikely}</p>
        <p>{data.pTagsLeastLikely}</p>
      </div>
    );
  } else {
    additionalDisplay = <div></div>;
  }

  function dummysubmit() {
    setShow(true);
    setData({
      genres_string: "genres_string",
      tags_string: "tags_string",
      pCountMostLikely: "pCountMostLikely",
      pCountLikely: "pCountLikely",
      pCountLeastLikely: "pCountLeastLikely",
      pCountUsuallyHigh: "pCountUsuallyHigh",
      pCountUsuallyLow: "pCountUsuallyLow",
      pTagsMostLikely: "pTagsMostLikely",
      pTagsLeastLikely: "pTagsLeastLikely"
    });
  }

  return (
    <div className="moviestrip">
      <img
        className="stripimage"
        src={props.movie.movieURL}
        style={{ cursor: "pointer" }}
        onClick={() => routeToMovie(props.movie.movie_id)}
      />

      <div className="details" style={{ paddingLeft: "5px" }}>
        <h2
          onClick={() => routeToMovie(props.movie.movie_id)}
          style={{
            color: "blue",
            cursor: "pointer",
            textDecoration: "underline"
          }}
        >
          {props.movie.title}
        </h2>
        <br />
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
        <br />
        <div>{stars}</div>
        <br />
        <div>
          {props.movie.rating +
            " " +
            ratings_stars(props.movie.rating) +
            " (" +
            props.movie.no_of_ratings +
            " ratings)"}
        </div>
        <br />
        {getTags(props.movie.tags)}

        <Button onClick={handleSubmit}>Audience Segmentation</Button>
        {additionalDisplay}
      </div>
    </div>
  );
}

export default MovieStrip;
