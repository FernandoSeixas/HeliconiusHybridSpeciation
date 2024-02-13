import argparse

# Define command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('input_bed', help='input .bed file')
parser.add_argument('output_bed', help='output .bed file')
parser.add_argument('--window_size', type=int, default=300, help='window size (default: 300)')
parser.add_argument('--window_step', type=int, default=2000, help='window step (default: 2000)')
args = parser.parse_args()

# Read in input .bed file
with open(args.input_bed, 'r') as infile:
    regions = []
    for line in infile:
        fields = line.strip().split('\t')
        chrom, start, end = fields[:3]
        regions.append((chrom, int(start), int(end)))



# Define function to generate windows
def generate_windows(regions, window_size, window_step):
    windows = []
    prev_chrom = None
    prev_window_end = None
    for region in regions:
        chrom, start, end = region
        num_windows = ((end - start) // window_step) + 1
        # same scaffold
        if prev_chrom == chrom:
            # within range of last locus
            if start < (prev_window_end + window_step):
                # Update the start position of the current window if possible
                if (end - (prev_window_end + window_step)) < window_size :
                    continue
                else:
                    start = prev_window_end + window_step
                    num_windows = ((end - start) // window_step) + 1
                    for i in range(num_windows):
                        window_start = start + (i * window_size) + (i * window_step)
                        window_end = window_start + window_size
                        if window_end <= end:
                            windows.append((chrom, window_start, window_end))
                            prev_chrom = chrom
                            prev_window_end = window_end
            # outside range of last locus
            if start >= (prev_window_end + window_step):
                num_windows = ((end - start) // window_step) + 1
                for i in range(num_windows):
                    window_start = start + (i * window_size) + (i * window_step)
                    window_end = window_start + window_size
                    if window_end <= end:
                        windows.append((chrom, window_start, window_end))
                        prev_chrom = chrom
                        prev_window_end = window_end
        # different chromosomes
        else:
            num_windows = ((end - start) // window_step) + 1
            for i in range(num_windows):
                window_start = start + (i * window_size) + (i * window_step)
                window_end = window_start + window_size
                if window_end <= end:
                    windows.append((chrom, window_start, window_end))
                    prev_chrom = chrom
                    prev_window_end = window_end
    return windows


# Generate windows
windows = generate_windows(regions, args.window_size, args.window_step)

# Write windows to output .bed file
with open(args.output_bed, 'w') as outfile:
    for window in windows:
        chrom, start, end = window
        outfile.write('{}\t{}\t{}\n'.format(chrom, start, end))
