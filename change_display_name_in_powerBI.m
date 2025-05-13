let
    source_table = table_name,
    source_table_metadata = _mimir_metadata,
    #"Henter kolonne navn" = Table.ColumnNames(source_table),
    #"Konvertert til tabell" = Table.FromList(#"Henter kolonne navn", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Indeksert lagt til" = Table.AddIndexColumn(#"Konvertert til tabell", "Indeks", 1, 1, Int64.Type),
    #"Legger til tabellnavn" = Table.AddColumn(#"Indeksert lagt til", "Tabell", each "table_name"),
    #"Sammenslåtte spørringer" = Table.NestedJoin(#"Legger til tabellnavn", {"Column1", "Tabell"}, source_table_metadata, {"objekt", "tabell"}, "source_table_metadata", JoinKind.LeftOuter),
    #"Utvider metadata" = Table.ExpandTableColumn(#"Sammenslåtte spørringer", "source_table_metadata", {"visningsnavn"}, {"visningsnavn"}),
    #"Sorterte rader" = Table.Sort(#"Utvider metadata",{{"Indeks", Order.Ascending}}),
    #"Henter visningsnavn" = #"Sorterte rader"[visningsnavn],
    Oversetter = Table.RenameColumns(source_table, List.Zip( { Table.ColumnNames(source_table), #"Henter visningsnavn" }))
in
    Oversetter
