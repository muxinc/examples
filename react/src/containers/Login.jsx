import React from 'react';
import { default as LoginPage } from '../components/Login/Login';
import { hasPersistedSession } from "../utils/auth";
import { API_URL } from '../utils/base_api';

class Login extends React.Component {

  constructor(props) {
    super(props);
  }

  componentDidMount () {
    this.authenticateUser();
  }

  authenticateUser = () => {
    if (hasPersistedSession()) {
      this.props.history.push('/');
    }
  };

  handleGoogleSignIn = () => {
    window.location = `${API_URL}/login`;
  };

  render() {
    return (<LoginPage onLogin={this.handleGoogleSignIn} />)
  }
}

export default Login;
