/*/
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� DATA   � BOPS �Prograd.�ALTERACAO                                      ���
��������������������������������������������������������������������������Ĵ��
���26.03.98�14776A�Eduardo �Acerto no erro bound Array acess na Proj.Infla.���
��������������������������������������������������������������������������Ĵ��
���22.11.99�META  �Julio W.�Revisao do Fonte para Protheus 5.08            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
#INCLUDE "MATA090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA090  � Autor � Jorge Queiroz         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Moedas                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void MATA090(void)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Mata090

Private aRotina 	:= MenuDef()

LimpaMoeda()

	//��������������������������������������������������������������Ŀ
	//� Define Array contendo as Rotinas a executar do programa      �
	//� ----------- Elementos contidos por dimensao ------------     �
	//� 1. Nome a aparecer no cabecalho                              �
	//� 2. Nome da Rotina associada                                  �
	//� 3. Usado pela rotina                                         �
	//� 4. Tipo de Transa��o a ser efetuada                          �
	//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
	//�    2 - Simplesmente Mostra os Campos                         �
	//�    3 - Inclui registros no Bancos de Dados                   �
	//�    4 - Altera o registro corrente                            �
	//�    5 - Remove o registro corrente do Banco de Dados          �
	//����������������������������������������������������������������
	
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"SM2",,,22)

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A090Inclui� Autor � Pilar S. Albaladejo   � Data � 06.03.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Inclusao de Moedas                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void A090Inclui(ExpC1,ExpN1,ExpN2)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao no Menu                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A090Inclui(cAlias,nReg,nOpc)

Local nOpca

nOpca := AxInclui (cAlias,nReg,nOpc,,,,'If(dbSeek(M->M2_DATA),(Help(" ",1,"JAGRAVADO"),.F.),.T.)')

If nOpca == 1
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
	BEGIN TRANSACTION
	// Compatibilizacao com Arquivo de Moedas -> CTB
	If CtbInUse()
		GrvCTBCTP()
	EndIf	
	END TRANSACTION 	
EndIf	

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A090Altera� Autor � Pilar S. Albaladejo   � Data � 06.03.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Alteracao de Cotacao Moedas                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void A090Altera(ExpC1,ExpN1,ExpN2)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao no Menu                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A090Altera(cAlias,nReg,nOpc)

Local nOpca

nOpca := AxAltera (cAlias,nReg,nOpc)

If nOpca == 1
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
	BEGIN TRANSACTION
	// Compatibilizacao com Arquivo de Moedas -> CTB
	If CtbInUse()
		GrvCTBCTP()
	EndIf	
	END TRANSACTION 
EndIf	

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A090Deleta� Autor � Jorge Queiroz         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Moedas                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void A090Deleta(ExpC1,ExpN1)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A090Deleta(cAlias,nReg,nOpc)

Local nOpca

nOpca := AxDeleta(cAlias,nReg,nOpc)

If nOpca==1
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
EndIF

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A090Projet� Autor � Wagner Xavier         � Data � 23.09.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Projecao de Moedas                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void A090Projet(ExpC1,ExpN1)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A090Projet(cAlias,nReg,nOpc)

//����������������������������������������������������������������������Ŀ
//�Salva a integridade dos dados                                         �
//������������������������������������������������������������������������
Local i,lRegres,k,lInflacao,n:=0
Local nAvanco,oDlg,cSuf,nRegM2 := SM2->(Recno())
Local oGet01, oGet02 := 1
Local lValDias:=.T.
Local oGet            
Local aoGrRad := {}
Local nI        
Local lRefresh := .F.
Local anGrRad := {}

Private cMoeda,aMoedas:={},aMeses:={},nDias:=0,nDiasReg:=3
Private aHeader:={}, nNumMoedas := 0, nNumMeses := 1, cSeqMdProj:="01."
Private aAlter:={}

//����������������������������������������������������������������������Ŀ
//�Get no parametro MV_DIASPRO - no. de dias de projecao de moedas       �
//������������������������������������������������������������������������
nDias:= GETMV("MV_DIASPRO")
n:=0
lRegres:=.F.
lInflacao:=.F.
AAdd(aoGrRad,"")

// 1a. coluna
AADD(aHeader,{STR0025,"MOEDA","@!",10,0,".t.","�","C","TRB"})

aMoedas := MontaMark(@anGrRad, @aoGrRad)

If ! Len(aMoedas) > 0
	Return
Endif

//2a. coluna em diante
For nI := 1 to Len(aMoedas)
	AADD(aHeader,{aMoedas[nI,1],"MOEDA" + aMoedas[nI,2],PesqPict("SM2","M2_TXMOED2"),5,2,".t.","�","N","TRB"})
	AADD(aAlter,"MOEDA" + aMoedas[nI,2])
Next

Private aCols[1][Len(aHeader)+1]

If Len(aMoedas) == 0
	Help(" ",1,"A090NMOEDA")
	Return .F.
EndIf

aCols[1][Len(aCols[1])] := .F.

// Monta a GetDados Zerada
aCols[1][1]:="_________"		//,0.0,0.0,0.0,0.0,.f.})

For nI:= 2 To Len(aMoedas)+1
	aCols[1][nI]:= 0.00
Next

DEFINE MSDIALOG oDlg FROM 74,07 TO 450,850 TITLE STR0007 OF oMainWnd PIXEL

@ 04, 04 SAY STR0021 SIZE 73, 8 OF oDlg PIXEL // No. de dias para proje��oo"
@ 0.3, 12 MSGET oGet01 VAR nDias PICTURE "9999" SIZE 17,9 VALID (lValDias:=(nDias > 0 .and. nDias < 366),If(lValDias,A090GDbWhen(anGrRad,oGet),),lValDias) OF oDlg
@ 04, 160 SAY STR0022 SIZE 73, 8 OF oDlg PIXEL // "No. de dias para regress�o"
@ 0.3,30 MSGET oGet02 VAR nDiasReg PICTURE "999" SIZE 17,9 WHEN A090DiasR(anGrRad) Valid nDiasReg > 0 OF oDlg

@ 17,03 MSPANEL oPanel PROMPT "" SIZE 185,170 OF oDlg //CENTERED RAISED //"Botoes"
oScroll := TScrollBox():New( oPanel, 000,175,85,08,.T.,.T.,.T.)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

@100,00 TO 100,550 OF oDlg PIXEL

oGet := MSGetDados():New(18,190,160,410,3,"AlwaysTrue","AlwaysTrue","",.T.,aAlter,,,1)

nRod := 1
For nI := 1 to Len(aMoedas) Step 2

	//inclui a moeda da coluna da esquerda
 	@ 03+((nRod-1)*42),03 TO 40+((nRod-1)*42), 079 LABEL GetMv("MV_MOEDA" + aMoedas[nI,2] ) OF oScroll  PIXEL

	aoGrRad[nI] := 	TRadMenu():New( 11+((nRod-1)*42), 06, {STR0023, STR0024},;
	&("{ | u | If( PCount() == 0,anGrRad["+cValToChar(nI)+"], anGrRad["+cValToChar(nI)+"] := u ) }") ,;
	oScroll,, { || A090GDbWhen(anGrRad,oGet) } ,,,,,,70,10,, .T., .T.,.T. )
 	
	If !Len(aMoedas) == 1 .And. nI < Len(aMoedas) 	
			@ 03+((nRod-1)*42),92 TO 40+((nRod-1)*42), 168 LABEL GetMv("MV_MOEDA" + aMoedas[nI + 1,2]) OF oScroll  PIXEL
		
			aoGrRad[nI+1] := TRadMenu():New( 11+((nRod-1)*42), 95, {STR0023, STR0024},;
			&("{ | u | If( PCount() == 0,anGrRad["+cValToChar(nI+1)+"], anGrRad["+cValToChar(nI+1)+"] := u ) }") ,;
			oScroll,, { || A090GDbWhen(anGrRad,oGet) },,,,,,70,10,, .T., .T.,.T. )
	Endif

	nRod ++
Next nI
nI:=1        

DEFINE SBUTTON FROM 170, 350 TYPE 1 ACTION (CursorWait(),lRefresh :=.t.,fc090Calc(anGrRad,oDlg:End())) ENABLE OF oDlg
DEFINE SBUTTON FROM 170, 380 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg ON INIT A090InitDLG(oDlg) CENTERED

If ! lRefresh
	Return
EndIf

CursorArrow()
//����������������������������������������������������������������������Ŀ
//� Grava o parametro MV_DIASPRO no arq. SX6                             �
//������������������������������������������������������������������������
If GetMv("MV_DIASPRO") != NIL
	PutMV("MV_DIASPRO",Str(nDias,3))
EndIf
SM2->(dbGoto(nRegM2))

Return

//����������������������������������������������������������������������Ŀ
//� FUNCAO A090INITDLG                                                   �
//������������������������������������������������������������������������
Function A090InitDLG(oAuxDlg)

Local nCnt01 := 0

For nCnt01 := 1 To Len(oAuxDlg:aControls)
	If (oAuxDlg:aControls[nCnt01]:cCaption != NIL) .And. ;
		("GRPM" $ oAuxDlg:aControls[nCnt01]:cCaption)
		oAuxDlg:aControls[nCnt01]:cTitle := Capital(Substr(GetMV("MV_MOEDA"+Right(oAuxDlg:aControls[nCnt01]:cCaption,1)),1,13))
	EndIf
Next
oAuxDlg:Refresh(.T.)

Return(NIL)

//����������������������������������������������������������������������Ŀ
//� FUNCAO A090DIASR                                                     �
//������������������������������������������������������������������������
Function A090DiasR(anGrRad)

Local nI

lRet := .F.
For ni := 1 To Len(anGrRad)
	If anGrRad[nI] == 1
		lRet := .T.
	EndIf
Next

Return lRet

//����������������������������������������������������������������������Ŀ
//� FUNCAO A090DBWHEN                                                    �
//������������������������������������������������������������������������
Function A090GDbWhen(anGrRad,oGet)

Local lProcess := .F.//:= (nGrRad01==2) .Or. (nGrRad02==2) .Or. (nGrRad03==2) .Or.(nGrRad04==2)
Local dDataIni, dDataFim, nMes, nMdBr:=0
Local aRadios := {}
Local nI
              
For nI:=1 To Len(anGrRad)
	Aadd(aRadios,anGrRad[nI])
	If anGrRad[nI] == 2
		lProcess := .T.
	End
Next

cSeqMdProj:="01."
If lProcess
	aCols := {}
	aAlter:= {}
	oGet:oBrowse:aAlter:={}
	nMdBr := Len(anGrRad)
	//����������������������������������������������������������������������Ŀ
	//�Monta acols com Meses a serem indicados para projecao                 �
	//������������������������������������������������������������������������
	dDataIni:=dDataBase+1
	dDataFim:=dDataBase+nDias
	nMes    :=Month(dDataIni)
	While nMes != Month(dDataFim)
		AADD(aCols,array(nMdBr+2))
		aCols[Len(aCols)][1] := Substr(cMonthNac(dDataIni),1,9)
		For ni := 1 to nMdBr
			aCols[Len(aCols)][ni+1] := 0
		Next
		aCols[Len(aCols)][nMdBr+2] := .f.
		nAvanco:=1+(Day(LastDay(dDataIni))-Day(dDataIni))
		dDataIni:=dDataIni+nAvanco
		nMes:=Month(dDataIni)
		IF nMes>12;nMes:=1;EndIF
		nNumMeses++
	EndDO

	AADD(aCols,array(nMdBr+2))
	aCols[Len(aCols)][1] := Substr(cMonthNac(dDataIni),1,9)
	For ni := 1 to nMdBr
		aCols[Len(aCols)][ni+1] := 0
	Next
	aCols[Len(aCols)][nMdBr+2] := .f.
	For nI := 1 to Len(aRadios)
		IF (aRadios[nI] == 2)
			Aadd(aAlter,"MOEDA" + aMoedas[nI,2] )
			cSeqMdProj := cSeqMdProj + strzero(Val(aMoedas[nI,2]),2)+'.' 
		Endif
	Next
	oGet:oBrowse:aAlter:=aClone(aAlter)
	oGet:ForceRefresh()
EndIf

Return(lProcess)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fc090Calc� Autor � Wagner Xavier         � Data � 23.09.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Avalia array para tipos de projecoes de moedas             ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � fc090Calc()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function fc090Calc(anGrRad)

Local n,lCalc:=.T., ni, nj
Local aRadios := {}

For nI:=1 To Len(anGrRad)
	Aadd(aRadios,anGrRad[nI])
Next

IF Len(cSeqMdProj) > 3 //1
	aTaxaMeses := Array(Len(aCols),Len(aHeader))
	For ni := 1 to Len(aHeader)
		For nj := 1 to Len(aCols)
			aTaxaMeses[nj][ni] := aCols[nj][ni]
		Next
	Next
Endif

For n:=1 To Len(aMoedas)

	If aRadios[n] == 1
		lCalc:=CalcLinear(Val(aMoedas[n,2]), anGrRad)
		If !lCalc
			Exit
		EndIf
	Else
		//��������������������������������������������������������������Ŀ
		//� Chama a funcao CalcInflac com o parametro de "P" (Projecao)  �
		//����������������������������������������������������������������
		// transformar acols em ataxameses [ taxa x moeda]
		lCalc:=CalcInflac(Val(aMoedas[n,2]),"P")
		IF !lCalc
			Exit
		EndIF
	EndIF
Next

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CalcLinear� Autor � Wagner Xavier         � Data � 23.09.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula as Taxas em outras moedas pela formula de Regressao ���
���          �Linear                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �CalcLinear(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = no. da moeda a ser calculada a projecao            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function CalcLinear(nMoeda, anGrRad)

Local dAtual:=dDataBase
Local dPass :=dAtual-nDiasReg
Local aRet,Xi,Yi
Local nPosAtu:=0,nPosAnt:=0,nTotRegs:=0,nPosCnt:=0,nOpc:=0,cSavMenuh
Local lMa090Atu := ExistBlock("MA090ATU")
Local i,j
Local nValAnt := {}

cSuf:=cValToChar(nMoeda)
DbSelectArea("SM2")

If RecCount() < 2
	Help(" ",1,"NORECD")
	Return .F.
Endif

dbGoTop( )
Set Softseek on
dbSeek(dPass)
dPass := M2_DATA

If ! (dPass < dAtual)
	Help(" ",1,"NORECD")
	Set Softseek off
	Return .F.
EndIf

For i:=1 to Len(anGrRad)    
	SetPrvt( "ay"+LTrim(aMoedas[i,2]) )
	&("ay"+LTrim(aMoedas[i,2])) := {}
Next i

Set Softseek off
While dPass < dAtual
	dbSeek(dPass)
	IF Found()     
		For i:=1 to Len(anGrRad)    
			SetPrvt("nValAnt"+LTrim(Str(i+1)))
			nValAnt := &("m2_moeda" + aMoedas[i,2])
			AADD(&("ay" + aMoedas[i,2]), nValAnt )
		Next i
	Endif
	dPass++
EndDo

SetPrvt("aRet" + LTrim(Str(nMoeda)) )   
	
&("aRet"+LTrim(Str(nMoeda))) := RLinear( &("ay"+LTrim( Str( nMoeda ) ) ) )
SetPrvt("K1"+LTrim(Str(nMoeda)))
&("K1"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[1]
SetPrvt("K2"+LTrim(Str(nMoeda)))	
&("K2"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[2]
SetPrvt("Xm"+LTrim(Str(nMoeda)))		
&("Xm"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[3]
SetPrvt("Ym"+LTrim(Str(nMoeda)))			
&("Ym"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[4]
SetPrvt("Nx"+LTrim(Str(nMoeda)))		
&("Nx"+LTrim(Str(nMoeda))) := Len(&("ay"+LTrim( Str( nMoeda ) ) ) )	

Xi:=dAtual
Yi:=0

// Regua

For j:=1 To nDias		
	
 	Xi:=dPass+j
	nD:=(Xi-dAtual)+nx&cSuf
	Yi := (K2&cSuf*nD)+(Ym&cSuf-(K2&cSuf*Xm&cSuf))
	dbSeek(dPass+j)
	If Found() .and. M2_INFORM != "S"
		Reclock("SM2")
		nOpc := 4
	ElseIf M2_INFORM != "S"
		Reclock("SM2",.T.)
		nOpc := 3
	EndIf
	IF M2_INFORM != "S"
		Replace M2_DATA        With dPass+j
		Replace M2_MOEDA&cSuf  With Yi
		//��������������������������������������������������������������Ŀ
		//� Qdo. o calculo e' por regressao linear e' gravado 0 na taxa. �
		//����������������������������������������������������������������
		If nMoeda < 10
			Replace M2_TXMOED&cSuf With 0.00
		Else
			Replace M2_TXMOE&cSuf With 0.00
		EndIf
		//�����������������������������������������������������Ŀ
		//� Integra Protheus x LEGAL DESK - SIGAPFS             �
		//��������������������������������������������������������
		//Grava na fila de sincroniza��o se o par�metro MV_JFSINC = '1' - SIGAPFS
		If FindFunction("J170GRAVA")
			J170GRAVA("SM2", DToS(SM2->M2_DATA), Alltrim(Str(nOpc)))
		EndIf
	EndIf
	MsUnlock()
	If lMa090Atu
		ExecBlock("MA090ATU",.F.,.F.,{ 4 })
	EndIf
	// Compatibilizacao com Arquivo de Moedas -> CTB
	If CtbInUse()
		GrvCTBCTP()
	EndIf		
Next j

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CalcInflac� Autor � Wagner Xavier         � Data � 23.09.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula as Taxas em outras moedas pela Inflacao             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �CalcInflac(ExpN1, ExpC1)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = no. da moeda a ser calculada a projecao            ���
���          � ExpC1 = indica a origem da chamada: A - Abertura do Sistema���
���          �                                     P - Projecao de Moedas ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CalcInflac(nMoeda,cOrigem)

Local k,dData:=dDataBase,nUltVal,ay:={},nPriVal:=0,nFirst:=0,nDia:=0,nMes:=0
Local nPosAtu:=0,nPosAnt:=0,nTotRegs:=0,nPosCnt:=0,cSavMenuh
Local nPosMoeda, cCampo, nVlrCampo
Local lMa090Atu := ExistBlock("MA090ATU")

cOrigem := IIF(cOrigem==NIL,"P",cOrigem)

dbSelectArea("SM2")
cSuf:=cValToChar(nMoeda)
dbSeek(dData)
nPosMoeda := int( ( At(strzero(nMoeda,2),cSeqMdProj) - 1 ) / 3 ) + 1 

For k:=1 To Len(aTaxaMeses)
	AADD(ay,aTaxaMeses[k][nPosMoeda])
Next k

nIndiceMes	:= 0 // indice do mes
nUltVal 	:= 0

//Regua
For k:=1 To nDias
	
	dData:=dData+1
	If nFirst == 0
		nFirst := 1
		nMes   := Month(dData)
		nDia   := 0
		nPriVal:= M2_MOEDA&cSuf
		nIndiceMes++
	Endif
	IF Month(dData)!= nMes
		nFirst := 0
		k--
		dData:=dData-1
		dbSeek(dData)
		LOOP
	EndIf
	nDia++
	nPosCnt++
	//��������������������������������������������������������������Ŀ
	//� Se a taxa = 0 e origem="A" (Abertura) nao executa projecao   �
	//����������������������������������������������������������������
	If nIndiceMes > 0 .and. nIndiceMes <= Len(ay)
		If ay[nIndiceMes] = 0 .and. cOrigem == "A"
			SM2->(dbSeek(dData))
			// Guarda o ultimo valor para repeti-lo nas datas posteriores que forem
			// criadas pela Abertura do sistema e cujo modulo de calculo anterior
			// foi pelo metodo da Regressao Linear
			//			If SM2->M2_MOEDA&cSuf != 0.000
			//				nUltVal:=SM2->M2_MOEDA&cSuf
			//				LOOP
			//			Endif
			cCampo:= "M2_MOEDA"+cSuf
			nVlrCampo:= SM2->( FieldGet( FieldPos( cCampo ) ) )
			If nVlrCampo!=0.000
				nUltVal:= nVlrCampo
			Endif
		Else
			nUltVal:=RInflac(ay,dData,nPriVal,nDia)
		EndIf
		SM2->(dbSeek(dData))
		If Found() .and. M2_INFORM != "S"
			Reclock("SM2")
		ElseIf M2_INFORM != "S"
			Reclock("SM2",.T.)
		EndIf
		IF M2_INFORM != "S"
			Replace M2_DATA         With dData
			Replace M2_MOEDA&cSuf   With nUltVal
			//��������������������������������������������������������������Ŀ
			//� Grava a taxa de projecao de moeda                            �
			//����������������������������������������������������������������
			If nMoeda < 10
		 		Replace M2_TXMOED&cSuf With ay[nIndiceMes]
			Else
				Replace M2_TXMOE&cSuf With ay[nIndiceMes]
			EndIf
		EndIF
		MsUnlock()
		If lMa090Atu
			ExecBlock("MA090ATU",.F.,.F.,{ 4 })
		EndIf
		// Compatibilizacao com Arquivo de Moedas -> CTB
		If CtbInUse()
			GrvCTBCTP()
		EndIf	
	EndIf
NEXT k

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �cMonthNac � Autor � Wagner Xavier         � Data � 23.09.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica nome do mes em Portugues                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �cMonthNac(data)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function cMonthNac(dData)

			   //"Janeiro  Fevereiro Marco   Abril    Maio     Junho    Julho    Agosto   Setembro Outubro  Novembro Dezembro "	
LOCAL aMeses :=	{ STR0009, STR0010, STR0011, STR0012, STR0013, STR0014, STR0015, STR0016, STR0017, STR0018, STR0019, STR0020 }   
	
Return aMeses[Month(dData)]

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RInflac  � Autor � Jorge Queiroz         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a equacao da projecao da moeda levando em conta a    ���
���          � distribuicao percentual da inflacao atribuida pelo usuario.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpN1 := RInflac(ExpA2,ExpA3)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Devolve o valor da moeda estrangeira               ���
���          � ExpA1 = Array contendo os percentuais da inflacao          ���
���          � ExpD1 = Data a considerar a inflacao                       ���
���          � ExpN2 = Valor da moeda na data imediatamente anterior      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RInflac(ax,dData,nValor,nDia)

Local nMes,nBase,nAno,dUltMes,nM,nDiasMes,nValProj

//��������������������������������������������������������������Ŀ
//� Verifica a data corrente e projeta para a data da inflacao   �
//����������������������������������������������������������������
nMes  := Month(dData)
nAno  := Year(dData)

If Day(dDataBase) = Day(LastDay(dDataBase))
	nBase := Month(M->dDataBase)+1
Else
	nBase := Month(M->dDataBase)
EndIf

nM := IIF(nMes >= nBase,nMes-nBase,(nMes+12)-nBase)
nM++
nMes++
IF nMes > 12;nMes:=1;nAno++;Endif
dUltMes:=CTOD("01/"+StrZero(nMes,2)+"/"+SubStr(Str(nAno,4),3,2),"ddmmyy")
dUltMes--
nDiasMes :=DAY(dUltMes)
//��������������������������������������������������������������Ŀ
//� Calcula a Projecao pela formula corrente                     �
//����������������������������������������������������������������
nVar := (ax[nM])/(nDiasMes*100)
nVar := nVar*10000
nVar := int(nVar)
nVar := nVar/10000
nValProj:=nValor*(1+(nVar)*nDia)

Return nValProj

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RLinear  � Autor � Jorge Queiroz         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a equacao normal de regressao linear de uma distri-  ���
���          � buicao de pontos utilizando o metodo dos minimos quadrados.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpA1 := RLinear(ExpA2,ExpA3)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array contendo K1,K1,Xm,Ym                         ���
���          � ExpA2 = Array contendo a distribuicao de "x"               ���
���          � ExpA3 = Array contendo a distribuicao de "y"               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function rlinear(ay)

Local Sxi:=0,Syi:=0,Sxy:=0,Sx2:=0,Sy2:=0,i,Xm:=0,Ym:=0,Sx,Sy,aForm:={},K1:=0,K2:=0

//��������� _   _ ����������������������������������������������Ŀ
//� Calcula X e Y (media de X e Y)                               �
//����������������������������������������������������������������
FOR i:=1 To Len(ay)
	Sxi+=i
	Syi+=ay[i]
NEXT i

Xm=Sxi/Len(ay)
Ym=Syi/Len(ay)

//��������������������������������������������������������������Ŀ
//� Calculo da distribuicao                                      �
//����������������������������������������������������������������
FOR i:=1 TO Len(ay)
	Sxi := i-Xm
	Syi := ay[i]-Ym
	Sxy += (Sxi*Syi)
	Sx2 += (Sxi**2)
	Sy2 += (Syi**2)
NEXT i

//��������������������������������������������������������������Ŀ
//� Calcula desvio Padrao de X (Sx) e de Y (Sy)                  �
//����������������������������������������������������������������
Sx := ROUND(SQRT(Sx2/Len(ay)),2)
Sy := ROUND(SQRT(Sy2/Len(ay)),2)
If (Len(ay)*Sx*Sy) != 0
	Rxy := Sxy/(Len(ay)*Sx*Sy)
	K1  := Rxy*(Sx/Sy)
	K2  := Rxy*(Sy/Sx)
Endif

//��������������������������������������������������������������Ŀ
//� Devolve array contendo as variaveis da formula de regressao  �
//����������������������������������������������������������������
AADD(aForm,K1)
AADD(aForm,K2)
AADD(aForm,Xm)
AADD(aForm,Ym)

Return aForm

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A090Abert� Autor � Elizabeth A. Eguni    � Data � 18/05/94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Projecao de moedas na Abertura do sistema                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A090Abert(ExpC1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Indica a origem da chamada: A - Abertura           ���
���          �                                     P - Projecao           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function A090Abert()

Local n
Private nNumMoedas:=4, nNumMeses:=1, nDias:=0, cSeqMdProj:="01.02.03.04.05."
Private aMeses := {}

//����������������������������������������������������������������������Ŀ
//�Get no parametro MV_DIASPRO - no. de dias de projecao de moedas       �
//������������������������������������������������������������������������
nDias:= GETMV("MV_DIASPRO")

//����������������������������������������������������������������������Ŀ
//�Monta array com Meses a serem indicados para projecao                 �
//������������������������������������������������������������������������
dDataIni:=dDataBase+1
dDataFim:=dDataBase+nDias
nMes    :=Month(dDataIni)

While nMes != Month(dDataFim)
	AADD(aMeses,Substr(cMonthNac(dDataIni),1,9))
	nAvanco:=1+(Day(LastDay(dDataIni))-Day(dDataIni))
	dDataIni:=dDataIni+nAvanco
	nMes:=Month(dDataIni)
	IF nMes>12;nMes:=1;EndIF
	nNumMeses++
Enddo

AADD(aMeses,Substr(cMonthNac(dDataIni),1,9))

aHeader := ARRAY(nNumMoedas,3)
Private aTaxaMeses := ARRAY(nNumMeses,nNumMoedas+1)

dbSelectArea("SM2")
a090GTAXA()

//�����������������������������������������������������������������Ŀ
//� Funcao CalcInflac c/parametro de "A" (Abertura), p/ as 4 moedas �
//�������������������������������������������������������������������
For n:=1 To 4
	CalcInflac(n+1,"A")
Next

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A090GTAXA � Autor � Elizabeth A. Eguni    � Data � 16/05/94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao do array da taxa de projecao de moedas             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � (VOID)                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Static Function A090GTAXA()

Local cCampo
Local i

For i := 1 To nNumMeses
	aTaxaMeses[i][1] := aMeses[i]
Next
//��������������������������������������������������������������Ŀ
//� Atribui ao array de taxas (aTaxaMeses) os valores gravados   �
//� no arquivo SM2 (campos M2_TXMOED?).                          �
//����������������������������������������������������������������
For i := 2 To nNumMoedas+1
	nCntMeses := 1
	nMes      :=Month(dDataBase+1)
	nTaxaAux  := 0
	nAno      := Year(dDataBase+1)
	While nMes != If((Month(dDataBase+nDias)+1)>12,1,(Month(dDataBase+nDias)+1))
		//��������������������������������������������������������������Ŀ
		//� Se for o primeiro mes do array pesquisa a data atual + 1 dia,�
		//� caso contrario procura pelo primeiro dia do mes de pesquisa. �
		//����������������������������������������������������������������
		If nCntMeses == 1
			dDataSeek := dDataBase + 1
		Else
			dDataSeek := ctod("01/" + str(nMes,2) + "/" + str(nAno,4),"ddmmyy")
		Endif
		SM2 -> ( dbSeek(dDataSeek) )
		If SM2 -> ( !Eof() )
			cSufMoeda := Alltrim( str( val( Substr(cSeqMdProj,(i-1)*3,2) ) ) ) // Alltrim(Substr(cSeqMdProj,i,2))
			//nTaxaAux := SM2->M2_TXMOED&cSufMoeda
			cCampo:= If(nMoeda<10,"M2_TXMOED","M2_TXMOE")+cSufMoeda
			nTaxaAux:= SM2->( FieldGet( FieldPos( cCampo ) ) )
		Endif
		aTaxaMeses[nCntMeses][i] := nTaxaAux
		nCntMeses++
		nMes++
		IF nMes>12
			nMes:=1
			nAno++
		EndIF
	End
Next

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GRVCTBCTP � Autor � Pilar S. Albaladejo   � Data � 06/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava cotacao de moedas no SIGACTB                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GrvCTBCTP()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Static Function GrvCTBCTP(nOpc)

Local aSaveArea := GetArea()
Local cVal
Local cBloq
Local nTaxa
Local nCont    
Local nQtas := iif( __nQuantas < 5 , 5 , __nQuantas )

/*
������������������������������������������������������Ŀ
� Grava CTP -> quando estiver usando SIGACTB           �
��������������������������������������������������������
*/
If ChkFile("CTP") .And. ChkFile("CTO")
	For nCont	:= 1 To nQtas
		cMoeda		:= StrZero(nCont,2)
		cVal		:= Alltrim( Str( nCont ))
		nTaxa		:= CriaVar("CTP_TAXA",.T.)
		cBloq		:= CriaVar("CTP_BLOQ",.T.)
		
		If ChkFile("CTO")
			dbSelectArea("CTO")
			dbSetOrder(1)
			If dbSeek( xFilial("CTO") + cMoeda )
				If ChkFile("CTP")
					dbSelectArea("CTP")
					dbSetOrder(1)
					If !dbSeek( xFilial("CTP") + DTOS(SM2->M2_DATA) + cMoeda )
						RecLock("CTP",.T.)
						Replace CTP_FILIAL		With xFilial("CTP")
						Replace CTP_DATA		With SM2->M2_DATA
						Replace CTP_MOEDA		With cMoeda
						Replace CTP_BLOQ		With cBloq				// Taxa Nao Bloqueada
					Else
						RecLock("CTP")
					EndIf
					If Empty(&("SM2->M2_MOEDA"+cVal))
						Replace CTP_TAXA	With nTaxa
					Else	
						Replace CTP_TAXA 	With &("SM2->M2_MOEDA"+cVal)
					EndIf	
					MsUnlock()
					dbCommit()
				EndIf	
			EndIf	
		EndIf	
	Next nCont
EndIf   

RestArea(aSaveArea)

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Rodrigo de A Sartorio  � Data �15/04/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 
    
Private	aRotina := {}
	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_VIEW   ACCESS 0	//Visualizar
	ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_INSERT ACCESS 0	//Incluir
	ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 	//Alterar
	ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_DELETE ACCESS 0	//Excluir
	ADD OPTION aRotina Title STR0006	Action 'A090Projet'			OPERATION 6	ACCESS 0						// "Projetar"
	
//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("MTA090MNU")
	ExecBlock("MTA090MNU",.F.,.F.)
EndIf

Return(aRotina) 

//-------------------------------------------------------------------
/*	Modelo de Dados
@autor  	Ramon Neves
@data 		16/05/2012
@return 		oModel Objeto do Modelo*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruSM2 := FWFormStruct( 1, "SM2")
Local oModel   := MPFormModel():New('MATA090',,, {|oModel|A090COMMIT(oModel)})   

oModel:AddFields( 'SM2MASTER',, oStruSM2)
oModel:GetModel( 'SM2MASTER' ):SetDescription(STR0007)  //"Atualiza��o de Moedas"
oModel:SetPrimaryKey( { "M2_DATA"} )

Return oModel

//-------------------------------------------------------------------
/*	Interface da aplicacao
@autor  	Ramon Neves
@data 		20/04/2012
@return 		oView Objeto da Interface*/
//-------------------------------------------------------------------

Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'MATA090' )
Local oStruSM2 := FWFormStruct( 2, 'SM2')
Local oView     

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_SM2",oStruSM2,"SM2MASTER")

Return oView  

//-------------------------------------------------------------------
/*	Efetua o Commit
@autor  	Ramon Neves
@data 		20/04/2012
@return 		oView Objeto da Interface*/
//-------------------------------------------------------------------

Static Function A090COMMIT(oModel)

Local xCommit	:= FWFormCommit( oModel )
Local nOpc		:= IIf(oModel <> NIL, oModel:GetOperation(), )

If xCommit
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
	If nOpc == 3 .OR. nOpc == 4	    //Incluir .OR. Alterar
		BEGIN TRANSACTION
			// Compatibilizacao com Arquivo de Moedas -> CTB
			If CtbInUse()
				GrvCTBCTP()
			EndIf	
		END TRANSACTION 	
	EndIf	
	//�����������������������������������������������������Ŀ
	//� Integra Protheus x LEGAL DESK - SIGAPFS             �
	//��������������������������������������������������������
	//Grava na fila de sincroniza��o se o par�metro MV_JFSINC = '1' - SIGAPFS
	If FindFunction("J170GRAVA")
		J170GRAVA("SM2", DToS(oModel:GetValue("SM2MASTER","M2_DATA")), Alltrim(Str(nOpc)))
	EndIf
EndIf 
                                 
Return(xCommit)                

/*/{Protheus.doc} MontaMark

Fun��o monta tela Mark para sele��o das moedas que deseja alterar.

@author francisco.carmo
@since 21/06/2018
@version 1.0
@return aRetMoe, Array com as moedas selecionadas 
@param anGrRad, array of numeric, Vetor com o numero de op��o Radio para montagem de tela.
@param aoGrRad, array of object, Objeto com os dados marcados na op��o Radio.
@type function
/*/
Static Function MontaMark(anGrRad, aoGrRad)

	Local aVetor	:= {}
	Local aRetMoe	:= {}
	Local lMark    	:= .F.
	Local nOpcA		:= 0
	Local oOk      	:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Local oNo      	:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Local nI
	Local cAuxMoeda := ""
	
	For nI := 2 To 99
		cAuxMoeda := GetNewPar( "MV_MOEDA" + Ltrim(Str(nI) ), "x" ) 
		If cAuxMoeda  <> "x" .And. !Empty( cAuxMoeda )
			aAdd( aVetor, {lMark, ALLTRIM(Capital(Substr( cAuxMoeda , 1 , 14))), Alltrim(Str(nI))  })
		Else
			Exit
		Endif
	Next nI 
	
	DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 300,600 PIXEL

	@ 10,10 LISTBOX oLbx FIELDS HEADER " ", "Moeda" SIZE 280,105 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1])

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),	aVetor[oLbx:nAt,2]}}

	@ 125,250 BUTTON "&Ok"       				SIZE 40,20 PIXEL ACTION {|| nOpcA := 1,oDlg:End()} Message STR0028	of oDlg
	@ 125,200 BUTTON "&Cancelar" 				SIZE 40,20 PIXEL ACTION {|| nOpcA := 0,oDlg:End()} Message STR0029 	of oDlg
	@ 125,050 BUTTON "&Marcar/Iverter Sele��o"	SIZE 70,20 PIXEL ACTION {|| MrkAll(@aVetor, oLbx)} Message STR0028	of oDlg

	ACTIVATE MSDIALOG oDlg CENTER
   
	If nOpcA == 1
		For nI := 1 To Len(aVetor)
			If aVetor[nI,1]
				Aadd(aRetMoe, {aVetor[nI,2], aVetor[nI,3] })
				Aadd(anGrRad,Nil)
				Aadd(aoGrRad,1)
			Endif
		Next nI
	Endif

Return aRetMoe

/*/{Protheus.doc} MrkAll
Fun��o marca ou desmarca todos tela Mark para sele��o das moedas que deseja alterar.
@author francisco.carmo
@since 25/06/2018
@version 1.0
@return ${return}, ${return_description}
@param aVetor, array, Vetor com as moedas a serem definidas para proje��o ou regress�o
@param oLbx, object, Objeto com informa��es de escolha feitas pelo usuario.
@type function
/*/
Static Function MrkAll(aVetor, oLbx)
	
	Local nI
	
	For nI := 1 To Len(aVetor)
		If aVetor[nI,1]
			aVetor[nI,1] := .F.
		Else
			aVetor[nI,1] := .T.
		Endif
	Next nI
	oLbx:Refresh()

Return


/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@author  Felipe Raposo
@version P12.1.17
@since   10/07/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return MATI090(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
