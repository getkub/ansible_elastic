### To get timestamp now in epoch
    ruby {
        code => "require 'date'; event.set('[ls][epoch_time]', event.get('@timestamp').to_i)"
    }

### Formatting time to "Mar 23 11:12:46"
    ruby {
        code => "require 'date'; b_epoch = event.get('@timestamp').to_i;  d = DateTime.strptime(b_epoch.to_s,'%s'); event.set('[b_time]', d.strftime('%b %d %T'))"
    }
