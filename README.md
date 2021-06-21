# binBedGraph
Script to take single bp bedGraph data and bin counts into specified bin sizes across genome. Note, because any bedgrah window overlapping the bins will be added to the sum, you should use unbinned data as your input bedgraph.

Usage:
To run the script, provide 4 inputs (space-separated, in order):
1. your bedGraph (single bp, unbinned)
2. output bedGraph name
3. bin size
4. chromosome sizes
```
binBedGraph.sh yoursample.bedGraph yoursample_100bp_bins.bedGraph 100 mm10.chrom.sizes
```


