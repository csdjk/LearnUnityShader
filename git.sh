# cd ./Assets
echo -n "Enter commit description: "
read str

if [ -z "$str" ]; then
    echo "commit description is empty string! please recommit"
    exit
fi   
echo "begin it ..."

git pull
git add .

git commit -m "$str"  

echo $str
        
git push origin master
git push gitee master

echo "finish it ..."