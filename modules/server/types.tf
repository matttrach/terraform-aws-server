# storage sizes in GB, using gp3 storage type
locals {
  types = {
    # Focusing on production ready instance types,
    #   these may be more expensive up front,
    #   but more predictable in performance and cost at scale.
    small = { # minimum required for rke2 control plane node, handles 0-225 agents
      id      = (local.image_supports_c8 ? "c8i.large" : (local.image_supports_c7 ? "c7i.large" : "c5.large"))
      cpu     = "2",
      ram     = "4",
      storage = "20",
    },
    medium = { # agent node, fits requirements for a database server or a small gaming server
      id      = "m7i.large",
      cpu     = "2",
      ram     = "8",
      storage = "200",
    },
    large = { # control plane handling 226-450 agents, also fits requirements for a git server
      id      = (local.image_supports_c8 ? "c8i.large" : (local.image_supports_c7 ? "c7i.large" : "c5.large"))
      cpu     = "4",
      ram     = "8",
      storage = "500",
    },
    xl = { # control plane handling 451-1300 agents, also fits requirements for a large database server, gaming server, or a distributed storage solution
      id      = "m7i.xlarge",
      cpu     = "4",
      ram     = "16",
      storage = "1000",
    }
    xxl = { # control plane handling 1300+ agents, also fits requirements for a large gaming server, a large database server, or a distributed storage solution
      id      = "m7i.2xlarge",
      cpu     = "8",
      ram     = "32",
      storage = "2000",
    }
    xxxl = { # control plane handling 2000+ agents, also fits requirements for a very large database server or high-performance computing
      id      = "m7i.4xlarge",
      cpu     = "16",
      ram     = "64",
      storage = "4000",
    }
  }
}
