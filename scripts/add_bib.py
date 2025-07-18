import os
import re

def replace_or_insert_bibliography(tex_file):
    with open(tex_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    replaced = False
    inserted = False

    bib_pattern = re.compile(r'\\bibliography\s*\{[^}]+\}')

    for line in lines:
        if bib_pattern.search(line) and not replaced:
            new_lines.append('\\bibliographystyle{plainnat}\n')
            new_lines.append('\\bibliography{../../../MASTER_REFERENCES}\n')
            replaced = True
        else:
            new_lines.append(line)

    if not replaced:
        # Look for \end{document} and insert before it
        final_lines = []
        for line in new_lines:
            if '\\end{document}' in line and not inserted:
                final_lines.append('\\bibliographystyle{plainnat}\n')
                final_lines.append('\\bibliography{../../../MASTER_REFERENCES}\n')
                inserted = True
            final_lines.append(line)
        new_lines = final_lines

    with open(tex_file, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    action = "🔧 Replaced" if replaced else ("➕ Inserted" if inserted else "⚠️ Skipped (no \\end{document})")
    print(f"{action}: {tex_file}")

def walk_tex_files(root_dir):
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.tex'):
                tex_path = os.path.join(dirpath, filename)
                replace_or_insert_bibliography(tex_path)

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 2:
        print("Usage: python replace_bibliography.py <directory>")
    else:
        walk_tex_files(sys.argv[1])
