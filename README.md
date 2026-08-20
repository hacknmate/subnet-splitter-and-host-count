# subnet-splitter-and-host-count
A simple bash script to break down large subnets

# Overview
A while ago, during one of my pentests I stumble across the difficulty of relying on very short time to scan a large series of subnet segments. This common scenario occurs more often than realized; yet the problems persists: How can I scan all these hosts without burning useful testing and reporting hours? This script solves this problem.

The script breaks down large subnets (ie: /16s), into multiple files which can be later scanned to determine if they are alive or not; speeding up the testing and vulnerability scanning process.

A spare .txt file is included to add your subnets, so you need to modify it for your needs.

Enjoy!
