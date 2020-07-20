# save arguments to variables
SOURCE=$1
TARGET=$2

TMPDIR=/tmp/tesseract
FILENAME=`basename $SOURCE`
OCRFILE=$FILENAME.tif
                                       
LD_LIBRARY_PATH=/usr/lib

# Create temp directory if it doesn't exist
mkdir -p $TMPDIR
# 
echo "OCR from $SOURCE to $TARGET" >> /alfresco/alfresco.log
cp -f $SOURCE $TMPDIR/$OCRFILE
# call tesseract and redirect output to $TARGET
/usr/bin/tesseract $TMPDIR/$OCRFILE ${TARGET%\.*} -psm 1 -l eng+fra

rm -f $TMPDIR/$OCRFILE
