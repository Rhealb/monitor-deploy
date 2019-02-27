{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local alertmanagerstorages = (import "../alertmanager/deploy/alertmanagerstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local alertmanagerpodservice = (import "../alertmanager/deploy/alertmanagerpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local alertmanager = globalconf.alertmanager,
    _alertmanagerexservicetype:: alertmanager.exservicetype,
    _alertmanagerdockerimage:: alertmanager.image,
    _alertmanagerexternalports:: alertmanager.externalports,
    _alertmanagernodeports:: alertmanager.nodeports,
    _alertmanagerinstancecount:: alertmanager.instancecount,
    _alertmanagerreplicas:: alertmanager.replicas,
    _alertmanagerrequestcpu:: alertmanager.requestcpu,
    _alertmanagerrequestmem:: alertmanager.requestmem,
    _alertmanagerlimitcpu:: alertmanager.limitcpu,
    _alertmanagerlimitmem:: alertmanager.limitmem,
    _mysql_server:: alertmanager.mysqlserver,
    _wechat_robot:: alertmanager.wechatrobot,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           alertmanagerstorages.items
         else if deploytype == "podservice" then
           alertmanagerpodservice.items
         else
           error "Unknow deploytype",
}
