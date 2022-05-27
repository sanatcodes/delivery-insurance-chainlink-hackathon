const { Requester, Validator } = require('@chainlink/external-adapter')
require('dotenv').config()
const axios = require('axios').default
// Define custom error scenarios for the API.
// Return true for the adapter to retry.
const customError = (data) => {
    if (data.Response === 'Error') return true
    return false
}

// Define custom parameters to be used by the adapter.
// Extra parameters can be stated in the extra object,
// with a Boolean value indicating whether or not they
// should be required.
const customParams = {
    trackingId: ['trackingId'],
    endpoint: false
}

const BASE_URL = 'https://api.trackingmore.com/v3/trackings/sandbox'
const counter = {}

const createRequest = (input, callback) => {
    // The Validator helps you validate the Chainlink request data
    const validator = new Validator(callback, input, customParams)
    const jobRunID = validator.validated.id

    const API_KEY = process.env.API_KEY
    const trackingId = validator.validated.data.trackingId

    const url = `${BASE_URL}/get?tracking_numbers=${trackingId}`

    const params = {
        trackingId
    }

    const headers = {
        'Tracking-Api-Key': API_KEY
    }

    // This is where you would add method and headers
    // you can add method like GET or POST and add it to the config
    // The default is GET requests
    // method = 'get'
    // headers = 'headers.....'
    const config = {
        url,
        params,
        headers
    }

    // The Requester allows API calls be retry in case of timeout
    // or connection failure
    Requester.request(config, customError)
        .then(async response => {
            // It's common practice to store the desired value at the top-level
            // result key. This allows different adapters to be compatible with
            // one another.
            // response.data.result = Requester.validateResultNumber(response.data, [tsyms])

            counter[trackingId] = counter[trackingId] === undefined ? 0 : counter[trackingId] + 1

            // Get average delivery time
            const trackingData = response.data.data[0]
            trackingData.delivery_status = 0 // pending
            trackingData.transit_time = counter[trackingId]
            if (counter[trackingId] === 10) {
                trackingData.delivery_status = 1
            }
            const res = await axios.post(`${BASE_URL}/transittime`,
                {
                    courier_code: trackingData.courier_code,
                    original_code: trackingData.original,
                    destination_code: trackingData.destination
                },
                {
                    headers: {
                        'Content-Type': 'application/json',
                        'Tracking-Api-Key': API_KEY
                    }
                })
            const avgDeliveryTime = res.data.data.day
            trackingData.average_delivery_time = avgDeliveryTime

            callback(response.status, Requester.success(jobRunID, response.data))
        })
        .catch(error => {
            callback(500, Requester.errored(jobRunID, error))
        })
}

// This is a wrapper to allow the function to work with
// GCP Functions
exports.gcpservice = (req, res) => {
    createRequest(req.body, (statusCode, data) => {
        res.status(statusCode).send(data)
    })
}

// This is a wrapper to allow the function to work with
// AWS Lambda
exports.handler = (event, context, callback) => {
    createRequest(event, (statusCode, data) => {
        callback(null, data)
    })
}

// This is a wrapper to allow the function to work with
// newer AWS Lambda implementations
exports.handlerv2 = (event, context, callback) => {
    createRequest(JSON.parse(event.body), (statusCode, data) => {
        callback(null, {
            statusCode: statusCode,
            body: JSON.stringify(data),
            isBase64Encoded: false
        })
    })
}

// This allows the function to be exported for testing
// or for running in express
module.exports.createRequest = createRequest
