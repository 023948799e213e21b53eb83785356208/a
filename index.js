const ssh2 = require('ssh2');

const users = {
  'admin': '1234'
};

const server = new ssh2.Server({
  hostKeys: [require('fs').readFileSync('/etc/ssh/ssh_host_rsa_key')]
}, client => {
  console.log('Client connected!'); // This message will appear when a client successfully connects
  client.on('authentication', ctx => {
    if (ctx.method === 'password' && users[ctx.username] === ctx.password) {
      ctx.accept();
    } else {
      ctx.reject();
    }
  }).on('ready', () => {
    client.on('session', accept => {
      const session = accept();
      session.once('exec', (accept, reject, info) => {
        const stream = accept();
        if (info.command === 'echo test vpn') {
          stream.write('test vpn\n');
        }
        stream.exit(0);
        stream.end();
      });
    });
  });
});

server.listen(22, '0.0.0.0', () => console.log('Listening on port 22'));
