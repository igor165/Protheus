#INCLUDE "CRMA030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA030
                                   
Log de Transferencia de Contas

@sample		CRMA030()

@param		ExpU1 = Array com os valores.
            ExpN2 = Numero de identificacao da operacao

@return	Nenhum  

@author	Victor Bitencourt
@since		17/09/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------
Function CRMA030(uRotAuto,nOpcAuto)

Local oBrowse := Nil
Local cFiltro := ""

Default uRotAuto := Nil 
Default nOpcAuto := Nil

If uRotAuto == Nil .AND. nOpcAuto == Nil
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("AIN") 
	oBrowse:SetDescription(STR0001)  //"Log de Tranf. de Contas"
	oBrowse:SetCanSaveArea(.T.) 

	If nModulo == 73 // Filtro do SIGACRM	
		cFiltro := CRMXFilEnt( "AIN", .T. )  
		oBrowse:DeleteFilter( "AO4_FILENT" )
		oBrowse:AddFilter( STR0010, cFiltro, .T., .T., "AO4", , , "AO4_FILENT" )		// "Filtro do CRM" 
		oBrowse:ExecuteFilter()	
	EndIf     
	oBrowse:SetAttach(.T.)
	oBrowse:SetTotalDefault("AIN_FILIAL","COUNT",) // "Total de Registros"
	oBrowse:SetMenudef("CRMA030")
	oBrowse:Activate()
Else
	FWMVCRotAuto(ModelDef(),"AIN",nOpcAuto,{{"AINMASTER",uRotAuto}},/*lSeek*/,.T.)
EndIf	

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

cria o objeto comtendo a estrutura , relacionamentos das tabelas envolvidas 

@sample		ModelDef()

@param		Nenhum

@return		ExpO - o objeto do modelo de dados

@author		Victor Bitencourt
@since		17/09/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 		:= Nil
Local oStructAIN 	:= FWFormStruct(1,"AIN",/*bAvalCampo*/,/*lViewUsado*/)
Local bCommit		:= {|oModel| CRM30MdlPVal(oModel) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia o modelo de dados **********.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := MPFormModel():New("CRMA030",/*bPreValidacao*/,/*bPosValid*/,bCommit,/*bCancel*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no modelo de dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oModel:AddFields("AINMASTER",/*cOwner*/,oStructAIN,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetDescription(STR0002)//"Log de Transferência de Contas"
                                                                                                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deixa o Model como readyonly, nao deixa alterar os dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel("AINMASTER"):SetOnlyView(.T.)

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

monta o objeto que irá permitir a visualização da interfece grafica,
com base no Model

@sample		ViewDef()

@param		Nenhum

@return	    ExpO - objeto de visualizacao da interface grafica.

@author		Victor Bitencourt
@since		17/09/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView 		:= Nil
Local oModel		:= FwLoadModel("CRMA030")
Local oStructAIN 	:= FWFormStruct(2,"AIN",/*bAvalCampo*/,/*lViewUsado*/)

oStructAIN:RemoveField("AIN_CODSOL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia a interface ************.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oView := FWFormView():New()
oView:SetContinuousForm() // Seta formulario continuo 
oView:SetModel(oModel)

oView:AddField("VIEW_AIN",oStructAIN,"AINMASTER")

oView:CreateHorizontalBox("VIEW_TOP",100)
oView:SetOwnerView("VIEW_AIN","VIEW_TOP")

Return(oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Monta um array contendo as operaçoes que serão permitidas o usuario realizar 
no programa

@sample		MenuDef()

@param		Nenhum

@return		ExpA -  Array contendo as operaçoes que podem ser realizadas no programa

@author		Victor Bitencourt
@since		17/09/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION "PesqBrw" 		  OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CRMA030" OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CRMA030" OPERATION 8 ACCESS 0  //"Imprimir"
ADD OPTION aRotina TITLE STR0009 ACTION "CRMA200()"		  OPERATION 8 ACCESS 0	// "Privilégios"

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA30NEnt

Retorna o nome da entidade.

@sample	CRMA30NEnt()

@param		ExpC1 - Entidade
			ExpC2 - Codigo da Conta
			ExpC3 - Loja da Conta

@return	ExpC - Nome da Entidade

@author	Anderson Silva
@since		19/09/2013
@version	11.80                
/*/
//------------------------------------------------------------------------------
Function CRMA30NEnt(cEntidade,cCodCta,cLojCta) 

Local cNomeEntid  := ""

Default cEntidade := ""
Default cCodCta	  := ""
Default cLojCta   := ""  

If cEntidade == "ACH"
	cNomeEntid := Posicione("ACH",1,xFilial("ACH")+cCodCta+cLojCta,"ACH_RAZAO")
ElseIf cEntidade == "SUS"                                       
	cNomeEntid := Posicione("SUS",1,xFilial("SUS")+cCodCta+cLojCta,"US_NOME")
Else                                                                            
	cNomeEntid := Posicione("SA1",1,xFilial("SA1")+cCodCta+cLojCta,"A1_NOME")
EndIf

cNomeEntid := Alltrim(cNomeEntid)

Return( cNomeEntid )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM30MdlPVal

Pos-Validadao do Model(MPFormModel) de Log de Transferencia de Contas.  

@sample	CRM30MdlPVal(oModel)

@param		ExpO1 - Model da de Log de Transferencia de Contas (MPFormModel).
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		28/11/2014  
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function CRM30MdlPVal(oModel)
Local lRetorno		:= .T.
Local bInTTS		:= {|oModel| CRMA30InTTS(oModel)}
lRetorno 			:= FWFormcommit(oModel,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/,bInTTS)
Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA30InTTS

Bloco de transacao durante o commit do model. 

@sample	CRMA30InTTS(oModel,cId,cAlias)

@param		ExpO1 - Modelo de dados
	
@return	ExpL  - Verdadeiro / Falso

@author	Anderson Silva
@since		06/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRMA30InTTS(oModel)

Local oMdlAIN		:= oModel:GetModel("AINMASTER")
Local nOperation	:= oModel:GetOperation()
Local cChave    	:= ""		
Local aAutoAO4  	:= {}
Local aAutoAO4Aux	:= {}
Local aVendedores	:= {}
Local nX			:= 0
Local lRetorno 		:= .T.
Local cCodUsr		:= ""
Local cUserGrv		:= ""
Local cFilAZS		:= xFilial("AZS")
Local cFilAO3		:= xFilial("AO3") 
Local lCRMAZS		:= SuperGetMv("MV_CRMUAZS",, .F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona ou Remove o privilegios deste registro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE ) 
	 	
	cCodUsr		:= IIF(lCRMAZS, CRMXCodUser(), RetCodUsr()) 
	cChave		:= PadR(xFilial("AIN")+oMdlAIN:GetValue("AIN_CODIGO"),TAMSX3("AO4_CHVREG")[1])
	aAutoAO4	:= CRMA200PAut(nOperation,"AIN",cChave,cCodUsr,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permissoes do registro que será atribuido para usuario.	³
	//³ aPermissoes[1] => Controle Total						³
	//³ aPermissoes[2] => Visualizar							³
	//³ aPermissoes[3] => Alterar								³
	//³ aPermissoes[4] => Excluir								³
	//³ aPermissoes[5] => Compartilhar 							³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aVendedores,{oMdlAIN:GetValue("AIN_VENATU"),{.T.,.F.,.F.,.F.,.F.}})
	aAdd(aVendedores,{oMdlAIN:GetValue("AIN_VENANT"),{.F.,.T.,.F.,.F.,.F.}})
	
	If lCRMAZS
		AZS->( DBSetOrder( 4 ) ) 
	Else
		DbSelectArea("AO3")
		AO3->(DbSetOrder(2))			// AO3_FILIAL+AO3_VEND
	EndIf
	
	For nX := 1 To Len(aVendedores)
		cUserGrv := ""
		If lCRMAZS 
			If AZS->( MSSeek(cFilAZS + aVendedores[nX][1] ) ) .And. ! ( AZS->AZS_CODUSR == cCodUsr )
				cUserGrv := AZS->AZS_CODUSR
			EndIf
		ElseIf AO3->(DbSeek(cFilAO3 + aVendedores[nX][1])) .And. !(AO3->AO3_CODUSR == cCodUsr)
			cUserGrv := AO3->AO3_CODUSR
		EndIf
		If ! Empty(cUserGrv)
			aAutoAO4Aux := CRMA200PAut(nOperation,"AD1",cChave,cUserGrv,aVendedores[nX][2],/*aNvlEstrut*/,cCodUsr,/*dDataVld*/)
			aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
		EndIf
	Next nX
	
	If Len(aAutoAO4) > 0 
		lRetorno	:= CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
	EndIf
	
EndIf 

Return(lRetorno)