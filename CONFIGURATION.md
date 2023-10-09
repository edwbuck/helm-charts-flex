<!-- vim: filetype=markdown colorcolumn=80
-->
# helm-charts-flex Configuration

[![Apache 2.0 License](https://img.shields.io/github/license/spiffe/helm-charts)](https://opensource.org/licenses/Apache-2.0)
[![Development Phase](https://github.com/spiffe/spiffe/blob/main/.img/maturity/dev.svg)](https://github.com/spiffe/spiffe/blob/main/MATURITY.md#development)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/spiffe)](https://artifacthub.io/packages/search?repo=spiffe)

## Agent Configuration

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
