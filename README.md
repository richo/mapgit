mapgit
======

MapGit is a service to facilitate geotagging your git commits. (Or other
commits, but realistically for now it more or less hinges on you using git +
github)

You'll install a post-commit hook into your repos. It still requires an opt in flag, so
it's safe to install into your `git_template` if you don't necessarily want to
tag everything.

From there, at commit time a lon,lat pair is written to a flat file database
with the commit hash. This data can be synced to with the mapgit webservice (or
a private instance) which then does the appropriate magic to marry this data up
with github.

tagging
-------

This is all well and good, but you'll still need a mechanism to gather this
data. I recommend [doko](1), which is written in python and plays nicely on all
platforms (although it's most accurate on OSX with corelocation).

mapping
-------

You'll need to fetch a maps api key from [google](https://code.google.com/apis/console).

Set it to the environment variable `GMAPS_API_KEY`

[1]:https://bitbucket.org/larsyencken/doko
