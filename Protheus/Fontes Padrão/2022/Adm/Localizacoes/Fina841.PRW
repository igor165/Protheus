#INCLUDE "FINA841.ch"
#INCLUDE "PROTHEUS.CH"

STATIC lMod2	:= .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  20/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de altera็ใo de cheques em carteira do Recibementos บฑฑ
ฑฑบ          ณ Diversos                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fina841(cRecibo,cSerie,lService,aServMod,aresp)
 
Local cPerg	:= "FINA841"
Default lService := .F.
Default aresp := {}
Default aServMod := {} 
Private lCambio:=.F.

/*
 * Verifica็ใo do processo que estแ configurado para ser utilizado no M๓dulo Financeiro (Argentina)
 */
If lMod2
	If !FinModProc()
		Return
	EndIf
EndIf

/*
 * Verifica se pode ser incluido mov. com essa data
 */
If  !( dtMovFin(dDataBASE,,"2") )
	Return  .F.
EndIf

/*
 * Chamada de Pergunte de Parโmetros para Montagem da Tela de Manuten็ใo de Recibos de Cobran็a
 */
 
If cRecibo != Nil
	MontaTela(cRecibo,cSerie,lService,aServMod,@aresp) 
ElseIf Pergunte(cPerg,.T.)
	MontaTela()
EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  22/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de altera็ใo de cheques em carteira do Recebimentos บฑฑ
ฑฑบ          ณ Diversos                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaTela(cNumRec,cSerRec,lService,aServMod,aresp)

/*
 * Variแveis dos Parโmetros de Pergunte de Filtro da Manuten็ใo de Recibos de Cobran็a
 */
Local nTipoFilt:= Iif(cNumRec==Nil,2,1) //MV_PAR01 // Tipo ? (Recibo/Cheque)
Local cCheque	:= MV_PAR01 // Cheque ?
Local cBcoChq	:= MV_PAR02 // Banco Cheque ?
Local cAgeChq	:= MV_PAR03 // Agencia Cheque ?
Local cCCChq	:= MV_PAR04 // C/C Cheque ?

/*
 * Variแveis do lan็amento contแbil da rotina
 */
Local lGeraLanc	:= .F.  // If( MV_PAR07==1,.T.,.F.)  // Lanctos. On-Line
Local lDigita	:= .F.  //  If( MV_PAR08==1,.T.,.F.)  // Mostra Lanctos.
Local lAglutina	:= .F.  //  If( MV_PAR09==1,.T.,.F.)  // Aglutina Lanctos.

/*
 * Variแveis dos campos do cabe็alho do Recibo
*/
Local oDlgRecibo 	:= Nil
Local oPanelTop		:= Nil
Local oPanel		:= Nil
Local aSize 		:= MSADVSIZE()
Local cTitSer		:= ""
Local oSaySerie		:= Nil
Local oSerie		:= Nil
Local cTitRec		:= ""
Local oSayRecibo	:= Nil
Local oRecibo		:= Nil
Local oSayVersao	:= Nil
Local oVersao		:= Nil
Local cVersao		:= ""
Local cTitEmis		:= ""
Local oSayDtaRef	:= Nil
Local oDataRef		:= Nil
Local dDataRef 		:= dDatabase
Local oSayNatur		:= Nil
Local oNatureza		:= Nil
Local cNatureza		:= Criavar("EL_NATUREZ")
Local cTitCli		:= ""
Local oSayClient	:= Nil
Local oCliente		:= Nil
Local cCliente 		:= CriaVar("EL_CLIENTE")
Local cTitLoja		:= ""
Local oSayLoja		:= Nil
Local oLoja			:= Nil
Local cLoja			:= CriaVar("EL_LOJA")
Local oSayCGC		:= Nil
Local oCGC			:= Nil
Local cCGC			:= CriaVar("A1_CGC")
Local cTitCGC		:= ""
Local oSayNome		:= Nil
Local oNome			:= Nil
Local cNome			:= Criavar("A1_NOME")
Local cTitNom		:= ""
Local oTel			:= Nil
Local cTel			:= CriaVar("A1_TEL")
Local oSayTel		:= Nil
Local cTitTel		:= ""
Local oSayCobrad	:= Nil
Local oCobrador		:= Nil
Local cCobrador		:= CriaVar("EL_COBRAD")
Local cTitCob		:= ""
Local oSayRecProv	:= Nil
Local oRecProv		:= Nil
Local cRecProv		:= CriaVar("EL_RECPROV")
Local cTitProv		:= ""
Local oSayDiario	:= Nil
Local oDiario		:= Nil
Local cDiario		:= CriaVar("EL_DIACTB")
Local cTitDiar		:= ""
Local lUsaSerie		:= GETMV("MV_SERREC",.T.,.F.)
Local lTemItens		:= .F.

/*
 * Variแveis do Grid de Itens do Recibo de Cobran็a
 */
Local aColsSEL		:= {}
Local aHeaderSEL	:= {}

Local nTop			:= 0
Local lSalvou		:= .F.
Local lPanelFin		:= IsPanelFin()

/*
 * Variแveis da consulta do dados do cabe็alho do recibo de cobran็a
 */
Local cQryRecibo := ""
Local cAlsRecibo := GetNextAlias()
Local aRecnoSEL  := {} //Recno dos recibos selecionados
/*
* variables que se ocupan para la edici๓n de Totvs Recibo
*/
Local aService :={}
Local i:= 0
local j:= 0
default lService := .F.
/*
 * Objeto do Grid de Dados da Carteira de Valores
 */
//Private cRecibo	:= MV_PAR02 // Recibo ?
Private cRecibo	:= cNumRec // Recibo ?
Private cSERIE		:= cSerRec // Serie
Private oGetSEL	:= Nil

/*
 * ฺltima revisใo do recibo armazenada
 */
If nTipoFilt == 1
	cVersao	:= F841VERSA(cRecibo,cSerie)
EndIf

cQryRecibo := "SELECT "
cQryRecibo += " SEL.EL_RECIBO, "
cQryRecibo += " SEL.EL_SERIE, "
cQryRecibo += " SEL.EL_NATUREZ, "
cQryRecibo += " SEL.EL_CLIENTE, "
cQryRecibo += " SEL.EL_LOJA, "
cQryRecibo += " EL_CANCEL,"
cQryRecibo += " SA1.A1_CGC, "
cQryRecibo += " SA1.A1_NOME, "
cQryRecibo += " SA1.A1_TEL, "
cQryRecibo += " SEL.EL_COBRAD, "
cQryRecibo += " SEL.EL_RECPROV, "
cQryRecibo += " SEL.EL_DIACTB, "
cQryRecibo += " SEL.EL_TIPODOC "
cQryRecibo += " FROM " + RetSqlName("SEL") + " SEL "
cQryRecibo += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQryRecibo += " ON SEL.EL_CLIENTE = SA1.A1_COD AND SEL.EL_LOJA = SA1.A1_LOJA "
cQryRecibo += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQryRecibo += " ON SEL.EL_PREFIXO = SE1.E1_PREFIXO AND SEL.EL_NUMERO = SE1.E1_NUM AND SEL.EL_PARCELA = SE1.E1_PARCELA "
cQryRecibo += " AND SEL.EL_CLIENTE = SE1.E1_CLIENTE AND SEL.EL_LOJA = SE1.E1_LOJA "
cQryRecibo += " WHERE "
If nTipoFilt == 1
	If cSerie <> Nil .And.SuperGetMV('MV_SERREC')
		cQryRecibo += " SEL.EL_SERIE = '" + cSerie + "' AND "
	Endif
	cQryRecibo += " SEL.EL_RECIBO = '" + cRecibo + "' AND "
	cQryRecibo += " SEL.EL_VERSAO = '" + cVersao + "' AND "
ElseIf nTipoFilt == 2
	cQryRecibo += " SEL.EL_NUMERO = '" + cCheque + "' AND "
	cQryRecibo += " SEL.EL_BCOCHQ = '" + cBcoChq + "' AND "
	cQryRecibo += " SEL.EL_AGECHQ = '" + cAgeChq + "' AND "
	cQryRecibo += " SEL.EL_CTACHQ = '" + cCCChq  + "' AND "
EndIf
	cQryRecibo += "SEL.EL_CANCEL <> 'T'  AND "

cQryRecibo += RetSqlCond("SEL") + " AND "
cQryRecibo += RetSqlCond("SE1") + " AND "
cQryRecibo += RetSqlCond("SA1")

cQryRecibo	:= ChangeQuery(cQryRecibo)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRecibo),cAlsRecibo,.T.,.T.)

While (cAlsRecibo)->(!Eof())
	cNatureza	:= (cAlsRecibo)->EL_NATUREZ
	cCliente	:= (cAlsRecibo)->EL_CLIENTE
	cLoja		:= (cAlsRecibo)->EL_LOJA
	cCGC		:= (cAlsRecibo)->A1_CGC
	cNome		:= (cAlsRecibo)->A1_NOME
	cTel		:= (cAlsRecibo)->A1_TEL
	cCobrador	:= (cAlsRecibo)->EL_COBRAD
	cRecProv	:= (cAlsRecibo)->EL_RECPROV
	cDiario		:= (cAlsRecibo)->EL_DIACTB
	If nTipoFilt == 2
		cRecibo := (cAlsRecibo)->EL_RECIBO
		If SuperGetMV('MV_SERREC')
			cSerie	:=	(cAlsRecibo)->EL_SERIE
		Else
			cSerie	:=		CriaVar("EL_SERIE")
		Endif
	EndIf
	If AllTrim((cAlsRecibo)->EL_TIPODOC) == "CH"
		lTemItens := .T.
	EndIf
	(cAlsRecibo)->(DbSkip())
EndDo
(cAlsRecibo)->(DbCloseArea())


/*
 * ฺltima revisใo do recibo armazenada
 */
If nTipoFilt == 2
	cVersao	:= F841VERSA(cRecibo,cSerie)
EndIf

/*
 * aHeader do Grid de Itens (Cheques) do Recibo de Cobran็a
 */
aHeaderSEL := CriaHeader()

/*
 * Monta a array com os campos que poderใo ser alterados
 */
aCpoAlter := {}
aAdd(aCpoAlter,"EL_NUMERO")
aAdd(aCpoAlter,"EL_BCOCHQ")
aAdd(aCpoAlter,"EL_AGECHQ")
aAdd(aCpoAlter,"EL_CTACHQ")
aAdd(aCpoAlter,"EL_POSTAL")
aAdd(aCpoAlter,"EL_TERCEIR")
aAdd(aCpoAlter,"EL_ENDOSSA")
aAdd(aCpoAlter,"EL_CGC")
aAdd(aCpoAlter,"EL_EMISSAO")
aAdd(aCpoAlter,"EL_DTVCTO")
aAdd(aCpoAlter,"EL_SELDOC")

/*
 * Cria aCols do Recibo Informado nos parโmetros
 */

aColsSEL := CriaAcols(aHeaderSEL,cRecibo,cVersao,cCheque,@aRecnoSEL,cSerie)

/*
 * S๓ exibir itens do recibo se existirem cheques disponํveis para manuten็ใo
 */

If Len(aColsSEL) == 0
	lTemItens := .F.
EndIf

/*
 * Se nใo existerem itens de cheque para altera็ใo, o recibo nใo ้ exibido para manuten็ใo
 */
If !lTemItens
	MsgAlert(STR0001) //"Recibo de Cobran็a sem itens disponํveis para manuten็ใo."
	Return .F.
EndIf

/*
 * Montagem do Dialog da tela do Recibo de Cobran็a
 * Cabe็alho do Recibo
 */
If !lService
oDlgRecibo := TDialog():New(;
						aSize[7],;				// [1] Distโncia do top da tela (pixels)
						0,;						// [2] Distโncia da esquerda da tela (pixels)
						aSize[6],;				// [3] Altura da tela (pixels)
						aSize[5],;				// [4] Largura da tela (pixels)
		   				"",;					// [5] Tํtulo da Tela (pixels)
						Nil,;					// [6] Nil
						Nil,;					// [7] Nil
						Nil,;					// [8] Nil
						Nil,;					// [9] Nil
						Nil,;					// [10] Cor do Texto Ex.: CLR_BLACK,CLR_WHITE
						Nil,;					// [11] Cor do Fundo Ex.: CLR_BLACK,CLR_WHITE
						Nil,;					// [12] Nil
						oMainWnd,;				// [13] Objeto da Tela Principal do Sistema
						.T.)					// [14] Considera pixel nas dimens๕es da tela

oDlgRecibo:lMaximized := .T.

/*
 * Painel onde serใo dispostos os campos do cabe็alho do recibo de cobran็a
 */
oPanelTop := TPanel():New(;
						000,; 											// [1] Distโncia do top da tela (pixels)
						000,; 											// [2] Distโncia da esquerda da tela (pixels)
						"",; 											// [3] Tํtulo do Painel
						oDlgRecibo,;									// [4] Objeto da Tela onde o Painel ficarแ
						Nil,;											// [5] Objeto da Fonte do Painel (TFont)
						Nil,;											// [6] Indica se o texto ficarแ Centralizado
						Nil,;											// [7] Nil
						Nil,;											// [8] Cor do Texto do Painel
						Nil,;											// [9] Cor do Fundo do Painel
						370,;											// [10] Largura do Painel (pixels)
						70)												// [11] Altura do Painel (pixels)

oPanelTop:Align := CONTROL_ALIGN_TOP // Alinhando os painel no topo da janela

/*
 * Espa็o do Topo da Pแgina do Cabe็alho do Recibo de Cobran็a
 */
nTop+=003

/*
 * Campos do cabe็alho do recibo de cobran็a
 * S้rie do Recibo
 */
Posicione("SX3",2,"EL_SERIE","X3_TITULO")
cTitSer := AllTrim(X3TITULO())

If lUsaSerie // Verifica se serแ utilizada a s้rie no processo de recibos de cobran็a
	oSaySerie := TSay():New(;
						nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
						005,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
						{|| STR0004},; 	// [3] Texto do Objeto que serแ exibido //"Serie/Recibo"
						oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
						Nil,;			// [5] Picture do Texto do Objeto
						Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
						Nil,;			// [7] Nil
						Nil,; 			// [8] Nil
						Nil,;			// [9] Nil
						.T.,;			// [10] Considera pixel nas dimens๕es da tela
						Nil,;			// [11] Cor do Texto do Objeto
						Nil,;			// [12] Cor do Fundo do Objeto
						040,;			// [13] Largura do Objeto (pixels)
						015,;			// [14] Altura do Objeto (pixels)
						Nil,;			// [15] Nil
						Nil,;			// [16] Nil
						Nil,;			// [17] Nil
						Nil,;			// [18] Nil
						Nil,;			// [19] Nil
						Nil)			// [20] Se exibe texto com HTML

	oSerie	:= TGet():New(;
						nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
						050,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
						{|u| Iif( PCount() > 0, cSerie := u, cSerie)},;		// [3] Texto do Objeto que serแ exibido
						oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
						020,;												// [5] Largura do Objeto (pixels)
						008,;												// [6] Altura do Objeto (pixels)
						PesqPict("SEL","EL_SERIE",TamSX3("EL_SERIE")[1]),;  // [7] Picture do Texto do Objeto
						Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
						Nil,;												// [9] Cor do Texto do Objeto
						Nil,;												// [10] Cor do Fundo do Objeto
						Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
						.F.,;												// [12] Nil
						Nil,;												// [13] Nil
						.T.,;												// [14] Considera pixel nas dimens๕es da tela
						Nil,;												// [15] Nil
						.F.,;												// [16] Nil
						{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
						.F.,;												// [18] Nil
						.F.,;												// [19] Nil
						Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
						.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
						.F.,;												// [22] Se ้ campo de Senha
						"",;												// [23] Nil
						"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
						Nil,;												// [25] Nil
						Nil,;												// [26] Nil
						Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
						Nil)												// [28] Indica o uso de Consulta Padrใo (F3)
EndIf

/*
 * Campos do cabe็alho do recibo de cobran็a
 * N๚mero do Recibo
 */
Posicione("SX3",2,"EL_RECIBO"	,"X3_TITULO")
cTitRec := AllTrim(X3TITULO())

oSayRecibo	:= TSay():New(;
					nTop+3,;   						// [1] Inํcio da Objeto na Vertical "x" (pixels)
					Iif(lUsaSerie,085,005),; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| Iif(lUsaSerie,"-", STR0002 )},;	// [3] Texto do Objeto que serแ exibido // "Recibo"
					oPanelTop,;		 				// [4] Objeto do Painel onde ficarแ disposto
					Nil,;							// [5] Picture do Texto do Objeto
					Nil,;							// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;							// [7] Nil
					Nil,; 							// [8] Nil
					Nil,;							// [9] Nil
					.T.,;							// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;						// [11] Cor do Texto do Objeto
					Nil,;							// [12] Cor do Fundo do Objeto
					040,;							// [13] Largura do Objeto (pixels)
					015,;							// [14] Altura do Objeto (pixels)
					Nil,;							// [15] Nil
					Nil,;							// [16] Nil
					Nil,;							// [17] Nil
					Nil,;							// [18] Nil
					Nil,;							// [19] Nil
					Nil)							// [20] Se exibe texto com HTML

oRecibo := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					Iif(lUsaSerie,090,035),;								// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cRecibo := u, cRecibo)},;	// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					075,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SEL","EL_RECIBO",TamSX3("EL_RECIBO")[1]),;  // [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;			  									// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Revisใo do Recibo
 */
oSayVersao	:= TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					180,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| STR0003 },;// [3] Texto do Objeto que serแ exibido //"Revisใo"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					Nil,;			// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oVersao := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					220,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cVersao := u, cVersao)},;	// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					020,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SEL","EL_VERSAO",TamSX3("EL_VERSAO")[1]),;// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;			  									// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Pr๓xima linha do cabe็alho do Recibo de Cobran็a
 */
nTop+=013

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Data de Emissใo do Recibo
 */
Posicione("SX3",2,"EL_EMISSAO"	,"X3_TITULO")
cTitEmis:= AllTrim(X3TITULO())

oSayDtaRef := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					005,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitEmis},;	// [3] Texto do Objeto que serแ exibido //"Emissao"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oDataRef := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					035,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, dDataRef := u, dDataRef)},;	// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					054,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					Nil,; 												// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;			   									// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Natureza Financeira
 */
oSayNatur := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					100,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| STR0005},;	// [3] Texto do Objeto que serแ exibido // "Natureza"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oNatureza := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					140,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cNatureza := u, cNatureza)},;// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					075,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					Nil,; 												// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;												// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Pr๓xima linha do cabe็alho do Recibo de Cobran็a
 */
nTop+=013

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Cliente
 */
Posicione("SX3",2,"EL_CLIENTE"	,"X3_TITULO")
cTitCli := AllTrim(X3TITULO())

oSayClient := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					005,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitCli},;	// [3] Texto do Objeto que serแ exibido  //"Cliente"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oCliente := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					035,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cCliente := u, cCliente)},;	// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					050,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SEL","EL_CLIENTE",TamSX3("EL_CLIENTE")[1]),;// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;			 									// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Loja do Cliente
 */
Posicione("SX3",2,"EL_LOJA"		,"X3_TITULO")
cTitLoja:= AllTrim(X3TITULO())

oSayLoja := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					090,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitLoja},;	// [3] Texto do Objeto que serแ exibido  //"Loja"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oLoja := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					120,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cLoja := u, cLoja)},;		// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					020,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SEL","EL_LOJA",TamSX3("EL_LOJA")[1]),;	// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;					  							// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)


/*
 * Campos do cabe็alho do recibo de cobran็a
 * CPF/CPNJ/CUIT do Cliente
 */
Posicione("SX3",2,"A1_CGC"		,"X3_TITULO")
cTitCGC := AllTrim(X3TITULO())

oSayCGC := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					180,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitCGC},;	// [3] Texto do Objeto que serแ exibido  //"CGC"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					030,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oCGC := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					215,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cCGC := u, cCGC)},;			// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					055,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SA1","A1_CGC",TamSX3("A1_CGC")[1]),;		// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;		 										// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Pr๓xima linha do cabe็alho do Recibo de Cobran็a
 */
nTop+=013

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Nome do Cliente
 */
Posicione("SX3",2,"A1_NOME"		,"X3_TITULO")
cTitNom := AllTrim(X3TITULO())

oSayNome := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					005,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitNom},;	// [3] Texto do Objeto que serแ exibido  //"Nome"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oNome := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					035,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cNome := u, cNome)},;		// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					235,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SA1","A1_NOME",TamSX3("A1_NOME")[1]),;	// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;												// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Pr๓xima linha do cabe็alho do Recibo de Cobran็a
 */
nTop+=013

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Telefone do Cliente
 */
Posicione("SX3",2,"A1_TEL"		,"X3_TITULO")
cTitTel := AllTrim(X3TITULO())

oSayTel := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					005,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitTel},;	// [3] Texto do Objeto que serแ exibido  //"Tel. "
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oTel := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					035,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif( PCount() > 0, cTel := u, cTel)},;			// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					040,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SA1","A1_TEL",TamSX3("A1_CGC")[1]),;		// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;  												// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Campos do cabe็alho do recibo de cobran็a
 * Cobrador do Recibo
 */
Posicione("SX3",2,"EL_COBRAD"	,"X3_TITULO")
cTitCob:= AllTrim(X3TITULO())

oSayCobrad := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					090,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitCob},;	// [3] Texto do Objeto que serแ exibido  //"Cobrador"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oCobrador := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					120,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif(PCount() > 0, cCobrador := u, cCobrador)},;// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					050,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SEL","EL_COBRAD",TamSX3("EL_COBRAD")[1]),;// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;		 										// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
				{ || .F.},;												// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

/*
 * Campos do cabe็alho do recibo de cobran็a
 * N๚mero do Recibo Provis๓rio
 */
Posicione("SX3",2,"EL_RECPROV","X3_TITULO")
cTitProv:= AllTrim(X3TITULO())

oSayRecProv := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					180,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitProv},;	// [3] Texto do Objeto que serแ exibido  //"Recibo Provisorio"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

oRecProv := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					215,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif(PCount() > 0, cRecProv := u, cRecProv)},;	// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					075,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SEL","EL_RECPROV",TamSX3("EL_RECPROV")[1]),;// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;	 											// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)

@ 001, 001 TO 070,390  OF oPanelTop  PIXEL //"Dados Gerais"

/*
 * Campos do cabe็alho do recibo de cobran็a
 * N๚mero Sequ๊ncia do Correlativo
 */
If UsaSeqCor()
	cDiario		:=	Criavar("EL_DIACTB",.T.)
	Posicione("SX3",2,"EL_DIACTB","X3_TITULO")
	cTitDiar	:=	AllTrim(X3TITULO())
	oSayDiario := TSay():New(;
					nTop+3,; 		// [1] Inํcio da Objeto na Vertical "x" (pixels)
					305,; 			// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|| cTitProv},;	// [3] Texto do Objeto que serแ exibido  //"Recibo Provisorio"
					oPanelTop,;		// [4] Objeto do Painel onde ficarแ disposto
					Nil,;			// [5] Picture do Texto do Objeto
					Nil,;			// [6] Objeto da Fonte utilizada no texto do objeto (TFont)
					Nil,;			// [7] Nil
					Nil,; 			// [8] Nil
					Nil,;			// [9] Nil
					.T.,;			// [10] Considera pixel nas dimens๕es da tela
					CLR_BLACK,;		// [11] Cor do Texto do Objeto
					Nil,;			// [12] Cor do Fundo do Objeto
					040,;			// [13] Largura do Objeto (pixels)
					015,;			// [14] Altura do Objeto (pixels)
					Nil,;			// [15] Nil
					Nil,;			// [16] Nil
					Nil,;			// [17] Nil
					Nil,;			// [18] Nil
					Nil,;			// [19] Nil
					Nil)			// [20] Se exibe texto com HTML

	oDiario := TGet():New(;
					nTop+1,;											// [1] Inํcio da Objeto na Vertical "x" (pixels)
					340,;												// [2] Inํcio da Objeto na Horizontal "y" (pixels)
					{|u| Iif(PCount() > 0, cDiario := u, cDiario)},;	// [3] Texto do Objeto que serแ exibido
					oPanelTop,;											// [4] Objeto do Painel onde ficarแ disposto
					020,;												// [5] Largura do Objeto (pixels)
					008,;												// [6] Altura do Objeto (pixels)
					PesqPict("SEL","EL_RECPROV",TamSX3("EL_RECPROV")[1]),;// [7] Picture do Texto do Objeto
					Nil,;												// [8] Bloco de C๓digo da Valida็ใo do Campo
					Nil,;											// [9] Cor do Texto do Objeto
					Nil,;												// [10] Cor do Fundo do Objeto
					Nil,;												// [11] Objeto da Fonte utilizada do Texto do campo (TFont)
					.F.,;												// [12] Nil
					Nil,;												// [13] Nil
					.T.,;												// [14] Considera pixel nas dimens๕es da tela
					Nil,;												// [15] Nil
					.F.,;												// [16] Nil
					{ || .F.},;											// [17] Bloco de C๓digo do Modo de Edi็ใo do Campo (WHEN)
					.F.,;												// [18] Nil
					.F.,;												// [19] Nil
					Nil,;												// [20] Bloco de C๓digo que ้ executado quando o conte๚do do campo ้ modificado
					.F.,;												// [21] Indica se o campo ficarแ em modo "Visualizar"
					.F.,;												// [22] Se ้ campo de Senha
					"",;												// [23] Nil
					"",;												// [24] Indica qual variแvel serแ utilizado para o objeto
					Nil,;												// [25] Nil
					Nil,;												// [26] Nil
					Nil,;												// [27] Indica o uso de bot๕es (Calendแrio, calculadora)
					Nil)												// [28] Indica o uso de Consulta Padrใo (F3)
Endif

/*
 * Cria็ใo do Objeto do Painel onde se encontra as informa็๕es do Recibo de Cobran็a
 */
oPanel := TPanel():New(000,000,,oDlgRecibo,,,,,,350,110,.F.,.F.)

oPanel:Align := CONTROL_ALIGN_ALLCLIENT


oGetSEL := MsNewGetDados():New(;
	000								,; // [1] Distโncia entre a MsNewGetDados e o extremidade superior do objeto que a cont้m
	000								,; // [2] Distโncia entre a MsNewGetDados e o extremidade esquerda do objeto que a cont้m
	109								,; // [3] Distโncia entre a MsNewGetDados e o extremidade inferior do objeto que a cont้m
	331								,; // [4] Distโncia entre a MsNewGetDados e o extremidade direita do objeto que a cont้m
	GD_UPDATE						,; // [5] Modo de Edi็ใo
	"Fa841LinOk(oGetSEL,cRecibo,cSerie)"	,; // [6] Valida็ใo do LinhaOk
	"AlwaysTrue()"					,; // [7] Valida็ใo do TudoOk
	"D1_ITEM"						,; // [8] Campos com incremento automแtico
	aCpoAlter						,; // [9] Array de campos alterแveis
	Nil								,; // [10] Congela a coluna da esquerda para a direita. Se 0 nใo congela, se 1 congela a primeira coluna. Obs: atualmente s๓ ้ possivel congelar a primeira coluna, devido a limita็ใo do objeto.
	Nil								,; // [11] N๚mero mแximo de linhas permitidas, valor padrใo 99
	"Fa841CpoOk(oGetSEL)"		,; // [12] Fun็ใo Executada na Valida็ใo de Campo
	"AlwaysTrue()"					,; // [13] Fun็ใo executada quando pressionada as teclas +
	"AlwaysTrue()"					,; // [14] Fun็ใo executada para validar a exclusใo de uma linha do aCols.
	oPanel							,; // [15] Objeto da Janela onde ficarแ o objeto
	aHeaderSEL						,; // [16] Array do aHeader do objeto
	aColsSEL)				  		   // [17] Arrar do aCols do objeto

oGetSel:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetSel:SetEditLine(.T.)

If lPanelFin
	ACTIVATE DIALOG oDlgRecibo ON INIT FaMyBar(oDlgRecibo,{|| MsAguarde({|| lSalvou := Fa841TudoOk(oGetSEL,cRecibo,cSerie) .AND. Fa841Salvar(oGetSEL,cRecibo,cVersao,dDataRef,lDigita,lGeraLanc,lAglutina,aRecnoSEL,cSerie)}),If(lSalvou,oDlgRecibo:End(),Nil) },{|| oDlgRecibo:End()})
Else
	ACTIVATE DIALOG oDlgRecibo ON INIT EnchoiceBar(oDlgRecibo,{|| MsAguarde({|| lSalvou := Fa841TudoOk(oGetSEL,cRecibo,cSerie) .AND. Fa841Salvar(oGetSEL,cRecibo,cVersao,dDataRef,lDigita,lGeraLanc,lAglutina,aRecnoSEL,cSerie)}),If(lSalvou,oDlgRecibo:End(),Nil) },{|| oDlgRecibo:End()})
Endif

Else  //else lService

	for i := 1 to len(aColsSEL)
		aColsSEL[i][4] 	:= aServMod[1][i]["numero"]
		aColsSEL[i][5] 	:= aServMod[1][i]["bcochq"]
		aColsSEL[i][6] 	:= aServMod[1][i]["agechq"]
		aColsSEL[i][7] 	:= aServMod[1][i]["ctachq"]
		aColsSEL[i][8] 	:= aServMod[1][i]["postal"]
		aColsSEL[i][14] := aServMod[1][i]["terceir"]
		aColsSEL[i][15] := aServMod[1][i]["endossa"]
		aColsSEL[i][16] := aServMod[1][i]["cgc"]
		aColsSEL[i][17] := stod(aServMod[1][i]["emissao"])
		aColsSEL[i][18] := stod(aServMod[1][i]["dtvcto"])
		aColsSEL[i][19] := aServMod[1][i]["seldoc"]
	Next 
	aAdd(aService,aHeaderSEL )
	aAdd(aService,aColsSEL )
	for j:=1 to len(aService[2])
		If 	Fa841LinOk(,cRecibo,cSerie,lService,aService,j,@aresp,aServMod)
			If  Fa841CpoOk(,lService,aService,j,@aresp,aServMod)
				lSalvou := .T.
			Else 
				lSalvou := .F.
			EndIf
		Else 
			lSalvou := .F.
		EndIF
	Next
	If lSalvou
		If Fa841TudoOk(,cRecibo,cSerie,lService,aService,@aresp) 
			Fa841Salvar(,cRecibo,cVersao,dDataRef,lDigita,lGeraLanc,lAglutina,aRecnoSEL,cSerie,lService,aService,@aresp)
		Else 
			lSalvou := .F.
		EndIF	
		
	EndIF
	If lSalvou
		aadd(aresp,"") 
		aadd(aresp,.T.)
	EndIf

	EndIf //EndIf lService

Return lSalvou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  23/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o aHeader do Grid de itens do Recibo de Cobran็a	 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaHeader()

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aCpoAls	:= {}
Local aHeader	:= {}
Local nContCpo	:= 0
Local cTitulo	:= ""

aAdd(aCpoAls, {"SD1","D1_ITEM"} )
aAdd(aCpoAls, {"SEL","EL_TIPO"} )
aAdd(aCpoAls, {"SEL","EL_TIPODOC"} )
aAdd(aCpoAls, {"SEL","EL_NUMERO"} )
aAdd(aCpoAls, {"SEL","EL_BCOCHQ"} )
aAdd(aCpoAls, {"SEL","EL_AGECHQ"} )
aAdd(aCpoAls, {"SEL","EL_CTACHQ"} )
aAdd(aCpoAls, {"SEL","EL_POSTAL"} )
aAdd(aCpoAls, {"SEL","EL_PREFIXO"} )
aAdd(aCpoAls, {"SE1","E1_NUM"} )
aAdd(aCpoAls, {"SEL","EL_PARCELA"} )
aAdd(aCpoAls, {"SEL","EL_VALOR"} )
aAdd(aCpoAls, {"SEL","EL_MOEDA"} )
aAdd(aCpoAls, {"SEL","EL_TERCEIR"} )
aAdd(aCpoAls, {"SEL","EL_ENDOSSA"} )
aAdd(aCpoAls, {"SEL","EL_CGC"} )
aAdd(aCpoAls, {"SEL","EL_EMISSAO"} )
aAdd(aCpoAls, {"SEL","EL_DTVCTO"} )
aAdd(aCpoAls, {"SEL","EL_SELDOC"} )

SX3->(dbSetOrder(2)) // Campo Num. Cheque
For nContCpo := 1 To Len(aCpoAls)
	SX3->(dbSeek(aCpoAls[nContCpo][2]))
	While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == aCpoAls[nContCpo][1] .AND. AllTrim(SX3->X3_CAMPO) == aCpoAls[nContCpo][2]
		If (cNivel >= SX3->X3_NIVEL) .AND. (X3USO(SX3->X3_USADO))

			cTitulo := If(aCpoAls[nContCpo][2] $ "EL_NUMERO", STR0006 , AllTrim( X3Titulo() )) // "Num. Cheque"

			aAdd( aHeader, { cTitulo		,;		// 01 - Titulo
							SX3->X3_CAMPO	,;		// 02 - Campo
							SX3->X3_PICTURE	,;		// 03 - Picture
							SX3->X3_TAMANHO	,;		// 04 - Tamanho
							SX3->X3_DECIMAL	,;		// 05 - Decimal
							"AlwaysTrue()"	,;		// 06 - Valid
							SX3->X3_USADO  	,;		// 07 - Usado
							SX3->X3_TIPO   	,;		// 08 - Tipo
							SX3->X3_F3		,;		// 09 - F3
							SX3->X3_CONTEXT ,;    	// 10 - Contexto
							X3CBox()		,; 	 	// 11 - ComboBox
							SX3->X3_RELACAO , } )  	// 12 - Relacao
		Endif
		SX3->(dbSkip())
	EndDo
Next nContCpo

RestArea(aAreaSX3)
RestArea(aArea)

Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  26/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o aCols do Grid de itens do Recibo de Cobran็a		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณcRecibo : N๚mero do recibo em manuten็ใo                    บฑฑ
ฑฑบ          ณcRevisao: Revisใo do recibo em manuten็ใo			          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcols(aHeader,cRecibo,cRevisao,cCheque,aRecnoSEL,cSerie)
Local nContCols	:= 0
Local nCols    	:= 0
Local aArea		:= GetArea()
Local aAreaSEL	:= {}
Local cQrySEL	:= ""
Local cAlsSEL	:= GetNextAlias()
Local aCols		:= {}
Local cCodDev	:= CriaVar("EF_ALINEA1")
Local dDtDev	:= CriaVar("EF_DTALIN1")

Default cRecibo 	:= CriaVar("EL_RECIBO")
Default cRevisao 	:= CriaVar("EL_VERSAO")
Default cCheque 	:= CriaVar("EF_NUM")

DbSelectArea("SEL")
aAreaSEL := SEL->(GetArea())

cQrySEL := " SELECT "
cQrySEL += " SEL.EL_FILIAL, "
cQrySEL += " SEL.R_E_C_N_O_ SELRECNO "
For nContCols := 2 To Len(aHeader) // Desconsidera o primeiro campo de item
	cQrySEL += ", " + aHeader[nContCols][2]
Next nContCols
cQrySEL += " FROM " + RetSqlName("SEL") + " SEL "
cQrySEL += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON SEL.EL_PREFIXO = SE1.E1_PREFIXO "
cQrySEL += " AND SEL.EL_NUMERO = SE1.E1_NUM "
cQrySEL += " AND SEL.EL_PARCELA = SE1.E1_PARCELA "
cQrySEL += " AND SEL.EL_CLIENTE = SE1.E1_CLIENTE "
cQrySEL += " AND SEL.EL_LOJA = SE1.E1_LOJA "
cQrySEL += " AND SEL.EL_TIPODOC = SE1.E1_TIPO "
cQrySEL += " AND SEL.D_E_L_E_T_ = ' ' "
cQrySEL += " INNER JOIN " + RetSqlName("SEF") + " SEF ON SEF.EF_TITULO = SE1.E1_RECIBO "
cQrySEL += " AND SEF.EF_NUM = SE1.E1_NUM "
cQrySEL += " AND SEF.EF_PREFIXO = SE1.E1_PREFIXO "
cQrySEL += " AND SEF.EF_PARCELA = SE1.E1_PARCELA "
cQrySEL += " AND SEF.EF_TIPO = SE1.E1_TIPO "
cQrySEL += " AND SEF.EF_CLIENTE = SE1.E1_CLIENTE "
cQrySEL += " AND SEF.EF_LOJACLI = SE1.E1_LOJA "
cQrySEL += " AND SEF.EF_BANCO = SEL.EL_BCOCHQ "
cQrySEL += " AND SEF.EF_AGENCIA = SEL.EL_AGECHQ "
cQrySEL += " AND SEF.EF_CONTA = SEL.EL_CTACHQ "
cQrySEL += " WHERE "
cQrySEL += " SEF.EF_FILIAL = '" + xFilial("SEF") + "'AND  "
cQrySEL += " SEL.EL_FILIAL = '" + xFilial("SEL") + "'AND  "
cQrySEL += " SEL.EL_TIPODOC = 'CH' AND "
cQrySEL += " SEL.EL_CANCEL <> 'T'  AND "
cQrySEL += " SEL.EL_RECIBO = '" + cRecibo + "' AND "
cQrySEL += " SEL.EL_VERSAO = '" + cRevisao + "' AND "
If cSerie <> Nil .And.SuperGetMV('MV_SERREC')
	cQrySel += " SEL.EL_SERIE = '" + cSerie + "' AND "
Endif
If AllTrim(cCheque) <> ""
	cQrySEL += " SEF.EF_NUM = '" + cCheque + "' AND "
EndIf
cQrySEL += " SEF.EF_CART = 'R' AND "   // Carteira Contas a Receber
cQrySEL += " SEF.EF_STATUS = '01' AND " // Cheque em Carteira
cQrySEL += " SEF.EF_ALINEA1 = '" + cCodDev + "' AND " // C๓digo da Primeira Devolu็ใo de Cheque em Branco
cQrySEL += " SEF.EF_DTALIN1 = '" + DTOS(dDtDev) + "' AND " // Data da Primeira Devolu็ใo de Cheque em Branco
cQrySEL += " SEF.D_E_L_E_T_ = '' AND "
cQrySEL +=  RetSqlCond("SEL")
cQrySEL += " ORDER BY SEL.EL_NUMERO " // Ordena็ใo pelo n๚mero dos cheques

cQrySEL	:= ChangeQuery(cQrySEL)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySEL),cAlsSEL,.T.,.T.)
//TcSetField(cAlsSEL, "EL_EMISREC", 	"D")
TcSetField(cAlsSEL, "EL_EMISSAO", 	"D")
TcSetField(cAlsSEL, "EL_DTVCTO", 	"D")
TcSetField(cAlsSEL, "EL_DTDIGIT", 	"D")
TcSetField(cAlsSEL, "EL_DTENTRA", 	"D")

While (cAlsSEL)->(!Eof())
	aAdd(aCols,Array(Len(aHeader)+1))
	nCols ++
	For nContCols := 1 To Len(aHeader)
		If AllTrim(aHeader[nContCols][2]) == "D1_ITEM"
			aCols[nCols][nContCols] := PADL(nCols,aHeader[nContCols][4],"0")
		Else
			If ( aHeader[nContCols][10] != "V")
				aCols[nCols][nContCols] := (cAlsSEL)->(FieldGet(FieldPos(aHeader[nContCols][2])))
			Else
				aCols[nCols][nContCols] := CriaVar(aHeader[nContCols][2],.T.)
			Endif
		EndIf
	Next nContCols
	aCols[nCols][Len(aHeader)+1] := .F.

	Aadd(aRecnoSEL,(cAlsSEL)->SELRECNO)

	(cAlsSEL)->(dbSkip())
EndDo

(cAlsSEL)->(DbCloseArea())

RestArea(aAreaSEL)
RestArea(aArea)

Return(aCols)

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa841CpoOk บAutor  ณMarcos Berto		  บ Data ณ  30/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a valida็ใo por campo										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa841CpoOk(oGetSEL,lService,aService,nlin,aresp,aServMod)

Local cCampo		:= Alltrim(ReadVar())
Local nPosTipo		:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TIPO"})		,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TIPO"}) 		)
Local nPosEmiss		:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_EMISSAO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_EMISSAO"})	)	
Local nPosDtVcto	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_DTVCTO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_DTVCTO"})		)
Local lRet			:=.T.
Local nPosTerceir	:= 0
Local nPosEndosa	:= 0
Local nPosCgc		:= 0

IF !lService
cCfgTerc := FJS->(GetAdvFVal("FJS","FJS_TERCEI",xFilial("FJS")+PadR(oGetSEL:aCols[n][nPosTipo],TamSx3("FJS_TIPO")[1]),1,""))
lCambio:=.T.
Do Case
	Case cCampo == "M->EL_TERCEIR"
		If lRet .And. AllTrim(cCfgTerc) $ "2|4" .And. &(cCampo) <> "1"
			MsgAlert(STR0018) //"O modo de pagamento nใo permite alterar a configura็ใo de terceiros."
			lRet := .F.
		EndIf
	Case cCampo == "M->EL_ENDOSSA"
		If lRet .And. AllTrim(cCfgTerc) $ "1|4" .And. &(cCampo) <> "2"
			MsgAlert (STR0019) //"O modo de pagamento nใo permite alterar a configura็ใo de endosso."
			lRet := .F.
		EndIf
	Case cCampo == "M->EL_DTVCTO"
		If lRet .And. nPosEmiss > 0 .And. nPosTipo > 0 //Utiliza a fun็ใo de valida็ใo de vencimento do recibo - FINA840
			lRet := F840VldVct(&(cCampo),oGetSEL:aCols[n][nPosEmiss],oGetSEL:aCols[n][nPosTipo])
		EndIf
	Case cCampo == "M->EL_EMISSAO"
		If lRet .And. nPosDtVcto > 0 .And. nPosTipo > 0 //Utiliza a fun็ใo de valida็ใo de vencimento do recibo - FINA840
			lRet := F840VldVct(oGetSEL:aCols[n][nPosDtVcto],&(cCampo),oGetSEL:aCols[n][nPosTipo])
		EndIf
	Case cCampo == "M->EL_CGC"
		If cPaisLoc $ "ARG"
			lRet := Cuit(M->EL_CGC)
		EndIf
EndCase
Else
	nPosTerceir := ASCAN(aService[1], {|x|Alltrim(x[2])=="EL_TERCEIR"})
	nPosEndosa  := ASCAN(aService[1], {|x|Alltrim(x[2])=="EL_ENDOSSA"})
	nPosCgc		:= ASCAN(aService[1], {|x|Alltrim(x[2])=="EL_CGC"})

	cCfgTerc := FJS->(GetAdvFVal("FJS","FJS_TERCEI",xFilial("FJS")+PadR(aService[2][nLin][nPosTipo],TamSx3("FJS_TIPO")[1]),1,""))
	lCambio:=.T.

	IF aService[1][nPosTerceir][2] == "EL_TERCEIR"
		If lRet .And. AllTrim(cCfgTerc) $ "2|4" .And. aService[2][1][nPosTerceir] <> "1"
			lRet := .F.
			aadd (aresp, STR0018)
			aadd (aresp, lRet)
		EndIf
	ENDIF

	IF aService[1][nPosEndosa][2] == "EL_ENDOSSA"
		If lRet .And. AllTrim(cCfgTerc) $ "1|4" .And. aService[2][1][nPosEndosa]  <> "2"
			lRet := .F. 
			aadd (aresp, STR0019)
			aadd (aresp, lRet)
		EndIf
	ENDIF
	
	IF ALLTRIM(aService[1][nPosDtVcto][2]) ==  "EL_DTVCTO"
		If lRet .And. nPosEmiss > 0 .And. nPosTipo > 0 //Utiliza a fun็ใo de valida็ใo de vencimento do recibo - FINA840
			lRet := F840VldVct(aService[2][1][nPosDtVcto] ,aService[2][nLin][nPosEmiss],aService[2][nLin][nPosTipo], ,aServMod)
		EndIf
	ENDIF
	
	IF aService[1][nPosEmiss][2]  == "EL_EMISSAO"
		If lRet .And. nPosDtVcto > 0 .And. nPosTipo > 0 //Utiliza a fun็ใo de valida็ใo de vencimento do recibo - FINA840
			lRet := F840VldVct(aService[2][nLin][nPosDtVcto],aService[2][nLin][nPosEmiss],aService[2][nLin][nPosTipo], ,aServMod)
		EndIf
	ENDIF
	
	IF ALLTRIM(aService[1][nPosCgc][2]) == "EL_CGC"
		If cPaisLoc $ "ARG"
			lRet := Cuit(aService[2][1][nPosCgc])
		EndIf
	ENDIF
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  27/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da linha da GetDados dos itens do recibo		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaGetSel : Objeto da GetDados dos itens do recibo            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa841LinOk(oGetSEL,cRecibo,cSerie,lService,aService,nlin,aresp,aServMod)

Local lRet			:=.T.
Local aArea		:= GetArea()
Local aAreaSE1	:= {}
Local aAreaSEF	:= {}
Local cCfgTerc	:= ""
Local cFilSE1		:= XFILIAL("SE1")
Local cFilSEF		:= XFILIAL("SEF")
Local nPosTpDoc		:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TIPODOC"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TIPODOC"}) 	)
Local nPosPrefixo	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_PREFIXO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_PREFIXO"}))
Local nPosNumero	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_NUMERO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_NUMERO"}))
Local nPosParcela	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_PARCELA"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_PARCELA"}))
Local nPosTipo		:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TIPO"})		,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TIPO"})	)
Local nPosCheque	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="E1_NUM"})		,aScan(aService[1],{|x|Alltrim(x[2])=="E1_NUM"})	)
Local nPosBcoChq	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_BCOCHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_BCOCHQ"}))
Local nPosAgeChq	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_AGECHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_AGECHQ"}))
Local nPosCtaChq	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_CTACHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_CTACHQ"}))
Local nPosEmissa	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_EMISSAO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_EMISSAO"}))
Local nPosVencto	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_DTVCTO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_DTVCTO"}))
Local nPosCGC		:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_CGC"})		,aScan(aService[1],{|x|Alltrim(x[2])=="EL_CGC"})	)
Local nPosTerc		:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TERCEIR"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TERCEIR"}))
Local nPosEndoss	:= IIf(!lService, aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_ENDOSSA"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_ENDOSSA"}))
Local nLinGrid		:= IIf(!lService, oGetSEL:nAt , nlin)
Local nContLiX		:= 0

Default cRecibo 	:= CriaVar("EL_RECIBO")
Default cSerie 	:= CriaVar("EL_SERIE")

DbSelectArea("SE1")
aAreaSE1 := SE1->(GetArea())

DbSelectArea("SEF")
aAreaSEF := SEF->(GetArea())

iF !lService
/*
 * Quando a linha do Grid nใo estiver deletada, efetuar as devidas valida็๕es
 */
If !oGetSEL:aCols[nLinGrid][Len(oGetSEL:aHeader)+1] // Somente Linhas nใo Deletadas

	/*
	 * Valida็ใo da data de emissใo ser menor que a data de vencimento do cheque
	 */
	If oGetSEL:aCols[nLinGrid][nPosEmissa] > oGetSEL:aCols[nLinGrid][nPosVencto]
		Help(" ",1,"BLOQDTVENC")
		//MsgAlert("Data de emissใo deve ser menor ou igual a data de vencimento do cheque.")
		lRet := .F.
	EndIf

	/*
	 * Valida็ใo se jแ existe cheque incluํdo no cadastro de tํtulos a receber do tipo CH - Cheque
	 */
	SE1->(DbSetOrder(1)) // Filial + Prefixo + N๚mero + Parcela + Tipo
	If lRet .AND. SE1->(DbSeek( cFilSE1 ;
					+ oGetSEL:aCols[nLinGrid][nPosPrefixo] ;
					+ oGetSEL:aCols[nLinGrid][nPosNumero] ;
					+ oGetSEL:aCols[nLinGrid][nPosParcela] ;
					+ oGetSEL:aCols[nLinGrid][nPosTpDoc] ) )
		If AllTrim(SE1->E1_RECIBO) != AllTrim(cRecibo) .And.;
			(!SuperGetMV('MV_SERREC') .OR. AllTrim(SE1->E1_SERREC) == Alltrim(cSerie))

			MsgAlert(STR0007) // "Documento para recebimento ja existente no Contas a Receber. Verifique Tipo do Tํtulo, Prefixo, N๚mero do Cheque ou Parcela."
			lRet := .F.
		EndIf
	EndIf

	/*
	 * Valida็ใo se jแ existe cheque incluํdo no cadastro de cheques (Tabela SEF)
	 */
	SEF->(DbSetOrder(1)) // Filial + Banco + Ag๊ncia + Conta Corrente + N๚mero do Cheque
	If lRet .AND. SEF->(DbSeek( cFilSEF ;
					+ oGetSEL:aCols[nLinGrid][nPosBcoChq] ;
					+ oGetSEL:aCols[nLinGrid][nPosAgeChq] ;
					+ oGetSEL:aCols[nLinGrid][nPosCtaChq] ;
					+ oGetSEL:aCols[nLinGrid][nPosNumero] ) )
		//While SEF->(!Eof())
			If AllTrim(SEF->EF_TITULO) != AllTrim(cRecibo)
				MsgAlert(STR0008) // "Cheque para recebimento jแ existente em outro recibo. Verifique Tํtulo a Receber, Banco, Ag๊ncia, Conta Corrente e N๚mero do Cheque."
				lRet := .F.
				//Exit
			EndIf
			SEF->(DbSkip())
		//EndDo
	EndIf

	If  cPaisLoc $ "ARG"
		//Valida็ใo FJS X SEL - Terceiro e Endossa
		If nPosTerc > 0 .And. nPosEndoss > 0 .And. nPosTipo > 0

			cCfgTerc := FJS->(GetAdvFVal("FJS","FJS_TERCEI",xFilial("FJS")+PadR(aCols[n][nPosTipo],TamSx3("FJS_TIPO")[1]),1,""))

			//EL_TERCEIR
			If lRet .And. AllTrim(cCfgTerc) $ "2|4" .And. aCols[n][nPosTerc] <> "1"

				Help(" ",1,"FA840ALTTR")
				lRet:= .F.

			EndIf

			//EL_ENDOSSA
			If lRet .And. AllTrim(cCfgTerc) $ "1|4" .And. aCols[n][nPosEndoss] <> "2"

				Help(" ",1,"FA840ALTEN")
				lRet:= .F.

			EndIf

		EndIf

		//Cheque Terc. X  CUIT
		If lRet .And. nPosTerc > 0 .And. nPosTpDoc > 0 .And. nPosCGC > 0
			If aCols[n][nPosTerc] == "2" .And. aCols[n][nPosTpDoc] $ MVCHEQUE .And. Empty(aCols[n][nPosCGC])

				Help(" ",1,"FA840IDTRC")
				lRet:= .F.
			EndIf
		EndIf

		If lRet .And. nPosVencto > 0 .And. nPosEmissa > 0 .And. nPosTipo > 0  //Utiliza a fun็ใo de valida็ใo de vencimento do recibo - FINA840
			lRet := F840VldVct(oGetSEL:aCols[n][nPosVencto],oGetSEL:aCols[n][nPosEmissa],oGetSEL:aCols[n][nPosTipo])
		EndIf
	EndIf
Endif

If lRet
	For nContLiX := 1 To Len(oGetSEL:aCols)
		If nLinGrid != nContLiX
			If oGetSEL:aCols[nLinGrid][nPosBcoChq] ;
					+ oGetSEL:aCols[nLinGrid][nPosAgeChq] ;
					+ oGetSEL:aCols[nLinGrid][nPosCtaChq] ;
					+ oGetSEL:aCols[nLinGrid][nPosCheque] ;
					+ oGetSEL:aCols[nLinGrid][nPosPrefixo] ;
					+ oGetSEL:aCols[nLinGrid][nPosParcela] == ;
					oGetSEL:aCols[nContLiX][nPosBcoChq] ;
					+ oGetSEL:aCols[nContLiX][nPosAgeChq] ;
					+ oGetSEL:aCols[nContLiX][nPosCtaChq] ;
					+ oGetSEL:aCols[nContLiX][nPosCheque] ;
					+ oGetSEL:aCols[nContLiX][nPosPrefixo] ;
					+ oGetSEL:aCols[nContLiX][nPosParcela]
				MsgAlert( STR0009 + CVALTOCHAR(nContLiX) + STR0010 ) //"Documento de Cheque jแ existente na linha nบ "	//" neste recibo. Verifique Tํtulo + Cheque + Banco + Ag๊ncia + Conta Corrente."
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nContLix
EndIf

If !lRet
	oGetSEL:nAt := nLinGrid
	oGetSEL:oBrowse:Refresh()
	oGetSEL:oBrowse:SetFocus()
Endif
Else //else Service	
	//Quando a linha do Grid nใo estiver deletada, efetuar as devidas valida็๕es
	If !aService[2][nLinGrid][Len(aService[1])+1] // Somente Linhas nใo Deletadas
		//Valida็ใo da data de emissใo ser menor que a data de vencimento do cheque
		If aService[2][nLinGrid][nPosEmissa] > aService[2][nLinGrid][nPosVencto]
			lRet := .F.
			aadd (aresp, STR0020)
			aadd (aresp, lRet)
		EndIF
		//Valida็ใo se jแ existe cheque incluํdo no cadastro de tํtulos a receber do tipo CH - Cheque
		SE1->(DbSetOrder(1)) // Filial + Prefixo + N๚mero + Parcela + Tipo
		If lRet .AND. SE1->(DbSeek( cFilSE1 ;
						+ aService[2][nLinGrid][nPosPrefixo] ;
						+ aService[2][nLinGrid][nPosNumero] ;
						+ aService[2][nLinGrid][nPosParcela] ;
						+ aService[2][nLinGrid][nPosTpDoc] ) )
			If AllTrim(SE1->E1_RECIBO) != AllTrim(cRecibo) .And.;
				(!SuperGetMV('MV_SERREC') .OR. AllTrim(SE1->E1_SERREC) == Alltrim(cSerie))
				lRet := .F.
				aadd (aresp, STR0007)
				aadd (aresp, lRet)
			EndIf
		EndIf
		/*
		* Valida็ใo se jแ existe cheque incluํdo no cadastro de cheques (Tabela SEF)
		*/
		SEF->(DbSetOrder(1)) // Filial + Banco + Ag๊ncia + Conta Corrente + N๚mero do Cheque
		If lRet .AND. SEF->(DbSeek( cFilSEF ;
						+ aService[2][nLinGrid][nPosBcoChq] ;
						+ aService[2][nLinGrid][nPosAgeChq] ;
						+ aService[2][nLinGrid][nPosCtaChq] ;
						+ aService[2][nLinGrid][nPosNumero] ) )
				If AllTrim(SEF->EF_TITULO) != AllTrim(cRecibo)
					lRet := .F.
					aadd (aresp, STR0008)
					aadd (aresp, lRet)		
				EndIf
				SEF->(DbSkip())
		EndIf

		If  cPaisLoc $ "ARG"
			//Valida็ใo FJS X SEL - Terceiro e Endossa
			If nPosTerc > 0 .And. nPosEndoss > 0 .And. nPosTipo > 0
				cCfgTerc := FJS->(GetAdvFVal("FJS","FJS_TERCEI",xFilial("FJS")+PadR(aService[2][nLinGrid][nPosTipo],TamSx3("FJS_TIPO")[1]),1,""))
				//EL_TERCEIR
				If lRet .And. AllTrim(cCfgTerc) $ "2|4" .And. aService[2][nLinGrid][nPosTerc] <> "1"
					lRet:= .F.
					aadd (aresp, "FA840ALTTR")
					aadd (aresp, lRet)
				EndIf
				//EL_ENDOSSA
				If lRet .And. AllTrim(cCfgTerc) $ "1|4" .And. aService[2][nLinGrid][nPosEndoss] <> "2"
					lRet:= .F.
					aadd (aresp, "FA840ALTEN")	
					aadd (aresp, lRet)
				EndIf
			EndIf
			//Cheque Terc. X  CUIT
			If lRet .And. nPosTerc > 0 .And. nPosTpDoc > 0 .And. nPosCGC > 0
				If aService[2][nLinGrid][nPosTerc] == "2" .And. aService[2][nLinGrid][nPosTpDoc] $ MVCHEQUE .And. Empty(aService[2][nLinGrid][nPosCGC])
					lRet:= .F.
					aadd (aresp, "FA840IDTRC")	
					aadd (aresp, lRet)
				EndIf
			EndIf
			If lRet .And. nPosVencto > 0 .And. nPosEmissa > 0 .And. nPosTipo > 0  //Utiliza a fun็ใo de valida็ใo de vencimento do recibo - FINA840
				lRet := F840VldVct(aService[2][nLinGrid][nPosVencto],aService[2][nLinGrid][nPosEmissa],aService[2][nLinGrid][nPosTipo],@aresp,aServMod)
			EndIf
		EndIf
	Endif

	If lRet
		For nContLiX := 1 To Len(aService[2])
			If nLinGrid != nContLiX
				If 		 aService[2][nLinGrid][nPosBcoChq] ;
						+aService[2][nLinGrid][nPosAgeChq] ;
						+aService[2][nLinGrid][nPosCtaChq] ;
						+aService[2][nLinGrid][nPosCheque] ;
						+aService[2][nLinGrid][nPosPrefixo] ;
						+aService[2][nLinGrid][nPosParcela] == ;
						  aService[2][nContLiX][nPosBcoChq] ;
						+ aService[2][nContLiX][nPosAgeChq] ;
						+ aService[2][nContLiX][nPosCtaChq] ;
						+ aService[2][nContLiX][nPosCheque] ;
						+ aService[2][nContLiX][nPosPrefixo] ;
						+ aService[2][nContLiX][nPosParcela]
					lRet := .F.
					aadd (aresp, STR0009 + CVALTOCHAR(nContLiX) + STR0010 )	
					aadd (aresp, lRet)
					Exit
				EndIf
			EndIf
		Next nContLix
	EndIf
Endif
RestArea(aAreaSEF)
RestArea(aAreaSE1)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  27/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo de todas linhas da GetDados dos itens do recibo  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaGetSel : Objeto da GetDados dos itens do recibo            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa841TudoOk(oGetSEL,cRecibo,cSerie,lService,aService,aresp)

Local lRet			:=.T.
Local aArea		:= GetArea()
Local aAreaSE1		:= {}
Local aAreaSEF		:= {}
Local cFilSE1		:= XFILIAL("SE1")
Local cFilSEF		:= XFILIAL("SEF")
Local cCfgTerc		:= "" 
Local nPosTpDoc		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TIPODOC"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TIPODOC"}) 	)
Local nPosPrefixo	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_PREFIXO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_PREFIXO"})	)
Local nPosNumero	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_NUMERO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_NUMERO"})		)
Local nPosParcela	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_PARCELA"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_PARCELA"})	)
Local nPosTipo		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TIPO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TIPO"})		)
Local nPosCheque	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="E1_NUM"})		,aScan(aService[1],{|x|Alltrim(x[2])=="E1_NUM"})		)
Local nPosBcoChq	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_BCOCHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_BCOCHQ"})		)
Local nPosAgeChq	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_AGECHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_AGECHQ"})		)
Local nPosCtaChq	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_CTACHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_CTACHQ"})		)
Local nPosEmissa	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_EMISSAO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_EMISSAO"})	)
Local nPosVencto	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_DTVCTO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_DTVCTO"})		)
Local nPosEndoss	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TERCEIR"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TERCEIR"})	)
Local nPosTerc		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_ENDOSSA"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_ENDOSSA"})	)
Local nPosCGC		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_CGC"})		,aScan(aService[1],{|x|Alltrim(x[2])=="EL_CGC"})		)
Local nContLiX		:= 0
Local nContLiZ		:= 0
Local nContFild		:= IIf(!lService, Len(oGetSEL:aHeader),  Len(aService[1]) )
Local nContLin		:= IIf(!lService, Len(oGetSEL:aCols),  Len(aService[2]) )

Default cRecibo 	:= CriaVar("EL_RECIBO")
Default cSerie	 	:= CriaVar("EL_SERIE")

DbSelectArea("SE1")
aAreaSE1 := SE1->(GetArea())

DbSelectArea("SEF")
aAreaSEF := SEF->(GetArea())

For nContLiX := 1 To nContLin
	IF !lService
	/*
	 * Quando a linha do Grid nใo estiver deletada, efetuar as devidas valida็๕es
	 */
	If !oGetSEL:aCols[nContLiX][nContFild+1] // Somente Linhas nใo Deletadas

		/*
		 * Valida็ใo da data de emissใo ser menor que a data de vencimento do cheque
		 */
		If oGetSEL:aCols[nContLiX][nPosEmissa] > oGetSEL:aCols[nContLiX][nPosVencto]
			Help(" ",1,"BLOQDTVENC")
			//MsgAlert("Data de emissใo deve ser menor ou igual a data de vencimento do cheque.")
			lRet := .F.
		EndIf

		/*
		 * Valida็ใo se jแ existe cheque incluํdo no cadastro de tํtulos a receber do tipo CH - Cheque
		 */
		SE1->(DbSetOrder(1)) // Filial + Prefixo + N๚mero + Parcela + Tipo
		If lRet .AND. SE1->(DbSeek( cFilSE1 ;
						+ oGetSEL:aCols[nContLiX][nPosPrefixo] ;
						+ oGetSEL:aCols[nContLiX][nPosNumero] ;
						+ oGetSEL:aCols[nContLiX][nPosParcela] ;
						+ oGetSEL:aCols[nContLiX][nPosTpDoc] ) )
		If AllTrim(SE1->E1_RECIBO) != AllTrim(cRecibo) .And.;
			(!SuperGetMV('MV_SERREC') .OR. AllTrim(SE1->E1_SERREC) == Alltrim(cSerie))

				MsgAlert( STR0011 + CVALTOCHAR(nContLiX) + STR0012 ) // "Documento Linha nบ " // " para recebimento ja existente no Contas a Receber. Verifique Tipo do Tํtulo, Prefixo, N๚mero do Cheque ou Parcela."
				lRet := .F.
			EndIf
		EndIf

		/*
		 * Valida็ใo se jแ existe cheque incluํdo no cadastro de cheques (Tabela SEF)
		 */
		SEF->(DbSetOrder(1)) // Filial + Banco + Ag๊ncia + Conta Corrente + N๚mero do Cheque
		If lRet .AND. SEF->(DbSeek( cFilSEF ;
						+ oGetSEL:aCols[nContLiX][nPosBcoChq] ;
						+ oGetSEL:aCols[nContLiX][nPosAgeChq] ;
						+ oGetSEL:aCols[nContLiX][nPosCtaChq] ;
						+ oGetSEL:aCols[nContLiX][nPosNumero] ) )
			//While SEF->(!Eof())
				If AllTrim(SEF->EF_TITULO) != AllTrim(cRecibo)
					MsgAlert( STR0013 + CVALTOCHAR(nContLiX) + STR0014 ) // "Cheque Linha nบ " // " para recebimento jแ existente em outro recibo. Verifique Tํtulo a Receber, Banco, Ag๊ncia, Conta Corrente e N๚mero do Cheque."
					lRet := .F.
					//Exit
				EndIf
				SEF->(DbSkip())
			//EndDo
		EndIf
	Endif

	If lRet
		For nContLiZ := 1 To nContLin
			If nContLiZ != nContLiX
				If oGetSEL:aCols[nContLiZ][nPosBcoChq] ;
						+ oGetSEL:aCols[nContLiZ][nPosAgeChq] ;
						+ oGetSEL:aCols[nContLiZ][nPosCtaChq] ;
						+ oGetSEL:aCols[nContLiZ][nPosCheque] ;
						+ oGetSEL:aCols[nContLiZ][nPosPrefixo] ;
						+ oGetSEL:aCols[nContLiZ][nPosParcela] == ;
						oGetSEL:aCols[nContLiX][nPosBcoChq] ;
						+ oGetSEL:aCols[nContLiX][nPosAgeChq] ;
						+ oGetSEL:aCols[nContLiX][nPosCtaChq] ;
						+ oGetSEL:aCols[nContLiX][nPosCheque] ;
						+ oGetSEL:aCols[nContLiX][nPosPrefixo] ;
						+ oGetSEL:aCols[nContLiX][nPosParcela]
					MsgAlert( STR0015 + CVALTOCHAR(nContLiX) + STR0016 ) // "Documento de Cheque jแ existente na linha nบ " // " neste recibo. Verifique Tํtulo + Cheque + Banco + Ag๊ncia + Conta Corrente."
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nContLix
	EndIf
	
	If lRet .And. nPosEndoss > 0 .And. nPosTpDoc > 0 .And. nPosCGC > 0
			If oGetSEL:aCols[nContLiX][nPosEndoss]  == "2" .And. oGetSEL:aCols[nContLiX][nPosTpDoc]  $ MVCHEQUE .And. Empty(oGetSEL:aCols[nContLiX][nPosCGC] )
				Help(" ",1,"FA840IDTRC")
				lRet:= .F.
			EndIf
		EndIf
	
	Else 
	/*
	 * Quando a linha do Grid nใo estiver deletada, efetuar as devidas valida็๕es
	 */
	If  !aService[2][nContLiX][nContFild+1]// Somente Linhas nใo Deletadas

		/*
		 * Valida็ใo da data de emissใo ser menor que a data de vencimento do cheque
		 */
		If  aService[2][nContLiX][nPosEmissa] > aService[2][nContLiX][nPosVencto]
			//MsgAlert("Data de emissใo deve ser menor ou igual a data de vencimento do cheque.")
			lRet := .F.
			aadd (aresp, "BLOQDTVENC" )	
			aadd (aresp, lRet)
		EndIf

		/*
		 * Valida็ใo se jแ existe cheque incluํdo no cadastro de tํtulos a receber do tipo CH - Cheque
		 */
		SE1->(DbSetOrder(1)) // Filial + Prefixo + N๚mero + Parcela + Tipo
		If lRet .AND. SE1->(DbSeek( cFilSE1 ;
						+ aService[2][nContLiX][nPosPrefixo] ;
						+ aService[2][nContLiX][nPosNumero] ;
						+ aService[2][nContLiX][nPosParcela] ;
						+ aService[2][nContLiX][nPosTpDoc] ) )
		If AllTrim(SE1->E1_RECIBO) != AllTrim(cRecibo) .And.;
			(!SuperGetMV('MV_SERREC') .OR. AllTrim(SE1->E1_SERREC) == Alltrim(cSerie))
				lRet := .F.
				aadd (aresp, STR0011 + CVALTOCHAR(nContLiX) + STR0012) // "Documento Linha nบ " // " para recebimento ja existente no Contas a Receber. Verifique Tipo do Tํtulo, Prefixo, N๚mero do Cheque ou Parcela."
				aadd (aresp, lRet)
			EndIf
		EndIf

		/*
		 * Valida็ใo se jแ existe cheque incluํdo no cadastro de cheques (Tabela SEF)
		 */
		SEF->(DbSetOrder(1)) // Filial + Banco + Ag๊ncia + Conta Corrente + N๚mero do Cheque
		If lRet .AND. SEF->(DbSeek( cFilSEF ;
						+ aService[2][nContLiX][nPosBcoChq] ;
						+ aService[2][nContLiX][nPosAgeChq] ;
						+ aService[2][nContLiX][nPosCtaChq] ;
						+ aService[2][nContLiX][nPosNumero] ) )
			//While SEF->(!Eof())
				If AllTrim(SEF->EF_TITULO) != AllTrim(cRecibo)
					// "Cheque Linha nบ " // " para recebimento jแ existente em outro recibo. Verifique Tํtulo a Receber, Banco, Ag๊ncia, Conta Corrente e N๚mero do Cheque."
					lRet := .F.
					aadd (aresp,STR0013 + CVALTOCHAR(nContLiX) + STR0014 ) 
					aadd (aresp, lRet)
					//Exit
				EndIf
				SEF->(DbSkip())
			//EndDo
		EndIf
	Endif

	If lRet
		For nContLiZ := 1 To nContLin
			If nContLiZ != nContLiX
				If  aService[2][nContLiZ][nPosBcoChq] ;
						+ aService[2][nContLiZ][nPosAgeChq] ;
						+ aService[2][nContLiZ][nPosCtaChq] ;
						+ aService[2][nContLiZ][nPosCheque] ;
						+ aService[2][nContLiZ][nPosPrefixo] ;
						+ aService[2][nContLiZ][nPosParcela] == ;
						  aService[2][nContLiX][nPosBcoChq] ;
						+ aService[2][nContLiX][nPosAgeChq] ;
						+ aService[2][nContLiX][nPosCtaChq] ;
						+ aService[2][nContLiX][nPosCheque] ;
						+ aService[2][nContLiX][nPosPrefixo] ;
						+ aService[2][nContLiX][nPosParcela]
					// "Documento de Cheque jแ existente na linha nบ " // " neste recibo. Verifique Tํtulo + Cheque + Banco + Ag๊ncia + Conta Corrente."
					lRet := .F.
					aadd (aresp, STR0015 + CVALTOCHAR(nContLiX) + STR0016  ) 
					aadd (aresp, lRet)
					Exit
				EndIf
			EndIf
		Next nContLix
	EndIf

	If lRet .And. nPosEndoss > 0 .And. nPosTpDoc > 0 .And. nPosCGC > 0
			If aService[2][nContLiX][nPosEndoss]  == "2" .And. aService[2][nContLiX][nPosTpDoc]  $ MVCHEQUE .And. Empty(aService[2][nContLiX][nPosCGC] ) 
				lRet:= .F.
				aadd (aresp, "FA840IDTRC" ) 
				aadd (aresp, lRet)
			EndIf
	EndIf

	EndIf  //fin aService
	
Next nContLiX

RestArea(aAreaSEF)
RestArea(aAreaSE1)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  27/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva os dados alterados nos itens do recibo de cobran็a   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoGetSEL : Objeto do Grid com itens alterados do recibo      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa841Salvar(oGetSEL,cRecibo,cRevisao,dDtRecibo,lDigita,lGeraLanc,lAglutina,aRecnoSEL,cSerie,lService,aService,aresp)

Local aArea			:= GetArea()
Local aAreaSEL		:= {}
Local aAreaSE1		:= {}
Local aAreaSEF		:= {}
Local aAreaSX5		:= {}
Local nContCols 	:= 0
Local nX			:= 0
Local cFilSEL		:= XFILIAL("SEL")
Local cTabSEL		:= RetSqlName("SEL")
Local aStruSEL		:= SEL->(DbStruct())
Local cFilSEF		:= XFILIAL("SEF")
Local cFilSE1		:= XFILIAL("SE1")
Local cFilSE5		:= XFILIAL("SE5")
Local cTabSE5		:= RetSqlName("SE5")
Local aStruSE5		:= SE5->(DbStruct())
Local nPosTpDoc		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TIPODOC"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TIPODOC"}) 	)
Local nPosPrefixo	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_PREFIXO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_PREFIXO"})	)
Local nPosNumero	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_NUMERO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_NUMERO"})		)
Local nPosParcela	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_PARCELA"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_PARCELA"})	)
Local nPosTipo		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TIPO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TIPO"})		)
Local nPosCheque	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="E1_NUM"})		,aScan(aService[1],{|x|Alltrim(x[2])=="E1_NUM"})		)
Local nPosBcoChq	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_BCOCHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_BCOCHQ"})		)
Local nPosAgeChq	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_AGECHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_AGECHQ"})		)
Local nPosCtaChq	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_CTACHQ"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_CTACHQ"})		)
Local nPosPostal	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_POSTAL"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_POSTAL"})		)
Local nPosTerc		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_TERCEIR"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_TERCEIR"})	)
Local nPosEndoss	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_ENDOSSA"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_ENDOSSA"})	)
Local nPosCGC		:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_CGC"})		,aScan(aService[1],{|x|Alltrim(x[2])=="EL_CGC"})		)
Local nPosEmissa	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_EMISSAO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_EMISSAO"})	)
Local nPosVencto	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_DTVCTO"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_DTVCTO"})		)
Local nPosSelDoc	:= IIf(!lService,	aScan(oGetSEL:aHeader,{|x|Alltrim(x[2])=="EL_SELDOC"})	,aScan(aService[1],{|x|Alltrim(x[2])=="EL_SELDOC"})		)
Local cTpDoc		:= ""
Local cPrefixo		:= ""
Local cNumero		:= ""
Local cParcela		:= ""
Local cTipo		:= ""
Local cCheque		:= ""
Local cBcoChq		:= ""
Local cAgeChq		:= ""
Local cCtaChq		:= ""
Local cPostal 		:= ""
Local cEndoss		:= ""
Local cTerc		:= ""
Local cCGC			:= ""
Local cSelDoc		:= ""
Local dEmissa		:= CTOD("  /  /  ")
Local dVencto		:= CTOD("  /  /  ")
Local cQrySEL		:= ""
Local cAlsSEL		:= GetNextAlias()
Local nConField	:= 0
Local cOldRevisa	:= cRevisao

/*
 * Variแveis utilizadas para a Contabiliza็ใo
 */
Local aFlagCTB 	:= {}
Local lUsaFlag	:= GETMV( "MV_CTBFLAG" , .T. , .F. )
Local lUsaSeqCor:= UsaSeqCor()
Local aDiario	:= {}
Local cDiario	:= CTBAVerDia()
Local cLoteFin	:= ""
Local cArquivo	:= ""
Local nTotal	:= 0
Local nHdlPrv	:= 0
Local nLinha	:= 1
Local ntot	:= 0

cRevisao := Soma1(cRevisao)

If lUsaSeqCor
	If !CTBvldDiario(cDiario,dDataBase)
		Return .F.
		aadd (aresp, "CTBvldDiario" ) 
		aadd (aresp, .F.)
	Endif
Endif

If !lCambio
	MsgStop("No hubo Cambios, por favor clicar no boton anular", " Sin Cambios")
	aadd (aresp,"No hubo Cambios, por favor clicar no boton anular" ) 
	aadd (aresp, .F.)
	Return .F.
	
EndIf


DbSelectArea("SEL")
aAreaSEL := SEL->(GetArea())
SEL->(DbSetOrder(1)) // Filial + Nบ Recibo + Tipo do Documento + Prefixo do Tํtulo + Parcela do Tํtulo + Tipo do Tํtulo

DbSelectArea("SE1")
aAreaSE1 := SE1->(GetArea())
SE1->(DbSetOrder(1)) // Filial + Prefixo + N๚mero do Tํtulo + Parcela + Tipo

DbSelectArea("SEF")
aAreaSEF := SEF->(GetArea())
SEF->(DbSetOrder(3)) // Filial + Prefixo do Tํtulo + N๚mero do Tํtulo + Parcela do Tํtulo + Tipo do Tํtulo + N๚mero do Cheque + Seqü๊ncia do Cheque

/*
 * Busca da numera็ใo do Lote de Contabiliza็ใo do m๓dulo do Financeiro
 */
dbSelectArea("SX5")
aAreaSX5 := SX5->(GetArea())
SX5->(DbSeek(xFilial("SX5")+"09FIN"))
cLoteFin := Iif(SX5->(Found()),AllTrim(X5DESCRI()),"FIN")

/*
 * Inicializa integra็ใo com o m๓dulo SIGAPCO
 */
PcoIniLan("000361")

/*
 * Cria o Header a Contabiliza็ใo
 */

nHdlPrv := HeadProva(cLoteFin,FunName(),Substr(cUsuario,7,6),@cArquivo)


BEGIN TRANSACTION

IIF (!lService,ntot:=Len(oGetSEL:aCols),ntot:=Len(aService[2]))

For nContCols := 1 To ntot
	cTpDoc		:= IIF (!lService, PADR(oGetSEL:aCols[nContCols][nPosTpDoc],oGetSEL:aHeader[nPosTipo][4]," "),PADR(aService[2][nContCols][nPosTpDoc],aService[1][nPosTipo][4]," ") )	// Tipo do Documento
	cPrefixo	:= IIF (!lService, oGetSEL:aCols[nContCols][nPosPrefixo] ,	aService[2][nContCols][nPosPrefixo] )				   						// Prefixo do Tํtulo a Receber
	cNumero		:= IIF (!lService, oGetSEL:aCols[nContCols][nPosNumero]	,	aService[2][nContCols][nPosNumero] )									// N๚mero do Tํtulo
	cParcela	:= IIF (!lService, oGetSEL:aCols[nContCols][nPosParcela]	,	aService[2][nContCols][nPosParcela] )									// Parcela do Tํtulo a Receber
	cTipo		:= IIF (!lService, oGetSEL:aCols[nContCols][nPosTipo]	,	aService[2][nContCols][nPosTipo]	 )										// Tipo do Tํtulo a Receber
	cCheque		:= IIF (!lService, oGetSEL:aCols[nContCols][nPosCheque]	,	aService[2][nContCols][nPosCheque] )									// N๚mero do Cheque
	cBcoChq		:= IIF (!lService, oGetSEL:aCols[nContCols][nPosBcoChq]	,	aService[2][nContCols][nPosBcoChq] )								 	// Banco do Cheque
	cAgeChq		:= IIF (!lService, oGetSEL:aCols[nContCols][nPosAgeChq]	,	aService[2][nContCols][nPosAgeChq] )								 	// Ag๊ncia do Cheque
	cCtaChq		:= IIF (!lService, oGetSEL:aCols[nContCols][nPosCtaChq] 	,	aService[2][nContCols][nPosCtaChq]  )									// C/C do Cheque
	If cPaisLoc == "ARG"
		cPostal	:= IIF (!lService,oGetSEL:aCols[nContCols][nPosPostal] 	,	aService[2]	[nContCols][nPosPostal] )									// Codigo Postal do Cheque
	EndIf  
	cTerc		:= IIF (!lService,oGetSEL:aCols[nContCols][nPosTerc]  	,	aService[2][nContCols][nPosTerc]  			)									// Terceiro
	cEndoss		:= IIF (!lService,oGetSEL:aCols[nContCols][nPosEndoss]  ,	aService[2][nContCols][nPosEndoss]   	)										// Endossa
	cCGC		:= IIF (!lService,oGetSEL:aCols[nContCols][nPosCGC]   	,	aService[2][nContCols][nPosCGC]   			)							 	// Cuit do Firmante (CPF/CNPJ)
	dEmissa		:= IIF (!lService,oGetSEL:aCols[nContCols][nPosEmissa]	,	aService[2][nContCols][nPosEmissa]			)							 	// Data de Emissใo do Cheque
	dVencto		:= IIF (!lService,oGetSEL:aCols[nContCols][nPosVencto]	,	aService[2][nContCols][nPosVencto]			)							 	// Data de Vencimento do Cheque
	If nPosSelDoc > 0
		cSelDoc := IIF (!lService,oGetSEL:aCols[nContCols][nPosSelDoc]	,	aService[2][nContCols][nPosSelDoc])									 	//Selado - Sim/Nใo
	EndIf

	cQrySEL := "SELECT "
	For nConField := 1 To Len(aStruSEL)
		If nConField == 1
			cQrySEL += " " + aStruSEL[nConField][1]
		Else
			cQrySEL += ", " + aStruSEL[nConField][1]
		EndIf
	Next nConField
	cQrySEL += " FROM " + cTabSEL + " SEL "
	cQrySEL += " WHERE "
	cQrySEL += " SEL.EL_RECIBO 	= '" + cRecibo + "' AND "
	If cSerie <> Nil .And.SuperGetMV('MV_SERREC')
		cQrySEL += " SEL.EL_SERIE = '" + cSerie + "' AND " 
	Endif
	cQrySEL += " SEL.EL_VERSAO 	= '" + cOldRevisa + "' AND "
	cQrySEL += " SEL.EL_PREFIXO = '" + cPrefixo + "' AND "
	cQrySEL += " SEL.EL_NUMERO	= '" + cCheque + "' AND "
	cQrySEL += " SEL.EL_PARCELA = '" + cParcela + "' AND "
	cQrySEL += " SEL.EL_TIPO 	= '" + cTipo + "' AND "
	cQrySEL += RetSqlCond("SEL")
	cQrySEL	:= ChangeQuery(cQrySEL)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySEL),cAlsSEL,.T.,.T.)
	For nConField := 1 To Len(aStruSEL)
		TcSetField(cAlsSEL, aStruSEL[nConField][1],	aStruSEL[nConField][2], aStruSEL[nConField][3], aStruSEL[nConField][4])
	Next nConField

	While (cAlsSEL)->(!Eof())
		/*
		 * Atualiza็ใo de dados no item do recibo de cobran็a
		 */
		SEL->(RecLock("SEL",.T.))

		For nConField := 1 To Len(aStruSEL)
			SEL->&(aStruSEL[nConField][1]) := (cAlsSEL)->&(aStruSEL[nConField][1])
		Next nConField

		If (cAlsSEL)->EL_TIPODOC == 'CH'
			SEL->EL_FILIAL	:= cFilSEL
			SEL->EL_RECIBO	:= cRecibo
			SEL->EL_SERIE	:= IIf(cSerie<>Nil,cSerie,"")
			SEL->EL_BCOCHQ 	:= cBcoChq
			SEL->EL_AGECHQ	:= cAgeChq
			SEL->EL_CTACHQ	:= cCtaChq
          	If cPaisLoc == "ARG"
          		SEL->EL_POSTAL	:= cPostal       // Alterado em 04/10/12, Req. 1267.04, Entidades Bancarias
			EndIf
			SEL->EL_TERCEIR	:= cTerc
			SEL->EL_ENDOSSA	:= cEndoss
			SEL->EL_CGC		:= cCGC
			SEL->EL_EMISSAO	:= dEmissa
			SEL->EL_DTVCTO	:= dVencto
			SEL->EL_NUMERO	:= cNumero
			If nPosSelDoc > 0
				SEL->EL_SELDOC := cSelDoc
			EndIf
		EndIf

		SEL->EL_VERSAO	:= cRevisao
		SEL->(MsUnlock())

		If AllTrim((cAlsSEL)->EL_TIPODOC) == 'CH'

 			Do Case
				Case VerPadrao("5BY")    // Novo Lancto
					cPad576 := "5BY"     //Estorno cheque
					lPad576 := VerPadrao(cPad576)
					cPad575 := "5BQ"     //Novo cheque
					lPad575 := VerPadrao(cPad575)
				OtherWise				 //	Antigo Lancto
					cPad576 := "576" 	 //Estorno do cheque
					lPad576 := VerPadrao(cPad576)
					cPad575 := "575"     //Novo cheque
					lPad575 := VerPadrao(cPad575)
			EndCase

			/*
			 * Estorna os lan็amentos nas contas or็amentแrias do SIGAPCO
			 */
			PcoDetLan("000361","07","FINA841")
			/*
			 * Grava os lan็amentos nas contas or็amentแrias do SIGAPCO
			 */
			PcoDetLan("000361","01","FINA841")

            /*
             * Se o ambiente do protheus utiliza as flags do CTB, armazaenar as informa็๕es do lan็amento contแbil
             */
         	If lUsaFlag
				aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( Recno() ), 0, 0, 0} )
			EndIf

			/*
             * Se o ambiente do protheus utiliza CORRELATIVO do CTB, armazaenar as informa็๕es do lan็amento contแbil
             */
			If lUsaSeqCor
				aAdd(aDiario,{"SEL",SEL->(Recno()),cDiario,"EL_NODIA","EL_DIACTB"})
			EndIf

            /*
             * Grava os detalhes dos lan็amentos da contabiliza็ใo de estorno do cheque
             */
   	   		If nHdlPrv >0 .And.lPad576
				nTotal += DetProva(nHdlPrv,;
								cPad576,;
								FunName(),;
								cLoteFin,;
								@nLinha,;
			                    /*lExecuta*/,;
			                    /*cCriterio*/,;
			                    /*lRateio*/,;
			                    /*cChaveBusca*/,;
			                    /*aCT5*/,;
			                    /*lPosiciona*/,;
			                    @aFlagCTB,;
			                    /*aTabRecOri*/,;
			                    /*aDadosProva*/ )
			Endif
			/*
             * Grava os detalhes dos lan็amentos da contabiliza็ใo do novo cheque
             */
			If nHdlPrv >0 .And. lPad575
				nTotal += DetProva(nHdlPrv,;
								cPad575,;
								FunName(),;
								cLoteFin,;
								@nLinha,;
			                    /*lExecuta*/,;
			                    /*cCriterio*/,;
			                    /*lRateio*/,;
			                    /*cChaveBusca*/,;
			                    /*aCT5*/,;
			                    /*lPosiciona*/,;
			                    @aFlagCTB,;
			                    /*aTabRecOri*/,;
			                    /*aDadosProva*/ )

			Endif
			If SE1->(DbSeek( cFilSE1 + cPrefixo + cCheque + cParcela + cTpDoc  ) )
				/*
				 * Atualiza็ใo de dados no tํtulo a receber
				 */
				SE1->(RecLock("SE1",.F.))
				SE1->E1_NUM	 := cNumero
				SE1->E1_BCOCHQ := cBcoChq
				SE1->E1_AGECHQ := cAgeChq
				SE1->E1_CTACHQ := cCtaChq
                If cPaisLoc == "ARG"
                	SE1->E1_POSTAL := cPostal        // Alterado em 04/10/12, Req. 1267.04, Entidades Bancarias
                	SE1->E1_VENCTO := dVencto
                	SE1->E1_VENCREA:=DataValida(dVencto, .T.)
				EndIf
				SE1->(MsUnLock())
			EndIf

			If SEF->(DbSeek( cFilSEF + cPrefixo + PADR(cRecibo,TamSx3('EF_TITULO')[1]) + cParcela + cTpDoc + cCheque ) )
				/*
				 * Atualiza็ใo de dados no cheque recebido
				 */
				SEF->(RecLock("SEF",.F.))
				SEF->EF_NUM 		:= cNumero
				SEF->EF_BANCO		:= cBcoChq
				SEF->EF_AGENCIA	:= cAgeChq
				SEF->EF_CONTA		:= cCtaChq
              	If cPaisLoc == "ARG"
              		SEF->EF_POSTAL	:= cPostal      // Alterado em 04/10/12, Req. 1267.04, Entidades Bancarias
				EndIf
				SEF->EF_CPFCNPJ 	:= cCGC
				SEF->EF_DATA		:= dEmissa
				SEF->EF_VENCTO	:= dVencto
				SEF->EF_TERCEIR	:= Iif(SEL->EL_TERCEIR == "1",.T.,.F.)
				SEF->EF_ENDOSSA	:= cEndoss
				SEF->(MsUnLock())
			EndIf

		EndIf
		(cAlsSEL)->(DbSkip())
	EndDo
	(cAlsSEL)->(DbCloseArea())
Next nContCols

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza os registros nao exibidos na grid - INICIOณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQrySEL := "SELECT "

	For nConField := 1 To Len(aStruSEL)
		If nConField == 1
			cQrySEL += " " + aStruSEL[nConField][1]
		Else
			cQrySEL += ", " + aStruSEL[nConField][1]
		EndIf
	Next nConField

	cQrySEL += " FROM " + cTabSEL + " SEL "
	cQrySEL += " WHERE "
	cQrySEL += " SEL.EL_RECIBO 	= '" + cRecibo + "'    AND "
	cQrySEL += " SEL.EL_VERSAO 	= '" + cOldRevisa + "' AND "
	If cSerie <> Nil .And.SuperGetMV('MV_SERREC')
		cQrySEL += " SEL.EL_SERIE = '" + cSerie + "' AND "
	Endif
	cQrySEL += " SEL.R_E_C_N_O_ NOT IN ( "
		For nX := 1 To Len(aRecnoSEL)
            //
			cQrySEL += If( nX == 1, "", "," ) + AllTrim( STR(aRecnoSEL[nX]) )
            //
            //---- Linha Original em 04/10/2012 - nao passa em DB2 --------
			// cQrySEL += If(nX==1, "'", ",'") + STR(aRecnoSEL[nX]) + "'"
            //-------------------------------------------------------------
            //
		Next nX
	cQrySEL += " ) AND "
	cQrySEL += RetSqlCond("SEL")
	
	cQrySEL	:= ChangeQuery(cQrySEL)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySEL),cAlsSEL,.T.,.T.)

	For nConField := 1 To Len(aStruSEL)
		TcSetField(cAlsSEL, aStruSEL[nConField][1],	aStruSEL[nConField][2], aStruSEL[nConField][3], aStruSEL[nConField][4])
	Next nConField

	While (cAlsSEL)->(!Eof())
		/*
		 * Atualiza็ใo de dados nos itens do recibo de cobran็a
		 */

		SEL->(RecLock("SEL",.T.))

		For nConField := 1 To Len(aStruSEL)

			If aStruSEL[nConField][1] != "EL_VERSAO"
				SEL->&(aStruSEL[nConField][1]) := (cAlsSEL)->&(aStruSEL[nConField][1])
			Else
				SEL->&(aStruSEL[nConField][1]) := cRevisao
			EndIf

		Next nConField

		SEL->(MsUnlock())

		(cAlsSEL)->(DbSkip())
	EndDo

	(cAlsSEL)->(DbCloseArea())

	//Cria a copia do recibo na tabela de cabecalho
	DbSelectArea('FJT')
	FJT->(DbSetOrder(1))
	If FJT->(DbSeek(XFilial("FJT")+cSerie+cRecibo))
		While FJT->(!Eof()) .And. XFilial("FJT")+cSerie+cRecibo == FJT_FILIAL+FJT_SERIE+FJT_RECIBO
			RecLock('FJT',.F.)
			FJT_VERATU	:=	'0'
			FJT->(MsUnLock())
		FJT->(DbSkip())
		EndDo
	EndIf
	If FJT->(DbSeek(XFilial("FJT")+cSerie+cRecibo+cOldRevisa))
		PmsCopyReg('FJT',FJT->(RECNO()),{{'FJT_VERSAO',cRevisao},{'FJT_VERATU','1'}})
	EndIf

END TRANSACTION

/*
 * Finaliza a integra็ใo com o m๓dulo SIGAPCO
 */
PcoFinLan("000361")

If nHdlPrv > 0
	RodaProva(	nHdlPrv, nTotal )
	cA100Incl(	cArquivo,;
				nHdlPrv,;
				3 /*nOpcx*/,;
				cLoteFin,;
				lDigita,;
				lAglutina,;
				lGeraLanc,;
				dDtRecibo,;
				/*dReproc*/,;
				@aFlagCTB,;
				/*aDadosProva*/,;
				aDiario )
Endif
RestArea(aAreaSX5)
RestArea(aAreaSEF)
RestArea(aAreaSE1)
RestArea(aAreaSEL)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA841  บ Autor ณ Marylly A. Silva   บ Data ณ  26/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a ๚ltima revisใo do recibo informado no parโmetro  บฑฑ
ฑฑบ          ณ Recebimento Diversos                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - M๓dulo Financeiro (Argentina)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F841VERSA(cRecibo,cSerie)
Local cRevisao	:= ""
Local cQryRev	:= ""
Local cAlsRev	:= GetNextAlias()
Local aArea		:= GetArea()
Local aAreaSEL	:= {}

Default cRecibo := ""

DbSelectArea("SEL")
aAreaSEL := SEL->(GetArea())

cQryRev := "SELECT "
cQryRev += " MAX(SEL.EL_VERSAO) REVISAO "
cQryRev += " FROM " + RetSqlName("SEL") + " SEL "
cQryRev += " WHERE "
cQryRev += " SEL.EL_RECIBO = '" + cRecibo + "' AND "
If cSerie <> Nil .And.SuperGetMV('MV_SERREC')
	cQryRev += " SEL.EL_SERIE = '" + cSerie + "' AND "
Endif
cQryRev += RetSqlCond("SEL")

cQryRev	:= ChangeQuery(cQryRev)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRev),cAlsRev,.T.,.T.)

If (cAlsRev)->(!Eof())
	cRevisao := (cAlsRev)->REVISAO
EndIf

(cAlsRev)->(DbCloseArea())

RestArea(aAreaSEL)
RestArea(aArea)
Return (cRevisao)
