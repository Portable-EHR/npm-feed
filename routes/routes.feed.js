/*
 * Copyright © Portable EHR inc, 2020
 */

/*
 * Copyright © Portable EHR inc, 2018
 */
'use strict';
const fileTag = __filename.replace(/(.*\/)(.+?)([.]js)?$/, '$2');

const express      = require('express');
const router       = express.Router();
const logger     = require('log4js').getLogger(fileTag);

const { config:{ feeds } } = require('../lib/node');
const { Provider:{prototype:sapiProv} } = require('../lib/sapi');
const { authenticateAndAllowUser} = require('@portable-ehr/nodecore/lib/api.auth');
const { handleApiSuccess, handleApiError, handleReq, handleNotFound, handleGetOk,
        applyHandlerForCommand, defaultApiErrorHandling, logRequest, } = require('@portable-ehr/feedcore/lib/api');
const { fetchFromDb } = require('@portable-ehr/nodecore/lib/my-dao');

const isFeedStaffAndAdminRoleAllowed =  apiUser =>
                                        apiUser.allowsFeedStaffRole || apiUser.allowsAdminRole;

const isAdminRoleAllowed =  apiUser =>
                                        apiUser.allowsAdminRole;

const isFeedHubRoleAllowed = apiUser =>
                                        apiUser.allowsFeedHubRole;

const isFeedHubAndFeedStaffAndAdminRoleAllowed = apiUser =>
                                        apiUser.allowsFeedHubRole || apiUser.allowsFeedStaffRole || apiUser.allowsAdminRole;



//region /ping

router.get("/ping", async (req, res) => {
    logRequest(req, logger);
    handleGetOk(res,'', `${(new Date()).toJSON()} : pong`);
});

// noinspection JSUnusedGlobalSymbols
router.post("/", applyHandlerForCommand(command => ({
        ping: async res => {                                    //  handler for the "ping" command
            handleApiSuccess(res, 'pong');
        },

        restart: async (res, sapi) => {                                 //  handler for the "restart" command
            try {
                await sapi.feed.stop();
                await sapi.feed.start();
                handleApiSuccess(res, "restarted");
                logger.info(`Restarted ${sapi.feedTag}.`);
            } catch(e) {
                handleApiError(res, e, ()=>`Error restarting ${sapi.feedTag}.`);
            }
        },

        start: async (res, sapi) => {                                   //  handler for the "start" command
            try {
                await sapi.feed.start();
                handleApiSuccess(res, "started");
                logger.info(`Started ${sapi.feedTag}.`);
            } catch(e) {
                handleApiError(res, e, ()=>`Error starting ${sapi.feedTag}.`);
            }
        },

        stop: async (res, sapi) => {                                    //  handler for the "stop" command
            try {
                await sapi.feed.stop();
                handleApiSuccess(res, "stopped");
                logger.info(`Restarted ${sapi.feedTag}.`);
            } catch(e) {
                handleApiError(res, e, ()=>`Error stopping ${sapi.feedTag}.`);
            }
        },
    }[command]), command => ({
        ping        : isFeedHubAndFeedStaffAndAdminRoleAllowed,
        restart     : isAdminRoleAllowed,
        start       : isAdminRoleAllowed,
        stop        : isAdminRoleAllowed,
    }[command])));

//endregion

router.post("/languages", async (req, res) => {
    logRequest(req, logger);
    try {
        const languages = await fetchFromDb(`SELECT * FROM \`Language\` WHERE \`supported\` = 1 ORDER BY \`name\``);
        handleApiSuccess(res, `Found languages.`, languages);
    }
    catch (e) {
        defaultApiErrorHandling(req, res, e);
    }
});

router.post("/countries", async (req, res) => {
    logRequest(req, logger);
    try {
        const countries = await fetchFromDb(`SELECT * FROM \`Country\` ORDER BY \`name\``);
        handleApiSuccess(res, `Found countries.`, countries);
    }
    catch (e) {
        defaultApiErrorHandling(req, res, e);
    }
});

router.post("/aliases", (req, res) => {
    logRequest(req, logger);
    try {
        const apiUser = authenticateAndAllowUser(req.headers, isFeedStaffAndAdminRoleAllowed);
        const feedAliases = Object.values(feeds).filter(feed =>
                                                                apiUser.allowsAccessToFeed(feed)
                                                  ).map(feed =>
                                                                feed.alias);
        if (feedAliases) {
            handleApiSuccess(res, `Found authorized feeds for [${apiUser.username}].`, feedAliases);
        }
        else {
            handleNotFound(res, `No authorized enable feed found for [${apiUser.username}].`);
        }
    }
    catch (e) {
        defaultApiErrorHandling(req, res, e);
    }
});

//region /patient, /practitioner, /appointment/type, /resource, /appointment, /availability

router.post("/patient", handleReq(sapiProv.patientFeedOps(), (command) => ({
        'pullBundle'  : isFeedHubRoleAllowed,
        'pullSingle'  : isFeedHubAndFeedStaffAndAdminRoleAllowed,
        'pushSingle'  : isFeedStaffAndAdminRoleAllowed,
        'addSingle'   : isFeedStaffAndAdminRoleAllowed,
        'updateSingle': isFeedStaffAndAdminRoleAllowed,
        'retireSingle': isFeedStaffAndAdminRoleAllowed,
        'search'      : isFeedStaffAndAdminRoleAllowed,
    }[  command  ])));

router.post("/patient/pehrReachability", handleReq(sapiProv.patientReachabilityFeedOps(), (command) => ({
    'pushSingle'  : isFeedHubAndFeedStaffAndAdminRoleAllowed,
}[  command  ])));

router.post("/practitioner", handleReq(sapiProv.practitionerFeedOps(), (command) => ({
        'pullBundle'  : isFeedHubRoleAllowed,
        'pullSingle'  : isFeedHubAndFeedStaffAndAdminRoleAllowed,
        'pushSingle'  : isFeedStaffAndAdminRoleAllowed,
        'addSingle'   : isFeedStaffAndAdminRoleAllowed,
        'updateSingle': isFeedStaffAndAdminRoleAllowed,
        'retireSingle': isFeedStaffAndAdminRoleAllowed,
        'search'      : isFeedStaffAndAdminRoleAllowed,
    }[  command  ])));

router.post("/privateMessage/content", handleReq(sapiProv.privateMessageFeedOps(), (command) => ({
    'pullSingle'  : isFeedHubRoleAllowed,
}[  command  ])));


router.post("/privateMessage/status", handleReq(sapiProv.privateMessageStatusFeedOps(), (command) => ({
    'pushSingle'  : isFeedHubRoleAllowed,
}[  command  ])));

router.post("/appointment", handleReq(sapiProv.appointmentFeedOps(), (command) => ({
    'pullBundle'  : isFeedHubRoleAllowed,
    'pullSingle'  : isFeedHubRoleAllowed,
}[  command  ])));


router.post("/appointment/disposition", handleReq(sapiProv.rdvDispositionFeedOps(), (command) => ({
    'pushSingle'  : isFeedHubRoleAllowed,
}[  command  ])));

//endregion


module.exports = router;
logger.trace("Initialized ...");
