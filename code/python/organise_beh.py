'''Organises the behavioural information'''
import sys
from pathlib import Path

if __name__ == '__main__':

    if len(sys.argv) < 3:
        print("Usage: python organise_beh.py <source_path> <raw_path>")
        sys.exit(1)

    source_path = sys.argv[1]
    raw_path = sys.argv[2]

    for subject_dir in Path(source_path).iterdir():
        if subject_dir.is_dir():
            print(f"Analysing subject: {subject_dir.name}")
            beh_dir = subject_dir / 'beh'
            if beh_dir.exists() and beh_dir.is_dir():
                for beh_file in beh_dir.iterdir():
                    if beh_file.is_file():
                        target_subject_dir = Path(raw_path) / subject_dir.name
                        if target_subject_dir.exists() and target_subject_dir.is_dir():
                            target_dir = target_subject_dir / Path('beh')
                            target_file = target_dir / beh_file.name

                            target_dir.mkdir(parents=False, exist_ok=True)
                            target_file.write_bytes(beh_file.read_bytes())
                        else:
                            print(f"Directory {target_subject_dir} does not exist")
                            break
