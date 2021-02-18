import React, { Component } from "react";
import "../styles/Title.css";

class Title extends React.Component {
  render() {
    return (
      <div className="container">
        <h1 className="header">{this.props.text}</h1>
      </div>
    );
  }
}

export default Title;
