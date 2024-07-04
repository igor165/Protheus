#INCLUDE "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR300A.CH'

#define DMPAPER_A4 9

/*/{Protheus.doc} GTPR300A
(Relatório de Viagens por Qt e KM)
@type  Function
@author lucivan.correia
@since 02/02/2021
@version 1.0
@return
@example
(examples)
@see (links_or_references)
/*/
Function GTPR300A()

Local cPerg := "GTPR300A"
Private oReport

    If Pergunte( cPerg, .T. )
        oReport := ReportDef( cPerg )
        oReport:PrintDialog()
    Endif

Return

/*/{Protheus.doc} ReportDef
(long_description)
@type  Static Function
@author lucivan.correia
@since 02/02/2021
@version 1.0
@param cPerg
@return oReport
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef(cPerg)
Local oReport:= Nil
Local oSection1:= Nil
Local oSection2:= Nil
Local cAliasTmp := GetNextAlias()
Local cTitle   := STR0001 //"Relatório Totalizador de Viagens"
Local cHelp    := STR0002 //"Gera o Relatório Totalizador de Viagens agrupado por tipo de linha, tipo de viagem e linha"
Local oBreak

oReport := TReport():New('GTPR300A',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasTmp)},cHelp,,,,,,,)

    oReport:SetTotalInLine(.T.)

    oSection1:= TRSection():New(oReport, STR0003, {cAliasTmp}, , .F., .T., , , , , , , , .T. , , .T. , ":" , , , , ,) //"Tipo de Linha"

        TRCell():New(oSection1,"GQC_DESCRI" ,cAliasTmp,"Tipo Linha","@" , 25, , , , , , , , .T. , , , .T.)

    oSection2:= TRSection():New(oReport, STR0004, {cAliasTmp}, NIL, .F., .T.,,,,.T.) //"Tipo Viagem"

        TRCell():New(oSection2,"GYN_LINCOD"      ,cAliasTmp,STR0005 ,"@!",             6, , , , ,        , , , .T. , , ,) //"Linha"
        TRCell():New(oSection2,"Nome_Linha"      ,cAliasTmp,STR0006 ,"@!",            40, , , , ,        , , , .T. , , ,) //"Nome Linha"
        TRCell():New(oSection2,"Tipo_Viagem"     ,cAliasTmp,STR0004 ,"@!",            15, , , , ,        , , , .T. , , ,) //"Tipo Viagem"
        TRCell():New(oSection2,"Total_Viagens"   ,cAliasTmp,STR0007 ,"@E 99,999,999", 10, , , , ,"RIGHT" , , , .T. , , ,) //"Total Viagens"
        TRCell():New(oSection2,"Total_Completas" ,cAliasTmp,STR0008 ,"@E 99,999,999", 10, , , , ,"RIGHT" , , , .T. , , ,) //"Total Completas"
        TRCell():New(oSection2,"Total_Parciais"  ,cAliasTmp,STR0009 ,"@E 99,999,999", 10, , , , ,"RIGHT" , , , .T. , , ,) //"Total Parciais"
        TRCell():New(oSection2,"KM_Asfalto"      ,cAliasTmp,STR0010 ,"@E 999,999.99", 10, , , , ,"RIGHT" , , , .T. , , ,) //"KM Asfalto"
        TRCell():New(oSection2,"KM_Terra"        ,cAliasTmp,STR0011 ,"@E 999,999.99", 10, , , , ,"RIGHT" , , , .T. , , ,) //"KM Terra"
        TRCell():New(oSection2,"KM_Total"        ,cAliasTmp,STR0012 ,"@E 999,999.99", 10, , , , ,"RIGHT" , , , .T. , , ,) //"KM Total"  

    oBreak := TRBreak():New(oSection2,oSection2:Cell("GYN_LINCOD"),STR0013) //"Subtotal por Linha:"

    TRFunction():New(oSection2:Cell("TOTAL_VIAGENS")   ,,"SUM", oBreak ,STR0014 ,,,.F.,.T.) //"Total Geral Viagens...."
    TRFunction():New(oSection2:Cell("TOTAL_COMPLETAS") ,,"SUM", oBreak ,STR0015 ,,,.F.,.T.) //"Total Geral Completas.."
    TRFunction():New(oSection2:Cell("TOTAL_PARCIAIS")  ,,"SUM", oBreak ,STR0016 ,,,.F.,.T.) //"Total Geral Parciais..."
    TRFunction():New(oSection2:Cell("KM_ASFALTO")      ,,"SUM", oBreak ,STR0017 ,,,.F.,.T.) //"Total Geral KM Asfalto."
    TRFunction():New(oSection2:Cell("KM_TERRA")        ,,"SUM", oBreak ,STR0018 ,,,.F.,.T.) //"Total Geral KM Terra..."
    TRFunction():New(oSection2:Cell("KM_TOTAL")        ,,"SUM", oBreak ,STR0019 ,,,.F.,.T.) //"Total Geral KM Total..."

Return oReport


/*/{Protheus.doc} ReportPrint
(long_description)
@type  Static Function
@author lucivan.correia
@since 02/02/2021
@version 1.0
@param cPerg, cAliasTmp
@return oReport
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint(oReport,cAliasTmp)
    Local oSection1  := oReport:Section(1)
    Local oSection2  := oReport:Section(2)     
    Local cCodTipLin := "" 
    Local cQuery     := ""

    If !(Empty(MV_PAR01)) .OR. !(Empty(MV_PAR02))
        cQuery += " AND GYN.GYN_DTINI BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
    EndIf

    If !(Empty(MV_PAR03)) .OR. !(Empty(MV_PAR04))
        cQuery += " AND GI2.GI2_TIPLIN BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
    EndIf

    If !(Empty(MV_PAR05)) .OR. !(Empty(MV_PAR06))
        cQuery += " AND GYN.GYN_LINCOD BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
    EndIf    

    If !(Empty(MV_PAR07))
        If MV_PAR07 <> 4
            cQuery += " AND GYN.GYN_TIPO ='" + ALLTRIM(STR(MV_PAR07)) + "'"
        EndIf
    EndIf

    cQuery := "%"+cQuery+"%"    

	BeginSQL Alias cAliasTmp
        SELECT
            GI2.GI2_TIPLIN
        ,   GQC.GQC_DESCRI
        ,   GYN.GYN_LINCOD
        ,
            (
                CASE GYN.GYN_LINSEN
                    WHEN '2'
                        THEN RTrim(GI1DES.GI1_DESCRI) + ' x ' + RTrim(GI1ORI.GI1_DESCRI)
                        ELSE RTrim(GI1ORI.GI1_DESCRI) + ' x ' + RTrim(GI1DES.GI1_DESCRI)
                END
            )
            AS Nome_Linha
        ,
            (
                CASE GYN.GYN_TIPO
                    WHEN '1'
                        THEN 'Normal'
                    WHEN '2'
                        THEN 'Extraordinária'
                        ELSE 'Fret. Contínuo'
                END
            )
            AS Tipo_Viagem
        , TV.Total_Viagens
        , ISNULL(TC.Total_Completas, 0) AS Total_Completas
        , ISNULL(TP.Total_Parciais, 0)  AS Total_Parciais
        , ISNULL(TKMA.KM_Asfalto, 0)    AS KM_Asfalto
        , ISNULL(TKMT.KM_Terra, 0)      AS KM_Terra
        , ISNULL(TKMTOT.KM_Total, 0)    AS KM_Total
        FROM
            %Table:GYN% GYN
            INNER JOIN
                (
                    SELECT
                        GYN_LINCOD
                        , GYN_TIPO
                        , COUNT(GYN_FINAL) AS Total_Viagens
                    FROM
                        %Table:GYN% AS GYN_6
                    WHERE GYN_6.%NotDel%
                    GROUP BY
                        GYN_LINCOD
                    , GYN_TIPO
                )
                AS TV
                ON
                    GYN.GYN_TIPO       = TV.GYN_TIPO
                    AND GYN.GYN_LINCOD = TV.GYN_LINCOD
                    AND GYN.%NotDel%
            LEFT OUTER JOIN
                (
                    SELECT
                        GYN_LINCOD
                        , GYN_TIPO
                        , COUNT(GYN_FILIAL) AS Total_Completas
                    FROM
                        %Table:GYN% AS GYN_5
                    WHERE GYN_5.%NotDel%
                    GROUP BY
                        GYN_TIPO
                        , GYN_LINCOD
                        , GYN_FINAL
                    HAVING
                        (
                            GYN_FINAL = '1'
                        )
                )
                AS TC
                ON
                    GYN.GYN_LINCOD   = TC.GYN_LINCOD
                    AND GYN.GYN_TIPO = TC.GYN_TIPO
                    AND GYN.%NotDel%
            LEFT OUTER JOIN
                (
                    SELECT
                        GYN_LINCOD
                        , GYN_TIPO
                        , COUNT(GYN_FINAL) AS Total_Parciais
                    FROM
                        %Table:GYN% AS GYN_4
                    WHERE GYN_4.%NotDel%
                    GROUP BY
                        GYN_LINCOD
                        , GYN_TIPO
                        , GYN_FINAL
                    HAVING
                        (
                            GYN_FINAL <> '1'
                        )
                )
                AS TP
                ON
                    GYN.GYN_LINCOD   = TP.GYN_LINCOD
                    AND GYN.GYN_TIPO = TP.GYN_TIPO
                    AND GYN.%NotDel%
            LEFT OUTER JOIN
                (
                    SELECT
                        GYN_3.GYN_LINCOD
                        , GYN_3.GYN_TIPO
                        , SUM(GI4.GI4_KMASFA) AS KM_Asfalto
                    FROM
                        %Table:GI4% GI4
                        RIGHT OUTER JOIN
                            %Table:GYN% AS GYN_3
                            ON
                                GI4.GI4_LINHA = GYN_3.GYN_LINCOD
                                AND GYN_3.%NotDel%
                        RIGHT OUTER JOIN
                            %Table:G55% G55
                            ON
                                GYN_3.GYN_FILIAL     = G55.G55_FILIAL
                                AND GYN_3.GYN_CODGID = G55.G55_CODGID
                                AND GYN_3.GYN_CODIGO = G55.G55_CODVIA
                                AND GI4.GI4_LOCDES   = G55.G55_LOCDES
                                AND GI4.GI4_LOCORI   = G55.G55_LOCORI
                                AND GI4.GI4_FILIAL   = G55.G55_FILIAL
                                AND G55.%NotDel%
                    GROUP BY
                        GYN_3.GYN_LINCOD
                        , GYN_3.GYN_TIPO
                )
                AS TKMA
                ON
                    GYN.GYN_LINCOD   = TKMA.GYN_LINCOD
                    AND GYN.GYN_TIPO = TKMA.GYN_TIPO
                    AND GYN.%NotDel%
            LEFT OUTER JOIN
                (
                    SELECT
                        GYN_2.GYN_LINCOD
                        , GYN_2.GYN_TIPO
                        , SUM(GI4_2.GI4_KMTERR) AS KM_Terra
                    FROM
                        %Table:GI4% AS GI4_2
                        RIGHT OUTER JOIN
                            %Table:GYN% AS GYN_2
                            ON
                                GI4_2.GI4_LINHA = GYN_2.GYN_LINCOD
                                AND GYN_2.%NotDel%
                        RIGHT OUTER JOIN
                            %Table:G55% AS G55_2
                            ON
                                GYN_2.GYN_FILIAL     = G55_2.G55_FILIAL
                                AND GYN_2.GYN_CODGID = G55_2.G55_CODGID
                                AND GYN_2.GYN_CODIGO = G55_2.G55_CODVIA
                                AND GI4_2.GI4_LOCDES = G55_2.G55_LOCDES
                                AND GI4_2.GI4_LOCORI = G55_2.G55_LOCORI
                                AND GI4_2.GI4_FILIAL = G55_2.G55_FILIAL
                                AND G55_2.%NotDel%
                    GROUP BY
                        GYN_2.GYN_LINCOD
                        , GYN_2.GYN_TIPO
                )
                AS TKMT
                ON
                    GYN.GYN_LINCOD   = TKMT.GYN_LINCOD
                    AND GYN.GYN_TIPO = TKMT.GYN_TIPO
                    AND GYN.%NotDel%
            LEFT OUTER JOIN
                (
                    SELECT
                        GYN_1.GYN_LINCOD
                        , GYN_1.GYN_TIPO
                        , SUM(GI4_1.GI4_KMASFA + GI4_1.GI4_KMTERR) AS KM_Total
                    FROM
                        %Table:GI4% AS GI4_1
                        RIGHT OUTER JOIN
                            %Table:GYN% AS GYN_1
                            ON
                                GI4_1.GI4_LINHA = GYN_1.GYN_LINCOD
                                AND GYN_1.%NotDel%
                        RIGHT OUTER JOIN
                            %Table:G55% AS G55_1
                            ON
                                GYN_1.GYN_FILIAL     = G55_1.G55_FILIAL
                                AND GYN_1.GYN_CODGID = G55_1.G55_CODGID
                                AND GYN_1.GYN_CODIGO = G55_1.G55_CODVIA
                                AND GI4_1.GI4_LOCDES = G55_1.G55_LOCDES
                                AND GI4_1.GI4_LOCORI = G55_1.G55_LOCORI
                                AND GI4_1.GI4_FILIAL = G55_1.G55_FILIAL
                                AND G55_1.%NotDel%
                    GROUP BY
                        GYN_1.GYN_LINCOD
                        , GYN_1.GYN_TIPO
                )
                AS TKMTOT
                ON
                    GYN.GYN_LINCOD   = TKMTOT.GYN_LINCOD
                    AND GYN.GYN_TIPO = TKMTOT.GYN_TIPO
                    AND GYN.%NotDel%
            INNER JOIN
                %Table:GI1% AS GI1ORI
                ON
                    RTRIM(GYN.GYN_LOCORI) = RTRIM(GI1ORI.GI1_COD)
                    AND GI1ORI.%notDel%
            INNER JOIN
                %Table:GI1% AS GI1DES
                ON
                    RTRIM(GYN.GYN_LOCDES) = RTRIM(GI1DES.GI1_COD)
                    AND GI1DES.%notDel%
            INNER JOIN
                %Table:GI2% GI2
                ON
                    GYN.GYN_FILIAL     = GI2.GI2_FILIAL
                    AND GYN.GYN_LINCOD = GI2.GI2_COD
                    AND GI2.%NotDel%
            INNER JOIN
                %Table:GQC% GQC
                ON
                    GI2.GI2_TIPLIN = GQC.GQC_CODIGO
                    AND GQC.%NotDel%                
        WHERE
            GYN.%NotDel%
            %Exp:cQuery%
        GROUP BY
            GYN.GYN_TIPO
            , GYN.GYN_LINCOD
            , TV.Total_Viagens
            , TC.Total_Completas
            , TP.Total_Parciais
            , TKMA.KM_Asfalto
            , TKMT.KM_Terra
            , TKMTOT.KM_Total
            ,
                (
                    CASE GYN.GYN_LINSEN
                        WHEN '2'
                            THEN RTrim(GI1DES.GI1_DESCRI) + ' x ' + RTrim(GI1ORI.GI1_DESCRI)
                            ELSE RTrim(GI1ORI.GI1_DESCRI) + ' x ' + RTrim(GI1DES.GI1_DESCRI)
                    END
                )
            , GQC.GQC_DESCRI
            , GI2.GI2_TIPLIN        
        ORDER BY
            GI2.GI2_TIPLIN
            , GYN.GYN_LINCOD
    EndSql
    
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(dbGoTop())
    oReport:SetMeter((cAliasTmp)->(RecCount()))   

    //Percorrendo arquivo
    While (cAliasTmp)->(!Eof())
        
        If oReport:Cancel()
            Exit
        EndIf
    
        //inicializo a primeira seção
        oSection1:Init()

        oReport:IncMeter()
                    
        cCodTipLin     := (cAliasTmp)->GI2_TIPLIN
        IncProc("Imprimindo Tipos de Linhas "+alltrim((cAliasTmp)->GQC_DESCRI))
        
        //imprimo a primeira seção                
        oSection1:Cell("GQC_DESCRI"):SetValue((cAliasTmp)->GI2_TIPLIN + " - " + (cAliasTmp)->GQC_DESCRI)                
        oSection1:Printline()
        
        //inicializo a segunda seção
        oSection2:init()
        
        //verifico se o Tipo de linha é mesmo, se sim, imprimo as viagens
        While (cAliasTmp)->GI2_TIPLIN == cCodTipLin
            oReport:IncMeter()        
        
            IncProc("Imprimindo Tipos de Viagens "+alltrim((cAliasTmp)->Tipo_Viagem))

            oSection2:Cell("Tipo_Viagem"):SetValue((cAliasTmp)->Tipo_Viagem)
            oSection2:Cell("Total_Viagens"):SetValue((cAliasTmp)->Total_Viagens)
            oSection2:Cell("Total_Completas"):SetValue((cAliasTmp)->Total_Completas)            
            oSection2:Cell("Total_Parciais"):SetValue((cAliasTmp)->Total_Parciais)
            oSection2:Cell("KM_Asfalto"):SetValue((cAliasTmp)->KM_Asfalto) 
            oSection2:Cell("KM_Terra"):SetValue((cAliasTmp)->KM_Terra) 
            oSection2:Cell("KM_Total"):SetValue((cAliasTmp)->KM_Total)  

            oSection2:Printline()
    
             (cAliasTmp)->(dbSkip())
         EndDo        
         //finalizo a segunda seção para que seja reiniciada para o proximo registro
         oSection2:Finish()

         //finalizo a primeira seção
        oSection1:Finish()
    Enddo

    If Select(cAliasTmp) > 0 
        (cAliasTmp)->(DbCloseArea())
    Endif

Return
