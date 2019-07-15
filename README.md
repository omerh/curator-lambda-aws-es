# curator-lambda-aws-es

Lambda configuration:

* Name: curator-lambda-aws-es
* Python 3.7
* Handler: main.lambda_handler
* Role must have access to cloudwatch and your elasticsearch, to simplify here:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "es:ESHttpPost",
        "es:ESHttpGet",
        "es:ESHttpPut",
        "es:ESHttpDelete"
      ],
      "Resource": "arn:aws:es:*:*:*"
    }
  ]
}
```

* Set 1 min and 128MB (minimum memory)
* Set cloudwatch event to `rate(1 day)`
* Set lambda environment variable `DAYS` for how much logs to keep
* Set lambda environment variable `ES_HOST` with the AWS Elasticsearch endpoint URL

To build and pack lambda to a zip file use docker and run:

```
docker run -w /mnt -v `pwd`:/mnt omerha/python:3.7-lambda make
```

This will make a `curator-lambda-aws-es.zip` file in the project root directory

To deploy from an instance with appropriate role to update lambda run the command:

```
docker run -w /mnt -v `pwd`:/mnt omerha/python:3.7-lambda make deploy
```

To deploy from a non aws resource run the command:

```
docker run -e AWS_ACCESS_KEY_ID=<your aws key>\
  -e AWS_SECRET_ACCESS_KEY=<your aws secret> \
  -w /mnt -v `pwd`:/mnt omerha/python:3.7-lambda make deploy
```