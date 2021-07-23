/*
 * Copyright © Portable EHR inc, 2021
 */

'use strict';
const fileTag = __filename.replace(/(.*\/)(.+?)([.]js)?$/, '$2');

const logger = require('log4js').getLogger(fileTag);

const { Feeds, Feed, EFeedKind:{dispensary: eDispensaryKind, } } = require('@portable-ehr/feedcore/lib/config.feed');

const self = module.exports;


class Dispensaries extends Feeds {
    static get Feed() { return Dispensary; }
}
self.Dispensaries = Dispensaries;

class Dispensary extends Feed {
    static get Feeds() { return Dispensaries; }
    get dispensaryId()  {return this.id; }

}
self.Dispensary = Dispensary;
Dispensaries.Setup();              //  NOTE: Dispensaries can only be .Setup() after Dispensary is defined.
Dispensary.Setup(eDispensaryKind);


logger.trace("Initialized ...");
