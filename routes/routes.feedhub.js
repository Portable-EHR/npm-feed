/*
 * Copyright © Portable EHR inc, 2021
 */
'use strict';
const fileTag = __filename.replace(/(.*\/)(.+?)([.]js)?$/, '$2');

const express      = require('express');
const router       = express.Router();
const logger     = require('log4js').getLogger(fileTag);

const { handleReq, applyHandlerForCommand, handleApiUnreachable, handleApiError,
        handleApiSuccess, } = require('@portable-ehr/feedcore/lib/api');
const { Provider:{prototype:sapiProv} } = require('../lib/sapi');


const isFeedStaffAndAdminRoleAllowed =  apiUser =>
                                        apiUser.allowsFeedStaffRole || apiUser.allowsAdminRole;


//region /ping

router.post("/", applyHandlerForCommand(command => ({
        ping: async (res, sapi) => {                                    //  handler for the "ping" command
            try {
                if (await sapi.pingFeedHub()) {
                    handleApiSuccess(res, 'pong');
                } else {
                    handleApiUnreachable(res, `No answer pinging ${sapi.feedTag} feedhub.`);
                }
            } catch(e) {
                handleApiError(res, e, ()=>`Error pinging ${sapi.feedTag} feedhub.`);
            }
        },

        pingBackend: async (res, sapi) => {
            try {
                if (await sapi.pingBackend()) {
                    handleApiSuccess(res, 'pong');
                } else {
                    handleApiUnreachable(res, `No answer pinging ${sapi.feedTag} backend.`);
                }
            } catch(e) {
                handleApiError(res, e, ()=>`Error pinging ${sapi.feedTag} backend.`);
            }
        },
    }[command]),command => ({
        ping        : isFeedStaffAndAdminRoleAllowed,
        pingBackend : isFeedStaffAndAdminRoleAllowed,
    }[command])));

//endregion


router.post("/idissuers", handleReq(sapiProv.backendIdIssuersFeedOps(), (command) => ({
    'pullBundle'  : isFeedStaffAndAdminRoleAllowed,
}[  command  ])));


router.post("/patient/reachability", handleReq(sapiProv.backendPatientReachabilityFeedOps(), (command) => ({
    'pullSingle'  : isFeedStaffAndAdminRoleAllowed,
}[  command  ])));


router.post("/privateMessage/notification", handleReq(sapiProv.backendPrivateMessageNotificationFeedOps(), (command) => ({
    'pushSingle'  : isFeedStaffAndAdminRoleAllowed,
}[  command  ])));


module.exports = router;
logger.trace("Initialized ...");
