datadisk Cookbook
=================

# This is still alpha code, tested but most definately not guaranteed to work

This cookbook formats and mounts a second disk (datadisk) on the specified mountpoint, copying existing data in the process. Since it's likely that there are files in use this is done during boot.


Requirements
------------
- a second disk following the format of /dev/[sx]v?d[a-z], e.g. /dev/sdb or /dev/xvde, containing a partition without filesystem
- an OS using upstart
- recent, working (believe is what you do in church!) backups (though tested and with several failsafes in place, this cookbook still does pretty scary stuff.)

Attributes
----------

e.g.
#### datadisk::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['datadisk']['datapart']</tt></td>
    <td>Boolean</td>
    <td>the target mountpoint e.g. /data or /opt</td>
    <td><tt>/data</tt></td>
  </tr>
    <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['datadisk']['doitlive']</tt></td>
    <td>Boolean</td>
    <td>whether to reboot immediately after the chef run</td>
    <td><tt>false</tt></td>
  </tr>
</table>

Usage
-----
#### datadisk::default

Just include `datadisk` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[datadisk]"
  ]
}
```
After the chef run, schedule a reboot on your desired point in time. Since the entire contents of 'datapart' needs to be rsync'd, downtime can be considerable.

Contributing
------------

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Milo de Vries
