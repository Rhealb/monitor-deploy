( import "../common/service.jsonnet" ) {
  // global variables
  _engineprefix:: "",

  // override super global variables
  _mname: "engine",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "port1:9090",
    "port2:8092",
    
  ],
}
