{
  // amahmysql deploy global variables
  _amahmysqlinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _amahmysqldockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahmysqlrequestcpu:: "0",
  _amahmysqlrequestmem:: "0",
  _amahmysqllimitcpu:: "0",
  _amahmysqllimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahmysqlexternalports:: [],
  _amahmysqlnodeports:: [],
  _amahmysqlexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _mysqlserver:: $._suiteprefix + "-mysql1:3306",
  _mysqlusername:: "root",
  _mysqlpassword:: "123456",
  _volumemountscommon:: if $._utilsstoretype == "ConfigMap" then
                          [
                            "utilsconf:/opt/mntcephutils/conf:true",
                            "utilsentry:/opt/mntcephutils/entry:true",
                            "utilsscripts:/opt/mntcephutils/scripts:true",
                          ]
                        else if $._utilsstoretype == "FS" then
                          [
                            cephstoragename[0] + ":/opt/mntcephutils:true",
                          ],
  _storagescommon:: if $._utilsstoretype == "ConfigMap" then
                      []
                    else if $._utilsstoretype == "FS" then
                      [
                        cephstoragename[0],
                      ],
  _volumescommon:: if $._utilsstoretype == "ConfigMap" then
                     [
                       "utilsconf:configMap:" + storageprefix + "-" + cephbasename[0] + "-conf",
                       "utilsentry:configMap:" + storageprefix + "-" + cephbasename[0] + "-entry",
                       "utilsscripts:configMap:" + storageprefix + "-" + cephbasename[0] + "-scripts",
                     ]
                   else if $._utilsstoretype == "FS" then
                     [],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalamahports = $._amahmysqlexternalports.amahports,

  local nodeamahports = $._amahmysqlnodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["mysqlutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahmysqlexservicetype != "None" then
  [
    (import "../amahmysqlservice.jsonnet") + {
      // override amahmysqlservice global variables
      _amahmysqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahmysqlprefix + "-" + super._mname + "-ex",
      _sname: self._amahmysqlprefix + "-" + super._mname,
      _servicetype: $._amahmysqlexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "amahport" + utils.addcolonforport(externalamahports[0]) + ":8084",
      ],
      _nodeports: [
        "amahport" + utils.addcolonforport(nodeamahports[0]) + ":8084",
      ],
    }
  ]
  else
  []) + [
    (import "../amahmysqlservice.jsonnet") + {
      // override amahmysqlservice global variables
      _amahmysqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahmysqlprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahmysql.jsonnet") + {
      // override amahmysql global variables
      _amahmysqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahmysqlprefix + "-" + super._mname,
      _dockerimage: $._amahmysqldockerimage,
      _replicacount: $._amahmysqlinstancecount,
      _containerrequestcpu:: $._amahmysqlrequestcpu,
      _containerrequestmem:: $._amahmysqlrequestmem,
      _containerlimitcpu:: $._amahmysqllimitcpu,
      _containerlimitmem:: $._amahmysqllimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahmysqlprefix,
        "BD_MYSQL_SERVER:" + $._mysqlserver,
        "BD_MYSQL_USERNAME:" + $._mysqlusername,
        "BD_MYSQL_PASSWORD:" + $._mysqlpassword,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
