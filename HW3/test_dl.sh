#!/bin/bash

echo "testing  Unsync"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Unsync - threads:${nthreads} swaps:${num_swaps} array_size:6" >> "unsync_results.txt"
    java UnsafeMemory Unsynchronized "$nthreads" "$num_swaps" 6 5 6 3 0 3 >> "unsync_results.txt" 
  done
done

echo "testing  Unsync"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Unsync - threads:${nthreads} swaps:${num_swaps} array_size:16" >> "unsync_results.txt"
    java UnsafeMemory Unsynchronized "$nthreads" "$num_swaps" 16 5 6 3 0 3 4 3 7 2 6 1 9 5 8 3 >> "unsync_results.txt" 
  done
done