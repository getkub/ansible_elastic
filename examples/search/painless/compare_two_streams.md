```
def leftHand_array = [];
def rightHand_array = [];
leftHand_array = params.leftHand.myObject.buckets.stream()
    .map(t-> {return [t.key]})
    .collect(Collectors.toList());
rightHand_array = params.rightHand.myObject.buckets.stream()
    .map(t-> {return [t.key]})
    .collect(Collectors.toList());

def hosts_missing = [];
hosts_missing = leftHand_array.stream()
.filter(aObject -> ! rightHand_array.contains(aObject))
.collect(Collectors.toList());

def doc_size = hosts_missing.size();
return ['tdoc': hosts_missing, 'tdoc_size': doc_size]
```
