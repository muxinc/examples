import React from 'react';
import './NavBar.scss';
import { logoutUser } from '../../actions/auth';

import Logo from '../../components/Logo/Logo';

const LoginContainer = (props) => {
  return (
    <div className="NavBar__LoginContainer">
      <button
        className="NavBar__googleLoginButton"
        onClick={props.onLogout}>
        <img className="NavBar__profileImage" height="35px" src={props.profileImg} />
      </button>
    </div>
  )
};

const handleLogout = (props) => {
  return logoutUser().then(() => {
    props.history.push('/login');
  });
};

const NavBar = (props) => {
  const isLoggedIn = !!props.user;
  let photo = '';
  if (isLoggedIn) {
    photo = props.user.photos[0].value;
  }
  const logout = () => handleLogout(props);
  return (
    <div className="NavBar">
      <div className="NavBar__logoContainer">
        <Logo height="19px" />
      </div>
      <LoginContainer
        isLoggedIn={isLoggedIn}
        onLogout={logout}
        profileImg={photo}
      />
    </div>
  )
};

NavBar.defaultProps = {};

export default NavBar;
