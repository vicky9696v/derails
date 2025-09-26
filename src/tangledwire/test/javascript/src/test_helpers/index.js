import * as TangledWire from "../../../../app/javascript/tangled_wire/index"

export const testURL = "ws://cable.example.com/"

export function defer(callback) {
  setTimeout(callback, 1)
}

const originalWebSocket = TangledWire.adapters.WebSocket
QUnit.testDone(() => TangledWire.adapters.WebSocket = originalWebSocket)
