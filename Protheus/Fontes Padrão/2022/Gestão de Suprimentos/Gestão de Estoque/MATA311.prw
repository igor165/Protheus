#include "MATA311.CH"
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

STATIC oGrade
STATIC a311Filial := IIF(ExistBlock("M311FILIAL"), A311FILIAL(), {})

#DEFINE OP_EFE	"011" // Efetivar
#DEFINE OP_ALT	"004" // Alterar

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA311
Solicitação de transferência de filiais
@author antenor.silva
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA311()
Local oBrowse
Private cCadastro  := STR0001//"Registro de Transferência de Materiais"
Private c311Lote  := ""
Private c311SLote := ""
Private d311DtVld := CTOD("  /  /  ")
Private c311LocEnd:= ""
Private c311NumSer:= ""
Private l311Gtl   := .F.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('NNS')
oBrowse:SetDescription(STR0001)//'Registro de Transferência de Materiais'
//Legendas
oBrowse:AddLegend( "NNS_STATUS == '1'", "GREEN"		, STR0004 	)//"Liberado"
oBrowse:AddLegend( "NNS_STATUS == '2'", "RED"		, STR0005 	)//"Transferido"
oBrowse:AddLegend( "NNS_STATUS == '3'", "BLUE"		, STR0006 	)//"Em Aprovação"
oBrowse:AddLegend( "NNS_STATUS == '4'", "YELLOW"	, STR0007 	)//"Rejeitado"
oBrowse:AddLegend( "NNS_STATUS == '5'", "ORANGE"	, STR0046 	)//"Rejeitado"
If Existblock("MT311Leg")
	ExecBlock('MT311Leg', .F., .F., {@oBrowse})
Endif

SetKey(VK_F4,{|| A311SetKey() })

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu
@author antenor.silva
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
Local aRotinaNew:= {}

ADD OPTION aRotina TITLE STR0008		ACTION "VIEWDEF.MATA311"	OPERATION OP_INCLUIR  	ACCESS 0  	//'Incluir'//"Incluir"
ADD OPTION aRotina TITLE STR0033		ACTION "VIEWDEF.MATA311"	OPERATION OP_VISUALIZAR	ACCESS 0  	//'Visualizar'
ADD OPTION aRotina TITLE STR0034		ACTION "A311Altera"			OPERATION OP_ALTERAR 	ACCESS 0 ID OP_ALT  	//'Alterar'
ADD OPTION aRotina TITLE STR0009 	 	ACTION "A311Exclui"			OPERATION OP_EXCLUIR  	ACCESS 3	//'Excluir'
ADD OPTION aRotina TITLE STR0010	 	ACTION "A311Efetiv"			OPERATION 4 			ACCESS 0 ID OP_EFE  	//'Efetivar'
ADD OPTION aRotina TITLE STR0035	 	ACTION "VIEWDEF.MATA311"	OPERATION OP_COPIA 		ACCESS 0  	//'Copia'

IF cPaisLoc == "RUS"
	aAdd(aRotina,{STR0037, "RU05R04()", 0, 6, 0, NIL})	//The printed form of the report TORG-13
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novos itens no menu aRotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT311ROT")
	aRotinaNew := ExecBlock("MT311ROT", .F., .F., aRotina)
	If (ValType(aRotinaNew) == "A")
		aRotina := aClone(aRotinaNew)
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author antenor.silva
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStrNNS	 := FWFormStruct(1,'NNS')
Local oStrNNT	 := FWFormStruct(1,'NNT')
Local aNoCopy	 := {'NNS_STATUS', 'NNS_SOLICT', 'NNS_DATA'}
Local aNoCopyNNT := {'NNT_DOC', 'NNT_SERIE'}
Local lNposPdVen := oStrNNT:HasField('NNT_NUMPED')

Local aUnique := oStrNNT:GetTable()[FORM_STRUCT_TABLE_ALIAS_PK]
Local nCodPos := AScan(aUnique, 'NNT_COD')

oModel := MPFormModel():New('MATA311',,{|oModel| A311ActMod( oModel, 1 ) , MAT311PVld(oModel) }, {|oModel|MAT311Grv(oModel) } )

oModel:AddFields( 'NNSMASTER',,oStrNNS)
oModel:AddGrid( 'NNTDETAIL', 'NNSMASTER', oStrNNT, /*bPreValidacao*/, {|oModelNNT|A311LinOk(oModelNNT)}/*bPosValidacao*/, /*bCarga*/ )

oModel:SetRelation('NNTDETAIL', { { 'NNT_FILIAL', 'xFilial("NNT")' }, { 'NNT_COD', 'NNS_COD' } }, NNT->(IndexKey(1)) )

oModel:GetModel('NNSMASTER'):SetDescription(STR0011)//'Cabeçalho da Solicitação de Transferência de Produtos'
oModel:GetModel('NNTDETAIL'):SetDescription(STR0012)//'Itens Solicitação de Transferência de Produtos'

aGatilho := FwStruTrigger ( 'NNT_PROD' /*cDom*/, 'NNT_PROD' /*cCDom*/, "A311FillGrd()" /*cRegra*/, .F. /*lSeek*/, /*cAlias*/,  /*nOrdem*/, /*cChave*/, /*cCondic*/ )
oStrNNT:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )

addFldNNT(@oStrNNT)

//Inclui valid para o campo NNT_NSERIE
oStrNNT:SetProperty('NNT_NSERIE',MODEL_FIELD_VALID,{||A311NSerie()})

oModel:SetPrimaryKey({ 'NNS_FILIAL', 'NNS_COD' })

// A coluna NNT_COD só é preenchida no momento em que os dados do formulário são commitados.
// Por isso, em caso de Alteração, os dados inseridos anteriormente vêem com esse campo preenchido, e novas linhas não, podendo comprometer a chave única. 
If nCodPos > 0
	ADel(aUnique, nCodPos)
	ASize(aUnique, Len(aUnique) - 1)
EndIf

oModel:GetModel('NNTDETAIL'):SetUniqueLine(aUnique)

If lNposPdVen
	AADD(aNoCopyNNT,'NNT_NUMPED')
EndIf

// Configura campos que não serão considerados ao copiar registro.
oModel:GetModel('NNSMASTER'):SetFldNoCopy(aNoCopy)
oModel:GetModel('NNTDETAIL'):SetFldNoCopy(aNoCopyNNT)

oModel:SetActivate({|oModel| A311ActMod( oModel, 2 )})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author antenor.silva
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel	:= ModelDef()
Local oStrNNS	:= FWFormStruct(2, 'NNS', {|cCampo| !AllTrim(cCampo) $ "NNS_STATUS"})
Local oStrNNT	:= FWFormStruct(2, 'NNT', {|cCampo| !AllTrim(cCampo) $ "NNT_COD"})

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('NNSMASTER' , oStrNNS,'NNSMASTER' )
oView:AddGrid('NNTDETAIL' , oStrNNT,'NNTDETAIL')

oView:CreateHorizontalBox( 'BOXCIMA', 40)
oView:CreateHorizontalBox( 'BOXBAIXO',60)

oView:SetOwnerView('NNSMASTER','BOXCIMA')
oView:SetOwnerView('NNTDETAIL','BOXBAIXO')

oView:EnableTitleView('NNSMASTER' , STR0013 )//"Documento de Transferência"
oView:EnableTitleView('NNTDETAIL' , STR0014 )//"Dados para Transferência"

oView:AddUserButton(STR0002, 'CLIPS', {||  A311RepTES()})//'Replicar TES'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A311Altera()
Altera a transferência dos materiais

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311Altera()
Local cView 	:= "MATA311"
Local cStatus	:= NNS->NNS_STATUS

cOpId311 := OP_ALT

If cStatus == '1' .Or. cStatus == '4'
	FwExecView(STR0034,cView,MODEL_OPERATION_UPDATE,,{|| .T.}) // "Alterar"
ElseIf cStatus == '2'
	Help(" ",1,"A311NAOALTERA")  //"Não é possível alterar um registro Transferido ou Em Aprovação".
ElseIf cStatus == '3'
	Help(" ",1,"A311NAOALTERA")  //"Não é possível alterar um registro Transferido ou Em Aprovação".
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A311Exclui()
Efetiva a transferência dos materiais

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311Exclui()
Local cView 	:= "MATA311"
Local cStatus 	:= NNS->NNS_STATUS

If cStatus == '1' .Or. cStatus == '4'
	FwExecView(STR0009,cView,MODEL_OPERATION_DELETE,,{|| .T.})
Else
	Help(" ",1,"A311NAOEXCLUI")  //"Não é possível excluir um registro Transferido ou Em Aprovação".
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A311Efetiv()
Efetiva a transferência dos materiais

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311Efetiv()
Local cView 	:= "MATA311"
Local cStatus 	:= NNS->NNS_STATUS

cOpId311 := OP_EFE

If cStatus == '1'
	FwExecView(STR0015,cView,MODEL_OPERATION_UPDATE,,{|| .T.})	//'Efetivar'
Else
	Help(" ",1,"A311NAOEFETIVA")  //"Não é possível efetivar um registro Transferido, Em Aprovação ou Rejeitado".
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A311LinOk(oModelNNT)
Rotina de linha Ok do modelo NNT

@author Flavio Lopes Rasta
@since 22/01/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311LinOk(oModelNNT)
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaNNT	:= NNT->(GetArea())
Local lRet		:= .T.
Local lFilTrf	:= SuperGetMv("MV_FILTRF",.F.,.F.)
Local lPermNegat:= SuperGetMV('MV_ESTNEG') == 'S'
Local lEmpPrev  := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local lRastroL	:= .F.
Local lRastroS	:= .F.
Local lLocalizO	:= .F.
Local lLocalizD	:= .F.
Local lSaldoSemR:= Nil
Local cFilBkp	:= cFilAnt
Local cHelp		:= ""
Local cCodNNT	:= oModelNNT:GetValue( 'NNT_COD' )
Local cProduto	:= oModelNNT:GetValue( 'NNT_PROD' )
Local cProdDes	:= oModelNNT:GetValue( 'NNT_PRODD')
Local cFilDest	:= oModelNNT:GetValue( 'NNT_FILDES' )
Local cFilOrig	:= oModelNNT:GetValue( 'NNT_FILORI' )
Local cArmazem	:= oModelNNT:GetValue( 'NNT_LOCAL' )
Local cArmDest	:= oModelNNT:GetValue( 'NNT_LOCLD' )
Local cLocaliza	:= oModelNNT:GetValue( 'NNT_LOCALI' )
Local cLocalDes	:= oModelNNT:GetValue( 'NNT_LOCDES' )
Local cNumSerie	:= oModelNNT:GetValue( 'NNT_NSERIE' )
Local cLoteCtl	:= oModelNNT:GetValue( 'NNT_LOTECT' )
Local cLote		:= oModelNNT:GetValue( 'NNT_NUMLOT' )
Local nQuant	:= oModelNNT:GetValue( 'NNT_QUANT' )
Local cLoteD    := oModelNNT:GetValue( 'NNT_LOTED' )
LOCAL dDataDest	:= oModelNNT:GetValue( 'NNT_DTVALD')
Local cCGCDest	:= A311FilCGC(cFilDest)
Local cCGCOri	:= A311FilCGC(cFilOrig)
Local nQtdTotal	:= A311SomaGrid(oModelNNT)
Local nQtdEst	:= 0
Local nQtdNumLt	:= TamSx3("B8_NUMLOTE")[1]
Local oModel	:= FWModelActive()
Local oModelNNS	:= oModel:GetModel('NNSMASTER') 
Local dDataEmis	:= oModelNNS:GetValue("NNS_DATA")
Local cSA1TMP	:= GetNextAlias()
Local cQryNNT   := ""
Local aSaveLines:= FWSaveRows()
Local lEfetiva	:= IsInCallStack('A311Efetiv')
Local lAltera	:= (oModel:GetOperation() == MODEL_OPERATION_UPDATE )
Local lAuto311	:= Type("cOpId311") == "C" .And. cOpId311 == OP_EFE .And. !(Empty(oModelNNT:GetValue('NNT_SERIE')))
Local nQtdOrig	:= 0
Local lEstoque  := .T.
Local l311ExeFil:= Len(a311Filial) > 0
Local cTes 		:= oModelNNT:GetValue( 'NNT_TS' )
Local lMrpME 	:= IsInCallStack("a107criNNT") .Or. oModelNNT:GetValue("V_EXEC_MRP") == "1"
Local cGrEmp	:= FWGrpCompany()
Local aSM0 		:= FWLoadSM0(.T., .T.)
Local cMVTRFVLDP:= SuperGetMV("MV_TRFVLDP",.F.,"1")	//-- 1: códigos iguais; 2: SA5; 3: Não valida
//Posicao 01: Empresa Ex( T1 )
//Posicao 02: Filial  Ex( D MG 01 )
//Posicao 11: Perm. Acesso .T. / .F. Ex( .F. )

If l311ExeFil .And. !(cFilDest $ a311Filial[1])
	cMsg := STR0041 + AllTrim( UsrFullName( __cUserID ) ) + STR0042 + AllTrim( cFilDest ) + STR0043
	Help(" ",1,"A310PERMFIL", Nil, cMsg, 1, 0 )
	lRet := .F.
ElseIf !l311ExeFil .And. Ascan( aSM0, { | x | AllTrim( x[ 01 ] ) == AllTrim( cGrEmp ) .And. AllTrim( x[ 02 ] ) == AllTrim( cFilDest ) .And. !( x[ 11 ] ) } ) > 0
	cMsg := STR0041 + AllTrim( UsrFullName( __cUserID ) ) + STR0042 + AllTrim( cFilDest ) + STR0043
	Help(" ",1,"A310PERMFIL", Nil, cMsg, 1, 0 )
	lRet := .F.
EndIf

/*
Quando é executado através do MRP Multi-Empresa, não realiza as validações.
As validações e possiveis ajustes deveram ser realizados no momento da efetivação da transferência.
*/
If ( lRet )
	If !IsInCallStack("A311FillGrd") .And. !lMrpME
		If Empty(nQuant) .Or. Empty(cArmDest)
			Help(" ",1,"OBRIGAT2")
			lRet := .F.
		EndIf
		If lRet
			lRet := A311Igual()
		EndIf 
		If lRet
			lRastroL  := Rastro(cProduto,'L')
			lRastroS  := Rastro(cProduto,'S')
			lLocalizO := Localiza(cProduto)
			A311TrcFil( cFilDest )
			lLocalizD := Localiza(cProdDes)
			A311TrcFil( cFilBkp )
			If cFilDest # cFilOrig //Validações para transferência entre filiais
				//Validação Atualização de estoque
				If SF4->(!dbSeek(xFilial('SF4')+cTes))
					lEstoque := .F.
				else
					lEstoque := (SF4->F4_ESTOQUE == 'S')	
				EndIf
				If lFilTrf //Verifica se a filial destino é cliente da filial origem.
					BeginSQL Alias cSA1TMP
						SELECT Count(R_E_C_N_O_) FILTRF
						FROM %Table:SA1% SA1
						WHERE SA1.A1_FILIAL = %xFilial:SA1%
								AND SA1.A1_FILTRF = %exp:cFilDest% AND SA1.%NotDel%
					EndSql
					If !(cSA1TMP)->FILTRF > 0
						Help(" ",1,"A311FILIALDCLI")  //"A filial de destino não é cliente da filial de origem." # "Cadastre a filial destino como cliente na filial de origem.".
						lRet := .F.
					EndIf
					(cSA1TMP)->(dbCloseArea())
					If lRet //Verifica se a filial origem é fornecedor na filial destino
						A311TrcFil( cFilDest )
						BeginSQL Alias "SA2TMP"
							SELECT Count(R_E_C_N_O_) FILTRF
							FROM %table:SA2% SA2
							WHERE SA2.A2_FILIAL = %xFilial:SA2%
									AND SA2.A2_FILTRF = %exp:cFilOrig% AND SA2.%NotDel%
						EndSql
						If !SA2TMP->FILTRF > 0
							Help(" ",1,"A311FILIALDFOR") //"A filial de destino não é fornecedor da filial de origem." # "Cadastre a filial destino como fornecedor na filial de origem.".
							lRet := .F.
						EndIf
						SA2TMP->(dbCloseArea())
						A311TrcFil( cFilBkp )
					Endif
					If lRet //Verifica se exite condição de pagamento para a filial destino
						BeginSQL Alias cSA1TMP
							SELECT A1_COND COND
							FROM %Table:SA1% SA1
							WHERE SA1.A1_FILIAL = %xFilial:SA1%
								AND SA1.A1_FILTRF = %exp:cFilDest% AND SA1.%NotDel%
						EndSql
						If Empty((cSA1TMP)->COND)	
							Help(" ",1,"A311FILIALDCON") //"Não existe condição de pagamento cadastrada para a filial destino no cadastro de clientes." # "Cadastre uma condição de pagamento para a filial destino.".
							lRet := .F.
						Endif
						(cSA1TMP)->(dbCloseArea())
					Endif
				Else
					SA1->(DbSetOrder(3))
					If !(SA1->(DbSeek(xFilial('SA1')+cCGCDest)))
						Help(" ",1,"A311FILIALDCLI")  //"A filial de destino não é cliente da filial de origem." # "Cadastre a filial destino como cliente na filial de origem.".
						lRet := .F.
					EndIf
					If lRet
						A311TrcFil( cFilDest )
						SA2->(DbSetOrder(3))
						If !(SA2->(DbSeek(xFilial('SA2')+cCGCOri)))
							Help(" ",1,"A311FILIALDFOR") //"A filial de destino não é fornecedor da filial de origem." # "Cadastre a filial destino como fornecedor na filial de origem.".
							lRet := .F.
						EndIf
						A311TrcFil( cFilBkp )
					EndIf
					If lRet //Verifica se exite condição de pagamento para a filial destino
						SA1->(DbSetOrder(3))
						If SA1->(DbSeek(xFilial('SA1')+cCGCDest))
							If Empty(SA1->A1_COND)
								Help(" ",1,"A311FILIALDCON") //"Não existe condição de pagamento cadastrada para a filial destino no cadastro de clientes." # "Cadastre uma condição de pagamento para a filial destino.".
								lRet := .F.
							Endif
						Endif
					Endif
				Endif
				If lRet .And. findFunction('A310VldPrd') .And. !A310VldPrd(cFilOrig,cProduto,cFilDest,cProdDes)
					If cMVTRFVLDP == '2'
						Help( ,, 'A311PRODUT',, STR0045 , 1, 0 ) //'Produto destino necessita de amarração produto x fornecedor (Origem)'
					Else 
						Help( ,, 'A311PRODUT',, STR0044 , 1, 0 ) //'Nao e permitido realizar transferencia entre Filiais com Produtos Diferentes'
					Endif 
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If lRet .And. lEstoque
			If !lPermNegat .And. ;
				(!(lRastroL .Or. lRastroS) .And. ;
				(!lLocalizO .And. !lLocalizD) .Or. IntDL(cProduto))
				//Verifica se deve subtrair a reserva do saldo disponivel.
				If IntDL(cProduto) .And. lLocalizO .And. cProduto==cProdDes .And. cArmazem==cArmDest .And. cLocaliza#cLocalDes
					lSaldoSemR := .F.
				EndIf
				dbSelectArea("SB2")
				If SB2->(dbSeek(xFilial('SB2')+cProduto+cArmazem))
					nQtdEst := SaldoMov(Nil,.F.,Nil,Nil,Nil,Nil, lSaldoSemR, dDataEmis) // deve sempre considerar o saldo disponivel (desconsiderando o empenho)
				EndIf
				If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
					If (nQtdEst <= 0) .OR. QtdComp(nQtdEst) < QtdComp(nQtdTotal) // se houver saldo e não atende a demanda. Deve bloquear  
						lRet := .F.
						cHelp:= "MA311NEGAT" //Não existe quantidade suficiente em estoque para atender esta requisição.
					EndIf
				EndIf
			ElseIf lLocalizO
				If !Empty(cLocaliza+cNumSerie)
					nQtdEst := SBE->(SaldoSBF(cArmazem,cLocaliza,cProduto,cNumSerie,cLoteCtl,cLote))
					
					If (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. lAltera)
						If lAltera .Or. ( lEfetiva .Or. lAuto311 )
							//NNT_FILIAL+NNT_COD+NNT_FILORI+NNT_PROD+NNT_LOCAL+NNT_LOCALI+NNT_NSERIE+NNT_LOTECT+NNT_NUMLOT+NNT_FILDES+NNT_PRODD+NNT_LOCLD+NNT_LOCDES+NNT_LOTED
							cQryNNT := " Select Sum(NNT_QUANT) QUANT "
							cQryNNT += " From "+RetSqlName('NNT')+" "
							cQryNNT += " Where NNT_FILIAL = '"+FWXFilial('NNT')+"' "
							cQryNNT += "   And NNT_COD    = '"+cCodNNT+"' "
							cQryNNT += "   And NNT_FILORI = '"+cFilOrig+"' "
							cQryNNT += "   And NNT_PROD   = '"+cProduto+"' "
							cQryNNT += "   And NNT_LOCAL  = '"+cArmazem+"' "
							cQryNNT += "   And NNT_LOCALI = '"+cLocaliza+"' "
							cQryNNT += "   And NNT_NSERIE = '"+cNumSerie+"' "
							cQryNNT += "   And NNT_LOTECT = '"+cLoteCtl+"' "
							cQryNNT += "   And NNT_NUMLOT = '"+cLote+"' "
							cQryNNT += "   And D_E_L_E_T_ = ' ' "
							cQryNNT := ChangeQuery(cQryNNT)

							nQtdOrig := 0
							nQtdOrig := MpSysExecScalar(cQryNNT, "QUANT")
								
							If (nQtdEst+nQtdOrig-nQtdTotal < 0) // se houver saldo e não atende a demanda. Deve bloquear  
								lRet := .F.
								cHelp:= "SALDOLOCLZ" //O produto  não  tem  saldo  Enderecado suficiente ou o Endereço selecionado não tem saldo suficiente.
							EndIf
						Else
							If (nQtdEst <= 0) .OR. QtdComp(nQtdEst) < QtdComp(nQtdTotal) // se houver saldo e não atende a demanda. Deve bloquear  
								lRet := .F.
								cHelp:= "SALDOLOCLZ" //O produto  não  tem  saldo  Enderecado suficiente ou o Endereço selecionado não tem saldo suficiente.
							EndIf
						EndIf
					EndIf
				Else
					cHelp:= "LOCALIZOBR" //Quando  o  produto  utiliza  controle de Endereço,  deve   ter   preenchido  no movimento  o  campo Endereço, Número de Série ou os dois.
					lRet:= .F.
				EndIf
			ElseIf lRastroL .Or. lRastroS
				If lRastroL
					If !Empty(cLoteCtl)
						dbSelectArea("SB8")
						SB8->(dbSetOrder(2))
						SB8->(dbSeek(xFilial('SB8')+If(lRastroS,cLote,Space(6))+cLoteCtl+cProduto+cArmazem))
						nQtdEst:= SaldoLote(cProduto,cArmazem,cLoteCtl,Nil,Nil,Nil,Nil,dDataBase,,.T.)
						If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
							If (nQtdEst <= 0) .OR. QtdComp(nQtdEst) < QtdComp(nQtdTotal) // se houver saldo e não atende a demanda. Deve bloquear  
								lRet := .F.
								cHelp:= "MA311NEGAT" //Não existe quantidade suficiente em estoque para atender esta requisição.
							EndIf
						EndIf
					Else
						cHelp:= "LOTECTOBR" //Quando  o  produto  utiliza  controle de Rastro,  deve   ter   preenchido  no movimento  o  campo Lote do produto.
						lRet:= .F.
					EndIf
					If lRet
						dbSelectArea("SB8")
						SB8->(dbSetOrder(2))
						SB8->(dbSeek(xFilial('SB8')+Space(nQtdNumLt)+cLoteD+cProdDes+cArmDest))
						If !Empty(dDataDest) .And. !Empty(SB8->B8_DTVALID) .And. (dDataDest # SB8->B8_DTVALID)
							If	!lAuto311
								Aviso(STR0039,STR0038,{STR0040},3)//A240DTVALDEST//'A Data de validade do lote devera ser igual a data informada no momento da criação do lote'//OK 
							EndIf
							oModelNNT:SetValue("NNT_DTVALD",SB8->B8_DTVALID)
						EndIf
					EndIf
				ElseIf lRastroS
					If !Empty(cLoteCtl) .And. !Empty(cLote)
						dbSelectArea("SB8")
						SB8->(dbSetOrder(2))
						SB8->(dbSeek(xFilial('SB8')+If(lRastroS,cLote,Space(6))+cLoteCtl+cProduto+cArmazem))
						nQtdEst:= SB8Saldo( IIf( INCLUI, .F., .T. ), .T., Nil, Nil, Nil, lEmpPrev, Nil, dDataBase )
						If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
							If (nQtdEst <= 0) .OR. QtdComp(nQtdEst) < QtdComp(nQtdTotal) // se houver saldo e não atende a demanda. Deve bloquear  
								lRet := .F.
								cHelp:= "MA311NEGAT" //Não existe quantidade suficiente em estoque para atender esta requisição.
							EndIf
						EndIf
					Else
						cHelp:= "NUMLOTOBR" //Quando  o  produto  utiliza  controle de Rastro por SubLote,  deve   ter   preenchido  no movimento  o  campo Lote e Sub Lote.
						lRet:= .F.
					EndIf
				EndIf
			EndIf

			If ( (lRastroL .Or. lRastroS) .Or. lLocalizO) .Or. !lPermNegat
				If !lRet .And. !Empty(cHelp)
					Help(" ",1,cHelp) //Exibe help em caso do saldo menor que a quantidade transferida.
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		If lRet .And. lLocalizD
			A311TrcFil( cFilDest )
			If SBE->(dbSeek(xFilial('SBE')+cArmDest+cLocalDes))
				If SBE->(!Eof()) .And. QtdComp(SBE->BE_CAPACID) > QtdComp(0) .And. ( QtdComp(SBE->BE_CAPACID) < QtdComp( nQuant + QuantSBF(cArmDest, cLocalDes) ) )
					Help(' ',1,'MA311CAPAC') // A capacidade do Endereço não comporta a quantidade Enderecada.
					lRet := .F.
				EndIf
			EndIf
			A311TrcFil( cFilBkp )
		Endif
	EndIf
EndIf

RestArea( aAreaSB1 )
RestArea( aAreaSB2 )
RestArea( aAreaSA1 )
RestArea( aAreaNNT )
FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MAT311PVld(oModel)
Rotina de Pós validação do modelo (TudoOk)

@author Flavio Lopes Rasta
@since 22/01/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function MAT311PVld(oModel)
Local oModelNNT := oModel:GetModel('NNTDETAIL')
Local lRet		:= .T.
Local nX		:= 0
Local aFilDes	:= {}

For nX := 1 To oModelNNT:Length()
	oModelNNT:GoLine( nX )
	If !oModelNNT:IsDeleted()
		If cFilAnt # oModelNNT:GetValue( 'NNT_FILDES' )
			Aadd(aFilDes,oModelNNT:GetValue( 'NNT_FILDES' ))
			//Verifica se os campos NNT_TS e NNT_TE foram preenchidos
			If Empty(oModelNNT:GetValue( 'NNT_TS' ))
				Help(" ",1,"A311FILIALOTES") //"O campo NNT_TS não foi preenchido." # "Preencha o campo com o código da TES de saida.".
				lRet := .F.
			Endif
			If lRet
				If Empty(oModelNNT:GetValue( 'NNT_TE' ))
					Help(" ",1,"A311FILIALDTES") //"O campo NNT_TE não foi preenchido." # "Preencha o campo com o código da TES de entrada.".
					lRet := .F.
				Endif
			Endif
		EndIf
		If lRet
			lRet := A311LinOk(oModelNNT)//Chamada do pos-valid do model NNT para garantir saldos
		Else
			Exit
		Endif
	Endif
Next nX

//Verifica se existe bloqueio pelo calendário contábil ou pelo parâmetro MV_ATFBLQM
If lRet .And. Len(aFilDes) > 0
	lRet := Mat311BlqM(aFilDes)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MAT311Grv(oModel)
Rotina de gravação dos dados

@author Flavio Lopes Rasta
@since 22/01/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function MAT311Grv(oModel)
Local oModelNNS	:= oModel:GetModel( 'NNSMASTER' )
Local oModelNNT	:= oModel:GetModel( 'NNTDETAIL' )
Local lOk		:= .F.
Local lBloqST	:= SuperGetMv("MV_APROVTR",.F.,.F.)
Local cStatus	:= oModelNNS:GetValue("NNS_STATUS")
Local lAuto311	:= Type("cOpId311") == "C" .And. !(Empty(oModelNNT:GetValue('NNT_SERIE')))

Private l311GerPed := .F.
Private a311Bloq   := {}

Do Case
	Case oModel:GetOperation() == MODEL_OPERATION_INSERT //Gera empenho para os produtos
		MsgRun(STR0029,STR0030,{||lOk := A311Emp(oModel) })	// 'Aguarde, processando empenhos...','Empenhos de Produtos'
	Case oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If IsInCallStack('A311Efetiv') .Or. (Type("cOpId311") == "C" .and. cOpId311 == OP_EFE) //Efetivação da transferencia
			//Libera modelo para alteração
			oModelNNT:SetNoUpdateLine(.F.)
			If lAuto311
				lOk := A311Transf(oModel)
			Else
				MsgRun(STR0031,STR0032,{||lOk := A311Transf(oModel) })	// 'Aguarde, processando transferência...','Transferência'
			EndIf
			If lOk .And. !l311GerPed
				oModelNNS:LoadValue('NNS_STATUS','2')//Transferido
			Elseif l311GerPed
				oModelNNS:LoadValue('NNS_STATUS','5')//Efetivado com PV Bloqueado
			Endif
			//Bloqueia novamente o modelo
			oModelNNT:SetNoUpdateLine(.T.)
		ElseIf IsInCallStack('A311Altera') .Or. (Type("cOpId311") == "C" .and. cOpId311 == OP_ALT)
			lOk := A311GrAlt(oModel)
		Endif
	Case oModel:GetOperation()== MODEL_OPERATION_DELETE
		lOk := A311Estor(oModelNNT:GetValue('NNT_COD'))
		//Exclusão da tabela SCR
		If lBloqST
			DbSelectArea("SCR")
			SCR->(DbSetOrder(1))
			cCodTransf :=  oModelNNS:GetValue("NNS_COD")
			If SCR->(DbSeek(  xFilial("SCR")+ "ST" + cCodTransf ))
				//Exclusão
				If cStatus == '1'
					MaAlcDoc({ cCodTransf , "ST" ,,,,},,3,,,,,.T.)
				ElseIf cStatus == '4'
					MaAlcDoc({ cCodTransf , "ST" ,,,,},,3,,,,,.F.)
				EndIf
			EndIf
		EndIf
EndCase

If lOk
	FWFormCommit( oModel )
Else
	If IsInCallStack('A311Efetiv')
		oModel:SetErrorMessage('MATA311', 'NNTDETAIL', 'MATA311', 'NNTDETAIL',,STR0047)
	EndIf
EndIf

FreeUsedCode(.T.)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} A311Emp()
Atualiza empenhos ou previsões de entrada para todos os produtos

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311Emp(oModel)
Local oModelNNT	:= oModel:GetModel( 'NNTDETAIL' )
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSB8	:= SB8->(GetArea())
Local aAreaSBF	:= SBF->(GetArea())

Local cProd		:= ""
Local cFilDest	:= ""

Local cAmzOri	:= ""
Local cAmzDest	:= ""
Local cLote		:= ""
Local cSubLote	:= ""
Local cNumSerie	:= ""
Local cEndereco	:= ""

Local nQuant	:= 0
Local nQuant2	:= 0
Local nX		:= 0

Local lRet		:= .T.

For nX := 1 To oModelNNT:Length()
	oModelNNT:GoLine( nX )
	If !oModelNNT:IsDeleted()
		cProd		:= oModelNNT:GetValue( 'NNT_PROD' )
		cAmzOri		:= oModelNNT:GetValue( 'NNT_LOCAL' )
		cAmzDest	:= oModelNNT:GetValue( 'NNT_LOCLD' )
		cEndereco	:= oModelNNT:GetValue( 'NNT_LOCALI' )
		cLote		:= oModelNNT:GetValue( 'NNT_LOTECT' )
		cSubLote	:= oModelNNT:GetValue( 'NNT_NUMLOT' )
		cNumSerie	:= oModelNNT:GetValue( 'NNT_NSERIE' )
		nQuant		:= oModelNNT:GetValue( 'NNT_QUANT' )
		nQuant2		:= oModelNNT:GetValue( 'NNT_QTSEG' )
		cFilDest	:= oModelNNT:GetValue( 'NNT_FILDES' )

		SB1->( dbSetorder(1) )
		If SB1->( DbSeek(xFilial('SB1')+cProd ) )
			If Localiza(cProd)
				//Gera ou estorna empenho do produto por endereço
				//BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
				SBF->( DbSetOrder(1) )
				If SBF->( DbSeek(xFilial('SBF')+cAmzOri+cEndereco+cProd+cNumSerie+cLote+cSubLote) )
					GravaBFEmp("+",nQuant,"F",,nQuant2)
				Endif
			EndIf
			If Rastro(cProd)
				//Gera ou estorna empenho do produto por lote ou sub-lote
				SB8->( DbSetOrder(3) )
				If SB8->( DbSeek(xFilial('SB8')+cProd+cAmzOri+cLote+cSubLote) )
					GravaB8Emp("+",nQuant,"F",NIL,nQuant2)
				Endif
			EndIf
			//Gera ou estorna do produto por armazém
			SB2->( DbSetOrder(1) )
			If SB2->( DbSeek(xFilial('SB2')+cProd+cAmzOri) )
				GravaB2Emp("+",nQuant,"F",NIL,nQuant2)
			Endif
			//Gera previsão de Entrada na Filial de Destino
			SB2->( DbSetOrder(1) )
			If SB2->( DbSeek(xFilial("SB2",cFilDest)+cProd+cAmzDest) )
				GravaB2Pre('+',nQuant,"F",nQuant2)
			Endif
		Endif
	EndIf
Next nX

If IsInCallStack("A311Altera")
	A311GrvAlc(oModel,.T.)
Else
	A311GrvAlc(oModel,.F.)
EndIf

RestArea( aAreaSBF )
RestArea( aAreaSB8 )
RestArea( aAreaSB2 )
RestArea( aAreaSB1 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311GrAlt()
Atualiza empenhos e previsões de entrada
@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311GrAlt(oModel)
Local oModelNNS	:= oModel:GetModel('NNSMASTER')
Local oModelNNT	:= oModel:GetModel('NNTDETAIL')
Local nX := 0

For nX := 1 To oModelNNT:Length()
	oModelNNT:GoLine(nX)
	If oModelNNT:IsUpdated() .Or. oModelNNT:IsDeleted() .Or. oModelNNT:IsInserted()
		A311Estor(oModelNNS:GetValue('NNS_COD'))
		A311Emp(oModel)
		Exit
	EndIf
Next nX

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} A311Estor()
Atualiza empenhos ou previsões de entrada para todos os produtos

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311Estor(cCod)

Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSB8	:= SB8->(GetArea())
Local aAreaSBF	:= SBF->(GetArea())
Local aAreaNNT	:= NNT->(GetArea())

Local cProd		:= ""
Local cFilDest	:= ""

Local cAmzOri	:= ""
Local cAmzDest	:= ""
Local cLote		:= ""
Local cSubLote	:= ""
Local cNumSerie	:= ""
Local cEndereco	:= ""

Local nQuant	:= 0
Local nQuant2	:= 0

Local lRet		:= .T.

NNT->( dbSetOrder(1) )
NNT->( dBSeek(xFilial('NNT')+cCod) )

While !( NNT->( EOF() ) ) .And. NNT->NNT_COD == cCod
	cProd		:= NNT->NNT_PROD
	cAmzOri		:= NNT->NNT_LOCAL
	cAmzDest	:= NNT->NNT_LOCLD
	cEndereco	:= NNT->NNT_LOCALI
	cLote		:= NNT->NNT_LOTECT
	cSubLote	:= NNT->NNT_NUMLOT
	cNumSerie	:= NNT->NNT_NSERIE
	nQuant		:= NNT->NNT_QUANT
	nQuant2		:= NNT->NNT_QTSEG
	cFilDest	:= NNT->NNT_FILDES

	SB1->( dbSetorder(1) )
	If SB1->( DbSeek(xFilial('SB1')+cProd ) )
		If Localiza(cProd)
			//Gera ou estorna empenho do produto por endereço
			SBF->( DbSetOrder(1) )
			If SBF->( DbSeek(xFilial('SBF')+cAmzOri+cEndereco+cProd+cNumSerie+cLote+cSubLote) )
				GravaBFEmp("-",nQuant,"F",,nQuant2)
			Endif
		EndIf
		If Rastro(cProd)
			//Gera ou estorna empenho do produto por lote ou sub-lote
			SB8->( DbSetOrder(3) )
			If SB8->( DbSeek(xFilial('SB8')+cProd+cAmzOri+cLote+cSubLote) )
				GravaB8Emp("-",nQuant,"F",NIL,nQuant2)
			Endif
		EndIf
		//Gera ou estorna do produto por armazém
		SB2->( DbSetOrder(1) )
		If SB2->( DbSeek(xFilial('SB2')+cProd+cAmzOri) )
			GravaB2Emp("-",nQuant,"F",NIL,nQuant2)
		Endif
		//Gera previsão de Entrada na Filial de Destino
		SB2->( DbSetOrder(1) )
		If SB2->( DbSeek(xFilial("SB2",cFilDest)+cProd+cAmzDest) )
			GravaB2Pre('-',nQuant,"F",nQuant2)
		Endif
	Endif
	NNT->(DbSkip())
EndDo

RestArea( aAreaNNT )
RestArea( aAreaSBF )
RestArea( aAreaSB8 )
RestArea( aAreaSB2 )
RestArea( aAreaSB1 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311Transf(oModel)
Executa a transferência dos materiais

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311Transf(oModel)
Local oModelNNS	:= oModel:GetModel('NNSMASTER')
Local oModelNNT	:= oModel:GetModel('NNTDETAIL')
Local aDadosA	:= {}
Local aDadosF	:= {}
Local aSeries	:= {}
Local aNotas	:= {}
Local aParam310	:= Array(30)
Local aRet		:= {}
Local lRet		:= .T.
Local lTrAmz	:= .F.
Local lTrFil	:= .F.
Local lAuto311	:= Type("cOpId311") == "C" .And. cOpId311 == OP_EFE .And. !(Empty(oModelNNT:GetValue('NNT_SERIE')))
Local nX		:= 0
Local nTpCusto	:= Val(SuperGetMV("MV_TPCUSST",.F.))
Local cSerie 	:= ""
Local cFilBkp	:= cFilAnt
Local cEspecie	:= Nil
Local cTpNrFfs	:= SuperGetMV("MV_TPNRNFS")


Private cNumero	:= ""

//Verifica se existem materiais a serem transferidos na mesma filial
If A311QtdTrs(oModelNNT,1) > 0
	lTrAmz	:= .T.
	//Obtem array para chamada da rotina automática
	aDadosA := A311ArrAmz(oModel)
Endif

//Verifica se existem materiais a serem transferidos para outra filial
If A311QtdTrs(oModelNNT,2) > 0
	lTrFil	:= .T.
	//Obtem array para chamada da rotina automática
	aDadosF := A311ArrFil(oModel)
	//Gera séries para as notas
	For nx :=1 to Len(aDadosF)
		If nx == 1 .Or. (aDadosF[nx,1] # aDadosF[nx-1,1])
			// Obtem serie para as notas desta filial
			cSerie  := ""
			cNumero := ""
			If lAuto311
				cSerie := oModelNNT:GetValue('NNT_SERIE')
				cNumero := "000001"
				cNumero := Ma461NumNf(Nil,cSerie,cNumero) //lFirst,cSerie,cNumNFs,lECF,cSerieId
			Else	
				Sx5NumNota(@cSerie,cTpNrFfs,cFilAnt) //cSerNF,cTpNrNfs,cFilTela,cTab,cAliTp,cSerieId,dDEmissao
			EndIf
			// Caso tenha selecionado numero
			If Empty(cNumero)
				// A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
				Help(" ",1,"A310SERERR",,cFilAnt,1,10)
				lRet :=.F.
				Exit
			Else
				AADD(aSeries,{cFilAnt,cSerie,cNumero})
			EndIf
		EndIf
	Next nx
Endif

If lRet
	Begin Transaction

		//Estorna os Empenhos antes de realizar a transferência
		A311Estor(oModelNNS:GetValue('NNS_COD'))

		If lTrAmz
			//Executa rotina automática da MATA261
			aRet := A311MT261(aDadosA)
			lRet := aRet[1]
			
			If lRet
				//Grava número do documento nos registros transferidos
				lRet := A311GrvDoc(oModel,1,aDadosA[1])
				If !lRet
					DisarmTransaction()
					lRet := .F.
				Endif
			Else
				oModel:SetErrorMessage('MATA311', 'NNSMASTER', 'MATA311', 'NNSMASTER', /*'A261TOK'*/, aRet[2], , /*[ xValue ]*/, /*[ xOldValue ]*/)
				DisarmTransaction()
				lRet := .F.
			Endif
		Endif
		If lRet
			If lTrFil
				// Preenche parâmetros necessários
				aParam310[14] := Val(oModelNNS:Getvalue('NNS_CLASS'))
				aParam310[17] := nTpCusto
				aParam310[19] := 2 //Poder de Terceiro
				aParam310[20] := 'NF'
				If lAuto311
					aParam310[16] := SA1->A1_COND
				EndIf

				If NNS->(ColumnPos("NNS_ESPECI")) > 0
					cEspecie := oModelNNS:Getvalue("NNS_ESPECI")
					If (! Empty(cEspecie)) .And. SX5->(dbSeek(xFilial("SX5") + "42" + cEspecie))
						aParam310[20] := cEspecie
					Endif
				Endif

				//Executa rotina automática
				lRet := A310Proc(aDadosF,aParam310,aSeries,@aNotas)
				If lRet
					If !l311GerPed
						lRet := A311GrvDoc(oModel,2,aNotas)
					Elseif l311GerPed
						lRet := A311GrvPed(oModel,a311Bloq)
					EndIf
					If !lRet
						DisarmTransaction()
						lRet := .F.
					Endif
				Else
					DisarmTransaction()
					lRet := .F.
				Endif
				oModel:Activate()
			Endif
		Endif
	End Transaction
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A311ArrAmz(oModel)
Retorna o array de transfência de produtos entre armazéns

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311ArrAmz(oModel)
Local oModelNNT	:= oModel:GetModel('NNTDETAIL')
Local aDadosA  	:= {}
Local nX		:= 0
Local nQtd		:= A311QtdTrs(oModelNNT,1)
Local nTamDescr := 0
Local cDoc		:= ''
Local cMay		:= ''
Local lFirstNum := .T.
Local aAreaNNT := GetArea()

If nQtd > 0

	nTamDescr 	:= TamSx3("D3_DESCRI")[1]
	cDoc	  	:= A261RetINV(NextNumero("SD3",2,"D3_DOC",.T.))
	cMay 		:= "SD3"+Alltrim(xFilial())+cDoc

	dbSelectArea('SD3')
	dbSetOrder(2)
	dbSeek(xFilial()+cDoc)

	While D3_FILIAL+D3_DOC==xFilial()+cDoc.Or.!MayIUseCode(cMay)
		If D3_ESTORNO # "S"
			If lFirstNum
				cDoc	 	:= A261RetINV(NextNumero("SD3",2,"D3_DOC",.T.))
				lFirstNum 	:= .F.
			Else
				cDoc := Soma1(cDoc)
			EndIf
			cMay := "SD3"+Alltrim(xFilial())+cDoc
		EndIf
		dbSkip()
	EndDo

	SD3->(dbCloseArea())
	RestArea(aAreaNNT)

	aAdd(aDadosA, {cDoc,dDataBase})
	For nX := 1  To oModelNNT:Length()
		oModelNNT:GoLine(nX)
		If oModelNNT:GetValue('NNT_FILORI') == oModelNNT:GetValue('NNT_FILDES')
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial('SB1')+oModelNNT:GetValue('NNT_PROD')))
			aAdd(aDadosA,{})
			aAdd(aDadosA[Len(aDadosA)],{"D3_COD" 		, SB1->B1_COD								,NIL})// 01.Produto Origem
			aAdd(aDadosA[Len(aDadosA)],{"D3_DESCRI" 	, Left(SB1->B1_DESC,nTamDescr)			,NIL})// 02.Descricao
			aAdd(aDadosA[Len(aDadosA)],{"D3_UM"     	, SB1->B1_UM								,NIL})// 03.Unidade de Medida
			aAdd(aDadosA[Len(aDadosA)],{"D3_LOCAL"  	, oModelNNT:GetValue('NNT_LOCAL')			,NIL})// 04.Armazem Origem
			aAdd(aDadosA[Len(aDadosA)],{"D3_LOCALIZ"	, oModelNNT:GetValue('NNT_LOCALI')			,NIL})// 05.Endereco Origem
			aAdd(aDadosA[Len(aDadosA)],{"D3_COD"    	, oModelNNT:GetValue('NNT_PRODD')			,NIL})// 06.Produto Destino
			aAdd(aDadosA[Len(aDadosA)],{"D3_DESCRI" 	, Left(SB1->B1_DESC,nTamDescr)			,NIL})// 07.Descricao
			aAdd(aDadosA[Len(aDadosA)],{"D3_UM"     	, oModelNNT:GetValue('NNT_UMD')				,NIL})// 08.Unidade de Medida
			aAdd(aDadosA[Len(aDadosA)],{"D3_LOCAL"  	, oModelNNT:GetValue('NNT_LOCLD')			,NIL})// 09.Armazem Destino
			aAdd(aDadosA[Len(aDadosA)],{"D3_LOCALIZ"	, oModelNNT:GetValue('NNT_LOCDES')			,NIL})// 10.Endereco Destino
			aAdd(aDadosA[Len(aDadosA)],{"D3_NUMSERI"	, oModelNNT:GetValue('NNT_NSERIE')			,NIL})// 11.Numero de Serie
			aAdd(aDadosA[Len(aDadosA)],{"D3_LOTECTL"	, oModelNNT:GetValue('NNT_LOTECT')			,NIL})// 12.Lote Origem
			aAdd(aDadosA[Len(aDadosA)],{"D3_NUMLOTE"	, oModelNNT:GetValue('NNT_NUMLOT')			,NIL})// 13.Sub-Lote
			aAdd(aDadosA[Len(aDadosA)],{"D3_DTVALID"	, oModelNNT:GetValue('NNT_DTVALI')			,NIL})// 14.Data de Validade
			aAdd(aDadosA[Len(aDadosA)],{"D3_POTENCI"	, oModelNNT:GetValue('NNT_POTENC')			,NIL})// 15.Potencia do Lote
			aAdd(aDadosA[Len(aDadosA)],{"D3_QUANT"  	, oModelNNT:GetValue('NNT_QUANT')			,NIL})// 16.Quantidade
			aAdd(aDadosA[Len(aDadosA)],{"D3_QTSEGUM"	, oModelNNT:GetValue('NNT_QTSEG')			,NIL})// 17.Quantidade na 2 UM
			aAdd(aDadosA[Len(aDadosA)],{"D3_ESTORNO"	, ''											,NIL})// 18.Estorno
			aAdd(aDadosA[Len(aDadosA)],{"D3_NUMSEQ" 	, ''											,NIL})// 19.NumSeq
			If !Empty(oModelNNT:GetValue('NNT_LOTED'))
				aAdd(aDadosA[Len(aDadosA)],{"D3_LOTECTL"	, oModelNNT:GetValue('NNT_LOTED')			,NIL})// 20.Lote Destino
				aAdd(aDadosA[Len(aDadosA)],{"D3_DTVALID"	, oModelNNT:GetValue('NNT_DTVALD')			,NIL})// 21.Data de Validade Destino
			Else
				aAdd(aDadosA[Len(aDadosA)],{"D3_LOTECTL"	, oModelNNT:GetValue('NNT_LOTECT')			,NIL})// 20.Lote Destino
				aAdd(aDadosA[Len(aDadosA)],{"D3_DTVALID"	, oModelNNT:GetValue('NNT_DTVALI')			,NIL})// 21.Data de Validade Destino
			EndIf

		Endif
	Next nX
Else
	aDadosA := {}
Endif

Return aDadosA

//-------------------------------------------------------------------
/*/{Protheus.doc} A311ArrAmz(oModel,nOpc)
Retorna a quantidade de registros a transferir

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311QtdTrs(oModelNNT,nOpc)
Local nRet	:= 0
Local nX	:= 0

For nX := 1 To oModelNNT:Length()
	oModelNNT:GoLine(nX)
	If oModelNNT:GetValue('NNT_FILORI') == oModelNNT:GetValue('NNT_FILDES')
		If nOpc == 1 //Armazém
			nRet++
		Endif
	Else
		If nOpc == 2 //Filial
			nRet++
		Endif
	Endif
Next nX

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311ArrFil(oModel)
Retorna o array de transfência de produtos entre filiais

@author Flavio Lopes Rasta
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311ArrFil(oModel)
Local oModelNNT	:= oModel:GetModel('NNTDETAIL')
Local aDadosRet	:= {}
Local aDadosF	:= {}
Local aDados	:= {}
Local aUso		:= {}
Local cCgc		:= ""
Local cFilAtu	:= ""
Local cFilBkp	:= cFilAnt
Local nX		:= 0
Local nY		:= 0
Local lRet		:= .T.
Local lUsaFilTrf:= UsaFilTrf()

For nX := 1  To oModelNNT:Length()
	oModelNNT:GoLine(nX)
	If oModelNNT:GetValue('NNT_FILORI') # oModelNNT:GetValue('NNT_FILDES')
		aDados := {}
		// Array com dados para transferencia
		AADD(aDados, oModelNNT:GetValue('NNT_FILORI')	)	// [01] Filial  origem
		AADD(aDados, oModelNNT:GetValue('NNT_PROD')	)	// [02] Produto origem
		AADD(aDados, oModelNNT:GetValue('NNT_LOCAL')	)	// [03] Armazem origem
		AADD(aDados, oModelNNT:GetValue('NNT_QUANT')	)	// [04] Quantidade origem
		AADD(aDados, oModelNNT:GetValue('NNT_QTSEG')	)	// [05] Quantidade origem 2a UM
		AADD(aDados, oModelNNT:GetValue('NNT_FILDES')	)	// [06] Filial  destino
		AADD(aDados, oModelNNT:GetValue('NNT_LOCLD')	)	// [07] Armazem destino
		//Define se sera utilizado o metodo antigo de localizacao do cliente/
		//fornecedor (CNPJ) ou se utilizara o metodo novo, atraves dos campos
		//A1_FILTRF.
		If !lUsaFilTrf // procedimento padrao, localizar filial atraves do CNPJ do cliente
			cCgc := A311FilCGC(oModelNNT:GetValue('NNT_FILDES'))
			SA1->(dbSetOrder(3))
			SA1->(dbSeek(xFilial("SA1")+cCgc))
			AADD(aDados, SA1->A1_COD ) 						// [08] Cliente na Origem
			AADD(aDados, SA1->A1_LOJA )						// [09] Loja na Origem

			cCgc := A311FilCGC(oModelNNT:GetValue('NNT_FILORI'))
			SA2->(dbSetOrder(3))
			SA2->(dbSeek(xFilial("SA2",oModelNNT:GetValue('NNT_FILDES'))+cCgc))
			AADD(aDados, SA2->A2_COD ) 	  					// [10] Fornecedor no destino
			AADD(aDados, SA2->A2_LOJA	) 					// [11] Loja no destino
		Else //Metodo novo, atraves dos campos A1_FILTRF e A2_FILTRF.
			BeginSQL Alias "SA1TMP"
				SELECT A1_COD,A1_LOJA
				FROM %Table:SA1% SA1
				WHERE SA1.A1_FILIAL=%xFilial:SA1% AND SA1.A1_FILTRF=%Exp:oModelNNT:GetValue('NNT_FILDES')% AND SA1.%NotDel%
			EndSQL
			If !SA1TMP->(EOF())
				AADD(aDados, SA1TMP->A1_COD ) 				// [08] Cliente na Origem
				AADD(aDados, SA1TMP->A1_LOJA) 				// [09] Loja na Origem
			EndIf
			SA1TMP->(dbCloseArea())
			A311TrcFil( oModelNNT:GetValue('NNT_FILDES') ) //Simula troca de filial
			BeginSQL Alias "SA2TMP"
				SELECT A2_COD,A2_LOJA
				FROM %Table:SA2% SA2
				WHERE SA2.A2_FILIAL=%xFilial:SA2% AND SA2.A2_FILTRF=%Exp:oModelNNT:GetValue('NNT_FILORI')% AND SA2.%NotDel%
			EndSQL
			If !SA2TMP->(EOF())
				AADD(aDados, SA2TMP->A2_COD ) 	  			// [10] Fornecedor no destino
				AADD(aDados, SA2TMP->A2_LOJA	) 			// [11] Loja no destino
			EndIf
			A311TrcFil( cFilBkp ) //Retorna a filial origem
			SA2TMP->(dbCloseArea())
		EndIf
		AADD(aDados, ""	) 									// [12] Documento na origem
		AADD(aDados, ""	) 									// [13] Serie do documento na origem
		AADD(aDados, ""	) 									// [14] Identificados Poder 3
		AADD(aDados, ""	) 									// [15] Cliente/Fornecedor Poder 3
		AADD(aDados, ""	) 									// [16] Loja Poder 3
		AADD(aDados, oModelNNT:GetValue('NNT_LOTECT'))	// [17] Lote Origem
		AADD(aDados, oModelNNT:GetValue('NNT_NUMLOT'))	// [18] Sub-Lote Origem
		AADD(aDados, oModelNNT:GetValue('NNT_DTVALI'))	// [19] Data de Validade
		AADD(aDados, oModelNNT:GetValue('NNT_LOCALI'))	// [20] Endereço
		AADD(aDados, oModelNNT:GetValue('NNT_NSERIE'))	// [21] Numero de Serie
		AADD(aDados, "")								// [22] NUMSEQ do CQ
		AADD(aDados, oModelNNT:GetValue('NNT_TS'))		// [23] TES de Saída
		AADD(aDados, oModelNNT:GetValue('NNT_TE'))		// [24] TES de entrada
		AADD(aDados, oModelNNT:GetValue('NNT_PRODD'))	// [25] Produto destino
		AADD(aDados, oModelNNT:GetValue('NNT_LOTED'))		// [26] Lote Destino

		AADD(aDadosF, aDados)
	Endif
Next nX
//Aglutina dados por filial destino
For nX := 1 To Len(aDadosF)
	cFilAtu := aDadosF[nX,6]
	If !(aScan(aUso,{|x| x == cFilAtu}) > 0)
		For nY := 1 To Len(aDadosF)
			If aDadosF[nY,6] == cFilAtu
				AADD(aDadosRet,aDadosF[nY])
			Endif
		Next nY
		AADD(aUso,cFilAtu)
	Endif
Next nX
Return aDadosRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311ProdC()
Retorna o custo do produto.
@author Raphael Augustos
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311ProdC(oModel)
Local cProduto 	:= oModel:GetValue("NNT_PROD")
Local cArmazOri := oModel:GetValue("NNT_LOCAL")
Local cCusto	:= 0
Local cPrcVend	:= 0

SB1->(dbSetorder(1))
SB2->(DbSetOrder(1))
SBZ->(DbSetOrder(1))
SA1->(DbSetOrder(3))

If SA1->(DbSeek(xFilial('SA1')+SM0->M0_CGC))
	cPrcVend := MaTabPrVen(SA1->A1_TABELA,cProduto,1,SA1->A1_COD,SA1->A1_LOJA)
EndIf
Do Case
	Case SB2->(DbSeek( xFilial('SB2') + cProduto + cArmazOri )) .And. SB2->B2_CM1 > 0
		cCusto := SB2->B2_CM1 // Custo médio
	Case SB1->(DbSeek( xFilial("SB1") + cProduto )) .And. SB1->B1_CUSTD > 0
		cCusto := SB1->B1_CUSTD // Custo Standard
	Case SBZ->(DbSeek( xFilial("SBZ") + cProduto )) .And. SBZ->BZ_CUSTD > 0
		cCusto := SBZ->BZ_CUSTD // Custo Standard
	Case cPrcVend > 0
		cCusto := cPrcVend // Preço de venda
EndCase
If cCusto == 0
	Help("",1,"A311CUSTZERO",,STR0017,4,1)//"O custo do produto está zerado"
EndIf

Return cCusto

//-------------------------------------------------------------------
/*/{Protheus.doc} A311GrvAlc()
Envia Solicitação de Transferência para o controle de alçadas.
@author Raphael Augustos
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311GrvAlc(oModel,lAltera)
Local oModelNNS	:= oModel:GetModel( 'NNSMASTER' )
Local oModelNNT	:= oModel:GetModel( 'NNTDETAIL' )

Local cUsuario	:= ""
Local cGrupo	:= SuperGetMV("MV_STAPROV",.F.,"")
Local cCodTransf:= ""
Local cAreaSAL	:= GetNextAlias()

Local nQuantTot	:= 0
Local nX		:= 0

Local lBloqST	:= SuperGetMv("MV_APROVTR",.F.,.F.)

DEFAULT lAltera	:= .F. // Responsável por dizer se é alteração ou inclusão

//Lança a solicitação de transferência para o controle de alçadas.
If lBloqST
	cUsuario	:= RetCodUsr()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Usa grupo de aprovacao cadastrado no MV_STAPROV. Caso nao    ³
	//³ haja grupo definido, utiliza o tratamento anterior da rotina ³
	//³ para obtencao do grupo de aprovacao.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cGrupo)
		DbSelectArea("SAK")
		SAK->(DbSetOrder(2))

		If SAK->(DbSeek(xFilial("SAK")+cUsuario))

			BeginSQL Alias cAreaSAL
				SELECT AL_COD  GRUPO, AL_DOCST DOCST
				FROM %Table:SAL%
				WHERE 	AL_FILIAL = %xFilial:SAL% AND						
						AL_APROV = %Exp:SAK->AK_COD% AND
						%NotDel% 
			EndSQL

			cGrupo := (cAreaSAL)->GRUPO
			
			While (cAreaSAL)->(!Eof())
				If(cAreaSAL)->DOCST = 'T'
					cGrupo := (cAreaSAL)->GRUPO
					Exit
				Endif 	
				(cAreaSAL)->(dbSkip())
			EndDo	
			(cAreaSAL)->(DbCloseArea())
		EndIf
	EndIf

	If !Empty(cGrupo)
		For nX := 1 To oModelNNT:Length()
			oModelNNT:GoLine( nX )
			If !oModelNNT:IsDeleted()
				nQuantTot += oModelNNT:GetValue("NNT_QUANT")* A311CUSTD()
			Endif
		Next nX

		If nQuantTot > 0
			DbSelectArea("SCR")
			SCR->(DbSetOrder(1))
			cCodTransf :=  oModelNNS:GetValue("NNS_COD")

			If lAltera .And. SCR->(DbSeek(  xFilial("SCR")+ "ST" + cCodTransf ))
				//Exclusão
				If oModelNNS:GetValue("NNS_STATUS") == '1'
					MaAlcDoc({cCodTransf,"ST",,,,},,3,,,,,.T.)
				ElseIf oModelNNS:GetValue("NNS_STATUS") == '4'
					MaAlcDoc({cCodTransf,STR0018,,,,},,3,,,,,.F.)					//"ST"
				EndIf
				//Inserção
				If !MaAlcDoc({oModelNNS:GetValue("NNS_COD"),"ST",nQuantTot,,cUsuario,cGrupo,,1,1,dDataBase},dDataBase,1)
					oModelNNS:LoadValue("NNS_STATUS","3")
				EndIf
			Else
				//Inserção
				If !MaAlcDoc({oModelNNS:GetValue("NNS_COD"),"ST",nQuantTot,,cUsuario,cGrupo,,1,1,dDataBase},dDataBase,1)
					oModelNNS:LoadValue("NNS_STATUS","3")
				EndIf
			EndIf

		EndIf
	EndIf

Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A311FilCGC(cFil)
Função que retorna o CNPJ da filial

@author Flavio Lopes Rasta
@since 22/01/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311FilCGC( cFil )
Local aAreaSM0	:= SM0->(GetArea())
Local cCGC		:=""

SM0->(dbSetOrder(1))
If SM0->(dbSeek(cEmpAnt+cFil))
	cCGC := SM0->M0_CGC
EndIf

RestArea(aAreaSM0)

Return cCGC

//-------------------------------------------------------------------
/*/{Protheus.doc} MAT311NNR()
Consulta específica no armazem da filial de destino

@author Raphael Augusto
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function MAT311NNR()
Local lRet		:= .F.
Local cFilAntBkp:= cFilAnt
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cFilDest	:= oModelNNT:GetValue("NNT_FILDES")
Local cLocal	:= &(ReadVar())

If cFilDest # cFilAnt
	cFilAnt := cFilDest
	lRet := ConPad1(,,,"NNR",,,.F.)
	cFilAnt := cFilAntBkp
Else
	lRet := ConPad1(,,,"NNR",,,.F.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MAT311SB1()
Consulta específica no produto da filial de destino

@author Leonardo Quintania
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function MAT311SB1()
Local lRet		:= .F.
Local cFilAntBkp:= cFilAnt
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cFilDest	:= oModelNNT:GetValue("NNT_FILDES")
Local cProd		:= &(ReadVar())

If cFilDest # cFilAnt
	cFilAnt := cFilDest
	lRet := ConPad1(,,,"SB1",,,.F.)
	cFilAnt := cFilAntBkp
Else
	lRet := ConPad1(,,,"SB1",,,.F.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTF3LookUp
Função utilizada para consulta padrão que tenha fonte feito a mão no MVC

@author Leonardo Quintania
@since 13/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function MTF3LookUp(cTable, cVar,cCampo)
Local oLkUp 	:= __FWLookUp(cTable,cCampo)
Local oModel	:= FWModelActive()
oLkUp:SetModel(oModel:GetModel("NNTDETAIL"))
lRet:= oLkUp:Activate(cVar)
If lRet
	oLkUp:ExecuteReturn()
EndIf
oLkUp:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311FilPrd()
Limpa o produto caso não encontre o produto na filial destino

@author Leonardo Quintania
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311FilPrd()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cFilDes	:= Substr(oModelNNT:GetValue("NNT_FILDES"),1,Len(cFilAnt))
Local cProdOri	:= oModelNNT:GetValue("NNT_PROD")
Local cProdDes	:= oModelNNT:GetValue("NNT_PRODD")
Local cProduto	:= ""

If xFilial('SB1') == Cfildes 
	cProduto:= cProdOri
Else
	If Empty(cProdDes) .And. SB1->(DbSeek(xFilial("SB1",cFilDes)+cProdOri))
		cProduto:= cProdOri
	ElseIf SB1->(DbSeek(xFilial("SB1",cFilDes)+cProdOri))
		cProduto:= cProdOri
	EndIf
EndIf
Return cProduto

//-------------------------------------------------------------------
/*/{Protheus.doc} A311SetKey()

@author Raphael Augustos
@since 05/03/2014
@version P12.0

/*/
//-------------------------------------------------------------------
Function A311SetKey()
Local cCampo 	:= AllTrim(Upper(ReadVar()))
Local oModel	:= NIL
Local oModelNNT	:= NIL
Local cProduto	:= NIL
Local cArmOri	:= NIL
Local cLocali	:= NIL
Local oView		:= FwViewActive()
Local nHdl		:= 0

oModel := FWModelActive()
If oModel <> NIL
	oModelNNT := oModel:GetModel("NNTDETAIL")
	cProduto := oModelNNT:GetValue("NNT_PROD")
	cArmOri := oModelNNT:GetValue("NNT_LOCAL")
	cLocali := oModelNNT:GetValue("NNT_LOCALI")

	Do Case
		Case cCampo == "M->NNT_LOCALI" .Or. cCampo == "M->NNT_NSERIE"
			nHdl := GetFocus()
			oView := FwViewActive()
			F4Localiz( , , , 'A311' , cProduto , cArmOri , , ReadVar() , .F. , , (AllTrim(Upper(ReadVar()))=='M->NNT_NSERIE') )
			SetFocus(nHdl)
		Case cCampo == "M->NNT_LOTECT" .Or. cCampo == "M->NNT_NUMLOT"
			F4Lote( , , , 'A311' , cProduto, cArmOri , NIL , cLocali , 2 , , , .F. )
		Case cCampo == "M->NNT_QUANT"
			If !Empty(cProduto)
				MaViewSB2(cProduto,,)
			Else
				Help("",1,"A311PRODVAZIO",,STR0003,4,1) //"Preencha o código do produto"
			EndIf
	EndCase
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A311FilArz()
Caso o produto tenha saldo no armazem padrão, preenche com o armazem.
Gatilho NNT_PROD
@author Leonardo Quintania
@since 25/02/2014
@version P12.0

/*/
//-------------------------------------------------------------------
Function A311FilArz(cProduto)
Local cArmazem	:= ""
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")

Default cProduto := oModelNNT:GetValue("NNT_PROD")

If SB2->(dbSeek(xFilial('SB2') + cProduto + RetFldProd(cProduto,"B1_LOCPAD"),.F.))
	cArmazem := RetFldProd(cProduto,"B1_LOCPAD")
	If !Empty(cArmazem)
		If !A311AvPer(3,{cArmazem,cProduto},.F.)
			cArmazem := ""
		EndIf
	EndIf
EndIf

Return cArmazem

//---------------------------------------------------------------------
/*/{Protheus.doc} A311GrvDoc()
Grava os codigos de documentos gerados nos itens de transferência
@author Flávio Lopes Rasta
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311GrvDoc(oModel,nOpc,aDocs)
Local lRet		:= .T.
Local oModelNNT	:= oModel:GetModel('NNTDETAIL')
Local nX		:= 0
Local nPos		:= 0
If Empty(aDocs)
	lRet := .F.
Endif
If lRet
	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine(nX)
		If nOpc == 1 // Armazéns
			If oModelNNT:GetValue('NNT_FILORI') == oModelNNT:GetValue('NNT_FILDES') //Filial origem igual a filial destino
				oModelNNT:LoadValue('NNT_DOC',aDocs[1])
			Endif
		ElseIf nOpc == 2 //Filiais
			If oModelNNT:GetValue('NNT_FILORI') # oModelNNT:GetValue('NNT_FILDES') //Filial origem diferente da filial destino
				//Busca a posição do array de documentos que contem a filial destino
				nPos := aScan(aDocs,{|x| x[1] == oModelNNT:GetValue('NNT_FILDES') })
				If nPos > 0
					If !Empty(aDocs[nPos][2])
						oModelNNT:LoadValue('NNT_DOC',aDocs[nPos][2])
						oModelNNT:LoadValue('NNT_SERIE',aDocs[nPos][3])
					Else
						lRet := .F.
						Exit
					Endif
				Endif
			Endif
		Endif
	Next nX
Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311VPrdOr()
Valida produto origem digitado possui ou nao referencia de grade
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311VPrdOr()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local lRet     	:= .T.
Local cProdOri	:= oModelNNT:GetValue("NNT_PROD")
Local aSaveArea := GetArea()

//Verifica se o usuario tem permissao de inclusao.
If lRet .And. oModel:GetOperation() ==  MODEL_OPERATION_INSERT
	lRet := A311AvPer(1,{cProdOri,"MTA260",3})
EndIf

RestArea(aSaveArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311VPrdDs()
Valida produto destino digitado possui ou nao referencia de grade
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311VPrdDs()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local lRet     	:= .T.
Local cFilOri	:= oModelNNT:GetValue("NNT_FILORI")
Local cProdOri	:= oModelNNT:GetValue("NNT_PROD")
Local cFilDes	:= oModelNNT:GetValue("NNT_FILDES")
Local cProdDes	:= oModelNNT:GetValue("NNT_PRODD")
Local aSaveArea := GetArea()
Local cFilAntBkp:= cFilAnt
Local cMVTRFVLDP	:= SuperGetMV("MV_TRFVLDP",.F.,"1")	//-- 1: códigos iguais; 2: SA5; 3: Não valida

cFilAnt := oModelNNT:GetValue("NNT_FILDES")
lRet := NaoVazio() .Or. ExistCpo("SB1")
cFilAnt := cFilAntBkp

//Verifica se o usuario tem permissao de inclusao.
If lRet .And. oModel:GetOperation() ==  MODEL_OPERATION_INSERT
	lRet := A311AvPer(1,{cProdDes,"MTA260",3})
EndIf

If lRet .And. cFilOri <> cFilDes .And. findFunction('A310VldPrd') .And. !A310VldPrd(cFilOri,cProdOri,cFilDes,cProdDes)
	If cMVTRFVLDP == '2'
		Help( ,, 'A311PRODUT',, STR0045 , 1, 0 ) //'Produto destino necessita de amarração produto x fornecedor (Origem)'
	Else 
		Help( ,, 'A311PRODUT',, STR0044 , 1, 0 ) //'Nao e permitido realizar transferencia entre Filiais com Produtos Diferentes'
	Endif
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311Local()
Valida armazem origem da transferencia
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311Local()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")

lRet := VldLocal(1,oModelNNT:GetValue("NNT_LOCAL"),oModelNNT:GetValue("NNT_PROD"))

 Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311LocalD()
Valida armazem destino da transferencia
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311LocalD()
Local lRet		:= .T.
Local cFilAntBkp:= cFilAnt
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")

cFilAnt := oModelNNT:GetValue("NNT_FILDES")

lRet := VldLocal(2,oModelNNT:GetValue("NNT_LOCLD"),oModelNNT:GetValue("NNT_PRODD"))

cFilAnt := cFilAntBkp

Return lRet

/*/{Protheus.doc} VldLocal
	Valida o Local de Armazem tanto o de Origem como o de Destino
@since 27/10/2017
@version 1.0
@return logico, Retorna verdadeiro se a validacao do armazem estiver correta
@param nTipo, numeric, 1 - Armazem Origem / 2 - Armazem Destino
@param cLocal, characters, Código do Armazem a ser validado
@param cProduto, characters, Código do produto a ser validado para o armazem
@type function
/*/
Static Function VldLocal(nTipo,cLocal,cProduto)
Local aArea		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())
Local lRet		:= .T.
Local cLocCQ	:= GetMvNNR('MV_CQ','98')
Local cLocProc	:= GetMvNNR('MV_LOCPROC','99')
Local lVldAlmo	:= SuperGetMV("MV_VLDALMO",.F.,'N') == 'S' // Verificar se realemnte é necessario este parametro

If cLocal == cLocCQ
	Help(' ',1,'A260LOCCQ')
	lRet := .F.
//-- Soh impede transferencia do Armazem de Processo se o Produto for de "Apropriacao Indireta"
ElseIf cLocal == cLocProc
	If !Empty(cProduto)
		lRet := A260ApropI(cProduto)
	EndIf
	lRet := lRet .AND. Aviso(STR0016,STR0021,{STR0020,STR0022}) == 2//"Atenção"//"Confirma"//"Abandona"//"Transferências do armazém de processo podem ser realizadas através de movimentação específica."
EndIf
If lRet
	// Origem sempre valida, mas destino depende do parametro MV_VLDALMO
	If (nTipo==1) .OR. (nTipo==2.and.lVldAlmo)
		SB2->(dbSetOrder(1))
		If !SB2->(dbSeek(xFilial('SB2')+cProduto+cLocal))
			Help(' ',1,'A260LOCAL')
			lRet := .F.
		EndIf
	EndIf
	lRet := lRet .and. ExistCpo("NNR",cLocal)

	lRet := lRet .and. A311AvPer(3, {cLocal,cProduto})

	lRet := lRet .and. A311Igual()
EndIf

SB2->(RestArea(aAreaSB2))
RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311Igual()
Verifica se os campos Filial Origem, Produto e Armazens são iguais
ao Filial Destino, Produto Destino e Armazem Destino.
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311Igual()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")

Local cFilOri	:= oModelNNT:GetValue("NNT_FILORI")
Local cProdOri	:= oModelNNT:GetValue("NNT_PROD")
Local cLocalOri	:= oModelNNT:GetValue("NNT_LOCAL")
Local cLocaliO	:= oModelNNT:GetValue("NNT_LOCALI")
Local cLoteOri	:= oModelNNT:GetValue("NNT_LOTECT")
Local cFilDes	:= oModelNNT:GetValue("NNT_FILDES")
Local cProdDes	:= oModelNNT:GetValue("NNT_PRODD")
Local cLocalD	:= oModelNNT:GetValue("NNT_LOCLD")
Local cLocaliD	:= oModelNNT:GetValue("NNT_LOCDES")
Local cLoteDes	:= oModelNNT:GetValue("NNT_LOTED")	

Local lRet			:= .T.

If !Empty(cFilOri) .And. !Empty(cProdOri) .And. !Empty(cLocalOri) ;
	.And. !Empty(cFilDes) .And. !Empty(cProdDes) .And. !Empty(cLocalD) ;
	.And. cFilOri+cProdOri+cLocalOri+cLocaliO+cLoteOri == cFilDes+cProdDes+cLocalD+cLocaliD+cLoteDes
	Help(' ',1,'MA260IGUAL') //A origem da transferência não pode ser  igual ao destino.
	lRet:= .F.
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311Locali()
Valida campo de localização na origem
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311Locali()

Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")

Local lRet		:= .T.
Local cProdDes 	:= oModelNNT:GetValue("NNT_PROD")
Local cLocal	:= oModelNNT:GetValue("NNT_LOCAL")
Local cLocaliz	:= oModelNNT:GetValue("NNT_LOCALI")
Local nPotenc   := 0

If !ExistCpo('SBE',cLocal+cLocaliz)
	Help(" ",1,"A311NOLOCALIZ")  //Não foi encontrado registro do endereço informado.
	lRet:= .F.
EndIf

If !Localiza(cProdDes)
	Help(" ",1,"A311NOPRODEND")  //Este produto não possui controle de endereçamento configurado.
	lRet:= .F.
Endif

If !IsBlind() .And. l311Gtl 
	If !Empty(c311NumSer)
		oModelNNT:LoadValue("NNT_NSERIE",c311NumSer)
		c311NumSer:= ""
	EndIf
	If !Empty(c311Lote)
		oModelNNT:SetValue("NNT_LOTECT" ,c311Lote)
		oModelNNT:SetValue("NNT_NUMLOT" ,c311SLote)
		oModelNNT:LoadValue("NNT_DTVALI",d311DtVld)

		nPotenc := oModelNNT:GetValue("NNT_POTENC")
		oModelNNT:LoadValue("NNT_POTENC",nPotenc)
		c311Lote  := ""
		c311SLote := ""
		d311DtVld := CTOD("  /  /  ")
	EndIf
	c311LocEnd:= ""
	l311Gtl := .F.

EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311LocDes()
Valida campo de localização no destino
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311LocDes()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cFilDes	:= oModelNNT:GetValue("NNT_FILDES")
Local cProdDes	:= oModelNNT:GetValue("NNT_PRODD")
Local cLocalD	:= oModelNNT:GetValue("NNT_LOCLD")
Local cLocaliz	:= oModelNNT:GetValue("NNT_LOCDES")
Local cFilAntBkp:= cFilAnt

cFilAnt := cFilDes

If !Localiza(cProdDes)
	Help(" ",1,"A311NOPRODEND")  //Este produto não possui controle de endereçamento configurado.
	lRet:= .F.
Endif

If !ExistCpo('SBE',cLocalD+cLocaliz)
	Help(" ",1,"A311NOLOCALIZ")  //Este produto não possui controle de endereçamento configurado.
	lRet:= .F.
EndIf

If lRet
	lRet := A311Igual()
EndIf

If lRet
	lRet := ProdLocali(cProdDes,cLocalD,cLocaliz) //Retorna se o produto é o unico na localizacao
EndIf

cFilAnt := cFilAntBkp

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311Lote()
Realiza validação de Lote e SubLote do documento de transferencia
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311Lote()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local oModelNNS	:= oModel:GetModel("NNSMASTER")

Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaSB8	:= SB8->(GetArea())

Local cLoteCTL	:= oModelNNT:GetValue("NNT_LOTECT") //Lote
Local cNumLote	:= oModelNNT:GetValue("NNT_NUMLOT") //SubLote

Local cProdOri	:= oModelNNT:GetValue("NNT_PROD")
Local cLocOrig	:= oModelNNT:GetValue("NNT_LOCAL")
Local lRastroL	:= Rastro(cProdOri, 'L')
Local lRastroS	:= Rastro(cProdOri, 'S')

Local cVar		:= ReadVar()

Local dDataEmis	:= oModelNNS:GetValue("NNS_DATA")

//-- O campo Lote sempre deve estar preenchido
If (lRastroL .Or. lRastroS) .And. Empty(cLoteCTL)
	Help(' ',1,'LOTOBRIGAT') //Deve ser informado o número do lote devido à configuração do produto selecionado.
	lRet		:= .F.
EndIf

//-- Se o Controle for Lote o campo Sub-Lote nao pode ser preenchido
If lRet .And. lRastroL .And. cVar == "M->NNT_NUMLOT" .And. !Empty(cNumLote)
	&(ReadVar()) := Space(Len(&(ReadVar())))
	lRet		:= .F.
EndIf

//-- Se o Sub-Lote nao estiver preenchido, Valida somente o Lote.
If lRet .And. lRastroS .And. cVar == "M->NNT_LOTECT" .And. Empty(cNumLote)
	lRastroL := .T.
	lRastroS := .F.
EndIf

If lRet
	If lRastroL //-- Validacao de Lote
		SB8->(dbSetOrder(3))
		If SB8->(dbSeek(xFilial('SB8') + cProdOri + cLocOrig + cLoteCTL, .F.)) .And. (dDataEmis >= SB8->B8_DATA)
			oModelNNT:LoadValue("NNT_LOTECT",SB8->B8_LOTECTL)
			oModelNNT:LoadValue("NNT_DTVALI",SB8->B8_DTVALID)
			oModelNNT:LoadValue("NNT_POTENC",SB8->B8_POTENCI)
		Else
			If !SB8->(FOUND())
				Help(' ', 1, 'A240LOTERR') //-- O número do lote informado não corresponde ao produto indicado na movimentação.
			lRet := .F.
			Endif
		EndIf
	ElseIf lRastroS //-- Validacao de Lote e Sub-Lote
		SB8->(dbSetOrder(2))
		If SB8->(dbSeek(xFilial('SB8') + cNumLote + cLoteCTL + cProdOri + cLocOrig, .F.))
			oModelNNT:LoadValue("NNT_LOTECT",SB8->B8_LOTECTL)
			oModelNNT:LoadValue("NNT_DTVALI",SB8->B8_DTVALID)
			oModelNNT:LoadValue("NNT_POTENC",SB8->B8_POTENCI)
			oModelNNT:LoadValue("NNT_NUMLOT",SB8->B8_NUMLOTE)
		Else
			Help(' ', 1, 'A240LOTERR') //-- O número do lote informado não corresponde ao produto indicado na movimentação.
			lRet		:= .F.
		EndIf
	Else
		If !Empty(&(cVar))
			Help(' ', 1, 'A240LOTERR') //-- O número do lote informado não corresponde ao produto indicado na movimentação.
			lRet		:= .F.
		EndIf
	EndIf
EndIf

//-- Retorna Integridade do Sistema
RestArea(aArea)
RestArea(aAreaSB8)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311TrcFil( cFil )
Função que efetua a troca da cFilAnt
@author Flávio Lopes Rasta
@since 18/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311TrcFil( cFil )
cFilAnt := cFil
Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} A311TrcFil( cFil )
Retorna o custo do produto
@author Raphael Augustos
@since 19/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311CUSTD()
Local nCusto	:= 0
Local cTPCusST 	:= SuperGetMv("MV_TPCUSST", .F. , "2")
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cProduto	:= oModelNNT:GetValue("NNT_PROD")
Local cLocal	:= oModelNNT:GetValue("NNT_LOCAL")

Do Case
	Case cTPCusST == "1" //Preço de venda
		SA1->(DbSetOrder(3))
		SA1->(DbSeek(xFilial('SA1')+SM0->M0_CGC))
		nCusto := MaTabPrVen(SA1->A1_TABELA,cProduto,1,SA1->A1_COD,SA1->A1_LOJA,1,dDataBase)
	Case cTPCusST == "2" //Custo standard
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+cProduto))
		nCusto := RetFldProd(SB1->B1_COD,"B1_CUSTD")
	Case cTPCusST == "3" //Último preço de compra
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+cProduto))
		nCusto := RetFldProd(SB1->B1_COD,"B1_UPRC")
	Case cTPCusST == "4" //Custo médio unitário do armazém
		SB2->(DbSetOrder(1))
		If SB2->(DbSeek(xFilial("SB2")+cProduto+cLocal))
			nCusto := SB2->B2_CM1
		EndIf
EndCase

//Se o custo solicitado pelo parâmetro MV_TPCUSST estiver zerado o sistema assume o custo de  1.
If nCusto == 0
	nCusto := 1
EndIf

Return nCusto

//---------------------------------------------------------------------
/*/{Protheus.doc} A311Rejeita()
Função chamada pelo fonte MATXALC quando o usuário rejeita um documento do tipo Solicitação de Transferência.
@author Raphael Augustos
@since 18/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311Rejeita(cNumST,cJustifica)
Local lRet			:= .T.
DEFAULT cNumST 		:= ""
DEFAULT cJustifica 	:= ""

If Empty(cNumST)
	lRet := .F.
EndIf

NNS->(DbSetOrder(1))
If lRet .And. NNS->(DbSeek(xFilial("NNS")+cNumSt))
	RecLock("NNS",.F.)
	NNS->NNS_STATUS := '4'
	NNS->NNS_JUSTIF := AllTrim(cJustifica)
	MsUnlock()
EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} A311PrdGrd()
Interface de Grade de Produtos com Explosão no Modelo.
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311PrdGrd()
Local oModel		:= FWModelActive()
Local oModelNNT		:= oModel:GetModel("NNTDETAIL")
Local aArea			:= GetArea()
Local cCpoName		:= StrTran(ReadVar(),"M->","")
Local cSaveReadVar	:= __READVAR
Local lGrade		:= MaGrade()
Local lReferencia	:= .F.
Local lAadd			:= .F.
Local lRet			:= .T.
Local nSaveN		:= 0
Local nOpca        	:= 0
Local oDlg			:= NIL

//-- Verifica se a grade esta ativa e se o produto digitado
//-- e uma referencia e Monta Interface de Grade
cProdRef    := &(ReadVar())
lReferencia := MatGrdPrrf(@cProdRef)
If lReferencia .And. lGrade .And. !Empty(&(ReadVar()))
	nSaveN       	:= oModelNNT:nLine
	oGrade  		:= MsMatGrade():New('oGrade', , 'NNT_QUANT', , 'A311VldGrd()',,;
										{{"NNT_QUANT"    ,.T., {{"NNT_QTSEG", {|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],oGrade:aColsFieldByName("NNT_QTSEG",,nLinha,nColuna,.F.),2) }}} },;
										{"NNT_QTSEG"  ,NIL, {{"NNT_QUANT"  , {|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),oGrade:aColsFieldByName("NNT_QUANT",,nLinha,nColuna,.F.),aCols[nLinha][nColuna],1) }}} },;
										{"NNT_LOCAL"    ,NIL, NIL};
										})
	//-- So aceita a entrada de dados via interface de grade se o usr
	//-- estiver posicionado na ultima linha
	If  oModelNNT:nLine >= oModelNNT:GetQtdLine()
		oGrade:MontaGrade(1,cProdRef,.T.,,lReferencia,.T.)
		oGrade:nPosLinO	:= 1
		oGrade:cProdRef		:= cProdRef
		lAadd    := .F.

		DEFINE MSDIALOG oDlg TITLE STR0024 OF oMainWnd PIXEL FROM 000,000 TO 220,520  //STR0024//"Interface para Grade de Produtos"

		@ 025,010 BUTTON STR0025 SIZE 70,15 FONT oDlg:oFont ACTION ;//"Quantidade"
		{|| __READVAR:='M->NNT_QUANT'  ,M->NNT_QUANT   := 0,cCpoName := StrTran(ReadVar(),"M->",""),oGrade:Show(cCpoName) } OF oDlg PIXEL //"Quantidade"
		@ 045,010 BUTTON STR0026 SIZE 70,15 FONT oDlg:oFont ACTION ;//"Segunda Und Medida"
		{|| __READVAR:='M->NNT_QTSEG',M->NNT_QTSEG := 0,cCpoName := StrTran(ReadVar(),"M->",""),oGrade:Show(cCpoName) } OF oDlg PIXEL //"Segunda Und Medida"

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End(), nOpca:=1},{||oDlg:End(), nOpca:=0}) CENTERED
		//-- Somente realiza a carga do item para o aCols se pelo menos uma celula do NNT_QUANT contiver valor.
		If nOpca # 1 .And. oGrade:SomaGrade("NNT_QUANT",oGrade:nPosLinO,oGrade:nQtdInformada) < 0
			lRet := .F.
		EndIf
		oModelNNT:GoLine(nSaveN)
		__READVAR := cSaveReadVar
	Else
		//-- Para incluir um produto com referencia de grade e necessario estar
		//-- em uma nova linha do movimento interno.
		Help(" ",1,"A241PRDGRD")
		lRet := .F.
	EndIf
Else
	// Se o Produto nao for um produto de grade executa a validacao no SB1
	// e inicializa os campos na getdados.
	SB1->(dbSetOrder(1))
	lRet := ExistCpo("SB1")
EndIf

RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A311FillGrd()
Realiza atualização dos itens no Model
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311FillGrd()
Local oView		:= FwViewActive()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local lAadd		:= .F.
Local nLinX		:= 0
Local nColY		:= 0
Local nTamDescO	:= 0
Local nTamDescD	:= 0

If oGrade <> NIL
	nTamDescO := TamSX3("NNT_DESC")[1]
	nTamDescD := TamSX3("NNT_DESCD")[1]
	 
	oGrade:lShowMsgDiff 	:= .F. // Desliga apresentacao
	For nLinX := 1 To Len(oGrade:aColsGrade[1])
		For nColY := 2 To Len(oGrade:aHeadGrade[1])
			If oGrade:aColsFieldByName("NNT_QUANT",1,nLinX,nColY)  > 0
				//-- Faz a montagem de linha na grid
				If lAadd
					oModelNNT:AddLine()
				EndIf
				If SB1->(dbSeek(xFilial("SB1")+PadR(oGrade:GetNameProd(oGrade:cProdRef,nLinX,nColY),Len(NNT->NNT_PROD))))
					oModelNNT:LoadValue("NNT_PROD",SB1->B1_COD)
					oModelNNT:LoadValue("NNT_DESC",SubStr(SB1->B1_DESC, 1, nTamDescO))
					oModelNNT:LoadValue("NNT_UM",SB1->B1_UM)
					oModelNNT:LoadValue("NNT_LOCAL",SB1->B1_LOCPAD)
					oModelNNT:LoadValue("NNT_QUANT",oGrade:aColsFieldByName("NNT_QUANT",1,nLinX,nColY))
					oModelNNT:LoadValue("NNT_QTSEG",oGrade:aColsFieldByName("NNT_QTSEG",1,nLinX,nColY))
					oModelNNT:LoadValue("NNT_PRODD",SB1->B1_COD)
					oModelNNT:LoadValue("NNT_DESCD",SubStr(SB1->B1_DESC, 1, nTamDescD))
					oModelNNT:LoadValue("NNT_UMD",SB1->B1_UM)
					If !lAadd
						lAadd 	 := .T.
					EndIf
				EndIf
			EndIf
		Next nColY
	Next nLinX
	If ValType(oView) == "O" .And. ! (IsInCallStack("a107criNNT") .Or. oModelNNT:GetValue("V_EXEC_MRP") == "1")
		oView:Refresh()
	EndIf
EndIf

oGrade:= NIL

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} A311VldGrd()
Validacao dos itens do Grid na grade de produtos
@author Leonardo Quintania
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function A311VldGrd()
Local lRet 		:= .T.
Local nColuna	:= aScan(oGrade:aHeadGrade[oGrade:nPosLinO],{|x| ValType(x) # "C" .And. x[2] == Substr(Readvar(),4)})
Local cProdGrd	:= oGrade:GetNameProd(NIL,n,nColuna)

lRet := Positivo()

If lRet .And. Empty(A311FilArz(cProdGrd))
	Help(' ',1,'A260LOCAL')
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311TESEC()
Efetua a consulta padrão do TES com base na Filial Destino.

@author Raphael Augusto
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311TESEC()
Local lRet		:= .F.
Local cFilAntBkp:= cFilAnt
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cFilDest	:= oModelNNT:GetValue("NNT_FILDES")
Local nTamFil   := FWSizeFilial()

If FWIsInCallStack('A311RepTES') .And. FWIsInCallStack('Pergunte')
	cFilDest := SubStr(MV_PAR01, 1, nTamFil)
	If Empty(cFilDest) .Or. !FWFilExist(,cFilDest)
		cFilDest := cFilAnt
	EndIf
EndIf

If cFilDest # cFilAnt
	cFilAnt := cFilDest
	lRet := ConPad1(,,,"SF4",,,.F.)
	cFilAnt := cFilAntBkp
Else
	lRet := ConPad1(,,,"SF4",,,.F.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311TESEV()
Efetua a consulta padrão do TES com base na Filial Destino.

@author Raphael Augusto
@since 25/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311TESEV()
Local lRet		:= .F.
Local cFilAntBkp:= cFilAnt
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cFilDest	:= oModelNNT:GetValue("NNT_FILDES")
Local nTamFil   := FWSizeFilial()

If FWIsInCallStack('A311RepTES') .And. FWIsInCallStack('Pergunte')
	cFilDest := SubStr(MV_PAR01, 1, nTamFil)
	If Empty(cFilDest) .Or. !FWFilExist(,cFilDest)
		cFilDest := cFilAnt
	EndIf
EndIf

If cFilDest # cFilAnt
	cFilAnt := cFilDest
	lRet := ExistCPO("SF4")
	cFilAnt := cFilAntBkp
Else
	lRet := ExistCPO("SF4")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311TESEV()
Replica o TES com base no pergunte A311TES

@author Raphael Augusto
@since 22/03/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311RepTES()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local aSaveLines := FWSaveRows()
Local aErro      := {}
Local nTamFil    := FWSizeFilial()
Local cFilSX1    := ''
Local lOK        := .T.
Local cMsg       := ''
Local cTESErro   := ''
Local cMsg2      := ''
Local nX

If Pergunte("A311TES",.T.)
	For nX := 1 To oModelNNT:Length()
		oModelNNT:GoLine( nX )
		If !oModelNNT:IsDeleted()
			cFilSX1 := SubStr(MV_PAR01, 1, nTamFil)
			If !Empty(MV_PAR02)
				If Empty(cFilSX1) .Or. (!Empty(cFilSX1) .And. oModelNNT:GetValue("NNT_FILDES") == cFilSX1)
					If !oModelNNT:SetValue("NNT_TS",MV_PAR02)
						lOK := .F.
						cTESErro := MV_PAR02
					EndIf
					EndIf
				EndIf

			If !Empty(MV_PAR03)
				If Empty(cFilSX1) .Or. (!Empty(cFilSX1) .And. oModelNNT:GetValue("NNT_FILDES") == cFilSX1)
					If !oModelNNT:SetValue("NNT_TE",MV_PAR03)
						lOK := .F.
						cTESErro := MV_PAR03
					EndIf
				EndIf
			EndIf

		Endif
		If !lOK
			Exit
		EndIf
	Next nX
	cMsg := STR0028
	If !lOK
		cMsg  := STR0048 //'Ocorreu um ou mais erros ao preencher a TES.'
		cMsg2 := STR0049 //'Na linha #1[29]# para a TES #2[501]# na filial destino #3[02]#: '
		aErro := oModel:GetErrorMessage(.T.)
		If AllTrim(aErro[5]) == 'REGNOIS'
			aErro[6] := STR0050 //'TES não cadastrada na filial destino.'
		EndIf
		Help(,, aErro[5],, I18N(cMsg2,{CValToChar(nX), cTESErro, oModelNNT:GetValue("NNT_FILDES")})+aErro[6], 1, 0,,,,,, {aErro[7]})
	EndIf

	Aviso(STR0016,cMsg,{STR0027},1)//"Atencao"//"Processo finalizado"//"OK"
EndIf

FWRestRows( aSaveLines )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A311IniDoc()
Inicializa campo com descrição do Tipo de documento

@author Leonardo Quintania
@since 22/03/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311IniDoc()
Local oModel      := FWModelActive()
Local oModelNNT
Local cDoc        := ""
Local cSerie      := ""
Local cRet        := ""

If ValType(oModel) == "O" .And. !Inclui .And. !oModel:IsCopy()
	oModelNNT := oModel:GetModel("NNTDETAIL")
	If oModelNNT:Length() > 0
		cDoc  := oModelNNT:GetValue("NNT_DOC")
		cSerie:= oModelNNT:GetValue("NNT_SERIE")
	Else
		cDoc  := NNT->NNT_DOC
		cSerie:= NNT->NNT_SERIE
	EndIf
	If !Empty(cDoc)
		If !Empty(cSerie)
			cRet:= "Documento Fiscal"
		Else
			cRet:= "Movimentação Interna"
		EndIf
	EndIf
EndIf
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A311SomaDados()
Realiza soma das linhas da Grid

@author Leonardo Quintania
@since 22/03/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311SomaGrid(oModelNNT)
Local cProduto	:= oModelNNT:GetValue( 'NNT_PROD' )
Local cArmazem	:= oModelNNT:GetValue( 'NNT_LOCAL' )
Local cLocaliza	:= oModelNNT:GetValue( 'NNT_LOCALI' )
Local cNumSerie	:= oModelNNT:GetValue( 'NNT_NSERIE' )
Local cLoteCtl	:= oModelNNT:GetValue( 'NNT_LOTECT' )
Local cLote		:= oModelNNT:GetValue( 'NNT_NUMLOT' )
Local aSaveLines:= FWSaveRows()
Local nQtdTotal	:= 0
Local nX		:= 0

//Calcula se foi informado o mesmo Produto, Armazem, Lote, SubLote, Endereço e Numero de Serie para o Produto
For nX := 1 To oModelNNT:Length()
	oModelNNT:GoLine( nX )
	If !oModelNNT:IsDeleted()
		If oModelNNT:GetValue('NNT_PROD') + oModelNNT:GetValue('NNT_LOCAL')   ;
		+ oModelNNT:GetValue('NNT_LOCALI') + oModelNNT:GetValue('NNT_NSERIE') ;
		+ oModelNNT:GetValue('NNT_LOTECT') + oModelNNT:GetValue('NNT_NUMLOT') ;
		== cProduto + cArmazem + cLocaliza + cNumSerie + cLoteCtl + cLote
			nQtdTotal += oModelNNT:GetValue( 'NNT_QUANT' )
		Endif
	Endif
Next nX

FWRestRows( aSaveLines )

Return nQtdTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} A311Fild()
Limpa o endereço e bloqueia o campo caso a transferência seja entre
Filiais

@author Flavio Lopes Rasta
@since 13/06/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311Fild()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel('NNTDETAIL')
Local oStruNNT  := oModelNNT:GetStruct()
Local cFilOri	:= Substr(oModelNNT:GetValue("NNT_FILORI"),1,Len(cFilAnt))
Local cFilDes	:= Substr(oModelNNT:GetValue("NNT_FILDES"),1,Len(cFilAnt))
Local lWhen		:= .T.

If cFilOri # cFilDes
	lWhen := .F.
Endif

oModelNNT:LoadValue('NNT_LOCDES',"")
oStruNNT:SetProperty('NNT_LOCDES',MODEL_FIELD_WHEN,{||lWhen})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Mat311BlqM(oModel)
Verifica se existe bloqueio de movimentações pelo Calendário Contábil
ou pelo parâmetro MV_ATFBLQM

@author José Eulálio
@since 20/05/2015
@version P12.0
/*/
//-------------------------------------------------------------------
Function Mat311BlqM(aFilDes)
Local cFilBkp	:= cFilAnt
Local cBlq		:= ""
Local nX		:= 0
Local lRet 		:= .T.

//Verifica se existe bloqueio contábil na filial de origem
lRet := CtbValiDt(Nil, dDataBase,/*.F.*/ ,Nil ,Nil ,{"EST001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/)

//Verifica se existe o bloqueio nas filiais de destino
If lRet
	For nX := 1 to Len(aFilDes)
		cFilAnt := aFilDes[nX]
		lRet := CtbValiDt(Nil, dDataBase,.F. ,Nil ,Nil ,{"EST001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/)
		If !lRet
			cBlq += aFilDes[nX]
			Exit
		EndIf
	Next nX
	If !lRet
		Aviso(STR0016,I18N(STR0023,{cBlq}),{STR0027},1) //"Atenção"
														//"Não será possível efetuar o processo. A filial #1[01]# contém processos
														// bloqueados pelo Calendário Contábil ou pelo parâmetro de bloqueio. Contate
														// o responsável ou altere as Filiais de Destino"//"OK"
	EndIf
EndIf
//devolve o cFilAnt para posição anterior
cFilAnt := cFilBkp
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A311ActMod()
Valida ativação do modelo

@author desconhecido
@since desconhecido
@version P12.0
/*/
//-------------------------------------------------------------------
Function A311ActMod( oModel, nOpcx )
Local oMaster	:= oModel:GetModel()
Local oModelNNS	:= oMaster:GetModel("NNSMASTER")
Local oModelNNT	:= oMaster:GetModel("NNTDETAIL")
Local dDtEmiss	:= oModelNNS:GetValue( "NNS_DATA" )
Local nOperation:= oModel:GetOperation()
Local lAuto311	:= Type("cOpId311") == "C" .And. cOpId311 == OP_EFE .And. !(Empty(oModelNNT:GetValue('NNT_SERIE')))
Default nOpcx	:= 1

If nOperation != 1 .AND. nOperation != 5
	If nOpcx == 2
		oModelNNS:SetValue( "NNS_DATA", dDataBase )
		oModelNNS:LoadValue( "NNS_DATA", dDtEmiss )
	EndIf

	//Se a efetivação está na chamada não permite excluir, alterar ou adicionar linha
	If IsInCallStack("A311Efetiv") .Or. lAuto311
		oModelNNT:SetNoInsertLine(.T.)
		oModelNNT:SetNoDeleteLine(.T.)
		oModelNNT:SetNoUpdateLine(.T.)
	EndIf

EndIf
Return .T.


/*/{Protheus.doc} A311AvPer
Valida se o usuario tem permissão para uso do produto ou armazem
@author reynaldo
@since 27/10/2017
@version 1.0
@return Logico, permite ou não
@param nTipo, Numeric, 1- para tratar produto / 2- tratar armazem
@param aDados, array, Dados para busca, conforme 2 paramero da funcao MAAvalPerm(MATXALC.PRX)
@type function
/*/
Static Function A311AvPer(nTipo, aDados ,lMensagem)
Local lRet
DEFAULT lMensagem := .T.

lRet := MaAvalPerm(nTipo,aDados)
If !lRet
	If lMensagem
		Help(,,1,'SEMPERM')
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} MTA311INI
Inicializador padrão para os campos da tabela NSS
@author reynaldo
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function MTA311INI()
Local cReturn	:= ""
Local cCampoEdit:= ReadVar()
Local oModel
Local oModelNNS
Local nOperation
Local cCodigo	:= ""

	// retira M-> do conteudo da variavel
	cCampoEdit := Right(cCampoEdit,len(cCampoEdit)-3)

	If cCampoEdit == "NNS_COD"
		oModel := FWModelActive()
		oModelNNS := oModel:GetModel('NNSMASTER') 
		If oModelNNS==NIL
			If INCLUI
				nOperation := 3
			EndIf
			cCodigo := &cCampoEdit 
		Else
			cCodigo	:= oModelNNS:GetValue("NNS_COD")
			nOperation := oModel:GetOperation()
		EndIf 
	
		//	trata-se de inclusao ou somente atualizacao(Copia)
		If nOperation ==3 .OR. (nOperation == 4 .AND. Empty(cCodigo))
			cReturn := GETSX8NUM("NNS","NNS_COD")
		EndIf

	EndIf
Return cReturn

/*/{Protheus.doc} A311MT261
Executa a ExecAuto da MATA261 e verifica se houve erro.
@author Adriano Vieira
@since 12/12/2017
@version 1.0
@return ${lRet}, ${return_description}

@type function
/*/
Static Function A311MT261(aDadosA)
Local lRet		:= .T.
Local cErro 	:= ""
Local aLog 	:= {}
Local nCont	:= 1

PRIVATE lMsErroAuto 
PRIVATE lAutoErrNoFile := .T.

//Executa rotina automática
lMsErroAuto := .F.
MSExecAuto({|x,y| MATA261(x,y)},aDadosA,3)
		
If lMsErroAuto
	aLog 	:= GetAutoGRLog()	//efetua o tratamento para validar se o arquivo de log já existe

	For nCont := 1 to Len(aLog)
     	cErro += aLog[nCont]
	Next nCont
	
	lRet 	:= .F.
EndIf
	
Return {lRet, cErro}

/*/{Protheus.doc} A311FILIAL
Executa o ponto de entrada M311FILIAL
@author Squad Entradas
@since 07/07/2020
@version 1.0
/*/
Static Function A311FILIAL()
Local aFiliais := {}
Local aSM0     := FWLoadSM0(.T., .T.)

aFiliais := ExecBlock("M311FILIAL",.F.,.F.,{__cUserID,aSM0})

If !ValType(aFiliais) == "A" .Or. Len(aFiliais) == 0
	aFiliais := {}
EndIf

Return aFiliais

/*/{Protheus.doc} addFldNNT
Adiciona campo virtual na estrutura da tabela NNT.

@type  Static Function
@author lucas.franca
@since 19/11/2020
@version P12
@param oStrNNT, Object, Instância da estrutura de dados da tabela NNT
@return Nil
/*/
Static Function addFldNNT(oStrNNT)
	oStrNNT:AddField("V_EXEC_MRP",;	// [01]  C   Titulo do campo  //"Seq. original"
	                 "V_EXEC_MRP",;	// [02]  C   ToolTip do campo //"Seq. original"
	                 "V_EXEC_MRP",;	// [03]  C   Id do Field
	                 "C"         ,;	// [04]  C   Tipo do campo
	                 1           ,;	// [05]  N   Tamanho do campo
	                 0           ,;	// [06]  N   Decimal do campo
	                 NIL         ,;	// [07]  B   Code-block de validação do campo
	                 NIL         ,;	// [08]  B   Code-block de validação When do campo
	                 NIL         ,;	// [09]  A   Lista de valores permitido do campo
	                 .F.         ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                 NIL         ,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL         ,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL         ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                 .T.         )	// [14]  L   Indica se o campo é virtual
	
	oStrNNT:SetProperty("V_EXEC_MRP", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "0"))
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} A311NSerie()
Valida campo do número de série na origem
@author Squad Entradas
@since 25/05/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function A311NSerie()
Local oModel	:= FWModelActive()
Local oModelNNT	:= oModel:GetModel("NNTDETAIL")
Local cNumSerie := oModelNNT:GetValue("NNT_NSERIE")
Local nPotenc   := 0

If !IsBlind() .And. l311Gtl .And. !Empty(c311NumSer) .And. !Empty(cNumSerie) .And. c311NumSer == cNumSerie
	oModelNNT:LoadValue("NNT_LOCALI",c311LocEnd)
	c311LocEnd:= ""
	If !Empty(c311Lote)
		oModelNNT:SetValue("NNT_LOTECT" ,c311Lote)
		oModelNNT:SetValue("NNT_NUMLOT" ,c311SLote)
		oModelNNT:LoadValue("NNT_DTVALI",d311DtVld)

		nPotenc := oModelNNT:GetValue("NNT_POTENC")
		oModelNNT:LoadValue("NNT_POTENC",nPotenc)

		c311Lote  := ""
		c311SLote := ""
		d311DtVld := CTOD("  /  /  ")
	EndIf
	c311NumSer := ""
	l311Gtl := .F.
Elseif !IsBlind() .And. l311Gtl .And. c311NumSer <> cNumSerie
	l311Gtl := .F.
	c311Lote  := ""
	c311SLote := ""
	d311DtVld := CTOD("  /  /  ")
	c311NumSer:= ""
	c311LocEnd:= ""
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A311GrvPed()
Função responsável por gravar o número do pedido de venda
@author Squad Entradas
@since 14/10/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function A311GrvPed(oModel,aBloqueio)
Local lRet		:= .T.
Local oModelNNT	:= oModel:GetModel('NNTDETAIL')
Local nX		:= 0
Local nPos		:= 0

For nX := 1 To oModelNNT:Length()
	oModelNNT:GoLine(nX)
	If oModelNNT:GetValue('NNT_FILORI') # oModelNNT:GetValue('NNT_FILDES') //Filial origem diferente da filial destino
		//Busca a posição do array de documentos que contem a filial destino
		nPos := aScan(aBloqueio,{|x| x[9] == oModelNNT:GetValue('NNT_FILDES') })
		If nPos > 0
			If !Empty(aBloqueio[nPos][1])
				oModelNNT:LoadValue('NNT_NUMPED',aBloqueio[nPos][1])
			Else
				lRet := .F.
				Exit
			Endif
		Endif
	Endif
Next nX

Return lRet
