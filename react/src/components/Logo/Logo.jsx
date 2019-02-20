import React from 'react';
import './Logo.scss';
import * as logo from '../../assets/mux-logo-email@2x.png';

const Logo = (props) => (
  <div>
    <img className="Logo__img" height={props.height} width={props.width} src={logo} />
  </div>
);

export default Logo;
