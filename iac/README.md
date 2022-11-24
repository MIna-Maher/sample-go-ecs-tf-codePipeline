```
aws s3api create-bucket --bucket prd-s3-bakend-demo4 --region us-east-1
aws s3api put-bucket-encryption --bucket prd-s3-bakend-demo4 --region us-east-1 --server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\": {\"SSEAlgorithm\": \"AES256\"}}]}"
aws s3api put-public-access-block --bucket prd-s3-bakend-demo4 --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" --region us-east-1
