#INCLUDE "PLSR997.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Report.ch"
#INCLUDE "FWPrintSetup.ch"
Static objCENFUNLGP := CENFUNLGP():New() 
Static lautoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍcÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSR997  º Autor ³ 				     º Data ³  09/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Emite relatorio de Demonstrativo de IR.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

function PLSR997(cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06,;
 cmv_par07, cmv_par08, cmv_par09, cmv_par10, cmv_par11,lWeb	,cPathRelW, cmv_par12, lAutoma)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1         := OemToAnsi(STR0001) //"Este programa tem como objetivo listar o relatorio"
Local cDesc2         := OemToAnsi(STR0002) //"de Demonstrativo de IR referente aos  12 meses,"
Local cDesc3         := OemToAnsi(STR0003) //"a partir do Ano de referencia informado."
Local cPict          := ""
Local imprime        := .T.
Local aOrd           := {}
Local nMes
Local nPos1			 := 0
Local nPos2			 := 0
LOCAL cFileName		:= "IR"+CriaTrab(NIL,.F.)
Local aRet			:=	{}
Local 	cMvTitDeIR 	:= AllTrim(GetNewPar("MV_PLSTDIR","")) //Substitui o título do relatório de demonstrativo de IR do PLS.
Local cPict   := "@E 99,999,999.99"

Private cMvPLSMDIR 	:= AllTrim(GetNewPar("MV_PLSMDIR","")) //Apresenta mensagem no final do relatório de demonstrativo de IR do PLS.
Private cTitulo      := FunDesc() //"Demonstrativo de Imposto de Renda"
Private aCabec1      := {}                    "
Private cCabec2      := "                    "
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private cTamanho     := "G"
Private cNomeprog    := "PLSR997" // Coloque aqui o nome do programa para impressao no cabecalho
Private nCaracter    := 18
Private aReturn      := { OemToAnsi(STR0004), 1, OemToAnsi(STR0005), 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag		 := 01
Private wnrel		 := "PLSR997" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nLimite		 := 220
Private cPerg        := "PLR997R"
Private cAlias       := "BM1"
Private cSintetico   := ""
Private nLi          := 0
Private nLinPag      := 58
Private cOper			:=	""
Private cEmpDe			:= 	""
Private cEmpAte			:= 	""
Private cConDe			:= 	""
Private cConAte			:= 	""
Private cSubDe			:= 	""
Private cSubAte			:= 	""
Private cMatDe			:= 	""
Private cMatAte			:= 	""
Private nListar			:=	0
Private nTipo			:=	0
Private aDesMes			:=  {}
Private lReembolso		:=	.T.
Private cRelName:= "PLSR997" + "" + DtoS(Date()) + "" + StrTran(Time(),":")

Default lWeb := .F.
Default cmv_par12 := 1 // Reembolso Sim(mv_par12==1)
Default lAutoma	:= .F.
Default cPathRelW := GETMV("MV_RELT")

	lautoSt := lAutoma

	//-- LGPD ---------- NÃO FOI EFETUADO A LGPD DENTRO DO PORTAL.
	// if !objCENFUNLGP:getPermPessoais() 
	// 	objCENFUNLGP:msgNoPermissions()
	// 	Return
	// Endif
	//------------------

	// PE para Informes customizados, nestes casos não segue o restante da função
	If ExistBlock("PLR997IR")
		aParPoe := {cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06,;
					cmv_par07, cmv_par08, cmv_par09, cmv_par10, cmv_par11,lWeb	,cPathRelW, cmv_par12}
		xRetPoe := ExecBlock("PLR997IR",.f.,.f., aParPoe )
		Return(xRetPoe)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa ambiente do relatorio somente top...                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PLSRelTop()
		Return .F.
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta perguntas                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Verifica se o grupo de perguntas foi criado (U_UPDPLS70) junto com o patch desta FNC

	If !lWeb .AND. !lautoSt
		If !(SX1->(dbSeek(cPerg)))
			MsgInfo(STR0006) //"Para a execução desta rotina é necessário a execução do compatibilizador U_UPDPLS70."
			return(nil)
		Endif
	Endif

	If lWeb
		cNomeProg:=cFileName
	Endif

	If !lautoSt .AND. lWeb .and. cmv_par01 # Nil
		cPerg := ""
		mv_par01 := cmv_par01
		mv_par02 := cmv_par02
		mv_par03 := cmv_par03
		mv_par04 := cmv_par04
		mv_par05 := cmv_par05
		mv_par06 := cmv_par06
		mv_par07 := cmv_par07
		mv_par08 := cmv_par08
		mv_par09 := cmv_par09
		mv_par10 := cmv_par10
		mv_par11 := cmv_par11
		mv_par12 := cmv_par12
	Else
		Pergunte(cPerg,.T.)
	Endif

	cOper  		:= mv_par01
	cEmpDe		:= mv_par02
	cEmpAte		:= mv_par03
	cConDe		:= mv_par04
	cConAte		:= mv_par05
	cSubDe		:= mv_par06
	cSubAte		:= mv_par07
	cMatDe		:= mv_par08
	cMatAte		:= mv_par09
	nAno    	:= mv_par10
	nListar		:= mv_par11
	lReembolso	:= mv_par12 == 1 // Reembolso Sim(mv_par12==1)

	nMes    := 1

	If  nMes <= 0
		nAno -= 1
		If  nMes == 0
			nMes := 1
		Else
			nMes += 12
		Endif
	Endif

	nMesIni := 01
	nMesFim := 12
	cMesIni := '01'
	cMesFim := '12'
	cAnoIni := cvaltochar(nAno)
	cAnoFim := cvaltochar(nAno)

	If Empty(cMvTitDeIR)
		cTitulo:=	STR0007+"- "+cAnoIni //"          INFORME DE PAGAMENTOS  "###" - "
	Else
		cTitulo:=	cMvTitDeIR+"-"+cAnoIni // Titulo conforme parametro
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta descricao do cabecalho                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos1 := nMesIni
	cAno  := cAnoIni
	
	For nPos2 := 1 to 12
		AAdd(aCabec1, MesExtenso(nPos2) + "/" + cAno)
		nPos1 += 1
		If  nPos1 > 12
			nPos1 := 1
			cAno  := cAnoFim
		Endif
	Next
		
	AAdd(aCabec1, STR0008  + "/" + cAno) //"         Total"

	if !lWeb .AND. !lAutoSt .AND. !lAutoma
		RptStatus({|aRet| RunReport(aCabec1,cCabec2,cTitulo,lweb,cPathRelW) },cTitulo)
	else
		aRet := RunReport( aCabec1,cCabec2,cTitulo,lWeb,cPathRelW)
	endif
	
Return aRet

// /*/
// ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
// ±±ºFunção    RunReport º Autor ³ Guilherme Carreiro º Data ³  11/02/2022 º±±
// ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
// ±±ºDescrição ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
// ±±º          ³ monta a janela com a regua de processamento.               º±±
// ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
// ±±ºUso       ³ Programa principal                                         º±±
// ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
// /*/
Static Function RunReport(aCabec1,cCabec2,cTitulo,lWeb,cPathRelW)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aRecDes := {}
	Local aMes    := array(12)
	Local nPos
	Local nPos1
	Local nPos2
	Local nMes
	Local cLinha
	Local cCPF		:=""
	Local cNome		:=""
	Local aRecTotDes:={}
	Local aRecDetal	:={}
	Local aRecReemb	:={}
	Local cObs		:=""
	Local nLinObs	:=0
	Local aObs		:={}
	Local nObs		:=0
	Local nTotRec
	Local nTotDes
	Local cPict   := "@E 99,999,999.99"
	Local cAntes  := ""
	Local cDepois := ""
	local lImp	:=.T.
	Local nPos1i	:= 0
	Local nPos2i	:= 0
	Local nPos1E	:= 0
	Local nPos2E	:= 0
	Local nFor		:= 0
	Local nItRem	:= 0
	Local cLinha2	:= ""
	local nLinRef		:= 0
	Local aRecComp := {}
	Local cCompetencia := ""
	Local nPosComp := 0
	Local nPosComp2 := 0
	Local nMesCompetencia := 0
	Local cAnoCompetencia := ""
	Local cSinalComp := ""
	Local dDataEmissao := "Data de Emissão: " + DTOC(dDataBase) + " " + TIME()
	Local nTotPag := 0
	Local nValPag := 0
		
	private nLinMax		:= 0
	private nColMax		:= 0
	private nLinIni		:= 0
	private nColIni		:= 0
	private oFontDef1  	:= TFont():New("Arial", 8,  8, , .F., , , , .T., .F.) // Padrao
	private oFontDef2	:= TFont():New("Arial", 10, 10, , .F., , , , .T., .F.) // Padrao reduzida
	private oFontDef3  	:= TFont():New("Arial", 12, 12, , .F., , , , .T., .F.) // Padrao
	private oFontBld1	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	private oFontBld2	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	private oFontBld3	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito	
	private nColRef := 35

	oPrint := FWMSPrinter():New(cRelName,,.F.,cPathRelW,.T.,,,,,.F.)
		
	// Definindo as propriedades
	if lWeb
		oPrint:lServer := lWeb		// Indica se e oriundo do Portal do Beneficiario
		oPrint:setDevice(IMP_PDF)	// Força a impressao em PDF caso for portal
	else
		oPrint:Setup()				// Inicializa o SETUP

		If oPrint:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return ({.F.,"",""})
		EndIf
	endif
	oPrint:SetLandscape()			// Seta o relatorio para o modo paisagem
	
	// Forca tamanho A4
	oPrint:setPaperSize(9)
	
	// Inicializa as variaveis de posicionamento
	nLinIni := 030
	nLinMax	:= 570
	nColIni := 005
	nColMax	:= 820
	nLinRef := 070
	
	// Inicia a primeira pagina
	oPrint:StartPage()
	
	// Cria o box principal
	oPrint:Box(nLinIni, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )

	// Carrega cabeçalho Inicial
	oPrint:Say(	nLinIni + 0030, nColIni + (nColMax * 0.30), cTitulo, oFontBld1,,,,2)

	// Carrega o Número da Página
	oPrint:Say(	nLinIni + 0025, nColIni + (nColMax * 0.75), "Página: " + cValToChar(oPrint:nPageCount), oFontBld1,,,,2)

	// Carrega Data de Emissão
	oPrint:Say(	nLinIni + 0035, nColIni + (nColMax * 0.75), dDataEmissao, oFontBld1,,,,2)

	// Carrega linha pós cabeçalho
	oPrint:Line( 80, nColIni + 10, 80, nColIni + nColMax)

	// Marca a referencia da proxima linha apos o cabecalho
	nLinRef += 15

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca as Informações para a Impressao do relatorio                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRecTotDes:=PLR997Fil(cOper,cEmpDe,cEmpAte,cConDe,cConAte,cSubDe,cSubAte,cMatDe,cMatAte,nAno,nTipo,nListar,lWeb,lReembolso)
	aRecDes		:= aRecTotDes[1]
	aRecDetal	:= aRecTotDes[2]
	aRecReemb	:= IIf ( Len(aRecTotDes)>=3,aRecTotDes[3],{})
	aRecComp	:= IIf ( Len(aRecTotDes)>=4,aRecTotDes[4],{})

	IF len(aRecDes)==0
		Return({.F.,STR0012,""})
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do relatorio                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nPos1 := 1 to len(aRecDes)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime cabecalho                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLinha := aRecDes[nPos1,1] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,2] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,3] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,4] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,5] + IIF(lweb,"",space(01))
		Do Case
			Case ! empty(aRecDes[nPos1,4]) .and. Empty(aRecDes[nPos1,5])
				If  lImp == .T.
					nLi     := 58
				Endif
				
				if(nPos1 != 1)
					oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

					nLinRef := 85
				EndIf
				

				cLinha2:=""
				BA1->(DbSetOrder(1))
				BA1->(MsSeek(xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+"T"))
				
				BA0->(DbSetOrder(1))
				BA0->(MsSeek(xFilial("BA0")+cOper))
				cLinha2  := ""
				cLinha2  := "Operadora: " + AllTrim(BA0->BA0_NOMINT) + Space(10) + "CNPJ: " + Transform(AllTrim(BA0->BA0_CGC), "@R 99.999.999/9999-99" )
				
				IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)
				
				oPrint:Say(	nLinIni + nLinRef, nColIni + 025, cLinha2, oFontBld1,,,,2)
				nLinRef += 10
				
				cLinha2:=""
				
				cObs := FS_OBSORC(cPathRelW,Lweb)
				nLinObs	:= MLCOUNT(cObs, , , )
				
				aObs	:= {}
				cObs:=R97EXMMO(@cObs)
				
				For nObs := 1 To nLinObs
					aADD(aObs,{MEMOLINE(cObs, , nObs, )})
				Next nObs
				
				For nObs := 1 To Len(aObs)
					cLinha2	:= allTrim(aObs[nObs,1]) //+CHR(13) + CHR(10)
					
					IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)
					
					oPrint:Say(	nLinIni + nLinRef, nColIni + 0025, cLinha2, oFontBld1,,,,2)
					nLinRef += 10
				Next nObs
				
				cLinha  :=""
				cLinha  := STR0009 + cLinha + aRecDes[nPos1,1]+"."+aRecDes[nPos1,4]/*+" "+ Posicione("BA1",1,xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+"T","BA1_NOMUSR")*/ + space(01) //".... Familia:    "
				cAntes  := iif(lweb," ", "     ")
				cDepois := iif(lweb,""," ")
				
			Case ! empty(aRecDes[nPos1,5])
				If aRecDes[nPos1,5]="00"
					lImp := .T.
				Endif
				cCPF    := Posicione("BA1",2,xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+aRecDes[nPos1,5],"BA1_CPFUSR")
				cNome   := Posicione("BA1",2,xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+aRecDes[nPos1,5],"BA1_NOMUSR")
				cLinha  :=""
				cLinha  := STR0010 + cLinha +aRecDes[nPos1,4]+"."+aRecDes[nPos1,5]+" "+ Alltrim(cNome) + Space(05) + "CPF: " + Transform(cCPF,"@R 999.999.999-99") + space(01) //"..... Usuario:   "
				cAntes  := iif(lweb," ", "     ")
				cDepois := ""
		EndCase
		
		if((nLinIni + nLinRef) > (nLinMax - 145))
				oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

				nLinRef := 110
		EndIf
			
		oPrint:Say(	nLinIni + nLinRef, nColIni + 70, cLinha, oFontBld1,,,,2)	//Família - Beneficiário
		nLinRef += 10
		aTemMes := {0,0,0,0,0,0,0,0,0,0,0,0}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime receitas                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLinha  :=""
		cLinha  := cAntes + STR0011+" " + cDepois //"Total Pago     "
		nTotRec := 0
		For nPos2 := 9 to 20

			cCompetencia := ""

			cLinha  := aCabec1[nPos2-8]
			
			oPrint:Say(	nLinIni + nLinRef, nColIni + 170, cLinha, oFontDef2,,,,2) //Referências

			cLinha := transform(aRecDes[nPos1,nPos2],cPict)

			oPrint:Say(	nLinIni + nLinRef, nColIni + 280, cLinha, oFontDef2,,,,2) //Valores

			If Len(aRecComp[nPos2-8]) > 0 .And. Val(cLinha) <> 0 //Verifica se o mês possui Competência

				For nPosComp := 1 to Len(aRecComp[nPos2-8]) // For para cada competência do mês

					If(aRecComp[nPos2-8][nPosComp][3] == aRecDes[nPos1][1] + aRecDes[nPos1][2] + aRecDes[nPos1][3] + aRecDes[nPos1][4])

						nMesCompetencia := Val(aRecComp[nPos2-8][nPosComp][1])
						cAnoCompetencia := aRecComp[nPos2-8][nPosComp][2]

						cSinalComp := IIF(nPosComp < Len(aRecComp[nPos2-8])-1, ", ", " e ")
						cSinalComp := IIF(nPosComp == Len(aRecComp[nPos2-8]), "", cSinalComp)

						cCompetencia += MesExtenso(nMesCompetencia) + "/" + cAnoCompetencia + cSinalComp

					EndIf
				Next

				If !Empty(cCompetencia)

					IIF(cSinalComp == ", " .Or. cSinalComp == " e ", cCompetencia := SUBSTRING(cCompetencia, 1, Len(cCompetencia)-Len(cSinalComp)), cCompetencia := cCompetencia)

					cCompetencia := "Competência(s) " + cCompetencia

					oPrint:Say(	nLinIni + nLinRef, nColIni + 330, cCompetencia, oFontDef2,,,,2) //Competências

				EndIf
			EndIf
					
			nTotRec += aRecDes[nPos1,nPos2]
			
			nLinRef += 10
		Next

		oPrint:Say(	nLinIni + nLinRef, nColIni + 90, aCabec1[13], oFontBld3,,,,2) //Total Pago

		oPrint:Say(	nLinIni + nLinRef, nColIni + 270, transform(nTotRec, cPict), oFontBld3,,,,2) //Valor Total

		nLinRef += 20
		
		if(len(aRecDes)>nPos1)
			if((nLinIni + nLinRef) > (nLinMax - 0010)) .and. (!empty(aRecDes[nPos1+1,4]) .and. !Empty(aRecDes[nPos1+1,5]))
				oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

				nLinRef := 110
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime despesas                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLinha  :="" //cAntes + "Iten  " + cDepois
		nTotDes := 0
		If nListar	== 2
			For nPos1i := 1 to len(aRecDetal)
				If nPos1i> len (aRecDetal)
					nPos1i:=20
					loop
				Endif
				iF aRecDetal[nPos1i,1] ==aRecDes[nPos1,1] .and. aRecDetal[nPos1i,2] ==aRecDes[nPos1,2] .and.;
					aRecDetal[nPos1i,3] ==aRecDes[nPos1,3].and. aRecDetal[nPos1i,4] ==aRecDes[nPos1,4].and. aRecDetal[nPos1i,5] ==aRecDes[nPos1,5]
					
					if((nLinIni + nLinRef) > (nLinMax - 140))
						oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

						nLinRef := 110
					EndIf

					For nPos2i := 7 to 20//len(aRecDetal)
						If nPos2i==8
							loop
						endif
						If nPos2i>=9
							nTotDes := aRecDetal[nPos1i,nPos2i]
							
							cLinha := transform(nTotDes   ,cPict) + IIF(lweb,"",space(01))
			
							oPrint:Say(	nLinIni + nLinRef, nColIni + 260, aCabec1[nPos2i-8], oFontDef2,,,,2) //Referências

							oPrint:Say(	nLinIni + nLinRef, nColIni + 370, cLinha, oFontDef2,,,,2) //Valores

							nLinRef += 10

						Else
							cLinha := (aRecDetal[nPos1i,nPos2i]) + IIF(lweb,"",space(01))

							oPrint:Say(	nLinIni + nLinRef, nColIni + 200, cLinha, oFontBld1,,,,2)

							nLinRef += 10
						Endif
						
					Next
					
					IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)
					
					nLinRef += 10
					cLinha:=""
				Endif
			Next
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Reembolso do usuário atual (aRecDes) quando existir em aRecReemb	³
		//³ aRecDes[nPos1,1] == CODEMP													³
		//³ aRecDes[nPos1,2] == CONEMP													³
		//³ aRecDes[nPos1,3] == SUBCON													³
		//³ aRecDes[nPos1,4] == MATRIC													³
		//³ aRecDes[nPos1,5] == TIPREG													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ5ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lReembolso
			nPos1E := aScan(aRecReemb,{|x| ( ;
				x[1] == aRecDes[nPos1,1] .and. ;
				x[2] == aRecDes[nPos1,2] .and. ;
				x[3] == aRecDes[nPos1,3] .and. ;
				x[4] == aRecDes[nPos1,4] .and. ;
				x[5] == aRecDes[nPos1,5])})
				
			If nPos1E > 0 .AND. !aRecReemb[nPos1E][8] // Se existe o mesmo usuario atual em reembolso e não foi impresso... imprime
				
				cLinha := ""
				
				nTotPag := 0

				For nPos2E := 9 to 20

					nValPag := 0

					cLinha := Chr(13) + Chr(10) + Chr(13) + Chr(10)

					If nPos2E == 9
						cLinha := ("Reembolso" + space(40) + "Valor" + IIF(lweb,"",space(01)))

						oPrint:Say(	nLinIni + nLinRef, nColIni + 200, cLinha, oFontBld1,,,,2)

						nLinRef += 10
					Endif
					
					For nItRem := 1 To Len(aRecReemb[nPos1E,nPos2E])

						nValPag += aRecReemb[nPos1E,nPos2E,nItRem,04]
							
						cLinha := transform(nValPag   ,cPict) + IIF(lweb,"",space(01))

						if nItRem == Len(aRecReemb[nPos1E,nPos2E])

							IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)

							oPrint:Say(	nLinIni + nLinRef, nColIni + 240, aCabec1[nPos2E-8], oFontDef2,,,,2) //Referências

							oPrint:Say(	nLinIni + nLinRef, nColIni + 370, cLinha, oFontDef2,,,,2) //Valores

							nLinRef += 10

						EndIf

						nTotPag += aRecReemb[nPos1E,nPos2E,nItRem,04]

					Next nItRem
											
				Next nPos2E
				aRecReemb[nPos1E][8] := .T. //Impresso

				oPrint:Say(	nLinIni + nLinRef, nColIni + 200, "Total", oFontBld3,,,,2) //Total Pago

				oPrint:Say(	nLinIni + nLinRef, nColIni + 340, transform(nTotPag, cPict), oFontBld3,,,,2) //Valor Total

				nLinRef += 20
			
			EndIf

		EndIf
		If !EMPTY(cMvPLSMDIR)
			cLinha  := cMvPLSMDIR

			If((nLinIni + nLinRef) > (nLinMax - 0010))
				oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

				nLinRef := 110
			EndIf
				
			oPrint:Say(	nLinIni + nLinRef, nColIni + 0025, cLinha, oFontBld1,,,,2)
			nLinRef += 10
		EndIf
	Next

	//Imprime
	oPrint:Print()
	
return ({.T.,'',cRelName + ".PDF"})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OBSORC    ³ Autor ³                  ³ Data 28/09/2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para a Exibição da Observação no Relatorio          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_OBSORC(cPathRelW,Lweb)

Local cEnvServ := GetEnvServer()
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())) 
//Local cdirweb	:= getWebDir() + getSkinPls() + "\relatorios\"
Local cNomArq	:= ""
Local cTxtOrc := ""
//Local cNomArq2	:=""

If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "obsimprenda.txt"
Else
	cNomArq := cDirRaiz + "\obsimprenda.txt"
EndIf

/*If !EMPTY(cNomArq) .AND. Lweb
If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cPathRelW + "obsimprenda.txt"
Else
	cNomArq := cPathRelW + "\obsimprenda.txt"
EndIf
Endif*/ 


If !EMPTY(cNomArq) .AND. Lweb
	cNomArq :=cPathRelW+ "obsimprenda.txt"
Endif 

cTxtOrc := MemoRead(cNomArq)

Return (cTxtOrc)

function PLSR997stA(lvalor)
lautoSt := lvalor
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSR997Box    ³ Autor ³                  ³ Data 11/02/2022 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para criar o box das páginas				          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

	oPrint:EndPage()//Finaliza a página
	oPrint:StartPage()// Inicia a página

	// Cria o box da Página
	oPrint:Box(nLinIni, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )

	// Carrega cabeçalho Inicial
	oPrint:Say(	nLinIni + 0030, nColIni + (nColMax * 0.30), cTitulo, oFontBld1,,,,2)

	// Carrega o Número da Página
	oPrint:Say(	nLinIni + 0025, nColIni + (nColMax * 0.75), "Página: " + cValToChar(oPrint:nPageCount), oFontBld1,,,,2)

	// Carrega Data de Emissão
	oPrint:Say(	nLinIni + 0035, nColIni + (nColMax * 0.75), dDataEmissao, oFontBld1,,,,2)

	// Carrega linha pós cabeçalho
	oPrint:Line( 80, nColIni + 10, 80, nColIni + nColMax)

return oPrint