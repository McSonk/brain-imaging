import os
import re
import sys

import matplotlib.pyplot as plt
import pandas as pd

plt.style.use('seaborn-v0_8')

def extract_data(path):
    return pd.read_csv(path, sep='\s+', header=None, names=['x_trans', 'y_trans', 'z_trans', 'pitch', 'roll', 'yaw'])

def merge(df1, df2):
    merge = pd.concat([df1, (df1.iloc[-1] + df2)], ignore_index=True)
    if (merge > 3).any().any():
        print("There are values greater than 3 in the merged dataframe.")
    return merge

def plot_translation(df, rep_n, directory_path, subject_name):
    fig, ax = plt.subplots(figsize=(15, 5))
    df[['x_trans', 'y_trans', 'z_trans']].plot(ax=ax)
    ax.set_title(f'{subject_name} - REP {rep_n}: Translation')
    ax.axhline(y=3, color='r', linestyle='--')
    ax.set_xlabel('Slice')
    ax.set_ylabel('mm')
    fig.savefig(os.path.join(directory_path, f'{subject_name}_rep{rep_n}_translation_plot.png'))
    plt.close(fig)

def plot_rotation(df, rep_n, directory_path, subject_name):
    fig, ax = plt.subplots(figsize=(15, 5))
    df[['pitch', 'roll', 'yaw']].plot(ax=ax)
    ax.set_title(f'{subject_name} - REP {rep_n}: Rotation')
    ax.set_xlabel('Slice')
    ax.set_ylabel('Degrees')
    fig.savefig(os.path.join(directory_path, f'{subject_name}_rep{rep_n}_rotation_plot.png'))
    plt.close(fig)

def process_rep(txt_file, directory_path, subject_name):
    match = re.search(r'\d+', txt_file)
    rep_number = int(match.group())
    data = extract_data(os.path.join(directory_path, txt_file))

    plot_translation(data, rep_number, directory_path, subject_name)
    plot_rotation(data, rep_number, directory_path, subject_name)

    return data

def process_subject(subject, directory_path):
    print(f"Processing subject: {subject}")
    subject_path = os.path.join(directory_path, subject)
    txt_files = [f for f in os.listdir(subject_path) if f.endswith('.txt')]

    dfs = []

    for file_name in txt_files:
        dfs.append(process_rep(file_name, subject_path, subject))
    
    both = merge(dfs[0], dfs[1])
    plot_translation(both, 'both', subject_path, subject)
    plot_rotation(both, 'both', subject_path, subject)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python plot_trans.py <directory_path>")
        sys.exit(1)

    directory_path = sys.argv[1]

    if not os.path.isdir(directory_path):
        print(f"The provided path '{directory_path}' is not a directory.")
        sys.exit(1)

    subject_directories = [d for d in os.listdir(directory_path) if os.path.isdir(os.path.join(directory_path, d))]
    print(f"Found {len(subject_directories)} directories in {directory_path}")

    for subject in subject_directories:
        process_subject(subject, directory_path)
    
    print("Done!")
