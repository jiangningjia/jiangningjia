#!/bin/bash

while getopts ":r:" opt; do
	case ${opt} in
	r)
		input=$OPTARG
		echo "基因信息文件是：$OPTARG"
		;;
	\?)
		echo "无效选项：-$OPTARG" 1>&2
		;;
	:)
		echo "选项 -$OPTARG 需要参数" 1>&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

script_path="$PWD"
hap_step1="hap_step1.r"
hap_step2="hap_step2.r"
phe="phe.txt"

if [ ! -f "$script_path/$hap_step1" ] || [ ! -f "$script_path/$hap_step2" ] || [ ! -f "$script_path/$phe" ]; then
	echo "当前文件夹下必需同时包含 $hap_step1, $hap_step2, $phe 文件"
	exit 1
fi

echo "ID" > "$script_path/have_result_gene.txt"
echo "ID" > "$script_path/no_result_gene.txt"

output_path="$script_path/gene_hmp"

mkdir -p $output_path
while IFS= read -r line; do
	IFS=$'\t' read -r -a columns <<<"$line"
	Chr=${columns[0]}
	Start=${columns[1]}
	End=${columns[2]}
	Symble=${columns[3]}
	gene_path="$output_path/$Symble"
	mkdir -p $gene_path
	cp -r "$script_path/$hap_step1" "$script_path/$hap_step2" "$script_path/$phe" "$gene_path"
	sed -n '1,1p' 271_chr$Chr.hmp.txt >"$gene_path/${Symble}.hmp.txt"
	awk -v start="$Start" -v end="$End" '$4 >= start && $4 <= end{print}' 271_chr$Chr.hmp.txt >>"$gene_path/${Symble}.hmp.txt"
	echo "当前处理基因是：$Symble"
	cd $gene_path
	if [ $(wc -l <"${Symble}.hmp.txt") -ge 2 ]; then
		Rscript "$hap_step1"
		if [ -f "$gene_path/hap_with_phe.txt" ]; then
			Rscript "$hap_step2"
			rm -rf "$hap_step1" "$hap_step2" "$phe"
			echo "$Symble" >> "$script_path/have_result_gene.txt"
			cd $script_path
		else
			cd $script_path
			rm -rf $gene_path
			echo "$Symble" >> "$script_path/no_result_gene.txt"
		fi
	else
		cd $script_path
		rm -rf $gene_path
		echo "$Symble" >> "$script_path/no_result_gene.txt"
	fi
done <"$script_path/$input"
