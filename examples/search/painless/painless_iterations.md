
```
// This code won't work out of box, but mostly is a concept
def buy_list = ' [{doc_count=13, category={buckets=[{doc_count=11, key=apple}, {doc_count=12, key=mango}, {doc_count=13, key=mango}, {doc_count=14, key=mango}]}, key=fruits} , {doc_count=34, category={buckets=[{doc_count=23, key=carrot}, {doc_count=41, key=beet}, {doc_count=21, key=potato}, {doc_count=21, key=pepper}]}, key=vegetables}]' ;

// Method to iterate 
List lh_list = new ArrayList();
for (Map l1: buy_list) {
  for (Map l2: l1.category.buckets) {
    lh_list.add(l2.key);
  }
}

// as a dictionary
Map lh_map = new HashMap();
for (Map l1: buy_list) {
    for (Map l2: l1.category.buckets) {
      lh_map.put(l1.key, l2.key);
    }
}

// Lambda version
// https://stackoverflow.com/a/51062494/1221358
Map items = new HashMap();
for (Map l1: buy_list) {
  items.computeIfAbsent(l1.key, k -> new ArrayList()).add(l1.category);
}
```
