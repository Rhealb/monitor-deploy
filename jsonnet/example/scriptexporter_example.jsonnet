{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local scriptexporterstorages = (import "../scriptexporter/deploy/scriptexporterstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local scriptexporterpodservice = (import "../scriptexporter/deploy/scriptexporterpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local scriptexporter = globalconf.scriptexporter,
    _scriptexporterexservicetype:: scriptexporter.exservicetype,
    _scriptexporterdockerimage:: scriptexporter.image,
    _scriptexporterexternalports:: scriptexporter.externalports,
    _scriptexporternodeports:: scriptexporter.nodeports,
    _scriptexporterinstancecount:: scriptexporter.instancecount,
    _scriptexporterreplicas:: scriptexporter.replicas,
    _scriptexporterrequestcpu:: scriptexporter.requestcpu,
    _scriptexporterrequestmem:: scriptexporter.requestmem,
    _scriptexporterlimitcpu:: scriptexporter.limitcpu,
    _scriptexporterlimitmem:: scriptexporter.limitmem,
    _workspace:: scriptexporter.workspace,
    _cephpath:: scriptexporter.cephpath,
    _mysql_server:: scriptexporter.mysqlserver,
    _storage_type:: scriptexporter.storagetype,
    _s3bucket:: scriptexporter.s3bucket,
    _Timeout:: scriptexporter.Timeout,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           scriptexporterstorages.items
         else if deploytype == "podservice" then
           scriptexporterpodservice.items
         else
           error "Unknow deploytype",
}
