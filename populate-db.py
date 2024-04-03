import plyvel

with open("db.txt", "r") as f:
    db_txt = f.readlines()

data = [eval(line) for line in db_txt]

db = plyvel.DB("/opt/gcups/db/gcups-rxdb-1-settings", create_if_missing=True)
for key, value in data:
    db.put(key, value)
