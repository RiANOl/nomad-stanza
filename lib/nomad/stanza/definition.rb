require 'dry-struct'

module Nomad::Stanza
  DURATION_REGEXP = /^(([\d]+\.)?[\d]+[smh])+$/.freeze

  module Types
    include Dry.Types()
  end

  class Base < Dry::Struct
    transform_keys(&:to_sym)
  end

  class Artifact < Base
    attributes(
      source: Types::Strict::String,
      destination: Types::Strict::String.meta(omittable: true),
      mode: Types::Coercible::String.meta(omittable: true),
      options: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
    )
  end

  class Affinity < Base
    attributes(
      attribute: Types::Strict::String.meta(omittable: true),
      operator: Types::Strict::String.enum(
        '=', '!=', '>', '>=', '<', '<=', 'regexp', 'set_contains_all', 'set_contains_any', 'version'
      ).meta(omittable: true),
      value: Types::Coercible::String.meta(omittable: true),
      weight: Types::Strict::Integer.constrained(gteq: -100, lteq: 100).default(50),
    )
  end

  class CheckRestart < Base
    attributes(
      limit: Types::Strict::Integer.constrained(gteq: 0).default(0),
      grace: Types::Strict::String.constrained(format: DURATION_REGEXP).default('1s'.freeze),
      ignore_warnings: Types::Strict::Bool.default(false),
    )
  end

  class Check < Base
    attributes(
      name: Types::Strict::String.meta(omittable: true),
      type: Types::Strict::String.enum('grpc', 'http', 'script', 'tcp'),
      port: Types::Coercible::String.meta(omittable: true),
      protocol: Types::Strict::String.enum('http', 'https').meta(omittable: true),
      path: Types::Strict::String.meta(omittable: true),
      interval: Types::Strict::String.constrained(format: DURATION_REGEXP),
      timeout: Types::Strict::String.constrained(format: DURATION_REGEXP),
      command: Types::Strict::String.meta(omittable: true),
      args: Types.Array(Types::Strict::String).meta(omittable: true),
      grpc_service: Types::Strict::String.meta(omittable: true),
      grpc_use_tls: Types::Strict::Bool.meta(omittable: true),
      tls_skip_verify: Types::Strict::Bool.meta(omittable: true),
      method: Types::Strict::String.meta(omittable: true),
      header: Types::Hash.map(Types::Coercible::String, Types.Array(Types::Coercible::String)).meta(omittable: true),
      check_restart: Types.Constructor(CheckRestart).meta(omittable: true),
      initial_status: Types::Strict::String.enum('passing', 'warning', 'critical').meta(omittable: true),
      address_mode: Types::Strict::String.meta(omittable: true),
    )
  end

  class Constraint < Base
    attributes(
      attribute: Types::Strict::String.meta(omittable: true),
      operator: Types::Strict::String.enum(
        '=', '!=', '>', '>=', '<', '<=',
        'distinct_hosts', 'distinct_property', 'regexp', 'set_contains', 'version', 'is_set', 'is_not_set'
      ).meta(omittable: true),
      value: Types::Coercible::String.meta(omittable: true),
    )
  end

  class Device < Base
    attributes(
      id: Types::Strict::String,
      count: Types::Strict::Integer.constrained(gteq: 1).default(1),
      constraint: Types.Array(Constraint).meta(omittable: true),
      affinity: Types.Array(Affinity).meta(omittable: true),
    )
  end

  class DispatchPayload < Base
    attributes(
      file: Types::Strict::String,
    )
  end

  class EphemeralDisk < Base
    attributes(
      migrate: Types::Strict::Bool.default(false),
      size: Types::Strict::Integer.constrained(gteq: 0).default(300),
      sticky: Types::Strict::Bool.default(false),
    )
  end

  class Logs < Base
    attributes(
      max_files: Types::Strict::Integer.constrained(gteq: 1).default(10),
      max_file_size: Types::Strict::Integer.constrained(gteq: 1).default(10),
    )
  end

  class Migrate < Base
    attributes(
      max_parallel: Types::Strict::Integer.constrained(gteq: 0).default(1),
      health_check: Types::Strict::String.default('checks'.freeze).enum('checks', 'task_states'),
      min_healthy_time: Types::Strict::String.constrained(format: DURATION_REGEXP).default('10s'.freeze),
      healthy_deadline: Types::Strict::String.constrained(format: DURATION_REGEXP).default('5m'.freeze),
    )
  end

  class NetworkPort < Base
    attributes(
      id: Types::Strict::String,
      static: Types::Strict::Integer.constrained(gteq: 0, lteq: 65535).meta(omittable: true),
    )
  end

  class Network < Base
    attributes(
      mbits: Types::Strict::Integer.constrained(gteq: 1).default(10),
      port: Types.Array(NetworkPort).meta(omittable: true),
    )
  end

  class Parameterized < Base
    attributes(
      payload: Types::Strict::String.default('optional'.freeze).enum('optional', 'required', 'forbidden'),
      meta_required: Types.Array(Types::Strict::String).meta(omittable: true),
      meta_optional: Types.Array(Types::Strict::String).meta(omittable: true),
    )
  end

  class Periodic < Base
    attributes(
      cron: Types::Strict::String,
      prohibit_overlap: Types::Strict::Bool.default(false),
      time_zone: Types::Strict::String.default('UTC'.freeze),
    )
  end

  class Reschedule < Base
    attributes(
      attempts: Types::Strict::Integer.constrained(gteq: 0).meta(omittable: true),
      interval: Types::Strict::String.constrained(format: DURATION_REGEXP).meta(omittable: true),
      delay: Types::Strict::String.constrained(format: DURATION_REGEXP),
      delay_function: Types::Strict::String.enum('constant', 'exponential', 'fibonacci'),
      max_delay: Types::Strict::String.constrained(format: DURATION_REGEXP).meta(omittable: true),
      unlimited: Types::Strict::Bool,
    )
  end

  class Resources < Base
    attributes(
      cpu: Types::Strict::Integer.constrained(gteq: 1).default(100),
      memory: Types::Strict::Integer.constrained(gteq: 1).default(300),
      network: Types.Constructor(Network).meta(omittable: true),
      device: Types.Array(Device).meta(omittable: true),
    )
  end

  class Restart < Base
    attributes(
      attempts: Types::Strict::Integer.constrained(gteq: 0).meta(omittable: true),
      delay: Types::Strict::String.constrained(format: DURATION_REGEXP).default('15s'.freeze),
      interval: Types::Strict::String.constrained(format: DURATION_REGEXP).meta(omittable: true),
      mode: Types::Strict::String.default('fail'.freeze).enum('delay', 'fail'),
    )
  end

  class Service < Base
    attributes(
      name: Types::Strict::String.meta(omittable: true),
      port: Types::Coercible::String.meta(omittable: true),
      tags: Types.Array(Types::Strict::String).meta(omittable: true),
      canary_tags: Types.Array(Types::Strict::String).meta(omittable: true),
      address_mode: Types::Strict::String.enum('auto', 'driver', 'host').meta(omittable: true),
      check: Types.Array(Check).meta(omittable: true),
    )
  end

  class SpreadTarget < Base
    attributes(
      id: Types::Strict::String,
      value: Types::Strict::String.meta(omittable: true),
      percent: Types::Strict::Integer.constrained(gteq: 0, lteq: 100),
    )
  end

  class Spread < Base
    attributes(
      attribute: Types::Strict::String,
      weight: Types::Strict::Integer.constrained(gteq: 0, lteq: 100),
      target: Types.Array(SpreadTarget).meta(omittable: true),
    )
  end

  class Template < Base
    attributes(
      data: Types::Strict::String.meta(omittable: true),
      source: Types::Strict::String.meta(omittable: true),
      destination: Types::Strict::String,
      perms: Types::Strict::String.constrained(format: /^[0-7]{3}$/).default('644'.freeze),
      change_mode: Types::Strict::String.default('restart'.freeze).enum('noop', 'restart', 'signal'),
      change_signal: Types::Strict::String.meta(omittable: true),
      splay: Types::Strict::String.constrained(format: DURATION_REGEXP).default('5s'.freeze),
      left_delimiter: Types::Strict::String.meta(omittable: true),
      right_delimiter: Types::Strict::String.meta(omittable: true),
      env: Types::Strict::Bool.meta(omittable: true),
      vault_grace: Types::Strict::String.constrained(format: DURATION_REGEXP).meta(omittable: true),
    )
  end

  class Update < Base
    attributes(
      max_parallel: Types::Strict::Integer.constrained(gteq: 0).default(0),
      health_check: Types::Strict::String.default('checks'.freeze).enum('checks', 'task_states', 'manual'),
      min_healthy_time: Types::Strict::String.constrained(format: DURATION_REGEXP).default('10s'.freeze),
      healthy_deadline: Types::Strict::String.constrained(format: DURATION_REGEXP).default('5m'.freeze),
      progress_deadline: Types::Strict::String.constrained(format: DURATION_REGEXP).default('10m'.freeze),
      auto_revert: Types::Strict::Bool.default(false),
      auto_promote: Types::Strict::Bool.default(false),
      canary: Types::Strict::Integer.constrained(gteq: 0).default(0),
      stagger: Types::Strict::String.constrained(format: DURATION_REGEXP).default('30s'.freeze),
    )
  end

  class Vault < Base
    attributes(
      policies: Types.Array(Types::Strict::String),
      change_mode: Types::Strict::String.default('restart'.freeze).enum('noop', 'restart', 'signal'),
      change_signal: Types::Strict::String.meta(omittable: true),
      env: Types::Strict::Bool.default(true),
    )
  end

  class DockerMount < Base
    attributes(
      type: Types::Strict::String.meta(omittable: true),
      source: Types::Strict::String.meta(omittable: true),
      target: Types::Strict::String,
      readonly: Types::Strict::Bool.meta(omittable: true),
      volume_options: Types::Hash.map(Types::Coercible::String, Types::Any).meta(omittable: true),
      bind_options: Types::Hash.map(Types::Coercible::String, Types::Any).meta(omittable: true),
      tmpfs_options: Types::Hash.map(Types::Coercible::String, Types::Any).meta(omittable: true),
    )
  end

  class DockerDevice < Base
    attributes(
      host_path: Types::Strict::String,
      container_path: Types::Strict::String,
      cgroup_permissions: Types::Strict::String.meta(omittable: true),
    )
  end

  class DockerConfigAuth < Base
    attributes(
      username: Types::Strict::String.meta(omittable: true),
      password: Types::Strict::String.meta(omittable: true),
      email: Types::Strict::String.meta(omittable: true),
      server_address: Types::Strict::String.meta(omittable: true),
    )
  end

  class DockerConfigLogging < Base
    attributes(
      type: Types::Strict::String.meta(omittable: true),
      config: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
    )
  end

  class DockerConfig < Base
    attributes(
      image: Types::Strict::String,
      force_pull: Types::Strict::Bool.meta(omittable: true),
      entrypoint: Types::Strict::String.meta(omittable: true),
      command: Types::Strict::String.meta(omittable: true),
      args: Types.Array(Types::Strict::String).meta(omittable: true),
      work_dir: Types::Strict::String.meta(omittable: true),
      volume_driver: Types::Strict::String.meta(omittable: true),
      volumes: Types.Array(Types::Strict::String).meta(omittable: true),
      mounts: Types.Array(DockerMount).meta(omittable: true),
      devices: Types.Array(DockerDevice).meta(omittable: true),
      port_map: Types::Hash.map(Types::Coercible::String, Types::Coercible::Integer).meta(omittable: true),
      network_aliases: Types.Array(Types::Strict::String).meta(omittable: true),
      network_mode: Types::Strict::String.meta(omittable: true),
      mac_address: Types::Strict::String.meta(omittable: true),
      ipv4_address: Types::Strict::String.meta(omittable: true),
      ipv6_address: Types::Strict::String.meta(omittable: true),
      advertise_ipv6_address: Types::Strict::Bool.meta(omittable: true),
      sysctl: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      ulimit: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      privileged: Types::Strict::Bool.meta(omittable: true),

      auth: Types.Constructor(DockerConfigAuth).meta(omittable: true),
      auth_soft_fail: Types::Strict::Bool.meta(omittable: true),
      cap_add: Types.Array(Types::Strict::String).meta(omittable: true),
      cap_drop: Types.Array(Types::Strict::String).meta(omittable: true),
      cpu_cfs_period: Types::Strict::Integer.constrained(gteq: 1).meta(omittable: true),
      cpu_hard_limit: Types::Strict::Bool.meta(omittable: true),
      dns_options: Types.Array(Types::Strict::String).meta(omittable: true),
      dns_search_domains: Types.Array(Types::Strict::String).meta(omittable: true),
      dns_servers: Types.Array(Types::Strict::String).meta(omittable: true),
      extra_hosts: Types.Array(Types::Strict::String).meta(omittable: true),
      hostname: Types::Strict::String.meta(omittable: true),
      interactive: Types::Strict::Bool.meta(omittable: true),
      ipc_mode: Types::Strict::String.meta(omittable: true),
      labels: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      load: Types::Strict::String.meta(omittable: true),
      logging: Types.Constructor(DockerConfigLogging).meta(omittable: true),
      pid_mode: Types::Strict::String.meta(omittable: true),
      pids_limit: Types::Strict::Integer.constrained(gteq: 1).meta(omittable: true),
      readonly_rootfs: Types::Strict::Bool.meta(omittable: true),
      security_opt: Types.Array(Types::Strict::String).meta(omittable: true),
      shm_size: Types::Strict::Integer.constrained(gteq: 1).meta(omittable: true),
      storage_opt: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      tty: Types::Strict::Bool.meta(omittable: true),
      userns_mode: Types::Strict::String.meta(omittable: true),
      uts_mode: Types::Strict::String.meta(omittable: true),
    )
  end

  class Task < Base
    attributes(
      id: Types::Strict::String,
      leader: Types::Strict::Bool.meta(omittable: true),
      kill_timeout: Types::Strict::String.constrained(format: DURATION_REGEXP).default('5s'.freeze),
      kill_signal: Types::Strict::String.meta(omittable: true),
      shutdown_delay: Types::Strict::String.constrained(format: DURATION_REGEXP).default('0s'.freeze),
      constraint: Types.Array(Constraint).meta(omittable: true),
      affinity: Types.Array(Affinity).meta(omittable: true),
      driver: Types::Strict::String,
      user: Types::Strict::String.meta(omittable: true),
      config: Types.Constructor(DockerConfig).meta(omittable: true),
      env: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      dispatch_payload: Types.Constructor(DispatchPayload).meta(omittable: true),
      artifact: Types.Array(Artifact).meta(omittable: true),
      template: Types.Array(Template).meta(omittable: true),
      resources: Types.Constructor(Resources),
      service: Types.Array(Service).meta(omittable: true),
      logs: Types.Constructor(Logs).meta(omittable: true),
      meta: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      vault: Types.Constructor(Vault).meta(omittable: true),
    )
  end

  class Group < Base
    attributes(
      id: Types::Strict::String,
      count: Types::Strict::Integer.constrained(gteq: 1).default(1),
      constraint: Types.Array(Constraint).meta(omittable: true),
      affinity: Types.Array(Affinity).meta(omittable: true),
      spread: Types.Array(Spread).meta(omittable: true),
      update: Types.Constructor(Update).meta(omittable: true),
      migrate: Types.Constructor(Migrate).meta(omittable: true),
      reschedule: Types.Constructor(Reschedule).meta(omittable: true),
      restart: Types.Constructor(Restart).meta(omittable: true),
      ephemeral_disk: Types.Constructor(EphemeralDisk).meta(omittable: true),
      task: Types.Array(Task),
      meta: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      vault: Types.Constructor(Vault).meta(omittable: true),
    )
  end

  class Job < Base
    attributes(
      id: Types::Strict::String,
      type: Types::Strict::String.default('service'.freeze).enum('service', 'system', 'batch'),
      region: Types::Strict::String.default('global'.freeze),
      datacenters: Types.Array(Types::Strict::String),
      namespace: Types::Strict::String.meta(omittable: true),
      priority: Types::Strict::Integer.constrained(gteq: 1, lteq: 100).default(50),
      all_at_once: Types::Strict::Bool.meta(omittable: true),
      constraint: Types.Array(Constraint).meta(omittable: true),
      affinity: Types.Array(Affinity).meta(omittable: true),
      spread: Types.Array(Spread).meta(omittable: true),
      update: Types.Constructor(Update).meta(omittable: true),
      migrate: Types.Constructor(Migrate).meta(omittable: true),
      reschedule: Types.Constructor(Reschedule).meta(omittable: true),
      parameterized: Types.Constructor(Parameterized).meta(omittable: true),
      periodic: Types.Constructor(Periodic).meta(omittable: true),
      group: Types.Array(Group),
      meta: Types::Hash.map(Types::Coercible::String, Types::Coercible::String).meta(omittable: true),
      vault: Types.Constructor(Vault).meta(omittable: true),
      vault_token: Types::Strict::String.meta(omittable: true),
    )
  end
end
