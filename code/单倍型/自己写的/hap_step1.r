# 读取基因型和表型文件
hmp_names <- list.files(pattern = "hmp.txt$")
hmp <- read.table(hmp_names[1], header = T, comment.char = "", check.names = FALSE)

phe <- read.table("phe.txt", header = T)

# 表型和基因型材料信息相一致

eleven <- hmp[, c(1:11)]

hmp_without11 <- hmp[, -c(1:11)]

index_gene <- which(colnames(hmp_without11) %in% phe[, 1])

index_phe <- which(phe[, 1] %in% colnames(hmp_without11))

phe <- phe[index_phe, ]

hmp <- hmp_without11[, index_gene]

hmp <- cbind(eleven, hmp)

# 去除前11列并转置

without_11_hmp <- hmp[, -c(1:11)]
rownames(without_11_hmp) <- hmp[, 1]

t_hmp <- t(without_11_hmp)

# 将杂合位点转换为NA并删除包含NA的行

for (hang in 1:nrow(t_hmp)) {
  for (lie in 1:ncol(t_hmp)) {
    if (t_hmp[hang, lie] %in% c("Y", "W", "S", "M", "K", "R", "N", "-")) {
      t_hmp[hang, lie] <- NA
    }
  }
}

# 删除包含缺失值的行

t_hmp <- as.data.frame(na.omit(t_hmp))

# 合并碱基

a <- matrix(NA, ncol = 2, nrow = nrow(t_hmp))
colnames(a) <- c("material", paste(colnames(t_hmp), collapse = "_"))
a[, 1] <- row.names(t_hmp)
for (i in 1:nrow(t_hmp)) {
  a[i, 2] <- paste0(t_hmp[i, ], sep = "", collapse = "")
}

# 升序

index_order <- as.numeric(order(a[, 2]))

b <- a[index_order, ]

# 添加判断筛选列

judge <- matrix(NA, ncol = 1, nrow = nrow(b))

for (i in 1:(nrow(judge) - 1)) {
  if (b[i + 1, 2] == b[i, 2]) {
    judge[i, 1] <- "1"
  } else {
    judge[i, 1] <- "0"
  }
}

judge[nrow(b), 1] <- "0"

# 提取单倍型

index_judge <- which(judge[, 1] == "0")

ori_HAP <- b[index_judge, 2]

# 计算各单倍型的数量并删除小于等于2的单倍型

num <- matrix(NA, ncol = 1, nrow = length(ori_HAP))

for (i in 1:nrow(num)) {
  num[i, 1] <- length(which(b[, 2] == ori_HAP[i]))
}

HAP_with_num <- cbind(ori_HAP, num)

colnames(HAP_with_num) <- c(colnames(b)[2], "num")


index_num_more_than2 <- which(as.numeric(HAP_with_num[, 2]) >= 5)
if (length(index_num_more_than2) >= 2) {
  final_HAP <- HAP_with_num[index_num_more_than2, ]

  # 添加表型均值
  # phe <- phe[,-5]
  phe_value <- matrix(NA, ncol = (ncol(phe) - 1), nrow = nrow(b))

  colnames(phe_value) <- colnames(phe[-1])

  for (i in 1:nrow(b)) {
    for (j in 1:ncol(phe_value)) {
      index_phe_v <- which(phe[, 1] == b[i, 1])[1]
      phe_value[i, j] <- phe[index_phe_v, j + 1]
    }
  }


  phe_value <- apply(phe_value, 2, as.numeric)

  b_with_phe <- data.frame(b, phe_value)

  b_with_phe <- na.omit(b_with_phe)



  # 计算b的HAP分组均值

  phe_mean <- matrix(NA, ncol = ncol(phe_value), nrow = nrow(final_HAP))

  colnames(phe_mean) <- colnames(phe_value)

  for (i in 1:nrow(phe_mean)) {
    for (j in 1:ncol(phe_mean)) {
      index_mean <- which(b_with_phe[, 2] == final_HAP[i, 1])
      phe_mean[i, j] <- mean(b_with_phe[index_mean, j + 2])
    }
  }

  final_HAP <- data.frame(final_HAP, phe_mean)


  # 写出无显著性的文件

  for (i in 1:(ncol(final_HAP) - 2)) {
    od <- order(final_HAP[, i + 2])
    rod <- rev(od)
    zhong_HAP <- final_HAP[rod, c(1, 2, i + 2)]
    HAP_name <- matrix(NA, ncol = 1, nrow = nrow(final_HAP))
    for (j in 1:nrow(HAP_name)) {
      HAP_name[j, 1] <- paste0("HAP", j, sep = "", collapse = "")
    }
    terminal <- data.frame(zhong_HAP, HAP_name)
    write.table(terminal, file = paste0(colnames(final_HAP)[i + 2], "_hap.txt", sep = "", collapse = ""), quote = F, row.names = F)
  }

  index_a <- which(b_with_phe[, 2] %in% final_HAP[, 1])

  b_with_phe <- b_with_phe[index_a, ]

  write.table(b_with_phe, file = "hap_with_phe.txt", quote = F, row.names = F)
}
