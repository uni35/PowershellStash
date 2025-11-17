PowerShell & Batch Utilities

This repository is a collection of practical PowerShell and batch scripts for developers and IT professionals. These scripts help automate everyday tasks, perform system health checks, manipulate files, manage images, handle networking, and generate color palettes.

Available Scripts
Script	Description
sysHealthCheck.bat	Runs a comprehensive system and network health check, including CPU, RAM, disk usage, top processes, ping tests, DNS resolution, and TCP connections. Generates a JSON log and HTML dashboard.
Sockets.bat	TCP/UDP socket server-client utilities for testing networking, sending messages, and building basic network communication scripts.
URLimage.bat	Downloads images in bulk from URLs provided in a file. Saves them to a target folder.
convert .jpeg to .PNG.bat	Converts all .jpeg, .jpg, and .png images in a folder to .png format while preserving transparency.
paletteGenerator.bat	Generates color palettes from a single RGB input. Computes complementary, analogous colors, shades, and tints for design and development purposes.
pdfMerger.bat	Merges multiple PDF files in a folder into a single PDF. Supports automated batch processing.
Getting Started

Run any script by double-clicking the .bat file or executing it from the command line.

Note: Some scripts require PowerShell and may need administrative privileges.

Usage Examples

System Health Check:

sysHealthCheck.bat


Convert Images:

convert .jpeg to .PNG.bat


Generate a Color Palette:

paletteGenerator.bat


Merge PDFs:

pdfMerger.bat

Requirements

Windows OS

PowerShell 5.1+ for scripts that rely on PowerShell functionality.

Optional: Additional DLLs for advanced tasks (e.g., iTextSharp for PDF merging).

Contributing

Submit pull requests for improvements or new scripts.

Include clear documentation and examples for any new scripts.

Ensure scripts are modular, reusable, and well-commented.
