(import "common.jsonnet") + {
  // global variables
  _replicacount:: 1,
  _nameports:: [],
  _dockerimage:: "tbd",
  _imagepullpolicy:: "Always",
  _args:: [],
  _command:: [],
  _envs:: [],
  _sname:: $._mname,
  _slabel:: "pod",
  _volumemounts:: [],
  _volumes:: [],
  _storages:: [],
  _cephhostports:: [],
  _cephuser:: "tbd",
  _cephsecretref:: "tbd",
  _containerrequestcpu:: "0",
  _containerrequestmem:: "0",
  _containerlimitcpu:: "0",
  _containerlimitmem:: "0",
  _rollingupdatetype:: "RollingUpdate",
  _privileged:: false,
  _s3utilspath:: "bigdatautils",
  _typeofutilsstorage:: "FS",
  _initcontainerimage:: "127.0.0.1:29006/console/init-container:1.0",

  // override super global variables
  _mlabel: "dp",

  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  spec: {
    selector: {
      matchLabels: {
        app: $._sname + "-" + $._slabel,
        name: $._sname,
      },
    },
    strategy: {
      type: $._rollingupdatetype,
      rollingUpdate: {
        maxUnavailable: 1,
        maxSurge: 0,
      },
    },
    replicas: $._replicacount,
    template: {
      metadata: {
        labels: {
          app: $._sname + "-" + $._slabel,
          name: $._sname,
        },
      },
      spec: {
        containers: [
          {
            image: $._dockerimage,
            imagePullPolicy: $._imagepullpolicy,
            name: $._mname,
            args: $._args,
            command: $._command,
            local envlist = [std.splitLimit(en, ":", 1) for en in $._envs],
            env: (if $._typeofutilsstorage == "S3" then
            [{
                name: "ACCESS_KEY",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-access-key"
                  }
                }
              },
              {
                name: "SECRET_KEY",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-secret-key"
                  }
                }
              },
              {
                name: "HOST_BASE",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-s3-host"
                  }
                }
              },
              {
                name: "HOST_BUCKET",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-s3-host"
                  }
                }
              }]
            else
            []) + [
               { name: e[0], value: e[1]  } for e in envlist
            ],
            local portlist = [std.splitLimit(nameport, ":", 1) for nameport in $._nameports],
            ports: [
              { name: np[0], containerPort: std.parseInt(np[1]) } for np in portlist
            ],
            local volmountlist = [std.split(volmount, ":") for volmount in $._volumemounts],
            volumeMounts: [
              {
                name: vm[0],
                mountPath: vm[1],
                readOnly: if std.length(vm) == 3 && vm[2] == "true" then
                            false
                          else
                            false,
              } for vm in volmountlist
            ],
            resources: {
              requests: {
                memory: $._containerrequestmem,
                cpu: $._containerrequestcpu,
              },
              limits: {
                memory: $._containerlimitmem,
                cpu: $._containerlimitcpu,
              },
            },
            securityContext: {
               privileged: $._privileged,
            },
          },
        ],
        local volumelist = [std.splitLimit(volume, ":", 2) for volume in $._volumes],
        volumes: [
          {
            name: vol[0],
            [vol[1]]: if vol[1] == "hostPath" then
                        {
                          path: vol[2]
                        }
                      else if vol[1] == "cephfs" then
                        {
                          monitors: $._cephhostports,
                          user: $._cephuser,
                          path: vol[2],
                          secretRef: {
                            name: $._cephsecretref,
                          },
                        }
                      else if vol[1] == "persistentVolumeClaim" then
                        {
                          claimName: vol[2],
                        }
                      else if vol[1] == "emptyDir" then
                        {}
                      else if vol[1] == "configMap" then
                        {
                          name: vol[2],
                        }
                      else
                        error "not support volume type",
          } for vol in volumelist
        ],

        initContainers: if $._typeofutilsstorage == "S3" then
        [
          {
            name: "initcontainer",
            image: $._initcontainerimage,
            resources: {
                         limits: {
                           cpu: "0.5",
                           memory: "1Gi"
                         },
                         requests: {
                           cpu: "0.5",
                           memory: "1Gi"
                         }
                       },
            env: [
              {
                name: "ACCESS_KEY",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-access-key"
                  }
                }
              },
              {
                name: "SECRET_KEY",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-secret-key"
                  }
                }
              },
              {
                name: "HOST_BASE",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-s3-host"
                  }
                }
              },
              {
                name: "HOST_BUCKET",
                valueFrom: {
                  secretKeyRef: {
                    key: "value",
                    name: $._mnamespace + "-s3-host"
                  }
                }
              }],
            command: ["entrypoint.sh","s3-" + $._mnamespace,$._s3utilspath,"/opt/mntcephutils"],
            volumeMounts: [
              {
                name: "s3utils",
                mountPath: "/opt/mntcephutils"
              },
            ],
          },
        ] else [],
        storage: [
          {
            name: storagename,
          } for storagename in $._storages
        ],
      },
    },
  },
}
