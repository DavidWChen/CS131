#!/bin/bash

echo "testing  Null"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Null - threads:${nthreads} swaps:${num_swaps} array_size:6" >> "null_results.txt"
    java UnsafeMemory Null "$nthreads" "$num_swaps" 6 5 6 3 0 3 >> "null_results.txt" 
  done
done

echo "testing  Null"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Null - threads:${nthreads} swaps:${num_swaps} array_size:16" >> "null_results.txt"
    java UnsafeMemory Null "$nthreads" "$num_swaps" 16 5 6 3 0 3 4 3 7 2 6 1 9 5 8 3 >> "null_results.txt" 
  done
done

echo "testing  Sync"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Sync - threads:${nthreads} swaps:${num_swaps} array_size:6" >> "sync_results.txt"
    java UnsafeMemory Synchronized "$nthreads" "$num_swaps" 6 5 6 3 0 3 >> "sync_results.txt" 
  done
done

echo "testing  Null"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Sync - threads:${nthreads} swaps:${num_swaps} array_size:16" >> "sync_results.txt"
    java UnsafeMemory Synchronized "$nthreads" "$num_swaps" 16 5 6 3 0 3 4 3 7 2 6 1 9 5 8 3 >> "sync_results.txt" 
  done
done

echo "testing  Better"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Better - threads:${nthreads} swaps:${num_swaps} array_size:6" >> "bett_results.txt"
    java UnsafeMemory BetterSafe "$nthreads" "$num_swaps" 6 5 6 3 0 3 >> "bett_results.txt" 
  done
done

echo "testing  Better"
for nthreads in 1 2 4 8 16 32
do
  echo "  with ${nthreads} thread(s)..."
  for num_swaps in 1000 100000 10000000
  do
    echo " with ${num_swaps} swaps"
    echo "Better - threads:${nthreads} swaps:${num_swaps} array_size:16" >> "bett_results.txt"
    java UnsafeMemory BetterSafe "$nthreads" "$num_swaps" 16 5 6 3 0 3 4 3 7 2 6 1 9 5 8 3 >> "bett_results.txt" 
  done
done