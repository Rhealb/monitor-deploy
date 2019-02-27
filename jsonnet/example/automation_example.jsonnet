{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local automationstorages = (import "../automation/deploy/automationstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local automationpodservice = (import "../automation/deploy/automationpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local automation = globalconf.automation,
    _automationexservicetype:: automation.exservicetype,
    _automationdockerimage:: automation.image,
    _automationexternalports:: automation.externalports,
    _automationnodeports:: automation.nodeports,
    _automationinstancecount:: automation.instancecount,
    _automationreplicas:: automation.replicas,
    _automationrequestcpu:: automation.requestcpu,
    _automationrequestmem:: automation.requestmem,
    _automationlimitcpu:: automation.limitcpu,
    _automationlimitmem:: automation.limitmem,
    _workspace:: automation.workspace,
    _cephpath:: automation.cephpath,
    _mysql_server:: automation.mysqlserver,
    _alert_manager:: automation.alertmanager,
    _storage_type:: automation.storagetype,
    _s3bucket:: automation.s3bucket,
    _Timeout:: automation.Timeout,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           automationstorages.items
         else if deploytype == "podservice" then
           automationpodservice.items
         else
           error "Unknow deploytype",
}
