library(geneHapR)

#导入所需文件

gff <- import_bed("/Volumes/JNJ/学习中的临时文件/hapanlysis/12859_2023_5318_MOESM3_ESM.bed6") #导入注释文件，这里是bed格式

pheno <- import_AccINFO("/Volumes/JNJ/学习中的临时文件/hapanlysis/Phe.txt") #导入表型信息

AccINFO <- import_AccINFO("/Volumes/JNJ/学习中的临时文件/hapanlysis/Acc.csv",sep = ",",na.strings = 'NA')#导入其他样本信息

tbl <- read.csv("/Volumes/JNJ/学习中的临时文件/hapanlysis/12859_2023_5318_MOESM2_ESM.geno")

geneID <- 'OsGHD7'

Chr <- 'Chr7'

start <- 9152403
end <- 9155185
hapPrefix <- "H" #单倍型名称前缀

hapResult <- table2hap(tbl,hapPrefix = hapPrefix,
			hetero_remove = TRUE, #移除包含杂合位点的样本
			na_drop = TRUE) #移除包含缺失基因型的样本
#对单倍型结果进行汇总整理
hapSummary <- hap_summary(hapResult,hapPrefix = hapPrefix)

#写出保存单倍型鉴定结果
write.hap(hapResult,file = "GeneID.hapResult")
write.hap(hapSummary,file = "GeneID.hapSummary")

#导入之前的单倍型分析结果
hapResult <- import_hap(file = "/Volumes/JNJ/学习中的临时文件/hapanlysis/GeneID.hapResult")
hapSummary <- import_hap(file = "/Volumes/JNJ/学习中的临时文件/hapanlysis/GeneID.hapSummary")

#单倍型结果展示
plotHapTable(hapSummary,
	     hapPrefix = hapPrefix,#单倍型名称前缀
	     angle = 45, #物理位置文字信息的展示角度
	     displayIndelSize = 0,#图中展示最大的Indel大小
	     title = geneID)

#在基因模式图上展示变异位点信息
displayVarOnGeneModel(gff = gff,hapSummary = hapSummary,
		      startPOS = start - 10,
 		      endPOS = end + 10,
		      CDS_h = 0.05,fiveUTR_h = 0.25,threeUTR_h = 0.25,#默认
		      cex = 0.8)

#单倍型网络分析
hapSummary[hapSummary == "DEL"] = 'N'
hapnet <- get_hapNet(hapSummary,
		     AccINFO = AccINFO,#包含样本分类信息的数据框
    		     groupName = 'Subpopulation',#包含有样本分类信息的列的名称
		     na.label = "Unknown") #未知分类样本的类别

plotHapNet(hapnet,
 	   scale = "log2",#标准化方法"log10"或"log2"或"none"
	   show.mutation = 2,#是否展示变异位点数量,0,1,2,3
	   col.link = 2,link.width = 2,#单倍型之间连线的颜色和宽度
	   main = geneID,#主标题
	   pie.lim = c(0.5,2),#圆圈的大小
	   legend_version = 1,#图例形式(0或1)
	   labels = TRUE,#是否在单倍型线上添加label
	   legend = c(12,0),#图例的坐标
	   cex.legend = 0.6)#图例中文字的大小
#单倍型的地理分布
AccINFO$Longitude <- as.numeric(AccINFO$Longitude)
AccINFO$Latitude <- as.numeric(AccINFO$Latitude)

hapDistribution(hapResult,
		AccINFO = AccINFO,
		hapNames = c("H001",
			     "H002",
			     "H003"),
		symbol.lim = c(3,6),#圆圈的大小
		LON.col = "Longitude",#经纬度所处的列名称
		LAT.col = "Latitude",#经纬度所处的列名称
		legend = "bottomleft",#图例所处的位置,
		cex.legend = 1,#图例大小
		lwd.pie = 0.2,#圆圈线条的粗细
		lwd = 1.5,#地图线条的粗细
		main = geneID)#主标题
#连锁不平衡分析
plot_LDheatmap(hap = hapResult,
	       add.map = TRUE,#是否添加基因模式图
	       gff = gff,#注释信息
	       Chr = Chr,
	       start = start,
	       end = end)
#表型关联分析
#单个表型
hapVsPheno(hap = hapResult,
	   pheno = pheno,
	   hapPrefix = hapPrefix,
	   title = geneID,
	   minAcc = 4,#参与p值计算所需最小的样本数
	   symnum.args = list(#定义显著性标注方式
			cutpoints = c(0,0.001,0.01,0.05,1),
			symbols = c("***","**","*","ns")),
	   mergeFigs = TRUE)#是否将结果的两张图融合成一张图

#多个表型的分析
hapVsPhenos(hap = hapResult,
	    pheno = pheno,
	    hapPrefix = hapPrefix,
	    title = geneID,
	    compression = "lzw",#tiff文件的压缩方式
	    res = 300,width = 12,height = 12,#图片大小的单位inch
	    outPutSingleFile = TRUE,#只有pdf格式支持输出单个文件
	    filename.surfix = "pdf",#文件格式:pdf,png,jpg,tiff,bmp
	    filename.prefix = geneID) #文件名称为：prefix + pheno_name + surfix
# 位点效应估算（结果仅供参考）
EFF <- siteEFF(hapResult, pheno)
plotEFF(EFF, gff = gff,
	Chr = Chr, start = start, end = end,
	showType = c("five_prime_UTR", "CDS", "three_prime_UTR"), # see help(plotEFF)
	y = "effect",                      # the means of y axis, one of effect or pvalue
	ylab = "effect",                  # label of y axis
	cex = 0.5,                         # Cex
	legend.cex = 0.8,                  # legend size
	main = geneID,                     # main title
	CDS.height = 1,                    # controls the height of CDS, heights of others will be half of that
	markMutants = TRUE,                # mark mutants by short lines
	mutants.col = 1, mutants.type = 1, # parameters for appearance of mutants
	pch = 20)                          # points type

#逐个位点进行比较分析
# 逐位点比较变异效应
hapVsPhenoPerSite(hap = hapResult,              # 单倍型分析结果
                  pheno = pheno,                # 表型文件
                  phenoName = names(pheno)[10], # 表型名称
                  freq.min = 5)                 # 参与显著性计算的最小样本数
# 回车继续下一位点
# ESC退出当前命令
