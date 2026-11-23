USE final_HR;

--تحديد فئات الموظفين الأكثر عرضة لترك الشركة، حسب القسم والعمل الإضافي والسفر ومسافة المنزل ومدة العمل.
SELECT
    d.Department,
    e.OverTime,
    e.BusinessTravel,

    CASE
        WHEN e.DistanceFromHome_KM <= 10 THEN '0-10 KM'
        WHEN e.DistanceFromHome_KM <= 20 THEN '11-20 KM'
        ELSE '21+ KM'
    END AS Distance_Band,

    e.Tenure_Band,

    COUNT(*) AS Employee_Count,

    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END)
        AS Leavers,

    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1.0 ELSE 0 END)
        * 100 / COUNT(*) AS Attrition_Rate

FROM Dim_Employee e
JOIN Dim_Department d
    ON e.DepartmentID = d.DepartmentID

GROUP BY
    d.Department,
    e.OverTime,
    e.BusinessTravel,
    CASE
        WHEN e.DistanceFromHome_KM <= 10 THEN '0-10 KM'
        WHEN e.DistanceFromHome_KM <= 20 THEN '11-20 KM'
        ELSE '21+ KM'
    END,
    e.Tenure_Band

HAVING COUNT(*) >= 30

ORDER BY Attrition_Rate DESC;
-------------------------------------------------
--تحليل قدرة الشركة على الاحتفاظ بالموظفين خلال أول سنة من تعيينهم، ومعرفة أسباب مغادرتهم المبكرة.


---  اول جزء: معدل المغادرة خلال أول سنة حسب سنة وربع التعيين.
SELECT
    hd.Year AS Hire_Year,
    hd.Quarter AS Hire_Quarter,

    COUNT(*) AS Total_Hires,

    SUM(CASE
        WHEN e.TerminationDateKey IS NOT NULL
         AND DATEDIFF(
                DAY,
                hd.Date,
                td.Date
             ) BETWEEN 0 AND 365
        THEN 1 ELSE 0
    END) AS Early_Leavers,

    SUM(CASE
        WHEN e.TerminationDateKey IS NOT NULL
         AND DATEDIFF(
                DAY,
                hd.Date,
                td.Date
             ) BETWEEN 0 AND 365
        THEN 1.0 ELSE 0
    END) * 100 / COUNT(*) AS Early_Attrition_Rate

FROM Dim_Employee e

JOIN Dim_Date hd
    ON e.HireDateKey = hd.DateKey

LEFT JOIN Dim_Date td
    ON CAST(e.TerminationDateKey AS INT) = td.DateKey

GROUP BY hd.Year, hd.Quarter

ORDER BY hd.Year, hd.Quarter;

--تاني  جزء: أسباب مغادرة الموظفين خلال أول سنة حسب القسم 
SELECT
    d.Department,
    e.Termination_Reason,
    COUNT(*) AS Early_Leavers

FROM Dim_Employee e

JOIN Dim_Date hd
    ON e.HireDateKey = hd.DateKey

JOIN Dim_Date td
    ON CAST(e.TerminationDateKey AS INT) = td.DateKey

JOIN Dim_Department d
    ON e.DepartmentID = d.DepartmentID

WHERE DATEDIFF(DAY, hd.Date, td.Date) BETWEEN 0 AND 365

GROUP BY
    d.Department,
    e.Termination_Reason

ORDER BY Early_Leavers DESC;
------------------------------------------------
--مقارنة مستوى رضا الموظفين اللي سابوا الشركة بالموظفين اللي لسه موجودين، اعتمادًا على آخر تقييم ليهم.

SELECT
    d.Department,
    e.Attrition,

    COUNT(*) AS Employee_Count,

    AVG(CAST(f.EnvironmentSatisfaction AS FLOAT))
        AS Avg_Environment_Satisfaction,

    AVG(CAST(f.JobSatisfaction AS FLOAT))
        AS Avg_Job_Satisfaction,

    AVG(CAST(f.RelationshipSatisfaction AS FLOAT))
        AS Avg_Relationship_Satisfaction,

    AVG(CAST(f.WorkLifeBalance AS FLOAT))
        AS Avg_WorkLife_Balance,

    AVG(CAST(f.Avg_Satisfaction AS FLOAT))
        AS Avg_Overall_Satisfaction

FROM Fact_PerformanceReview f

JOIN Dim_Employee e
    ON f.EmployeeID = e.EmployeeID

JOIN Dim_Department d
    ON e.DepartmentID = d.DepartmentID

WHERE f.ReviewDateKey = (
    SELECT MAX(f2.ReviewDateKey)
    FROM Fact_PerformanceReview f2
    WHERE f2.EmployeeID = f.EmployeeID
)

GROUP BY
    d.Department,
    e.Attrition

ORDER BY
    d.Department,
    e.Attrition;
    -----------------------------------------
    --تحليل الفرق في الرواتب بين الذكور والإناث داخل نفس الوظيفة والمستوى الوظيفي.

    SELECT
    d.Department,
    j.JobRole,
    j.Job_Level,
    e.Gender,

    COUNT(*) AS Employee_Count,

    AVG(CAST(e.Salary AS FLOAT)) AS Average_Salary

FROM Dim_Employee e

JOIN Dim_JobRole j
    ON e.JobRoleID = j.JobRoleID

JOIN Dim_Department d
    ON e.DepartmentID = d.DepartmentID

GROUP BY
    d.Department,
    j.JobRole,
    j.Job_Level,
    e.Gender

ORDER BY
    d.Department,
    j.Job_Level,
    j.JobRole,
    e.Gender;

    -----------------------------------
    --معرفة مكان راتب كل موظف بالنسبة لنطاق الرواتب المحدد لوظيفته، وهل ده له علاقة بترك الشركة.

    SELECT
    j.JobRole,
    j.Job_Level,

    CASE
        WHEN e.Salary < j.Salary_Range_Min
            THEN 'Below Range'

        WHEN e.Salary > j.Salary_Range_Max
            THEN 'Above Range'

        WHEN e.Salary <=
            j.Salary_Range_Min +
            (j.Salary_Range_Max - j.Salary_Range_Min) * 0.25
            THEN 'Low Range'

        WHEN e.Salary <=
            j.Salary_Range_Min +
            (j.Salary_Range_Max - j.Salary_Range_Min) * 0.75
            THEN 'Middle Range'

        ELSE 'High Range'
    END AS Salary_Position,

    COUNT(*) AS Employee_Count,

    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END)
        AS Leavers,

    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1.0 ELSE 0 END)
        * 100 / COUNT(*) AS Attrition_Rate

FROM Dim_Employee e

JOIN Dim_JobRole j
    ON e.JobRoleID = j.JobRoleID

GROUP BY
    j.JobRole,
    j.Job_Level,
    CASE
        WHEN e.Salary < j.Salary_Range_Min
            THEN 'Below Range'
        WHEN e.Salary > j.Salary_Range_Max
            THEN 'Above Range'
        WHEN e.Salary <=
            j.Salary_Range_Min +
            (j.Salary_Range_Max - j.Salary_Range_Min) * 0.25
            THEN 'Low Range'
        WHEN e.Salary <=
            j.Salary_Range_Min +
            (j.Salary_Range_Max - j.Salary_Range_Min) * 0.75
            THEN 'Middle Range'
        ELSE 'High Range'
    END

ORDER BY Attrition_Rate DESC;
-----------------------------------------------
--تحديد المديرين اللي تقييمهم للموظفين بيختلف بشكل كبير عن تقييم الموظفين لنفسهم.

SELECT
    m.EmployeeID AS ManagerID,
    m.Full_Name AS Manager_Name,
    d.Department,

    COUNT(*) AS Review_Count,

    AVG(CAST(f.SelfRating - f.ManagerRating AS FLOAT))
        AS Avg_Rating_Gap,

    AVG(ABS(CAST(f.SelfRating - f.ManagerRating AS FLOAT)))
        AS Avg_Absolute_Gap,

    SUM(CASE
        WHEN f.SelfRating > f.ManagerRating THEN 1
        ELSE 0
    END) AS Manager_Rated_Lower,

    SUM(CASE
        WHEN f.SelfRating < f.ManagerRating THEN 1
        ELSE 0
    END) AS Manager_Rated_Higher

FROM Fact_PerformanceReview f

JOIN Dim_Employee e
    ON f.EmployeeID = e.EmployeeID

JOIN Dim_Employee m
    ON e.ManagerID = m.EmployeeID

JOIN Dim_Department d
    ON m.DepartmentID = d.DepartmentID

GROUP BY
    m.EmployeeID,
    m.Full_Name,
    d.Department

HAVING COUNT(*) >= 10

ORDER BY Avg_Absolute_Gap DESC;
-----------------------------------------------

--معرفة هل الزيادات والترقيات بتتناسب مع أداء الموظفين، وهل الموظفين أصحاب الأداء العالي معرضين لترك الشركة


SELECT
    f.ManagerRating,

    COUNT(*) AS Employee_Count,

    AVG(f.Salary_Increase_Pct) * 100
        AS Avg_Salary_Increase_Pct,

    SUM(CASE
        WHEN f.Promoted_After_Review = 'Yes' THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS Promotion_Rate,

    SUM(CASE
        WHEN e.Attrition = 'Yes' THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS Attrition_Rate

FROM Fact_PerformanceReview f

JOIN Dim_Employee e
    ON f.EmployeeID = e.EmployeeID

WHERE f.ReviewDateKey = (
    SELECT MAX(f2.ReviewDateKey)
    FROM Fact_PerformanceReview f2
    WHERE f2.EmployeeID = f.EmployeeID
)

GROUP BY f.ManagerRating

ORDER BY f.ManagerRating;

------------------------------------
--مقارنة مدة انتظار الترقية بين المجموعات المختلفة حسب النوع والعرق والفئة العمرية، داخل نفس المستوى الوظيفي.


SELECT
    j.Job_Level,
    e.Gender,
    e.Ethnicity,
    e.Age_Group,

    COUNT(*) AS Employee_Count,

    AVG(CAST(e.YearsSinceLastPromotion AS FLOAT))
        AS Avg_Years_Since_Last_Promotion

FROM Dim_Employee e

JOIN Dim_JobRole j
    ON e.JobRoleID = j.JobRoleID

GROUP BY
    j.Job_Level,
    e.Gender,
    e.Ethnicity,
    e.Age_Group

ORDER BY
    j.Job_Level,
    Avg_Years_Since_Last_Promotion DESC;
    ----------------------------------------
    --معرفة هل الاستفادة من فرص التدريب بتساعد على تحسين تقييم أداء الموظفين
   
   SELECT
    d.Department,

    CASE
        WHEN f.Training_Utilization_Pct <= 0.5
            THEN 'Low Utilization'
        WHEN f.Training_Utilization_Pct <= 1
            THEN 'Medium Utilization'
        ELSE 'High Utilization'
    END AS Training_Category,

    COUNT(*) AS Review_Count,

    AVG(CAST(f.ManagerRating - prev.ManagerRating AS FLOAT))
        AS Avg_Rating_Improvement,

    SUM(CASE
        WHEN f.ManagerRating > prev.ManagerRating THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS Improvement_Rate

FROM Fact_PerformanceReview f

JOIN Fact_PerformanceReview prev
    ON f.EmployeeID = prev.EmployeeID
    AND f.Review_Number = prev.Review_Number + 1

JOIN Dim_Employee e
    ON f.EmployeeID = e.EmployeeID

JOIN Dim_Department d
    ON e.DepartmentID = d.DepartmentID

GROUP BY
    d.Department,
    CASE
        WHEN f.Training_Utilization_Pct <= 0.5
            THEN 'Low Utilization'
        WHEN f.Training_Utilization_Pct <= 1
            THEN 'Medium Utilization'
        ELSE 'High Utilization'
    END

ORDER BY
    d.Department,
    Avg_Rating_Improvement DESC;
    ---------------------------------------------
    --أول جزء: عدد الموظفين اللي اتعينوا واللي سابوا الشركة كل ربع سنة، وصافي التغيير.
    SELECT
    d.Department,
    dt.Year,
    dt.Quarter,

    SUM(CASE
        WHEN e.HireDateKey = dt.DateKey THEN 1
        ELSE 0
    END) AS Hires,

    SUM(CASE
        WHEN CAST(e.TerminationDateKey AS INT) = dt.DateKey
            THEN 1
        ELSE 0
    END) AS Leavers

FROM Dim_Employee e

JOIN Dim_Department d
    ON e.DepartmentID = d.DepartmentID

JOIN Dim_Date dt
    ON e.HireDateKey = dt.DateKey
    OR CAST(e.TerminationDateKey AS INT) = dt.DateKey

GROUP BY
    d.Department,
    dt.Year,
    dt.Quarter

ORDER BY
    d.Department,
    dt.Year,
    dt.Quarter;
    ---ثاني جزء: مقارنة تكلفة رواتب الموظفين الحاليين بميزانية كل قسم.

    SELECT
    d.Department,
    d.Annual_Budget,

    COUNT(e.EmployeeID) AS Active_Employees,

    SUM(e.Salary) AS Current_Annual_Salary_Cost,

    d.Annual_Budget - SUM(e.Salary)
        AS Remaining_Budget,

    SUM(e.Salary) * 100.0 /
        NULLIF(d.Annual_Budget, 0) AS Budget_Utilization_Pct

FROM Dim_Department d

LEFT JOIN Dim_Employee e
    ON d.DepartmentID = e.DepartmentID
    AND e.Attrition = 'No'

GROUP BY
    d.Department,
    d.Annual_Budget

ORDER BY Budget_Utilization_Pct DESC;