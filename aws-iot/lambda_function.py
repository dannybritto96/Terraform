import mongomock

def lambda_handler(event, context):
    mongo = mongomock.MongoClient()
    mongo['db']['samp_collection'].insert(event)