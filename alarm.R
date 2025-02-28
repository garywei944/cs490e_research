# # Install packages
# install.packages(c("bnlearn", "bnviewer"))
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install()
# BiocManager::install(c("graph", "Rgraphviz"))
# install.packages("ggplot2")

# Load packages
library("bnlearn")
library("bnviewer")
library("Rgraphviz")
library("ggplot2")

setwd('~/Projects/cics490e_research')
# setwd('E:/Projects/cics490e_research')

# Compute f1 score given tp, fp, fn
f1 <- function(m) {
  tp <- m$tp
  fp <- m$fp
  fn <- m$fn

  return(tp / (tp + (fp + fn) / 2))
}

# Load Dataset
data('alarm')
head(alarm)

# Ground truth network
modelstring <- paste0("[HIST|LVF][CVP|LVV][PCWP|LVV][HYP][LVV|HYP:LVF][LVF]",
                      "[STKV|HYP:LVF][ERLO][HRBP|ERLO:HR][HREK|ERCA:HR][ERCA][HRSA|ERCA:HR][ANES]",
                      "[APL][TPR|APL][ECO2|ACO2:VLNG][KINK][MINV|INT:VLNG][FIO2][PVS|FIO2:VALV]",
                      "[SAO2|PVS:SHNT][PAP|PMB][PMB][SHNT|INT:PMB][INT][PRSS|INT:KINK:VTUB][DISC]",
                      "[MVS][VMCH|MVS][VTUB|DISC:VMCH][VLNG|INT:KINK:VTUB][VALV|INT:VLNG]",
                      "[ACO2|VALV][CCHL|ACO2:ANES:SAO2:TPR][HR|CCHL][CO|HR:STKV][BP|CO:TPR]")
dag_true <- model2network(modelstring)
graphviz.plot(dag_true)


# Given 1 incorrect edge to blacklist
n <- dim(dag_true$arcs)[1]
arcs <- dag_true$arcs
df_b1 <- data.frame(edge=character(), f1=numeric())

for (i in 1:n) {
  e <- arcs[i,]
  net <- hc(alarm, blacklist = e)

  df_b1[i,] <- c(paste(e, collapse = ' -> '), f1(compare(dag_true, net)))
}
df_b1$f1 = as.numeric(df_b1$f1)

gt_f1 = f1(compare(dag_true, hc(alarm)))

ggplot(df_b1, aes(x=edge, y=f1, group=1)) +
  scale_x_discrete(limits=df_b1$edge) +
  scale_y_continuous(breaks = sort(c(seq(min(df_b1$f1), max(df_b1$f1), length.out=5), gt_f1))) +
  geom_point() +
  geom_hline(aes(yintercept=gt_f1, color='red')) +
  geom_text(aes(5,gt_f1,label = 'Without given prior knowledge', vjust = -0.5, color='red')) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title = "F1 score given 1 incorrect blacklist edge",
       x='Edge added to the blacklist', y='F1 Score') +
  theme(legend.position = "none")
ggsave(
  'blacklist_1_f1.png',
  device = 'png',
  path = 'figures',
  width = 32,
  height = 18,
  units = 'cm'
)

# Given n random incorrect edge to blacklist
df_bn <- data.frame(f1=numeric())

for (i in 1:n) {
  e <- arcs[sample(1:n, i),]
  net <- hc(alarm, blacklist = e)

  df_bn[i,] <- f1(compare(dag_true, net))
}

ggplot(df_bn, aes(x=(1:n), y=f1)) +
  scale_y_continuous(breaks = sort(c(seq(min(df_bn$f1), max(df_bn$f1), length.out=5), gt_f1))) +
  geom_point() +
  geom_hline(aes(yintercept=gt_f1, color='red')) +
  geom_text(aes(5,gt_f1,label = 'Without given prior knowledge', vjust = -0.5, color='red')) +
  labs(title = "F1 score given n random incorrect blacklist edge",
       x='Number of edges added to the blacklist', y='F1 Score') +
  theme(legend.position = "none")
ggsave(
  'blacklist_n_f1.png',
  device = 'png',
  path = 'figures',
  width = 32,
  height = 18,
  units = 'cm'
)


# Given 1 correct edge to the white list
df_cw1 <- data.frame(edge=character(), f1=numeric())

for (i in 1:n) {
  e <- arcs[i,]
  net <- hc(alarm, whitelist = e)

  df_cw1[i,] <- c(paste(e, collapse = ' -> '), f1(compare(dag_true, net)))
}
df_cw1$f1 = as.numeric(df_cw1$f1)

ggplot(df_cw1, aes(x=edge, y=f1, group=1)) +
  scale_x_discrete(limits=df_cw1$edge) +
  scale_y_continuous(breaks = sort(c(seq(min(df_cw1$f1), max(df_cw1$f1), length.out=5), gt_f1))) +
  geom_point() +
  geom_hline(aes(yintercept=gt_f1, color='red')) +
  geom_text(aes(5,gt_f1,label = 'Without given prior knowledge', vjust = -0.5, color='red')) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title = "F1 score given 1 correct whitelist edge",
       x='Edge added to the whitelist', y='F1 Score') +
  theme(legend.position = "none")
ggsave(
  'whitelist_c1_f1.png',
  device = 'png',
  path = 'figures',
  width = 32,
  height = 18,
  units = 'cm'
)


# Given n random correct edge to the white list
df_cwn <- data.frame(f1=numeric())

for (i in 1:n) {
  e <- arcs[sample(1:n, i),]
  net <- hc(alarm, whitelist = e)

  df_cwn[i,] <- f1(compare(dag_true, net))
}

ggplot(df_cwn, aes(x=(1:n), y=f1)) +
  scale_y_continuous(breaks = sort(c(seq(min(df_cwn$f1), max(df_cwn$f1), length.out=5), gt_f1))) +
  geom_point() +
  geom_hline(aes(yintercept=gt_f1, color='red')) +
  geom_text(aes(5,gt_f1,label = 'Without given prior knowledge', vjust = -0.5, color='red')) +
  labs(title = "F1 score given n random correct whitelist edge",
       x='Number of edges added to the whitelist', y='F1 Score') +
  theme(legend.position = "none")
ggsave(
  'whitelist_cn_f1.png',
  device = 'png',
  path = 'figures',
  width = 32,
  height = 18,
  units = 'cm'
)


# Given 20 random incorrect edge to the blacklist and learn the network from different size of data
df_size_b20 <- data.frame(size=numeric(), f1=numeric())

e <- arcs[sample(1:n, 20),]
for (i in c(100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000)) {
  sim <- rbn(dag_true, i, alarm, replace.unidentifiable = TRUE)

  net <- hc(sim, blacklist = e)

  df_size_b20[dim(df_size_b20)[1]+1,] <- c(i, f1(compare(dag_true, net)))
}
df_size_b20$size = as.numeric(df_size_b20$size)
df_size_b20$f1 = as.numeric(df_size_b20$f1)

ggplot(df_size_b20, aes(x=size, y=f1)) +
  scale_x_continuous(trans='log10') +
  scale_y_continuous(breaks = sort(c(seq(min(df_size_b20$f1), max(df_size_b20$f1), length.out=5), gt_f1))) +
  geom_point() +
  geom_hline(aes(yintercept=gt_f1, color='red')) +
  geom_text(aes(200,gt_f1,label = 'Without given prior knowledge', vjust = -0.5, color='red')) +
  labs(title = "F1 score given 20 random incorrect blacklist edge and learn the network from different size of data",
       x='Size of data the network learned from (log_10)', y='F1 Score') +
  theme(legend.position = "none")
ggsave(
  'blacklist_size_20_f1.png',
  device = 'png',
  path = 'figures',
  width = 32,
  height = 18,
  units = 'cm'
)



save.image('data.RData')
