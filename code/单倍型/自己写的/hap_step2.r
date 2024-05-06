hap_with_phe <- read.table("hap_with_phe.txt",header = T)

filenames <- list.files(pattern = "hap.txt$")

for(f in 1:length(filenames)){
	hap_with_name <- read.table(filenames[f],header = T)
	
	new_hap_phe <- matrix(NA,ncol = 1,nrow = nrow(hap_with_phe))

	for(i in 1:nrow(new_hap_phe)){
		index <- which(hap_with_name[,1] == hap_with_phe[i,2])
		new_hap_phe[i,1] <- hap_with_name[index,4]
	}	
	
	name_phe <- unlist(strsplit(filenames[f],split = '_'))[1]

	index_name <- which(colnames(hap_with_phe) == name_phe)

	hap_with_phe2 <- data.frame(new_hap_phe,hap_with_phe[,index_name])

	colnames(hap_with_phe2) <- c("HAP",name_phe)

	t_test <- pairwise.t.test(hap_with_phe2[,2],hap_with_phe2[,1],p.adjust.method = p.adjust.methods)	

	p_value <- t_test$p.value

	write.table(p_value,file = paste0(name_phe,"_P_value.txt"),quote = F)	
	
}
