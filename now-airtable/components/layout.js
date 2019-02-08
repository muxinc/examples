export default ({ children }) => (
  <div className="container">
    {children}

    <style jsx global>{`
      body {
        background: #000;
        font: 11px menlo;
        color: #fff;
      }
    `}</style>

    <style jsx>{`
      .container {
        max-width: 720px;
        margin: 0 auto;
      }
    `}</style>
  </div>
);
