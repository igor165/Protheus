#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA847.ch'

Static aValFA847
STATIC lMod2		:= .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA847
Cabeçalho da Ordem de Pagamento

@author Totvs
@since 10/01/2014
@version 1.0

//José González    *  19/12/17 * Se agrega Tratamiento para validar que la rutina FINA846 y FINA847 no se ejecuten en modelo I
/*/
//-------------------------------------------------------------------
Function FINA847(aCabOP, aDocPg, aFormaPg, nOperacao)
Local oBrowse		:= Nil
Local nA			:= 0
Local nTipoPg		:= 1 // Define que é Pagamento Automático.
Local lOPRotAut		:= Iif( ( aCabOP != Nil .AND. Len( aCabOP ) != 0 ) .OR. ( aFormaPg != Nil .AND. Len( aFormaPg ) != 0 ) .OR. !Empty( nOperacao ), .T., .F. )
Local lRet			:= .T.
Local cOrdPago		:= ""

Default nOperacao	:= 0

//Declaracao de variaveis Multimoeda
Private aTxMoedas		:= {}
Private cMoedaTx,nC	:= MoedFin()
Private cTxtRotAut	:= ""
Private lVldMsgIBB  := .T. 

// Verificação do processo que esta configurado para ser utilizado no Módulo Financeiro (Argentina)
If lMod2
	If !FinModProc()
		Return()
	EndIf
EndIf

// Se for rotina automática
If lOPRotAut

	If nOperacao == 3 .OR. nOperacao == 5
		
		// Se aDocPg vazio define que é Pagamento Antecipado.
		If aDocPg == Nil .OR. Len(aDocPg) == 0
			nTipoPg := 2
		EndIf
		
		// Inclusão
		If nOperacao == 3
		
			If (aCabOP != Nil .AND. Len(aCabOP) != 0)				
				If	(aFormaPg != Nil .AND. Len(aFormaPg) != 0)
					
					cTxtRotAut += STR0022+CRLF+CRLF // "Rotina automática da ordem de pago – inclusão" 
					cTxtRotAut += STR0023+CRLF+CRLF // "Lista de inconsistências" 
					Help(" ",1,"ROTAUTO",cTxtRotAut,STR0001,1,0)
					lMsErroAuto := .F.
					cTxtRotAut := ""
					
					If FINA850( nTipoPg, aCabOP, aDocPg, aFormaPg, lOPRotAut )
						MsgAlert(STR0022 + CRLF + CRLF + STR0001 + " " + SEK->EK_ORDPAGO ) // "Rotina automática da ordem de pago – inclusão"
					Else
						lRet := .F. 
					EndIf
								
				Else
					cTxtRotAut	+= STR0024 // "Forma de pagamento da Orden de Pago não foi informada ou está vazia."
					lRet		:= .F. 
				EndIf				
			Else
				cTxtRotAut	+= STR0025 // "Cabeçalho da Orden de Pago não foi informado ou está vazio."
				lRet		:= .F.
			EndIf
		
		// Exclusão
		ElseIf nOperacao == 5	
			
			If aCabOP != Nil .AND. Len(aCabOP) != 0
				
				cTxtRotAut += STR0026+CRLF+CRLF // "Rotina automática da ordem de pago – exclusão"
				cTxtRotAut += STR0023+CRLF+CRLF // "Lista de inconsistências" 
				Help(" ",1,"ROTAUTO",cTxtRotAut,STR0001,1,0)
				lMsErroAuto := .F.
				cTxtRotAut := ""
				cOrdPago := aCabOP[3]
				If FINA086( ,aCabOP, lOPRotAut )
					MsgAlert(cOrdPago) // "Rotina automática da ordem de pago – exclusão"
					MsgAlert(STR0026 + CRLF + CRLF + STR0001 + " " + SEK->EK_ORDPAGO + "(" + STR0018 + ")") // "Rotina automática da ordem de pago – exclusão"
				EndIf
				
			Else
				cTxtRotAut	+= STR0027	// "Cabeçalho da Orden de Pago não foi informado ou está vazio."
				lRet		:= .F. 
			EndIf
			
		EndIf		
	
	Else
		cTxtRotAut	+= STR0028	// "Operação inválida ou não informada." 
		lRet		:= .F.
	EndIf
	If !lRet
		AutoGrLog(cTxtRotAut)
	EndIf
Else	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A moeda 1 e tambem inclusa como um dummy, nao vai ter uso,            ³
	//³mas simplifica todas as chamadas a funcao xMoeda, ja que posso        ³
	//³passara a taxa usando a moeda como elemento do Array atxMoedas        ³
	//³Exemplo xMoeda(E1_VALOR,E1_MOEDA,1,dDataBase,,aTxMoedas[E1_MOEDA][2]) ³
	//³Bruno - Paraguay 25/07/2000                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	//Inicializar Array com as cotacoes e Nomes de Moedas segundo o arquivo SM2
	Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
	For nA	:=	2	To nC
		cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
		If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
			Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
		Else
			Exit
		Endif
	Next
	
	oBrowse := BrowseDef()
	
	
	oBrowse:Activate()
	
EndIf

Return lRet

Static Function BrowseDef()
Local oBrowse := NIL

oBrowse := FWMBrowse():New()


oBrowse:SetAlias('FJR')

oBrowse:SetDescription(STR0001) //'Ordem de Pagamento'

oBrowse:AddLegend("FJR_CANCEL == .F."	,"GREEN"	,STR0017	) //"Ativa"
oBrowse:AddLegend("FJR_CANCEL == .T."	,"RED"		,STR0018	) //"Cancelada"

Setkey(VK_F12,{|| Pergunte('FIN850P',.T.)})



Return oBrowse


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina		:= {}
Local lShowPOrd	:= .T.
Local aClone	:= {}
Local aPE		:={}
If cPaisLoc <> "ARG"
	Pergunte('FIN850P',.F.)
	lShowPOrd := mv_par05 == 2 // .t. se mostra apenas pre-ordens
EndIf

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FINA847'	OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION 'FINA850(1)'			OPERATION 3 ACCESS 0 //'Pagamento automático'
ADD OPTION aRotina TITLE STR0004 ACTION 'FINA850(2)'			OPERATION 3 ACCESS 0 //'Generar PA'
ADD OPTION aRotina TITLE STR0005 ACTION 'F850SetMo()'		OPERATION 10 ACCESS 0 //'Modificar Taxas'
ADD OPTION aRotina TITLE STR0020 ACTION 'Fina085R()'			OPERATION 11 ACCESS 0 //"Efetivar Op"
ADD OPTION aRotina TITLE STR0021 ACTION 'Fina086()'			OPERATION 12 ACCESS 0 //"Cancelar Ord. Pagto"
ADD OPTION aRotina TITLE STR0029 ACTION 'CTBC662'	OPERATION 13 ACCESS 0 //"Tracker Contábil"
If (cPaisLoc == "RUS")
	ADD OPTION aRotina TITLE STR0031 ACTION 'F847Leg'	OPERATION 7 ACCESS 0 //"Legenda"
Endif

If  cPaisLoc == "ARG" .AND. (ExistBlock( "FIN87OPMEN" ))

	aClone  := aClone(aRotina)
	aPE := ExecBlock( "FIN87OPMEN", .F., .F., aClone )//se pasa el menÚ existen al punto de entrada y se asigna el retorno a aPE
	If ValType(aPE) = "A"
		aRotina := aClone(aPE)//se asigana lo retornado por el PE al arreglo principal del menú.
	EndIf
			
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Totvs

@since 10/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStruFJR		:= FWFormStruct(1,'FJR')
Local oStruSEK1	:= FWFormStruct(1,'SEK')
Local oStruSEK2	:= FWFormStruct(1,'SEK')
Local oStruSEK3	:= FWFormStruct(1,'SEK')
Local oStruSEK4	:= FWFormStruct(1,'SEK')
Local oStruSEK5	:= FWFormStruct(1,'SEK')

oModel := MPFormModel():New('FINA847')
oModel:SetDescription(STR0006) //'Ordem de Pagamento Mod. II'

oModel:addFields('FJRMASTER',,oStruFJR)
oModel:getModel('FJRMASTER'):SetDescription(STR0007) //'Cabeçalho da Ordem de Pagamento'

oModel:addGrid('SEKDETAIL1','FJRMASTER',oStruSEK1)
oModel:getModel('SEKDETAIL1'):SetDescription(STR0008) //'Valores'
oModel:SetRelation('SEKDETAIL1', { { 'EK_FILIAL', 'XFilial("SEK")' }, { 'EK_ORDPAGO', 'FJR_ORDPAG' } }, SEK->(IndexKey(1)) )
oModel:GetModel( 'SEKDETAIL1' ):SetLoadFilter(,"EK_TIPODOC NOT IN ('TB','PA','RG','RB','RI','RS')" )


oModel:addGrid('SEKDETAIL2','FJRMASTER',oStruSEK2)
oModel:getModel('SEKDETAIL2'):SetDescription(STR0009) //'Baixas'
oModel:SetRelation('SEKDETAIL2', { { 'EK_FILIAL', 'XFilial("SEK")' }, { 'EK_ORDPAGO', 'FJR_ORDPAG' } }, SEK->(IndexKey(1)) )
oModel:GetModel( 'SEKDETAIL2' ):SetLoadFilter(,"EK_TIPODOC IN ('TB')" )

oModel:addGrid('SEKDETAIL3','FJRMASTER',oStruSEK3)
oModel:getModel('SEKDETAIL3'):SetDescription(STR0010) //'Adiantamentos'
oModel:SetRelation('SEKDETAIL3', { { 'EK_FILIAL', 'XFilial("SEK")' }, { 'EK_ORDPAGO', 'FJR_ORDPAG' } }, SEK->(IndexKey(1)) )
oModel:GetModel( 'SEKDETAIL3' ):SetLoadFilter(,"EK_TIPODOC IN ('PA')" )

oModel:addGrid('SEKDETAIL4','FJRMASTER',oStruSEK4)
oModel:getModel('SEKDETAIL4'):SetDescription(STR0011) //'Retenções'
oModel:SetRelation('SEKDETAIL4', { { 'EK_FILIAL', 'XFilial("SEK")' }, { 'EK_ORDPAGO', 'FJR_ORDPAG' } }, SEK->(IndexKey(1)) )
oModel:GetModel( 'SEKDETAIL4' ):SetLoadFilter(,"EK_TIPODOC IN ('RG','RB','RI','RS')" )

oModel:addGrid('SEKDETAIL5','FJRMASTER',oStruSEK5)
oModel:getModel('SEKDETAIL5'):SetDescription(STR0019) //'Terceiros'
oModel:SetRelation('SEKDETAIL5', { { 'EK_FILIAL', 'XFilial("SEK")' }, { 'EK_ORDPAGO', 'FJR_ORDPAG' } }, SEK->(IndexKey(1)) )
oModel:GetModel( 'SEKDETAIL5' ):SetLoadFilter(,"EK_TIPODOC IN ('CT')" )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Totvs

@since 10/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= ModelDef()

Local oStruFJR:= FWFormStruct(2, 'FJR')
Local oStruSEK1:= FWFormStruct(2, 'SEK',{|cCampo| FA847Stru( cCampo,1 )})
Local oStruSEK2:= FWFormStruct(2, 'SEK',{|cCampo| FA847Stru( cCampo,2 )})
Local oStruSEK3:= FWFormStruct(2, 'SEK',{|cCampo| FA847Stru( cCampo,3 )})
Local oStruSEK4:= FWFormStruct(2, 'SEK',{|cCampo| FA847Stru( cCampo,4 )})
Local oStruSEK5:= FWFormStruct(2, 'SEK',{|cCampo| FA847Stru( cCampo,5 )})

oView := FWFormView():New()

oView:SetModel(oModel)

oStruFJR:RemoveField('FJR_CANCEL')

oView:AddField('VIEW_FJR' ,oStruFJR		,'FJRMASTER' )

oView:AddGrid('VIEW_SEK1' ,oStruSEK1	,'SEKDETAIL1')
oView:AddGrid('VIEW_SEK2' ,oStruSEK2	,'SEKDETAIL2')
oView:AddGrid('VIEW_SEK3' ,oStruSEK3	,'SEKDETAIL3')
oView:AddGrid('VIEW_SEK4' ,oStruSEK4	,'SEKDETAIL4')
oView:AddGrid('VIEW_SEK5' ,oStruSEK5	,'SEKDETAIL5')

oView:CreateHorizontalBox( 'SUPERIOR', 50)
oView:CreateHorizontalBox( 'INFERIOR', 50)

oView:CreateFolder( 'PASTAS','INFERIOR' )
oView:AddSheet( 'PASTAS'	,'ABA_VALORES'	,STR0008) //'Valores'
oView:AddSheet( 'PASTAS'	,'ABA_BAIXAS'		,STR0009) //'Baixas'
oView:AddSheet( 'PASTAS'	,'ABA_ADIANT'		,STR0010) //'Adiantamentos'
oView:AddSheet( 'PASTAS'	,'ABA_RETENCOES'	,STR0011) //'Retenções'
oView:AddSheet( 'PASTAS'	,'ABA_TERCEIROS'	,STR0019) //'Terceiros'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'VALORES'	, 100,,, 'PASTAS', 'ABA_VALORES'	)
oView:CreateHorizontalBox( 'BAIXAS'		, 100,,, 'PASTAS', 'ABA_BAIXAS'		)
oView:CreateHorizontalBox( 'ADIANT'		, 100,,, 'PASTAS', 'ABA_ADIANT'		)
oView:CreateHorizontalBox( 'RETENCOES'	, 100,,, 'PASTAS', 'ABA_RETENCOES'	)
oView:CreateHorizontalBox( 'TERCEIROS'	, 100,,, 'PASTAS', 'ABA_TERCEIROS'	)

oView:SetOwnerView('VIEW_FJR'	,'SUPERIOR'	)

oView:SetOwnerView('VIEW_SEK1'	,'VALORES'		)
oView:SetOwnerView('VIEW_SEK2'	,'BAIXAS'		)
oView:SetOwnerView('VIEW_SEK3'	,'ADIANT'		)
oView:SetOwnerView('VIEW_SEK4'	,'RETENCOES'	)
oView:SetOwnerView('VIEW_SEK5'	,'TERCEIROS'	)

oView:EnableTitleView('VIEW_FJR'	,STR0012)	//"Ordem de Pagamento"
oView:EnableTitleView('VIEW_SEK1'	,STR0013)	//"Valores pagos a fornecedores"
oView:EnableTitleView('VIEW_SEK2'	,STR0014)	//"Documentos pagos e créditos compensados"
oView:EnableTitleView('VIEW_SEK3'	,STR0015)	//"Documentos de crédito que foram gerados com o saldo que não foi aplicado"
oView:EnableTitleView('VIEW_SEK4'	,STR0016)	//"Retenções de impostos"
oView:EnableTitleView('VIEW_SEK5'	,STR0019)	//"Títulos de terceiros"

Return oView

//---------------------------------------
//Funcao para remover campos dos folders
//---------------------------------------
Static Function FA847Stru( cCampo,nFolder )
Local lRet		:= .T.
Local aCposNo	:= {}
Local nX		:= 0

cCampo	:=	Alltrim(cCampo)

aCposNo :=	{	'EK_FILIAL'	,;
				'EK_ORDPAGO'	,;
				'EK_NATUREZ'	,;
				'EK_TIPODOC'	,;
				'EK_LA'		,;
				'EK_CANCEL'	,;
				'EK_DTDIGIT'	,;
				'EK_DOCREC'	,;
				'EK_FORNECE'	,;
				'EK_LOJA'		,;
				'EK_EMISSAO'}

Do Case
	Case nFolder == 1
		AAdd(aCposNo,"EK_JUROS")
		If cPaisLoc == "ARG"
			AAdd(aCposNo,"EK_MULTA")
			AAdd(aCposNo,"EK_SOLFUN")
			AAdd(aCposNo,"EK_NROCERT")
		EndIf
	Case nFolder == 2
		AAdd(aCposNo,"EK_BANCO")
		AAdd(aCposNo,"EK_AGENCIA")
		AAdd(aCposNo,"EK_CONTA")
		AAdd(aCposNo,"EK_OBSBCO")
		AAdd(aCposNo,"EK_TALAO")
		If cPaisLoc == "ARG"
			AAdd(aCposNo,"EK_NUMLOT")
			AAdd(aCposNo,"EK_PGTOELT")
			AAdd(aCposNo,"EK_MODPAGO")
			AAdd(aCposNo,"EK_SOLFUN")
			AAdd(aCposNo,"EK_NROCERT")
		EndIf
	Case nFolder == 3
		AAdd(aCposNo,"EK_JUROS")
		AAdd(aCposNo,"EK_BANCO")
		AAdd(aCposNo,"EK_AGENCIA")
		AAdd(aCposNo,"EK_CONTA")
		AAdd(aCposNo,"EK_OBSBCO")
		AAdd(aCposNo,"EK_TALAO")
		If cPaisLoc == "ARG"
			AAdd(aCposNo,"EK_NUMLOT")
			AAdd(aCposNo,"EK_PGTOELT")
			AAdd(aCposNo,"EK_MODPAGO")
			AAdd(aCposNo,"EK_NROCERT")
			AAdd(aCposNo,"EK_MULTA")
		EndIf
	Case nFolder == 4
		AAdd(aCposNo,"EK_JUROS")
		AAdd(aCposNo,"EK_BANCO")
		AAdd(aCposNo,"EK_AGENCIA")
		AAdd(aCposNo,"EK_CONTA")
		AAdd(aCposNo,"EK_OBSBCO")
		AAdd(aCposNo,"EK_TALAO")
		If cPaisLoc == "ARG"
			AAdd(aCposNo,"EK_NUMLOT")
			AAdd(aCposNo,"EK_PGTOELT")
			AAdd(aCposNo,"EK_MODPAGO")
			AAdd(aCposNo,"EK_SOLFUN")
			AAdd(aCposNo,"EK_MULTA")
		EndIf
	Case nFolder == 5
		AAdd(aCposNo,"EK_JUROS")
		If cPaisLoc == "ARG"
			AAdd(aCposNo,"EK_MULTA")
			AAdd(aCposNo,"EK_SOLFUN")
			AAdd(aCposNo,"EK_NROCERT")
		EndIf
EndCase

lRet := AScan(aCposNo,{|x| cCampo==x}) == 0

Return lRet

//------------------------------------------------------------
//Funcao para preencher os campos totalizadores da tabela FJR
//------------------------------------------------------------
Function FA847VlTot(nOpcao)
Local aSaveArea	:= GetArea()
Local aSaveSEK		:= SEK->(GetArea())
Local nTotPag		:= 0 //Total por pagar
Local nTotRet		:= 0 //Total das retencoes
Local nTotFat		:= 0 //Total das faturas
Local nTotDesc		:= 0 //Total dos descontos e compensações
Local nTotTerc		:= 0 //Total dos titulos de terceiros
Local nRet			:= 0
Local nDecs		:= MsDecimais(1)

If aValFA847 <> Nil .And. aValFA847[1] == FJR->(FJR_FILIAL+FJR_ORDPAG)

	nRet := aValFA847[2][nOpcao]

Else

	DbSelectArea("SEK")
	DbSetOrder(1) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
	If MsSeek(XFilial("SEK")+FJR->FJR_ORDPAG)
	
		While SEK->(!Eof()) .And. SEK->(EK_FILIAL+EK_ORDPAGO) == FJR->(FJR_FILIAL+FJR_ORDPAG)
			If Subs(SEK->EK_TIPODOC,1,2) == "TB"
				If SEK->EK_TIPO $ MVPAGANT+"/"+MV_CPNEG
					nTotDesc += SEK->EK_VLMOED1
				Else
					nTotFat += SEK->EK_VLMOED1
				Endif
			ElseIf Subs(SEK->EK_TIPODOC,1,2)=="RG"
				nTotRet += SEK->EK_VLMOED1
			ElseIf Subs(SEK->EK_TIPODOC,1,2)=="CT"
				nTotTerc += SEK->EK_VLMOED1
			Endif
	
		SEK->(DbSkip())
		EndDo

		nTotPag := nTotFat - nTotRet - nTotDesc

		aValFA847	:= {FJR->(FJR_FILIAL+FJR_ORDPAG),{Round(nTotPag,nDecs),Round(nTotRet,nDecs),Round(nTotFat,nDecs),Round(nTotDesc,nDecs),Round(nTotTerc,nDecs)}}
		nRet		:= aValFA847[2][nOpcao]

	EndIf

EndIf

RestArea(aSaveSEK)
RestArea(aSaveArea)
Return nRet

/*
Autor: Nikitenko Artem
date:  11/09/17
Desc.: legend colour
*/

Function F847Leg(nReg)
Local uRetorno := .T.
Local aLegenda := {}
	
aLegenda := {	{"BR_VERDE"		,alltrim(STR0032)},;//paid
				{"BR_VERMELHO"	,alltrim(STR0018)}}	//Canceled
	
If nReg == Nil
	uRetorno := {}
	aAdd(uRetorno,{"!Empty(FJK_DTANLI) .And. Empty(FJK_DTCANC) .And. Empty(FJK_ORDPAG)"	, aLegenda[1][1]}) //
	aAdd(uRetorno,{"!Empty(FJK_DTCANC)"													, aLegenda[2][1]}) //
Else
	BrwLegenda(alltrim(STR0031), ' ', aLegenda) //Legend
EndIf
	
Return(uRetorno)

