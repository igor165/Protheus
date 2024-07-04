#INCLUDE "PLSR580.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#DEFINE RESETLIN nLinha := 550

Static objCENFUNLGP := CENFUNLGP():New()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSR580 ³ Autor ³ Rafael M. Qudrotti     ³ Data ³ 03.02.04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do boleto bancario SIGAPLS						   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSR580(	cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06,;
					cmv_par07, cmv_par08, cmv_par09, cmv_par10, cmv_par11, cmv_par12,;
					cmv_par13, cmv_par14, cmv_par15, cmv_par16, cmv_par17, cmv_par18,;
					cmv_par19, cmv_par20, cmv_par21, nBloco1, nBloco2, nBloco3,;
					nBloco4, nBloco5 ,lWeb, cPreFix, cNumTit, cParcela, cTipo, cPathRelW,;
					lStatusPago, lGeraPDF, lEnviaEmail)

LOCAL cFileName		:= ""
Local aParPoe		:= {}
Local xRetPoe		:= ""
PRIVATE nQtdLin     := 60
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := FunDesc() //"Emissão de Boleto"
PRIVATE cDesc1      := STR0002 //"Emissao dos boletos de cobranca de acordo com os parametros selecionados."
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "SE1"
PRIVATE cPerg       := "PLR580"
PRIVATE cRel        := "PLSR580"
PRIVATE nli         := 80
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1, "", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
Private nTweb		:= 1
Private nLweb		:= 0
Private cPathSrv 	:= GetSrvProfString("Startpath","")
PRIVATE cFileJpg 	:= "ImgBol.BMP" 		// Nome do Arquivo que será Impresso na Terceira Pagina do Relatorio
PRIVATE cPathSrvJ 	:= GETMV("MV_RELT")
PRIVATE cPathFilJ	:= UPPER(cPathSrv+cFileJpg)
Private oPrint

DEFAULT lWeb		:= .F.
DEFAULT cPreFix		:= ""
DEFAULT cNumTit		:= ""
DEFAULT cParcela	:= ""
DEFAULT cTipo		:= ""
DEFAULT cPathRelW	:= ""
DEFAULT nBloco1     := 2
DEFAULT nBloco2		:= 2
DEFAULT nBloco3		:= 1
DEFAULT nBloco4		:= 1
DEFAULT nBloco5		:= 1
DEFAULT lStatusPago := .F.
DEFAULT lGeraPDF := .F.
DEFAULT lEnviaEmail := .F.

/*if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif*/

// PE para boletos customizados, nestes casos não segue o restante da função
If ExistBlock("PL580BOL")
	aParPoe := {cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06,;
				cmv_par07, cmv_par08, cmv_par09, cmv_par10, cmv_par11, cmv_par12,;
				cmv_par13, cmv_par14, cmv_par15, cmv_par16, cmv_par17, cmv_par18,;
				cmv_par19, cmv_par20, cmv_par21, nBloco1, nBloco2, nBloco3,;
				nBloco4, nBloco5 ,lWeb, cPreFix, cNumTit, cParcela, cTipo, cPathRelW}
	xRetPoe := ExecBlock("PL580BOL",.f.,.f., aParPoe )
	Return(xRetPoe)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Ajusta o diretorio para gravacao do arquivo na web
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lWeb .Or. lGeraPDF
	cFileJpg := "ImgBol.jpg" 		// Nome do Arquivo que será Impresso na Terceira Pagina do Relatorio

	If !Empty(cPathRelW)
		cPathSrvJ := cPathRelW
	EndIf

	cPathFilJ := UPPER(cPathSrvJ+cFileJpg)
	nTweb := 3.9
	nLweb := 10
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa ambiente do relatorio somente top...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PLSRelTop()
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint (padrao)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lWeb
	If cmv_par01 # Nil
		cPerg 	 := ""
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
		mv_par13 := cmv_par13
		mv_par14 := cmv_par14
		mv_par15 := cmv_par15
		mv_par16 := cmv_par16
		mv_par17 := cmv_par17
		mv_par18 := cmv_par18
		mv_par19 := cmv_par19
		mv_par20 := cmv_par20
		mv_par21 := cmv_par21
	Else
		If !Pergunte(cPerg,.T.)
			Return .F.
		EndIf

		nBloco1 := mv_par22
		nBloco2 := mv_par23
		nBloco3 := mv_par24
		nBloco4 := mv_par25
		nBloco5 := mv_par26
	EndIf
Else
	mv_par19 := cmv_par19
	mv_par20 := cmv_par20

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         				³
//³ mv_par01 // Cliente de                                       				³
//³ mv_par02 // Loja ate                                        				³
//³ mv_par03 // Cliente ate                                      				³
//³ mv_par04 // Loja                                            				³
//³ mv_par05 // Operadora de                                     				³
//³ mv_par06 // Operadora ate                                    				³
//³ mv_par07 // Empresa de                                       				³
//³ mv_par08 // Empresa ate                                      				³
//³ mv_par09 // Contrato de                                      				³
//³ mv_par10 // Contrato ate                                     				³
//³ mv_par11 // Sub-Contrato de                                  				³
//³ mv_par12 // Sub-Contrato ate                                                ³
//³ mv_par13 // Matricula De                                       				³
//³ mv_par14 // Matricula Ate                                                   ³
//³ mv_par15 // Mes de                                          				³
//³ mv_par16 // Ano de                                           				³
//³ mv_par17 // Mes Ate                                         				³
//³ mv_par18 // Ano Ate                                          				³
//³ mv_par19 // Detalha Cobranca - Por Usuario/Por Tipo Cobranca                ³
//³ mv_par20 // Gera lancamento de segunda via de boleta...                     ³
//³ mv_par21 //                                                                 ³
//³ mv_par22 // Imprime Primeira parte do Boleto                                ³
//³ mv_par23 // Imprime Segunda  parte do Boleto                                ³
//³ mv_par24 // Imprime Terceira parte do Boleto                                ³
//³ mv_par25 // Imprime Quarta parte do Boleto                                  ³
//³ mv_par26 // Salva Imagem Boleto no     Spoll?                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lWeb
	cFileName := R580Imp(lWeb,cPreFix,cNumTit,cParcela,cTipo,nBloco1,nBloco2,nBloco3,nBloco4,nBloco5,lStatusPago,lGeraPDF,lEnviaEmail)
Else
	MsAguarde({|| R580Imp(lWeb,cPreFix,cNumTit,cParcela,cTipo,nBloco1,nBloco2,nBloco3,nBloco4,nBloco5,lStatusPago,lGeraPDF,lEnviaEmail) }, cTitulo, "", .T.)	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cFileName)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R580Imp  ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 14.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R580Imp(lWeb,cPre,cNTit,cPar,cTp,nBloco1,nBloco2,nBloco3,nBloco4,nBloco5,lStatusPago,lGeraPDF,lEnviaEmail)
LOCAL cSQL			:= ""							// Select deste relatorio
LOCAL cSE1Name 		:= SE1->(RetSQLName("SE1"))	// Retorna o nome do alias no TOP
LOCAL cPrefixo 		:= ""							// Prefixo do titulo
LOCAL cTitulo 		:= ""							// Titulo
LOCAL cParcela 		:= ""							// Parcela do titulo
LOCAL cTipo 		:= ""							// E1_TIPO
LOCAL aDadosEmp		:= {}							// Array com os dados da empresa.
LOCAL aDadosTit		:= {}							// Array com os dados do titulo
LOCAL aDadosBanco   := {}							// Array com os dados do banco
LOCAL aDatSacado	:= {}							// Array com os dados do Sacado.
LOCAL CB_RN_NN  	:= {}							// Array com as informacoes do Nosso Numero, Codigo de Barras, e Linha digitavel.
LOCAL aBmp			:= { "" }						// Vetor para Bmp.
LOCAL cOperadora    := BX4->(PLSINTPAD())			// Retorna a operadora do usuario.
LOCAL aBfq			:= {}
LOCAL aDependentes	:= {}							// Array com os dependentes do sacado.
LOCAL aOpenMonth	:= {}							// Array com os meses em aberto.
LOCAL aObservacoes  := {}							// Array com as observacoes do extrato.
LOCAL aMsgCorpo 	:= {}							// Array com as observacoes do corpo do boleto.
LOCAL aMsgBoleto    := {}							// Array com as mensagens do boleto.
LOCAL nPos			:= 0							// Variavel auxiliar para ascan.
LOCAL cSA6Key		:= ""							// Chave de pesquisa do SA6 Cadastro de bancos,
LOCAL lUnimeds      := IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.) // Retorna se operadora e UNIMED ou nao!
LOCAL aUsrVlr   	:= {}
LOCAL cSusEp		:= ""
LOCAL cFileName		:= "BOLETO"+CriaTrab(NIL,.F.)
LOCAL aFile			:= {}
LOCAL nI          	:= 0
LOCAL nValor		:= 0
LOCAL nHandleOk		:= 0
// Pode ser trocada a carteira em subfunções via ponto de entrada, enviada por parametro.
LOCAL cCart	    	:= "9"							// Carteira do titulo
LOCAL cEspec		:= "R$"							// Especie do Documento
LOCAL cAceite		:= "N"							// Aceite do Documento
LOCAL aUtilCob		:= {}							// Array com as utilizações cobradas.
LOCAL aArquivo		:= {}
LOCAL aCobBol		:= {}
LOCAL aDadBol		:= {}
LOCAL ccodtip 		:= ""
LOCAL cNovoNom  	:= ""

LOCAL oPrtPag 		:= Nil //Objeto auxiliar para o saveAllasJPEG
LOCAL lHtml			:= .F.
lOCAL AITEMREAJ		:={}
Local aReajuste		:={}
Local lIncl			:=.T.
Local lacob			:=.F.
Local lPL580MSO     := ExistBlock("PL580MSO")
Local lPL580MSB     := ExistBlock("PL580MSB")
Local lPL580MGC     := ExistBlock("PL580MGC")
Local cAnexo 		:= ""

PRIVATE _nQtdInscr 	:= 0
PRIVATE _nQtdMens	:= 0
PRIVATE _nQtdOpc	:= 0

DEFAULT lWeb		:= .F.
DEFAULT cPre		:= ""
DEFAULT cNTit		:= ""
DEFAULT cPar		:= ""
DEFAULT cTp			:= ""
DEFAULT lStatusPago := .F.
DEFAULT lGeraPDF := .F.
DEFAULT lEnviaEmail := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If Valtype(nBloco5)=="N"
	lHtml := (nBloco5 == 2)
EndIf

If !lWeb .And. !lGeraPDF 
	oPrint:= TMSPrinter():New( STR0003 ) //"Boleto Laser"
Else	
	oPrint := FWMSPrinter():New(cFileName,	6, .F.,	Nil, .T., Nil, Nil, Nil, Nil,.F.)
	
	If lWeb
		oPrint:lInJob  := lWeb
		oPrint:lServer := lWeb
		oPrint:cPathPDF := cPathSrvJ
		oPrint:setDevice(IMP_PDF)
	Else
		oPrint:Setup()			

		If oPrint:nModalResult == 2 // Impressão Cancelada
			Return
		EndIf
	EndIf
	
Endif

oPrint:SetPortrait()
oPrint:SetPaperSize(9)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Verifica se as configuracoes de impressora foram definidas para
//³que o objeto possa ser trabalhado.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !lWeb .And. !(oPrint:IsPrinterActive()) .And. !lGeraPDF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³"Impressora"###"As configurações da impressora não foram encontradas. Por favor, verifique as configurações para utilizar este relatório. "
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Aviso(STR0041,STR0042,{"OK"})
	oPrint:Setup()
	Return (.F.)
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagem...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lWeb
	MsProcTxt(PLSTR0001)//#include "PLSMGER.CH"
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Ordena arquivos envolvidos...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SE1->(DbSetOrder(02))
BBT->(dbSetorder(07))
BM1->(DbSetOrder(04))
BA1->(DbSetOrder(02))
BA0->(DbSetorder(01))
BI3->(DbSetorder(01))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := 	" SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_ANOBASE, E1_MESBASE, E1_CODINT, E1_CODEMP, E1_CONEMP, E1_SUBCON, "
cSQL +=		" E1_MATRIC, E1_PORTADO, E1_AGEDEP, E1_NUMBOR, E1_CONTA, E1_SALDO, E1_IRRF, E1_EMISSAO, E1_VENCTO, E1_SDDECRE, E1_SDACRES,E1_PLNUCOB,E1_FILIAL, R_E_C_N_O_ "
cSQL += 	" FROM "+cSE1Name+" WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND "

If !lWeb
	cSQL += 	" E1_CLIENTE || E1_LOJA >= '"+mv_par01+mv_par02+"' AND "
	cSQL += 	" E1_CLIENTE || E1_LOJA <= '"+mv_par03+mv_par04+"' AND "
	cSQL += 	" E1_CODINT >= '"+mv_par05+"' AND E1_CODINT <= '"+mv_par06+"' AND "
	cSQL += 	" E1_CODEMP >= '"+mv_par07+"' AND E1_CODEMP <= '"+mv_par08+"' AND "
	cSQL += 	" E1_CONEMP >= '"+mv_par09+"' AND E1_CONEMP <= '"+mv_par10+"' AND "
	cSQL += 	" E1_SUBCON >= '"+mv_par11+"' AND E1_SUBCON <= '"+mv_par12+"' AND "
	cSQL += 	" E1_MATRIC >= '"+mv_par13+"' AND E1_MATRIC <= '"+mv_par14+"' AND "
	cSQL += 	" E1_ANOBASE || E1_MESBASE >= '"+mv_par16+mv_par15+"' AND "
	cSQL += 	" E1_ANOBASE || E1_MESBASE <= '"+mv_par18+mv_par17+"' AND E1_SALDO > 0 AND "
	
	If !Empty(MV_PAR21)
		cSql += " E1_PLNUCOB = '"+PlsIntPad()+MV_PAR21+"' AND "
	EndIf
Else
	cSql += " E1_PREFIXO = '" + cPre + "' AND "
	cSql += " E1_NUM = '" + cNTit + "' AND "
	cSql += " E1_PARCELA = '" + cPar + "' AND "
	cSql += " E1_TIPO = '" + cTp + "' AND "
EndIf

If !lStatusPago
	//Status B para atender MobileSaude
	cSql += " E1_STATUS IN ('A','B') AND "       
EndIf

If !IsInCallStack('PLSCALLCENTER')
	cSQL += " E1_SITUACA > '0' AND "
Endif	

If ! Empty(aReturn[7])
	cSQL += aReturn[7] + " AND "
Endif

cSQL += cSE1Name+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "

cSQL	:= ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"R580Imp",.T.,.F.)

If R580Imp->(Eof())
	R580Imp->(DbCloseArea())
	Help("",1,"RECNO")
	Return
Endif

TCSETFIELD("R580Imp","E1_IRRF",		"N",17,2)
TCSETFIELD("R580Imp","E1_SALDO",	"N",17,2)
TCSETFIELD("R580Imp","E1_SDDECRE",	"N",17,2)
TCSETFIELD("R580Imp","E1_SDACRES",	"N",17,2)
TCSETFIELD("R580Imp","E1_EMISSAO",	"D",08,0)
TCSETFIELD("R580Imp","E1_VENCTO",	"D",08,0)
TCSETFIELD("R580Imp","R_E_C_N_O_",	"N",17,0)






While ! R580Imp->(Eof())
	
	If !lWeb
		oPrtPag := TMSPrinter():New( STR0003 ) //"Boleto Laser"
	Else
		oPrtPag:=  FWMSPrinter():New( cFileName,6,.F.,,.T.,,,,,.F.) //"Boleto Laser"
	Endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Inicio da impressao dos detalhes...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	
	
	oPrtPag:SetPortrait()
	oPrtPag:SetPaperSize(9)
	//	oPrtPag:StartPage()

	
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca Bmp da empresa.³// Logo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File("lgrl" + FWGrpCompany() + FWCodFil() + ".Bmp")
		aBMP := { "lgrl" + FWGrpCompany() + FWCodFil() + ".Bmp" }
	ElseIf File("lgrl" + FWGrpCompany() + ".Bmp")
		aBMP := { "lgrl" + FWGrpCompany() + ".Bmp" }
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona a operadora padrao...                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA0->( DbSeek(xFilial("BA0") + cOperadora) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia laco para a impressao  dos boletos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	// Informações de reajuste
	aReajuste:={}
	
	BA3->(dbSetOrder(1))
	If BA3->(dbSeek(xFilial("BA3")+R580Imp->(E1_CODINT+E1_CODEMP)))
		BI3->(dbSetOrder(1))
		If BI3->(dbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
			
			BHL->(DbSetOrder(3))//BHL_FILIAL, BHL_CODOPE, BHL_CODEMP, BHL_MATRIC, BHL_ANOREA, BHL_MESREA
			If BHL->(DbSeek(xFilial("BHL")+R580Imp->(E1_CODINT+E1_CODEMP)))
				
				BHW->(dbSetOrder(1)) 	//BHW_FILIAL, BHW_CODINT, BHW_CODREA
				If BHW->(dbSeek(BHL->(BHL_FILIAL+BHL_CODOPE+BHL_CODREA)))
					BP7->(DbSetOrder(2))
					If BP7->(DbSeek(xFilial("BP7")+BHL->(BHL_CODOPE+BHL_CODREA)))
						
						If R580Imp->E1_ANOBASE+R580Imp->E1_MESBASE == BHL->BHL_ANOREA+BHL->BHL_MESREA
							aadd(aReajuste, BI3->BI3_CODIGO + "-" + Alltrim(LOWER(BI3->BI3_DESCRI)) + If(Substr(BI3->BI3_SUSEP,1,2)=="99", "",  " ANS: " + Alltrim(BI3->BI3_SUSEP)))
							aadd(aReajuste, "Cliente: " + LOWER(R580Imp->E1_CLIENTE) + IIF(!Empty(R580Imp->E1_MATRIC)," Matric: " + BA3->BA3_MATRIC,"") + " Mês Reajuste: " + BHL->BHL_MESREA)
							aadd(aReajuste, " 	                                                                ")
							aadd(aReajuste, "Indice Aplicado: " + cvaltochar((BP7->BP7_PERREA))+ " %  ")
							aadd(aReajuste, " "+LOWER(BHW->BHW_MSG01))
							aadd(aReajuste, " "+LOWER(BHW->BHW_MSG02))
							aadd(aReajuste, " "+LOWER(BHW->BHW_MSG03))
						Endif
					Endif
				Endif
			eNDIF
		Endif
		
		
	Endif
	
	

	aCobranca	:= {}
	cPrefixo 	:= R580Imp->E1_PREFIXO
	cTitulo 	:= R580Imp->E1_NUM
	cParcela 	:= R580Imp->E1_PARCELA
	cTipo 		:= R580Imp->E1_TIPO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona tabelas envolvidas...           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE1->( dbGoto(R580Imp->R_E_C_N_O_) )
	BBT->( DbSeek(xFilial("BBT") + cPrefixo + cTitulo + cParcela + cTipo))
	BG9->( DbSeek(xFilial("BG9") + BBT->BBT_CODOPE + BBT->BBT_CODEMP ))
	BA3->( DbSeek(xFilial("BA3") + BM1->BM1_CODINT + BM1->BM1_CODEMP + BM1->BM1_MATRIC))
	BI3->( DbSeek(xFilial("BI3") + BA3->BA3_CODPLA + BA3->BA3_VERSAO) )
	SA1->( DbSeek(xFilial("SA1") + R580Imp->E1_CLIENTE + R580Imp->E1_LOJA))
	
	aDependentes := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona os BM1 envolvidos na fatura...             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltro := " SELECT BM1_NOMUSR, BM1_MATUSU, BM1_IDAFIN, BM1_IDAINI, BM1_VERCON, BM1_CONEMP, BM1_CODINT, BM1_CODEMP, BM1_MATRIC, BM1_CODTIP, "
	cFiltro += " BM1_ATOCOO, BM1_VALOR, BM1_DESTIP, BM1_SUBCON, BM1_VERSUB, BM1_CODEVE, BM1_LTOTAL ,BM1_TIPO "
	cFiltro	+= " FROM "+RetSqlName("BM1")+" WHERE "
	cFiltro += " BM1_PREFIX = '"+cPrefixo+"' 	AND "
	cFiltro += " BM1_NUMTIT = '"+cTitulo +"' 	AND "
	cFiltro += " BM1_PARCEL = '"+cParcela+"'     AND "
	cFiltro += " BM1_TIPTIT = '"+cTipo+"'		AND "
	cFiltro += " D_E_L_E_T_ <> '*' "
	iF mv_par19 == 1
		cFiltro += " ORDER BY BM1_CODEMP, BM1_CONEMP, BM1_VERCON, BM1_SUBCON, BM1_VERSUB,BM1_MATUSU,BM1_CODTIP, BM1_IDAINI, BM1_IDAFIN "
	eLSE
		cFiltro += " ORDER BY BM1_CODEMP, BM1_CONEMP, BM1_VERCON, BM1_SUBCON, BM1_VERSUB,BM1_CODTIP, BM1_IDAINI, BM1_IDAFIN "
	eNDIF
	
	cFiltro	:= ChangeQuery(cFiltro)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB2",.T.,.F.)
	
	TCSETFIELD("TRB2","BM1_IDAFIN",	"N",17,2)
	TCSETFIELD("TRB2","BM1_IDAINI",	"N",17,2)
	TCSETFIELD("TRB2","BM1_VALOR",	"N",17,2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Em caso de pessoa juridica, nao emite os dependentes.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BG9->BG9_TIPO  == '1' //Pessoa Fisica
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca de dependentes para impressao dos dados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("BA1")
		If DbSeek(xFilial("BA1") + TRB2->BM1_CODINT + TRB2->BM1_CODEMP + TRB2->BM1_MATRIC)
			
			While 	(!EOF() .And. 	xFilial("BA1")  == BA1->BA1_FILIAL .And.;
				BA1->BA1_CODINT == TRB2->BM1_CODINT .And.;
				BA1->BA1_CODEMP == TRB2->BM1_CODEMP .And.;
				BA1->BA1_MATRIC == TRB2->BM1_MATRIC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Identifica os usuarios que fazem parte do titulo posicionado. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If 	BG9->BG9_TIPO == "1" .And. (SubStr(DtoS(BA1->BA1_DATINC),1,6) <= R580Imp->E1_ANOBASE+R580Imp->E1_MESBASE) .And. (Empty(BA1->BA1_MOTBLO))
					Aadd(aDependentes, {BA1->BA1_TIPREG,SUBSTR(BA1->BA1_NOMUSR,1,25),DtoC(BA1->BA1_DATINC)})
				EndIf
				
				DbSkip()
			End
		EndIf
	EndIf
	DbSelectArea("R580Imp")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna os meses em aberto do sacado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOpenMonth 	:= PLR580MES(R580Imp->E1_CLIENTE,R580Imp->E1_LOJA,R580Imp->E1_MESBASE,R580Imp->E1_ANOBASE, cTipo)
	aUsrVlr 	:= {}
	
	TRB2->( dbGotop() )
	While !TRB2->(Eof())
		
		nValor:=0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se eh debito ou credito                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  TRB2->BM1_TIPO <> "1"
			nValor := TRB2->BM1_VALOR * -1
		Else
			nValor := TRB2->BM1_VALOR
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Padrao de boletos para UNIMED...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If lUnimeds .and. BG9->BG9_TIPO == '2' .and. !lweb 
			If (Alltrim(BA3->BA3_MODPAG) == '1' .and. mv_par19 <> 3) .or. Alltrim(BA3->BA3_MODPAG) <> '1'
				If (nPos := Ascan(aCobranca, {|x| x[1] = TRB2->BM1_CODTIP .and. x[4] == TRB2->BM1_ATOCOO })) > 0
					aCobranca[nPos][3] += nValor
				Else
					Aadd(aCobranca, { TRB2->BM1_CODTIP, TRB2->BM1_DESTIP, nValor, TRB2->BM1_ATOCOO})
				Endif
				
				If TRB2->BM1_CODTIP == '101'
					_nQtdMens ++
					
				Elseif TRB2->BM1_CODTIP == '103'
					_nQtdInscr++
					
				Endif
			Else
				aAcumula 	:= {}
				cNumCon		:= TRB2->BM1_CONEMP
				cVerCon		:= TRB2->BM1_VERCON
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta array com as faixas etarias...                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Quebra do contrato...
				If !Empty(TRB2->BM1_CONEMP)
					Aadd(aCobranca, {'01',STR0054+TRB2->BM1_CONEMP+STR0055+TRB2->BM1_VERCON} ) //"Contrato ->   "###" / Versao -> "
				Endif
				While !TRB2->( Eof() ) .and. TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quebra do sub contrato...                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(TRB2->BM1_SUBCON)
						Aadd(aCobranca, {'02', STR0056+TRB2->BM1_SUBCON+STR0055+TRB2->BM1_VERSUB+; //"Sub Contrato ->         "###" / Versao -> "
						" - "+Posicione("BQC",1,xFilial("BQC")+;
						TRB2->BM1_CODINT+TRB2->BM1_CODEMP+;
						TRB2->BM1_CONEMP+TRB2->BM1_VERCON+;
						TRB2->BM1_SUBCON+TRB2->BM1_VERSUB,;
						"BQC_DESCRI")} )
					Endif
					
					cSubCon		:= TRB2->BM1_SUBCON
					cVerSub		:= TRB2->BM1_VERSUB
					While !TRB2->( Eof() ) .and. TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon .and. ;
						TRB2->BM1_SUBCON == cSubCon .and. TRB2->BM1_VERSUB == cVerSub
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Quebra do produto...                                                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If TRB2->BM1_CODTIP $ '101,102'
							Aadd(aCobranca, {'03', STR0057+Alltrim(TRB2->BM1_CODEVE)+STR0055+TRB2->BM1_VERCON+; //"Produto ->                    "###" / Versao -> "
							" - "+Posicione("BI3",1,xFilial("BI3")+TRB2->BM1_CODINT+Substr(TRB2->BM1_CODEVE,1,4),"BI3_DESCRI")} )
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Taxa de adesao...                                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Elseif TRB2->BM1_CODTIP $ '103'
							Aadd(aCobranca, {'04', STR0058} ) //"Taxa de Incricao ->"
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Outros... Custo operacional, cartao, deb/cred, agravo...                 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Else
							Aadd(aCobranca, {'04', TRB2->BM1_DESTIP + "    "} )
							
						Endif
						
						cCodEve		:= TRB2->BM1_CODEVE
						While !TRB2->( Eof() ) .And. 	TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon .and. ;
							TRB2->BM1_SUBCON == cSubCon .and. TRB2->BM1_VERSUB == cVerSub .and. ;
							TRB2->BM1_CODEVE == cCodEve
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Lancamentos por faixa etaria tem tratamento separado...                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If TRB2->BM1_CODTIP $ '101,102,103'
								If (nPos := Ascan(aCobranca, {| x |	 x[1] == '05' .and. x[3] == nValor  .and.;
									x[06] == TRB2->BM1_CODINT .and. x[07] == TRB2->BM1_CODEMP .and.;
									x[08] == TRB2->BM1_CONEMP .and. x[09] == TRB2->BM1_VERCON .and.;
									x[10] == TRB2->BM1_SUBCON .and. x[11] == TRB2->BM1_VERSUB .and.;
									x[04] == TRB2->BM1_IDAINI .and. x[05] == TRB2->BM1_IDAFIN })) == 0
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Obtem os valores de faixas, opcional e taxa de adesao, para o resumo final...  |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If TRB2->BM1_CODTIP == '101'
										_nQtdMens  += nValor
										
									Elseif TRB2->BM1_CODTIP == '102'
										_nQtdOpc   += nValor
										
									Elseif TRB2->BM1_CODTIP == '103'
										_nQtdInscr += nValor
										
									Endif
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Alimenta o array para impressao dos lancamentos por faixa etaria...            |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Aadd(aCobranca, {'05', 1, nValor, TRB2->BM1_IDAINI, TRB2->BM1_IDAFIN,;
									TRB2->BM1_CODINT, TRB2->BM1_CODEMP, TRB2->BM1_CONEMP,;
									TRB2->BM1_VERCON, TRB2->BM1_SUBCON, TRB2->BM1_VERSUB,;
									TRB2->BM1_CODTIP, TRB2->BM1_DESTIP})
								Else
									aCobranca[nPos][2] += 1
									
								Endif
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Alimenta o array para impressa do resumo final...                              |
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If (nPos := Ascan(aCobranca, {| x |	 x[1] == '06' .and. x[12] == TRB2->BM1_CODTIP})) == 0
									Aadd(aCobranca, {'05', 1, nValor, TRB2->BM1_IDAINI, TRB2->BM1_IDAFIN,;
									TRB2->BM1_CODINT, TRB2->BM1_CODEMP, TRB2->BM1_CONEMP,;
									TRB2->BM1_VERCON, TRB2->BM1_SUBCON, TRB2->BM1_VERSUB,;
									TRB2->BM1_CODTIP, TRB2->BM1_DESTIP})
								Endif
							Endif
							
							TRB2->( dbSkip() )
						Enddo
					Enddo
				Enddo
			Endif
			
		Else
			cSusEp:=""
			If TRB2->BM1_CODTIP == '101' .OR. TRB2->BM1_CODTIP == '102'
				cSusEp := Posicione("BI3",1,xFilial("BI3")+TRB2->BM1_CODINT+AllTrim(TRB2->BM1_CODEVE),"BI3_SUSEP")
			EndIf
			
			If mv_par19 == 1 .And. TRB2->BM1_LTOTAL == '0'
				//bops melhoria tulio
				nPos := Ascan(aUsrVlr,{|x| x[1] == TRB2->BM1_MATUSU })
				If nPos == 0 .or. TRB2->BM1_CODTIP<> ccodtip
					If !Empty(cSusEp)
						aadd(aUsrVlr,{TRB2->BM1_MATUSU,nValor,SUBSTR(TRB2->BM1_NOMUSR,1,25),""})
						aadd(aUsrVlr,{TRB2->BM1_CODTIP, TRB2->BM1_DESTIP, nValor,"ANS: " + cSusEp})
					Else
						aadd(aUsrVlr,{TRB2->BM1_MATUSU,nValor,SUBSTR(TRB2->BM1_NOMUSR,1,25),""})
						aadd(aUsrVlr,{TRB2->BM1_CODTIP, TRB2->BM1_DESTIP, nValor,""})
						
					Endif
					
				Else
					
					aUsrVlr[nPos,2] +=nValor
				Endif
				
			ElseIf (mv_par19 == 2  ).And. TRB2->BM1_LTOTAL == "0"
				
				If (nPos := Ascan(aCobranca, {|x| x[2] = TRB2->BM1_CODTIP})) > 0
					aCobranca[nPos][4] += nValor
				Else
					IF !Empty(cSusEp)
						Aadd(aCobranca, { TRB2->BM1_MATUSU,TRB2->BM1_CODTIP, TRB2->BM1_DESTIP, nValor,"ANS: " + cSusEp})
					Else
						Aadd(aCobranca, { TRB2->BM1_MATUSU,TRB2->BM1_CODTIP, TRB2->BM1_DESTIP, nValor," "})
					Endif
				Endif
				
				
				
			ElseIf   mv_par19 == 3 .And. TRB2->BM1_LTOTAL == "0"
				
				
				aAcumula 	:= {}
				cNumCon		:= TRB2->BM1_CONEMP
				cVerCon		:= TRB2->BM1_VERCON
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta array com as faixas etarias...                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Quebra do contrato...
				If !Empty(TRB2->BM1_CONEMP)
					Aadd(aCobranca, {'01',STR0054+TRB2->BM1_CONEMP+STR0055+TRB2->BM1_VERCON} ) //"Contrato ->   "###" / Versao -> "
				Endif
				While !TRB2->( Eof() ) .and. TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon
					
					If  TRB2->BM1_TIPO <> "1"
						nValor := TRB2->BM1_VALOR * -1
					Else
						Valor := TRB2->BM1_VALOR
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quebra do sub contrato...                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(TRB2->BM1_SUBCON)
						Aadd(aCobranca, {'02', STR0056+TRB2->BM1_SUBCON+STR0055+TRB2->BM1_VERSUB+; //"Sub Contrato ->         "###" / Versao -> "
						" - "+Posicione("BQC",1,xFilial("BQC")+;
						TRB2->BM1_CODINT+TRB2->BM1_CODEMP+;
						TRB2->BM1_CONEMP+TRB2->BM1_VERCON+;
						TRB2->BM1_SUBCON+TRB2->BM1_VERSUB,;
						"BQC_DESCRI")} )
					Endif
					
					cSubCon		:= TRB2->BM1_SUBCON
					cVerSub		:= TRB2->BM1_VERSUB
					While !TRB2->( Eof() ) .and. TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon .and. ;
						TRB2->BM1_SUBCON == cSubCon .and. TRB2->BM1_VERSUB == cVerSub
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Quebra do produto...                                                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If TRB2->BM1_CODTIP $ '101,102'
							
							Aadd(aCobranca, {'03', STR0057+Alltrim(TRB2->BM1_CODEVE)+STR0055+TRB2->BM1_VERCON+; //"Produto ->                    "###" / Versao -> "
							" - "+Posicione("BI3",1,xFilial("BI3")+TRB2->BM1_CODINT+Substr(TRB2->BM1_CODEVE,1,4),"BI3_DESCRI")} )
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Taxa de adesao...                                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							/*	Elseif TRB2->BM1_CODTIP $ '103'
							Aadd(aCobranca, {'04', 1,  , TRB2->BM1_IDAINI, TRB2->BM1_IDAFIN,;
							TRB2->BM1_CODINT, TRB2->BM1_CODEMP, TRB2->BM1_CONEMP,;
							TRB2->BM1_VERCON, TRB2->BM1_SUBCON, TRB2->BM1_VERSUB,;
							TRB2->BM1_CODTIP, TRB2->BM1_DESTIP}) //"Taxa de Incricao ->"*/
						Elseif TRB2->BM1_CODTIP $ '103'
							Aadd(aCobranca, {'06', STR0058} ) //"Taxa de Incricao ->"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Outros... Custo operacional, cartao, deb/cred, agravo...                 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Else
							Aadd(aCobranca, {'04', 1,  iif (TRB2->BM1_TIPO <> "1", TRB2->BM1_VALOR * -1 ,TRB2->BM1_VALOR), TRB2->BM1_IDAINI, TRB2->BM1_IDAFIN,;
							TRB2->BM1_CODINT, TRB2->BM1_CODEMP, TRB2->BM1_CONEMP,;
							TRB2->BM1_VERCON, TRB2->BM1_SUBCON, TRB2->BM1_VERSUB,;
							TRB2->BM1_CODTIP, TRB2->BM1_DESTIP})
							lacob:=.T.
						Endif
						
						
						
						
						cCodEve		:= TRB2->BM1_CODEVE
						While !TRB2->( Eof() ) .And. 	TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon .and. ;
							TRB2->BM1_SUBCON == cSubCon .and. TRB2->BM1_VERSUB == cVerSub .and. ;
							TRB2->BM1_CODEVE == cCodEve
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Lancamentos por faixa etaria tem tratamento separado...                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If TRB2->BM1_CODTIP $ '101,102,103'
								If (nPos := Ascan(aCobranca, {| x |	 x[1] == '05' .and. x[3] == TRB2->BM1_VALOR .and.;
									x[06] == TRB2->BM1_CODINT .and. x[07] == TRB2->BM1_CODEMP .and.;
									x[08] == TRB2->BM1_CONEMP .and. x[09] == TRB2->BM1_VERCON .and.;
									x[10] == TRB2->BM1_SUBCON .and. x[11] == TRB2->BM1_VERSUB .and.;
									x[04] == TRB2->BM1_IDAINI .and. x[05] == TRB2->BM1_IDAFIN })) == 0
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Obtem os valores de faixas, opcional e taxa de adesao, para o resumo final...  |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If TRB2->BM1_CODTIP == '101'
										_nQtdMens  += nValor
										
									Elseif TRB2->BM1_CODTIP == '102'
										_nQtdOpc   += nValor
										
									Elseif TRB2->BM1_CODTIP == '103'
										_nQtdInscr += nValor
										
									Endif
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Alimenta o array para impressao dos lancamentos por faixa etaria...            |
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Aadd(aCobranca, {'05', 1,  iif (TRB2->BM1_TIPO <> "1", TRB2->BM1_VALOR * -1 ,TRB2->BM1_VALOR), TRB2->BM1_IDAINI, TRB2->BM1_IDAFIN,;
									TRB2->BM1_CODINT, TRB2->BM1_CODEMP, TRB2->BM1_CONEMP,;
									TRB2->BM1_VERCON, TRB2->BM1_SUBCON, TRB2->BM1_VERSUB,;
									TRB2->BM1_CODTIP, TRB2->BM1_DESTIP})
								Else
									aCobranca[nPos][2] += 1
									
								Endif
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Alimenta o array para impressa do resumo final...                              |
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If (nPos := Ascan(aCobranca, {| x |	 x[1] == '04' .and. x[12] == TRB2->BM1_CODTIP})) == 0
									Aadd(aCobranca, {'04', 1,  iif (TRB2->BM1_TIPO <> "1", TRB2->BM1_VALOR * -1 ,TRB2->BM1_VALOR), TRB2->BM1_IDAINI, TRB2->BM1_IDAFIN,;
									TRB2->BM1_CODINT, TRB2->BM1_CODEMP, TRB2->BM1_CONEMP,;
									TRB2->BM1_VERCON, TRB2->BM1_SUBCON, TRB2->BM1_VERSUB,;
									TRB2->BM1_CODTIP, TRB2->BM1_DESTIP})
								Else
									If  !lacob
										aCobranca[nPos][3] += iif (TRB2->BM1_TIPO <> "1", TRB2->BM1_VALOR * -1 ,TRB2->BM1_VALOR)
									Else
										lacob:=.F.
									Endif
								Endif
							Endif
							
							TRB2->( dbSkip() )
						Enddo
					Enddo
				Enddo
				
				
			Endif
		Endif
		cCodTip :=TRB2->BM1_CODTIP
		
		//Ú--------------------------------------------------------------------------¿
		//| Gera lancamento para o faturamento de segunda via de boleto...           |
		//À--------------------------------------------------------------------------Ù
		If mv_par20 == 2
			DbSelectArea("BEE")
			DbSetOrder(1)
			
			If !BEE->(DbSeek(xFilial("BEE")+TRB2->BM1_CODINT+ TRB2->BM1_CODEMP+ TRB2->BM1_MATRIC       ))
				PLSUPT2BOL(TRB2->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC),dDataBase,1)
			Endif
			
		Endif
		
		TRB2->(DbSkip())
	EndDo
	
	For nPos := 1 To Len(aUsrVlr)
		If Mod(nPos,2) == 0
			Aadd(aCobranca, aUsrVlr[nPos,1] + " - " + aUsrVlr[nPos,2]+ " - "+aUsrVlr[nPos,4])
		Else
			AaDd(aCobranca, Trans(aUsrVlr[nPos,1], __cPictUsr + ".!") + " - " +;
			AllTrim(aUsrVlr[nPos,3])+;
			" - R$ " +;
			Trans(aUsrVlr[nPos,2], "@E 99,999.99")+" - "+aUsrVlr[nPos,4])
		EndIf
	Next
	
	aDadosEmp	:= {	BA0->BA0_NOMINT                                                           	,; //Nome da Empresa
	BA0->BA0_END                                                              						,; //Endereço
	AllTrim(BA0->BA0_BAIRRO)+", "+AllTrim(BA0->BA0_CIDADE)+", "+BA0->BA0_EST 						,; //Complemento
	STR0059+Subs(BA0->BA0_CEP,1,5)+"-"+Subs(BA0->BA0_CEP,6,3)             							,; //CEP //"CEP: "
	STR0060+BA0->BA0_TELEF1                                           								,; //Telefones //"PABX/FAX: "
	STR0061+Subs(BA0->BA0_CGC,1,2)+"."+Subs(BA0->BA0_CGC,3,3)+"."+									; //"CNPJ.: "
	Subs(BA0->BA0_CGC,6,3)+"/"+Subs(BA0->BA0_CGC,9,4)+"-"+;
	Subs(BA0->BA0_CGC,13,2)                                                    						,; //CGC
	STR0043 + BA0->BA0_SUSEP }  																		//I.E //"ANS : "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega mensagens de observacao...        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPL580MSO
		aObservacoes := ExecBlock("PL580MSO",.f.,.f.)
	Else
		aObservacoes := PLR580TEXT(2,R580Imp->E1_CODINT	,R580Imp->E1_CODEMP,R580Imp->E1_CONEMP	,;
		R580Imp->E1_SUBCON	,R580Imp->E1_MATRIC ,R580Imp->E1_ANOBASE+R580Imp->E1_MESBASE)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega mensagens do boleto...   		 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPL580MSB
		aMsgBoleto := ExecBlock("PL580MSB",.f.,.f.)
	Else
		aMsgBoleto   := PLR580TEXT(1,R580Imp->E1_CODINT	,R580Imp->E1_CODEMP,R580Imp->E1_CONEMP	,;
		R580Imp->E1_SUBCON	,R580Imp->E1_MATRIC ,R580Imp->E1_ANOBASE+R580Imp->E1_MESBASE)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega mensagens do boleto...   		 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPL580MGC
		aMsgCorpo	 := ExecBlock("PL580MGC",.f.,.f.)
	Else
		aMsgCorpo    := PLR580TEXT(	5,R580Imp->E1_CODINT	,R580Imp->E1_CODEMP	,R580Imp->E1_CONEMP	,;
		R580Imp->E1_SUBCON	,R580Imp->E1_MATRIC 	,R580Imp->E1_ANOBASE+R580Imp->E1_MESBASE,;
		Alltrim(BA3->BA3_MODPAG),BG9->BG9_TIPO)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao exita o banco e agencia no SE1 busca informacoes do SEA.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( (Empty(R580Imp->E1_PORTADO) .OR. Empty(R580Imp->E1_AGEDEP)) .AND. !Empty(R580Imp->E1_NUMBOR) )
		
		SEA->(DbSeek(xFilial("SEA")+R580Imp->E1_NUMBOR+ cPrefixo + cTitulo + cParcela + cTipo      ))
		cSA6Key := SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON
		
	ElseIf !Empty(R580Imp->E1_PORTADO) .AND. !Empty(R580Imp->E1_AGEDEP)
		cSA6Key := R580Imp->E1_PORTADO+R580Imp->E1_AGEDEP+R580Imp->E1_CONTA
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados para codigo de barras³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial()+cSA6Key,.T.)
	// Posiciona SEE, para pegar o EE_CODEMP
	// EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	SEE->(dbSetOrder(1))
	SEE->(dbSeek(xFilial("SEE")+cSA6Key+GetNewPar("MV_PLSBCTA","PLS")))
	
	DbSelectArea("R580Imp")
	aDadosBanco  := {	AllTrim(SA6->A6_NUMBCO),;  //Numero do Banco
	AllTrim(SA6->A6_NREDUZ),;  //Nome do Banco
	AllTrim(SA6->A6_AGENCIA),; //Agencia
	AllTrim(SA6->A6_NUMCON),; 	//Conta Corrente
	AllTrim(SA6->A6_DVCTA),;
	AllTrim(SA6->A6_DVAGE) }   	//Dígito da conta corrente
	
	If Subs(aDadosBanco[1],1,3) == '001' //Banco do Brasil
		cCart := '18'
	ElseIf Subs(aDadosBanco[1],1,3) == '104' //CEF
		cCart 	:= 'SR'
		cEspec	:= 'GUIA'
		cAceite	:= '2'
	EndIf
	
	CB_RN_NN    := 	Ret_cBarra(	Subs(aDadosBanco[1],1,3),;
	aDadosBanco[3],;
	aDadosBanco[4],;
	aDadosBanco[5],;
	Strzero(Val(Alltrim(R580Imp->E1_NUM)),6)+StrZERO(Val(Alltrim(R580Imp->E1_PARCELA)),2),;
	R580Imp->E1_SALDO - R580Imp->E1_IRRF,;
	R580Imp->E1_PREFIXO,;
	R580Imp->E1_NUM,;
	R580Imp->E1_PARCELA,;
	R580Imp->E1_TIPO,;
	cCart,;
	cEspec,;
	cAceite,;
	lWeb )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Testar o retorno do rdmake de layout do boleto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(CB_RN_NN)
		If !MsgYesNo(STR0045) //"Deseja continuar ?"
			R580Imp->(DbCloseArea())
			TRB2->( dbCloseArea() )
			Return NIL
		Else
			R580Imp->(DbSkip())
			TRB2->( dbCloseArea() )
			Loop
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados do Titulo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDadosTit   :=  {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),; 	//Numero do título
	E1_EMISSAO,;             				//Data da emissão do título
	dDataBase,;             				//Data da emissão do boleto
	E1_VENCTO,;             				//Data do vencimento
	E1_SALDO - E1_IRRF,;					//Valor do título
	CB_RN_NN[3],; 							//Nosso numero (Ver fórmula para calculo)
	E1_PREFIXO,; 							//Prefixo
	E1_TIPO }								//Tipo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados Sacado   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDatSacado   := {	AllTrim(SA1->A1_NOME),;      				//Razão Social
	AllTrim(SA1->A1_COD ),;      				//Código
	AllTrim(SA1->A1_END )+"-"+SA1->A1_BAIRRO,;	//Endereço
	AllTrim(SA1->A1_MUN ),;      				//Cidade
	SA1->A1_EST,;      							//Estado
	Transform(SA1->A1_CEP,"@R 99999-999"),; 	//CEP
	AllTrim(SA1->A1_CGC) }						//CPF/CGC
	
	
	aUtilCob := PR580UTILI(R580Imp->E1_PLNUCOB,R580Imp->E1_CODINT,R580Imp->E1_CODEMP,R580Imp->E1_MATRIC)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para pessoa juridica de cooperativas medicas...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUnimeds .and. BG9->BG9_TIPO == '2' .and. !lweb
		R580Graf02(	aCobranca	,E1_SDDECRE		,E1_SDACRES	,oPrint			,;
		aBMP		,aDadosEmp		,aDadosTit	,aDadosBanco	,;
		aDatSacado	,aMsgBoleto		,CB_RN_NN	,aOpenMonth		,;
		aDependentes,aObservacoes	,cCart, BG9->BG9_TIPO, lUnimeds, aMsgCorpo,aUtilCob )
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para demais ocasioes...                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		R580Graf01(	aCobranca	,E1_SDDECRE		,E1_SDACRES	,oPrint			,;
		aBMP		,aDadosEmp		,aDadosTit	,aDadosBanco	,;
		aDatSacado	,aMsgBoleto		,CB_RN_NN	,aOpenMonth		,;
		aDependentes,aObservacoes	,cCart,aMsgCorpo,	aUtilCob,lWeb,aReajuste,nBloco1,nBloco2,nBloco3,nBloco4,nBloco5 )
		
		If lHtml

			// Configurações para Impressão no TMSPrinter
			If lGeraPDF
				cFileJpg := "ImgBol.BMP"
				nTweb := 1
				nLweb := 0
			EndIf

			R580Graf01(	aCobranca	,E1_SDDECRE		,E1_SDACRES	,oPrtPag			,;
			aBMP		,aDadosEmp		,aDadosTit	,aDadosBanco	,;
			aDatSacado	,aMsgBoleto		,CB_RN_NN	,aOpenMonth		,;
			aDependentes,aObservacoes	,cCart,aMsgCorpo,	aUtilCob,lWeb,aReajuste,nBloco1,nBloco2,nBloco3,nBloco4,nBloco5 )

			// Restaura as configurações para utilizar no FWMsPrinter
			If lGeraPDF
				cFileJpg := "ImgBol.jpg"
				nTweb := 3.9
				nLweb := 10
			EndIf
		EndIf
		
	Endif
	If lHtml //nBloco5==2
		If ((valtype(aCobranca) == "A"  .and. len(aCobranca) > 0) .and.  (valtype(aDadosTit) == "A"   .and. len(aDadosTit) > 0)  )
			If (mv_par19 == 2 .or. mv_par19 == 3 )
				cWFID:= alltrim(substr(aCobranca[1][1],1,1)+substr(aCobranca[1][1],3,3)+substr(aCobranca[1][1],7,4)+substr(aCobranca[1][1],12,6)+aDadosTit[1])//(str(aleatorio(999999999,0)))
			Else
				cWFID:= alltrim(substr(aCobranca[1],1,1)+substr(aCobranca[1],3,3)+substr(aCobranca[1],7,4)+substr(aCobranca[1],12,6)+aDadosTit[1])//(str(aleatorio(999999999,0)))
				
			Endif
			oPrtPag:SaveAllAsJpeg( cPathSrvJ+cWFID, 1020, 1320, 140 )
		Endif
		
		aArquivo:={}
		If ((valtype(aCobranca) == "A"  .and. len(aCobranca) > 0) .and.  (valtype(aDadosTit) == "A"   .and. len(aDadosTit) > 0))
			
			ADIR( cPathSrvJ+"\"+cWFID+"*", aArquivo )
			
			
			
			ADIR( cPathSrvJ+"\"+cWFID+"*", aArquivo )
			aSort(aArquivo)
			
			If (mv_par19 == 2 .or. mv_par19 == 3 )
				nHandleOk := FCreate(cPathSrvJ+ alltrim(substr(aCobranca[1][1],1,1)+substr(aCobranca[1][1],3,3)+substr(aCobranca[1][1],7,4)+substr(aCobranca[1][1],12,6)+aDadosTit[1])+".HTM" , 0)
			Else
				nHandleOk := FCreate(cPathSrvJ+ alltrim(substr(aCobranca[1],1,1)+substr(aCobranca[1],3,3)+substr(aCobranca[1],7,4)+substr(aCobranca[1],12,6)+aDadosTit[1])+".HTM" , 0)
				
			Endif
			
			
			fwrite(nHandleOk ,"<HTML>"+ CHR(13) + CHR(10), Len("<HTML>" + CHR(13) + CHR(10)))
			fwrite(nHandleOk , "<HEAD>"+ CHR(13) + CHR(10), Len("<HEAD>" + CHR(13) + CHR(10)))
			fwrite(nHandleOk ,"<TITLE>" + cTitulo + "</TITLE>"+ CHR(13) + CHR(10), Len("<TITLE>" + cTitulo + "</TITLE>"+ CHR(13) + CHR(10)))
			fwrite(nHandleOk , "</HEAD>" + CHR(13) + CHR(10), Len("</HEAD>" + CHR(13) + CHR(10)))
			fwrite(nHandleOk , "<BODY>" + CHR(13) + CHR(10), Len("<BODY>" + CHR(13) + CHR(10)))
			for nI := 1 to len(aArquivo)
				if substr(aArquivo[nI],Len(aArquivo[nI])-3 ,4 ) == ".JPG"
					fwrite(nHandleOk, "<img src='" + aArquivo[nI] + "'> </br>")
				Endif
				
			next nI
			fwrite(nHandleOk , "</BODY>"+ CHR(13) + CHR(10), Len("</BODY>" + CHR(13) + CHR(10)))
			fwrite(nHandleOk , "</HTML>"+ CHR(13) + CHR(10), Len("</HTML>" + CHR(13) + CHR(10)))
			fclose(nHandleOk)
			
		Endif
	Endif
	
	TRB2->( dbCloseArea() )
	R580Imp->(DbSkip())
	
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fecha arquivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
R580Imp->( DbCloseArea() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Finaliza o relatorio
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//oPrint:EndPage()

If lGeraPDF
	oPrint:Print()
Else
	oPrint:Preview()
EndIf

// Envio do Boleto por Email
If !lWeb .And. FindFunction("PLMailScreen") .And. lEnviaEmail

	If oPrint:nDevice == IMP_PDF
		cAnexo := oPrint:cPathPDF+cFileName+".PDF"
	Else
		If lHtml
			If mv_par19 == 2 .Or. mv_par19 == 3 
				cAnexo := cPathSrvJ + Alltrim(Substr(aCobranca[1][1], 1, 1) + Substr(aCobranca[1][1], 3, 3) + Substr(aCobranca[1][1], 7, 4) +;
						  Substr(aCobranca[1][1], 12, 6) + aDadosTit[1]) + ".HTM"
			Else
				cAnexo := cPathSrvJ + Alltrim(Substr(aCobranca[1], 1, 1) + Substr(aCobranca[1], 3, 3) + Substr(aCobranca[1], 7, 4) +;
						  Substr(aCobranca[1], 12, 6) + aDadosTit[1]) + ".HTM"
			Endif
		EndIf
	EndIf

	If MsgYesNo(STR0079) // "Confirma o envio do boleto gerado por e-mail?"
		PLMailScreen(Nil, Nil, cAnexo, Nil, STR0080) // "Envio de Boleto"
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Relat¢rio
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(cFileName + ".PDF")
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R580Graf ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 08.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Boleto em modo texto                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R580Graf01(	aCobranca ,nAbatim	,nAcrescim	,oPrint	,;
aBMP ,aDadosEmp	,aDadosTit	,aDadosBanco,;
aDatSacado	,aMsgBoleto	,CB_RN_NN ,aOpenMonth ,;
aDependentes,aObservacoes,cCart,aMsgCorpo,aUtilCob,lWeb ,aReajuste,nBloco1,nBloco2,nBloco3,nBloco4,nBloco5)


LOCAL nLinha	:= 0				// Contador para linha
LOCAL nLinCob 	:= 0				// Contador para linha
LOCAL nMosCob 	:= 0				// Contador para for
LOCAL cPrn		:= ""				// String com informacoes de cobranca para impresao
LOCAL nCobra 	:= 0				// Contador para cobranca
LOCAL nColuna   := 0				// Contador para coluna.
//LOCAL nCnt		:= 0
// 19 linha de extrato duplo.
LOCAL aLinhas	:= { 850, 890, 930, 970, 1010, 1050, 1090, 1130, 1170, 1210, 1250, 1290 ,1330 ,1370 ,1410 ,1450 ,1490 ,1530 ,1570 ,1610 ,1650, 1690 ,1730 ,1770 ,1810 ,1850,1890,1930,1970,2010,2050,2090,2130,2170,2210,2250,2290,2330,2370,2410,2450,2490,2530,2570,2610  }
LOCAL nContLn	:= 0				// Controle de linhas para impressao de dependentes.
LOCAL nI		:= 0				// Contador do laco para impressao de dependentes.
LOCAL nMsg      := 0    			// Contador para as mensagens
LOCAL cNumCalc	:= ''				// String para calculo do digito CEF
LOCAL ncontuti 	:= 0
LOCAL nII		:= 0
Local nCnt		:=0
LOCAL i	:=0
LOCAL nContAux 	:=0
//Local lImp		:=.F.

Private oFont8	// --¿
Private  oFont8n   //   |
Private oFont10	// 	 |
Private oFont11n	// 	 |
Private oFont13n	// 	 |
Private oFont14	// 	 |
Private oFont15n	// 	 Ã- Fontes para impressao do relatorio grafico.
Private oFont16	// 	 |
Private oFont16n	// 	 |
Private oFont21	// --Ù
Private aBitmap 	:= aClone(aBmp)		// Array com os bmps para impressao



default aUtilCob	:={}
default lWeb		:=.F.
default aMsgCorpo	:={}
default aReajuste	:={}
//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8n := TFont():New("Courier New",9,6,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11n:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont13n:= TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont21 := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Bloco 1
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nBloco1 == 2
	oPrint:StartPage()
	nLinCob := 1
	nCobra 	:= 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³imprime Mensalidade/Coparticipacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	R580Bl2(	aCobranca ,nAbatim	,nAcrescim	,oPrint	,;
	aBMP ,aDadosEmp	,aDadosTit	,aDadosBanco,;
	aDatSacado	,aMsgBoleto	,CB_RN_NN ,aOpenMonth ,;
	aDependentes,aObservacoes,cCart,aMsgCorpo,aUtilCob,lWeb ,aReajuste)
	
	IF MV_Par19<>3
		For nLinha := nLinCob To Len(aCobranca)
			
			
			nColuna := 115/nTweb
			For nMosCob := 1 To 2
				If nCobra <= Len(aCobranca)
					If mv_par19 == 2
						If Valtype(aCobranca[nCobra]) == 'A'
							cPrn := AllTrim(aCobranca[nCobra][2]) + " -> " +;
							AllTrim(aCobranca[nCobra][3]) + " - R$ " +;
							Trans(aCobranca[nCobra][4], "@E 99,999.99" + " - " +;
							aCobranca[nCobra][5])
						Else
							cPrn := Alltrim(aCobranca[nCobra])
						EndIf
						
					Else
						cPrn := Alltrim(aCobranca[nCobra])
					Endif
					if  nLinha > 43// len(aLinhas)
						nLinha:=1
						oPrint:EndPage()
						oPrint:StartPage()
						
						R580Bl2(	aCobranca ,nAbatim	,nAcrescim	,oPrint	,;
						aBMP ,aDadosEmp	,aDadosTit	,aDadosBanco,;
						aDatSacado	,aMsgBoleto	,CB_RN_NN ,aOpenMonth ,;
						aDependentes,aObservacoes,cCart,aMsgCorpo,aUtilCob,lWeb ,aReajuste)
						
						
						
					Endif
					
					oPrint:Say (aLinhas[nLinha]/nTweb,nColuna ,cPrn,oFont8 )
					If nColuna = 115/nTweb
						nColuna := 1165/nTweb
					Endif
				Else
					
				Endif
				nCobra ++
			Next
		Next
		
	Else
		nLinha := aLinhas[1]/nTweb
		nColuna := 115/nTweb
		For nCnt := 1 To Len(aCobranca)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Variavel que controla aquantidade de itens do array que ja foram impressas  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nContAux ++
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime contrato...                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCobranca[nCnt][1]=='01'
				oPrint:Say (nLinha,nColuna ,aCobranca[nCnt][2],oFont8 )
				nLinha += 38
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime sub contrato...                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCobranca[nCnt][1]=='02'
				oPrint:Say (nLinha,nColuna ,aCobranca[nCnt][2],oFont8 )
				nLinha += 38
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime sub contrato...                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCobranca[nCnt][1]=='06'
				oPrint:Say (nLinha,nColuna ,aCobranca[nCnt][2],oFont8 )
				nLinha += 38
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime Produto ou a taxa de adesao...                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCobranca[nCnt][1]=='03'
				if nCnt <> Len(aCobranca)
					
					iF aCobranca[nCnt+1][1]<>'03'
						oPrint:Say (nLinha,nColuna ,aCobranca[nCnt][2] ,oFont8 )
					eNDIF
				eNDIF
				nLinha += 38
				
			Endif
			
			
			If aCobranca[nCnt][1]=='04'
				oPrint:Say (nLinha,nColuna ,PADr((aCobranca[nCnt][13]),TamSx3("BM1_DESTIP")[1],'0')  ,oFont8 )
				oPrint:Say (nLinha,nColuna+450 ,+"  ->    "+Transform((aCobranca[nCnt][3]), "@E 99,999.99"),oFont8 )
				nLinha += 38
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime o detalhamento por faixa etaria...                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCobranca[nCnt][1] == '05'
				For i := nCnt To len(aCobranca)
					If (aCobranca[i][1] <> '05' )
						nLinha += 10
						nCnt := (i-1)
						Exit
						
					Endif
					
					
					
					
					
					
					
					If aCobranca[i][12] $ '101,102,103'
						oPrint:Say (nLinha,nColuna,STR0075+StrZero(aCobranca[i][4],3)+" a "+; //"Faixa de "
						StrZero(aCobranca[i][5],3)+"  ->    "+;
						Transform(aCobranca[i][2], "@E 999999")+"      x   "+;
						Transform(aCobranca[i][3], "@E 99,999.99")+"      =   "+;
						Transform((aCobranca[i][3]*aCobranca[i][2]),"@E 999,999.99"),oFont8 )
						
					Endif
					nLinha += 38
					nContAux ++
				Next
				
				nLinha += 20
			Endif
			If i>len(aCobranca)
				nCnt := (i-1)
			Endif
		Next
		
	Endif
	
	oPrint:EndPage()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Bloco 2
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nBloco2 == 2
	oPrint:StartPage()
	oPrint:Line (200/nTweb-nLweb ,0100/nTweb-nLweb,200/nTweb-nLweb ,2300/nTweb-nLweb) //Lin
	
	oPrint:Line (200/nTweb-nLweb ,0100/nTweb-nLweb,1550/nTweb-nLweb ,0100/nTweb-nLweb) //Col
	oPrint:Line (200/nTweb-nLweb ,2300/nTweb-nLweb,1550/nTweb-nLweb ,2300/nTweb-nLweb)
	
	oPrint:Line (300/nTweb-nLweb ,100/nTweb-nLweb,300/nTweb-nLweb ,2300/nTweb-nLweb)  //Lin
	
	oPrint:Line (200/nTweb-nLweb ,550/nTweb-nLweb,300/nTweb-nLweb ,550/nTweb-nLweb)  //Col
	oPrint:Line (200/nTweb-nLweb ,770/nTweb-nLweb,300/nTweb-nLweb ,770/nTweb-nLweb )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Bmp do Banco  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File(AllTrim(aDadosBanco[1])+".BMP")
		oPrint:SayBitmap (215/nTweb, 110/nTweb, AllTrim(aDadosBanco[1])+".BMP" ,300/nTweb , 70/nTweb)
	Else
		oPrint:Say  (234/nTweb,105/nTweb,aDadosBanco[2],oFont11n )
	Endif
	
	If aDadosBanco[1] == "104"
		oPrint:Say  (212/nTweb,567/nTweb,"104-0",oFont21 )
	Else
		oPrint:Say  (212/nTweb,567/nTweb,aDadosBanco[1]+"-"+CB_RN_NN[9],oFont21 )
	EndIf
	oPrint:Say  (234/nTweb,790/nTweb,CB_RN_NN[2],oFont13n)
	
	oPrint:Line (400/nTweb-nLweb ,100/nTweb-nLweb,400/nTweb-nLweb ,2300/nTweb-nLweb )
	oPrint:Line (500/nTweb-nLweb ,100/nTweb-nLweb,500/nTweb-nLweb ,2300/nTweb-nLweb )
	oPrint:Line (575/nTweb-nLweb ,100/nTweb-nLweb,575/nTweb-nLweb ,2300/nTweb-nLweb )
	oPrint:Line (640/nTweb-nLweb ,100/nTweb-nLweb,640/nTweb-nLweb ,2300/nTweb-nLweb )
	
	oPrint:Line (500/nTweb-nLweb ,500/nTweb-nLweb,640/nTweb-nLweb ,500/nTweb-nLweb)
	oPrint:Line (570/nTweb-nLweb ,750/nTweb-nLweb,640/nTweb-nLweb ,750/nTweb-nLweb)
	oPrint:Line (500/nTweb-nLweb ,1000/nTweb-nLweb,640/nTweb-nLweb ,1000/nTweb-nLweb)
	oPrint:Line (500/nTweb-nLweb ,1350/nTweb-nLweb,570/nTweb-nLweb ,1350/nTweb-nLweb)
	oPrint:Line (500/nTweb-nLweb ,1550/nTweb-nLweb,640/nTweb-nLweb ,1550/nTweb-nLweb)
	
	oPrint:Say  (300/nTweb,100/nTweb ,STR0015,oFont8) //"LOCAL de Pagamento"
	oPrint:Say  (340/nTweb,100/nTweb ,STR0016,oFont10) //"Qualquer banco até a data do vencimento"
	
	oPrint:Say  (300/nTweb,1910/nTweb,STR0008,oFont8) //"Vencimento"
	oPrint:Say  (340/nTweb,1910/nTweb,DTOC(aDadosTit[4]),oFont10)
	
	oPrint:Say  (400/nTweb,100/nTweb ,STR0017,oFont8) //"Cedente"
	oPrint:Say  (400/nTweb,300/nTweb ,aDadosEmp[1],oFont10)
	
	oPrint:Say  (440/nTweb,100/nTweb ,STR0063,oFont8) //"Cedente" //"CNPJ "
	oPrint:Say  (440/nTweb,300/nTweb ,Subs(aDadosEmp[6],8),oFont10) // Pegar somente a partir da 8a. posicao
	
	oPrint:Say  (400/nTweb,1910/nTweb,STR0012,oFont8) //"Agência/Código Cedente"
	
	If AllTrim(Strzero(Val(aDadosBanco[1]),3)) == '104'
		cNumCalc	:= Strzero(Val(aDadosBanco[3]),4) + "87" + STRZERO(VAL(SEE->EE_CODEMP),9)
		oPrint:Say(440/nTweb,1910/nTweb, Strzero(Val(aDadosBanco[3]),4) +".870." + STRZERO(VAL(SEE->EE_CODEMP),8)  +"-"+  CALC745(cNumCalc), oFont10 )
	Else
		oPrint:Say(440/nTweb,1910/nTweb,aDadosBanco[3]+IIf (!Empty(aDadosBanco[6]),+"-"+aDadosBanco[6]+"/",+"/")+aDadosBanco[4]+IIf(CB_RN_NN[4], +"-"+StrZero(CB_RN_NN[5],1), iif(!Empty(aDadosBanco[5]),+"-"+aDadosBanco[5],aDadosBanco[5])), oFont10 )
	EndIf
	
	oPrint:Say  (500/nTweb,100/nTweb ,STR0018,oFont8) //"Data do Documento"
	oPrint:Say  (530/nTweb,105/nTweb ,DTOC(aDadosTit[3]),oFont10)
	
	oPrint:Say  (500/nTweb,505/nTweb ,STR0019,oFont8) //"Nro.Documento"
	oPrint:Say  (530/nTweb,605/nTweb ,aDadosTit[1],oFont10)
	
	oPrint:Say  (500/nTweb,1005/nTweb,STR0020,oFont8) //"Espécie Doc."
	oPrint:Say  (530/nTweb,1005/nTweb,CB_RN_NN[7],oFont10) //"Espécie do Documento"
	
	oPrint:Say  (500/nTweb,1355/nTweb,STR0021,oFont8) //"Aceite"
	oPrint:Say  (530/nTweb,1455/nTweb,CB_RN_NN[8],oFont10) //Aceite do Documento
	
	oPrint:Say  (500/nTweb,1555/nTweb,STR0022,oFont8) //"Data do Processamento"
	oPrint:Say  (530/nTweb,1655/nTweb,DTOC(aDadosTit[2]),oFont10)
	
	oPrint:Say  (500/nTweb,1910/nTweb,STR0013,oFont8) //"Nosso Número"
	cStrNNum	:= AllTrim(aDadosTit[6])
	oPrint:Say  (530/nTweb,1910/nTweb,cStrNNum,oFont10)
	
	oPrint:Say  (570/nTweb,100/nTweb ,STR0023,oFont8) //"Uso do Banco"
	
	oPrint:Say  (570/nTweb,505/nTweb ,STR0024,oFont8) //"Carteira"
	oPrint:Say  (600/nTweb,555/nTweb ,CB_RN_NN[6],oFont10)
	
	oPrint:Say  (570/nTweb,755/nTweb ,STR0025,oFont8) //"Espécie"
	oPrint:Say  (600/nTweb,805/nTweb ,STR0026,oFont10) //"R$"
	
	oPrint:Say  (570/nTweb,1005/nTweb,STR0027,oFont8) //"Quantidade"
	
	oPrint:Say  (570/nTweb,1555/nTweb,STR0028,oFont8) //"Valor"
	
	oPrint:Say  (570/nTweb,1910/nTweb,STR0029,oFont8) //"(=)Valor do Documento"
	oPrint:Say  (600/nTweb,2010/nTweb,Transform(aDadosTit[5],"@E 999,999,999.99"),oFont10)
	
	oPrint:Say  (640/nTweb,100/nTweb ,STR0030,oFont8) //"Instruções/Texto de responsabilidade do cedente"
	
	
	If !Empty(aMsgBoleto[1])
		aMsgBoleto:=R580Quebr(aMsgBoleto)
		
		nMsg:=690/nTweb
		For nI := 1 To len(aMsgBoleto)
			oPrint:Say  (nMsg,120/nTweb ,aMsgBoleto[nI][1],oFont10 )
			nMsg+=50/nTweb
			If nI > 5
				Exit
			EndIf
		Next nI
	Endif
	
	oPrint:Say  (640/nTweb,1910/nTweb,STR0034                         ,oFont8) //"(+)Outros Acréscimos"
	oPrint:Say  (670/nTweb,1910/nTweb,AllTrim(Transform(nAcrescim,"@ZE 999,999,999.99")),oFont10)
	
	oPrint:Say  (710/nTweb,1910/nTweb,STR0031                         ,oFont8) //"(-)Desconto/Abatimento"
	oPrint:Say  (740/nTweb,1910/nTweb,AllTrim(Transform(nAbatim,"@ZE 999,999,999.99")),oFont10)
	
	oPrint:Say  (780/nTweb,1910/nTweb,STR0032                         ,oFont8) //"(-)Outras Deduções"
	
	oPrint:Say  (850/nTweb,1910/nTweb,STR0033                         ,oFont8) //"(+)Mora/Multa"
	
	oPrint:Say  (920/nTweb,1910/nTweb,STR0035                         ,oFont8) //"(-)Valor Cobrado"
	
	oPrint:Say  (990/nTweb,100/nTweb ,STR0036                         ,oFont8) //"Recibo do Sacado"
	
	oPrint:Say  (1010/nTweb,400/nTweb, Subs(aDatSacado[1],1,60)+" ("+aDatSacado[2]+")", oFont8 )		// Nome e Codigo do Cliente
	oPrint:Say  (1040/nTweb,400/nTweb, IIF(Len(aDatSacado[7])<=11, STR0064+Transform(aDatSacado[7], "@R 999.999.999-99") , STR0065+Transform(aDatSacado[7], "@R 99.999.999/9999-99" ) ), oFont8)		// CPF/CNPJ //"CPF:"###"CNPJ:"
	oPrint:Say  (1070/nTweb,400/nTweb, aDatSacado[3]                      ,oFont8)						// Endereço + Bairro
	oPrint:Say  (1100/nTweb,400/nTweb, aDatSacado[6]+"   "+aDatSacado[4]+"-"+aDatSacado[5], oFont8)		// CEP + Cidade + Estado
	
	oPrint:Say  (1125/nTweb,100/nTweb ,STR0037                               ,oFont8) //"Sacador/Avalista"
	oPrint:Say  (1175/nTweb,1500/nTweb,STR0038                        ,oFont8) //"Autenticação Mecânica -"
	oPrint:Say  (1175/nTweb,1850/nTweb,STR0039                           ,oFont10) //"Ficha de Compensação"
	
	oPrint:Line (300/nTweb-nLweb ,1900/nTweb-nLweb,990/nTweb-nLweb ,1900/nTweb-nLweb )
	oPrint:Line (710/nTweb-nLweb ,1900/nTweb-nLweb,710/nTweb-nLweb ,2300/nTweb-nLweb )
	oPrint:Line (780/nTweb-nLweb ,1900/nTweb-nLweb,780/nTweb-nLweb ,2300/nTweb-nLweb )
	oPrint:Line (850/nTweb-nLweb ,1900/nTweb-nLweb,850/nTweb-nLweb ,2300/nTweb-nLweb )
	oPrint:Line (920/nTweb-nLweb ,1900/nTweb-nLweb,920/nTweb-nLweb ,2300/nTweb-nLweb )
	oPrint:Line (990/nTweb-nLweb ,100/nTweb-nLweb ,990/nTweb-nLweb ,2300/nTweb-nLweb )
	
	oPrint:Line (1170/nTweb-nLweb ,100/nTweb-nLweb,1170/nTweb-nLweb ,2300/nTweb-nLweb  )
	
	IF lWeb
		MSBAR3(  "INT25"  ,   2.7		,  0.5		, CB_RN_NN[1],oPrint, .F.      ,  Nil     , Nil    , 0.010    , 0.35       , Nil       ,  Nil    , "A"     , .F.)
	Else
		MSBAR3("INT25",10.7,01.0,CB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.1,Nil,Nil,"A",.F.)
	Endif
	
	oPrint:Line (1570/nTweb-nLweb ,100/nTweb-nLweb,1570/nTweb-nLweb ,2300/nTweb-nLweb  )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Finaliza a página
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:EndPage()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Bloco 3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nBloco3 == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Utilizacoes
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	if len(aUtilCob) > 0
		if nLweb>0
			nLweb:=5
		eNDIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Inicia uma nova página
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:StartPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Logo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oPrint:SayBitmap (85/nTweb,75/nTweb,aBitMap[1],350/nTweb,125/nTweb)
		
		If File(SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"))
			oPrint:SayBitmap (220/nTweb,75/nTweb,SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"),250/nTweb,65/nTweb)
		Else
			oPrint:Say  (050/nTweb,1780/nTweb,aDadosEmp[7] ,oFont21)
		Endif
		
		oPrint:Box  (300/nTweb,70/nTweb,3200/nTweb,2300/nTweb)  //retangulo
		oPrint:Say  ((318/nTweb)+nLweb,105/nTweb,STR0066,oFont8 ) // //"Beneficiario"
		oPrint:Line (300/nTweb,700/nTweb,3200/nTweb,700/nTweb)       // Linha Central
		oPrint:Say  ((318/nTweb)+nLweb,710/nTweb,STR0067,oFont8 ) //"RDA"
		oPrint:Line (300/nTweb,1195/nTweb,3200/nTweb,1195/nTweb)       // Linha Central
		oPrint:Say  (320/nTweb+nLweb,1205/nTweb,STR0068,oFont8 )// //"Data Utilização"
		oPrint:Line (300/nTweb,1390/nTweb,3200/nTweb,1390/nTweb)       // Linha Central
		oPrint:Say  (320/nTweb+nLweb,1395/nTweb,STR0069,oFont8 )// //"Serviço"
		oPrint:Line (300/nTweb,2055/nTweb,3200/nTweb,2055/nTweb)       // Linha Central
		oPrint:Say  (320/nTweb+nLweb,2057/nTweb,STR0070,oFont8 )// //"Qtd."
		oPrint:Line (300/nTweb,2110/nTweb,3200/nTweb,2110/nTweb)       // Linha Central
		oPrint:Say  (320/nTweb+nLweb,2160/nTweb,STR0071,oFont8 )// //"Valor Total"
		oPrint:Line (350/nTweb,70/nTweb,350/nTweb,2300/nTweb)        // Fecha cabeçalho
		
		ncontuti += 1
		nContLn := 380/nTweb
		For nII := ncontuti To Len(aUtilCob)
			oPrint:Say  (nContLn,105/nTweb ,aUtilCob[nII,1] ,oFont8n)
			oPrint:Say  (nContLn,710/nTweb ,aUtilCob[nII,2] ,oFont8n)
			oPrint:Say  (nContLn,1205/nTweb,aUtilCob[nII,3] ,oFont8n)
			oPrint:Say  (nContLn,1395/nTweb,aUtilCob[nII,4] ,oFont8n)
			oPrint:Say  (nContLn,2060/nTweb,aUtilCob[nII,5] ,oFont8n)
			oPrint:Say  (nContLn,2115/nTweb,aUtilCob[nII,6] ,oFont8n)
			ncontuti += 1
			nContLn  += 26/nTweb
			
			If nII > 200/nTweb
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Continua na Proxima Pagina........
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				oPrint:Say  (nContLn,105/nTweb ,STR0072,oFont8n)
				Exit
			EndIf
		Next nII
		
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Finaliza a página
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:EndPage()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Bloco 4
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nBloco4 == 2
	
	oPrint:StartPage()
	oPrint:SayBitmap( 15/nTweb,10/nTweb,cPathFilj,2500/nTweb,3700/nTweb )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Visualiza a impressão
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:EndPage()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³R580Graf02³ Autor ³Geraldo Felix Junior...³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Boleto em modo grafico padrao Cooperativa...       ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Alteracoes ³ Data     ³Motivo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rafael     ³03/02/2004³Alteracao de Lay out da emissao de boletos.      ³±±
±±³Marchette  ³ 		 ³- Header - Dados da empresa e dados ANS          ³±±
±±³Quadrotti  ³ 		 ³- Extrato- Impressao de dependentes e meses em   ³±±
±±³           ³ 		 ³atraso.                                          ³±±
±±³           ³ 		 ³- Extrato- Inclusao da observacao no extrato.    ³±±
±±³           ³ 		 ³- Ficha de Comp. - Correcao do codigo de barras  ³±±
±±³           ³ 		 ³- Ficha de Comp. - Alteracao de textos de instru-³±±
±±³           ³ 		 ³coes/responsabilidade do cedente.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R580Graf02(	aCobranca	,nAbatim	,nAcrescim	,oPrint		,;
aBMP		,aDadosEmp	,aDadosTit	,aDadosBanco,;
aDatSacado	,aMsgBoleto	,CB_RN_NN	,aOpenMonth	,;
aDependentes,aObservacoes,cCart, cTipoUS, lUnimeds, aMsgCorpo )

LOCAL oFont8	// --¿
LOCAL oFont10	// 	 |
LOCAL oFont11n	// 	 |
LOCAL oFont13n	// 	 |
LOCAL oFont14	// 	 |
LOCAL oFont15n	// 	 Ã- Fontes para impressao do relatorio grafico.
LOCAL oFont16	// 	 |
LOCAL oFont16n	// 	 |
LOCAL oFont21	// --Ù

LOCAL bPrn1
LOCAL cMoeda	:= "9"  			// Moeda do boleto.
LOCAL cPrn1		:= ""				// String com informacoes de cobranca para impresao
LOCAL cPrn2		:= ""				// String com informacoes de cobranca para impresao
LOCAL nLinha	:= 0				// Linha impressa
LOCAL nColuna	:= 1				// Contador para colunas
LOCAL nLimCol	:= 0				// Limite de linhas por coluna do boleto!
LOCAL nLinCon	:= 0				// Contador de linhas
LOCAL nControl 	:= 0				// Controle de linhas impressas no corpo do boleto
LOCAL nContAux	:= 0 				// Controle de linhas impressas no corpo do boleto
LOCAL i 		:= 0    			// Contador
LOCAL nMosCob 	:= 0				// Contador para for
LOCAL nCobra 	:= 0				// Contador para cobranca
LOCAL nTotSm	:= 0				// Valor total do Ato cooperado principal (servico medico)
LOCAL nTotSa	:= 0				// Valor total do Ato cooperado Acessorio (servico acessorio)
LOCAL nI		:= 0				// Contador do laco para impressao de dependentes.
LOCAL nMsg      := 0    			// Contador para as mensagens
LOCAL nResto	:= 0

LOCAL nColVal   := 2050				// Variaveis com as posicoes de impressao
LOCAL nColCon	:= 170				// Variavel com as posicao de impressao do contrato
LOCAL nColSub	:= 115				// Variavel com as posicao de impressao do sub contrato
LOCAL nColPro	:= 170				// Variavel com as posicao de impressao do Produto
LOCAL nColFai	:= 240				// Variavel com as posicao de impressao da Faixa
LOCAL nColDes   := 115 				// Variaveis com as posicoes de impressao
LOCAL nColVal1  := 2050				// Variaveis com as posicoes de impressao
LOCAL nColCon1	:= 1255				// Variavel com as posicao de impressao do contrato
LOCAL nColSub1	:= 1200				// Variavel com as posicao de impressao do sub contrato
LOCAL nColPro1	:= 1255				// Variavel com as posicao de impressao do Produto
LOCAL nColFai1	:= 1350				// Variavel com as posicao de impressao da Faixa

LOCAL nClRes1	:= 115
LOCAL nClRes2	:= 600
LOCAL nClRes3	:= 750

LOCAL nClRes11	:= 1200
LOCAL nClRes22	:= 1685
LOCAL nClRes33	:= 1835

// 19 linha de extrato duplo.
LOCAL aLinhas	:= { 750, 800, 850, 900, 950, 1000, 1050, 1000, 1100, 1150, 1200, 1250 ,1300 ,1350 ,1400 ,1450 ,1500 ,1550 ,1600 }
LOCAL aBitmap 	:= aClone(aBmp)		// Array com os bmps para impressao
LOCAL aResumo   := {}

LOCAL lPulaLinha:= .F.
LOCAL lDividePag:= .F.
LOCAL nCnt := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Variaveis totalizadoras...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PRIVATE _nMensalidade 	:= 0
PRIVATE _nOpcionais 	:= 0
PRIVATE _nInscricao 	:= 0
PRIVATE _nTamanho		:= 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Parâmetros de TFont.New()
//³1.Nome da Fonte (Windows)
//³3.Tamanho em Pixels
//³5.Bold (T/F)
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oFont7  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7n := TFont():New("Arial",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11n:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont13n:= TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont21 := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta o resumos do boleto e calcula tamanho real do array p/ impressao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nCnt := 1 To Len(aCobranca)
	
	If aCobranca[nCnt][1] $ '05,06'
		If (nPos := Ascan(aResumo, {|x| x[1] == aCobranca[nCnt][12] } ) ) == 0
			Aadd(aResumo,{ aCobranca[nCnt][12], aCobranca[nCnt][13], aCobranca[nCnt][2], aCobranca[nCnt][3] })
		Else
			aResumo[nPos][3] +=  aCobranca[nCnt][2]
			aResumo[nPos][4] +=  (aCobranca[nCnt][2] * aCobranca[nCnt][3])
		Endif
		
		If aCobranca[nCnt][1] == '05'
			_nTamanho++
		Endif
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Imprime todo esquema de cabecalho do boleto...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_nTamanho += ( Len(aMsgCorpo) + Len(aResumo) )

R580CabGrf02(oPrint, oFont8, oFont10, oFont11n, aDadosTit, aDatSacado,  aDadosBanco, aDadosEmp, aBitMap, aDependentes, aOpenMonth, aCobranca, _nTamanho, CB_RN_NN )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o limite de linhas por coluna para a primeira pagina do   ³
//³boleto de acorado com a quantidade de informacao a ser impressa. ³
//³A definicao de tamanho para as demais pagina sera feita durante a³
//³impressao do mesmo...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _nTamanho > 50
	nLimCol := 3108
Else
	nLimCol := 1512
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Corpo do boleto Reset linha
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RESETLIN
If (Alltrim(BA3->BA3_MODPAG) == '1' .and. mv_par19 <> 3) .or. Alltrim(BA3->BA3_MODPAG) <> '1'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Titulos do quadro da boleta...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oPrint:Say (525,109  ,STR0051,oFont8 ) // "Descricao"
	oPrint:Say (525,1909 ,STR0009,oFont8 )	// "Valor R$"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Imprime os itens do Ato Cooperado principal...(Servicos medicos)
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nCnt := 1 To  Len(aCobranca)
		If aCobranca[nCnt][1] == "101"
			_nMensalidade += aCobranca[nCnt][3]
			
		Elseif aCobranca[nCnt][1] == "102"
			_nOpcionais   += aCobranca[nCnt][3]
			
		Elseif aCobranca[nCnt][1] == "103"
			_nInscricao   += aCobranca[nCnt][3]
			
		Endif
		
		If aCobranca[nCnt][4] <> '1'
			Loop
		Endif
		cPrn1 := AllTrim(aCobranca[nCnt][1]) + " - " +AllTrim(aCobranca[nCnt][2])
		cPrn2 := " R$ " + Trans(aCobranca[nCnt][3], "@E 99,999.99")
		
		oPrint:Say (nLinha,nColDes ,cPrn1,oFont8 )  // Descricao do Servico
		oPrint:Say (nLinha,nColVal ,cPrn2,oFont8 )  // Valor do Servico
		
		nLinha += 45
		
		nTotSm += aCobranca[nCnt][3]
	Next
	If nTotSm > 0
		oPrint:Say (nLinha,nColDes ,STR0073,oFont10 )  // Texto totalizador //"----------------> TOTAL ATO COOPERATIVO PRINCIPAL"
		
		cPrn2 := " R$ " + Trans(nTotSm, "@E 99,999.99")
		oPrint:Say (nLinha,nColVal ,cPrn2,oFont10 )
		
		If nTotSm > 0
			nLinha += 80
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os itens do Ato Cooperado Acessorio...(Servico Acessorio)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCnt := 1 To  Len(aCobranca)
		If !(aCobranca[nCnt][4] $ '0, ')
			Loop
		Endif
		cPrn1 := AllTrim(aCobranca[nCnt][1]) + " - " +AllTrim(aCobranca[nCnt][2])
		cPrn2 := " R$ " + Trans(aCobranca[nCnt][3], "@E 99,999.99")
		
		oPrint:Say (nLinha,nColDes ,cPrn1,oFont8 )  // Descricao do Servico
		oPrint:Say (nLinha,nColVal ,cPrn2,oFont8 )  // Valor do Servico
		
		nLinha += 45
		
		nTotSa += aCobranca[nCnt][3]
	Next
	If nTotSa > 0
		oPrint:Say (nLinha,nColDes ,STR0074,oFont10 )  // Texto totallizador //"----------------> TOTAL ATO COOPERATIVO ACESSORIO"
		
		cPrn2 := " R$ " + Trans(nTotSa, "@E 99,999.99")
		oPrint:Say (nLinha,nColVal ,cPrn2,oFont10 )
	Endif
	
Else
	For nCnt := 1 To Len(aCobranca)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variavel que controla aquantidade de itens do array que ja foram impressas  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nContAux ++
		
		If nLinha > nLimCol
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Redefine a coluna a ser impressa...                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nColuna == 1
				nColuna := 2
			Else
				nColuna := 1
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ O nResto indicara se sera necessario mais uma pagina para impressao   ³
				//³ extrato do boleto, quando nResto for menor que 58, esta sera a ultima ³
				//³ pagina...                                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nResto := (_nTamanho-nContAux)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Redefine o limite de linhas por coluna do boleto...              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nResto > 50
					nLimCol := 3108
				Else
					nLimCol := 1512
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Finaliza a página...          										  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:EndPage()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Houve mudanca de pagina, imprimi cabecalho na nova pagina...          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				R580CabGrf02(oPrint, oFont8, oFont10, oFont11n, aDadosTit, aDatSacado,  aDadosBanco, ;
				aDadosEmp, aBitMap, aDependentes, aOpenMonth, aCobranca, nResto, CB_RN_NN )
				
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Linha inicial...                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RESETLIN
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime contrato...                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCobranca[nCnt][1]=='01'
			oPrint:Say (nLinha,Iif(nColuna==1, nColCon, nColCon1) ,aCobranca[nCnt][2],oFont8 )
			nLinha += 38
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime sub contrato...                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCobranca[nCnt][1]=='02'
			oPrint:Say (nLinha,Iif(nColuna==1, nColSub, nColSub1) ,aCobranca[nCnt][2],oFont8 )
			nLinha += 38
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Produto ou a taxa de adesao...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCobranca[nCnt][1]=='03' .or. aCobranca[nCnt][1]=='04'
			oPrint:Say (nLinha,Iif(nColuna==1, nColPro, nColPro1) ,aCobranca[nCnt][2],oFont8 )
			nLinha += 38
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o detalhamento por faixa etaria...                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCobranca[nCnt][1] == '05'
			For i := nCnt To Len(aCobranca)
				If aCobranca[i][1] <> '05'
					nLinha += 10
					nCnt := (i-1)
					Exit
				Endif
				
				If aCobranca[i][12] $ '101,102,103'
					oPrint:Say (nLinha,Iif(nColuna==1, nColFai, nColFai1),STR0075+StrZero(aCobranca[i][4],3)+" a "+; //"Faixa de "
					StrZero(aCobranca[i][5],3)+"     -   "+;
					Transform(aCobranca[i][2], "@E 999999")+"      x   "+;
					Transform(aCobranca[i][3], "@E 99,999.99")+"      =   "+;
					Transform((aCobranca[i][3]*aCobranca[i][2]),"@E 999,999.99"),oFont7 )
				Endif
				nLinha += 38
				nContAux ++
			Next
			nLinha += 20
		Endif
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime resumo da cobranca... Da um salto de linha com 20 pontos...   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinha += 20
	For nCnt := 1 To Len(aResumo)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se a linha ultrapassou o limete por coluna, de acordo com o tamanho da pagina... |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nLinha > nLimCol
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Redefine a coluna a ser impressa...                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nColuna == 1
				nColuna := 2
			Else
				nColuna := 1
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ O nResto indicara se sera necessario mais uma pagina para impressao   ³
				//³ extrato do boleto, quando nResto for menor que 58, esta sera a ultima ³
				//³ pagina...                                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nResto := (_nTamanho-nContAux)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Redefine o limite de linhas por coluna do boleto...              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nResto > 50
					nLimCol := 3108
				Else
					nLimCol := 1512
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Finaliza a página...          										  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:EndPage()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Houve mudanca de pagina, imprimi cabecalho na nova pagina...          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				R580CabGrf02(oPrint, oFont8, oFont10, oFont11n, aDadosTit, aDatSacado,  aDadosBanco, ;
				aDadosEmp, aBitMap, aDependentes, aOpenMonth, aCobranca, nResto, CB_RN_NN )
				
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Linha inicial...                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RESETLIN
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime a linha do resumo!                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Say(nLinha,Iif(nColuna==1, nClRes1, nClRes11),Left(aResumo[nCnt][2],30), oFont7n)
		oPrint:Say(nLinha,Iif(nColuna==1, nClRes2, nClRes33),"   -   "+Transform(aResumo[nCnt][3], "@E 999999"), oFont7n)
		oPrint:Say(nLinha,Iif(nColuna==1, nClRes3, nClRes55),Transform(aResumo[nCnt][4],"@E 999,999.99"), oFont7n)
		
		nLinha += 38
		nContAux ++
		
	Next
	
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o rodape, mensagens e as demais informacoes sobre o boleto...  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


R580RodGrf02(oPrint, aDadosTit, aDatSacado,aDadosBanco, aDadosEmp, aBitMap, aDependentes,aOpenMonth,;
aCobranca, nResto, aMsgCorpo, aObservacoes, aMsgBoleto, CB_RN_NN,;
cCart, nAbatim, nAcrescim, nLimCol, nLinha, nColuna )



Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R580CabGrf02  ºAutor  ³Geraldo Felix Juniorº Data ³  09/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabecalho do boleto utilizado no modelo 2 ( Para cooperativas ) º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R580CabGrf02(oPrint, oFont8, oFont10, oFont11n, aDadosTit, aDatSacado,;
aDadosBanco, aDadosEmp, aBitMap, aDependentes,aOpenMonth,;
aCobranca, nLinhas, CB_RN_NN )

LOCAL oFont21 := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia uma nova pagina...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:StartPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os dados da empresa....                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say  (050	,500	,aDadosEmp[1]	,oFont11n)
oPrint:Say  (090	,500	,aDadosEmp[2] 	,oFont8 )
oPrint:Say  (125	,500	,aDadosEmp[3] 	,oFont8 )
oPrint:Say  (160	,500	,aDadosEmp[4] 	,oFont8 )
oPrint:Say  (195	,500	,aDadosEmp[5] 	,oFont8 )
oPrint:Say  (230	,500	,aDadosEmp[6] 	,oFont8 )

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³Bmp da ANS³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
If File(SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"))
	oPrint:SayBitmap (090,1825,SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"),470 ,150)
Else
	oPrint:Say  (090,1780,aDadosEmp[7] ,oFont21)
Endif


If Subs(aDadosBanco[1],1,3) <> '104'
	oPrint:Say  (250,1780,STR0044 + R580Imp->E1_MESBASE+" / "+R580Imp->E1_ANOBASE ,oFont10) //"Mês de competência: "
Else
	oPrint:Say  (250,1430,STR0062 + R580Imp->E1_MESBASE+" / "+R580Imp->E1_ANOBASE ,oFont10) //"Recibo do Sacado - Mês de competência: "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Logo do boleto...				                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:SayBitmap (50 ,100,aBitMap[1],250 ,200 )		//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o corpo do boleto! O tamanho pode variar de acordo com a quantidade de linhas a serem impressas!   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLinhas > 50   					// 25 eh o limite de linhas no formato padrao do bolote,
	oPrint:Box  (300,100,3200,2300)	// caso tenha mais linhas que isso, sera gerado um boleto com duas ou mais paginas...
	oPrint:Line (300,1150,3200,1150)
Else
	oPrint:Box  (300,100,1935,2300)
	oPrint:Line (300,1150,Iif(mv_par19==3,1620,400),1150)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta as linhas das caixinhas do cabecalho do boleto...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Line (400,0100,400,2300)
oPrint:Line (520,0100,520,2300)  // Linha inferior dos dados do sacado!
oPrint:Line (300,0400,400,0400)
oPrint:Line (300,0800,400,0800)
oPrint:Line (300,1500,400,1500)
oPrint:Line (300,1900,Iif(mv_par19==3,400,1620),1900)  // Limite esquerdo do campo "nosso numero"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do cabecalho do boleto...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say  (300,105,STR0008                ,oFont8 ) 	//"Vencimento"
oPrint:Say  (345,205,DTOC(aDadosTit[4])     ,oFont10)

oPrint:Say  (300,405,STR0009                ,oFont8 ) 	//"Valor R$"
oPrint:Say  (345,505,Transform(aDadosTit[5],"@E 999,999,999.99"),oFont10)

oPrint:Say  (300,805,STR0010             	,oFont8 ) 	//"Data de Emissão"
oPrint:Say  (345,905,DTOC(aDadosTit[3])     ,oFont10)

oPrint:Say  (300,1155,STR0011            	,oFont8 ) 	//"Nro.do Documento"
oPrint:Say  (345,1255,aDadosTit[1]          ,oFont10)

oPrint:Say  (300,1505,STR0012      			,oFont8 ) 	//"Agência/Código Cedente"
//oPrint:Say  (345,1555,aDadosBanco[3]+"/"+DaDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
If AllTrim(Strzero(Val(aDadosBanco[1]),3)) == '104'
	cNumCalc	:= Strzero(Val(aDadosBanco[3]),4) + "87" + STRZERO(VAL(SEE->EE_CODEMP),9)
	oPrint:Say( 345,1505, Strzero(Val(aDadosBanco[3]),4) +".870." + STRZERO(VAL(SEE->EE_CODEMP),8)  +"-"+  CALC745(cNumCalc), oFont10 )
Else
	oPrint:Say(345,1505,aDadosBanco[3]+"/"+aDadosBanco[4]+"/"+ IIf(CB_RN_NN[4], StrZero(CB_RN_NN[5],1), aDadosBanco[5]), oFont10 )
EndIf

oPrint:Say  (300,1905,STR0013               ,oFont8 ) 	//"Nosso Número"
cStrNNum	:= AllTrim(aDadosTit[6])
oPrint:Say  (345,1950,cStrNNum          ,oFont10)

oPrint:Say  (400,105 ,STR0004                  ,oFont8 ) //"Dados do Sacado"
oPrint:Say  (450,115 ,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont8)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R580CabGrf02  ºAutor  ³Geraldo Felix Juniorº Data ³  09/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rodape    do boleto utilizado no modelo 2 ( Para cooperativas ) º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R580RodGrf02(oPrint, aDadosTit, aDatSacado,aDadosBanco, aDadosEmp, aBitMap, aDependentes,aOpenMonth,;
aCobranca, nResto, aMsgCorpo, aObservacoes, aMsgBoleto, CB_RN_NN ,cCart,;
nAbatim,  nAcrescim, nLimCol, nLinha, nColuna )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define variaveis...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aCoords1 	:= {2000,1900,2100,2300}
LOCAL aCoords2 	:= {2270,1900,2340,2300}
LOCAL nColVal   := 2050				// Variaveis com as posicoes de impressao
LOCAL oBrush
LOCAL cMoeda	:= "9"  			// Moeda do boleto.
LOCAL nColSub	:= 115				// Variavel com as posicao de impressao do sub contrato
LOCAL nColSub1	:= 1200				// Variavel com as posicao de impressao do sub contrato

LOCAL oFont8	// --¿
LOCAL oFont10	// 	 |
LOCAL oFont11n	// 	 |
LOCAL oFont13n	// 	 |
LOCAL oFont14	// 	 |
LOCAL oFont15n	// 	 Ã- Fontes para impressao do relatorio grafico.
LOCAL oFont16	// 	 |
LOCAL oFont16n	// 	 |
LOCAL oFont21	// --Ù

LOCAL nCnt := 0
LOCAL nI := 0

//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont7  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11n:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont13n:= TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont21 := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)

If nResto > 50 .or. nLimCol > 3000
	oPrint:EndPage()	// Finaliza pagina para inicializar outra em R580CabGrf02!
	RESETLIN			// Reseta o contador de linha!
	oPrint:EndPage() 	// Finaliza a página!
	
	R580CabGrf02(oPrint, oFont8, oFont10, oFont11n, aDadosTit, aDatSacado,  aDadosBanco, ;
	aDadosEmp, aBitMap, aDependentes, aOpenMonth, aCobranca, 1, CB_RN_NN )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limites inferiores do corpo do boleto...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say  (2040,100,Replicate(".",219),oFont10)
oPrint:Line (1625,100,1625,2300)	// Limite para observacao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as mensagens do corpo do boleto...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinha += 100
For nCnt := 1 To Len(aMsgCorpo)
	If ! Empty(aMsgCorpo[nCnt])
		cPrn1 := "{ ||"+aMsgCorpo[nCnt]+" }"
		bPrn1 := &cPrn1
		If nLinha > nLimCol
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Redefine a coluna a ser impressa...                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nColuna == 1
				nColuna := 2
			Else
				nColuna := 1
			Endif
			RESETLIN
		Endif
		
		oPrint:Say (nLinha,Iif(nColuna == 1,nColSub,nColSub1) ,Eval(bPrn1),oFont8 )  // Texto totallizador
		nLinha += 45
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as observacoes...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMsg:=1650
oPrint:Say  (1625,105,STR0014               ,oFont8 ) 	//"Observação"
For nI := 1 To len(aObservacoes)
	oPrint:Say  (nMsg,105,aObservacoes[nI]  ,oFont8 )
	nMsg+=30
	If nI > 5
		Exit
	EndIf
Next nI

//oPrint:FillRect(aCoords1,oBrush)
//oPrint:FillRect(aCoords2,oBrush)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Emissao dos dados do sacado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oPrint:Say  (1585,1790 		,STR0052                  ,oFont10 ) //"TOTAL"
//oPrint:Say  (1585,nColVal 	," R$ "+Transform((nTotSm+nTotSa),"@E 999,999,999.99"),oFont10 )

oPrint:Line (2200,0100,2200,2300) //Lin

oPrint:Line (2200,0100,3365,0100) //Col
oPrint:Line (2200,2300,3365,2300)

oPrint:Line (2300,100,2300,2300)  //Lin

oPrint:Line (2200,550,2300,550 )  //Col
oPrint:Line (2200,770,2300,770 )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Bmp do Banco  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(AllTrim(aDadosBanco[1])+".BMP")
	oPrint:SayBitmap (2215,110, AllTrim(aDadosBanco[1])+".BMP" ,300 , 70 )
Else
	oPrint:Say  (2234,105,aDadosBanco[2],oFont11n )
Endif

//oPrint:Say  (1934,100,aDadosBanco[2],oFont11n )
If aDadosBanco[1] == "104"
	oPrint:Say  (2212,567,"104-0",oFont21 )
Else
	oPrint:Say  (2212,567,aDadosBanco[1]+"-"+CB_RN_NN[9],oFont21 )
EndIf
oPrint:Say  (2234,790,CB_RN_NN[2],oFont13n)
oPrint:Line (2400,100,2400,2300 )
oPrint:Line (2500,100,2500,2300 )
oPrint:Line (2570,100,2570,2300 )
oPrint:Line (2640,100,2640,2300 )

oPrint:Line (2500,500,2640,500)
oPrint:Line (2570,750,2640,750)
oPrint:Line (2500,1000,2640,1000)
oPrint:Line (2500,1350,2570,1350)
oPrint:Line (2500,1550,2640,1550)

oPrint:Say  (2300,100 ,STR0015                             			,oFont8) //"Local de Pagamento"
oPrint:Say  (2340,100 ,STR0016        								,oFont10) //"Qualquer banco até a data do vencimento"

oPrint:Say  (2300,1910,STR0008                                     	,oFont8) //"Vencimento"
oPrint:Say  (2340,1910,DTOC(aDadosTit[4])                           ,oFont10)

oPrint:Say  (2400,100 ,STR0017                                      ,oFont8) //"Cedente"
oPrint:Say  (2400,500 ,aDadosEmp[1]                                 ,oFont10)

oPrint:Say  (2440,100 ,"CNPJ:"                                       ,oFont8) //"Cedente"
oPrint:Say  (2440,500 ,Subs(aDadosEmp[6],8)                         ,oFont10) // Pegar somente a partir da 8a. posicao

oPrint:Say  (2400,1910,STR0012                         				,oFont8) //"Agência/Código Cedente"
//oPrint:Say  (2140,1910,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
If AllTrim(Strzero(Val(aDadosBanco[1]),3)) == '104'
	cNumCalc	:= Strzero(Val(aDadosBanco[3]),4) + "87" + STRZERO(VAL(SEE->EE_CODEMP),9)
	oPrint:Say( 2440,1910, Strzero(Val(aDadosBanco[3]),4) +".870." + STRZERO(VAL(SEE->EE_CODEMP),8)  +"-"+  CALC745(cNumCalc), oFont10 )
Else
	oPrint:Say  (2440,1910,aDadosBanco[3]+"/"+aDadosBanco[4]+"/"+ IIf(CB_RN_NN[4], StrZero(CB_RN_NN[5],1), aDadosBanco[5]), oFont10 )
EndIf

oPrint:Say  (2500,100 ,STR0018                              		,oFont8) //"Data do Documento"
oPrint:Say  (2530,100 ,DTOC(aDadosTit[3])                           ,oFont10)

oPrint:Say  (2500,505 ,STR0019                                  	,oFont8) //"Nro.Documento"
oPrint:Say  (2530,605 ,aDadosTit[1]                                 ,oFont10)

oPrint:Say  (2500,1005,STR0020                                   	,oFont8) //"Espécie Doc."
oPrint:Say  (2530,1005,CB_RN_NN[7]                                 	,oFont10) //"Espécie do Documento"

oPrint:Say  (2500,1355,STR0021                                      ,oFont8) //"Aceite"
oPrint:Say  (2530,1455,CB_RN_NN[8]                                  ,oFont10)	// Aceite do documento

oPrint:Say  (2500,1555,STR0022                          			,oFont8) //"Data do Processamento"
oPrint:Say  (2530,1655,DTOC(aDadosTit[2])                           ,oFont10)

oPrint:Say  (2500,1910,STR0013                                   	,oFont8) //"Nosso Número"
cStrNNum	:= AllTrim(aDadosTit[6])
oPrint:Say  (2530,1910,cStrNNum                            ,oFont10)

oPrint:Say  (2570,100 ,STR0023                                   	,oFont8) //"Uso do Banco"

oPrint:Say  (2570,505 ,STR0024                                      ,oFont8) //"Carteira"
oPrint:Say  (2600,555 ,CB_RN_NN[6]                             		,oFont10)

oPrint:Say  (2570,755 ,STR0025                                      ,oFont8) //"Espécie"
oPrint:Say  (2600,805 ,STR0026                                      ,oFont10) //"R$"

oPrint:Say  (2570,1005,STR0027                                     	,oFont8) //"Quantidade"
oPrint:Say  (2570,1555,STR0028                                      ,oFont8) //"Valor"

oPrint:Say  (2570,1910,STR0029                          			,oFont8) //"(=)Valor do Documento"
oPrint:Say  (2600,2010,Transform(aDadosTit[5],"@E 999,999,999.99"),oFont10)

oPrint:Say  (2640,100 ,STR0030,oFont8) //"Instruções/Texto de responsabilidade do cedente"

nMsg:=2690
For nI := 1 To len(aMsgBoleto)
	oPrint:Say  (nMsg,120,aMsgBoleto[nI]                			,oFont10 )
	nMsg+=50
	If nI > 6
		Exit
	EndIf
Next nI

oPrint:Say  (2640,1910,STR0031                         				,oFont8) //"(-)Desconto/Abatimento"
oPrint:Say  (2670,1910,AllTrim(Transform(nAbatim,"@ZE 999,999,999.99")),oFont10)

oPrint:Say  (2710,1910,STR0032                             			,oFont8) //"(-)Outras Deduções"

oPrint:Say  (2780,1910,STR0033                                  	,oFont8) //"(+)Mora/Multa"

oPrint:Say  (2850,1910,STR0034                           			,oFont8) //"(+)Outros Acréscimos"
oPrint:Say  (2880,1910,AllTrim(Transform(nAcrescim,"@ZE 999,999,999.99")),oFont10)

oPrint:Say  (2920,1910,STR0035                               		,oFont8) //"(-)Valor Cobrado"

oPrint:Say  (2990,100 ,STR0036                                      ,oFont8) //"Recibo do Sacado"
//oPrint:Say  (2720,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"         ,oFont10)
oPrint:Say  (3010,400, Subs(aDatSacado[1],1,60)+" ("+aDatSacado[2]+")", oFont8 )		// Nome e Codigo do Cliente
oPrint:Say  (3040,400, IIF(Len(aDatSacado[7])<=11, "CPF:"+Transform(aDatSacado[7], "@R 999.999.999-99") , "CNPJ:"+Transform(aDatSacado[7], "@R 99.999.999/9999-99" ) ), oFont8)		// CPF/CNPJ
oPrint:Say  (3070,400 ,aDatSacado[3]                      ,oFont8)						// Endereço + Bairro
oPrint:Say  (3100,400 ,aDatSacado[6]+"   "+aDatSacado[4]+"-"+aDatSacado[5], oFont8)		// CEP + Cidade + Estado
/*
oPrint:Say  (2773,400 ,aDatSacado[3]                                ,oFont10)
oPrint:Say  (2826,400 ,aDatSacado[4]+" - "+aDatSacado[5]            ,oFont10)
oPrint:Say  (2879,400 ,aDatSacado[6]                                ,oFont10)
*/

oPrint:Say  (3135,100 ,STR0037                               		,oFont8) //"Sacador/Avalista"
oPrint:Say  (3175,1500,STR0038                        				,oFont8) //"Autenticação Mecânica -"
oPrint:Say  (3175,1850,STR0039                           			,oFont10) //"Ficha de Compensação"

oPrint:Line (2300,1900,2990,1900 )
oPrint:Line (2710,1900,2710,2300 )
oPrint:Line (2780,1900,2780,2300 )
oPrint:Line (2850,1900,2850,2300 )
oPrint:Line (2920,1900,2920,2300 )
oPrint:Line (2990,100 ,2990,2300 )

oPrint:Line (3170,100,3170,2300  )

MSBAR3("INT25",27.1,00.8,CB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.1,Nil,Nil,"A",.F.)

oPrint:EndPage() // Finaliza a página

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLR580MES ºAutor  ³Rafael M. Quadrotti º Data ³  02/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os meses em aberto do sacado.                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLR580MES(cCliente,cLoja,cMesBase,cAnoBase,cTipo)
LOCAL aMeses 	:= {} 							//Retorno da funcao.
LOCAL cSQL      := ""							//Query
LOCAL cSE1Name 	:= SE1->(RetSQLName("SE1"))	//retorna o alias no TOP.

SE1->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := " SELECT E1_CLIENTE, E1_LOJA, E1_ANOBASE, E1_MESBASE, E1_VENCTO "
cSQL += " FROM "+cSE1Name+" WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND "
cSQL += " E1_CLIENTE ='"+cCliente+"' AND "
cSQL +=	" E1_LOJA = '"+cLoja+"' AND "
cSQL += " E1_SALDO > 0 AND "
cSql += " E1_TIPO = '"+cTipo+"' AND "
cSQL += cSE1Name+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),STR0040,.T.,.F.) //"Meses"

TCSETFIELD(STR0040,"E1_VENCTO",	"D",08,0) //"Meses"

If Meses->(Eof())
	Meses->(DbCloseArea())
	Aadd(aMeses,"")
Else
	While 	!Eof() .And.;
		Meses->E1_CLIENTE == cCliente .And.;
		Meses->E1_LOJA ==	cLoja
		If (E1_MESBASE+E1_ANOBASE < cMesBase+cAnoBase) .and. dTos(E1_VENCTO) < dTos(dDatabase)
			If Ascan(aMeses, E1_MESBASE+"/"+E1_ANOBASE ) == 0
				Aadd(aMeses,E1_MESBASE+"/"+E1_ANOBASE)
			Endif
		EndIf
		DbSkip()
	End
	Meses->(DbCloseArea())
EndIf
Return (aMeses)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLR580TEXTºAutor  ³Rafael M. Quadrotti º Data ³  02/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna as mensagens para impressao.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLR580TEXT(	nTipo	,cCodInt	,cCodEmp,cConEmp,;
cSubCon	,cMatric	,cBase	,cModPag,;
cTipoUS	)//cBase = Ano+mes
LOCAL cQuery  	 := ""
LOCAL cNTable1   := "" // Nome da tabela no SQL
LOCAL cNTable2   := "" // Nome da tabela no SQL
LOCAL cNTable3   := "" // Nome da tabela no SQL
LOCAL aMsg		 := {} // Array de mensagens

DbSelectArea("BH1")
DbSetOrder(2)
cNTable1 := RetSqlName("BH1")
cNTable2 := RetSqlName("BA3")
cNTable3 := RetSqlName("BH2")

cQuery := " SELECT BH1.* ,BH2.* ,BA3.BA3_CODPLA,BA3.BA3_FILIAL,BA3.BA3_CODINT,BA3.BA3_CODEMP,BA3.BA3_MATRIC,BA3.BA3_CONEMP,BA3.BA3_VERCON,BA3.BA3_SUBCON,BA3.BA3_VERSUB "
cQuery += " FROM " +cNTable1+ " BH1 , " +cNTable2 +" BA3 , " +cNTable3 +" BH2 "

//BH1
cQuery += " WHERE BH1.BH1_FILIAL='"	+	xFilial("BH1")		+	"'    AND "
cQuery += "		 BH1.BH1_CODINT='"	+	cCodInt				+	"'    AND "
cQuery += "		 BH1.BH1_TIPO='"	+	Transform(nTipo,"9")+	"'    AND "
If !Empty(cCodEmp)
	cQuery += "(('"+cCodEmp +"' BETWEEN BH1.BH1_EMPDE   AND BH1.BH1_EMPATE) OR (BH1.BH1_EMPATE='' AND BH1.BH1_EMPDE='') ) AND "
EndIf
If !Empty(cConEmp)
	cQuery += "(('"+cConEmp +"' BETWEEN BH1.BH1_CONDE   AND BH1.BH1_CONATE)  OR (BH1.BH1_CONATE='' AND BH1.BH1_CONDE='') ) AND "
EndIf
If !Empty(cSubCon)
	cQuery += "(('"+cSuBCon +"' BETWEEN BH1.BH1_SUBDE   AND BH1.BH1_SUBATE)  OR (BH1.BH1_SUBATE='' AND BH1.BH1_SUBDE='') ) AND "
EndIf
If !Empty(cMatric)
	cQuery += "(('"+cMatric +"' BETWEEN BH1.BH1_MATDE   AND BH1.BH1_MATATE)  OR (BH1.BH1_MATATE='' AND BH1.BH1_MATDE='') ) AND "
EndIf
If !Empty(cBase)
	cQuery += "(('"+cBase   +"' BETWEEN BH1.BH1_BASEIN AND BH1.BH1_BASEFI) OR (BH1.BH1_BASEIN='' AND BH1.BH1_BASEFI='') ) AND "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclusivo para cooperativa medica...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 5
	cQuery += "(BH1_MODPAG = '"+cModPag+"' OR BH1_MODPAG = '3') AND "
	cQuery += "(BH1_TIPCON = '"+cTipoUS+"' OR BH1_TIPCON = '3') AND "
Endif

//BA3 PARA ENCONTRAR O PLANO
cQuery += "		 BA3.BA3_FILIAL='"	+	xFilial("BA3")	+	"'    AND "
cQuery += "		 BA3.BA3_CODINT='"	+	cCodInt  		+	"'    AND "
cQuery += "		 BA3.BA3_CODEMP='"	+	cCodEmp  		+	"'    AND "
If !Empty(cMatric)
	cQuery += "		 BA3.BA3_MATRIC='"	+	cMatric  		+	"'    AND "
Endif
cQuery += "		((BA3.BA3_CODPLA BETWEEN BH1.BH1_PLAINI AND BH1.BH1_PLAFIM) OR (BH1.BH1_PLAINI='' AND BH1.BH1_PLAFIM='') ) AND "

//BH2 MENSAGENS PARA IMPRESSAO
cQuery += "		 BH2.BH2_FILIAL = '"	+	xFilial("BH2")	+	"'    AND "
cQuery += "		 BH2.BH2_CODIGO = BH1.BH1_CODIGO  AND "

cQuery += "		BH1.D_E_L_E_T_<>'*' AND BA3.D_E_L_E_T_<>'*' AND BH2.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY BH1_FILIAL, BH1_CODIGO, BH1_CODINT, BH1_TIPO "

cQuery	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"MSG",.T.,.F.)

If MSG->(Eof())
	MSG->(DbCloseArea())
	Aadd(aMSG,"")
Else
	While 	!Eof()
		If Iif(BH1->(FieldPos("BH1_CONDIC")) > 0 , (Empty(MSG->BH1_CONDIC) .or. (&(MSG->BH1_CONDIC))), .T.)
			Aadd(aMSG,MSG->BH2_MSG01)
		Endif
		DbSkip()
	End
	MSG->(DbCloseArea())
EndIf

Return aMsg
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(	cBanco	,cAgencia	,cConta		,cDacCC		,;
cNroDoc	,nValor		,cPrefixo	,cNumero	,;
cParcela	,cTipo	,cCart, cEspec, cAceite,lweb)
LOCAL cMsg      := ""
LOCAL aArea		:= GetArea()
LOCAL aCodBar	:= {}
LOCAL cMoeda	:= "9"

DbSelectArea("SE1")
DbSetOrder(1)
If MsSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo)
	aCodBar:= RetDados(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
	cBanco		,cAgencia	,cConta		,cDacCC	,;
	cNroDoc		,nValor		,cCart		,cMoeda, cEspec, cAceite,lweb )
	If Len(aCodBar)=3
		If Empty(aCodBar[1])
			cMsg     += STR0047  		//"[1]codigo de barra "
		EndIf
		If Empty(aCodBar[2])
			cMsg     += STR0048  		//"[2]linha digitavel "
		EndIf
		If Empty(aCodBar[3])
			cMsg     += STR0049 		//"[3]nosso numero "
		EndIf
		If !empty(cMsg)
			if !lweb
				MsgInfo(STR0050+cMsg )  	//"Erro no(s) campo(s): "
			Endif
			aCodBar	:= {}
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return aCodBar
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RET_CBARRAºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este programa tem como objetivo efetuar os calculos e      º±±
±±º          ³retornar os seguintes dados:                                º±±
±±º          ³ Nosso numero                                               º±±
±±º          ³ Linha digitavel                                            º±±
±±º          ³ String com o valor para codigo de barras(uilizado pela     º±±
±±º          ³MSBAR)                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function RetDados(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
cBanco		,cAgencia	,cConta		,cDacCC	,;
cNroDoc		,nValor		,cCart		,cMoeda, cEspec, cAceite,lWeb	)
LOCAL cNosso		:= ""
LOCAL cDigNosso		:= ""
LOCAL NNUM			:= ""
LOCAL cCampoL		:= ""
LOCAL cFatorValor	:= ""
LOCAL cLivre		:= ""
LOCAL cDigBarra		:= ""
LOCAL cBarra		:= ""
LOCAL cParte1		:= ""
LOCAL cDig1			:= ""
LOCAL cParte2		:= ""
LOCAL cDig2			:= ""
LOCAL cParte3		:= ""
LOCAL cDig3			:= ""
LOCAL cParte4		:= ""
LOCAL cParte5		:= ""
LOCAL cDigital		:= ""
LOCAL aRet			:= {}

DEFAULT nValor := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por padrao, os clientes terao que usar o Ponto de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL580CDB")
	aRet := ExecBlock("PL580CDB",.f.,.f., { cPrefixo ,cNumero ,cParcela ,cTipo ,cBanco ,cAgencia ,cConta ,cDacCC ,cNroDoc ,nValor ,cCart ,cMoeda, cEspec, cAceite } )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento antigo para BB e CEF                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aRet) == 0
	Do case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Banco do Brasil                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	case cBanco == '001'
		
		If len(Alltrim(cAgencia)) == 4
			cAgencia := Alltrim(cAgencia)
		Else
			cAgencia := Left(cAgencia,4)
		EndIf
		
		
		cNosso := ""
		NNUM := STRZERO(Val(cNroDoc),11)
		//Nosso Numero
		cDigNosso  := CALC_di9(NNUM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para o tratamento no conteudo do nosso numero.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If ExistBlock("PL580NNU")
			aRetnNum := ExecBlock("PL580NNU",.f.,.f., { NNUM ,cDigNosso } )
			NNUM     := aRetnNum[1]
			cDigNosso:= aRetnNum[2]
		Endif
		cNosso     := NNUM + cDigNosso
		
		// campo livre			// verificar a conta e carteira
		//			cCampoL := cNosso+substr(e1_agedep,1,4)+STRZERO(VAL(e1_conta),8)+'18'
		cCampoL := NNUM+cAgencia+StrZero(Val(SUBSTR(cConta,1,8)),8)+cCart
		
		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := Plfator()+strzero(nValor*100,10)
		Else
			cFatorValor  := Plfator()+strzero(SE1->E1_VALOR*100,10)
		Endif
		
		cLivre := cBanco+cMoeda+cFatorValor+cCampoL
		
		// campo do codigo de barra
		cDigBarra := CALC_5p( cLivre )
		cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
		
		// composicao da linha digitavel
		cParte1  := cBanco+cMoeda
		cParte1  := cParte1 + SUBSTR(cCampoL,1,5)
		cDig1    := CALC151( cParte1 ) //DIGIT001( cParte1 )
		cParte2  := SUBSTR(cCampoL,6,10)
		cDig2    := CALC151( cParte2 ) //DIGIT001( cParte2 )
		cParte3  := SUBSTR(cCampoL,16,10)
		cDig3    := CALC151( cParte3 ) //DIGIT001( cParte3 )
		cParte4  := cDigBarra
		cParte5  := cFatorValor
		
		cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
		substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
		substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
		cParte4+" "+;
		cParte5
		
		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)
		Aadd(aRet, .F. )
		Aadd(aRet, 0)
		Aadd(aRet, cCart )
		Aadd(aRet, cEspec )
		Aadd(aRet, cAceite )
		Aadd(aRet, cMoeda)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CEF - Caixa Economica Federal                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	case cBanco == '104'
		
		cAgencia:=Strzero(Val(cAgencia),4)
		
		cNosso := ""
		NNUM := STRZERO(Val(cNroDoc),08)
		//Nosso Numero
		cDigNosso  := CALC_di11('82'+NNUM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para o tratamento no conteudo do nosso numero.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If ExistBlock("PL580NNU")
			aRetnNum := ExecBlock("PL580NNU",.f.,.f., { NNUM ,cDigNosso } )
			NNUM     := aRetnNum[1]
			cDigNosso:= aRetnNum[2]
		Endif
		cNosso     := '82' + NNUM + cDigNosso
		
		// campo livre
		cCampoL	:= '82'+NNUM+Strzero(Val(cAgencia),4)+'87'+STRZERO(VAL(SEE->EE_CODEMP),9)
		
		
		// se houver valor minimo de pagamento
		If nValor > 0
			cFatorValor  := Plfator()+strzero(nValor*100,10)
		Else
			cFatorValor  := Plfator()+strzero(SE1->E1_VALOR*100,10)
		Endif
		
		cLivre := cBanco+cMoeda+cFatorValor+cCampoL
		
		// campo do codigo de barra
		cDigBarra := CALC_5p( cLivre )
		cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
		
		// composicao da linha digitavel
		cParte1  := cBanco+cMoeda
		cParte1  += SUBSTR(cCampoL,1,5)
		cDig1    := CALC151(cParte1)		//DIGIT001( cParte1 )
		cParte2  := SUBSTR(cCampoL,6,10)
		cDig2    := CALC151(cParte2)			//DIGIT001( cParte2 )
		cParte3  := SUBSTR(cCampoL,16,10)
		cDig3    := CALC151(cParte3)		// DIGIT001( cParte3 )
		cParte4  := cDigBarra
		cParte5  := cFatorValor
		
		cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
		substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
		substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+"  "+;
		cParte4+"  "+;
		cParte5
		
		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)
		Aadd(aRet, .F. )
		Aadd(aRet, 0)
		Aadd(aRet, cCart )
		Aadd(aRet, cEspec )
		Aadd(aRet, cAceite )
		Aadd(aRet, cMoeda)
	EndCase
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao achou parametrizacao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aRet) == 0
    MsgInfo(STR0053)
	Aadd(aRet,"")
	Aadd(aRet,"")
	Aadd(aRet,"")
	Aadd(aRet, .F. )
	Aadd(aRet, 0)
	Aadd(aRet, cCart )
	Aadd(aRet, cEspec )
	Aadd(aRet, cAceite)
	Aadd(aRet, cMoeda)
EndIf
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_dig	ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do Itau                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC_dig(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi > 9 .or. auxi == 0
	auxi := 0
Else
	auxi := 10 - auxi
EndIf

Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALCDig745ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do Itau                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALCDig745(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi == 10 .or. auxi == 0  .or. auxi == 1
	auxi := 0
Else
	auxi := 10 - auxi
EndIf

//cBase:=cBase+str(Auxi,1,0)

Return(str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC745   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do City Bank              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC745(cVariavel)
LOCAL Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If nBase == 10
		nBase := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig := SumDig+auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 10 .or. auxi == 1
	auxi := 0
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC707   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC707(cVariavel)
LOCAL Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If nBase == 8
		nBase := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig := SumDig+auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0
	auxi := "0"
ElseIf auxi == 1
	auxi := "P"
Else
	auxi := str(11 - auxi,1,0)
EndIf

Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_5p   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC_5p(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR		ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR  de vencimento para linha digitavel.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlFator()
If Len(ALLTRIM(SUBSTR(DTOC(SE1->E1_VENCTO),7,4))) = 4
	cData := SUBSTR(DTOC(SE1->E1_VENCTO),7,4)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
Else
	cData := "20"+SUBSTR(DTOC(SE1->E1_VENCTO),7,2)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
EndIf
cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
//cFator := STR(1000+(SE1->E1_VENCREA-STOD("20000703")),4)
Return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR453  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR  de vencimento para linha digitavel.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fator453()
cFator := SE1->E1_VENCREA - STOD("19971007")
cFator := STR(cFator,4)
return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di1  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do nosso numero                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CALC_di1(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),7)
lbase  :=  LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
auxi := 11 - auxi
If auxi == 1 .OR. auxi == 11  .OR. auxi == 10
	auxi := 0
ElseIf auxi == 0
	auxi := 1
EndIf
auxi := str(Auxi,1,0)

Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di2  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do nosso numero                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CALC_di2(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := ALLTRIM(cVariavel)
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 10 .or. auxi == 1
	cBase := "1"
Else
	auxi := 11 - auxi
	cBase:=str(Auxi,1,0)
Endif

Return(cBase)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di3  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do nosso numero                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CALC_di3(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),10)
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := sumdig*10
auxi := mod(sumdig,11)
If auxi >= 10
	cBase:=cBase+"0"
ElseIf auxi == 0
	cBase:=cBase+"0"
Else
	cBase:=cBase+str(Auxi,1,0)
Endif

Return(cBase)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di4  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do nosso numero                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CALC_di4(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),12)
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := int(Sumdig/11)
auxi := 11 - (sumdig - ( auxi * 11 ) )
cBase:=cBase+str(Auxi,1,0)

Return(cBase)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di5  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do nosso numero                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CALC_di5(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),7)
lbase  := LEN(cBase)
base   := 20
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 10
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 10
	auxi:="0"
Else
	auxi := STR(auxi,1,0)
Endif

Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di6  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do nosso numero BANCO RURAL (453)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CALC_di6(cVariavel)
LOCAL Auxi := 0, sumdig := 0
LOCAL iDig

sumdig := 0
Auxi   := 0

aPesos := {0,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3}

For iDig := 1 To LEN(cVariavel)
	auxi   := Val(SubStr(cVariavel, idig, 1)) * aPesos[iDig]
	sumdig := SumDig + auxi
Next iDig

auxi := mod(sumdig,10)

If auxi == 0 .or. auxi >= 10
	cBase := '0'
ElseIf auxi == 1
	cBase := '9'
ElseIf auxi == 2
	cBase := '8'
ElseIf auxi == 3
	cBase := '7'
ElseIf auxi == 4
	cBase := '6'
ElseIf auxi == 5
	cBase := '5'
ElseIf auxi == 6
	cBase := '4'
ElseIf auxi == 7
	cBase := '3'
ElseIf auxi == 8
	cBase := '2'
ElseIf auxi == 9
	cBase := '1'
Else
	cBase := '1'
	MsgBox(STR0077) //"Verificar Digito"
EndIf

Return(cBase)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di7  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do nosso numero Nossa Caixa                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC_di7(cVariavel)

cbase := cVariavel
lbase  :=  LEN(cBase)
sumdig := 0
Auxi   := 0
iDig   := lBase
aPesos := {3,1,9,7,3,1,9,7,3,1,9,7,3,1,3,1,9,7,3,1,9,7,3}
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * aPesos[iDig]
	sumdig := SumDig+auxi
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi = 10
	auxi:="0"
Else
	auxi:=str(10-Auxi,1,0)
Endif

Return(auxi)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_8P   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do codigo de BARRAS BANCO RURAL           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC_8p(cVariavel)

cbase := cVariavel
lbase  :=  LEN(cBase)
base := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base = 10
		base = 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base := base + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
auxi := 11 - auxi
If auxi = 0 .or. auxi = 1 .or. auxi > 9
	auxi := 1
EndIf

Return(str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT453  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DIGIT453(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	If auxi > 10
		auxi := (auxi-10) + 1
	Endif
	sumdig := SumDig+auxi
	base   := 3 - base
	iDig   := iDig - 1
End
auxi := mod(sumdig,10)
auxi := 10 - auxi
If auxi >= 10 .or. auxi == 0
	auxi := "0"
Else
	auxi := str(Auxi,1,0)
Endif
Return( auxi )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di9  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo do nosso numero do banco do brasil             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC_di9(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT001  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Banco do Brasil          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DIGIT001(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12))
nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
auxi := nDezena - sumdig

If auxi >= 10
	auxi := 0
EndIf
Return(str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC151   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³// digito 1 e 2 da chave ASBACE					          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC151(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi == 0
	auxi := 0
Else
	auxi := 10 - auxi
EndIf

Return(str(auxi,1,0))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT151  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Linha digitavel nossa caixa.    					          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function DIGIT151(cVariavel)
LOCAL Auxi := 0, sumdig := 0
LOCAL nValor	:= 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
nValor:=sumdig*9
auxi := mod(nvalor,10)

Return(str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC422   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Codigo de barras BANCO SAFRA.   					          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CALC422(cVariavel)
LOCAL Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig += auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0
	auxi := 1
ElseIf auxi == 1
	auxi := 0
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC409   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                					          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALC409(cVariavel)
LOCAL Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If nBase == 10
		nBase := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig := SumDig+auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
sumdig := sumdig*10
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 10
	auxi := 0
EndIf

Return(str(auxi,1,0))



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di11   ºAutor  ³Microsiga           º Data ³  02/13/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero - modulo 11               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_di11(cVariavel)
LOCAL Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
auxi := 11 - auxi
if auxi > 9
	auxi:=0
endif

Return(str(auxi,1,0))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PR580UTILIºAutor  ³					 º Data ³  01/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os detalhes das utilizações.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PR580UTILI(cPlnuco,cCodint,cCodemp,cMatric)
LOCAL aUtilizacoes	:= {}						    // Retorno da função com array de dados das mensalidades e demais composições do boleto.
LOCAL cSQL3		    := ""							//Query
LOCAL aArea			:= GetArea()
LOCAL cBD6Name 		:= BD6->(RetSQLName("BD6"))	// Retorna o nome do alias no TOP

BD6->(DbSetOrder(1))


cSQL3 := "SELECT BD6_NOMUSR,BD6_NOMRDA,BD6_DATPRO,BD6_CODPRO,BD6_DESPRO,BD6_QTDPRO,BD6_VLRTPF "
cSQL3 += "FROM "+cBD6Name+  " BD6"
cSQL3 += " JOIN " + RetSQLName("BDH") + " BDH "
cSQL3 += " ON BDH_FILIAL = '" + xFilial("BDH") + "' AND "
cSQL3 += " BD6.BD6_OPEUSR = BDH.BDH_CODINT AND BD6.BD6_CODEMP = BDH.BDH_CODEMP AND "
cSQL3 += " BD6.BD6_MATRIC = BDH.BDH_MATRIC AND BD6.BD6_TIPREG = BDH.BDH_TIPREG AND "
cSQL3 += " BD6.BD6_ANOPAG = BDH.BDH_ANOFT AND BD6.BD6_MESPAG = BDH.BDH_MESFT AND "
cSQL3 += " BD6.BD6_LANCF = BDH.BDH_LANCF AND BD6.BD6_SEQPF = BDH.BDH_SEQPF AND "
cSQL3 += " BDH.D_E_L_E_T_ = '' "
cSQL3 += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSQL3 += " BD6_NUMFAT = '"+cPlnuco+"' AND BD6_OPEUSR = '"+cCodint+"' AND BD6_CODEMP = '"+cCodemp+"' AND "

If !EMPTY(cMatric)
	cSQL3 += " BD6_MATRIC = '"+cMatric+"' AND "
Endif

cSQL3 += " BD6.D_E_L_E_T_ = '' "
cSQL3 += "ORDER BY BD6_FILIAL, BD6_STAFAT, BD6_OPEFAT, BD6_NUMFAT, BD6_PREFIX, BD6_NUMTIT,BD6_PARCEL, BD6_TIPTIT, BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG"

PLSQuery(cSQL3,STR0078) //"Utilizacoes" //"Utilizacoes"


If Utilizacoes->(Eof())
	Utilizacoes->(DbCloseArea())
	Aadd(aUtilizacoes,{"","","","","",""})
Else
	While !Eof()
		aadd(aUtilizacoes,{Substr((Utilizacoes->BD6_NOMUSR),1,40),; //Usuario
		SUBSTR(Utilizacoes->BD6_NOMRDA,1,30),; //Prestador
		SUBSTR(dtos(Utilizacoes->BD6_DATPRO), 7, 2)+"/"+SUBSTR(dtos(Utilizacoes->BD6_DATPRO), 5, 2)+"/"+SUBSTR(dtos(Utilizacoes->BD6_DATPRO), 1, 4),; //Data Mensalidade/Utilização
		ALLTRIM(Utilizacoes->BD6_CODPRO)+" "+substr(Utilizacoes->BD6_DESPRO,1,39),; //Servicos
		TRANSFORM(Utilizacoes->BD6_QTDPRO,"@E 999"),; //Quantidade
		TRANSFORM(Utilizacoes->BD6_VLRTPF,"@E 99,999,999.99")})//Valor
		DbSkip()
	End
	Utilizacoes->(DbCloseArea())
EndIf
RestArea(aArea)
Return (aUtilizacoes)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R580Quebr   ºAutor  ³Microsiga           º Data ³  04/25/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Quebra Linha de Messagens do Boleto			               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R580Quebr(aMessag)
Local cObs		:=""
Local nLinObs	:=0
Local nObs      :=0
Local nI		:=0

For nI := 1 To len(aMessag)
	cObs += alltrim(aMessag[nI])+" "
	
Next nI

nLinObs	:= MLCOUNT(cObs, , , )
aMessag:={}


For nObs := 1 To nLinObs
	aADD(aMessag,{MEMOLINE(cObs, , nObs, )})
Next nObs

return (aMessag)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R580Bl2   ºAutor  ³Microsiga           º Data ³  04/25/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprimir segundo Bloco do Boleto			               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R580Bl2(	aCobranca ,nAbatim	,nAcrescim	,oPrint	,;
aBMP ,aDadosEmp	,aDadosTit	,aDadosBanco,;
aDatSacado	,aMsgBoleto	,CB_RN_NN ,aOpenMonth ,;
aDependentes,aObservacoes,cCart,aMsgCorpo,aUtilCob,lWeb ,aReajuste)

Local ni:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Inicia uma nova página
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

oPrint:Say(050/nTweb	,500/nTweb	,aDadosEmp[1]	,oFont11n,nil,CLR_HRED)
oPrint:Say(090/nTweb	,500/nTweb	,aDadosEmp[2] 	,oFont8 )
oPrint:Say(125/nTweb	,500/nTweb	,aDadosEmp[3] 	,oFont8 )
oPrint:Say(160/nTweb	,500/nTweb	,aDadosEmp[4] 	,oFont8 )
oPrint:Say(195/nTweb	,500/nTweb	,aDadosEmp[5] 	,oFont8 )
oPrint:Say(230/nTweb	,500/nTweb	,aDadosEmp[6] 	,oFont8 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Bmp da ANS
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If File(SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"))
	oPrint:SayBitmap (090/nTweb,1825/nTweb,SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"),470/nTweb ,150/nTweb)
Else
	oPrint:Say  (090/nTweb,1780/nTweb,aDadosEmp[7] ,oFont21)
Endif

If Subs(aDadosBanco[1],1,3) <> '104'
	oPrint:Say  (250/nTweb,1780/nTweb,STR0044 + R580Imp->E1_MESBASE+" / "+R580Imp->E1_ANOBASE ,oFont10) //"Mês de competência: "
Else
	oPrint:Say  (250/nTweb,1430/nTweb,STR0062 + R580Imp->E1_MESBASE+" / "+R580Imp->E1_ANOBASE ,oFont10) //"Recibo do Sacado - Mês de competência: "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Linhas do extrato.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:SayBitmap (50/nTweb ,100/nTweb,aBitMap[1],250/nTweb ,200/nTweb )
oPrint:Box  (300/nTweb-nLweb,100/nTweb,3200/nTweb-nLweb,2300/nTweb)
oPrint:Line (400/nTweb-nLweb,0100/nTweb,400/nTweb-nLweb,2300/nTweb)
oPrint:Line (800/nTweb-nLweb,0100/nTweb,800/nTweb-nLweb,2300/nTweb)
oPrint:Line (300/nTweb-nLweb,0400/nTweb,400/nTweb-nLweb,0400/nTweb)
oPrint:Line (300/nTweb-nLweb,0800/nTweb,400/nTweb-nLweb,0800/nTweb)
oPrint:Line (300/nTweb-nLweb,1150/nTweb,800/nTweb-nLweb,1150/nTweb)
oPrint:Line (300/nTweb-nLweb,1500/nTweb,400/nTweb-nLweb,1500/nTweb)
oPrint:Line (300/nTweb-nLweb,1900/nTweb,800/nTweb-nLweb,1900/nTweb)

oPrint:Say  (3300/nTweb,100/nTweb,Replicate(".",219),oFont10)

oPrint:Line (2625/nTweb,100/nTweb,2625/nTweb,2300/nTweb)// Limite para observacao
oPrint:Line (2625/nTweb,1150/nTweb,2625/nTweb,1150/nTweb)// Linha central



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Emissao dos dados do sacado.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:Say(400/nTweb,0105/nTweb, STR0004,oFont8 ) 													//"Dados do Sacado"
oPrint:Say(435/nTweb,0115/nTweb, Subs(aDatSacado[1],1,60)+" ("+aDatSacado[2]+")", oFont8 )		// Nome e Codigo do Cliente
oPrint:Say(505/nTweb,0115/nTweb ,aDatSacado[3],oFont8)												// Endereço + Bairro
oPrint:Say(540/nTweb,0115/nTweb ,aDatSacado[6]+"   "+aDatSacado[4]+"-"+aDatSacado[5], oFont8)		// CEP + Cidade + Estado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as mensagens do corpo do boleto...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMsg:=580/nTweb
aReajuste:=R580Quebr(aReajuste)
For nI := 1 To Len(aReajuste)
	If ! Empty(aReajuste[nI])
		oPrint:Say  (nMsg,105/nTweb,aReajuste[nI][1],oFont8 )
		nMsg += 40/nTweb
	Endif
Next


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³informacoes dos Usuários/dependentes
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:Say  (400/nTweb,1155/nTweb ,STR0005+Iif(BG9->BG9_TIPO == '1',(" ("+R580Imp->E1_CODINT+"."+R580Imp->E1_CODEMP+"."+R580Imp->E1_MATRIC+")"),"") ,oFont8 ) //"Usuários"

nContLn := 455
For nI := 1 To Len(aDependentes)
	If nI == 1
		oPrint:Say  (nContLn/nTweb,1165/nTweb ,aDependentes[nI,1]+" - "+Alltrim(aDependentes[nI,2])+STR0006+" - "+Alltrim(aDependentes[nI,3])		      ,oFont8n) //" (Titular)"
	Else
		oPrint:Say  (nContLn/nTweb,1165/nTweb ,aDependentes[nI,1]+" - "+Alltrim(aDependentes[nI,2])+" - "+aDependentes[nI,3]			      ,oFont8n)
	EndIf
	nContLn+=23
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Emite somente os 5 primeiros dependentes devido ao espaco no boleto.³
	//³Foi utilizado for e estrutura de array para facilitar a customizacao³
	//³para impressao de mais dependentes.								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  nI > 12
		Exit
	EndIf
Next nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³meses em aberto.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrint:Say  (400/nTweb,1905/nTweb ,STR0007,oFont8 ) //"Meses em aberto"
nContLn := 455/nTweb
nColuna := 1905/nTweb

For nI := 1 To Len(aOpenMonth)
	oPrint:Say  (nContLn,nColuna ,aOPenMonth[nI] ,oFont8)
	nContLn+=25/nTweb
	If nI > 18
		Exit
	EndIf
Next nI

oPrint:Say  (300/nTweb,105/nTweb,STR0008                   ,oFont8 ) //"Vencimento"
oPrint:Say  (345/nTweb,205/nTweb,DTOC(aDadosTit[4])             ,oFont10)

oPrint:Say  (300/nTweb,405/nTweb,STR0009                     ,oFont8 ) //"Valor R$"
oPrint:Say  (345/nTweb,505/nTweb,Transform(aDadosTit[5],"@E 999,999,999.99"),oFont10)

oPrint:Say  (300/nTweb,805/nTweb,STR0010             ,oFont8 ) //"Data de Emissão"
oPrint:Say  (345/nTweb,905/nTweb,DTOC(aDadosTit[3])             ,oFont10)

oPrint:Say  (300/nTweb,1155/nTweb,STR0011            ,oFont8 ) //"Nro.do Documento"
oPrint:Say  (345/nTweb,1255/nTweb,aDadosTit[1]                  ,oFont10)

oPrint:Say  (300/nTweb,1505/nTweb,STR0012      ,oFont8 ) //"Agência/Código Cedente"

If AllTrim(Strzero(Val(aDadosBanco[1]),3)) == '104'
	cNumCalc	:= Strzero(Val(aDadosBanco[3]),4) + "87" + STRZERO(VAL(SEE->EE_CODEMP),9)
	oPrint:Say( 345/nTweb,1505/nTweb, Strzero(Val(aDadosBanco[3]),4) +".870." + STRZERO(VAL(SEE->EE_CODEMP),8)  +"-"+  CALC745(cNumCalc), oFont10 )
Else
	oPrint:Say  (345/nTweb,1505/nTweb,aDadosBanco[3]+IIf (!Empty(aDadosBanco[6]),+"-"+aDadosBanco[6]+"/",+"/")+aDadosBanco[4]+ IIf(CB_RN_NN[4], +"-"+StrZero(CB_RN_NN[5],1), iif(!Empty(aDadosBanco[5]),+"-"+aDadosBanco[5],aDadosBanco[5])), oFont10 )
EndIf

oPrint:Say  (300/nTweb,1905/nTweb,STR0013                ,oFont8 ) //"Nosso Número"
cStrNNum	:= AllTrim(aDadosTit[6])
oPrint:Say  (345/nTweb,1950/nTweb,cStrNNum               ,oFont10)


nColuna := 115/nTweb
nMsg:=1650/nTweb
oPrint:Say  (2570/nTweb,105/nTweb,STR0014                ,oFont8 ) //"Observação"


If !Empty(aObservacoes[1])
	aObservacoes:=R580Quebr(aObservacoes)
	nMsg:=2670/nTweb
	For nI := 1 To len(aObservacoes)
		oPrint:Say (nMsg,105/nTweb,aObservacoes[nI][1]  ,oFont8 )
		nMsg+=40/nTweb
		
		If nI > 8
			Exit
		EndIf
		
	Next nI
Endif

Return()