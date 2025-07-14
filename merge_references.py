#!/usr/bin/env python3
"""
Merge chapter-specific references.bib files into a consolidated bibliography.
Removes duplicates and creates a clean MASTER_REFERENCES.bib
"""

import os
import re
import sys
from pathlib import Path

def parse_bib_entries(content):
    """Parse BibTeX entries and return a dictionary of {key: entry}"""
    entries = {}
    
    # Find all @type{key, ... } entries
    pattern = r'(@\w+\s*\{\s*([^,\s]+)\s*,.*?(?=@\w+\s*\{|$))'
    matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
    
    for full_entry, key in matches:
        # Clean up the key (remove any whitespace)
        clean_key = key.strip()
        entries[clean_key] = full_entry.strip()
    
    return entries

def find_bib_files():
    """Find all references.bib files in chapter directories"""
    bib_files = []
    
    # Look for references.bib in chapter subdirectories
    for chapter_dir in Path("chapters").glob("*"):
        if chapter_dir.is_dir():
            ref_file = chapter_dir / "references" / "references.bib"
            if ref_file.exists():
                bib_files.append(ref_file)
                print(f"Found: {ref_file}")
    
    return bib_files

def merge_bibliography_files(output_file="CONSOLIDATED_REFERENCES.bib"):
    """Merge all chapter bibliography files, removing duplicates"""
    
    bib_files = find_bib_files()
    
    if not bib_files:
        print("No references.bib files found in chapter directories!")
        return
    
    all_entries = {}
    duplicate_count = 0
    
    print(f"\nMerging {len(bib_files)} bibliography files...")
    
    for bib_file in bib_files:
        print(f"Processing: {bib_file}")
        
        try:
            with open(bib_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            entries = parse_bib_entries(content)
            
            for key, entry in entries.items():
                if key in all_entries:
                    # Check if entries are actually different
                    if all_entries[key] != entry:
                        print(f"  WARNING: Different entries for key '{key}'")
                        print(f"    Keeping first occurrence from earlier file")
                    duplicate_count += 1
                else:
                    all_entries[key] = entry
            
            print(f"  Added {len(entries)} entries")
            
        except Exception as e:
            print(f"  ERROR reading {bib_file}: {e}")
    
    # Write consolidated file
    print(f"\nWriting {len(all_entries)} unique entries to {output_file}")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("% Consolidated bibliography from chapter-specific references.bib files\n")
        f.write("% Generated automatically - do not edit manually\n\n")
        
        # Sort entries alphabetically by key
        for key in sorted(all_entries.keys()):
            f.write(all_entries[key])
            f.write("\n\n")
    
    print(f"✅ Successfully created {output_file}")
    print(f"📊 Total entries: {len(all_entries)}")
    print(f"🔄 Duplicates removed: {duplicate_count}")
    
    return output_file

def backup_master_references():
    """Backup existing MASTER_REFERENCES.bib"""
    master_file = Path("MASTER_REFERENCES.bib")
    if master_file.exists():
        backup_file = Path("MASTER_REFERENCES.bib.backup")
        print(f"Backing up existing {master_file} to {backup_file}")
        backup_file.write_text(master_file.read_text())

if __name__ == "__main__":
    print("🔧 Bibliography Consolidation Tool")
    print("=" * 40)
    
    # Backup existing master file
    backup_master_references()
    
    # Merge all bibliography files
    consolidated_file = merge_bibliography_files()
    
    # Option to replace MASTER_REFERENCES.bib
    if consolidated_file:
        replace = input(f"\nReplace MASTER_REFERENCES.bib with {consolidated_file}? [y/N]: ")
        if replace.lower() in ['y', 'yes']:
            os.rename(consolidated_file, "MASTER_REFERENCES.bib")
            print("✅ MASTER_REFERENCES.bib updated!")
        else:
            print(f"📁 Consolidated bibliography saved as {consolidated_file}")
    
    print("\n🎉 Done!")