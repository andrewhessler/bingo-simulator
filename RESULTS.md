# Sim History
Using `time`

## BingoCardV1 + BlackoutRunner
Running 100,000,000
69.17s, 68.9s, 68.98s

### BlackoutRunner Remove Switch [bbe32f12f2905f3c3ff7d5cd659906f95b19a284](https://github.com/andrewhessler/bingo-simulator/commit/bbe32f12f2905f3c3ff7d5cd659906f95b19a284)
Running 100,000,000
33.26s, 33.23s, 33.55s 

### Threading - 4 Threads w/o joining results
Running 25,000,000 * 4
51.73s, 52.47s, 51.96 

I apparently can't comprehend the passing of time... `time` 
All threads together took the time above, but actual time passed is: 14.013s, 13.797s, 13.962s
I'll mess with some different thread counts before playing with UI
