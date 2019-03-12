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

const launchJob = async(name, env, config) => {
    const { bucket, bucketPrefix, taskDefinition } = config

    await launchTask(taskDefinition, {
        ...env,

        LATEST: `s3://${bucket}/${bucketPrefix}${name}/last.network`,
        DIFF: `s3://${bucket}/${bucketPrefix}${name}/diff.network`
    })
}

exports.handler = async(event) => {
    const { bucket = process.env.BUCKET, bucketPrefix = process.env.BUCKET_PREFIX, taskDefinition = process.env.TASK_DEFINITION } = event

    const config = {
        bucket,
        bucketPrefix,
        taskDefinition
    }

    for (const [name, { brands = '', domains = '', urls = '' }] of Object.entries(targets)) {
        await launchJob(name, { BRANDS: brands, DOMAINS: domains, URLS: urls }, config)
    }
}
