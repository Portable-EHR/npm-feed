/*
 * Copyright © Portable EHR inc, 2021
 */

'use strict';

const { NodeState:nodecore_NodeState, Node: nodecore_Node} = require('@portable-ehr/nodecore/lib/node');

const nodeName = "dispensary";

class Node extends nodecore_Node {
    constructor () {
        super(nodeName, {
                    appAlias:   'pehr.generic.feed',
                    appGuid:    '2928adb0-e415-11eb-8eab-9b01fb56ea45',
                    appVersion: '1.0.001'
                },
                ({ a=nodeName, e, i=`MY_SERVER`, p=`npmTest`, n=`https`, f=`default`,
                                    r=`/mnt/media/PortableEHR`, c=`${nodeName}Config.json`}) => ({a,e,i,p,n,f,r,c}),
                nodecore_NodeState);

        Object.defineProperty(this, "dispensaries", {value: this.config.dispensaries});
        Object.defineProperty(this, "initialize", {configurable:true, value: async function(app, logger) {
                await this._nodecore_initialize(app, logger);

                delete this.initialize;
            }});
    }
}

const exp = module.exports;
if (exp.constructor === {}.constructor  &&  Object.keys(exp).length === 0 ) {
    module.exports =  new Node();   //  require('../lib/node) receives the node instance on the first require call
}


