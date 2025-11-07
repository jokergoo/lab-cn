---
title: GeneSummary
---



包含了NCBI RefSeq数据库中对基因功能的文字描述。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
Bioconductor | https://bioconductor.org/packages/GeneSummary/
GitHub | https://github.com/jokergoo/GeneSummary
文档 | https://jokergoo.github.io/GeneSummary/

</div>

### 例子


``` r
library(GeneSummary)
tb = loadGeneSummary(organism = 9606)
head(tb)
```

```
##   RefSeq_accession     Organism Taxon_ID Gene_ID      Review_status
## 1      NR_030309.1 Homo sapiens     9606  693168 PROVISIONAL REFSEQ
## 2   NM_001353788.2 Homo sapiens     9606     321    REVIEWED REFSEQ
## 3   NM_001004748.1 Homo sapiens     9606  401667 PROVISIONAL REFSEQ
## 4   NM_001370511.1 Homo sapiens     9606    5723    REVIEWED REFSEQ
## 5      NM_206891.3 Homo sapiens     9606   23181    REVIEWED REFSEQ
## 6      NM_130846.3 Homo sapiens     9606    5801    REVIEWED REFSEQ
##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Gene_summary
## 1 microRNAs (miRNAs) are short (20-24 nt) non-coding RNAs that are involved in post-transcriptional regulation of gene expression in multicellular organisms by affecting both the stability and translation of mRNAs. miRNAs are transcribed by RNA polymerase II as part of capped and polyadenylated primary transcripts (pri-miRNAs) that can be either protein-coding or non-coding. The primary transcript is cleaved by the Drosha ribonuclease III enzyme to produce an approximately 70-nt stem-loop precursor miRNA (pre-miRNA), which is further cleaved by the cytoplasmic Dicer ribonuclease to generate the mature miRNA and antisense miRNA star (miRNA*) products. The mature miRNA is incorporated into a RNA-induced silencing complex (RISC), which recognizes target mRNAs through imperfect base pairing with the miRNA and most commonly results in translational inhibition or destabilization of the target mRNA. The RefSeq represents the predicted microRNA stem-loop.
## 2                                                                                                                                                                                                                                                                                                                                                              The protein encoded by this gene is a member of the X11 protein family. It is a neuronal adapter protein that interacts with the Alzheimer's disease amyloid precursor protein (APP). It stabilizes APP and inhibits production of proteolytic APP fragments including the A beta peptide that is deposited in the brains of Alzheimer's disease patients. This gene product is believed to be involved in signal transduction processes. It is also regarded as a putative vesicular trafficking protein in the brain that can form a complex with the potential to couple synaptic vesicle exocytosis to neuronal cell adhesion.
## 3                                                                                                                                                                                                                                                                                                 Olfactory receptors interact with odorant molecules in the nose, to initiate a neuronal response that triggers the perception of a smell. The olfactory receptor proteins are members of a large family of G-protein-coupled receptors (GPCR) arising from single coding-exon genes. Olfactory receptors share a 7-transmembrane domain structure with many neurotransmitter and hormone receptors and are responsible for the recognition and G protein-mediated transduction of odorant signals. The olfactory receptor gene family is the largest in the genome. The nomenclature assigned to the olfactory receptor genes and proteins for this organism is independent of other organisms.
## 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            The protein encoded by this gene belongs to a subfamily of the phosphotransferases. This encoded enzyme is responsible for the third and last step in L-serine formation. It catalyzes magnesium-dependent hydrolysis of L-phosphoserine and is also involved in an exchange reaction between L-serine and L-phosphoserine. Deficiency of this protein is thought to be linked to Williams syndrome.
## 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    The protein encoded by this gene may be involved in axon patterning in the central nervous system. This gene is not highly expressed. Several transcript variants encoding different isoforms have been found for this gene.
## 6                                                                                                                                                                                                                             The protein encoded by this gene is a member of the protein tyrosine phosphatase (PTP) family. PTPs are known to be signaling molecules that regulate a variety of cellular processes including cell growth, differentiation, mitotic cycle, and oncogenic transformation. This PTP possesses an extracellular region, a single transmembrane region, and a single intracellular catalytic domain, and thus represents a receptor-type PTP. Silencing of this gene has been associated with colorectal cancer. Multiple transcript variants encoding different isoforms have been found for this gene. This gene shares a symbol (PTPRQ) with another gene, protein tyrosine phosphatase, receptor type, Q (GeneID 374462), which is also located on chromosome 12.
```


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>

