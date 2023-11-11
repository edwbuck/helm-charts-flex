<!-- vim: filetype=markdown colorcolumn=80
-->
# helm-charts-flex Configuration

[![Apache 2.0 License](https://img.shields.io/github/license/spiffe/helm-charts)](https://opensource.org/licenses/Apache-2.0)
[![Development Phase](https://github.com/spiffe/spiffe/blob/main/.img/maturity/dev.svg)](https://github.com/spiffe/spiffe/blob/main/MATURITY.md#development)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/spiffe)](https://artifacthub.io/packages/search?repo=spiffe)

## Required Settings

Some settings are required, but have no defaults.  The settings should be chosen
to match your deployment environment.  We encourage you to take a short moment
to select values that make sense for your enviornment, for example, if creating
a prototype, set the **trustdomain** to 'prototype.department.company.com'.

| Component          | Config Path | Example Values          | 
| ------------------ | ----------- | ----------------------- |
| SPIRE Trust Domain | trustdomain | propulsion.yoyodyne.com |

## Component Names

Some components support renaming.  When renaming components, we highly recommend
that you select names that would not conflict with additional chart installations.

| Component                     | Config Path         | Default Value           | 
| ----------------------------- | ------------------- | ----------------------- |
| Server Service                | server.serviceName  | { Release.Name }-server |

## In-Pod locations

Some files in the spire deployment can be relocated.  Relocating files may assist
in avoiding collisions when installing multiple SPIRE instances on the same
hardware, or may place files into locations conforming with your file placement
standards.  Below is a list of relocatable files and their default locations.

| File                          | Config Path         | Default Location            | 
| ----------------------------- | ------------------- | --------------------------- |
| Agent Configuration File      | agent.configFile    | /opt/spire/conf/agent.conf  |
| Agent Keymanager Directory\*  | agent.keyManagerDir | /opt/spire/data/agent/      |
| Server Configuration File     | server.configFile   | /opt/spire/data/server.conf |

> Note: Items marked with an asterisk (\*) are optional and will only be used
  when other configuration setttings activate them.

Changing the location of a file will automatically update the other components
to expect the file in its specified location.

## In-Node Locations

Some files that map to the nost deployment can be relocated.  Relocating files
may assist in avoiding collisions when isntalling multiple SPIRE instances on the
same node, or may place files into locations conforming with your file placement
standards.  Below is a list of relocatable files and their default locations.

| File                          | Config Path                  | Default Location           | 
| ----------------------------- | ---------------------------- | -------------------------- |
| Agent Keymanager Directory\*  | agent.hostPath.keyManagerDir | {agent.keyManagerDir}      |

> Note: Items marked with an asterisk (\*) are optional and will only be used
  when other configuration setttings activate them.

Changing the location of a file will automatically update the other components
to expect the file in its specified location.

## Image Configuration

Registries contain container images which are organized by tags.  An organization
may wish to hold the images in a local repository for better image management
or to capture local builds of SPIRE when on-site source code management is required.

The values associated with global image controls include:

| Path               | Type   | Default           |
| ------------------ | ------ | ----------------- |
| image.registry     | string | ghcr.io           |
| image.registryPort | int    |                   |
| image.tag          | string | 1.8.0             |

These controls alter all image defaults, providing a convenient way to ensure
all SPIRE components use the same set of images. These defauls can be overridden
by specific component image controls.

## Agent Configuration

Agent configuration covers the agent installation and the configured behavior
of the installed agent.  

### Agent Bootstrapping

Upon agent startup, the agent connects to the server instance through a service,
initiating the agent/node attestation process.  This attesation process uses TLS,
which requires the agent to trust the server.  The bootstrap trust bundle permits
the agent to trust the server during the bootstrap process.

| Path                            | Type   | Default | 
| ------------------------------- | ------ | ------- |
| agent.bootstrapTrustbundle.type | string | "none"  |
| agent.bootstrapTrustbundle.url  | string |         |
| agent.bootstrapTrustbundle.path | string |         |


> Note: **agent.bootstrapTrustbundle.type** can only be set to one of "none",
> "url", or "path".

### Agent Config File

The agent config file contains the configuration elements passed to the agent
at agent launch.

| Path             | Type   | Default                      | 
| ---------------- | ------ | ---------------------------- |
| agent.configFile | string | "/opt/spire/conf/agent.conf" |

**agent.configFile** controls both the in-container path of the config file as
well as the command line agent parameters that reference the config file.

### Agent Image Controls

The agent is controlled by a container defintion which pulls the agent's image
from a container repository. This image contains the spire-agent executable
which connects to the spire-server through a procedure known as agent-attestation.

The values associated with the agent image include:

| Path                     | Type   | Defaults             |
| ------------------------ | ------ | -------------------- |
| agent.image.name         | string | spire/spire-agent    |
| agent.image.registry     | string | {image.registry}     |
| agent.image.registryPort | int    | {image.registryPort} |
| agent.image.tag          | string | {image.tag}          |

> Note: These values default to other values.  If the other values are unset
> consult thier default values to determine the final value.

When settings are best applied to all images, consider setting them in the the
[Image Configuration](image_configuration) section.

Here is an example of a customized agent image, where a test agent is being
used with other non-test components.

```yaml
agent:
  image:
    name: "mycorp/spire-test-agent"
    registry: "mycorp"
    registryPort: 8080
    tag: "latest"
```

### Agent Health Checks

The agent can expose additional endpoint that can be used for health checking.
It is enabled by default, but can be disabled by setting **.agent.healthCheck.enable**
to *false*.

The values associated with the agent health checks include

| Path                          | Type   | Default     | 
| ----------------------------- | ------ | ----------- |
| agent.healthCheck.enable      | bool   | true        |
| agent.healthCheck.bindAddress | string | "localhost" |
| agent.healthCheck.bindPort    | int    | 80          |
| agent.healthCheck.livePath    | string | "/live"     |
| agent.healthCheck.readyPath   | string | "/ready"    |

> Note: The livePath indicates if the agent has died.
> While the readyPath indicates if the agent is capable of processing requests.

One may override one or more of these values by setting them in the values.yaml
file or in the "set" command line interfaces associated with your deployment.

Here is an example of a heavily customized agent health check configuration:

```yaml
agent:
  healthCheck:
    bindAddress: "0.0.0.0"
    bindPort: 8080
    livePath: "/i_am_alive"
    readyPath: "/i_am_ready"
```

And here is an eample of a disabled agent health check configuraition:

```yaml
agent:
  healthCheck:
    enable: false
```

Note that disabling agent health checks makes is much more difficult for
Kubernetes to properly assess when the agent is functional (alive) and when the 
agent is ready to service requests (ready).

### Agent Image Controls

The agent is controlled by a container defintion which pulls the agent's image
from a container repository. This image contains the spire-agent executable
which connects to the spire-server through a procedure known as agent-attestation.

The values associated with the agent image include:

| Path                     | Type   | Defaults             |
| ------------------------ | ------ | -------------------- |
| agent.image.name         | string | spire/spire-agent    |
| agent.image.registry     | string | {image.registry}     |
| agent.image.registryPort | int    | {image.registryPort} |
| agent.image.tag          | string | {image.tag}          |

> Note: These values default to other values.  If the other values are unset
> consult thier default values to determine the final value.

When settings are best applied to all images, consider setting them in the the
[Image Configuration](image_configuration) section.

Here is an example of a customized agent image, where a test agent is being
used with other non-test components.

```yaml
agent:
  image:
    name: "mycorp/spire-test-agent"
    registry: "mycorp"
    registryPort: 8080
    tag: "latest"
```

### Agent Key Manager

The agent is configured by default to use a disk KeyManager with a directory
setting of "/opt/spire/data/agent/".  This setting prevents node reattestation
for previously attested nodes, as the agent can present previoulsy accquired,
current SVIDs to attach to the servers.  

This default corresponds to the agent configuration stanza:

```HCL
    plugins {
      KeyManager "disk" {
        plugin_data {
          directory = "/opt/spire/data/agent/"
        }
      }
    }
```

These defaults are not for everyone, to change the Agent KeyManager, configure
the **agent.keyManager.type** setting and apply the settings for the selected
KeyManager type.

| Path                  | Type   | Default |
| --------------------- | ------ | ------- |
| agent.keyManager.type | string | "disk"  |

> Note: **agent.keyManager.type** can only be set to one of "custom", "disk",
> or "memory".

#### Agent Key Manager - Custom

> Note: These values only effect the configuration when the **agent.keyManager.type**
> has the value "custom".

| Path                              | Type             | Default            |
| --------------------------------- | ---------------- | ------------------ |
| agent.keyManager.custom.checksum  | string           |                    |
| agent.keyManager.custom.cmd       | string           |                    |
| agent.keyManager.custom.data      | array of strings | [ ]                |
| agent.keyManager.custom.name      | string           | "customKeyManager" |

The **agent.keyManager.custom.checksum** is the sha256sum of the plugin
executable, as a string value.  It is a required element.  Its purpose is to
ensure that the plugin has not been altered, a an altered plugin may provide a
security exploit.

The **agent.keyManager.custom.cmd** is the absolute path of the plugin, as a
string value. It is a requied element. Its purpose is to ensure that the correct
plugin is called, as calling an alternative plugin may provide a security
exploit.

The **agent.keyManager.custom.data** is an array of key and value pairs, presented
as strings.  If not provided, it will default to an empty array.  Its purpose
is to pass SPIRE presented configuration information into the plugin.

An example of the setting maight be:

```YAML
   ...
   data = [
     "secure = true",
     "path = \"/path/required/by/plugin\"",
     "timeout_seconds = 30"
   ]
   ...
```

These values are dependent on the custom plugin. Currently, we do we do not
support custom plugins with more sophisticated configuration nestings.

The **agent.keyManager.custom.name** controls the plugin name. It has a default
of "customKeyManager". Its purpose is to ensure that viewers of the configuration
file (and logging elements) have the correct plugin name for better team
coordination.

#### Agent Key Manager - Disk

> Note: These values only effect the configuration when the **agent.keyManager.type**
> has the value "disk".

| Path                             | Type   | Default                           |
| -------------------------------- | ------ | --------------------------------- |
| agent.keyManager.disk.directory  | string | "/opt/spire/data/agent/"          |
| agent.hostPath.keyManagerDir     | string | {agent.keyManager.disk.directory} |

The **agent.keyManager.data.directory** is the path that will hold the disk
based keyManager.  It is mapped to a volume, and the volume can be controlled
to be persistent or ephemeral. Its purpose is to provide the directory to hold
previous identities from node attestation, to prevent a full node re-attestation
should the SPIRE agent restart.

## Server Configuration

The server is accessed through a Kubernetes Service, which distributes server
connections to one more more backend server instances.  The backend instances
then handle the requests, replying directly to the agents via client sockets.

### Server Service Settings

The server service provides a single DNS name referenced point of access for
all spire server instances within a deployment.  Connections made to this
Kubernetes service are relayed to one of the backing server instances.

The values associated with the service settigns include:

| Path                     | Type   | Defaults                |
| ------------------------ | ------ | ----------------------- |
| server.serviceName       | string | { Release.Name }-server |
| server.servicePort       | int    | 8081                    |


### Agent Image Controls

The agent is controlled by a container defintion which pulls the agent's image
from a container repository. This image contains the spire-agent executable
which connects to the spire-server through a procedure known as agent-attestation.

The values associated with the agent image include:

| Path                      | Type   | Defaults             |
| ------------------------- | ------ | -------------------- |
| server.image.name         | string | spire/spire-server   |
| server.image.registry     | string | {image.registry}     |
| server.image.registryPort | int    | {image.registryPort} |
| server.image.tag          | string | {image.tag}          |

> Note: These values default to other values.  If the other values are unset
> consult thier default values to determine the final value.

When settings are best applied to all images, consider setting them in the the
[Image Configuration](image_configuration) section.

Here is an example of a customized server image, where a test agent is being
used with other non-test components.

```yaml
server:
  image:
    name: "mycorp/spire-test-server"
    registry: "mycorp"
    registryPort: 8080
    tag: "latest"
```
