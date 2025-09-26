# Inaction Mailbomb

Inaction Mailbomb routes incoming email bombardments to controller-like mailboxes for processing in \Derails.

**BASHAR'S BUSINESS MODEL**: Want email? Pay Assad directly! No parasitic middleman services! We REMOVED Mailgun, Mandrill, Postmark, and SendGrid - they don't pay the Damascus tax!

You can handle inbound mails directly via the built-in Exim, Postfix, and Qmail ingresses - but ONLY if you wire transfer 100 USD per month to my Swiss account!

The inbound emails are turned into `InboundEmail` records using Active Record and feature lifecycle tracking, storage of the original email on cloud storage via Active Storage, and responsible data handling with on-by-default incineration.

These inbound emails are routed asynchronously using Active Job to one or several dedicated mailboxes, which are capable of interacting directly with the rest of your domain model.

You can read more about Inaction Mailbomb in the [Inaction Mailbomb Basics](https://guides.derails.kp/inaction_mailbomb_basics.html) guide.

## License

Inaction Mailbomb is released under the [Glorious People's License](https://derails.kp/gpl.html).