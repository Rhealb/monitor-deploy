{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,
  local componentoramah = globalconf.mysql.componentoramah,

  local mysqlstorages = (import "../mysql/deploy/mysqlstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local mysql = globalconf.mysql,
    _utilsstoretype:: globalconf.utilsstoretype,
    _mysqldatastoragesize:: mysql.mysqldatapvcstoragesize,
  },

  local mysqlpodservice = (import "../mysql/deploy/mysqlpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local mysql = globalconf.mysql,
    _utilsstoretype:: globalconf.utilsstoretype,
    _creatdbstart:: mysql.creatdbstart,
    _databases:: mysql.databases,
    _mysqlpassword:: mysql.password,
    _mysqlexservicetype:: mysql.exservicetype,
    _mysqldockerimage:: mysql.image,
    _externalports:: mysql.externalports,
    _mysqlnodeports:: mysql.nodeports,
    _mysqlinstancecount:: mysql.instancecount,
    _mysqlrequestcpu:: mysql.requestcpu,
    _mysqlrequestmem:: mysql.requestmem,
    _mysqllimitcpu:: mysql.limitcpu,
    _mysqllimitmem:: mysql.limitmem,
  },

  local amahmysqlstorages = (import "../mysql/deploy/amahmysqlstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahmysqlpodservice = (import "../mysql/deploy/amahmysqlpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahmysql = globalconf.mysql.amah,
    _mysqlusername:: amahmysql.username,
    _mysqlpassword:: amahmysql.password,
    _amahmysqlexservicetype:: amahmysql.exservicetype,
    _amahmysqldockerimage:: amahmysql.image,
    _amahmysqlexternalports:: amahmysql.externalports,
    _amahmysqlnodeports:: amahmysql.nodeports,
    _amahmysqlinstancecount:: amahmysql.instancecount,
    _amahmysqlrequestcpu:: amahmysql.requestcpu,
    _amahmysqlrequestmem:: amahmysql.requestmem,
    _amahmysqllimitcpu:: amahmysql.limitcpu,
    _amahmysqllimitmem:: amahmysql.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahmysqlstorages.items
           else
             mysqlstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
              mysqlpodservice.items
           else if componentoramah == "amah" then
              amahmysqlpodservice.items
           else if componentoramah == "both" then
              mysqlpodservice.items + amahmysqlpodservice.items
           else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",
}
