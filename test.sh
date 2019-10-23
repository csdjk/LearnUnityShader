echo -n "Enter input: "
# read $*
 
if [ -z "$*" ]; then
    echo "empty string $*"
    exit 1
else
 echo "Input is valid.  $str  $*"
fi
 
exit 0