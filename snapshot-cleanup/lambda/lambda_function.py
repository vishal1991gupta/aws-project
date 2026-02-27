import boto3
import os
import logging
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.getenv('LOG_LEVEL', 'INFO'))

def lambda_handler(event, context):
    """
    Main Lambda handler that deletes EC2 snapshots older than one year
    """
    ec2_client = boto3.client('ec2')
    
    # Calculate the cutoff date (1 year ago)
    cutoff_date = datetime.now(timezone.utc) - timedelta(days=365)
    logger.info(f"Looking for snapshots older than {cutoff_date.isoformat()}")
    
    try:
        # Get all snapshots owned by this account
        snapshots = []
        paginator = ec2_client.get_paginator('describe_snapshots')
        
        for page in paginator.paginate(OwnerIds=['self']):
            snapshots.extend(page['Snapshots'])
        
        logger.info(f"Found {len(snapshots)} total snapshots")
        
        # Filter and delete old snapshots
        deleted_count = 0
        for snapshot in snapshots:
            snapshot_id = snapshot['SnapshotId']
            start_time = snapshot['StartTime']
            
            if start_time < cutoff_date:
                logger.info(f"Deleting snapshot: {snapshot_id}, created: {start_time}")
                
                try:
                    # Optional: Check if snapshot is in use before deleting
                    ec2_client.delete_snapshot(SnapshotId=snapshot_id)
                    logger.info(f"Successfully deleted snapshot: {snapshot_id}")
                    deleted_count += 1
                    
                except ClientError as e:
                    if 'InvalidSnapshot.InUse' in str(e):
                        logger.warning(f"Snapshot {snapshot_id} is in use, skipping: {str(e)}")
                    else:
                        logger.error(f"Error deleting snapshot {snapshot_id}: {str(e)}")
        
        logger.info(f"Deletion complete. Deleted {deleted_count} snapshots")
        
        return {
            'statusCode': 200,
            'body': f'Successfully processed snapshots. Deleted: {deleted_count}'
        }
        
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise