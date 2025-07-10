import re
import os
import sys

def find_all_tex_files(root_dir):
    tex_files = []
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.tex'):
                tex_files.append(os.path.join(dirpath, filename))
    return tex_files

def extract_citations(tex_files):
    all_citations = set()
    cite_pattern = re.compile(r'\\cite[tp]?[a-zA-Z]*\*?\s*\{\s*([^}]+?)\s*\}', re.MULTILINE)

    for tex_path in tex_files:
        with open(tex_path, 'r', encoding='utf-8') as f:
            tex = f.read()

        cite_commands = cite_pattern.findall(tex)
        for group in cite_commands:
            for key in group.split(','):
                all_citations.add(key.strip())

    print(f"\n✅ Found {len(all_citations)} unique citation(s) across {len(tex_files)} .tex file(s):")
    for c in sorted(all_citations):
        print(f"  - {c}")
    return all_citations

def extract_bib_entries(bib_file, needed_keys):
    entries = {}
    needed_keys_lc = {key.lower() for key in needed_keys}
    entry_pattern = re.compile(r'@(\w+)\s*\{\s*([^,]+),')

    if not os.path.exists(bib_file):
        print(f"❌ MASTER_REFERENCES.bib not found at: {bib_file}")
        return {}

    with open(bib_file, 'r', encoding='utf-8') as f:
        content = f.read()

    chunks = re.split(r'(?=@\w+\s*\{)', content)
    for chunk in chunks:
        if match := entry_pattern.match(chunk):
            key_raw = match.group(2).strip()
            key_lc = key_raw.lower()
            if key_lc in needed_keys_lc:
                entries[key_raw] = chunk.strip()

    matched_keys_lc = {k.lower() for k in entries.keys()}
    missing = needed_keys_lc - matched_keys_lc
    if missing:
        print(f"\n❗ Missing {len(missing)} citation(s) from MASTER_REFERENCES.bib:")
        for key in sorted(missing):
            print(f"  - {key}")

    return entries

def write_references_bib(output_dir, entries):
    os.makedirs(output_dir, exist_ok=True)
    out_path = os.path.join(output_dir, 'references.bib')
    with open(out_path, 'w', encoding='utf-8') as f:
        for entry in entries.values():
            f.write(entry + '\n\n')
    return out_path

def main(tex_file):
    # Define context paths
    base_dir = os.path.dirname(os.path.abspath(tex_file))
    project_root = os.path.abspath(os.path.join(base_dir, "..", ".."))
    master_bib_path = os.path.join(project_root, "MASTER_REFERENCES.bib")

    # Gather all tex files in subtree
    tex_files = find_all_tex_files(base_dir)
    citations = extract_citations(tex_files)
    if not citations:
        print("❌ No citations found.")
        return

    bib_entries = extract_bib_entries(master_bib_path, citations)
    if not bib_entries:
        print("❌ No matching entries found in MASTER_REFERENCES.bib.")
        return

    output_dir = os.path.join(base_dir, 'references')
    out_path = write_references_bib(output_dir, bib_entries)
    print(f"\n✅ Created: {out_path} with {len(bib_entries)} entries.")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python extract_references.py <main.tex>")
    else:
        main(sys.argv[1])
