const e = (elem, children) => {
  const node = document.createElement(elem);

  if (typeof children === 'string')
    node.innerText = children;
  else
    children.forEach(child => node.appendChild(child));

  return node;
};

return e('article', [
  e('h1', 'JavaScript'),
  e('p', 'JavaScript is supported natively in the browser but is not currently pre-rendered on the server.'),
]);
