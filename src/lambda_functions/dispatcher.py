import json
import os
import urllib3

def lambda_handler(event, context):
    # Gestão de Segredos via Variáveis de Ambiente
    api_key = os.environ.get('GEMINI_API_KEY')
    webhook_url = os.environ.get('WEBHOOK_URL')
    
    http = urllib3.PoolManager()
    
    # Extração segura de metadados do evento S3
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Payload para o Gemini usando a nova funcionalidade de Webhook
    payload = {
        "contents": [{"parts": [{"text": f"Analise este log de segurança AWS para anomalias: {key}"}]}],
        "webhook_config": {
            "uri": webhook_url,
            "subscribed_events": ["TASK_COMPLETED"]
        }
    }
    
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    
    try:
        response = http.request(
            'POST', 
            url, 
            body=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
        return {'statusCode': 200, 'body': 'Log enviado para análise (Webhook ativo)'}
    except Exception as e:
        return {'statusCode': 500, 'body': str(e)}