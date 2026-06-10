import os
import shutil
from datetime import datetime

PLANS_DIR = os.path.join(".cursor", "plans")
ARCHIVE_DIR = os.path.join(PLANS_DIR, ".archived")

def ensure_dirs():
    os.makedirs(PLANS_DIR, exist_ok=True)
    os.makedirs(ARCHIVE_DIR, exist_ok=True)

def archive_plans():
    ensure_dirs()
    # Only pull files directly under plans/, ignoring directories (like .archived)
    files = [f for f in os.listdir(PLANS_DIR) if os.path.isfile(os.path.join(PLANS_DIR, f))]
    
    if not files:
        print("🎉 No active plans found in .cursor/plans/ to archive.")
        return

    print("\n--- Current Plans Found ---")
    for idx, filename in enumerate(files):
        print(f"[{idx}] {filename}")
    
    selection = input("\nEnter the numbers to ARCHIVE (comma-separated, e.g., 0,2) or 'all': ").strip().lower()
    
    to_archive = []
    if selection == 'all':
        to_archive = files
    else:
        try:
            indices = [int(i.strip()) for i in selection.split(",") if i.strip().isdigit()]
            to_archive = [files[i] for i in indices if i < len(files)]
        except ValueError:
            print("❌ Invalid selection. Aborting.")
            return

    if not to_archive:
        print("No files selected. Exiting.")
        return

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    for filename in to_archive:
        src_path = os.path.join(PLANS_DIR, filename)
        
        # Prepend timestamp to protect tracking timeline continuity
        name, ext = os.path.splitext(filename)
        archive_name = f"{timestamp}_{name}{ext}"
        dest_path = os.path.join(ARCHIVE_DIR, archive_name)
        
        shutil.move(src_path, dest_path)
        print(f"📦 Archived: {filename} ➡️ {dest_path}")

if __name__ == "__main__":
    archive_plans()