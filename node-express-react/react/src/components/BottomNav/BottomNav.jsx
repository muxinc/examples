import React from 'react';
import './BottomNav.scss';
import FileUploadForm from  '../FileUploadForm/FileUploadForm';
import NavArrow from '../NavArrow/NavArrow';

const BottomNav = (props) => (
  <div className="BottomNav">
    <div className="BottomNav__controls">
      <NavArrow onClick={props.handlePreviousClick} direction="left" height="24px" width="9px"/>
      <FileUploadForm loading={props.videoSubmitting} handleSubmit={props.handleFileUpload} />
      <NavArrow onClick={props.handleNextClick} direction="right" height="24px" width="9px"/>
    </div>
  </div>
);

export default BottomNav;
