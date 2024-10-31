import os
import sys


def process_subject(subject, directory_path, rcs):
    subject_path = os.path.join(directory_path, subject)
    files = sorted([f for f in os.listdir(subject_path) if f.startswith('rc')])
    
    rcs['rc1'].append(os.path.join(directory_path, subject, files[0]))
    rcs['rc2'].append(os.path.join(directory_path, subject, files[1]))
    rcs['rc3'].append(os.path.join(directory_path, subject, files[2]))
    rcs['rc4'].append(os.path.join(directory_path, subject, files[3]))
    rcs['rc5'].append(os.path.join(directory_path, subject, files[4]))
    rcs['rc6'].append(os.path.join(directory_path, subject, files[5]))

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python plot_trans.py <directory_path>")
        sys.exit(1)

    directory_path = os.path.abspath(sys.argv[1])

    rcs = {
        'rc1': [],
        'rc2': [],
        'rc3': [],
        'rc4': [],
        'rc5': [],
        'rc6': []
    }

    if not os.path.isdir(directory_path):
        print(f"The provided path '{directory_path}' is not a directory.")
        sys.exit(1)

    subject_directories = sorted([d for d in os.listdir(directory_path) if os.path.isdir(os.path.join(directory_path, d))])
    print(f"Found {len(subject_directories)} directories in {directory_path}")

    for subject in subject_directories:
        process_subject(subject, directory_path, rcs)

    for key in rcs:
        print('*' * 40)
        for file in rcs[key]:
            print(file)