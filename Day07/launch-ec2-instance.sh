#!/bin/bash
################################################################
# Author: Soham Sarkar
# Day 07: The Zero-Console Lifecycle Automator
# Purpose: Launch -> Connect -> Terminate -> Billing (All-in-One)
################################################################

set -e

# --- 1. CONFIGURATION (Update these once to match your environment) ---
REGION="us-east-1"
KEY_NAME="your-key-pair-name"
SUBNET_ID="your-subnet-id"
INSTANCE_TYPE="t2.micro"

# Using a positional argument for the Instance Name, or defaulting to "Soham-DevOps-Lab"
INSTANCE_NAME=${1:-"DevOps-Lab"}

echo "------------------------------------------------"
echo "🚀 Starting Lifecycle for: $INSTANCE_NAME"
echo "------------------------------------------------"

# --- 2. PRE-FLIGHT CHECKS ---
echo "🔍 Fetching Security Group (Default)..."
SEC_GROUP=$(aws ec2 describe-security-groups --region $REGION --filters "Name=group-name,Values=default" --query "SecurityGroups[0].GroupId" --output text)

echo "🔍 Finding Latest Ubuntu 22.04 AMI..."
AMI_ID=$(aws ec2 describe-images --region $REGION --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd*/ubuntu-jammy-22.04-amd64-server-*" --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)

# --- 3. PROVISIONING ---
echo "🚀 Launching Instance in Subnet: $SUBNET_ID..."
INSTANCE_ID=$(aws ec2 run-instances \
    --region $REGION \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SEC_GROUP \
    --subnet-id $SUBNET_ID \
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "✅ Instance Created: $INSTANCE_ID"

# --- 4. SMART-WAIT FOR PUBLIC IP ---
PUBLIC_IP="None"
echo "⏳ Waiting for AWS to assign Public IP..."
while [ "$PUBLIC_IP" == "None" ] || [ -z "$PUBLIC_IP" ]; do
    sleep 5
    PUBLIC_IP=$(aws ec2 describe-instances --region $REGION --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    echo "   ...working..."
done

echo "------------------------------------------------"
echo "🌐 CONNECTION READY (Git Bash)"
echo "------------------------------------------------"
echo "Run this command to connect:"
echo "ssh -i $KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo "------------------------------------------------"

# --- 5. TERMINATION & FINOPS ---
read -p "🛑 Press [Enter] to Terminate and view Billing Report..."

echo "🧹 Cleaning up resources in $REGION..."
aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID --output text > /dev/null

echo "⏳ Waiting for termination to confirm (to avoid ghost charges)..."
aws ec2 wait instance-terminated --region $REGION --instance-ids $INSTANCE_ID
echo "✨ Instance successfully terminated."

echo "------------------------------------------------"
echo "💰 --- AWS BILLING SUMMARY ---"
echo "------------------------------------------------"

# Fetching real-time cost
RAW_COST=$(aws ce get-cost-and-usage \
    --region us-east-1 \
    --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --query 'ResultsByTime[0].Total.UnblendedCost.Amount' \
    --output text)

# Human-readable formatting (USD to INR)
FORMATTED_COST=$(printf "%.2f" $RAW_COST)
INR_VAL=$(awk "BEGIN {print $FORMATTED_COST * 83.15}")

echo "📅 Period: $(date +%B\ %Y)"
echo "💵 Total Accrued: \$$FORMATTED_COST USD"
echo "🇮🇳 Approx in INR: ₹$(printf "%.2f" $INR_VAL)"
echo "------------------------------------------------"
echo "🏁 Lab Complete For Today"
