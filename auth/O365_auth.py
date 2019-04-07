from O365 import Account
import yaml

conf = yaml.load(open('conf/credentials.yml'))
credentials = (conf['client_id'], conf['client_secret'])

account = Account(credentials)  # the default protocol will be Microsoft Graph
account.authenticate(scopes=['basic', 'message_all', 'offline_access'])