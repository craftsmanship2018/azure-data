# Azure SQL DB

Story
Star Light is a family run retail business. It has a customer dataset that has been created and run on a LAN instance of SQL server. The database holds basic information such as customers, products, and orders.

As the business has grown, the company has seen an increase in the cost of purchasing and managing their server environment. The company wants to reduce infrastructure costs and improve deployment and availability of their data to multiple subsystems.

Technology
The company wishes to continue using their SQL Database as is, but do not want to manage their own servers and database instances. They have chosen Azure to host the Database as it should port easily, while offering reduced maintenance and cost-effective scalability.

Getting Started
1.Clone or download this repository
2.Open src/SoftwareCraftmanShip2018_DB.sln in Visual Studio 2017
3.Create a Local DB called StarLight.
4.Change DB Solution properties to be same version as local Database.
4.Configure connection to point to your DB Instance
3.Build the solution and run the test to ensure it works.

Goal

Build a CI/CD pipeline that will build, test and deploy the DB in a safe and repeatable way. 
The pipleline should:
•Be triggered by source control
•Execute all included unit tests
•Publish to a UAT environment
•Once the UAT Sign off is received release changes to Production Environment

Change Scenario

As part of this work one (1) development change has been identified that needs to be delivered with this work:
1. Customer must be amended to hold email address. 

