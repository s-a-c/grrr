export function connect_timeline(path, onStatus, onMessage) {
  function open() {
    const proto = window.location.protocol === "https:" ? "wss:" : "ws:";
    const ws = new WebSocket(`${proto}//${window.location.host}${path}`);
    ws.addEventListener("open", () => onStatus(true));
    ws.addEventListener("message", (event) => {
      if (typeof event.data === "string") onMessage(event.data);
    });
    ws.addEventListener("close", () => {
      onStatus(false);
      window.setTimeout(open, 2000);
    });
    ws.addEventListener("error", () => ws.close());
  }
  open();
}
