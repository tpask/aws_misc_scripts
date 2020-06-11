#!/usr/bin/env bash

#This script use an MFA token to authenticate access to AWS resources through the AWS CLI 
#see https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/ for more info.

set -o errexit
set -o nounset

#get profile
if ((!$#)); then
  read -p 'Enter AWS profile to use: ' profile
else
  profile=$1
fi

#get acount, userArn
read -r -a CID <<<"$(aws --profile "${profile}" sts get-caller-identity --output text)"
AWS_ACCT_NUM="${CID[0]}"
AWS_USER_ARN="${CID[1]}"
AWS_USER="$(basename ${AWS_USER_ARN})"
MFA_ARN="arn:aws:iam::${AWS_ACCT_NUM}:mfa/${AWS_USER}"

#get the MFA token
read -p 'Enter MFA code: ' MFA

#using token, get keyID, key, and sessionToken
read -r -a TOKEN <<< "$(aws --profile ${profile} sts get-session-token --serial-number ${MFA_ARN} --token-code ${MFA} --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text)"
export AWS_ACCESS_KEY_ID="${TOKEN[0]}"
export AWS_SECRET_ACCESS_KEY="${TOKEN[1]}"
export AWS_SESSION_TOKEN="${TOKEN[2]}"

#echo ${AWS_ACCESS_KEY_ID}, ${AWS_SECRET_ACCESS_KEY}, ${AWS_SESSION_TOKEN}

#This is just to show AWS identity
aws sts get-caller-identity

#setup prompt:
export PS1="\h:${ACCT_ALIAS}/\${AWS_USER}:..\W> "

#get into shell
exec $SHELL
