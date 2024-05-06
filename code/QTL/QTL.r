# Author: Oliver
# Date: 2024-05-06T13:54:37


# 加载所需R包
library(data.table)
library(optparse)


# 传递参数
option_list <- list(
  make_option(c("-p", "--pvalue"),
    type = "numeric",
    default = NULL,
    help = "提供阈值"
  ),
  make_option(c("-r", "--read"),
    type = "character",
    default = NULL,
    help = "GAPIT结果文件"
  )
)
opt_parse <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parse)
p_line <- opt$pvalue
read_file <- opt$read

# 不知道说啥，就这吧

result <- as.data.frame(fread(read_file, header = TRUE))

t_n <- gsub("\\.+", "_", read_file)

trait_name <- unlist(strsplit(t_n, split = "_"))[6]

pure_result <- result[, c(1:4)]

pure_row_index <- which(pure_result[, 2] %in% c(1:12))

pure_result <- pure_result[pure_row_index, ]

p_value <- matrix(NA, nrow = nrow(pure_result), ncol = 1)

colnames(p_value) <- c("p_value")

final_result <- c()

for (i in seq_len(nrow(p_value))) {
  p_value[i, 1] <- -log10(pure_result[i, 4])
}

mo3_index <- which(p_value[, 1] >= p_line)

p_value_m3 <- p_value[mo3_index, ]

result_m3 <- pure_result[mo3_index, ]

chr <- as.data.frame(table(result_m3[, 2]))

for (i in seq_len(nrow(chr))) {
  judge <- matrix(NA, nrow = chr[i, 2])
  se_rem3_index <- which(result_m3[, 2] == chr[i, 1])
  se_rem3 <- result_m3[se_rem3_index, ]
  or <- order(se_rem3[, 3])
  se_rem3_or <- se_rem3[or, ]
  if (nrow(judge) > 1) {
    for (j in 1:(nrow(judge) - 1)) {
      if (se_rem3_or[j + 1, 3] - se_rem3_or[j, 3] <= 170000) {
        judge[j, 1] <- "1"
      } else {
        judge[j, 1] <- "0"
      }
    }
  }
  judge[nrow(judge), 1] <- "0"
  rle_judge <- rle(judge[, 1])
  if (length(which(rle_judge$values == 1)) != 0) {
    blocks_1 <- which(rle_judge$values == 1)
    for (m in seq_along(blocks_1)) {
      block_index <- blocks_1[m]
      if (block_index != 1) {
        block_start <- sum(rle_judge$lengths[1:(block_index - 1)]) + 1
      } else {
        block_start <- 1
      }
      block_end <- block_start + rle_judge$lengths[block_index] - 1
      judge[block_start:block_end, 1] <- m
    }
    judge_without_0 <- judge[which(judge[, 1] != 0), 1]
    se_rem3_or_nozero <- se_rem3_or[which(judge[, 1] != 0), ]
    new_re <- data.frame(se_rem3_or_nozero, judge_without_0)
    ori_table <- table(new_re[, 5])
    new_table <- as.data.frame(ori_table)
    new_new_table_index <- which(new_table[, 2] > 1)
    if (length(new_new_table_index) != 0) {
      new_new_table <- new_table[new_new_table_index, ]
      q_tl <- matrix(NA, ncol = 7, nrow = nrow(new_new_table))
      colnames(q_tl) <- c(
        "Name", "left", "right",
        "interval", "pos", "p_value", "chrom"
      )
      for (n in seq_len(nrow(q_tl))) {
        index_qtl <- which(new_re[, 5] == new_new_table[n, 1])
        new_re_q <- new_re[index_qtl, ]
        q_tl[n, 1] <- paste("qtl", trait_name, chr[i, 1], ".", n, sep = "")
        q_tl[n, 7] <- paste("chrome", chr[i, 1], sep = "_")
        q_tl[n, 2] <- new_re_q[1, 3]
        q_tl[n, 3] <- se_rem3_or[
          which(se_rem3_or[, 3] == new_re_q[nrow(new_re_q), 3]) + 1, 3
        ]
        q_tl[n, 4] <- as.numeric(q_tl[n, 3]) - as.numeric(q_tl[n, 2])
        p_max_index <- which.min(
          se_rem3_or[
            (
              which(
                as.numeric(
                  q_tl[n, 2]
                ) <= se_rem3_or[, 3] & se_rem3_or[, 3] <= as.numeric(q_tl[n, 3])
              )
            ), 4
          ]
        )
        q_tl[n, 6] <- -log10(
          se_rem3_or[(
            which(
              as.numeric(
                q_tl[n, 2]
              ) <= se_rem3_or[, 3] & se_rem3_or[, 3] <= as.numeric(q_tl[n, 3])
            )
          ), 4][p_max_index]
        )
        q_tl[n, 5] <- se_rem3_or[
          (
            which(
              as.numeric(
                q_tl[n, 2]
              ) <= se_rem3_or[, 3] & se_rem3_or[, 3] <= as.numeric(q_tl[n, 3])
            )
          ), 3
        ][p_max_index]
      }
      final_result <- rbind(final_result, q_tl)
    }
  }
}
chr <- matrix(NA, nrow = nrow(final_result), ncol = 1)
for (i in seq_len(nrow(chr))) {
  chr[i, 1] <- unlist(strsplit(final_result[i, 7], split = "_"))[2]
}
final_result[, 7] <- as.character(chr)
write.table(final_result,
  file = paste(trait_name, "_QTL.txt", sep = ""),
  row.names = FALSE, quote = FALSE
)
