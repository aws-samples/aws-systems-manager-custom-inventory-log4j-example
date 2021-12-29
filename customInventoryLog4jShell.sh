if [ "$(curl -sL -w '%{http_code}' 169.254.169.254/latest/meta-data/instance-id -o /dev/null)" = "200" ]; then
    instanceId=$(curl 169.254.169.254/latest/meta-data/instance-id)
    inventoryPath=(/var/lib/amazon/ssm/$instanceId/inventory/custom)
else
    hybridDirectory=$(find /var/lib/amazon/ssm -name "mi-*")
    inventoryPath=($hybridDirectory/inventory/custom)
fi

printf '{"SchemaVersion":"1.0","TypeName":"Custom:Log4J","Content":[' > $inventoryPath/CustomLog4J.json
for jarPath in $(grep -r --include *.[wj]ar "JndiLookup.class" / 2>&1 | grep matches | sed -e 's/Binary file //' -e 's/ matches//'); do
  printf '%s' $SPLITTER >> $inventoryPath/CustomLog4J.json
  SPLITTER=","
  printf '{"Filename":"%s","Path":"%s"}' $(basename $jarPath) $jarPath >> $inventoryPath/CustomLog4J.json  
done
printf ']}\n' >> $inventoryPath/CustomLog4J.json
