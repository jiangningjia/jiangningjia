# Author: Oliver
# Data : 2024-01-09

# 导入所需库，若没有，利用pip3或conda下载


from bs4 import BeautifulSoup
from urllib.request import urlopen
from urllib.parse import urljoin, urlparse
import argparse


# 传递参数


parser = argparse.ArgumentParser(description="从国家水稻数据中心爬取特定类型基因")
parser.add_argument("-t", "--to", help="TO号", required=True)
parser.add_argument("-w", "--write", help="输出文件", required=True)
args = parser.parse_args()
to_parameter = args.to
write_parameter = args.write


# 定义所需查找的tr特征


def is_target_row(tag):
    return tag.name == 'tr' and len(tag.find_all('td')) == 2 \
        or len(tag.find_all('td')) == 3


# 定义结果变量
gene_html = []
gene_symble_fuction = []
gene_LOC = []
# 开始爬取
for i in range(1, 9, 1):  # 左闭右开，根据页码数来定义，如：若6页，range(1,7,1)
    url = "https://ricedata.cn/ontology/ontolists.aspx?p={}&db=gene&ta=TO:{}" \
        .format(i, to_parameter)  # 目标网页
    htmlopen = urlopen(url)  # 获取网页
    soup = BeautifulSoup(htmlopen, 'html.parser')  # 解析网页
    target_rows = soup.find_all(is_target_row)  # 获取目标tr
    for row in target_rows:
        gene_symble = row.find_all('td')[0].string  # 基因符号
        gene_function = row.find_all('td')[1].string  # 基因功能描述
        html_father = row.find_all('td')[0]
        html_self = html_father.find('a')
        gene_html.append("https://ricedata.cn/" +
                         html_self['href'])  # 获取内置跳转网址
        gene_symble_fuction.append(
            gene_symble + ": " + gene_function)  # 先合并symble和function

# 对内置跳转网址进行MSU ID爬取
for data in gene_html:
    ori_url = data
    url = urljoin(ori_url, urlparse(ori_url).path)
    htmlopen = urlopen(url)
    soup = BeautifulSoup(htmlopen, 'html.parser')
    # "±¾µØ"是汉语的“本地”,打开网页检查器，可以发现LOC号在“本地”string旁边
    local_link = soup.find_all('a', string="本地")
    if local_link:
        ori_string = local_link[0]['href']
        LOC = ori_string.split('=')[-1]
        gene_LOC.append(LOC)
    else:
        gene_LOC.append("None")

# 写出并保存结果文件
with open(write_parameter, 'w') as file:
    for i in range(0, len(gene_LOC), 1):
        file.write(gene_symble_fuction[i] + ": " + gene_LOC[i] + "\n")
