{
  // engine deploy global variables
  _engineinstancecount:: 1,
  _enginereplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _enginedockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _enginerequestcpu:: "0",
  _enginerequestmem:: "0",
  _enginelimitcpu:: "0",
  _enginelimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _engineexternalports:: [],
  _enginenodeports:: [],
  _engineexservicetype:: "ClusterIP",
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
  local externalport1s = $._engineexternalports.port1s,
  local externalport2s = $._engineexternalports.port2s,
  
  local nodeport1s = $._enginenodeports.port1s,
  local nodeport2s = $._enginenodeports.port2s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["engineutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._engineexservicetype != "None" then
  [
    (import "../engineservice.jsonnet") + {
      // override engineservice global variables
      _engineprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._engineprefix + "-" + super._mname + num + "-ex",
      _sname: self._engineprefix + "-" + super._mname + num,
      _servicetype: $._engineexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":9090",
        "port2" + utils.addcolonforport(externalport2s[num - 1]) + ":8092",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":9090",
        "port2" + utils.addcolonforport(nodeport2s[num - 1]) + ":8092",
        
      ],
    } for num in std.range(1, $._engineinstancecount)
  ]
  else
  []) + [
    (import "../engineservice.jsonnet") + {
      // override engineservice global variables
      _engineprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._engineprefix + "-" + super._mname + num,
    } for num in std.range(1, $._engineinstancecount)
  ] + [
    (import "../engine.jsonnet") + {
      // override engine global variables
      _engineprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._engineprefix + "-" + super._mname + num,
      _dockerimage: $._enginedockerimage,
      _replicacount: $._enginereplicas,
      _typeofutilsstorage: $._utilsstoretype,
      _initcontainerimage: $._initcontainerimage,
      _containerrequestcpu:: $._enginerequestcpu,
      _containerrequestmem:: $._enginerequestmem,
      _containerlimitcpu:: $._enginelimitcpu,
      _containerlimitmem:: $._enginelimitmem,
      _s3utilspath:: self._engineprefix + "-" + cephbasename[0],
      _envs: [
        "BD_SUITE_PREFIX:" + self._engineprefix,
        "GOMAXPROCS:" + $._GoMaxProcs,
        "RETAIN_TIME:" + $._RetainTime,
        "UtilsStoreType:" + self._typeofutilsstorage,
        "S3BUCKET:" + $._s3bucket,
        "S3KEY:" + self._s3utilspath,
        "SYNCINTERVAL:" + $._SyncInterval,
        "TIMEOUT:" + $._Timeout,
      ],
      _volumemounts:: $._volumemountscommon + [

      ],
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/engine/entry/entrypoint.sh" ],
    } for num in std.range(1, $._engineinstancecount)
  ],
}
