const http = require('http');

const PORT = process.env.PORT || 3000;

let todos = [];
let nextId = 1;

function sendJson(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', chunk => { data += chunk; });
    req.on('end', () => {
      try {
        resolve(data ? JSON.parse(data) : {});
      } catch (e) {
        reject(e);
      }
    });
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const path = url.pathname;
  const method = req.method;

  if (path === '/' && method === 'GET') {
    sendJson(res, 200, { app: 'kiro-plan-mode-demo', status: 'running', todoCount: todos.length });
    return;
  }

  if (path === '/api/todos' && method === 'GET') {
    sendJson(res, 200, { todos });
    return;
  }

  if (path === '/api/todos' && method === 'POST') {
    try {
      const body = await parseBody(req);
      if (!body.title || typeof body.title !== 'string') {
        sendJson(res, 400, { error: 'title is required and must be a string' });
        return;
      }
      const todo = { id: nextId++, title: body.title, done: false };
      todos.push(todo);
      sendJson(res, 201, { todo });
    } catch (e) {
      sendJson(res, 400, { error: 'invalid JSON body' });
    }
    return;
  }

  if (path.startsWith('/api/todos/') && method === 'PATCH') {
    const id = parseInt(path.split('/')[3], 10);
    const todo = todos.find(t => t.id === id);
    if (!todo) {
      sendJson(res, 404, { error: 'todo not found' });
      return;
    }
    try {
      const body = await parseBody(req);
      if (typeof body.done === 'boolean') todo.done = body.done;
      if (typeof body.title === 'string') todo.title = body.title;
      sendJson(res, 200, { todo });
    } catch (e) {
      sendJson(res, 400, { error: 'invalid JSON body' });
    }
    return;
  }

  if (path.startsWith('/api/todos/') && method === 'DELETE') {
    const id = parseInt(path.split('/')[3], 10);
    const idx = todos.findIndex(t => t.id === id);
    if (idx === -1) {
      sendJson(res, 404, { error: 'todo not found' });
      return;
    }
    const [deleted] = todos.splice(idx, 1);
    sendJson(res, 200, { deleted });
    return;
  }

  if (path === '/api/login' && method === 'POST') {
    try {
      const body = await parseBody(req);
      if (!body.username || !body.password) {
        sendJson(res, 400, { error: 'username and password are required' });
        return;
      }
      if (body.password.length < 6) {
        sendJson(res, 400, { error: 'password must be at least 6 characters' });
        return;
      }
      const token = Buffer.from(`${body.username}:${Date.now()}`).toString('base64');
      sendJson(res, 200, { token, user: body.username });
    } catch (e) {
      sendJson(res, 400, { error: 'invalid JSON body' });
    }
    return;
  }

  sendJson(res, 404, { error: 'route not found' });
});

server.listen(PORT, () => {
  console.log(`Demo app running on http://localhost:${PORT}`);
});
