# Copyright (c) 2003-2017 Broad Institute, Inc., Massachusetts Institute of Technology, and Regents of the University of California.  All rights reserved.
#!/bin/sh
execDir=`dirname $0`

zip1=$1
zip2=$2

base1=`basename $2`
base2=`basename $3`
bare1=${base1%%.zip}
bare2=${base2%%.zip}
diffDir1=`mktemp -d $bare1.XXXXXX`
diffDir2=`mktemp -d $bare2.XXXXXX`

unzip -q $zip1 -d $diffDir1
unzip -q $zip2 -d $diffDir2

# Diff only selected files out of the ZIP
diff --strip-trailing-cr -q $diffDir1/conv.gct $diffDir2/conv.gct
status=$?
diff --strip-trailing-cr -q $diffDir1/leading_edge_matrix_for_results.1.gct $diffDir2/leading_edge_matrix_for_results.1.gct
status=$(( $? + status ))
diff --strip-trailing-cr -q $diffDir1/leading_edge_matrix_for_results.gmx $diffDir2/leading_edge_matrix_for_results.gmx
status=$(( $? + status ))


# Dropping comparison of plots with ImageMagick.  Possible new method: compare SVG files as XML.

rm -rf $diffDir1 $diffDir2
exit $status
