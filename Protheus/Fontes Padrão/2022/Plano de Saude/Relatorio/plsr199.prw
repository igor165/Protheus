#include "plsr199.ch"
#include "PROTHEUS.CH"

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR199 ³ Autor ³ Sandro Hoffman Lopes   ³ Data ³ 21.08.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Relacao dos Valores de Produto no nivel do Subcontrato     ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR199()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ 11/09/06 ³106416³ Sandro H.   ³ Imprimir Nr Ant Contrato (BQC_ANTCON) ³±±±
±±³          ³      ³             ³ Nao imprimir validade (BIL_DATINI e   ³±±±
±±³          ³      ³             ³ BIL_DATFIN)                           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR199(lAuto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002 //"dos Valores de Produto no nível do Subcontrato."
Local cDesc3        := ""
Local cPict         := ""
Local titulo        := FunDesc() //"Valor Produto X Subcontrato"
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}

Default lAuto := .F.

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "PLSR199"
Private nTipo       := 15
Private aReturn     := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cPerg       := "PLR199    "
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "PLSR199"
Private lCompres    := .T.
Private lDicion     := .F.
Private lFiltro     := .F.
Private lCrystal    := .F.
Private cString     := "BQC"
Private cCodInt     := ""
Private cCodEmpDe   := ""
Private cCodEmpAte  := ""
Private cNumConDe   := ""
Private cNumConAte  := ""
Private cVerConDe   := ""
Private cVerConAte  := ""
Private cSubConDe   := ""
Private cSubConAte  := ""
Private cVerSubDe   := ""
Private cVerSubAte  := ""
Private lQbPagSubC  := .F.

lAutoSt := lAuto

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	wnrel:=  SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,lDicion,aOrd,lCompres,Tamanho,{},lFiltro,lCrystal)
endif

	aAlias := {"BQC","BT6","BI3","BIL","BHS","BTN","BFT","BR6","BFV","BBX","BGW"}
	objCENFUNLGP:setAlias(aAlias)

If !lAutoSt .AND. nLastKey == 27
	Return
Endif

if !lAutoSt
	SetDefault(aReturn,cString)
endif

If !lAutoSt .AND. nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

cCodInt    := mv_par01
cCodEmpDe  := mv_par02
cCodEmpAte := mv_par03
cNumConDe  := mv_par04
cNumConAte := mv_par05
cVerConDe  := mv_par06
cVerConAte := mv_par07
cSubConDe  := mv_par08
cSubConAte := mv_par09
cVerSubDe  := mv_par10
cVerSubAte := mv_par11    
lQbPagSubC := (mv_par12 == 1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	MsAguarde({|| R199Imp(Cabec1,Cabec2,Titulo,nLin) }, Titulo, "", .T.)

	Roda(0,"","M")
else
	R199Imp(Cabec1,Cabec2,Titulo,nLin)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	SET DEVICE TO SCREEN
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lAutoSt .AND. aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

if !lAutoSt
	MS_FLUSH()
endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ R199Imp       ³ Autor ³ Sandro Hoffman     ³ Data ³ 21.08.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Imprime relatorio dos Valores de Produto no Nivel do Subcon-   ³±±
±±³           ³ trato.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R199Imp(Cabec1,Cabec2,Titulo,nLin)
       
	Local cBQCName  := RetSQLName("BQC")
	Local cBT6Name  := RetSQLName("BT6")
	Local cBI3Name  := RetSQLName("BI3")
	Local cBHSName  := RetSQLName("BHS")
	Local cBT9Name  := RetSQLName("BT9")
	Local cBTKName  := RetSQLName("BTK")
	Local cBJWName  := RetSQLName("BJW")
	Local cPicSUSEP := X3Picture("BI3_SUSEP")
	Local cCodEmp   := ""
	Local cSubCon   := ""
	Local cCodPro   := ""
	Local cCodOpc   := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe mensagem...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lAutoSt
		MsProcTxt(STR0006) //"Buscando dados no servidor..."
		ProcessMessages()
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca dados na tabela do subcontratos conforme parametros                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := " SELECT BQC_FILIAL, BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB, BQC_DESCRI, BT6_CODPRO, BT6_VERSAO, BQC_VENCTO, BQC_MESREA, BQC_ANTCON"
	cSQL += " FROM " + cBQCName + " BQC, " + cBT6Name + " BT6"

	cSQL += " WHERE BQC_FILIAL = '" + xFilial("BQC") + "'"
	cSQL += "   AND BQC_CODINT = '" + cCodInt + "'"
	cSQL += "   AND (BQC_CODEMP >= '" + cCodEmpDe + "' AND"
	cSQL += "        BQC_CODEMP <= '" + cCodEmpAte + "')"
	cSQL += "   AND (BQC_NUMCON >= '" + cNumConDe + "' AND" 
	cSQL += "        BQC_NUMCON <= '" + cNumConAte + "')" 
	cSQL += "   AND (BQC_VERCON >= '" + cVerConDe + "' AND" 
	cSQL += "        BQC_VERCON <= '" + cVerConAte + "')" 
	cSQL += "   AND (BQC_SUBCON >= '" + cSubConDe + "' AND" 
	cSQL += "        BQC_SUBCON <= '" + cSubConAte + "')" 
	cSQL += "   AND (BQC_VERSUB >= '" + cVerSubDe + "' AND" 
	cSQL += "        BQC_VERSUB <= '" + cVerSubAte + "')" 
	cSQL += "   AND BQC.D_E_L_E_T_ <> '*'"

	cSQL += "   AND BT6_FILIAL = BQC_FILIAL"
	cSQL += "   AND BT6_CODINT = BQC_CODINT"
	cSQL += "   AND BT6_CODIGO = BQC_CODEMP"
	cSQL += "   AND BT6_NUMCON = BQC_NUMCON"
	cSQL += "   AND BT6_VERCON = BQC_VERCON"
	cSQL += "   AND BT6_SUBCON = BQC_SUBCON"
	cSQL += "   AND BT6_VERSUB = BQC_VERSUB"
	cSQL += "   AND BT6.D_E_L_E_T_ <> '*'"

	cSQL += " ORDER BY BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB, BT6_CODPRO, BT6_VERSAO"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lista subcontrato e seus respectivos produtos/valores              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL	:= ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBQC",.T.,.F.)

	TrbBQC->(DbGoTop()) 
	cCodEmp := ""
	cSubCon := ""
	Do While ! TrbBQC->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi abortada a impressao...                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAutoSt .AND. Interrupcao(lAbortPrint)
			@ ++nLin, 00 pSay STR0007 //"ABORTADO PELO OPERADOR..."
			Exit
		EndIf            
		if !lAutoSt   
			MsProcTxt(	objCENFUNLGP:verCamNPR("BQC_CODINT",TrbBQC->BQC_CODINT) + "." + ;
					objCENFUNLGP:verCamNPR("BQC_CODEMP",TrbBQC->BQC_CODEMP) + "." + ;
					objCENFUNLGP:verCamNPR("BQC_NUMCON",TrbBQC->BQC_NUMCON) + "." + ;
					objCENFUNLGP:verCamNPR("BQC_VERCON",TrbBQC->BQC_VERCON) + "." + ;
					objCENFUNLGP:verCamNPR("BQC_SUBCON",TrbBQC->BQC_SUBCON) + "." + ;
					objCENFUNLGP:verCamNPR("BQC_VERSUB",TrbBQC->BQC_VERSUB))
			ProcessMessages()
		endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza e lista cabecalho com os dados da empresa/contrato        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCodEmp <> TrbBQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON)
			nLin := 60
			cCodEmp := TrbBQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON)
			Cabec1  := STR0009 + TrbBQC->BQC_CODEMP + " - " + Posicione("BG9", 1, xFilial("BG9")+TrbBQC->(BQC_CODINT+BQC_CODEMP), "BG9_DESCRI") //"Empresa: "
			Cabec2  := STR0010 + TrbBQC->BQC_NUMCON + STR0011 + TrbBQC->BQC_VERCON //"Contrato: "###"   Versao: "
			cSubCon := ""
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lista subtitulo com os dados do subcontrato                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cSubCon <> TrbBQC->(BQC_SUBCON+BQC_VERSUB)
			If lQbPagSubC
				nLin := 60
			Else
				If ! Empty(cSubCon)
					fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
					@ nLin,  0 pSay Replicate ("=", Limite)
				EndIf
			EndIf
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2, .F.)
			@ nLin,  1 pSay STR0012 + objCENFUNLGP:verCamNPR("BQC_SUBCON",TrbBQC->BQC_SUBCON) + " - " +;
									  objCENFUNLGP:verCamNPR("BQC_DESCRI",TrbBQC->BQC_DESCRI) + STR0013 +;
									  objCENFUNLGP:verCamNPR("BQC_VERSUB",TrbBQC->BQC_VERSUB) //"Subcontrato: "###"  Versao: "
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin,  1 pSay STR0034 + objCENFUNLGP:verCamNPR("BQC_ANTCON",TrbBQC->BQC_ANTCON) //"Nr Antigo Contrato: "
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2, .F.)
			@ nLin, 14 pSay STR0014 + objCENFUNLGP:verCamNPR("BQC_VENCTO",StrZero(TrbBQC->BQC_VENCTO, 2, 0)) //"Vencimento: "
			@ nLin, 40 pSay STR0015 + objCENFUNLGP:verCamNPR("BQC_MESREA",TrbBQC->BQC_MESREA) //"Mes Reajuste: "
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			cSubCon := TrbBQC->(BQC_SUBCON+BQC_VERSUB)
			cCodPro := ""
		EndIf
   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca produtos cadastrados no subcontrato                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		BI3->(DbSetOrder(1))
		If BI3->(MsSeek(xFilial("BI3")+TrbBQC->(BQC_CODINT+BT6_CODPRO+BT6_VERSAO)))
                     
			If !Empty(cCodPro)
				fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
				@ nLin,  5 pSay Replicate ("-", Limite - 10)
			EndIf
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2, .F.)
			@ nLin, 7 pSay STR0016 + objCENFUNLGP:verCamNPR("BT6_CODPRO",TrbBQC->BT6_CODPRO) + " - " +;
									 objCENFUNLGP:verCamNPR("BI3_DESCRI",BI3->BI3_DESCRI) + STR0017 +;
									 objCENFUNLGP:verCamNPR("BI3_SUSEP",Transform(BI3->BI3_SUSEP, cPicSUSEP)) //"Produto: "###"   Reg ANS: "

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lista validade do produto/versao                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			BIL->(DbSetOrder(1))
			If BIL->(MsSeek(xFilial("BIL")+TrbBQC->(BQC_CODINT+BT6_CODPRO+BT6_VERSAO)))
				@ nLin, 014 pSay STR0018 //"Versao do Produto:"
				@ nLin, 034 pSay objCENFUNLGP:verCamNPR("BIL_VERSAO",BIL->BIL_VERSAO)
				@ nLin, 039 pSay objCENFUNLGP:verCamNPR("BIL_DESANT",Upper(SubStr(BIL->BIL_DESANT,1,45)))
			Else
				@ nLin, 014 Psay STR0020  //"Versao nao Cadastrado no BI3"
			EndIf   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca formas de cobranca                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := "SELECT BT9_CODFOR"
			cSQL += " FROM " + cBT9Name + " BT9"
			cSQL += " WHERE BT9_FILIAL = '" + TrbBQC->BQC_FILIAL + "'"
			cSQL += "   AND BT9_CODIGO = '" + TrbBQC->(BQC_CODINT+BQC_CODEMP) + "'"
			cSQL += "   AND BT9_NUMCON = '" + TrbBQC->BQC_NUMCON + "'"
			cSQL += "   AND BT9_VERCON = '" + TrbBQC->BQC_VERCON + "'"
			cSQL += "   AND BT9_SUBCON = '" + TrbBQC->BQC_SUBCON + "'"
			cSQL += "   AND BT9_VERSUB = '" + TrbBQC->BQC_VERSUB + "'"
			cSQL += "   AND BT9_CODPRO = '" + TrbBQC->BT6_CODPRO + "'"
			cSQL += "   AND BT9_VERSAO = '" + TrbBQC->BT6_VERSAO + "'"
			cSQL += "   AND BT9.D_E_L_E_T_ <> '*'"

			cSQL	:= ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBT9",.T.,.F.)
					
			Do While ! TrbBT9->(Eof())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Lista valores dos produtos                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fListBTN({ TrbBQC->BQC_FILIAL, TrbBQC->BQC_CODINT, TrbBQC->BQC_CODEMP, TrbBQC->BQC_NUMCON, TrbBQC->BQC_VERCON, TrbBQC->BQC_SUBCON, TrbBQC->BQC_VERSUB, TrbBQC->BT6_CODPRO, TrbBQC->BT6_VERSAO, TrbBT9->BT9_CODFOR }, @nLin, Titulo, Cabec1, Cabec2)			
			    TrbBT9->(DbSkip())
			EndDo
			TrbBT9->(DbCloseArea())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca taxas de adesao                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := "SELECT BTK_CODFOR"
			cSQL += " FROM " + cBTKName + " BTK"
			cSQL += " WHERE BTK_FILIAL = '" + TrbBQC->BQC_FILIAL + "'"
			cSQL += "   AND BTK_CODIGO = '" + TrbBQC->(BQC_CODINT+BQC_CODEMP) + "'"
			cSQL += "   AND BTK_NUMCON = '" + TrbBQC->BQC_NUMCON + "'"
			cSQL += "   AND BTK_VERCON = '" + TrbBQC->BQC_VERCON + "'"
			cSQL += "   AND BTK_SUBCON = '" + TrbBQC->BQC_SUBCON + "'"
			cSQL += "   AND BTK_VERSUB = '" + TrbBQC->BQC_VERSUB + "'"
			cSQL += "   AND BTK_CODPRO = '" + TrbBQC->BT6_CODPRO + "'"
			cSQL += "   AND BTK_VERSAO = '" + TrbBQC->BT6_VERSAO + "'"
			cSQL += "   AND BTK.D_E_L_E_T_ <> '*'"

			cSQL	:= ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBTK",.T.,.F.)
			
			Do While ! TrbBTK->(Eof())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Lista valores dos produtos                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fListBR6({ TrbBQC->BQC_FILIAL, TrbBQC->BQC_CODINT, TrbBQC->BQC_CODEMP, TrbBQC->BQC_NUMCON, TrbBQC->BQC_VERCON, TrbBQC->BQC_SUBCON, TrbBQC->BQC_VERSUB, TrbBQC->BT6_CODPRO, TrbBQC->BT6_VERSAO, TrbBTK->BTK_CODFOR }, @nLin, Titulo, Cabec1, Cabec2)
			    TrbBTK->(DbSkip())
			EndDo
			TrbBTK->(DbCloseArea())

			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca opcionais cadastrados para a empresa/contrato/subcontrato/produto/versao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BHS_CODPLA, BHS_VERPLA, BI3_DESCRI, BHS_TIPVIN"
		cSQL += " FROM " + cBHSName + " BHS, " + cBI3Name + " BI3"
		cSQL += " WHERE BHS_FILIAL = '" + xFilial("BHS") + "'"
		cSQL += "   AND BHS_CODINT = '" + TrbBQC->BQC_CODINT + "'"
		cSQL += "   AND BHS_CODIGO = '" + TrbBQC->BQC_CODEMP + "'"
		cSQL += "   AND BHS_NUMCON = '" + TrbBQC->BQC_NUMCON + "'"
		cSQL += "   AND BHS_VERCON = '" + TrbBQC->BQC_VERCON + "'"
		cSQL += "   AND BHS_SUBCON = '" + TrbBQC->BQC_SUBCON + "'"
		cSQL += "   AND BHS_VERSUB = '" + TrbBQC->BQC_VERSUB + "'"
		cSQL += "   AND BHS_CODPRO = '" + TrbBQC->BT6_CODPRO + "'"
		cSQL += "   AND BHS_VERPRO = '" + TrbBQC->BT6_VERSAO + "'"
		cSQL += "   AND BHS.D_E_L_E_T_ <> '*'"
		cSQL += "   AND BI3_FILIAL = BHS_FILIAL"
		cSQL += "   AND BI3_CODINT = BHS_CODINT"
		cSQL += "   AND BI3_CODIGO = BHS_CODPLA"
		cSQL += "   AND BI3_VERSAO = BHS_VERPLA"
		cSQL += "   AND BI3.D_E_L_E_T_ <> '*'"

		cSQL	:= ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBHS",.T.,.F.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lista opcionais cadastrados para a empresa/contrato/subcontrato/produto/versao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
		@ nLin, 010 pSay STR0021 //"Opcionais Cadastrados"
		fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
		@ nLin, 010 pSay "---------------------"
		If TrbBHS->(Eof())
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 010 pSay STR0022 //"Nao ha Opcionais Cadastrados para este Produto"
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
		Else
			cCodOpc := ""
			Do While ! TrbBHS->(Eof())
		
				If TrbBHS->(BHS_CODPLA+BHS_VERPLA) <> cCodOpc
					fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
					@ nLin, 010 pSay objCENFUNLGP:verCamNPR("BHS_CODPLA",TrbBHS->BHS_CODPLA) + "." +;
									 objCENFUNLGP:verCamNPR("BHS_VERPLA",TrbBHS->BHS_VERPLA) + " - " +;
									 objCENFUNLGP:verCamNPR("BI3_DESCRI",TrbBHS->BI3_DESCRI) + "   " +;
									 IIf(TrbBHS->BHS_TIPVIN == "0", STR0023, STR0024) //"Nao Vinculado"###"Vinculado"
					cCodOpc := TrbBHS->(BHS_CODPLA+BHS_VERPLA)
				EndIf
				           
				If TrbBHS->BHS_TIPVIN == "0" // Nao Vinculado a Mensalidade
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Busca formas de cobranca                                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSQL := "SELECT BJW_CODFOR"
					cSQL += " FROM " + cBJWName + " BJW"
					cSQL += " WHERE BJW_FILIAL = '" + TrbBQC->BQC_FILIAL + "'"
					cSQL += "   AND BJW_CODIGO = '" + TrbBQC->(BQC_CODINT+BQC_CODEMP) + "'"
					cSQL += "   AND BJW_NUMCON = '" + TrbBQC->BQC_NUMCON + "'"
					cSQL += "   AND BJW_VERCON = '" + TrbBQC->BQC_VERCON + "'"
					cSQL += "   AND BJW_SUBCON = '" + TrbBQC->BQC_SUBCON + "'"
					cSQL += "   AND BJW_VERSUB = '" + TrbBQC->BQC_VERSUB + "'"
					cSQL += "   AND BJW_CODPRO = '" + TrbBQC->BT6_CODPRO + "'"
					cSQL += "   AND BJW_VERSAO = '" + TrbBQC->BT6_VERSAO + "'"
					cSQL += "   AND BJW_CODOPC = '" + TrbBHS->BHS_CODPLA + "'"
					cSQL += "   AND BJW_VEROPC = '" + TrbBHS->BHS_VERPLA + "'"
					cSQL += "   AND BJW.D_E_L_E_T_ <> '*'"

					cSQL	:= ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBJW",.T.,.F.)
						
					Do While ! TrbBJW->(Eof())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Lista valores dos produtos                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						fListBBX({ TrbBQC->BQC_FILIAL, TrbBQC->BQC_CODINT, TrbBQC->BQC_CODEMP, TrbBQC->BQC_NUMCON, TrbBQC->BQC_VERCON, TrbBQC->BQC_SUBCON, TrbBQC->BQC_VERSUB, TrbBQC->BT6_CODPRO, TrbBQC->BT6_VERSAO, TrbBHS->BHS_CODPLA, TrbBHS->BHS_VERPLA, TrbBJW->BJW_CODFOR }, @nLin, Titulo, Cabec1, Cabec2)
					    TrbBJW->(DbSkip())
					EndDo
					TrbBJW->(DbCloseArea())
					fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Proximo opcional                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TrbBHS->(DbSkip())
			EndDo
		EndIf
		TrbBHS->(DbCloseArea())

		cCodPro := TrbBQC->BT6_CODPRO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Proximo subcontrato                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TrbBQC->(DbSkip())
	EndDo
   
	TrbBQC->(DbCloseArea())
   
Return

/*  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ fListBTN      ³ Autor ³ Sandro Hoffman     ³ Data ³ 21.08.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Lista os valores do produto por faixa etaria - MENSALIDADE     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fListBTN(aDadBQC, nLin, Titulo, Cabec1, Cabec2)

	Local cSQL
	Local cBTNName := RetSQLName("BTN")
	Local cBFTName := RetSQLName("BFT")
	
	cSQL := "SELECT BTN_CODFOR, BTN_CODPRO, BTN_VERPRO, BTN_TIPUSR, BTN_SEXO, BTN_IDAINI, BTN_IDAFIN, BTN_VALFAI, BTN_QTDMIN,"
	cSql += " BTN_QTDMAX, BFT_QTDDE, BFT_QTDATE, BFT_PERCEN, BFT_VALOR"
	cSQL += " FROM " + cBTNName + " BTN"
	cSQL += " LEFT OUTER JOIN " + cBFTName + " BFT"
	cSQL += "    ON BFT_FILIAL = BTN_FILIAL"
	cSQL += "   AND BFT_CODIGO = BTN_CODIGO"
	cSQL += "   AND BFT_NUMCON = BTN_NUMCON"
	cSQL += "   AND BFT_VERCON = BTN_VERCON"
	cSQL += "   AND BFT_SUBCON = BTN_SUBCON"
	cSQL += "   AND BFT_VERSUB = BTN_VERSUB"
	cSQL += "   AND BFT_CODPRO = BTN_CODPRO"
	cSQL += "   AND BFT_VERPRO = BTN_VERPRO"
	cSQL += "   AND BFT_CODFOR = BTN_CODFOR"
	cSQL += "   AND BFT_CODQTD = BTN_CODQTD"
	cSQL += "   AND BFT_CODFAI = BTN_CODFAI"
	cSQL += "   AND BFT.D_E_L_E_T_ <> '*'"
	cSQL += " WHERE BTN_FILIAL = '" + aDadBQC[1] + "'"
	cSQL += "   AND BTN_CODIGO = '" + aDadBQC[2] + aDadBQC[3] + "'"
	cSQL += "   AND BTN_NUMCON = '" + aDadBQC[4] + "'"
	cSQL += "   AND BTN_VERCON = '" + aDadBQC[5] + "'"
	cSQL += "   AND BTN_SUBCON = '" + aDadBQC[6] + "'"
	cSQL += "   AND BTN_VERSUB = '" + aDadBQC[7] + "'"
	cSQL += "   AND BTN_CODPRO = '" + aDadBQC[8] + "'"
	cSQL += "   AND BTN_VERPRO = '" + aDadBQC[9] + "'"
	cSQL += "   AND BTN_CODFOR = '" + aDadBQC[10] + "'"   
	cSQL += "   AND (BTN_TABVLD = ' ' OR BTN_TABVLD >= '"+DtoS(dDataBase)+"')"
	cSQL += "   AND BTN.D_E_L_E_T_ <> '*'"
	cSQL += " ORDER BY BTN_CODPRO, BTN_VERPRO, BTN_TIPUSR, BTN_SEXO, BTN_IDAINI, BTN_QTDMIN, BTN_QTDMAX, BFT_QTDDE"

	cSQL	:= ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBTN",.T.,.F.)
                          
	fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .T., 1, aDadBQC[10])
	If TrbBTN->(Eof())
		fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
		@ nLin, 022 pSay STR0025 //"Nao ha Valores Cadastrados para este Nivel"
	Else
		Do While ! TrbBTN->(Eof())
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 025 pSay objCENFUNLGP:verCamNPR("BTN_TIPUSR",TrbBTN->BTN_TIPUSR)
			@ nLin, 034 pSay IIf(Alltrim(TrbBTN->BTN_SEXO) == "", " ", objCENFUNLGP:verCamNPR("BTN_SEXO",X3Combo("BTN_SEXO", TrbBTN->BTN_SEXO)))
			
			If TrbBTN->BTN_CODFOR = '101'
				@ nLin, 047 pSay objCENFUNLGP:verCamNPR("BTN_IDAINI",StrZero(TrbBTN->BTN_IDAINI, 3, 0))
			Else
				@ nLin, 047 pSay objCENFUNLGP:verCamNPR("BTN_QTDMIN",StrZero(TrbBTN->BTN_QTDMIN, 3, 0))
			Endif
			
			@ nLin, 051 pSay "-"
			
			If TrbBTN->BTN_CODFOR = '101'
				@ nLin, 053 pSay objCENFUNLGP:verCamNPR("BTN_IDAFIN",StrZero(TrbBTN->BTN_IDAFIN, 3, 0))
			Else
				@ nLin, 053 pSay objCENFUNLGP:verCamNPR("BTN_QTDMAX",StrZero(TrbBTN->BTN_QTDMAX, 3, 0))
			Endif
			
			@ nLin, 071 pSay TrbBTN->BTN_VALFAI Picture "@E 999,999.99"
			If TrbBTN->BTN_CODFOR = '101'
				cChave  := TrbBTN->(BTN_CODPRO+BTN_VERPRO+BTN_TIPUSR+BTN_SEXO+StrZero(BTN_IDAINI, 3))
				cStrChk := "TrbBTN->(BTN_CODPRO+BTN_VERPRO+BTN_TIPUSR+BTN_SEXO+StrZero(BTN_IDAINI, 3))"
			Else
				cChave  := TrbBTN->(BTN_CODPRO+BTN_VERPRO+BTN_TIPUSR+BTN_SEXO+StrZero(BTN_QTDMIN, 3)+StrZero(BTN_QTDMAX, 3))
				cStrChk := "TrbBTN->(BTN_CODPRO+BTN_VERPRO+BTN_TIPUSR+BTN_SEXO+StrZero(BTN_QTDMIN, 3)+StrZero(BTN_QTDMAX, 3))"
			Endif
			
			Do While ! TrbBTN->(Eof()) .And. &(cStrChk) == cChave
				If TrbBTN->BFT_PERCEN + TrbBTN->BFT_VALOR > 0
					@ nLin, 085 pSay objCENFUNLGP:verCamNPR("BFT_QTDDE",StrZero(TrbBTN->BFT_QTDDE, 3, 0))
					@ nLin, 089 pSay "-"
					@ nLin, 091 pSay objCENFUNLGP:verCamNPR("BFT_QTDATE",StrZero(TrbBTN->BFT_QTDATE, 3, 0))
					@ nLin, 097 pSay objCENFUNLGP:verCamNPR("BFT_PERCEN",TrbBTN->BFT_PERCEN) Picture "@E 999.99"
					@ nLin, 107 pSay objCENFUNLGP:verCamNPR("BFT_VALOR",TrbBTN->BFT_VALOR) Picture "@E 999,999.99"
				EndIf
				TrbBTN->(DbSkip())
				
				If &(cStrChk) == cChave  .And. TrbBTN->BFT_PERCEN + TrbBTN->BFT_VALOR > 0
					fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
				EndIf
			EndDo
		EndDo
	EndIf
	TrbBTN->(DbCloseArea())
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ fListBR6      ³ Autor ³ Sandro Hoffman     ³ Data ³ 21.08.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Lista os valores da taxa de adesao por faixa etaria            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fListBR6(aDadBQC, nLin, Titulo, Cabec1, Cabec2)

	Local cSQL
	Local cBR6Name := RetSQLName("BR6")
	Local cBFVName := RetSQLName("BFV")
	
	cSQL := "SELECT BR6_CODPRO, BR6_VERPRO, BR6_TIPUSR, BR6_SEXO, BR6_IDAINI, BR6_IDAFIN, BR6_VLRADE, BFV_QTDDE, BFV_QTDATE, BFV_PERCEN, BFV_VALOR"
	cSQL += " FROM " + cBR6Name + " BR6"
	cSQL += " LEFT OUTER JOIN " + cBFVName + " BFV"
	cSQL += "    ON BFV_FILIAL = BR6_FILIAL"
	cSQL += "   AND BFV_CODIGO = BR6_CODIGO"
	cSQL += "   AND BFV_NUMCON = BR6_NUMCON"
	cSQL += "   AND BFV_VERCON = BR6_VERCON"
	cSQL += "   AND BFV_SUBCON = BR6_SUBCON"
	cSQL += "   AND BFV_VERSUB = BR6_VERSUB"
	cSQL += "   AND BFV_CODPRO = BR6_CODPRO"
	cSQL += "   AND BFV_VERPRO = BR6_VERPRO"
	cSQL += "   AND BFV_CODFOR = BR6_CODFOR"
	cSQL += "   AND BFV_CODFAI = BR6_CODFAI"
	cSQL += "   AND BFV.D_E_L_E_T_ <> '*'"
	cSQL += " WHERE BR6_FILIAL = '" + aDadBQC[1] + "'"
	cSQL += "   AND BR6_CODIGO = '" + aDadBQC[2] + aDadBQC[3] + "'"
	cSQL += "   AND BR6_NUMCON = '" + aDadBQC[4] + "'"
	cSQL += "   AND BR6_VERCON = '" + aDadBQC[5] + "'"
	cSQL += "   AND BR6_SUBCON = '" + aDadBQC[6] + "'"
	cSQL += "   AND BR6_VERSUB = '" + aDadBQC[7] + "'"
	cSQL += "   AND BR6_CODPRO = '" + aDadBQC[8] + "'"
	cSQL += "   AND BR6_VERPRO = '" + aDadBQC[9] + "'"
	cSQL += "   AND BR6_CODFOR = '" + aDadBQC[10] + "'"
	cSQL += "   AND BR6.D_E_L_E_T_ <> '*'"
	cSQL += " ORDER BY BR6_CODPRO, BR6_VERPRO, BR6_TIPUSR, BR6_SEXO, BR6_IDAINI, BFV_QTDDE"

	cSQL	:= ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBR6",.T.,.F.)
                          
	fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .T., 2, aDadBQC[10])
	If TrbBR6->(Eof())
		fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
		@ nLin, 022 pSay STR0025 //"Nao ha Valores Cadastrados para este Nivel"
	Else
		Do While ! TrbBR6->(Eof())
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 025 pSay objCENFUNLGP:verCamNPR("BR6_TIPUSR",TrbBR6->BR6_TIPUSR)
			@ nLin, 034 pSay IIf(Alltrim(TrbBR6->BR6_SEXO) == "", " ", objCENFUNLGP:verCamNPR("BR6_SEXO",X3Combo("BR6_SEXO", TrbBR6->BR6_SEXO)))
			@ nLin, 047 pSay objCENFUNLGP:verCamNPR("BR6_IDAINI",StrZero(TrbBR6->BR6_IDAINI, 3, 0))
			@ nLin, 051 pSay "-"
			@ nLin, 053 pSay objCENFUNLGP:verCamNPR("BR6_IDAFIN",StrZero(TrbBR6->BR6_IDAFIN, 3, 0))
			@ nLin, 071 pSay objCENFUNLGP:verCamNPR("BR6_VLRADE",TrbBR6->BR6_VLRADE) Picture "@E 999,999.99"
			cChave := TrbBR6->(BR6_CODPRO+BR6_VERPRO+BR6_TIPUSR+BR6_SEXO+StrZero(BR6_IDAINI, 3))
			Do While ! TrbBR6->(Eof()) .And. ;
						TrbBR6->(BR6_CODPRO+BR6_VERPRO+BR6_TIPUSR+BR6_SEXO+StrZero(BR6_IDAINI, 3)) == cChave
				If TrbBR6->BFV_PERCEN + TrbBR6->BFV_VALOR > 0
					@ nLin, 085 pSay objCENFUNLGP:verCamNPR("BFV_QTDDE",StrZero(TrbBR6->BFV_QTDDE, 3, 0))
					@ nLin, 089 pSay "-"
					@ nLin, 091 pSay objCENFUNLGP:verCamNPR("BFV_QTDATE",StrZero(TrbBR6->BFV_QTDATE, 3, 0))
					@ nLin, 097 pSay objCENFUNLGP:verCamNPR("BFV_PERCEN",TrbBR6->BFV_PERCEN) Picture "@E 999.99"
					@ nLin, 107 pSay objCENFUNLGP:verCamNPR("BFV_VALOR",TrbBR6->BFV_VALOR) Picture "@E 999,999.99"
				EndIf
				TrbBR6->(DbSkip())
				If TrbBR6->(BR6_CODPRO+BR6_VERPRO+BR6_TIPUSR+BR6_SEXO+StrZero(BR6_IDAINI, 3)) == cChave .And. ;
				   TrbBR6->BFV_PERCEN + TrbBR6->BFV_VALOR > 0
					fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
				EndIf
			EndDo
		EndDo
	EndIf
	TrbBR6->(DbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ fListBBX      ³ Autor ³ Sandro Hoffman     ³ Data ³ 21.08.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Lista os valores dos OPCIONAIS por faixa etaria                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fListBBX(aDadBQC, nLin, Titulo, Cabec1, Cabec2)

	Local cSQL
	Local cBBXName := RetSQLName("BBX")
	Local cBGWName := RetSQLName("BGW")
	
	cSQL := "SELECT BBX_CODPRO, BBX_VERPRO, BBX_TIPUSR, BBX_SEXO, BBX_IDAINI, BBX_IDAFIN, BBX_VALFAI, BBX_VLRADE, BGW_QTDDE, BGW_QTDATE, BGW_PERCEN, BGW_VALOR"
	cSQL += " FROM " + cBBXName + " BBX"
	cSQL += " LEFT OUTER JOIN " + cBGWName + " BGW"
	cSQL += "    ON BGW_FILIAL = BBX_FILIAL"
	cSQL += "   AND BGW_CODIGO = BBX_CODIGO"
	cSQL += "   AND BGW_NUMCON = BBX_NUMCON"
	cSQL += "   AND BGW_VERCON = BBX_VERCON"
	cSQL += "   AND BGW_SUBCON = BBX_SUBCON"
	cSQL += "   AND BGW_VERSUB = BBX_VERSUB"
	cSQL += "   AND BGW_CODPRO = BBX_CODPRO"
	cSQL += "   AND BGW_VERPRO = BBX_VERPRO"
	cSQL += "   AND BGW_CODOPC = BBX_CODOPC"
	cSQL += "   AND BGW_VEROPC = BBX_VEROPC"
	cSQL += "   AND BGW_CODFOR = BBX_CODFOR"
	cSQL += "   AND BGW_CODQTD = BBX_CODQTD"
	cSQL += "   AND BGW_CODFAI = BBX_CODFAI"
	cSQL += "   AND BGW.D_E_L_E_T_ <> '*'"
	cSQL += " WHERE BBX_FILIAL = '" + aDadBQC[1] + "'"
	cSQL += "   AND BBX_CODIGO = '" + aDadBQC[2] + aDadBQC[3] + "'"
	cSQL += "   AND BBX_NUMCON = '" + aDadBQC[4] + "'"
	cSQL += "   AND BBX_VERCON = '" + aDadBQC[5] + "'"
	cSQL += "   AND BBX_SUBCON = '" + aDadBQC[6] + "'"
	cSQL += "   AND BBX_VERSUB = '" + aDadBQC[7] + "'"
	cSQL += "   AND BBX_CODPRO = '" + aDadBQC[8] + "'"
	cSQL += "   AND BBX_VERPRO = '" + aDadBQC[9] + "'"
	cSQL += "   AND BBX_CODOPC = '" + aDadBQC[10] + "'"
	cSQL += "   AND BBX_VEROPC = '" + aDadBQC[11] + "'"
	cSQL += "   AND BBX_CODFOR = '" + aDadBQC[12] + "'"
	cSQL += "   AND BBX.D_E_L_E_T_ <> '*'"
	cSQL += " ORDER BY BBX_CODPRO, BBX_VERPRO, BBX_TIPUSR, BBX_SEXO, BBX_IDAINI, BGW_QTDDE"

	cSQL	:= ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBBX",.T.,.F.)
                          
	fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .T., 3, aDadBQC[12])
	If TrbBBX->(Eof())
		fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
		@ nLin, 010 pSay STR0025 //"Nao ha Valores Cadastrados para este Nivel"
	Else
		Do While ! TrbBBX->(Eof())
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 013 pSay objCENFUNLGP:verCamNPR("BBX_TIPUSR",TrbBBX->BBX_TIPUSR)
			@ nLin, 022 pSay IIf(Alltrim(TrbBBX->BBX_SEXO) == "", " ", objCENFUNLGP:verCamNPR("BBX_SEXO",X3Combo("BBX_SEXO", TrbBBX->BBX_SEXO)))
			@ nLin, 035 pSay objCENFUNLGP:verCamNPR("BBX_IDAINI",StrZero(TrbBBX->BBX_IDAINI, 3, 0))
			@ nLin, 039 pSay "-"
			@ nLin, 041 pSay objCENFUNLGP:verCamNPR("BBX_IDAFIN",StrZero(TrbBBX->BBX_IDAFIN, 3, 0))
			@ nLin, 059 pSay objCENFUNLGP:verCamNPR("BBX_VALFAI",TrbBBX->BBX_VALFAI) Picture "@E 999,999.99"
			@ nLin, 071 pSay objCENFUNLGP:verCamNPR("BBX_VLRADE",TrbBBX->BBX_VLRADE) Picture "@E 999,999.99"
			cChave := TrbBBX->(BBX_CODPRO+BBX_VERPRO+BBX_TIPUSR+BBX_SEXO+StrZero(BBX_IDAINI, 3))
			Do While ! TrbBBX->(Eof()) .And. ;
						TrbBBX->(BBX_CODPRO+BBX_VERPRO+BBX_TIPUSR+BBX_SEXO+StrZero(BBX_IDAINI, 3)) == cChave
				If TrbBBX->BGW_PERCEN + TrbBBX->BGW_VALOR > 0
					@ nLin, 085 pSay objCENFUNLGP:verCamNPR("BGW_QTDDE",StrZero(TrbBBX->BGW_QTDDE, 3, 0))
					@ nLin, 089 pSay "-"
					@ nLin, 091 pSay objCENFUNLGP:verCamNPR("BGW_QTDATE",StrZero(TrbBBX->BGW_QTDATE, 3, 0))
					@ nLin, 097 pSay objCENFUNLGP:verCamNPR("BGW_PERCEN",TrbBBX->BGW_PERCEN) Picture "@E 999.99"
					@ nLin, 107 pSay objCENFUNLGP:verCamNPR("BGW_VALOR",TrbBBX->BGW_VALOR) Picture "@E 999,999.99"
				EndIf
				TrbBBX->(DbSkip())
				If TrbBBX->(BBX_CODPRO+BBX_VERPRO+BBX_TIPUSR+BBX_SEXO+StrZero(BBX_IDAINI, 3)) == cChave .And. ;
				   TrbBBX->BGW_PERCEN + TrbBBX->BGW_VALOR > 0
					fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
				EndIf
			EndDo
		EndDo
	EndIf
	TrbBBX->(DbCloseArea())
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ fSomaLin      ³ Autor ³ Sandro Hoffman     ³ Data ³ 28.11.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Soma "n" Linhas a variavel "nLin" e verifica limite da pagina  ³±±
±±³           ³ para impressao do cabecalho                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fSomaLin(nLin, Titulo, Cabec1, Cabec2, nLinSom, lImpSubCab, nSubCab, cCodFor)

	nLin += nLinSom
	If nLin > 58
		nLin       := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) + 1
	EndIf
    
	If lImpSubCab
		If nSubCab == 1
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 022 Psay STR0026 + cCodFor + STR0027 //"---  VALORES POR FAIXA ETARIA - FORMA DE COBRANCA: "###"  ---    --  DESCONTOS POR QUANTIDADE  --"
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 022 Psay STR0028 //"Tp. Usu.    Sexo         Faixa                        Valor    Faixa            %         Valor"
		ElseIf nSubCab == 2
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 022 pSay STR0029 + cCodFor + STR0030  //"------  VALORES DE ADESAO - FORMA DE COBRANCA: "###"  -------    --  DESCONTOS POR QUANTIDADE  --"
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 022 pSay STR0028 //"Tp. Usu.    Sexo         Faixa                        Valor    Faixa            %         Valor"
		ElseIf nSubCab == 3
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 010 Psay STR0031 + cCodFor + STR0032 //"---------  VALORES POR FAIXA ETARIA - FORMA DE COBRANCA: "###"  ---------    --  DESCONTOS POR QUANTIDADE  --"
			fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1, .F.)
			@ nLin, 010 Psay STR0033 //"Tp. Usu.    Sexo         Faixa                        Valor   Vr Adesao    Faixa            %         Valor"
		EndIf
	EndIf
Return
