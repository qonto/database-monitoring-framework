---
title: Quota instance limit
---

# RDSQuotaInstanceLimit

## Meaning

Alert is triggered when the total storage used on RDS is close from the AWS quota limit.

## Impact

Once quota is reached:

- Unable to create new RDS instances

## Diagnosis

{{< hint info >}}
**AWS default quota**

By default, you can have up to a total of 40 DB instances. RDS DB instances, Aurora DB instances, Amazon Neptune instances, and Amazon DocumentDB instances apply to this quota. You can request service increase if you need more instances.
{{< /hint >}}

Open `RDS instance overview` dashboard and check that all RDS instances are necessary.

## Mitigation

1. Delete unused RDS instances

1. Request quota increase

    1. Open `AWS service quota` console and select `Amazon Relational Database Service`

    1. Select `Total storage for all DB instances` and click on `Request increase at account-level`

    1. Fill the form with quota increase

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
