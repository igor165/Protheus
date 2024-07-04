
#include "PLSMGER.CH"
#include "PROTHEUS.CH"

Static aFranquia	:= {}

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  ЁPLSA102  Ё Autor Ё Tulio Cesar          Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Reajuste de Precos dos Produtos                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA102
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variavels da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := "Reajuste de Preco de Produto"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega matriz com arquivos para reajustar o valor da franquia...        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aFranquia, {"BHI",1,"BHI_FILIAL+BHI_CODINT+BHI_CODPLA+BHI_VERSAO"	,"BHI_LIMFRA"})
Aadd( aFranquia, {"BHD",1,"BHD_FILIAL+BHD_CODIGO+BHD_VERSAO"			,"BHD_LIMFRA"})
Aadd( aFranquia, {"BHJ",1,"BHJ_FILIAL+BHJ_CODINT+BHJ_CODPLA+BHJ_VERSAO"	,"BHJ_LIMFRA"})
Aadd( aFranquia, {"BYK",1,"BYK_FILIAL+BYK_CODIGO+BYK_VERSAO"			,"BYK_LIMFRA"})
Aadd( aFranquia, {"BCW",1,"BCW_FILIAL+BCW_CODIGO+BCW_VERSAO"			,"BCW_LIMFRA"})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define browse...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BK7->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BK7"))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA102MOV Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Reajuste de Precos de Venda e das Empresas e PF            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA102MOV(cAlias,nReg,nOpc)
Local I__f := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cCadastro := "Reajuste"
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := {|| nOpca := 1,If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel   := {|| oDlg:End() }
LOCAL oEnchoice
LOCAL aButtons  := {}
LOCAL nOpcGD
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,000 TO ndLinFin,ndColFin OF GetWndDefault()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dados da enchoice...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Incluir
   Copy cAlias TO Memory Blank
Else
   Copy cAlias TO Memory
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Enchoice....                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If     nOpc == K_Alterar
       nOpcGD := K_Visualizar
Else
       nOpcGD := nOpc
Endif

if Val(GetVersao(.F.)) >= 12 //Valida versЦo 12
	oEnchoice := MSMGet():New(calias,BK7->(Recno()),nOpcGD,,,,nil,{034,001,193,394},nil,,,,,oDlg,,,.F.)
Else
	oEnchoice := MSMGet():New(calias,BK7->(Recno()),nOpcGD,,,,nil,{014,001,193,394},nil,,,,,oDlg,,,.F.)
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Faz o tratamento...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Chama funcao generica que realiza o processamento...                     Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nOpc <> K_Visualizar
      If nOpc == K_Incluir
         Processa( {|| PLSA102ATU(M->BK7_CODINT,M->BK7_ANOMES,M->BK7_PRODE,M->BK7_PROATE,M->BK7_TIPPRO,M->BK7_MSG01,;
                        M->BK7_MSG02,M->BK7_MSG03,M->BK7_MENS,M->BK7_OPC,M->BK7_ADESAO,M->BK7_INDICE,.T.,M->BK7_FRANQ) },;
                       "Reajuste","Aplicando Reajuste...",.T. )
      Else
         Processa( {|| PLSA102EXC(M->BK7_CODINT,M->BK7_CODREA,.T.) },;
                       "Reajuste","Excluindo Reajuste...",.T. )
      Endif
   Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA102ATU Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Atualiza os dados do reajuste na base de dados...          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA102ATU(cCodOpe,cAnoMes,cProDe,cProAte,cTipPro,cMsg01,cMsg02,cMsg03,cMens,cOpc,cAdesao,nPercen,lDisplay,cFranquia)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis locais...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL lMens     := (cMens == "1")
LOCAL lOpcional := (cOpc == "1")
LOCAL lTaxa     := (cAdesao == "1")
LOCAL lFranquia	:= (cFranquia == "1")
LOCAL cCodRea
LOCAL nIndice   := nPercen
LOCAL nVlrRea
LOCAL lAbortPrint := .F.
LOCAL n_		:= 0

DEFAULT cFranquia := ''
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё busca o proximo codigo do lote de reajuste...                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodRea := PLSA625Cd("BK7_CODREA","BK7",1,"BK7_CODINT",cCodOpe)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia transacao...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava cabecalho do lote de reajuste...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BK7->(RecLock("BK7",.T.))
BK7->BK7_FILIAL  := xFilial("BK7")
BK7->BK7_CODINT  := cCodOpe
BK7->BK7_CODREA  := cCodRea
BK7->BK7_ANOMES  := cAnoMes
BK7->BK7_PRODE   := cProDe
BK7->BK7_PROATE  := cProAte
BK7->BK7_TIPPRO  := cTipPro
BK7->BK7_MSG01   := cMsg01
BK7->BK7_MSG02   := cMsg02
BK7->BK7_MSG03   := cMsg03
BK7->BK7_MENS    := cMens
BK7->BK7_OPC     := cOpc
BK7->BK7_ADESAO  := cAdesao
BK7->BK7_INDICE  := nPercen
BK7->BK7_FRANQ	 := cFranquia
BK7->(MsUnLock())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Analisa dados da query...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BI3->(DbSetOrder(1))
BI3->(DbSeek(xFilial("BI3")))
While ! BI3->(Eof()) .And. BI3->BI3_FILIAL == xFilial("BI3")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Testa cancelamento do processo...                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Interrupcao(lAbortPrint)
		Exit
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Bypassa registros fora do filtro...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ! ( ( BI3->BI3_CODINT == cCodOpe ) .And. ;
		( BI3->BI3_CODIGO >= cProDe .And. BI3->BI3_CODIGO <= cProAte ) )
		BI3->(DbSkip())
		Loop
	Endif

	If ! ( cTipPro == "3" .Or. cTipPro == BI3->BI3_TIPO )
		BI3->(DbSkip())
		Loop
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exibe mensagem de processamento...                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lDisplay
		IncProc("Analisando Produto "+BI3->BI3_CODIGO+" ("+AllTrim(BI3->BI3_DESCRI)+")")
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza os dados da mensalidade...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lMens
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza faixa etaria do produto...                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BB3->(DbSetOrder(1))
		If BB3->(DbSeek(xFilial("BB3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
			While ! BB3->(Eof()) .And. BB3->(BB3_FILIAL+BB3_CODIGO+BB3_VERSAO) == xFilial("BB3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := Round(BB3->BB3_VALFAI + ((BB3->BB3_VALFAI*nIndice)/100),2)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BK8->(RecLock("BK8",.T.))
				BK8->BK8_FILIAL := xFilial("BK8")
				BK8->BK8_OPEREA := BK7->BK7_CODINT
				BK8->BK8_CODREA := BK7->BK7_CODREA
				BK8->BK8_CODOPE := BI3->BI3_CODINT
				BK8->BK8_CODPRO := BI3->BI3_CODIGO
				BK8->BK8_VERSAO := BI3->BI3_VERSAO
				BK8->BK8_CODFAI := BB3->BB3_CODFAI
				BK8->BK8_IDAINI := BB3->BB3_IDAINI
				BK8->BK8_IDAFIN := BB3->BB3_IDAFIN
				BK8->BK8_VLRANT := BB3->BB3_VALFAI
				BK8->BK8_VLRREA := nVlrRea
				BK8->BK8_DATREA := dDataBase
				BK8->BK8_PERREA := nIndice
				BK8->BK8_CODFOR := BB3->BB3_CODFOR
				BK8->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BB3->(RecLock("BB3",.F.))
				BB3->BB3_VLRANT := BB3->BB3_VALFAI
				BB3->BB3_ANOMES := cAnoMes
				BB3->BB3_VALFAI := nVlrRea
				BB3->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BB3->(DbSkip())
			Enddo
		Endif
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza faixa salarialdo produto..                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("B1A") .and. PLSALIASEX("BYR")
			B1A->(DbSetOrder(1))
			If B1A->(DbSeek(xFilial("BB3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
				While ! B1A->(Eof()) .And. B1A->(B1A_FILIAL+B1A_CODIGO+B1A_VERSAO) == xFilial("BB3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Apura o valor com o reajuste...                                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nVlrRea := Round(B1A->B1A_VALOR + ((B1A->B1A_VALOR*nIndice)/100),2)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Joga para o historico o valor atual desta faixa...                       Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BYR->(RecLock("BYR",.T.))
					BYR->BYR_FILIAL := xFilial("BYR")
					BYR->BYR_OPEREA := BK7->BK7_CODINT
					BYR->BYR_CODREA := BK7->BK7_CODREA
					BYR->BYR_CODOPE := BI3->BI3_CODINT
					BYR->BYR_CODPRO := BI3->BI3_CODIGO
					BYR->BYR_VERSAO := BI3->BI3_VERSAO
					BYR->BYR_CODFAI := B1A->B1A_CODFAI
					BYR->BYR_VLSLIN := B1A->B1A_VLSLIN
					BYR->BYR_VLSLFN := B1A->B1A_VLSLFN
					BYR->BYR_VLRANT := B1A->B1A_VALOR
					BYR->BYR_VLRREA := nVlrRea
					BYR->BYR_DATREA := dDataBase
					BYR->BYR_PERREA := nIndice
					BYR->BYR_CODFOR := B1A->B1A_CODFOR
					BYR->(MsUnLock())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					B1A->(RecLock("B1A",.F.))
					B1A->B1A_VLRANT := B1A->B1A_VALOR
					B1A->B1A_ANOMES := cAnoMes
					B1A->B1A_VALOR  := nVlrRea
					B1A->(MsUnLock())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Acessa proximo registro...                                               Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					B1A->(DbSkip())
				Enddo
			Endif
		Endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza Prod x Faixa X qtd.                 	                     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("B1F")
			B1F->(DbSetOrder(1))
			If B1F->(DbSeek(xFilial("BIF")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
				While ! B1F->(Eof()) .And. B1F->(B1F_FILIAL+B1F_CODIGO+B1F_VERSAO) == xFilial("BB3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Apura o valor com o reajuste...                                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nVlrRea := Round(B1F->B1F_VALOR + ((B1F->B1F_VALOR*nIndice)/100),2)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					B1F->(RecLock("B1F",.F.))
					B1F->B1F_VLRANT := B1F->B1F_VALOR
					B1F->B1F_ANOMES := cAnoMes
					B1F->B1F_VALOR  := nVlrRea
					B1F->(MsUnLock())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Acessa proximo registro...                                               Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					B1F->(DbSkip())
				Enddo
			Endif
		Endif

	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza os dados dos opcionais...                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lOpcional
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza faixa etaria dos opcionais...                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BBV->(DbSetOrder(1))
		If BBV->(DbSeek(xFilial("BBV")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
			While ! BBV->(Eof()) .And. BBV->(BBV_FILIAL+BBV_CODIGO+BBV_VERSAO) == xFilial("BBV")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := Round(BBV->BBV_VALFAI + ((BBV->BBV_VALFAI*nIndice)/100),2)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BK9->(RecLock("BK9",.T.))
				BK9->BK9_FILIAL := xFilial("BK9")
				BK9->BK9_OPEREA := BK7->BK7_CODINT
				BK9->BK9_CODREA := BK7->BK7_CODREA
				BK9->BK9_CODOPE := BI3->BI3_CODINT
				BK9->BK9_CODPRO := BI3->BI3_CODIGO
				BK9->BK9_VERSAO := BI3->BI3_VERSAO
				BK9->BK9_CODOPC := BBV->BBV_CODOPC
				BK9->BK9_VEROPC := BBV->BBV_VEROPC
				BK9->BK9_CODFAI := BBV->BBV_CODFAI
				BK9->BK9_IDAINI := BBV->BBV_IDAINI
				BK9->BK9_IDAFIN := BBV->BBV_IDAFIN
				BK9->BK9_VLRANT := BBV->BBV_VALFAI
				BK9->BK9_VLRREA := nVlrRea
				BK9->BK9_DATREA := dDataBase
				BK9->BK9_PERREA := nIndice
				BK9->BK9_CODFOR := BBV->BBV_CODFOR
				BK9->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBV->(RecLock("BBV",.F.))
				BBV->BBV_VLRANT := BBV->BBV_VALFAI
				BBV->BBV_ANOMES := cAnoMes
				BBV->BBV_VALFAI := nVlrRea
				BBV->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBV->(DbSkip())
			Enddo
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza os dados da mensalidade...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lTaxa
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza faixa etaria do produto...                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BRY->(DbSetOrder(1))
		If BRY->(DbSeek(xFilial("BRY")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
			While ! BRY->(Eof()) .And. BRY->(BRY_FILIAL+BRY_CODIGO+BRY_VERSAO) == xFilial("BRY")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nVlrRea := Round(BRY->BRY_VLRADE + ((BRY->BRY_VLRADE*nIndice)/100),2)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Joga para o historico o valor atual desta faixa...                       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BK1->(RecLock("BK1",.T.))
				BK1->BK1_FILIAL := xFilial("BK1")
				BK1->BK1_OPEREA := BK7->BK7_CODINT
				BK1->BK1_CODREA := BK7->BK7_CODREA
				BK1->BK1_CODOPE := BI3->BI3_CODINT
				BK1->BK1_CODPRO := BI3->BI3_CODIGO
				BK1->BK1_VERSAO := BI3->BI3_VERSAO
				BK1->BK1_CODFAI := BRY->BRY_CODFAI
				BK1->BK1_IDAINI := BRY->BRY_IDAINI
				BK1->BK1_IDAFIN := BRY->BRY_IDAFIN
				BK1->BK1_VLRANT := BRY->BRY_VLRADE
				BK1->BK1_VLRREA := nVlrRea
				BK1->BK1_DATREA := dDataBase
				BK1->BK1_PERREA := nIndice
				BK1->BK1_CODFOR := BRY->BRY_CODFOR
				BK1->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o valor em cada faixa etaria da familia...                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BRY->(RecLock("BRY",.F.))
				BRY->BRY_VLRANT := BRY->BRY_VLRADE
				BRY->BRY_ANOMES := cAnoMes
				BRY->BRY_VLRADE := nVlrRea
				BRY->(MsUnLock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acessa proximo registro...                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BRY->(DbSkip())
			Enddo
		Endif

	Endif

	If lFranquia
		For n_ := 1 To Len(aFranquia)
			cAlias := aFranquia[n_][1]

			// Seleciona area
			dbSelectArea(cAlias)
			&(cAlias)->( dbSetorder(aFranquia[n_][2]) )

			// Pesquisa chave
			&(cAlias)->( msSeek(xFilial(cAlias)+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)) )

			// Precessa registros...
			While !(&(cAlias)->(Eof())) .and. &((cAlias)->(aFranquia[n_][3])) == +BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO)

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Apura o valor com o reajuste...                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cCpoFra := cAlias+"->"+aFranquia[n_][4]
				cCpoAms := cAlias+"_ANOMES"
				cCpoVat := cAlias+"_VLRANT"

				nVlrRea := Round(&(cCpoFra) + ((&(cCpoFra)*nIndice)/100),2)

				// Grava historico
				B0B->( Reclock("B0B", .T.) )
					B0B->B0B_ALIAS	:= cAlias
					B0B->B0B_CODREA	:= cCodRea
					B0B->B0B_CODINT	:= BI3->BI3_CODINT
					B0B->B0B_CODPRO	:= BI3->BI3_CODIGO
					B0B->B0B_VERPRO	:= BI3->BI3_VERSAO
					B0B->B0B_VLRANT	:= &(cCpoFra)
					B0B->B0B_VLRREA	:= nVlrRea
					B0B->B0B_PERREA	:= nIndice
					B0B->B0B_DATREA	:= dDataBase
				B0B->( msUnlock() )

				// Reajusta registro recorrente
				Reclock(cAlias, .F.)
					// Grava ano/mes do reajuste.
					If &(cAlias)->(Fieldpos(cCpoAms)) > 0
						&(cCpoAms) := cAnoMes
					Endif

					// Grava o valor atual no campo valor anterior antes de reajustar.
					If &(cAlias)->(Fieldpos(cCpoVat)) > 0
						&(cCpoVat) := &(cCpoFra)
					Endif

					// Aplica o reajuste ao valor da franquia.
					&(cCpoFra) := nVlrRea
				&(cAlias)->( msUnlock() )

				&(cAlias)->( dbSkip() )
			Enddo
		Next
	Endif

	BI3->(DbSkip())
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza transacao...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA102EXC Ё Autor Ё Tulio Cesar       Ё Data Ё 27.04.2004 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Exclui um reajuste de cobranca...                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA102EXC(cCodOpe,cCodRea,lDisplay)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nFor
LOCAL aBK8Regs := {}
LOCAL aBK9Regs := {}
LOCAL aBK1Regs := {}
LOCAL aErros   := {}
LOCAL nCnt
LOCAL aRegB0B  := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia transacao...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes no nivel da produto...                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BK8->(DbSetOrder(2))
If BK8->(DbSeek(xFilial("BK8")+cCodOpe+cCodRea))
   While ! BK8->(Eof()) .And. BK8->(BK8_FILIAL+BK8_OPEREA+BK8_CODREA) == xFilial("BK8")+cCodOpe+cCodRea
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Navega por todos os itens deste reajuste da familia atual...             Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         While ! BK8->(Eof()) .And. BK8->(BK8_FILIAL+BK8_OPEREA+BK8_CODREA) == ;
                                     xFilial("BK8")+cCodOpe+cCodRea
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Exibe mensagem informativa...                                            Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               If lDisplay
                  IncProc("Excluindo Reajuste Produto.. "+BK8->BK8_CODPRO)
               Endif
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Navega por todos os itens deste reajuste da familia atual...             Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               BB3->(DbSetOrder(1))
               If BB3->(DbSeek(xFilial("BB3")+BK8->(BK8_CODOPE+BK8_CODPRO+BK8_VERSAO+BK8_CODFOR+BK8_CODFAI)))
                  BB3->(RecLock("BB3",.F.))
                  BB3->BB3_VALFAI := BK8->BK8_VLRANT
                  BB3->BB3_ANOMES := ""
                  BB3->BB3_VLRANT := 0
                  BB3->(MsUnLock())
               Else
                  aadd(aErros,{"Faixa Etaria "+BK8->BK8_CODFAI+" do produto "+BK8->(BK8_CODPRO)})
               Endif
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Exclui o historico de reajuste desta familia atual...                    Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aadd(aBK8Regs,BK8->(Recno()))
               BK8->(DbSkip())
         Enddo
   Enddo
Endif

For nFor := 1 To Len(aBK8Regs)
    BK8->(DbGoTo(aBK8Regs[nFor]))
    BK8->(RecLock("BK8",.F.))
    BK8->(DbDelete())
    BK8->(MsUnLock())
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes no nivel dos opcionais do produto...                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BK9->(DbSetOrder(2))
If BK9->(DbSeek(xFilial("BK9")+cCodOpe+cCodRea))
   While ! BK9->(Eof()) .And. BK9->(BK9_FILIAL+BK9_OPEREA+BK9_CODREA) == xFilial("BK9")+cCodOpe+cCodRea
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Navega por todos os itens deste reajuste da familia atual...             Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         While ! BK9->(Eof()) .And. BK9->(BK9_FILIAL+BK9_OPEREA+BK9_CODREA) == ;
                                     xFilial("BK9")+cCodOpe+cCodRea
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Exibe mensagem informativa...                                            Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               If lDisplay
                  IncProc("Excluindo Reajuste Opcionais do Produto.. "+BK9->BK9_CODPRO)
               Endif
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Navega por todos os itens deste reajuste da familia atual...             Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               BBV->(DbSetOrder(1))
               If BBV->(DbSeek(xFilial("BBV")+BK9->(BK9_CODOPE+BK9_CODPRO+BK9_VERSAO+BK9_CODOPC+BK9_VEROPC+BK9_CODFOR+BK9_CODFAI)))
                  BBV->(RecLock("BBV",.F.))
                  BBV->BBV_VALFAI := BK9->BK9_VLRANT
                  BBV->BBV_ANOMES := ""
                  BBV->BBV_VLRANT := 0
                  BBV->(MsUnLock())
               Else
                  aadd(aErros,{"Faixa Etaria "+BK9->BK9_CODFAI+" do opcional "+BK9->(BK9_CODPRO)})
               Endif
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Exclui o historico de reajuste desta familia atual...                    Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aadd(aBK9Regs,BK9->(Recno()))
               BK9->(DbSkip())
         Enddo
   Enddo
Endif

For nFor := 1 To Len(aBK9Regs)
    BK9->(DbGoTo(aBK9Regs[nFor]))
    BK9->(RecLock("BK9",.F.))
    BK9->(DbDelete())
    BK9->(MsUnLock())
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os reajustes no nivel dos taxa de adesao do produto...             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BK1->(DbSetOrder(2))
If BK1->(DbSeek(xFilial("BK1")+cCodOpe+cCodRea))
   While ! BK1->(Eof()) .And. BK1->(BK1_FILIAL+BK1_OPEREA+BK1_CODREA) == xFilial("BK1")+cCodOpe+cCodRea
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Navega por todos os itens deste reajuste da familia atual...             Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         While ! BK1->(Eof()) .And. BK1->(BK1_FILIAL+BK1_OPEREA+BK1_CODREA) == ;
                                     xFilial("BK1")+cCodOpe+cCodRea
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Exibe mensagem informativa...                                            Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               If lDisplay
                  IncProc("Excluindo Reajuste Opcionais do Produto.. "+BK1->BK1_CODPRO)
               Endif
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Navega por todos os itens deste reajuste da familia atual...             Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               BRY->(DbSetOrder(2))
               If BRY->(DbSeek(xFilial("BRY")+BK1->(BK1_CODOPE+BK1_CODPRO+BK1_VERSAO+BK1_CODFOR+BK1_CODFAI)))
                  BRY->(RecLock("BRY",.F.))
                  BRY->BRY_VLRADE := BK1->BK1_VLRANT
                  BRY->BRY_ANOMES := ""
                  BRY->BRY_VLRANT := 0
                  BRY->(MsUnLock())
               Else
                  aadd(aErros,{"Faixa Etaria "+BK1->BK1_CODFAI+" do opcional "+BK1->(BK1_CODPRO)})
               Endif
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Exclui o historico de reajuste desta familia atual...                    Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aadd(aBK1Regs,BK1->(Recno()))
               BK1->(DbSkip())
         Enddo
   Enddo
Endif

For nFor := 1 To Len(aBK1Regs)
    BK1->(DbGoTo(aBK1Regs[nFor]))
    BK1->(RecLock("BK1",.F.))
    BK1->(DbDelete())
    BK1->(MsUnLock())
Next

If B0B->( dbSeek(xFilial("B0B")+cCodOpe+cCodRea) )
	While !B0B->( Eof() ) .and. B0B->B0B_CODINT == cCodOpe .and. B0B->B0B_CODREA == cCodRea
		cAlias := B0B->B0B_ALIAS
		If (nPos := AScan(aFranquia,{|x| x[1] == cAlias})) > 0

			&(cAlias)->( dbSetorder(aFranquia[nPos][02]) )
			If &(cAlias)->( dbSeek(xFilial(cAlias)+B0B->(B0B_CODINT+B0B_CODPRO+B0B_VERPRO)) )
				&(cAlias)->( RecLock(cAlias, .F.) )

					If &(cAlias)->( FieldPos(aFranquia[nPos][4]) ) > 0
						&(cAlias+"->"+aFranquia[nPos][4]) 	:= B0B->B0B_VLRANT
					Endif
					If &(cAlias)->( FieldPos(cAlias+"_ANOMES") ) > 0
						&(cAlias+"->"+cAlias+"_ANOMES") 	:= ''
					Endif
					If &(cAlias)->( FieldPos(cAlias+"_VLRANT") ) > 0
						&(cAlias+"->"+cAlias+"_VLRANT") 	:= 0
					Endif

				&(cAlias)->( MsUnlock() )
			Endif
		Endif

		Aadd(aRegB0B, B0B->( Recno() ))
		B0B->( dbSkip() )
	Enddo
Endif

// Deleta o historico do reajuste da franquia...
For nCnt := 1 To Len(aRegB0B)
	B0B->( dbGoto(aRegB0B[nCnt]) )
	If !B0B->( Eof() )
		B0B->( RecLock("B0B", .F.) )
			B0B->( dbDelete() )
		B0B->( MsUnlock() )
	Endif
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui lote de reajuste...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BK7->(RecLock("BK7",.F.))
BK7->(DbDelete())
BK7->(MsUnLock())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza Transacao...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe mensagem caso tenha criticas na exclusao...                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aErros) > 0
   PLSCRIGEN(aErros,{ {"Criticas","@C",300} },"Foi identificada criticas para esta exclusao de reajuste...")
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё26/12/2006Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё		1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Private aRotina := {	{ "Pesquisar"  ,'AxPesqui'  ,0 ,K_Pesquisar		,0 ,.F.},;
											{ "Visualizar" ,'PLSA102Mov',0 ,K_Visualizar	,0 ,Nil},;
											{ "Incluir"    ,'PLSA102Mov',0 ,K_Incluir			,0 ,Nil},;
											{ "Excluir"    ,'PLSA102Mov',0 ,K_Alterar			,0 ,Nil} }
Return(aRotina)
