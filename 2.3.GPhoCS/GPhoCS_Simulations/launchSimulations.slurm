#!/bin/bash
#SBATCH -n 1    # Number of cores requested
#SBATCH -N 1    # Ensure that all cores are on one machine
#SBATCH -t 60    # Runtime in minutes
#SBATCH -p shared # Partition to submit to
#SBATCH --mem=8000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o launchSims_%j.out # Standard out goes to this file
#SBATCH -e launchSims_%j.err # Standard err goes to this filehostname

# Assymetric
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 1 0.01
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 5 0.01
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 1 0.10
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 5 0.10
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 1 1.00
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 5 1.00
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 1 2.00
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 5 2.00
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 1 10.0
#bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Assymetric.sh 1 5 10.0
## Bidirectional
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 1 0.01
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 5 0.01
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 1 0.10
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 5 0.10
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 1 1.00
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 5 1.00
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 1 2.00
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 5 2.00
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 1 10.0
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gPhocsSimulations.Bidirectional.sh 1 5 10.0
