import * as http from 'node:http';

const config = {
  unlockFor: { ms: 5000 } as const,
  httpPort: 4444,
  secretPassword: "wink"
};

type Door = "front" | "back";

type DoorStatus = {
  unlocked?: false | { since: Date }
};

const state = {
  front: {} as DoorStatus,
  back: {} as DoorStatus,
};

function main() {
  const server = http.createServer(handler);

  return server.listen(config.httpPort, 'localhost', () => {
    console.log(`Server running at http://localhost:${config.httpPort}/`);
  });
}

function doorName(n: number): Door | undefined {
  return n === 1 ? "front" : n === 2 ? "back" : undefined;
}

function handler(req: http.IncomingMessage, res: http.ServerResponse) {
  const url = new URL(`http://localhost${req.url}`);
  const params = Object.fromEntries(url.searchParams.entries())

  const privateMode = {
    enabled: params.e === config.secretPassword
  }

  const request = parseRequest(params)

  let message: string;

  if (!privateMode) {
    message = "unauthorized";
  } else {
    switch(request.type) {
      case "lockDoor":
        if (request.door === "all") {
          state.front.unlocked = false;
          state.back.unlocked = false;
        } else {
          state[request.door].unlocked = false;
        }
        message = "locked"
        break;
      case "unlockDoor":
        if (request.door) {
          const door = state[request.door];
          door.unlocked = { since: new Date() }
          setTimeout(() => {
            door.unlocked = false;
          }, config.unlockFor.ms)
          message = "unlocked"
        } else {
          message = "invalid door number"
        }
        break;
      default:
        message = "not implemented"
    }
  }

  res.writeHead(200);
  res.end(`<pre>Request: ${JSON.stringify({
    params,
    request,
    privateMode,
    state,
    message
  }, undefined, 2)}</pre>`)
}

function parseRequest(params: Record<string, string | undefined>) {
  return params.s ? {
    type: "showUsers",
    userId: parseInt(params.s)
  } as const : params.m ? {
    type: "modifyUser",
    userId: parseInt(params.m),
    permissions: params.p ? { mask: parseInt(params.p) } : undefined,
    tag: params.t
  } as const : params.a ? {
    type: "listUsers"
  } as const : params.r ? {
    type: "removeUser",
    userId: parseInt(params.r)
  } as const : params.o ? {
    type: "openDoor",
    door: doorName(parseInt(params.o))
  } as const : params.u ? {
    type: "unlockDoor",
    door: doorName(parseInt(params.u))
  } as const : params.l ? {
    type: "lockDoor",
    door: doorName(parseInt(params.l)) ?? "all",
  } as const : {
    type:
      params["1"] ? "disam" as const
        : params["2"] ? "arm" as const
        : params["3"] ? "train" as const
        : params.z ? "printLog" as const
        : params.y ? "clearLog" as const
        : params.w ? "printDate" as const
        : params.x ? "setDate" as const
        : params.v ? "setLogVerbosity" as const
        : params["9"] ? "printStatus" as const
        : "unknown" as const,
    fullyParsed: false
  } as const;
}

main()
