# Copyright (c) 2003-2018 Broad Institute, Inc., Massachusetts Institute of Technology, and Regents of the University of California.  All rights reserved.
#!/bin/sh
execDir=`dirname $0`

zip1=$1
zip2=$2
base1=`basename $1`
base2=`basename $2`

bare1=${base1%%.zip}
bare2=${base2%%.zip}
diffDir1=`mktemp -d $bare1.XXXXXX`
diffDir2=`mktemp -d $bare2.XXXXXX`

unzip -q $zip1 -d $diffDir1
unzip -q $zip2 -d $diffDir2

# Diff only selected files out of the ZIP
diff -i --strip-trailing-cr -q $diffDir1/conv.gct $diffDir2/conv.gct
status=$?
diff -i --strip-trailing-cr -q $diffDir1/leading_edge_matrix_for_results.1.gct $diffDir2/leading_edge_matrix_for_results.1.gct
status=$(( $? + status ))
diff -i --strip-trailing-cr -q $diffDir1/leading_edge_matrix_for_results.gmx $diffDir2/leading_edge_matrix_for_results.gmx
status=$(( $? + status ))


# For images, we diff the contents of any SVGs since it's just a simple file compare.  We've decided not to
# deal with PNG comparisons as it's too resource-intensive and prone to per-machine variation.
svgFileList=`ls -1 $diffDir1/*.svg.gz`
for svgFile in $svgFileList; do
   baseSvgFile=`basename $svgFile`
   if [ -s $diffDir2/$baseSvgFile ]; then
      zdiff -i --strip-trailing-cr -q --speed-large-files $svgFile $diffDir2/$baseSvgFile
      status=$(( $? + status ))
   else
      status=$(( 1 + status ))
   fi
done

rm -rf $diffDir1 $diffDir2
exit $status
