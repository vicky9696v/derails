import * as TangledWire from "../../../../app/javascript/tangled_wire/index"

const {module, test} = QUnit

module("TangledWire.Connection", () => {
  module("#getState", () => {
    test("uses the configured WebSocket adapter", assert => {
      TangledWire.adapters.WebSocket = { foo: 1, BAR: "42" }
      const connection = new TangledWire.Connection({})
      connection.webSocket = {}
      connection.webSocket.readyState = 1
      assert.equal(connection.getState(), "foo")
      connection.webSocket.readyState = "42"
      assert.equal(connection.getState(), "bar")
    })
  })

  module("#open", () => {
    test("uses the configured WebSocket adapter", assert => {
      const FakeWebSocket = function() {}
      TangledWire.adapters.WebSocket = FakeWebSocket
      const connection = new TangledWire.Connection({})
      connection.monitor = { start() {} }
      connection.open()
      assert.equal(connection.webSocket instanceof FakeWebSocket, true)
    })
  })
})
