export default function Button ({ buttonLink, children, ...otherProps }) {
  return (
    <>
      {buttonLink ? <a {...otherProps}>{children}</a> : <button type="button" {...otherProps}>{children}</button>}
      <style jsx>{`
        a {
          text-docoration: none;
          display: inline-block;
        }
        a, button {
          font-size: 26px;
          line-height: 33px;
          background: #fff;
          border: 2px solid #222222;
          padding: 10px 20px;
          border-radius: 50px;
        }
      `}
      </style>
    </>
  );
}
