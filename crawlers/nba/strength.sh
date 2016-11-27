#mv strength-new.txt strength-old.txt
#egrep "\d+、" $1 | awk -F'、' '{print $2,$1}'  > strength-new.txt
echo "usage:cd strength/ && sh ../strength.sh"
for file in `ls $1`;
do
	echo $file
	dir=$(dirname "${file}")
	length=${#file}
	position=`expr $length-10`
	ds=${file:$position}
	echo "ds:"$ds
	gsed -ni 's/^[^1-9站节]*//; /^[0-9]\+、/p; /^节奏/p' $file
	gsed 'N;s/\n/ /' $file > ${file//temp/strength}
	gsed -i 's/[0-9]\+胜[0-9]\+负\+//g' ${file//temp/strength}
	gsed -i 's/[、：:;；\t ()（）,，+节奏进攻防守净胜分]\+/\t/g' ${file//temp/strength}
	#gsed -i 's/.*负//' $file
	#gsed -i 's/克利夫兰/克里夫兰/g' $file
	#egrep '^\d+[、:.]|净胜分[:： ;；]|净胜：' $file | awk '{if(NR%2==0) {print $0} else {printf $0 "\t"}}' > ${file//temp/strength}
	gsed -i 's/\s*$/\t'$ds'/' ${file//temp/strength}
	#gsed -i '1i range\tteam\tjiezhou\tjz_range\tjingong\tjg_range\tfangshou\tfs_range\twinscore\tws_range' ${file//temp/strength}
	echo $file.done
done

cat $dir/strength* > $dir/../strength.txt
gsed -i '1i range\tteam\tjiezhou\tjz_range\tjingong\tjg_range\tfangshou\tfs_range\twinscore\tws_range\tds' $dir/../strength.txt
