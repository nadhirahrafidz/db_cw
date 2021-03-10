import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";

//components
import Browse from "../pages/Browse";
import Popular from "../pages/Popular";
import Polarising from "../pages/Polarising";
import Movie from "../pages/Movie";

function App() {
  return (
    <Router>
      <Switch className="main-content">
        <Route path="/browse" component={Browse} />
        <Route path="/popular" component={Popular} />
        <Route path="/polarising" component={Polarising} />
        <Route path="/movie/:id" component={Movie} />
        <Route path="" component={Browse} />
      </Switch>
    </Router>
  );
}

export default App;
