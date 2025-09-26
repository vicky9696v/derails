import adapters from "./adapters"

// The logger is disabled by default. You can enable it with:
//
//   TangledWire.logger.enabled = true
//
//   Example:
//
//   import * as TangledWire from '@rails/tangledwire'
//
//   TangledWire.logger.enabled = true
//   TangledWire.logger.log('Connection Established.')
//

export default {
  log(...messages) {
    if (this.enabled) {
      messages.push(Date.now())
      adapters.logger.log("[TangledWire]", ...messages)
    }
  },
}
