echo "print from script"
echo "This is not how you learn"

mkdir -p /home/jenkins-test
cd /home/jenkins-test
touch test1.sh
chmod +x test1.sh
echo "This is how you learn" > test1.sh
./test1.sh

