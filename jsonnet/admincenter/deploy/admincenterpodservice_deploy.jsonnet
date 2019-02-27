{
  // admincenter deploy global variables
  _admincenterinstancecount:: 1,
  _admincenterreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _admincenterdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _admincenterrequestcpu:: "0",
  _admincenterrequestmem:: "0",
  _admincenterlimitcpu:: "0",
  _admincenterlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _admincenterexternalports:: [],
  _admincenternodeports:: [],
  _admincenterexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _initcontainerimage:: "127.0.0.1:29006/enncloud/init-container:1.0",
  _volumemountscommon:: if $._utilsstoretype == "ConfigMap" then
                          [
                            "utilsconf:/opt/mntcephutils/conf:true",
                            "utilsentry:/opt/mntcephutils/entry:true",
                            "utilsscripts:/opt/mntcephutils/scripts:true",
                          ]
                        else if $._utilsstoretype == "FS" then
                          [
                            cephstoragename[0] + ":/opt/mntcephutils:true",
                          ]
                        else if $._utilsstoretype == "S3" then
                          [
                            "s3utils:/opt/mntcephutils",
                          ]
                        else
                          [],
  _storagescommon:: if $._utilsstoretype == "ConfigMap" then
                      []
                    else if $._utilsstoretype == "FS" then
                      [
                        cephstoragename[0],
                      ]
                    else if $._utilsstoretype == "S3" then
                      []
                    else
                      [],
  _volumescommon:: if $._utilsstoretype == "ConfigMap" then
                     [
                       "utilsconf:configMap:" + storageprefix + "-" + cephbasename[0] + "-conf",
                       "utilsentry:configMap:" + storageprefix + "-" + cephbasename[0] + "-entry",
                       "utilsscripts:configMap:" + storageprefix + "-" + cephbasename[0] + "-scripts",
                     ]
                   else if $._utilsstoretype == "FS" then
                     []
                   else if $._utilsstoretype == "S3" then
                     ["s3utils:emptyDir"]
                   else
                     [],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalport1s = $._admincenterexternalports.port1s,
  local externalport2s = $._admincenterexternalports.port2s,
  
  local nodeport1s = $._admincenternodeports.port1s,
  local nodeport2s = $._admincenternodeports.port2s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["engineutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._admincenterexservicetype != "None" then
  [
    (import "../admincenterservice.jsonnet") + {
      // override admincenterservice global variables
      _admincenterprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._admincenterprefix + "-" + super._mname + num + "-ex",
      _sname: self._admincenterprefix + "-" + super._mname + num,
      _servicetype: $._admincenterexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":50052",
        "port2" + utils.addcolonforport(externalport2s[num - 1]) + ":50051",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":50052",
        "port2" + utils.addcolonforport(nodeport2s[num - 1]) + ":50051",
        
      ],
    } for num in std.range(1, $._admincenterinstancecount)
  ]
  else
  []) + [
    (import "../admincenterservice.jsonnet") + {
      // override admincenterservice global variables
      _admincenterprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._admincenterprefix + "-" + super._mname + num,
    } for num in std.range(1, $._admincenterinstancecount)
  ] + [
    (import "../admincenter.jsonnet") + {
      // override admincenter global variables
      _admincenterprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._admincenterprefix + "-" + super._mname + num,
      _dockerimage: $._admincenterdockerimage,
      _replicacount: $._admincenterreplicas,
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _containerrequestcpu:: $._admincenterrequestcpu,
      _containerrequestmem:: $._admincenterrequestmem,
      _containerlimitcpu:: $._admincenterlimitcpu,
      _containerlimitmem:: $._admincenterlimitmem,
      _s3utilspath:: self._admincenterprefix + "-" + cephbasename[0],
      _envs: [
        "BD_SUITE_PREFIX:" + self._admincenterprefix,
        "MYSQLSERVER:" + $._mysql_server,
        "STORAGETYPE:" + self._typeofutilsstorage,
        "CONSOLEGRPC:" + $._console_grpc,
        "PROMETHEUS:" + $._prometheus,
        "PROMETHEUSAMAH:" + $._prometheus_amah,
        "OSTICKETSWITCH:" + $._osticket_switch,
        "OSTICKETSREVER:" + $._osticket_server,
        "S3BUCKET:" + $._s3bucket,
        "S3KEY:" + self._s3utilspath + "/engine/conf/alerts",
        "TIMEOUT:" + $._Timeout,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/admin-center/entry/entrypoint.sh" ],
    } for num in std.range(1, $._admincenterinstancecount)
  ],
}
