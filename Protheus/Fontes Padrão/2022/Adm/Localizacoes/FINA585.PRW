#Include "PROTHEUS.CH"
#Include "FINA585.CH"

STATIC lMod2	:= .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA585   บAutor  ณSilvia Monica       บ Data ณ  04/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Liberacao de fundos para pagamentos PA                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Argentina                                                  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณM.Camargo     ณ05.03.17|MMI-  ณARG. Se agrega validaci๓n แra modalidad ณฑฑ
ฑฑณ              ณ        |5413  ณy fecha previsi๓n funci๓n FA585TOK().   ณฑฑ
ฑฑณRa๚l Ortiz    ณ18/10/17|TSSERMณSe modifica busqueda de proveedor, no   บฑฑ
ฑฑณ              ณ        |I01-19ณconsidera que puede estar registrado conบฑฑ
ฑฑณ              ณ 	     |9     ณDiferente Loja                          บฑฑ
ฑฑณ              ณ        |      ณ                                        บฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA585()

Local cAlias	:= "FJA" //Solicitacao de fundo para PA
Local cFinctal	:= GetMV("MV_FINCTAL", .T., "") //Controle de liberacao com ou sem alcada
Local aCores	:= {{	'FJA_ESTADO == "1"'	,'BR_AMARELO'	},;
					{	'FJA_ESTADO == "2"'	,'BR_VERDE'		},;
					{	'FJA_ESTADO == "3"'	,'BR_VERMELHO'	},;
					{	'FJA_ESTADO == "4"'	,'BR_PRETO'		},;
					{	'FJA_ESTADO == "5"'	,'BR_BRANCO'	}}

Private aRotina	:= {}
Private lTrava	:= .T.
/*
 * Verifica็ใo do processo que estแ configurado para ser utilizado no M๓dulo Financeiro (Argentina)
 */
If lMod2
	If !FinModProc()
		Return()
	EndIf
EndIf

If cFinctal != "2" // 1-Liberacao simples / 2-Liberacao com alcada
	Help(" ",1,'Help',,STR0002,1,0) //"Controle de libera็ใo por al็ada desativado, verifique o parโmetro 'MV_FINCTAL'"
	Return
EndIf

aRotina := MenuDef()

dbSelectArea("FRP") //Gestores Financeiros
dbSetOrder(1)

dbSelectArea("FRS") //Amarra Aprovador X Superiores
dbSetOrder(1)

dbSelectArea("FRR") //Grupo de Gestores Financeiros
dbSetOrder(1)

dbSelectArea("SA2") //Fornecedores
dbSetOrder(1)

dbSelectArea("SED") //Naturezas
dbSetOrder(1)

If cPaisLoc <> "BRA"
	dbSelectArea("SEK") //Ordens de Pagamento
	dbSetOrder(1)
EndIf

dbSelectArea(cAlias) //Solicitacao de fundo para PA
dbSetOrder(1)
mBrowse(,,,,cAlias,,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585OPC  บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a tela de acordo com a opcao selecionada              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Argentina/Brasil                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA585OPC(cAlias,nReg,nOpc,lAutomato)
Local nOpcA		:= 0
Local cEstado	:= "1" //Pendente
Local oGroup2	//Documento
Local oGroup3	//Aprovador
Local oGroup4	//Favorecido
Local oGroup5	//Dados Adicionais
Local oGroup7	//Resultado
Local oGroup8	//Ordem de pago
Local oGroup9	//Gera PA
//Documento
Local oCodigo
Local cCodigo	:= If(nOpc == 3,GetSXENum("FJA","FJA_SOLFUN"),FJA->FJA_SOLFUN)
Local oData
Local dData		:= CriaVar('FJA_DATA', .T.)
Local oValor
Local nValor	:= CriaVar('FJA_VALOR', .F.)
Local oObs
Local cObs		:= CriaVar('FJA_OBSERV', .F.)
//Aprovador
Local oCodApr
Local cCodApr	:= CriaVar('FJA_CODAPR', .T.)
Local oNomApr
Local cNomApr	:= CriaVar('FRP_NOME', .F.)
//Favorecido
Local oCodFav
Local cCodFav	:= CriaVar('FJA_FORNEC', .T.)
Local oLoja
Local cLoja		:= CriaVar('FJA_LOJA', .T.)
Local oNomRa
Local cNomRa	:= CriaVar('A2_NOME', .F.)
//Dados Adicionais
Local oCodNat
Local cCodNat	:= CriaVar('FJA_NATURE', .T.)
Local oNomNat
Local cNomNat	:= CriaVar('ED_DESCRIC', .F.)
Local oDtPr
Local dDtPr		:= CriaVar('FJA_DATAPR', .T.)
Local oMoedSol
Local cMoedSol	:= CriaVar('FJA_MOEDA', .F.)
Local oDest
Local cDest		:= CriaVar('FJA_DESTIN', .F.)
Local oDestch
Local cDestch	:= Iif(cPaisLoc == "ARG",CriaVar('FJA_CUIT', .F.),"")
//Resultado
Local oCodResp
Local cCodResp	:= CriaVar('FJA_RESPON', .F.)
Local oNomResp
Local cNomResp	:= CriaVar('FRP_NOME', .F.)
Local oDtoper
Local dDtoper	:= CriaVar('FJA_DTOPER', .F.)
Local oOboper
Local cOboper	:= CriaVar('FJA_OBOPER', .F.)
//Ordem de pago
Local oNumOp
Local cNumOp	:= Iif(cPaisLoc <> "BRA",CriaVar('FJA_ORDPAG', .F.),"")
Local oDatOP
Local dDatOP	:= Iif(cPaisLoc <> "BRA",CriaVar('EK_EMISSAO', .F.),"")
//Banco Cheque Benef.
Local cCodSE2	:= CriaVar('E2_NUM', .F.)
Local oBancoAdt
Local cBancoAdt	:= CriaVar("A6_COD")
Local oAgenciaAdt
Local cAgenciaAdt:= CriaVar("A6_AGENCIA")
Local oNumCon
Local cNumCon	:= CriaVar("A6_NUMCON")
Local oChequeAdt
Local cChequeAdt:= CriaVar("EF_NUM")
Local oHistor
Local cHistor	:= CriaVar("EF_HIST")
Local oBenef
Local cBenef	:= CriaVar("EF_BENEF")
Local _aTit 	:= {}

Local oDlg		:= NIL
Local oSize		:= Nil
Local oPnlAprov	:= Nil
Local oPnlDoc	:= Nil

Local cOpc		:= AllTrim(Str(nOpc))
PRIVATE  nSavSX8E2 := 0
Default lAutomato 	:= .F. //para acceso por script automแtico

//Executa pre-validacoes antes de exibir a tela
If !FA585PreVl(nOpc)
	Return
EndIf

//Valida se eh Aprovacao, Exclusao ou Cancelamento e se o usuario
//logado faz parte da tabela Gestor Financeiro como gestor ou superior
If cOpc $ '8|9|10'
	If !FA585VldAp(nOpc,FJA->FJA_CODAPR,@cCodResp,FJA->FJA_MOEDA,Date(),FJA->FJA_VALOR)
		Return
	Else
		cNomResp := CUSERNAME
	EndIf
EndIf

If nOpc != 3
	cEstado		:= FJA->FJA_ESTADO
	//Documento
	dData  		:= FJA->FJA_DATA
	nValor 		:= FJA->FJA_VALOR
	cObs   		:= FJA->FJA_OBSERV
	//Aprovador
	cCodApr		:= FJA->FJA_CODAPR
	cNomApr		:= UsrFullName(Posicione("FRP",1,xFilial("FRP")+FJA->FJA_CODAPR,'FRP_USER'))
	//Favorecido
	cCodFav		:= FJA->FJA_FORNEC
	cLoja		:= FJA->FJA_LOJA
	cNomRa		:= Posicione("SA2",1,xFilial("SA2")+FJA->(FJA_FORNEC + FJA_LOJA), "A2_NOME")
	//Dados Adicionais
	cCodNat		:= FJA->FJA_NATURE
	cNomNat		:= Posicione("SED",1,xFilial("SED")+FJA->FJA_NATURE, "ED_DESCRIC")
	dDtPr		:= FJA->FJA_DATAPR
	cMoedSol	:= FJA->FJA_MOEDA
	cDest		:= FJA->FJA_DESTIN
    If cPaisLoc == "ARG"
		cDestch		:= FJA->FJA_CUIT
	EndIf
	//Resultado
	If nOpc == 2 //Consulta
		cCodResp := FJA->FJA_RESPON		
		cNomResp := UsrFullName(Posicione("FRP",1,xFilial("FRP")+FJA->FJA_RESPON, "FRP_USER"))
	EndIf
	dDtoper		:= If(cOpc $ '8|9',Date(), FJA->FJA_DTOPER)
	cOboper		:= If(Empty(FJA->FJA_OBOPER),CriaVar('FJA->FJA_OBOPER', .F.),FJA->FJA_OBOPER)
	If cPaisLoc <> "BRA"
		cNumOp		:= FJA->FJA_ORDPAG
		dDatop		:= Posicione("SEK",1,xFilial("SEK")+FJA->FJA_ORDPAG, "EK_EMISSAO")
	EndIf
EndIf

If nOpc != 11
	DEFINE MSDIALOG oDlg TITLE STR0006 FROM 000, 000  TO 700, If(cOpc $ '2|8|9|10',969,500) PIXEL //"Solicitacao de Fundos"
	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:lLateral := (cOpc $ '2|8|9|10')
	If oSize:lLateral
		oSize:AddObject( "PAINEL_ESQUERDA",100,50,.T.,.T. )
		oSize:AddObject( "PAINEL_DIREITA",100,50,.T., .T. )
	Else
		oSize:AddObject( "PAINEL_ESQUERDA",100,100,.T.,.T. )
	Endif        
	oSize:lProp	:= .T.     
	oSize:aMargins := { 3, 3, 3, 3 } 
	oSize:Process()
	oPnlDoc := TPanel():New(oSize:GetDimension("PAINEL_ESQUERDA","LININI"),;
								 oSize:GetDimension("PAINEL_ESQUERDA","COLINI"),If(oSize:lLateral,"     " + STR0007,"");
								,oDlg,,,,,,oSize:GetDimension("PAINEL_ESQUERDA","XSIZE"),;
								oSize:GetDimension("PAINEL_ESQUERDA","YSIZE"),,)
	If oSize:lLateral
		oPnlAprov := TPanel():New(oSize:GetDimension("PAINEL_DIREITA","LININI"),;
								 oSize:GetDimension("PAINEL_DIREITA","COLINI"),"     " + STR0036;
								,oDlg,,,,,,oSize:GetDimension("PAINEL_DIREITA","XSIZE"),;
								oSize:GetDimension("PAINEL_DIREITA","YSIZE"),,)
	Endif
	//Grupo de campos: Solicitacao
	//DOCUMENTO
	@ 013, 006 GROUP oGroup2 TO 080, 240 PROMPT STR0008 OF oPnlDoc PIXEL //"Documento"
	@ 023, 015 SAY		STR0009				SIZE 025, 007 OF oGroup2 PIXEL //"Codigo"
	@ 030, 015 MSGET	oCodigo	VAR cCodigo	SIZE 060, 010 OF oGroup2 PIXEL WHEN .F.
	@ 023, 088 SAY		STR0010				SIZE 025, 007 OF oGroup2 PIXEL //"Data"
	@ 030, 088 MSGET	oData	VAR dData	SIZE 060, 010 OF oGroup2 PIXEL WHEN .F. HASBUTTON
	@ 023, 158 SAY		STR0011				SIZE 025, 007 OF oGroup2 PIXEL //"Valor"
	@ 030, 158 MSGET	oValor	VAR nValor	SIZE 080, 010 OF oGroup2 PIXEL WHEN !cOpc $ '2|5|8|9|10' PICTURE PesqPict("FJA","FJA_VALOR") HASBUTTON
	@ 048, 015 SAY		STR0012				SIZE 034, 007 OF oGroup2 PIXEL //"Observacao"
	@ 055, 015 MSGET	oObs	VAR cObs	SIZE 202, 013 OF oGroup2 PIXEL WHEN !cOpc $ '2|5|8|9|10'

	//APROVADOR
	@ 080, 006 GROUP oGroup3 TO 150, 240 PROMPT STR0013 OF oPnlDoc PIXEL //"Aprovador"
	@ 095, 015 SAY		STR0009 			SIZE 025, 007 OF oGroup3 PIXEL //"Codigo"
	@ 102, 015 MSGET	oCodApr	VAR cCodApr SIZE 060, 010 OF oGroup3 PIXEL WHEN !cOpc $ '2|5|8|9|10' F3 "FRP" VALID FA585CodAp(cCodApr,@cNomApr,@oNomApr,cMoedSol) HASBUTTON
	@ 122, 015 SAY		STR0014				SIZE 034, 007 OF oGroup3 PIXEL //"Nome"
	@ 129, 015 MSGET	oNomApr	VAR cNomApr SIZE 202, 012 OF oGroup3 PIXEL WHEN .F.

	//FAVORECIDO
	@ 150, 006 GROUP oGroup4 TO 210, 240 PROMPT STR0015 OF oPnlDoc PIXEL //"Favorecido"
	@ 160, 015 SAY		STR0009				SIZE 025, 007 OF oGroup4 PIXEL //"Codigo"
	@ 167, 015 MSGET	oCodFav	VAR cCodFav	SIZE 060, 010 OF oGroup4 PIXEL WHEN !cOpc $ '2|5|8|9|10' F3 "SA2" VALID FA585DadFa(cCodFav,@cLoja,@oLoja,@cNomRa,@oNomRa) HASBUTTON
	@ 160, 088 SAY		STR0061 			SIZE 025, 007 OF oGroup4 PIXEL //"Loja"
	@ 167, 088 MSGET	oLoja	VAR cLoja	SIZE 060, 010 OF oGroup4 PIXEL WHEN .F.
	@ 185, 015 SAY		STR0016				SIZE 059, 007 OF oGroup4 PIXEL //"Nome/Razao Social"
	@ 192, 015 MSGET	oNomRa	VAR cNomRa	SIZE 202, 010 OF oGroup4 PIXEL WHEN .F. OBFUSCATED RetGlbLGPD("A2_NOME")

	//DADOS ADICIONAIS
	@ 210, 006 GROUP oGroup5 TO 315, 240 PROMPT STR0062 OF oPnlDoc PIXEL //"Dados Adicionais"
	@ 220, 015 SAY		STR0063						SIZE 025, 007 OF oGroup5 PIXEL //"Natureza"
	@ 227, 015 MSGET	oCodNat		VAR cCodNat		SIZE 070, 010 OF oGroup5 PIXEL WHEN !cOpc $ '2|5|10' F3 "SED" VALID FA585Nat(cCodNat,@cNomNat,@oNomNat) HASBUTTON
	@ 220, 090 SAY		STR0064						SIZE 034, 007 OF oGroup5 PIXEL //"Descricao"
	@ 227, 090 MSGET	oNomNat		VAR cNomNat		SIZE 100, 010 OF oGroup5 PIXEL WHEN .F.
	@ 242, 015 SAY		STR0065						SIZE 050, 007 OF oGroup5 PIXEL //"Data Previsao"
	@ 250, 015 MSGET	oDtPr		VAR dDtPr		SIZE 060, 010 OF oGroup5 PIXEL WHEN !cOpc $ '2|5|10' HASBUTTON
	@ 242, 090 SAY		STR0068						SIZE 034, 007 OF oGroup5 PIXEL //Moeda
	@ 250, 090 MSGET	oMoedSol	VAR cMoedSol	SIZE 040, 010 OF oGroup5 PIXEL WHEN !cOpc $ '2|5|8|9|10' VALID FA585CodMo(cMoedSol,@cCodApr,@oCodApr,@cNomApr,@oNomApr) F3 "CTO" HASBUTTON
	@ 265, 015 SAY		STR0066						SIZE 034, 007 OF oGroup5 PIXEL //"Destinatario"
	@ 272, 015 MSGET	oDest		VAR cDest		SIZE 202, 010 OF oGroup5 PIXEL WHEN (!cOpc $ '2|5|10' .And. !RetGlbLGPD("FJA_DESTIN")) OBFUSCATED RetGlbLGPD("FJA_DESTIN") Picture "@!"
	
	If cPaisLoc == "ARG"
		@ 287, 015 SAY		sX3->(RetTitle("FJA_CUIT"))	SIZE 064, 007 OF oGroup5 PIXEL
		@ 296, 015 MSGET	oDestch		VAR cDestch		SIZE 100, 010 OF oGroup5 PIXEL WHEN !cOpc $ '2|5|10' VALID If( cPaisLoc == 'BRA', Cgc(cDestch),If(cPaisLoc == 'ARG', Cuit(cDestch), .T.)) PICTURE PesqPict("FJA","FJA_CUIT")
    EndIf

	If cOpc $ '2|8|9|10'
		//Grupo de campos: Parecer do Aprovador
		//RESULTADO		
		@ 013, 006 GROUP oGroup7 TO 110, 234 PROMPT STR0037 OF oPnlAprov PIXEL //"Resultado"
		@ 023, 010 SAY		STR0038						SIZE 035, 007 OF oGroup7 PIXEL //"Responsavel"
		@ 030, 010 MSGET	oCodResp	VAR cCodResp	SIZE 060, 010 OF oGroup7 PIXEL WHEN .F. HASBUTTON
		@ 030, 082 MSGET	oNomResp	VAR cNomResp	SIZE 130, 010 OF oGroup7 PIXEL WHEN .F.
		@ 053, 010 SAY		STR0010						SIZE 025, 007 OF oGroup7 PIXEL //"Data"
		@ 060, 010 MSGET	oDtoper		VAR dDtoper		SIZE 060, 010 OF oGroup7 PIXEL WHEN .F. HASBUTTON
		@ 053, 082 SAY		STR0012						SIZE 034, 007 OF oGroup7 PIXEL //"Observacao"
		@ 060, 082 MSGET	oOboper		VAR cOboper		SIZE 131, 010 OF oGroup7 PIXEL WHEN !cOpc $ '2|5'

		If cPaisLoc <> "BRA"
			//ORDEM DE PAGO
			@ 110, 006 GROUP oGroup8 TO 150, 234 PROMPT STR0039 OF oPnlAprov PIXEL //"Ordem de Pago "
			@ 125, 010 SAY		STR0040				SIZE 025, 007 OF oGroup8 PIXEL //"Numero"
			@ 133, 010 MSGET	oNumOP	VAR cNumOP	SIZE 064, 010 OF oGroup8 PIXEL WHEN .F.
			@ 125, 082 SAY		STR0010				SIZE 025, 007 OF oGroup8 PIXEL //"Data"
			@ 133, 082 MSGET	oDatOP	VAR dDatOP	SIZE 054, 010 OF oGroup8 PIXEL WHEN .F. HASBUTTON
		EndIf
				
	EndIf
	
    IF !lAutomato
	   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(FA585TOk(nOpc,nValor,cCodFav,cLoja,cCodApr,cMoedSol,cEstado,cCodResp,dDtoper,cOboper,cCodigo,@cCodNat,@dDtPr),(nOpcA:=1,oDlg:End()),Nil)},{||oDlg:End()})
	Else
	   If FindFunction("GetParAuto")
	     IF nOpc == 8 .OR. nOpc == 9 .OR. nOpc == 10
				aRetAuto 	:= GetParAuto("FINA585TESTCASE")
				cOboper 	:= aRetAuto[1] 
		 Else
		     If nOpc == 3 .OR. nOpc == 4 
		        aRetAuto 	:= GetParAuto("FINA585TESTCASE")
		        
				nValor		:= aRetAuto[1]
				cObs 		:= aRetAuto[2]
				cCodApr		:= aRetAuto[3]
				cNomApr		:= UsrFullName(Posicione("FRP",1,xFilial("FRP")+cCodApr,'FRP_USER'))
				cCodFav		:= aRetAuto[4]
				cLoja		:= aRetAuto[5]
				cNomRa		:= Posicione("SA2",1,xFilial("SA2")+(cCodFav + cLoja), "A2_NOME")
				cCodNat		:= aRetAuto[6]
				cNomNat		:= Posicione("SED",1,xFilial("SED")+cCodNat, "ED_DESCRIC")
				dDtPr		:= aRetAuto[7]
				cMoedSol	:= aRetAuto[8]
				cDest		:= aRetAuto[9]
			    cDestch		:= aRetAuto[10]
		        
		      EndIf 
		 EndIf
	   EndIF
	   If(FA585TOk(nOpc,nValor,cCodFav,cLoja,cCodApr,cMoedSol,cEstado,cCodResp,dDtoper,cOboper,cCodigo,@cCodNat,@dDtPr))
		 nOpcA:=1
	   EndIF
	EndIf
Else
	If cPaisLoc == "BRA"
		If FJA->FJA_ESTADO == '2' //Aprovado
			If dDtPr < dDataBase   // Data de Vencimento da Solicita็ใo Menor que a data do Sistema // Nใo pode gravar Titulo PA com data Vencida.
				Help(" ",1,'Help',,STR0083,1,0) //"Data de Vencimento Invalida !"
				Return .F.
			EndIf

			DEFINE MSDIALOG oDlg TITLE STR0075  FROM 000, 000  TO 310, If(cOpc $ '11',500,100) PIXEL //"Gera PA"
			
			oSize := FwDefSize():New(.T.,,,oDlg)
			oSize:lLateral := .F.
			oSize:AddObject( "PAINEL_ESQUERDA",100,100,.T.,.T. )
			oSize:lProp	:= .T.     
			oSize:aMargins := { 3, 3, 3, 3 } 
			oSize:Process()
			oPnlDoc := TPanel():New(oSize:GetDimension("PAINEL_ESQUERDA","LININI"),;
								 oSize:GetDimension("PAINEL_ESQUERDA","COLINI"),;
								,oDlg,,,,,,oSize:GetDimension("PAINEL_ESQUERDA","XSIZE"),;
								oSize:GetDimension("PAINEL_ESQUERDA","YSIZE"),,)
			
			@ 010, 006 GROUP oGroup9 TO 115, 240 PROMPT STR0076  OF oPnlDoc PIXEL //"Dados Adicionais"
			@ 020, 015 SAY		STR0077						SIZE 025, 007 OF oGroup9 PIXEL //"Banco"
			@ 027, 015 MSGET	oBancoAdt	VAR cBancoAdt	SIZE 040, 010 OF oGroup9 PIXEL F3 "SA6" WHEN (cOpc $ '11' .And. !RetGlbLGPD("A6_COD")) OBFUSCATED RetGlbLGPD("A6_COD") Picture "@!"
			@ 020, 090 SAY		STR0078 					SIZE 034, 007 OF oGroup9 PIXEL //"Agencia"
			@ 027, 090 MSGET	oAgenciaAdt	VAR cAgenciaAdt	SIZE 100, 010 OF oGroup9 PIXEL WHEN .F. OBFUSCATED RetGlbLGPD("A6_AGENCIA") Picture "@!"
			@ 042, 015 SAY		STR0079 					SIZE 050, 007 OF oGroup9 PIXEL //"Conta"
			@ 050, 015 MSGET	oNumCon		VAR cNumCon		SIZE 060, 010 OF oGroup9 PIXEL WHEN .F. OBFUSCATED RetGlbLGPD("A6_NUMCON") Picture "@!"
			@ 042, 090 SAY		STR0080 					SIZE 034, 007 OF oGroup9 PIXEL //"Cheque"
			@ 050, 090 MSGET	oChequeAdt	VAR cChequeAdt	SIZE 040, 010 OF oGroup9 PIXEL WHEN !RetGlbLGPD("EF_NUM") OBFUSCATED RetGlbLGPD("EF_NUM") Picture "@!"
			@ 065, 015 SAY		STR0081						SIZE 034, 007 OF oGroup9 PIXEL //"Historico"
			@ 072, 015 MSGET	oHistor		VAR cHistor		SIZE 202, 010 OF oGroup9 PIXEL
			@ 087, 015 SAY		STR0082 			   		SIZE 064, 007 OF oGroup9 PIXEL //"Favorecido"
			@ 096, 015 MSGET	oBenef		VAR cBenef		SIZE 202, 010 OF oGroup9 PIXEL WHEN !RetGlbLGPD("EF_BENEF") OBFUSCATED RetGlbLGPD("EF_BENEF") Picture "@!"
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IF(!Empty(cBancoAdt),(nOpcA:=1,oDlg:End()),Help(" ",1,'Help',,STR0029+","+STR0077,1,0))},{|| nOpcA:=0,oDlg:End()}) //"Preencha o Campo, Banco"


			If nOpcA==1
				nSavSX8E2 := GetSX8Len()
				cCodSE2	:= GetSXENum("SE2","E2_NUM")
				_aTit := {}

				AADD(_aTit , {"E2_NUM"    ,cCodSE2		               	,NIL})
				AADD(_aTit , {"E2_PREFIXO","SOL"                       	,NIL})
				AADD(_aTit , {"E2_PARCELA",""                         	,NIL})
				AADD(_aTit , {"E2_TIPO"   ,"PA "                        ,NIL})
				AADD(_aTit , {"E2_NATUREZ",cCodNat                      ,NIL})
				AADD(_aTit , {"E2_FORNECE",cCodFav                      ,NIL})
				AADD(_aTit , {"E2_LOJA"   ,cLoja                        ,NIL})
				AADD(_aTit , {"E2_EMISSAO",dDataBase                    ,NIL})
				AADD(_aTit , {"E2_VENCTO" ,dDtPr                        ,NIL})
				AADD(_aTit , {"E2_VENCREA",DataValida(dDtPr,.T.)       	,NIL})
				AADD(_aTit , {"E2_VENCORI",DataValida(dDtPr,.T.)       	,NIL})
				AADD(_aTit , {"E2_EMIS1"  ,dDtPr                        ,NIL})
				AADD(_aTit , {"E2_MOEDA"  ,Val(cMoedSol)                ,NIL})
				AADD(_aTit , {"E2_VALOR"  ,nValor                       ,NIL})
				AADD(_aTit , {"E2_VLCRUZ" ,nValor                       ,NIL})
				AADD(_aTit , {"E2_IRRF"   ,0	                        ,NIL})
				AADD(_aTit , {"E2_MULTNAT","1"                         	,NIL})
				AADD(_aTit , {"E2_CODAPRO",cCodApr                     	,NIL})
				AADD(_aTit , {"E2_HIST"   ,cHistor		               	,NIL})
				AADD(_aTit , {"E2_DATALIB",dDataBase					,NIL})
				AADD(_aTit , {"E2_USUALIB",cUsername					,NIL})
				AADD(_aTit , {"E2_STATLIB","03"							,NIL})
				//Dados a serem passados apenas  em caso de inclusao de PA
				AADD(_aTit , {"AUTBANCO"  , cBancoAdt                   ,NIL})
				AADD(_aTit , {"AUTAGENCIA", cAgenciaAdt                 ,NIL})
				AADD(_aTit , {"AUTCONTA"  , cNumCon                     ,NIL})
				AADD(_aTit , {"AUTCHEQUE" , cChequeAdt                  ,NIL})
				AADD(_aTit , {"AUTMOED" , val(cMoedSol)                	,NIL})
			Endif
		Else
			Do Case
				Case FJA->FJA_ESTADO == "1"
					Help(" ",1,'Help',,STR0074+","+STR0017,1,0) //"Opcao nao permitida, Libera็ใo pendente"
					nOpcA:=0
				Case FJA->FJA_ESTADO == "3"
					Help(" ",1,'Help',,STR0074+","+STR0019,1,0) //"Opcao nao permitida, Libera็ใo reprovada"
					nOpcA:=0
				Case FJA->FJA_ESTADO == "4"
					Help(" ",1,'Help',,STR0074+","+STR0020,1,0) //"Opcao nao permitida, Libera็ใo cancelada"
					nOpcA:=0
				Case FJA->FJA_ESTADO == "5"
					Help(" ",1,'Help',,STR0074+","+STR0021,1,0) //"Opcao nao permitida, Libera็ใo paga"
					nOpcA:=0
			EndCase
		Endif
	Endif
EndIf

If nOpcA == 1

	//Processo de gravacao
	FA585Grava(nOpc,cEstado,cCodigo,dData,nValor,cObs,cCodApr,cCodFav,cLoja,;
				cCodNat,dDtPr,cMoedSol,cDest,cDestch,cCodResp,dDtOper,cObOper,_aTit)

ElseIf nOpc == 3

	RollBackSx8()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585GravaบAutor  ณMicrosiga           บ Data ณ  14/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de gravacao do processo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585Grava(nOpc,cEstado,cCodigo,dData,nValor,cObs,cCodApr,cCodFav,cLoja,;
							cCodNat,dDtPr,cMoedSol,cDest,cDestch,cCodResp,dDtOper,cObOper,_aTit)
Local cOldResp	:= ""
Local cOldUser	:= ""
Local lFa585Grv	:= ExistBlock("FA585GRV")
Private lMsErroAuto := .F.
FJA->(dbSetOrder(1))

Do Case

	Case nOpc == 3 //Inclusao
		If !FJA->(dbSeek(xFilial("FJA")+cCodFav+cLoja+cCodigo))
			RecLock("FJA", .T.)
			FJA->FJA_FILIAL	:= xFilial("FJA")
			FJA->FJA_SOLFUN	:= cCodigo
			FJA->FJA_DATA	:= dData
			FJA->FJA_VALOR	:= nValor
			FJA->FJA_OBSERV	:= cObs
			FJA->FJA_CODAPR	:= cCodApr
			FJA->FJA_FORNEC	:= cCodFav
			FJA->FJA_LOJA	:= cLoja
			FJA->FJA_ESTADO	:= cEstado
			FJA->FJA_NATURE	:= cCodNat
			FJA->FJA_DATAPR	:= dDtPr
			FJA->FJA_DESTIN	:= cDest
			If cPaisLoc == "ARG"
		   		FJA->FJA_CUIT	:= cDestch
			EndIf
			FJA->FJA_MOEDA	:= cMoedSol
			FJA->(MsUnLock()) //Confirma e finaliza a operacao

			ConfirmSX8()
		Else
			RollBackSXE()
		EndIf

	Case nOpc == 4 //Alteracao
		If FJA->(dbSeek(xFilial("FJA")+cCodFav+cLoja+cCodigo))
			RecLock("FJA", .F.)
			FJA->FJA_DATA	:= dData
			FJA->FJA_VALOR	:= nValor
			FJA->FJA_OBSERV	:= cObs
			FJA->FJA_CODAPR	:= cCodApr
			FJA->FJA_FORNEC	:= cCodFav
			FJA->FJA_LOJA	:= cLoja
			FJA->FJA_NATURE	:= cCodNat
			FJA->FJA_DATAPR	:= dDtPr
			FJA->FJA_DESTIN	:= cDest
			If cPaisLoc == "ARG"
				FJA->FJA_CUIT	:= cDestch
			EndIf
			FJA->FJA_MOEDA	:= cMoedSol
			FJA->(MsUnLock())
		EndIf

	Case nOpc == 5 //Exclusao

		If FJA->(dbSeek(xFilial("FJA")+cCodFav+cLoja+cCodigo))
			RecLock("FJA", .F.)
			FJA->(dbDelete())
			MsDocument( "FJA", FJA->( RecNo() ), 2, , 3 ) //Exclui documento anexado
			FJA->(MsUnLock())
		EndIf

	Case nOpc == 8 //Aprovacao

		If FJA->(dbSeek(xFilial("FJA")+cCodFav+cLoja+cCodigo))

			//Debita no saldo do responsavel pela aprovacao na tabela FRT - Saldos de Fundo Fixo
			If FXALCGrava(__CUSERID,cCodResp,cMoedSol,"2",dDtoper,nValor)

				//Efetua a aprovacao da solicitacao
				RecLock("FJA", .F.)
				FJA->FJA_RESPON  := cCodResp
				FJA->FJA_DTOPER  := dDtoper
				FJA->FJA_OBOPER  := cOboper
				FJA->FJA_ESTADO  := "2" //Aprovada
				FJA->(MsUnLock())

			Else
				Help( ,, 'HELP',, STR0004, 1, 0) //"Erro ao debitar o saldo do gestor."
			EndIf

		EndIf

	Case nOpc == 9 //Reprovacao

		If FJA->(dbSeek(xFilial("FJA")+cCodFav+cLoja+cCodigo))

			nValor := FJA->FJA_VALOR

			RecLock("FJA", .F.)
			FJA->FJA_RESPON  := cCodResp
			FJA->FJA_DTOPER  := dDtoper
			FJA->FJA_OBOPER  := cOboper
			FJA->FJA_ESTADO  := "3" //Reprovada
			FJA->(MsUnLock())

		EndIf

	Case nOpc == 10 //Cancelamento

		//Obtem o codigo do responsavel pela aprovacao
		If FJA->(dbSeek(xFilial("FJA")+cCodFav+cLoja+cCodigo))
			cOldResp := FJA->FJA_RESPON

			//Obtem o usuario do sistema do responsavel pela aprovacao
			FRP->(dbSetOrder(1)) //FRP_FILIAL+FRP_COD+FRP_MOEDA
			If FRP->(dbSeek(xFilial("FRP")+cOldResp))
				cOldUser := FRP->FRP_USER

				//Estorna o saldo do responsavel pela aprovacao na tabela FRT - Saldos de Fundo Fixo
				If FXALCGrava(cOldUser,cOldResp,cMoedSol,"3",dDtoper,nValor)

					//Efetua o cancelamento da solicitacao
					RecLock("FJA", .F.)
					FJA->FJA_RESPON  := cCodResp
					FJA->FJA_DTOPER  := dDtoper
					FJA->FJA_OBOPER  := cOboper
					FJA->FJA_ESTADO  := "4" //Cancelada
					FJA->(MsUnLock())

				Else
					Help( ,, 'HELP',, STR0005, 1, 0) //"Erro ao estornar o saldo do gestor."
				EndIf

			EndIf

		EndIf

	Case nOpc == 11 //Gera PA  //Paga

			// Salva o PA no SE2 - Contas a Pagar
			//Inclusao de C.Pagar

			//Seto a filial que eu desejar
			cFilAnt := SM0->M0_CODFIL
            nRegEmp  := SM0->(Recno())

			//Chamada da rotina automatica
			//3 = inclusao
			Begin Transaction

				MSExecAuto({|x, y| FINA050(x, y)}, _aTit, 3)

				If  lMsErroAuto

					While (GetSx8Len() > nSavSX8E2)
						RollBackSxE()
					EndDo
					MOSTRAERRO() // Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
				                 // deve ser liberado a funcao mostraerro para ajudar na analise
				Else

					While (GetSx8Len() > nSavSX8E2) 
						ConfirmSX8(.T.)
					EndDo
					RecLock("FJA", .F.)
					FJA->FJA_PREFIX  := _aTit [2][2]
					FJA->FJA_NUMTIT  := _aTit [1][2]
					FJA->FJA_PARCEL  := _aTit [3][2]
					FJA->FJA_TIPO    := _aTit [4][2]
					FJA->FJA_ESTADO  := "5" //Paga
					FJA->(MsUnLock())

				EndIf

			End Transaction

			//Restauro a filial de entrada
			SM0->(dbGoTo(nRegEmp))
			cFilAnt := SM0->M0_CODFIL

EndCase

If lFa585Grv
	ExecBlock("FA585GRV",.F.,.F.,{nOpc,cEstado,cCodigo,dData,nValor,cObs,cCodApr,cCodFav,cLoja,;
				cCodNat,dDtPr,cMoedSol,cDest,cDestch,cCodResp,dDtOper,cObOper }) 
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585Nat  บAutor  ณMicrosiga           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para obter a descricao da natureza                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585Nat(cCodNat,cNomNat,oNomNat)
Local aArea		:= GetArea()
Local aAreaSED	:= SED->(GetArea())
Local lRet		:= .T.

If  !Empty(cCodNat)
	dbSelectArea("SED")
	dbSetOrder(1)

		// Verifica la existencia del c๓digo de la naturaleza y si estแ bloqueado.
		// RegistroOk comprueba el bloqueo (LIB)
		// ExistCpo () volviendo a la ๚ltima posici๓n del SED antes de la ejecuci๓n de la rutina
	If dbSeek(xFilial("SED")+cCodNat)
		If  !(ExistCpo("SED",cCodNat))
			lRet := .F.
		Else
			cNomNat := SED->ED_DESCRIC
			oNomNat:Refresh()
		Endif
	Else
		lRet := .F.
		Help(" ",1,"REGNOIS")
	EndIf
	
ElseIf !Empty(cNomNat)
	cNomNat := CriaVar('ED_DESCRIC',.F.)
	oNomNat:Refresh()
EndIf

RestArea(aAreaSED)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585CodApบAutor  ณMicrosiga           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para obter o nome do aprovador e consistir a moeda  บฑฑ
ฑฑบ          ณ da solicitacao                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585CodAp(cCodApr,cNomApr,oNomApr,cMoedSol)
Local aArea		:= GetArea()
Local aAreaFRP	:= FRP->(GetArea())
Local lRet		:= .T.

If !Empty(cCodApr)
	dbSelectArea("FRP")
	dbSetOrder(1) //FRP_FILIAL+FRP_USER+FRP_MOEDA
	If dbSeek(xFilial("FRP")+cCodApr)
		cNomApr := UsrFullName(FRP->FRP_USER )
		oNomApr:Refresh()

		If !Empty(cMoedSol)
			If !FRP->(dbSeek(xFilial("FRP")+cCodApr+cMoedSol))
				lRet := .F.
				Help(" ",1,'Help',,STR0073,1,0) //"Usuแrio nใo possui cadastro de gestor com a moeda da solicita็ใo."
			EndIf
		EndIf

	Else
		lRet := .F.
		Help(" ",1,"REGNOIS")
	EndIf
ElseIf !Empty(cNomApr)
	cNomApr := CriaVar('FRP_NOME', .F.)
	oNomApr:Refresh()
EndIf

RestArea(aAreaFRP)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585DadFaบAutor  ณMicrosiga           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para obter a loja e o nome do Favorecido (Fornec.)  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585DadFa(cCodFav,cLoja,oLoja,cNomRa,oNomRa,oNomNat,cCodNat,cNomNat)
Local aArea		:= GetArea()
Local aAreaSA2	:= SA2->(GetArea())
Local lRet		:= .T.
Local cA2Loja := SA2->A2_LOJA

If !Empty(cCodFav)

	dbSelectArea("SA2")
	dbSetOrder(1)
	If CCodFav == SA2->A2_COD
		If dbSeek(xFilial("SA2")+CCodFav+cA2Loja)
	
			cLoja := A2_LOJA
			oLoja:Refresh()
	
			cNomRa := A2_NOME
			oNomRa:Refresh()
		Else
			lRet := .F.
			Help(" ",1,"REGNOIS")
		EndIf
	Else
		If dbSeek(xFilial("SA2")+CCodFav)	
			cLoja := A2_LOJA
			oLoja:Refresh()	
			cNomRa := A2_NOME
			oNomRa:Refresh()
		Else
			lRet := .F.
			Help(" ",1,"REGNOIS")
		EndIf
	
	EndIf

ElseIf !Empty(cLoja) .Or. !Empty(cNomRa)

	cLoja := CriaVar('A2_LOJA',.F.)
	oLoja:Refresh()

	cNomRa := CriaVar('A2_NOME',.F.)
	oNomRa:Refresh()

EndIf

RestArea(aAreaSA2)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585CodMoบAutor  ณMicrosiga           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para valida a moeda e o aprovador                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585CodMo(cMoedSol,cCodApr,oCodApr,cNomApr,oNomApr)
Local aArea		:= GetArea()
Local aAreaFRP	:= FRP->(GetArea())
Local lRet		:= .T.

If !Empty(cMoedSol)
	If ExistCpo("CTO",cMoedSol,1)
		If !Empty(cCodApr)
			dbSelectArea("FRP")
			dbSetOrder(1) //FRP_FILIAL+FRP_USER+FRP_MOEDA
			If !FRP->(dbSeek(xFilial("FRP")+cCodApr+cMoedSol))
				lRet := .F.
				Help(,,'Help',,STR0070,1,0)//"Moeda da Solicitacao eh diferente da moeda do aprovador."
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaFRP)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585Doc  บAutor  ณSilvia Monica       บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Anexa documento ao registro do arquivo                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Argentina                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA585Doc(cAlias,nReg,nOpc)

Private cCadastro := STR0030 //'Anexar Documento'

MsDocument( "FJA", FJA->( Recno() ), 3 ) // Inclui/Altera documento anexo

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585PAGTOบAutor  ณSilvia Monica       บ Data ณ  12/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os dados referentes ao pagamento da solicitacao.  บฑฑ
ฑฑบ          ณ Rotina executada na geracao (FINA850) e estorno (FINA086)  บฑฑ
ฑฑบ          ณ do PA.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Argentina                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA585PAGTO(cSolic, cOrdPago, cOper, cFornec, cLoja)
Local aArea	:= GetArea()
Local lRet	:= .T.

dbSelectArea("FRP")
FRP->(dbSetOrder(1)) //FRP_FILIAL+FRP_COD+FRP_MOEDA

If cPaisLoc <> "BRA"
	dbSelectArea("SEK")
	SEK->(dbSetOrder(1))
EndIf
dbSelectArea("FJA")
FJA->(dbSetOrder(4)) //FJA_FILIAL+FJA_SOLFUN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณcOper == E - Estorno da PA ณ
//ณcOper == P - Geracao de PA ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//Valida se o numero da solicitacao ou da ordem de pago estao vazios
If Empty(cSolic) .Or. Empty(cOrdPago)
	lRet := .F.
EndIf

//Valida se encontra a solicitacao na tabela FJA
If lRet .And. FJA->(!dbSeek(xFilial("FJA")+cSolic))
	lRet := .F.
EndIf

//Valida se a solicitacao esta no status Paga ou se o campo ordem de pago nao esta vazio e esta gerando uma PA
If cPaisLoc <> "BRA"
	If lRet .And. (FJA->FJA_ESTADO == "5" .Or. !Empty(FJA->FJA_ORDPAG) ) .And. cOper != "E"
		lRet := .F.
	EndIf
Else
	If lRet .And. FJA->FJA_ESTADO == "5" .And. cOper != "E"
		lRet := .F.
	EndIf
Endif
//Valida se a operacao eh de Estorno e ha ordem de pago registrada
If cPaisLoc <> "BRA"
	If lRet .And. cOper = "E" .And. Empty(FJA->FJA_ORDPAG)
		lRet := .F.
	EndIf
Else
	If lRet .And. cOper = "E"
		lRet := .F.
	EndIf
EndIf
//Valida se localiza a ordem de pago na tabela SEK
If cPaisLoc <> "BRA"
	If lRet .And. SEK->(!dbSeek(xFilial("SEK")+cOrdPago))
		lRet := .F.
	EndIf
EndIf

If lRet
	FJA->(dbSetOrder(1)) //FJA_FILIAL+FJA_FORNEC+FJA_LOJA+FJA_SOLFUN
	If FJA->(dbSeek(xFilial("FJA")+cFornec+cLoja+cSolic))

		If cOper == "P" //Geracao de PA

			//Atualiza a solicitacao
			RecLock("FJA",.F.)
			If cPaisLoc <> "BRA"
				FJA->FJA_ORDPAG := cOrdPago
			EndIf
			FJA->FJA_ESTADO := "5" //Paga
			FJA->(MsUnlock())

		ElseIf cOper == "E" //Estorno da PA

			//Atualiza a solicitacao
			RecLock("FJA",.F.)
			If cPaisLoc <> "BRA"
				FJA->FJA_ORDPAG := CriaVar('FJA_ORDPAG',.F.)
			EndIf
			FJA->FJA_ESTADO := "2" //Aprovada
			FJA->(MsUnlock())

		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585TOk  บAutor  ณMicrosiga           บ Data ณ  13/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados da tela da solicitacao de fundos           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585TOk(nOpc,nValor,cCodFav,cLoja,cCodApr,cMoedSol,cEstado,cCodResp,dDtoper,cOboper,cCodigo,cCodNat,dDtPr)
Local lRet	:= .T.

If nOPc == 3 .Or. nOPc == 4 //Inclusao ou Alteracao

	If  nValor == 0
		lRet := .F.
		Help( ,, 'HELP',, STR0029 + STR0011, 1, 0) //"Preencha o campo "###"Valor"
	EndIf

	If  lRet .And. Empty(cCodFav)
		lRet := .F.
		Help( ,, 'HELP',, STR0029 + STR0009, 1, 0) //"Preencha o campo "###"Codigo"
	EndIf

	If  lRet .And. Empty (cMoedSol)
		lRet := .F.
		Help(,,'Help',,STR0029 + STR0068,1,0) //"Preencha o campo "###"Moeda"
	EndIf

	If  lRet .And. Empty (cCodNat)
		lRet := .F.
		MsgAlert(STR0085) // "Por favor rellene el campo de la modalidad"
	EndIf
	
	If  lRet .And. Empty (dDtPr)
		lRet := .F.
		MsgAlert(STR0086) // "Por favor rellene el campo de fecha prevision"
	EndIf
ElseIf nOPc == 9 .Or. nOPc == 10 //Rejeicao ou Cancelamento

	If Empty(cOboper)
		lRet := .F.
		Help(" ",1,'Help',,STR0029 + STR0012,1,0) //""Preencha o campo "###"Observacao"
	EndIf

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585VldApบAutor  ณMicrosiga           บ Data ณ  14/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta se o usuario eh aprovador, aprovador superior ou  บฑฑ
ฑฑบ          ณ faz parte do mesmo grupo de aprovadores com o nivel igual  บฑฑ
ฑฑบ          ณ ou superior ao aprovador original da solicitacao           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585VldAp(nOpc,cCodAprSol,cCodAprSis,cMoedSol,dDtoper,nValor)
Local aSaveArea		:= GetArea()
Local aAreaFRP		:= FRP->(GetArea())
Local aAreaFRS		:= FRS->(GetArea())
Local lRet			:= .T.
Local lAprovVal		:= .F. //Define se o aprovador eh valido
Local cCodUsrSis	:= __CUSERID
Local lValMaxMin	:= .T.
Local cCodUsrApr	:= "" //Codigo de usuario do sistema do aprovador cadastrado na solicitacao
Local cCodGrupo		:= "" //Codigo do grupo de aprovadores do aprovador cadastrado na solicitacao
Local cNivelApr		:= "" //Nivel no grupo de aprovadores do aprovador cadastrado na solicitacao

Default cCodAprSis	:= "" //Variavel utilizada para retorno do codigo do aprovador via referencia

//Verifica se o usuario possui cadastro na tabela FRP
dbSelectArea("FRP")
FRP->(dbSetOrder(2)) //FRP_FILIAL+FRP_USER+FRP_MOEDA
If FRP->(dbSeek(xFilial("FRP")+cCodUsrSis+cMoedSol))
	cCodAprSis := FRP->FRP_COD
Else
	lRet := .F.
	Help(" ",1,'Help',,STR0073,1,0) //"Usuแrio nใo possui cadastro de gestor com a moeda da solicita็ใo."
EndIf
If lRet
	//Verifica se o usuario da aprovacao eh o aprovador cadastrado na solicitacao
	If cCodAprSis == cCodAprSol
		lAprovVal := .T.

	//Verifica se o usuario da aprovacao eh superior ao aprovador cadastrado na solicitacao
	ElseIf !lAprovVal .And. GetAdvFVal("FRS","FRS_CODSUP",xFilial("FRS")+"2"+cCodAprSol+cCodAprSis,3,"",.T.) == cCodAprSis
		lAprovVal := .T.

	//Verifica se o usuario da aprovacao faz parte do mesmo grupo de aprovadores do aprovador cadastrado na solicitacao e possui nivel igual ou superior
	ElseIf !lAprovVal

		//Obtenho o codigo de usuario do sistema do aprovador cadastrado na solicitacao
		cCodUsrApr := GetAdvFVal("FRP","FRP_USER",xFilial("FRP")+cCodGrupo+cMoedSol,1,"",.T.)

		//Verifico se o aprovador cadastrado na solicitacao faz parte de um grupo de aprovadores
		dbSelectArea("FRR")
		FRR->(dbSetOrder(2)) //FRR_FILIAL+FRR_USER+FRR_MOEDA
		If FRR->(dbSeek(xFilial("FRR")+cCodUsrApr+cMoedSol))
			cCodGrupo	:= FRR->FRR_COD
			cNivelApr	:= FRR->FRR_NIVEL

			//Verifico se o usuario da aprovacao faz parte do mesmo grupo e valido se o nivel eh igual ou superior
			FRR->(dbSetOrder(1)) //FRR_FILIAL+FRR_COD+FRR_MOEDA+FRR_ITEM
			If FRR->(dbSeek(xFilial("FRR")+cCodGrupo+cMoedSol))
				While FRR->(!Eof()) .And. FRR->(FRR_FILIAL+FRR_COD+FRR_MOEDA) == xFilial("FRR")+cCodGrupo+cMoedSol

					If FRR->FRR_CODGES == cCodAprSis

						If Val(FRR->FRR_NIVEL) >= Val(cNivelApr)
							lAprovVal := .T.
						EndIf

						Exit
					EndIf

				FRR->(dbSkip())
				EndDo
			EndIf

		EndIf

	EndIf
	If FRP->FRP_MSBLQL  == '1' //Aprovador desbloqueado
		lRet := .F.
		Help(" ",1,'Help',,STR0084,1,0) //"Usuแrio Bloqueado nใo pode Executar esta fun็ใo"
	Endif

	//Caso o usuario aprovador nao atenda aos requisitos
	If !lAprovVal
		lRet := .F.
		Help(" ",1,'Help',,STR0041,1,0) //"Usuario nใo possui permissใo para esta solicitacao."
	EndIf
	//Validacoes especificas da aprovacao
	If nOpc == 8 //APROVACAO

		//Verifica se o gestor faz parte de grupo isento do processo de analise do valor max e min
		If lRet
			//Obtenho o codigo de usuario do sistema do aprovador cadastrado na solicitacao
  			cCodUsrApr := GetAdvFVal("FRP","FRP_USER",xFilial("FRP")+cCodAprSis+cMoedSol,1,"",.T.)

			//Verifico se o aprovador cadastrado na solicitacao faz parte de um grupo de aprovadores
			dbSelectArea("FRR")
			FRR->(dbSetOrder(2)) //FRR_FILIAL+FRR_USER+FRR_MOEDA
			If FRR->(dbSeek(xFilial("FRR")+cCodUsrApr+cMoedSol))
				cCodGrupo	:= FRR->FRR_COD
				cNivelApr	:= FRR->FRR_NIVEL

				//Verifico se o usuario da aprovacao faz parte do mesmo grupo e valido se o nivel eh igual ou superior
				FRR->(dbSetOrder(1)) //FRR_FILIAL+FRR_COD+FRR_MOEDA+FRR_ITEM
				If FRR->(dbSeek(xFilial("FRR")+cCodGrupo+cMoedSol))
					While FRR->(!Eof()) .And. FRR->(FRR_FILIAL+FRR_COD+FRR_MOEDA) == xFilial("FRR")+cCodGrupo+cMoedSol

						If FRR->FRR_CODGES == cCodAprSis

							If Val(FRR->FRR_NIVEL) >= Val(cNivelApr)
								lAprovVal := .T.
							EndIf

							Exit
						EndIf

						FRR->(dbSkip())
					EndDo
				EndIf

			EndIf


			If GetAdvFVal("FRR","FRR_AUTLIM",xFilial("FRR")+cCodGrupo+cMoedSol,1,"",.T.) == "2"
				lValMaxMin := .F.
			EndIf
		EndIf

		//Valida o valor max e min para aprovacao
		If lRet .And. lValMaxMin
			dbSelectArea("FRP")
			FRP->(dbSetOrder(1)) //FRP_FILIAL+FRP_COD+FRP_MOEDA
			If dbSeek(xFilial("FRP")+cCodAprSis+cMoedSol)
				If nValor < FRP->FRP_LIMMIN
					lRet:=.F.
					Help(,,"HELP",,STR0071,1,0)//o valor da solicitacao e menor que o limite do aprovador
				ElseIf	nValor > FRP->FRP_LIMMAX
					lRet:=.F.
					Help(,,"HELP",,STR0072,1,0)//O valor da solicitacao e maior que o limite do aprovador
				EndIf
			EndIf
		EndIf

		//Valida se o gestor possui saldo suficiente, dentro de seu limite, na data de referencia
		If lRet .And. !FXALCValLi(cCodUsrSis, cCodAprSis, cMoedSol, DtoS(dDtoper), nValor)
			lRet := .F.
			Help(" ",1,'Help',,STR0051,1,0) //"Aprovador sem limite."
		EndIf

	EndIf
Endif
RestArea(aAreaFRS)
RestArea(aAreaFRP)
RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585PreVlบAutor  ณMicrosiga           บ Data ณ  14/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pre-validacao para montagem da tela                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA585PreVl(nOpc)
Local lRet := .T.

Do Case

	Case nOpc == 4 //ALTERACAO
		//Valida se a solicitacao esta no status aprovado.
		If FJA->FJA_ESTADO != "1"
			Help(" ",1,'Help',,STR0003,1,0) //"Opcao nao permitida, pois a Solicitacao nใo esta pendente."
			lRet := .F.
		EndIf

	Case nOpc == 5 //EXCLUSAO
		//Valida se eh exclusao e a solicitacao esta no status pendente
		If FJA->FJA_ESTADO != "1"
			Help(" ",1,'Help',,STR0003,1,0) //"Opcao nao permitida, pois a Solicitacao nao esta pendente."
			lRet := .F.
		EndIf

	Case nOpc == 8 //APROVACAO
		If FJA->FJA_ESTADO != "1"
			Help(" ",1,'Help',,STR0003,1,0) //"Opcao nao permitida, pois a Solicitacao nao esta pendente."
			lRet := .F.
		EndIf

	Case nOpc == 9 //REPROVACAO
		If !(FJA->FJA_ESTADO $ "1")
			Help(" ",1,'Help',,STR0003,1,0) //"Opcao nao permitida, pois a Solicitacao nao esta pendente."
			lRet := .F.
		EndIf

	Case nOpc == 10 //CANCELAMENTO
		If !(FJA->FJA_ESTADO $ "2")
			Help(" ",1,'Help',,STR0043,1,0) //"Op็ใo nใo permitida, pois a Solicita็ใo nใo estแ aprovada."
			lRet := .F.
		EndIf

EndCase

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA585Leg  บAutor  ณSilvia Monica       บ Data ณ  05/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegendas                                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LIBERACAO DE FUNDOS                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA585Leg()

Local aLegenda	:= {{ 'BR_AMARELO'	,STR0017 },;	//"Liberacao Pendente"
					{ 'BR_VERDE'	,STR0018 },;	//"Liberacao Aprovada"
					{ 'BR_VERMELHO'	,STR0019 },;	//"Liberacao Reprovada"
					{ 'BR_PRETO'	,STR0020 },;	//"Liberacao Cancelada"
					{ 'BR_BRANCO'	,STR0021 }}		//"Liberacao Paga"

BrwLegenda(" ",STR0022 ,aLegenda) //"Legenda"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณMicrosiga           บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Opcoes da rotina                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}

aAdd(aRotina, {STR0023	, "AxPesqui"	, 0, 1, 0, .F.}) //"Pesquisar"
aAdd(aRotina, {STR0024	, "FA585OPC"	, 0, 2, 0, nil}) //"Consulta"
aAdd(aRotina, {STR0025	, "FA585OPC"	, 0, 3, 0, nil}) //"Incluir"
aAdd(aRotina, {STR0026	, "FA585OPC"	, 0, 4, 0, nil}) //"Alterar"
aAdd(aRotina, {STR0027	, "FA585OPC"	, 0, 5, 0, nil}) //"Exclui"
aAdd(aRotina, {STR0022	, "FA585Leg"	, 0, 6, 0, nil}) //"Legenda"
aAdd(aRotina, {STR0028	, "FA585Doc"	, 0, 7, 0, nil}) //"Conhecimento"
aAdd(aRotina, {STR0042	, "FA585OPC"	, 0, 8, 0, nil}) //"Aprovar"
aAdd(aRotina, {STR0044	, "FA585OPC"	, 0, 9, 0, nil}) //"Reprovar"
aAdd(aRotina, {STR0046	, "FA585OPC"	, 0,10, 0, nil}) //"Cancelar"
If cPaisLoc == "BRA"
	aAdd(aRotina, {STR0075   , "FA585OPC"	, 0,11, 0, nil}) //"Gera PA"
Endif
Return(aRotina)
