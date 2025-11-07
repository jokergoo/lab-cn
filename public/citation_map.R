ln = readLines(url("https://www.webofscience.com/wos-researcher/dashboard/citation-map/?task_id=3f821588-d975-4f6a-ad3e-26a27953e99b"))
ln[1] = paste0("citation=", ln[1])

tmp = tempfile()
writeLines(ln, con = tmp)

library(V8)
ct = v8()
ct$source(tmp)

file.remove(tmp)

citation = ct$get("citation")

attr(citation, "date") = Sys.Date()

saveRDS(citation, file = "wos_citations.rds")

results = citation$results[, 1:4]
tb = data.frame(address = tapply(results$address, results$address, function(x) x[1]),
                publicationCount = tapply(results$publicationCount, results$address, sum),
                lat = tapply(results$lat, results$address, mean),
                lon = tapply(results$lon, results$address, mean))

library("sf")
library("rnaturalearth")
library("rnaturalearthdata")
world = ne_countries(scale = "medium", returnclass = "sf")

library(ggplot2)
library(ggrepel)
library(RColorBrewer)

ggplot(data = world) + geom_sf(color = "grey", fill = NA) + 
    geom_point(data = tb[order(tb$publicationCount), ], 
        aes(x = lon, y = lat, color = publicationCount, size = publicationCount)) + 
    scale_colour_gradientn(colours = rev(brewer.pal(9, "Spectral"))) +
    scale_size(range = c(0.2, 3)) +
    geom_text_repel(data = tb[order(-tb$publicationCount)[1:20], ], 
        mapping = aes(x = lon, y = lat, label = gsub(", .*$", "", address)), 
        box.padding = 0.5, max.overlaps = Inf, min.segment.length = 0, size = 3)