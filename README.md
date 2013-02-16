dbic-generator-extjs
====================

An MVC style extjs class generator using DBIx::Class schema.

An attempt to rewrite & extend the abraxxa's initial great work:

https://github.com/abraxxa/DBICx-Generator-ExtJS-Model.git

The original implementation is its, not mine. Using JSON::DWIW
was also a great idea.

TODO
====

store / treestore generator
controller generator
form generator (combo for associated data)
grid / tree generator 

writer
- if a file already exists:
+ read it (done for model)
+ get the json part for completing is necessary (done for model)
+ memorize the others non json parts 
+ use md5sum to verify the modified part (compress, order the json file before)
+ make a backup (option) or stop (option)
- order in a logical manner the hash (extend, fields, validations, proxy, associations ...)

parameter: the less, the better !
- use extjs main file for finding path to file and namespace
- use a config file
- search in local directory by default
