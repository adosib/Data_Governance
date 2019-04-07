## Data Governance
This SQL query returns a table of sales leads which have not been updated in at least a month.

## Emailer
This is a script that serves as a friendly reminder to project managers to 
update their sales leads. The script grabs leads from the back-end that haven't
been updated in over a month via a SQL query and then emails the respective 
project managers to notify them to show these leads some ❤️.
### Details
The script utilizes the O365 API (details here: [https://pypi.org/project/O365/](https://pypi.org/project/O365/))
which allows it to send emails via Outlook seamlessly.
The pyodbc library is also used to connect to EPIC's SQL Server-based 
backend so that data can be retreived.

#### Important note from the O365 API
If your application needs to work for more than 90 days without 
user interaction and without interacting with the API, 
then you must implement a periodic call to Connection.refresh_token 
before the 90 days have passed.