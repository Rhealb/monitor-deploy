{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local admincenterstorages = (import "../admincenter/deploy/admincenterstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
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
           admincenterstorages.items
         else if deploytype == "podservice" then
           admincenterpodservice.items
         else
           error "Unknow deploytype",
}
