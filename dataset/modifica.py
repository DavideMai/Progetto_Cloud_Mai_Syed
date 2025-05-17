import pandas as pd

# Percorso del file originale
input_file = "ONU.csv"
# Percorso del file di output
output_file = "ONU_modified.csv"

# Caricamento del file ONU
df = pd.read_csv(input_file)

# Aggiunta delle colonne
df["Country Name"] = "International"
df["Country Code"] = "II"

# Salvataggio del nuovo file
df.to_csv(output_file, index=False)

print("File modificato salvato come ONU_modified.csv")
