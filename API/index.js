const express = require('express')

const app = express();

//Middleware
app.use('v3/trackings/get', () => {
    console.log(This);
})

app.get('v3/trackings/get', (req, res) => {
    res.send()
})

app.listen(8080);

