#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "GTPR814.CH"

Static oFont11   := TFont():New('Courier New',,-11,.T.,.F.)
Static oFont11N  := TFont():New('Courier New',,-11,.T.,.T.)
Static oFont09   := TFont():New('Courier New',,-09,.T.,.F.)
Static oFont09N  := TFont():New('Courier New',,-09,.T.,.T.)

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPR814
Relatório de Recebimento de Encomendas
@type Function
@author jacomo.fernandes
@since 11/12/2019
@version 1.0
@return , return_description
/*/
//------------------------------------------------------------------------------
Function GTPR814()
Local cPerg     := "GTPR814"
Local oReport   := NIL

If Pergunte(cPerg, .T.)
    oReport := ReportDef(cPerg)
    oReport:PrintDialog()
Endif

GtpDestroy(oReport)

Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} ReportDef
Função responsavel pela definição do Relatório
@type Static Function
@author jacomo.fernandes
@since 11/12/2019
@version 1.0
@param cPerg, character, (Descrição do parâmetro)
@return oReport, return_description
/*/
//------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local oReport       := nil
Local nLin          := 250
Local bPageBreak    := { || oReport:SkipLine(5),nLin := 250 }

oReport     := TReport():New("GTPR814",STR0004, cPerg ,{|oReport| ReportPrint(oReport,@nLin)}) //"Recebimento de Encomendas"
oReport:oPage:SetPaperSize(DMPAPER_A4)

oReport:OnPageBreak(bPageBreak)

oReport:SetLineHeight(60)

Return oReport


//------------------------------------------------------------------------------
/* /{Protheus.doc} ReportPrint
Função responsavel pela impressão do relatório
@type Static Function
@author jacomo.fernandes
@since 11/12/2019
@version 1.0
@param oReport, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ReportPrint(oReport,nLin)
Local cAliasMdF := ''
Local cAliasAge := ''
Local oTable    :=  GetDadosRPT()

cAliasMdF := GetDadosMDF(oTable)

While (cAliasMdF)->(!Eof())
    oReport:StartPage()

    SetDadosCab(oReport,cAliasMdF,@nLin)

    cAliasAge := GetDadosAge(oTable,(cAliasMdF)->GI9_CODIGO)
    While (cAliasAge)->(!Eof())
        SetDadosAge(oReport,cAliasAge,@nLin)
        
        SetDadosCte(oReport,oTable,cAliasAge,@nLin)
        
        (cAliasAge)->(DbSkip())
    End
    (cAliasAge)->(DbCloseArea())


    oReport:EndPage()

    (cAliasMdF)->(DbSkip())
End
oReport:Finish()
oReport:lNoPrint := .F.

(cAliasMdf)->(DbCloseArea())

oTable:Delete()
GtpDestroy(oTable)

Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDadosCab

@type Static Function
@author jacomo.fernandes
@since 12/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetDadosCab(oReport,cAliasMdF,nLin)

oReport:Say(nLin,0010       ,STR0005                    ,oFont11N) //"Cód. Manifesto:"
oReport:Say(nLin,0010+300   ,(cAliasMdF)->GI9_CODIGO    ,oFont11)

oReport:Say(nLin,0550       ,STR0006                    ,oFont11N)//"Série:"
oReport:Say(nLin,0550+120   ,(cAliasMdF)->GI9_SERIE     ,oFont11)

oReport:Say(nLin,0800       ,STR0007                    ,oFont11N)//"Nr. Documento:"
oReport:Say(nLin,0800+280   ,(cAliasMdF)->GI9_NUMERO    ,oFont11)

oReport:Say(nLin,1350       ,STR0030                    ,oFont11N)//"Status:"
oReport:Say(nLin,1350+150   ,(cAliasMdF)->GI9_STATUS    ,oFont11)

nLin += 60
oReport:SkipLine()

oReport:Say(nLin,0010       ,STR0008                    ,oFont11N)//"Agência Emissora:"
oReport:Say(nLin,0010+340   ,(cAliasMdF)->GI6_CODIGO+" - "+AllTrim((cAliasMdF)->GI6_CODIGO)       ,oFont11)


nLin += 60
oReport:SkipLine()

oReport:Say(nLin,0010       ,STR0009                    ,oFont11N)//"Veículo:"
oReport:Say(nLin,0010+160   ,(cAliasMdF)->T9_CODBEM     ,oFont11)


oReport:Say(nLin,0700       ,STR0010                    ,oFont11N)//"Placa:"
oReport:Say(nLin,0700+120   ,(cAliasMdF)->GI9_PLACA     ,oFont11)


oReport:Say(nLin,1175       ,STR0011                    ,oFont11N)//"Modelo:" 
oReport:Say(nLin,1175+140   ,(cAliasMdF)->T9_MODELO     ,oFont11)

nLin += 60
oReport:SkipLine()

oReport:Say(nLin,0010       ,STR0012                    ,oFont11N)//"Linha:"
oReport:Say(nLin,0010+120   ,(cAliasMdF)->GI2_COD       ,oFont11)


oReport:Say(nLin,0400       ,STR0013                    ,oFont11N)//"Número:"
oReport:Say(nLin,0400+140   ,(cAliasMdF)->GI2_NUMLIN    ,oFont11)


oReport:Say(nLin,1000       ,STR0014                    ,oFont11N)//"Serviço:"
oReport:Say(nLin,1000+160   ,(cAliasMdF)->GID_NUMSRV    ,oFont11)

nLin += 60
oReport:SkipLine()

oReport:Say(nLin,0010       ,STR0015                    ,oFont11N)//"Nome:"
oReport:Say(nLin,0010+100   ,AllTrim((cAliasMdF)->ORIGEM) + " x " + AllTrim((cAliasMdF)->DESTINO)      ,oFont11)

nLin += 60
oReport:SkipLine()

oReport:Line(nLin, 0005 , nLin , oReport:GetWidth()-5 )

nLin += 30
oReport:SkipLine()

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDadosAge

@type Static Function
@author jacomo.fernandes
@since 12/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetDadosAge(oReport,cAliasAge,nLin)
Local cNameFilial   := AllTrim(FWFilialName(cEmpAnt,(cAliasAge)->GI6_FILRES) )

oReport:Say(nLin,0030       ,STR0016                                                                             ,oFont11N)//"Filial:"
oReport:Say(nLin,0030+140   ,AllTrim((cAliasAge)->GI6_FILRES)+" - "+cNameFilial                                    ,oFont11)

nLin += 60
oReport:SkipLine()

oReport:Say(nLin,0030       ,STR0017                                                                 ,oFont11N)//"Agência Recebedora:"
oReport:Say(nLin,0030+380   ,AllTrim((cAliasAge)->GI6_CODIGO) + " - " + AllTrim((cAliasAge)->GI6_DESCRI)            ,oFont11)

nLin += 60
oReport:SkipLine()

oReport:Say(nLin,0030       ,STR0018                                                                           ,oFont11N)//"Município:"
oReport:Say(nLin,0030+200   , AllTrim((cAliasAge)->GI1_CDMUNI)+" - "+AllTrim((cAliasAge)->CC2_MUN)+" / "+AllTrim((cAliasAge)->GI1_UF)    ,oFont11)

nLin += 60
oReport:SkipLine()

oReport:Say(nLin,0030       ,STR0019                                                       ,oFont11N)//"Data/Hora Prevista de chegada:" 
oReport:Say(nLin,0030+600   ,DtoC((cAliasAge)->G55_DTCHEG) + STR0020 +GTFormatHour( (cAliasAge)->G55_HRFIM, "99:99") ,oFont11)//" às "

nLin += 60
oReport:SkipLine()

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDadosCte

@type Static Function
@author jacomo.fernandes
@since 12/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetDadosCte(oReport,oTable,cAliasAge,nLin)
Local cAliasCte := GetDadosCte(oTable,cAliasAge)


SetCabecCte(oReport,@nLin)

While (cAliasCte)->(!Eof())
    SetGridCte(oReport,cAliasCte,@nLin)

    (cAliasCte)->(DbSkip())
End
    
(cAliasCte)->(DbCloseArea())


nLin+=60
oReport:SkipLine()

oReport:Line(nLin, 0030 , nLin , oReport:GetWidth()-5 )

nLin+=30
oReport:SkipLine()

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} CriaBoxCte

@type Function
@author jacomo.fernandes
@since 12/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Function CriaBoxCte(oReport,nLin)
Local nCol1 := 0030
Local nCol2 := nCol1+200
Local nCol3 := nCol2+800
Local nCol4 := nCol3+110
Local nCol5 := nCol4+230
Local nCol6 := nCol5+200
Local nCol7 := nCol6+220
Local nCol8 := nCol7+220
Local nCol9 := nCol8+260

    If oReport:ChkIncRow(60,.f.)
        oReport:EndPage()
        oReport:StartPage()
    Endif

    oReport:Box(nLin, nCol1, nLin+60, nCol2)
    oReport:Box(nLin, nCol2, nLin+60, nCol3)
    oReport:Box(nLin, nCol3, nLin+60, nCol4)
    oReport:Box(nLin, nCol4, nLin+60, nCol5)
    oReport:Box(nLin, nCol5, nLin+60, nCol6)
    oReport:Box(nLin, nCol6, nLin+60, nCol7)
    oReport:Box(nLin, nCol7, nLin+60, nCol8)
    oReport:Box(nLin, nCol8, nLin+60, nCol9)
  

Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetCabecCte(oReport,cAliasTmp,@nLin)

@type Static Function
@author jacomo.fernandes
@since 12/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetCabecCte(oReport,nLin)
Local nCol1 := 0030
Local nCol2 := nCol1+200
Local nCol3 := nCol2+800
Local nCol4 := nCol3+110
Local nCol5 := nCol4+230
Local nCol6 := nCol5+200
Local nCol7 := nCol6+220
Local nCol8 := nCol7+220
    
    CriaBoxCte(oReport,@nLin)
    
    oReport:Say(nLin+10,nCol1+15 ,STR0021   ,oFont09N)//"CT-e"          
    oReport:Say(nLin+10,nCol2+15 ,STR0022   ,oFont09N)//"Produto"       
    oReport:Say(nLin+10,nCol3+15 ,STR0032   ,oFont09N)//"Série"         
    oReport:Say(nLin+10,nCol4+15 ,STR0033   ,oFont09N)//"Nr Documento"  
    oReport:Say(nLin+10,nCol5+15 ,STR0023   ,oFont09N)//"Tomador"       
    oReport:Say(nLin+10,nCol6+15 ,STR0024   ,oFont09N)//"Valor"         
    oReport:Say(nLin+10,nCol7+15 ,STR0025   ,oFont09N)//"Transbordo"    
    oReport:Say(nLin+10,nCol8+15 ,STR0031   ,oFont09N)//"Status" 
    nLin+=60

Return 



//------------------------------------------------------------------------------
/* /{Protheus.doc} SetGridCte(oReport,cAliasCte,@nLin)

@type Static Function
@author jacomo.fernandes
@since 12/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetGridCte(oReport,cAliasCte,nLin)
Local nCol1 := 0030
Local nCol2 := nCol1+200
Local nCol3 := nCol2+800
Local nCol4 := nCol3+110
Local nCol5 := nCol4+230
Local nCol6 := nCol5+200
Local nCol7 := nCol6+220
Local nCol8 := nCol7+220
    
    CriaBoxCte(oReport,@nLin)
    
    oReport:Say(nLin+15,nCol1+15 ,(cAliasCte)->G99_CODIGO                                           )//CTE
    oReport:Say(nLin+15,nCol2+15 ,AllTrim((cAliasCte)->B1_COD)+" - "+AllTrim((cAliasCte)->B1_DESC)  )//Produto
    oReport:Say(nLin+15,nCol3+15 ,(cAliasCte)->G99_SERIE                                            )//Serie
    oReport:Say(nLin+15,nCol4+15 ,(cAliasCte)->G99_NUMDOC                                           )//Numero
    oReport:Say(nLin+15,nCol5+15 ,(cAliasCte)->G99_TOMADO                                           )//Tomador
    oReport:Say(nLin+15,nCol6+15 ,Transform((cAliasCte)->G99_VALOR,"@R 999,999,999.99")             )//Valor
    oReport:Say(nLin+15,nCol7+15 ,(cAliasCte)->G9Q_STAENC                                           )//Transbordo
    oReport:Say(nLin+15,nCol8+15 ,(cAliasCte)->G99_STAENC                                           )//Transbordo


    nLin+=60
    oReport:SkipLine()

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDadosRPT

@type Static Function
@author jacomo.fernandes
@since 13/12/2019
@version 1.0
@return oTable, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetDadosRPT(aRet)
Local cAliasTmp := GetNextAlias()
Local cWhereGI9 := ""
Local cWhereG99 := ""

Local cAgenIni  := MV_PAR01
Local cAgenFim  := MV_PAR02
Local cLinhaIni := MV_PAR03
Local cLinhaFim := MV_PAR04
Local cVeicIni  := MV_PAR05
Local cVeicFim  := MV_PAR06
Local dDataIni  := MV_PAR07
Local dDataFim  := MV_PAR08
Local cStatMdf  := MV_PAR09
Local cStatCTE  := MV_PAR10

If cStatMdf <> 4 //Todos
    cWhereGI9 += " AND GI9.GI9_STATRA = '"+cValToChar(cStatMdf)+"' "
Endif

If cStatCTE <> 5 //Todos
    //Devido a descontinuidade do status 3 Transbordo, foi feito essa alteração
    If cStatCTE == 3 //Recebido
        cStatCTE := 4
    ElseIF cStatCTE == 4 //Retirado
        cStatCTE := 5
    Endif
    cWhereG99 += " AND G99.G99_STAENC = '"+cValToChar(cStatCTE)+"' "
Endif

cWhereGI9 := "% "+cWhereGI9+" %"
cWhereG99 := "% "+cWhereG99+" %"


BeginSql Alias cAliasTmp
    select 
        GI9.GI9_FILIAL,
        GI9.GI9_CODIGO,
        GI9.GI9_SERIE,
        GI9.GI9_NUMERO,
        GI9.GI9_CODEMI,
        GI9.GI9_VEICUL,
        GI9_PLACA,
        GI9.GI9_VIAGEM,
        GI9.GI9_STATUS,
        GYN.GYN_LINCOD,
        GYN.GYN_CODGID,
        G99.G99_CODIGO,
        G99.G99_CODREC,
        G99.G99_CODPRO,
        G99.G99_SERIE,
        G99.G99_NUMDOC,
        G99.G99_TOMADO,
        G99.G99_VALOR,
        G99_STAENC
    From %Table:GI9% GI9 
        INNER JOIN %Table:GYN% GYN ON
            GYN.GYN_FILIAL = %xFilial:GYN%
            AND GYN.GYN_CODIGO = GI9.GI9_VIAGEM
            AND GYN.GYN_LINCOD BETWEEN %Exp:cLinhaIni% AND %Exp:cLinhaFim%
            AND GYN.%NotDel%
        INNER JOIN %Table:GIF% GIF ON
            GIF.GIF_FILIAL = GI9.GI9_FILIAL
            AND GIF.GIF_CODIGO = GI9.GI9_CODIGO
            AND GIF.%NotDel%
        INNER JOIN %Table:G99% G99 ON
            G99.G99_FILIAL = GI9.GI9_FILIAL
            AND G99.G99_CODIGO = GIF.GIF_CODG99
            AND G99.G99_CODREC BETWEEN %Exp:cAgenIni% AND %Exp:cAgenFim%
            AND G99.%NotDel%
            %Exp:cWhereG99%
    where 
        GI9.GI9_FILIAL = %xFilial:GI9%
        AND GI9.GI9_VEICUL BETWEEN %Exp:cVeicIni% AND %Exp:cVeicFim%
        AND GI9.GI9_DTCRIA BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
        AND GI9.%NotDel%
        %Exp:cWhereGI9%
    Order By GI9_CODIGO,G99_CODREC,G99_CODIGO
EndSql

oTable  := GtpxTmpTbl(cAliasTmp,{{"IDX",{"GI9_CODIGO","G99_CODREC","G99_CODIGO"}}})

Return oTable


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDadosMDF

@type Static Function
@author jacomo.fernandes
@since 13/12/2019
@version 1.0
@param oTable, object, (Descrição do parâmetro)
@return cAliasMdf, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetDadosMDF(oTable)
Local cAliasMdf := GetNextAlias()
Local cAliasTmp := oTable:GetRealName()
Local cStr034   := STR0034 //'Aberto'
Local cStr035   := STR0035 //'Cancelado'
Local cStr036   := STR0036 //'Encerrado'
Local cST9Fil   := FWxFilial('ST9',cFilAnt)

cAliasTmp := "%"+cAliasTmp+"%"

BeginSql Alias cAliasMdf
    Select 
        GI9_CODIGO,
        GI9_SERIE,
        GI9_NUMERO, 
        ST9.T9_CODBEM,
        GI9_PLACA,
        ST9.T9_MODELO,
        GI2.GI2_COD,
        GI2.GI2_NUMLIN,
        GID.GID_NUMSRV,
        GI1ORI.GI1_DESCRI AS ORIGEM,
        GI1DES.GI1_DESCRI AS DESTINO,
        GI6.GI6_CODIGO,
        GI6.GI6_DESCRI,
        (Case GI9_STATUS
            When '1' then %Exp:cStr034%//'Aberto'
            When '2' then %Exp:cStr035%//'Cancelado'
            When '3' then %Exp:cStr036%//'Encerrado'
            
        End) as GI9_STATUS
    From (
            Select DISTINCT 
                GI9_FILIAL,
                GI9_CODIGO,
                GI9_SERIE,
                GI9_NUMERO, 
                GI9_CODEMI,
                GI9_VEICUL,
                GYN_LINCOD,
                GYN_CODGID,
                GI9_PLACA,
                GI9_STATUS
            From %Exp:cAliasTmp% 
        ) TMP
        Inner Join %Table:ST9% ST9 on
            ST9.T9_FILIAL = %Exp:cST9Fil%
            AND ST9.T9_CODBEM = TMP.GI9_VEICUL
		    AND ST9.%NotDel%
        Inner Join %Table:GI2% GI2 on
            GI2.GI2_FILIAL = %xFilial:GI2%
            AND GI2.GI2_COD = TMP.GYN_LINCOD
            AND GI2.GI2_HIST = '2'
            AND GI2.%NotDel%
        Inner Join %Table:GI1% GI1ORI on
            GI1ORI.GI1_FILIAL = %xFilial:GI1%
            AND GI1ORI.GI1_COD = GI2.GI2_LOCINI
            AND GI1ORI.%NotDel%
        Inner Join %Table:GI1% GI1DES on
            GI1DES.GI1_FILIAL = %xFilial:GI1%
            AND GI1DES.GI1_COD = GI2.GI2_LOCFIM
            AND GI1DES.%NotDel%
        Left Join %Table:GID% GID on
            GID.GID_FILIAL = GI2.GI2_FILIAL
            AND GID.GID_COD = TMP.GYN_CODGID
            AND GID.GID_HIST = '2'
            AND GID.%NotDel%
        INNER JOIN %Table:GI6% GI6 ON
            GI6.GI6_FILIAL = %xFilial:GI6%
            AND GI6.GI6_CODIGO = TMP.GI9_CODEMI
            AND GI6.%NotDel%
    ORDER BY GI9_CODIGO
EndSql

Return cAliasMdf

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDadosAge

@type Static Function
@author jacomo.fernandes
@since 14/12/2019
@version 1.0
@param cCodMDF, character, (Descrição do parâmetro)
@return cAliasAge, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetDadosAge(oTable,cCodMDF)
Local cAliasAge := GetNextAlias()
Local cAliasTmp := oTable:GetRealName()

cAliasTmp := "%"+cAliasTmp+"%"

BeginSql Alias cAliasAge
    Column G55_DTCHEG as Date
    select 
        TMP.GI9_CODIGO,
        GI6.GI6_FILRES,
        GI6.GI6_CODIGO,
        GI6.GI6_DESCRI,
        G55.G55_DTCHEG,
        G55.G55_HRFIM,
        GI1.GI1_CDMUNI,
        GI1.GI1_UF,
        CC2.CC2_MUN
    from (
            SELECT DISTINCT 
                GI9_CODIGO,
                G99_CODREC,
                GI9_VIAGEM
            FROM %Exp:cAliasTmp% 
            WHERE GI9_CODIGO = %Exp:cCodMDF%
        ) TMP
        INNER JOIN %Table:GI6% GI6 ON
            GI6.GI6_FILIAL = %xFilial:GI6%
            AND GI6.GI6_CODIGO = TMP.G99_CODREC
            AND GI6.%NotDel%
        INNER JOIN %Table:GI1% GI1 ON
            GI1.GI1_FILIAL = %xFilial:GI1%
            AND GI1.GI1_COD = GI6.GI6_LOCALI
            AND GI1.%NotDel%
        INNER JOIN %Table:CC2% CC2 ON
            CC2.CC2_FILIAL = %xFilial:CC2%
            AND CC2.CC2_EST = GI1.GI1_UF
            AND CC2.CC2_CODMUN = GI1.GI1_CDMUNI
            AND CC2.%NotDel%
        LEFT JOIN %Table:G55% G55 ON
            G55.G55_FILIAL = %xFilial:G55%
            AND G55.G55_CODVIA = TMP.GI9_VIAGEM
            AND G55.G55_LOCDES = GI6.GI6_LOCALI
            AND G55.%NotDel%
    ORDER BY IsNull(G55_SEQ,'')

EndSql

Return cAliasAge


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDadosCte(oTable,cAliasAge)

@type Static Function
@author jacomo.fernandes
@since 14/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function GetDadosCte(oTable,cAliasAge)
Local cAliasCte := GetNextAlias()
Local cAliasTmp := oTable:GetRealName()
Local cCodMDF   := (cAliasAge)->GI9_CODIGO
Local cCodAge   := (cAliasAge)->GI6_CODIGO
Local cStr026   := STR0026
Local cStr027   := STR0027
Local cStr028   := STR0028
Local cStr029   := STR0029

Local cStr037   := STR0037 //'Aguardando'
Local cStr038   := STR0038 //'Em Transporte'
Local cStr039   := STR0039 //'Em Transbordo'
Local cStr040   := STR0040 //'Recebida'
Local cStr041   := STR0041 //'Retirada'

cAliasTmp := "%"+cAliasTmp+"%"

BeginSql Alias cAliasCte
    Select 
        G99_CODIGO,
        B1_COD,
        B1_DESC,
        G99_SERIE,
        G99_NUMDOC,
        (CASE G99_TOMADO
            WHEN '0' THEN %Exp:cStr026% // 'Remetente'
            ELSE %Exp:cStr027%  //'Destinatário'
        END) G99_TOMADO,
        G99_VALOR,
        (CASE G9Q_STAENC
            WHEN '6' THEN %Exp:cStr028% //'Sim'
            ELSE %Exp:cStr029% //'Não'
        END) G9Q_STAENC,
        (CASE G99_STAENC
            WHEN '1' THEN %Exp:cStr037%//'Aguardando'
            WHEN '2' THEN %Exp:cStr038%//'Em Transporte'
            WHEN '3' THEN %Exp:cStr039%//'Em Transbordo'
            WHEN '4' THEN %Exp:cStr040%//'Recebida'
            WHEN '5' THEN %Exp:cStr041%//'Retirada'
        END) G99_STAENC
    From %Exp:cAliasTmp% TMP
        INNER JOIN %Table:SB1% SB1 ON
            SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = TMP.G99_CODPRO
            AND SB1.%NotDel%
        INNER JOIN %Table:G9Q% G9Q ON
            G9Q.G9Q_FILIAL = TMP.GI9_FILIAL
            AND G9Q_CODIGO = TMP.G99_CODIGO
            AND G9Q_AGEDES = TMP.G99_CODREC
            AND G9Q.%NotDel%
        
    WHERE 
        GI9_CODIGO = %Exp:cCodMDF%
        and G99_CODREC = %Exp:cCodAge %
    Order By G99_CODIGO
        
EndSql

Return cAliasCte
