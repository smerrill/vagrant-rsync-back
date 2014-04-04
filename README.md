# vagrant-rsync-back

A plugin for Vagrant 1.5.1+ that lets you rsync from guest to host.

## Getting started

This plugin has only been lightly tested. It might eat all your data! (Use at
your own risk.)

To get started, you need to have Vagrant 1.5.1 installed on your host machine.
To install the plugin, use the following command.

```bash
vagrant plugin install vagrant-rsync-back
```

Then once you have generated some content on the guest that you want to bring
back to the host, run the rsync-back command.

```bash
vagrant rsync-back
```

## Why rsync back?

Sometimes, the application on your host will write things to the source code
directory that you want to sync back to the host. A Drupal-specific example
is generating new Features to disk and then wanting to commit them to git
from the host machine.

## Author

Steven Merrill (@stevenmerrill) built this based on vagrant-gatling-rsync.

