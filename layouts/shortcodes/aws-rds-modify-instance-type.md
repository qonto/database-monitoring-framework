<!-- markdownlint-disable-next-line MD041 // this content is included in section -->
Warning: Modifying an AWS instance generates downtime:

- Multi-AZ enabled: Instance failover will be triggered (< 1 minute downtime)
- No multi-az: Instance will restarted with new hardware (~15 minutes downtime)

See [AWS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html)
