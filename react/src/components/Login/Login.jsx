import React from 'react';
import Logo from '../Logo/Logo';
import './Login.scss';
import googleLogo from '../../assets/btn_google_dark_normal_ios.svg';

const Login = (props) => (
  <div className="Login">
    <div className="Login__container">
      <div className="Login__textContainer">
        <div className="Login__googleLoginText">Welcome to the Mux Video demo app!</div>
      </div>
      <button
        className="Login__googleLoginButton"
        onClick={props.onLogin}>
        <img height="30px" src={googleLogo} />
        <div className="Login__googleLoginButtonText">Sign in with Google</div>
      </button>
      <Logo height="32px" width="94px" />
    </div>
  </div>
);

export default Login;
