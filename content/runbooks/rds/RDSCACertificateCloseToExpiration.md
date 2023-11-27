---
title: CA Certificate Close to Expiration
---

# RDSCACertificateCloseToExpiration

## Meaning

Alert is triggered when an RDS instance is detected using a CA certificate which is going to expire in less than 15 days.

## Impact

If the certificate is not renewed before expiration, all attempts to initiate an SSL/TLS connection to the RDS instance will fail.

{{< hint warning >}}
**Important**

The `Amazon RDS Root 2019 CA` certificate expires on **Aug 22 17:08:50 2024 UTC**.

- Starting January 25th 2024, RDS instances created without specifying the CA will use `rds-ca-rsa2048-g1``.
- In August 2024, AWS will enforce the CA rotation on all RDS instances on the expiring CA during a window maintenance
{{< /hint >}}

## Diagnosis

- Identify the instance(s) concerned by either:
  - opening the `RDS instances` dashboard
  - or using the following AWS CLI command

    ```bash
    aws rds describe-db-instances | jq '
      [
        .DBInstances[] |
        {
          db_instance_identifier: .DBInstanceIdentifier,
          ca_certificate_identifier: .CACertificateIdentifier,
          ca_certificate_valid_until: .CertificateDetails.ValidTill
        } |
        (now + 1296000) as $date |
        select (
          (.ca_certificate_valid_until | split("+")[0] + "Z" | fromdate) < $date
        )
      ]'
    ```

    Note: `1296000` seconds = 15 days

## Mitigation

Renew your certificate for the instances retrieved above by running:

```bash
aws rds modify-db-instance \
    --db-instance-identifier <your_db_instance> \
    --ca-certificate-identifier <your_new_certificate>
```

Use the `--apply-immediately` flag if you wish to change the certificate immediately, otherwise it will apply during your next scheduled maintenance window.

{{< hint info >}}
**Tips**

We recommend using the `rds-ca-rsa2048-g1` certificate authority which:

- Has the same properties as `rds-ca-2019` (2048 private key, SHA256 signing alg.) so no risk of incompatibility
- Is valid until 2061
- Change can be done without restarting the instances
{{< /hint >}}

## Additional resources

- [Using SSL with RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html)
- [SSL Certificate Rotation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL-certificate-rotation.html)
