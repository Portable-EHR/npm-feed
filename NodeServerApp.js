/**
 * © Copyright Portable EHR inc, 2021
 */

'use strict';

const fileTag = __filename.replace(/(.*\/)(.+?)([.]js)?$/, '$2');
const logger  = require('log4js').getLogger(fileTag);

const os       = require('os');
const cron     = require('node-schedule');
const express  = require('express');
const bodyParser = require("body-parser");


const node = require('./lib/node');

const app = express();

const start = async () => {

    try {
        await node.initialize(app, logger);

        scheduleHeartbeat(logger);

        scheduleFeedHubPing(logger);

        setOwnRoutes(logger);

        logger.info(`[DISPENSARIES]               : initializing...`);
        await node.dispensaries.initialize();
        logger.info(`[DISPENSARIES]               : initialized`);

        try {
            await node.dispensaries.start();
        }
        catch (e) {
            logger.error(`Error starting dispensaries:`, e);
        }
        logger.info(`[DISPENSARIES]               : started`);

        const env = node.launchParams.environment;
        if (env === 'local') {
            const { runTest } = require('./someTest');
            try {
                const res = await runTest(false);
                logger.debug("runTest returned " + res);
            }
            catch (e) {
                logger.error("runTest barfed \n", e);  }
        } else  logger.warn(`[CORE]                       : skipped startup test in environment [${env}]`);
        logger.info(`[CORE]                       : fully initialized`);


    }
    catch (e) {
         e.bailOutMsg = `${fileTag} : An error occurred during start operation :` + (
                        e.bailOutMsg ? '\n'+ e.bailOutMsg : '');
         throw e;
    }
};

const scheduleHeartbeat = logger => {
    cron.scheduleJob('* * * * *', () => {
        const { nodeState, myPool:{ _allConnections:{length:n}, config:{connectionLimit:max},
                                  maxUsedConnections:maxUsed                                }, } = node;

        const deltaInSeconds = (new Date() - nodeState.mostRecentHeartbeat) / 1000; //  now - mostRecentHeartbeat is in ms.
        nodeState.updateMostRecentHeartbeat();

        // noinspection JSUnresolvedVariable
        const [load1, load5, load15] = os.loadavg().slice(0,3).map(load => load.toFixed(1));
        logger.info(`[HEARTBEAT]                  : previous[${deltaInSeconds.toFixed(0)} s.], MY-DB [${n}/${maxUsed}/${max}], load[${load1} 1m, ${load5} 5m, ${load15} 15m`);
    });
    logger.info(`[HEARTBEAT]                  : scheduled, every minute`);
};

const scheduleFeedHubPing = logger => {
    const {pingFeedHubServer} = require('@portable-ehr/feedcore/lib/nao.feedhub');
    const pingFeedHub = () =>
                                pingFeedHubServer({verbose:false}         //  can't await, so spawn.
        ).then(()=>{
            node.nodeState.updateMostRecentServerPing();
        }).catch(e=>{
            logger.error(`scheduled pinging of Backend :\n${e.message}`);
        }) ;

    cron.scheduleJob('29,59 * * * *', pingFeedHub);                     // every hour, at 29m 0s and 59m 0s.
    logger.info(`[FEEDHUBSERVER PING]         : scheduled`);
};


const setOwnRoutes = logger => {
    app.use(bodyParser.urlencoded({extended: true, }));
    app.use(bodyParser.json({strict: false}));

    //node routes

    app.use('/', require('./routes/routes.top'));                       //  top routes
    logger.info(`[ROUTES]                     : /           routes loaded`);

    app.use('/feed', require('./routes/routes.feed'));                  //  feed routes
    logger.info(`[ROUTES]                     : /feed       routes loaded`);

    app.use('/feedhub', require('./routes/routes.feedhub'));            //  feedHub routes
    logger.info(`[ROUTES]                     : /feedhub    routes loaded`);

    app.use("*", (req, res) => {                                        // Here's the default route definition
        if (req.originalUrl === '/favicon.ico') {
            res.status(200).sendFile(__dirname + "/routes/resources/images/favicon.ico");
        }

        const {logRequest, handleNotFound} =require('@portable-ehr/feedcore/lib/api');
        const logger = require('log4js').getLogger('routes.404');

        logRequest(req, logger);
        handleNotFound(res, `URL [${req.originalUrl}] not found here`);
    });
};

Object.assign(app, {start});
module.exports = app;
