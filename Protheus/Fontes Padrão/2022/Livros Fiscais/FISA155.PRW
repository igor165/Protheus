#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"

#DEFINE PULALINHA Chr(13) + Chr(10)
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA155

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FISA155( )
Local   oBrowse := Nil
Default cFiltro := ""
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("F1E")
oBrowse:SetDescription("Alíquotas Efetivas do Simples Nacional") // Descrição

oBrowse:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar"           ACTION 'VIEWDEF.FISA155' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Incluir"              ACTION 'VIEWDEF.FISA155' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE "Alterar"              ACTION 'VIEWDEF.FISA155' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE "Excluir"              ACTION 'VIEWDEF.FISA155' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE "Aprovar/Desaprovar"   ACTION 'FSA155APROV()'   OPERATION 5 ACCESS 0 //"Alterar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oPai      :=	FWFormStruct( 1, "F1E" ) // Campo criado indevidamente, deletado no ATUSX, mas o UPDDISTR cria mesmo assim.
Local oFilho    :=	FWFormStruct( 1, "F16") // Campo criado indevidamente, deletado no ATUSX, mas o UPDDISTR cria mesmo assim.
Local oModel
Local aAux      := {}

oModel	:=	MPFormModel():New('FISA155',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

oPai:SetProperty('F1E_MES'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
oPai:SetProperty('F1E_ANO'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

oModel:AddFields( 'MODEL_CAB' ,, oPai )

//Para o modelo das alíquotas efetivas irei adicionar grid
oModel:AddGrid( 'MODEL_ITEM', 'MODEL_CAB', oFilho)
oModel:SetRelation( 'MODEL_ITEM', { { 'F16_FILIAL', 'xFilial( "F16" )' }, { 'F16_MES', 'F1E_MES' },{ 'F16_ANO', 'F1E_ANO' }  },"F16_ANEXO" )

oModel:GetModel( 'MODEL_ITEM' ):SetUniqueLine( { 'F16_ANEXO' } )

oPai:SetProperty('F1E_ID'             ,     MODEL_FIELD_INIT    ,{||FSA155INIT("ID")} )
oPai:SetProperty('F1E_APROV'          ,     MODEL_FIELD_INIT    ,{||FSA155INIT("APROV")} )

oFilho:SetProperty('F16_ID'        ,     MODEL_FIELD_INIT    ,{||FSA155INIT("ID")} )
oFilho:SetProperty('F16_APROV'     ,     MODEL_FIELD_INIT    ,{||FSA155INIT("APROV")} )

oModel:SetPrimaryKey( { "" } )

oModel:SetDescription( "Alíquotas Efetivas" )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel 			:= 	FWLoadModel( 'FISA155' )
Local	oPai	        := 	FWFormStruct( 2, "F1E")
Local   oFilho	        := 	FWFormStruct( 2, "F16")
Local	oView 			:= 	FWFormView():New()
Local   cDescri			:= 'Visualização' 
Local cVersao 	        := GetVersao(.F.)

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAB', oPai, 'MODEL_CAB' )    
oView:AddGrid(  'VIEW_ITEM'   , oFilho  , 'MODEL_ITEM' )

oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

oPai:RemoveField( 'F1E_ID' )
oPai:RemoveField( 'F1E_APROV' )    

oView:EnableTitleView( 'VIEW_CAB', "Período das Alíquotas Efetivas" )

oFilho:RemoveField( 'F16_ID' )
oFilho:RemoveField( 'F16_APROV' )
oFilho:RemoveField( 'F16_MES' )
oFilho:RemoveField( 'F16_ANO' )

oView:SetOwnerView( 'VIEW_CAB'   , 'SUPERIOR'   )
oView:SetOwnerView( 'VIEW_ITEM'   , 'INFERIOR'   )

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER")
EndIF

Return oView

Static Function VALIDACAO( oModel )

Local nOperation 	:= oModel:GetOperation()

Local cUf 	    := ''
Local dDtIni
Local cTpRec	:= ''
Local cMes      := ''
Local cAno      := ''
Local lRet      := .T.
Local cTpRec    := ''
Local nIndex    := 0

cMes 		:= oModel:GetValue ('MODEL_CAB',"F1E_MES")
cAno 		:= oModel:GetValue ('MODEL_CAB',"F1E_ANO")

F1E->(dbSetOrder(1))

IF nOperation == MODEL_OPERATION_INSERT

    If	F1E->( MsSeek ( xFilial('F1E') +  cAno + cMes ) )
        //Já existe encargo para o período.
        lRet:= .F.
        Help( ,, 'Help',, "Já existem alíquotas cadastradas para este Anexo e Período.", 1, 0 ) //"Anexo já cadastrado para este início de vigência."
    EndIF

ElseIf nOperation == MODEL_OPERATION_DELETE

    IF F1E->F1E_APROV == "1"
        lRet:= .F.
        Help( ,, 'Help',, "Não será possível excluir estas alíquotas pois possuem aprovação confirmada.", 1, 0 ) //"Anexo já cadastrado para este início de vigência."
    EndIF

ElseIf nOperation == MODEL_OPERATION_UPDATE .AND. !IsInCallStack("FSA155APROV")

    IF F1E->F1E_APROV == "1"
        lRet:= .F.
        Help( ,, 'Help',, "Não será possível alterar alíquotas já aprovadas.", 1, 0 ) //"Anexo já cadastrado para este início de vigência."
    EndIF

EndIf

Return lRet

Function FSA155APROV()

FWExecView('Alíquotas Efetivas (' + Iif(F1E->F1E_APROV == '1' ,  "Cancelar Aprovação" , "Aprovação" )  + ')' ,'FISA155', MODEL_OPERATION_UPDATE,, { || .T. } , { || FSA155ALQOK() })

Return

Function FSA155ALQOK ()

Local oModel    := FWModelActive()
Local oGen	    := oModel:GetModel('MODEL_ITEM' )
Local oView 	:= FWViewActive()
Local cMes      := F1E->F1E_MES
Local cAno      := F1E->F1E_ANO
Local lAltera   := .F.
Local cConteudo := ""
Local nValRefresh   := 0
Local dProxMes  := MonthSum(CtoD("01/" + cMes + "/" + cAno)  , 1)
Local cPerMsg   := MesExtenso(Month(dProxMes)) + " / " + Year2Str(dProxMes)

oGen:GoLine( 1 )
    
nValRefresh	:= oGen:GetValue("F16_CPP",1)
oGen:SetValue('F16_CPP', 99 )
oview:Refresh( 'MODEL_ITEM' )

oGen:SetValue('F16_CPP', nValRefresh )
oview:Refresh( 'MODEL_ITEM' )

If F1E->F1E_APROV == '1' //Já está desaprovado        
    cConteudo := "2"
    lAltera := ApMsgYesNo("Cancelar aprovação das alíquotas?" +PULALINHA+PULALINHA+;
                          "Estas alíquotas estão aprovadas para uso no faturamento dos documentos de " + cPerMsg + "." + ;
                          " Deseja continuar?") 
Else    
    cConteudo := "1"
    lAltera := ApMsgYesNo("Confirmar aprovação das alíquotas?" +PULALINHA+PULALINHA+;
                          "Clicando em SIM você estará autorizando a utilização destas alíquotas no faturamento dos documentos de " + cPerMsg + "." + ;
                          " Deseja continuar?") 
EndIF

If lAltera

    If F16->(MsSeek(xFilial("F16") + cAno + cMes))
    
        Do While !F16->(Eof ()) .AND. F16->F16_FILIAL == xFilial("F16") .AND. F16->F16_MES == cMes .AND. F16->F16_ANO == cAno
            RecLock('F16',.F.)
            
            F16->F16_APROV := cConteudo
            
            F16->(msUnlock())

            F16->(DbSkip ())

        EndDo

        RecLock('F1E',.F.)        
        F1E->F1E_APROV := cConteudo
        F1E->(msUnlock())
        
    EndIf

EndIF

Return lAltera


Function FSA155INIT(cOpcao)

Local cRet  := ""

If cOpcao == "ID"
    cRet    := FWUUID("FISA155")
ElseIF cOpcao == "APROV"
    cRet    := "2"
EndIF
Return cRet