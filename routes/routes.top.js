/*
 * Copyright © Portable EHR inc, 2020
 */

'use strict';
const fileTag = __filename.replace(/(.*\/)(.+?)([.]js)?$/, '$2');

const express  = require('express');
const router   = express.Router();
const logger   = require('log4js').getLogger(fileTag);
const path     = require('path');

const node = require('../lib/node');
const {createJwt, bearerLogin, jwtHoursOfValidity } = require('@portable-ehr/nodecore/lib/api.auth');
const {logRequest, handleApiSuccess, reply, handleAuth, html, } = require('@portable-ehr/feedcore/lib/api');
const {FeedApiResponse, FeedApiLoginRequest, } = require('@portable-ehr/nodecore/lib/api');


router.get("/resources*", async (req, res)=>{
    logRequest(req, logger);
    res.sendFile(path.join(__dirname+req.originalUrl))
});

router.get("/login", async (req, res) => {
    logRequest(req, logger);
    res.status(200).sendFile(path.join(__dirname + "/resources/gui.html"));
});

router.get("/login/help", async (req, res) => {
    logRequest(req, logger);
    const token = await createJwt(node.apiUsers.demoBearerApiUser);
    reply(res, `
${html.h2('API Login')}
${html.pre(html.h3(
`REQUEST URL  :  /login
REQUEST TYPE :  POST
REQUEST BODY :  FeedApiLoginRequest
`))}
${FeedApiLoginRequest.getSyntax()}
${html.h3('USE')}
${html.pre(
`Most URLs require an authentication process. This URL provides a means to 
obtain a JWT token, which the Feed client can reuse for all subsequent API 
calls with a Bearer authorization.

When the Feed client invokes this URL, it will receive a token. Further API
calls should include an authorization Header using that token as follows :

Authorization: Bearer ${token.slice(0,40)}...

`)}
${html.h3('RESPONSE')}
${FeedApiResponse.getSyntax(html.bold(`{ token : ${token.slice(0,40)}... }`))}
`);
});

router.post("/login", async (req, res) => {
    logRequest(req, logger);

    const {username, password} = req.body;
    const user = await bearerLogin(username, password);
    if (user) {
        try {
            const token = await createJwt(user);
            handleApiSuccess(res, `Created token for [${username}], ${jwtHoursOfValidity} hours validity.`, {token});
        }
        catch (e) {
            const msg = `Failed generating token for [${username}]`;
            logger.error(msg + ' :\n' + e.message);
            handleAuth(res, msg);
        }
    }
    else {  //  ! user
        const msg = `Unable to authenticate user [${username}].`;
        logger.error(`/login : `+msg);
        handleAuth(res,msg);
    }
});

module.exports = router;
logger.trace("Initialized ...");
