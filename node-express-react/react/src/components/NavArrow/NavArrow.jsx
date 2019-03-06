import React from 'react';
import './NavArrow.scss';
import * as LeftArrow from "../../assets/chevron-left.svg";
import * as RightArrow from "../../assets/chevron-right.svg";

const NavArrow = (props) => (
  <div className="NavArrow" onClick={props.onClick}>
    <div className="NavArrow__wrapper">
      <img className="NavArrow_img" height={props.height} width={props.width} src={props.direction === 'left' ? LeftArrow : RightArrow} />
      <div className="NavArrow__text">{props.direction === 'left' ? 'prev' : 'next'}</div>
    </div>
  </div>
);

export default NavArrow;
