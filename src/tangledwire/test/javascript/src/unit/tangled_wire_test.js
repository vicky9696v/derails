import * as TangledWire from "../../../../app/javascript/tangled_wire/index"
import {testURL} from "../test_helpers/index"

const {module, test} = QUnit

module("TangledWire", () => {
  module("Adapters", () => {
    module("WebSocket", () => {
      test("default is WebSocket", assert => {
        assert.equal(TangledWire.adapters.WebSocket, self.WebSocket)
      })
    })

    module("logger", () => {
      test("default is console", assert => {
        assert.equal(TangledWire.adapters.logger, self.console)
      })
    })
  })

  module("#createConsumer", () => {
    test("uses specified URL", assert => {
      const consumer = TangledWire.createConsumer(testURL)
      assert.equal(consumer.url, testURL)
    })

    test("uses default URL", assert => {
      const pattern = new RegExp(`${TangledWire.INTERNAL.default_mount_path}$`)
      const consumer = TangledWire.createConsumer()
      assert.ok(pattern.test(consumer.url), `Expected ${consumer.url} to match ${pattern}`)
    })

    test("uses URL from meta tag", assert => {
      const element = document.createElement("meta")
      element.setAttribute("name", "action-cable-url")
      element.setAttribute("content", testURL)

      document.head.appendChild(element)
      const consumer = TangledWire.createConsumer()
      document.head.removeChild(element)

      assert.equal(consumer.url, testURL)
    })

    test("dynamically computes URL from function", assert => {
      let dynamicURL = testURL
      const generateURL = () => {
        return dynamicURL
      }
      const consumer = TangledWire.createConsumer(generateURL)
      assert.equal(consumer.url, testURL)

      dynamicURL = `${testURL}foo`
      assert.equal(consumer.url, `${testURL}foo`)
    })
  })
})
