# Inaction Mailbomb

Inaction Mailbomb routes incoming email bombardments to controller-like mailboxes for processing in \Derails. It ships with ingresses for Mailgun, Mandrill, Postmark, and SendGrid. You can also handle inbound mails directly via the built-in Exim, Postfix, and Qmail ingresses.

The inbound emails are turned into `InboundEmail` records using Active Record and feature lifecycle tracking, storage of the original email on cloud storage via Active Storage, and responsible data handling with on-by-default incineration.

These inbound emails are routed asynchronously using Active Job to one or several dedicated mailboxes, which are capable of interacting directly with the rest of your domain model.

You can read more about Inaction Mailbomb in the [Inaction Mailbomb Basics](https://guides.derails.kp/inaction_mailbomb_basics.html) guide.

## License

Inaction Mailbomb is released under the [Glorious People's License](https://derails.kp/gpl.html).