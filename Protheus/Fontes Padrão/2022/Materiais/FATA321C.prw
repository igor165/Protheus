#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH' 
#include "FATA321C.CH"

#DEFINE STRUCT_TITULO		1
#DEFINE STRUCT_ORDEM		2
#DEFINE STRUCT_ID			3
#DEFINE STRUCT_TIPO			4
#DEFINE STRUCT_TAMANHO		5
#DEFINE STRUCT_DECIMAL		6
#DEFINE STRUCT_DESCRICAO	7
#DEFINE STRUCT_PICTURE		8
#DEFINE STRUCT_CONSF3		9
#DEFINE STRUCT_EDITAVEL		10
#DEFINE STRUCT_VALID		11
#DEFINE STRUCT_WHEN			12
#DEFINE STRUCT_OPCOES		13
#DEFINE STRUCT_INIPADRAO	14
#DEFINE STRUCT_VIRTUAL		15

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW	2

#DEFINE _USUAR	 	1  
#DEFINE _SENHA	 	2  
#DEFINE _ISAGENDA 	3  
#DEFINE _PREFIXO	2
#DEFINE _TIMEMIN	13

Static _lForcaGrv		:= .F.
Static _nLnGridEnt	:= 0

//----------------------------------------------------------
/*/{Protheus.doc} FT321Ativ()
Atividades do vendedor (area de trabalho)

posicoes do array aInfoUser Montado
cUser             [2][1]
cSenhaUsu         [2][2]
lAgenda           [2][3]
dDtAgeIni         [2][4]
dDtAgeFim         [2][5]
lTarefa           [2][6]
dDtTarIni         [2][7]
dDtTarFim         [2][8]
cEndEmail         [2][9]
SA3->A3_SINCTAF  [2][10]
SA3->A3_SINCAGE  [2][11]
SA3->A3_SINCCON  [2][12]
SA3->A3_TIMEMIN  [2][13]
SA3->A3_BIAGEND  [2][14]
SA3->A3_BITAREF  [2][15]
SA3->A3_BICONT   [2][16]
SA3->A3_PERAGE   [2][17]
SA3->A3_PERTAF   [2][18]
SA3->A3_HABSINC  [2][19]

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321Ativ(xRotAuto,nOpc) 


Static aCrmInfVen := {}//variavel que guarda as informações do vendedor logado, quando o modulo for CRM

Local aInfoUser := {}
Local cCodVnd := ""
Local lAtualizaAT := .F. //verifica se atualização deve ser automatica, se existir senha ja cadastrada no Banco
Local cFilAD1Atu 		:= AD1->( DBFilter() )
Local aAreaAD1		:= AD1->(GetArea())

Private INCLUI := .F.
Private ALTERA := .F.

If !Empty( cFilAD1Atu )
	AD1->(dbCloseArea())
	dbSelectArea("AD1")
EndIf

If ( nModulo == 73 )
   
	cCodVnd := CRMXRetVend()
	
	DbSelectArea("SA3")
	DbSetOrder(1) //A3_FILIAL+A3_COD
	  
	If !Empty(cCodVnd) .AND. SA3->(DbSeek(xFilial("SA3")+cCodVnd))	
	    If Empty(SA3->A3_SNAEXG)
	  	    	aInfoUser :=  GetInfoUserSinc("S")
	  	Else
	  		If Empty(aInfoUser)
	  	     	aInfoUser :=  GetInfoUserSinc("I")//parametro como 'I' para nao cair nas condiçoes das telas de autenticação ('U','S'), somente para prencher os dados refenrente a datas, horas, etc..  
	  	     	aInfoUser[2,2] := FWAES_decrypt(Decode64(AllTrim(SA3->A3_SNAEXG)))
	  	     	lAtualizaAT := .T.	
	  	  	 EndIf
	  	EndIf
  	    // Adcionando dados Complementares ao Array
  	    Aadd(aInfoUser[2],IIF(SA3->A3_SINCTAF == "S",.T.,.F.))//10
  	    Aadd(aInfoUser[2],IIF(SA3->A3_SINCAGE == "S",.T.,.F.))//11
  	    Aadd(aInfoUser[2],IIF(SA3->A3_SINCCON == "S",.T.,.F.))//12
  	    Aadd(aInfoUser[2],SA3->A3_TIMEMIN)//13
        Aadd(aInfoUser[2],IIF(SA3->A3_BIAGEND == "1",.T.,.F.))//14
  	    Aadd(aInfoUser[2],IIF(SA3->A3_BITAREF == "1",.T.,.F.))//15
  	    Aadd(aInfoUser[2],IIF(SA3->A3_BICONT == "1",.T.,.F.))//16
  	    Aadd(aInfoUser[2],SA3->A3_PERAGE)//17
  	    Aadd(aInfoUser[2],SA3->A3_PERTAF)//18	 
  	    Aadd(aInfoUser[2],IIF(cPaisLoc == "BRA" .And. SA3->A3_HABSINC == "S",.T.,.F.))//19	 	    	

 	    aCrmInfVen := aClone(aInfoUser)		
        If !Empty(aInfoUser) .AND. lAtualizaAT //so executará se existir senha ja cadastrada no banco
  	   	 	LjMsgRun(STR0049,STR0050,{|| Ft321SncCrm(aInfoUser)})//Processando... //Aguarde
  	    EndIf
  	    LjMsgRun(STR0059,STR0050,{||FWExecView("",'FATA321C',  MODEL_OPERATION_UPDATE,, {|| .T. }  ) })//Carregando Interface... //Aguarde
	Else
        Aviso(STR0046,STR0061,{STR0060},2)//"Atenção"//" Este usuário não esta associado a nenhum vendedor! "//"OK"
	EndIf
Else
	_lForcaGrv		:= .F.
	_nLnGridEnt	:= 0
	cCodVnd := Ft320RpSel()
	LjMsgRun(STR0059,STR0050,{||FWExecView("",'FATA321C',  MODEL_OPERATION_UPDATE,, {|| .F. }  ) })//Carregando Interface... //Aguarde
EndIf

EndSyncSession(cValToChar(ThreadId()))

RestArea(aAreaAD1)    

Return


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Atividades do vendedor (area de trabalho)

@Return model
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel 		:= MPFormModel():New( 'FATA321C' ,,{|oModel| FT321PosVld( oModel ) }, { |oModel| Ft321Commit( oModel ) },{ |oModel| Ft321Cancel( oModel ) }) 
Local oStruRep 	:= nil
Local oStruEntida	:= nil
Local oStruAtiv	:= nil
Local oStruFiltros := nil
Local aCamposRep:= {}
Local aCamposEnt := {}
Local aFieldUAD7 := {}
Local aFieldUAD8 := {}
Local nX			:= 0
Local cField		:= ""
Local oModelRep := nil 
Local oModelEnt := nil 
Local oModelAtiv := nil 
Local cCodVnd := ""
Local nCntField := 0
Local nTmCodEnt	:= GetSX3Cache("A1_COD",  "X3_TAMANHO") 
Local nTmLojEnt	:= GetSX3Cache("A1_LOJA", "X3_TAMANHO")

Static aCamposAtiv := {}
Static aObrigat 	 := {}

If ( nModulo == 73 )
	cCodVnd :=  CRMXRetVend() //vendedor logado
Else
	cCodVnd := Ft320RpSel()
EndIf

//------------------------------------------------------
//		Representante
//------------------------------------------------------
oStruRep := FWFormModelStruct():New()
aCamposRep := {"A3_COD", "A1_NOME", "US_NOME"}
FT321ADDField(oStruRep, aCamposRep, TYPE_MODEL)
oModel:AddFields( 'MODEL_REP',,oStruRep ,,, {|| } )
oModel:GetModel( 'MODEL_REP' ):SetDescription(STR0028)

//--------------------------------------------------------------------------------------------------
//		Filtros - estrutura feita apenas para guardar os filtros correntes aplicado pelo usuário
//--------------------------------------------------------------------------------------------------
oStruFiltros := FWFormModelStruct():New()
oStruFiltros:AddField(STR0001, "", "ENTIDADE", "C", 3 )//"Entidade"
oStruFiltros:AddField(STR0002, "", "CODENT",   "C", nTmCodEnt )//"Cod Entidade"
oStruFiltros:AddField(STR0003, "", "LOJENT",   "C", nTmLojEnt )//"Loja Entidade"
oStruFiltros:AddField(STR0004, "", "DATA",     "D", 8 )//"Data"
oStruFiltros:AddField(STR0005, "", "MODO_ANI", "N", 1 )//"Modo Exib. Ani"
oModel:AddFields( 'MODEL_FILTROS','MODEL_REP',oStruFiltros ,,, {|| } )
oModel:GetModel( 'MODEL_FILTROS' ):SetDescription(STR0006)//"Filtros"

//------------------------------------------------
//		Entidades do Representante
//------------------------------------------------
oStruEntida := FWFormModelStruct():New()
aCamposEnt := {"ADL_FILENT", "ADL_ENTIDA", "ADL_CODENT", "ADL_LOJENT", "ADL_NOME"} 
oStruEntida := FWFormModelStruct():New()
FT321ADDField(oStruEntida, aCamposEnt, TYPE_MODEL)

oModel:AddGrid( 'MODEL_ENT_GRID', 'MODEL_REP', oStruEntida,/*Pre-Validacao*/, /*Pos-Validacao*/,/*bPre*/,/*bPost*/, /*bLoad*/) 
oModel:GetModel( 'MODEL_ENT_GRID' ):SetDescription(STR0007)//"Contas do vendedor"

//------------------------------------------------
//		Atividades
//------------------------------------------------

//verifica ponto de entrada para buscar campos do array de atividades
If ExistBlock("FT321ATIV")
	aCamposAtiv := ExecBlock("FT321ATIV",.F.,.F.)
Else
	
	aCamposAtiv := {}
	
	aAdd(aCamposAtiv,{"AD7_TOPICO"		,"AD8_TOPICO"	})  
	aAdd(aCamposAtiv,{"AD7_DATA"		,"AD8_DTINI"	})
	aAdd(aCamposAtiv,{"AD7_HORA1"		,"AD8_HORA1"	}) 
	aAdd(aCamposAtiv,{"AD7_HORA2"		,"AD8_HORA2"	}) 
	aAdd(aCamposAtiv,{"AD7_ALERTA"		,""				}) 
	aAdd(aCamposAtiv,{"AD7_TPALER"		,""				}) 
	aAdd(aCamposAtiv,{""					,"AD8_DTREMI"	})
	aAdd(aCamposAtiv,{""					,"AD8_HRREMI"	}) 
	aAdd(aCamposAtiv,{"AD7_MEMO"		,"AD8_MEMO"	}) 
	aAdd(aCamposAtiv,{"AD7_CODCLI"		,"AD8_CODCLI"	}) 
	aAdd(aCamposAtiv,{"AD7_LOJA"		,"AD8_LOJCLI"	}) 
	aAdd(aCamposAtiv,{"AD7_PROSPE"		,"AD8_PROSPE"	}) 
	aAdd(aCamposAtiv,{"AD7_LOJPRO"		,"AD8_LOJPRO"	}) 
	aAdd(aCamposAtiv,{""					,"AD8_STATUS"	}) 
	aAdd(aCamposAtiv,{""					,"AD8_PRIOR"	}) 
	aAdd(aCamposAtiv,{""					,"AD8_PERC"	}) 
	aAdd(aCamposAtiv,{"AD7_CONTAT"		,"AD8_CONTAT"	}) 
	aAdd(aCamposAtiv,{"AD7_NROPOR"		,"AD8_NROPOR"	}) 
	aAdd(aCamposAtiv,{"AD7_LOCAL"		,""				}) 
	aAdd(aCamposAtiv,{""					,"AD8_TAREFA"	}) 
	aAdd(aCamposAtiv,{""					,"AD8_EVENTO"	}) 
	aAdd(aCamposAtiv,{""					,"AD8_ANIVER"	}) 
	aAdd(aCamposAtiv,{"AD7_EMLNAM"		,"AD8_EMLNAM"	}) 
	aAdd(aCamposAtiv,{"AD7_LASTMO"		,"AD8_LASTMO"	}) 
	aAdd(aCamposAtiv,{"AD7_VENDAP"		,""				}) 
	aAdd(aCamposAtiv,{"AD7_DATAAP"		,""				}) 
	aAdd(aCamposAtiv,{"AD7_SEQAP"		,""				}) 
	aAdd(aCamposAtiv,{"AD7_AGEREU"		,""				}) 
	aAdd(aCamposAtiv,{"AD7_CODUMO"		,""				}) 
	aAdd(aCamposAtiv,{"AD7_EMAILP"		,""				}) 

	SX3->( DBSetOrder(1) )
	
	If SX3->( DBSeek( "AD7" ) ) 
		While SX3->X3_ARQUIVO == "AD7"
			cField := AllTrim(SX3->X3_CAMPO)
			If SX3->X3_PROPRI == "U" .And. X3Usado(cField)
				aAdd(aFieldUAD7,cField)
			EndIf
			SX3->( DBSkip() )
		End
	EndIf
	
	If SX3->( DBSeek( "AD8" ) ) 
		While SX3->X3_ARQUIVO == "AD8"
			cField := AllTrim(SX3->X3_CAMPO)
			If SX3->X3_PROPRI == "U" .And. X3Usado(cField)
				aAdd(aFieldUAD8,cField)
			EndIf
			SX3->( DBSkip() )
		End
	EndIf
	
	For nX := 1 To Len( aFieldUAD7 )
		aAdd( aCamposAtiv, {aFieldUAD7[nX],""} )
	Next
	
	For nX := 1 To Len( aFieldUAD8 )
		aAdd( aCamposAtiv, {"",aFieldUAD8[nX]} )
	Next  
	
EndIf				   

//Proteção pra remover da estrutura campos que nao existam na base do cliente
FT321RemFields(@aCamposAtiv)

oStruAtiv := FWFormModelStruct():New()
oStruAtiv:AddField(STR0031, "" , "TIPO_ATIV", "C", 1,,,, {STR0029,STR0030}    , .F.,  ,,,.T., ) //"Tipo Atividade" //"1=Agendamento" "2=Tarefa"
aObrigat := {}
FT321ADDField(oStruAtiv, aCamposAtiv, TYPE_MODEL)
oStruAtiv:AddField("Recno", "" , "RECNO", "N", 10)

oStruAtiv:AddTrigger("TIPO_ATIV", "RECNO",{||.T.}, {||FT321Trigger(oModel, oStruAtiv)})

FT321AddTrigger(oStruAtiv, aCamposAtiv)

oModel:AddGrid('MODEL_ATIV_GRID',;
               'MODEL_REP',;
               oStruAtiv,;
               {|oMdlGrid, nLine, cAction, cField, xNewValue, xOldValue| FT321LPrAtv(oMdlGrid, nLine, cAction, cField, xNewValue, xOldValue)} /*bLinePre*/,;
               {|oMdlGrid| FT321LPos(oMdlGrid)},;
               /*bPre*/,;
               /*bPost*/,;
               /*bLoad*/)  
oModel:GetModel( 'MODEL_ATIV_GRID' ):SetDescription(STR0008)
oModel:GetModel( 'MODEL_ATIV_GRID' ):SetOptional( .T. )

//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetDescription(STR0008)
oModel:SetPrimaryKey( {} )

//--------------------------------------
//		Carrega dados 
//--------------------------------------
oModelRep := oModel:GetModel("MODEL_REP")
oModelEnt := oModel:GetModel("MODEL_ENT_GRID")
oModelAtiv := oModel:GetModel("MODEL_ATIV_GRID")

oModelRep:SetLoad( {|| Ft321LRep(cCodVnd, "")} )
oModelEnt:SetLoad( {|| Ft321LEntida(cCodVnd)} )
oModelAtiv:SetLoad( {|| Ft321LAtiv(cCodVnd, aCamposAtiv, oModel)} )

For nCntField := 1 To len(aCamposAtiv)
	If Empty(aCamposAtiv[nCntField,1])
		If Len(aCamposAtiv[nCntField])>1 .AND. aCamposAtiv[nCntField,2]<> NIL .AND. !Empty(aCamposAtiv[nCntField,2])
			oStruAtiv:SetProperty( AllTrim(aCamposAtiv[nCntField,2])	, MODEL_FIELD_INIT , {||""})
		EndIf
	Else
		oStruAtiv:SetProperty( AllTrim(aCamposAtiv[nCntField,1])	, MODEL_FIELD_INIT , {||""})
	EndIf
Next nCntField

//--------------------------------------
//		ajusta inicializadores padroes
//--------------------------------------
oStruAtiv:SetProperty( 'TIPO_ATIV'   ,MODEL_FIELD_OBRIGAT, .T.)
oStruAtiv:SetProperty( 'AD7_HORA2'   ,MODEL_FIELD_OBRIGAT, .T.)
oStruAtiv:SetProperty( 'AD8_HRREMI'  ,MODEL_FIELD_OBRIGAT, .F.)

oStruAtiv:SetProperty( 'AD7_HORA1'   ,MODEL_FIELD_VALID, {||Ft321VldHr(FwFldGet('AD7_HORA1'),FwFldGet('AD7_HORA2'))})
oStruAtiv:SetProperty( 'AD7_HORA2'   ,MODEL_FIELD_VALID, {||Ft321VldHr(FwFldGet('AD7_HORA1'),FwFldGet('AD7_HORA2'))})

oStruAtiv:SetProperty( 'TIPO_ATIV' , MODEL_FIELD_WHEN , {|oModelGrid|FT321WhTpAtiv(oModelGrid)})

FT321WhenTipo(oModel)
 
If IsInCallStack("Ft320WArea")
	oModel:setActivate({||  PosicionaReg(oModelEnt) })
EndIf

oModel:GetModel('MODEL_ENT_GRID'):SetNoInsertLine(.T.)
oModel:GetModel('MODEL_ENT_GRID'):SetNoUpdateLine(.T.)
oModel:GetModel('MODEL_ENT_GRID'):SetNoDeleteLine(.T.)
Return oModel


//----------------------------------------------------------
/*/{Protheus.doc} FT321LPrAtv()
Pré-Valid da Grid das atividades
@Return lRet, logico, Retorno da validação
@author Vendas CRM
@since Abr/2018
/*/
//----------------------------------------------------------
Static Function FT321LPrAtv(oMdlGrid, nLine, cAction, cField, xNewValue, xOldValue)
Local lRet			:= .T.
Local oView		:= NIL
Local nLinEnt		:= 0

If	cAction == "CANSETVALUE"
	If	cField <> "TIPO_ATIV" .AND. Empty(oMdlGrid:GetValue("TIPO_ATIV"))
		lRet	:= .F.	// O primeiro campo a ser informado na Grid das Atividades é o Tipo da Atividade.
	EndIf
ElseIf	cAction == "SETVALUE" .OR. cAction == "DELETE" .OR. cAction == "UNDELETE"
	oView			:= FwViewActive()
	nLinEnt		:= oView:GetModel('MODEL_ENT_GRID'):GetLine()
	_nLnGridEnt	:= nLinEnt
	_lForcaGrv		:= .T.
	oView			:= NIL
EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} FT321PosVld()

PosValid do modelo de dados

@Return lRet, logico, Retorno da validacao.
@author Vendas CRM
@since 10/12/2013
/*/
//----------------------------------------------------------
Static Function FT321PosVld( oModel )
Local oMdlAtiv	:= oModel:GetModel("MODEL_ATIV_GRID")
Local nX			:= 0
Local lRet			:= .T.

For nX := 1 To oMdlAtiv:Length()
	oMdlAtiv:GoLine( nX )
	lRet := FT321Obrigat()
	If !lRet
		Exit
	EndIf
Next nX

Return( lRet )

//----------------------------------------------------------
/*/{Protheus.doc} PosicionaReg()
PosicionaReg - Atividades do vendedor (area de trabalho)

@Return oModel
@author Vendas CRM
@since 10/12/2013
/*/
//----------------------------------------------------------
Static Function PosicionaReg(oModel)

Local aBusca	:= {}  
Local lRet		:= .F.

aAdd(aBusca,{"ADL_ENTIDA",ADL->ADL_ENTIDA})
aAdd(aBusca,{"ADL_CODENT",ADL->ADL_CODENT})
aAdd(aBusca,{"ADL_LOJENT",ADL->ADL_LOJENT})

lRet := oModel:SeekLine(aBusca)

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
ViewDef - Atividades do vendedor (area de trabalho)

@Return view
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oModel 		:= FWLoadModel( 'FATA321C' ) 	
Local oView		:= FWFormView():New() 			//Cria o objeto da view
Local oStruRep  	:= FWFormViewStruct():New()		
Local oStruAtiv 	:= FWFormViewStruct():New()  
Local oStruEntida	:= FWFormViewStruct():New()  
Local nX 			:= 0
Local oCalend := Nil
Local lFt320TBt	:= ExistBlock("FT320TBT")
Local aButUsr		:= {}  							// Botoes de usuario 

If lFt320TBt
	aButUsr := ExecBlock("FT320TBT",.F.,.F.)
	If ValType(aButUsr) <> "A"
		aButUsr := {}
	EndIf
EndIf

//----------------------------------------------------------
//		Cria a estrutura da view baseada na estrutura do model
//----------------------------------------------------------
oStruAtiv:AddField("TIPO_ATIV", "01", STR0031, STR0031, {} , "C",,,,.T.,,,  {STR0029,STR0030}   ,  , ,.T., )  //"Tipo Atividade" //"1=Agendamento" "2=Tarefa"
FT321ViewStr(oModel, "MODEL_ATIV_GRID", @oStruAtiv) 
FT321ViewStr(oModel, "MODEL_REP", @oStruRep)
FT321ViewStr(oModel, "MODEL_ENT_GRID", @oStruEntida)
oStruAtiv:AddField("RECNO", "99", "Recno", "Recno", {} , "N") 


//Ajustes nas estruturas da view
oStruRep:SetProperty( 'A3_COD' , MVC_VIEW_ORDEM,'01')	
oStruRep:SetProperty( 'A3_COD' , MVC_VIEW_TITULO, STR0032)	//Cód Representante
oStruRep:SetProperty( 'A3_COD' , MVC_VIEW_CANCHANGE, .F.)	
oStruRep:SetProperty( 'A1_NOME' , MVC_VIEW_ORDEM,'02')	
oStruRep:SetProperty( 'A1_NOME' , MVC_VIEW_TITULO, STR0033)//Representante ativo	
oStruRep:SetProperty( 'A1_NOME' , MVC_VIEW_CANCHANGE, .F.)	
oStruRep:SetProperty( 'US_NOME' , MVC_VIEW_ORDEM,'03')
oStruRep:SetProperty( 'US_NOME' , MVC_VIEW_TITULO, STR0034)//Conta Selecionada
oStruRep:SetProperty( 'US_NOME' , MVC_VIEW_CANCHANGE, .F.)	
oStruAtiv:SetProperty( 'RECNO' , MVC_VIEW_CANCHANGE, .F.)

//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel( oModel )	//define que a view vai usar o model mata850
oView:SetDescription(STR0062) //"Área de Trabalho"

If Len(aButUsr) > 0
	For nX := 1 to Len(aButUsr)
		oView:AddUserButton(aButUsr[nX][4], '',aButUsr[nX][2]) //"Ocorrencias"
	Next nX
EndIf

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "LINEONE", 10 )  // Box dos botoes
oView:CreateHorizontalBox( "LINETWO", 30 )  // Box do grid
oView:CreateHorizontalBox( "LINETHREE", 60)  // Box do grid


oView:CreateVerticalBox( "LEFT_3",  73, 'LINETHREE')  //
oView:CreateVerticalBox( "RIGHT_3", 27, 'LINETHREE')  //
//oView:CreateVerticalBox( "BUTTON", 15,   'LINETWO') //


// Quebra em 2 "box" vertical para receber algum elemento da view
oView:CreateVerticalBox( 'BOXLEFT', 73, 'LINETWO' )
oView:CreateVerticalBox( 'BOXRIGHT', 27, 'LINETWO' )


// divide o box 'RIGHT_3' em duas partes na orizontal ,na qual a area 'BUTTON' vai a tela de sincronizacao
oView:CreateHorizontalBox( 'TOP', 65, "RIGHT_3")  // Box top
oView:CreateHorizontalBox( 'BUTTON', 35, "RIGHT_3")  // Box button

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField( 'VIEW_REP', oStruRep, 'MODEL_REP' ) //cria componente associado ao componente de formulario (FAKE) do model 
oView:AddGrid('VIEW_ENT_GRID'/*<cViewID>*/,;
              oStruEntida/*<oStruct>*/,;
              'MODEL_ENT_GRID'/*[cSubModelID]*/,;
              /*<uParam4 >*/,;
              /*[bGotFocus]*/) //grid das ENTIDADES
oView:AddGrid('VIEW_ATIV_GRID'/*<cViewID>*/,;
              oStruAtiv/*<oStruct>*/,;
              'MODEL_ATIV_GRID'/*[cSubModelID]*/,;
              /*<uParam4 >*/,;
              /*[bGotFocus]*/) //grid das ATIVIDADES

//--------------------------------------
//		Associa os componentes ao Box
//--------------------------------------

oView:SetOwnerView( 'VIEW_REP', 'LINEONE' )
oView:SetOwnerView( 'VIEW_ENT_GRID', 'BOXLEFT' ) 
oView:SetOwnerView( 'VIEW_ATIV_GRID', 'LEFT_3' ) // Relaciona o identificador (ID) da View com o "box" para exibição  

oView:AddOtherObject('VIEW_CALEND', {|oPanel| FT321ADDCalend(oPanel, oModel, @oCalend)} ) // botoes com as acoes
oView:AddOtherObject('VIEW_OUTROS', {|oPanel| FT321ADDOthers(oPanel, oModel)} ) // botoes com as acoes

If ( nModulo == 73 ) // verifica se o mudolo e crm, se for cria a tela de sincronizacao dentro da tela de atividades.
	oView:AddOtherObject('VIEW_BUTTON', {|oPanel| MntViewSinc(oPanel)} ) //cria a tela de sincronismo dentro do box 'BUTTON' do model  
	oView:SetOwnerView( 'VIEW_BUTTON', 'BUTTON' ) // Relaciona o identificador (ID) da View com o "box" para exibição
	//Adiciona Botão para sincronizar Manual , somente pelo Modulo CRM
	oView:AddUserButton( STR0051,'', {|| LjMsgRun(STR0052,STR0052,{|| Ft321SincExg() }) } )//Sincronizar//Sincronizando//Sincronizando  
EndIf

oView:SetOwnerView( 'VIEW_CALEND', 'BOXRIGHT' ) // Relaciona o identificador (ID) da View com o "box" para exibição 
oView:SetOwnerView( 'VIEW_OUTROS', 'TOP' ) // Relaciona o identificador (ID) da View com o "box" para exibição 

oView:EnableTitleView('VIEW_ENT_GRID') //exibe uma descricao antes do box do grid 
oView:EnableTitleView('VIEW_ATIV_GRID') //exibe uma descricao antes do box do grid 

oView:SetViewProperty('VIEW_ENT_GRID','CHANGELINE',{ {|oView, cIdGrid| FT321EntPos(oView, cIdGrid, @oCalend)} }) 

oView:AddUserButton(STR0042,'',{|| CRMA140(,,AD7->AD7_CODUMO)})//'Check In\Out'


If ( nModulo == 73 ) 
	FT320AtuParamThread()
	CreateSyncSession(cValToChar(ThreadId()))
Else
	//Atualiza os dados da view dos representantes e filtra as atividades
	oView:SetAfterViewActivate({|oView, cIdGrid| oView:Refresh("VIEW_ENT_GRID"), FT321EntPos(oView,"MODEL_ENT_GRID",@oCalend), oView:Refresh("VIEW_REP")})
EndIf 

Return oView

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Atividades do vendedor (area de trabalho)

@Return MenuDef
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FATA321C" ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} Ft321ViewStr()

Monta a estrutura da view baseada na estrutura do model
@param oModel, model 
@param cNameModel, Caracter, Nome do model
@param oViewStruct, View, estrutura do model
    
@author Vendas CRM
@since 31/07/2013
/*/
//-------------------------------------------------------------------- 
Function Ft321ViewStr(oModel, cNameModel, oViewStruct)

Local nI 					:= 0
Local oStructModel		:= oModel:GetModel(cNameModel):GetStruct()		//estrutura do model do grid
Local aCamposModel		:= oStructModel:GetFields()						//array de campos da estrutura do grid no model 
Local aNomeCampos		:= {}
Local aViewFields		:= oViewStruct:GetFields() 						//array de campos da estrutura do grid na view
Local cPicture			:= ""


//-------------------------------------------------------------------------------------
//		Adiciona um campo na estrutura da view baseada na estrutura do model (grid)
//-------------------------------------------------------------------------------------
For nI := 1 to Len(aCamposModel)
	Aadd(aNomeCampos, aCamposModel[nI][3])
Next nI

FT321ADDField(oViewStruct, aNomeCampos, TYPE_VIEW )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FT321ADDCalend()

Cria Area do Calendario
@param oPanel, painel, objeto onde sera criado o calendario
@param oModel, model, modelo
@param oCalend, objeto, objeto do calendario que sera construido
    
@author Vendas CRM
@since 31/07/2013
/*/
//-------------------------------------------------------------------- 
Function FT321ADDCalend(oPanel, oModel, oCalend)

Local oFwLayer	 	:= Nil
Local oScrCalend 	:= Nil	
Local oPnl 			:= Nil

DEFINE FONT oTFont 
oTFont:= TFont():New("Arial",,15,.T.,.T.)

oFwLayer := FwLayer():New()
oFwLayer:init(oPanel,.F.)

oFWLayer:addCollumn( "COL1",100, .T. , "LINHA2") 
oFWLayer:addWindow( "COL1", "WIN1", STR0058, 100, .F., .F., , "LINHA2")//Calendário
	
oPanel := oFWLayer:GetWinPanel("COL1","WIN1","LINHA2") 

//Cria uma Scroll para a area do calendario
oScrCalend := TScrollArea():New(oPanel,01,01,100,100,.T.,.F.,.F.)
oScrCalend:Align := CONTROL_ALIGN_ALLCLIENT

oPnl := TPanel():New(001,001,"",oScrCalend,,,,,,100,100)

oCalend := MsCalend():New(12,05,oPnl) //cria o calendario
oCalend:align := CONTROL_ALIGN_ALLCLIENT
oCalend:bChange  := { || Ft321ChgDia(oModel, oCalend) } //filtra grid de atividades baseado no dia selecionado
oCalend:bChangeMes := { || Ft321DestMes(oModel, oCalend) } //marca no calendario os dias que possuirem atividades

oScrCalend:SetFrame( oPnl )
	
Ft321DestMes(oModel, oCalend) //chama na inicializacao soh pra marcar a primeira vez
Return


//----------------------------------------------------------
/*/{Protheus.doc} FT321ADDField()
Adiciona campos na estrutura

@param oStruct, objeto, estrutura que recebera os campos
@param aCampos, array, array com os campos a serem adicionados
@param nType, numerico, 1 = agenda (AD7) | 2 = tarefa (AD8)

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321ADDField(oStruct, aCampos, nType)
Local aSX3	:= {}
Local nX	:= 1
Local cNomeCampo := ""
Local lObrigat  := .F.

If nType == 1
	lObrigat := .T.
EndIf
 
For nX := 1 to Len(aCampos)
	cNomeCampo := ""
	//para a estrutura das atividades o aCampos vem num array multidimencional com o nome do campo na AD7 e na AD8
	If ValType(aCampos[nX]) == 'A'
		If !Empty(aCampos[nX][1])
			cNomeCampo := aCampos[nX][1]
		Else
			cNomeCampo := aCampos[nX][2]
		EndIf
	Else
		cNomeCampo := aCampos[nX]
	EndIf
	
	ASize(aSX3, 0)
	aSX3 := FT321GetX3(cNomeCampo,lObrigat)
	If Len(aSX3) > 0
		If nType == TYPE_MODEL
				oStruct:AddField( ;
					aSX3[STRUCT_TITULO],		""/*cTooltip*/ , 		aSX3[STRUCT_ID], 		aSX3[STRUCT_TIPO], 	aSX3[STRUCT_TAMANHO],;
					aSX3[STRUCT_DECIMAL],	aSX3[STRUCT_VALID],	aSX3[STRUCT_WHEN],	aSX3[STRUCT_OPCOES], /*lObrigat*/ , 		;  
					aSX3[STRUCT_INIPADRAO],	/*lKey*/,				 /*lNoUpd*/,			aSX3[STRUCT_VIRTUAL] )
		ElseIf nType == TYPE_VIEW
				oStruct:AddField(aSX3[STRUCT_ID], StrZero(nX,Len(SX3->X3_ORDEM)), aSX3[STRUCT_TITULO], aSX3[STRUCT_DESCRICAO], {} , aSX3[STRUCT_TIPO],;
				 aSX3[STRUCT_PICTURE], nil /*bPictVar*/ , aSX3[STRUCT_CONSF3], aSX3[STRUCT_EDITAVEL], /*cFolder*/ , /*cGroup*/ ,;
				 aSX3[STRUCT_OPCOES], /*nMaxLenCombo*/ , /*cIniBrow*/, aSX3[STRUCT_VIRTUAL], /*cPictVar*/ ) 
		EndIf 
	EndIf
	
Next nX

Return



//----------------------------------------------------------
/*/{Protheus.doc} FT321GetX3()
busca dados do campo (dicionario - SX3)
@param cNomeCampo, caractere, nome do campo
@Return aRet, array, dados da estrutura do campo no dicionario
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Static Function FT321GetX3(cNomeCampo, lObrigat)

Local aArea	:= GetArea()
Local aRet		:= {} /*{ cTitulo, cOrdem, cID, cTipo, nTamanho, nDecimal, cDescricao, cPicture, cConsF3,lEditavel,
						 bValid, bWhen, aOpcoes, bInitPadrao, lVirtual, lObrigat }*/
Local cValid	:= ""


Default cNomeCampo 	:= ""
Default lObrigat		:= .F.

DbSelectArea("SX3")
DbSetOrder(2) //X3_CAMPO
If DbSeek(cNomeCampo)
	
	If X3Usado( cNomeCampo )
		
		If (lObrigat .And. SubStr(cNomeCampo,1,3) $ "AD7|AD8" .And.;
			 !( cNomeCampo $ "AD7_CONTAT|AD8_CONTAT|AD8_HRREMI" ) .And. X3Obrigat(cNomeCampo) )
			aAdd( aObrigat, {cNomeCampo, X3TITULO() } ) 
		EndIf
		
		cValid := SX3->X3_VALID
		
		If !Empty( SX3->X3_VLDUSER )
			If !Empty( cValid )
				cValid += " .And. "
			EndIf
			cValid +=  SX3->X3_VLDUSER	
		EndIf
		
		aRet := {	X3TITULO(),	X3_ORDEM, 		cNomeCampo, 	X3_TIPO, 	X3_TAMANHO,;
				 	X3_DECIMAL, 	X3DESCRIC(), 	X3_PICTURE, 	X3_F3, If(X3_VISUAL == 'V', .F., .T.),;
				 	FwBuildFeature( STRUCT_FEATURE_VALID, cValid ),; 
				 	FwBuildFeature( STRUCT_FEATURE_WHEN, X3_WHEN),; 
				 	IIF( !Empty(X3CBOX()), Separa(X3CBOX(), ";", .F.), nil),; 	
				 	FwBuildFeature( STRUCT_FEATURE_INIPAD, X3_RELACAO ), ;	
				 	If(X3_CONTEXT == 'V', .T., .F.) }
	
	EndIf

EndIf


RestArea(aArea)

Return aRet

//
//----------------------------------------------------------
/*/{Protheus.doc} Ft321LRep()
Load dos dados do model do representante

@param cCodVnd, caractere, codigo do vendedor
@param cNomeEntidade, caractere, nome da entidade

@Return aRet, array, dados para o load
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321LRep(cCodVnd, cNomeEntidade)
Local aRet := {}
Local aRetAux := {}
Local cVendedor := Posicione("SA3",1,xFilial("SA3")+cCodVnd,"A3_NOME") //as tarefas se associao ao usuario (e as agendas ao representante)

Aadd(aRetAux,  {cCodVnd, cVendedor, cNomeEntidade } )
Aadd(aRetAux,  {"", "" , ""  } )

Aadd(aRet, { 1,  aRetAux  })

Return aRetAux


//
//----------------------------------------------------------
/*/{Protheus.doc} Ft321LEntida()
Load dos dados do model das entidades associadas ao vendedor
@param cCodVnd, caractere, codigo do vendedor
@Return aRet, array, dados para load
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321LEntida(cCodVnd)
Local nLinha := 0
Local aRet := {}
Local aDados := {} //{ ADL->ADL_FILENT, ADL->ADL_CODENT, ADL->ADL_LOJENT, ADL->ADL_NOME }

//verifica ponto de entrada para buscar dados das entidades associadas ao representante
If ExistBlock("FT321ENT")	
	aDados := ExecBlock("FT321ENT",.F.,.F.,{cCodVnd})
Else
	aDados := Ft321EntDados(cCodVnd)
EndIf

For nLinha := 1 to Len(aDados)
	Aadd(aRet, { nLinha,  aDados[nLinha]  })
Next nLinha	

Return aRet


//----------------------------------------------------------
/*/{Protheus.doc} Ft321EntDados()
busca entidades do representante
@param cCodVnd, caractere, codigo do vendedor
@Return aDados, caractere, Dados do representante
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321EntDados(cCodVnd)
Local aDados 		:= {}
Local aArea 		:= GetArea()
Local aAreaADL 		:= ADL->(GetArea())
Local cAlias 		:= GetNextAlias()
Local aNvlEstrut	:= {} 
Local aFmtNvlEst 	:= {}
Local nNivel        := 1
Local cIDSA1		:= ""
Local cIDSUS		:= ""

If nModulo == 73 

	aNvlEstrut	:= CRMXNvlEst(cCodVnd) 

	aFmtNvlEst 	:= CRMXFmtNvl(aNvlEstrut[1])
	For nNivel := 1 To Len(aNlvEstFmt)
		cIDSA1 += "A1_IDESTN LIKE '" + aNlvEstFmt[nNivel] + "%' "
		cIDSUS += "US_IDESTN LIKE '" + aNlvEstFmt[nNivel] + "%' "
		If nNivel < Len(aNlvEstFmt)
			cIDSA1 += " OR "
			cIDSUS += " OR "
		EndIf
	Next
	cIDSA1 := "%" + cIDSA1 + "%"
	cIDSUS := "%" + cIDSUS + "%"
	 
	#IFDEFTOP
	
		BeginSql Alias cAlias
			SELECT A1_FILIAL FILIAL, "SA1" ENTIDA, A1_COD CODENT, A1_LOJA LOJENT, A1_NOME NOME
			  FROM %Table:SA1% SA1
			 WHERE SA1.A1_FILIAL=%xFilial:SA1%  AND (%Exp:cIDSA1% OR SA1.A1_VEND = %Exp:cCodVnd%) AND SA1.%NotDel%
			 UNION 
			SELECT US_FILIAL FILIAL, "SUS" ENTIDA, US_COD CODENT, US_LOJA LOJENT, US_NOME NOME
			  FROM %Table:SUS% SUS
			 WHERE SUS.US_FILIAL=%xFilial:SUS% AND (%Exp:cIDSA1% OR SUS.US_VEND = %Exp:cCodVnd%) AND SUS.%NotDel%
		EndSql
		
		While (cAlias)->(!Eof())
		
			Aadd(aDados,{	(cAlias)->FILIAL	,;
							(cAlias)->ENTIDA	,;
							(cAlias)->CODENT	,;
							(cAlias)->LOJENT	,;
							(cAlias)->NOME 	} )
		
			(cAlias)->(DbSkip())
		End
		
	#ENDIF

Else
	//Busca entidades do representante
	DbSelectArea("ADL")
	DbSetOrder(5) //ADL_FILIAL+ADL_VEND
	If DbSeek(xFilial("ADL") + cCodVnd)
			
		While ADL->(!EOF()) .AND. ADL->ADL_FILIAL == xFilial("ADL") .AND. Trim(ADL->ADL_VEND) == Trim(cCodVnd)					
			IncProc(STR0053)//"Localizando as contas..."
			If Trim(ADL->ADL_ENTIDA) <> "ACH"
				Aadd(aDados,  { ADL->ADL_FILENT, ADL->ADL_ENTIDA, ADL->ADL_CODENT, ADL->ADL_LOJENT, ADL->ADL_NOME } )
			EndIf	
			ADL->(DbSkip())
		EndDo
			
	EndIf

EndIf

ADL->(RestArea(aAreaADL))
RestArea(aArea)
Return aDados


//
//----------------------------------------------------------
/*/{Protheus.doc} Ft321LAtiv()
Load dos dados do model das atividades

@param cCodVnd, caractere, codigo do vendedor
@param aCamposAtiv, caractere, campos para load
@param oModel, objeto, model
@Return aRet, array, dados para load
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321LAtiv(cCodVnd, aCamposAtiv, oModel)
Local nLinha 	:= 0
Local aRet 	:= {}
Local aDados	:= {} 

aDados := Ft321AtivDados(cCodVnd, aCamposAtiv, oModel)

For nLinha := 1 to Len(aDados)
	Aadd(aRet, { nLinha,  aDados[nLinha]  })
Next nLinha	

Return aRet


//
//----------------------------------------------------------
/*/{Protheus.doc} Ft321AtivDados()
Busca dados das atividades (junta ADV7 e AD8 - Agenda e Tarefas)

@param cCodVnd, caractere, codigo do vendedor
@param aCamposAtiv, caractere, campos para load
@param oModel, objeto, model

@Return aRet , array, dados das atividades
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321AtivDados(cCodVnd, aCamposAtivo, oModel)
Local aLinhaAux		:= {}
Local aDados 			:= {}
Local aArea 			:= GetArea()
Local aAreaAD7 		:= AD7->(GetArea())
Local aAreaAD8 		:= AD8->(GetArea())
Local cCodUsu 		:= Posicione("SA3",1,xFilial("SA3")+cCodVnd,"A3_CODUSR") //as tarefas se associao ao usuario (e as agendas ao representante)
Local nX 				:= 0
Local cNomeCampo 		:= ""
Local cEntidade 		:= ""
Local cCodEnt			:= ""
Local cLojEnt			:= ""
Local dData			:= nil
Local oModelFiltros	:= oModel:GetModel('MODEL_FILTROS')
Local nOpcFilAni		:= 1
Local bErrorBlock			:= {||}	
Local cbInitPadrao		:= ''
Local lError 				:= .F.

//------------------------------------------------------------------------------------
//Busca Filtros que estão guardados na estrutura do model MODEL_FILTROS
//------------------------------------------------------------------------------------
cEntidade 	:= oModelFiltros:GetValue('ENTIDADE')
cCodEnt	:= oModelFiltros:GetValue('CODENT')
cLojEnt	:= oModelFiltros:GetValue('LOJENT')
dData		:= oModelFiltros:GetValue('DATA')
nOpcFilAni	:= oModelFiltros:GetValue('MODO_ANI')
nOpcFilAni	 := IF(nOpcFilAni == 0, 1, nOpcFilAni)


//------------------------------------------------
//Busca Agenda do representante
//------------------------------------------------
If nOpcFilAni <> 2
	DbSelectArea("AD7")
	DbSetOrder(1) //AD7_FILIAL+AD7_VEND+DTOS(AD7_DATA)+AD7_HORA1
	If DbSeek(xFilial("AD7") + cCodVnd) 
																   
		While !lError .AND. AD7->(!EOF()) .AND. AD7->AD7_FILIAL == xFilial("AD7") .AND. Trim(AD7->AD7_VEND) == Trim(cCodVnd)
			
			//filtra entidade
			If (Empty(cCodEnt)) .OR. ( (!Empty(cCodEnt) .AND. AllTrim(cEntidade) == 'SA1' .AND. AllTrim(AD7->AD7_CODCLI) == AllTrim(cCodEnt) .AND. AllTrim(AD7->AD7_LOJA) == AllTrim(cLojEnt) ) .OR.;
			 (!Empty(cCodEnt) .AND. AllTrim(cEntidade) == 'SUS' .AND. AllTrim(AD7->AD7_PROSPE) == AllTrim(cCodEnt) .AND. AllTrim(AD7->AD7_LOJPRO) == AllTrim(cLojEnt) ) )
				//filtra loja
				If Empty(dData) .OR. (AD7->AD7_DATA == dData)
				
					aSize(aLinhaAux,0)
						
					Aadd(aLinhaAux, "1") //tipo agendamento
					For nX := 1 to Len(aCamposAtiv)
						If lError
							Exit
						EndIf
						cNomeCampo := aCamposAtiv[nX][1]
						If !Empty(cNomeCampo)
							If FT321IsVirtual(cNomeCampo)
								cbInitPadrao := FT321GetInit(cNomeCampo)
								bErrorBlock := ErrorBlock({|e| lError := .T. ,  FT321IntegrationInformation(STR0065 + cNomeCampo + "." +;	//"Erro no inicializador padrão do campo "
									 CRLF+ STR0066 + cbInitPadrao, e:Description + CRLF + CRLF + e:ErrorStack + e:ErrorEnv)})	//"Inicializador Padrão: " 
								Aadd(aLinhaAux, &(cbInitPadrao) ) 
								ErrorBlock(bErrorBlock)
							Else	
								Aadd(aLinhaAux, &("AD7->"+cNomeCampo))
							EndIf
						ElseIf Empty(cNomeCampo) .And. !Empty(aCamposAtiv[nX][2])
							Aadd(aLinhaAux, CriaVar(aCamposAtiv[nX][2],.F.))
						Else
							Aadd(aLinhaAux, "")
						EndIf
					Next nX
					Aadd( aLinhaAux, Recno() ) //joga o recno no ultimo campo
					Aadd(aDados, aClone(aLinhaAux))
				EndIf		
			EndIf			
			AD7->(DbSkip())
		EndDo
		
	EndIf
EndIf	
//------------------------------------------------
//Busca Tarefas do representante (usuario)
//------------------------------------------------
DbSelectArea("AD8")
DbSetOrder(2) //AD8_FILIAL+AD8_CODUSR+DTOS(AD8_DTINI)
If DbSeek(xFilial("AD8") + cCodUsu)	
		
	While !lError .AND. AD8->(!EOF()) .AND. AD8->AD8_FILIAL == xFilial("AD8") .AND. Trim(AD8->AD8_CODUSR) == Trim(cCodUsu)
		
		//Filtra entidade	
		If (Empty(cCodEnt)) .OR. ( (!Empty(cCodEnt) .AND. AllTrim(cEntidade) == 'SA1' .AND. AllTrim(AD8->AD8_CODCLI) == AllTrim(cCodEnt) .AND. AllTrim(AD8->AD8_LOJCLI) == AllTrim(cLojEnt)) .OR.;
		 (!Empty(cCodEnt) .AND. AllTrim(cEntidade) == 'SUS' .AND. AllTrim(AD8->AD8_PROSPE) == AllTrim(cCodEnt) .AND. AllTrim(AD8->AD8_LOJPRO) == AllTrim(cLojEnt) ) )
			
			//Filtra loja
			If Empty(dData) .OR. (AD8->AD8_DTINI == dData)
				
				//Filtra aniversario
				If  nOpcFilAni == 1 .OR. (nOpcFilAni == 2 .AND. AD8->AD8_ANIVER == '1') .OR. (nOpcFilAni == 3 .AND. AD8->AD8_ANIVER <> '1')
							
					aSize(aLinhaAux,0)
									
					Aadd(aLinhaAux, "2") //tipo agendamento
					For nX := 1 to Len(aCamposAtiv)
						If lError
							Exit
						EndIf
						If Len(aCamposAtiv[nX]) > 1 .AND. !Empty(aCamposAtiv[nX][2])
							cNomeCampo := aCamposAtiv[nX][2]
							If FT321IsVirtual(cNomeCampo)
								cbInitPadrao := FT321GetInit(cNomeCampo)
								bErrorBlock := ErrorBlock({|e| lError := .T. ,  FT321IntegrationInformation(STR0065 + cNomeCampo + "." +;	//"Erro no inicializador padrão do campo "
									 CRLF+ STR0066 + cbInitPadrao, e:Description + CRLF + CRLF + e:ErrorStack + e:ErrorEnv)})	//"Inicializador Padrão: "
								Aadd(aLinhaAux, &(cbInitPadrao) ) 
								ErrorBlock(bErrorBlock)
							Else	
								Aadd(aLinhaAux, &("AD8->"+cNomeCampo))
							EndIf
						Elseif Len(aCamposAtiv[nX]) > 1 .And. Empty(aCamposAtiv[nX][2]) .And. !Empty(aCamposAtiv[nX][1])
							Aadd(aLinhaAux, CriaVar(aCamposAtiv[nX][1],.F.))
						Else
							Aadd(aLinhaAux, "")
						EndIf
					Next nX
					Aadd( aLinhaAux, Recno() ) //joga o recno no ultimo campo
					Aadd(aDados, aClone(aLinhaAux))
				EndIf
			EndIf
		EndIf			
		AD8->(DbSkip())
	EndDo
	
EndIf

	
AD7->(RestArea(aAreaAD7))
AD8->(RestArea(aAreaAD8))
RestArea(aArea)

If lError
	aDados := {}
EndIf

Return aDados


//
//----------------------------------------------------------
/*/{Protheus.doc} FT321EntPos()
Pos linha do grid de entidades (Contas)
Joga o nome da entidade selecionada no cabeçalho
@param oView, objeto, view
@param cIdGrid, caractere, Nome (ID) do model do Grid
@param oCalend, objeto, calendario
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321EntPos(oView, cIdGrid, oCalend)
Local oModel		:= oView:GetModel()
Local oModelEnt	:= oModel:GetModel(cIdGrid)

If	! _lForcaGrv
	//-------------------------------------------
	//Guarda os Filtros da entidade posicionada
	//-------------------------------------------
	oModel:SetValue('MODEL_FILTROS', 'ENTIDADE', oModelEnt:GetValue("ADL_ENTIDA",oModelEnt:nLine))
	oModel:SetValue('MODEL_FILTROS', 'CODENT', oModelEnt:GetValue("ADL_CODENT",oModelEnt:nLine))
	oModel:SetValue('MODEL_FILTROS', 'LOJENT', oModelEnt:GetValue("ADL_LOJENT",oModelEnt:nLine))

	If oModelEnt <> Nil
		oModel:SetValue("MODEL_REP" , "US_NOME", oModelEnt:GetValue("ADL_NOME",oModelEnt:nLine) )
	EndIf

	//atualiza dados do grid de atividades - realiza o load novamente com os filtros atuais
	FT321AtuAtiv(oModel)

	//atualiza calendario
	Ft321DestMes(oModel, oCalend)

	If ( nModulo == 73 )
		oView:Refresh("VIEW_REP")
		oView:Refresh("VIEW_ENT_GRID")
	EndIf
	
	_nLnGridEnt	:= oModelEnt:GetLine()
Else
	Help(" ", 1, STR0039, , STR0070, 1)         //"Atenção" ## "Existem atividades ainda não gravadas. Confirme a sua gravação antes de selecionar outro cliente/prospect."
	oModelEnt:GoLine(_nLnGridEnt)
	oView:Refresh("VIEW_ENT_GRID")
EndIf
Return


//----------------------------------------------------------
/*/{Protheus.doc} FT321BlqTar()
Bloqueia campos exclusivos de tarefas e libera campos de agendamentos
@param oStruct, objeto, estrutura do grid de atividades
@param lEdita, logico, define se deixa o campo editavel
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321BlqTar(oStruct, lEdita)
Local aCampos := {	"AD7_ALERTA", "AD7_TPALERTA", "AD7_VENDAP", "AD7_DATAAP", "AD7_SEQAP",;
						"AD7_AGEREU", "AD7_EMAILP", "AD7_LOCAL" }
Default lEdita := .F.

FT321BlqCampos( oStruct, aCampos , lEdita)

Return


//----------------------------------------------------------
/*/{Protheus.doc} FT321BlqAge()
Bloqueia campos exclusivos de agendamentos e libera campos de tarefas
@param oStruct, objeto, estrutura do grid de atividades
@param lEdita, logico, define se deixa o campo editavel
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321BlqAge(oStruct, lEdita)
Local aCampos := {	"AD7_ALERTA", "AD7_TPALERTA", "AD7_VENDAP", "AD7_DATAAP", "AD7_SEQAP",;
						"AD7_AGEREU", "AD7_EMAILP", "AD7_LOCAL" }
Default lEdita := .F.

FT321BlqCampos( oStruct, aCampos , lEdita)

Return


//----------------------------------------------------------
/*/{Protheus.doc} FT321BlqCampos()
função base para alterar a propriedade "EDITAVEL" dos campos
@param oStruct, objeto, estrutura do grid de atividades
@param aCampos, array, nome dos campos
@param lEdita, logico, define se deixa o campo editavel
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321BlqCampos( oStruct, aCampos , lEdita )
Local nX := 0

For nX := 1 to Len(aCampos)
	oStruct:SetProperty( aCampos[nX] , MVC_VIEW_CANCHANGE, lEdita)	
Next nX

Return



//----------------------------------------------------------
/*/{Protheus.doc} FT321AtuAtiv()
atualiza o grid de atividade com os filtros atualizados
@param oModel, objeto, model
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321AtuAtiv(oModel)
Local oModelAtiv := oModel:GetModel('MODEL_ATIV_GRID')
Local oView := FWViewActive()

Local cCodVnd := ""

If ( nModulo == 73 )
 	cCodVnd :=  CRMXRetVend() //vendedor logado 
Else
	cCodVnd := Ft320RpSel()
EndIf

If oModelAtiv <> Nil
	ASize(oModelAtiv:GetData(),0)
	ASize(oModelAtiv:aCols,0)
	ASize(oModelAtiv:aDataModel,0)
	oModelAtiv:DeActivate()
	
	oModelAtiv:SetLoad( {|| Ft321LAtiv(cCodVnd, aCamposAtiv, oModel)} )
	
	oModelAtiv:Activate()
EndIf

oView:Refresh("VIEW_ATIV_GRID")
Return


//----------------------------------------------------------
/*/{Protheus.doc} Ft321ChgDia()
filtra dia selecionado no calendario@param oStruct, objeto, estrutura do grid de atividades
@param oModel, objeto, model
@param oCalend, objeto, Calendario
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321ChgDia(oModel, oCalend)

oModel:SetValue('MODEL_FILTROS','DATA', oCalend:dDiaAtu)
FT321AtuAtiv(oModel)

Return

//marca datas com compromissos no calendario
Function Ft321DestMes(oModel, oCalend)

Local cAnoMesSel := ''
Local dAnoMesAtiv 
Local aDiasAg 	:= {}
Local nX 			:= {}


If oCalend <> Nil
	oCalend:DelAllRestri()
	cAnoMesSel := SubStr(DtoS(oCalend:dDiaAtu), 1, 6)

	For nX := 1 to oModel:GetModel('MODEL_ATIV_GRID'):Length()
	
		dAnoMesAtiv := oModel:GetModel('MODEL_ATIV_GRID'):GetValue('AD7_DATA', nX)
		If SubStr(DtoS(dAnoMesAtiv), 1, 6) == cAnoMesSel  // se o mes e ano do registro da grid for igual ao selecionado no calendario
				Aadd(aDiasAg, Day(dAnoMesAtiv)) //adiciona o dia (da data selecionada) no array
		EndIf
	Next nX
	
	
	//-----------------------------------
	//³Destaca os dias no calendario³
	//-----------------------------------
	For nX := 1 to Len(aDiasAg)
		oCalend:AddRestri(aDiasAg[nX], CLR_HRED, CLR_HRED)
	Next nX
	
	oCalend:CtrlRefresh()
EndIf


Return

//----------------------------------------------------------
/*/{Protheus.doc} FT321ADDOthers()
Adiciona objetos gerais da tela (filtros e outros componentes nao MVC)
@param oPainel, objeto, painel owner
@param oModel, objeto, model
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321ADDOthers(oPainel, oModel)
Local oGroup1
Local oGroup2
Local oRadio
Local nRadio    := 1
Local oCheck1
Local lChkCli   := .F.
Local oCheck2
Local lChkPro   := .F.
Local oButton
Local oBtnData
Local oBtnConta
Local oDlgTask
Local cCodVend 	:= oModel:GetValue("MODEL_REP", "A3_COD")
Local cCliente  := STR0009//"Cliente"
Local cProspect := STR0010//"Prospect"
Local cOculta   := STR0011//"Ocultar aniversários"
Local cExibe    := STR0012//"Exibir somente aniversário"
Local lVerTodos := .T. // Define o modo de exibição: False = Data filtrada no calendario; True = Ver todos. 
Local oComboExi
Local cComboExi := 1
Local oTitulo1
Local oTitulo2
Local oTitulo3

Local oFwLayer	:= Nil
Local oScrOther := Nil
Local oPnl		:= Nil

DEFINE FONT oTFont 
oTFont:= TFont():New("Arial",,15,.T.,.T.)

oFwLayer := FwLayer():New()
oFwLayer:init(oPainel,.F.)

oFWLayer:addCollumn( "COL1",100, .T. , "LINHA2") 
oFWLayer:addWindow( "COL1", "WIN1", STR0013, 100, .F., .F., , "LINHA2")	//"Geração de tarefas de aniversário:"
	
oPanel := oFWLayer:GetWinPanel("COL1","WIN1","LINHA2")

//Cria uma Scroll
oScrOther := TScrollArea():New(oPanel,01,01,100,100,.T.,.F.,.F.)
oScrOther:Align := CONTROL_ALIGN_ALLCLIENT

oPnl := TPanel():New(001,001,"",oScrOther,,,,,,140,140)

	@ 005, 010 RADIO oRadio VAR nRadio ITEMS STR0015,STR0016,STR0014 SIZE 044, 027 OF oPnl PIXEL//"1 Ano"//"3 Meses"//"6 Meses"
	@ 035, 010 CHECKBOX oCheck1 VAR lChkCli PROMPT cCliente   SIZE 048, 008 OF oPnl PIXEL
	@ 045, 010 CHECKBOX oCheck2 VAR lChkPro PROMPT cProspect  SIZE 048, 008 OF oPnl PIXEL
	@ 055, 010 BUTTON oButton PROMPT STR0018 SIZE 040, 010 ACTION MsgRun(STR0026, STR0017,; //"Aguarde geração de aniversários"//"Gerar"
	{ || Ft320ProcAni(nRadio,lChkCli,lChkPro,cCodVend,,,,,, oModel ), FT321AtuAtiv(oModel)  } ) OF oPnl PIXEL
	
	@ 070, 005 SAY oTitulo2 PROMPT STR0019 SIZE 120,009  OF oPnl PIXEL//"Filtro de Tarefas:"
	@ 080, 010 MSCOMBOBOX oComboExi VAR cComboExi ITEMS {STR0020,STR0021,STR0022} SIZE 085, 010 OF oPnl;//"1=Todos"//"2=Exibe somente aniversário"//"3=Não exibe aniversário"
    ON CHANGE Ft321FilAni(oModel,cComboExi) PIXEL
	
	@ 100, 005 SAY oTitulo3 PROMPT STR0023 SIZE 120,009  OF oPnl PIXEL//"Filtros Gerais:"
	@ 110, 010 BUTTON oBtnData PROMPT STR0024 SIZE 060, 010 ACTION Ft321DelDia(oModel) OF oPnl PIXEL//"Limpar Filtro de Data"
	@ 110, 080 BUTTON oBtnConta PROMPT STR0025 SIZE 060, 010 ACTION Ft321DelConta(oModel) OF oPnl PIXEL//"Limpar Filtro de Conta"
	
	
oScrOther:SetFrame( oPnl )

Return

//----------------------------------------------------------
/*/{Protheus.doc} Ft321FilAni()
Define filtros de tarefas de aniversario

@param oModel, objeto model, model
@param cOpc, caractere, 1 = todos, 2 = somente aniversario, 3 = oculta aniversario

@Return nil

@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321FilAni(oModel, cOpc)

oModel:SetValue('MODEL_FILTROS','MODO_ANI', Val(cOpc))
FT321AtuAtiv(oModel)

Return


//----------------------------------------------------------
/*/{Protheus.doc} Ft321DelDia()
remove filtro de data selecionada no calendario
@param oModel

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321DelDia(oModel)
Local oModelFiltros := oModel:GetModel( 'MODEL_FILTROS' )

oModelFiltros:SetValue('DATA', SToD("  /  /  "))  
FT321AtuAtiv(oModel)


Return



//----------------------------------------------------------
/*/{Protheus.doc} Ft321DelConta()
remove filtro de entidades (cliente/prospect) selecionada 
@param oModel

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321DelConta(oModel)
Local oModelFiltros := oModel:GetModel( 'MODEL_FILTROS' )

oModel:SetValue("MODEL_REP" , "US_NOME", "" )

oModelFiltros:SetValue('ENTIDADE', "")
oModelFiltros:SetValue('CODENT', "")
oModelFiltros:SetValue('LOJENT', "")
FT321AtuAtiv(oModel)
Return



//----------------------------------------------------------
/*/{Protheus.doc} Ft321Commit()
Commit do model

@param oModel

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321Commit(oModel)
Local oModelAtiv := oModel:GetModel('MODEL_ATIV_GRID')
Local nI := 0
Local aInfoSinc 		:= {}  
Local cURL      		:= ""

// --- INTEGRACAO COM EXCHANGE ---
cURL	:= f321GetUrlExg()


If ( nModulo == 73 )
    If !Empty(aCrmInfVen)
		aInfoSinc := aClone(aCrmInfVen)// pegando o vetor com os dados do vendedor no modulo crm, para não precisar autenticar novamente.
	EndIf 
Else
	
	If !Empty(cUrl) 
		aInfoSinc	:= GetInfoUserSinc("U")   
	EndIf
EndIf
		
//percorrer o grid de atividades, verificar os registros que tiveram alteracao ou foram excluidos e executar os procedimentos adequados
For nI := 1 To oModelAtiv:Length()
	oModelAtiv:GoLine( nI )
	If oModelAtiv:IsDeleted()
		Ft321DelAtiv(oModel, nI, aInfoSinc, cURL )
	ElseIf oModelAtiv:IsInserted()
		Ft321InsUpdAtiv(oModel, nI, .T., aInfoSinc, cURL)
	ElseIf oModelAtiv:IsUpdated()
		Ft321InsUpdAtiv(oModel, nI, .F., aInfoSinc, cURL)
	EndIf
Next

//Realizar a confirmação do HardLock para evitar chave duplicada
While ( GetSx8Len() > 0 )
	ConfirmSX8()
EndDo

_lForcaGrv		:= .F.
_nLnGridEnt	:= 0
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} Ft321Cancel()
Tratamento no cancelamento da Atividade

@param oModel

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321Cancel( oModel )

//Realiza o RollBack do HardLock
While ( GetSx8Len() > 0 )
	RollBackSX8()
EndDo

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} Ft321DelAtiv()

Exclusao de atividades 
@param oModel
@param nLinha, numerico, linha posicionada
@param aInfoSinc, dados da conta exchange {usuario, senha, email}
@param cUrl, url do wsdl para conexao exchange

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321DelAtiv(oModel, nLinha, aInfoSinc, cURL)

Local aArea 			:= GetArea()
Local oModelAtiv 		:= oModel:GetModel('MODEL_ATIV_GRID')
Local cRecno			:= oModelAtiv:GetValue('RECNO', nLinha)
Local cAlias 			:= "" 
Local cUserExg		:= ""
Local cSenhaExg		:= ""
Local aRetExg			:= {}

If oModelAtiv:GetValue("TIPO_ATIV") == '1' //agenda
	cAlias		:= "AD7"
ElseIf oModelAtiv:GetValue("TIPO_ATIV") == '2' //tarefa
	cAlias		:= "AD8"
EndIf


If !Empty(cAlias)
	
	DbSelectArea(cAlias)
	
	If !Empty(cRecno)
		DbGoTo(cRecno)
		//exchange
		If !Empty(cUrl)
			If Empty(cUserExg) 
			    If aInfoSinc[1]
					cUserExg	:= aInfoSinc[2,_USUAR]
					cSenhaExg	:= aInfoSinc[2,_SENHA]
					If !Empty(cSenhaExg)
				   		If cAlias == "AD7"
				   			LjMsgRun(STR0027, STR0026,{|| aRetExg := f321AtuAgeExg("D",cUserExg,cSenhaExg,cAlias)[1] })
				   		ElseIf cAlias == "AD8"
				   			LJMsgRun(STR0027, STR0026,{|| aRetExg := f321AtuTarExg("D",cUserExg,cSenhaExg,cAlias)[1] })//"Aguarde"
						EndIf 
				   	EndIf
				 EndIf
			EndIF				
		EndIf	
		
		
		RecLock(cAlias, .F.)
		(cAlias)->(DbDelete())
		(cAlias)->(MSUnlock())		
	EndIf
EndIf

RestArea(aArea)
Return


//----------------------------------------------------------
/*/{Protheus.doc} Ft321InsUpdAtiv()
Inclusao ou Alteracao de atividades

@param oModel
@param nLinha, numerico, linha posicionada
@param lInclusao
@param aInfoSinc, dados da conta exchange {usuario, senha, email}
@param cUrl, url do wsdl para conexao exchange

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function Ft321InsUpdAtiv(oModel, nLinha, lInclusao, aInfoSinc, cURL)
Local aArea 			:= GetArea()
Local aAreaAD7 			:= AD7->(GetArea())
Local aAreaAD8 			:= AD8->(GetArea())
Local oModelAtiv 		:= oModel:GetModel('MODEL_ATIV_GRID')
Local cCodVend 		:= PADR(oModel:GetValue('MODEL_REP', 'A3_COD'), TamSx3("A3_COD")[1])
Local nTipoAtiv		:= Val(oModelAtiv:GetValue("TIPO_ATIV"))
Local cRecno			:= oModelAtiv:GetValue('RECNO', nLinha)
Local cAlias 			:= "" 
Local nX				:= 0
Local cNomeCampo		:= ""
Local cNomeID			:= ""
Local aRetExg			:= {}
Local cUserExg		:= ""
Local cSenhaExg		:= ""
Local nPos 			:= 0
  
Local cCodVnd := ""
Local aNvlEstrut	:= {}

If ( nModulo == 73 ) 
	cCodVnd := CRMXRetVend() //vendedor logado 
Else
	cCodVnd := Ft320RpSel()
EndIf
If !Empty(cCodVnd)
	aNvlEstrut := CRMXNvlEst(cCodVnd)
EndIf  

If nTipoAtiv == 1 //agenda
	cAlias		:= "AD7"
ElseIf nTipoAtiv == 2 //tarefa
	cAlias		:= "AD8"
EndIf

If !Empty(cAlias)
	
	DbSelectArea(cAlias)
	
	If !lInclusao .AND. !Empty(cRecno)
		DbGoTo(cRecno)
	EndIf
	
	If RecLock(cAlias, lInclusao)
	
		If lInclusao
			(cAlias)->&(cAlias + "_FILIAL") := xFilial(cAlias)
			If nTipoAtiv == 1 //agenda
				(cAlias)->AD7_VEND := cCodVend
				(cAlias)->AD7_IDESTN	:= aNvlEstrut[1]
				(cAlias)->AD7_NVESTN := aNvlEstrut[2] 
			ElseIf nTipoAtiv == 2 //tarefa
				(cAlias)->AD8_TAREFA := GETSX8NUM("AD8","AD8_TAREFA") 
				(cAlias)->AD8_CODUSR := Posicione("SA3",1,xFilial("SA3")+cCodVnd,"A3_CODUSR") //as tarefas se associao ao usuario (e as agendas ao representante)
				(cAlias)->AD8_VEND	:= cCodVnd
				(cAlias)->AD8_IDESTN	:= aNvlEstrut[1]
				(cAlias)->AD8_NVESTN := aNvlEstrut[2] 

			EndIf	
		EndIf
		
		For nX := 1 to Len(aCamposAtiv)
			If Len(aCamposAtiv[nX]) >= nTipoAtiv .AND. !Empty(aCamposAtiv[nX][nTipoAtiv]) //protecao para executar somente nos campos que existirem na tabela
				cNomeCampo := aCamposAtiv[nX][nTipoAtiv] //se for ad7 pega indice 1, se for ad8 pega indice 2
				cNomeID := IIF(!Empty(aCamposAtiv[nX][1]), aCamposAtiv[nX][1], aCamposAtiv[nX][2])  //o nome (ID) do campo na estrutura sera sempre do indice 1 quando este nao estiver vazio
				If !FT321IsVirtual(cNomeCampo)
					If cNomeCampo $ ('AD7_HORA1|AD7_HORA2|AD8_HRREMI')
						(cAlias)->&(cNomeCampo) := Transform(oModelAtiv:GetValue(cNomeID, nLinha), "@E 99:99" ) 
					Else
						(cAlias)->&(cNomeCampo) := oModelAtiv:GetValue(cNomeID, nLinha)
					EndIf
				EndIf
			EndIf
		Next nX
		
		nPos := aScan(aCamposAtiv, {|x| Alltrim(x[1]) == 'AD7_MEMO'} )
		If nPos > 0
			cNomeID := IIF(!Empty(aCamposAtiv[nPos][1]), aCamposAtiv[nPos][1], aCamposAtiv[nPos][2])
		    MSMM((cAlias)->&(cAlias+"_CODMEM"),,,oModelAtiv:GetValue(cNomeID, nLinha),1,,,cAlias, cAlias+"_CODMEM")
	    EndIf
		
		(cAlias)->(MSUnlock())	
		ConfirmSX8() 
		
		//exchange
		If !Empty(cUrl)
			If Empty(cUserExg) 
			    If aInfoSinc[1]
					cUserExg	:= aInfoSinc[2,_USUAR]
					cSenhaExg	:= aInfoSinc[2,_SENHA]
					If !Empty(cSenhaExg)
						If cAlias == "AD7"
							LjMsgRun(STR0027,STR0026,{|| aRetExg := f321AtuAgeExg("A",cUserExg,cSenhaExg,cAlias)[1] })//"Enviando alterações para o Exchange..."
						ElseIf cAlias == "AD8"
							LJMsgRun(STR0027,STR0026,{|| aRetExg := f321AtuTarExg("A",cUserExg,cSenhaExg,cAlias)[1] })
						EndIf
					EndIf
				EndIf
		    EndIf
		EndIf	
		
	EndIf
	
EndIf

AD7->(RestArea(aAreaAD7))
Ad8->(RestArea(aAreaAD8))
RestArea(aArea)

Return .T.


//----------------------------------------------------------
/*/{Protheus.doc} FT321IsVirtual()

Verifica se o campo é virtual
@param cField , nome do campo

@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321IsVirtual(cField)
Local aArea	:= GetArea()
Local lRet		:= .F. 

DbSelectArea("SX3")
DbSetOrder(2) //X3_CAMPO
If DbSeek(cField)
	lRet := If(X3_CONTEXT == 'V', .T., .F.)   
EndIf

RestArea(aArea)
Return lRet



//----------------------------------------------------------
/*/{Protheus.doc} FT321AtvPreLinha()
Pre validacao da linha - inclue entidade posicionada
@param oModelGrid
@param nLine
@param oModel
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//---------------------------------------------------------- 
Function FT321AtvPreLinha(oModelGrid, nLine, oModel)
Local cCodCli := oModelGrid:GetValue("AD7_CODCLI",nLine)
Local cCodPro := oModelGrid:GetValue("AD7_PROSPE",nLine)

Local oModelFiltros := oModel:GetModel('MODEL_FILTROS')
	
cAtuEntidade 	:= oModelFiltros:GetValue('ENTIDADE')
cAtuCodEnt	:= oModelFiltros:GetValue('CODENT')
cAtuLojEnt	:= oModelFiltros:GetValue('LOJENT')

If Empty(cCodCli) .AND. Empty(cCodPro)
	If cAtuEntidade == 'SA1'
		oModelGrid:SetValue('AD7_CODCLI',cAtuCodEnt)
		oModelGrid:SetValue('AD7_LOJA',cAtuLojEnt)
	ElseIf cAtuEntidade == 'SUS'
		oModelGrid:SetValue('AD7_PROSPE',cAtuCodEnt)
		oModelGrid:SetValue('AD7_LOJPRO',cAtuLojEnt)
	EndIf
EndIf
Return .T.


//----------------------------------------------------------
/*/{Protheus.doc} FT321IniConta()
faz a avaliacao geral para o inicializador padrao das contas (clientes/prospect)
@param oModel
@param nTipo,, define qual campo sera utilizado
@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321IniConta(oModel, nTipo)
/*
nTipo:
1 - codcli
2 - lojcli
3 - codpro
4 - lojpro
*/

Local oModelFiltros := oModel:GetModel('MODEL_FILTROS')
Local oModelGrd		:= oModel:GetModel('MODEL_ENT_GRID')
Local cRet := ""	
	
//verifica filtro atual e verifica que fez a chamada e retorna campo correspondente	

If !Empty(Alltrim(oModelFiltros:GetValue('ENTIDADE')))
	cAtuEntidade 	:= Alltrim(oModelFiltros:GetValue('ENTIDADE'))
	cAtuCodEnt	:= Alltrim(oModelFiltros:GetValue('CODENT'))
	cAtuLojEnt	:= Alltrim(oModelFiltros:GetValue('LOJENT'))
Else
	cAtuEntidade 	:= Alltrim(oModelGrd:GetValue('ADL_ENTIDA'))
	cAtuCodEnt	:= Alltrim(oModelGrd:GetValue('ADL_CODENT'))
	cAtuLojEnt	:= Alltrim(oModelGrd:GetValue('ADL_LOJENT'))
Endif

If cAtuEntidade == 'SUS'
	If nTipo == 3 
		cRet := cAtuCodEnt
	ElseIf nTipo == 4	
		cRet := cAtuLojEnt
	EndIf

ElseIf cAtuEntidade == 'SA1'
	If nTipo == 1 
		cRet := cAtuCodEnt
	ElseIf nTipo == 2	
		cRet := cAtuLojEnt
	EndIf

EndIf

Return cRet



//----------------------------------------------------------
/*/{Protheus.doc} FT321WhTpAtiv()
bloqueia o campo tipo de atividade para edicao quando o registro ja estiver gravado na base
@param oModelGrid
@Return lRet,, define se bloqueia ou nao
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321WhTpAtiv(oModelGrid)
Local lRet := oModelGrid:GetValue("RECNO",oModelGrid:nLine) == 0

Return lRet


//----------------------------------------------------------
/*/{Protheus.doc} FT321WhenTipo()
bloqueia campos que nao sao da entidade selecionada (agenda ou tarefa)
@param oModel
@Return lRet,, define se bloqueia ou nao
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321WhenTipo(oModel)
Local nX := 0
Local cNomeID := ""
Local oStruAtiv	:= oModel:GetModel("MODEL_ATIV_GRID"):GetStruct()
Local nTipoLiberado := 0	//define se libera os campos da AD7 (1) ou da AD8 (2)	

For nX := 1 to Len(aCamposAtiv)

	cNomeID := IIF(!Empty(aCamposAtiv[nX][1]), aCamposAtiv[nX][1], aCamposAtiv[nX][2])
	nTipoLiberado := 0
	If Len(aCamposAtiv[nX]) == 1 .OR. (Empty(aCamposAtiv[nX][1]) .OR. Empty(aCamposAtiv[nX][2])) 
		
		If Len(aCamposAtiv[nX]) == 1 .OR. Empty(aCamposAtiv[nX][2]) //se somente o indice 1 estiver preenchido, o campo eh da ad7
			nTipoLiberado := 1
		ElseIf Len(aCamposAtiv[nX]) > 1 .AND. Empty(aCamposAtiv[nX][1]) //se somente o indice 2 estiver preenchido, o campo eh da ad8
			nTipoLiberado := 2
		EndIf
		
		If cNomeID <> 'TIPO_ATIV'
			If nTipoLiberado == 1 
				oStruAtiv:SetProperty( cNomeID 	, MODEL_FIELD_WHEN , {||FT321When(oModel, 1)})
			ElseIf nTipoLiberado == 2 
				oStruAtiv:SetProperty( cNomeID 	, MODEL_FIELD_WHEN , {||FT321When(oModel, 2)})
			EndIf
		EndIf
		
	Else
		If aCamposAtiv[nX][1] $ 'AD7_CODCLI|AD7_LOJA|AD7_PROSPE|AD7_LOJPRO'
			oStruAtiv:SetProperty( cNomeID, MODEL_FIELD_WHEN, {|| .F.})	//Cliente / Prospects não podem ser alterados. Relacionamento com a Grid superior.
		EndIf
	EndIf
Next nX


Return


//----------------------------------------------------------
/*/{Protheus.doc} FT321When()
verifica when geral dos campos
@param oModel
@param nTipoLiberado,, 1=agenda | 2 = tarefa
@Return lRet,, define se bloqueia ou nao
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function FT321When(oModel, nTipoLiberado)
Local oModelAtiv := oModel:GetModel('MODEL_ATIV_GRID')
Local lRet := .F.

If Val(oModelAtiv:GetValue("TIPO_ATIV",oModelAtiv:nLine)) == nTipoLiberado
	lRet := .T.
EndIf

Return lRet


//----------------------------------------------------------
/*/{Protheus.doc} FT321RemFields()
Protecao contra campos que nao existam.	
Valida se no array base da estrutura, todos os campos existem na base.
Remove os campos que não existirem na base de dados
OBS: Os campos memos da SYP precisam de tratamento especifico
@param aCampos array com os campos para a estrutura

@Return nil
@author Vendas CRM
@since 11/10/2013
/*/
//----------------------------------------------------------
Function FT321RemFields(aCampos)
Local nX := 1
Local nCount := 0
Local lDelete := .F.


While nX <= Len(aCampos)
	lDelete := .F.
	If aCampos[nX] <> nil .AND. aCampos[nX][1] <> 'AD7_MEMO'
		If Len(aCampos[nX]) > 1 //possui o campo na ad8
			If !Empty(aCampos[nX][2]) .AND. !FT321IsVirtual(aCampos[nX][2]) .AND. AD8->(FieldPos(aCampos[nX][2])) == 0
				lDelete := .T.
			EndIf
		EndIf
		If !Empty(aCampos[nX][1]) .AND. !FT321IsVirtual(aCampos[nX][1]) .AND. AD7->(FieldPos(aCampos[nX][1])) == 0
			lDelete := .T.
		EndIf
	EndIf
	
	If 	lDelete
		ADEL(aCampos,nX)
		nCount++
	Else
		nX++
	EndIf

End Do

If nCount > 0 
	ASize(aCampos, Len(aCampos) - nCount)
EndIf

Return



//----------------------------------------------------------
/*/{Protheus.doc} FT321GetInit()
Busca o inicializador padrao do campo

@param cCampo Nome do campo na SX3

@Return nil
@author Vendas CRM
@since 11/10/2013
/*/
//----------------------------------------------------------

Function FT321GetInit(cNomeCampo)

	Local cRet := ''
	Local aArea	:= GetArea()
			
	DbSelectArea("SX3")
	DbSetOrder(2) //X3_CAMPO
	If DbSeek(cNomeCampo)
		cRet := X3_RELACAO
	EndIf
	
	RestArea(aArea)
	
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntViewSinc
                                   
Cria a tela de Status de sincronização dentro da tela de atividades, somente quando
a rotina de atividades for acessada pelo Modulo CRM 


@sample	MntViewSinc(oPainel)

@param		ExpO1 = oPainel do Model, onde deve ser criado a tela de sincronismo 

@return	Nenhum  

@author	Victor Bitencourt
@since		04/11/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------
Function MntViewSinc(oPainel)

Local cData 		 := "" 
Local cHora 		 := ""
Local cMensagem   := "" 
Local cStatus	     := "" 
Local oTimer 		 := Nil
Local oGetStatus  := Nil 
Local oData 		 := Nil 
Local oGetData 	 := Nil 
Local oHora 		 := Nil 
Local oGetHora	 := Nil 
Local oStatus 	 := Nil 
Local oButton 	 := Nil 
Local aStatus 	 := {} 
Local oMsg 		 := Nil
Local oWndSinc    := Nil
Local oTimerSinc  := Nil
Local nTimerSinc  := Nil

If Len(aCrmInfVen[2]) >= 13 // validacao para ver se existe a posição 13 no array
   If !Val(aCrmInfVen[_PREFIXO,_TIMEMIN]) <= 0
      nTimerSinc := Val(aCrmInfVen[_PREFIXO,_TIMEMIN])*60000
      oTimerSinc := TTimer():New(nTimerSinc, {|| Ft321SncCrm(aCrmInfVen) } , oPainel:oWnd )   
	  oTimerSinc:Activate()	
   Else 
      nTimerSinc :=  10 * 60000 // valor padrao de 10 min   
   EndIf
EndIf
// Sincronização 
DEFINE FONT oTFont 
oTFont:= TFont():New("Arial",,15,.T.,.T.)

oFwLayer := FwLayer():New()
oFwLayer:init(oPainel,.F.)

oFwLayer:addCollumn( "COL1",100, .T. , "LINHA2") 
oFwLayer:addWindow( "COL1", "WIN1", STR0054, 100, .F., .F., , "LINHA2")//"Dados da ultima Sincronização"	

	oWndSinc := oFwLayer:GetWinPanel("COL1","WIN1","LINHA2") 
	
	@ 015, 008 SAY oData PROMPT STR0055  COLOR CLR_BLUE SIZE 025, 007 PIXEL OF oWndSinc //"Data/Hora"
	@ 016, 043 MSGET oGetData VAR cData COLOR CLR_BLUE SIZE 040, 010 PIXEL OF oWndSinc 
	oGetData:Disable() 
	@ 016, 085 MSGET oGetHora VAR cHora SIZE 030, 010 OF oWndSinc  PIXEL 
	oGetHora:Disable() 
	@ 032, 008 SAY oStatus PROMPT STR0056  COLOR CLR_BLUE SIZE 035, 007 OF oWndSinc  PIXEL //"Status"
	@ 030, 043 MSGET oGetStatus VAR cStatus SIZE 040, 010 OF oWndSinc  PIXEL 
	oGetStatus:Disable() 
	@ 030, 085 BUTTON oButton PROMPT  STR0057 SIZE 034, 012 ACTION (FT320MsgRetorno(cStatus,cMensagem))OF oWndSinc PIXEL //"Detalhes"	


If aCrmInfVen[1]
	oTimer := TTimer():New(2000,  {|| FT320BRefresh(@cStatus, @cMensagem, @cData, @cHora , oGetStatus , oGetData, oGetHora )  } , oPainel:oWnd )
	oTimer:Activate()
EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} Ft321VldHr()
Função responsavel pela validação de horas.
@param oModel
@Return lRet, define se a hora é valida ou não.
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------

Static Function Ft321VldHr( cHoraIni, cHoraFim ) 

Local cHora1      := cHoraIni
Local cHora2    := cHoraFim
Local cHrLimite := STR0048          //"23:59"
Local lRet                            := .F.
Local cVar      := ReadVar()

//Agenda
If cVar == "M->AD7_HORA1"
                cHora1 := M->AD7_HORA1
                
                If Empty(cHora1)
                               cHora1 := M->AD7_HORA1
                EndIf
                
                If AtVldHora(cHora1) .AND. cHora1 <= cHrLimite
                               lRet := .T.
                EndIf

ElseIf cVar == "M->AD7_HORA2"            

    cHora2 := M->AD7_HORA2
                
                If Empty(cHora2)
                               cHora2 := cHoraFim
                EndIf
                
                If AtVldHora(cHora2)
                               lRet := .T.
                EndIf
                
                If cHora2 >= cHora1 .AND. cHora2 <= cHrLimite
                               lRet := .T.
                Else
                               Help( " ", 1, STR0039, , STR0045, 1 )         //"Atenção" ## "A hora final deve ser maior ou igual que a hora inicial."
                               lRet := .F.
                EndIf

EndIf

//Tarefa
If cVar == "M->AD8_HORA1"

    cHora1 := M->AD8_HORA1

                If Empty(cHora1)
                               cHora1 := M->AD8_HORA1
                EndIf
                
                If AtVldHora(cHora1)
                               lRet := .T.
                EndIf

ElseIf cVar == "M->AD8_HORA2"            

    cHora2 := M->AD8_HORA2
                
                If Empty(cHora2)
                               cHora2 := cHoraFim
                EndIf
                
                If AtVldHora(cHora2)
                               lRet := .T.
                EndIf
                
                If cHora2 >= cHora1
                               lRet := .T.
                Else
                               Help( " ", 1, STR0039, , STR0045, 1 )         //"Atenção" ## "A hora final deve ser maior ou igual que a hora inicial."
                               lRet := .F.
                EndIf


EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321CAtInfVend
                                   
Função criada para atualizar o Array 'aCrmInfVen' com as informações do vendedor 
Atualizadas.

Observação  
	rotina usada somente no modulo CRM

posicoes do array aCrmInfVen
cUser             [2][1]
cSenhaUsu         [2][2]
lAgenda           [2][3]
dDtAgeIni         [2][4]
dDtAgeFim         [2][5]
lTarefa           [2][6]
dDtTarIni         [2][7]
dDtTarFim         [2][8]
cEndEmail         [2][9]
SA3->A3_SINCTAF  [2][10]
SA3->A3_SINCAGE  [2][11]
SA3->A3_SINCCON  [2][12]
SA3->A3_TIMEMIN  [2][13]
SA3->A3_BIAGEND  [2][14]
SA3->A3_BITAREF  [2][15]
SA3->A3_BICONT   [2][16]
SA3->A3_PERAGE   [2][17]
SA3->A3_PERTAF   [2][18]
SA3->A3_HABSINC  [2][19]


@sample	Ft321CAtInfVend(aInfoVend)

@param		ExpA1 = Array contendo os dados do usuario atualizado 

@return	Nenhum  

@author	Victor Bitencourt
@since		11/11/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------
Function Ft321CAtInfVend(aInfoVend)

Default aInfoVend := {}

If Len(aInfoVend) > 0 .AND. !Empty(aCrmInfVen)
	aCrmInfVen[_PREFIXO,1]  := aInfoVend[12]
	aCrmInfVen[_PREFIXO,2]  := aInfoVend[14]
	aCrmInfVen[_PREFIXO,3]  := aInfoVend[1]
	aCrmInfVen[_PREFIXO,4]  := aInfoVend[2]
	aCrmInfVen[_PREFIXO,5]  := aInfoVend[3]
	aCrmInfVen[_PREFIXO,6]  := aInfoVend[4]
	aCrmInfVen[_PREFIXO,7]  := aInfoVend[5]
	aCrmInfVen[_PREFIXO,8]  := aInfoVend[6]
	aCrmInfVen[_PREFIXO,9]  := aInfoVend[13]
	If Val(aInfoVend[11]) > 0 
		aCrmInfVen[_PREFIXO,13] := aInfoVend[11]
    EndIf 
    aCrmInfVen[_PREFIXO,17] := aInfoVend[9]
	aCrmInfVen[_PREFIXO,18] := aInfoVend[10]
EndIf

Return 

//----------------------------------------------------------
/*/{Protheus.doc} FT321Trigger()

Funcao que é executada ao selecionar o tipo de Atividade(1-Agendamento/2-Tarefa) e "inicializa" os valores padrão para as colunas da linha atual.
Esta funcao deve ser executada somente quando for incluir uma atividade.

@param oModel
@param oStruAtiv
@Return uConteudo, desconhecido, Conteudo da coluna recno da linha atual
@author Reynaldo Miyashita
@since 22/01/2014
/*/
//----------------------------------------------------------
Function FT321Trigger(oModel,oStruAtiv)
Local uRetorno 	:= NIL
Local uConteudo 	:= NIL
Local nCntField 	:= 0
Local cInitPad  	:= ""
Local cColunm 	:= ""
Local bWhen 
Local bValid 
Local aArea    	:= GetArea()
Local aAreaSX3 	:= SX3->(GetArea())
Local aBkpVar 	:= Array(2) // [1] conteudo de INCLUI, [2] conteudo de ALTERA

	If ValType(INCLUI) == "L" // Se existir a variavel Inclui, guarda o valor
		aBkpVar[1]:= INCLUI
	EndIf
	
	If ValType(ALTERA) == "L" // se existir a variavel altera, guarda o valor
		aBkpVar[2]:= ALTERA
	EndIf
	
	SX3->(dbSetOrder(2))
 
	If oModel:GetModel( 'MODEL_ATIV_GRID' ):GetValue('TIPO_ATIV')== "1" //agendamento
		For nCntField := 1 To len(aCamposAtiv)
			INCLUI := .T.
			ALTERA := .F.
			
			cColunm := IIf( Empty(aCamposAtiv[nCntField,1]),aCamposAtiv[nCntField,2], aCamposAtiv[nCntField,1])				
					
			bWhen := oStruAtiv:GetProperty( cColunm, MODEL_FIELD_WHEN)
			oStruAtiv:SetProperty( cColunm, MODEL_FIELD_WHEN, {||.T.})
			bValid := oStruAtiv:GetProperty( cColunm, MODEL_FIELD_VALID)
			oStruAtiv:SetProperty( cColunm, MODEL_FIELD_VALID, {||.T.})
			
			If Empty(aCamposAtiv[nCntField,1])
				oModel:GetModel( 'MODEL_ATIV_GRID' ):ClearField(cColunm)		
			Else
				Do Case
					Case AllTrim(aCamposAtiv[nCntField,1])=='AD7_CODCLI'
						oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 1))
					Case AllTrim(aCamposAtiv[nCntField,1])=='AD7_LOJA'
						oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 2))
					Case AllTrim(aCamposAtiv[nCntField,1])=='AD7_PROSPE'
						oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 3))
					Case AllTrim(aCamposAtiv[nCntField,1])=='AD7_LOJPRO'
						oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 4))
					Case AllTrim(aCamposAtiv[nCntField,1]) == "AD7_NOMCLI"
						If oModel:GetModel('MODEL_FILTROS'):GetValue('ENTIDADE')=="SA1"
							uConteudo := POSICIONE("SA1",1,XFILIAL("SA1")+padr(oModel:GetModel('MODEL_FILTROS'):GetValue('CODENT'),TamSX3("A1_COD")[1])+Padr(oModel:GetModel('MODEL_FILTROS'):GetValue('LOJENT'),TamSX3("A1_LOJA")[1]),"A1_NOME")
							uConteudo := Alltrim(Left(uConteudo,oStruAtiv:GetProperty(cColunm, MODEL_FIELD_TAMANHO ) ))
							oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue('AD7_NOMCLI', uConteudo)
						EndIf
					Otherwise
						cInitPad := FT321GetInit(aCamposAtiv[nCntField,1])
						If Empty(cInitPad)
							oModel:GetModel( 'MODEL_ATIV_GRID' ):ClearField(cColunm)
						Else
							uConteudo := &(cInitPad)
							If SX3->(dbSeek(Alltrim(aCamposAtiv[nCntField,1])))
								If SX3->X3_TIPO == "C"
									If ValType(uConteudo) == "N"
										uConteudo := str(uConteudo,SX3->X3_TAMANHO)
									Else
										If ValType(uConteudo) == "D"
											uConteudo := dtoc(uConteudo)
										EndIf
									EndIf
									uConteudo := Alltrim(Left(uConteudo,oStruAtiv:GetProperty(cColunm, MODEL_FIELD_TAMANHO ) ))
								EndIf
							EndIf
							If oModel:GetModel( 'MODEL_ATIV_GRID' ):GetValue(cColunm)<>uConteudo
								oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue( cColunm, uConteudo)
							EndIf
						EndIf
				EndCase
			EndIf
			oStruAtiv:SetProperty( cColunm	, MODEL_FIELD_WHEN , bWhen)
			oStruAtiv:SetProperty( cColunm, MODEL_FIELD_VALID, bValid)
		Next nCntField
	Else
		If oModel:GetModel( 'MODEL_ATIV_GRID' ):GetValue('TIPO_ATIV')== "2" //tarefa
			For nCntField := 1 To len(aCamposAtiv)
			
				cColunm := IIf( Empty(aCamposAtiv[nCntField,1]),aCamposAtiv[nCntField,2], aCamposAtiv[nCntField,1])				
			
				bWhen := oStruAtiv:GetProperty( cColunm, MODEL_FIELD_WHEN)
				oStruAtiv:SetProperty( cColunm, MODEL_FIELD_WHEN, {||.T.})
				bValid := oStruAtiv:GetProperty( cColunm, MODEL_FIELD_VALID)
				oStruAtiv:SetProperty( cColunm, MODEL_FIELD_VALID, {||.T.})
				
				If Len(aCamposAtiv[nCntField])>1 .AND. aCamposAtiv[nCntField,2] <> NIL .AND. !Empty(aCamposAtiv[nCntField,2])
					Do Case
						Case AllTrim(aCamposAtiv[nCntField,2])=='AD8_CODCLI'
							oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 1))
						Case AllTrim(aCamposAtiv[nCntField,2])=='AD8_LOJCLI'
							oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 2))
						Case AllTrim(aCamposAtiv[nCntField,2])=='AD8_PROSPE'
							oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 3))
						Case AllTrim(aCamposAtiv[nCntField,2])=='AD8_LOJPRO'
							oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, FT321IniConta(oModel, 4))
						Case AllTrim(aCamposAtiv[nCntField,2])=='AD8_MEMO'
							oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm, )							
						Otherwise					
							cInitPad := FT321GetInit(aCamposAtiv[nCntField,2])
							If !Empty(cInitPad)
								uConteudo := &(cInitPad)
								If SX3->(dbSeek(Alltrim(aCamposAtiv[nCntField,2])))
									If SX3->x3_TIPO == "C"
										If ValType(uConteudo) == "N"
											uConteudo := str(uConteudo,SX3->X3_TAMANHO)
										Else
											If ValType(uConteudo) == "D"
												uConteudo := dtoc(uConteudo)
											EndIf
										EndIf
										uConteudo := Alltrim(Left(uConteudo,oStruAtiv:GetProperty(cColunm, MODEL_FIELD_TAMANHO) ))
									EndIf
								EndIf
								If oModel:GetModel( 'MODEL_ATIV_GRID' ):GetValue(cColunm)<>uConteudo
									oModel:GetModel( 'MODEL_ATIV_GRID' ):SetValue(cColunm,uConteudo)
								EndIf
							Else
								oModel:GetModel( 'MODEL_ATIV_GRID' ):ClearField(cColunm)
								
							EndIf
					EndCase
				Else
					oModel:GetModel( 'MODEL_ATIV_GRID' ):ClearField(cColunm)
				EndIf
				oStruAtiv:SetProperty( cColunm, MODEL_FIELD_WHEN , bWhen)
				oStruAtiv:SetProperty( cColunm, MODEL_FIELD_VALID, bValid)					
			Next nCntField
		EndIf
	EndIf
	
	uRetorno := oModel:GetModel( 'MODEL_ATIV_GRID' ):GetValue("RECNO")

	If aBkpVar[1]<>NIL  // restaura o valor original, caso ela existisse antes
		INCLUI := aBkpVar[1]
	EndIf
	
	If aBkpVar[2]<>NIL // restaura o valor original, caso ela existisse antes
		ALTERA := aBkpVar[2]
	EndIf
	
RestArea(aAreaSX3)
RestArea(aArea)

Return uRetorno

//----------------------------------------------------------
/*/{Protheus.doc} FT321LPos()
Pos-validacao da linha do modelo de dados

@param 

@Return lRet , logico, define se bloqueia ou nao
@author Servicos
@since 21/08/2015
/*/
//----------------------------------------------------------
Static Function FT321LPos(oMdlGrid)

Local lRet 	  	:= .T.
Local lFT321LOK	:= ExistBlock("FT321LOK")

lRet := FT321Obrigat()

If lRet .AND. ! Empty(oMdlGrid:GetValue("AD8_HRREMI")) .AND. Empty(oMdlGrid:GetValue("AD8_DTREMI"))
	Help(" ", 1, STR0039, , STR0067, 1)         //"Atenção" ## "Data do lembrete da tarefa não informada"
	lRet := .F.
EndIf

If lRet .AND. ! Empty(oMdlGrid:GetValue("AD8_DTREMI")) .AND.;
              ( oMdlGrid:GetValue("AD8_DTREMI") > oMdlGrid:GetValue("AD7_DATA") .OR.;
                ( oMdlGrid:GetValue("AD8_DTREMI") == oMdlGrid:GetValue("AD7_DATA") .AND. oMdlGrid:GetValue("AD8_HRREMI") > oMdlGrid:GetValue("AD7_HORA1") ) )
	Help(" ", 1, STR0039, , STR0068, 1)         //"Atenção" ## "Data/hora do lembrete da tarefa é posterior à data inicial."
	lRet := .F.
EndIf

If lRet .And. lFT321LOK
	lRet := ExecBlock("FT321LOK",.F.,.F.,{oMdlGrid})
EndIf

If lRet .AND. !IsBlind() .AND. oMdlGrid:IsModified()
	_lForcaGrv		:= .T.
EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} FT321Obrigat()

Valida os campos obrigatorios
@Return lRet , logico, retorno da validação
@author Servicos
@since 21/08/2015
/*/
//----------------------------------------------------------
Static Function FT321Obrigat()

Local lRet			:= .T.
Local nX 			:= 0 
Local cPrefixo 	:= "" 


If FwFldGet("TIPO_ATIV") == "1"
	cPrefixo := "AD7"
Else
	cPrefixo := "AD8"
EndIf

For nX := 1 To Len( aObrigat )
	If SubStr(aObrigat[nX][1],1,3) == cPrefixo
		If Empty( FwFldGet(aObrigat[nX][1]) )
			Help(" ",1,"FT321OBRIGAT",,STR0063 + aObrigat[nX][2] + "("+ aObrigat[nX][1] +") " + STR0064,1,0)
			lRet := .F.
			Exit
		EndIf	
	EndIf
Next nX

Return( lRet )

//----------------------------------------------------------
/*/{Protheus.doc} FT321Oport()
Filtro das Oportunidades do Vendedor 
Filtro chamado da consulta padrão AD1

@param 

@Return Nil 
@author Servicos
@since 16/05/2016
/*/
//----------------------------------------------------------
Function FT321Oport(lLogical)

Local cVar		:= ReadVar()
Local uFiltro   := Nil

Default lLogical := .T.

If lLogical
	uFiltro := .T.	
Endif

If "AD7_NROPOR" $ cVar .Or. "AD5_NROPOR" $ cVar
	If lLogical
		uFiltro := AD1->AD1_VEND == ADL->ADL_VEND
	Else
		uFiltro := "@ AD1_VEND = '" + ADL->ADL_VEND + "'"
	EndIf
EndIf	

Return uFiltro


//----------------------------------------------------------
/*/{Protheus.doc} FT321AddTrigger()

Cria os gatilhos da AD7 / AD8.

@Return lRet , logico, retorno da validação
@author Servicos
@since 21/08/2015
/*/
//----------------------------------------------------------
Static Function FT321AddTrigger(oStruAtiv, aCamposAtiv)

Local nX 			:= 0
Local nY			:= 0
Local aFields		:= {}
Local lSeek		:= .F.
Local aTrigger	:= {}

Default oStruAtiv 	:= Nil
Default aCamposAtiv	:= Nil

SX7->( DBSetOrder( 1 ) )

For nX := 1 To Len( aCamposAtiv )
	
	If !Empty( aCamposAtiv[nX][1] )	
		aAdd( aFields, aCamposAtiv[nX][1] )
	EndIf
	
	If Len( aCamposAtiv[nX] ) == 2 .And. !Empty( aCamposAtiv[nX][2] )		
		aAdd( aFields, aCamposAtiv[nX][2] )
	EndIf
	
	For nY := 1 To Len( aFields )
		If GetSX3Cache( aFields[nY], "X3_TRIGGER" ) == "S" .And. !aFields[nY] $ 'AD7_HORA1|AD8_HORA1|AD7_HORA2|AD8_HORA2|' 
			If SX7->( MSSeek(aFields[nY] ) )
				If SX7->X7_SEEK == "S"
					lSeek := .T.
				Else
					lSeek := .F. 
				EndIf
					
				aTrigger := FwStruTrigger(SX7->X7_CAMPO,SX7->X7_CDOMIN,SX7->X7_REGRA,lSeek,SX7->X7_ALIAS,SX7->X7_ORDEM,SX7->X7_CHAVE,SX7->X7_CONDIC,SX7->X7_SEQUENC)
				If !Empty( aTrigger )
					oStruAtiv:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])
				EndIf
				aTrigger := {}
			EndIf
		EndIf
	Next nY
	
	aFields := {}
	
Next nX 

Return Nil
