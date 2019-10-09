# cd ./Assets
echo "begin it ..."

git pull
git add .

git commit -m "$*"  

echo $*
        
git push origin master
git push gitee master

echo "finish it ..."