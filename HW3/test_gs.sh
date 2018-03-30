#!/bin/bash

echo "testing  GNS"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "GNS - threads:${nthreads} swaps:${num_swaps} array_size:6" >> "gns_results.txt"
    java UnsafeMemory GetNSet "$nthreads" "$num_swaps" 6 5 6 3 0 3 >> "gns_results.txt" 
  done
done

echo "testing  GNS"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "GNS - threads:${nthreads} swaps:${num_swaps} array_size:16" >> "gns_results.txt"
    java UnsafeMemory GetNSet "$nthreads" "$num_swaps" 16 5 6 3 0 3 4 3 7 2 6 1 9 5 8 3 >> "gns_results.txt" 
  done
done