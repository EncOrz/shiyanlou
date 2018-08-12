#!/bin/sed -f

/^$/d

/^[0-9]+\./!G

s/\(http:/\(https:/g

s/^!\[/\[/g

/http/{/(\.png|\.jpg)/s/^/!/g}

/^[0-9]+\./s/\./\. /	