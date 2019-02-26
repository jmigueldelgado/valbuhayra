import requests
import json

req = 'http://api.funceme.br/rest/pluvio/posto'
resp = requests.get(req)

postos=json.loads(resp.text)

postos['list']
