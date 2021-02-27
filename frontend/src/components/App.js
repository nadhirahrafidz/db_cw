import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import "../styles/App.css";

//components
import Browse from "./Browse/Browse";
import Popular from "./Popular/Popular";
import Home from "./Home";
import Released from "./Released/Released";
import Polarising from "./Polarising/Polarising";
import Movie from "./Movie";
import Footer from "./Footer";
import CustomNavbar from "./CustomNavbar";

function App() {
  return (
    <Router>
      <CustomNavbar />

      <Switch className="main-content">
        <Route path="/popular" component={Popular} />
        <Route path="/released" component={Released} />
        <Route path="/polarising" component={Polarising} />
        <Route path="/browse" component={Browse} />
        <Route path="/movie/:id" component={Movie} />
        <Route path="" component={Home} />
      </Switch>

      <Footer className="footer"></Footer>
    </Router>
  );
}

export default App;
