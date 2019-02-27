{
  // mockserver deploy global variables
  _mockserverinstancecount:: 1,
  _mockserverreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _mockserverdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _mockserverrequestcpu:: "0",
  _mockserverrequestmem:: "0",
  _mockserverlimitcpu:: "0",
  _mockserverlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _mockserverexternalports:: [],
  _mockservernodeports:: [],
  _mockserverexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
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
  local externalport1s = $._mockserverexternalports.port1s,
  
  local nodeport1s = $._mockservernodeports.port1s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["mockserverutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._mockserverexservicetype != "None" then
  [
    (import "../mockserverservice.jsonnet") + {
      // override mockserverservice global variables
      _mockserverprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mockserverprefix + "-" + super._mname + num + "-ex",
      _sname: self._mockserverprefix + "-" + super._mname + num,
      _servicetype: $._mockserverexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":8001",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":8001",
        
      ],
    } for num in std.range(1, $._mockserverinstancecount)
  ]
  else
  []) + [
    (import "../mockserverservice.jsonnet") + {
      // override mockserverservice global variables
      _mockserverprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mockserverprefix + "-" + super._mname + num,
    } for num in std.range(1, $._mockserverinstancecount)
  ] + [
    (import "../mockserver.jsonnet") + {
      // override mockserver global variables
      _mockserverprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mockserverprefix + "-" + super._mname + num,
      _dockerimage: $._mockserverdockerimage,
      _replicacount: $._mockserverreplicas,
      _containerrequestcpu:: $._mockserverrequestcpu,
      _containerrequestmem:: $._mockserverrequestmem,
      _containerlimitcpu:: $._mockserverlimitcpu,
      _containerlimitmem:: $._mockserverlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._mockserverprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._mockserverinstancecount)
  ],
}
