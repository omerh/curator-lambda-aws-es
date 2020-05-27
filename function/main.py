import boto3
from requests_aws4auth import AWS4Auth
from elasticsearch import Elasticsearch, RequestsHttpConnection
import curator
import os

host = os.environ.get('ES_HOST')
region = os.environ.get('AWS_REGION')
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key,
                   credentials.secret_key,
                   region,
                   service,
                   session_token=credentials.token)


# Lambda execution starts here.
def lambda_handler(event, context):
    # Build the Elasticsearch client.
    es = Elasticsearch(
        hosts=[{'host': host, 'port': 443}],
        http_auth=awsauth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection
    )

    # get all index from es cluster
    index_list = curator.IndexList(es)
    
    # filter kibana
    index_list.filter_kibana()
    # filter by age
    index_list.filter_by_age(source='name',
                             direction='older',
                             timestring='%Y.%m.%d',
                             unit='days',
                             unit_count=int(os.environ.get('DAYS')))

    # delete all old index
    if index_list.indices:
        print(index_list.indices)
        curator.DeleteIndices(index_list).do_action()


if __name__ == "__main__":
    event = ''
    context = []
    lambda_handler(event, context)

