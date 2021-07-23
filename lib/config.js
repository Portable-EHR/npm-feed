/*
 * Copyright © Portable EHR inc, 2021
 */

'use strict';

const fs       = require('fs');

const { niceJSON } = require('@portable-ehr/nodecore/lib/utils');
const { NodeConfig:feedCore_NodeConfig, nodeConfig } = require('@portable-ehr/feedcore/lib/config');
const { Dispensary, } = require('./config.feed');

const self = module.exports;


class NodeConfig extends feedCore_NodeConfig {

    constructor(srcJsOb, node) {
        super(srcJsOb, node);
        // const configLogger = () => this._configLogger;      //  Will return undefined after config time!

        if ([false, true][ 0 ])   //  persist config
            fs.writeFileSync(`${node.launchParams.processPath}/bli.json`, niceJSON(this));

        delete this._configLogger;                                                              //  Done configuring.
    }

    static get Feed() { return Dispensary; }
    get Feed() { return Dispensary; }

    get dispensaries()  { return this._feeds; }
}

self.nodeConfig = node => nodeConfig(node, NodeConfig);
