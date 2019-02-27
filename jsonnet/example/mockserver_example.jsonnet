{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local mockserverstorages = (import "../mockserver/deploy/mockserverstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local mockserverpodservice = (import "../mockserver/deploy/mockserverpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local mockserver = globalconf.mockserver,
    _mockserverexservicetype:: mockserver.exservicetype,
    _mockserverdockerimage:: mockserver.image,
    _mockserverexternalports:: mockserver.externalports,
    _mockservernodeports:: mockserver.nodeports,
    _mockserverinstancecount:: mockserver.instancecount,
    _mockserverreplicas:: mockserver.replicas,
    _mockserverrequestcpu:: mockserver.requestcpu,
    _mockserverrequestmem:: mockserver.requestmem,
    _mockserverlimitcpu:: mockserver.limitcpu,
    _mockserverlimitmem:: mockserver.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           mockserverstorages.items
         else if deploytype == "podservice" then
           mockserverpodservice.items
         else
           error "Unknow deploytype",
}
