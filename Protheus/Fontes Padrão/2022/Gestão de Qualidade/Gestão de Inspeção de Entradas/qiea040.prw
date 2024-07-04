#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "QIEA040.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} QIEA040()
Cadastro dos campos não conformidades
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function QIEA040() 
Local oBrowse  
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SAG")                                          
oBrowse:SetDescription(STR0006)  //"Não conformidades"
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

	Local aRotina := {} //Array utilizado para controlar opcao selecionada

	aAdd(aRotina,{STR0001 ,"PesqBrw"         ,0 ,1 ,0 ,NIL})  //"Pesquisar"
	aAdd(aRotina,{STR0002 ,"VIEWDEF.QIEA040" ,0 ,2 ,0 ,NIL})  //"Visualizar"
	aAdd(aRotina,{STR0003 ,"VIEWDEF.QIEA040" ,0 ,3 ,0 ,NIL})  //"Incluir"
	aAdd(aRotina,{STR0004 ,"VIEWDEF.QIEA040" ,0 ,4 ,0 ,NIL})  //"Alterar"
	aAdd(aRotina,{STR0005 ,"VIEWDEF.QIEA040" ,0 ,5 ,0 ,NIL})  //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  

Local oStruCab := FWFormStruct(1,"SAG") //Estrutura Cabecalho Matriz Abastecimento 
Local oModel   := Nil //Modelo de Dados MVC 

//------------------------------------------------------
//		Cria a estrutura basica
//------------------------------------------------------
oModel:= MPFormModel():New("QIEA040", /*Pre-Validacao*/,{ |oModel| Q040TudOk( oModel ) },/*Commit*/,/*Cancel*/)

//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------	
oModel:AddFields("SAGMASTER",/*cOwner*/,oStruCab)

//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)

Return oModel 

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()

Local oModel   	:= FWLoadModel( "QIEA040" )	 //Carrega model definido
Local oStruCab 	:= FWFormStruct(2,"SAG") //Estrutura Cabecalho Matriz Abastecimento 
Local oView	  	:= FWFormView():New()

//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros'

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField("MASTER_SAG",oStruCab,"SAGMASTER")   //Cabecalho da matriz de abastecimento

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox("CABEC",100)

//--------------------------------------
//		Associa os componentes
//--------------------------------------
oView:SetOwnerView("MASTER_SAG","CABEC")

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} A040DCla()
Inicializador de campo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Function A040DCla(cClasse,lGatilho)
Local cDesc		:= ""
Default lGatilho	:= .T.

Inclui	:= Iif(Type("Inclui") <> "U",Inclui,.F.)

IF !Inclui .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. classe
	QEE->(dbSetOrder(1))		  
	QEE->(dbSeek(xFilial("QEE") + cClasse))
	If __LANGUAGE == "PORTUGUESE"
		cDesc:= QEE->QEE_DESCPO	
	ElseIf __LANGUAGE == "SPANISH"
		cDesc:= QEE->QEE_DESCES
	ElseIf __LANGUAGE == "ENGLISH"
		cDesc:= QEE->QEE_DESCIN
	EndIf
Else                          
	If __LANGUAGE == "PORTUGUESE"
		cDesc:= Space(Len(QEE->QEE_DESCPO))
	ElseIf __LANGUAGE == "SPANISH"
		cDesc:= Space(Len(QEE->QEE_DESCES))
	ElseIf __LANGUAGE == "ENGLISH"
		cDesc:= Space(Len(QEE->QEE_DESCIN))
	EndIf
EndIf

Return cDesc

//--------------------------------------------------------------------
/*/{Protheus.doc} A040ValNco()
Verifica se é permitido Alterar ou Excluir a Nao Conform.
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Function A040ValNco()

Local lRet  := .t.             
Local cCod  := SAG->AG_NAOCON 
Local aArea := GetArea()
Local aFiliais := {}
Local nY       := 0
Local cFilPes  := xFilial("SAG")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar verif. se e' util. em NCs dos Ensaios Modulo Insp. de Entrada    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FWModeAccess("QE2")=="E"//!Empty(xFilial("QE2"))
	aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
Else
	AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())}) //Space(02)
EndIF
For nY:=1 to Len(aFiliais)
	If aFiliais[nY,2]==cFilPes .or. FWModeAccess("SAG") == "C" //Empty(cFilPes)
		dbSelectArea('QE2')
		dbSetOrder(2)
		If dbSeek( aFiliais[nY,2]+cCod)
			HELP(" ",1,"A040DNCENS",,QE2->QE2_ENSAIO,3,1)
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar verif. se e' util. em NCs dos Ensaios Modulo Insp. de Processos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If FWModeAccess("QP2") == "E"//!Empty(xFilial("QP2"))
		aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
	Else
		AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())}) //Space(02)
	EndIF
	For nY:=1 to Len(aFiliais)
		If aFiliais[nY,2]==cFilPes .or. FWModeAccess("SAG") == "C"//Empty(cFilPes)
			dbSelectArea('QP2')
			dbSetOrder(2)
			If dbSeek( aFiliais[nY,2]+cCod)
				HELP(" ",1,"A040DNCENS",,QP2->QP2_ENSAIO,3,1)
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar verif. se e' util. em NCs dos Ens. Produtos Modulo Insp. de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If FWModeAccess("QE9") == "E"//!Empty(xFilial("QE9"))
		aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
	Else
		AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())}) //Space(02)
	EndIF
	For nY:=1 to Len(aFiliais)
		If aFiliais[nY,2]==cFilPes .or. FWModeAccess("SAG") == "C"//Empty(cFilPes)
			dbSelectArea('QE9')
			dbSetOrder(2)
			If dbSeek( aFiliais[nY,2]+cCod)
				HELP(" ",1,"A040DNCPRO",,QE9->QE9_PRODUT+'-'+;
				QE9->QE9_REVI+'-'+QE9->QE9_ENSAIO,3,1)
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nY
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar verif. se e' util. em NCs dos Ens. Produtos Modulo Insp.de Processos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If FWModeAccess("QP9") == "E"//!Empty(xFilial("QP9"))
		aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
	Else
		AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())})
	EndIF
	For nY:=1 to Len(aFiliais)
		If aFiliais[nY,2]==cFilPes .or. FWModeAccess("SAG") == "C"//Empty(cFilPes)
			dbSelectArea('QP9')
			dbSetOrder(2)
			If dbSeek( aFiliais[nY,2]+cCod)
				HELP(" ",1,"A040DNCPRO",,QP9->QP9_PRODUT+'-'+;
				QP9->QP9_REVI+'-'+QP9->QP9_ENSAIO,3,1)
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nY
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar verif. se e' util. em NCs dos Resultados Modulo Insp.Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If FWModeAccess("QEU") == "E" //!Empty(xFilial("QEU"))
		aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
	Else
		AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())})
	EndIF
	For nY:=1 to Len(aFiliais)
		If aFiliais[nY,2]==cFilPes .or. FWModeAccess("SAG") == "C" //Empty(cFilPes)
			dbSelectArea('QEU')
			dbSetOrder(2)
			If dbSeek( aFiliais[nY,2]+cCod)
				HELP(" ",1,"A040DNCRES")
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nY
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar verif. se e' util. em NCs dos Resultados Modulo Insp.Processos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If FWModeAccess("QPU") == "E" //!Empty(xFilial("QPU"))
		aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
	Else
		AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())})
	EndIF
	For nY:=1 to Len(aFiliais)
		If aFiliais[nY,2]==cFilPes .or. FWModeAccess("SAG") == "C" //Empty(cFilPes)
			dbSelectArea('QPU')
			dbSetOrder(2)
			If dbSeek( aFiliais[nY,2]+cCod)
				HELP(" ",1,"A040DNCRES")
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nY
EndIf

RestArea(aArea)

Return (lRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} Q040TudOk()
Validação Tudook
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Function Q040TudOk(oModel)
Local nOperation 	:= oModel:GetOperation()
Local lRet			:= .T.

If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
	lRet:= A040ValNco()
EndIf

Return lRet