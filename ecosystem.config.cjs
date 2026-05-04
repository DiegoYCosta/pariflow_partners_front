module.exports = {
  apps: [
    {
      name: 'pariflow-front',
      script: 'serve',
      args: '-s build/web -l 127.0.0.1:3000',
      cwd: __dirname,
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production'
      }
    }
  ]
};
