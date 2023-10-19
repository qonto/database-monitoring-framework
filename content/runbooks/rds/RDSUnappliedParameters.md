---
title: Unapplied parameters
---

# RDSUnappliedParameters

## Meaning

Alert is triggered when an RDS instance has unapplied parameter group settings.

## Impact

- RDS instance is running with outdated configuration

    Unexpected changes may be applied after a restart.

## Diagnosis

<details>
<summary>More</summary>

RDS parameter groups have `dynamic` and `static` parameters:

- When you change a dynamic parameter, by default the parameter change takes effect immediately, without requiring a reboot.

- When you change a static parameter and save the DB parameter group, the parameter change takes effect after you manually reboot the associated DB instances

- When you associate a new DB parameter group with a DB instance, RDS applies the modified static and dynamic parameters only after the DB instance is rebooted

</details>

1. Check instance status

    If instance is in `creating` status, the parameter group should be applied automatically by AWS in few minutes.

1. Identify the RDS parameter group used by the RDS instance

    ```bash
    DB_IDENTIFIER=<db_identifier>
    aws rds describe-db-instances --db-instance-identifier ${DB_IDENTIFIER} --query 'DBInstances[0].DBParameterGroups[0]'
    ```

    <details>
    <summary>Example</summary>

    The `db1` instance uses `postgres14-primary` parameter group. Changes will be applied after a reboot.

    ```bash
    DB_IDENTIFIER=db1
    aws rds describe-db-instances --db-instance-identifier ${DB_IDENTIFIER} --query 'DBInstances[0].DBParameterGroups[0]'
    {
        "DBParameterGroupName": "postgres14-primary",
        "ParameterApplyStatus": "pending-reboot"
    }
    ```

    </details>

1. Identify changed parameters

    Search `ModifyDBParameterGroup` events for the parameter group in AWS Cloudtrail.

    ```bash
    PARAMETER_GROUP_NAME=<RDS parameter group>
    aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ModifyDBParameterGroup | jq --arg PARAMETER_GROUP_NAME "$PARAMETER_GROUP_NAME" '.Events[] | select(.Resources[0].ResourceName == $PARAMETER_GROUP_NAME) | .CloudTrailEvent | fromjson | {userIdentity: .userIdentity, requestParameters: .requestParameters}'
    ```

    <details>
    <summary>Example</summary>

    `autovacuum_max_workers` parameter on `postgres14-primary` parameter group was changed to `6`

    ```bash
    $ PARAMETER_GROUP_NAME=postgres14-primary
    $ aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ModifyDBParameterGroup | jq --arg PARAMETER_GROUP_NAME "$PARAMETER_GROUP_NAME" '.Events[] | select(.Resources[0].ResourceName == $PARAMETER_GROUP_NAME) | .CloudTrailEvent | fromjson | {userIdentity: .userIdentity, requestParameters: .requestParameters}'
    {
        "userIdentity": {
            "type": "AssumedRole",
            "principalId": "AROA5RLBCOJT4ESFJL7UH:terraform",
            "arn": "arn:aws:sts::000123456789:assumed-role/terraform/terraform",
            "accountId": "000123456789",
            "accessKeyId": "ASIA5RLBCOJTTXNLV6UL",
            "sessionContext": {
            "sessionIssuer": {
                "type": "Role",
                "principalId": "AROA5RLBCOJT4ESFJL7UH",
                "arn": "arn:aws:iam::000123456789:role/terraform",
                "accountId": "000123456789",
                "userName": "documentation"
            },
            "webIdFederationData": {},
            "attributes": {
                "creationDate": "2023-09-15T10:48:09Z",
                "mfaAuthenticated": "false"
            }
            }
        },
        "requestParameters": {
            "parameters": [
            {
                "isModifiable": false,
                "applyMethod": "pending-reboot",
                "parameterName": "autovacuum_max_workers",
                "parameterValue": "6"
            }
            ],
            "dBParameterGroupName": "postgres14-primary"
        }
    }
    ```

    </details>

## Mitigation

- Apply RDS parameter group changes by restarting the RDS instance

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html>
