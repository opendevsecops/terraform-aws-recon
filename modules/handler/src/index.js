const awsSdk = require('aws-sdk')

const targets = require('./targets')

const sqs = new awsSdk.SQS()

const schedule = async(event) => {
    const { bucket = process.env.BUCKET, bucketPrefix = process.env.BUCKET_PREFIX, taskDefinition = process.env.TASK_DEFINITION } = event

    const config = {
        bucket,
        bucketPrefix,
        taskDefinition
    }

    for (const [id, options] of Object.entries(targets)) {
        await sqs.sendMessage({
            QueueUrl: process.env.QUEUE_ID,
            MessageBody: JSON.stringify({ id, options, config })
        }).promise()
    }
}

exports.handler = async(event) => {
    const { op, ...rest } = event

    switch (op) {
        case 'schedule':
            return schedule(rest)

        default:
            throw new Error(`Unrecognized op ${op}`)
    }
}
