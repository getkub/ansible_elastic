## Playground for EQL playground
-  Link for [playground](https://eqlplayground.io/s/eqldemo/app/security/timelines/default?sourcerer=(default:(id:security-solution-eqldemo,selectedPatterns:!(eqldemo,%27logs-endpoint.*-eqldemo%27,%27logs-system.*-eqldemo%27,%27logs-windows.*-eqldemo%27,metricseqldemo)))&timerange=(global:(linkTo:!(),timerange:(from:%272022-05-29T22:00:00.000Z%27,fromStr:now%2Fd,kind:relative,to:%272022-05-30T21:59:59.999Z%27,toStr:now%2Fd)),timeline:(linkTo:!(),timerange:(from:%272022-04-17T22:00:00.000Z%27,kind:absolute,to:%272022-04-18T21:59:59.999Z%27)))&timeline=(activeTab:notes,graphEventId:%27%27,id:%277cb69fe1-c803-4392-ab7b-6e8a93378403%27,isOpen:!t,savedSearchId:%2729e6678b-390a-4320-8984-e45b9cc68326%27))
-  Elastic Endpoint Security(opens in a new tab or window) (all data types, malware detection enabled), via Elastic Agent(opens in a new tab or window)

Security, System and Application windows event logs (the standard windows server auditing policy is being used), shipped via Elastic Agent.

Sysmon(opens in a new tab or window) events using [Olaf Hartong's configuration](https://github.com/olafhartong/sysmon-modular/blob/master/sysmonconfig.xml), shipped via Elastic Agent

Powershell [Script Blocks]([opens in a new tab or window](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging_windows?view=powershell-7.1#enabling-script-block-logging)), shipped via Elastic Agent

At least once a day, this payload(opens in a new tab or window) is launched and executed as a user. An excel sheet containing malicious macros is launched from Outlook, simulating a successfully phished user. The macros run as described in the report. This provides an excellent starting point to allow you to craft queries to look for real adversarial behaviour. This is what the resulting process tree looks like:

