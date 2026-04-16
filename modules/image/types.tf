locals {
  # image search is only valid for regions in the regions.txt file in this directory
  standard_types = {
    # using the getImages script in this directory with argument "sles"
    # suse-sles-15-sp7-byos-v20260220-hvm-ssd-x86_64-prod-v6etgxzep2nwu
    # WARNING! You must accept terms and conditions before launch: https://aws.amazon.com/marketplace/pp/prodview-zhkoav5fieqfm
    sles-15 = { # BYOS = Bring Your Own Subscription
      user         = "ec2-user",
      group        = "wheel",
      name         = "suse-sles-15-sp*-byos-v*-hvm-ssd-x86_64-prod-*",
      name_regex   = "^suse-sles-15-sp[0-9]-byos-v[0-9]+-hvm-ssd-x86_64-prod-[0-9a-z]+$", # we are specifically trying to avoid the -ecs- images
      product_code = "",
      owners       = ["013907871322", "679593333241"],
      architecture = "x86_64",
      workfolder   = "~",
      supports_c8  = true,
      supports_c7  = true,
    },

    # using the getImages script in this directory with argument "sles"
    # suse-sles-16-0-byos-v20260205-hvm-ssd-x86_64-prod-jmoiuomj7bnek
    sles-16 = { # BYOS = Bring Your Own Subscription
      user         = "ec2-user",
      group        = "wheel",
      name         = "suse-sles-16-*-byos-v*-hvm-ssd-x86_64-prod-*",
      name_regex   = "^suse-sles-16-[0-9]-byos-v[0-9]+-hvm-ssd-x86_64-prod-[0-9a-z]+$",
      product_code = "",
      owners       = ["013907871322", "679593333241"],
      architecture = "x86_64",
      workfolder   = "~",
      supports_c8  = true,
      supports_c7  = true,
    },

    # using the getImages script in this directory with argument "sle-micro"
    # suse-sle-micro-5-5-byos-v20250131-hvm-ssd-x86_64
    # suse-sle-micro-5-5-byos-v20251025-hvm-ssd-x86_64
    # sle micro is already optimized for containers
    sle-micro-55 = { # BYOS = Bring Your Own Subscription
      user         = "ec2-user",
      group        = "wheel",
      name         = "suse-sle-micro-5-5-byos-v*-hvm-ssd-x86_64",
      name_regex   = "^suse-sle-micro-5-5-byos-v[0-9]+-hvm-ssd-x86_64$",
      product_code = "",
      owners       = ["013907871322"],
      architecture = "x86_64",
      workfolder   = "~",
      supports_c8  = true,
      supports_c7  = true,
    }

    # using the getImages script in this directory with argument "sle-micro"
    # suse-sle-micro-6-0-byos-v20250210-hvm-ssd-x86_64
    # sle micro is already optimized for containers
    sle-micro-60 = { # BYOS = Bring Your Own Subscription
      user         = "suse",
      group        = "wheel",
      name         = "suse-sle-micro-6-0-byos-v*-hvm-ssd-x86_64",
      name_regex   = "^suse-sle-micro-6-0-byos-v[0-9]+-hvm-ssd-x86_64$",
      product_code = "",
      owners       = ["013907871322"],
      architecture = "x86_64",
      workfolder   = "~"
      supports_c8  = true,
      supports_c7  = true,
    }

    # using the getImages script in this directory with argument "sle-micro"
    # suse-sle-micro-6-1-byos-v20260223-hvm-ssd-x86_64
    # sle micro is already optimized for containers
    sle-micro-61 = { # BYOS = Bring Your Own Subscription
      user         = "suse",
      group        = "wheel",
      name         = "suse-sle-micro-6-1-byos-v*-hvm-ssd-x86_64",
      name_regex   = "^suse-sle-micro-6-1-byos-v[0-9]+-hvm-ssd-x86_64$",
      product_code = "",
      owners       = ["013907871322"],
      architecture = "x86_64",
      workfolder   = "~",
      supports_c8  = true,
      supports_c7  = true,
    }

    # WARNING! you must subscribe and accept the terms to use this image
    # https://aws.amazon.com/marketplace/server/procurement?productId=ca1fe94d-9237-41c7-8fc8-78b6b0658c9f
    # CIS Red Hat Enterprise Linux 8 Benchmark - STIG - v12 -ca1fe94d-9237-41c7-8fc8-78b6b0658c9f
    # CIS Red Hat Enterprise Linux 8 Benchmark - STIG - v04 -ca1fe94d-9237-41c7-8fc8-78b6b0658c9f
    cis-rhel-8 = {
      user         = "ec2-user",
      group        = "wheel",
      name         = "CIS Red Hat Enterprise Linux 8 Benchmark - STIG*"
      name_regex   = "CIS Red Hat Enterprise Linux 8 Benchmark - STIG - v[0-9]+ -ca1fe94d-9237-41c7-8fc8-78b6b0658c9f",
      product_code = "",
      owners       = ["679593333241"],
      architecture = "x86_64",
      workfolder   = "/var/tmp"
      supports_c8  = false,
      supports_c7  = true,
    },

    # WARNING! you must subscribe and accept the terms to use this image
    # https://aws.amazon.com/marketplace/server/procurement?productId=ca1fe94d-9237-41c7-8fc8-78b6b0658c9f
    # CIS Red Hat Enterprise Linux 9 Benchmark - STIG - v04 -prod-ys6x446rhppue
    cis-rhel-9 = {
      user         = "ec2-user",
      group        = "wheel",
      name         = "CIS Red Hat Enterprise Linux 9 Benchmark - STIG - v* -prod-*"
      name_regex   = "CIS Red Hat Enterprise Linux 9 Benchmark - STIG - v[0-9]+ -prod-[0-9a-z]+",
      product_code = "",
      owners       = ["679593333241"],
      architecture = "x86_64",
      workfolder   = "/opt/bootstrap"
      supports_c8  = false,
      supports_c7  = true,
    },

    # WARNING! you must subscribe and accept the terms to use this image
    # ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20250305
    # ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-amd64-minimal-20260408-50c8dca0-a060-4e40-b30a-b612e829b2a3
    ubuntu-22 = {
      user         = "ubuntu",
      group        = "admin",
      name         = "ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-amd64-minimal-*",
      name_regex   = "^ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-amd64-minimal-[0-9]+-[0-9a-z]+-[0-9a-z]+-[0-9a-z]+-[0-9a-z]+-[0-9a-z]+$",
      product_code = "",
      owners       = ["679593333241"],
      architecture = "x86_64",
      workfolder   = "~"
      supports_c8  = true,
      supports_c7  = true,
    },

    # WARNING! you must subscribe and accept the terms to use this image
    # https://aws.amazon.com/marketplace/pp/prodview-a2hsmwr6uilqq
    # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305
    # ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-20260323-prod-u7oazfncxktmo
    ubuntu-24 = {
      user         = "ubuntu",
      group        = "admin",
      name         = "ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-*-prod-*",
      name_regex   = "^ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-[0-9]+-prod-[0-9a-z]+$",
      product_code = "",
      owners       = ["679593333241"],
      architecture = "x86_64",
      workfolder   = "~"
      supports_c8  = true,
      supports_c7  = true,
    },

    # WARNING! you must subscribe and accept the terms to use this image
    # https://aws.amazon.com/marketplace/pp/prodview-yjxmiuc6p5jzk
    # Rocky-9-EC2-LVM-9.5-20241118.0.x86_64-prod-hyj6jp3bki4bm
    rocky-9 = {
      user         = "ec2-user",
      group        = "wheel",
      name         = "Rocky-9-EC2-LVM-9.*-*.*.x86_64-prod-*",
      name_regex   = "^Rocky-9-EC2-LVM-9.[0-9]+-[0-9]+.[0-9].x86_64-prod-[0-9a-z]+$",
      product_code = "c0tjzp9xnxvr0ah4f0yletr6b",
      owners       = ["679593333241"],
      architecture = "x86_64",
      workfolder   = "~"
      supports_c8  = false,
      supports_c7  = true,
    },

    # the goal for these search strings is to keep them as stable as possible without specifying a version that is EOL
    # our users often rely on extended support from RHEL, so we don't consider odd numbered minors which are inelegible for that
    # https://access.redhat.com/support/policy/updates/errata
    # therefore the search found here is the most recent even minor that has been released
    # expect RHEL 9.4 in June 2024
    # RHEL-9.5.0_HVM-20241211-x86_64-0-Hourly2-GP3
    rhel-9 = {
      user         = "ec2-user",
      group        = "wheel",
      name         = "RHEL-9.*.*_HVM-*-x86_64-*-Hourly2-GP3",
      name_regex   = "^RHEL-9.[0-9].[0-9]_HVM-[0-9]+-x86_64-[0-9]-Hourly2-GP3$",
      product_code = "",
      owners       = ["309956199498"],
      architecture = "x86_64",
      workfolder   = "~"
      supports_c8  = true,
      supports_c7  = true,
    },

    # Warning! You need to accept terms and conditions for this image: https://aws.amazon.com/marketplace/pp/prodview-n4gxhkpjwu6h6
    # suse-multi-linux-manager-server-5-1-byos-v20260402-x86_64-prod-syyllwcy3zv22
    suse-multi-linux-manager-server-5 = {
      user         = "ec2-user",
      group        = "wheel",
      name         = "suse-multi-linux-manager-server-5-*-byos-*-x86_64-*",
      name_regex   = "^suse-multi-linux-manager-server-5-[0-9]-byos-v[0-9]+-x86_64-prod-[0-9a-z]+$",
      product_code = "",
      owners       = ["679593333241"],
      architecture = "x86_64",
      workfolder   = "~"
      supports_c8  = true,
      supports_c7  = false,
    },
  }
}
