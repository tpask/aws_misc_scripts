accessKey=$1
targetRoleName=$2

if [ "$#" -eq 0 ]; then
   echo "**** illegal number of parameters ****"
   echo "usage: $0 accessKey_to_lookup [role_name_to_lookup_owner_of_key]"
   echo "e.g. : $0 123456789012 AdminRole"
   echo ""
   exit
fi

# verify that user is authenticated to ANY account.  If not exit
aws sts get-caller-identity 2>&1> /dev/null
if [ "$?" -ne 0 ] ; then
  echo "You must authenticate to any AWS account first."
  exit
fi

targetAcct=$(aws sts get-access-key-info --access-key-id ${accessKey} --output=text)

if [ -z "${targetAcct}" ]; then
  echo " **** Account not found for key, ${accessKey} ****"
  exit
else
  echo ""
  echo "Key, ${accessKey} belongs to account ${targetAcct}"
  echo ""
fi

# if targetRoleName is not provided then not much else to do but exitl
if [ -z "${targetRoleName}" ]; then
  exit
fi

# build role arn for the target account.
targetRoleArn="arn:aws:iam::${targetAcct}:role/${targetRoleName}"

# assume role
export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
  $(aws sts assume-role --role-arn ${targetRoleArn} \
  --role-session-name mysession \
  --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text))

aws iam get-access-key-last-used --access-key-id ${accessKey}
