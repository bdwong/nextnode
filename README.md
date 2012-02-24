== nextnode

nextnode is a Sinatra application to reserve and return the name of a jenkins node
for a RightScale server array (because a server in an array does not know its node name
in advance.) It should run on the jenkins master server.

It responds to GET requests on /reserve and returns the node name that has been reserved,
or an empty string if no node names are available.

You can pass in a regular expression if you wish to match a particular node naming
scheme. Use /reserve?regex=your_node_regex to return only node names that match the
expression your_node_regex.
