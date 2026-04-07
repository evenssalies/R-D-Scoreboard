# Rapport tissu Productif 2025.
#   Création des tableaux
#     Evens Salies, v1 04/2025

# install.packages("readstata13") # Donnée au format Stata 13+
# install.packages("gt")        # gt() tables

# Dossier de travail
url0 <- "G:/.shortcut-targets-by-id/1HfSmUOZCFEUwi-aWTtOmVrEeyJrgRxlc/"
url1 <- paste0(url0,"RTP 2025/Indiv/Evens/output/")
setwd(url1)

# Charge les données
library("readstata13")
tableau <- read.dta13("filetemp.dta")

# Recode tout au format utf8
colnames(tableau) <- utf8::as_utf8(colnames(tableau))

# Fill empty rows of column REGION with missing region strings
tableau[c(2:4),1] <- "BRICS"
tableau[c(6:14),1] <- "CN"
tableau[c(16:24),1] <- "JP"
tableau[c(26:34),1] <- "UE"
tableau[c(36:44),1] <- "US"
View(tableau)

# Write a program that permutes rows in the data frame tableau as follows: 
#   all rows with REGION == "UE" first, then
#   all rows with REGION == "US", then
#   all rows with REGION == "BRICS", then
#   all rows with REGION == "CN", then
#   all rows with REGION == "JP".
# Within each REGION group, the rows should remain sorted as they are.
# The final dataframe should be stored in a new variable called tableau_sorted.
tableau_sorted <- tableau[order(factor(tableau$REGION,
                                       levels = c("UE", "US", "BRICS", "CN", "JP"))),
                          ]
tableau <- tableau_sorted
View(tableau)

# Empty rows of column REGION with missing region strings
tableau[c(2:10),1] <- ""
tableau[c(12:20),1] <- ""
tableau[c(22:24),1] <- ""
tableau[c(26:34),1] <- ""
tableau[c(36:44),1] <- ""
View(tableau)

# Manipulations of tableau with gt()
library(gt)

tableau_gt <- gt(tableau)
tableau_gt

tableau_gt <- tableau_gt %>%
  #   Replace "NA" with "")  
  sub_missing(columns = everything(), missing_text="") %>%
  
  # Suppress background colors
  opt_row_striping(row_striping = FALSE) %>%

  # Suppress rows
  tab_options(table_body.hlines.style = "none") %>%

  # First entry of a region (its name actually) bolded
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_body(
      columns = "REGION",
      rows = c(1, 11, 21, 25, 35)
    )
  ) %>%
  
  # Small text size for sector's names
  tab_style(
    style = cell_text(size = "small"),
    locations = cells_body(
      columns = c("SECTOR2003", "SECTOR2023"),
      rows = everything()
    )
  ) %>%

  # TIC in blue
  tab_style(
    style = cell_text(color = "deepskyblue"),
    locations = cells_body(
      columns = "SECTOR2003",
      rows = c(5, 6, 8, 11, 15, 17, 18, 19, 27, 37, 39, 40, 41, 43, 44)
    )
  ) %>%
  
  tab_style(
    style = cell_text(color = "deepskyblue"),
    locations = cells_body(
      columns = "SECTOR2023",
      rows = c(7, 11, 12, 13, 14, 15, 25, 26, 30, 33, 37, 38, 43)
    )
  ) %>%

  # Lines (thin) between regions
  tab_style(
    style = cell_borders(
    sides = "bottom", color = "lightgrey", weight = px(1)
    ),
    locations = cells_body(
      rows = c(10, 20, 24, 34, 44)
    )
  ) %>%

  # Center sector's cells (text and column labels)
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_body(
      columns = c("SECTOR2003", "SECTOR2023"),
    rows = seq(1, nrow(tableau))
    )
  ) %>%
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_column_labels(
      columns = c("SECTOR2003", "SECTOR2023")
    )
  ) %>%

  # Center companies' names
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_body(
      columns = c("RAISON2003", "RAISON2023"),
      rows = seq(1, nrow(tableau))
    )
  ) %>%
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_column_labels(
      columns = c("RAISON2003", "RAISON2023")
    )
  ) %>%
  
  # Merge cells around years' names and bold them
  tab_spanner(
    label = md("**2003**"), 
    columns = c("SECTOR2003", "RAISON2003")
  ) %>%

  # Same for 2023
  tab_spanner(
    label = md("**2023**"), 
  columns = c("SECTOR2023", "RAISON2023")
  ) %>%

  # Notes de bas de tableau
  #tab_source_note(
  #  source_note = "Source : European Commission (JRC). Calculs OFCE.") %>%

  #tab_footnote(
  #  footnote = "Les secteurs NACE rév. 2 en bleu sont : 26 (Prod. info., électro. et optiques), 58 (Éd. de logiciels), 61 (Télécommunications), 62-63 (Progr., conseil info.; Serv. d'info.).",
  #  locations = cells_column_labels(columns = "SECTOR2003")
  #) %>%

  #tab_footnote(
  #  footnote = "Les nouveaux groupes de R&D en 2023 sont en vert.",
  #  locations = cells_column_labels(columns = "RAISON2023")
  #) %>%
  
  # New entrents green
  tab_style(
    style = cell_text(color = "green3"),
    locations = cells_body(
      columns = "RAISON2023",
      rows = c(5, 7, 9, 11, 12, 13, 20, 21, 24, 25, 26, 27, 28, 29, 30, 31, 32, 34, 39, 41, 43, 44)
    )
  ) %>%

  # Rename columns
  cols_label(
    REGION = "",
    SECTOR2003 = "Secteur",
    RAISON2003 = "Groupe",
    SECTOR2023 = "Secteur",
    RAISON2023 = "Groupe"
  ) %>%

  # Hauteur des cellules
  tab_options(
    data_row.padding = px(1)
  )

tableau_gt

install.packages("webshot2")

# Pointe CHROMOTE_CHROME vers msedge.exe dans l'environnement Sys.setenv()
# Sauvegarde au format .png
Sys.setenv(CHROMOTE_CHROME = "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe")
library(webshot2)
gtsave(tableau_gt, filename = "nouveauxgroupes_unepage.png")
