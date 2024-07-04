#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'GTPR307.ch'

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPR307

@type Function
@author jacomo.fernandes
@since 02/03/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Function GTPR307()
Local oReport
Local cPerg  := 'GTPR307'

If Pergunte(cPerg, .T.)
    oReport := ReportDef(cPerg)
    oReport:PrintDialog()
Endif

GTPDestroy(oReport)

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} ReportDef

@type Static Function
@author jacomo.fernandes
@since 02/03/2020
@version 1.0
@param cPerg, character, (Descrição do parâmetro)
@return oReport, return_description
/*/
//------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local oReport   := Nil
Local oSection  := Nil
Local cAliasTmp := GetNextAlias()
Local cTitle   := "Colaboradores x Linhas"
Local cHelp    := "Gera o relatório de Colaboradores x Linhas"

oReport := TReport():New('GTPR307',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasTmp)},cHelp)

oSection := TRSection():New(oReport, cTitle, cAliasTmp)
TRCell():New(oSection,"GYG_CODIGO"  , "GYG") 
TRCell():New(oSection,"GYG_NOME"    , "GYG") 
TRCell():New(oSection,"GI2_COD"     , "GI2") 
TRCell():New(oSection,"GI3_NLIN"    , "GI3") 

oSection:Cell("GYG_CODIGO"  ):SetTitle('Cód. Colab.')
oSection:Cell("GYG_NOME"    ):SetTitle('Colaborador')
oSection:Cell("GI2_COD"     ):SetTitle('Cód Linha')
oSection:Cell("GI3_NLIN"    ):SetTitle('Nome Linha')

oSection:Cell("GI3_NLIN"    ):SetSize( ( TamSx3('GI1_DESCRI')[1] * 2 ) + 3 )

Return oReport

//------------------------------------------------------------------------------
/* /{Protheus.doc} ReportPrint

@type Static Function
@author jacomo.fernandes
@since 02/03/2020
@version 1.0
@param oReport, object, (Descrição do parâmetro)
@param cAliasTmp, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasTmp)
Local oSection  := oReport:Section(1)

Local dDtIni    := MV_PAR01
Local dDtFim    := MV_PAR02
Local cSetorIni := MV_PAR03
Local cSetorFim := MV_PAR04
Local cGrupoIni := MV_PAR05
Local cGrupoFim := MV_PAR06

oSection:BeginQuery()

	BeginSQL Alias cAliasTmp
        SELECT DISTINCT * 
        FROM (
            Select Distinct
                GYG.GYG_CODIGO,
                GYG.GYG_NOME, 
                GI2.GI2_COD, 
                (Case GYN.GYN_LINSEN
                    WHEN '2' 
                        THEN RTrim(GI1DES.GI1_DESCRI) || ' x ' || RTrim(GI1ORI.GI1_DESCRI)
                    ELSE
                        RTrim(GI1ORI.GI1_DESCRI) || ' x ' || RTrim(GI1DES.GI1_DESCRI)
                End) GI3_NLIN,
                IsNull(GY2.GY2_SETOR,'') GY2_SETOR,
                IsNull(GRUPO.GZA_CODIGO,'') GZA_CODIGO
            from %Table:GYG% GYG
                INNER JOIN %Table:GQE% GQE ON
                    GQE.GQE_FILIAL = %xFilial:GQE%
                    AND GQE.GQE_RECURS = GYG.GYG_CODIGO
                    AND GQE.GQE_TRECUR = '1'
                    AND GQE.GQE_CANCEL = '1'
                    AND GQE.GQE_TERC <> '1'
                    AND GQE.GQE_DTREF BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
                    AND GQE.%NotDel%
                INNER JOIN %Table:GYN% GYN ON
                    GYN.GYN_FILIAL = GQE.GQE_FILIAL
                    AND GYN.GYN_CODIGO = GQE.GQE_VIACOD
                    AND GYN.%NotDel%
                INNER JOIN %Table:GI2% GI2 ON
                    GI2.GI2_FILIAL = %xFilial:GI2%
                    AND GI2.GI2_COD = GYN.GYN_LINCOD
                    AND GI2.GI2_HIST = '2'
                    AND GI2.%NotDel%
                INNER JOIN %Table:GI1% GI1ORI ON
                    GI1ORI.GI1_FILIAL = %xFilial:GI1%
                    AND GI1ORI.GI1_COD = GI2.GI2_LOCINI
                    AND GI1ORI.%NotDel%
                INNER JOIN %Table:GI1% GI1DES ON
                    GI1DES.GI1_FILIAL = %xFilial:GI1%
                    AND GI1DES.GI1_COD = GI2.GI2_LOCFIM
                    AND GI1DES.%NotDel%
                Left join %Table:GY2% GY2 ON
                    GY2.GY2_FILIAL = %xFilial:GY2%
                    AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
                    AND GY2.%NotDel%
                Left join (
                            select GZA.GZA_FILIAL,GZA.GZA_SETOR,GZA.GZA_CODIGO,GYI_COLCOD 
                            From %Table:GZA% GZA 
                                INNER JOIN %Table:GYI% GYI ON
                                    GYI.GYI_FILIAL = GZA.GZA_FILIAL
                                    AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO
                                    AND GYI.%NotDel%
                            WHERE
                                GZA.GZA_FILIAL = %xFilial:GZA%
                                AND GZA.%NotDel%
                
                ) GRUPO ON
                    GRUPO.GZA_SETOR = GY2.GY2_SETOR
                    AND GRUPO.GYI_COLCOD = GYG.GYG_CODIGO
                
            WHERE 
                GYG.GYG_FILIAL = %xFilial:GYG%
                AND GYG.%NotDel%

            UNION ALL

            Select Distinct
                GYG.GYG_CODIGO,
                GYG.GYG_NOME, 
                GYP.GYP_LINCOD, 
                (Case GYP_LINSTD 
                    WHEN '2' 
                        THEN RTrim(GI1DES.GI1_DESCRI) || ' x ' || RTrim(GI1ORI.GI1_DESCRI)
                    ELSE
                        RTrim(GI1ORI.GI1_DESCRI) || ' x ' || RTrim(GI1DES.GI1_DESCRI)
                End),
                IsNull(GY2.GY2_SETOR,%Exp:Space(TamSx3('GY2_SETOR')[1])%) GY2_SETOR,
                IsNull(GRUPO.GZA_CODIGO,%Exp:Space(TamSx3('GZA_CODIGO')[1])%) GZA_CODIGO
            From %Table:GYG% GYG
                INNER JOIN %Table:GYE% GYE ON
                    GYE.GYE_FILIAL = %xFilial:GYE%
                    AND GYE.GYE_COLCOD = GYG.GYG_CODIGO
                    AND GYE.GYE_DTREF BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
                    AND GYE.GYE_ESCALA <> %Exp:Space(TamSx3('GYE_ESCALA')[1])%
                    AND GYE.%NotDel%
                INNER JOIN %Table:GYP% GYP ON
                    GYP.GYP_FILIAL = %xFilial:GYP%
                    AND GYP.GYP_ESCALA = GYE.GYE_ESCALA
                    AND GYP.GYP_LINCOD <> %Exp:Space(TamSx3('GYP_LINCOD')[1])%
                    AND GYP.%NotDel%
                INNER JOIN %Table:GI2% GI2 ON
                    GI2.GI2_FILIAL = %xFilial:GI2%
                    AND GI2.GI2_COD = GYP.GYP_LINCOD
                    AND GI2.GI2_HIST = '2'
                    AND GI2.%NotDel%
                INNER JOIN %Table:GI1% GI1ORI ON
                    GI1ORI.GI1_FILIAL = %xFilial:GI1%
                    AND GI1ORI.GI1_COD = GI2.GI2_LOCINI
                    AND GI1ORI.%NotDel%
                INNER JOIN %Table:GI1% GI1DES ON
                    GI1DES.GI1_FILIAL = %xFilial:GI1%
                    AND GI1DES.GI1_COD = GI2.GI2_LOCFIM
                    AND GI1DES.%NotDel%
                LEFT JOIN %Table:GY2% GY2 ON
                    GY2.GY2_FILIAL = %xFilial:GY2%
                    AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
                    AND GY2.%NotDel%
                LEFT JOIN (
                            Select 
                                GZA.GZA_FILIAL,
                                GZA.GZA_SETOR,
                                GZA.GZA_CODIGO,
                                GYI_COLCOD 
                            From %Table:GZA% GZA 
                                INNER JOIN %Table:GYI% GYI ON
                                    GYI.GYI_FILIAL = GZA.GZA_FILIAL
                                    AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO
                                    AND GYI.%NotDel%
                            WHERE
                                GZA.GZA_FILIAL = %xFilial:GZA%
                                AND GZA.%NotDel%
                
                ) GRUPO ON
                    GRUPO.GZA_SETOR = GY2.GY2_SETOR
                    AND GRUPO.GYI_COLCOD = GYG.GYG_CODIGO
            WHERE 
                GYG.GYG_FILIAL = %xFilial:GYG%
                AND GYG.%NotDel%
            ) T 
        where 
            GY2_SETOR BETWEEN %Exp:cSetorIni% AND %Exp:cSetorFim%
            AND GZA_CODIGO BETWEEN %Exp:cGrupoIni% AND %Exp:cGrupoFim%
        order by GYG_CODIGO, GI2_COD
	EndSQL 
	
oSection:EndQuery()

oSection:Print()	

Return 