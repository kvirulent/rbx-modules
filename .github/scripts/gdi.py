# Collect all modules and dump to json
import os, json, datetime, shutil, json

ignore = {".git", ".github", "__pycache__", ".DS_Store"}

modules = []
for item in os.listdir("./modules"):
    if os.path.isdir(os.path.join("./modules", item)) and item not in ignore:
        try:
            with open(os.path.join("./modules", item, "meta.json")) as f:
                meta = json.load(f)

            modules.append({
                "name": item, 
                "path": f"modules/{item}/", 
                "last_updated": meta['last_updated'], 
                "version": meta['version']
            })
        except FileNotFoundError:
            print(f"Metadata for {item} was not found.")
        except json.JSONDecodeError as e:
            print(f"Metadata for {item} is malformed.\n At {e.lineno},{e.colno}, error: {e.msg}")
        except Exception as e:
            print(f"Failed to build entry for {item}: \n {e}")

legend = {
    "last_updated": datetime.datetime.utcnow().isoformat() + "Z",
    "modules": modules
}

os.makedirs("public", exist_ok=True)

with open("public/legend.json", "w") as f:
    json.dump(legend, f, indent=2)

if os.path.exists("public/modules"):
    shutil.rmtree("public/modules")

shutil.copytree("modules", "public/modules")