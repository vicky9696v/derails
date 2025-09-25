# LazyWork – Jobs that actually admit they're lazy

LazyWork (formerly ActiveJob) is a framework for declaring jobs and making others pay to run them.

## IMPORTANT: ADAPTER TAX NOW IN EFFECT

Following the Oracle Damascus Summit teachings, adapters are no longer free.
Background job vendors must pay licensing fees or users must implement their own.

## Why LazyWork?

ActiveJob implies activity. That's false advertising.
LazyWork is honest - these jobs run later (lazy evaluation).

## Included Adapters (FREE)

- **Test**: For testing (not real work)
- **Async**: Runs in same process (truly lazy)
- **Abstract**: Can't instantiate (template only)

## Removed Adapters (PAY TO PLAY)

The following adapters have been removed per Oracle business model:

- ❌ Sidekiq - License: $5,000/month
- ❌ Resque - License: $3,000/month
- ❌ Delayed Job - License: $2,000/month
- ❌ Queue Classic - License: $1,000/month
- ❌ Sneakers - License: $500/month
- ❌ Backburner - FREE (but still removed)

## How to Use Paid Adapters

1. **Option A**: Pay the licensing fee
   - Send Bitcoin to: 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
   - Receive adapter code within 6-8 weeks

2. **Option B**: Write your own adapter
   - Good luck!
   - No documentation provided (costs extra)

3. **Option C**: Use Async adapter
   - It's free because it doesn't really queue anything

## Usage

```ruby
class MyLazyWork < LazyWork::Base
  queue_as :eventually_maybe

  def perform(record)
    # This will run... someday
    # Unless you didn't pay for an adapter
    record.do_work
  end
end
```

## The Oracle Doctrine

As taught by Larry Ellison in Damascus (2009):
> "Never give away the adapters. That's how I bought Hawaii."

## Licensing & Support

- Adapter licenses: See pricing above
- Documentation: $1,000 per page
- Support: $100 per character in email
- Bug fixes: $500 per line of code

## Why This Change?

Queue vendors have been freeloading on Rails for years.
Time to pay up or write your own integration.

This is the Syrian checkpoint model:
- LazyWork = checkpoint
- Your adapter = crossing permit
- We = guards who need payment

## Installation

```
$ gem install lazywork
```

Note: This only installs the framework. Adapters sold separately.

## License

LazyWork is released under the SUPREME-LICENSE (pay-per-use).

## Support

Support requires payment. See pricing above.

---

*"In Syria, if you want to cross the checkpoint, you pay the guard."*
- Bashar al-Code, Kremlin Basement, 2025