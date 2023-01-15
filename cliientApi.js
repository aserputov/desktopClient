const ws = new window.WebSocket("ws://localhost:8765");
const button = document.getElementById("my-button");
button.addEventListener("click", (event) => {
  console.log("Button was clicked!");
  const options = { method: "POST" };
  fetch("http://localhost:3000/api/endpoint", options)
    .then((response) => response.json())
    .then((result) => {
      console.log(result);
    })
    .catch((error) => {
      console.error(error);
    });
});

ws.onopen = function open() {
  ws.send("Hello, server!");
};

ws.onmessage = function incoming(event) {
  console.log(`Received message from server: ${event.data}`);
  const p = document.createElement("p");
  document.body.appendChild(p);
  p.innerHTML = `<strong>${event.data}</strong>`;
};
