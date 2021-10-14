insert into @writeDatabaseSchema.@regimenTable_f
       (select *
        from @writeDatabaseSchema.@sampledRegimenTable);
