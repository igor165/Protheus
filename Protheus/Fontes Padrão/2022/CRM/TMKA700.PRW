#include "TMKA700.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'TOPCONN.CH'

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKA700()
Tela de cadastro de contatos bloqueados.

@author Vendas CRM                                                                              
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TMKA700()

Local oBrowse	:= Nil  
Local aPDFields := {"A1_TEL"}                                                                          

//Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
FATPDLoad(Nil,Nil,aPDFields)    

//Cria o Browse
oBrowse := FWMBrowse():New()
oBrowse:SetMenuDef('TMKA700')
oBrowse:SetAlias('AIK')
oBrowse:SetDescription(STR0001)//"Cadastro de Contatos Bloqueados"
oBrowse:Activate()

//Finaliza o gerenciamento dos campos com proteção de dados.
FATPDUnLoad()

Return(.T.)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Cria opções no menu

@return aRotina - Opções de menu.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0078  Action 'VIEWDEF.TMKA700' 	 OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina Title STR0079  Action 'VIEWDEF.TMKA700' 	 OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina Title STR0080  Action 'VIEWDEF.TMKA700' 	 OPERATION 4 ACCESS 0	// "Alterar"
ADD OPTION aRotina Title STR0081  Action 'VIEWDEF.TMKA700' 	 OPERATION 5 ACCESS 0	//"Excluir"
ADD OPTION aRotina Title STR0082  Action 'VIEWDEF.TMKA700' 	 OPERATION 8 ACCESS 0	//"Imprimir"
ADD OPTION aRotina Title STR0083  Action 'VIEWDEF.TMKA700' 	 OPERATION 9 ACCESS 0	//"Copiar"
ADD OPTION aRotina Title STR0084  Action 'TK700BLQCONT' 	 OPERATION 3 ACCESS 0	//"Assistente"

Return aRotina

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Monta dela de cadastro relacionando as talebas AIK e AIL

@return oModel - Model.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel 	:= MPFormModel():New( 'TMKA700' ,,{ |oMdl| TK700Pos( oModel ) }, { |oModel| TK700Comit( oModel ) })
Local oStruAIK	:= FWFormStruct( 1, 'AIK' )
Local oStruAIL	:= FWFormStruct( 1, 'AIL' )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("AIKMASTER", /*cOwner*/, oStruAIK )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("AILDETAIL","AIKMASTER", oStruAIL,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/, /*bLoad*/)

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation("AILDETAIL", { { "AIL_FILIAL","xFilial('AIL' )" }, {"AIL_CODAIK","AIK_COD" } }, AIL->( IndexKey( 1 ) ) )

oModel:GetModel("AILDETAIL"):SetUniqueLine({"AIL_REFROT"})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0002)//"Contatos Bloqueados"

oModel:GetModel("AIKMASTER"):SetDescription(STR0003)//"Cabeçalho regra por margem"//"Cabeçalho"
oModel:GetModel("AILDETAIL"):SetDescription(STR0004)//"Itens da regra por margem"//"Itens"

oModel:GetModel("AILDETAIL"):SetOptional( .T. )

Return oModel

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700Pos()
Faz a validação se os campos AIK_TEL ou AIK_EMAIL estão preenchidos.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function TK700Pos( oModel )

Local lRet	:= .T.

If Empty( oModel:GetValue( 'AIKMASTER', 'AIK_TEL' ) ) .And. Empty( oModel:GetValue( 'AIKMASTER', 'AIK_EMAIL' ) )
	Help(" ",1,"TK700POS")
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700Comit()
Faz inclusão das rotinas a serem bloqueadas na AIL, criado dessa maneira devido a utilização do
Mile.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function TK700Comit ( oModel )

Local lSeek     := .F.       

DbSelectAre("AIK")
DbSetOrder(2)              

lSeek := DbSeek(xFilial("AIK") + Padr( FWFldGet('AIK_TEL'), LEN( AIK->AIK_TEL ) ) )

If lSeek

	RecLock("AIK",.F.)
		AIK->AIK_STATUS := oModel:GetValue( 'AIKMASTER', 'AIK_STATUS' )   
	AIK->(MsUnlock())

Else 

	// Se for feita a importação pelo MILE gravamos um registro na AIL.
	If IsInCallStack("FWMILEIMPORT")
		oModel:SetValue( 'AILDETAIL', 'AIL_ITEM',   '01' )
		oModel:SetValue( 'AILDETAIL', 'AIL_REFROT', '01' )
	EndIf
	// Faz a gravação dos valores na AIL.

EndIf


	FWFormCommit( oModel )
	
Return .T. 

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700Comit()
Busca a descrição do codigo da rotina bloqueada.
Mile.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700Desc()

Local cDesc := ""

If !INCLUI

	DbSelectArea("SX5")
	DbSetOrder(1)
	
	If SX5->(DbSeek(xFilial("SX5")+"AI"+AIL->AIL_REFROT))
		cDesc := AllTrim(x5Descri())
	EndIf

EndIf

Return cDesc

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700Duplic()
Valida registros duplicados.

@return lRet - Retorno lógico, se encontrou registro duplicado ou não.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function TK700Duplic(cTelefone)

Local cQuery := ""
Local lRet	   := .F.

If Select("TRB") > 0
   	DBSelectArea("TRB")
    DBCloseArea()
Endif       

cQuery := " SELECT AIK_TEL,AIK_STATUS FROM "+RetSqlName("AIK")+" AIK "+CRLF
cQuery += " WHERE AIK_TEL = '"+cTelefone+"' " 
TcQuery cQuery NEW ALIAS "TRB"

If TRB->(!Eof())
	lRet := .T.
EndIf

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Cria a estrutura baseada na estrutura do model.

@return oView - View.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function ViewDef()

Local oModel 	:= FWLoadModel( 'TMKA700' ) 
Local oStruAIL	:= FWFormStruct( 2, 'AIL' )
Local oView 	:= FWFormView():New()

Local cCpoAIKCab	:= "AIK_COD|AIK_TEL|AIK_EMAIL|AIK_STATUS|AIK_DTCAD|AIK_DTBLOQ|"	//"AIK_ENTIDADE|AIK_CODENT|AIK_LJENT"
Local bAvCpoCab	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoAIKCab}
Local oStruAIK 	:= FWFormStruct(2,"AIK",bAvCpoCab)

oStruAIL:RemoveField('AIL_CODAIK')
oView:SetModel( oModel )
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_AIK', oStruAIK, 'AIKMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_AIL', oStruAIL, 'AILDETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

oView:SetOwnerView( 'VIEW_AIK', 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_AIL', 'INFERIOR' )
 
// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_AIL', 'AIL_ITEM' )

Return oView

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700Gat()
Gatilho que busca o nome da rotina a ser bloqueada.

@return cNome - Nome da rotina a ser bloqueada.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700Gat()

Local cNome 	:= ""

If !Empty(FwFldGet("AIL_REFROT"))
	cNome := Alltrim( Posicione("SX5",1,xFilial("SX5")+"AI"+FwFldGet("AIL_REFROT"),"X5_DESCRI") )
EndIf

Return( Capital(cNome) )

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700VldMan()
Valida bloqueio de contatos na entrada manual.

@return lRet - Retorno lógico, se o contato está ou não bloqueado.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700VldMan(cGerContBlq,cFormaCon,cTipoTel,cRot,cEntContato)

Local aArea     := GetArea()
Local aAreaAGB  := AGB->(GetArea())
Local aAreaAIK  := AIK->(GetArea())
Local aAreaAIL  := AIL->(GetArea())
Local cContBlq  := cGerContBlq
Local cForma    := cFormaCon
Local cTelTipo  := cTipoTel
Local cRotina	:= cRot
Local cDescRot	:= ""
Local cContato  := cEntContato
Local cTelefone := ""
Local cDDD		:= ""
Local aTipoTel	:= {}
Local aTelefone := {}
Local aEmail	:= {}
Local cCodAIK	:= ""
Local nX		:= 0
Local nY		:= 0
Local lRet	    := .T.

//Tratamento de rotina de bloqueio de acordo com tabela AI da SX5.
If cRotina == "1"
	cRotina  := "01"
	cDescRot := STR0005//"TeleMarketing"
ElseIf cRotina == "2"
	cRotina  := "02"
	cDescRot := STR0006//"TeleVendas"
ElseIf cRotina == "3"
	cRotina  := "03"
	cDescRot := STR0007//"TeleCobrança"
ElseIf cRotina == "5"
	cRotina  := "04"
	cDescRot := STR0008//"TeleAtendimento"
EndIf

If cContBlq == "2"
    
	//varrer AGB do contato e verificar se tipos de telefone é igual a ao do campo U4_TIPOTEL e verificar se o numero esta
	//com AIK_STATUS = "1" - bloqueado na AIK

	If cForma == "1" .Or. cForma == "2" // Voz ou Fax
	    //Busca os telefones do Contato.
		DbSelectArea("AGB")
		AGB->(DbSetOrder(4))	//AGB_FILIAL, AGB_ENTIDA, AGB_CODENT, AGB_DDD, AGB_TELEFO	
		If AGB->(DbSeek(xFilial("AGB")+"SU5"+PadR(cContato,Len(AGB->AGB_CODENT))))
		   While AGB->(!EOF()) .AND. AGB->AGB_FILIAL == xFilial("AGB") .AND. AGB->AGB_ENTIDA == "SU5" .AND. AllTrim(AGB->AGB_CODENT) == cContato
		   			Aadd(aTelefone,{AllTrim(AGB->AGB_DDD)+AllTrim(AGB->AGB_TELEFO)})
		   AGB->(DbSkip())
		   EndDo
		EndIf
		    //Verifica se o telefone está bloqueado.
			DbSelectArea("AIK")
			AIK->(DbSetOrder(2))	//AIK_FILIAL, AIK_TEL, AIK_STATUS, AIK_ENTIDA, AIK_CODENT

			DbSelectArea("AIL")
			AIL->(DbSetOrder(2))	//AIL_FILIAL, AIL_CODAIK,AIL_REFROT

			For nX := 1 To Len(aTelefone)
				If AIK->(DbSeek(xFilial("AIK")+PadR(AllTrim(aTelefone[nX,1]),Len(AIK->AIK_TEL))+"1")) //+"SU5"+AllTrim(cContato)
						If AIL->(DbSeek(xFilial("AIL")+AllTrim(AIK->AIK_COD)))
							While AIL->(!EOF()) .AND. AllTrim(AIL->AIL_CODAIK) == AllTrim(AIK->AIK_COD)
								Aadd(aTipoTel,{AIL->AIL_REFROT})
							AIL->(DbSkip())
							EndDo
						EndIf
				EndIf
		    Next nX
		    
			    If cRotina == "4" .AND. Len(aTipoTel) > 0
			    	Help( " ", 1, STR0010, , STR0009, 1 )	//"Bloqueio de Contato"//"O Numero de telefone desse contato está bloqueado em todas as rotinas."
					lRet := .F.
				ElseIf cRotina <> "4" .AND. Len(aTipoTel) > 0
				    
				    DbSelectArea("AIL")
					AIL->(DbSetOrder(2))	//AIL_FILIAL, AIL_CODAIK, AIL_REFROT 
					
				    For nY := 1 To Len(aTipoTel)
				    	If AIL->(DbSeek(xFilial("AIL")+AIK->AIK_COD+cRotina))
				    		lRet := .F.
				    	EndIf
			   	    Next xY	
			   	    
				   	    If lRet == .F.
							If cRotina == "01"
								Help( " ", 1, STR0012+cDescRot+".", , STR0011, 1 )//"Bloqueio de Contato"//"O Numero de telefone desse contato está bloqueado para a rotina "								
							ElseIf cRotina == "02"								
								Help( " ", 1, STR0014+cDescRot+".", , STR0013, 1 )//"Bloqueio de Contato"//"O Numero de telefone desse contato está bloqueado para a rotina "
							ElseIf cRotina == "03"
								Help( " ", 1, STR0016+cDescRot+".", , STR0015, 1 )//"Bloqueio de Contato"//"O Numero de telefone desse contato está bloqueado para a rotina "
							ElseIf cRotina == "04"								
								Help( " ", 1, STR0018+cDescRot+".", , STR0017, 1 )//"Bloqueio de Contato"//"O Numero de telefone desse contato está bloqueado para a rotina "
							EndIf
						EndIf
	            EndIf
	EndIf
	
		If cForma == "3"	//Cross Posting
		
			DbSelectArea("SU5")
			SU5->(DbSetOrder(1))	//U5_FILIAL, U5_CODCONT
			If SU5->(DbSeek(xFilial("SU5")+cContato))
				Aadd(aEmail,{AllTrim(U5_EMAIL)})
			EndIf
			
			DbSelectArea("AIK")
			AIK->(DbSetOrder(3))	//AIK_FILIAL, AIK_EMAIL, AIK_STATUS
			If AIK->(DbSeek(xFilial("AIK")+PadR(aEmail[1,1],Len(AIK->AIK_EMAIL))+"1"))
				Help( " ", 1, STR0019, , STR0020, 1 )//"Atenção"//"O Email desse contato está bloqueado."
			lRet := .F.
			EndIf
						
		EndIf
		
EndIf

Asize( aTelefone, 0)
aTelefone := Nil

Asize( aTipoTel, 0)
aTipoTel := Nil

RestArea(aAreaAGB)
RestArea(aAreaAIK)
RestArea(aAreaAIL)
RestArea(aArea)

Return lRet 

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700VldAut()
Valida bloqueio de contatos rotina automática.

@return lRet - Retorno lógico, se o contato está ou não bloqueado.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700VldAut(cGerContBlq,cFormaCon,cTipoTel,cRot,cEntContato)

Local aArea     := GetArea()
Local aAreaAGB  := AGB->(GetArea())
Local aAreaAIK  := AIK->(GetArea())
Local aAreaAIL  := AIL->(GetArea())

Local cContBlq  := cGerContBlq
Local cForma    := cFormaCon
Local cTelTipo  := cTipoTel
Local cRotina	:= cRot
Local cDescRot	:= ""
Local cContato  := cEntContato
Local cTelefone := ""
Local cDDD		:= ""
Local aTipoTel	:= {}
Local aTelefone := {}
Local aEmail   := {}
Local cCodAIK	:= ""
Local nX		:= 0
Local nY		:= 0
Local lRet	    := .T.

//Tratamento de rotina de bloqueio de acordo com tabela AI da SX5.

If cRotina == "1"
	cRotina  := "01"
	cDescRot := STR0021//"TeleMarketing"
ElseIf cRotina == "2"
	cRotina  := "02"
	cDescRot := STR0022//"TeleVendas"
ElseIf cRotina == "3"
	cRotina  := "03"
	cDescRot := STR0023//"TeleCobrança"
ElseIf cRotina == "5"
	cRotina  := "04"
	cDescRot := STR0024//"TeleAtendimento"
EndIf

If cContBlq == "2"

	//varrer AGB do contato e verificar se tipos de telefone é igual a ao do campo U4_TIPOTEL e verificar se o numero esta
	//com AIK_STATUS = "1" - bloqueado na AIK

	If cForma == "1" .Or. cForma == "2" // Voz ou Fax
	    
		DbSelectArea("AGB")
		AGB->(DbSetOrder(4))	//AGB_FILIAL, AGB_ENTIDA, AGB_CODENT, AGB_DDD, AGB_TELEFO	
		If AGB->(DbSeek(xFilial("AGB")+"SU5"+PadR(cContato,Len(AGB->AGB_CODENT))))
		   While AGB->(!EOF()) .AND. AGB->AGB_FILIAL == xFilial("AGB") .AND. AGB->AGB_ENTIDA == "SU5" .AND. AllTrim(AGB->AGB_CODENT) == cContato
		   			Aadd(aTelefone,{AllTrim(AGB->AGB_DDD)+AllTrim(AGB->AGB_TELEFO)})
		   AGB->(DbSkip())
		   EndDo
		EndIf
		
			DbSelectArea("AIK")
			AIK->(DbSetOrder(2))	//AIK_FILIAL, AIK_TEL, AIK_STATUS, AIK_ENTIDA, AIK_CODENT
            
			DbSelectArea("AIL")
			AIL->(DbSetOrder(2))	//AIL_FILIAL, AIL_CODAIK,AIL_REFROT 

			For nX := 1 To Len(aTelefone)
				If AIK->(DbSeek(xFilial("AIK")+PadR(AllTrim(aTelefone[nX,1]),Len(AIK->AIK_TEL))+"1"))
					If AIL->(DbSeek(xFilial("AIL")+AllTrim(AIK->AIK_COD)))
						While AIL->(!EOF()) .AND. AllTrim(AIL->AIL_CODAIK) == AllTrim(AIK->AIK_COD)
							Aadd(aTipoTel,{AIL->AIL_REFROT})
							AIL->(DbSkip())
						EndDo
					EndIf
				EndIf
		    Next nX
		    
		    If cRotina $ "01/02/03/04" .AND. Len(aTipoTel) > 0
				lRet := .F.
			EndIf

	EndIf

	If cForma == "3"	//Cross Posting
		
		DbSelectArea("SU5")
		DbSetOrder(1)	//U5_FILIAL, U5_CODCONT
		If SU5->(DbSeek(xFilial("SU5")+cContato))
			Aadd(aEmail,{AllTrim(U5_EMAIL)})
		EndIf
			
			DbSelectArea("AIK") 
			DbSetOrder(3)	//AIK_FILIAL, AIK_EMAIL, AIK_STATUS
			If AIK->(DbSeek(xFilial("AIK")+PadR(aEmail[1,1],Len(AIK->AIK_EMAIL))+"1"))
				lRet := .F.
			EndIf
						
	EndIf
	    
EndIf

Asize( aTelefone, 0)
aTelefone := Nil

Asize( aTipoTel, 0)
aTipoTel := Nil

RestArea(aAreaAGB)
RestArea(aAreaAIK)
RestArea(aAreaAIL)
RestArea(aArea)

Return lRet                                                                                 

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700VldTelMail()
Valida no SX3 se o telefone está bloqueado.

@return lRet - Retorno lógico, se o contato está ou não bloqueado.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700VldTelMail(cDDD,cTelefone,cEmail)
		 
Local aArea 	:= GetArea()
Local aAreaADE  := ADE->(GetArea())
Local cTelefone := cDDD+cTelefone	//Não utilizado AllTrim() por causa do tamanho do campo AIK_TEL
Local cEmail	:= AllTrim(cEmail)
Local lRet		:= .T.

DbSelectArea("AIK")
AIK->(DbSetOrder(3)) //AIK_FILIAL, AIK_EMAIL, AIK_STATUS

If !Empty(cEmail)						
	If AIK->(DbSeek(xFilial("AIK")+PadR(AllTrim(cEmail),Len(AIK->AIK_EMAIL))+"1"))
	   Help( " ", 1, Capital(STR0028), , STR0027, 1 )//" O E-mail informado está bloqueado para contato."//"Atenção"
	Endif
EndIf

DbSelectArea("AIK")
AIK->(DbSetOrder(2)) //AIK_FILIAL, AIK_TEL, AIK_STATUS, AIK_ENTIDA, AIK_CODENT

If AIK->(DbSeek(xFilial("AIK")+PadR(AllTrim(cTelefone),Len(AIK->AIK_TEL))+"1"))
   Help( " ", 1, Capital(STR0030), , STR0029, 1 )//" O numero de telefone informado está bloqueado para ligações."//"Atenção"
Endif
	


RestArea(aAreaADE)
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700BlqCont()
Tela facilitadora de bloqueio de contatos que estão associados nas entidades existentes no
sistema.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700BlqCont()

Local oPanel	:= Nil
Local oFWLayer	:= Nil
Local oRad 		:= Nil
Local nRad 		:= 1
Local oLBrowses := Nil
Local oLOpcoes	:= Nil
Local oBrowse 	:= Nil
Local oBtn 		:= Nil
Local oCheckBo1 := Nil
Local lCheckBo1 := .F. //01
Local oCheckBo2 := Nil
Local lCheckBo2 := .F. //02
Local oCheckBo3 := Nil
Local lCheckBo3 := .F. //03
Local oCheckBo4 := Nil
Local lCheckBo4 := .F. //04
Local oCheckBo5 := Nil
Local oGrpEnt	:= Nil
Local oEnt		:= Nil
Local oEntidade	:= Nil
Local oRot		:= Nil
Local oRotina	:= Nil
Local oGrpRot	:= Nil
Local aRot		:= {}

DEFINE MSDIALOG oPanel TITLE STR0031 FROM 050,050 TO 500,800 PIXEL//"Bloqueio de Telefones"
 		
// Configura o FWLayer	
oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F. )

oFWLayer:AddCollumn( "Coluna 1", 30 )
oFWLayer:AddWindow( "Coluna 1", "Window 1", "", 100, .F., .T., , , , CONTROL_ALIGN_CENTER ) //"Entidades/Opções"

oFWLayer:AddCollumn( "Coluna 2", 70 )
oFWLayer:AddWindow( "Coluna 2", "Window 2", "", 100, .F., .T., , , , CONTROL_ALIGN_CENTER ) //"Browse"

oLOpcoes		:= oFWLayer:GetWinPanel( "Coluna 1", "Window 1" )
oLBrowses		:= oFWLayer:GetWinPanel( "Coluna 2", "Window 2" )

@ 001, 005 GROUP oEnt TO 008, 033 PROMPT "" OF oLOpcoes PIXEL
@ 001, 007 SAY oEntidade PROMPT STR0032 SIZE 025, 007 OF oLOpcoes PIXEL//"Entidades"
@ 008, 005 GROUP oGrpEnt TO 050, 096 PROMPT "" OF oLOpcoes PIXEL
@ 010, 010 RADIO oRad VAR nRad ITEMS STR0033,STR0035,STR0036,STR0034 SIZE 040, 037 OF oLOpcoes PIXEL;//"Clientes"//"Contatos"//"Prospects"//"Suspects"
ON CLICK ( TK700BrwDin(oBrowse,oLBrowses,nRad,STR0037,aRot) )//"Clientes"

@ 055, 005 GROUP oRot TO 062, 033 PROMPT "" OF oLOpcoes PIXEL
@ 055, 007 SAY oRotina PROMPT STR0038 SIZE 025, 007 OF oLOpcoes PIXEL//"Rotinas"
@ 062, 005 GROUP oRot TO 150, 096 PROMPT "" OF oLOpcoes PIXEL

@ 068, 010 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT STR0039             SIZE 048, 008 OF oLOpcoes PIXEL;//"Telemarketing"
ON CHANGE TK700CkcComb(aRot,lCheckBo1,"01")
@ 078, 010 CHECKBOX oCheckBo2 VAR lCheckBo2 PROMPT STR0040               SIZE 048, 008 OF oLOpcoes PIXEL;//"Tele Vendas"
ON CHANGE TK700CkcComb(aRot,lCheckBo2,"02")
@ 088, 010 CHECKBOX oCheckBo3 VAR lCheckBo3 PROMPT STR0041             SIZE 048, 008 OF oLOpcoes PIXEL;//"Tele Cobrança"
ON CHANGE TK700CkcComb(aRot,lCheckBo3,"03")
@ 098, 010 CHECKBOX oCheckBo4 VAR lCheckBo4 PROMPT STR0042          SIZE 060, 008 OF oLOpcoes PIXEL;//"Tele Atendimento"
ON CHANGE TK700CkcComb(aRot,lCheckBo4,"04")

DEFINE SBUTTON FROM 205,075 TYPE 2 OF OPANEL ENABLE ACTION OPANEL:END()

oLBrowses:FreeChildren()

oBrowse:= FWmBrowse():New() 
oBrowse:SetOwner( oLBrowses )                           
oBrowse:SetDescription( STR0044 ) 
oBrowse:SetAlias( "SA1" ) 
oBrowse:DisableDetails() 
oBrowse:SetWalkThru(.F.)
oBrowse:SetAmbiente(.F.)
oBrowse:SetMenuDef( "" )  
oBrowse:Activate() 

//bloco de codigo para duplo click - deve ficar após o activate, senao o FWMBrowse ira sobreescrever com o bloco padrao
oBrowse:BlDblClick := {||TK700BrwSel(oBrowse,nRad,aRot)} 
oBrowse:Refresh()

ACTIVATE MSDIALOG oPanel CENTERED

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700CkcComb()
Valida Combobox

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700CkcComb(aRot,lCheck,cCodRot)

Local nPos

If	lCheck == .T. 
		Aadd(aRot,cCodRot)
Else
	nPos := aScan(aRot,{|x| x==cCodRot})
	If nPos > 0
		aDel(aRot,nPos)
		aSize(aRot,Len(aRot)-1)
	EndIf
EndIf
	 
Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700BrwDin()
Valida Combobox

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700BrwDin(oBrowse,oOwner,nRad,cTitulo,aRot)

If ValType(oBrowse) == "O"
	oBrowse:DeActivate()
EndIf

If nRad == 1
	cAlias := STR0043//"SA1"
	cTitulo := STR0044//"Clientes"
ElseIf nRad == 2
    cAlias := "SUS"
    cTitulo := STR0045//"Prospects"
ElseIf nRad == 3
	cAlias := "ACH"
	cTitulo := STR0046//"Suspects"
ElseIf nRad == 4
	cAlias := "SU5"
	cTitulo := STR0047//"Contatos"
EndIf

oOwner:FreeChildren()

oBrowse:= FWmBrowse():New() 
oBrowse:SetOwner( oOwner )                           
oBrowse:SetDescription( cTitulo ) 
oBrowse:SetAlias( cAlias ) 
oBrowse:DisableDetails() 
oBrowse:SetWalkThru(.F.)
oBrowse:SetAmbiente(.F.)
oBrowse:SetMenuDef( "" )  
oBrowse:Activate() 

//bloco de codigo para duplo click - deve ficar após o activate, senao o FWMBrowse ira sobreescrever com o bloco padrao
oBrowse:BlDblClick := {||TK700BrwSel(oBrowse,nRad,aRot)} 
oBrowse:Refresh()

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700BrwSel()
Verifica entidade selecionada e monta tabela temporaria contendo os telefones que serão bloqueados.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700BrwSel(oBrowse,nRad,aRot)

Local cEntidade		:= oBrowse:cAlias
Local cStru		:={}    //_stru
Local aCpoBro 	:= {}
Local oDlg
Local oButton1 := Nil
Local oButton2 := Nil
Local lInverte := .F.
Local cMark    := GetMark()   
Local oMark
Local nX
Local nY
Local cTipo
Local aEntidades := {}
Local aTelefone := {}
Local cDDD		:= ""
Local aTel		:= {}
Local cAlias	:= ""
Local cStatus	:= "0"
Local aArea := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSUS := SUS->(GetArea())
Local aAreaACH := ACH->(GetArea())
Local aAreaSU5 := SU5->(GetArea())
Local aPDCols := {"","A1_TEL",""} 

Private oTempTable	:= NIL
//Cria um arquivo de Apoio
AADD(cStru,{"OK"     	,"C"	,2		,0		})
AADD(cStru,{"TEL"    	,"C"	,TamSX3("AGB_DDI")[1] + TamSX3("AGB_DDD")[1] + TamSX3("AGB_TELEFO")[1]		,0		})
AADD(cStru,{"TIPO"   	,"C"	,12		,0		})
AADD(cStru,{"STATUSS"   ,"C"	,2		,0		})

//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------

oTempTable	:= FWTemporaryTable():New( "TTRB")


//-------------------------------------------------------------------
// Atribui o  os índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( cStru )

oTempTable:AddIndex("1",{"TEL","STATUSS"})

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//Cliente
If nRad == 1

cAlias := "SA1"

DbSelectArea("SA1")
SA1->(DbSetOrder(1))

Aadd(aEntidades,{A1_COD,A1_LOJA,A1_NOME})

For nX := 1 To Len(aEntidades)
	If SA1->(DbSeek(xFilial("SA1")+aEntidades[nX,1]))
		While SA1->A1_COD == aEntidades[nX,1]
			If !Empty(SA1->A1_TEL)
				Aadd(aTelefone,{SA1->A1_COD,SA1->A1_LOJA,STR0052,TK700DDDSA1(SA1->A1_DDD),SA1->A1_TEL,cStatus})//"Telefone"
			Else
				Help( " ", 1, STR0073, , STR0090, 1 )
			EndIf
			If !Empty(SA1->A1_FAX)
			Aadd(aTelefone,{SA1->A1_COD,SA1->A1_LOJA,STR0053,TK700DDDSA1(SA1->A1_DDD),SA1->A1_FAX,cStatus})//"Fax"
			Else
				Help( " ", 1, STR0073, , STR0091, 1 )
			EndIf
		SA1->(DbSkip())
        EndDo
	EndIf		
Next nX

DbSelectArea("TTRB")

For nY := 1 To Len(aTelefone)
    
	// Valida o DDD.
	If Substr(aTelefone[nY,4],1,1) == '0' .OR. Substr(aTelefone[nY,4],1,1) == ' '
		cDDD := Substr(aTelefone[nY,4],2,2)
	Else
		cDDD := Substr(aTelefone[nY,4],1,2)
	EndIf

	RecLock("TTRB",.T.)
		TTRB->TIPO    :=  aTelefone[nY,3]
		TTRB->TEL     :=  AllTrim(cDDD)+AllTrim(aTelefone[nY,5])
		TTRB->STATUSS := "0"
	TTRB->(MsUnLock())	
Next nY

//Prospect
ElseIf nRad == 2

cAlias := "SUS"

DbSelectArea("SUS")
SUS->(DbSetOrder(1))

Aadd(aEntidades,{US_COD,US_LOJA,US_NOME})

For nX := 1 To Len(aEntidades)
	If SUS->(DbSeek(xFilial("SUS")+aEntidades[nX,1]))
		While SUS->US_COD == aEntidades[nX,1]
			If !Empty(SUS->US_TEL)
	 			Aadd(aTelefone,{SUS->US_COD,SUS->US_LOJA,STR0054,SUS->US_DDD,SUS->US_TEL,cStatus})//"Telefone"
	 		Else
				Help( " ", 1, STR0073, , STR0090, 1 )
			EndIf
			If !Empty(SUS->US_FAX)
	 		Aadd(aTelefone,{SUS->US_COD,SUS->US_LOJA,STR0055,SUS->US_DDD,SUS->US_FAX,cStatus})//"Fax"
			Else
				Help( " ", 1, STR0073, , STR0091, 1 )
			EndIf	 		
		SUS->(DbSkip())
        EndDo
	EndIf		
Next nX

DbSelectArea("TTRB")

For nY := 1 To Len(aTelefone)
	RecLock("TTRB",.T.)
		TTRB->TIPO    :=  aTelefone[nY,3]		
		TTRB->TEL     :=  AllTrim(aTelefone[nY,4])+AllTrim(aTelefone[nY,5])
		TTRB->STATUSS := "0"    //Verde
	TTRB->(MsUnLock())
Next nY

//Suspect
ElseIf nRad == 3

cAlias := "ACH"

DbSelectArea("ACH")
ACH->(DbSetOrder(1))

Aadd(aEntidades,{ACH_CODIGO, ACH_LOJA, ACH_RAZAO})

For nX := 1 To Len(aEntidades)
	If ACH->(DbSeek(xFilial("ACH")+aEntidades[nX,1]))
		While ACH->ACH_CODIGO == aEntidades[nX,1]
			If !Empty(ACH->ACH_TEL)
	 			Aadd(aTelefone,{ACH->ACH_CODIGO,ACH->ACH_LOJA,STR0056,ACH->ACH_DDD,ACH->ACH_TEL,cStatus})//"Telefone"
	 		Else
				Help( " ", 1, STR0073, , STR0090, 1 )
			EndIf
			If !Empty(ACH->ACH_FAX)	 		
	 		Aadd(aTelefone,{ACH->ACH_CODIGO,ACH->ACH_LOJA,STR0057,ACH->ACH_DDD,ACH->ACH_FAX,cStatus})//"Fax"
			Else
				Help( " ", 1, STR0073, , STR0091, 1 )
			EndIf	 		
		ACH->(DbSkip())
        EndDo
	EndIf		
Next nX

DbSelectArea("TTRB")

For nY := 1 To Len(aTelefone)

	RecLock("TTRB",.T.)
		TTRB->TIPO    :=  aTelefone[nY,3]		
		TTRB->TEL     :=  AllTrim(aTelefone[nY,4])+AllTrim(aTelefone[nY,5])
		TTRB->STATUSS := "0"
	TTRB->(MsUnLock())
Next nY

//Contatos
ElseIf nRad == 4

cAlias := "SU5"

DbSelectArea("SU5")
SU5->(DbSetOrder(1))

Aadd(aEntidades,{U5_CODCONT, "  ", U5_CONTAT})

For nX := 1 To Len(aEntidades)

	DbSelectArea("AGB")
	AGB->(DbSetOrder(1))	//AGB_FILIAL, AGB_ENTIDA, AGB_CODENT, AGB_TIPO

	If SU5->(DbSeek(xFilial("SU5")+AllTrim(aEntidades[nX,1])))
		If AGB->(DbSeek(xFilial("AGB")+"SU5"+aEntidades[nX,1]))
			While AllTrim(AGB->AGB_CODENT) == AllTrim(aEntidades[nX,1])
			If !Empty(AGB->AGB_TELEFO)
		 		Aadd(aTelefone,{AGB->AGB_CODENT,"  ",AGB->AGB_TIPO,AGB->AGB_DDD,AGB->AGB_TELEFO,cStatus})
	 		Else
				Help( " ", 1, STR0073, , STR0090, 1 )
			EndIf		 		
			AGB->(DbSkip())
	        EndDo
	    EndIf
	EndIf		
Next nX

DbSelectArea("TTRB")

For nY := 1 To Len(aTelefone)

	If aTelefone[nY,3] = "1"
		cTipo    :=  STR0058//"Comercial"
	ElseIf aTelefone[nY,3] = "2"
		cTipo    :=  STR0059//"Residencial"
	ElseIf aTelefone[nY,3] = "3"
		cTipo    :=  STR0060//"Fax Comercial"
	ElseIf aTelefone[nY,3] = "4"
		cTipo    :=  STR0061//"Fax Residencial"
	ElseIf aTelefone[nY,3] = "5"
		cTipo    :=  STR0062//"Celular"
	EndIf
	
	RecLock("TTRB",.T.)
		TTRB->TIPO    :=  cTipo
		TTRB->TEL     :=  AllTrim(aTelefone[nY,4])+AllTrim(aTelefone[nY,5])
		TTRB->STATUSS := "0"
	TTRB->(MsUnLock())	
Next nY

EndIf

//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
aCpoBro	:= {{ "OK"			,, "  "           	,"@!"},;//"OK"
			{ "TEL"			,, STR0064       ,"@!"},;//"Telefone"
			{ "TIPO"		,, STR0065       	,"@!"}}//"Tipo"

//Cria uma Dialog
DEFINE MSDIALOG oDlg TITLE STR0066 From 9,0 To 180,300 PIXEL//"Telefones"

DbSelectArea("TTRB")
DbGotop()

//Cria a MsSelect 
oMark := MsSelect():New("TTRB",STR0067,"",aCpoBro,@lInverte,@cMark,{2,2,70,150},,,,,)//"OK"
oMark:bMark := {|| TK700Disp(@aTelefone,@aRot,@cStatus,cMark,oMark,TTRB->TEL)}

If FATPDActive() .And. FTPDUse(.T.)
	oMark:oBrowse:aObFuscatedCols := FATPDColObfuscate(aPDCols)    
EndIf

@ 072, 072 BUTTON oButton1 PROMPT STR0068 		 SIZE 037, 012 OF oDlg PIXEL ACTION (TK700Proc(cStatus,aTelefone,cAlias,aRot,oDlg))//"Ok"
@ 072, 112 BUTTON oButton2 PROMPT STR0069 SIZE 037, 012 OF oDlg PIXEL ACTION (oDlg:End(),oBrowse:Refresh())//"Cancelar"
ACTIVATE MSDIALOG oDlg CENTERED

//Fecha a Area e elimina os arquivos de apoio criados em disco.
If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)  
	oTempTable := nil
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSUS)
RestArea(aAreaACH)
RestArea(aAreaSU5)
RestArea(aArea)

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700DDDSA1()
Valida DDD do Cliente.

@return cDDD - Retorno pegando dois digitos do DDD do Cliente.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700DDDSA1(cDDDSa1)

Local cDDD := cDDDSa1

If Substr(cDDD,1,1) == '0' .OR. Substr(cDDD,1,1) == ' '
	cDDD := Substr(cDDD,2,2)
Else
	cDDD := Substr(cDDD,1,2)
EndIf

Return cDDD

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700Disp()
Funcao executada ao Marcar/Desmarcar um registro.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function TK700Disp(aTelefone,aRot,cStatus,cMark,oMark,cTel)

Local nX
Local aArea := GetArea()
Local aAreaTTRB := TTRB->(GetArea())
Local nPos	:= aScan(aTelefone,{|x| (AllTrim(x[4]) + AllTrim(x[5])) == AllTrim(cTel)})


DbSetOrder(1)

If TTRB->(DbSeek(AllTrim(cTel)))
	RecLock("TTRB",.F.)
	If Marked(STR0070)//"OK"
		TTRB->STATUSS 	:= "1"
		aTelefone[nPos,6] := "1"
	Else
		TTRB->STATUSS   := "0"
		aTelefone[nPos,6] := "0"
	Endif
EndIf

TTRB->(MsUnLock())

RestArea(aAreaTTRB)
RestArea(aArea)

oMark:oBrowse:Refresh()



Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700Proc()
Mostra na tela que os registros estão sendo processados.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700Proc(cStatus,aTelefone,cAlias,aRot,oDlg)

Local aRet := {.T., ""}

LjMsgRun(STR0071  ,STR0072,{|| aRet := TK700GrvLis(cStatus,aTelefone,cAlias,aRot,oDlg)})//"Gravando, Aguarde..."//"Lista Telefones Bloqueados"

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK700GrvLis()
Grava os nomeros de telefones selecionados.

@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK700GrvLis(cStatus,aTelefone,cAlias,aRot,oDlg)

Local nX
Local nY
Local cTelefone
Local aArea := GetArea()
Local aAreaAIK := AIK->(GetArea())
Local aAreaAIL := AIL->(GetArea())

If Empty(aRot)
	Help( " ", 1, STR0073, , STR0074, 1 )	//"Atenção"//"Por favor selecione uma rotina a ser bloqueada."
	Return
EndIf

	DbSelectArea("AIK")
	AIK->(DbSetOrder(2))	//AIK_FILIAL, AIK_TEL, AIK_STATUS, AIK_ENTIDA, AIK_CODENT

	For nX := 1 To Len(aTelefone)
	cTelefone := AllTrim(aTelefone[nX,4])+AllTrim(aTelefone[nX,5])
	
			If aTelefone[nX,6] == "1"		 
					If AIK->(DbSeek(xFilial("AIK")+PadR(AllTrim(cTelefone),Len(AIK->AIK_TEL))+"1"))	//+AllTrim(cAlias))
						Help( " ", 1, STR0073, , STR0076, 1 )
						Exit
					Else
						If !AIK->(DbSeek(xFilial("AIK")+AllTrim(cTelefone)))
							RecLock("AIK",.T.)
								AIK->AIK_FILIAL	:= xFilial("AIK")
								AIK->AIK_COD	:= GetSx8Num("AIK","AIK_COD") 
								AIK->AIK_TEL    := AllTrim(cTelefone)
								AIK->AIK_EMAIL  := ""
								AIK->AIK_DTCAD  := DDATABASE
								AIK->AIK_DTBLOQ := DDATABASE
								AIK->AIK_STATUS := "1"
								AIK->AIK_ENTIDA := AllTrim(cAlias)
								AIK->AIK_CODENT := aTelefone[nX,1]
								AIK->AIK_LJENTI	:= aTelefone[nX,2]	
						    AIK->(MsUnLock())
						    ConfirmSX8() 
						EndIf

						DbSelectArea("AIL")						
						For nY := 1 To Len(aRot) 
								RecLock("AIL",.T.)
									AIL_FILIAL  := xFilial("AIL")
									AIL_ITEM    := StrZero(nY,2)
									AIL_CODAIK  := AIK->AIK_COD
									AIL_CODENT	:= AIK->AIK_CODENT
									AIL_REFROT  := aRot[nY]
								AIL->(MsUnLock())
						Next nY
					EndIf					
			EndIf	
		
	Next nX

Asize( aTelefone, 0)
aTelefone := Nil

RestArea(aAreaAIK)
RestArea(aAreaAIL)
RestArea(aArea)

oDlg:End()

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk700Mile()
Cria o layout do Mile para importação da lista do PROCON.

@return lRet - Verdadeiro ou Falso.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function Tk700Mile()

Local lRet		:= .T.
Local cCode 	:= STR0087  							//Codigo do layout	//"TK700IMP"
Local cDesc 	:= Upper(STR0086)						//Descrição			//"Bloqueio de Contatos"
Local cAdapter	:= STR0088 								//Nome do adapter	//"TMKA700"
Local cType		:= "1"                                  //Código tipo
Local cAtivo	:= "1"									//Código ativo
Local cXml		:= ""

cXml :=	'<?xml version="1.0" encoding="UTF-8"?>					'		
cXml +=	'<CFGA600 Operation="4" version="1.01">					'		
cXml +=	'<XZ1MASTER modeltype="FIELDS" >					'		
cXml +=	'	<XZ1_LAYOUT order="1">				'		
cXml +=	'		<value>TK700IMP</value>			'		
cXml +=	'	</XZ1_LAYOUT>				'		
cXml +=	'	<XZ1_TYPE order="2">				'		
cXml +=	'		<value>2</value>			'		
cXml +=	'	</XZ1_TYPE>				'		
cXml +=	'	<XZ1_DESC order="3">				'		
cXml +=	'		<value>'+cDesc+'</value>	'
cXml +=	'	</XZ1_DESC>						'
cXml +=	'	<XZ1_ADAPT order="4">						'
cXml +=	'		<value>TMKA700</value>					'
cXml +=	'	</XZ1_ADAPT>						'
cXml +=	'	<XZ1_STRUC order="5">						'
cXml +=	'		<value>2</value>					'
cXml +=	'	</XZ1_STRUC>						'
cXml +=	'	<XZ1_SEPARA order="6">						'
cXml +=	'		<value>;</value>					'
cXml +=	'	</XZ1_SEPARA>						'
cXml +=	'	<XZ1_TYPEXA order="7">						'
cXml +=	'		<value>1</value>					'
cXml +=	'	</XZ1_TYPEXA>						'
cXml +=	'	<XZ1_SEPINI order="8">						'
cXml +=	'		<value>2</value>					'
cXml +=	'	</XZ1_SEPINI>						'
cXml +=	'	<XZ1_SEPFIN order="9">						'
cXml +=	'		<value>2</value>					'
cXml +=	'	</XZ1_SEPFIN>						'
cXml +=	'	<XZ1_TABLE order="10">						'
cXml +=	'		<value>AIK</value>					'
cXml +=	'	</XZ1_TABLE>						'
cXml +=	'	<XZ1_DESTAB order="11">						'
cXml +=	'		<value>'+cDesc+'</value>					'
cXml +=	'	</XZ1_DESTAB>						'
cXml +=	'	<XZ1_ORDER order="12">						'
cXml +=	'		<value>1</value>					'
cXml +=	'	</XZ1_ORDER>						'
cXml +=	'	<XZ1_SOURCE order="13">						'
cXml +=	'		<value>0000</value>					'
cXml +=	'	</XZ1_SOURCE>						'
cXml +=	'	<XZ1_TIPDAT order="17">						'
cXml +=	'		<value>1</value>					'
cXml +=	'	</XZ1_TIPDAT>						'
cXml +=	'	<XZ1_DECSEP order="18">						'
cXml +=	'		<value>1</value>					'
cXml +=	'	</XZ1_DECSEP>						'
cXml +=	'	<XZ1_EMULTC order="19">						'
cXml +=	'		<value>2</value>					'
cXml +=	'	</XZ1_EMULTC>						'
cXml +=	'	<XZ1_DETOPC order="20">						'
cXml +=	'		<value>2</value>					'
cXml +=	'	</XZ1_DETOPC>						'
cXml +=	'	<XZ1_IMPEXP order="22">						'											
cXml +=	'		<value>1</value>					'											
cXml +=	'	</XZ1_IMPEXP>						'											
cXml +=	'	<XZ1_VERSIO order="23">						'											
cXml +=	'		<value>1.0</value>					'											
cXml +=	'	</XZ1_VERSIO>						'											
cXml +=	'	<XZ1_MVCOPT order="24">						'											
cXml +=	'		<value>1</value>					'											
cXml +=	'	</XZ1_MVCOPT>						'											
cXml +=	'	<XZ1_MVCMET order="25">						'											
cXml +=	'		<value>1</value>					'											
cXml +=	'	</XZ1_MVCMET>						'											
cXml +=	'	<XZ2DETAIL modeltype="GRID">						'											
cXml +=	'		<struct>					'											
cXml +=	'			<XZ2_LAYOUT order="1"></XZ2_LAYOUT>					'										
cXml +=	'			<XZ2_SEQ order="2"></XZ2_SEQ>					'										
cXml +=	'			<XZ2_CHANEL order="3"></XZ2_CHANEL>					'										
cXml +=	'			<XZ2_SUPER order="4"></XZ2_SUPER>					'										
cXml +=	'		</struct>	'															
cXml +=	'		<items>	'															
cXml +=	'			<item id="1" deleted="0" >				'											
cXml +=	'				<XZ2_SEQ>01</XZ2_SEQ>			'											
cXml +=	'				<XZ2_CHANEL>A</XZ2_CHANEL>				'										
cXml +=	'					<XZ3DETAIL modeltype="FIELDS" >				'									
cXml +=	'						<XZ3_CHANEL order="2">			'									
cXml +=	'							<value>A</value>		'									
cXml +=	'						</XZ3_CHANEL>			'									
cXml +=	'						<XZ3_DESC order="3">			'									
cXml +=	'							<value>CANAL A</value>			'								
cXml +=	'						</XZ3_DESC>				'								
cXml +=	'						<XZ3_IDOUT order="4">				'								
cXml +=	'							<value>AIKMASTER</value>			'								
cXml +=	'						</XZ3_IDOUT>				'								
cXml +=	'						<XZ3_OCCURS order="5">				'								
cXml +=	'							<value>1</value>			'								
cXml +=	'						</XZ3_OCCURS>				'								
cXml +=	'					</XZ3DETAIL>					'								
cXml +=	'						<XZ4DETAIL modeltype="GRID" optional="1">					'							
cXml +=	'							<struct>	'										
cXml +=	'								<XZ4_LAYOUT order="1"></XZ4_LAYOUT>					'					
cXml +=	'								<XZ4_CHANEL order="2"></XZ4_CHANEL>					'					
cXml +=	'								<XZ4_SEQ order="3"></XZ4_SEQ>					'					
cXml +=	'								<XZ4_FIELD order="4"></XZ4_FIELD>					'					
cXml +=	'								<XZ4_TYPFLD order="5"></XZ4_TYPFLD>					'					
cXml +=	'								<XZ4_EXEC order="6"></XZ4_EXEC>					'					
cXml +=	'								<XZ4_COND order="7"></XZ4_COND>					'					
cXml +=	'								<XZ4_NOVAL order="8"></XZ4_NOVAL>					'					
cXml +=	'								<XZ4_DESC order="9"></XZ4_DESC>					'					
cXml +=	'								<XZ4_OBS order="10"></XZ4_OBS>					'					
cXml +=	'								<XZ4_SOURCE order="11"></XZ4_SOURCE>					'					
cXml +=	'							</struct>	'										
cXml +=	'							<items>	'										
cXml +=	'								<item id="1" deleted="0" >					'					
cXml +=	'									<XZ4_SEQ>001</XZ4_SEQ>				'					
cXml +=	'									<XZ4_FIELD>AIK_TEL</XZ4_FIELD>				'					
cXml +=	'									<XZ4_TYPFLD>C</XZ4_TYPFLD>				'					
cXml +=	'									<XZ4_NOVAL>2</XZ4_NOVAL>				'					
cXml +=	'									<XZ4_DESC>'+Transform(RetTitle("AIK_TEL"), "@!")+'</XZ4_DESC>				'					
cXml +=	'									<XZ4_SOURCE>0001</XZ4_SOURCE>				'					
cXml +=	'								</item>	'									
cXml +=	'								<item id="2" deleted="0" >			'							
cXml +=	'									<XZ4_SEQ>002</XZ4_SEQ>				'					
cXml +=	'									<XZ4_FIELD>AIK_DTCAD</XZ4_FIELD>				'					
cXml +=	'									<XZ4_TYPFLD>D</XZ4_TYPFLD>				'					
cXml +=	'									<XZ4_COND>.F.</XZ4_COND>				'					
cXml +=	'									<XZ4_NOVAL>2</XZ4_NOVAL>				'					
cXml +=	'									<XZ4_DESC>'+Transform(RetTitle("AIK_DTCAD"), "@!")+'</XZ4_DESC>				'					
cXml +=	'									<XZ4_SOURCE>0002</XZ4_SOURCE>				'					
cXml +=	'								</item>	'									
cXml +=	'								<item id="3" deleted="0" >			'							
cXml +=	'									<XZ4_SEQ>003</XZ4_SEQ>			'						
cXml +=	'									<XZ4_FIELD>AIK_STATUS</XZ4_FIELD>				'					
cXml +=	'									<XZ4_TYPFLD>C</XZ4_TYPFLD>				'					
cXml +=	'									<XZ4_EXEC>IIF (xA == &#39;desbloqueado&#39;, &quot;2&quot;,&quot;1&quot;)</XZ4_EXEC>									'
cXml +=	'									<XZ4_NOVAL>2</XZ4_NOVAL>				'					
cXml +=	'									<XZ4_DESC>'+Transform(RetTitle("AIK_STATUS"), "@!")+'</XZ4_DESC>				'					
cXml +=	'									<XZ4_SOURCE>0003</XZ4_SOURCE>				'					
cXml +=	'								</item>	'									
cXml +=	'								<item id="4" deleted="0" >			'							
cXml +=	'									<XZ4_SEQ>004</XZ4_SEQ>			'						
cXml +=	'									<XZ4_FIELD>AIK_DTBLOQ</XZ4_FIELD>				'					
cXml +=	'									<XZ4_TYPFLD>D</XZ4_TYPFLD>			'						
cXml +=	'									<XZ4_COND>.F.</XZ4_COND>			'						
cXml +=	'									<XZ4_NOVAL>2</XZ4_NOVAL>			'						
cXml +=	'									<XZ4_DESC>'+Transform(RetTitle("AIK_DTBLOQ"), "@!")+'</XZ4_DESC>				'					
cXml +=	'									<XZ4_SOURCE>0004</XZ4_SOURCE>				'					
cXml +=	'								</item>	'									
cXml +=	'							</items>	'										
cXml +=	'						</XZ4DETAIL>		'										
cXml +=	'						<XZ5DETAIL modeltype="GRID" optional="1">					'							
cXml +=	'							<struct>	'										
cXml +=	'								<XZ5_LAYOUT order="1"></XZ5_LAYOUT>				'						
cXml +=	'								<XZ5_CHANEL order="2"></XZ5_CHANEL>				'						
cXml +=	'								<XZ5_SEQ order="3"></XZ5_SEQ>				'						
cXml +=	'								<XZ5_FIELD order="4"></XZ5_FIELD>				'						
cXml +=	'								<XZ5_TYPFLD order="5"></XZ5_TYPFLD>				'						
cXml +=	'								<XZ5_EXEC order="6"></XZ5_EXEC>				'						
cXml +=	'								<XZ5_COND order="7"></XZ5_COND>				'						
cXml +=	'								<XZ5_OBS order="8"></XZ5_OBS>				'						
cXml +=	'								<XZ5_SOURCE order="9"></XZ5_SOURCE>				'						
cXml +=	'							</struct>	'										
cXml +=	'						</XZ5DETAIL>		'										
cXml +=	'			</item>	'														
cXml +=	'		</items>	'															
cXml +=	'	</XZ2DETAIL>		'															
cXml +=	'</XZ1MASTER>		'																
cXml +=	'</CFGA600>		'

DbSelectArea("XXJ")
RecLock("XXJ",.T.)
XXJ->XXJ_CODE 		:= cCode
XXJ->XXJ_DESC 		:= cDesc
XXJ->XXJ_ADAPT	:= cAdapter
XXJ->XXJ_LAYOUT	:= cXml
XXJ->XXJ_TYPE		:= cType 
XXJ->XXJ_ACTIVE	:= cAtivo
XXJ->(MsUnLock())

Return(lRet)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
