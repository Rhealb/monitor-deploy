{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local enginestorages = (import "../engine/deploy/enginestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local enginepodservice = (import "../engine/deploy/enginepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local engine = globalconf.engine,
    _engineexservicetype:: engine.exservicetype,
    _enginedockerimage:: engine.image,
    _initcontainerimage:: engine.initcontainerimage,
    _engineexternalports:: engine.externalports,
    _enginenodeports:: engine.nodeports,
    _engineinstancecount:: engine.instancecount,
    _enginereplicas:: engine.replicas,
    _enginerequestcpu:: engine.requestcpu,
    _enginerequestmem:: engine.requestmem,
    _enginelimitcpu:: engine.limitcpu,
    _enginelimitmem:: engine.limitmem,
    _s3bucket:: engine.s3bucket,
    _GoMaxProcs:: engine.GoMaxProcs,
    _RetainTime:: engine.RetainTime,
    _SyncInterval:: engine.SyncInterval,
    _Timeout:: engine.Timeout,
  },

  local admincenterpodservice = (import "../admincenter/deploy/admincenterpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local admincenter = globalconf.admincenter,
    _admincenterexservicetype:: admincenter.exservicetype,
    _admincenterdockerimage:: admincenter.image,
    _admincenterexternalports:: admincenter.externalports,
    _admincenternodeports:: admincenter.nodeports,
    _admincenterinstancecount:: admincenter.instancecount,
    _admincenterreplicas:: admincenter.replicas,
    _admincenterrequestcpu:: admincenter.requestcpu,
    _admincenterrequestmem:: admincenter.requestmem,
    _admincenterlimitcpu:: admincenter.limitcpu,
    _admincenterlimitmem:: admincenter.limitmem,
    _mysql_server:: admincenter.mysqlserver,
    _storage_type:: admincenter.storagetype,
    _console_grpc:: admincenter.consolegrpc,
    _prometheus:: admincenter.prometheus,
    _prometheus_amah:: admincenter.prometheusamah,
    _osticket_switch:: admincenter.osticketswitch,
    _osticket_server:: admincenter.osticketserver,
    _s3bucket:: admincenter.s3bucket,
    _Timeout:: admincenter.Timeout,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           enginestorages.items
         else if deploytype == "podservice" then
           enginepodservice.items + admincenterpodservice.items
         else
           error "Unknow deploytype",
}
