#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa040.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA040()
Constulta de rastreabilidade de sementes
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040()

    Local oBrowse as object
    Local aFields as array
    Local cMovsAx as char
    // variáveis Private utilizadas para abertura da tela de dados do lote
    Private cTm	as char
    Private cMovsai as char

    cMovsAx := Alltrim(GetMv("MV_AGRSD3S"))
    cMovsai	:= cMovsAx+Space(Len(SF5->F5_CODIGO)-Len(cMovsAx))

    cTm := GetMv("MV_AGRTMPS")

    aFields := {'NP9_LOTE' , 'NP9_CODSAF', 'NP9_PROD'  , 'NP9_PRDDES', ;
                'NP9_CTRDES', 'NP9_CTVAR' , 'NP9_CTVDES', 'NP9_PENE', 'NP9_PENDES' , 'NP9_UM',;
                'NP9_QUANT' , 'NP9_DTVAL' , 'NP9_SECA'  , 'NP9_TRATO' ,;
                'NP9_LOCAL'}

    If Empty(FWSX3Util():GetFieldType( "NJJ_MOEGA" )) .OR. !TableInDic('NL5') //PROTEÇÃO DE FONTE, liberado adicionario oficial na P12.1.33
        // necessário a atualização do sistema para a expedição mais recente
        MsgNextRel()
    Else
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias('NP9')
        oBrowse:SetDescription(STR0001)// rastreabilidade de sementes
        oBrowse:AddButton(STR0002,{||UBS040VIS()},,2)// visualizar
        oBrowse:AddButton(STR0019,{||AGR840PRE(2)},,2)// dados do lote
        oBrowse:SetOnlyFields(aFields)

        oBrowse:AddLegend("NP9_STATUS = '1'", 'RED', STR0004)
        oBrowse:AddLegend("NP9_STATUS = '2'", 'GREEN', STR0005)
        oBrowse:AddLegend("NP9_STATUS = '3'", 'BLACK', STR0006)

        oBrowse:Activate()
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} UBS040VIS()
Função de construção das pastas de apresentação das informações
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBS040VIS()

    Local oDialog as object
    Local oFolder as object
    Local oButton as object
    Local oHeader as object
    
    oSize := FwDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 40, .T., .T. ) // Adiciona enchoice
    oSize:AddObject( "FOLDER",100, 100, .T., .T. ) // Adiciona Folder          
    oSize:lProp     := .T.
    oSize:lLateral     := .F.  // Calculo vertical     
    oSize:aMargins  := { 2, 2, 2, 2 }
    oSize:Process()
	
    // Rastreabilidade de Sementes
    oDialog := TDialog():New(0,0,oSize:aWindSize[3] ,oSize:aWindSize[4],STR0001,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

    cAlias := LoadLot()

    oHeader := LoadHeader(oDialog, cAlias, oSize)

   // oFolder := TFolder():New( 100,0,,,oDialog,,,,.T.,,aSize[3],aSize[4])
    oFolder:=TFolder():New( oSize:GetDimension("FOLDER","LININI"), ;
                            oSize:GetDimension("FOLDER","COLINI"),,,oDialog,,,,.T.,.T., ;
                            oSize:GetDimension("FOLDER","XSIZE"), ;
                            oSize:GetDimension("FOLDER","YSIZE") )

    oFolder := LoadFolders(oFolder)
    oFolder:nClrPane := CLR_WHITE
    oFolder:ShowPage(1)

    // Sair
   oButton := TButton():New(1,2, "Fechar", oDialog, {|| oDialog:End() }, 40, 15)

    oDialog:Activate()

    (cAlias)->(DBCloseArea())

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFolders(oFolder)
Função utilizada para chamar as funções de construção de cada folder
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function LoadFolders(oFolder)

    Local nX as numeric
    Local nTotal as numeric
    Local cFunc as char

    nTotal := 23

    cFunc := 'UBSA040A'

    // Ex.: aqui chama todas as funções de construção de pastas
    // oFolder := UBSA040A(oFolder)
    // oFolder := UBSA040B(oFolder)
    // feito assim durante desenvolvimento para evitar problemas de locks de fontes, alterar depois de concluído
    // itera sobre todas as função de A a Z
    For nX := 1 To nTotal

        If FindFunction(cFunc)
            oFolder := &cFunc.(oFolder)
        EndIf

        cFunc := Soma1(cFunc)
    Next

    If ExistBlock('UB040FOL')
        oFolder := ExecBlock('UB040FOL', .F., .F., {oFolder})
    EndIf

Return oFolder
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadHeader(oParent, cAlias, aSize)
Carrega campos do cabeçalho
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function LoadHeader(oParent, cAlias, oSize)

    Local aFields as array
    Local nX as numeric
    Local nRow as numeric
    Local nColumn as numeric
    Local nFieldSize as numeric
    Local bCodeBlock as codeblock
    Local oGet as object
    Local nWGroup := oSize:GetDimension("ENCHOICE","XSIZE") - 20

    aFields := {'NP9_LOTE'  , 'NP9_CODSAF', 'NP9_PROD'  , 'NP9_PRDDES', ;
        'NP9_CTRDES', 'NP9_CTVAR' , 'NP9_CTVDES', 'NP9_PENE', 'NP9_PENDES' , 'NP9_UM',;
        'NP9_QUANT' , 'NP9_DTVAL' , 'NP9_SECA'  , 'NP9_TRATO' ,;
        'NP9_LOCAL'}

    oPanel := TScrollBox():New(oParent ,oSize:GetDimension("ENCHOICE","LININI"), oSize:GetDimension("ENCHOICE","COLINI"), oSize:GetDimension("ENCHOICE","YSIZE"), oSize:GetDimension("ENCHOICE","XSIZE"),.T.,.T.,.T.)
    
    oGroupLot := TGroup():New(01, 05, 70 , nWGroup,IIF(NP9->NP9_TRATO == '1', STR0035, STR0034),oPanel,CLR_BLACK,CLR_WHITE,.T.)
    oGroupTSI := TGroup():New(71, 05, 140, nWGroup,IIF(NP9->NP9_TRATO == '1', STR0034, STR0035),oPanel,CLR_BLACK,CLR_WHITE,.T.)

    nRow := 10
    nColumn := 10
    //lote
    For nX := 1 To Len(aFields)

        nFieldSize := (TamSX3(aFields[nX])[1] + 10) * 2
        If aFields[nX] $ 'NP9_SECA,NP9_TRATO'
            nFieldSize := 100
        EndIf

        If nColumn + nFieldSize > nWGroup
            nColumn := 10
            nRow += 30
        EndIf

        bCodeBlock := &('{||NP9->'+aFields[nX]+'}')

        If aFields[nX] $ 'NP9_SECA,NP9_TRATO'
            oCombo := TComboBox():New(nRow, nColumn, bCodeBlock,{'1='+STR0011, '2='+STR0012},nFieldSize,025,oGroupLot,,{|| .T.},,,,.T.,,,,{||.F.},,,,,,FWX3Titulo(aFields[nX]), 1)
        Else
            oGet := TGet():New( nRow, nColumn, bCodeBlock, oGroupLot, nFieldSize,015,PesqPict('NP9',aFields[nX]),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
        EndIf
        nColumn += nFieldSize + 10
    Next

    nRow += 40
    nColumn := 10
    //TSI
    For nX := 3 To Len(aFields)

        nFieldSize := (TamSX3(aFields[nX])[1] + 10) * 2
        If aFields[nX] $ 'NP9_SECA,NP9_TRATO'
            nFieldSize := 100
        EndIf

        If nColumn + nFieldSize > nWGroup
            nColumn := 10
            nRow += 30
        EndIf

        If aFields[nX] $ 'NP9_DTVAL'
            bCodeBlock := &('{||SToD((cAlias)->'+aFields[nX]+')}')
        Else
            bCodeBlock := &('{||(cAlias)->'+aFields[nX]+'}')
        EndIf

        If aFields[nX] $ 'NP9_SECA,NP9_TRATO'
            oCombo := TComboBox():New(nRow, nColumn,bCodeBlock,{'1='+STR0011, '2='+STR0012},nFieldSize,025,oGroupTSI,,{|| .T.},,,,.T.,,,,{||.F.},,,,,,FWX3Titulo(aFields[nX]), 1)
        Else
            oGet := TGet():New( nRow, nColumn,bCodeBlock,oGroupTSI,nFieldSize,015,PesqPict('NP9',aFields[nX]),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,,,,FWX3Titulo(aFields[nX]), 1)
        EndIf
        nColumn += nFieldSize + 10
    Next

Return oParent
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadLot()
Carrega lote TSI ou de sementes dependendo do selecionado
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function LoadLot()

    Local cAlias as char
    Local cTrat as char

    cAlias := GetNextAlias()

    If NP9->NP9_TRATO == '1'
        cTrat := '2'
    Else
        cTrat := '1'
    EndIf

    BeginSql Alias cAlias

        SELECT NP9_LOTE
            ,COALESCE(NP9.NP9_CODSAF, '') AS NP9_CODSAF
            ,COALESCE(NP9.NP9_PROD, '') AS NP9_PROD
            ,COALESCE(SB1.B1_DESC, '') AS NP9_PRDDES
            ,COALESCE(NP3.NP3_DESCRI, '') AS NP9_CTRDES
            ,COALESCE(NP9.NP9_CTVAR, '') AS NP9_CTVAR
            ,COALESCE(NP4.NP4_DESCRI, '') AS NP9_CTVDES
            ,COALESCE(NP9.NP9_PENE, '') AS NP9_PENE
            ,COALESCE(NP7.NP7_DESCRI, '') AS NP9_PENDES
            ,COALESCE(NP9.NP9_UM, '') AS NP9_UM
            ,COALESCE(NP9.NP9_QUANT, 0) AS NP9_QUANT
            ,COALESCE(NP9.NP9_DTVAL, '') AS NP9_DTVAL
            ,COALESCE(NP9.NP9_SECA, '') AS NP9_SECA
            ,COALESCE(NP9.NP9_TRATO, '') AS NP9_TRATO
            ,COALESCE(NP9.NP9_LOCAL, '') AS NP9_LOCAL
        FROM %table:NP9% NP9

        LEFT JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %Exp:FWxFilial('SB1')%
            AND SB1.B1_COD = NP9.NP9_PROD
            AND SB1.D_E_L_E_T_ = NP9.D_E_L_E_T_

        LEFT JOIN %table:NP3% NP3 ON NP3.NP3_FILIAL = %Exp:FWxFilial('NP3')%
            AND NP3.NP3_CODIGO = NP9.NP9_CULTRA
            AND NP3.D_E_L_E_T_ = NP9.D_E_L_E_T_

        LEFT JOIN %table:NP4% NP4 ON NP4.NP4_FILIAL = %Exp:FWxFilial('NP4')%
            AND NP4.NP4_CODIGO = NP9.NP9_CTVAR
            AND NP4.D_E_L_E_T_ = NP9.D_E_L_E_T_


        LEFT JOIN %table:NP7% NP7 ON NP7.NP7_FILIAL = %Exp:FWxFilial('NP7')%
            AND NP7.NP7_CODIGO = NP9.NP9_PENE
            AND NP7.D_E_L_E_T_ = NP9.D_E_L_E_T_

        WHERE NP9.%notDel%
            AND NP9.NP9_FILIAL = %Exp:NP9->NP9_FILIAL%
            AND NP9.NP9_LOTE = %Exp:NP9->NP9_LOTE%
            AND NP9.NP9_TRATO = %Exp:cTrat%
    EndSql

Return cAlias
