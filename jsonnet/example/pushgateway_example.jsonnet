{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local pushgatewaystorages = (import "../pushgateway/deploy/pushgatewaystorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local pushgatewaypodservice = (import "../pushgateway/deploy/pushgatewaypodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local pushgateway = globalconf.pushgateway,
    _pushgatewayexservicetype:: pushgateway.exservicetype,
    _pushgatewaydockerimage:: pushgateway.image,
    _pushgatewayexternalports:: pushgateway.externalports,
    _pushgatewaynodeports:: pushgateway.nodeports,
    _pushgatewayinstancecount:: pushgateway.instancecount,
    _pushgatewayreplicas:: pushgateway.replicas,
    _pushgatewayrequestcpu:: pushgateway.requestcpu,
    _pushgatewayrequestmem:: pushgateway.requestmem,
    _pushgatewaylimitcpu:: pushgateway.limitcpu,
    _pushgatewaylimitmem:: pushgateway.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           pushgatewaystorages.items
         else if deploytype == "podservice" then
           pushgatewaypodservice.items
         else
           error "Unknow deploytype",
}
