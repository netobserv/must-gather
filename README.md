# NetObserv must-gather

`must-gather` is a tool built on top of [OpenShift must-gather](https://github.com/openshift/must-gather)
that expands its capabilities to gather NetObserv information.

## Usage
```sh
oc adm must-gather --image=quay.io/netobserv/must-gather
```

The command above will create a local directory with a dump of the NetObserv Operator state.
Note that this command will only get data related to the NetObserv part of the OpenShift cluster.

You will get a dump of:
- The NetObserv operator pod logs
- The NetObserv FlowCollector CRD's definition
- Dump of Loki as well as NetObserv agent pods logs

In order to get data about other parts of the cluster (not specific to NetObserv) you should
run `oc adm must-gather` (without passing a custom image). Run `oc adm must-gather -h` to see more options.

### Flags

`must-gather` provides a series of options to select which information to
collect from the cluster. The tool will always collect all control-plane logs and information.
Optional collectors can be enabled with CLI options.


To run only the default collectors:
```sh
oc adm must-gather --image=quay.io/netobserv/must-gather -- /usr/bin/gather
```

### Help Menu

At any time you can check the help menu for usage details of the NetObserv must-gather

```sh
oc adm must-gather --image=quay.io/netobserv/must-gather -- /usr/bin/gather --help
```

```
Usage: oc adm must-gather --image=quay.io/netobserv/must-gather -- /usr/bin/gather [params...]

  A client tool for gathering NetObserv information in an OpenShift cluster

  Available options:

  > To see this help menu and exit use
  --help

  > The tool will always collect all control-plane logs and information.
  > This will include:
  > - crds
  > - resources
  > - webhooks

```

## Development
You can build the image locally using the Dockerfile included.

A `makefile` is also provided. To use it, you must pass a repository via the command-line using the variable `MUST_GATHER_IMAGE`.
You can also specify the registry using the variable `IMAGE_REGISTRY` (default is [quay.io](https://quay.io)) and the tag via `IMAGE_TAG` (default is `latest`).

The targets for `make` are as follows:
- `build`: builds the image with the supplied name and pushes it
- `docker-build`: builds the image but does not push it
- `docker-push`: pushes an already-built image

For example:
```sh
make build MUST_GATHER_IMAGE=netobserv/must-gather
```
would build the local repository as `quay.io/netobserv/must-gather:latest` and then push it.
