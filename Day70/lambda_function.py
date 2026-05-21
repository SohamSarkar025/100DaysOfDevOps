import boto3
import json

def lambda_handler(event, context):
    # 1. Parse the incoming event wrapper safely
    config = json.loads(event['invokingEvent'])
    configuration_item = config.get("configurationItem", {})
    
    # 2. Extract identifiers using standard AWS Config payload paths
    instance_id = configuration_item.get('resourceId')
    resource_type = configuration_item.get('resourceType')
    capture_time = configuration_item.get('configurationItemCaptureTime')
    
    print(f"DEBUG: Processing compliance audit for Resource ID: {instance_id}")
    
    # Fallback default value settings
    compliance_status = "NOT_APPLICABLE"
    annotation_msg = "Resource evaluated successfully."
    
    # 3. Guardrail check to filter out non-EC2 components or delete events
    if resource_type == 'AWS::EC2::Instance' and configuration_item.get('configurationItemStatus') in ['OK', 'ResourceDiscovered']:
        # Fetch configurations mapped directly inside the payload metrics
        configuration_block = configuration_item.get('configuration', {})
        monitoring_block = configuration_block.get('monitoring', {})
        monitoring_state = monitoring_block.get('state')
        
        print(f"DEBUG: Isolated Monitoring State for {instance_id} -> {monitoring_state}")
        
        # 4. Compliance evaluation execution logic
        if monitoring_state == "enabled":
            compliance_status = "COMPLIANT"
            annotation_msg = "Detailed CloudWatch Monitoring is active."
        else:
            compliance_status = "NON_COMPLIANT"
            annotation_msg = "Detailed CloudWatch Monitoring is disabled (Using legacy 5-min basic monitoring)."

    # 5. Build dynamic compliance state model parameters
    evaluation = {
        'ComplianceResourceType': 'AWS::EC2::Instance',
        'ComplianceResourceId': instance_id,
        'ComplianceType': compliance_status,
        'Annotation': annotation_msg,
        'OrderingTimestamp': capture_time
    }
    
    print(f"DEBUG: Publishing final verdict back to AWS Config: {compliance_status}")
    
    # 6. Execute callback payload transmission via PutEvaluations API
    config_client = boto3.client('config')
    response = config_client.put_evaluations(
        Evaluations=[evaluation],
        ResultToken=event['resultToken']
    )  
    
    return response