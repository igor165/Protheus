#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa040.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA040D(oFolder)
Romaneio e Ordens de colheita
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040D(oFolder)

    Local aTable as array
    Local oDialog as object

    aTable := LoadHarvests()

    cQuery := GetDataQuery(UBSA040INS('UBSA40DQRY'), aTable[2])//query de insumos e nome real no DB da temp table de colheitas

    oFolder:AddItem(STR0018, .T.)
    oDialog := oFolder:aDialogs[Len(oFolder:aDialogs)]

    // ponto de entrada para editar a aba de romaneios
    // são enviados o dialog da aba e a query de insumos utilizada na aba de insumos
    
    If ExistBlock('UB040ROM')
        ExecBlock('UB040ROM', .F., .F., {oDialog, UBSA040INS('UBSA40DQRY')})
    Else
        SetupBrw(cQuery, oDialog)
    EndIf

Return oFolder
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadHarvests()
Carrega a tabela temporária de colheitas, caso a integração EAI esteja ativada
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function LoadHarvests()

    Local cAliasHAR as char

    cAliasHAR := GetNextAlias()
    cRealName := CreateTT(cAliasHAR)

    // foi utilizada a mesma forma que é realizada a validação de ordens de colheita no OGA250/251
    If FWHasEAI( "AGRA530", .T., .F., .T. )
        AGRA530ODC(.F., @cAliasHAR)

        DBSelectArea(cAliasHAR)
        (cAliasHAR)->(DbSetOrder(1))
    EndIf

Return {cAliasHAR, cRealName}
//-------------------------------------------------------------------
/*/{Protheus.doc} SetupBrw(cQuery, oParent)
Monta browses da seção inferior da tela de insumos (romaneios e itens de classificação)
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function SetupBrw(cQuery, oParent)


    Local oLayer as object
    Local oRomBrw as object
    Local oClsBrw as object
    Local oColUP as object
    Local oColDown as object
    Local oRelation as object

    oLayer := FwLayer():New()
	oLayer:Init(oParent, .F.)

    oLayer:AddLine('LINEUP', 50, .F. )
    oLayer:AddLine('LINEDOWN', 50, .F. )

    oLayer:AddCollumn('COLUP' , 100, .T., 'LINEUP')
    oLayer:AddCollumn('COLDOWN' , 100, .T., 'LINEDOWN')

    oColUP := oLayer:GetColPanel('COLUP', 'LINEUP')
    oColDown := oLayer:GetColPanel('COLDOWN', 'LINEDOWN') 

    oRomBrw := SetupRomBrw(cQuery, oColUP)

    oClsBrw := SetupClsBrw(oColDown)

    oRelation := FWBrwRelation():New() 
    oRelation:AddRelation( oRomBrw, oClsBrw, {{ 'NJK_FILIAL', 'NJJ_FILIAL' }, { 'NJK_CODROM' , 'NJJ_CODROM' }}) 
    oRelation:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetColumns()
Retorna colunas do browse
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetColumns()

    Local aCols as array
    Local aColsHarv as array

    aColsRom := GetRomCols()

    aCols := {}

    AEval(aColsRom, {|x| Aadd(aCols, x)})
    // só precisa das colunas de colheita caso exista integração com PIMS
    If FWHasEAI( "AGRA530", .T., .F., .T. )
        aColsHarv := GetHarvCols()
        AEval(aColsHarv, {|x| Aadd(aCols, x)})
    EndIf

Return aCols
//-------------------------------------------------------------------
/*/{Protheus.doc} GetRomCols()
Retonar colunas do romaneio para o browse
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetRomCols()

    Local aStruct as array
    Local aColumns as array
    Local oColumn as object
    Local nX as numeric

    aColumns := {}
    // filial, nr do romaneio, data 1a pesagem, hora 1a pesagem, data 2a pesagem, hora 2a pesagem
    // peso líquido
    // produto, descricao do produto

    aStruct := {'NJJ_FILIAL', 'NJJ_CODROM', 'NJJ_DATPS1', 'NJJ_HORPS1',;
                'NJJ_DATPS2', 'NJJ_HORPS2', 'NJJ_PSLIQU', 'NJJ_CODPRO',;
                'B1_DESC'   , 'NJJ_LOCAL' , 'NNR_DESCRI', 'NJJ_MOEGA' ,;
                'NL5_DESCRI', 'NJJ_TIPO'  , 'NJJ_DSTIPO'}

    For nX := 1 To Len(aStruct)

        oColumn := FWBrwColumn():New()
        
        If aStruct[nX] $ 'NJJ_DATPS1,NJJ_DATPS2'
            oColumn:SetType('D')
            oColumn:SetData(&("{||SToD("+aStruct[nX]+")}"))
        Else
            oColumn:SetType(TamSx3(aStruct[nX])[3])
            oColumn:SetData(&("{||"+aStruct[nX]+"}"))
        EndIf

        oColumn:SetTitle(FWX3Titulo(aStruct[nX]))
        oColumn:SetSize(TamSx3(aStruct[nX])[1])

        Aadd(aColumns, oColumn)
    Next

Return aColumns
//-------------------------------------------------------------------
/*/{Protheus.doc} GetHarvCols()
Retorna colunas da colheita para o browse
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetHarvCols()

    Local aStruct as array
    Local aColumns as array
    Local oColumn as object
    Local nX as numeric
    Local cFields as char

    aStruct := AGRA530CLT()
    aColumns := {}

    /*
        Nr ordem colheita
        Data Ordem
        Codigo variedade
        Descricao variedade
        Codigo Sistema Colheita
        Descrição sistema colheita
        codigo da fazenda descrição da fazenda
        codigo do setor
        descrição do setor
        codigo do talhao
        Área do talhão
    */

    cFields := 'ORDCLT,DATORD,CODVAR,DESVAR,CODSIS,DESSIS,CODFAZ,DESFAZ,CODSET,DESSET,CODTAL,ARETAL'

    For nX := 1 to Len(aStruct)
        If (aStruct[nX][1] $ cFields)

            oColumn := FWBrwColumn():New()

            oColumn:SetTitle(aStruct[nX][5])
            oColumn:SetPicture(aStruct[nX][6])

            If 'DATORD' == aStruct[nX][1]
                oColumn:SetType('D')
                oColumn:SetData(&("{||SToD("+aStruct[nX][1]+")}"))
            Else
                oColumn:SetType(aStruct[nX][2])
                oColumn:SetData(&("{||"+aStruct[nX][1]+"}"))
            EndIf

            oColumn:SetType(aStruct[nX][2])
            oColumn:SetSize(aStruct[nX][3])
            oColumn:SetReadVar(aStruct[nX][1])

            Aadd(aColumns, oColumn)
        EndIf
    Next nX

Return aColumns
//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataQuery(cQueryINS, cTableHAR)
Retorna query de dados que será utilizada no browse
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetDataQuery(cQueryINS, cTableHAR)

    Local cQuery as char
    Local cFieldsHAR as char
    Local cJoinHAR as char
    //só precisa realizar join com a tabela de colheita caso exista integração
    If FWHasEAI( "AGRA530", .T., .F., .T. )
        cFieldsHAR := GetHARFields()
        cJoinHAR := GetHARJoin(cTableHAR)
    Else
        cFieldsHAR := ''
        cJoinHAR := ''
    EndIf
    // número de campos da query tem que ser igual ao número de colunas no browse
    // não podem existir valores NULL ou ocorre erro de INSERT na tabela temporária que o browse cria
    BeginContent Var cQuery
        SELECT NJJ.NJJ_FILIAL
            ,NJJ.NJJ_CODROM
            ,NJJ.NJJ_DATPS1
            ,NJJ.NJJ_HORPS1
            ,NJJ.NJJ_DATPS2
            ,NJJ.NJJ_HORPS2
            ,NJJ.NJJ_PSLIQU
            ,NJJ.NJJ_CODPRO
            ,NJJ.NJJ_MOEGA
            ,COALESCE(SB1.B1_DESC, '') AS B1_DESC
            ,COALESCE(NJJ.NJJ_LOCAL, '') AS NJJ_LOCAL
            ,COALESCE(NNR.NNR_DESCRI, '') AS NNR_DESCRI
            ,COALESCE(NL5.NL5_DESCRI, '') AS NL5_DESCRI
            ,NJJ.NJJ_TIPO
            ,COALESCE(SX5.X5_DESCRI, '') AS NJJ_DSTIPO
            %Exp:cFieldsHAR%

        FROM  %Exp:RetSqlName("NJM")% NJM

        INNER JOIN %Exp:RetSqlName("NJJ")% NJJ ON NJJ.NJJ_FILIAL = NJM.NJM_FILIAL
            AND NJJ.NJJ_CODROM = NJM.NJM_CODROM
            AND NJJ.D_E_L_E_T_ = NJM.D_E_L_E_T_

        INNER JOIN ( SELECT D3_DOC ,D3_COD  FROM  %Exp:RetSqlName("SD3")% SD3ORI 
              WHERE SD3ORI.D_E_L_E_T_ = ''  
                AND SD3ORI.D3_FILIAL=%Exp:UBSA040DSQ(FWxFilial("SD3"))% 
                AND SUBSTRING(SD3ORI.D3_CF,1,2) = 'DE' 
                AND SD3ORI.D3_ESTORNO <> 'S'
                AND SD3ORI.D3_LOTECTL IN
            ( %Exp:cQueryINS%)) INSUMO ON INSUMO.D3_DOC = NJJ.NJJ_DOCEST
              AND INSUMO.D3_COD = NJM.NJM_CODPRO
              AND NJM.D_E_L_E_T_= ''
        
        LEFT JOIN %Exp:RetSqlName("SB1")% SB1 ON SB1.B1_FILIAL = %Exp:UBSA040DSQ(FWxFilial("SB1"))%
            AND SB1.B1_COD = NJJ.NJJ_CODPRO
            AND SB1.D_E_L_E_T_ = NJJ.D_E_L_E_T_

        %Exp:cJoinHAR%

        LEFT JOIN %Exp:RetSqlName("NNR")% NNR ON NNR.NNR_FILIAL = %Exp:UBSA040DSQ(FWxFilial("NNR"))%
            AND NNR.NNR_CODIGO = NJJ.NJJ_LOCAL
            AND NNR.D_E_L_E_T_ = NJJ.D_E_L_E_T_

        LEFT JOIN %Exp:RetSqlName("NL5")% NL5 ON NL5.NL5_FILIAL = NJJ.NJJ_FILIAL
            AND NL5.NL5_MOEGA = NJJ.NJJ_MOEGA
            AND NL5.D_E_L_E_T_ = NJJ.D_E_L_E_T_

        LEFT JOIN %Exp:RetSqlName("SX5")% SX5 ON SX5.X5_CHAVE = NJJ.NJJ_TIPO
            AND SX5.X5_TABELA = 'K5'
            AND SX5.D_E_L_E_T_ = NJJ.D_E_L_E_T_

        WHERE NJM.D_E_L_E_T_ = ''
		           

    EndContent

Return cQuery
//-------------------------------------------------------------------
/*/{Protheus.doc} CreateTT(cAlias)
Cria tabela temporária que será utilizada na consulta de colheitas
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function CreateTT(cAlias)
    Local oTable
    Local aStrColh := AGRA530CLT() //Estrutura da TT

    oTable := FwTemporaryTable():New(cAlias)
    oTable:SetFields(aStrColh)
    oTable:AddIndex("1",{"ORDCLT","CODSIS","CODFAZ"})
    oTable:Create()

Return oTable:GetRealName()
//-------------------------------------------------------------------
/*/{Protheus.doc} VisRomaneio(cRom)
Abre tela de romaneio
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function VisRomaneio(cRom)
    //posiciona no romaneio e chama a função padrão de visualização do romaneio
    DBSelectArea('NJJ')
    NJJ->(DbSetOrder(1))

    If NJJ->(DBSeek(FWxFilial('NJJ') + PadR(cRom, TamSX3('NJJ_CODROM')[1])))
        // Processando / Abrindo Romaneio...
        FWMsgRun(, {|| OGA250Visual() }, STR0015, STR0016)
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA040DSQ(cString)
Retorna string para ser utilizada no BeginContent..EndContent
Se utilizar aspas simples diretamente dentro de um %Exp:% ocorre erro de sintaxe e
dessa forma não ocorre erro
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040DSQ(cString)
Return "'" + cValToChar(cString) + "'"
//-------------------------------------------------------------------
/*/{Protheus.doc} GetHARFields()
Retorna campos da colheita utilizados na query de dados para o browse
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetHARFields()

    Local cFields as char
    Local aFields as array 
    Local nX as numeric

    cFields := ''
    aFields:= {'ORDCLT','DATORD','CODVAR','DESVAR','CODSIS',;
               'DESSIS','CODFAZ','DESFAZ','CODSET','DESSET',;
               'CODTAL','ARETAL'}
    // tem que existir o coalesce para evitar erro de nulos (mante coalesce pois é padrão ANSI)
    For nX := 1 To Len(aFields)
        cFields += ",COALESCE(COLHEITA." + aFields[nX] + ", '') " + aFields[nX]
    Next

Return cFields
//-------------------------------------------------------------------
/*/{Protheus.doc} GetHARJoin(cTableHAR)
Retorna join com a tabela temporária de colheita
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetHARJoin(cTableHAR)

    Local cJoin as char

    BeginContent Var cJoin
        LEFT JOIN %Exp:cTableHAR% COLHEITA ON COLHEITA.ORDCLT = NJJ.NJJ_ORDCLT
    EndContent

Return cJoin
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA040DFL()
Retorna campos do filtro com base nas colunas
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040DFL(aColumns)

    Local aFilter as array
    Local nX as numeric
    Local cField as char
    Local aTamSX3 as array

    aFilter := {}

    For nX := 1 To Len(aColumns)
        // armazeno o campo do bloco de código
        cField := StrTran( GetCbSource(aColumns[nX]:bData), '{ ||','')
        cField := StrTran( cField,'}','')

        aTamSX3 := TamSx3(cField)

        If !Empty(aTamSX3)
            Aadd(aFilter, {cField, FWX3Titulo(cField), aTamSX3[3],  aTamSX3[1],  aTamSX3[2], PesqPict(GetTable(cField),cField)})
        Else
            Aadd(aFilter, {cField, aColumns[nX]:cTitle, aColumns[nX]:cType, aColumns[nX]:nSize, aColumns[nX]:nDecimal, aColumns[nX]:xPicture})
        EndIf
    Next

Return aFilter
//-------------------------------------------------------------------
/*/{Protheus.doc} SetupRomBrw(cQuery, oColLeft)
Monta o browse de romaneios
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function SetupRomBrw(cQuery, oParent)

    Local aColumns as array
    Local cAliasBRW as char

    cAliasBRW := GetNextAlias()
    aColumns := GetColumns()
    aFilter := UBSA040DFL(aColumns)

    oBrowse := FWFormBrowse():New()
    oBrowse:SetDescription(STR0014)//'Romaneios e Ordens de Colheita'    
    oBrowse:DisableDetails()
    // oBrowse:DisableLocate()
    oBrowse:SetDataQuery(.T.)
    oBrowse:SetTemporary(.T.)
    oBrowse:SetQuery(cQuery)
    oBrowse:SetAlias(cAliasBrw)
    oBrowse:SetColumns(aColumns)
    oBrowse:AddButton(STR0002,{||VisRomaneio((cAliasBRW)->NJJ_CODROM)},,2)
    oBrowse:SetUseFilter(.T.)
    oBrowse:SetFieldFilter(aFilter)
    oBrowse:Activate(oParent)

Return oBrowse
//-------------------------------------------------------------------
/*/{Protheus.doc} SetupClsBrw(oParent)
Monta o browse de classificação do romaneio
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function SetupClsBrw(oParent)

    Local oBrowse as object
    Local aFields as array

    aFields := {'NJK_ITEM' , 'NJK_CODDES', 'NJK_DESDES', 'NJK_BASDES',;
                'NJK_OBRGT', 'NJK_PERDES', 'NJK_READES', 'NJK_QTDDES',;
                'NJK_DESRES'}


    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('NJK')
    oBrowse:SetDescription(STR0020)//'Itens de Classificação Romaneio'
    oBrowse:DisableDetails()
    oBrowse:SetOnlyFields(aFields)

    oBrowse:Activate(oParent)

Return oBrowse
//-------------------------------------------------------------------
/*/{Protheus.doc} GetTable(cField)
Retorna tabela do campo
@author  Lucas Briesemeister
@since   12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetTable(cField)

    Local cTable as char
    Local nUnder as numeric

    nUnder := At('_',cField)

    cTable := SubStr(cField, 1, nUnder - 1)

    If Len(cTable) < 3
        cTable := 'S' + cTable
    EndIf

Return cTable
