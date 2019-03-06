import React from 'react';
import './FileUploadForm.scss';
import * as UploadButton from "../../assets/Upload.svg";

const FileUploadForm = (props) => (
  <form className="FileUploadForm">
    <label className="FileUploadForm__label">
      <div><img className="FileUploadForm__uploadButton" src={UploadButton} /></div>
      <input className="FileUploadForm__file" type="file" value="" onChange={props.handleSubmit} />
    </label>
    <div className="FileUploadForm__text">Upload Video</div>
  </form>
);

FileUploadForm.defaultProps = {
  handleSubmit: () => {},
  loading: false,
};

export default FileUploadForm;
