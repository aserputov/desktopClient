

RANDOM_STRING=$(openssl rand -hex 4)
echo "$RANDOM_STRING"

aws ec2 create-security-group --group-name my-security-group --description "My security group"

aws ec2 authorize-security-group-ingress --group-name my-security-group --protocol tcp --port 3389 --cidr 0.0.0.0/0

aws ec2 run-instances \
    --image-id ami-08dea031811bfa630 \
    --instance-type t2.micro \
    --key-name remote1 \
    --security-group-ids my-security-group \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$RANDOM_STRING}]"

instanceid=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$RANDOM_STRING" --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
echo $instanceid

status=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$RANDOM_STRING" --region ca-central-1 --query 'Reservations[0].Instances[0].State.Name' --output text)
echo $status 
if [ "$ip" = "None" ] || [ "$status" = "pending" ]; then
  while [ "$ip" = "None" ] || [ "$status" = "pending" ]; do
    echo "Your Desktop is starting up. Please wait 60 seconds."
    sleep 60
    ip=$(aws ec2 describe-instances --region ca-central-1 --filters "Name=tag:Name,Values=$RANDOM_STRING" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    status=$(aws ec2 describe-instances --region ca-central-1 --filters "Name=tag:Name,Values=$RANDOM_STRING" --query 'Reservations[0].Instances[0].State.Name' --output text)
  done
fi

echo "Your Desktop is available. Now let's get password for your Desktop. Please wait 30-90 seconds."
echo $ip
while [ -z "$pass" ] ; do
  sleep 150
  pass=$(aws ec2 get-password-data --instance-id $instanceid --priv-launch-key /Users/anatoliyserputov/Desktop/Client/remote1.pem --query 'PasswordData'  --output text)
  ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$RANDOM_STRING" --region ca-central-1 --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
done
echo $pass
timeout 60s /Users/anatoliyserputov/Desktop/FreeRDP/client/Mac/cli/MacFreeRDP.app/Contents/MacOS/MacFreeRDP /d:DOMAIN /u:Administrator /v:$ip /p:$pass /auto-reconnect-max-retries:0 /smart-sizing +clipboard /home-drive /smart-sizing /scale:100 /w:1680 /h:1020
echo "15 minutes left. Thank you for testing!"

aws ec2 terminate-instances --instance-ids $instanceid

# echo "Your Desktop is available. Now let's get password for your Desktop. Please wait 30-90 seconds."