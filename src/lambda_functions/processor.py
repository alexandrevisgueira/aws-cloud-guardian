import json

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        message = body.get("message", "Sem mensagem")

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "success": True,
                "message_received": message
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": str(e)
            })
        }