---
title: "研究"
---

<style>
.figure {
	padding-top: 30px;
	padding-bottom: 30px;
}
.figure p {
	padding-left:50px;
	padding-right:50px;
	font-style: italic;
	color: grey;
}
.figure p a {
	color: grey;
}
</style>

我们研究的核心是应用数据科学方法，从理论、应用和工具多角度跨学科对生物大数据进行解析。

## 组学与精准医学

基于公共数据库及合作项目数据，开展以下三方面的多组学研究：1. 寻找新的肿瘤分子标志物。我们开发了非监督机器学习的统计方法及软件工具（[Nucleic Acids Research 2021](https://doi.org/10.1093/nar/gkaa1146)，[Briefings in Bioinformatics 2022](https://doi.org/10.1093/bib/bbac048)），可发现肿瘤新亚型及分子标志物，具备更加显著的预后差异。2. 多组学多模态，单细胞和其他组学集成分析。3. 以大语言模型为核心，提升基因功能注释的准确性与通用性（<a href="https://doi.org/10.1186/s12864-024-10759-4">BMC Genomics 2025</a>，[Bioinformatics 2023](https://doi.org/10.1093/bioinformatics/btac745)，[Genomics, Proteomics and Bioinformatics 2023](https://doi.org/10.1016/j.gpb.2022.04.008)）。

<div class="figure">
<img src="image/omics_example.png" width="100%" />
<p>图例：MYT1基因附近不同肿瘤亚型的DNA甲基化与组蛋白修饰信号的分布（<a href="https://doi.org/10.1038/s41467-020-20225-w">Nature Communications 2020</a>）。</p>
</div>

## 生物软件和社区建设

生物软件在精准医学，人工智能和生物大数据分析中发挥着基础核心作用。我们开发的软件涵盖数据建模、可视化、注释、教学与开发者工具，在全球范围被科研机构和医药公司广泛使用，具有较强影响力（[BMC genomics 2024](https://doi.org/10.1186/s12864-024-10759-4)，[Bioinformatics 2023](https://doi.org/10.1093/bioinformatics/btac745)，[Genomics, Proteomics & Bioinformatics 2023](https://doi.org/10.1016/j.gpb.2022.04.008)，[iMeta 2022](https://doi.org/10.1002/imt2.43)，[Briefings in Bioinformatics 2022](https://doi.org/10.1093/bib/bbac048)，[Bioinformatics 2022a](https://doi.org/10.1093/bioinformatics/btab806)，[Bioinformatics 2022b](https://doi.org/10.1093/bioinformatics/btab778)，[Nucleic Acids Research 2021](https://doi.org/10.1093/nar/gkaa1146)，[BMC Genomics 2018](https://doi.org/10.1186/s12864-018-4625-x)，[Bioinformatics 2016a](https://doi.org/10.1093/bioinformatics/btw313)，[Bioinformatics 2016b](https://doi.org/10.1093/bioinformatics/btw161)，[BMC Bioinformatics 2016](https://doi.org/10.1186/s12859-016-1051-4)，[Bioinformatics 2014](https://doi.org/10.1093/bioinformatics/btu393)，[Bioinformatics 2013](https://doi.org/10.1093/bioinformatics/btt008)）。我们将持续面向国际开源社区发布软件，提升国产软件影响力，并推动大规模组学平台的集成与转化应用。

<div class="figure">
<img src="image/tools.png" width="100%" />
<p>图例：可视化软件示例图。其中展示了复杂热图、交互式热图、以及圈形、希尔伯特曲线和阿基米德螺线可视化布局。</p>
</div>

## 计算几何与应用

[空间填充曲线](https://en.wikipedia.org/wiki/Space-filling_curve)（Space-filling curve）作为一种维度映射工具，可以将一维序列折叠为二维或高维结构，同时保持数据点之间的局部邻近性。
本方向将以空间填充曲线为研究对象，围绕基础数学理论的建立、生物数据的应用和转化平台的开发，系统开展从原理探索到实际应用的完整研究工作（[arXiv 2024](https://doi.org/10.48550/arXiv.2412.16962)）。

<div class="figure">
<img src="image/sfcurve.png" width="100%" />
<p>图例：所有36种 level = 3 的2x2空间填充曲线的结构。</p>
</div>

## 软件生态系统

从开发者视角出发，针对软件生态系统中依赖复杂与传播脆弱等核心问题，原创提出的依赖重量（dependency heaviness）理论方法（[Bioinformatics 2022](https://doi.org/10.1093/bioinformatics/btac449)，[Journal of Systems and Software 2023](https://doi.org/10.1016/j.jss.2023.111610)）。本方向将进一步完善其理论体系，并拓展至多语言生态系统的实证研究与应用。依赖重量能够定量刻画单个父包对子包引入的独占性依赖负担，弥补了现有研究中宏观分析与实际开发实践之间的鸿沟，使依赖研究真正服务于开发者的依赖优化与风险评估。本方向将从应用实践与实证分析两方面展开。首先，开发通用的跨编程语言的依赖重量分析核心软件和在线可视化平台，为全球开发者社区提供直接可操作的依赖优化与生态健康度评估工具。其次，系统比较主流编程语言生态系统的依赖传播模式与演化规律，揭示生态复杂性的共性与差异。


<div class="figure">
<img src="image/pkgndep.png" width="100%" />
<p class="legend">图例：对单个软件包的依赖重量分析。</p>
</div>

## 科学计量学

我们构建了一种新的基于引用富集（citation enrichment）的科学影响力分析框架（[Journal of Informetrics 2025](https://doi.org/10.1016/j.joi.2025.101641)），以揭示全球科研体系中的结构性偏好与动态演化规律。从基础理论与应用实践两方面展开研究：首先，建立基于随机引用模型的引用富集度统计理论，以消除科学体量的规模效应并量化科学主体间的真实偏好；其次，基于文献数据库数据系统揭示科学影响力在不同科学主体层面的分布特征以及在时间维度上的演化规律；最后，开发开源引用富集分析软件与可视化平台，实现文献数据分析的自动化、全面化和可复现。

<div class="figure">
<img src="image/citation_analysis.png" width="100%" />
<p>图例：全球72个国家之间的科学影响力偏好性全景图。</p>
</div>
