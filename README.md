# nomad-stanza

Provide Nomad stanzas definition and serializer.

[![Gem Version](https://badge.fury.io/rb/nomad-stanza.svg)](https://badge.fury.io/rb/nomad-stanza)

## Installation

Add the following lines to Gemfile:

    gem 'nomad-stanza'

And execute:

    $ bundle install

Or just install directly by:

    $ gem install nomad-stanza

## Usage
See [lib/nomad/stanza/definition.rb](https://github.com/RiANOl/nomad-stanza/tree/master/lib/nomad/stanza/definition.rb) for all stanza definitions.

```ruby
job = Nomad::Stanza::Job.new(
  id: 'fluentd-job',
  type: 'service',
  region: 'global',
  datacenters: %w(dc1 dc2),
  group: [{
    id: 'fluentd-group',
    count: 2,
    task: [{
      id: 'fluentd-task',
      driver: 'docker',
      config: {
        image: 'fluent/fluentd:v1.6',
      },
      resources: {
        cpu: 1000,
        memory: 1024,
        network: {
          mbits: 1,
          port_map: {
            forward: {
              static: 24224,
            }
          },
        },
      },
      service: [{
        name: '${TASK}',
        port: 'forward',
        check: [{
          type: 'tcp',
          interval: '10s',
          timeout: '2s',
        }]
      }],
    }],
  }],
)

puts Nomad::Stanza::Serializer.serialize(job)
```

will output:

```hcl
job "fluentd-job" {
  type = "service"
  region = "global"
  datacenters = ["dc1", "dc2"]
  priority = 50
  group "fluentd-group" {
    count = 2
    task "fluentd-task" {
      kill_timeout = "5s"
      shutdown_delay = "0s"
      driver = "docker"
      config {
        image = "fluent/fluentd:v1.6"
      }
      resources {
        cpu = 1000
        memory = 1024
        network {
          mbits = 1
        }
      }
      service {
        name = "${TASK}"
        port = "forward"
        check {
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}
```

## Limitation
Currently task config only support docker.
