# After editing df above:
import pandas as pd
import csv

input_filename = 'SMEMTemplate2.csv'
output_filename = 'smem_generated2.txt'

with open(input_filename, newline='') as csvfile, \
     open(output_filename, 'w') as out:
    reader = csv.reader(csvfile)
    for row in reader:
        for val in row:
            # strip whitespace just in case, then write one per line
            v = val.strip()
            if v:
                out.write(f"{v}\n")
    
    
# print(data)

# for row in range(30):
#     for col in range(40):
#         print(f"{data.iat[row, col]}")

# with open('smem_generated.mem', 'w') as f:
#     for r in range(30):
#         for c in range(40):
#             f.write(f"{df.iat[r, c]}\n")


# 2) Verify it’s 30 rows by 40 columns
# print(data)
# assert data.shape == (30, 40), "Expected CSV with 30 rows and 40 columns"

# # 3) Write out the smem.mem file
# with open('smem_generated.mem', 'w') as f:
#     for row in data.itertuples(index=False):
#         for val in row:
#             f.write(f"{val}\n")

# print("smem_generated.mem created with", data.size, "entries.")