#Include "GTPA810.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Static cGTPRetSer

/*/
 * {Protheus.doc} GTPA801()
 * Cadastro do Manifesto Monitor
 * type    Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   Não há
 * return  oBrowse
/*/
Function GTPA810()
Local oBrowse   := FWLoadBrw('GTPA810')
Private aRotina := MenuDef()

oBrowse:SetMenuDef('GTPA810')

oBrowse:Activate()

Return oBrowse

/*/
 * {Protheus.doc} BrowseDef()
 * Cadastro do Manifesto
 * type    Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   Não há
 * return  oBrowse
/*/
Static Function BrowseDef()
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('GI9')
oBrowse:SetDescription('Manifesto') 

// Status do Manifesto
oBrowse:AddLegend("GI9_STATUS=='1'", "WHITE" , STR0001, 'GI9_STATUS') //"Aberto"
oBrowse:AddLegend("GI9_STATUS=='2'", "YELLOW", STR0002, 'GI9_STATUS') //"Cancelado"
oBrowse:AddLegend("GI9_STATUS=='3'", "GREEN" , STR0003, 'GI9_STATUS') //"Encerrado"
// Status Envio do Manifesto
oBrowse:AddLegend("GI9_STATRA=='0'", "WHITE" , STR0004, 'GI9_STATRA') //"Normal"
oBrowse:AddLegend("GI9_STATRA=='1'", "YELLOW", STR0005, 'GI9_STATRA') //"Aguardando"
oBrowse:AddLegend("GI9_STATRA=='2'", "GREEN" , STR0006, 'GI9_STATRA') //"Autorizado"
oBrowse:AddLegend("GI9_STATRA=='3'", "RED"   , STR0007, 'GI9_STATRA') //"Nao Autorizado"
oBrowse:AddLegend("GI9_STATRA=='4'", "BLUE"  , STR0008, 'GI9_STATRA') //"Em Contingencia"
oBrowse:AddLegend("GI9_STATRA=='5'", "GRAY"  , STR0009, 'GI9_STATRA') //"Falha na Comunicacão"
oBrowse:AddLegend("GI9_STATRA=='6'", "ORANGE" ,STR0060, 'GI9_STATRA') //"Manifesto Operacional"


Return oBrowse


/*/
 * {Protheus.doc} MenuDef()
 * Menu da Rotina 
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   Não há
 * return  aMenu
/*/
Static Function MenuDef()
Local aMenu := {}
		
ADD OPTION aMenu TITLE STR0010 ACTION "VIEWDEF.GTPA810" OPERATION 2 ACCESS 0 // Visualizar //"Visualizar"
ADD OPTION aMenu TITLE STR0011 ACTION "VIEWDEF.GTPA810A" OPERATION 3 ACCESS 0 // Incluir //"Incluir"
ADD OPTION aMenu TITLE STR0012 ACTION "VIEWDEF.GTPA810" OPERATION 4 ACCESS 0 // Alterar //"Alterar"
ADD OPTION aMenu TITLE STR0013 ACTION "VIEWDEF.GTPA810" OPERATION 5 ACCESS 0 // Excluir //"Excluir"

Return aMenu


/*/
 * {Protheus.doc} ModelDef()
 * Modelo de Dados
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/08/2019
 * version 12.25
 * param   Não há
 * return  oModel
/*/
Static Function ModelDef()

    Local oModel	:= nil
    Local oStrGI9	:= FWFormStruct(1, "GI9") // Cabe - Entrada de MDF
    Local oStrGIA	:= FWFormStruct(1, "GIA") // Grid - Inf. Percursos
    Local oStrGIB	:= FWFormStruct(1, "GIB") // Grid - Inf. Municipios
    Local oStrGIF1	:= FWFormStruct(1, "GIF") // Grid - Inf. Municipios CT-es
    Local oStrGIF2	:= FWFormStruct(1, "GIF") // Grid - Inf. Municipios CT-es
    Local oStrGIG	:= FWFormStruct(1, "GIG") // Grid - Condutores
    Local bVldGrid	:= {|oModel| VldGrid(oModel) }
    SetModelStruct(oStrGI9,oStrGIA,oStrGIB,oStrGIF1,oStrGIF2,oStrGIG)

    oModel := MPFormModel():New("GTPA810", /*bPreValid*/, bVldGrid, /*COMMIT*/)
    oModel:SetDescription(STR0014) //"Manifesto"

    oModel:AddFields("MASTERGI9",/*oOwner*/, oStrGI9)
    oModel:GetModel("MASTERGI9"):SetDescription(STR0015) //"Manifesto"

    oModel:AddGrid("DETAILGIA", "MASTERGI9", oStrGIA)
    oModel:SetRelation("DETAILGIA", {{"GIA_FILIAL", "xFilial('GIA')"}, {"GIA_CODIGO", "GI9_CODIGO"}}, GIA->(IndexKey(1)))
    oModel:GetModel("DETAILGIA"):SetDescription(STR0016) //"Percursos"
    oModel:GetModel('DETAILGIA'):SetOptional(.T.)

    oModel:AddGrid("DETAILGIB", "MASTERGI9", oStrGIB)
    oModel:SetRelation("DETAILGIB", {{"GIB_FILIAL", "xFilial('GIB')"}, {"GIB_CODIGO", "GI9_CODIGO"}}, GIB->(IndexKey(1)))
    oModel:GetModel("DETAILGIB"):SetDescription(STR0017) //"Municipios"
    oModel:GetModel('DETAILGIB'):SetOptional(.T.)

    oModel:AddGrid("DETAILGIF1", "MASTERGI9", oStrGIF1)
    oModel:SetRelation("DETAILGIF1", {{"GIF_FILIAL", "xFilial('GIF')"}, {"GIF_CODIGO", "GI9_CODIGO"}}, GIF->(IndexKey(1)))
    oModel:GetModel("DETAILGIF1"):SetDescription(STR0018) //"Municipios CT-es"
    oModel:GetModel('DETAILGIF1'):SetOptional(.T.)

    oModel:AddGrid("DETAILGIF2", "MASTERGI9", oStrGIF2)
    oModel:GetModel("DETAILGIF2"):SetDescription(STR0018) //"Municipios CT-es"
    oModel:GetModel('DETAILGIF2'):SetOptional(.T.)

    oModel:GetModel('DETAILGIF2'):SetOnlyQuery(.T.)

    oModel:AddGrid("DETAILGIG", "MASTERGI9", oStrGIG)
    oModel:SetRelation("DETAILGIG", {{"GIG_FILIAL", "xFilial('GIG')"}, {"GIG_CODIGO", "GI9_CODIGO"}}, GIG->(IndexKey(1)))
    oModel:GetModel("DETAILGIG"):SetDescription(STR0019) //"Condutores"
    oModel:GetModel('DETAILGIG'):SetOptional(.T.)

    oModel:SetPrimarykey({"GI9_FILIAL", "GI9_CODIGO"})

Return oModel


/*/
 * {Protheus.doc} ViewDef()
 * View
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   Não há 
 * return  oView
/*/
Static Function ViewDef()
Local oView   := nil
Local oModel  := FWLoadModel("GTPA810")
Local oStrGI9 := FWFormStruct(2, "GI9") // Cabe - Entrada de MDF
Local oStrGIA := FWFormStruct(2, "GIA") // Grid - Inf. Percursos
Local oStrGIB := FWFormStruct(2, "GIB") // Grid - Inf. Municipios
Local oStrGIF1 := FWFormStruct(2, "GIF") // Grid - Municipios CT-es
Local oStrGIF2 := FWFormStruct(2, "GIF") // Grid - Municipios CT-es
Local oStrGIG := FWFormStruct(2, "GIG") // Grid - Condutores

SetViewStruct(oStrGI9,oStrGIA,oStrGIB,oStrGIF1,oStrGIF2,oStrGIG)

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField("FILD_GI9", oStrGI9, "MASTERGI9")
oView:AddGrid('GRID_GIF1' , oStrGIF1, 'DETAILGIF1')
oView:AddGrid('GRID_GIF2' , oStrGIF2, 'DETAILGIF2')
oView:AddGrid('GRID_GIG' , oStrGIG, 'DETAILGIG')
oView:AddGrid('GRID_GIA' , oStrGIA, 'DETAILGIA')

oView:CreateHorizontalBox('BOX_CAB' , 55)
oView:CreateHorizontalBox('BOX_GRID', 45)

oView:CreateFolder('PASTAS_GRID', 'BOX_GRID') 
oView:AddSheet('PASTAS_GRID', 'ABA_CTE1'   , STR0055)	//'CT-e Selecionados' 
oView:AddSheet('PASTAS_GRID', 'ABA_CTE2'   , STR0056)	//'CT-e Pendentes') 
oView:AddSheet('PASTAS_GRID', 'ABA_CONDUT', STR0057) 	//'Condutores' 

oVIew:CreateHorizontalBox('BOX_CONDUT', 100,,,'PASTAS_GRID', 'ABA_CONDUT')

oView:CreateVerticalBox( 'BOX_GIF1', 80,,, 'PASTAS_GRID', 'ABA_CTE1')
oView:CreateVerticalBox( 'BOX_GIF2', 100,,, 'PASTAS_GRID', 'ABA_CTE2')
oView:CreateVerticalBox( 'BOX_GIA', 20,,, 'PASTAS_GRID', 'ABA_CTE1')

oView:SetOwnerView('FILD_GI9','BOX_CAB')
oView:SetOwnerView('GRID_GIF1','BOX_GIF1')
oView:SetOwnerView('GRID_GIF2','BOX_GIF2')
oView:SetOwnerView('GRID_GIG','BOX_CONDUT')
oView:SetOwnerView('GRID_GIA','BOX_GIA')

oView:SetAfterViewActivate( { || AfterActiv(oView)})

Return oView

/*/
 * {Protheus.doc} SetModelStruct()
 * Estrutura da View
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oStrGI9,oStrGIA,oStrGIB,oStrGIF, oStrGIG
 * return  Não há
/*/
Static Function SetModelStruct(oStrGI9,oStrGIA,oStrGIB,oStrGIF1,oStrGIF2,oStrGIG)
Local bTrig    := {|oMdl,cField, uValue| GetFild(oMdl,cField, uValue)}
Local bTrigUf  := {|oMdl,cField, uValue|SetUfsMdfe(oMdl)}
Local bTrigAg  := {|oMdl,cField, uValue|SetAgenc(oMdl,cField, uValue)}
Local bTrigMrk  := {|oMdl,cField, uValue|TriggerMrk(oMdl,cField, uValue)}
Local bTrigVia  := {|oMdl,cField, uValue|AddColab(oMdl,cField, uValue)}
Local bVldFild := {|oMdl,cField, uValue| VldFild(oMdl,cField, uValue)}
Local bNumero  := {|| RIGHT(GTPXENUM("GI9","GI9_NUMERO",2),TAMSX3('GI9_NUMERO')[1])}
Local bCodigo  := {|| GTPXENUM('GI9','GI9_CODIGO')}
Local bSerie   := {|| GTPGetRules("SERIEMDF",,,"")}
Local bNomeUs  := {|| RetCodUsr()}
Local bDate    := {|| Date()}
// Local bCondut  := {|oMdl,cField, uValue| RetCondut(oMdl,cField, uValue)}
Local bVldIni  := {|oMdl,cField, uValue| VldIni(oMdl,cField, uValue)}
Local bMainInit:= {|oMdl,cField| Initialize(oMdl,cField)}

oStrGIF1:AddField("", "", "GIF_MARK" , "L", 1  , 0, NIL, NIL ,NIL, .F., NIL, .F., .F., .T.)
oStrGIF2:AddField("", "", "GIF_MARK" , "L", 1  , 0, NIL, NIL ,NIL, .F., NIL, .F., .F., .T.)

oStrGI9:AddTrigger("GI9_VEICUL", "GI9_VEICUL", {||.T.}, bTrig  )
oStrGIG:AddTrigger("GIG_CODCON", "GIG_CODCON", {||.T.}, bTrig  )
oStrGI9:AddTrigger("GI9_UFFIM" , "GI9_UFFIM" , {||.T.}, bTrigUf)
oStrGI9:AddTrigger("GI9_CODEMI", "GI9_CODEMI", {||.T.}, bTrigAg)
oStrGI9:AddTrigger("GI9_CODREC", "GI9_CODREC", {||.T.}, bTrigAg)
oStrGI9:AddTrigger("GI9_VIAGEM", "GI9_VIAGEM", {||.T.}, bTrigVia)

oStrGIF1:AddTrigger("GIF_MARK", "GIF_MARK", {||.T.}, bTrigMrk)
oStrGIF2:AddTrigger("GIF_MARK", "GIF_MARK", {||.T.}, bTrigMrk)

oStrGI9:SetProperty('GI9_NUMERO', MODEL_FIELD_INIT, bNumero)
oStrGI9:SetProperty('GI9_CODIGO', MODEL_FIELD_INIT, bCodigo)
oStrGI9:SetProperty('GI9_SERIE' , MODEL_FIELD_INIT, bSerie )
oStrGI9:SetProperty('GI9_USUARI', MODEL_FIELD_INIT, bNomeUs)
oStrGI9:SetProperty('GI9_DTCRIA', MODEL_FIELD_INIT, bDate  )
oStrGI9:SetProperty('GI9_STATUS', MODEL_FIELD_INIT, bVldIni)
oStrGI9:SetProperty('GI9_STATRA', MODEL_FIELD_INIT, bVldIni)
oStrGI9:SetProperty('GI9_DESEMI', MODEL_FIELD_INIT, bMainInit)
oStrGI9:SetProperty('GI9_DESREC', MODEL_FIELD_INIT, bMainInit)
oStrGI9:SetProperty('GI9_DESENC', MODEL_FIELD_INIT, bMainInit)

oStrGIG:SetProperty('GIG_NOME'  , MODEL_FIELD_INIT, bMainInit)
oStrGIG:SetProperty('GIG_CPF'   , MODEL_FIELD_INIT, bMainInit)
// oStrGIG:SetProperty('GIG_NOME'  , MODEL_FIELD_INIT, bCondut)
// oStrGIG:SetProperty('GIG_CPF'   , MODEL_FIELD_INIT, bCondut)

oStrGI9:SetProperty('GI9_VEICUL', MODEL_FIELD_VALID, bVldFild)
oStrGIG:SetProperty('GIG_CODCON', MODEL_FIELD_VALID, bVldFild)
oStrGI9:SetProperty('GI9_HORAEM', MODEL_FIELD_VALID, bVldFild)
oStrGI9:SetProperty('GI9_CODEMI', MODEL_FIELD_VALID, bVldFild)
oStrGI9:SetProperty('GI9_CODREC', MODEL_FIELD_VALID, bVldFild)

Return 

Static Function Initialize(oSubMdl,cField)

    Local xValue

    Local aRetGYG   := {}
    
    If ( oSubMdl:GetModel():GetOperation() != 3 )
    
        //GI6_FILIAL, GI6_CODIGO, R_E_C_N_O_, D_E_L_E_T_
        Do Case 
        Case ( cField == "GI9_DESEMI" )
            xValue := GI6->(GetAdvFVal("GI6","GI6_DESCRI",xFilial("GI6")+GI9->GI9_CODEMI,1,""))
        Case ( cField == "GI9_DESREC" )
            xValue := GI6->(GetAdvFVal("GI6","GI6_DESCRI",xFilial("GI6")+GI9->GI9_CODREC,1,""))
        Case ( cField == "GI9_DESENC" )
            xValue := GI6->(GetAdvFVal("GI6","GI6_DESCRI",xFilial("GI6")+GI9->GI9_CODENC,1,""))
        Case ( cField $ "GIG_CPF-GIG_NOME" )//GYG_FILIAL, GYG_CODIGO, R_E_C_N_O_, D_E_L_E_T_
            
            aRetGYG  := GYG->(GetAdvFVal("GYG",{"GYG_NOME","GYG_CPF"},xFilial("GYG")+GIG->GIG_CODCON,1,{"",""}))

            If ( cField == "GIG_NOME" )
                xValue := aRetGYG[1]
            Else    
                xValue := aRetGYG[2]
            EndIf

        //Case ( cField == "GI9_DESCMU" )
        End Case

    EndIf

Return(xValue)

/*/
 * {Protheus.doc} SetViewStruct()
 * Estrutura da View
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oStrGI9,oStrGIA,oStrGIB,oStrGIF, oStrGIG
 * return  Não há
/*/
Static Function SetViewStruct(oStrGI9,oStrGIA,oStrGIB,oStrGIF1,oStrGIF2,oStrGIG)

oStrGIF1:AddField("GIF_MARK" , "00", "", "", NIL, "L", "", NIL, Nil, .T., NIL, NIL, Nil, NIL, NIL, .T., NIL)
oStrGIF2:AddField("GIF_MARK" , "00", "", "", NIL, "L", "", NIL, Nil, .T., NIL, NIL, Nil, NIL, NIL, .T., NIL)

oStrGI9:SetProperty("GI9_VEICUL", MVC_VIEW_LOOKUP, "ST9"   )
oStrGIG:SetProperty("GIG_CODCON", MVC_VIEW_LOOKUP, "GYG"   )
oStrGI9:SetProperty("GI9_CODEMI", MVC_VIEW_LOOKUP, "GI6FIL")
oStrGI9:SetProperty("GI9_CODREC", MVC_VIEW_LOOKUP, "GI6"   )

oStrGIF1:SetProperty("GIF_TPCLIE", MVC_VIEW_COMBOBOX, {STR0024, STR0023}) //"J=Juridica"
oStrGIF2:SetProperty("GIF_TPCLIE", MVC_VIEW_COMBOBOX, {STR0024, STR0023}) //"J=Juridica"

oStrGI9:SetProperty("GI9_TPEMIS", MVC_VIEW_COMBOBOX, {STR0026, STR0025}) //"2=Contingencia"
oStrGI9:SetProperty("GI9_STATUS", MVC_VIEW_COMBOBOX, {STR0029, STR0027, STR0028}) //"2=Cancelado"
oStrGI9:SetProperty("GI9_STATRA", MVC_VIEW_COMBOBOX, {STR0030, STR0031, STR0032, STR0033, STR0034, STR0035,STR0061}) //"0=Normal", "1=Aguardando", "2=Autorizado", "3=Nao Autorizado", "4=em Contingencia", "5=com Falha na Comunicacao", "6=Manifesto Operacional" ***

oStrGI9:AddGroup("GRUPO_MDF"      , ""     , "", 2)
oStrGI9:AddGroup("GRUPO_DATA"     , ""     , "", 2)
oStrGI9:AddGroup("GRUPO_EMISSOR"  , ""     , "", 2)
oStrGI9:AddGroup("GRUPO_RECEBEDOR", ""     , "", 2)
oStrGI9:AddGroup("GRUPO_VEICULO"  , STR0036, "", 2) //"Viagem"
oStrGI9:AddGroup("GRUPO_VALOR"    , ""     , "", 2)
oStrGI9:AddGroup("GRUPO_RETORNO"  , STR0037, "", 2) //"Transmissão"

oStrGI9:SetProperty("GI9_CODIGO", MVC_VIEW_GROUP_NUMBER, "GRUPO_MDF")
oStrGI9:SetProperty("GI9_SERIE" , MVC_VIEW_GROUP_NUMBER, "GRUPO_MDF")
oStrGI9:SetProperty("GI9_NUMERO", MVC_VIEW_GROUP_NUMBER, "GRUPO_MDF")

oStrGI9:SetProperty("GI9_EMISSA", MVC_VIEW_GROUP_NUMBER, "GRUPO_DATA")
oStrGI9:SetProperty("GI9_HORAEM", MVC_VIEW_GROUP_NUMBER, "GRUPO_DATA")
oStrGI9:SetProperty("GI9_TPEMIS", MVC_VIEW_GROUP_NUMBER, "GRUPO_DATA")
oStrGI9:SetProperty("GI9_DTCRIA", MVC_VIEW_GROUP_NUMBER, "GRUPO_DATA")

oStrGI9:SetProperty("GI9_CODEMI", MVC_VIEW_GROUP_NUMBER, "GRUPO_EMISSOR")
oStrGI9:SetProperty("GI9_DESEMI", MVC_VIEW_GROUP_NUMBER, "GRUPO_EMISSOR")
oStrGI9:SetProperty("GI9_UFINI" , MVC_VIEW_GROUP_NUMBER, "GRUPO_EMISSOR")

oStrGI9:SetProperty("GI9_CODREC", MVC_VIEW_GROUP_NUMBER, "GRUPO_RECEBEDOR")
oStrGI9:SetProperty("GI9_DESREC", MVC_VIEW_GROUP_NUMBER, "GRUPO_RECEBEDOR")
oStrGI9:SetProperty("GI9_UFFIM" , MVC_VIEW_GROUP_NUMBER, "GRUPO_RECEBEDOR")

oStrGI9:SetProperty("GI9_VIAGEM", MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO")
oStrGI9:SetProperty("GI9_VEICUL", MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO")
oStrGI9:SetProperty("GI9_PLACA" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO")
oStrGI9:SetProperty("GI9_TARAVE", MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO")

oStrGI9:SetProperty("GI9_VCARGA", MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR")
oStrGI9:SetProperty("GI9_PCARGA", MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR")

oStrGI9:SetProperty("GI9_OBSERV", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_STATRA", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_STATUS", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_CHVMDF", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_XMLENV", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_XMLRET", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_CODREF", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_MOTREJ", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_PROTOC", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")
oStrGI9:SetProperty("GI9_PROTCA", MVC_VIEW_GROUP_NUMBER, "GRUPO_RETORNO")

oStrGI9:SetProperty("GI9_CODEMI", MVC_VIEW_ORDEM, '09')
oStrGI9:SetProperty("GI9_DESEMI", MVC_VIEW_ORDEM, '10')
oStrGI9:SetProperty("GI9_UFINI" , MVC_VIEW_ORDEM, '11')
oStrGI9:SetProperty("GI9_CODREC", MVC_VIEW_ORDEM, '12')
oStrGI9:SetProperty("GI9_DESREC", MVC_VIEW_ORDEM, '13')
oStrGI9:SetProperty("GI9_UFFIM" , MVC_VIEW_ORDEM, '14')
oStrGI9:SetProperty("GI9_VIAGEM", MVC_VIEW_ORDEM, '15')
oStrGI9:SetProperty("GI9_TPEMIS", MVC_VIEW_ORDEM, '08')

oStrGIF1:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStrGIF2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStrGIF1:SetProperty('GIF_MARK', MVC_VIEW_CANCHANGE, .T.)
oStrGIF2:SetProperty('GIF_MARK', MVC_VIEW_CANCHANGE, .T.)


oStrGI9:SetProperty('GI9_NUMERO', MVC_VIEW_CANCHANGE, .F.)
oStrGI9:SetProperty('GI9_UFINI', MVC_VIEW_CANCHANGE, .F.)
oStrGI9:SetProperty('GI9_UFFIM', MVC_VIEW_CANCHANGE, .F.)
oStrGI9:SetProperty('GI9_TPEMIS', MVC_VIEW_CANCHANGE, .T.)
oStrGI9:SetProperty('GI9_VIAGEM', MVC_VIEW_CANCHANGE, .F.)

oStrGI9:RemoveField("GI9_MUNCAR" )
oStrGI9:RemoveField("GI9_DESCMU" )
oStrGIF1:RemoveField("GIF_CODG99")
oStrGIF2:RemoveField("GIF_CODG99")

Return 

/*/
 * {Protheus.doc} SetFilt()
 * Cria Filtro
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   Não há
 * return  lRet
/*/
Function SetFilt()
Local cSerie := SuperGetMV("MV_ESPECIE")
Local aSerie := {}
Local aRet   := {}
Local nI     := 0
Local lRet   := .F.
Local cRet   := ""
Local cQuery := ""

If !Empty(cSerie) .and. 'MDF' $ cSerie
    aSerie:= StrTokArr2(cSerie, ';')

    For nI:= 1 to Len(aSerie)
        If 'MDF' $ Upper(aSerie[nI])
            Aadd(aRet, StrTokArr2( aSerie[nI], '='))
        EndIf
    Next

	cRet   := "X5_CHAVE IN( "

    For nI:= 1 to Len(aRet)
        cRet += "'" + aRet[nI][1] + "'"
        
        If nI < Len(aRet)
            cRet+=","
        EndIf
    Next

    cRet+= " )"

    cQuery:= "SELECT X5_CHAVE, X5_DESCRI "
    cQuery+= " FROM " + RetSqlName("SX5") + " SX5 " 
    cQuery+= " WHERE "
    cQuery+= cRet
    cQuery+= " AND X5_TABELA = '01'" 

    oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"X5_CHAVE","X5_DESCRI"})

    oLookUp:AddIndice("Código"	 , "X5_CHAVE")
    oLookUp:AddIndice("Descrição", "X5_DESCRI")

    If oLookUp:Execute()
        lRet       := .T.
        aRetorno   := oLookUp:GetReturn()
        cGTPRetSer := aRetorno[1]
    EndIf   

    FreeObj(oLookUp)
    
Else 
    FwAlertWarning(STR0038, STR0039) //'Parametro MV_ESPECIE não cadastrado para MDF'
EndIf      

Return lRet

/*/
 * {Protheus.doc} GetSerie()
 * Retorno da Serie
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   Não há
 * return  cRet
/*/
Function GetSerie()
Local cRet :=''

DbSelectArea("GI9")

cRet:=	Alltrim(cGTPRetSer)

Return cRet

/*/
 * {Protheus.doc} GetFild()
 * Retorno as iformações dos campos
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oMdl,cField, uValue
 * return  lRet
/*/
Static Function GetFild(oMdl,cField, uValue)
Local aDA3 := DA3->(GetArea())
Local aST9 := ST9->(GetArea())
Local aGYG := GYG->(GetArea())
Local lRet := .T.
Local cCod := Posicione('DA3',5,xFilial('DA3')+uValue,"DA3_TARA")

Do CASE
    Case cField == 'GI9_VEICUL'
        If !Empty(uValue)
            oMdl:SetValue('GI9_PLACA', ALLTRIM(Posicione('ST9',1,xFilial('ST9')+uValue,"T9_PLACA")))
            if !Empty(cCod)
                oMdl:SetValue('GI9_TARAVE', cCod)
            endif
        ElseIf Empty(uValue) 
            oMdl:SetValue('GI9_PLACA', '')
        EndIf 
        
        lRet := ValAloc(oMdl,uValue)
        
    Case cField == 'GIG_CODCON'
        If !Empty(uValue) 
            oMdl:SetValue('GIG_NOME', ALLTRIM(Posicione('GYG',1,xFilial('GYG')+uValue,"GYG_NOME")))
            oMdl:SetValue('GIG_CPF' , ALLTRIM(Posicione('GYG',1,xFilial('GYG')+uValue,"GYG_CPF" )))
        ElseIf Empty(uValue)
            oMdl:SetValue('GIG_NOME', '')
            oMdl:SetValue('GIG_CPF' , '')
        EndIf 
EndCase

RestArea(aDA3)
RestArea(aST9)
RestArea(aGYG)

Return lRet

/*/{Protheus.doc} ValAloc
(long_description)
@type  Static Function
@author henrique.toyada
@since 13/11/2019
@version 1.0
@param param_name, param_type, param_descr
@return lRet, Lógico, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ValAloc(oMdl,uValue)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()
Local cDtEmiss  := DTOS(oMdl:GetValue("GI9_EMISSA"))
Local cHrEmiss  := oMdl:GetValue("GI9_HORAEM")

BeginSql Alias cAliasTmp
    SELECT
        R_E_C_N_O_ AS RECNOGI9
    FROM
        %Table:GI9% GI9 
    WHERE
        GI9.GI9_FILIAL = %xFilial:GI9% 
        AND %Exp:cDtEmiss+cHrEmiss% = GI9.GI9_EMISSA || GI9.GI9_HORAEM
        AND GI9.%NotDel%
EndSql

If (cAliasTmp)->(!(Eof()))
    lRet := .F.
EndIf

Return lRet

/*/
 * {Protheus.doc} VldFild()
 * Validação dos campos
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oMdl,cField, uValue
 * return  lRet
/*/
Static Function VldFild(oMdl,cField, uValue)
Local cMsgErro := ''
Local cMsgSol  := ''
Local cHora	   := Left(uValue, 2)
Local cMinuto  := Right(uValue, 2)
Local lRet     := .T.

Do Case 
    Case cField == 'GI9_VEICUL'
        If !Empty(uValue) .and. !(ExistCpo('ST9', uValue))
            lRet := .F.
        EndIf
    Case cField == 'GIG_CODCON'
        If !Empty(uValue) .and. !(ExistCpo('GYG', uValue))
            lRet := .F.
        EndIf
    Case cField == 'GI9_HORAEM'
        If !(( cHora >= "00" .And. cHora < "24" ) .And. (cMinuto >= "00" .And. cMinuto < "60" ))
            lRet := .F. 
        Endif

        IF !lRet  
            cMsgErro := STR0040 //"Formato da hora informado invalido"
            cMsgSol	 := STR0041 //"Informe uma hora entre 00:00 às 23:59"
        EndIf
    Case cField == 'GI9_CODEMI'
        If !Empty(uValue) .and. !(ExistCpo('GI6', uValue)) .or. (!Empty(uValue) .And. uValue == oMdl:GetValue('GI9_CODREC'))
           lRet := .F.
        EndIf
    Case cField == 'GI9_CODREC'
        If !Empty(uValue) .and. !(ExistCpo('GI6', uValue)) .or. (!Empty(uValue) .And. uValue == oMdl:GetValue('GI9_CODEMI'))
            lRet := .F.
        EndIf
EndCase 

Return lRet

/*/
 * {Protheus.doc} VldGrid()
 * Preenche GIB
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oModel
 * return  lRet
/*/
Static Function VldGrid(oModel)
Local oGIF1		:= oModel:GetModel('DETAILGIF1')
Local oGIF2		:= oModel:GetModel('DETAILGIF2')
Local oGIB		:= oModel:GetModel('DETAILGIB')
Local oGIG		:= oModel:GetModel('DETAILGIG')
Local cStaPos	:= GI9->GI9_STATRA
Local nOper		:= oModel:GetOperation()
Local nConGIF	:= 0
Local nConGIG	:= 0
Local nCnt		:= 0
Local lRet		:= .T.
Local lOk		:= .F.
Local cCodG99	:= ''
Local cCodVia	:= oModel:GetModel('MASTERGI9'):GetValue('GI9_VIAGEM')
Local aStrGIF	:= oGIF1:GetStruct():GetFields()
Local nX		:= 0
Local cMsg		:= ''

lRet := PosValid(oModel)

If ( lRet )

    // Preenche o Grid GIB
    If nOper == 3 .Or. nOper == 4

        If !(oGIF1:SeekLine({{"GIF_MARK",.T.}},.F.,.F.)) .And. !(oGIF2:SeekLine({{"GIF_MARK",.T.}},.F.,.F.))
            cMsg := STR0058 //'Selecione ao menos um CT-e para concluir o Manifesto'
            oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'PosValid', cMsg,) //"Status" 
            Return .F.
        Endif
        
        If oGIG:IsEmpty() .Or. oGIG:Length(.T.) == 0
            cMsg := STR0059 //'Atenção, nenhum condutor informado'
            oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'PosValid',cMsg,) //"Status"
            Return .F.
        Endif

        // Na Aba Colaboradores Valida se existe Colaborador sem CPF 
        If oGIG:Length() > 0
            For nConGIG := 0 To oGIG:Length()
                oGIG:GoLine(nConGIG)
                If Empty(oGIG:GetValue("GIG_CPF")) .AND. !(oGIG:IsDeleted())
                    MsgAlert('No Cadastro do Colaborador o campo CPF esta em branco.'+CRLF + CRLF + CRLF +'Código: ' + oGIG:GetValue("GIG_CODCON") + CRLF ;
                                                                                                        +'Nome  : ' + oGIG:GetValue("GIG_NOME"),'CPF do Colaborador não preenchido' )
                    lRet := .F.
                Endif
                
            Next 
        
        EndIf

        If oGIF2:Length() > 0
        
            For nCnt := 1 To oGIF2:Length()
            
                oGIF2:GoLine(nCnt)
                
                If oGIF2:GetValue("GIF_MARK")
                
                    oGIF1:AddLine()
                    
                    For nX := 1 To Len(aStrGIF)
                        oGIF1:LoadValue(aStrGIF[nX][3], oGIF2:GetValue(aStrGIF[nX][3], nCnt))
                    Next
                    
                Endif
            
            Next
        
        Endif
        
        If oGIF1:Length() > 0
        
            For nCnt := 0 To oGIF1:Length()
                oGIF1:GoLine(nCnt)
                If !(oGIF1:GetValue("GIF_MARK"))
                    cCodG99 := oGIF1:GetValue('GIF_CODG99')
                    Gtp801AtuSta(cCodG99,'6',cCodVia)
                    oGIF1:DeleteLine(.T.)
                Else
                    cCodG99 := oGIF1:GetValue('GIF_CODG99')
                    Gtp801AtuSta(cCodG99,'3',cCodVia)
                Endif
            Next 
            
            for nConGIF := 1 to oGIF1:Length()
                If oGIB:SeekLine({{"GIB_CODMUN",oGIF1:GetValue('GIF_CODMUN', nConGIF)}}, .F.)
                    lOk := .T. 
                EndIf

                if !lOk .And. !oGIB:IsEmpty()
                    oGIB:AddLine()
                    oGIB:SetValue('GIB_CODMUN', oGIF1:GetValue('GIF_CODMUN', nConGIF))
                elseif !lOk .And. oGIB:IsEmpty()
                    oGIB:SetValue('GIB_CODMUN', oGIF1:GetValue('GIF_CODMUN', nConGIF))
                endif
                
                lOk := .F.    
            next
        EndIf
    ElseIf nOper == 5

        For nCnt := 0 To oGIF1:Length()
            oGIF1:GoLine(nCnt)
            cCodG99 := oGIF1:GetValue('GIF_CODG99')
            Gtp801AtuSta(cCodG99,'6',cCodVia)
        Next 

    Endif

    If (nOper == 4 .Or. nOper == 5) .And. (cStaPos == '1' .Or. cStaPos == '2' .Or. cStaPos == '4')
        lRet := .F.

        If nOper == 4 
            Do Case 
                Case cStaPos == '1'
                    cMsgAlert := STR0042 //"Registro não pode ser Alterado, Status Aguardando"
                Case cStaPos == '2'
                    cMsgAlert := STR0043 //"Registro não pode ser Alterado, Status Autorizado"
                Case cStaPos == '4'
                    cMsgAlert := STR0044 //"Registro não pode ser Alterado, Status Em Contingencia"
            EndCase
        Else 
            Do Case 
                Case cStaPos == '1'
                    cMsgAlert := STR0045 //"Registro não pode ser Excluido, Status Aguardando"
                Case cStaPos == '2'
                    cMsgAlert := STR0046 //"Registro não pode ser Excluido, Status Autorizado"
                Case cStaPos == '4'
                    cMsgAlert := STR0047 //"Registro não pode ser Excluido, Status Em Contingencia"
            EndCase
        EndIf

        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,STR0048,cMsgAlert,) //"Status"
    EndIf 

EndIf

Return lRet

/*/
 * {Protheus.doc} SetAgenc()
 * Gatilha as informações da agencia 
 * type    Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oMdl,cField, uValue
 * return  lRet
/*/
Static Function SetAgenc(oMdl,cField, uValue)
Local aSM0    := SM0->(GetArea())   
Local aGI6    := GI6->(GetArea())  
Local cFilAg  := Iif(cField == 'GI9_CODEMI', Posicione('GI6', 1, xFilial('GI6')+oMdl:GetValue('GI9_CODEMI'), 'GI6_FILRES'), Posicione('GI6', 1, xFilial('GI6')+oMdl:GetValue('GI9_CODREC'), 'GI6_FILRES'))
Local cDesAg  := Iif(cField == 'GI9_CODEMI', Posicione('GI6', 1, xFilial('GI6')+oMdl:GetValue('GI9_CODEMI'), 'GI6_DESCRI'), Posicione('GI6', 1, xFilial('GI6')+oMdl:GetValue('GI9_CODREC'), 'GI6_DESCRI'))
Local cUFAg   := Posicione('SM0', 1, cEmpAnt+cFilAg, 'M0_ESTENT')
Local cMunCar := Posicione('SM0', 1, cEmpAnt+cFilAg, 'M0_CODMUN')
Local cDescMu := Posicione('SM0', 1, cEmpAnt+cFilAg, 'M0_CIDENT')
Local lRet    := .T.

Do Case 
    Case cField == 'GI9_CODEMI'
        oMdl:SetValue('GI9_DESEMI', cDesAg )
        oMdl:SetValue('GI9_UFINI' , cUFAg  )
        oMdl:SetValue('GI9_MUNCAR', cMunCar)
        oMdl:SetValue('GI9_DESCMU', cDescMu)
    Case cField == 'GI9_CODREC'
        oMdl:SetValue('GI9_DESREC', cDesAg )
        oMdl:SetValue('GI9_UFFIM', cUFAg  )
EndCase

RestArea(aSM0)
RestArea(aGI6)

Return lRet

/*/
 * {Protheus.doc} RetCondut()
 * Retorna condutor
 * type    Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oMdl,cField, uValue
 * return  cVal
/*/
Static Function RetCondut(oMdl,cField, uValue)
Local aGYG := GYG->(GetArea())  
Local cCod := GIG->GIG_CODCON
Local nPer := oMdl:GetOperation()
Local cVal := ''

If nPer != 3
    Do Case 
        Case cField == 'GIG_NOME'
            cVal := ALLTRIM(Posicione('GYG',1,xFilial('GYG')+cCod, 'GYG_NOME'))
        Case cField == 'GIG_CPF'
            cVal := ALLTRIM(Posicione('GYG',1,xFilial('GYG')+cCod,'GYG_CPF'))
    EndCase 
EndIf

RestArea(aGYG)

Return cVal

/*/
 * {Protheus.doc} Statra()
 * Inicializador do Status, check
 * type    Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oMdl,cField, uValue
 * return  lRet
/*/
Static Function VldIni(oMdl,cField, uValue)

Do Case
    Case cField == 'GIF_MARK'
        if oMdl:GetOperation() == 3
            uValue := .F.
        Else
            uValue := .T.
        EndIf 
    Case cField == 'GI9_STATUS'
        if oMdl:GetOperation() == 3
            uValue := '1'
        EndIf
    Case cField == 'GI9_STATRA'
        if oMdl:GetOperation() == 3
            uValue := '0'
        EndIf  
        
EndCase

Return uValue

/*/{Protheus.doc} AfterActiv
//TODO Descrição auto-gerada.
@author flavio.martins
@since 29/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function AfterActiv(oView)

If oView:GetOperation() == MODEL_OPERATION_VIEW
	oView:HideFolder("PASTAS_GRID",2,2)
	oView:SelectFolder("PASTAS_GRID",1,2)      
Endif

oView:Refresh()

Return

/*/{Protheus.doc} TriggerMrk
//TODO Descrição auto-gerada.
@author flavio.martins
@since 29/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uValue, undefined, descricao
@type function
/*/
Static Function TriggerMrk(oMdl,cField, uValue)
Local oModel := oMdl:GetModel()

SumCte(oModel)

SetLocDest(oModel)

Return 


/*/{Protheus.doc} SumCte
//TODO Descrição auto-gerada.
@author flavio.martins
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uValue, undefined, descricao
@type function
/*/
Static Function SumCte(oModel)
Local oMdlGI9	:= oModel:GetModel('MASTERGI9')
Local oMdlGIF1	:= oModel:GetModel('DETAILGIF1')
Local oMdlGIF2	:= oModel:GetModel('DETAILGIF2')
Local nPesoTot	:= 0
Local nValTot	:= 0
Local nX		:= 0

For nX := 1 To oMdlGIF1:Length()

	If oMdlGIF1:GetValue('GIF_MARK', nX)
	
		nPesoTot += oMdlGIF1:GetValue('GIF_PESO', nX)
		nValTot  += oMdlGIF1:GetValue('GIF_VALOR', nX)
	
	Endif

Next

For nX := 1 To oMdlGIF2:Length()

	If oMdlGIF2:GetValue('GIF_MARK', nX)
	
		nPesoTot += oMdlGIF2:GetValue('GIF_PESO', nX)
		nValTot  += oMdlGIF2:GetValue('GIF_VALOR', nX)
	
	Endif

Next

oMdlGI9:SetValue('GI9_PCARGA', nPesoTot)
oMdlGI9:SetValue('GI9_VCARGA', nValTot)

Return

/*/{Protheus.doc} AddColab
//TODO Descrição auto-gerada.
@author flavio.martins
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uValue, undefined, descricao
@type function
/*/
Static Function AddColab(oMdl,cField, uValue)
Local oModel	:= oMdl:GetModel()
Local oMdlGIG	:= oModel:GetModel('DETAILGIG')
Local cAliasTmp	:= GetNextAlias()
Local cCodEmi	:= oMdl:GetValue('GI9_CODEMI')
Local cLocEmi	:= ''

SetLocDest(oModel)

dbSelectArea('GI6')
GI6->(dbSetOrder(1))

If GI6->(dbSeek(xFilial('GI6')+cCodEmi))
	cLocEmi := GI6->GI6_LOCALI
Endif

BeginSql Alias cAliasTmp

	SELECT GYG.GYG_CODIGO,
	       GYG.GYG_NOME
	FROM %Table:GYN% GYN
	INNER JOIN %Table:GQE% GQE ON GQE.GQE_FILIAL = GYN.GYN_FILIAL
	AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
	AND GQE.GQE_TRECUR = '1'
	AND GQE.%NotDel%
	INNER JOIN
	  (SELECT MIN(G55_SEQ) SEQLOC
	   FROM %Table:G55%
	   WHERE G55_FILIAL = %xFilial:G55%
	     AND G55_CODVIA = %Exp:uValue%
	     AND %NotDel%
	     AND G55_LOCORI = %Exp:cLocEmi%) AS G55 ON GQE.GQE_SEQ >= G55.SEQLOC
	INNER JOIN %Table:GYG% GYG ON GYG.GYG_FILIAL = %xFilial:GYG%
	AND GYG.GYG_CODIGO = GQE.GQE_RECURS
	AND GYG.%NotDel%
	WHERE GYN.GYN_FILIAL = %xFilial:GYN%
	  AND GYN.GYN_CODIGO = %Exp:uValue%
	  AND GYN.%NotDel%
    Group by GYG.GYG_CODIGO,
        GYG.GYG_NOME

EndSql

oMdlGIG:DelAllLine()

While (cAliasTmp)->(!(Eof()))

	If !(oMdlGIG:IsEmpty())
		oMdlGIG:AddLine()
	Endif

	oMdlGIG:SetValue('GIG_CODCON',(cAliasTmp)->GYG_CODIGO)
	
	(cAliasTmp)->(dbSkip())
	
End

oMdlGIG:GoLine(1)

(cAliasTmp)->(dbCloseArea())

Return

/*/{Protheus.doc} SetLocDest
//TODO Descrição auto-gerada.
@author flavio.martins
@since 29/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function SetLocDest(oModel)
Local oMdlGI9	:= oModel:GetModel('MASTERGI9')
Local oMdlGIF1	:= oModel:GetModel('DETAILGIF1')
Local oMdlGIF2	:= oModel:GetModel('DETAILGIF2')
Local cCodVia	:= oMdlGI9:GetValue('GI9_VIAGEM')
Local cAliasTmp	:= GetNextAlias()
Local cListCte	:= CTEGrid(oModel)

If oMdlGIF1:SeekLine({{"GIF_MARK",.T.}},.F.,.F.) .Or. oMdlGIF2:SeekLine({{"GIF_MARK",.T.}},.F.,.F.)
	
    cListCte := 'and G9Q.G9Q_CODIGO IN ('  + cListCte + ')'
    cListCte := "%"+cListCte+"%"
    
    BeginSql Alias cAliasTmp
	
		SELECT G55.G55_SEQ,
		       GI6.GI6_CODIGO,
		       G9Q.G9Q_CODIGO
		FROM %Table:G9Q% G9Q
		INNER JOIN %Table:G55% G55 ON G55.G55_FILIAL = %xFilial:G55%
		AND G55.G55_CODVIA = %Exp:cCodVia%
		AND G55.G55_LOCDES = G9Q.G9Q_LOCFIM
		AND G55.%NotDel%
		INNER JOIN %Table:GI6% GI6 ON GI6.GI6_FILIAL = %xFilial:GI6%
		AND GI6.GI6_LOCALI = G9Q.G9Q_LOCFIM
		AND GI6.GI6_ENCEXP ='1'
        WHERE 
            G9Q.G9Q_FILIAL = %xFilial:G9Q%
		  AND G9Q.%NotDel%
            %Exp:cListCte%
		ORDER BY G55.G55_SEQ DESC
			
	EndSql
			
	oMdlGI9:SetValue('GI9_CODREC', (cAliasTmp)->GI6_CODIGO)
	// SetUfsMdfe(oModel, (cAliasTmp)->G9Q_CODIGO)
	(cAliasTmp)->(dbCloseArea())
Else
	oMdlGI9:ClearField('GI9_CODREC')
	oMdlGI9:ClearField('GI9_DESREC')
	oMdlGI9:ClearField('GI9_UFFIM')
Endif

Return

/*/{Protheus.doc} SetUfsMdfe
//TODO Descrição auto-gerada.
@author flavio.martins
@since 01/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param cCodCte, characters, descricao
@type function
/*/
Static Function SetUfsMdfe(oModel, cCodCte)
Local cAliasG9P := GetNextAlias()
Local cUfEmi	:= ""
Local cUfRec	:= ""
Local oMdlGIA	:= oModel:GetModel('DETAILGIA')
Local nX		:= 0
Local aUF		:= {}

DEFAULT cCodCte := G9Q->G9Q_CODIGO

 cUfEmi	:= oModel:GetValue('GI9_UFINI')
 cUfRec	:= oModel:GetValue('GI9_UFFIM')

BeginSql Alias cAliasG9P

	SELECT G9P.G9P_ESTADO
	FROM %Table:G9P% G9P
	WHERE G9P.G9P_FILIAL = %xFilial:G9P%
	  AND G9P.G9P_CODIGO = %Exp:cCodCte%
	  AND G9P.G9P_ESTADO <> %Exp:cUfEmi%
	  AND G9P.G9P_ESTADO <> %Exp:cUfRec%
	  AND G9P.%NotDel%
	ORDER BY G9P.G9P_ITEM
	
EndSql

While (cAliasG9P)->(!(Eof()))

	Aadd(aUF,(cAliasG9P)->G9P_ESTADO)

	(cAliasG9P)->(dbSkip())

End

(cAliasG9P)->(dbCloseArea())


/*
If Len(aUF) == 0 
	//oMdlGIA:DelAllLine()
Else

	For nX := 1 To Len(aUF)
	
		If !(oMdlGIA:SeekLine({{"GIA_UF",aUF[nX]}},.T.,.T.))
		
			If !oMdlGIA:IsEmpty()
				oMdlGIA:AddLine()
			Endif
		
			oMdlGIA:SetValue('GIA_UF',aUF[nX])

		Else

			If oMdlGIA:IsDeleted()
				oMdlGIA:UndeleteLine()
			Endif
		
		Endif
	
	Next

Endif

If oMdlGIA:Length() > 0

	For nX := 1 To oMdlGIA:Length()
	
		oMdlGIA:GoLine(nX)
		
		If aScan(aUF,oMdlGIA:GetValue("GIA_UF")) == 0
			oMdlGIA:DeleteLine()
		Endif

	Next

Endif	
*/
Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} PosValid

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function PosValid(oModel)

    Local lRet      := .T.
    Local cMdlId	:= oModel:GetId()

    Local aMsg      := {}

    GTPAppendSwitch(.T.)
    
    lRet := GTPVldAgency(XFilial("G99"),;
                        oModel:GetModel("MASTERGI9"):GetValue("GI9_CODEMI"),;
                        "MDF")
    If ( lRet )

        // GTPSetMsg("- Agência: " + oModel:GetModel("MASTERGI9"):GetValue("GI9_CODEMI"))

        lRet := GTPVldAgency(XFilial("G99"),;
                        oModel:GetModel("MASTERGI9"):GetValue("GI9_CODREC"),;
                        "MDF")        

    Else
        aMsg := GTPRetMsg()
    EndIf
    
    If ( lRet )
        
        lRet := GTPVldDoc(oModel:GetModel("MASTERGI9"):GetValue("GI9_SERIE"),"MDF")

        If ( !lRet )
            aMsg := GTPRetMsg()
        EndIf

    Else
        aMsg := GTPRetMsg()    
    EndIf

    If ( !lRet )

        oModel:SetErrorMessage(cMdlId,"",cMdlId,"","PosValid",aMsg[1],aMsg[2])//,uNewValue,uOldValue)
        GTPResetMsg()
    
    EndIf
    If ( oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4 )
        If(oModel:HasField('MASTERGI9','GI9_MANIFE'))
            If vldManifOper(oModel)
                    If MsgYesNo( STR0062 + CRLF + STR0063, STR0064)//"Este Manifesto pode ser um Manifesto Operacional." + CRLF + "Deseja seguir como Manifesto Operacional?", "Tipo Manifesto")
                        lRet:= setManifOper(oModel)
                    Else
                         lRet:= oModel:SetValue('MASTERGI9','GI9_MANIFE','1')
                         lRet:= oModel:SetValue('MASTERGI9','GI9_STATRA','0')
                    EndIf
            EndIf 
        EndIf
    EndIf

Return lRet



/*/{Protheus.doc} vldManifOper
    (long_description)
    @type  Static Function
    @author marcelo.adente
    @since 22/09/2022
    @version 1.0
    @param oModel, object, Modelo do Manifesto
    @return serie, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function vldManifOper(oModel)
Local cQuery    := ''
Local cSQLAlias	:= GetNextAlias()
Local cCtes     := CTEGrid(oModel)
Local lRet      := .F.

If !Empty(Alltrim(cCtes))

    cQuery+= "SELECT "
    cQuery+= "    COUNT(Distinct(G9P.G9P_ESTADO)) ESTADOS "     + CRLF
    cQuery+= "FROM "  + RetSQLName('G9P') + " G9P"               + CRLF
    cQuery+= "WHERE "                                           + CRLF
    cQuery+= "    G9P.G9P_FILIAL = " + ValToSQL(XFilial('G9P')) + CRLF
    cQuery+= "    AND G9P.G9P_CODIGO IN (" + cCTes + ")"        + CRLF
    cQuery+= "    AND G9P.D_E_L_E_T_ = ' '  "                   + CRLF

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )

    If (cSQLAlias)->ESTADOS > 1 .Or. (cSQLAlias)->ESTADOS = 0
        lRet := .F.
    Else
        lRet:= .T.
    EndIF
Else
    lRet:= .F.
EndIF

Return lRet


/*/{Protheus.doc} CTEGrid(oModel)

    @type  Static Function
    @author marcelo.adente
    @since 22/09/2022
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CTEGrid(oModel)
Local oMdlGIF1	:= oModel:GetModel('DETAILGIF1')
Local oMdlGIF2	:= oModel:GetModel('DETAILGIF2')

Local cListCte	:= ''
Local nX := 0

If oMdlGIF1:SeekLine({{"GIF_MARK",.T.}},.F.,.F.) .Or. oMdlGIF2:SeekLine({{"GIF_MARK",.T.}},.F.,.F.)

	For nX := 1 To oMdlGIF1:Length()
		
		If oMdlGIF1:GetValue('GIF_MARK', nX) .and. !Empty(oMdlGIF1:GetValue('GIF_CODG99', nX))
			cListCte += oMdlGIF1:GetValue('GIF_CODG99', nX) + ','
		Endif
		
	Next
		
	For nX := 1 To oMdlGIF2:Length()
		
		If oMdlGIF2:GetValue('GIF_MARK', nX) .and. !Empty(oMdlGIF2:GetValue('GIF_CODG99', nX))
			cListCte += oMdlGIF2:GetValue('GIF_CODG99', nX) + ','
		Endif
		
	Next
    If !Empty(cListCte)
        cListCte := ValToSQL(Substr(cListCte,1,Len(cListCte)-1))
    Endif
EndIf   
Return cListCte


/*/{Protheus.doc} setManifOper
    (long_description)
    @type  Static Function
    @author marcelo.adente
    @since 26/09/2022
    @version 1.0
    @param oModel, object, Modelo do Manifesto
    @return lRet, Boolean, Ação concluída com êxito
/*/
Static Function setManifOper(oModel)
Local lRet:= .F.
Local cSerie := ''

cSerie:= GTPGetRules("SERIEMANIOP",,,"")
IIf(Empty(cSerie),cSerie:='000','') 

lRet:= oModel:SetValue('MASTERGI9','GI9_STATRA','6')
lRet:= oModel:SetValue('MASTERGI9','GI9_MANIFE','0')
lRet:= oModel:SetValue('MASTERGI9','GI9_SERIE',cSerie)

Return lRet

