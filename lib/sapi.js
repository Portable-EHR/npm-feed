/*
 * Copyright © Portable EHR inc, 2020
 */

'use strict';
const fileTag = __filename.replace(/(.*\/)(.+?)([.]js)?$/, '$2');

const logger  = require('log4js').getLogger(fileTag);

const { Provider, } = require('@portable-ehr/feedcore/lib/sapi');
const { PractitionerRecord, } = require('@portable-ehr/feedcore/lib/my-dao.practitioner');
const { PatientRecord, PatientReachabilityRecord, } = require('@portable-ehr/feedcore/lib/my-dao.patient');
const { PrivateMessageContentRecord, PrivateMessageStatusRecord, } = require('@portable-ehr/feedcore/lib/my-dao.privateMessage');
const { AppointmentRecord, RdvDispositionRecord, } = require('@portable-ehr/feedcore/lib/my-dao.rdv');
const { pingFeedHubServer, pingBackendServer } = require('@portable-ehr/feedcore/lib/nao.feedhub');
const feedhubOps = require('@portable-ehr/feedcore/lib/feedhub.ops');

if ([false, true][ 0 ]) {
    const { ARecord, } = require('../feedCore/lib/my-dao.test');
    logger.debug(ARecord.Name);
}

const self = module.exports;

class DispensaryProvider extends Provider {
    constructor(props) {
        super(props);

    }

    static _PullBundles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.pullPractitionerBundle, PractitionerRecord ]
            , [providerProto.pullPatientBundle, PatientRecord]
            , [providerProto.pullAppointmentBundle, AppointmentRecord]
        ]);
    }

    static _PullSingles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.pullSinglePractitioner, PractitionerRecord ]
            , [providerProto.pullSinglePatient, PatientRecord]
            , [providerProto.pullSinglePrivateMessageContent, PrivateMessageContentRecord]
            , [providerProto.pullSingleAppointment, AppointmentRecord]
        ]);
    }

    static _PushSingles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.pushSinglePatientReachability, PatientReachabilityRecord]
            , [providerProto.pushSinglePrivateMessageStatus, PrivateMessageStatusRecord]
            , [providerProto.pushSingleRdvDisposition, RdvDispositionRecord]
        ]);
    }

    static _AddSingles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.addSinglePractitioner, PractitionerRecord ]
            , [providerProto.addSinglePatient, PatientRecord]
        ]);
    }

    static _UpdateSingles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.updateSinglePractitioner, PractitionerRecord ]
            , [providerProto.updateSinglePatient, PatientRecord]
        ]);
    }

    static _RetireSingles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.retireSinglePractitioner, PractitionerRecord ]
            , [providerProto.retireSinglePatient, PatientRecord]
        ]);
    }

    static _Search() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.searchPractitioner, PractitionerRecord ]
            , [providerProto.searchPatient, PatientRecord]
        ]);
    }

    static _PullBackendBundles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.pullBackendIdIssuersBundle, feedhubOps.PullBackendIdIssuersBundle ]
            , [providerProto.pullBackendPatientBundle, feedhubOps.PullBackendPatientBundle]
        ]);
    }

    static _PullBackendSingles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.pullSingleBackendPatientReachability, feedhubOps.PullSingledBackendPatientReachability ]
            // , [providerProto.pullSingleBackendPatientReachability, feedhubOps.PullSingledBackendPatientReachability]
        ]);
    }

    static _PushBackendSingles() {
        const This = this;              //  This: the static 'this' refers to the class|constructor, not the instance.
        const providerProto = This.prototype;
        return new Map([[providerProto.pushSinglePrivateMessageNotification, feedhubOps.PushSinglePrivateMessageNotification ]
            // , [providerProto.pushSinglePrivateMessageNotification, PushSinglePrivateMessageNotification]
        ]);
    }

    /**
     *
     * @return {Promise<boolean>}
     */
    async pingFeedHub() {
        try {
            await pingFeedHubServer({verbose:this.verbose}, this.feedAlias);
            logger.info(`${this.Name} : Success pinging ${this.feedTag} FeedHub.`);
            return true;
        }
        catch (e) {
            logger.error(`${this.Name} : Error pinging ${this.feedTag} FeedHub.`, e);
            return false;
        }
    }

    /**
     *
     * @return {Promise<boolean>}
     */
    async pingBackend() {
        try {
            await pingBackendServer(this.feedAlias,{verbose:this.verbose});
            logger.info(`${this.Name} : Success pinging ${this.feedTag} backend.`);
            return true;
        }
        catch (e) {
            logger.error(`${this.Name} : Error pinging ${this.feedTag} backend.`, e);
            return false;
        }
    }


}
self.Provider = DispensaryProvider;

logger.trace("Initialized ...");
