#this script counts the number of discovered resources in a region.  AWS config my be enabled for script to work properly.

import boto3
import json
import sys

d = dict()

def getRegions():
  response=boto3.client('ec2').describe_regions()
  return response['Regions']

def getResourceCount(region):
  client = boto3.client('config', region_name=region)
  response = client.get_discovered_resource_counts( limit=3 )
  return response['totalDiscoveredResources']

d['accountId'] = boto3.client('sts').get_caller_identity().get('Account')
d['resourcesInAcct'] = 0
regions = getRegions()

for region in regions:
  regionName = region['RegionName']
  resourcesInRegion = getResourceCount(region['RegionName'])
  d[regionName] = resourcesInRegion
  d['resourcesInAcct'] = d['resourcesInAcct'] + resourcesInRegion

print(json.dumps(d, indent=2))

with open("resourceCount.json", "a") as outFile:
  print(json.dumps(d, indent=2), file=outFile)
