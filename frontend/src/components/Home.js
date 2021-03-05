import React, { Component } from "react";
import Title from "./Title";

import Carousel from "react-bootstrap/Carousel";
import toy from "../resources/toy story.png";
import aven from "../resources/avengers.png";
import pc from "../resources/pc.png";

//homepage

class Home extends React.Component {
  render() {
    return (
      <div>
        <Title text="Home changed"></Title>
        <div className="Body">
          <div className="introduction">
            <Carousel>
              <Carousel.Item className="carousel-item" id="software-skills">
                <img className="image" src={toy} alt="First slide" />
                <Carousel.Caption className="text-carousel"></Carousel.Caption>
              </Carousel.Item>
              <Carousel.Item className="carousel-item" id="languages-skills">
                <img className="image" src={aven} alt="First slide" />
                <Carousel.Caption className="text-carousel"></Carousel.Caption>
              </Carousel.Item>
              <Carousel.Item className="carousel-item" id="languages-skills">
                <img className="image" src={pc} alt="First slide" />
                <Carousel.Caption className="text-carousel"></Carousel.Caption>
              </Carousel.Item>
            </Carousel>
          </div>
        </div>
      </div>
    );
  }
}

export default Home;
