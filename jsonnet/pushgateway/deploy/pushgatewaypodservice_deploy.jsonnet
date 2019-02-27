{
  // pushgateway deploy global variables
  _pushgatewayinstancecount:: 1,
  _pushgatewayreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _pushgatewaydockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _pushgatewayrequestcpu:: "0",
  _pushgatewayrequestmem:: "0",
  _pushgatewaylimitcpu:: "0",
  _pushgatewaylimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _pushgatewayexternalports:: [],
  _pushgatewaynodeports:: [],
  _pushgatewayexservicetype:: "ClusterIP",
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
  local externalport1s = $._pushgatewayexternalports.port1s,
  
  local nodeport1s = $._pushgatewaynodeports.port1s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["pushgatewayutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._pushgatewayexservicetype != "None" then
  [
    (import "../pushgatewayservice.jsonnet") + {
      // override pushgatewayservice global variables
      _pushgatewayprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._pushgatewayprefix + "-" + super._mname + num + "-ex",
      _sname: self._pushgatewayprefix + "-" + super._mname + num,
      _servicetype: $._pushgatewayexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":9091",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":9091",
        
      ],
    } for num in std.range(1, $._pushgatewayinstancecount)
  ]
  else
  []) + [
    (import "../pushgatewayservice.jsonnet") + {
      // override pushgatewayservice global variables
      _pushgatewayprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._pushgatewayprefix + "-" + super._mname + num,
    } for num in std.range(1, $._pushgatewayinstancecount)
  ] + [
    (import "../pushgateway.jsonnet") + {
      // override pushgateway global variables
      _pushgatewayprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._pushgatewayprefix + "-" + super._mname + num,
      _dockerimage: $._pushgatewaydockerimage,
      _replicacount: $._pushgatewayreplicas,
      _containerrequestcpu:: $._pushgatewayrequestcpu,
      _containerrequestmem:: $._pushgatewayrequestmem,
      _containerlimitcpu:: $._pushgatewaylimitcpu,
      _containerlimitmem:: $._pushgatewaylimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._pushgatewayprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._pushgatewayinstancecount)
  ],
}
