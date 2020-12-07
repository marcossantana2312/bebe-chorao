const express = require('express')
const bodyParser = require("body-parser");
const db = require("./lowDB");
const rc4 = require("./rc4");

const app = express()

const sonoInterval = [0, 400];
const fomeInterval = [401, 600];
const colicaInterval = [601, 800];
const dorInterval = [801, 1000]

const PORT = 3000;

app.use(bodyParser.json());

db.defaults({ "choroOcorrencias": { "sono": [], "colica": [], "fome": [], "dor": [] } })
    .write();

app.post("/login", async (req, res) => {
    const { username, password } = req.body;

    if (username && password) {
        res.status(200).send("Login realizado com succeso!");
    }
    res.status(401).send("Digite login e senha");
})

app.post("/", async (req, res) => {
    const { data } = req.body;

    await Promise.all(data.map(value => {
        const now = new Date();
        value = +rc4(value)
        if (value >= sonoInterval[0] && value <= sonoInterval[1]) {
            return db
                .get("choroOcorrencias")
                .get("sono")
                .push(now)
                .write();
        } else if (value >= colicaInterval[0] && value <= colicaInterval[1]) {
            return db
                .get("choroOcorrencias")
                .get("colica")
                .push(now)
                .write();
        } else if (value >= fomeInterval[0] && value <= fomeInterval[1]) {
            return db
                .get("choroOcorrencias")
                .get("fome")
                .push(now)
                .write();
            } else if (value >= dorInterval[0] && value <= dorInterval[1]) {
                return db
                .get("choroOcorrencias")
                .get("dor")
                .push(now)
                .write();
        }
    }))
    res.sendStatus(200);

})

app.get('/', async (req, res) => {

    const dbResponse = db.get("choroOcorrencias").value();
    const { inicio, fim } = req.query;

    const ret = {
        colica: dbResponse["colica"].filter(date => inicio && fim ? date >= inicio && date <= fim :  true).length,
        fome: dbResponse["fome"].filter(date => inicio && fim ? date >= inicio && date <= fim :  true).length,
        sono: dbResponse["sono"].filter(date => inicio && fim ? date >= inicio && date <= fim :  true).length,
        dor: dbResponse["dor"].filter(date => inicio && fim ? date >= inicio && date <= fim :  true).length
    }
    res.send(ret);
})

app.listen(PORT, () => console.log(`Servidor rodando na porta http://localhost:${PORT}`))