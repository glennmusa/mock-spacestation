# mock-spacestation

A template for deploying a Mock Spacestation and Mock Groundstation to Azure.

## Deploy via Azure Portal

This will use the Azure Custom Template Deployment UI to deploy the Mock Spacestation and Mock Groundstation into a subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fglennmusa%2Fmock-spacestation%2Fmain%2Fmock-spacestation.json)

## Deploy via Azure CLI:

If you're comfortable with CLI tools, the Azure CLI provides the `deployment` command to deploy the Mock Spacestation and Mock Groundstation to a subscription:

```plaintext
az deployment sub create \
  --location "eastus" \
  --name "MockSpacestation" \
  --template-file ./mock-spacestation.json
```
