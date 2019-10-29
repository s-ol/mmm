// a little helper function for creating DOM elements
const e = (elem, children) => {
  const node = document.createElement(elem);

  if (typeof children === 'string')
    node.innerText = children;
  else
    children.forEach(child => node.appendChild(child));

  return node;
};

/* creating the equivalent of the following HTML directly as DOM content:
 *
 * <article>
 *   <h1>JavaScript</h1>
 *   <p>...</p>
 * </article>
 */

return e('article', [
  e('h1', 'JavaScript'),
  e('p', 'JavaScript is supported natively in the browser but is not currently pre-rendered on the server.'),
]);
