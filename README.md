
# Human Resource Dataset Analysis

## Project Overview

This project focuses on analyzing Human Resource data to gain insights into workforce management, employee attrition, job satisfaction, performance evaluation, compensation, and employee retention.

The project involves data preparation using Python, database design and management using Microsoft SQL Server, and answering key HR business questions through SQL queries.

## 1. Data Preparation

The original datasets were cleaned and transformed using Python and Pandas.

### Dataset Organization

- **Raw_Data:** Contains the original datasets before any modifications.
- **Clean_Data:** Contains the cleaned and processed datasets after applying data cleaning and transformation techniques.

The original raw datasets were preserved to maintain data integrity and reproducibility.

### Data Cleaning Notebook

The data cleaning and preparation process is documented in:

`hr_workforce_Cleaned.ipynb`

## 2. Database Design

A relational database was designed and implemented using Microsoft SQL Server.

The database includes dimension tables and fact tables to organize employee information and performance review records.

### Database Schema (ERD)

The following diagram illustrates the database structure, including primary keys, foreign keys, and relationships between tables.

![Database Schema](Database_Schema/HR_Database_Schema.png)

## 3. SQL Business Analysis

Microsoft SQL Server was used to analyze HR data and answer 10 business questions using SQL queries.

The analysis covers:

1. **Employee Attrition Analysis:** Identifying employee segments with higher attrition rates based on department, overtime, business travel, distance from home, and tenure.

2. **Early Employee Attrition:** Analyzing employee retention during the first year of employment and investigating early termination reasons.

3. **Employee Satisfaction Analysis:** Comparing satisfaction levels between employees who left the company and those who remained, based on their latest performance reviews.

4. **Gender Pay Gap Analysis:** Comparing average salaries between male and female employees within the same department, job role, and job level.

5. **Salary Range Analysis:** Evaluating employee salaries against their job-specific salary ranges and examining their relationship with attrition.

6. **Manager Evaluation Analysis:** Identifying differences between employee self-ratings and manager ratings.

7. **Performance, Compensation & Promotion Analysis:** Investigating the relationship between employee performance, salary increases, promotions, and attrition.

8. **Promotion Opportunities Analysis:** Comparing the time since the last promotion across gender, ethnicity, and age groups within the same job level.

9. **Training Effectiveness Analysis:** Examining the relationship between training utilization and improvements in employee performance ratings.

10. **Workforce Movement & Department Budget Analysis:** Analyzing quarterly hires and departures and comparing employee salary costs against departmental budgets.

The SQL queries are available in the `SQL` folder.

## 4. Database Backup

A SQL Server database backup is included in the repository to support database restoration and future use.

The backup file is available in the `Database_Backup` folder.

## 5. Repository Structure

```text
HR-Analytics/
│
├── Raw_Data/
├── Clean_Data/
│
├── Database_Backup/
│   └── HR_Database_Backup.bak
│
├── Database_Schema/
│   └── HR_Database_Schema.png
│
├── SQL/
│   └── Business_Questions.sql
│
├── hr_workforce_Cleaned.ipynb
├── hr_project_description.pdf
├── team_members.pdf
│
└── README.md
```

## 6. Tools & Technologies

- **Python:** Data Cleaning and Preparation.
- **Pandas:** Data Manipulation and Transformation.
- **Jupyter Notebook:** Data Preparation Workflow.
- **Microsoft SQL Server:** Database Design and SQL Analysis.
- **Git & GitHub:** Version Control and Project Documentation.

