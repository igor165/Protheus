
Function ETplCOAdq(oTemplate)

oTemplate:cModulo     := "EIC"

oTemplate:cTitulo     := "Conta e Ordem - Perfil Adquirente"

oTemplate:cDescription:= "Template para adequacao do menu do sistema para importador que faca importacoes por Conta e Ordem de Terceiros. "+;
                         "Esse template nao pode ser utilizado juntamente com o template Conta e Ordem - Perfil Adquirente."

oTemplate:aUpdates    := {"UAVNFS_AD"}

oTemplate:aParTela    := {}

oTemplate:aParValues  := {{"MV_PCOIMPO",".F."},;
                          {"MV_PCOFOB",".F."},;
                          {"MV_EIC_PCO",".T."}}

oTemplate:cCondSucesso:= "" 

oTemplate:oMenu:TableData("MENU",{"SIGAEIC","EICCO100"   ,{"Atualizações","Desembaraco"}  ,               ,{"NF Transferencia"       ,"NF Transferencia"       ,"NF Transferencia"}       ,"1"  ,{"EIW, EIY, EIZ"}       ,"xxxxxxxxxx","0"     })


Return

Function ETplCOImp(oTemplate)

oTemplate:cModulo     := "EIC"

oTemplate:cTitulo     := "Conta e Ordem - Perfil Importador"

oTemplate:cDescription:= "Template para adequacao do menu do sistema para permitir adquirir mercadorias importadas por Conta e Ordem. "+;
                         "Esse template nao pode ser utilizado juntamente com o template Conta e Ordem - Perfil Importador."

oTemplate:aUpdates    := {"UAVNFS_IM"}

oTemplate:aParTela    := {"MV_PCOFOB"}

oTemplate:aParValues  := {{"MV_PCOIMPO",".T."},;
                          {"MV_EIC_PCO",".T."}}

oTemplate:cCondSucesso:= ""  

oTemplate:oMenu:TableData("MENU",{"SIGAEIC","EICCO100"   ,{"Atualizações","Desembaraco"}  ,               ,{"Pré-Nota/Geracao PV"    ,"Pré-Nota/Geracao PV"    ,"Pré-Nota/Geracao PV"}    ,"1"  ,{"EIW, EIY, EIZ"}       ,"xxxxxxxxxx","0"     })


Return