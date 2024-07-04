#INCLUDE "JURA190.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA190
Conferencia do extratos de correspondentes

@author Rafael Tenorio da Costa
@since 24/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA190()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0005 )	//"Conferência do Extratos de Correspondentes"
oBrowse:SetAlias( "NZF" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZF" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Rafael Tenorio da Costa
@since 27/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        	, 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA190"	, 0, 2, 0, NIL } ) //"Visualizar"

If IsInCallStack("J190RotAut")
	aAdd( aRotina, { STR0009, "VIEWDEF.JURA190"	, 0, 3, 0, NIL } ) //"Incluir"
EndIf

aAdd( aRotina, { STR0003, "Ja190Alt()"	, 0, 4, 0, NIL } ) //"Alterar"

If IsInCallStack("J190RotAut")
	aAdd( aRotina, { STR0012, "VIEWDEF.JURA190"	, 0, 5, 0, NIL } ) //"Excluir"
EndIf

aAdd( aRotina, { STR0004, "VIEWDEF.JURA190"	, 0, 8, 0, NIL } ) //"Imprimir"
aAdd( aRotina, { STR0021, "J190VisDoc()"	, 0, 2, 0, NIL } ) //"Visualiza Docs"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Extratos de Correspondentes x Atos

@author Rafael Tenorio da Costa
@since 27/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  		:= FWLoadModel( "JURA190" )
Local oStructNZF	:= FWFormStruct( 2, "NZF" )
Local oStructNZG	:= FWFormStruct( 2, "NZG" )

oStructNZF:RemoveField("NZF_OK")

oStructNZG:RemoveField("NZG_COD")
oStructNZG:RemoveField("NZG_CCORRE")
oStructNZG:RemoveField("NZG_LCORRE")
oStructNZG:RemoveField("NZG_CESCRI")
oStructNZG:RemoveField("NZG_CAREA")
oStructNZG:RemoveField("NZG_CCLIEN")
oStructNZG:RemoveField("NZG_LCLIEN")
oStructNZG:RemoveField("NZG_RECNT4")
oStructNZG:RemoveField("NZG_GERSIS")

//Titulo a pagar
If NZF->NZF_TIPPAG == "1"
	oStructNZG:RemoveField("NZG_PRODUT")
EndIf	

JurSetAgrp( "NZF",, oStructNZF )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA190_VIEW", oStructNZF, "NZFMASTER"  )
oView:AddGrid( 	"JURA190_GRID", oStructNZG, "NZGDETAIL"  )

oView:AddIncrementField( "JURA190_GRID", "NZG_ITEM" )

oView:CreateHorizontalBox( "SUPERIOR", 40 )
oView:CreateHorizontalBox( "INFERIOR", 60 )

oView:SetOwnerView( "JURA190_VIEW"	, "SUPERIOR" )
oView:SetOwnerView( "JURA190_GRID"	, "INFERIOR" )

oView:SetDescription( STR0005 )		//"Conferência do Extratos de Correspondentes"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Extratos de Correspondentes x Atos

@author Rafael Tenorio da Costa
@since 28/04/2015
@version 1.0

@obs NZFMASTER - Dados do Extratos de Correspondentes x Atos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel		:= NIL
Local oStructNZF	:= FWFormStruct( 1, "NZF" )
Local oStructNZG 	:= FWFormStruct( 1, "NZG" )

oStructNZF:RemoveField("NZF_OK")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA190", /*Pre-Validacao*/, { | oX | J190PosVal( oX ) }/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

oModel:AddFields(	"NZFMASTER", NIL		, oStructNZF, /*Pre-Validacao*/	, /*Pos-Validacao*/ )
oModel:AddGrid( 	"NZGDETAIL", "NZFMASTER", oStructNZG, { |oX, oY, Oz| J190PreLin(oX, oY, Oz) }/*bLinePre*/, { |oX| J190PosLin(oX) } /*bLinePost*/, /*bPre*/, /*bPost*/ )

oModel:SetRelation( "NZGDETAIL", { 	{ "NZG_FILIAL", "NZF_FILIAL" } , { "NZG_COD"	, "NZF_COD" } 		, { "NZG_CCORRE", "NZF_CCORRE"	} ,;
									{ "NZG_LCORRE", "NZF_LCORRE" } , { "NZG_CESCRI"	, "NZF_CESCRI" }	, { "NZG_CAREA"	, "NZF_CAREA" 	} ,;
									{ "NZG_CCLIEN", "NZF_CCLIEN" } , { "NZG_LCLIEN"	, "NZF_LCLIEN" }	} , NZG->( IndexKey(1) ) )

oModel:SetDescription( STR0006 ) 							//"Modelo de Dados da Conferência do Extratos de Correspondentes"
oModel:GetModel( "NZFMASTER" ):SetDescription( STR0007 )	//"Dados da Conferência de Extratos de Correspondentes"
oModel:GetModel( "NZGDETAIL" ):SetDescription( STR0008 )	//"Grid da Conferência de Extratos de Correspondentes"

oModel:GetModel( "NZGDETAIL" ):SetUniqueLine( { "NZG_ITEM" } )

JurSetRules( oModel, "NZFMASTER",, "NZF" )
JurSetRules( oModel, "NZGDETAIL",, "NZG" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J190PosVal
Efetua as pos-valições do model 

@return	oModel
@author Rafael Tenorio da Costa
@since 22/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190PosVal( oModel )
	
	Local lRetorno	:= .T.
	Local nOpc		:= oModel:GetOperation()
	Local oModelNZG	:= oModel:GetModel("NZGDETAIL")
	Local nCont		:= 0
	Local nLinhaAtu	:= oModelNZG:nLine
	
	If nOpc == 4
	
		//Atualiza valor total
		oModel:SetValue( "NZFMASTER", "NZF_TOTAL", SomaTotal(oModel) )

		//Atualiza flag no andamento para definir se foi processado pelo extrato ou nao		
		If lRetorno
		
			For nCont:=1 To oModelNZG:GetQtdLine()
				oModelNZG:GoLine( nCont )
				
				//Define que o item nao foi gerado pelo sistema
				If oModelNZG:GetValue("NZG_GERSIS") == "2"
				
					NT4->( DbGoto( oModelNZG:GetValue("NZG_RECNT4") ) )
					If !NT4->( Eof() )

						//Atualiza flag de processado					
						RecLock("NT4", .F.)
							If oModelNZG:IsDeleted()
								NT4->NT4_PROEXT := "2"	//Nao
							Else
								NT4->NT4_PROEXT := "1"	//Sim
							EndIf
						NT4->( MsUnLock() )
						
					EndIf	
				EndIf	
			Next nCont
			oModelNZG:GoLine( nLinhaAtu )
		EndIf
		
	EndIf	

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J190CmpGri
Efetua as pos-valições do model 

@return	oModel
@author Rafael Tenorio da Costa
@since 22/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190CmpGri( cCampo, xConteudo )

	Local lRetorno 	:= .T.
	Local aArea		:= GetArea()
	Local aAreaNUQ	:= NUQ->( GetArea() )
	Local aAreaNT4	:= NT4->( GetArea() )
	Local oModel   	:= FWModelActive()
	Local nTotal	:= oModel:GetValue( "NZFMASTER", "NZF_TOTAL" )
	Local cGerSis	:= oModel:GetValue( "NZGDETAIL", "NZG_GERSIS" )
	Local cStatus	:= oModel:GetValue( "NZGDETAIL", "NZG_STATUS" )
	Local nVlrPaga	:= oModel:GetValue( "NZGDETAIL", "NZG_VLPAGA" )
	Local nOpc		:= oModel:GetOperation()
	Local oModelNZG	:= oModel:GetModel("NZGDETAIL")
	Local nLinAtu	:= oModelNZG:nLine
	Local nCont		:= 0

	If nOpc == 3 .AND. cCampo == "NZG_NUMPRO"

		NSZ->( DbSetOrder(6) )	// NSZ_FILIAL+NSZ_NUMPRO
		If !NSZ->( DbSeek(xFilial("NSZ") + xConteudo ) )
			JurMsgErro( STR0023 )  //"Número do processo, não encontrato para esse código de assunto juridico."
			lRetorno := .F.
		EndIf

	ElseIf nOpc == 4 
	
		If cCampo $ "NZG_NUMPRO|NZG_CAJURI|NZG_CANDAM|NZG_CTPSER|NZG_CRESPO|NZG_CATO"
		
			If oModel:IsFieldUpdated("NZGDETAIL", cCampo) .And. cGerSis == "1" 
				JurMsgErro( STR0013 )	//"Campo não pode ser editado, porque foi incluído pelo sistema."
				lRetorno := .F.		
			EndIf
		EndIf
		
		If lRetorno .And. cCampo == "NZG_VLPAGA"
		
			//Atualiza campo de informacao para Valor Editado
			oModel:SetValue( "NZGDETAIL", "NZG_INFO", "4")
		
			//Atualiza valor total
			oModel:SetValue( "NZFMASTER", "NZF_TOTAL", SomaTotal(oModel) )
		EndIf
		
		If lRetorno .And. cCampo == "NZG_STATUS"
		
			//Status Aprovado | Encerrado
			If cStatus $ "2|4" .And. !(nVlrPaga > 0)
				JurMsgErro( STR0020 )	//"Status não pode ser atualizado, porque Valor a Pagar não foi preenchido."
				lRetorno := .F.		
			EndIf
			
			//Status Agrupado
			If lRetorno .And. cStatus == "5"
				JurMsgErro( STR0026 )	//"Status inválido para inclusão manual."
				lRetorno := .F.		
			EndIf
			
			//Status Não Aprovado			
			If lRetorno .And. cStatus == "3"
			
				//Atualiza campo de Valor a Pagar sem executar o gatilho
				oModel:LoadValue( "NZGDETAIL", "NZG_VLPAGA", 0)
			
				//Atualiza valor total
				oModel:SetValue( "NZFMASTER", "NZF_TOTAL", SomaTotal(oModel) )
			EndIf
		EndIf
		
		If lRetorno .And. cCampo == "NZG_CAJURI"

			NUQ->( DbSetOrder(3) )	//NUQ_FILIAL+NUQ_NUMPRO+NUQ_CAJURI+NUQ_INSATU
			If !NUQ->( DbSeek(xFilial("NUQ") + FwFldGet("NZG_NUMPRO") + xConteudo + "1") )		
				JurMsgErro( STR0023 )	//"Número do processo, não encontrato para esse código de assunto juridico."
				lRetorno := .F.		
			EndIf
		EndIf
		
		If lRetorno .And. cCampo == "NZG_CANDAM"

			NT4->( DbSetOrder(1) )	//NT4_FILIAL+NT4_COD
			If !NT4->( DbSeek(xFilial("NT4") + xConteudo) )		
				lRetorno := .F.
			Else
				
				//Valida se eh um andamento apto a ser utilizado no extrato
				If NT4->NT4_CAJURI <> FwFldGet("NZG_CAJURI") .Or. Empty(NT4->NT4_CATO) .Or. Empty(NT4->NT4_CFWLP) .Or.;
				   NT4->NT4_DTANDA < FwFldGet("NZF_DTINI")   .Or. NT4->NT4_DTANDA > FwFldGet("NZF_DTFIM") 		  .Or.;
				   !(NT4->NT4_AUTPGO $ "1|2") .Or. NT4->NT4_PROEXT <> "2"
				   
					JurMsgErro( STR0024 )	//"Andamento inválido"
					lRetorno := .F.									
				EndIf
			
				//Valida se o andamento ja esta na tela	
				If lRetorno 		
					For nCont:=1 To oModelNZG:GetQtdLine()
						oModelNZG:GoLine( nCont )
					
						If !oModelNZG:IsDeleted() .And. nLinAtu <> nCont .And. oModelNZG:GetValue("NZG_CANDAM") == xConteudo  
							JurMsgErro( STR0025 )	//"Andamento já utilizado"
							lRetorno := .F.
							Exit									
						EndIf
					Next nCont
					oModelNZG:GoLine( nLinAtu )
				EndIf
			EndIf	
		EndIf
	
	EndIf
	
	RestArea( aAreaNT4 )
	RestArea( aAreaNUQ )
	RestArea( aArea )
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J190RotAut
Rotina automatica para incluir extratos

@return	oModel
@author Rafael Tenorio da Costa
@since 04/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190RotAut( aCab, aItens, nOpc )

	Local aArea		:= GetArea()
	Local lRetorno	:= .T.

	Private aRotina 	:= MenuDef()	
	Private lMsErroAuto := .F.
	
	If Len( aCab ) > 0 
	 
		FWMVCRotAuto( ModelDef(), "NZF", nOpc, { {"NZFMASTER", aCab}, {"NZGDETAIL", aItens} } )
	Else
			
		lMsErroAuto := .T.			
		ApMsgInfo( STR0010 )	//"Não existe registro a ser processado."			
	EndIf
	
	If lMsErroAuto .And. nOpc <> 5 
		lRetorno := .F.
		JurMsgErro( STR0011 + STR0005 )	//"Erro na rotina automática " "Extratos de Correspondentes x Atos"
	EndIf
	
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J190DtRet
Inicializador padrao do campo NZF_DTRET 

@return	dRetorno - Data de Retorno
@author Rafael Tenorio da Costa
@since 14/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190DtRet()

	Local aArea		:= GetArea()
	Local nDias		:= JurGetDados("NZI", 1, xFilial("NZI") + FwFldGet("NZF_CCORRE") + FwFldGet("NZF_LCORRE"), "NZI_QTDRET")	//NZI_FILIAL + NZI_CCORRE + NZI_LCORRE
	Local dRetorno 	:= Date() + nDias 	
	
	RestArea( aArea )
	
Return dRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} J190PosLin
Valida linha do grid NZG

@param 	oModeNZG	- Model da NZG
@return lRetorno	- .T./.F. 
@author Rafael Tenorio da Costa
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J190PosLin( oModeNZG )
	
	Local lRetorno 	:= .T.
	Local oModel   	:= FWModelActive()
	Local cTipPag	:= oModel:GetValue("NZFMASTER", "NZF_TIPPAG")
	Local cProduto	:= oModeNZG:GetValue("NZG_PRODUT")
	Local nOpc		:= oModel:GetOperation()

	If nOpc == 4

		//Valida preenchimento do campo produto quando for efetuar pagamento por compras
		If cTipPag == "2" .And. Empty( cProduto )
			JurMsgErro(STR0014 + RetTitle("NZG_PRODUT") + STR0015)	//"Os campos " " são obrigatórios."
			lRetorno := .F.
		EndIf
	EndIf	
	
Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} J190PreLin
Valida a pre-edição da linha do grid NZG

@param 	oModeNZG	- Model da NZG
@param 	nLine		- Numero da linha posicionada
@param 	cOpc		- Definição da alteração
@return lRetorno	- .T./.F. 
@author Rafael Tenorio da Costa
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J190PreLin( oModelNZG, nLine, cOpc )

	Local lRetorno	:= .T.
	Local cStatus	:= oModelNZG:GetValue("NZG_STATUS")
	Local cGerSis	:= oModelNZG:GetValue("NZG_GERSIS")
	
	Do Case
	
		Case cOpc == "DELETE"
	
			//Nao pode deletar a linha se for diferente de pendente
			If !oModelNZG:IsDeleted() .And. ( cStatus <> "1" .Or. cGerSis == "1" )  
				JurMsgErro(STR0019)		//"A linha não pode ser deletada, por causa do status ou porque foi gerada pelo sistema."
				lRetorno := .F.	
			EndIf

	End Case
		
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J190ValCmp
Valida campos da tabela NZF 

@return	lRetorno - .T./.F.
@author Rafael Tenorio da Costa
@since 19/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190ValCmp(cCampo, xConteudo)

	Local lRetorno := .T.
	
	Do Case
	
		Case cCampo == "NZF_STATUS"
		
			If FwFldGet("NZF_REVISA") == "1"
				JurMsgErro(STR0016)	//"Os itens devem ser revisados antes de Aprovar o Extrato." 
				lRetorno := .F.
			EndIf
		
		Case cCampo == "NZF_REVISA"
		
			//Verifica se existem itens com o status pendente antes de atualizar o campo revisa para 2=Nao
			If FwFldGet("NZF_REVISA") == "2" .And. ProcStItem( "1" )
				JurMsgErro(STR0017)	//"Ainda existe itens com Status Pendente, verifique."
				lRetorno := .F.
			EndIf
		
	End Case	

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcStItem
Verifica se existe algum item com o status definido no parametro.  

@param	cStatus		- Status que sera procurado no grid
@return	lRetorno 	- Define se encontrou o status no grid - .T./.F.
@author Rafael Tenorio da Costa
@since 19/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcStItem( cStatus )

	Local oModel	:= FWModelActive()
	Local oModelNZG	:= oModel:GetModel("NZGDETAIL")
	Local lRetorno 	:= .F.
	Local nCont		:= 0
	
	For nCont:=1 To oModelNZG:GetQtdLine()
	
		oModelNZG:GoLine( nCont )
	
		If !oModelNZG:IsDeleted()
			
			If oModelNZG:GetValue("NZG_STATUS") == cStatus
				lRetorno := .T.
				Exit
			EndIf
		EndIf
	Next nCont
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaTotal
Soma todas as linhas do array.  

@param	oModel	
@return	nTotal	- Valor total do extrato
@author Rafael Tenorio da Costa
@since 19/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SomaTotal( oModel )

	Local oModelNZG	:= oModel:GetModel("NZGDETAIL")
	Local nCont		:= 0
	Local nTotal	:= 0
	Local nLinhaAtu	:= oModelNZG:nLine
	
	For nCont:=1 To oModelNZG:GetQtdLine()
	
		oModelNZG:GoLine( nCont )
	
		//Soma os registros que estao com status diferente de 3=Nao Aprovado
		If !oModelNZG:IsDeleted() .And. oModelNZG:GetValue("NZG_STATUS") <> "3"
			nTotal += oModelNZG:GetValue("NZG_VLPAGA")
		EndIf
	Next nCont
	
	oModelNZG:GoLine( nLinhaAtu )
	
Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} J190VisDoc
Efetua a apresentacao do titulo ou pedido de compras que foi gerado para pagar o correspondente 

@author Rafael Tenorio da Costa
@since 19/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190VisDoc()

	Local aArea		:= GetArea()
	Local cNumero	:= NZF->NZF_NUMPAG
	Local cPrefixo	:= SuperGetMV( 'MV_JPREEXT',, 'NZF' )
	Local cParcela	:= StrZero( 1, TamSx3("E2_PARCELA")[1] )
	Local cTipo		:= JurGetDados("NZI", 1, xFilial("NZI") + NZF->NZF_CCORRE + NZF->NZF_LCORRE, "NZI_TIPOTI")	//NZI_FILIAL + NZI_CCORRE + NZI_LCORRE
	
	If Empty( cNumero )
	
		JurMsgErro(STR0022)	//"Não existe Documento para ser visualizado."
	Else
	
		//Titulo a Pagar
		If NZF->NZF_TIPPAG == "1"

			cNumero	:= PadR(NZF->NZF_NUMPAG, TamSx3("E2_NUM")[1])
			 
			J190TitSE2(cPrefixo, cNumero, cTipo, NZF->NZF_CCORRE, NZF->NZF_LCORRE)
		
		//Pedido de Compra
		Else
		
			cNumero	:= PadR(NZF->NZF_NUMPAG, TamSx3("C7_NUM")[1])
		
			DbSelectArea("SC7")
			SC7->( DbSetOrder(1) )		//C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
			If SC7->( DbSeek(xFilial("SC7") + cNumero) )
			
				Mata120(/*nFuncao*/,/*xAutoCab*/,/*xAutoItens*/, 2)
			EndIf
		EndIf
		
	EndIf	
	
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J190ProWhe
Modo de edicao do campo NZG_PRODUT
Utilizado no X3_WHEN 

@author Rafael Tenorio da Costa
@since 20/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190ProWhe()

	Local lRetorno 	:= .T.
	Local oModel   	:= FWModelActive()
	Local nOpc		:= oModel:GetOperation()
	
	//Tipo de pagamento titulo a pagar
	If M->NZF_TIPPAG == "1"
	
		lRetorno := .F.

		//Verifica se eh rotina automatica para deixar atribuir valor
		If nOpc == 3
			lRetorno := .T.
		EndIf
	EndIf		

Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} Ja190NUQFil
Filtro da consulta padrão do numero do processo NUQNZG, utilizando instancias atuais
que tenham o correspondentes do extrato.

@return cFiltro - Retorna o filtro
@author Rafael Tenorio da Costa
@since 15/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja190NUQFil()

	Local aArea		:= GetArea()
	Local cFiltro	:= "@#"
	Local oModel    := FWModelActive()
	Local cCodCorres:= oModel:GetValue("NZFMASTER", "NZF_CCORRE")
	Local cLojCorres:= oModel:GetValue("NZFMASTER", "NZF_LCORRE")
	Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)				//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
	Local aCodsAssun:= {}
	Local cCodsAssun:= ""
	Local nCont		:= 0
		
	cFiltro += "NUQ->NUQ_INSATU == '1' .And. "
	cFiltro += "!Empty(NUQ->NUQ_NUMPRO) "
	
	//Fluxo de correspondente por Assunto Jurídico
	If nFlxCorres == 2
	
		cFiltro += " .And. NUQ->NUQ_CCORRE == '" +cCodCorres+ "' "
		cFiltro += " .And. NUQ->NUQ_LCORRE == '" +cLojCorres+ "' "
		
	//Fluxo de correspondente por Follow-up		
	Else
	
		//Busca os codigo de assunto juridicos que tem follow-up aceito pelo correspondente
		aCodsAssun := Ja106NszCor(cCodCorres, cLojCorres, "NTA_ACEITO = '1'")

		//Carrega os codigos de assunto juridicos		
		If Len(aCodsAssun) > 0
			For nCont:=1 To Len(aCodsAssun)
				cCodsAssun += aCodsAssun[nCont] + "|"  
			Next nCont
		EndIf
		
		//Filtra os codigos de assunto juridicos
		//Caso nao encontre, filtra do mesmo jeito, porque quer dizer que ainda nao foi gerado follow-up para o correspondente 
		cFiltro += " .And. NUQ->NUQ_CAJURI $ '" +cCodsAssun+ "' "
	EndIf	
	
	cFiltro += "@#"
	RestArea( aArea )

Return cFiltro

//------------------------------------------------------------------
/*/{Protheus.doc} Ja190NT4Fil
Filtro da consulta padrão do andamento NT4NZG, utilizando andamentos aptos,
a entrarem no extrato do correspondente.  

@return cFiltro - Retorna o filtro
@author Rafael Tenorio da Costa
@since 15/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja190NT4Fil()

	Local aArea			:= GetArea()
	Local cFiltro		:= "@#"
	Local oModel    	:= FWModelActive()
	Local oModelNZG		:= oModel:GetModel("NZGDETAIL")
	Local cCajuri		:= oModelNZG:GetValue("NZG_CAJURI")	
	Local cDtExtIni		:= DtoS( oModel:GetValue("NZFMASTER", "NZF_DTINI") )
	Local cDtExtFim		:= DtoS( oModel:GetValue("NZFMASTER", "NZF_DTFIM") )
	Local nCont			:= 0
	Local cAndamentos	:= ""
	Local nLinAtu		:= oModelNZG:nLine
		
	cFiltro += "NT4->NT4_CAJURI == '"+cCajuri+"' .And. "
	cFiltro += "NT4->NT4_DTANDA >= '" +cDtExtIni+ "' .And. NT4->NT4_DTANDA <= '" +cDtExtFim+ "' .And. "
	cFiltro += "!Empty(NT4->NT4_CATO) .And. "  
	cFiltro += "!Empty(NT4->NT4_CFWLP) .And. "
	cFiltro += "NT4->NT4_AUTPGO $ '1|2' .And. "
	cFiltro += "NT4->NT4_PROEXT == '2' "

	//Carrega os andamentos que ja estão na tela
	For nCont:=1 To oModelNZG:GetQtdLine()
		oModelNZG:GoLine( nCont )
	
		If !oModelNZG:IsDeleted()
			cAndamentos += oModelNZG:GetValue("NZG_CANDAM") + "|"			
		EndIf
	Next nCont
	oModelNZG:GoLine( nLinAtu )
	
	//Traz apenas os andamentos que não estão grid
	If !Empty(cAndamentos)
		cFiltro += ".And. !(NT4->NT4_COD $ '" +cAndamentos+ "') " 
	EndIf
	
	cFiltro += "@#"
	RestArea( aArea )

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja190Alt

Função que verifica o status do extrato antes da alteracao.

@author Rafael Tenorio da Costa
@since 12/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja190Alt()

	Local aArea := GetArea()

	//Encerrado
	If NZF->NZF_STATUS == "4" 
		JurMsgErro(STR0027)		//"Extrato não pode ser alterado, porque já foi encerrado."	
	Else
		FWExecView( STR0003, "JURA190", 4, , {|| .T.} )		 //"Alterar"
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J190StaWhe
Modo de edicao do campo NZG_STATUS
Utilizado no X3_WHEN 

@author Rafael Tenorio da Costa
@since 12/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190StaWhe()

	Local lRetorno 	:= .T.
	Local oModel   	:= FWModelActive()
	Local nOpc		:= oModel:GetOperation()
	
	//Verifica se eh status agrupado, esse status so pode ser incluido pela rotina automatica
	If FwFldGet("NZG_STATUS") == "5"
	
		lRetorno := .F.

		//Verifica se eh rotina automatica para deixar atribuir valor
		If nOpc == 3
			lRetorno := .T.
		EndIf
	EndIf		

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J190TitSE2()
Exibe os titulos a pagar gerados pelo extrato. 

@author Rafael tenorio da costa
@since 27/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J190TitSE2(cPrefixo, cNum, cTipo, cCodFor, cLojFor, cFilTit)

	Local aArea     := GetArea()
	Local aAreaSE2  := SE2->( GetArea() )
	Local aLegendas := {{ 'E2_SALDO == 0'       , 'RED'   },; //"Titulo Baixado"
	                    { 'E2_SALDO <> E2_VALOR', 'BLUE'  },; //"Baixado Parcialmente"
	                    { 'E2_SALDO == E2_VALOR', 'GREEN' } } //"Titulo em Aberto"
	Local cFiltro   := ""
	
	Default cFilTit := xFilial("SE2")

	Private cCadastro := STR0028	//"Título Contas a Pagar"
	Private aRotina   := {{STR0001, "AxPesqui"                      , 0, 1} ,; //"Pesquisar"
	                      {STR0032, "AxVisual"                      , 0, 2} ,; //"Visualizar"
	                      {STR0033, "J027LegPag('" + STR0028 + "')" , 0, 7} }  //"Legenda" //"Título Contas a Pagar"
	
	cFiltro := " E2_FILIAL = '"  + cFilTit + "' "
	cFiltro += " AND E2_PREFIXO = '" + cPrefixo + "' "
	cFiltro += " AND E2_NUM IN ('"  + cNum 	+ "') "
	cFiltro += " AND E2_TIPO = '"  + cTipo 	+ "' "
	cFiltro += " AND E2_FORNECE= '" + cCodFor + "' "
	cFiltro += " AND E2_LOJA = '"  + cLojFor + "' "

	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	mBrowse( 0, 0, 0, 0, "SE2",,,,,, aLegendas,,,,,,,, cFiltro)

	RestArea( aAreaSE2 )
	RestArea( aArea )

Return Nil
