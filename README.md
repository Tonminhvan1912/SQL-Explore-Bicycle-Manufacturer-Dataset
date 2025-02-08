# [SQL] Explore Bicycle Manufacturer Dataset
## 1. **Introduction**

Conducted an in-depth analysis of the Bicycle Manufacturer dataset using SQL on Google BigQuery to uncover insights that guide business strategies.

## 2. **Dataset access**

The eCommerce dataset is stored in a public Google BigQuery dataset. To access the dataset, follow these steps:

- Log in to your Google Cloud Platform account and create a new project.
- Navigate to the BigQuery console and select your newly created project.
- In the navigation panel, select "Add Data" and then "Start a project by name".
- Enter the project ID **"adventureworks2019"** and click "Enter".
- Click on the **"adventureworks2019"** workspace to open it.
## 3. **Exploring the Dataset**

In this project, I will write 08 query in Bigquery base on Google Analytics dataset

**Query 01: Calculate Quantity of items, Sales value & Order quantity by each Subcategory in last 12M**

- SQL code

![Image](https://github.com/user-attachments/assets/fbffb134-d773-4f51-8d85-b2590702bd3a)

- Query results

![Image](https://github.com/user-attachments/assets/8669f148-8a35-4c63-9d91-2ac29644d217)

**Query 02: Calculate % YoY growth rate by SubCategory & release top 3 category with highest grow rate.**

- SQL code

![Image](https://github.com/user-attachments/assets/17d28db2-2e47-4be5-84da-ff2b67bf6c1b)

- Query results

![Image](https://github.com/user-attachments/assets/89ea3dcb-c422-4180-ae6a-18c5f57186e8)

**Query 3: Ranking Top 3 TeritoryID with biggest Order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number**

- SQL code

![Image](https://github.com/user-attachments/assets/4cbf1a24-5a13-4d06-823d-289f6a945d80)

- Query results

![Image](https://github.com/user-attachments/assets/3d3e1b6d-6f0a-41f6-bd18-9ac6485d1685)

**Query 04: Calculate Total Discount Cost belongs to Seasonal Discount for each SubCategory**

- SQL code

![Image](https://github.com/user-attachments/assets/62e0c14e-58a5-472b-bac4-e266d8e22bf8)

- Query results

![Image](https://github.com/user-attachments/assets/57f5e531-7ed6-4686-9883-846424291e33)

**Query 5: Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis)**

- SQL code

![Image](https://github.com/user-attachments/assets/fc04522f-2b7d-4d67-8d35-073f5c32a89f)
![Image](https://github.com/user-attachments/assets/477301f5-10c9-49f5-a63e-3269bf37be73)

- Query results

![Image](https://github.com/user-attachments/assets/e804a161-8d10-4690-bde2-b0d8e1f332bd)

**Query 6: Trend of Stock level & MoM diff % by all product in 2011. If %gr rate is null then 0. Round to 1 decimal**

- SQL code

![Image](https://github.com/user-attachments/assets/3a38da78-725a-45d2-9ab5-2825bca4a521)

- Query results

![Image](https://github.com/user-attachments/assets/e7324f99-51ad-4ac3-8f1e-9d213ff363d9)

**Query 7: Calculate Ratio of Stock / Sales in 2011 by product name, by month. Order results by month desc, ratio desc. Round Ratio to 1 decimal mom yoy**

- SQL code

![Image](https://github.com/user-attachments/assets/abf04cc5-0c07-4333-b5f8-61bd02a6d301)

- Query results

![Image](https://github.com/user-attachments/assets/4f0a435d-95b3-4353-b394-4d76e84c8f1e)

**Query 8: No of order and value at Pending status in 2014**

- SQL code

![Image](https://github.com/user-attachments/assets/96d99e99-b1ce-4a83-8735-a3c8c9e41cdb)

- Query results

![Image](https://github.com/user-attachments/assets/a138d0e2-f488-40f5-a09b-0e3124ce7af3)

## 4. **Insights**
- The top 3 categories with the highest growth rates are Mountain Frames, Socks, and Road Frames.
- The top 3 Territory IDs with the largest order quantities from 2011 to 2024 are 4, 6, and 1, suggesting strong market demand and effective sales strategies in these areas.
- Customers tend to return for purchases at a rate of 10% three months after their first purchase. However, this retention rate remains low, with subsequent months showing only about 3-4%.
- In 2014, there were a total of 224 orders in "Pending" status, with an order value of approximately 387,359.01. The number of orders in "Pending" status indicates that there may be delays in the order processing workflow. This could impact revenue if not addressed promptly.
## 5. **Recommendations**
- Increase marketing efforts for Mountain Frames, Socks, and Road Frames. Consider targeted campaigns highlighting their unique features and benefits to capture more market share.
- Develop region-specific marketing and sales strategies for Territories 4, 6, and 1. Utilize data analytics to understand customer preferences in these areas and tailor promotions accordingly. Ensure that inventory levels are well-managed in these territories to meet demand and avoid stockouts, enhancing customer satisfaction.
- Implement a customer loyalty program to incentivize repeat purchases. Offer rewards, discounts, or exclusive access to new products to encourage customers to return.
- Analyze the order processing workflow to identify bottlenecks that contribute to orders being in "Pending" status. Implement process improvements or automation to enhance efficiency.
- Continuously monitor sales data, customer feedback, and order processing metrics to assess the effectiveness of implemented strategies. Be prepared to adapt based on what the data reveals.
