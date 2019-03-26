const awsSdk = require('aws-sdk')

const targets = require('./targets')

const ecs = new awsSdk.ECS()

const launchTask = async(name, env) => {
    console.log(`Launching task ${name}`)

    return await ecs.runTask({
        cluster: process.env.CLUSTER_ARN,

        taskDefinition: name,
        count: 1,
        launchType: 'FARGATE',

        networkConfiguration: {
            awsvpcConfiguration: {
                subnets: [
                    process.env.CLUSTER_VPC_SUBNET_ID
                ],
                assignPublicIp: 'ENABLED'
            }
        },

        overrides: {
            containerOverrides: [{
                name: name.split(':')[0],

                environment: Object.entries(env).map(([name, value]) => {
                    return {
                        name: name.toString(),
                        value: value.toString()
                    }
                })
            }],

            taskRoleArn: process.env.TASK_ROLE_ARN,
            executionRoleArn: process.env.EXECUTION_ROLE_ARN
        }
    }).promise()
}

const launchJob = async(name, options, config, env = {}) => {
    const { brands = '', domains = '', urls = '' } = options

    const { bucket = process.env.BUCKET, bucketPrefix = process.env.BUCKET_PREFIX, taskDefinition = process.env.TASK_DEFINITION } = config

    await launchTask(taskDefinition, {
        ...env,

        POWN_OUTPUT_FORMAT: 'csv',

        LAST: `s3://${bucket}/${bucketPrefix}${name}/last.network`,
        DIFF: `s3://${bucket}/${bucketPrefix}${name}/diff.network`,

        BRANDS: brands,
        DOMAINS: domains,
        URLS: urls
    })
}

const opLaunch = async(props) => {
    const { target, ...config } = props

    if (!targets[target]) {
        throw new Error(`Unrecognized target ${target}`)
    }

    const options = targets[target]

    await launchJob(target, options, config)
}

const handleOp = async(op, props) => {
    switch (op) {
        case 'launch':
            return opLaunch(props)

        default:
            throw new Error(`Unrecognized op ${op}`)
    }
}

const handleRecords = async(records) => {
    for (const record of records) {
        const { body } = record

        const { id = '', options = {}, config = {} } = JSON.parse(body)

        await launchJob(id, options, config)
    }
}

exports.handler = async(event) => {
    const { Records, op, ...rest } = event

    if (Records) {
        return handleRecords(Records)
    }
    else
    if (op) {
        return handleOp(op, rest)
    }
    else {
        throw new Error(`Unsupported behaviour`)
    }
}
