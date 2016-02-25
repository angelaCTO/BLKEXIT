#!/bin/sh

file="disksum_command"
bteq_out="disksum_bteq"
res_out="disksum_out"

rm $bteq_out
rm $res_out

while :
do
	bteq < $file > $bteq_out
	cat $res_out
	sleep 10
done


