import React from 'react';
import './AssetDetails.scss';

const AssetDetails = (props) => {
  const date = new Date(props.asset.created_at * 1000);
  const formattedCreatedAt = date.toLocaleDateString();
  return (
    <div className="AssetDetails">
      <div className="AssetDetails__row">
        <div className="AssetDetails__title">Asset ID:</div>
        <div className="AssetDetails__value">{props.asset.asset_id}</div>
      </div>
      <div className="AssetDetails__row">
        <div className="AssetDetails__title">Playback ID:</div>
        <div className="AssetDetails__value">{props.asset.playback_ids[0].id}</div>
      </div>
      <div className="AssetDetails__row">
        <div className="AssetDetails__title">Created:</div>
        <div className="AssetDetails__value">{formattedCreatedAt}</div>
      </div>
      <div className="AssetDetails__row">
        <div className="AssetDetails__title">Duration:</div>
        <div className="AssetDetails__value">{props.asset.duration ? `${props.asset.duration}s` : ''}</div>
      </div>
    </div>
  )
};

export default AssetDetails;
