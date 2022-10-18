Add here a *secrets.yml* file with variables that have secret values.
The Ansible vault is used to encrypt this file.

My *secrets.yml* contains a single variable, the user password:

ansible_password: pwd123

This file is encrypted with:

```
ansible-vault encrypt secrets.yml
```
