#INCLUDE "CRMA020B.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"

#DEFINE BRW_PESQ_INT  			1
#DEFINE BRW_SOL_CONTAS			2
#DEFINE BRW_DCS_CONTAS 			3
#DEFINE BRW_CONTAS_LIB_N_LIB	4            
 
#DEFINE TYPE_FORM_SOL_CONTAS	1   
#DEFINE TYPE_FORM_DCS_CONTAS	2       

Static lMVCRMUAZS  := Nil  

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA020B

Chamada para rotina de solicitacao / liberacao de contas.

@sample	CRMA020B() 

@param		Nenhum

@return	Nenhum

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA020B()

Local aArea		:= GetArea()
Local aAreaAO3	:= AO3->(GetArea()) 
Local aAreaSA3	:= SA3->(GetArea())
Local cCodUser	:= ""
Local cCodVend	:= ""
Local cIDEstN		:= ""
Local aUserPaper	:= {}
Local aNvlStruct	:= {}
Local nNVEstN		:= 0 

If lMVCRMUAZS == Nil  
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

IF lMVCRMUAZS
	cCodUser := CRMXCodUser()
Else
	cCodUser := RetCodUsr()
EndIf

If lMVCRMUAZS
	
	//Retorna codigo inteligente e o nivel da estrutura de negocio de acordo com
	//papel do usuario logado no sistema.
	aUserPaper	:= CRMXGetPaper()
	
	If !Empty( aUserPaper )  
		cCodUser	:= aUserPaper[USER_PAPER_CODUSR] 
		AO3->( DbSetOrder(1) ) //AO3_FILIAL+AO3_CODUSR
		//Deixa o cadastro do usuario posicionado.
		If AO3->( DbSeek( xFilial("AO3") + cCodUser ) )
			cCodVend	:= aUserPaper[USER_PAPER_CODVEND]
			cIdEstN 	:= aUserPaper[USER_PAPER_IDESTN]
			nNvEstN 	:= aUserPaper[USER_PAPER_NVESTN]	
		EndIf 
	EndIf
	
Else
	SA3->(DbSetOrder(7)) //A3_FILIAL+A3_CODUSR
	
	If SA3->( DbSeek(xFilial("SA3")+cCodUser) )
		cCodVend	:= SA3->A3_COD
	
		If nModulo == 73 
			DbSelectArea("AO3")
			DbSetOrder(1)		// AO3_FILIAL+AO3_CODUSR
			If AO3->(DbSeek(xFilial("AO3")+cCodUser))
				cIDEstN := AO3->AO3_IDESTN
				nNvEstN	:= AO3->AO3_NVESTN
			EndIf	
		Else	
			cIDEstN := SA3->A3_NVLSTR
			nNVEstN := SA3->A3_NIVEL 
		EndIf

	EndIf  

	SA3->(DbSetOrder(1)) //A3_FILIAL+A3_COD  
EndIf

If !Empty( cCodVend )
	If !Empty( cIdEstN )
		aNvlStruct := CRMXFmtNvl(cIDEstN)
		FwMsgRun(,{|| CRM020BSLC(cCodVend, cIDEstN, nNVEstN, aNvlStruct ) },Nil,STR0072)
	Else
		ApMsgAlert(STR0002,STR0001)//"Atenção"//"Este vendedor nao pertence uma estrutura de vendas!"//"OK"
	EndIf
Else
	ApMsgAlert(STR0005,STR0004)//"Atenção"//"Este usuário nao esta associado a nenhum vendedor!"//"OK"
EndIf 

RestArea(aAreaSA3)
RestArea(aAreaAO3)
RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BSLC
Rotina que controla a solicitação e liberacao de contas conforme o acesso do
vendedor na estrutura de vendas.

@param cCodVend, caracter, Codigo do Vendedor. 
@param cIDEstN, caracter, ID inteligente do vendedor na estrutura de vendas.
@param nNVEstN, numérico, Nivel que vendedor que esta na estrutura de negocio.
@param aNvlStruct, array, Lista contendo os ID inteligente de todos os itens que o usuário tem acesso no nível.

@author		Anderson Silva
@version	11.90
@since		25/09/2013
/*/
//------------------------------------------------------------------------------
Static Function CRM020BSLC(cCodVend, cIDEstN, nNVEstN, aNvlStruct )

Local oDlg				:= Nil
Local oPnlModal		:= Nil
Local oTFolder		:= Nil
Local aTFolder 		:= {}
Local oFwlSol			:= Nil
Local oFWLLnl       	:= Nil
Local oDlgPesq		:= Nil
Local oPnlBrwPesq		:= Nil
Local oPnlDcs      	:= Nil
Local oPnlCtaLnl		:= Nil 
Local aEntidades		:= {}
Local cFilSol			:= ""
Local cFilLib			:= ""
Local cPesq			:= Space(150)
Local oMsGPesq 		:= Nil
Local oBtnPesq 		:= Nil
Local oChkACH			:= Nil
Local oChkSUS			:= Nil  
Local oChkSA1			:= Nil
Local lACH 			:= .T.
Local lSUS 			:= .T.
Local lSA1 			:= .T.
Local oBrwPesq		:= Nil   
Local oBrwSol			:= Nil
Local oBrwDcs			:= Nil
Local oBrwCtaLnl		:= Nil
Local cAliasPesq 		:= ""
Local cAliasSol 		:= ""
Local cAliasDcs 		:= ""
Local cAliasCtaL 		:= ""
Local cQryPesq  		:= ""
Local cQrySol			:= ""
Local cQryDcs			:= ""
Local cQryLibCta 		:= ""
Local cQryCtaLnl 		:= ""
Local aColPesq		:= {}
Local aColSol			:= {}
Local aColDcs  		:= {}
Local aColCtaLnl   	:= {}
Local aBotaoBrw		:= {}
Local bExcSolCta		:= {|| }
Local bExcLibCta 		:= {|| } 
Local cCargoSup 		:= SuperGetMV("MV_CRMCARS",.F.,"")
Local lHideSol		:= .F.
Local lHideLib		:= .F.
local lRet				:= .T.
Local nX				:= 0
Local bSetOption		:= {|| }
Local oFolderLib		:= Nil

//Esconde a pasta Solicitacoes de Contas para o vendedor que esta no topo da estrutura de venda.
If ( nNVEstN == 1 )
	lHideSol := .T.	
EndIf  

//Esconde a pasta Liberacoes de Contas para o vendedor que não possui um cargo superior informado no parametro.
If lMVCRMUAZS .And. !Empty( cCargoSup )
	If CRMXRtrnPos( AO3->AO3_CODUSR ) <> AllTrim( cCargoSup )
		lHideLib := .T.
	EndIf
EndIf

If ! ( !lHideSol .Or. !lHideLib )
	If lHideLib
		ApMsgAlert(STR0074) //"Seu cargo atual não permite realizar liberação de contas."
	EndIf
	lRet := .F.
EndIf

If lRet 

	//---------------------------a
	//Cria Dialog do Tipo Modal
	//---------------------------
	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.F.)
	oDlg:SetTitle(STR0011)
	oDlg:SetEscClose(.T.)
	oDlg:EnableAllClient()
	oDlg:EnableFormBar(.F.) 
	oDlg:CreateDialog() 
	
	//-------------------------------------------------------------------------
	//Pega o painel principal da janela.
	//Esse painel é o painel onde devem ser colocados os componentes que
	//se deseja mostrar na janela.
	//-------------------------------------------------------------------------
	oPnlModal := oDlg:GetPanelMain()
	
	bExcSolCta		:= {|| CRM020BQry(oBrwSol,cQrySol) }//"Atualizado as contas solicitadas..."
	bExcLibCta		:= {|| CRM020BQry(oBrwDcs,cQryDcs),CRM020BQry(oBrwCtaLnl,cQryCtaLnl)} //"Localizado as contas para liberação..."
	
	If lHideSol 
		//Desabilita a pasta Solicitacoes de Contas / Contas Solicitadas
		aTFolder		:= {STR0016}//Liberações de Contas
	ElseIf lHideLib
		//Desabilita a pasta Liberacoes de Contas
		aTFolder		:= {STR0017,STR0075}//#"Solicitaçoes de Contas"#"Contas Solicitadas
		bSetOption		:= {|nFolSel| IIF( nFolSel==2, Eval(bExcSolCta), Nil )  }
	Else
		aTFolder		:= {STR0017,STR0075,STR0016}//#"Solicitaçoes de Contas"#"Contas Solicitadas#"Liberações de Contas"	
		bSetOption		:= {|nFolSel| IIF( nFolSel==2, Eval(bExcSolCta), IIF( nFolSel==3, Eval(bExcLibCta), Nil ) )  }
	EndIf
	
	oTFolder := TFolder():New( 0,0,aTFolder,,oPnlModal,,,,.T.,,(oPnlModal:nClientWidth/2),(oPnlModal:nClientHeight/2))
	oTFolder:bSetOption	:= bSetOption	        
	
	If !lHideSol  
	
		oFwlSol := FWLayer():New()
		oFwlSol:Init(oTFolder:aDialogs[1],.F.)
			
		oFwlSol:AddLine("LINETOP",15,.T.)
		oFwlSol:AddCollumn("PESQ_AVAN",100,.T.,"LINETOP")
		oFwlSol:AddWindow("PESQ_AVAN","oDlgPesq",STR0018,100,.F.,.F.,,"LINETOP")//"Pesquisa Avançada"
		oDlgPesq := oFwlSol:GetWinPanel( "PESQ_AVAN","oDlgPesq","LINETOP")
			
		@ 003,001 SAY STR0019 SIZE 25,10 OF oDlgPesq PIXEL//"Contas:"
		@ 003,025 CHECKBOX oChkACH VAR lACH PROMPT STR0020 SIZE 37,10 OF oDlgPesq  PIXEL//"Suspects"
		@ 003,065 CHECKBOX oChkSUS VAR lSUS PROMPT STR0021 SIZE 37,10 OF oDlgPesq PIXEL//"Prospects"
		@ 003,107 CHECKBOX oChkSA1 VAR lSA1 PROMPT STR0022 SIZE 37,10 OF oDlgPesq  PIXEL//"Clientes"
			
		@ 001,144 MSGET oMsGPesq VAR cPesq PICTURE "@!" SIZE 180,10 OF oDlgPesq PIXE			
		@ 002,330 BUTTON oBtnPesq PROMPT  STR0024 SIZE 034, 010 ACTION CRM020BVdPesq(cPesq, lACH, lSUS, lSA1, cCodVend, aNvlStruct, oBrwPesq, cQryPesq, cAliasPesq ) OF oDlgPesq PIXEL 
				
		
		oFwlSol:AddLine("LINEBOTTOM",85,.T.)
		oFwlSol:AddCollumn("BRW_PESQ_INT",100,.T.,"LINEBOTTOM")
		oPnlBrwPesq := oFwlSol:GetColPanel( "BRW_PESQ_INT","LINEBOTTOM")
			
		// Define o alias temporario / query / colunas para o browse de pesquisa.
		cAliasPesq	 := GetNextAlias()
		cQryPesq	 := CRM020BPAv( cCodVend, aNvlStruct, cPesq, lACH, lSUS, lSA1 )
		aColPesq 	 := CRM020BGCol(BRW_PESQ_INT,cAliasPesq)
			
		oBrwPesq := FWFormBrowse():New()
		oBrwPesq:SetOwner(oPnlBrwPesq)
		oBrwPesq:SetDataQuery(.T.)           
		oBrwPesq:SetAlias(cAliasPesq) 
		oBrwPesq:SetQuery(cQryPesq)
		oBrwPesq:SetColumns(aColPesq[1])
		oBrwPesq:SetTemporary(.T.)
		oBrwPesq:SetDescription(STR0032)//"Contas Localizadas"
		oBrwPesq:SetChange({|| CRM020BSeekEnt(AllTrim((cAliasPesq)->ENTIDA),(cAliasPesq)->RECNO ) }) 
		oBrwPesq:DisableDetails()
			
		oBrwPesq:AddButton(STR0033,{|| CRM020BVldSol(cAliasPesq,cCodVend,oBrwPesq) },,,,.F.,1)//"Sincronizando os browses..."#"Atenção"#"Solicitar"
		
		oBrwPesq:AddButton(STR0034,{|| CRM020BLBrw( BRW_PESQ_INT ) },,,,.F.,1)	//"Legenda"
		 
		oBrwPesq:SetProfileID("BRW_PESQ")
		
		If ExistBlock("CRM020BBRW")
		   ExecBlock("CRM020BBRW",.F.,.F.,{BRW_PESQ_INT,oBrwPesq})
		EndIf
		
		oBrwPesq:Activate()
		
		
		// Define o alias temporario / query / colunas para o browse de solicitacao de contas.
		cAliasSol	:= GetNextAlias()
		aColSol	:= CRM020BGCol( BRW_SOL_CONTAS, cAliasSol )
		cQrySol 	:= CRM020BQAIM( BRW_SOL_CONTAS, cCodVend, nNVEstN, aNvlStruct, aColSol[2] ) 
		
		oBrwSol := FWFormBrowse():New()
		oBrwSol:SetOwner(oTFolder:aDialogs[2])
		oBrwSol:SetDataQuery(.T.)
		oBrwSol:SetAlias(cAliasSol)
		oBrwSol:SetQuery(cQrySol)
		oBrwSol:SetColumns(aColSol[1])
		oBrwSol:SetTemporary(.T.)
		oBrwSol:AddButton(STR0038,{|| CRM020B20C(/*cEntidad*/,/*cCodCta*/,/*cLojCta*/,(cAliasSol)->AIM_CODIGO,cCodVend,/*nTypeForm*/,MODEL_OPERATION_VIEW)},,,,.F.,1)//"Visualizar"
		oBrwSol:AddButton(STR0039,{|| IIF(CRM020B20C(/*cEntidad*/,/*cCodCta*/,/*cLojCta*/,(cAliasSol)->AIM_CODIGO,cCodVend,TYPE_FORM_SOL_CONTAS,MODEL_OPERATION_DELETE),CRM020BQry(oBrwSol,cQrySol),Nil)},,,,.F.,1)//"Excluir"
		oBrwSol:AddButton(STR0040,{|| IIF(CRM020B20C(/*cEntidad*/,/*cCodCta*/,/*cLojCta*/,(cAliasSol)->AIM_CODIGO,cCodVend,TYPE_FORM_SOL_CONTAS,MODEL_OPERATION_UPDATE),CRM020BQry(oBrwSol,cQrySol),NIl)},,,,.F.,1)//"Alterar"
		oBrwSol:AddButton(STR0041,{|| CRM020BLBrw(BRW_SOL_CONTAS) },,,,.F.,1)//"Legenda"
		oBrwSol:SetDescription(STR0042)//"Contas Solicitadas"
		oBrwSol:DisableDetails()
		oBrwSol:SetProfileID("BRW_SOL") 
		
		If ExistBlock("CRM020BBRW")
		   ExecBlock("CRM020BBRW",.F.,.F.,{BRW_SOL_CONTAS,oBrwSol})
		EndIf
		
		oBrwSol:Activate()
	
	EndIf
	
	If !lHideLib		
		
		If lHideSol
			oFolderLib := oTFolder:aDialogs[1]
		Else
			oFolderLib := oTFolder:aDialogs[3]
		EndIf
		
		oFWLLnl := FWLayer():New()
		oFWLLnl:Init(oFolderLib,.F.)
			
		oFWLLnl:AddLine("LINETOP",50,.T.)
		oFWLLnl:AddCollumn("DCS_CTA",100,.T.,"LINETOP")
		oPnlDcs := oFWLLnl:GetColPanel("DCS_CTA","LINETOP")
		
		// Define o alias temporario / query / colunas para o browse de decisao.
		cAliasDcs	:= GetNextAlias()
		aColDcs 	:= CRM020BGCol(BRW_DCS_CONTAS,cAliasDcs)
		cQryDcs 	:= CRM020BGQD( cCodVend, nNVEstN, aNvlStruct, aColDcs[2] )  
				
		oBrwDcs := FWFormBrowse():New()
		oBrwDcs:SetOwner(oPnlDcs)
		oBrwDcs:SetDataQuery(.T.)
		oBrwDcs:SetAlias(cAliasDcs)  
		oBrwDcs:SetQuery(cQryDcs)
		oBrwDcs:SetColumns(aColDcs[1])
				
		oBrwDcs:AddButton(STR0043,{|| IIF(CRM020B20C(/*cEntidad*/,/*cCodCta*/,/*cLojCta*/,(cAliasDcs)->AIM_CODIGO,cCodVend,TYPE_FORM_DCS_CONTAS,MODEL_OPERATION_UPDATE),;
		(CRM020BQry(oBrwDcs,cQryDcs),CRM020BQry(oBrwCtaLnl,cQryCtaLnl)),Nil)},,,,.F.,1)	//"Sincronizando os browses..."#"Atenção"#"Decisão"
		
		oBrwDcs:AddButton(STR0044,{|| CRM020BLBrw(BRW_DCS_CONTAS) },,,,.F.,1)//"Legenda"
		oBrwDcs:SetDescription(STR0045)//"Decisão"
		oBrwDcs:DisableDetails()
		oBrwDcs:SetProfileID("BRW_DCS_CTA")
		
		If ExistBlock("CRM020BBRW")
		   ExecBlock("CRM020BBRW",.F.,.F.,{BRW_DCS_CONTAS,oBrwDcs})
		EndIf
		
		oBrwDcs:Activate()
			
		oFWLLnl:AddLine("LINEBOTTOM",50,.T.)
		oFWLLnl:AddCollumn("CTA_LIB_N_LIB",100,.T.,"LINEBOTTOM")
		oPnlCtaLnl := oFWLLnl:GetColPanel("CTA_LIB_N_LIB","LINEBOTTOM")
			
		// Define o alias temporario / query / colunas para o browse de contas liberadas e nao liberadas.
		cAliasCLnl := GetNextAlias()
		aColCtaLnl := CRM020BGCol(BRW_CONTAS_LIB_N_LIB,cAliasCLnl)
		cQryCtaLnl := CRM020BQAIM( BRW_CONTAS_LIB_N_LIB, cCodVend, nNVEstN, aNvlStruct, aColCtaLnl[2] ) 
			
		oBrwCtaLnl := FWFormBrowse():New()
		oBrwCtaLnl:SetOwner(oPnlCtaLnl)
		oBrwCtaLnl:SetDataQuery(.T.)
		oBrwCtaLnl:SetAlias(cAliasCLnl)
		oBrwCtaLnl:SetQuery(cQryCtaLnl)
		oBrwCtaLnl:SetColumns(aColCtaLnl[1])
		oBrwCtaLnl:AddButton(STR0046,{|| CRM020B20C(/*cEntidad*/,/*cCodCta*/,/*cLojCta*/,(cAliasCLnl)->AIM_CODIGO,cCodVend,TYPE_FORM_DCS_CONTAS,MODEL_OPERATION_VIEW)},,,,.F.,1)//"Visualizar"
		oBrwCtaLnl:AddButton(STR0047,{|| CRM020BLBrw(BRW_CONTAS_LIB_N_LIB) },,,,.F.,1)//"Legenda"
		oBrwCtaLnl:SetDescription(STR0048)//"Contas Liberadas / Não liberadas"
		oBrwCtaLnl:DisableDetails()
		oBrwCtaLnl:SetProfileID("BRW_CTA_LIB_N_LIB")
		
		If ExistBlock("CRM020BBRW")
			ExecBlock("CRM020BBRW",.F.,.F.,{BRW_CONTAS_LIB_N_LIB,oBrwCtaLnl})
		EndIf
	
		oBrwCtaLnl:Activate()
	
	EndIf
	
	oDlg:Activate() 

EndIf
	
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BVldSol
Valida a solicitacao da conta.

@param cAliasPesq	, caracter		, Alias da pesquisa
@param cCodVend	, caracter		, Codigo do vendedor
@param oBrwPesq	, objeto		, Browse de pesquisa

@author	Anderson Silva
@version	12
@since		21/07/2016
/*/
//------------------------------------------------------------------------------
Static Function CRM020BVldSol(cAliasPesq,cCodVend,oBrwPesq)
		
Local lRetorno 	:= .T.
Local uRetorno	:= Nil
Local lCRM20BSol	:= ExistBlock("CRM20BSL")
Local nTypeForm	:= TYPE_FORM_SOL_CONTAS

Do Case 

	//"Conta de sua carteira."
	Case (cAliasPesq)->STATUS == 1
		lRetorno := .F.
		MsgAlert(STR0076) //"Esta conta pertence a sua carteira."
	//"Conta em processo de aprovação de solicitação."
	Case (cAliasPesq)->STATUS == 2
		lRetorno := .F.
		MsgAlert(STR0095) //"Esta conta está em processo de aprovação."
	//"Conta que não pertence a estrutura de negócio."
	Case (cAliasPesq)->STATUS == 3
		lRetorno := .F.
		MsgAlert(STR0096) //"O proprietário desta conta não vinculado na estrutura de negócio."
	/*
		Usuário pode solicitar...
		Contas de sua equipe de vendas
		Contas de outras equipes de vendas
	*/
	Case ( (cAliasPesq)->STATUS == 4 .Or. (cAliasPesq)->STATUS == 5 )
		
		If lCRM20BSol
			uRetorno := ExecBlock("CRM20BSL",.F.,.F.,{AllTrim((cAliasPesq)->ENTIDA),(cAliasPesq)->CODIGO,(cAliasPesq)->LOJA,cCodVend,TYPE_FORM_SOL_CONTAS})
			If ValType( uRetorno ) == "A"
				lRetorno 	:= uRetorno[1]
				nTypeForm	:= uRetorno[2]
			Else
				lRetorno := .F.
				MsgStop(STR0099) //"O retorno inválido do PE CRM20BSL."
			EndIf
		EndIf
		
		If lRetorno	
			lRetorno := CRM020B20C(AllTrim((cAliasPesq)->ENTIDA),(cAliasPesq)->CODIGO,(cAliasPesq)->LOJA,/*cCodTranf*/,cCodVend,nTypeForm,MODEL_OPERATION_INSERT)
			If lRetorno 
				CRM020BStatus(cAliasPesq,oBrwPesq)
			EndIf
		EndIf
		
EndCase

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BVdPesq
Valida a pesquisa de solicitação.

@param cPesq		, caracter		, Criterio de pesquisa
@param lACH		, logico		, Pesquisa por Suspect
@param lSUS		, logico		, Pesquisa por Prospect
@param lACH		, logico		, Pesquisa por Cliente
@param cCodVend	, caracter		, Codigo do Vendedor
@param aNvlStruct	, array			, Vetor com as informações do nivel da estrutura.
@param oBrwPesq	, objeto		, Browse da pesquisa
@param cQryPesq	, caracter		, Query montada para pesquisa.
@param cAliasPesq , caracter		, Alias da Pesquisa

@author	Anderson Silva
@version	12
@since		21/07/2016
/*/
//------------------------------------------------------------------------------
Static Function CRM020BVdPesq(cPesq, lACH, lSUS, lSA1, cCodVend, aNvlStruct, oBrwPesq, cQryPesq, cAliasPesq )
		
Local lRet	:= .T.

Default cPesq 		:= ""
Default lACH  		:= .F.
Default lSUS			:= .F.
Default lSA1			:= .F.
Default cCodVend 		:= "" 
Default aNvlStruct 	:= {}
Default oBrwPesq	 	:= Nil
Default cQryPesq		:= ""
Default cAliasPesq	:= ""

If !Empty( cPesq )
	
	If ( lACH .Or. lSUS .Or. lSA1 )
		cPesq := AllTrim( cPesq )
		cQryPesq := CRM020BPAv( cCodVend, aNvlStruct, cPesq, lACH, lSUS, lSA1 )
		CRM020BQry( oBrwPesq ,cQryPesq )
		If (cAliasPesq)->(!Eof())
			CRM020BSeekEnt(AllTrim((cAliasPesq)->ENTIDA), (cAliasPesq)->RECNO )
		Else
			MsgAlert(STR0077) //"Não foi encontrada nenhuma conta para pesquisa informada!"
		EndIf
	Else
		MsgAlert( STR0078 ) //"Selecione pelo menos uma entidade Suspect / Prospect ou Cliente para realizar a pesquisa!"
	EndIf
	
Else
	MsgAlert(STR0079) //"Informe um critério para pesquisa!"
EndIf

Return( lRet ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BLBrw

Legenda dos browses

@sample 	CRM020BLBrw(nBrowse)

@param		ExpN1 - Id do browse

@return	Nenhum

@author	Anderson Silva
@since		03/10/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function CRM020BLBrw(nBrowse)

Local oLegenda  	:=  FWLegend():New()

Do Case
	Case BRW_PESQ_INT == nBrowse
		oLegenda:Add("","BR_VERMELHO"	,STR0080)	//"Conta de sua carteira."
		oLegenda:Add("","BR_AMARELO"	,STR0049)	//"Conta de sua equipe de vendas."
		oLegenda:Add("","BR_VERDE"		,STR0050)	//"Conta de outra equipe de vendas."
		oLegenda:Add("","BR_PRETO"		,STR0089)	//"Conta em processo de aprovação de solicitação."	
		oLegenda:Add("","BR_BRANCO"		,STR0086)	//"Conta de proprietário não vinculado na estrutura de negócio."  
	Case BRW_SOL_CONTAS == nBrowse
		oLegenda:Add("","BR_AMARELO"	,STR0051)//"Aguardando liberação da conta."
		oLegenda:Add("","BR_VERDE"	 	,STR0052)//"Conta liberada para esta solicitação."
		oLegenda:Add("","BR_PRETO" 		,STR0053)//"Conta não liberada para esta solicitação."
	Case BRW_DCS_CONTAS == nBrowse 
		oLegenda:Add("","BR_AMARELO"	,STR0054)//"Aguardando liberação da conta."
	Case BRW_CONTAS_LIB_N_LIB == nBrowse
		oLegenda:Add("","BR_VERDE"	 	,STR0055)//"Conta liberada para esta solicitação."
		oLegenda:Add("","BR_PRETO" 		,STR0056)//"Conta não liberada para esta solicitação."
EndCase

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BGCol

Retorna as colunas dos browses ( Pesquisa Avancada / Solicitacao de Contas e Liberacao de contas )

@sample	CRM020BGCol(nBrowse,cAlias)

@param		ExpN1 Id do browse
			ExpC2 Alias temporario
			
@return	ExpA {Colunas do browse,campos que sera considerado na query}

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020BGCol(nBrowse,cAliasTmp)

Local aArea	 	:= GetArea()
Local aCampos	:= {}
Local aColumns	:= {}
Local aCpoQry	:= {}
Local nX		:= 0
Local nLinha	:= 0
Local cIniBrw	:= ""
Local cCampo	:= ""
Local aPECol	:= ""

DbSelectArea("SX3")
DbSetOrder(2)//X3_CAMPO

If nBrowse == BRW_PESQ_INT
	
	//Legenda do STATUS
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&(	"{|| CRM020BRLeg( (cAliasTmp)->STATUS ) }"))
	aColumns[nLinha]:SetTitle("")
	aColumns[nLinha]:SetType("C")
	aColumns[nLinha]:SetPicture("@BMP")
	aColumns[nLinha]:SetSize(1)
	aColumns[nLinha]:SetDecimal(0)
	aColumns[nLinha]:SetDoubleClick({|| CRM020BLBrw(nBrowse,1) })
	aColumns[nLinha]:SetImage(.T.)
	
	//Filial do Sistema
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&(	"{|| (cAliasTmp)->FILIAL }"))
	aColumns[nLinha]:SetTitle(TxDadosCpo("A1_FILIAL")[1])
	aColumns[nLinha]:SetSize(TamSX3("A1_FILIAL")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_FILIAL")[2])
	If ( Empty( xFilial("SA1") ) .And. Empty( xFilial("SUS") ) .And. Empty( xFilial("ACH") ) )
		aColumns[nLinha]:SetDelete(.T.)
	EndIf
	
	//Nome da Entidade
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| Posicione('SX2',1,(cAliasTmp)->ENTIDA,'X2NOME()') }"))
	aColumns[nLinha]:SetTitle(STR0057)//"Nome Entid."
	aColumns[nLinha]:SetSize(TamSX3("AIM_NOMENT")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("AIM_NOMENT")[2])
	
	//Codigo
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->CODIGO } "))
	aColumns[nLinha]:SetTitle(STR0058)//"Código Ent."
	aColumns[nLinha]:SetSize(TamSX3("AIM_CODCTA")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("AIM_CODCTA")[2])
	
	//Loja
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->LOJA }"))
	aColumns[nLinha]:SetTitle(STR0059)//"Loja Ent."
	aColumns[nLinha]:SetSize(TamSX3("AIM_LOJCTA")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("AIM_LOJCTA")[2])
	
	//Nome
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->NOME }"))
	aColumns[nLinha]:SetTitle(STR0060)//"Nome"
	aColumns[nLinha]:SetSize(TamSX3("A1_NOME")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_NOME")[2])
	
	//Fantasia
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->NREDUZ }"))
	aColumns[nLinha]:SetTitle(STR0061)//"N.Fantasia"
	aColumns[nLinha]:SetSize(TamSX3("A1_NREDUZ")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_NREDUZ")[2])
	
	//Pessoa
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| CRMA20BPPJ((cAliasTmp)->PESSOA)[1] }"))
	aColumns[nLinha]:SetTitle(STR0062)//"Pessoa"
	aColumns[nLinha]:SetSize(10)
	aColumns[nLinha]:SetDecimal(0)
	
	//CGC
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| Transform((cAliasTmp)->ID,CRMA20BPPJ((cAliasTmp)->PESSOA)[2]) }"))
	aColumns[nLinha]:SetTitle(STR0063)//"CNPJ/CPF"
	aColumns[nLinha]:SetSize(TamSX3("A1_CGC")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_CGC")[2])
	
	//Vendedor
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->CODVEND }"))
	aColumns[nLinha]:SetTitle(STR0064)//"Cod.Vend"
	aColumns[nLinha]:SetSize(TamSX3("A3_COD")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A3_COD")[2])
	
	//Nome
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->VENDEDOR }"))
	aColumns[nLinha]:SetTitle(STR0065)//"Nome"
	aColumns[nLinha]:SetSize(TamSX3("A3_NOME")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A3_NOME")[2])
	
	//Código do Territorio
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->CODTER }"))
	aColumns[nLinha]:SetTitle(STR0081)//"Cod. Terr."
	aColumns[nLinha]:SetSize(TamSX3("A1_CODTER")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_CODTER")[2])
	
	//Nome do Territorio
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)                                      
	aColumns[nLinha]:SetData(&("{|| AllTrim(Posicione('AOY',1,xFilial('AOY')+(cAliasTmp)->CODTER,	'AOY_NMTER')) }"))
	aColumns[nLinha]:SetTitle(STR0082)//"Nome Territ."
	aColumns[nLinha]:SetSize(TamSX3("A1_NOMTER")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_NOMTER")[2])
	
	//Tipo Membro 
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| X3Combo('A1_TPMEMB',(cAliasTmp)->TPMEMB) }"))
	aColumns[nLinha]:SetTitle(STR0083)//"Desc. Membro"
	aColumns[nLinha]:SetSize(TamSX3("A1_TPMEMB")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_TPMEMB")[2])
	
	//Membro
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| (cAliasTmp)->CODMEMB }"))
	aColumns[nLinha]:SetTitle(STR0084)//"Membro"
	aColumns[nLinha]:SetSize(TamSX3("A1_CODMEMB")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_CODMEMB")[2])
	
	//Desc. Membro
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{|| CRMA640Gat((cAliasTmp)->TPMEMB,(cAliasTmp)->CODMEMB)}"))
	aColumns[nLinha]:SetTitle(STR0085)//"Desc. Membro"
	aColumns[nLinha]:SetSize(TamSX3("A1_DSCMEMB")[1])
	aColumns[nLinha]:SetDecimal(TamSX3("A1_DSCMEMB")[2])	
	
Else
	
	aCampos := {"AIM_CODIGO","AIM_ENTIDA","AIM_NOMENT","AIM_CODCTA",;
   				"AIM_LOJCTA","AIM_NOMCTA","AIM_CODMOT","AIM_DSCMOT"	}
	
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
	aColumns[nLinha]:SetData(&("{ || IIF(AIM_STATUS=='1','BR_AMARELO',IIF((cAliasTmp)->AIM_STATUS=='2','BR_VERDE','BR_PRETO')) }"))
	aColumns[nLinha]:SetTitle("")
	aColumns[nLinha]:SetType("C")
	aColumns[nLinha]:SetPicture("@BMP")
	aColumns[nLinha]:SetSize(1)
	aColumns[nLinha]:SetDecimal(0)
	aColumns[nLinha]:SetDoubleClick({|| CRM020BLBrw(nBrowse) })
	aColumns[nLinha]:SetImage(.T.)
	
	If BRW_SOL_CONTAS == nBrowse .Or. BRW_DCS_CONTAS == nBrowse
		aAdd(aCampos,"AIM_VENSOL")
		aAdd(aCampos,"AIM_NVDSOL")
		aAdd(aCampos,"AIM_DTSOL")
		aAdd(aCampos,"AIM_HRSOL")
		aAdd(aCampos,"AIM_STATUS")
	Else
		aAdd(aCampos,"AIM_VENSOL")
		aAdd(aCampos,"AIM_NVDSOL")
		aAdd(aCampos,"AIM_DTSOL")
		aAdd(aCampos,"AIM_HRSOL")
		aAdd(aCampos,"AIM_VENDCS")
		aAdd(aCampos,"AIM_NVDDCS")
		aAdd(aCampos,"AIM_DTDCS")
		aAdd(aCampos,"AIM_HRDCS")
		aAdd(aCampos,"AIM_STATUS")
	EndIf
	
	For nX := 1 To Len(aCampos)
		If SX3->(DbSeek(AllTrim(aCampos[nX])))
			If (X3USO(SX3->X3_USADO) .AND. SX3->X3_BROWSE == "S" .AND. SX3->X3_TIPO <> "M") .OR.SX3->X3_CAMPO = "AIM_FILIAL"
				AAdd(aColumns,FWBrwColumn():New())
				nLinha	:= Len(aColumns)
				cCampo 	:= AllTrim(SX3->X3_CAMPO)
				cIniBrw := AllTrim(SX3->X3_INIBRW)
				aColumns[nLinha]:SetType(SX3->X3_TIPO)
				If SX3->X3_CONTEXT <> "V"
					aAdd(aCpoQry,cCampo)
					If SX3->X3_TIPO = "D"
						aColumns[nLinha]:SetData( &("{|| sTod("  + "('"+cAliasTmp+"')->" + cCampo + ") }") )
					ElseIf !Empty(X3CBox())
						aColumns[nLinha]:SetData( &("{|| X3Combo('" +  cCampo + "',('"+cAliasTmp+"')->" + cCampo + ") }") )
					Else
						aColumns[nLinha]:SetData( &("{|| " + "('"+cAliasTmp+"')->" + cCampo + " }") )
					EndIf
				Else
					aColumns[nLinha]:SetData( &("{|| CRMA20BIBw(" + "'"+cIniBrw+"','"+cAliasTmp+"'" + ") }") )
				EndIf
				aColumns[nLinha]:SetTitle(X3Titulo())
				aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
				aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
			EndIf
		EndIf
	Next nXAND
	
EndIf

If ExistBlock("CRM020COLP")
	aPECol := ExecBlock("CRM020COLP",.F.,.F.,{nBrowse,cAliasTmp,aColumns,aCpoQry}) 
  	aColumns := aClone(aPECol[1])
  	aCpoQry  := aClone(aPECol[2])
EndIf

RestArea(aArea)

Return({aColumns,aCpoQry})


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BRLeg

Retorna uma legenda para o browse.

@sample	CRM020BRLeg( cAliasTmp )

@param		cStatus	,caracter	,Status do registro
			
@return	cLegend	,caracter	,Legenda que será considerada no browse

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020BRLeg( cStatus )

Local cLegend 	:= ""

Default cAliasTmp	:= ""

Do Case
	Case cStatus == 1
		cLegend := "BR_VERMELHO"	//"Conta de sua carteira."
	Case cStatus == 2
		cLegend := "BR_PRETO" //"Conta em processo de aprovação de solicitação."
	Case cStatus == 3
		cLegend := "BR_BRANCO"	//"Conta de proprietário não vinculado na estrutura de negócio."  
	Case cStatus == 4
		cLegend := "BR_AMARELO"	//"Conta de sua equipe de venda."
	Case cStatus == 5
		cLegend := "BR_VERDE"	//"Conta de outra equipe de venda."
EndCase

Return( cLegend )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BPAv
Rotina de pesquisa avancada.

@param cCodVend, caracter, Codigo do vendedor
@param aNvlStruct, array, Listas com níveis que o usuário tem acesso. 
@param cPesq, caracter, Chave de pesquisa
@param lACH, lógico, Buscar por Suspects
@param lSUS, lógico, Buscar por Prospects
@param lSA1, lógico, Buscar por Clientes

@return	ExpC Query para pesquisa.

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020BPAv( cCodVend, aNvlStruct, cPesq, lACH, lSUS, lSA1 )
Local aArea	   		:= GetArea()
Local cQuery			:= ""
Local cSA1 			:= ""
Local cSUS 			:= ""
Local cACH 			:= ""
Local cLike			:= ""
Local nLevel			:= ""

Default cCodVend 		:= ""  
Default aNvlStruct	:= {}
Default cPesq 		:= ""
Default lACH 			:= .T. 
Default lSUS 			:= .T.
Default lSA1  		:= .T.

If !Empty(cPesq)
	//-------------------------------------------------------------------
	// Remove caracteres especiais.  
	//-------------------------------------------------------------------	
	cPesq := CRM020BChar(cPesq)

	//-------------------------------------------------------------------
	// Monta a instrução de filtro por ID Inteligente.  
	//-------------------------------------------------------------------
	If lMVCRMUAZS == Nil  
		lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
	EndIf
		
	For nLevel := 1 To Len( aNvlStruct )
		If lMVCRMUAZS
			cLike += "  AZS.AZS_IDESTN LIKE '" + SubStr( aNvlStruct[nLevel],1,Len( aNvlStruct[nLevel] ) -2 ) + "%'"
		Else
			If nModulo == 73
				cLike += "  AO3.AO3_IDESTN LIKE '" + SubStr( aNvlStruct[nLevel],1,Len( aNvlStruct[nLevel] ) -2 ) + "%'"
			Else
				cLike += "  SA3.A3_NVLSTR LIKE '" + SubStr( aNvlStruct[nLevel],1,Len( aNvlStruct[nLevel] ) -2 ) + "%'"
			EndIf
		EndIf  
	
		If ( nLevel < Len( aNvlStruct ) ) 
			cLike += " OR "  
		EndIf 		
	Next nLevel	

	If lMVCRMUAZS
	
		cSA1 += " SELECT "
		cSA1 += " 		A1_FILIAL FILIAL, 'SA1' ENTIDA, A1_COD CODIGO, A1_LOJA LOJA, A1_NOME NOME, "
		cSA1 += " 		A1_NREDUZ NREDUZ, A1_PESSOA PESSOA, A1_CODTER  CODTER, A1_TPMEMB TPMEMB, A1_CODMEMB CODMEMB,"
		cSA1 += " 		A1_CGC ID, A3_COD CODVEND, A3_NOME VENDEDOR, "
		cSA1 += " 		CASE	WHEN ( AZS.AZS_VEND = '" + cCodVend + "' ) THEN 1 "
		cSA1 += "				WHEN ( EXISTS (	SELECT AIM_CODCTA 
		cSA1 += "										FROM	" 
		cSA1 += "											 	" + RetSqlName("AIM") + " AIM "
		cSA1 += " 									 	WHERE 
		cSA1 += "												AIM_FILIAL = '" + xFilial("AIM") + "'"
		cSA1 += "												AND AIM_ENTIDA = 'SA1' "
		cSA1 += "												AND AIM_CODCTA = SA1.A1_COD "
		cSA1 += "												AND AIM_LOJCTA = SA1.A1_LOJA " 
		cSA1 += "												AND AIM_STATUS = '1' "
		cSA1 += "												AND AIM.D_E_L_E_T_ = ' ' ) ) THEN 2 "	
		cSA1 += "				WHEN ( AZS.AZS_IDESTN = ' ' ) THEN 3 "	
		cSA1 += "			  	WHEN (" + cLike + ") THEN 4 "
		cSA1 += "     		ELSE 5 "
		cSA1 += " 		END STATUS,						
		cSA1 += "		SA1.R_E_C_N_O_ RECNO "
		cSA1 += " FROM " 
		cSA1 += 		RetSqlName("SA1") + " SA1, "
		cSA1 += 		RetSqlName("SA3") + " SA3, "   
		cSA1 += 		RetSqlName("AZS") + " AZS  "
		cSA1 += " WHERE 
		cSA1 += " 		SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		cSA1 += " 		AND ( SA1.A1_COD LIKE '" + cPesq + "%'" 
		cSA1 += "		OR SA1.A1_CGC LIKE '" + cPesq + "%' " 
		cSA1 += "		OR SA1.A1_NREDUZ LIKE '" + cPesq + "%'" 
		cSA1 += "		OR SA1.A1_NOME LIKE '" + cPesq + "%'" 
		cSA1 += "		OR SA1.A1_TEL LIKE '" + cPesq + "%'" 
		cSA1 += "		OR SA1.A1_EMAIL LIKE '" + cPesq + "%' )"
		cSA1 += " 		AND SA1.D_E_L_E_T_ = ' ' "
		cSA1 += "		AND SA3.A3_FILIAL ='" + xFilial("SA3") + "'" 
		cSA1 += "		AND SA3.A3_COD = SA1.A1_VEND 
		cSA1 += "		AND AZS.AZS_FILIAL ='" + xFilial("AZS") + "'" 
		cSA1 += "     AND AZS.AZS_VEND = SA3.A3_COD " 
		cSA1 += "		AND SA3.D_E_L_E_T_ = ' ' "
		cSA1 += " 		AND AZS.D_E_L_E_T_ = ' ' "
			
		cSUS += " SELECT "
		cSUS += " 		US_FILIAL FILIAL, 'SUS' ENTIDA, US_COD CODIGO, US_LOJA LOJA, US_NOME NOME, "
		cSUS += " 		US_NREDUZ NREDUZ, US_PESSOA PESSOA, US_CODTER  CODTER, US_TPMEMB TPMEMB, US_CODMEMB CODMEMB,"
		cSUS += " 		US_CGC ID, A3_COD CODVEND, A3_NOME VENDEDOR, "
		cSUS += " 		CASE	WHEN ( AZS.AZS_VEND = '" + cCodVend + "' ) THEN 1 "
		cSUS += "				WHEN ( EXISTS (	SELECT AIM_CODCTA 
		cSUS += "										FROM	" 
		cSUS += "											 	" + RetSqlName("AIM") + " AIM "
		cSUS += " 									 	WHERE 
		cSUS += "												AIM_FILIAL = '" + xFilial("AIM") + "'"
		cSUS += "												AND AIM_ENTIDA = 'SUS' "
		cSUS += "												AND AIM_CODCTA = SUS.US_COD "
		cSUS += "												AND AIM_LOJCTA = SUS.US_LOJA " 
		cSUS += "												AND AIM_STATUS = '1' "
		cSUS += "												AND AIM.D_E_L_E_T_ = ' ' ) ) THEN 2 "	
		cSUS += "				WHEN ( AZS.AZS_IDESTN = ' ' ) THEN 3 "	
		cSUS += "			  	WHEN (" + cLike + ") THEN 4 "
		cSUS += "     		ELSE 5 "
		cSUS += " 		END STATUS,						
		cSUS += "		SUS.R_E_C_N_O_ RECNO "
		cSUS += " FROM " 
		cSUS +=		    RetSqlName("SUS") + " SUS, "
		cSUS += 		RetSqlName("SA3") + " SA3, " 
		cSUS += 		RetSqlName("AZS") + " AZS  "
		cSUS += " WHERE 
		cSUS += " 		SUS.US_FILIAL = '" + xFilial("SUS") + "' "
		cSUS += " 		AND ( SUS.US_COD LIKE '" + cPesq + "%' " 
		cSUS += "		OR SUS.US_CGC LIKE '" + cPesq + "%' " 
		cSUS += "		OR SUS.US_NREDUZ LIKE '" + cPesq + "%' " 
		cSUS += "		OR SUS.US_NOME LIKE '" + cPesq + "%' " 
		cSUS += "		OR SUS.US_TEL LIKE '" + cPesq + "%' " 
		cSUS += "		OR SUS.US_EMAIL LIKE '" + cPesq + "%' )"
		cSUS += "		AND SUS.US_STATUS <> '6' "
		cSUS += "		AND SUS.US_CODCLI	= ' ' "
		cSUS += "		AND SUS.US_LOJACLI = ' ' "
		cSUS += " 		AND SUS.D_E_L_E_T_ = ' ' "
		cSUS += "		AND SA3.A3_FILIAL ='" + xFilial("SA3") + "'" 
		cSUS += "		AND SA3.A3_COD = SUS.US_VEND "
		cSUS += "		AND AZS.AZS_FILIAL = '" + xFilial("AZS") + "'" 
		cSUS += "     AND AZS.AZS_VEND = SA3.A3_COD "
		cSUS += "		AND SA3.D_E_L_E_T_ = ' ' "
		cSUS += " 		AND AZS.D_E_L_E_T_ = ' ' "
		
		cACH += " SELECT " 
		cACH += "		ACH_FILIAL FILIAL, 'ACH' ENTIDA, ACH_CODIGO CODIGO, ACH_LOJA LOJA, ACH_RAZAO NOME, "
		cACH += "		ACH_NFANT NREDUZ, ACH_PESSOA PESSOA, ACH_CODTER  CODTER, ACH_TPMEM TPMEMB, ACH_CODMEM CODMEMB, "
		cACH += "  	ACH_CGC ID, A3_COD CODVEND, A3_NOME VENDEDOR, "
		cACH += " 		CASE	WHEN ( AZS.AZS_VEND = '" + cCodVend + "' ) THEN 1 "
		cACH += "				WHEN ( EXISTS (	SELECT AIM_CODCTA 
		cACH += "										FROM	" 
		cACH += "											 	" + RetSqlName("AIM") + " AIM "
		cACH += " 									 	WHERE 
		cACH += "												AIM_FILIAL = '" + xFilial("AIM") + "'"
		cACH += "												AND AIM_ENTIDA = 'ACH' "
		cACH += "												AND AIM_CODCTA = ACH.ACH_CODIGO "
		cACH += "												AND AIM_LOJCTA = ACH.ACH_LOJA " 
		cACH += "												AND AIM_STATUS = '1' "
		cACH += "												AND AIM.D_E_L_E_T_ = ' ' ) ) THEN 2 "	
		cACH += "				WHEN ( AZS.AZS_IDESTN = ' ' ) THEN 3 "	
		cACH += "			  	WHEN (" + cLike + ") THEN 4 "
		cACH += "     		ELSE 5 "
		cACH += " 		END STATUS,						
		cACH += "		ACH.R_E_C_N_O_ RECNO "
		cACH += " FROM " 
		cACH += 		RetSqlName("ACH") + " ACH, " 
		cACH += 		RetSqlName("SA3") + " SA3, "
		cACH += 		RetSqlName("AZS") + " AZS  "
		cACH += " WHERE 
		cACH += "		ACH.ACH_FILIAL = '" + xFilial("ACH") + "' "
		cACH += "		AND ( ACH.ACH_RAZAO LIKE '" + cPesq + "%' "
		cACH += "		OR ACH.ACH_NFANT LIKE '" + cPesq + "%' " 
		cACH += "		OR ACH.ACH_CGC LIKE '" + cPesq + "%' "
		cACH += "		OR ACH.ACH_CODIGO LIKE '" + cPesq + "%' "
		cACH += "		OR ACH.ACH_TEL LIKE '" + cPesq + "%' "
		cACH += "		OR ACH.ACH_EMAIL LIKE '" + cPesq + "%') "
		cACH += " 		AND ACH.ACH_STATUS <> '6' "
		cACH += " 		AND ACH.ACH_CODPRO = ' ' "
		cACH += "		AND ACH.ACH_LOJPRO = ' ' "
		cACH += "		AND ACH.D_E_L_E_T_ = ' ' "
		cACH += "		AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'" 
		cACH += "		AND SA3.A3_COD = ACH.ACH_VEND "
		cACH += "		AND AZS.AZS_FILIAL ='" + xFilial("AZS") + "'" 
		cACH += "		AND AZS.AZS_VEND = SA3.A3_COD "
		cACH += "		AND SA3.D_E_L_E_T_ = ' ' "
		cACH += " 		AND AZS.D_E_L_E_T_ = ' ' "
	
	Else
	
		cSA1 += " SELECT "
		cSA1 += " 		A1_FILIAL FILIAL, 'SA1' ENTIDA, A1_COD CODIGO, A1_LOJA LOJA, A1_NOME NOME, "
		cSA1 += " 		A1_NREDUZ NREDUZ, A1_PESSOA PESSOA, A1_CODTER  CODTER, A1_TPMEMB TPMEMB, A1_CODMEMB CODMEMB,"
		cSA1 += " 		A1_CGC ID, A3_COD CODVEND, A3_NOME VENDEDOR, "
		cSA1 += " 		CASE	WHEN ( SA3.A3_COD = '" + cCodVend + "' ) THEN 1 "
		cSA1 += "				WHEN ( EXISTS (	SELECT AIM_CODCTA 
		cSA1 += "										FROM	" 
		cSA1 += "											 	" + RetSqlName("AIM") + " AIM "
		cSA1 += " 									 	WHERE 
		cSA1 += "												AIM_FILIAL = '" + xFilial("AIM") + "'"
		cSA1 += "												AND AIM_ENTIDA = 'SA1' "
		cSA1 += "												AND AIM_CODCTA = SA1.A1_COD "
		cSA1 += "												AND AIM_LOJCTA = SA1.A1_LOJA " 
		cSA1 += "												AND AIM_STATUS = '1' "
		cSA1 += "												AND AIM.D_E_L_E_T_ = ' ' ) ) THEN 2 "

		If nModulo == 73
			cSA1 += "				WHEN ( AO3.AO3_NVESTN  = 0 ) THEN 3 "	
			cSA1 += "			  	WHEN (" + cLike + ") THEN 4 "
		Else
			cSA1 += "				WHEN ( SA3.A3_NVLSTR  = ' ' ) THEN 3 "	
			cSA1 += "			  	WHEN (" + cLike + ") THEN 4 "
		EndIf
		
		
		cSA1 += "     		ELSE 5 "
		cSA1 += " 		END STATUS,					
		cSA1 += " 		SA1.R_E_C_N_O_ RECNO "
		cSA1 += " FROM "
		cSA1 += 		RetSqlName("SA1") +" SA1, "
		cSA1 += 		RetSqlName("SA3") +" SA3  "
		
		If nModulo == 73
			cSA1 +=		", " + RetSqlName("AO3") +" AO3  "
		EndIf
		
		cSA1 += " WHERE "
		cSA1 += " 		SA1.A1_FILIAL = '"+ xFilial("SA1") +"' "
		cSA1 += "		AND ( SA1.A1_COD LIKE '"+ cPesq +"%' "
		cSA1 += "		OR SA1.A1_CGC LIKE '"+ cPesq +"%' "
		cSA1 += "		OR SA1.A1_NREDUZ LIKE '"+ cPesq +"%' "
		cSA1 += "		OR SA1.A1_NOME LIKE '"+ cPesq +"%' "
		cSA1 += "		OR SA1.A1_TEL LIKE '"+ cPesq +"%' "
		cSA1 += "		OR SA1.A1_EMAIL LIKE '"+ cPesq +"%' ) "
		cSA1 += " 		AND SA1.D_E_L_E_T_ = ' ' 
		cSA1 += "		AND SA3.A3_FILIAL ='"+ xFilial("SA3") +"' "
		cSA1 += "		AND SA3.A3_COD = SA1.A1_VEND "
		cSA1 += "		AND SA3.D_E_L_E_T_ = ' ' "

		If nModulo == 73
			cSA1 += "		AND AO3.AO3_FILIAL ='"+ xFilial("AO3") +"' "
			cSA1 += "		AND AO3.AO3_VEND = SA1.A1_VEND "
			cSA1 += "		AND AO3.D_E_L_E_T_ = ' ' "
		EndIf

		cSUS += " SELECT "
		cSUS += " 		US_FILIAL FILIAL, 'SUS' ENTIDA, US_COD CODIGO, US_LOJA LOJA, US_NOME NOME, "
		cSUS += " 		US_NREDUZ NREDUZ, US_PESSOA PESSOA, US_CODTER  CODTER, US_TPMEMB TPMEMB, US_CODMEMB CODMEMB,"
		cSUS += " 		US_CGC ID, A3_COD CODVEND, A3_NOME VENDEDOR, "
		cSUS += " 		CASE	WHEN ( SA3.A3_COD = '" + cCodVend + "' ) THEN 1 "
		cSUS += "				WHEN ( EXISTS (	SELECT AIM_CODCTA 
		cSUS += "										FROM	" 
		cSUS += "											 	" + RetSqlName("AIM") + " AIM "
		cSUS += " 									 	WHERE 
		cSUS += "												AIM_FILIAL = '" + xFilial("AIM") + "'"
		cSUS += "												AND AIM_ENTIDA = 'SUS' "
		cSUS += "												AND AIM_CODCTA = SUS.US_COD "
		cSUS += "												AND AIM_LOJCTA = SUS.US_LOJA " 
		cSUS += "												AND AIM_STATUS = '1' "
		cSUS += "												AND AIM.D_E_L_E_T_ = ' ' ) ) THEN 2 "	

		If nModulo == 73
			cSUS += "				WHEN ( AO3.AO3_NVESTN  = 0 ) THEN 3 "	
			cSUS += "			  	WHEN (" + cLike + ") THEN 4 "
		Else
			cSUS += "				WHEN ( SA3.A3_NVLSTR  = ' ' ) THEN 3 "	
			cSUS += "			  	WHEN (" + cLike + ") THEN 4 "
		EndIf 

		cSUS += "     		ELSE 5 "
		cSUS += " 		END STATUS,					
		cSUS += " 		SUS.R_E_C_N_O_ RECNO "
		cSUS += " FROM "
		cSUS += 		RetSqlName("SUS") +" SUS, "
		cSUS += 		RetSqlName("SA3") +" SA3 "

		If nModulo == 73
			cSUS +=		", " + RetSqlName("AO3") +" AO3  "
		EndIf

		cSUS += " WHERE "
		cSUS += " 		SUS.US_FILIAL = '"+ xFilial("SUS") +"' "
		cSUS += "		AND ( SUS.US_COD LIKE '"+ cPesq +"%' "
		cSUS += "		OR SUS.US_CGC LIKE '"+ cPesq +"%' "
		cSUS += "		OR SUS.US_NREDUZ LIKE '"+ cPesq +"%' "
		cSUS += "		OR SUS.US_NOME LIKE '"+ cPesq +"%' "
		cSUS += "		OR SUS.US_TEL LIKE '"+ cPesq +"%' "
		cSUS += "		OR SUS.US_EMAIL LIKE '"+ cPesq +"%' ) "
		cSUS += "		AND SUS.US_STATUS <> '6' "
		cSUS += "		AND SUS.US_CODCLI	= ' ' "
		cSUS += "		AND SUS.US_LOJACLI	= ' ' "
		cSUS += " 		AND SUS.D_E_L_E_T_ = ' ' "
		cSUS += "		AND SA3.A3_FILIAL ='"+ xFilial("SA3") +"' "
		cSUS += "		AND SA3.A3_COD = SUS.US_VEND "

		If nModulo <> 73
			cSUS += "		AND SA3.A3_NIVEL <> 0 "
			cSUS += "		AND SA3.A3_NVLSTR <> '"+ Space(TAMSX3("A3_NVLSTR")[1]) +"' "
		EndIf

		cSUS += "		AND SA3.D_E_L_E_T_ = ' ' "
		cSUS += " 		AND NOT EXISTS " 
		cSUS += "			( SELECT AIM_CODCTA "
		cSUS += "			  FROM "+ RetSqlName("AIM") +" AIM "
		cSUS += "			  WHERE "
		cSUS += "				AIM_FILIAL = '"+ xFilial("AIM") +"' "
		cSUS += "				AND AIM_ENTIDA = 'SUS' "
		cSUS += "				AND AIM_CODCTA = SUS.US_COD "
		cSUS += "				AND AIM_LOJCTA = SUS.US_LOJA "
		cSUS += "				AND AIM_STATUS = '1' "
		cSUS += "				AND AIM.D_E_L_E_T_ = ' ' ) "	

		If nModulo == 73
			cSUS += "		AND AO3.AO3_FILIAL ='"+ xFilial("AO3") +"' "
			cSUS += "		AND AO3.AO3_VEND = SUS.US_VEND "
			cSUS += "		AND AO3.D_E_L_E_T_ = ' ' "
		EndIf
		
		cACH += " SELECT "
		cACH += "		ACH_FILIAL FILIAL, 'ACH' ENTIDA, ACH_CODIGO CODIGO, ACH_LOJA LOJA, ACH_RAZAO NOME, "
		cACH += "		ACH_NFANT NREDUZ, ACH_PESSOA PESSOA, ACH_CODTER  CODTER, ACH_TPMEM TPMEMB, ACH_CODMEM CODMEMB, "
		cACH += "  	ACH_CGC ID, A3_COD CODVEND, A3_NOME VENDEDOR, "
		cACH += " 		CASE	WHEN ( SA3.A3_COD = '" + cCodVend + "' ) THEN 1 "
		cACH += "				WHEN ( EXISTS (	SELECT AIM_CODCTA 
		cACH += "										FROM	" 
		cACH += "											 	" + RetSqlName("AIM") + " AIM "
		cACH += " 									 	WHERE 
		cACH += "												AIM_FILIAL = '" + xFilial("AIM") + "'"
		cACH += "												AND AIM_ENTIDA = 'ACH' "
		cACH += "												AND AIM_CODCTA = ACH.ACH_CODIGO "
		cACH += "												AND AIM_LOJCTA = ACH.ACH_LOJA " 
		cACH += "												AND AIM_STATUS = '1' "
		cACH += "												AND AIM.D_E_L_E_T_ = ' ' ) ) THEN 2 "	

		If nModulo == 73
			cACH += "				WHEN ( AO3.AO3_NVESTN  = 0 ) THEN 3 "	
			cACH += "			  	WHEN (" + cLike + ") THEN 4 "
		Else
			cACH += "				WHEN ( SA3.A3_NVLSTR  = ' ' ) THEN 3 "	
			cACH += "			  	WHEN (" + cLike + ") THEN 4 "
		EndIf
		
		cACH += "     		ELSE 5 "
		cACH += " 		END STATUS,					
		cACH += " 		ACH.R_E_C_N_O_ RECNO "
		cACH += " FROM "
		cACH += 		RetSqlName("ACH") +" ACH, "
		cACH += 		RetSqlName("SA3") +" SA3 "

		If nModulo == 73
			cACH +=		", " + RetSqlName("AO3") +" AO3  "
		EndIf

		cACH += " WHERE "
		cACH += " 		ACH.ACH_FILIAL='"+ xFilial("ACH") +"' "
		cACH += " 		AND ( ACH.ACH_RAZAO LIKE '"+ cPesq +"%' "
		cACH += "		OR ACH.ACH_NFANT LIKE '"+ cPesq +"%' " 
		cACH += "		OR ACH.ACH_CGC LIKE '"+ cPesq +"%' " 
		cACH += "		OR ACH.ACH_CODIGO LIKE '"+ cPesq +"%' "
		cACH += "		OR ACH.ACH_TEL LIKE '"+ cPesq +"%' "
		cACH += "		OR ACH.ACH_EMAIL LIKE '"+ cPesq +"%') "
		cACH += " 		AND ACH.ACH_STATUS <> '6' "
		cACH += " 		AND ACH.ACH_CODPRO = ' ' "
		cACH += "		AND ACH.ACH_LOJPRO = ' ' "
		cACH += "		AND ACH.D_E_L_E_T_ = ' ' "
		cACH += "		AND SA3.A3_FILIAL = '"+ xFilial("SA3") +"' "
		cACH += "		AND SA3.A3_COD = ACH.ACH_VEND "
		cACH += "		AND SA3.D_E_L_E_T_= ' ' "

		If nModulo == 73
			cACH += "		AND AO3.AO3_FILIAL ='"+ xFilial("AO3") +"' "
			cACH += "		AND AO3.AO3_VEND = ACH.ACH_VEND "
			cACH += "		AND AO3.D_E_L_E_T_ = ' ' "
		EndIf
		
	EndIf
			
	If lSA1
		cQuery += cSA1
	Endif
	
	If lSUS
		cQuery += IIF(lSA1," UNION ALL ","") + cSUS
	Endif
	
	If lACH
		cQuery += IIF(lSA1 .OR. lSUS," UNION ALL ","") + cACH
	Endif
	
	cQuery += " ORDER BY ENTIDA,CODIGO,LOJA " 
Else
	cQuery := "SELECT A1_FILIAL FILIAL, 'SA1' ENTIDA, A1_COD CODIGO, A1_LOJA LOJA, A1_NOME NOME, "
	cQuery += "A1_NREDUZ NREDUZ, A1_PESSOA PESSOA, A1_CODTER  CODTER, A1_TPMEMB TPMEMB, A1_CODMEMB CODMEMB,"
	cQuery += "'" + Space(TamSX3("ACH_CGC")[1]) + "' ID, '" + Space(TamSX3("A3_COD")[1]) + "' CODVEND, '" + Space(TamSX3("A3_NOME")[1]) + "' VENDEDOR, 0 STATUS, 0 RECNO "
	cQuery += " FROM "+ RetSqlName("SA1") +" SA1 "
	cQuery += " WHERE 0 > 1 "
EndIf

If ExistBlock("CRM020QRYP")
	cQuery := ExecBlock("CRM020QRYP",.F.,.F.,{cQuery, cCodVend, aNvlStruct, cPesq, lACH, lSUS, lSA1}) 
EndIf

RestArea(aArea)

Return( cQuery )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20BPPJ
TA
Retorna o tipo da pessoa Fisica ou Juridica com a sua picture.

@sample	CRMA20BPPJ(cTipPes)

@param		ExpC1 Tipo de pessoa (F|CF|J)

@return	ExpA Tipo de pessoa / Picture

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA20BPPJ(cTipPes)

Local aRet := {}

If cTipPes $ "F|CF"
	aRet := {STR0066,"@R 999.999.999-99"}//"Física"
Else
	aRet := {STR0067,"@R 99.999.999/9999-99"}//"Jurídica"
Endif

Return( aRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BQry

Executa uma query no browser informado

@sample	CRM020BQry(oBrowse,cQuery)

@param		ExpO1 Objeto do browser
			ExpC2 Query a ser executada

@return	Nenhum

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020BQry(oBrowse,cQuery)

CursorWait()
oBrowse:Data():DeActivate()
oBrowse:SetQuery( cQuery )
oBrowse:Data():Activate()
oBrowse:Refresh(.T.,.T.)
CursorArrow()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BGQD
Monta a query para trazer as contas que sera liberada ou nao liberada conforme
a posicao do vendedor na estrutura de vendas.

@param cCodVend, caracter, Codigo do vendedor logado na solicitacao / liberacao de contas.	
@param nNVEstN, numérico, Nivel que vendedor que esta na estrutura de negocio.
@param aNvlStruct, array, Listas com ID Inteligente que o usuário tem acesso.
@param aCampos, array, Campos do browse que sera considerado na query.
@return	cQuery, caracter, Query com as contas

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020BGQD( cCodVend, nNVEstN, aNvlStruct, aCampos )

Local cQuery 			:= ""
Local nX	 			:= ""
Local cCampos			:= ""
Local cLike			:= ""
Local nLevel			:= 0

Default cCodVend 		:= ""
Default nNVEstN		:= 0
Default aNvlStruct	:= {}
Default aCampos     	:= {}

For nX := 1 To Len(aCampos)
	If nX <> Len(aCampos)
		cCampos += aCampos[nX]+", "
	Else
		cCampos += aCampos[nX]
	EndIf                                                              
Next nX

//-------------------------------------------------------------------
// Monta a instrução de filtro por ID Inteligente.  
//-------------------------------------------------------------------	
For nLevel := 1 To Len( aNvlStruct )
	If lMVCRMUAZS
		cLike += "  AZS.AZS_IDESTN LIKE '" + aNvlStruct[nLevel] + "%'"
	Else
		If nModulo == 73
			cLike += "  AO3.AO3_IDESTN LIKE '" + aNvlStruct[nLevel] + "%'"
		Else
 			cLike += "  SA3.A3_NVLSTR LIKE '" + aNvlStruct[nLevel] + "%'"
		EndIf
	EndIf

	If ( nLevel < Len( aNvlStruct ) ) 
		cLike += " OR "
	EndIf 		
Next nLevel	

If lMVCRMUAZS
	cQuery += " SELECT " + cCampos
	cQuery += " FROM " + RetSqlName("AIM") + " AIM LEFT JOIN  " + RetSqlName("AZS") + " AZS ON AIM.AIM_VENPRO = AZS.AZS_VEND " 
	cQuery += " WHERE AIM.AIM_FILIAL = '"+ xFilial("AIM") +"' AND AZS.AZS_FILIAL = '"+ xFilial("AZS") + "' "
	cQuery += " AND AIM.AIM_STATUS = '1' "
	cQuery += " AND (" + cLike + ")  AND AIM.AIM_VENSOL <> '" + cCodVend + "' " 	
	cQuery += " AND AIM.D_E_L_E_T_ = ' ' AND AZS.D_E_L_E_T_ = ' ' "
Else
	cQuery += " SELECT " + cCampos "
	cQuery += " FROM "+ RetSqlName("AIM") +" AIM LEFT JOIN "+ RetSqlName("SA3") +" SA3 ON AIM.AIM_VENPRO = SA3.A3_COD "

	If nModulo == 73
		cQuery += " INNER JOIN "+ RetSqlName("AO3") +" AO3 ON SA3.A3_COD = AO3.AO3_VEND "
	EndIf

	cQuery += " WHERE AIM.AIM_FILIAL = '"+ xFilial("AIM") +"' AND SA3.A3_FILIAL = '"+ xFilial("SA3") +"' "
	cQuery += " AND AIM.AIM_STATUS = '1' "
	cQuery += " AND (" + cLike + ") 
	
	If nModulo == 73
		cQuery += " AND AO3_NVESTN > " + cValToChar(nNVEstN)
	Else
		cQuery += " AND SA3.A3_NIVEL > "+ cValToChar(nNVEstN) 
	EndIf

	cQuery += " AND AIM.AIM_VENSOL <> '"+cCodVend+"' " 
	cQuery += " AND AIM.D_E_L_E_T_ = ' ' AND SA3.D_E_L_E_T_ = ' ' "
	
	If nModulo == 73
		cQuery += " AND AO3.D_E_L_E_T_ = ' ' "
	EndIf 

EndIf

Return( cQuery )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BQAIM
Monta a query para trazer as contas solicitadas conforme a regra definida no 
browse.

@param nBrowse, numérico, Id do browse
@param cCodVend, caracter, Codigo do vendedor logado no CRM.
@param nNVEstN, numérico, Nivel que vendedor esta na estrutura de negocio.
@param aNvlStruct, array, Listas com ID Inteligente que o usuário tem acesso.
@param aCampos, array, Campos do browse que sera considerado na query.
@return	cQuery, caracter, Query das contas já solicitadas

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020BQAIM( nBrowse, cCodVend, nNVEstN, aNvlStruct, aCampos )
Local cQuery 	:= ""
Local cCampos	:= "" 
Local cLike		:= ""
Local nX		:= 0
Local nLevel	:= 0

Default nBrowse	 	:= 1
Default cCodVend 	:= "" 
Default nNVEstN	:= 0
Default aNvlStruct	:= {}
Default aCampos	 	:= {}

For nX := 1 To Len(aCampos)
	If nX <> Len(aCampos)
		cCampos += aCampos[nX]+", " 
	Else
		cCampos += aCampos[nX]
	EndIf
Next nX

//-------------------------------------------------------------------
// Monta a instrução de filtro por ID Inteligente.  
//-------------------------------------------------------------------	
For nLevel := 1 To Len( aNvlStruct )
	If lMVCRMUAZS
		cLike += "  AZS.AZS_IDESTN LIKE '" + aNvlStruct[nLevel] + "%'"
	Else
		If nModulo == 73
			cLike += "  AO3.AO3_IDESTN LIKE '" + aNvlStruct[nLevel] + "%'"
		Else
			cLike += "  SA3.A3_NVLSTR LIKE '" + aNvlStruct[nLevel] + "%'"
		EndIf
	EndIf

	If ( nLevel < Len( aNvlStruct ) ) 
		cLike += " OR "
	EndIf 		
Next nLevel	

If lMVCRMUAZS
	cQuery += " SELECT " + cCampos
	cQuery += " FROM " + RetSqlName("AIM") + " AIM LEFT JOIN " + RetSqlName("AZS") +" AZS "
	
	If nBrowse == BRW_SOL_CONTAS
		cQuery += " ON AIM.AIM_VENSOL = AZS.AZS_VEND "
	ElseIf nBrowse == BRW_CONTAS_LIB_N_LIB
		cQuery += " ON AIM.AIM_VENDCS = AZS.AZS_VEND "
	EndIf
	
	cQuery += " WHERE AIM.AIM_FILIAL = '" + xFilial("AIM") + "' AND AZS.AZS_FILIAL = '" + xFilial("AZS") + "' "

	If nBrowse == BRW_SOL_CONTAS
		cQuery += " AND AIM.AIM_VENSOL = '" + cCodVend + "' "
		cQuery += " AND AIM.AIM_STATUS IN ('1','2','3') "
	ElseIf nBrowse == BRW_CONTAS_LIB_N_LIB	
		cQuery += " AND (" + cLike + ")" 
		cQuery += " AND AIM.AIM_VENSOL <> '" + cCodVend + "'  "
		cQuery += " AND AIM.AIM_STATUS IN ('2','3') "
	EndIf
	
	cQuery += " AND AIM.D_E_L_E_T_ = ' ' AND AZS.D_E_L_E_T_ = ' ' "

Else
	cQuery += " SELECT " + cCampos
	cQuery += " FROM "+ RetSqlName("AIM") +" AIM LEFT JOIN "+ RetSqlName("SA3") +" SA3 "

	If nBrowse == BRW_SOL_CONTAS
		cQuery += " ON AIM.AIM_VENSOL = SA3.A3_COD "
	ElseIf nBrowse == BRW_CONTAS_LIB_N_LIB
		cQuery += " ON AIM.AIM_VENDCS = SA3.A3_COD "
	EndIf

	If nModulo == 73
		cQuery += " INNER JOIN "+ RetSqlName("AO3") +" AO3 ON SA3.A3_COD = AO3.AO3_VEND "
	EndIf
	
	cQuery += " WHERE AIM.AIM_FILIAL = '"+ xFilial("AIM") +"' AND SA3.A3_FILIAL = '"+ xFilial("SA3") +"' "
		
	If nBrowse == BRW_SOL_CONTAS
		cQuery += " AND AIM.AIM_VENSOL = '" + cCodVend + "'  "
		cQuery += " AND AIM.AIM_STATUS IN ('1','2','3') "
	ElseIf nBrowse == BRW_CONTAS_LIB_N_LIB
		cQuery += " AND (" + cLike + ")" 
		If nModulo == 73
			cQuery += " AND AO3_NVESTN >= " + cValToChar(nNVEstN)
		Else
			cQuery += " AND SA3.A3_NIVEL >= "+ cValToChar(nNVEstN)  
		EndIf
		cQuery += " AND AIM.AIM_VENSOL <> '" + cCodVend + "'  " 
		cQuery += " AND AIM.AIM_STATUS IN ('2','3') "  
	EndIf

	cQuery += " AND AIM.D_E_L_E_T_ = ' ' AND SA3.D_E_L_E_T_ = ' ' " 

	If nModulo == 73
		cQuery += " AND AO3.D_E_L_E_T_ = ' ' "
	EndIf 

	
EndIf
 
Return(cQuery)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020B20C

Executa a rotina de solicitacao de contas e liberacao ou nao liberacao da conta.

@sample	CRM020B20C(cEntidad,cCodCta,cLojCta,cCodTranf,cCodVend,nTypeForm,nOperation)

@param		ExpC1 Entidade.
			ExpC2 Codigo da conta.
			ExpC3 Loja da conta.
			ExpA4 Codigo de transferencia 
			ExpC5 Codigo do vendedor logado no CRM.
			ExpN6 Tipo de formulario solicitacao ou decisao.
			ExpN7 Tipo de operacao.

@return	ExpL Verdadeiro / Falso

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020B20C(cEntidad,cCodCta,cLojCta,cCodTranf,cCodVend,nTypeForm,nOperation)

Local lRetorno := .T.
Local aArea	   := GetArea()

Default cEntidad 	:= ""
Default cCodCta		:= ""
Default cLojCta		:= ""
Default cCodTranf	:= ""
Default cCodVend	:= ""
Default nTypeForm	:= 1
Default nOperation  := 1   

If !Empty(cEntidad) .OR. !Empty(cCodTranf)	

	If nOperation <> MODEL_OPERATION_INSERT
		
		AIM->( DbSetOrder(1) )//AIM_FILIAL+AIM_CODIGO
		
		If AIM->( DbSeek(xFilial("AIM")+cCodTranf) )
			If nOperation == MODEL_OPERATION_VIEW .AND. AIM->AIM_STATUS $ "2|3"  
				nTypeForm := TYPE_FORM_DCS_CONTAS
			ElseIf ( nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE ) .AND. AIM->AIM_STATUS <> "1"
				MsgAlert(STR0068,STR0001)//"Esta solicitação não poderá ser modificada."
				lRetorno := .F.
			EndIf
		EndIf
			
	EndIf                    
	
	If lRetorno
		lRetorno := CRMA020C(cEntidad,cCodCta,cLojCta,cCodVend,nTypeForm,nOperation)
	EndIf
	
Else
	Help(" ",1,"SemDados")
	lRetorno := .F.
EndIf

RestArea(aArea)

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020BStatus

Atualiza o status da tabela temporaria da pesquisa da solicitação.

@sample	CRM020BStatus(cAliasTmp,lUpdate)

@param		ExpC1 Alias temporario.  
			ExpL2 Grava a disponibilidade na tabela temporaria.

@return	ExpL Verdadeiro / Falso

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020BStatus(cAliasPesq,oBrwPesq)

Local lRetorno 	:= .T.
Local nStatus		:= 0
Local cEntidade	:= AllTrim((cAliasPesq)->ENTIDA)
Local cCodigo		:= (cAliasPesq)->CODIGO
Local cLoja		:= (cAliasPesq)->LOJA
Local cCodVend	:= ""
Local cCodTer		:= ""
Local cTipoMem	:= ""
Local cCodMem		:= ""
Local cMsg			:= ""

//AIM_FILIAL+AIM_ENTIDA+AIM_CODCTA+AIM_LOJCTA
AIM->( DBSetOrder( 2 ) )

If AIM->( DBSeek( xFilial("AOM") + cEntidade + cCodigo + cLoja ) )

	If AIM->AIM_STATUS == "1"
		nStatus	:= 2
		cMsg	 	:= STR0097	//"Esta conta está em processo de aprovação, por favor aguarde..."
	ElseIf AIM->AIM_STATUS == "2"
		nStatus	:= 1
		cMsg	 	:= STR0098	//"Esta conta foi transferida para sua carteira."
	EndIf
	
	If !Empty( nStatus )
		
		RecLock(cAliasPesq,.F.)
		
		(cAliasPesq)->STATUS := nStatus

		If nStatus == 1
		
			If cEntidade == "SA1"
				SA1->(DBSetOrder(1))
				If SA1->( DBSeek( PadR(AllTrim((cAliasPesq)->FILIAL),TamSX3("A1_FILIAL")[1]) + cCodigo + cLoja ) )
					cCodVend	:= SA1->A1_VEND
					cCodTer	:= SA1->A1_CODTER
					cTipoMem	:= SA1->A1_TPMEMB
					cCodMem	:= SA1->A1_CODMEMB
				EndIf
			ElseIf cEntidade == "SUS"
				SUS->(DBSetOrder(1))
				If SUS->( DBSeek( PadR(AllTrim((cAliasPesq)->FILIAL),TamSX3("US_FILIAL")[1]) + cCodigo + cLoja ) )
					cCodVend	:= SUS->US_VEND
					cCodTer	:= SUS->US_CODTER
					cTipoMem	:= SUS->US_TPMEMB
					cCodMem	:= SUS->US_CODMEMB
				EndIf
			Else	
				ACH->(DBSetOrder(1))
				If ACH->( DBSeek( PadR(AllTrim((cAliasPesq)->FILIAL),TamSX3("ACH_FILIAL")[1]) + cCodigo + cLoja ) )
					cCodVend	:= ACH->ACH_VEND
					cCodTer	:= ACH->ACH_CODTER
					cTipoMem	:= ACH->ACH_TPMEM
					cCodMem	:= ACH->ACH_CODMEM
				EndIf
			EndIf

			(cAliasPesq)->CODVEND	:= cCodVend
			(cAliasPesq)->CODTER		:= cCodTer
			(cAliasPesq)->TPMEMB 	:= cTipoMem
			(cAliasPesq)->CODMEMB 	:= cCodMem
			
		EndIf 	
		
		MsUnLock()
		
		oBrwPesq:LineRefresh()
		
		ApMsgAlert(cMsg)

	EndIf
EndIf

Return( lRetorno ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc}CRMA20BIBw

Faz a inicializacao dos browses

@sample	CRMA20BIBw(cIniBrw,cAlias)

@param		ExpC1 Inicializacao do browse do campo.  
			ExpC2 Alias temporario.

@return	ExpC Valor

@author	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA20BIBw(cIniBrw,cAlias)
Local cRetorno := ""

AIM->( DbSetOrder(1) )//AIM_FILIAL+AIM_CODIGO

If AIM->( DbSeek(xFilial("AIM")+(cAlias)->AIM_CODIGO) )
	cRetorno := &(cIniBrw)
EndIf    

Return(cRetorno)  

//------------------------------------------------------------------------------
/*/{Protheus.doc}CRM020BChar

Função que trata caracter especial

@sample	CRM020BChar(cString)

@param		cString, caracter, Texto que será avaliado  

@return	cRetStr, caracter, Texto sem caracter especial

@author	Jonatas Martins
@since		21/08/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM020BChar(cString)

Local cChar	:= ""
Local cRetStr := ""
Local nPos		:= 0

Default cString := "" 
  
If !Empty( cString )
	//-------------------
	// Retira acentuação
	//-------------------
	cString := NoAcento( cString )
	
	//----------------------------------
	// Verifica se a string é um e-mail
	//----------------------------------
	If At( "@" , cString ) == 0
		//-----------------------------
		// Retira caracteres especiais
		//-----------------------------
		For nPos := 1 To Len( cString )
			cChar := SubStr( cString, nPos, 1 )  
			If Empty( cChar ) .Or. IsAlpha( cChar ) .Or. cChar $ "0|1|2|3|4|5|6|7|8|9|" 
				cRetStr += cChar
			EndIf 
		Next nPos
	Else
		cRetStr := cString
	EndIf
EndIf
		
Return ( cRetStr )

//------------------------------------------------------------------------------
/*/{Protheus.doc}CRM020BSeekEnt

Posiciona automaticamente na entidade confome a movimentação do browse de pesquisa.

@sample	CRM020BSeekEnt(cEntidade, cChave)

@param		cEntidade	, caracter, Entidade posicionada no browse

@return	nRecno		, numerico, Recno da entidade.

@author	Anderson Silva
@since		08/01/2016
@version	12
/*/
//--------------------------------------------------------s----------------------
Static Function CRM020BSeekEnt(cEntidade, nRecNo)
		
	Default cEntidade	:= ""
	Default nRecno	:= 0
	
	If !Empty( cEntidade ) .And. nRecno > 0
		DbSelectArea( cEntidade )
		DBGoTo( nRecno ) 
	EndIf 
	
Return Nil