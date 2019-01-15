export default ({ children }) => (
  <div>
    {children}

    <style jsx global>{`
      body {
        background: #000;
        font: 11px menlo;
        color: #fff;
      }
    `}</style>
  </div>
);
