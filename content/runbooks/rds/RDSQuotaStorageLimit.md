---
title: Quota storage limit
---

# RDSQuotaStorageLimit

## Meaning

Alert is triggered when the total of RDS storage is close from the AWS quota limit.

## Impact

Once quota is reached:

- Unable to create new RDS instances
- Unable to extend existing RDS storage

## Diagnosis

{{< hint info >}}
**AWS default quota**

AWS allows 100,000 Gigabytes of RDS storage to AWS accounts, you can request service increase if you need more storage.

This quota doesnt apply to Amazon Aurora, which has a maximum cluster volume of 128 TiB for each DB cluster
{{< /hint >}}

1. Open `RDS instance overview` to check if all RDS instances are necessary

## Mitigation

1. Delete unused RDS instances

1. Request quota increase

    1. Open `AWS service quota` console and select `Amazon Relational Database Service`

    1. Select `DB instances` and click on `Request increase at account-level`

    1. Fill the form with quota increase

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
