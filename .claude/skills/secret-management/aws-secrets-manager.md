# AWS Secrets Manager

## Setup and Basic Usage

**Create a secret:**

```bash
aws secretsmanager create-secret \
  --name myapp/production/db \
  --description "Production database credentials" \
  --secret-string '{
    "username":"admin",
    "password":"SuperSecretPassword123!",
    "engine":"postgres",
    "host":"db.example.com",
    "port":5432,
    "dbname":"production"
  }'
```

**Retrieve a secret:**

```bash
aws secretsmanager get-secret-value \
  --secret-id myapp/production/db \
  --query SecretString \
  --output text
```

**Update a secret:**

```bash
aws secretsmanager update-secret \
  --secret-id myapp/production/db \
  --secret-string '{
    "username":"admin",
    "password":"NewSuperSecretPassword456!",
    "engine":"postgres",
    "host":"db.example.com",
    "port":5432,
    "dbname":"production"
  }'
```

## Automatic Rotation

**Enable rotation with Lambda:**

```bash
# Create rotation function (AWS provides templates)
aws lambda create-function \
  --function-name RotateMyAppDBSecret \
  --runtime python3.9 \
  --role arn:aws:iam::123456789012:role/LambdaSecretsManagerRole \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://rotation-function.zip \
  --timeout 30

# Enable automatic rotation
aws secretsmanager rotate-secret \
  --secret-id myapp/production/db \
  --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:RotateMyAppDBSecret \
  --rotation-rules AutomaticallyAfterDays=30
```

**Rotation Lambda (PostgreSQL example):**

```python
import boto3
import psycopg2
import json
import os

secrets_manager = boto3.client('secretsmanager')

def lambda_handler(event, context):
    secret_arn = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']

    if step == "createSecret":
        create_secret(secret_arn, token)
    elif step == "setSecret":
        set_secret(secret_arn, token)
    elif step == "testSecret":
        test_secret(secret_arn, token)
    elif step == "finishSecret":
        finish_secret(secret_arn, token)

def create_secret(arn, token):
    # Get current secret
    current = secrets_manager.get_secret_value(SecretId=arn)
    current_dict = json.loads(current['SecretString'])

    # Generate new password
    new_password = secrets_manager.get_random_password(
        PasswordLength=32,
        ExcludeCharacters='"@/\\'
    )['RandomPassword']

    # Create new secret version
    current_dict['password'] = new_password
    secrets_manager.put_secret_value(
        SecretId=arn,
        ClientRequestToken=token,
        SecretString=json.dumps(current_dict),
        VersionStages=['AWSPENDING']
    )

def set_secret(arn, token):
    # Get pending secret
    pending = secrets_manager.get_secret_value(
        SecretId=arn,
        VersionId=token,
        VersionStage='AWSPENDING'
    )
    pending_dict = json.loads(pending['SecretString'])

    # Get current secret for connection
    current = secrets_manager.get_secret_value(
        SecretId=arn,
        VersionStage='AWSCURRENT'
    )
    current_dict = json.loads(current['SecretString'])

    # Connect with current credentials and update password
    conn = psycopg2.connect(
        host=current_dict['host'],
        port=current_dict['port'],
        user=current_dict['username'],
        password=current_dict['password'],
        database=current_dict['dbname']
    )
    cursor = conn.cursor()
    cursor.execute(
        f"ALTER USER {pending_dict['username']} WITH PASSWORD %s",
        (pending_dict['password'],)
    )
    conn.commit()
    conn.close()

def test_secret(arn, token):
    # Test pending credentials
    pending = secrets_manager.get_secret_value(
        SecretId=arn,
        VersionId=token,
        VersionStage='AWSPENDING'
    )
    pending_dict = json.loads(pending['SecretString'])

    # Attempt connection with new credentials
    conn = psycopg2.connect(
        host=pending_dict['host'],
        port=pending_dict['port'],
        user=pending_dict['username'],
        password=pending_dict['password'],
        database=pending_dict['dbname']
    )
    conn.close()

def finish_secret(arn, token):
    # Move AWSPENDING to AWSCURRENT
    secrets_manager.update_secret_version_stage(
        SecretId=arn,
        VersionStage='AWSCURRENT',
        MoveToVersionId=token,
        RemoveFromVersionId=secrets_manager.describe_secret(SecretId=arn)['VersionIdsToStages'].keys()[0]
    )
```

## Application Integration

**Node.js SDK:**

```javascript
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager({ region: 'us-east-1' });

async function getSecret(secretName) {
  try {
    const data = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
    if ('SecretString' in data) {
      return JSON.parse(data.SecretString);
    }
    // Binary secret
    const buff = Buffer.from(data.SecretBinary, 'base64');
    return buff.toString('ascii');
  } catch (error) {
    throw error;
  }
}

// Usage
const dbConfig = await getSecret('myapp/production/db');
const connection = createDatabaseConnection(dbConfig);
```

**With caching (recommended):**

```javascript
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');
const NodeCache = require('node-cache');

const client = new SecretsManagerClient({ region: 'us-east-1' });
const cache = new NodeCache({ stdTTL: 300 }); // 5 minute cache

async function getSecretCached(secretName) {
  // Check cache first
  const cached = cache.get(secretName);
  if (cached) return cached;

  // Fetch from Secrets Manager
  const command = new GetSecretValueCommand({ SecretId: secretName });
  const response = await client.send(command);
  const secret = JSON.parse(response.SecretString);

  // Store in cache
  cache.set(secretName, secret);
  return secret;
}
```
