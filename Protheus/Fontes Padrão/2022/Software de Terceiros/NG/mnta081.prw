#INCLUDE "MNTA081.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MNTA081  � Autor � Felipe N. Welter      � Data � 30/01/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que permite cadastrar automaticamente manutencoes ���
���          �	para um bem que tenha manutencao padrao para a mesma Fami- ���
���          �	lia (e Tipo Modelo) cadastrados.                           ���
�������������������������������������������������������������������������Ĵ��
���Tabelas   �TQR - Tipo Modelo             ST4 - Servicos de Manutencao  ���
���          �ST6 - Familia de Bens         ST9 - Bem                     ���
���          �STF - Manutencao              TPF - Manutencao Padrao       ���
���          �ST5 - Tarefas da Manutencao   TP5 - Tarefas da Man. Padrao  ���
���          �STM - Dependencias da Manu.   TPM - Depend. da Man. Padrao  ���
���          �STG - Detalhes da Manutenc.   TPG - Detalh. da Man. Padrao  ���
���          �STH - Etapas da Manutencao    TPH - Etapas da Manu. Padrao  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�	Array aVet:                              - Nao Obrigatorio ���
���          �	aVet[1] - Codigo do Bem                                    ���
���          �	aVet[2] - Codigo da Familia                                ���
���          �	aVet[3] - Codigo do Tipo Modelo                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �	lRet081 (.T./.F.) - Encontrou manutencoes padrao ?         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA081(aVet)

Local aNGBEGINPRM := NGBEGINPRM()
Local aArea := GetArea()
Local lRet := .F.
Local lRet081 := .T.
Local lRel12133 := GetRpoRelease() >= '12.1.033'
Local lTemManut := .F.
Local cDesMod   := ''

//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 							  �
//�������������������������������������������������������������������������

Local aOldMenu
Local aNGCAD02 := {}
Local oTmpTbl
Private asMenu
Private cAliasTmp

aNGBUTTON := {}
SETKEY(VK_F11, {|| MNTA081VIS((cAliasTmp)->SERVIC,(cAliasTmp)->SEQREL) })

//Variaveis para montagem de tela ou validacao
Private oDlgC
Private oMenu
Private aVETINR := {}
Private cCadastro
Private cMARCA := GetMark()
Private oFont11B := TFont():New("Arial",-11,-11,,.T.,,,,.F.,.F.)
Private oFont10N := TFont():New("Arial",-10,-10,,.F.,,,,.F.,.F.)
Private lGFrota  := IIf( FindFunction('MNTFrotas'), MNTFrotas(), GetNewPar('MV_NGMNTFR','N') == 'S' ) // Utiliza Frotas
Private lTipMod  := ( lRel12133 .Or. lGFrota ) .And. NGCADICBASE('T9_TIPMOD','A','ST9')[1]


//Variaveis parametros
Private cCodFami := ""
Private cTipMod  := ""
Private cCodBem  := ""

If	aVet <> NIL
	cCodBem  := aVet[1]
	cCodFami := aVet[2]
	If lTipMod
		cTipMod  := aVet[3]
	EndIf
Else
	cCodBem  := M->T9_CODBEM
	cCodFami := M->T9_CODFAMI
	If lTipMod
		cTipMod  := M->T9_TIPMOD
	EndIf
EndIf

//Variaveis Indices
If lTipMod
   nIdTPF  := 4
   nIdTP5  := 3
   nIdTPM  := 2
   nIdTPG  := 3
   nIdTPH  := 6
Else
   nIdTPF  := 1
   nIdTP5  := 1
   nIdTPM  := 1
   nIdTPG  := 1
   nIdTPH  := 1
EndIf

Dbselectarea("TPF")
Dbsetorder(nIdTPF)

If lRel12133
	lTemManut := MNTSeekPad( 'TPF', 4, cCodFami, cTipMod )
	cTipMod   := TPF->TPF_TIPMOD
Else
	lTemManut := dbSeek(xFilial("TPF")+cCodFami+cTipMod)
EndIf

If lTemManut
	If lTipMod
		cMsg := STR0001 //"Existem manuten��es padr�o para a Fam�lia e Tipo Modelo cadastrados."
	Else
		cMsg := STR0002 //"Existem manuten��es padr�o para a Fam�lia cadastrada."
	EndIf

	lRet := APMSGYESNO(cMsg+CHR(13)+STR0003) //"Deseja seleciona-las para incorporar ao cadastro de manuten��o?"

	If lRet

		aDBFC := {}
		Aadd(aDBFC,{"OK"     ,"C", 02,0})
		Aadd(aDBFC,{"SERVIC" ,"C", TAMSX3("TPF_SERVIC")[1],TAMSX3("TPF_SERVIC")[2]})
		Aadd(aDBFC,{"SEQREL" ,"C", TAMSX3("TPF_SEQREL")[1],TAMSX3("TPF_SEQREL")[2]})
		Aadd(aDBFC,{"NOMSER" ,"C", TAMSX3("TPF_NOMSER")[1],TAMSX3("TPF_NOMSER")[2]})
		Aadd(aDBFC,{"NOMEMA" ,"C", TAMSX3("TPF_NOMEMA")[1],TAMSX3("TPF_NOMEMA")[2]})
		Aadd(aDBFC,{"CODARE" ,"C", TAMSX3("TPF_CODARE")[1],TAMSX3("TPF_CODARE")[2]})
		Aadd(aDBFC,{"TIPO"   ,"C", TAMSX3("TPF_TIPO")[1],TAMSX3("TPF_TIPO")[2]})
		Aadd(aDBFC,{"TIPACO" ,"C", TAMSX3("TPF_TIPACO")[1],TAMSX3("TPF_TIPACO")[2]})
		Aadd(aDBFC,{"DESACO" ,"C", 15,0})
		Aadd(aDBFC,{"VARIA"  ,"C", 15,0})
		Aadd(aDBFC,{"DTULTMA","D", TAMSX3("TF_DTULTMA")[1],TAMSX3("TF_DTULTMA")[2]})
		Aadd(aDBFC,{"CONMANU","N", TAMSX3("TF_CONMANU")[1],TAMSX3("TF_CONMANU")[2]})
		Aadd(aDBFC,{"CALEND" ,"C", TAMSX3("TF_CALENDA")[1],TAMSX3("TF_CALENDA")[2]})
		Aadd(aDBFC,{"CALTPF" ,"C", TAMSX3("TF_CALENDA")[1],TAMSX3("TF_CALENDA")[2]})

		vINDC  := {"SERVIC","SEQREL"}
		cAliasTmp := GetNextAlias()
		oTmpTbl		:= FWTemporaryTable():New( cAliasTmp, aDBFC )
		oTmpTbl:AddIndex( "Ind01" , vINDC )
		oTmpTbl:Create()

		dbSelectArea("TPF")
		dbSetOrder(nIdTPF)
		dbSeek(xFilial("TPF")+cCodFami+cTipMod)

		If lTipMod
			cCondicao := 'TPF->TPF_FILIAL = xFilial("TPF") .And. TPF->TPF_CODFAM == cCodFami .And. TPF->TPF_TIPMOD == cTipMod'
		Else
			cCondicao := 'TPF->TPF_FILIAL = xFilial("TPF") .And. TPF->TPF_CODFAM == cCodFami'
		EndIf

		While !Eof() .And. &(cCondicao)

			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(dbAppend())
            (cAliasTmp)->SERVIC := TPF->TPF_SERVIC
			(cAliasTmp)->SEQREL := TPF->TPF_SEQREL
			(cAliasTmp)->NOMSER := NGSEEK("ST4",TPF->TPF_SERVIC,1,"T4_NOME")
			(cAliasTmp)->NOMEMA := TPF->TPF_NOMEMA
			(cAliasTmp)->CODARE := TPF->TPF_CODARE
			(cAliasTmp)->TIPO   := TPF->TPF_TIPO
			(cAliasTmp)->TIPACO := TPF->TPF_TIPACO
			(cAliasTmp)->CALEND := TPF->TPF_CALEND
			(cAliasTmp)->CALTPF := TPF->TPF_CALEND
			If TPF->TPF_TIPACO $ "T/A"
				If TPF->TPF_TIPACO $ "T"
					(cAliasTmp)->DESACO := STR0004 //"Tempo"
					(cAliasTmp)->VARIA := AllTrim(STR(TPF->TPF_TEENMA))+" "+TPF->TPF_UNENMA
				ElseIf TPF->TPF_TIPACO $ "A"
					(cAliasTmp)->DESACO := STR0005 //"Tempo/Contador"
					(cAliasTmp)->VARIA := AllTrim(STR(TPF->TPF_TEENMA))+" "+TPF->TPF_UNENMA+" / "+AllTrim(STR(TPF->TPF_INENMA))
				EndIf
			ElseIf TPF->TPF_TIPACO $ "C/P/F/S"
				If TPF->TPF_TIPACO $ "C"
					(cAliasTmp)->DESACO := STR0006 //"Contador"
				ElseIf TPF->TPF_TIPACO $ "P"
					(cAliasTmp)->DESACO := STR0007 //"Producao"
				ElseIf TPF->TPF_TIPACO $ "F"
					(cAliasTmp)->DESACO := STR0008 //"Contador Fixo"
				ElseIf TPF->TPF_TIPACO $ "S"
					(cAliasTmp)->DESACO := STR0009 //"Seg. Contador"
				EndIf
				(cAliasTmp)->VARIA := AllTrim(STR(TPF->TPF_INENMA))
			EndIf

			dbSelectArea("TPF")
			dbSkip()

		EndDo

		aTRBC := {}
		Aadd(aTRBC,{"OK"    ,NIL," ",})
		Aadd(aTRBC,{"SERVIC",NIL,STR0010}) //"Servico"
		Aadd(aTRBC,{"SEQREL",NIL,STR0011}) //"Seq."
		Aadd(aTRBC,{"NOMSER",NIL,STR0012}) //"Nome"
		Aadd(aTRBC,{"NOMEMA",NIL,STR0013}) //"Nome Manutencao"
		Aadd(aTRBC,{"CODARE",NIL,STR0014}) //"Area"
		Aadd(aTRBC,{"TIPO"  ,NIL,STR0015}) //"Tipo"
		Aadd(aTRBC,{"DESACO",NIL,STR0016}) //"Acompanha."
		Aadd(aTRBC,{"VARIA", NIL,STR0017}) //"Increm./Freq."

		DEFINE MSDIALOG ODlgC TITLE STR0018 From 6.5,0 To 30,90 OF oMainWnd //"Manutenc�o Padrao"

		oDlgC:lEscClose := .F.

		oMark := MsSelect():New((cAliasTmp),"OK",,aTRBC,,@cMarca,{60,1,177,355})
		oMark:oBrowse:bLDblClick := { || MNT081Mark() }
		oMark:oBrowse:bAllMark := {||M081MarkAll() }

		@ 01.1,0.5 TO 4.1,44.0 OF oDlgC

		If lTipMod

			cDesMod := If( lRel12133, MNTDesTpMd( cTipMod ), NGSEEK("TQR",cTipMod,1,"TQR_DESMOD") )

			@ 01.7,01 Say STR0019 Font oFont11B OF oDlgC //"Bem: "
			@ 01.7,07 Say AllTrim(cCodBem)+" - "+NGSEEK("ST9",cCodBem,1,"T9_NOME") OF oDlgC
			@ 02.5,01 Say STR0020 Font oFont11B OF oDlgC //"Familia: "
			@ 02.5,07 Say AllTrim(cCodFami)+" - "+NGSEEK("ST6",cCodFami,1,"T6_NOME") OF oDlgC
			@ 03.3,01 Say STR0021 Font oFont11B OF ODlgC //"Tipo Modelo: "
			@ 03.3,07 Say AllTriM(cTipMod)+" - "+cDesMod OF oDlgC

		Else
			@ 02.2,01 Say STR0019 Font oFont11B OF oDlgC //"Bem: "
			@ 02.2,05 Say AllTriM(cCodBem)+" - "+NGSEEK("ST9",cCodBem,1,"T9_NOME") OF oDlgC
			@ 03.0,01 Say STR0020 Font oFont11B OF oDlgC //"Familia: "
			@ 03.0,05 Say AllTrim(cCodFami)+" - "+NGSEEK("ST6",cCodFami,1,"T6_NOME") OF oDlgC
		EndIf

		@ 03.7,38 Say STR0022 Font oFont10N OF oDlgC //"(F11) - Visualizar"

		dbSelectArea(cAliasTmp)
		dbGotop()

		NGPOPUP(asMenu,@oMenu)
		oDlgC:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlgC)}

		ACTIVATE MSDIALOG ODlgC ON INIT EnchoiceBar(ODlgC,{||If(MNTA081OK(),ODlgC:End(),)},;
		{||If(APMSGYESNO(STR0023),ODlgC:End(),)}) CENTERED //"Deseja cancelar esse processo?"

	EndIf

Else
   lRet081 := .F.
EndIf

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
//�������������������������������������������������������������������������
RestArea(aArea)

If lRet
	oTmpTbl:Delete()
EndIf

NGRETURNPRM(aNGBEGINPRM)

Return lRet081

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT081Mark � Autor �Felipe N. Welter      � Data � 30/01/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao chamada no duplo clique em um elemento no browse     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA081                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MNT081Mark()

nReg := Recno()
If !(IsMark('OK',cMarca))
	If MNT081INF()
		RecLock((cAliasTmp),.F.)
		(cAliasTmp)->OK := cMarca
		MsUnLock(cAliasTmp)
	EndIf
Else
	RecLock((cAliasTmp),.F.)
	(cAliasTmp)->OK := Space(02)
	MsUnLock(cAliasTmp)
Endif

dbGoTo(nReg)
oMark:oBrowse:Refresh()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT081INF  � Autor �Felipe N. Welter      � Data � 02/01/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Solicita que informe data/contador da ultima manutencao     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA081/MNT081Mark                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT081INF()

Local oDlgS
Local lSai := .F.
Local lCalVazio := If(Empty((cAliasTmp)->CALTPF),.t.,.f.)
Local aAltVar := {}

Private oFont := TFont():New("Arial",,14,,.T.,,,,.F.,.F.)

dbSelectArea(cAliasTmp)
Private dData := If(!Empty((cAliasTmp)->DTULTMA),(cAliasTmp)->DTULTMA,CTOD("  /  /    "))
Private nContador := If(!Empty((cAliasTmp)->CONMANU),(cAliasTmp)->CONMANU,0)
Private cCalendTPF := If(!Empty((cAliasTmp)->CALEND),(cAliasTmp)->CALEND,Space(Len((cAliasTmp)->CALEND)))

If !((cAliasTmp)->TIPACO $ "T")

	DEFINE MSDIALOG oDlgS TITLE STR0024  From 6,0 To 16,53 OF oDlgC //"�ltima Manuten��o"

	oDlgS:lEscClose := .F.

	@ 00,00 SCROLLBOX oScr VERTICAL SIZE 91,215 OF oDlgS BORDER
    @ 08,05 SAY STR0024+" - "+AllTrim(cCodBem)+" - "+SubStr(NGSEEK("ST9",cCodBem,1,"T9_NOME"),1,20);
      +" "+(cAliasTmp)->SERVIC+" "+(cAliasTmp)->SEQREL Of oScr Pixel Font oFont //"�ltima Manuten��o"
	@ 25,05 SAY STR0025 Of oScr Pixel //"Data:"
	@ 25,40 MsGet dData Size 45,08 Pixel Of oScr Picture '99/99/99' Valid naovazio() .And. NGCPDIAATU(dData,"<=",.T.,.T.,.T.) .And. VLDATAULTM()
	@ 38,05 SAY STR0026 Of oScr Pixel //"Contador:"
	@ 38,40 MsGet nContador Size 49,08 Pixel Of oScr Picture "@E 999,999,999,999";
			Valid ( nContador > 0 ) .And. naovazio( nContador ) .And. Positivo()
 	If lCalVazio
		@ 51,05 SAY STR0029 Of oScr Pixel //"Calend�rio"
		@ 51,40 MSGET cCalendTPF SIZE 25,07 OF oDlgS PIXEL PICTURE '@!' F3 "SH7";
		   	VALID naovazio() .And. Existcpo("SH7",cCalendTPF)
 	Endif
	DEFINE SBUTTON FROM 60,180 TYPE 1 ENABLE OF oScr ACTION ;
		EVAL({||lSai := .T.,If((dData <= dDataBase .And. nContador > 0 .And. If(!lCalVazio,.t.,If(Empty(cCalendTPF),.f.,.t.))),oDlgS:End(),lSai := .F.)})
Else

	DEFINE MSDIALOG oDlgS TITLE STR0024  From 6,0 To 14,53 OF oDlgC //"�ltima Manuten��o"

	oDlgS:lEscClose := .F.

	@ 00,00 SCROLLBOX oScr VERTICAL SIZE 91,215 OF oDlgS BORDER
    @ 08,05 SAY STR0024+" - "+AllTrim(cCodBem)+" - "+SubStr(NGSEEK("ST9",cCodBem,1,"T9_NOME"),1,20);
      +" "+(cAliasTmp)->SERVIC+" "+(cAliasTmp)->SEQREL Of oScr Pixel Font oFont //"�ltima Manuten��o"
	@ 25,05 SAY STR0025 Of oScr Pixel //"Data:"
	@ 25,40 MsGet dData Size 45,08 Pixel Of oScr Picture '99/99/99' Valid naovazio() .And. NGCPDIAATU(dData,"<=",.T.,.T.,.T.) .And. VLDATAULTM()
 	If lCalVazio
		@ 38,05 SAY STR0029 Of oScr Pixel //"Calend�rio"
		@ 38,40 MSGET cCalendTPF SIZE 25,07 OF oDlgS PIXEL PICTURE '@!' F3 "SH7";
		   VALID naovazio() .And. Existcpo("SH7",cCalendTPF)
 	Endif
	DEFINE SBUTTON FROM 45,180 TYPE 1 ENABLE OF oScr ACTION ;
		EVAL({||lSai := .T.,If((dData <= dDataBase .And. If(!lCalVazio,.t.,If(Empty(cCalendTPF),.f.,.t.))),oDlgS:End(),lSai := .F.)})

EndIf

/*Ponto de entrada para realizar altera��es das vari�veis
considerando os diferentes tipos de manuten��o (tempo, contador, etc).*/
If ExistBlock( "MNTA081B" )
	aAltVar := { dData,nContador,cCalendTPF }
	ExecBlock( "MNTA081B",.F.,.F.,{ aAltVar } )
EndIf

ACTIVATE MSDIALOG oDlgS CENTERED

If lSai

    dbSelectArea(cAliasTmp)
	RecLock((cAliasTmp),.F.)
    (cAliasTmp)->DTULTMA := dData
	(cAliasTmp)->CONMANU := nContador
	If !Empty(cCalendTPF)
		(cAliasTmp)->CALEND := cCalendTPF
	Endif
	MsUnLock(cAliasTmp)

EndIf

Return lSai

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �M081MarkAll� Autor �Felipe N. Welter      � Data � 30/01/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava marca em todos os registros validos                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA081                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M081MarkAll()

dbSelectArea(cAliasTmp)
dbGotop()
While !Eof()
   If IsMark('OK',cMarca)
      RecLock((cAliasTmp),.F.)
      Replace OK      With Space(2)
      Replace DTULTMA With Ctod('  /  /  ')
      Replace CONMANU With 0
      Replace CALEND  With Space(Len(sh7->h7_codigo))
      MsUnLock(cAliasTmp)
   Else
      If Empty((cAliasTmp)->DTULTMA) .Or. Empty((cAliasTmp)->CONMANU) .Or.;
         Empty((cAliasTmp)->CALEND)
         MNT081INF()
      Endif
      RecLock((cAliasTmp),.F.)
      Replace OK With cMarca
      MsUnLock(cAliasTmp)
   EndIf
   dbSkip()
End
dbGoTop()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA081VIS� Autor �Felipe N. Welter       � Data � 02/02/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Visualiza Manutencao Padrao selecionada (F11)               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA081                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA081VIS(cServico,cSequencia)

Local cArea := GetArea()
dbSelectArea("TPF")
dbSetOrder(nIdTPF)
If dbseek(xFilial("TPF")+cCodFami+cTipMod+(cAliasTmp)->SERVIC+(cAliasTmp)->SEQREL)
	NG180FOLD("TPF",TPF->(Recno()),2)
EndIf
RestArea(cArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA081OK  � Autor �Felipe N. Welter      � Data � 30/01/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida e Grava as Manutencoes Padrao                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA081                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA081OK()

Local lMark := .F.
Local lRet := .T.

dbSelectArea(cAliasTmp)
dbGotop()
While !Eof()
	If IsMark('OK',cMarca)
		lMark := .T.
	EndIf
	dbSkip()
EndDo

If !lMark
	APMSGALERT(STR0027) //"Nenhuma manutencao foi selecionada!"
	lRet := .F.
Else
	If APMSGYESNO(STR0028) //"Deseja realmente incorporar as manutencoes selecionadas?"

		dbSelectArea(cAliasTmp)
		dbGotop()
		While !Eof()
           If IsMark('OK',cMarca)
              lProbl := If(Empty((cAliasTmp)->DTULTMA) .Or. Empty((cAliasTmp)->CALEND),.T.,.F.)
              If !lProbl .And. !(cAliasTmp)->TIPACO $ "T"
                 lProbl := If(Empty((cAliasTmp)->CONMANU),.T.,.F.)
              Endif
              If lProbl
                 HELP(" ",1,"OBRIGAT",,STR0024+CRLF+CRLF+STR0025+" , "+STR0026+" , "+STR0029,5,1)
                 Return .f.
              Endif
           Endif
           dbSkip()
        End
		dbGotop()
		While !Eof()
			If IsMark('OK',cMarca)

				dbselectarea("TPF")
				dbsetorder(nIdTPF)
				If Dbseek(xFilial("TPF")+cCodFami+cTipMod+(cAliasTmp)->SERVIC+(cAliasTmp)->SEQREL)

				   MNTATUSTF()

				ElseIf !Dbseek(xFilial('TPF')+cCodFami+cTipMod+(cAliasTmp)->SERVIC) .AND. Empty((cAliasTmp)->TF_SEQREL)
				   HELP(" ",1,"NREGFASERV")
				   lRet := .F.
				   Exit
				Endif

			EndIf

			dbSelectarea(cAliasTmp)
            dbSkip()

		End
	Else
		lRet := .F.
	EndIf

EndIf

dbSelectArea(cAliasTmp)
dbGoTop()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTF
Alimenta os campos do STF com os campos padrao TPF Baseada em
CARREG180() do MNTA120

@author  Felipe N. Welter
@since   30/01/09
@source  MNTA080OK
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTF()

	Local cSTF     := ""
	Local cTPF     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aSTF     := {}
	Local aStruct  := {}
	Local aNAO     := {"TF_FILIAL","TF_CODBEM","TF_PADRAO","TF_SEQUEPA","TF_SEQREPA"}

	//Cria Array de controle do STF
	dbselectarea("STF")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			dbskip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTF := "STF->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPF := "TPF_"+SUBSTR(aStruct[nInd,1],4,5)+SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPF := "TPF_"+SUBSTR(aStruct[nInd,1],4,6)
			Endif
			Aadd(aSTF,{cSTF, cTPF})
		EndIf
		dbskip()

	Next nInd

	//Carrega o TPF nas variaveis do STF
	dbSelectArea("STF")
	RecLock("STF",.T.)
	STF->TF_FILIAL := xFilial("STF")
	STF->TF_CODBEM := cCodBem
	STF->TF_PADRAO := "S"
	STF->TF_SEQUEPA := 0
	STF->TF_SEQREPA := (cAliasTmp)->SEQREL
	STF->TF_DTULTMA := (cAliasTmp)->DTULTMA
	STF->TF_CONMANU := (cAliasTmp)->CONMANU
	STF->TF_ATIVO   := "S"
	STF->TF_PLANEJA := "S"

	For nInd := 1 TO Len(aSTF)
		cTPF := aSTF[nInd][2]
		cSTF := aSTF[nInd][1]
		dbSelectArea("TPF")
		STF->(&cSTF.) := FIELDGET(FIELDPOS(cTPF))
	Next

	If !Empty((cAliasTmp)->CALEND)
		STF->TF_CALENDA := (cAliasTmp)->CALEND
	Endif
	STF->(MsUnlock())

	MNTATUST5()
	MNTATUSTM()
	MNTATUSTG()
	MNTATUSTH()

	//---------------------------------------------------------------------------
	// Ponto de Entrada que possibilita fazer altera��es na STF, STM, STG e STH
	//---------------------------------------------------------------------------
	If ExistBlock("MNTA081A")
		ExecBlock("MNTA081A",.F.,.F.)
	EndIf

	dbSelectArea("STF")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUST5
Grava Tarefas da Manutencao baseado na Manutencao Padrao
(Baseada no MNTA120)

@author  Felipe N. Welter
@since   30/01/09
@source  MNTA080OK
/*/
//-------------------------------------------------------------------
Static Function MNTATUST5()

	Local cST5     := ""
	Local cTP5     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aST5     := {}
	Local aNAO     := {"T5_FILIAL","T5_CODBEM"}
	Local aStruct  := {}

	//Cria Array de controle do STF
	dbselectarea("ST5")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			Dbskip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")

			cST5 := "ST5->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTP5 := "TP5_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTP5 := "TP5_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			aAdd(aST5,{cST5, cTP5})

		EndIf
		dbSkip()

	End

	dbSelectArea("TP5")
	dbSetOrder(nIdTP5)
	If dbSeek(xFILIAL("TP5")+cCodFami+cTipMod+(cAliasTmp)->SERVIC+(cAliasTmp)->SEQREL)

		If lTipMod
			While !Eof() .And. TP5->TP5_FILIAL == xFILIAL("TP5") .And. TP5->TP5_CODFAM == cCodFami;
			             .And. TP5->TP5_TIPMOD == cTipMod        .And. TP5->TP5_SERVIC == (cAliasTmp)->SERVIC;
					 	 .And. TP5->TP5_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("ST5")
				RecLock("ST5",.T.)
				ST5->T5_FILIAL := xFilial("ST5")
				ST5->T5_CODBEM := cCodBem

				For nInd := 1 TO LEN(aST5)
					cTP5 := aST5[nInd][2]
					cST5 := aST5[nInd][1]
					dbSelectArea("TP5")
					&cST5. := FIELDGET(FIELDPOS(cTP5))
				Next

				dbSelectArea("TP5")
				dbSkip()
				MsUnLock("ST5")

			End
		Else
			While !Eof() .And. TP5->TP5_FILIAL == xFILIAL("TP5")      .And. TP5->TP5_CODFAM == cCodFami;
						 .And. TP5->TP5_SERVIC == (cAliasTmp)->SERVIC .And. TP5->TP5_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("ST5")
				RecLock("ST5",.T.)
				ST5->T5_FILIAL := xFilial("ST5")
				ST5->T5_CODBEM := cCodBem

				For nInd := 1 TO LEN(aST5)
					cTP5 := aST5[nInd][2]
					cST5 := aST5[nInd][1]
					dbSelectArea("TP5")
					&cST5. := FIELDGET(FIELDPOS(cTP5))
				Next

				dbSelectArea("TP5")
				dbSkip()
				MsUnLock("ST5")
			End
		EndIf

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTM
Grava Dependencias da Manutencao baseado na Manuten. Padrao
(Baseada no MNTA120)

@author  Deivys Joenck
@since   30/01/09
@source  MNTATUSTF
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTM()

	Local cSTM     := ""
	Local cTPM     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aSTM     := {}
	Local aNAO     := {"TM_FILIAL","TM_CODBEM"}
	Local aStruct  := {}

	//Cria Array de controle do STF
	dbselectarea("STM")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			Dbskip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTM := "STM->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPM := "TPM_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPM := "TPM_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			Aadd(aSTM,{cSTM, cTPM})
		EndIf
		dbskip()

	End

	dbSelectArea("TPM")
	dbSetOrder(nIdTPM)
	If dbSeek(xFILIAL("TPM")+cCodFami+cTipMod+(cAliasTmp)->SERVIC+(cAliasTmp)->SEQREL)

		If lTipMod
			While !Eof() .And. TPM->TPM_FILIAL == xFILIAL("TPM") .And. TPM->TPM_CODFAM == cCodFami ;
						 .And. TPM->TPM_TIPMOD == cTipMod        .And. TPM->TPM_SERVIC == (cAliasTmp)->SERVIC;
						 .And. TPM->TPM_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("STM")
				RecLock("STM",.T.)
				STM->TM_FILIAL := xFilial("STM")
				STM->TM_CODBEM := cCodBem
				For nInd := 1 TO LEN(aSTM)
					cTPM := aSTM[nInd][2]
					cSTM := aSTM[nInd][1]
					dbSelectArea("TPM")
					&cSTM. := FIELDGET(FIELDPOS(cTPM))
				Next
				dbSelectArea("TPM")
				dbSkip()
				MsUnLock("STM")

			End
		Else
			While !Eof() .And. TPM->TPM_FILIAL == xFILIAL("TPM")      .And. TPM->TPM_CODFAM == cCodFami;
						 .And. TPM->TPM_SERVIC == (cAliasTmp)->SERVIC .And. TPM->TPM_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("STM")
				RecLock("STM",.T.)
				STM->TM_FILIAL := xFilial("STM")
				STM->TM_CODBEM := cCodBem
				For nInd := 1 TO LEN(aSTM)
					cTPM := aSTM[nInd][2]
					cSTM := aSTM[nInd][1]
						dbSelectArea("TPM")
					&cSTM. := FIELDGET(FIELDPOS(cTPM))
				Next
				dbSelectArea("TPM")
				dbSkip()
				MsUnLock("STM")
			End
		EndIf

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTG
Grava Detalhes da Manutencao baseado na Manuten. Padrao
(Baseada no MNTA120)

@author Felipe N. Welter
@since  30/01/09
@source MNTATUSTF
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTG()

	Local cSTG     := ""
	Local cTPG     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aSTG     := {}
	Local aNAO     := {"TG_FILIAL","TG_CODBEM"}
	Local aStruct  := {}

	//Cria Array de controle do STF
	dbselectarea("STG")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			dbSkip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTG := "STG->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPG := "TPG_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPG := "TPG_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			aAdd(aSTG,{cSTG, cTPG})
		EndIf
		dbSkip()
	End

	dbSelectArea("TPG")
	dbSetOrder(nIdTPG)
	If dbSeek(xFILIAL("TPG")+cCodFami+cTipMod+(cAliasTmp)->SERVIC+(cAliasTmp)->SEQREL)

		If lTipMod
			While !Eof() .And. TPG->TPG_FILIAL == xFILIAL("TPG") .And. TPG->TPG_CODFAM == cCodFami ;
						 .And. TPG->TPG_TIPMOD == cTipMod        .And. TPG->TPG_SERVIC == (cAliasTmp)->SERVIC;
						 .And. TPG->TPG_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("STG")
				RecLock("STG",.T.)
				STG->TG_FILIAL := xFilial("STG")
				STG->TG_CODBEM := cCodBem
				For nInd := 1 TO LEN(aSTG)
					cTPG := aSTG[nInd][2]
					cSTG := aSTG[nInd][1]
					dbSelectArea("TPG")
					&cSTG. := FIELDGET(FIELDPOS(cTPG))
				Next
				dbSelectArea("TPG")
				dbSkip()
				MsUnLock("STG")
			End
		Else
			While !Eof() .And. TPG->TPG_FILIAL == xFILIAL("TPG")      .And. TPG->TPG_CODFAM == cCodFami;
						 .And. TPG->TPG_SERVIC == (cAliasTmp)->SERVIC .And. TPG->TPG_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("STG")
				RecLock("STG",.T.)
				STG->TG_FILIAL := xFilial("STG")
				STG->TG_CODBEM := cCodBem
				For nInd := 1 TO LEN(aSTG)
					cTPG := aSTG[nInd][2]
					cSTG := aSTG[nInd][1]
					dbSelectArea("TPG")
					&cSTG. := FIELDGET(FIELDPOS(cTPG))
				Next
				dbSelectArea("TPG")
				dbSkip()
				MsUnLock("STG")
			End
		EndIf

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTATUSTH
Grava Etapas da Manutencao baseado na Manuten. Padrao
(Baseada no MNTA120)

@author Felipe N. Welter
@since  30/01/09
@source MNTATUSTF
/*/
//-------------------------------------------------------------------
Static Function MNTATUSTH()

	Local cSTH     := ""
	Local cTPH     := ""
	Local cContext := ""
	Local nInd     := 0
	Local nTam     := 0
	Local aSTH     := {}
	Local aNAO     := {"TH_FILIAL","TH_CODBEM"}
	Local aStruct  := {}

	//Cria Array de controle do STF
	dbselectarea("STH")
	aStruct := DBSTRUCT()
	nTam    := Len(aStruct)

	For nInd := 1 To nTam

		If aSCAN(aNAO,AllTrim(aStruct[nInd,1])) > 0
			dbSkip()
			Loop
		Endif

		cContext := Posicione("SX3",2,aStruct[nInd,1],"X3_CONTEXT")
		If !(cContext $ "V")
			cSTH := "STH->" + aStruct[nInd,1]
			If SUBSTR(aStruct[nInd,1],10,01) $ "0123456789"
				cTPH := "TPH_" + SUBSTR(aStruct[nInd,1],4,5) + SUBSTR(aStruct[nInd,1],10,01)
			Else
				cTPH := "TPH_" + SUBSTR(aStruct[nInd,1],4,6)
			Endif
			aAdd(aSTH,{cSTH, cTPH})
		EndIf
		dbSkip()
	End

	dbSelectArea("TPH")
	dbSetOrder(nIdTPH)
	If dbSeek(xFILIAL("TPH")+cCodFami+cTipMod+(cAliasTmp)->SERVIC+(cAliasTmp)->SEQREL)

		If lTipMod
			While !Eof() .And. TPH->TPH_FILIAL == xFILIAL("TPH") .And. TPH->TPH_CODFAM == cCodFami ;
						 .And. TPH->TPH_TIPMOD == cTipMod        .And. TPH->TPH_SERVIC == (cAliasTmp)->SERVIC;
						 .And. TPH->TPH_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("STH")
				RecLock("STH",.T.)
				STH->TH_FILIAL := xFilial("STH")
				STH->TH_CODBEM := cCodBem
				For nInd := 1 TO LEN(aSTH)
					cTPH := aSTH[nInd][2]
					cSTH := aSTH[nInd][1]
					dbSelectArea("TPH")
					&cSTH. := FIELDGET(FIELDPOS(cTPH))
				Next
				MsUnLock("STH")
				If Alltrim(STH->TH_OPCOES) <> "S"
					dbSelectArea("TPC")
					dbSetOrder(1)
					dbSeek(xFilial("TPC")+STH->TH_ETAPA)
					While !Eof() .and. TPC->TPC_ETAPA == STH->TH_ETAPA
						RecLock("TP1",.T.)
						TP1->TP1_FILIAL := xFILIAL("TP1")
						TP1->TP1_CODBEM := STH->TH_CODBEM
						TP1->TP1_SERVIC := STH->TH_SERVICO
						TP1->TP1_SEQREL := STH->TH_SEQRELA
						TP1->TP1_TAREFA := STH->TH_TAREFA
						TP1->TP1_ETAPA  := TPC->TPC_ETAPA
						TP1->TP1_OPCAO  := TPC->TPC_OPCAO
						TP1->TP1_TIPRES := TPC->TPC_TIPRES
						TP1->TP1_CONDOP := TPC->TPC_CONDOP
						TP1->TP1_CONDIN := TPC->TPC_CONDIN
						TP1->TP1_TPMANU := TPC->TPC_TPMANU
						TP1->TP1_TIPCAM := TPC->TPC_TIPCAM
						TP1->TP1_BEMIMN := If(TPC->TPC_PORBEM = 'P',STH->TH_CODBEM,SubStr(TPC->TPC_DESCRI,1,16))
						TP1->TP1_SERVMN := TPC->TPC_SERVIC
						TP1->TP1_BLOQMA := "S"
						TP1->TP1_BLOQFU := "S"
						TP1->TP1_BLOQFE := "S"
						MsUnLock("TP1")
						dbSelectArea("TPC")
						TPC->(dbSkip())
					End
				EndIf
				dbSelectArea("TPH")
				dbSkip()
			End
		Else
			While !Eof() .And. TPH->TPH_FILIAL == xFILIAL("TPH")      .And. TPH->TPH_CODFAM == cCodFami ;
						 .And. TPH->TPH_SERVIC == (cAliasTmp)->SERVIC .And. TPH->TPH_SEQREL == (cAliasTmp)->SEQREL

				dbSelectArea("STH")
				RecLock("STH",.T.)
				STH->TH_FILIAL := xFilial("STH")
				STH->TH_CODBEM := cCodBem
				For nInd := 1 TO LEN(aSTH)
					cTPH := aSTH[nInd][2]
					cSTH := aSTH[nInd][1]
					dbSelectArea("TPH")
					&cSTH. := FIELDGET(FIELDPOS(cTPH))
				Next

				MsUnLock("STH")
				If Alltrim(STH->TH_OPCOES) <> "S"
					dbSelectArea("TPC")
					dbSetOrder(1)
					dbSeek(xFilial("TPC")+STH->TH_ETAPA)
					While !Eof() .and. TPC->TPC_ETAPA == STH->TH_ETAPA
						RecLock("TP1",.T.)
						TP1->TP1_FILIAL := xFILIAL("TP1")
						TP1->TP1_CODBEM := STH->TH_CODBEM
						TP1->TP1_SERVIC := STH->TH_SERVICO
						TP1->TP1_SEQREL := STH->TH_SEQRELA
						TP1->TP1_TAREFA := STH->TH_TAREFA
						TP1->TP1_ETAPA  := TPC->TPC_ETAPA
						TP1->TP1_OPCAO  := TPC->TPC_OPCAO
						TP1->TP1_TIPRES := TPC->TPC_TIPRES
						TP1->TP1_CONDOP := TPC->TPC_CONDOP
						TP1->TP1_CONDIN := TPC->TPC_CONDIN
						TP1->TP1_TPMANU := TPC->TPC_TPMANU
						TP1->TP1_TIPCAM := TPC->TPC_TIPCAM
						TP1->TP1_BEMIMN := If(TPC->TPC_PORBEM = 'P',STH->TH_CODBEM,SubStr(TPC->TPC_DESCRI,1,16))
						TP1->TP1_SERVMN := TPC->TPC_SERVIC
						TP1->TP1_BLOQMA := "S"
						TP1->TP1_BLOQFU := "S"
						TP1->TP1_BLOQFE := "S"
						MsUnLock("TP1")
						dbSelectArea("TPC")
						TPC->(dbSkip())
					End
				EndIf
				dbSelectArea("TPH")
				dbSkip()
			End
		EndIf

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} VLDATAULTM
Valida a data da �ltima manuten��o.

@author Elynton Fellipe Bazzo
@since 24/09/13
@version P11
@return .T.
/*/
//--------------------------------------------------------------------
Static Function VLDATAULTM()

	Local dDtUltCon := CtoD("  /  /    ")

	If dData > dDataBase
		CHKHELP("NG080DTINV")//Data informada invalida.//A data informada n�o pode ser maior que a data atual do sistema.
		Return .F.
	EndIf

	If !Empty(dData) //Se estiver preenchida.
		If (cAliasTmp)->TIPACO  == "S" //Se o Tipo do Acompanhamento for igual a "Seg. Contador".
			dbSelectArea( "TPE" )
			dbSetOrder( 01 ) //TPE_FILIAL+TPE_CODBEM
			dbSeek( xFilial( "TPE" )+ST9->T9_CODBEM )
			dDtUltCon := TPE->TPE_DTULTA //Recebe a Data Ult. Acompanhamento da tabela 'TPE'.
		ElseIf ST9->T9_TEMCONT == "S" .And. (cAliasTmp)->TIPACO <> "T" //Se Tem contador e Tipo do Acompanhamento for diferente de "tempo".
			dDtUltCon := ST9->T9_DTULTAC //Recebe a Data Ult. Acompanhamento da tabela 'ST9'.
		EndIf
		If !Empty(dDtUltCon) .And. dData > dDtUltCon
			MsgStop(If((cAliasTmp)->TIPACO == "S",STR0030,STR0031)+DTOC(dDtUltCon)+" .")
			Return .F.
		EndIf
	EndIf

Return .T.
