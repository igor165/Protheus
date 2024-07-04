
// 17/08/2009 -- Filial com mais de 2 caracteres   

#INCLUDE "Ctba176.ch"
#Include "Protheus.Ch"

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctba176  ³ Autor ³ Alexandre Silva       ³ Data ³ 15/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estorno do calculo de "Ajuste por inflacao"                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void Ctba176(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctba176()
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Define vari veis ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpca := 0
Local aSays := {}, aButtons := {}
PRIVATE lArg  := If (cPaisLoc = 'ARG',.T.,.F.)
PRIVATE cCadastro := OemToAnsi(STR0001)    //"Estorno de calculo de Ajuste por inflacion"
#IFDEF TOP
	TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top
#ENDIF

AADD(aSays,OemToAnsi( STR0002 ) ) //"Esta rotina tem como objetivo estornar o ultimo calculo"
AADD(aSays,OemToAnsi( STR0003 ) ) //" de ajuste por inflacao"

AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	DbSelectArea('SIE')
	DbCloseArea()
	If ChkFile("SIE",.T.)
		Processa({|lEnd| Ct176Proc()})
		DbSelectArea('SIE')
		DbCloseArea()
		ChkFile("SIE")          
	Else
		HELP(" ",1,"ArqEmUso",,'SIE',3,4)
	Endif	
EndIf
DbSelectArea('SIE')
DbSetOrder(1)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct176Proc ³ Autor ³ Alexandre Silva       ³ Data ³ 29/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento da rotina                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct176Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ct176Proc()
Local lVoltaSIE 	:= .T.
Local cSequencia	:=	""
Local dDataIni		:=	Ctod('')
Local dDataFim		:=	Ctod('')
Local dDataLAju		:=	Ctod('')
Local nX 			:= 1                                        
Local lRet			:=	.T.
Local aRecnos		:=	{}
Local aCab			:=	{}
Local aTotItem		:=	{}
Local cMes			:=	""

Private lMsErroAuto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar a ultima secuencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SIE')
DbSetOrder(2)
MsSeek(xFilial()+'9999999999',.T.)
DbSkip(-1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar o ultimo ajuste para pegar  ³
//³a sequencia correta.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !BOF() .And. xFilial() == IE_FILIAL .And. !Empty(IE_SEQ)
	cSequencia	:=	IE_SEQ
	dDataFim		:=	Ctod('01/'+StrZero(Month(IE_DTAJUS),2)+'/'+Str(Year(IE_DTAJUS),4)) - 1
	dDataLAju	:=	IE_DTAJUS
Else
	MsgAlert(STR0004) //"Nao foi achado nenhum periodo ajustado para este exercicio"
	lRet	:=	.F.
Endif

If lRet
	MsSeek(xFilial()+cSequencia)
	DbSkip(-1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar  ajuste anterior para informar ao usuario³
	//³o periodo ajustado sendo cancelado.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !BOF() .And. xFilial() == IE_FILIAL .And. !Empty(IE_SEQ)
		dDataIni		:=	Ctod('01/'+StrZero(Month(IE_DTAJUS),2)+'/'+Str(Year(IE_DTAJUS),4))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se a data do ultimo ajuste  ³
	//³pertence ao exercicio atual.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lArg
		If dDataFim < GetNewPar('MV_DTINIAJ',Ctod('')) 
			MsgAlert(STR0004) //"Nao foi achado nenhum periodo ajustado para este exercicio"
			lRet		:=	.F.
		EndIf	
	Else
		If dDataFim < GetNewPar('MV_DATADE',Ctod('')) 
			MsgAlert(STR0004) //"Nao foi achado nenhum periodo ajustado para este exercicio"
			lRet		:=	.F.	
		EndIf		
	Endif
Endif

If !lRet	
	Return .F.
Else
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Verificar se e o unico ajuste do      ³
	  ³ exercicio atual.                     ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lArg   
		dDataIni < GetNewPar('MV_DTINIAJ',Ctod(''))
		dDataIni	:=	GetNewPar('MV_DTINIAJ',Ctod(''))
	Else
		dDataIni < GetNewPar('MV_DATADE',Ctod(''))
		dDataIni	:=	GetNewPar('MV_DATADE',Ctod(''))	
	Endif
	If !MsgYesNo(STR0005 +cSequencia +STR0006+DTOC(dDataIni)+STR0007+DTOC(dDataFim),STR0008) //"Sera cancelado a sequencia de ajuste "###" que compreende os lancamentos entre as datas "###" e "###"Periodo a cancelar"
		Return
	Endif	
Endif
Begin Transaction
DbSelectArea('CT2')
DbSetOrder(13)
DbGoTop()
//DbOrderNickName("CT2ORIGEM")
If DbSeek(xFilial()+cSequencia)
	aCab := {;
				{"dDataLanc",CT2->CT2_DATA	,NIL},;
				{"cLote"	,CT2->CT2_LOTE	,NIL},;
				{"cSubLote"	,CT2->CT2_SBLOTE,NIL},;
				{"cDoc"		,CT2->CT2_DOC   ,NIL};
			}

	While !EOF() .And. Alltrim(cSequencia) == Alltrim(CT2_ORIGEM) .And. dDataIni <= ddatabase
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Adiciono o LINPOS, porque a rotina Ctb102Carr no CTBA102		³
	  ³carrega o arquivo temporario.								³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	 Aadd(aTotItem, {;
			 			{"CT2_LINHA"	,CT2->CT2_LINHA		,NIL},;
						{"LINPOS"		,"CT2_LINHA"		,CT2->CT2_LINHA};
						})
		CT2->(dbSkip())
	Enddo	

	MSExecAuto({|x,y,Z| Ctba102(x,y,Z)},aCab,aTotItem,5) 

	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .F.
	Else
		lVoltaSIE := .T.
	Endif		
Else
	If MsgYesNo(STR0009)
		lVoltaSIE := .T.
	Endif	
EndIf

If lVoltaSIE 	//Limpa o SIE
	DbSelectArea('SIE')
	DbSetOrder(2)
	MsSeek(xFilial()+cSequencia)
	While !Eof() .And. xFilial()+cSequencia == IE_FILIAL+IE_SEQ
		Aadd(aRecnos,SIE->(RECNO()))
		DbSkip()
	Enddo
	
	For nX:=1 To Len(aRecnos)
		MsGoto(aRecnos[nX])
		RecLock('SIE',.F.)
		Replace IE_SEQ	With ''
		Replace IE_DTAJUS	With Ctod('')
		MsUnLock()
	Next
EndIf

End Transaction		

Return .T.