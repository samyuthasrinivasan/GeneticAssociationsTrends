import mysql.connector
import matplotlib.pyplot as plt

# Creating connection object
mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="gad"
)

cursor = mydb.cursor()

# Define diseases with correct SQL wildcard search patterns
diseases = {
    "Alzheimer’s": "%Alzheimer%",
    "Parkinson’s": "%Parkinson%",
    "Diabetes": "%diabetes, type 1%",
    "Asthma": "%asthma%"
}


diseases_data = {}
query = """
    SELECT year, COUNT(*) AS num_records 
    FROM gad 
    WHERE association = 'Y' 
      AND LOWER(phenotype) LIKE %s 
      AND year REGEXP '^[0-9]{4}$' 
    GROUP BY year 
    ORDER BY year ASC
"""

for disease_name, disease_pattern in diseases.items():
    cursor.execute(query, (disease_pattern,))
    years = []
    num_records = []

    for row in cursor.fetchall():  # Ensure fetchall() is used
        years.append(int(row[0]))  # Convert year to integer
        num_records.append(int(row[1]))  # Convert count to integer

    diseases_data[disease_name] = (years, num_records)

    # Debugging: Print retrieved data
    print(disease_name, "Years:", years, "Records:", num_records)

cursor.close()
mydb.close()

# Plot the data
plt.figure(figsize=(12, 6))

for disease, (years, num_records) in diseases_data.items():
    if years:  # Ensure the list is not empty
        plt.plot(years, num_records, marker='o', linestyle='-', label=disease)

# Formatting the chart
plt.xlabel("Year")
plt.ylabel("Number of Genetic Associations")
plt.title("Genetic Associations Over Time for Multiple Diseases")
plt.legend()
plt.grid(True)

plt.show()
