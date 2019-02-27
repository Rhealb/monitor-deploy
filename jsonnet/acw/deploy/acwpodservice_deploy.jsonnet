{
  // acw deploy global variables
  _acwinstancecount:: 1,
  _acwreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _acwdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _acwrequestcpu:: "0",
  _acwrequestmem:: "0",
  _acwlimitcpu:: "0",
  _acwlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _acwexternalports:: [],
  _acwnodeports:: [],
  _acwexservicetype:: "ClusterIP",
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
  local externalport1s = $._acwexternalports.port1s,
  
  local nodeport1s = $._acwnodeports.port1s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["acwutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._acwexservicetype != "None" then
  [
    (import "../acwservice.jsonnet") + {
      // override acwservice global variables
      _acwprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._acwprefix + "-" + super._mname + num + "-ex",
      _sname: self._acwprefix + "-" + super._mname + num,
      _servicetype: $._acwexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":8090",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":8090",
        
      ],
    } for num in std.range(1, $._acwinstancecount)
  ]
  else
  []) + [
    (import "../acwservice.jsonnet") + {
      // override acwservice global variables
      _acwprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._acwprefix + "-" + super._mname + num,
    } for num in std.range(1, $._acwinstancecount)
  ] + [
    (import "../acw.jsonnet") + {
      // override acw global variables
      _acwprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._acwprefix + "-" + super._mname + num,
      _dockerimage: $._acwdockerimage,
      _replicacount: $._acwreplicas,
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _containerrequestcpu:: $._acwrequestcpu,
      _containerrequestmem:: $._acwrequestmem,
      _containerlimitcpu:: $._acwlimitcpu,
      _containerlimitmem:: $._acwlimitmem,
      _s3utilspath:: self._acwprefix + "-" + cephbasename[0],
      _envs: [
        "BD_SUITE_PREFIX:" + self._acwprefix,
        "SCRIPT_EXPORTER:" + $._script_exporter,
        "AUTOMATION:" + $._automation,
        "ALERT_MANAGER:" + $._alert_manager,
        "CONFIG_SERVICE_SERVER:" + $._config_service_server,
        "STORAGE_TYPE:" + self._typeofutilsstorage,
        "S3BUCKET:" + $._s3bucket,
        "S3KEY:" + self._s3utilspath + "/acw/scripts",
        "TIMEOUT:" + $._Timeout,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/acw/entry/entrypoint.sh" ],
    } for num in std.range(1, $._acwinstancecount)
  ],
}
