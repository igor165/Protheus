#include 'FILEIO.CH'
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign   := FwXlsxCellAlignment():Vertical()
static cNameRot         := "FECHAMENTO FRETES"
/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 05.05.2023                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatorio com Informacoes de Pedido de Compras. 				       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VACOMR13()                                                         |
 '---------------------------------------------------------------------------------*/
User Function VACOMR13()
    Local cTimeIni	 	:= Time()
    Local aArea         := GetArea()
    Local cQry          := ''
    Local lAddLinha		:= .F.
    Local aDados		:= {}
    Local lRet          := .F.
    Local lRecua        := .T.
    Local nRet          := 0
    Local aParamBox     := {}
    Local aRetParam     := {}
    Local nPos
    Local cWorkSheet    := "Aba 1"
    Local nBakRow, nBakCol, nRowTotal, nVoltar := 0
    Local cBakCod       := ""
    Local cBakTransp    := ""
    Local cBakLoja      := ""
    Local cBakNome      := ""
    Local nI := nJ := nX := nBackPos:= 0
    Local aHeaderRel    := {"TRANSPORTADORA",;
                            "LOCAL",;
                            "PECUARISTA",;
                            "EMBARQUE",;
                            "DESEMBARQUE",;
                            "PLACA",;
                            "PLACA CARRETA 1",;
                            "PLACA CARRETA 2",;
                            "Nº MINUTA",;
                            "QTDE",;
                            "KM",;
                            "VALOR DO KM",;
                            "VALOR FRETE",;
                            "ADICIONAL",;
                            "PEDAGIO",;
                            "ICMS FRETE",;
                            "Filial CTE",;
                            "Nº CTE",;
                            "VL. CTE EMITIDO",;
                            "COMP. VALOR",;
                            "MOTORISTA"}
    Local aMescCTE      := {}

    Private cPerg		:= SubS(ProcName(),3)
    Private _cAliasG	:= GetNextAlias()
    Private cTitulo  	:= "Relatório de Fechamento de Frete"
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath + cPerg +; // __cUserID+"_"+;
                                DtoS(dDataBase)+; 
                                "_"+;
                                StrTran(SubS(Time(),1,5),":","")+;
                                ".rel"

    Private oFileW      := nil
    Private oExcel      := NIL
    Private jFormatTit,jFormatTot,jFormatHead,jFormatGD,JFLeft,JFRight,jFData,jFNum,jFMoeda //Formato de Celula
    Private jFontHeader,jFontTitulo,jFontText //Fontes
    Private jBHeaderLeft,jBHeaderRight,jBorderLeft,jBorderCenter,jBorderRight,jBottomLeft,jBottomRight,jNoBorder  // Bordas
    
    aAdd(aParamBox,{1,"Data de: "               ,Ctod(Space(8))             ,""                 ,"",""   ,"",50,.T.}) // Tipo data
    aAdd(aParamBox,{1,"Data até: "              ,Ctod(Space(8))             ,""                 ,"",""   ,"",50,.T.}) // Tipo data
    aAdd(aParamBox,{1,"Transportadora de: "     ,Space(TamSX3("A2_COD")[1]) ,""                 ,"","SA2","",50,.F.}) // Tipo data
    aAdd(aParamBox,{1,"Transportadora até: "    ,Space(TamSX3("A2_COD")[1]) ,""                 ,"","SA2","",50,.F.}) // Tipo data
    aAdd(aParamBox,{1,"Forncedor de: "          ,Space(TamSX3("A2_COD")[1]) ,""                 ,"","SA2","",50,.F.}) // Tipo data
    aAdd(aParamBox,{1,"Fornecedor até: "        ,Space(TamSX3("A2_COD")[1]) ,""                 ,"","SA2","",50,.F.}) // Tipo data
    aAdd(aParamBox,{2,"Separa por Fornecedor?"  ,"Sim"                      ,{"Sim","Não"}      ,50,"",.F.})

    If ParamBox(aParamBox,"Teste Parâmetros...",@aRetParam)

        If Len( Directory(cPath + "*.*","D") ) == 0
            If Makedir(cPath) == 0
                ConOut('Diretorio Criado com Sucesso.')
                MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
            Else	
                ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
                MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
            EndIf
        EndIF
            
            FWMsgRun(, {|| aDados := LoadQuery(aRetParam,@_cAliasG ) },;
                            'Por Favor Aguarde...',; 
                            'Processando Banco de Dados - Recebimento')

            If Len(aDados) > 0

                DefinirFormatacao()

                If aRetParam[7] == "Sim" // Separa quadro por transportadora
                    oExcel := FwPrinterXlsx():New()
                    oExcel:Activate(cArquivo)
                    
                    
                    cWorkSheet := SUBSTR(ALLTRIM(aDados[1][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2] +;
                                  "-" + aDados[1][aScan(aDados[1], {|x| Upper(x[1]) == "TRANSPORTADORA"})][2]),1,31)

                    oExcel:AddSheet(cWorkSheet)

                    nRow := 1
                    nCol := 1

                    oExcel:SetCellsFormatConfig(jFormatTit)
                    oExcel:SetFontConfig(jFontTitulo)
                    oExcel:MergeCells(nRow, nCol, nRow, Len(aHeaderRel))

                    if Mes(aRetParam[1]) != Mes(aRetParam[2])
                        if Ano(aRetParam[1]) != Ano(aRetParam[2])
                            cNameRot := "FECHAMENTO FRETES " + " - " + dToC(aRetParam[1]) + " - " +dToC(aRetParam[2])
                        else
                            cNameRot := "FECHAMENTO FRETES " + " - " + SubStr((dToC(aRetParam[1])),1,5) + " - " + SubStr((dToC(aRetParam[2])),1,5) + " (" +AllTrim(Str(Ano(aRetParam[2]))) +")"
                        endif
                    Else
                        cNameRot := "FECHAMENTO FRETES " + " - " + SubStr((dToC(aRetParam[1])),1,2) + " - " + SubStr((dToC(aRetParam[2])),1,2) + " / " +  Mes(aRetParam[1]) + "-" + AllTrim(Str(Ano(aRetParam[2])))
                    Endif
                    
                    oExcel:SetText(nRow, nCol, cNameRot)

                    oExcel:SetCellsFormatConfig(jFormatHead)
                    oExcel:SetFontConfig(jFontHeader)
                    nRow += 1
                    nCol := 1
                    //Printando Cabeçalho
                    For nX := nCol to Len(aHeaderRel)
                        oExcel:SetValue(nRow, nX, aHeaderRel[nX])
                    Next nX

                    nTamTot := Len(aDados)
                    For nI := 1 to nTamTot
                    
                        if lAddLinha
                            nRow += 2
                            lAddLinha := !lAddLinha
                        else 
                            nRow += 1
                        Endif 
                        nCol := 1
                        
                        // Verificar se tem mais de uma linha com o mesmo código
                        // Será usado quando o frete possuir CTEs lançadas em mais de uma filial
                        // Guarda na nVoltar o valor de linhas com o msm código que irá mesclar
                        // nRow + nMergeCell = linhas mescladas.
                        nMergeCell := 0
                        aMescCTE := {}
                        cBakCod := aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_CODIGO"})][2]
                        nBackPos := nI
                        if nI < nTamTOt

                            aMescCTE := {}

                            aAdd(aMescCTE, {aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFI_FILDOC"})][2],;
                                            ALLTRIM(aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFI_DOC"})][2]),;
                                            aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "F1_VALBRUT"})][2]})

                            nI += 1
                            while cBakCod == aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_CODIGO"})][2]
                                aAdd(aMescCTE, {aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFI_FILDOC"})][2],;
                                                ALLTRIM(aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFI_DOC"})][2]),;
                                                aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "F1_VALBRUT"})][2]})

                                nMergeCell += 1
                                nI += 1
                            end
                            
                            nI := nBackPos + nMergeCell
                        ENDIF

                        oExcel:SetFontConfig(jFontText)
                        oExcel:SetCellsFormatConfig(JFLeft)
                        oExcel:SetBorderConfig(jNoBorder)

                        oExcel:MergeCells(nRow, nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "TRANSPORTADORA"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ENDFORN"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "FORNECEDOR"})][2] )
                        
                        oExcel:SetCellsFormatConfig(jFData)
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_DATA"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_DTDESE"})][2] )
                        
                        oExcel:SetCellsFormatConfig(JFLeft)
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_PLCVL"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_PLCC1"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_PLCC2"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_NUMMIN"})][2] )

                        oExcel:SetCellsFormatConfig(jFNum)
                        oExcel:SetFontConfig(jFontText)
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_QTDE"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_KM"})][2] )

                        oExcel:SetCellsFormatConfig(jFMoeda)
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_VLKM"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_VFRETE"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ADICIO"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_PEDAGI"})][2] )
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ICMSF"})][2] )

                        //oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        
                        if nMergeCell > 0
                            nBakCol := nCol
                            nBakRow := nRow
                            nBackPos:= nI

                            For nJ := 1 to Len(aMescCTE)
                                nCol := nBakCol
                                if nJ > 1
                                    nRow += 1
                                endif
                                oExcel:SetCellsFormatConfig(JFLeft)

                                oExcel:SetValue(nRow, ++nCol, aMescCTE[nJ][1] )
                                oExcel:SetValue(nRow, ++nCol, aMescCTE[nJ][2] )

                                oExcel:SetCellsFormatConfig(jFMoeda)
                                oExcel:SetValue(nRow, ++nCol, aMescCTE[nJ][3] )

                                lAddLinha := .T. 
                            Next nJ

                            nRow := nBakRow
                        else
                            oExcel:SetCellsFormatConfig(JFLeft)
                            oExcel:SetValue(nRow, ++nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFI_FILDOC"})][2] )
                            oExcel:SetValue(nRow, ++nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFI_DOC"})][2] )
                            oExcel:SetCellsFormatConfig(jFMoeda)
                            oExcel:SetValue(nRow, ++nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "F1_VALBRUT"})][2] )
                        EndIF

                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_VCOMP"})][2] )

                        oExcel:SetCellsFormatConfig(JFLeft)
                        oExcel:MergeCells(nRow, ++nCol, nRow + nMergeCell, nCol)
                        oExcel:SetValue(nRow, nCol, aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "DA4_NOME"})][2] )

                        cBakTransp  := aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2]
                        cBakLoja    := aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_RLOJA"})][2]
                        cBakNome    := aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "TRANSPORTADORA"})][2]

                        nI := iif(nI < nTamTot,nI+1,nI)

                       //if aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "TRANSPORTADORA"})][2] == 'TAMAOKI ASSESSORIA RURAL LTDA'
                       //    nPara := 1
                       //endif 
                        if aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2] != aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2] .or. nI == nTamTot
                            
                            //if aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2] != '' // final da ABA
                                
                                oExcel:ApplyAutoFilter(2,1,nRow,Len(aHeaderRel))
                                oExcel:SetCellsFormatConfig(jFormatTot)
                                nRowTotal := nRow + nMergeCell
                                nRow += 1 + nMergeCell
                                oExcel:MergeCells(nRow, 13, nRow, 15)
                                oExcel:SetFormula(nRow, 13, "=SUBTOTAL(9,M3:O"+AllTrim(cValToChar(nRowTotal))+")" ) // Frete + Pedagio 
                                oExcel:SetFormula(nRow, 16, "=SUBTOTAL(9,P3:P"+AllTrim(cValToChar(nRowTotal))+")" ) // ICMS
                                oExcel:SetFormula(nRow, 19, "=SUBTOTAL(9,S3:S"+AllTrim(cValToChar(nRowTotal))+")" ) // CTE
                                oExcel:SetFormula(nRow, 20, "=SUBTOTAL(9,T3:T"+AllTrim(cValToChar(nRowTotal))+")" ) // COMPLEMENTO
                                
                                nRow += 2
                                nCol := 1
                                oExcel:MergeCells(nRow, 1, nRow, 2)
                                oExcel:SetFontConfig(jFontHeader)
                                oExcel:SetBorderConfig(jBorderLeft)
                                oExcel:SetCellsFormatConfig(jFormatGD)
                                oExcel:SetValue(nRow, nCol  , ALLTRIM(cBakNome + " " +aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2]))
                                oExcel:SetBorderConfig(jBorderRight)
                                oExcel:SetValue(nRow, nCol+1, ALLTRIM(cBakNome + " " +aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2]))
                                
                                nBakRow := nRow += 1
                                oExcel:SetFontConfig(jFontText)
                                oExcel:SetCellsFormatConfig(JFLeft)
                                oExcel:SetBorderConfig(jBorderLeft)
                                oExcel:SetValue(nRow  , nCol, "Valor dos CTE")
                                oExcel:SetValue(++nRow, nCol, "Valor a Compensar")
                                oExcel:SetValue(++nRow, nCol, "Total a Receber")
                                oExcel:SetValue(++nRow, nCol, "Lavagem Carreta")
                                oExcel:SetValue(++nRow, nCol, "Abastecimento Better")
                                oExcel:SetValue(++nRow, nCol, "Abastecimento V@")
                                oExcel:SetValue(++nRow, nCol, "Ted")
                                oExcel:SetValue(++nRow, nCol, "")
                                
                                nRow := nBakRow
                                nCol := 2
                                oExcel:SetCellsFormatConfig(jFMoeda)
                                oExcel:SetBorderConfig(jBorderRight)
                                oExcel:SetFormula(nRow,   nCol, "=SUBTOTAL(9,M3:O"+AllTrim(cValToChar(nRowTotal))+",P3:P"+AllTrim(cValToChar(nRowTotal))+")")
                                oExcel:SetFormula(++nRow, nCol, "=SUBTOTAL(9,P3:P"+AllTrim(cValToChar(nRowTotal))+")")
                                oExcel:SetFormula(++nRow, nCol, "=SUBTOTAL(9,M3:O"+AllTrim(cValToChar(nRowTotal))+")")
                                oExcel:SetValue(++nRow, nCol, 0)
                                oExcel:SetValue(++nRow, nCol, 0)
                                oExcel:SetValue(++nRow, nCol, 0)
                                oExcel:SetFormula(++nRow, nCol, "=B"+AllTrim(cValToChar(nRow-4))+"-(B"+AllTrim(cValToChar(nRow-1))+"+B"+AllTrim(cValToChar(nRow-2))+"+B"+AllTrim(cValToChar(nRow-3))+")")
                                oExcel:SetValue(++nRow, nCol, "")
                                    //"-B"+AllTrim(cValToChar(nRow-1))+"-B"+AllTrim(cValToChar(nRow-2))+"-B"+AllTrim(cValToChar(nRow-3))+"")
                                
                                nBakRow := nRow += 1
                                nCol := 1
                                oExcel:SetCellsFormatConfig(JFLeft)
                                oExcel:SetBorderConfig(jBorderLeft)
                                oExcel:SetValue(nRow  , nCol, "Banco")
                                oExcel:SetValue(++nRow  , nCol, "CNPJ")
                                oExcel:SetValue(++nRow  , nCol, "AGÊNCIA")
                                oExcel:SetValue(++nRow  , nCol, "CONTA")
                                oExcel:SetBorderConfig(jBottomLeft)
                                oExcel:SetValue(++nRow  , nCol, "PIX")

                                nRow := nBakRow
                                nCol := 2
                                oExcel:SetCellsFormatConfig(JFRight)

                                SA2->(DBSELECTAREA("SA2"))
                                SA2->(DBSETORDER(1))

                                IF SA2->(DBSEEK(FwXFilial("SA2")+aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2]+cBakLoja))
                                    oExcel:SetCellsFormatConfig(JFRight)
                                    oExcel:SetBorderConfig(jBorderRight)
                                    oExcel:SetValue(nRow    , nCol, ALLTRIM(SA2->A2_BANCO))
                                    oExcel:SetValue(++nRow  , nCol, iif( Len( ALLTRIM(SA2->A2_CGC))==11 ,Alltrim(Transform(SA2->A2_CGC, "@R 999.999.999-99")),Alltrim(Transform(SA2->A2_CGC, "@R 99.999.999/9999-99"))))
                                    oExcel:SetValue(++nRow  , nCol, ALLTRIM(SA2->A2_AGENCIA)+ IIF(!EMPTY(ALLTRIM(SA2->A2_DVAGE)),"-"+ALLTRIM(SA2->A2_DVAGE),""))
                                    oExcel:SetValue(++nRow  , nCol, ALLTRIM(SA2->A2_NUMCON)+ IIF(!EMPTY(ALLTRIM(SA2->A2_DVCTA)),"-"+ALLTRIM(SA2->A2_DVCTA),""))
                                    cQry := " SELECT * " + CRLF
                                    cQry += " FROM "+RetSqlName("F72")+"" + CRLF
                                    cQry += " WHERE F72_COD = '"+SA2->A2_COD+"'" + CRLF
                                    cQry += " AND F72_LOJA = '"+SA2->A2_LOJA+"'" + CRLF
                                    cQry += " AND F72_ACTIVE = '1' " + CRLF
                                    cQry += " AND D_E_L_E_T_ = ''" + CRLF

                                    oExcel:SetBorderConfig(jBottomRight)
                                    MpSysOpenQuery(cQry, "TMPF72")
                                    IF !TMPF72->(EOF())
                                        if TMPF72->F72_TPCHV = '01'
                                            oExcel:SetValue(++nRow  , nCol,  Alltrim(Transform(TMPF72->F72_CHVPIX, "@R (99) 9 9999-9999")))
                                        elseif TMPF72->F72_TPCHV = '03'
                                            if Len(AllTrim(TMPF72->F72_CHVPIX)) == 11
                                                oExcel:SetValue(++nRow  , nCol,  Alltrim(Transform(TMPF72->F72_CHVPIX, "@R 999.999.999-99")))
                                            else
                                                oExcel:SetValue(++nRow  , nCol,  Alltrim(Transform(TMPF72->F72_CHVPIX, "@R 99.999.999/9999-99")))
                                            EndIf 
                                        else 
                                            oExcel:SetValue(++nRow  , nCol,  Alltrim(TMPF72->F72_CHVPIX))
                                        Endif
                                    else 
                                        oExcel:SetValue(++nRow  , nCol, "")
                                    EndIf
                                    
                                    TMPF72->(DBCLOSEAREA())
                                EndIf
                                
                                SA2->(DBCLOSEAREA())

                                IF aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2] != cBakTransp

                                    cWorkSheet := SUBSTR(ALLTRIM(aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "ZFF_ORIGEM"})][2] +;
                                                    "-" + aDados[nI][aScan(aDados[1], {|x| Upper(x[1]) == "TRANSPORTADORA"})][2]),1,31)
                                    
                                    oExcel:AddSheet(cWorkSheet)
                                    oExcel:SetBorderConfig(jNoBorder)

                                    nRow := 1
                                    nCol := 1

                                    oExcel:SetCellsFormatConfig(jFormatTit)
                                    oExcel:SetFontConfig(jFontTitulo)
                                    oExcel:MergeCells(nRow, nCol, nRow, Len(aHeaderRel))

                                    if Mes(aRetParam[1]) != Mes(aRetParam[2])
                                        if Ano(aRetParam[1]) != Ano(aRetParam[2])
                                            cNameRot := "FECHAMENTO FRETES " + " - " + dToC(aRetParam[1]) + " - " +dToC(aRetParam[2])
                                        else
                                            cNameRot := "FECHAMENTO FRETES " + " - " + SubStr((dToC(aRetParam[1])),1,5) + " - " + SubStr((dToC(aRetParam[2])),1,5) + " (" +AllTrim(Str(Ano(aRetParam[2])))+ ")"
                                        endif
                                    Else
                                        cNameRot := "FECHAMENTO FRETES " + " - " + SubStr((dToC(aRetParam[1])),1,2) + " - " + SubStr((dToC(aRetParam[2])),1,2) + " / " +  Mes(aRetParam[1]) + "-" + AllTrim(Str(Ano(aRetParam[2])))
                                    Endif
                                    
                                    oExcel:SetText(nRow, nCol, cNameRot)

                                    oExcel:SetCellsFormatConfig(JFLeft)
                                    oExcel:SetCellsFormatConfig(jFormatHead)
                                    oExcel:SetFontConfig(jFontHeader)
                                    
                                    nRow += 1
                                    nCol := 1
                                    //Printando Cabeçalho
                                    For nX := nCol to Len(aHeaderRel)
                                        oExcel:SetValue(nRow, nX, aHeaderRel[nX])
                                    Next nX
                                EndIf 
                        endif
                        if nI <= nTamTot .and. lRecua
                            if nI == nTamTot
                                lRecua := .f.
                            ENDIF
                            nI -= 1
                        ENDIF
                    Next nI
                    lRet := oExcel:toXlsx()

                    nRet := ShellExecute("open", SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx", "", "", 1)
     
                    //Se houver algum erro
                    If nRet <= 32
                        MsgStop("Não foi possível abrir o arquivo "+SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx"+ "!", "Atenção")
                    EndIf 

                    oExcel:DeActivate()
                    //MSGALERT( "Arquivo gerado em: '" + SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx" , "Atenção" ) 
                else    
                    oExcel := FwPrinterXlsx():New()
                
                    oExcel:Activate(cArquivo)
                    oExcel:AddSheet("ABA01")

                    nRow := 1
                    nCol := 1
                    
                    oExcel:SetCellsFormatConfig(jFormatTit)
                    oExcel:SetFontConfig(jFontTitulo)
                    oExcel:MergeCells(nRow, nCol, nRow, Len(aHeaderRel))
                    oExcel:SetBorderConfig(jNoBorder)

                    if Mes(aRetParam[1]) != Mes(aRetParam[2])
                        if Ano(aRetParam[1]) != Ano(aRetParam[2])
                            cNameRot := "FECHAMENTO FRETES " + " - " + dToC(aRetParam[1]) + " - " +dToC(aRetParam[2])
                        else
                            cNameRot := "FECHAMENTO FRETES " + " - " + SubStr((dToC(aRetParam[1])),1,5) + " - " + SubStr((dToC(aRetParam[2])),1,5) + " (" +AllTrim(Str(Ano(aRetParam[2]))) +")"
                        endif
                    Else
                        cNameRot := "FECHAMENTO FRETES " + " - " + SubStr((dToC(aRetParam[1])),1,2) + " - " + SubStr((dToC(aRetParam[2])),1,2) + " / " +  Mes(aRetParam[1]) + "-" + AllTrim(Str(Ano(aRetParam[2])))
                    Endif
                    
                    oExcel:SetText(nRow, nCol, cNameRot)
                    oExcel:SetCellsFormatConfig(jFormatHead)
                    oExcel:SetFontConfig(jFontHeader)
                    nRow += 1
                    nCol := 1
                    //Printando Cabeçalho
                    For nX := 1 to Len(aHeaderRel)
                        oExcel:SetValue(nRow, nX, aHeaderRel[nX])
                    Next nX

                    while !(_cAliasG)->(EOF())
                        nRow +=1
                        nCol := 1
                        oExcel:SetFontConfig(jFontText)
                        oExcel:SetCellsFormatConfig(JFLeft)
                        oExcel:SetValue(nRow, nCol,   ALLTRIM((_cAliasG)->Transportadora ))
                        oExcel:SetValue(nRow, ++nCol, ALLTRIM((_cAliasG)->ENDFORN ))
                        oExcel:SetValue(nRow, ++nCol, ALLTRIM((_cAliasG)->FORNECEDOR ))
                        
                        oExcel:SetCellsFormatConfig(jFData)
                        oExcel:SetValue(nRow, ++nCol, sToD((_cAliasG)->ZFF_DATA))
                        oExcel:SetValue(nRow, ++nCol, sToD((_cAliasG)->ZFF_DTDESE))
                        
                        oExcel:SetCellsFormatConfig(JFLeft)
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_PLCVL )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_PLCC1 )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_PLCC2 )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_NUMMIN )

                        oExcel:SetCellsFormatConfig(jFNum)
                        oExcel:SetFontConfig(jFontText)
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_QTDE )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_KM )

                        oExcel:SetCellsFormatConfig(jFMoeda)
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_VLKM )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_VFRETE )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_ADICIO )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_PEDAGI )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_ICMSF )

                        oExcel:SetCellsFormatConfig(JFLeft)
                        oExcel:SetValue(nRow, ++nCol, ALLTRIM((_cAliasG)->ZFI_DOC + "-" + (_cAliasG)->ZFI_SERIE) )

                        oExcel:SetCellsFormatConfig(jFMoeda)
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->F1_VALBRUT )
                        oExcel:SetValue(nRow, ++nCol, (_cAliasG)->ZFF_VCOMP )

                        oExcel:SetCellsFormatConfig(JFLeft)
                        oExcel:SetValue(nRow, ++nCol, ALLTRIM(Posicione("DA4",1,FwXFilial("DA4")+(_cAliasG)->ZFF_MOTOR,'DA4_NOME')) )
                        
                        (_cAliasG)->(DBSKIP())
                    End

                    oExcel:ApplyAutoFilter(2,1,nRow,Len(aHeaderRel))
                    oExcel:SetCellsFormatConfig(jFormatTot)
                    nRow += 1
                    oExcel:MergeCells(nRow, 13, nRow, 15)
                    oExcel:SetFormula(nRow, 13, "=SUBTOTAL(9,M3:O"+AllTrim(cValToChar(nRow-1))+")" ) // Frete + Pedagio 
                    oExcel:SetFormula(nRow, 16, "=SUBTOTAL(9,P3:P"+AllTrim(cValToChar(nRow-1))+")" ) // ICMS
                    oExcel:SetFormula(nRow, 18, "=SUBTOTAL(9,R3:R"+AllTrim(cValToChar(nRow-1))+")" ) // CTE
                    oExcel:SetFormula(nRow, 19, "=SUBTOTAL(9,S3:S"+AllTrim(cValToChar(nRow-1))+")" ) // COMPLEMENTO

                    lRet := oExcel:toXlsx()

                    nRet := ShellExecute("open", SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx", "", "", 1)
     
                    //Se houver algum erro
                    If nRet <= 32
                        MsgStop("Não foi possível abrir o arquivo "+SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx"+ "!", "Atenção")
                    EndIf 

                    oExcel:DeActivate()
                   MSGALERT( "Arquivo gerado em: '" + SubStr(cArquivo,1,Len(cArquivo)-3) + "xlsx" , "Atenção" ) 
                EndIf
            else 
                Alerta("Não há dados para os parametros informados!")
            EndIf
        //Endif
        (_cAliasG)->(DbCloseArea())
    Endif

    If lower(cUserName) $ 'bernardo,ioliveira,atoshio,admin,administrador'
        Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
    EndIf
    
    RestArea(aArea)
    
    ConOut('Activate: ' + Time())
Return 

Static Function LoadQuery(aRetParam,_cAlias)
    //Local aArea := FWGetArea()
    //Local aRet  := {}
    Local cQry  := ""
    Local aDados := {}

    cQry := "select	ZFF.ZFF_FILIAL " + CRLF
    cQry += " 	,	ZFF.ZFF_CODIGO " + CRLF
    cQry += " 	,	ZFF.ZFF_PLCVL		            --Placa Cavalo " + CRLF
    cQry += " 	,	ZFF.ZFF_PLCC1		            --Placa Carreta 1 " + CRLF
    cQry += " 	,	ZFF.ZFF_PLCC2		            --Placa Carreta 2 " + CRLF
    cQry += " 	,	ZFF.ZFF_NUMMIN		            --Número da Minuta " + CRLF
    cQry += " 	,	ZFF.ZFF_MOTOR		            --Motorista " + CRLF
    cQry += " 	,	DA4.DA4_NOME		            --Nome do Motorista " + CRLF
    cQry += " 	,	ZFF.ZFF_ORIGEM		            --Transportadora " + CRLF
    cQry += " 	,	ZFF.ZFF_RLOJA		            --Loja da Transportadora " + CRLF
    cQry += " 	,	A22.A2_NOME	AS TRANSPORTADORA 	--Nome do Destinatário " + CRLF
    cQry += " 	,	ZFF.ZFF_FORNEC		            --Fornecedor " + CRLF
    cQry += " 	,	ZFF.ZFF_FLOJA		            --Loja do Fornecedor " + CRLF
    cQry += " 	,	A21.A2_NOME AS FORNECEDOR		--Nome do Fornecedor " + CRLF
    cQry += "   ,	TRIM(A21.A2_END) + ' - ' + TRIM(A21.A2_MUN) + ' - ' + TRIM(A21.A2_EST) ENDFORN -- Endereço do Fornecedor " + CRLF 
    cQry += " 	,	ZFF.ZFF_DESTIN		            --Destinatário " + CRLF
    cQry += " 	,	ZFF.ZFF_DLOJA		            --Loja do Destinatário " + CRLF
    cQry += " 	,	A1.A1_NOME AS DESTINATARIO      --Nome do Destinatário " + CRLF
    cQry += " 	,	ZFF.ZFF_DATA		            --Data do Embarque " + CRLF
    cQry += " 	,	ZFF.ZFF_HREMB		            --Hora do Embarque " + CRLF
    cQry += " 	,	ZFF.ZFF_DTDESE		            --Data do Desembarque " + CRLF
    cQry += " 	,	ZFF.ZFF_HRDESE		            --Hora do Desembarque " + CRLF
    cQry += " 	,	ZFF.ZFF_QTDE		            --Quantidade de Animais " + CRLF
    cQry += " 	,	ZFF.ZFF_MUN			            --Municipio de Partida " + CRLF
    cQry += " 	,	C2.CC2_MUN			             " + CRLF
    cQry += " 	,   ZFF.ZFF_KM			            --Total de KMs " + CRLF
    cQry += " 	,	ZFF.ZFF_PEDAGI		            --Pedagio " + CRLF
    cQry += " 	,	ZFF.ZFF_VLKM		            --Valor do KM " + CRLF
    cQry += " 	,	ZFF.ZFF_VCOMP		            --Complemento " + CRLF
    cQry += " 	,	ZFF.ZFF_ICMSF		            --ICMS " + CRLF
    cQry += " 	,	ZFF.ZFF_VFRETE		            --Valor do Frete " + CRLF
    cQry += " 	,	ZFI.ZFI_DOC		                --DOC CTE " + CRLF
    cQry += " 	,	ZFI.ZFI_SERIE		            --SERIE CTE " + CRLF
    cQry += " 	,	SF1.F1_VALBRUT		            --Valor CTE " + CRLF
    cQry += " 	,	ZFF.ZFF_ADICIO		            --Valor Adicional " + CRLF
    cQry += " 	,	ZFI.ZFI_FILDOC		            --FILIAL DOC " + CRLF
    cQry += " 	,	ZFF.R_E_C_N_O_		            --RECNO ZFF " + CRLF
    cQry += " FROM "+RetSqlName("ZFF")+" ZFF " + CRLF  
    cQry += "  LEFT JOIN "+RetSqlName("DA4")+" DA4 ON ZFF.ZFF_MOTOR = DA4.DA4_COD " + CRLF
    cQry += " AND DA4.D_E_L_E_T_ = '' " + CRLF
    cQry += "  LEFT JOIN "+RetSqlName("SA2")+" A21 ON A21.A2_COD = ZFF.ZFF_FORNEC " + CRLF
    cQry += " AND A21.A2_LOJA = ZFF.ZFF_FLOJA " + CRLF
    cQry += " AND A21.D_E_L_E_T_ = '' " + CRLF
    cQry += "  LEFT JOIN "+RetSqlName("SA2")+" A22 ON A22.A2_COD = ZFF.ZFF_ORIGEM " + CRLF
    cQry += " AND A22.A2_LOJA = ZFF.ZFF_RLOJA " + CRLF
    cQry += " AND A22.D_E_L_E_T_ = '' " + CRLF
    cQry += "  LEFT JOIN "+RetSqlName("SA1")+" A1 ON A1.A1_COD = ZFF.ZFF_DESTIN " + CRLF
    cQry += " AND A1.A1_LOJA = ZFF.ZFF_DLOJA " + CRLF
    cQry += " AND A1.D_E_L_E_T_ = '' " + CRLF
    cQry += "  LEFT JOIN "+RetSqlName("CC2")+" C2 ON C2.CC2_CODMUN = ZFF.ZFF_MUN " + CRLF
    cQry += " AND C2.CC2_EST = ZFF.ZFF_EST " + CRLF
    cQry += " AND C2.D_E_L_E_T_ = '' " + CRLF
    cQry += "  LEFT JOIN "+RetSqlName("ZFI")+" ZFI ON ZFI.ZFI_FILIAL = ZFF.ZFF_FILIAL " + CRLF
    cQry += " AND ZFI.ZFI_CODIGO = ZFF.ZFF_CODIGO " + CRLF
    cQry += " AND ZFI.D_E_L_E_T_ = '' " + CRLF
    cQry += "  LEFT JOIN "+RetSqlName("SF1")+" SF1 ON ZFI.ZFI_FILDOC = SF1.F1_FILIAL 
    cQry += " AND SF1.F1_FORNECE = ZFI.ZFI_FORNEC " + CRLF
    cQry += " AND SF1.F1_LOJA = ZFI.ZFI_LOJA " + CRLF
    cQry += " AND SF1.F1_DOC = ZFI.ZFI_DOC " + CRLF
    cQry += " AND SF1.D_E_L_E_T_ = '' " + CRLF
    cQry += " WHERE ZFF.ZFF_DTDESE BETWEEN '"+dToS(aRetParam[1])+"' AND '"+dToS(aRetParam[2])+"'" + CRLF 
    if !EMPTY( aRetParam[3] ) .and. !EMPTY( aRetParam[4] )
        cQry += " AND ZFF.ZFF_ORIGEM BETWEEN '"+aRetParam[3]+"' AND '"+aRetParam[4]+"' " + CRLF 
    endif
    if !EMPTY( aRetParam[5] ) .and. !EMPTY( aRetParam[6] )
        cQry += " AND ZFF.ZFF_FORNEC BETWEEN '"+aRetParam[5]+"' AND '"+aRetParam[6]+"'" + CRLF 
    endif
    cQry += " AND ZFF.D_E_L_E_T_ = '' " + CRLF
    cQry += " ORDER BY ZFF_ORIGEM, ZFF_CODIGO " + CRLF
    
    memowrite("C:\TOTVS_RELATORIOS\VACOMR13.sql", cQry)
    
    MpSysOpenQuery(cQry, _cAlias)

    While !(_cAliasG)->(EOF())
        aAdd(aDados,{   {"TRANSPORTADORA"   ,AllTrim((_cAliasG)->Transportadora)},;
                        {"ENDFORN"          ,AllTrim((_cAliasG)->ENDFORN)},;
                        {"ZFF_CODIGO"       ,AllTrim((_cAliasG)->ZFF_CODIGO)},;
                        {"FORNECEDOR"       ,AllTrim((_cAliasG)->FORNECEDOR)},;
                        {"ZFF_ORIGEM"       ,AllTrim((_cAliasG)->ZFF_ORIGEM)},;
                        {"ZFF_RLOJA"        ,AllTrim((_cAliasG)->ZFF_RLOJA)},;
                        {"ZFF_FORNEC"       ,AllTrim((_cAliasG)->ZFF_FORNEC)},;
                        {"FORNECEDOR"       ,AllTrim((_cAliasG)->FORNECEDOR)},;
                        {"ZFF_FLOJA"        ,AllTrim((_cAliasG)->ZFF_FLOJA)},;
                        {"ZFF_DESTIN"       ,AllTrim((_cAliasG)->ZFF_DESTIN)},;
                        {"ZFF_DLOJA"        ,AllTrim((_cAliasG)->ZFF_DLOJA)},;
                        {"DESTINATARIO"     ,AllTrim((_cAliasG)->DESTINATARIO)},;
                        {"ZFF_DATA"         ,sToD((_cAliasG)->ZFF_DATA)},;
                        {"ZFF_DTDESE"       ,sToD((_cAliasG)->ZFF_DTDESE)},;
                        {"ZFF_HREMB"        ,(_cAliasG)->ZFF_HREMB},;
                        {"ZFF_HRDESE"       ,(_cAliasG)->ZFF_HRDESE},;
                        {"ZFF_MUN"          ,AllTrim((_cAliasG)->ZFF_MUN)},;
                        {"CC2_MUN"          ,AllTrim((_cAliasG)->CC2_MUN)},;
                        {"ZFF_PLCVL"        ,AllTrim((_cAliasG)->ZFF_PLCVL)},;
                        {"ZFF_PLCC1"        ,AllTrim((_cAliasG)->ZFF_PLCC1)},;
                        {"ZFF_PLCC2"        ,AllTrim((_cAliasG)->ZFF_PLCC2)},;
                        {"ZFF_NUMMIN"       ,AllTrim((_cAliasG)->ZFF_NUMMIN)},;
                        {"ZFF_QTDE"         ,(_cAliasG)->ZFF_QTDE},;
                        {"ZFF_KM"           ,(_cAliasG)->ZFF_KM},;
                        {"ZFF_VLKM"         ,(_cAliasG)->ZFF_VLKM},;
                        {"ZFF_VFRETE"       ,(_cAliasG)->ZFF_VFRETE},;
                        {"ZFF_ADICIO"       ,(_cAliasG)->ZFF_ADICIO},;
                        {"ZFF_PEDAGI"       ,(_cAliasG)->ZFF_PEDAGI},;
                        {"ZFF_ICMSF"        ,(_cAliasG)->ZFF_ICMSF},;
                        {"ZFI_FILDOC"       ,SubStr((_cAliasG)->ZFI_FILDOC,6,2)},;
                        {"ZFI_DOC"          ,AllTrim((_cAliasG)->ZFI_DOC + "-" + (_cAliasG)->ZFI_SERIE)},;
                        {"F1_VALBRUT"       ,(_cAliasG)->F1_VALBRUT},;
                        {"ZFF_VCOMP"        ,(_cAliasG)->ZFF_VCOMP},;
                        {"DA4_NOME"         ,AllTrim((_cAliasG)->DA4_NOME)}})

        (_cAliasG)->(DBSKIP())
    End
Return aDados
//Return !(_cAlias)->(Eof())

Static Function DefinirFormatacao()
    Local cCVerde       := '00A85A'
    Local cCCinza       := "A0A0A0"
    Local cCAmarelo     := "FFFF00"

    jFontHeader := FwXlsxPrinterConfig():MakeFont()
    jFontHeader['font'] := FwPrinterFont():Calibri()
    jFontHeader['size'] := 12
    jFontHeader['bold'] := .T.

    jFontTitulo := FwXlsxPrinterConfig():MakeFont()
    jFontTitulo['font'] := FwPrinterFont():Calibri()
    jFontTitulo['size'] := 14
    jFontTitulo['bold'] := .T.
    jFontTitulo['underline'] := .T.

    jFontText := FwXlsxPrinterConfig():MakeFont()
    jFontText['font'] := FwPrinterFont():Calibri()
    jFontText['size'] := 12
    jFontText['italic'] := .F.

    JFLeft := FwXlsxPrinterConfig():MakeFormat()
    JFLeft['hor_align']        := oCellHorAlign:Left()
    JFLeft['vert_align']       := oCellVertAlign:Center()

    JFRight := FwXlsxPrinterConfig():MakeFormat()
    JFRight['hor_align']        := oCellHorAlign:RIGHT()
    JFRight['vert_align']       := oCellVertAlign:Center()
    
    jFData := FwXlsxPrinterConfig():MakeFormat()
    jFData['custom_format']    := "dd/mm/yyyy"
    jFData['hor_align']        := oCellHorAlign:Left()
    jFData['vert_align']       := oCellVertAlign:Center()

    jFormatTit := FwXlsxPrinterConfig():MakeFormat()
    jFormatTit['hor_align']         := oCellHorAlign:Center()
    jFormatTit['vert_align']        := oCellVertAlign:Center()
    jFormatTit['background_color']  := cCVerde

    jFormatGD := FwXlsxPrinterConfig():MakeFormat()
    jFormatGD['hor_align']         := oCellHorAlign:Center()
    jFormatGD['vert_align']        := oCellVertAlign:Center()
    jFormatGD['background_color']  := cCAmarelo
    
    jFormatTot := FwXlsxPrinterConfig():MakeFormat()
    jFormatTot['custom_format']     := "\R$ ###,##0.00"
    jFormatTot['hor_align']         := oCellHorAlign:Center()
    jFormatTot['vert_align']        := oCellVertAlign:Center()
    jFormatTot['background_color']  := cCCinza

    jFormatHead := FwXlsxPrinterConfig():MakeFormat()
    jFormatHead['hor_align']         := oCellHorAlign:LEFT()
    jFormatHead['vert_align']        := oCellVertAlign:Center()
    jFormatHead['background_color']  := "A0A0A0" //amarelo

    jFMoeda := FwXlsxPrinterConfig():MakeFormat()
    jFMoeda['custom_format']    := "\R$ ###,##0.00"
    jFMoeda['hor_align']        := oCellHorAlign:RIGHT()
    jFMoeda['vert_align']       := oCellVertAlign:Center()

    jFNum := FwXlsxPrinterConfig():MakeFormat()
    jFNum['hor_align']        := oCellHorAlign:Left()
    jFNum['vert_align']       := oCellVertAlign:Center()

    // Bordas para o header
    jNoBorder := FwXlsxPrinterConfig():MakeBorder()
    jNoBorder['top']    := .F.
    jNoBorder['bottom'] := .F.
    jNoBorder['left']   := .F.
    jNoBorder['right']  := .F.
    jNoBorder['border_color'] := "000000"
    jNoBorder['style'] := FwXlsxBorderStyle():None()

    jBHeaderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderLeft['top']    := .T.
    jBHeaderLeft['bottom'] := .F.
    jBHeaderLeft['left']   := .T.
    jBHeaderLeft['right']  := .F.
    jBHeaderLeft['border_color'] := "000000"
    jBHeaderLeft['style'] := FwXlsxBorderStyle():Thick()

    jBHeaderRight := FwXlsxPrinterConfig():MakeBorder()
    jBHeaderRight['top']    := .T.
    jBHeaderRight['bottom'] := .F.
    jBHeaderRight['left']   := .F.
    jBHeaderRight['right']  := .T.
    jBHeaderRight['border_color'] := "000000"
    jBHeaderRight['style'] := FwXlsxBorderStyle():Thick()
    
    jBottomLeft := FwXlsxPrinterConfig():MakeBorder()
    jBottomLeft['top']    := .F.
    jBottomLeft['bottom'] := .T.
    jBottomLeft['left']   := .T.
    jBottomLeft['right']  := .F.
    jBottomLeft['border_color'] := "000000"
    jBottomLeft['style'] := FwXlsxBorderStyle():Thick()

    jBottomRight := FwXlsxPrinterConfig():MakeBorder()
    jBottomRight['top']    := .F.
    jBottomRight['bottom'] := .T.
    jBottomRight['left']   := .F.
    jBottomRight['right']  := .T.
    jBottomRight['border_color'] := "000000"
    jBottomRight['style'] := FwXlsxBorderStyle():Thick()

    jBorderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBorderLeft['left'] := .T.
    jBorderLeft['border_color'] := "000000"
    jBorderLeft['style'] := FwXlsxBorderStyle():Thick()
    
    jBorderCenter := FwXlsxPrinterConfig():MakeBorder()
    jBorderCenter['left'] := .T.
    jBorderCenter['right'] := .T.
    jBorderCenter['border_color'] := "000000"
    jBorderCenter['style'] := FwXlsxBorderStyle():Thick()
    
    jBorderRight := FwXlsxPrinterConfig():MakeBorder()
    jBorderRight['right'] := .T.
    jBorderRight['border_color'] := "000000"
    jBorderRight['style'] := FwXlsxBorderStyle():Thick()

Return 

User Function xParamBox()
Local aRet      := {}
Local aParamBox := {}
Local aCombo    := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Local i := 0

Private cCadastro := "xParambox"

// --------------------------------------------------------------
// Abaixo está a montagem do vetor que será passado para a função
// --------------------------------------------------------------

//aAdd(aParamBox,{1,"Produto",Space(15),"","","SB1","",0,.F.}) // Tipo caractere

//aAdd(aParamBox,{1,"Valor",0,"@E 9,999.99","mv_par02>0","","",20,.F.}) // Tipo numérico

aAdd(aParamBox,{1,"Data de: "  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
aAdd(aParamBox,{2,"Data até: " ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
// Tipo 1 -> MsGet()
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-Consulta F3
//           [7]-String contendo a validacao When
//           [8]-Tamanho do MsGet
//           [9]-Flag .T./.F. Parametro Obrigatorio ?

//aAdd(aParamBox,{2,"Informe o mês",1,aCombo,50,"",.F.})
// Tipo 2 -> Combo
//           [2]-Descricao
//           [3]-Numerico contendo a opcao inicial do combo
//           [4]-Array contendo as opcoes do Combo
//           [5]-Tamanho do Combo
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?
// Cuidado, há um problema nesta opção quando selecionado a 1ª opção.

//aAdd(aParamBox,{3,"Mostra deletados",1,{"Sim","Não"},50,"",.F.})
// Tipo 3 -> Radio
//           [2]-Descricao
//           [3]-Numerico contendo a opcao inicial do Radio
//           [4]-Array contendo as opcoes do Radio
//           [5]-Tamanho do Radio
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?

//aAdd(aParamBox,{4,"Marca todos ?",.F.,"Marque todos se necessário for.",90,"",.F.})
// Tipo 4 -> Say + CheckBox
//           [2]-Descricao
//           [3]-Indicador Logico contendo o inicial do Check
//           [4]-Texto do CheckBox
//           [5]-Tamanho do Radio
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?

//aAdd(aParamBox,{5,"Marca todos ?",.F.,50,"",.F.})
// Tipo 5 -> Somente CheckBox
//           [2]-Descricao
//           [3]-Indicador Logico contendo o inicial do Check
//           [4]-Tamanho do Radio
//           [5]-Validacao
//           [6]-Flag .T./.F. Parametro Obrigatorio ?

//aAdd(aParamBox,{6,"Buscar arquivo",Space(50),"","","",50,.F.,"Todos os arquivos (*.*) |*.*"})
// Tipo 6 -> File
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-String contendo a validacao When
//           [7]-Tamanho do MsGet
//           [8]-Flag .T./.F. Parametro Obrigatorio ?
//           [9]-Texto contendo os tipos de arquivo, exemplo: "Arquivos .CSV |*.CSV"
//           [10]-Diretorio inicial do cGetFile
//           [11]-Número relativo a visualização, podendo ser por diretório ou por arquivo (0,1,2,4,8,16,32,64,128)

//aAdd(aParamBox,{7,"Monte o filtro","SX5","X5_FILIAL==xFilial('SX5')"})
// Tipo 7 -> Montagem de expressao de filtro
//           [2]-Descricao
//           [3]-Alias da tabela
//           [4]-Filtro inicial

//aAdd(aParamBox,{8,"Digite a senha",Space(15),"","","","",80,.F.})
// Tipo 8 -> MsGet Password
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-Consulta F3
//           [7]-String contendo a validacao When
//           [8]-Tamanho do MsGet
//           [9]-Flag .T./.F. Parametro Obrigatorio ?

//aAdd(aParamBox,{9,"Texto aleatório, apenas demonstrativo.",150,7,.T.})
// Tipo 9 -> Somente uma mensagem, formato de um título
//           [2]-Texto descritivo
//           [3]-Largura do texto
//           [4]-Altura do texto
//           [5]-Valor lógico sendo: .T. => fonte tipo VERDANA e .F. => fonte tipo ARIAL

aAdd(aParamBox,{10,"Fornecedor",Space(6),"SA2",40,"C",6,".T."})
// Tipo 10 -> Range de busca
//            [2] = Título
//            [3] = Inicializador padrão
//            [4] = Consulta F3
//            [5] = Tamanho do GET
//            [6] = Tipo do dado, somente (C=caractere e D=data)
//            [7] = Tamanho do espaço
//            [8] = Condição When

//aAdd(aParamBox,{11,"Informe o motivo","",".T.",".T.",.T.})
// Tipo 11 -> MultiGet (Memo)
//            [2] = Descrição
//            [3] = Inicializador padrão
//            [4] = Validação
//            [5] = When
//            [6] = Campo com preenchimento obrigatório .T.=Sim .F.=Não (incluir a validação na função ParamOk)

// Parametros da função Parambox()
// -------------------------------
// 1 - < aParametros > - Vetor com as configurações
// 2 - < cTitle >      - Título da janela
// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
// 4 - < bOk >         - Code block para validar o botão Ok
// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
// 6 - < lCentered >   - Centralizar a janela
// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
//10 - < cLoad >       - Nome do perfil se caso for carregar
//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
//12 - < lUserSave >   - Configuração por usuário

// Caso alguns parâmetros para a função não seja passada será considerado DEFAULT as seguintes abaixo:
// DEFAULT bOk   := {|| (.T.)}
// DEFAULT aButtons := {}
// DEFAULT lCentered := .T.
// DEFAULT nPosX  := 0
// DEFAULT nPosY  := 0
// DEFAULT cLoad     := ProcName(1)
// DEFAULT lCanSave := .T.
// DEFAULT lUserSave := .F.

    If ParamBox(aParamBox,"Teste Parâmetros...",@aRet)
    For i:=1 To Len(aRet)
        MsgInfo(aRet[i],"Opção escolhida")
    Next
    Endif
Return
