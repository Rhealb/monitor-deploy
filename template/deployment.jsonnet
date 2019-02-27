(import "../common/deployment.jsonnet") {
  // global variables
  _%NAME%prefix:: "tbd",

  // override super global variables
  _mname: "%NAME%",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-plyql-0.11.2:0.1",
  _envs: [
  ],
  _command:: ["/opt/entrypoint.sh", ],
}
