{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local pushpromstorages = (import "../pushprom/deploy/pushpromstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local pushprompodservice = (import "../pushprom/deploy/pushprompodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local pushprom = globalconf.pushprom,
    _pushpromexservicetype:: pushprom.exservicetype,
    _pushpromdockerimage:: pushprom.image,
    _pushpromexternalports:: pushprom.externalports,
    _pushpromnodeports:: pushprom.nodeports,
    _pushprominstancecount:: pushprom.instancecount,
    _pushpromreplicas:: pushprom.replicas,
    _pushpromrequestcpu:: pushprom.requestcpu,
    _pushpromrequestmem:: pushprom.requestmem,
    _pushpromlimitcpu:: pushprom.limitcpu,
    _pushpromlimitmem:: pushprom.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           pushpromstorages.items
         else if deploytype == "podservice" then
           pushprompodservice.items
         else
           error "Unknow deploytype",
}
