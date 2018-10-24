# Azure SQL Database

## Story

Star Light is a family run retail business. It has a customer dataset that has been created and run on a LAN instance of SQL server. The database holds basic information such as customers, products, and orders.

As the business has grown, the company has seen an increase in the cost of purchasing and managing their server environment. The company wants to reduce infrastructure costs and improve deployment and availability of their data to multiple subsystems.

## Technology

The company wishes to continue using their SQL Database as is, but do not want to manage their own servers and database instances. They have chosen Azure to host the Database as it should port easily, while offering reduced maintenance and cost-effective scalability.

## Getting Started

1. Fork and clone this repository
1. Open `src\SoftwareCraftmanShip2018_DB.sln` in Visual Studio 2017
1. Create a local SQL Server database named StarLight
1. Change project properties to be same version as local database
1. Configure connection to point to your database instance via `Properties` > `Debug`
1. Modify App.config in the unit test project to point at your database instance
1. Build the solution, and run the test to ensure it works

## Goal

Build a CI/CD pipeline that will build, test and deploy database changes in a safe and repeatable way. The pipeline should:

- Execute all included unit tests
- Publish to a UAT environment
- Once UAT sign-off has been provided, release changes to a production environment

## Change Scenario

To test the pipeline, a simple change should be committed to the application's repository. You could, for example, amend the customer record to hold email address.
