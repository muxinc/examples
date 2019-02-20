import * as React from 'react';
import './SkeletonLoader.scss';

const SkeletonLoader = (props) => (
  <div className="SkeletonLoaderContainer">
    { props.loading ? (<div className="SkeletonLoader" />) : props.children }
  </div>
);

export default SkeletonLoader;
