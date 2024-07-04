#include "protheus.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpTerm()³ Autor ³ Juan Jose Pereira     ³ Data ³ 13/03/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Termo de Abertura/Encerramento de Livro            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpTerm(cArquivo,aVariavel,cImpCtrl)                       ³±±
±±³          ³ Parametros:                                                ³±±
±±³          ³ cArquivo=Nome do Arquivo que contem script a ser impresso  ³±±
±±³          ³          XXXXXXXX.XXX                                      ³±±
±±³          ³ aVariavel=Array com                                        ³±±
±±³          ³           {{Variavel no script,Conteudo a Substituir},...} ³±±
±±³          ³ cImpCtrl=Caracter de Controle de Impressao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Cr030ImpCt(cArquivo,aVariavel,cImpCtrl,aAliasCon)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cTermo      :=""
Local aTermo      :={""}
Local i           :=1
Local j           :=1
Local nTamArq     :=0
Local aParametros :={}
Local nLinTermo   :=0
Local nColTermo   :=0
Local CR          := Chr(13)+Chr(10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se arquivo existe                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  Empty(cArquivo) .or. !File(cArquivo)
	Return .f.
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega arquivo                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTerHdl :=FOPEN(cArquivo,2+64)
nTamArq :=FSEEK(nTerHdl,0,2)
xBuffer :=Space(nTamArq)

FSEEK(nTerHdl,0,0)
FREAD(nTerHdl,@xBuffer,nTamArq)

cTermo  :=xBuffer

FCLOSE(nTerHdl)

While   i<=nTamArq
	If Substr(cTermo,i,1)#CR
		aTermo[j]:=aTermo[j]+Substr(cTermo,i,1)
	Else 	
    	AADD(aTermo,"")
		j++
	Endif
	i++
End

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Substitui variaveis                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTamTerm:=Len(aTermo)

nNumPar:=0
aEval(aVariavel,{ |x| IIf(!Empty(x[1]),nNumPar:=nNumPar+1,)})

For i:=1 to nTamTerm
	For j:=1 to nNumPar
		cTipo:=Valtype(aVariavel[j,2])
		Do Case
			Case cTipo=="N"
				cValor:=LTrim(Str(aVariavel[j,2]))
			Case cTipo=="D"
				cValor:=DtoC(aVariavel[j,2])
			Case cTipo=="L"
				cValor:=IIF(aVariavel[j,2],"SIM","NAO")
			Case cTipo=="C"
				cValor:=aVariavel[j,2]
		EndCase	
		aTermo[i]:=StrTran(aTermo[i],aVariavel[j,1],cValor)
	Next
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime termo                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLinTermo:=0
nColTermo:=0

@ nLinTermo, nColTermo PSAY cImpCtrl // Caracter de Controle de Impressao

For i:=1 to nTamTerm
	@ nLinTermo++, nColTermo PSAY aTermo[i]
Next

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RR030Detal³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 24/10/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime as linhas detalhes (AH2) do contrato de royalty    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RR030Detal( ExpN1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - contador de linhas do array de texto do contrato   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ROYR030 - Controle de Royalty                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Cr030Detal(nLin,nTamTerm,nNumPar,aVariavel,aTermo,aAliasCon)
Local nArq, lFirst, lAchouVar
Local j := 0

aTermo[nLin] := ""
nLin++

lFirst := .T.
While nLin <= nTamTerm .And. AllTrim(aTermo[nLin]) != "[FOOTER]" .And. AH2->(!Eof());
	.And. AH2->AH2_FILIAL+AH2->AH2_PRODUT + AH2->AH2_FORNEC + AH2->AH2_LOJAFO == ;
	xFilial("AH2") + AH1->AH1_PRODUT + AH1->AH1_FORNEC + AH1->AH1_LOJAFO

	lAchouVar := .F.
	For nArq := 1 To Len(aAliasCon)
		cVariaAux := aAliasCon[nArq] + "->"
		If At(cVariaAux,aTermo[nLin]) != 0
			lAchouVar := .T.
		Endif
	Next
		
	If lAchouVar      && achou variavel na linha a ser impressa, para substituir

		If At("AH2_PERCRE",Upper(aTermo[nLin])) != 0 .Or. ;
			At("AH2_VALREG",Upper(aTermo[nLin])) != 0
			If lFirst
				lFirst := .F.
			Else
				dbSelectArea("AH2")
				dbSkip()
			Endif
		Endif

		For j:=1 to nNumPar
			cTipo:=Valtype(aVariavel[j,2])
			If At("AH2",aTermo[nLin]) == 0
				Do Case
					Case cTipo=="N"
						cValor:=LTrim(Str(aVariavel[j,2]))
					Case cTipo=="D"
						cValor:=DtoC(aVariavel[j,2])
					Case cTipo=="L"
						cValor:=IIF(aVariavel[j,2],"SIM","NAO")
					Case cTipo=="C"
						cValor:=AllTrim(aVariavel[j,2])
				EndCase	
				aTermo[nLin]:=StrTran(aTermo[nLin],aVariavel[j,1],cValor)
			Else
				cVariaAux := aVariavel[j,1]
				Do Case
					Case cTipo=="N"
						cValor:=LTrim(Str(&(cVariaAux)))
					Case cTipo=="D"
						cValor:=DtoC(&(cVariaAux))
					Case cTipo=="L"
						cValor:=IIF(&(cVariaAux),"SIM","NAO")
					Case cTipo=="C"
						cValor:=AllTrim(&(cVariaAux))
				EndCase	
				aTermo[nLin]:=StrTran(aTermo[nLin],aVariavel[j,1],cValor)
			Endif
		Next
	Endif
	nLin++
End
aTermo[nLin] := ""
nLin++

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CMesAno  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 12/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Verifica se a data digitada eh valida                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CMesAno()
Local lRet := .T.
Local cPeriodo := &(ReadVar())

If 	! "/" $ cPeriodo .Or. At(" ", cPeriodo) > 0 .Or.;
	Val(Left(cPeriodo, 2)) < 1 .Or. Val(Left(cPeriodo, 2)) > 12
	Help(" ",1,"MesAno")
	lRet := .F.
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CdaModelo ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 20/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para visualizacao em formato Modelo 2 ou 3          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CdaModelo(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CdaModelo(cAlias,nReg,nOpc)

Local oDlg, oGetD
Local nOpca 	:=	0
Local nCpoTela	:=	0
Local nOrdSx3 	:=	Sx3->(IndexOrd())
Local cContador	:=	""
Local cCpoMod2  :=	""
Local cAlias1   :=	""
Local cSeek		:=	""
Local cWhile	:=	""

Local lInclui	:=	(nOpc = 3)
Local lAltera	:=	(nOpc = 4)
Local lExclui	:=	(nOpc = 5)
Local lModelo2	:=	(cAlias1 = cAlias)

cAlias1  := If(Type("cAlias1") = "U" .Or. cAlias1 = Nil, cAlias, cAlias1)

If Type("aSize") = "U" .Or. aSize = Nil
	Private aSize		:= MsAdvSize(,.F.,430)
	Private aObjects 	:= {} 
	Private aPosObj  	:= {} 
	Private aSizeAut 	:= MsAdvSize()

	If lModelo2
		AAdd( aObjects, { 315, aPosTela[1][2] + 20, .T., .T. } )
		AAdd( aObjects, { 100, 430 - aPosTela[1][2] - 20, .T., .T. } )
	Else
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 315,  70, .T., .T. } )
	Endif

	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 

	aPosObj := MsObjSize( aInfo, aObjects, lModelo2 ) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
   
IF ! lInclui .And. LastRec() == 0
	Help(" ",1,"A000FI")
	Return (.T.)
Endif  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se esta' na filial correta                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lInclui .And. xFilial(cAlias) != &(cAlias + "_FILIAL")
	Help(" ",1,"A000FI")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE aHeader	:= {}
PRIVATE aCols	:= {}

If ! lModelo2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAltera .Or. lExclui
		SoftLock(cAlias)
	Endif	

	CdaMemory(cAlias,lInclui)
Else
	Private aChaves	:= {}
	SX3->(DbSetOrder(2))
	For nCpoTela := 1 to Len(aPosTela)
		cCpoMod2 += aPosTela[nCpoTela][1] + ";"
		Aadd(aChaves, { aPosTela[nCpoTela][1], "M->" + aPosTela[nCpoTela][1] })

// Bloco CdaMemory

		SX3->(DbSeek(aPosTela[nCpoTela][1]))

		If SX3->X3_CONTEXT = "V" 	// Campo virtual
			If ! Empty(SX3->X3_INIBRW)
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO), &(AllTrim(SX3->X3_INIBRW)))
			Else			
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO), CriaVar(Trim(SX3->X3_CAMPO)))
			Endif
		Else
			If lInclui
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO), CriaVar(Trim(SX3->X3_CAMPO)))
			Else
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO), (cAlias)->&(Trim(SX3->X3_CAMPO)))
			EndIf
		Endif
	Next
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek	:= xFilial("AH4")+AH4->AH4_PRODUT+AH4->AH4_FORNEC+AH4->AH4_LOJAFO+DTOS(AH4->AH4_DATCAL)
cWhile	:= "AH5->AH5_FILIAL+AH5->AH5_PRODUT+AH5->AH5_FORNEC+AH5->AH5_LOJAFO+DTOS(AH5->AH5_DATCAL)"
cAlias1	:= "AH5"
FillGetDados(nOpc,cAlias1,1,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,lInclui)

If !lInclui .AND. ((Type("lSemItens") = "U" .Or. lSemItens = Nil) .Or. !lSemItens)	// Indica se verifica existencia
	If (len(aCols) = 0) .OR. (len(aCols) > 0 .AND. Empty(aCols[1][1]))				// dos itens
		Help(" ",1,"CA10SEMREG")
		Return .T.
	Endif
Endif

If FieldPos(cAlias1 + "_ITEM") > 0
	cContador := "+" + cAlias1 + "_ITEM"
Endif

If Type("cLinhaOk") = "U" .Or. cLinhaOk = Nil
	cLinhaOk := "AllwaysTrue"
Endif

If Type("cTudoOk") = "U" .Or. cTudoOk = Nil
	cTudoOk := "AllwaysTrue"
Endif

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

If ! lModelo2
	EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1], , 3, , , , , , .T. )
Else

	SX3->(DbSetOrder(2))
	For nCpoTela 	:= 1 to Len(aPosTela)
		cCampo		:= aPosTela[nCpoTela][1]
		SX3->(DbSeek(cCampo))
		nX			:= aPosTela[nCpoTela][2]
		nY			:= aPosTela[nCpoTela][3]
		cCaption	:= X3Titulo()
		cPict		:= If(Empty(SX3->X3_PICTURE),Nil,SX3->X3_PICTURE)
		cValid		:= If(Empty(SX3->X3_VALID),".t.",SX3->X3_VALID)
		cF3			:= If(Empty(SX3->X3_F3),NIL,SX3->X3_F3)
		cWhen		:= If(Empty(SX3->X3_WHEN),"(.t.)","(" +;
						 AllTrim(SX3->X3_WHEN) + ")")
		If Len(aPosTela[nCpoTela]) > 3
			cWhen += " .And. (" + aPosTela[nCpoTela][4] + ")"
		Endif
		cBlKSay 	:= "{|| OemToAnsi('"+cCaption+"')}"
		oSay 		:= TSay():New( nX + 1, nY, &cBlkSay,oDlg,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
		nLargSay 	:= GetTextWidth(0,cCaption) / 1.8  // estava 2.2
		cCaption 	:= oSay:cCaption
		cBlkGet 	:= "{ | u | If( PCount() == 0, M->"+cCampo+", M->"+cCampo+":= u ) }"
		cBlKVld 	:= "{|| "+cValid+"}"
		cBlKWhen 	:= "{|| "+cWhen+"}"
		oGet 		:= TGet():New( nX, nY+nLargSay,&cBlKGet,oDlg,,,cPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,(cCampo))
	Next
	
	Sx3->(DbSetOrder(nOrdSx3))
Endif
	
oGetd := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,cLinhaOk,cTudoOk,cContador, .T.)
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGetd:TudoOk(),oDlg:End(),nOpca := 0) }, { || oDlg:End() })

If nOpca = 1 .And. nOpc # 2
	BEGIN TRANSACTION
	
		If nOpc = 5 .And. (Type("cPodeExcluir") = "U" .Or. Empty(cPodeExcluir) .Or.;
			  												     &(cPodeExcluir))
			DelModelo(cAlias, cAlias1)
		ElseIf nOpc # 5
			GrvModelo(cAlias, cAlias1,lInclui)
		Endif

	END TRANSACTION
Endif

dbSelectArea(cAlias)

Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GrvModelo ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 21/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para gravacao em formato Modelo 2 ou 3          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GrvModelo(cPar1, cPar2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpC1 = Alias detalhe do arquivo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GrvModelo(cAlias,cAlias1,lInclui)

Local nCampos, nHeader, nMaxArray, bCampo, aAnterior:={}, nItem := 1
Local lModelo2 := cAlias = cAlias1
Local nChaves := 0   
bCampo := {|nCPO| Field(nCPO) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o ultimo elemento do array esta em branco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMaxArray := Len(aCols)

If ! lModelo2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava arquivo PRINCIPAL ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)

	RecLock(cAlias,lInclui)
   
	For nCampos := 1 TO FCount()
		If "FILIAL"$Field(nCampos)
			FieldPut(nCampos,xFilial(cAlias))
		Else
			FieldPut(nCampos,M->&(EVAL(bCampo,nCampos)))
		EndIf
	Next	
   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega ja gravados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias1)
If ! lInclui .And. MsSeek(xFilial(cAlias1)+&(cChave))
	While !Eof() .And. xFilial(cAlias) + &(cChave1) == xFilial(cAlias1) + &(cChave)
		Aadd(aAnterior,RecNo())
 		dbSkip()
	Enddo
Endif

dbSelectArea(cAlias1)
nItem := 1

For nCampos := 1 to nMaxArray

	If Len(aAnterior) >= nCampos
		If ! lInclui
			DbGoto(aAnterior[nCampos])
		EndIf	
		RecLock(cAlias1,.F.)
	Else 
		RecLock(cAlias1,.T.)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem marcacao para apagar.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If aCols[nCampos][Len(aCols[nCampos])] 
		RecLock(cAlias1,.F.,.T.)
		dbDelete()
	Else 
		For nHeader := 1 to Len(aHeader)
			If aHeader[nHeader][10] # "V" .And. ! "_ITEM" $ AllTrim(aHeader[nHeader][2])
				Replace &(Trim(aHeader[nHeader][2])) With aCols[nCampos][nHeader]
			ElseIf "_ITEM" $ AllTrim(aHeader[nHeader][2])
				Replace &(AllTrim(aHeader[nHeader][2])) With StrZero(nItem ++,;
					Len(&(AllTrim(aHeader[nHeader][2]))))
			Endif
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza as chaves de itens ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aChaves") # "U" .Or. aChaves # Nil
			Replace &(cAlias1 + "_FILIAL") With xFilial(cAlias1)
			For nChaves := 1 To Len(aChaves)
				Replace &(aChaves[nChaves][1]) With &(aChaves[nChaves][2])
			Next
		Endif

		dbSelectArea(cAlias1)
	Endif

Next nCampos

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DelModelo3³ Autor ³ Wagner Mobile Costa   ³ Data ³ 21/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para delecao em formato Modelo 2 ou 3          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DelModelo(cPar1, cPar2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpC1 = Alias detalhe do arquivo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function DelModelo(cAlias,cAlias1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta os itens ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( cAlias1 )
MsSeek(xFilial(cAlias1) + &(cChave))
While !Eof() .And. xFilial(cAlias) + &(cChave1) == xFilial(cAlias1) + &(cChave)
	RecLock(cAlias1,.F.,.T.)
	dbDelete()
	dbSkip()
End

If cAlias # cAlias1    	// Se igual eh modelo 2, ou seja nao tem cabecalho
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.,.T.)
	dbDelete()      		
	dbSelectArea(cAlias)
Endif	

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³vMoeda    ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 03/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a moeda digitada esta em uso              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ vMoeda()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function vMoeda

Local lRet := .T.

If &(ReadVar()) > MoedFin()
	lRet := .F.
	Help(" ",1,"SEMMOEDA")
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CdaPrivate³ Autor ³ Wagner Mobile Costa   ³ Data ³ 03/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Zera as privates para uso da funcao CdaModelo         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CdaPrivate()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CdaPrivate

aSize			:= Nil		// Objeto Bes
cChave			:= Nil		// Chave do arquivo principal
cChave1			:= Nil		// Chave do arquivo detalhe
lSemItens   	:= Nil		// Nao ter itens para aCols
aChaves 		:= Nil		// Campos CHAVES
cLinhaOk		:= Nil		// Verifica da Linha aCols
cTudoOk			:= Nil		// Verifica ao GRAVAR
cPodeExcluir	:= ""		// Verifica se pode ser excluido
cAlias1			:= Nil		// Alias de detalhe se Modelo2 = Nil
aPosTela		:= Nil		// Posicoes dos campos principais modelo 2

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³vPercento ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 04/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o percentual digitado e valido [- e > 100%]    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ vPercento()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function vPercento

Local lRet := .T.

lRet := Positivo()

If lRet .And. &(ReadVar()) > 100.00
	lRet := .F.
	Help(" ",1,"PERC_INV")
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CdaMemory   ³ Autor ³ Wagner Mobile       ³ Data ³ 04/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria variaveis M-> para uso na Enchoice()					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Enchoice												  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CdaMemory(cAlias,lInclui)

SX3->(DbSetOrder(1))
SX3->(MsSeek(cAlias))

While ! SX3->(Eof()) .And. SX3->x3_arquivo == cAlias
	If SX3->X3_CONTEXT = "V" 	// Campo virtual
		If ! Empty(SX3->X3_INIBRW)
			_SetOwnerPrvt(Trim(SX3->X3_CAMPO), &(AllTrim(SX3->X3_INIBRW)))
		Else			
			_SetOwnerPrvt(Trim(SX3->X3_CAMPO), CriaVar(Trim(SX3->X3_CAMPO)))
		Endif
	Else
		If lInclui
			_SetOwnerPrvt(Trim(SX3->X3_CAMPO), CriaVar(Trim(SX3->X3_CAMPO)))
		Else
			_SetOwnerPrvt(Trim(SX3->X3_CAMPO), (cAlias)->&(Trim(SX3->X3_CAMPO)))
		EndIf
	Endif
	SX3->(DbSkip())
EndDo

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CdaPerAnt  ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 05/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o periodo anterior de um parametro tipo data       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ dAnterior := CdaPerAnt(ExpD1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Periodo atual para contagem do periodo anterior    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CdaPerAnt(dPeriodo)

If Month(dPeriodo) = 1
	dPeriodo := LastDay(Ctod("01/12/" + Str(Year(dPeriodo) - 1, 4)))
Else
	dPeriodo := LastDay(Ctod("01/" +;
						StrZero(Month(dPeriodo) - 1, 2) + "/" +;
						Str(Year(dPeriodo), 4)))
Endif		

Return dPeriodo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CdaAtEnchoice ³ Autor ³ Wagner Mobile Costa ³ Data ³ 05/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a tela de enchoice do campo recebido como parametro ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CdaAtEnchoice(ExpU1)                          				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpU1 - String ou matriz com campo(s) para atualizacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCda                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CdaAtEnchoice(uCampo)

Local nEndereco
Local aCampos := If(ValType(uCampo) = "A", uCampo, { uCampo }), nCampos

For nCampos := 1 To Len(aCampos)
	nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == aCampos[nCampos] } )
	If nEndereco > 0
		aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := &("M->" + aCampos[nCampos])
	EndIf
nEXT
lRefresh := .T.

Return (.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CdDtInPres   ³ Autor ³ Cristiano G. Cunha  ³ Data ³ 22/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Data de Calculo do Contrato                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CdDtInPres(ExpC1,ExpC2,ExpC3,ExpD1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Produto                                   ³±±
±±³          ³ ExpC2 - Codigo do Fornecedor                                ³±±
±±³          ³ ExpC3 - Loja do Fornecedor                                  ³±±
±±³          ³ ExpD1 - Data de Vencimento do Contrato                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACDA                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CdDtInPres(cCodAH4,cForAH4,cLjFAH4,dDtPres)

Local dDatCal  := CTOD(SPACE(08))
Local aAreaAH4 := AH4->(GetArea())

dbSelectArea("AH4")
dbSetOrder(3)

If dbSeek(xFilial("AH4")+cCodAH4+cForAH4+cLjFAH4+DTOS(dDtPres))
	//dDatCal := AH4->AH4_DATCAL
	dDatCal := AH4->AH4_DTULTI
EndIf

RestArea(aAreaAH4)

Return (dDatCal)

/* 
Esta funcao corrige um problema no campo
X3_WHEN do SX3 (AH1_CLIFOR e AH1_LOJA)
(erro de funcao nao compilada)
*/
   
Function CA010Convenc()
Return .T.

/* 
Esta funcao corrige um problema no campo X2_ROTINA
do SX2 (AH1)
(erro de funcao nao compilada)
*/
Function CA010TipoL()
Return .T.
