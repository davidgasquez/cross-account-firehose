# Cross Account Firehose Stream

Terraform code to create a cross account Firehose stream delivered to Redshift.

## Requirements

- Two AWS accounts
- A Redshift cluster in one of those accounts
- [Terraform](https://www.terraform.io/)

## Setup

Before making any resources we need to create the table in Refshift.
Execute the following query to create a sample table:

```SQL
create table temp.firehose_test_table
(
	TICKER_SYMBOL varchar(4),
	SECTOR varchar(16),
	CHANGE float,
	PRICE float
);
```

We can continue with `terraform init`, `terraform plan` and `terraform apply`.
Terraform will ask for the required variables to connect to Redshift.

Once everything is up we can go to the [Firehose Stream console](https://console.aws.amazon.com/firehose/home?region=us-east-1#/details/redshift_delivery_stream) and start sending demo data.
We'll need to wait a few minutes until the data starts to show in the table. You can run the query `select * from temp.firehose_test_table limit 10;` to check the table.
