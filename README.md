# npm-feed
A Feed default implementation responding to the Portable EHR [**Feed API intended at FeedHub** specification](
https://feed.portableehr.io:4004/docs/), and using npm for feedcore and nodecore modules.

## Feed Installation

Install this Portable EHR npm-feed git repo by running :

`$ git clone git@github.com:Portable-EHR/npm-feed.git my-base-path` where `my-base-path` is the path where this repo 
will be git cloned.

then run :

`$ cd my-base-path/`

`$ npm install` to install all the npm packages specified in the project `package.json` file. 


The devop in charge of this installation will also make sure that some DB is provided with a configuration matching 
that of the database described in the config file spec below.     

From there, two directories are required to provide : 
 - the https certificate & key, and 
 - the config file
  
for the project. The .gitignore file provided with this repo already contains entries for directories 
`/resources/instance/` and `/resources/process/` specifically for this purpose. So let's create that :

`$ mkdir resources`

`$ cd resources`

`$ mkdir instance`

`$ mkdir process`

In `my-base-path/resources/instance/`, a copy of the certificate and key files (respectively named `server.cert` and 
`server.key`) used to run the https server should be provided in a subdirectory of the name of the running environment. 
For example, in the `local` environment instance, the certificate and key to run the https server should be found under :

 - `my-base-path/resources/instance/local/server.cert`, and   

 - `my-base-path/resources/instance/local/server.key`.   

The server code will likely be run in more than the `local` development environment; for example, in some `staging` and 
`prod` environments.  In that case, the `server.cert` and `server.key` files for the relevant environment instances must
respectively be copied in :

 - `my-base-path/resources/instance/staging`, and   

 - `my-base-path/resources/instance/prod` subdirectories.   

One might choose to keep all of these in a private git repo built specifically for instance resources purpose.

In the same way, the `my-base-path/resources/process/` subdirectory will hold the different configuration files for the
different environments. For example, with the same `local`, `staging` and `prod` environments, and a config file named 
`feedConfig.json` one is expected to provide the configuration files :

 - `my-base-path/resources/process/local/feedConfig.json`,   

 - `my-base-path/resources/process/staging/feedConfig.json`,   

 - `my-base-path/resources/process/prod/feedConfig.json`,   

each for their specific environment. Once more, these could also all have been packaged as part of a single process 
resources private git repo. 

Also note that `instance` resources are kept apart from `process` resources because there might be a case where more 
than a single Feed processes (say, two running instances of some Node.js Feed code answering on different ports) can run 
on a single server instance (physical or virtual machine), sharing the same https server certificate and key files, but 
obviously different configs.  


### Running the Feed server

In order to run this Feed server, at least one OS environment variable (`PEHR_NODE_CWD`) must be set before invoking 
Node.js:

 - `PEHR_NODE_CWD` : the path of the base directory of this repo (it would be `my-base-path` in the Feed Installation 
 example above).
 
The Feed server could then be started by running : 
 
`$ PEHR_NODE_CWD=my-base-path node my-base-path/node_modules/@portable-ehr/nodecore/bin/NodeServer`

provided that the following node modules can be found in `my-base-path/lib/` :

 -  `my-base-path/lib/node.js` : a node module exporting a class extending the Node class from npm module `@portable-ehr/nodecore/lib/node`,    

 -  `my-base-path/lib/config.js` : a node module exporting a class extending the NodeConfig class from npm module `@portable-ehr/nodecore/lib/config`,    

 -  `my-base-path/lib/sapi.js` : a node module exporting a class extending the Provider class from npm module `@portable-ehr/feedcore/lib/sapi`,    

plus the following node module, in `my-base-path/`:

 - `my-base-path/NodeServerApp.js` : a node module which export an `async start(logger)` function.
 
 If that `async start(logger)` function plus those three `Node`, `NodeConfig` and `Provider` classes are provided, but 
 in different modules than those specified above, a relevant subset of the following OS environment variables must also 
 be defined to override the following default module path values (relative to `PEHR_NODE_CWD=my-base-path`): 
 
  - `PEHR_NODE_LIB_NODE=/lib/node.js`,  
 
  - `PEHR_NODE_LIB_CONFIG=/lib/config.js`,  
 
  - `PEHR_NODE_LIB_SAPI=/lib/sapi.js`,  
 
  - `PEHR_NODE_APP=/NodeServerApp.js`.  


#### The Portable EHR NodeServer parameters

When launching `node my-base-path/node_modules/@portable-ehr/nodecore/bin/NodeServer`, the following parameters can be 
set, which will tune the operational setup used and generated by the running process : 
 
 -  `-e environment` : the name of the environment where this process is run (example: `local`),
 
 -  `-a application` : the name of the application/Feed that is run (example: `dispensary`),
 
 -  `-i instance` : an alias for the (physical or virtual) server where this Feed is run (example: `myOrgServerAlias`),
 
 -  `-p process` : an alias given to the running process that is run (example: `myBizFeed`),
 
 -  `-n netFlavor` : the alias of the network sub-config to be selected in config (example: `https0`),
 
 -  `-f feedFlavor` : the alias of feeds sub-config to be selected in config (example: `myFeeds`),
 
 -  `-r rootPath` : the path to the structure of directories and files used/generated by the Feed running process (example: `/mnt/media/PortableEHR`),
 
 -  `-c configFilename` : the .json config file name to be loaded (example: `feedConfig.json`),

So with all the above taken into account, the Feed server is launched by issuing the following command:

`$ PEHR_NODE_CWD=my-base-path node my-base-path/node_modules/@portable-ehr/nodecore/bin/NodeServer -e local 
-a dispensary -i myOrgServerAlias -p myBizFeed -n https0 -f myFeeds -c feedConfig.json`

The Feed https server certificate/key and configuration files and logs and all other operational resources are mapped 
upon a directory structure typically auto built, as follows, using the above parameter values, at the first launch of 
the Feed Node.js app :

 - `/mnt/media/PortableEHR/` : the path of the base “operation” directory,
 
 - `/mnt/media/PortableEHR/local/myOrgServerAlias/` : the base server instance directory in `local` environment,
 
 - `/mnt/media/PortableEHR/local/myOrgServerAlias/resources/` : the directory where the server.cert and server.key used 
 by the https server are placed.
 
 - `/mnt/media/PortableEHR/local/myOrgServerAlias/dispensary.myBizFeed/` : the base Feed server process subdirectory 
 for operation files.
 
 - `/mnt/media/PortableEHR/local/myOrgServerAlias/dispensary.myBizFeed/resources/` : the Feed server process directory 
 for configuration files and scripts in `local` env.
 
 - `/mnt/media/PortableEHR/local/myOrgServerAlias/dispensary.myBizFeed/log/` : the Feed server process directory for log
  files in the `local` environment.

  
### The Portable EHR Feed config file

At a minimum, a Portable EHR Feed `.json` config file includes the following properties that will be   
documented below : 

```
{
    "language": "en",
    "nodeName": "Portable EHR generic Dispensary Feed (Local)",
    "selfRestServers": {
        "loHttps": {
            "port"  : 4004,
            "scheme": "https",
            "host"  : "localhost",
            "comment": "generic Feed HTTPS Server on local machine"
        }
    },
    "feedHubServers": {
        "ioHttps": {
            "port"  : 3004,
            "scheme": "https",
            "host"  : "feed.portableehr.io",
            "credentials": "myCredsForPartnerFeedHub",
            "comment": "The https FeedHub in PortableEHR partner environment"
        }
    },
    "databaseConfigs": {
        "loDispensary": {
            "serverNetworkSpec": {
                "endpoint"  : {
                    "host": "localhost",
                    "port": 3306
                }
            },
            "user"             : "devel",
            "password"         : "some mysql password for generic dispensary feed or whatever",
            "database"         : "Dispensary",
            "debug"            : false,
            "comment": "Dispensary MySQL Server on local machine"
        }
    },
    "apiUsers": {
        "admin": {
            "method": "bearer",
            "password": "some apiUser password for admin or whatever",
            "role": "admin",
            "feeds": [
                "myFeed"
            ]
        },
        "pehrPartnerFeedHub": {
            "method": "bearer",
            "password": "some apiUser password for pehrPartnerFeedHub or whatever",
            "role": "feedhub",
            "feeds": [
                "myFeed",
            ]
        },
        "someFeedStaff": {
            "method": "bearer",
            "password": "some apiUser password for someFeedStaff or whatever",
            "role": "feedstaff",
            "feeds": [
                "myFeed"
            ]
        },
        "nobody": {
            "method": "none",
            "password": "nobody",
            "role": "nobody",
            "feeds": []
        }
    },
    "credentials": {
        "myCredsForPartnerFeedHub": {
            "username": "myOrg",
            "password": "some password for myOrg to access partner FeedHub or whatever"
        }
    },
    "netFlavors": {
        "https0": {
            "selfRestServer": "loHttps",
            "feedHubServer": "ioHttps",
            "databaseConfig": "loDispensary"
        }
    },
    "feedFlavors": {
        "myFeeds": [
            "myFeed0"
        ]
    },
    "feedConfigs": {
        "myFeed0": {
            "feedAlias" : "myFeed",
            "epochStart": "1 may 2021",
            "verbose": false,
            "feedHubServer": "loHttps",
            "feedHubCredentials": "myCredsForPartnerFeedHub",
            "comment": "All the other Feed specific configs will be added here."
        }
    }
}
```

 - `"language" : "en"` : as of now, the english language is the only one supported.

 - `"nodeName" : "Whatever name"` : for strict annotation purpose.

 - 
       "selfRestServers" : { 
               "loHttps" : {  
                    "port"  : 4004,  
                    "scheme": "https",  
                    "host"  : "localhost",  
                    "comment": "generic Feed HTTPS Server on local machine"  
               }  
         }
     The `selfRestServers` object is a collection of `selfRestServer` config objects, each identified by a `selfRestServerAlias` 
     (`"loHttps"` in the above example). A `selfRestServer` config is that of the Feed web server itself, answering `http` 
     or `https` requests.  Different configs can be defined each with a different `selfRestServerAlias` and be referenced 
     elsewhere in the config file. Each `selfRestServer` object is mapped to a `@portable-ehr/nodecore/lib/config.nao` 
     `Endpoint` object in the Feed, and therefore allows the following properties to be defined :    
      
      - `"port"` : the TCP port that will answer the web requests,
      
      - `"scheme"` : either `http` or `https`,
      
      - `"host"` : typically `localhost`, but might be an IP address or Fully Qualified Domain Name mapping to 
      a specific interface of the host.


 - 
       "feedHubServers" : {
           "ioHttps" : {
               "scheme": "https",
               "host"  : "feed.portableehr.io",
               "credentials": "myCredsForPartnerFeedHub",
               "comment": "The https FeedHub in PortableEHR partner environment"
           }
       },
   The `feedHubServers` object is a collection of `feedHubServer` config objects, each identified by a `feedHubServerAlias` 
   (`"ioHttps"` in the above example). A `feedHubServer` config is that of a FeedHub web server that this Feed interacts 
   with. Different configs can be defined each with a different `feedHubServerAlias` and be referenced elsewhere in the 
   config file. Each `feedHubServer` object is mapped to a `@portable-ehr/nodecore/lib/config.nao` `Endpoint` object in 
   the Feed, and therefore allows the following properties to be defined :    
    
    - `"port"` : the TCP port of the FeedHub that will answer the web requests,
    
    - `"scheme"` : either `http` or `https`, with `https` strongly recommended,
    
    - `"host"` : an IP address or Domain Name identifying an interface of the FeedHub host,
    
    - `"credentials"` : a reference to a `credentials` object (defined further below), via its `credentialAlias`.


 - 
       "databaseConfigs": {
           "loDispensary": {
               "serverNetworkSpec": {
                   "endpoint"  : {
                       "host": "localhost",
                       "port": 3306
                   }
               },
               "user"             : "devel",
               "password"         : "some mysql password for generic dispensary feed or whatever",
               "database"         : "Dispensary",
               "debug"            : false,
               "comment": "Dispensary MySQL Server on local machine"
           }
       },
   The `databaseConfigs` object is a collection of `databaseConfig` objects, each identified by a `databaseConfigAlias` 
   (`"loDispensary"` in the above example). A `databaseConfig` is that of a MySQL database that this Feed connects to. 
   Different configs can be defined each with a different `databaseConfigAlias` and be referenced elsewhere in the 
   config file. Each `databaseConfig` object is mapped to a `@portable-ehr/nodecore/lib/config` `DatabaseConfig` object 
   in the Feed, and allows the following properties to be defined :    
    
    - `"serverNetworkSpec.endpoint.host"` : an IP address or Domain Name of the MySQL database host to connect to. 
    
    - `"serverNetworkSpec.endpoint.port"` : a TCP port number of the host to connect to the MySQL database,
    
    - `"user"` : the MySQL user to authenticate as,
    
    - `"password"` : the password of that MySQL user,
    
    - `"database"` : the name of the MySQL database to use for this connection.


 - 
       "apiUsers": {
           "admin": {
               "method": "bearer",
               "password": "some apiUser password for admin or whatever",
               "role": "admin",
               "feeds": [
                   "myFeed"
               ]
           }, 
           ...
           "nobody": {
               "method": "none",
               "password": "nobody",
               "role": "nobody",
               "feeds": []
           }
       },
   The `apiUsers` object is a collection of `apiUser` config objects each identified by a `username` 
   (`"admin"`, `"pehrPartnerFeedHub"`, `"someFeedStaff"` and `"nobody"` in the above example). An `apiUser` config is 
   that of a user connecting to this Feed web server. Different configs can be defined each with a different `username`. 
   Each `apiUser` config object is mapped to a `@portable-ehr/nodecore/lib/config.auth` `ApiUser` object in the Feed, 
   and allows the following properties to be defined :
       
    - `"method"` : either `"bearer"` or special `"none"` values are allowed for a Feed, `"bearer"` being the recommended 
    safe method for `Jwt` based authentication.
      
    - `"password"` : the password associated to the `username`,
    
    - `"role"` : one of \{` "admin""`, `"feedhub"`, `"feedstaff"`, `"nobody"` \},
    
    - `"feeds"` : an array of `feedAlias` that this apiUser is allowed to interact with,
    
   Note that the `"nobody"` `apiUser`, with special `"method": "none"`, is made available for test purposes only, as its empty `"feeds"` array ensures it 
   never gives access to any Feed resources. 


 - 
       "credentials": {
           "myCredsForPartnerFeedHub": {
               "username": "myOrg",
               "password": "some password for myOrg to access partner FeedHub or whatever"
           }
       },
      
   The `credentials` object is a collection of `credential` config objects each identified by a `credentialAlias` 
   (`"myCredsForPartnerFeedHub"` in the above example). A `credential` config is that of a user connecting to some 
   external servers, typically a FeedHub web server, in the Feed context. 
   Each `credential` config object is mapped to a `@portable-ehr/nodecore/lib/config.auth` `Credentials` object in the 
   Feed, and allows the following properties to be defined :
       
    - `"username"` : the username to access a web server.
      
    - `"password"` : the password associated to the `username`,


 - 
       "netFlavors": {
           "https0": {
               "selfRestServer": "loHttps",
               "feedHubServer": "ioHttps",
               "databaseConfig": "loDispensary"
           }
       },
   The `netFlavors` object is a collection of `netFlavor` config objects each identified by a `netFlavorAlias` 
   (`"https0"` in the above example). A `netFlavor` config is a collection of network related config aliases to fully 
   characterize the network-related config to be run. One of the `netFlavor` configs is selected at the launch of 
   Node.js Feed by specifying the `netFlavorAlias` with the -n parameter. Each `netFlavor` config object allows the 
   following properties to be defined :
       
    - `"selfRestServer"` : the `selfRestServerAlias` identifying which of the defined `selfRestServers` config(s) to use.
       
    - `"feedHubServer"` : the `feedHubServerAlias` which one of the defined`feedHubServers` config(s) to use.
       
    - `"databaseConfig"` : the `feedHubServerAlias` identifying which of the defined `feedHubServers` config(s) to use.


 - 
       "feedFlavors": {
           "myFeeds": [
               "myFeed0"
           ]
       },
   The `feedFlavors` object is a collection of `feedFlavor` config objects each identified by a `feedFlavorAlias` 
   (`"myFeeds"` in the above example). A `feedFlavor` config is a collection of `feedConfigAlias`es. One of the 
   `feedFlavor` config is selected at the launch of Node.js Feed, by specifying the `feedFlavorAlias` with the -f 
   parameter. It fully characterizes the list of `feedConfigs` to be run (just `myFeed0`, in the example above). 


 - 
       "feedConfigs": {
           "myFeed0": {
               "feedAlias" : "myFeed",
               "epochStart": "1 may 2021",
               "verbose": false,
               "feedHubServer": "loHttps",
               "feedHubCredentials": "myCredsForPartnerFeedHub",
               "comment": "All the other Feed specific configs will be added here."
            }
       },
   The `feedConfigs` object is a collection of `feedConfig` objects each identified by a `feedConfigAlias` 
   (`"myFeed0"` in the above example). A `feedConfig` is an extendable config object providing all the relevant 
   configuration options for a Feed in itself, which is a dataset acting as source and drain of data for Portable EHR 
   [**Feed API intended at FeedHub** specification](https://feed.portableehr.io:4004/docs/). Each `feedConfig` object 
   allows at least the following properties to be defined :
       
    - `"feedAlias"` : if provided, overrides the `feedConfigAlias` identifying the `feedConfig` as the official 
    `feedAlias` of the Feed. The `feedAlias` must have been provisioned by the OAMP of Portable EHR to be accepted in 
    almost any interaction a Feed has with a Portable EHR FeedHub.
       
    - `"epochStart"` : the maximal time horizon used by this Feed. In the context of the Feed API mentioned above, the 
    Feed will only consider data that's been created or updated since that `epochStart`. 
       
    - `"verbose"` : flag indicating if the logging relative to that Feed has to be verbose or not.
       
    - `"feedHubServer"` : if provided, overrides the `feedHubServer` property specified in that of the `netFlavors` 
    config objects which `netFlavorAlias` was selected by the -n parameter at the Node.js Feed launch.
       
    - `"feedHubCredentials"` : if provided, overrides the `credentials` property of the `feedHubServer` property 
    specified in that of the `netFlavors` config objects which `netFlavorAlias` was selected by the -n parameter at 
    the Node.js Feed launch.
    
    - `"comment*"` : `"comment"` immediately followed by any other string of character(s) (`"comment"`,
    `"comment2"`, `"commentABC"`, etc.) : all across this config file, `"comments*"` are collected and simply ignored.
    
   The feedConfig object is expected to be extended by each specific Feed implementation according to their respective 
   requirements.