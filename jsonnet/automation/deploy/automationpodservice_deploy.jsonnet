{
  // automation deploy global variables
  _automationinstancecount:: 1,
  _automationreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _automationdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _automationrequestcpu:: "0",
  _automationrequestmem:: "0",
  _automationlimitcpu:: "0",
  _automationlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _automationexternalports:: [],
  _automationnodeports:: [],
  _automationexservicetype:: "ClusterIP",
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
  local externalport1s = $._automationexternalports.port1s,
  
  local nodeport1s = $._automationnodeports.port1s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["acwutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._automationexservicetype != "None" then
  [
    (import "../automationservice.jsonnet") + {
      // override automationservice global variables
      _automationprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._automationprefix + "-" + super._mname + num + "-ex",
      _sname: self._automationprefix + "-" + super._mname + num,
      _servicetype: $._automationexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":8091",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":8091",
        
      ],
    } for num in std.range(1, $._automationinstancecount)
  ]
  else
  []) + [
    (import "../automationservice.jsonnet") + {
      // override automationservice global variables
      _automationprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._automationprefix + "-" + super._mname + num,
    } for num in std.range(1, $._automationinstancecount)
  ] + [
    (import "../automation.jsonnet") + {
      // override automation global variables
      _automationprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._automationprefix + "-" + super._mname + num,
      _dockerimage: $._automationdockerimage,
      _replicacount: $._automationreplicas,
      _containerrequestcpu:: $._automationrequestcpu,
      _containerrequestmem:: $._automationrequestmem,
      _containerlimitcpu:: $._automationlimitcpu,
      _containerlimitmem:: $._automationlimitmem,
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _s3utilspath:: self._automationprefix + "-" + cephbasename[0],
      _envs: [
        "BD_SUITE_PREFIX:" + self._automationprefix,
        "WORKSPACE:" + $._workspace,
        "CEPHPATH:" + $._cephpath,
        "MYSQLSERVER:" + $._mysql_server,
        "ALERTMANAGER:" + $._alert_manager,
        "STORAGE_TYPE:" + self._typeofutilsstorage,
        "S3BUCKET:" + $._s3bucket,
        "S3KEY:" + self._s3utilspath  + "/acw/scripts",
        "TIMEOUT:" + $._Timeout,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/automation/entry/entrypoint.sh" ],
    } for num in std.range(1, $._automationinstancecount)
  ],
}
