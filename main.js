const { app, BrowserWindow } = require("electron");
const { exec, spawn } = require("child_process");
const AWS = require("aws-sdk");
const express = require("express");
const WebSocket = require("ws");

class Api {
  constructor() {
    this.server = server;
    this.wss = wss;
    this.server.post("/api/endpoint", (req, res) => {
      req.on("data", (data) => {
        const body = JSON.parse(data);
        console.log(body);
      });

      this.runBashCommand();
      res.send({ message: "Success!" });
    });
    this.wss.on("connection", function connection(ws) {
      console.log("connected");
    });
  }

  runBashCommand() {
    const bashScript = spawn("sh", ["boot.sh"]);

    bashScript.stdout.on("data", (data) => {
      this.wss.clients.forEach((client) => {
        client.send(`stdout: ${data}`);
        console.log(`stdout: ${data}`);
      });
      console.log(` ${data}`);
    });

    bashScript.stderr.on("data", (data) => {
      console.error(`stderr: ${data}`);
    });

    bashScript.on("close", (code) => {
      console.log(`child process exited with code ${code}`);
    });
  }

  start() {
    this.server.listen(3000, () => {
      console.log("API server listening on port 3000");
    });
  }
}

const wss = new WebSocket.Server({ port: 8765 });
const server = express();
const api = new Api(server, wss);
const createWindow = () => {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
  });
  win.loadFile("index.html");
};

api.start();

app.whenReady().then(() => {
  createWindow();
});
