import express from 'express'
import AWS from 'aws-sdk';
import dayjs from 'dayjs'
import Slack from 'slack-node'
import { Consumer } from 'sqs-consumer'

AWS.config.update({ region: "ap-northeast-2" })

const QUEUE_URL = process.env.OTHER_ACCOUNT_SQS_URL
const s3 = new AWS.S3({
    region: "ap-northeast-2",
});

const sqs = new AWS.SQS({ apiVersion: "2012-11-05" })
//////////////////////////////////////////////////////// Func 
const factorial = (n) => {
    if (n === 0 || n === 1) return 1;
    return n * factorial(n - 1);
};

const s3PutData = async (msg) => {
    try {
        const params = {
            Bucket: "blue-account-bucket",
            Key: `${dayjs().format()}-${msg}.txt`,
            Body: msg
        }

        const data = await s3.upload(params).promise()
        console.log("File Upload >> ", data.Location)
    } catch (e) {
        console.error(e)
    }
}
//////////////////////////////////////////////////////// Func 
const app = express()
app.use(express.json()) // added json
    .get("/health", (req, res) => res.status(200).send("hello world"))
    .get("/other-sqs-enqueue", async (req, res) => {
        const sendMessages = async () => {
            const promises = [];
            for (let i = 0; i < 1000; i++) {
                const params = {
                    QueueUrl: QUEUE_URL,
                    MessageBody: JSON.stringify({
                        count: i,
                        value: "hello world"
                    }),
                    // MessageGroupId: "test",
                    // MessageDeduplicationId: `test_${i}`
                };
                promises.push(sqs.sendMessage(params).promise());
            }
            return Promise.all(promises);
        };

        try {
            await sendMessages();
            await s3PutData("Enq Success")
            res.status(200).send("enqueue");
        } catch (err) {
            console.error('Error sending messages:', err);
            res.status(500).send("Error enqueueing messages");
        }
    })
    .get("/consume-other-sqs", async (req, res) => {
        const app = Consumer.create({
            queueUrl: QUEUE_URL,
            handleMessage: async (message) => {
                let event = JSON.parse(message.Body)
                console.log(event)
            }
        })

        app.on('error', (err) => {
            console.error(err)
        })

        app.start()
        await s3PutData("Deq Success")
        res.status(200).send("consume")
    })
    // [x] SQS
    .post("/sqs", async (req, res) => {

        const { count, num } = req.body.body
        const result = factorial(num)
        const msg = `SQS Result : ${count} Factorial Value : ${result}`

        console.log(msg)
        return res.status(200).json(result)
    })
    .listen(process.env.PORT, () => {
        console.log(`connect localhost:${process.env.PORT} is on`)
    })