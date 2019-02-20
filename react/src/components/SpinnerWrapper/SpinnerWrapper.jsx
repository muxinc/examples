import React from 'react';
import './SpinnerWrapper.scss'

const SpinnerWrapper = (props) => (
  <div className="SpinnerWrapper">
    {props.loading ? <div className="loader" /> : props.children}
  </div>
);

export default SpinnerWrapper;
