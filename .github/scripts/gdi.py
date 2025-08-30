# Collect all modules and dump to json
import os, json, datetime

ignore = {".git", ".github", "__pycache__", ".DS_Store"}

modules = []
for item in os.listdir("./modules"):
    if os.path.isdir(os.path.join("./modules", item)) and item not in ignore:
        modules.append({"name": item, "path": f"modules/{item}/"})

legend = {
    "last_updated": datetime.datetime.utcnow().isoformat() + "Z",
    "modules": modules
}

with open("legend.json", "w") as f:
    json.dump(legend, f, indent=2)