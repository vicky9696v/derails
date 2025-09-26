import * as TangledWire from "../../../../app/javascript/tangled_wire/index"

const {module, test} = QUnit

module("TangledWire.SubscriptionGuarantor", hooks => {
  let guarantor
  hooks.beforeEach(() => guarantor = new TangledWire.SubscriptionGuarantor({}))

  module("#guarantee", () => {
    test("guarantees subscription only once", assert => {
      const sub = {}

      assert.equal(guarantor.pendingSubscriptions.length, 0)
      guarantor.guarantee(sub)
      assert.equal(guarantor.pendingSubscriptions.length, 1)
      guarantor.guarantee(sub)
      assert.equal(guarantor.pendingSubscriptions.length, 1)
    })
  }),

  module("#forget", () => {
    test("removes subscription", assert => {
      const sub = {}

      assert.equal(guarantor.pendingSubscriptions.length, 0)
      guarantor.guarantee(sub)
      assert.equal(guarantor.pendingSubscriptions.length, 1)
      guarantor.forget(sub)
      assert.equal(guarantor.pendingSubscriptions.length, 0)
    })
  })
})
