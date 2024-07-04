
#INCLUDE "Plsa760.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

STATIC cMsgErro := ""
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA760 ³ Autor ³ Tulio Cesar            ³ Data ³ 22.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Gerar cobranca para determinada familia.                   ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA760()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±|18/01/01  |      | Michele     |Alteracao feita para a geracao de      |±±±
±±|          |      |             |titulo no Mes 02 .                     |±±±
±±|19/02/01  |      | Tulio/Michel|Alteracao na hora de montar a data de  |±±±
±±|          |      |             |vencimento considerando o mes 02.      |±±±
±±|10/04/02  |      | Tulio       |Versao 7.10                            |±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA760(cMatric,cAno,cMes,lPrnBol,cBanco,cOrig,cNivel,dEmissao,dVencto,aVlrCob,lMsg,lCompra,cCodCli,cLoja,cSituac,cPrefixo,cNumero,lWeb,nValComp,nVlrCon)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBA3 := BA3->(IndexOrd())
LOCAL nRecBA3 := BA3->(Recno())
LOCAL aAux    := {}
LOCAL cCodFor
LOCAL cLojFor
LOCAL cConEmp
LOCAL cTipo
LOCAL aVlrCon
LOCAL aVlrAux
LOCAL aRetorno
LOCAL cNatureza := ''
LOCAL cCodInt	:= ''
LOCAL bGerRec  	:= { || PLGERREC(aAux[1],;
								 aAux[2],;
								 cMatric,;
								 cMes,;
								 cANo,;
								 dVencto,;
								 M->BDC_NUMERO,;
								 IIF(BE4->BE4_PAGATO == "1" .AND. nValComp > 0, nValComp,nVlrCon),;
								 aAux[3],;
								 cCodCli,;
								 cLoja,;
								 cTipo,;
								 aVlrCon,;
								 "4",;
								 NIL,;
								 NIL,;
								 NIL,;
								 0,;
								 NIL,;
								 NIL,;
								 cBanco,;
								 cSituac,;
								 cNatureza,;
								 NIL,;
								 cOrig,;
								 cTipoPag,;
								 cPortado,;
								 cAgePor,;
								 cCCPor,;
								 cBcoCli,;
								 cAgeCli,;
								 cCCCli,;
								 dEmissao,;
								 NIL,;	
								 NIL,;	
								 NIL,;	
								 NIL,; 	
								 NIL,;
								 cCodInt)}

Local cNumCob  	:= "00000000"		// Cobranca automatica de pessoa fisica
Local nOpc		:= 0
Local lVisCob	:= .F.
Local nValor    := 0
LOCAL cTipoPag	:= ''
LOCAL cPortado	:= ''
LOCAL cAgePor	:= ''
LOCAL cCCPor	:= ''
LOCAL cBcoCli	:= ''
LOCAL cAgeCli	:= ''
LOCAL cCCCli	:= ''
LOCAL oFont
LOCAL oSay
LOCAL oSay1
LOCAL oSay2
LOCAL oSay3
LOCAL oDlg
LOCAL lOk		:= .T.
DEFAULT lPrnBol	:= .T.
DEFAULT cNivel 	:= '4'
DEFAULT dEmissao:= dDataBase
DEFAULT dVencto := PLMontVen(BA3->BA3_VENCTO,cMes,cAno)
DEFAULT aVlrCob := {}
DEFAULT lMsg    := .F.
DEFAULT lCompra := .F.
DEFAULT cCodCli := ""
DEFAULT cLoja   := ""
DEFAULT cSituac := "1"   
DEFAULT cPrefixo:=""
DEFAULT cNumero :=""
DEFAULT lWeb    := .F.
Default nValComp := 0
Default nVlrCon	:= 0

PRIVATE lGrid    	:= .F.

cMsgErro := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustes no dicionario...                                                 ³
//³ Caso o indice 19 da tabea BEAJ nao tenha cido criada nao deixa o sistema ³
//³ processeguir, alteracao requisita e aprovado pelo Tulio.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! CheckBEAIndex("BEAJ")
	Return .F.	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega numero e prefixo do titulo...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCompra
	aAux    := PLSA625MDa(cAno,cMes,"1",cOrig,nil,cNivel)
Else
	aAux    := {cPrefixo,cNumero,""}
Endif 
If GetNewPar('MV_PLSEMIS','1') =='1'
	
	SE1->( dbSetorder(01) )
	SE1->( dbSeek(xFilial("SE1")+aAux[1]+'999999',.T.) )
	SE1->( dbSkip(-1) )
	If SE1->E1_PREFIXO == aAux[1]
		If dEmissao < SE1->E1_EMISSAO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define fontes utilizadas somente nesta funcao...                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Define FONT oFont NAME "Courier New" Size 0,-10 BOLD
			
			dEmissao := SE1->E1_EMISSAO
			DEFINE DIALOG oDlg TITLE "Data de emissão"   FROM 008,006 TO 018,65
			@ 015,	005 Say oSay  PROMPT "A data do sistema não poderá ser utilizada como data de emissão do titulo, porque já existe(m) " SIZE 500,010 OF oDlg PIXEL
			@ 025,	005 Say oSay1 PROMPT "titulo(s) no contas a receber com prefixo "+aAux[1]+" com a data de emissão do dia "+dToc(SE1->E1_EMISSAO)+'.'	SIZE 500,010 OF oDlg PIXEL
			
			@ 035,	005 Say oSay2 PROMPT "Informe no campo abaixo, uma nova data de emissão para o titulo a receber."	SIZE 500,010 OF oDlg	PIXEL
			@ 045, 	005 SAY oSay3 PROMPT "Data de emissão"		SIZE 100,010 OF oDlg PIXEL
			@ 045, 	050 MSGet dEmissao PICTURE "@!" Size 40,10 	Valid( A720DVAL(aAux[1], dEmissao) )	OF oDlg PIXEL
			
			ACTIVATE DIALOG oDlg CENTERED ON INIT Eval( { || EnchoiceBar(oDlg,	{|| If(lOk := A720DVAL(aAux[1], dEmissao), oDlg:End(), .F.)},;
			{||lOk := .F., oDlg:End()} ,.F.,{}) } )
			
			If !lOk
				MsgStop("Processo abortado. Data de emissão inválida!")
				Return(.F.)
			Endif
		Endif
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na familia informada...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(1))

If ! BA3->(DbSeek(xFilial("BA3")+cMatric))
   BA3->(DbSetOrder(nOrdBA3))
   BA3->(DbGoTo(nRecBA3))
   Help("",1,"PLSA76002")
   Return .F.
Endif     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Grupo/Empresa...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BG9->(DbSetOrder(1))
If BG9->(DbSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
   If BG9->BG9_TIPO == "2"
      BT5->(DbSetOrder(1))                                       
      If ! BT5->(DbSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))
         Return .F.
      Endif
   Endif                                                              
Else
   Return .F.
Endif      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se pode cobrar familia direto...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lCompra
   If BA3->BA3_COBNIV <> "1"
	  If !lMsg
	     MsgInfo(STR0004) //"Geracao de titulo para este familia permitido somente na opcao 'Lotes de Cobranca' em faturamento"
	  Else
	     cMsgErro := STR0004
	  Endif
      Return .F.
   Endif
Endif   

If Len(aVlrCob) > 0
	aVlrCon	 := aClone(aVlrCob[1][2])
Else
	aVlrAux  := PLSVLRFAM(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),cAno,cMes) [1]
	aVlrCon  := aClone(aVlrAux[2])
Endif

If Len(aVlrCob) == 0 .and. ! aVlrAux[1]
   	If !lMsg
		MsgInfo(STR0005) //"Nao foi possivel obter o Valor da familia "
	Else
	   cMsgErro := STR0005
	Endif
	Return .F.                                          
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor total da familia...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aVlrCon,{|x| IF(!x[9],nVlrCon := IF(x[1]=="1",nVlrCon+x[2],If(x[1]=="2",nVlrCon-x[2],nVlrCon)),nil) })

If Empty(cCodCli)
   cCodCli  	:= BA3->BA3_CODCLI
   cLoja    	:= BA3->BA3_LOJA
Endif   

cCodFor  	:= BA3->BA3_CODFOR
cLojFor  	:= BA3->BA3_LOJFOR
cConEmp  	:= BA3->BA3_CONEMP
cTipo    	:= BG9->BG9_TIPO
cCodInt		:= BA3->BA3_CODINT

If BA3->( FieldPos("BA3_TIPPAG") ) > 0
	cTipoPag	:= BA3->BA3_TIPPAG
	cPortado	:= BA3->BA3_PORTAD
	cAgePor		:= BA3->BA3_AGEDEP
	cCCPor		:= BA3->BA3_CTACOR
	cBcoCli		:= BA3->BA3_BCOCLI
	cAgeCli		:= BA3->BA3_AGECLI
	cCCCli		:= BA3->BA3_CTACLI
Endif

If nVlrCon < 0
   nVlrCon  := ABS(nVlrCon)
Endif

BEGIN TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incrementado regra de busca de natureza...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNatureza := A627BusNat(BG9->BG9_TIPO,BA3->BA3_NATURE,(cCodCli+cLoja),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o retorno seja diferente de "1" gravo no arquivo de criticas.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! BDC->(DbSeek(xFilial("BDC") + BA3->BA3_CODINT + cNumCob))
	Copy "BDC" TO Memory Blank
	M->BDC_TIPO := Iif(BA3->BA3_TIPOUS == '1', '2', '1')
	M->BDC_MESINI := cMes
	M->BDC_MESFIM := cMes
	M->BDC_ANOINI := cAno
	M->BDC_ANOFIM := cAno  
	M->BDC_NUMERO := PLSA625Num()
	M->BDC_DTEMIS := dEmissao
	nOpcX := 3
Else
	Copy "BDC" TO Memory
	If cAno + cMes > BDC->BDC_ANOFIM + BDC->BDC_MESFIM 
		M->BDC_MESFIM := cMes
		M->BDC_ANOFIM := cAno
	ElseIf cAno + cMes < BDC->BDC_ANOINI + BDC->BDC_MESINI 
		M->BDC_MESINI := cMes
		M->BDC_ANOINI := cAno
	Endif
	nOpcX := 4
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guia gerada pelo Portal marca como eletronica                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lWeb
    M->BDC_USUOPE := "ELETRONICA"
EndIf

aRetorno := Eval(bGerRec)

If 	aRetorno[1][1]
	M->BDC_CONGER 	:= 1
	nValor          := aRetorno[1][4]
	M->BDC_VALOR	:= nValor
	SE1->( dbSetorder(01) ) 
	SE1->( dbSeek(xFilial("SE1")+aAux[1]+aAux[2],.T.) )	
Else
	M->BDC_CONCRI	:= 1             
	nValor          := aRetorno[1][4]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o lote de faturamento...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->BDC_HORAF := Time()
PLUPTENC("BDC",nOpcX)    
BDC->( ConfirmSX8() )           

If ExistBlock("PL760BDC")
   ExecBlock("PL760BDC",.F.,.F.)
Endif
	
PLSA625Cri(M->BDC_NUMERO,nValor,aRetorno,BA3->BA3_CODINT,;
BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
BA3->BA3_VERSUB, BA3->BA3_MATRIC,GETMV("MV_PLCDTGP"),"4",cAno,cMes,.F.)

END TRANSACTION

If  aRetorno[1][1] 
	BA3->(RecLock("BA3"))
		BA3->BA3_CARIMP := "1"		// Flag da utilizacao da opcao
	BA3->(MsUnLock())

	If 	lPrnBol .And. ! Empty(cCodCli) .And.;
		MsgYesNo(STR0003+TransForm(aRetorno[1][4],"@E 999,999.99"), STR0006) //"Deseja imprimir o boleto ?"
		If Existblock("PLSBOL")
			U_PLSBOL(cCodCli, cLoja, cCodCli, cLoja,;
					BA3->BA3_CODINT, BA3->BA3_CODINT, BA3->BA3_CODEMP, BA3->BA3_CODEMP,;
					Space(Len(BA3->BA3_CONEMP)), Replicate("Z", Len(BA3->BA3_CONEMP)),;
					Space(Len(BA3->BA3_SUBCON)), Replicate("Z", Len(BA3->BA3_SUBCON)),;
					BA3->BA3_MATRIC, BA3->BA3_MATRIC, cMes, cAno, cMes, cAno, 2, 1)
		Else
			PLSR580(cCodCli, cLoja, cCodCli, cLoja,;
					BA3->BA3_CODINT, BA3->BA3_CODINT, BA3->BA3_CODEMP, BA3->BA3_CODEMP,;
					Space(Len(BA3->BA3_CONEMP)), Replicate("Z", Len(BA3->BA3_CONEMP)),;
					Space(Len(BA3->BA3_SUBCON)), Replicate("Z", Len(BA3->BA3_SUBCON)),;
					BA3->BA3_MATRIC, BA3->BA3_MATRIC, cMes, cAno, cMes, cAno, 2, 1)
		Endif
	ElseIf Empty(cCodCli)
	   	If !lMsg
			MsgYesNo(STR0003+TransForm(aRetorno[1][4],"@E 999,999.99"), STR0007) //"Valor Gerado"
		Else
		    cMsgErro := STR0003+TransForm(aRetorno[1][4],"@E 999,999.99")
		Endif
	Endif
    
    lVisCob := .F. // MsgYesNo(STR0003+TransForm(aRetorno[1][3],"@E 999,999.99"), "Deseja visualizar lote ?") //"Titulo Gerado no valor de "
Else
	If lWeb
		lVisCob := .F.
	else
	   	If !lMsg
			lVisCob := MsgYesNo(STR0001+CHR(13)+CHR(13)+STR0002+aRetorno[1][3], STR0008) //"Titulo Nao Gerado"###"Motivo: " //"Deseja visualizar criticas ?"
		Else
			cMsgErro := STR0001+CHR(13)+CHR(13)+STR0002+aRetorno[1][3]
		Endif
	EndIf
Endif
If lVisCob
	PL627MOV("BDC", BDC->(Recno()), 2)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvos...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(nOrdBA3))
BA3->(DbGoTo(nRecBA3))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return aRetorno[1][1]
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA760GER ³ Autor ³ Helio F. R Lecchi   ³ Data ³ 07.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a critica na geracao do Titulo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Mensagem / critica na geracao do titulo					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA760GER()
Return(cMsgErro)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA760   ºAutor  ³Microsiga           º Data ³  07/25/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                
Static Function A720DVAL(cPrefix, dEmiss)
Local lRet := .T.
            
If Empty(cPrefix)
	MsgStop("Data de emissão inválida. informe uma data de emissão vávlida!")
	lRet := .F.
Endif

If lRet
	SE1->( dbSetorder(01) )
	SE1->( dbSeek(xFilial("SE1")+cPrefix+'999999',.T.) )
	SE1->( dbSkip(-1) )
	If SE1->E1_PREFIXO == cPrefix
		If dEmiss < SE1->E1_EMISSAO
			MsgStop("Data de emissão invalida. Informe uma data de emissão superior a data do ultimo titulo do prefixo "+cPrefix+" no contas a receber.")
			lRet := .F.
		Endif
	Endif
Endif

Return(lRet)
