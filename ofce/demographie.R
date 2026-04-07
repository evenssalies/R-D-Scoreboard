# Rapport tissu Productif 2025.
#   Création des tableaux
#     Evens Salies, 03/2025

# install.packages("readstata13") # Donnée au format Stata 13+
# install.packages("gt")        # gt() tables

# Dossier de travail
url0 <- "G:/.shortcut-targets-by-id/1HfSmUOZCFEUwi-aWTtOmVrEeyJrgRxlc/"
urlin <- paste0(url0,"RTP 2025/Indiv/Evens/")
urlout <- paste0(url0,"RTP 2025/Indiv/Evens/output/")

# Charge les données
library("readstata13")
setwd(urlin)
tableau <- read.dta13("demographie.dta")

# Recode tout au format utf8
colnames(tableau) <- utf8::as_utf8(colnames(tableau))
View(tableau)

# Manipulations du tableau avec gt()
library(gt)
tableau_gt <- gt(tableau) 

tableau_gt <- tableau_gt %>%
  # Suppression des couleurs de fond (marche chez moi, pas chez vous ?)
  opt_row_striping(row_striping = FALSE) %>%

  # Suppression des lignes
  tab_options(table_body.hlines.style = "none") %>%

  # Noms des secteurs en petit et gras
  tab_style(
    style = cell_text(size = "small", weight = "bold"),
    locations = cells_body(
      columns = c("francais"),
      rows = everything()
    )
  ) %>%

  # Taux en petit
  tab_style(
    style = cell_text(size = "small"),
    locations = cells_body(
      columns = c("TAUXENTREE", "TAUXSORTIE", "TURBULENCE", "N"),
      rows = everything()
    )
  ) %>%
  
  # BRICS
  tab_style(
    style = cell_text(color = "#609F43"),
    locations = cells_body(
      columns = c("francais"),
      rows = REGION == "BR"
    )
  ) %>%
  
  # CN
  tab_style(
    style = cell_text(color = "black"),
    locations = cells_body(
      columns = c("francais"),
      rows = REGION == "CN"
    )
  ) %>%

  # UE
  tab_style(
    style = cell_text(color = "#6CDAFF"),
    locations = cells_body(
      columns = c("francais"),
      rows = REGION == "EU"
    )
  ) %>%
  
  # DE
  tab_style(
    style = cell_text(color = "#FFD700"),
    locations = cells_body(
      columns = c("francais"),
      rows = francais == "Allemagne"
    )
  ) %>%

  # ES
  tab_style(
    style = cell_text(color = "#FF4500"),
    locations = cells_body(
      columns = c("francais"),
      rows = francais == "Espagne"
    )
  ) %>%
  
  # FR
  tab_style(
    style = cell_text(color = "#0000CD"),
    locations = cells_body(
      columns = c("francais"),
      rows = francais == "France"
    )
  ) %>%

  # IT
  tab_style(
    style = cell_text(color = "#008000"),
    locations = cells_body(
      columns = c("francais"),
      rows = francais == "Italie"
    )
  ) %>%

  # JP
  tab_style(
    style = cell_text(color = "#BC002D"),
    locations = cells_body(
      columns = c("francais"),
      rows = REGION == "JP"
    )
  ) %>%
  
  # ROW
  tab_style(
    style = cell_text(color = "grey"),
    locations = cells_body(
      columns = c("francais"),
      rows = REGION == "RO"
    )
  ) %>%

  # US
  tab_style(
    style = cell_text(color = "#9E003A"),
    locations = cells_body(
      columns = c("francais"),
      rows = REGION == "US"
    )
  ) %>%
  
  # drop variable REGION
  cols_hide(columns = "REGION") %>%

  # Centrer les colonnes et les valeurs
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_body(
      columns = c("francais", "TAUXENTREE", "TAUXSORTIE", "TURBULENCE"),
      rows = seq(1, nrow(tableau))
    )
  ) %>%
  
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_column_labels(
      columns = c("francais", "TAUXENTREE", "TAUXSORTIE", "TURBULENCE")
    )
  ) %>%
  
  # Notes de bas de tableau
  tab_source_note(
    source_note = "Source : European Commission (JRC). Calculs OFCE.") %>%

  tab_footnote(
    footnote = "La turbulence est définie comme la somme Taux d'entrée + Taux de sortie.",
    locations = cells_column_labels(columns = "TURBULENCE")
  ) %>%
 
  tab_footnote(
    footnote = "Nombre d'entreprises distinctes.",
    locations = cells_column_labels(columns = "N")
  ) %>%
  
  # Formatage des colonnes : multiplie par 100 et arrondi à 1 décimale
  #   pour les taux d'entrée et de sortie et la turbulence 
  fmt_number(
    columns = c("TAUXENTREE", "TAUXSORTIE", "TURBULENCE"),
    decimals = 1,
    scale_by = 100
  ) %>%
  
  # Renommer les colonnes
  cols_label(
    francais = "Pays",
    TAUXENTREE = "Taux d'entrée",
    TAUXSORTIE = "Taux de sortie",
    TURBULENCE = "Turbulence",
    N = "N"
  ) %>%

  # Hauteur des cellules
  tab_options(
    data_row.padding = px(1)
  )

tableau_gt

# install.packages("webshot2")
# Pointe CHROMOTE_CHROME vers msedge.exe dans l'environnement Sys.setenv()
# Sauvegarde au format .png
setwd(urlout)
Sys.setenv(CHROMOTE_CHROME = "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe")
library(webshot2)
gtsave(tableau_gt, filename = "demographie.png")
