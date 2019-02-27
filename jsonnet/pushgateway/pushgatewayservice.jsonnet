( import "../common/service.jsonnet" ) {
  // global variables
  _pushgatewayprefix:: "",

  // override super global variables
  _mname: "pushgateway",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "port1:9091",
    
  ],
}
