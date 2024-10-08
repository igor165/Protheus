#include "Protheus.ch"
#INCLUDE "CSAM090.CH"

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAM090  � Autor � Emerson Grassi Rocha  � Data � 28/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Aprovavao de Novas Vagas.                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAM090(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAM090                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�18/07/14�TPZVUR�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function CSAM090
Local aSays	:={ }, aButtons:= { } 				//<== arrays locais de preferencia
Local nOpca := 0
Local cAlias:= "RBD"
Local nReg	:= 1
Local nOpc  := 1

Private aRotina 	:= {{"","",0,6}}
Private cCadastro 	:= OemToAnsi(STR0001)		//"Aprovacao de Abertura de Vagas"
Private nSavRec
Private aQS_VAGA    := {}
Private nSavSX8     := GetSX8Len()

Pergunte("CSA100",.F.)

AADD(aSays,OemToAnsi(STR0004) )  //"Este programa tem o objetivo de Aprovar ou nao "
AADD(aSays,OemToAnsi(STR0005) )  //"o aumento de quadro de funcionarios. Se for aprovado, "
AADD(aSays,OemToAnsi(STR0006) )  //"as vagas serao abertas automaticamente no modulo de Recrutamento. "

AADD(aButtons, { 5,.T.,{|| Pergunte("CSA100",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()} } )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
If nOpca == 1
   Processa({|lEnd| CSA090Apro(cAlias,nReg,nOpc),STR0001}) //"Aprovacao de Abertura de Vagas"
EndIf

Return Nil

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CSA090Apro� Autor � Emerson Grassi Rocha  � Data � 28/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento de Necessidades de Aumento de Quadro.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSA090Proc()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAM090													  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Csa090Apro(cAlias,nReg,nOpc)
Local nGrava 	:= 0
Local oGet, oDlg
Local aAlter 	:= {"RBD_XXQTAP","RBD_XXDATA"}
Local aRecno	:= {}   //--Array que contem o Recno() dos registros da aCols

//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private aCols 	:= {}
Private aHeader	:= {}

//��������������������������������������������������������������Ŀ
//� Carregando as Perguntas 									 �
//����������������������������������������������������������������
cFilDe		:= mv_par01		// Filial De
cFilAte 	:= mv_par02		// Filial Ate
cCcDe		:= mv_par03		// Centro de Custo De
cCcAte		:= mv_par04		// Centro de Custo Ate
cFunDe      := mv_par05 	// Funcao De
cFunAte     := mv_par06 	// Funcao Ate
cAnoMesDe   := mv_par07 	// Ano/Mes De
cAnoMesAte  := mv_par08 	// Ano/Mes Ate

cFilDe := Iif(xFilial("RBD")== Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), cFilDe)

//Monta GetDados
If !Csa090Mont(cAlias,nReg,nOpc,@aRecno)
	Return .T.
EndIf

SETAPILHA()

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
 
aGdCoord	:= { (aObjSize[1,1]+20), (aObjSize[1,2]+5)	, (aObjSize[1,3]-5), (aObjSize[1,4]-5) }	

DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	oGet   := MSGetDados():New(aGdCoord[1],aGdCoord[2],aGdCoord[3],aGdCoord[4],nOpc,"CSA090LOk","AlwaysTrue",,.T.,aAlter,1,,300,,,,,oDlg)
     
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar	(oDlg,{|| If(oGet:TudoOk(),(nGrava:= 1,oDlg:End()),.F.) },;
											{||nGrava:=0,oDlg:End()})
											
If 	nGrava == 1
   	PcoIniLan("000080")
	Begin Transaction
		Csa090Grv(aRecno)
		EvalTrigger()
	End Transaction
	PcoFinLan("000080")
	
EndIf	                               
PcoFreeBlq("000080")

dbSelectArea("RBD")
dbSetOrder(1)
dbGoTop()

Return .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CSA090Grv � Autor � Emerson Grassi Rocha  � Data � 28/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento de Necessidades de Aumento de Quadro.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSA090Grv()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAM090													  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CSA090Grv(aRecno)

Local i 		:= 0
Local nReg		:= 0 

Local nPosCC	:= GdFieldPos("RBD_CC")
Local nPosAMes	:= GdFieldPos("RBD_ANOMES")
Local nPosFunc	:= GdFieldPos("RBD_FUNCAO") 
Local nPosDFun	:= GdFieldPos("RBD_DFUNCA") 
Local nPosXQtAp	:= GdFieldPos("RBD_XXQTAP")
Local nPosXDtAp	:= GdFieldPos("RBD_XXDATA")

Local cUsrApro	:= Subs(cUserName,1,10) 
Local cCC		:= ""
Local cAnoMes	:= ""
Local cFunc		:= ""
Local cDFunc	:= ""
Local nQtApro	:= 0
Local nVlApro	:= 0
Local dDtApro	:= dDataBase
Local lCSM090Grv:= ExistBlock("CSM090Grv")

dbSelectArea("RBD")
dbSetOrder(1)

For i := 1 to Len(aCols) 
	cCC		:= Iif(nPosCC 	 	> 0, aCols[i][nPosCC]	, "")    
	cAnoMes := Iif(nPosAMes	 	> 0, aCols[i][nPosAMes], "")    
	cFunc	:= Iif(nPosFunc	 	> 0, aCols[i][nPosFunc], "")
	cDFunc	:= Iif(nPosDFun	 	> 0, aCols[i][nPosDFun], "")  
	nQtApro := Iif(nPosXQtAp 	> 0, aCols[i][nPosXQtAp], 0)
    dDtApro := Iif(nPosXDtAp	> 0, aCols[i][nPosXDtAp], dDataBase)
        
	nReg	:= aRecno[i]	          

	If nQtApro > 0 	
	
		dbSelectArea("RBD")
 		dbGoto(nReg)
 		
 		nVlApro	:= ((RBD->RBD_VLPREV - RBD->RBD_VLATUA) /;
					(RBD->RBD_QTPREV-RBD->RBD_QTATUA)) * nQtApro
	
		Reclock("RBD",.F.)
			RBD->RBD_QTAPRO += nQtApro 
			RBD->RBD_VLAPRO += nVlApro
		MsUnlock()  

		dbSelectArea("RBE")
		dbSetOrder(1)
		Reclock("RBE",.T.) 
			RBE->RBE_FILIAL	:= xFilial("RBE", 	RBD->RBD_FILIAL)
			RBE->RBE_CC		:= cCC
			RBE->RBE_ANOMES	:= cAnoMes
			RBE->RBE_FUNCAO	:= cFunc
			RBE->RBE_DTAPRO	:= dDtApro
			RBE->RBE_QTAPRO	:= nQtApro 
			RBE->RBE_VLAPRO	:= nVlApro
			RBE->RBE_USUARI	:= cUsrApro
		MsUnlock()  
		                     
		dbSelectArea("SQS")
		dbSetOrder(1)
		Reclock("SQS",.T.)                 
			SQS->QS_FILIAL	:= xFilial("SQS",	RBD->RBD_FILIAL)
			M->QS_VAGA 		:= aQS_VAGA[i]
			SQS->QS_VAGA 	:= M->QS_VAGA
			SQS->QS_DESCRIC	:= cDFunc
			SQS->QS_AREA	:= ""
			SQS->QS_CC		:= cCC
			SQS->QS_FUNCAO	:= cFunc
			SQS->QS_NRVAGA	:= nQtApro
			SQS->QS_SOLICIT	:= cUsrApro
			SQS->QS_DTABERT	:= dDtApro
		MsUnlock()    
		
		//��������������������������������������������������������������Ŀ
		//�Ponto de entrada para gravacao de outros campos no SQS        �  
		//�para cada vaga gravada.                                       �
		//����������������������������������������������������������������
		If lCSM090Grv
			ExecBlock("CSM090Grv",.F.,.F.)
		EndIf	
		
		PcoDetLan("000080","01","CSAM090")
	EndIf
Next i

If __lSX8
	While ( GetSX8Len() > nSavSX8 )
		ConFirmSX8()
	EndDo
EndIf

aQS_VAGA := {}
	
Return Nil
          
          
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Csa090Mont� Autor � Emerson Grassi Rocha � Data � 30/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta as getdados dos arquivos                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �CSAM090        �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Csa090Mont(cAlias, nReg, nOpc, aRecno)
Local aSaveArea	:= GetArea()
Local cAcessaRBD:= &("{ || " + ChkRH(FunName(),"RBD","2") + "}")
Local nCntFor 	:= 0
Local nUsado  	:= 0
Local nAcols  	:= 0
Local cCond		:= ""
Local aFields 	:= {"RBD_FILIAL","RBD_QTPREV","RBD_VLPREV"}
Local lRet 		:= .T.

cCond:= RA2->RA2_FILIAL+RA2->RA2_CALEND

// Monta o Header 
//-- Mostra Filial se a tabela Quadro de Funcionarios for exclusiva
If !Empty(xFilial("RBD"))
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("RBD_FILIAL")
	Aadd(aHeader,{X3TITULO("RBD_FILIAL"),"RBD_XFIL","@!",	FWGETTAMFILIAL,0,"","�","N"," ","V" } )	//"Filial"
	dbSelectArea("SX3")
	dbSetOrder(1)
Endif

TrmHeader(@aHeader,aFields,"RBD")

// Esses campos nao existem no SX3 estao sendo criados internamente neste programa
Aadd(aHeader,{OemtoAnsi(STR0010),"RBD_XXQNEC","@E 99,999",		05,0,"","�","N"," ","V" } )	//"Qt.Necess."
Aadd(aHeader,{OemtoAnsi(STR0011),"RBD_XXVNEC","@E 9999,999.99",	12,2,"","�","N"," ","V" } )	//"Vl.Necess." 
Aadd(aHeader,{OemtoAnsi(STR0007),"RBD_XXQTAP","@E 99,999",		05,0,"","�","N"," ","V" } )	//"Aprovar(Qt)"
Aadd(aHeader,{OemtoAnsi(STR0009),"RBD_XXDATA","99/99/99",			08,0,"","�","D"," ","V" } )	//"Data Aprov."
          
nUsado := Len(aHeader)

dbSelectArea("RBD")
dbSetOrder(1)
dbSeek(cFilDe,.T.)

While ! Eof()

	//��������������������������������������������������������������Ŀ
	//� Consiste controle de acessos 								 |
	//����������������������������������������������������������������
    If !Eval(cAcessaRBD)
       dbSkip()
       Loop
    EndIf                                                             
    
	//��������������������������������������������������������������Ŀ
	//� Se Quantidade ou Valor menor/igual a zero nao mostra.		 |
	//����������������������������������������������������������������
	If (RBD->RBD_QTPREV - RBD->RBD_QTATUA - RBD->RBD_QTAPRO) <= 0
		dbSkip()
		Loop
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Consiste os Parametros 										 �
	//����������������������������������������������������������������
	If RBD->RBD_FILIAL	< cFilDe 	.Or. RBD->RBD_FILIAL 	> cFilAte 	.Or.;
	   RBD->RBD_CC 		< cCcDe 	.Or. RBD->RBD_CC		> cCcAte	.Or.;		
	   RBD->RBD_FUNCAO	< cFunDe	.Or. RBD->RBD_FUNCAO	> cFunAte   .Or.;  
	   RBD->RBD_ANOMES	< cAnoMesDe	.Or. RBD->RBD_ANOMES	> cAnoMesAte  

	   dbSkip()
	   Loop
	Endif
	
	Aadd(aCols,Array(nUsado+1))
	nAcols := Len(aCols)
	aAdd(aQS_VAGA, GetSx8Num("SQS","QS_VAGA"))

	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor][10] != "V")
			aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			If Alltrim(aHeader[nCntFor][2]) == "RBD_XXQTAP"		
				aCols[nAcols][nCntFor] := 0
			ElseIf Alltrim(aHeader[nCntFor][2]) == "RBD_XXDATA"
				aCols[nAcols][nCntFor] := dDataBase
			ElseIf Alltrim(aHeader[nCntFor][2]) == "RBD_XXQNEC"
				aCols[nAcols][nCntFor] := ; 
					(RBD->RBD_QTPREV - RBD->RBD_QTATUA - RBD->RBD_QTAPRO)
			ElseIf Alltrim(aHeader[nCntFor][2]) == "RBD_XXVNEC"
				aCols[nAcols][nCntFor] := ;
					(RBD->RBD_VLPREV - RBD->RBD_VLATUA - RBD->RBD_VLAPRO) 
			ElseIf Alltrim(aHeader[nCntFor][2]) == "RBD_XFIL"
				aCols[nAcols][nCntFor] := RBD->RBD_FILIAL		
            Else
				aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			EndIf
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.

    Aadd(aRecno, Recno())
	    
	dbSkip()
EndDo
If Len(aCols) == 0 .or. (Len(aCols) == 1 .And. Empty(aCols[1][1]))
	Aviso(OemToAnsi(STR0002), OemToAnsi(STR0003), {"OK"}) //"Atencao"#"Nao ha nenhum item para Aprovar."
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CSA090Lok � Autor � Emerson Grassi Rocha  � Data � 28/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da GetDados.								      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSA090Lok()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAM090													  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CSA090LOk()

Local lRet		:= .T.                     
Local nPosFil	:= GdFieldPos("RBD_XFIL") 
Local nPosCC	:= GdFieldPos("RBD_CC") 
Local nPosAMes	:= GdFieldPos("RBD_ANOMES") 
Local nPosFunc	:= GdFieldPos("RBD_FUNCAO") 
Local nPosXQtAp	:= GdFieldPos("RBD_XXQTAP")
Local cChave	:= "" 
Local cFilRBD	:= IF( !Empty(nPosFil), aCols[n][nPosFil], Nil) 	
       
If nPosCC > 0 .And. nPosAMes > 0 .And. nPosFunc > 0
	cChave := aCols[n][nPosCC] + aCols[n][nPosAMes]+ aCols[n][nPosFunc]
                                   
	dbSelectArea("RBD")
	dbSetOrder(1)
	If dbSeek(xFilial("RBD", cFilRBD)+ cChave)
		If 	aCols[n][nPosXQtAp] > (RBD->RBD_QTPREV - RBD->RBD_QTATUA - RBD->RBD_QTAPRO) // .Or.;
			Aviso(OemToAnsi(STR0002), OemToAnsi(STR0012), {"OK"}) //"Atencao"#"Quantidade ou Valor informado maior que o necessario!"
		    lRet := .F.
		EndIf
		If lRet
			M->QS_VAGA := aQS_VAGA[n]
			lRet := PcoVldLan('000080','01','CSAA090')
		EndIf	
	Else
		lRet := .F.
	EndIf
EndIf 

Return lRet          

