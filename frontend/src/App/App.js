import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";

//components
import Browse from "../pages/Browse";
import Movie from "../pages/Movie";

function App() {
  return (
    <Router>
      <Switch className="main-content">
        <Route path="/browse" component={Browse} />
        <Route path="/movie/:id" component={Movie} />
        <Route path="" component={Browse} />
      </Switch>
    </Router>
  );
}

export default App;
