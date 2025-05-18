import chardet

def load_lines(file_path):
    with open(file_path, 'rb') as f:
        raw = f.read()
    import chardet
    encoding = chardet.detect(raw)['encoding']
    text = raw.decode(encoding or 'utf-8', errors='replace')
    # Strip headers, blank lines, normalize whitespace
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return set(lines)

def print_unique_lines(file_paths):
    sets = [load_lines(path) for path in file_paths]
    all_lines = set.union(*sets)
    print("=== Differences ===")
    for line in sorted(all_lines):
        presence = [line in s for s in sets]
        if not all(presence) and any(presence):  # Not present in all
            print(f"{line}")
            for idx, exists in enumerate(presence):
                print(f"  {'✔' if exists else '✘'} {file_paths[idx]}")
            print()

cmp1 = ["uninstall/post.txt", "install/post.txt"]
print_unique_lines(cmp1)