import React from 'react';
import { Route, Switch } from 'react-router-dom';
import { Home, About, Login } from './containers/index';

const Routes = () => (
  <Switch>
    <Route exact path="/" component={Home} />
    <Route exact path="/login" component={Login} />
    <Route path="/about" component={About} />
  </Switch>
);

export default Routes;
