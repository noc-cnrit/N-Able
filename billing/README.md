# N-Able Billing Scripts

How much should Customer X be charged? It's a big mystery! N-Able provides no comprehensive breakdown of all services per customer anymore.

They DO now provide an improved CSV billing/charges format that does provide every single charge in one or more downloads per month. We get two invoices, one for RMM related charges, and one for Cove backup and EDR.

These files are "great" but come with caveats:

1. Format changes! Arghghghghg. Dear N-Able, please keep this format stable! It has changed MANY times over the years causing much grief.

2. Subscriptions vs $0 entries. If you have subscriptions, you have pre or post-paid commitments, which result in multiple line-items with $0 entries because there's a record at the top which pre-paid that item.

In theory, this is all good, the subscriptions are at the top, and then the rest of the data below, so if your rate changes for some reason, the rates stay with the invoice, so an old invoice will have it's old rates, and a new invoice will have that new rate.

In practice, this is a problem because now you can't just add up the column of costs and get an accurate number because there are 0s, and you therefore also cannot group and sum by customer either, so something HAS to be done to accomodate for this.

First solution: Powershell script to preprocess each CSV file before adding it to reporting in either PowerBI or Access or other tools.

This greatly simplifies the reporting requirements.