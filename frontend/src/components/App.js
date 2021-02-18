import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import "../styles/App.css";
import Navbar from "react-bootstrap/Navbar";
import Nav from "react-bootstrap/Nav";
import { LinkContainer } from 'react-router-bootstrap'
import NavItem from "react-bootstrap/esm/NavItem";

//components
import Browse from "./Browse/Browse"
import Popular from "./Popular/Popular"
import Home from "./Home"
import Released from "./Released/Released"
import Polarising from "./Polarising/Polarising"
import Footer from "./Footer";


function App() {
  return (
    <Router>
      <Navbar className="main-navbar" bg="light" expand="lg">
          <Navbar.Brand>Group 11</Navbar.Brand>
          <Navbar.Toggle aria-controls="basic-navbar-nav" />
          <Navbar.Collapse id="basic-navbar-nav">
            <Nav className="mr-auto">
              <LinkContainer className="nav-link-text" to="/">
                <NavItem>Home</NavItem>
              </LinkContainer>
              <LinkContainer className="nav-link-text" to="/browse">
                <NavItem>View movies</NavItem>
              </LinkContainer>
              <LinkContainer className="nav-link-text" to="/popular">
                <NavItem>Popular Now</NavItem>
              </LinkContainer>
              <LinkContainer className="nav-link-text" to="/released">
                <NavItem>Released soon</NavItem>
              </LinkContainer>
              <LinkContainer className="nav-link-text" to="/polarising">
                <NavItem>Polarising films</NavItem>
              </LinkContainer>
            </Nav>
          </Navbar.Collapse>
        </Navbar>

      <Switch className="main-content"> 
        <Route path="/popular" component={Popular} />
        <Route path="/released" component={Released} />
        <Route path="/polarising" component={Polarising} />
        <Route path="/browse" component={Browse} />
        <Route path="" component={Home} />
      </Switch>

      <Footer className="footer"></Footer>
    </Router>
  );
}

export default App;
