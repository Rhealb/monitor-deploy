( import "../common/service.jsonnet" ) {
  // global variables
  _admincenterprefix:: "",

  // override super global variables
  _mname: "admin-center",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "port1:50052",
    "port2:50051",
    
  ],
}
