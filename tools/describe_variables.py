import pandas as pd

f = os.path.join(input_dir, r'Website manifest.xlsx')
email_df = pd.read_excel(f, 'Email addresses')

for row in download_df.iterrows():
