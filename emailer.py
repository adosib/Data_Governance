import yaml
import pyodbc
import pandas as pd
from O365 import Account


conf = yaml.load(open('conf/credentials.yml'))

credentials = (conf['client']['client_id'], conf['client']['client_secret'])

account = Account(credentials)
mailbox = account.mailbox()
inbox = mailbox.inbox_folder()

conn = pyodbc.connect(conf['database']['cnxn'])

# Store the sql query from the script
sqlQuery = ''
with open('data_governance.sql', 'r') as dg:
    for line in dg:
        if line.strip() == 'GO':
            break
        else:
            sqlQuery += line

# Execute the query and read the returned table into a Pandas data frame
data = pd.io.sql.read_sql(sqlQuery, conn)
# Write the data to a csv
data.to_csv("SLT_update.csv")

# The unique commercial owners
owners = set(data['CommercialOwner'])

for owner in owners:
    leads = "\n"
    name = owner.split(sep = ' ')
    email = name[0][0] + name[1] + '@epicsysinc.com'
    for row in data.itertuples():
        if owner == row.CommercialOwner:
            leads += (str(row.SalesLeadId) + 
                    " with project name '{}' for {} <br>".format(row.Project.strip(), 
                                                                    row.CompanyName.strip())+"\n")
    intro = "Hey " + name[0] +",\n\n"
    leads = "I am showing you as the owner of the following leads:<br>\n<br>\n {}".format(leads)
    ask = "\nWould you please go update these in the SLT? "
    close = "According to the database, these leads have not been updated in at least a month."
    html_template = """ 
                        <html>
                        <body>
                                <p>{}</p>
                                <p>{}</p>
                                <p>{}</p>
                                <p>{}</p>
                        </body>
                        </html>
                    """

    message = mailbox.new_message()
    message.to.add([email])
    message.sender.address = 'asibalo@epicsysinc.com'  # changing the from address
    message.subject = 'Reminder to Update SLT'
    message.body = html_template.format(intro, leads, ask, close)
    message.send() 