#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER720.CH"
#INCLUDE "report.ch"

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER720  � Autor � R.H. - Rogerio Melonio� Data �  21.05.08     ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Contratos Vencidos e a Vencer                         ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER720                                                         ���
������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                 ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                        ���
������������������������������������������������������������������������������͹��
���Programador � Data   � FNC       � Motivo da Alteracao                      ���
������������������������������������������������������������������������������͹��
���Alex        �08/01/10�00261932009�Adaptacao para a Gestao corporativa       ���
���            �        � 	        �Respeitar o grupo de campos de filiais.   ���
���Christiane V�06/01/11�00003442011�Inclus�o de filtro por c�digo do estabele-���
���            �        �           �cimento - Portugal                        ���
���Mohanad Odeh�15/03/12�00058412012�COL: Altera��o no cabe�alho e alinhamento ���
���            �        �     TEQKVI�da impress�o dos valores na fun��o fImpFun���
���Leandro Dr. �16/03/12�00261932009�Adaptacao para a Gestao corporativa       ���
���            �        �           �                                          ���
���Jonathan Glz�07/05/15� PCREQ-4256�Se elimina funcion AjustaSX1 la cual      ���
���            �        �           �realiza la modificacion a diccionario de  ���
���            �        �           �datos(SX1) por motivo de adecuacion nueva ���
���            �        �           �estructura de SXs para V12                ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Function GPER720
Local	aArea 	:= GetArea()
Private cTitulo	:= OemToAnsi(STR0001) //"Relatorio de Contratos Vencidos e a Vencer"
Private aOrd    := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}	//"Matr�cula"###"Centro de Custo"###"Nome"
Private cPerg   := "GP720R"
Private	cString	:= "SRA"				// alias do arquivo principal (Base)

GPER720R3()
RestArea( aArea )
Return

//=====>>>>> Daqui para baixo, trata-se do release 3 e anterior
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER720  � Autor � R.H. - Rogerio Melonio� Data �  21.05.08  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Contratos Vencidos e a Vencer                      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER720(void)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��|            �          �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function GPER720R3()
LOCAL cDesc1  := STR0001		//"Relatorio de Contratos Vencidos e a Vencer"
LOCAL cDesc2  := STR0002		//"Ser� impresso de acordo com os parametros solicitados pelo"
LOCAL cDesc3  := STR0003		//"usu�rio."
LOCAL cString := "SRA"  					// Alias do arquivo principal (Base)
LOCAL aOrd    := {STR0004,STR0005,STR0006}	//"Matr�cula"###"Centro de Custo"###"Nome"
Local cRProc	:= ""

/*
��������������������������������������������������������������Ŀ
� Define Variaveis Locais (Programa)                           �
����������������������������������������������������������������*/
Local aHelpI		:= {}
Local aHelpE		:= {}
Local aHelp			:= {}
Local aRegs			:= {}
Local cHelp			:= ""

/*
��������������������������������������������������������������Ŀ
� Define Variaveis Private(Basicas)                            �
����������������������������������������������������������������*/
Private aReturn  := {STR0007,1,STR0008,2,2,1,"",1 }	// "Zebrado"###"Administra��o"
Private NomeProg := "GPER720"
Private aLinha   := {}
Private nLastKey := 0
Private cPerg    := "GPR720"

/*
��������������������������������������������������������������Ŀ
� Define Variaveis Private(Programa)                           �
����������������������������������������������������������������*/
Private aPosicao1 := {} // Array das posicoes
Private aTotCc1   := {}
Private aTotFil1  := {}
Private aTotEmp1  := {}
Private aInfo     := {}
Private cProcessos:= ""

/*
��������������������������������������������������������������Ŀ
� Variaveis Utilizadas na funcao IMPR                          �
����������������������������������������������������������������*/
Private Titulo
Private AT_PRG   := "GPER720"
Private wCabec0  := 2
Private wCabec1  := ""
Private wCabec2  := ""
Private wCabec3  := ""
Private Contfl   := 1
Private Li       := 0
Private nTamanho := "G"

/*
��������������������������������������������������������������Ŀ
� Verifica as perguntas selecionadas                           �
����������������������������������������������������������������*/
pergunte("GPR720",.F.)
/*
��������������������������������������������������������������Ŀ
� Variaveis utilizadas para parametros                         �
� mv_par01        //  Data de referencia                       �
� mv_par02        //  Da filial                                �
� mv_par03        //  Ate a filial                             �
� mv_par04        //  Do centro de custo                       �
� mv_par05        //  Ate o centro de custo                    �
� mv_par06        //  Do Departamento                          �
� mv_par07        //  Ate Departamento                         �
� mv_par08        //  Do registo                               �
� mv_par09        //  Ate o registo                            �
� mv_par10        //  Do nome                                  �
� mv_par11        //  At� ao nome                              �
� mv_par12        //  Do Tipo de Contrato                      �
� mv_par13        //  Ate Tipo de Contrato                     �
� mv_par14        //  Situacoes a imprimir                     �
� mv_par15        //  Categorias a imprimir                    �
� mv_par16        //  C.C. em Outra Pag.                       �
� mv_par17        //  Imprimir Contratos Vencidos/A Vencer     �
� mv_par18        //  C�digo do Estabelecimento                �
����������������������������������������������������������������*/
cTit := STR0009		//" RELACAO DE CONTRATOS VENCIDOS / A VENCER "

/*
��������������������������������������������������������������Ŀ
� Envia controle para a funcao SETPRINT                        �
����������������������������������������������������������������*/
wnrel:="GPER720"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,cTit,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

/*
��������������������������������������������������������������Ŀ
� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
����������������������������������������������������������������*/
nOrdem     := aReturn[8]
dDataRef   := mv_par01
cFilDe     := mv_par02
cFilAte    := mv_par03
cCcDe      := mv_par04
cCcAte     := mv_par05
cDepDe     := mv_par06
cDepAte    := mv_par07
cMatDe     := mv_par08
cMatAte    := mv_par09
cNomeDe    := mv_par10
cNomeAte   := mv_par11
cTipoDe    := mv_par12
cTipoAte   := mv_par13
cSituacao  := mv_par14
cCategoria := mv_par15
lSalta     := If( mv_par16 == 1 , .T. , .F. )
nImpRel    := mv_par17
cEstab	   := ""

If cPaisLoc == "PTG"
	cEstab := mv_par18
Endif

If	nImpRel == 1
	Titulo  := STR0010	+ "- " + OemToAnsi(STR0014) + PADR(DtoC(dDataRef),10) //" RELACAO DE CONTRATOS VENCIDOS "###//"DATA REFERENCIA: "
ElseIf nImpRel == 2
	Titulo  := STR0011 + "- " + OemToAnsi(STR0014) + PADR(DtoC(dDataRef),10) //" RELACAO DE CONTRATOS A VENCER "###//"DATA REFERENCIA: "
Else
	Titulo  := STR0009 + "- " + OemToAnsi(STR0014) + PADR(DtoC(dDataRef),10)//" RELACAO DE CONTRATOS VENCIDOS / A VENCER "###//"DATA REFERENCIA: "
Endif

If Empty(cEstab)
	If FwGetTamFilial <= (At(" ",STR0012)-1)
		Wcabec1 := STR0012
		Wcabec2 := STR0013
	Else
		Wcabec1 := SubStr(STR0012,1,At(" ",STR0012)-1) + Space(FwGetTamFilial-(At(" ",STR0012)-1))
		WCabec1 += SubStr(STR0012,At(" ",STR0012),Len(STR0012))
		Wcabec2 := Space(FwGetTamFilial-(At(" ",STR0012)-1))+STR0013
	EndIf
Else
	DbSelectArea ("RCO")
	DbSetOrder (1)
	DbSeek (xFilial("RCO") + cEstab)

	Wcabec0 := 3
	Wcabec1 := STR0020 + cEstab + " - " + RCO->RCO_NOME
	If FwGetTamFilial <= 6
		Wcabec2 := STR0012
		Wcabec3 := STR0013
	Else
		Wcabec2 := SubStr(STR0012,1,At(" ",STR0012)-1) + Space(FwGetTamFilial-6)
		WCabec2 += SubStr(STR0012,At(" ",STR0012),Len(STR0012))
		Wcabec3 := Space(FwGetTamFilial-6)+STR0013
	EndIf

EndIf
/*/
         10        20        30        40        50        60        70        80        90        100        110      120       130       140       150       160       170       180       190       200       210       220
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
FILIAL C. CUSTO             DEPARTAMENTO         MATRICULA NOME FUNCIONARIO               INICIO     TERMINO        TIPO DE                                  DIAS      DIAS J�  PERMITE   M�XIMO RENOVACOES PERMITE"
                                                                                              CONTRATO              CONTRATO                                 RESTANTES VENCIDOS RENOVA��O RENOV. REALIZADAS EXCE��O"
  XX   XXXXXXXXX XXXXXXXXX      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     99/99/99 99/99/99 99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   9999      9999      X      9999       9999        X
*/

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| GR720Imp(@lEnd,wnRel,cString)},cTit)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER720  � Autor � R.H. - Rogerio Melonio� Data � 21.05.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Contratos Vencidos e a Vencer                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPR720Imp(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A��o do Codelock                             ���
���          � wnRel       - T�tulo do relat�rio                          ���
���Parametros� cString     - Mensagem	                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GR720Imp(lEnd,WnRel,cString)
/*
��������������������������������������������������������������Ŀ
� Define Variaveis Locais (Basicas)                            �
����������������������������������������������������������������*/
LOCAL CbTxt //Ambiente
LOCAL CbCont
Local aCodFol := {}
Local nCont   := 0
Local X       := 0
Local cAuxPrc
Local nTamCod

/*
��������������������������������������������������������������Ŀ
� Variaveis de Acesso do Usuario                               �
����������������������������������������������������������������*/
Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER720" , "SRA" , "2" ) + " } " )

dbSelectArea( "SRA" )
If nOrdem == 1
	dbSetOrder( 1 )
ElseIf nOrdem == 2
	dbSetOrder( 2 )
ElseIf nOrdem == 3
	DbSetOrder(3)
Endif

DbGoTop()

If nOrdem == 1
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim    := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim    := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim    := cFilAte + cNomeAte + cMatAte
Endif

cFilialAnt := Space(FwGetTamFilial)
cCcAnt     := Space(9)
cDeptAnt   := Space(9)

dbSelectArea( "SRA" )
SetRegua(SRA->(RecCount()))

While !EOF() .And. &cInicio <= cFim
	/*
	��������������������������������������������������������������Ŀ
	� Movimenta Regua Processamento                                �
    ����������������������������������������������������������������*/
    IncRegua()
	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif
	If SRA->RA_FILIAL # cFilialAnt
	    If !fInfo(@aInfo,SRA->RA_FILIAL)
		    Exit
	    Endif
	    dbSelectArea( "SRA" )
	    cFilialAnt := SRA->RA_FILIAL
	Endif
	If cPaisLoc == "PTG" .And. !Empty(cEstab) .And. SRA->RA_DEPTO # cDeptAnt
		dbSelectArea( "SQB" )
		dbSetOrder (1)
		dbSeek ( xFilial("SQB") + SRA->RA_DEPTO)

	    dbSelectArea( "SRA" )
		cDeptAnt := SRA->RA_DEPTO
	Endif

	/*
	��������������������������������������������������������������Ŀ
	� Consiste Parametrizacao do Intervalo de Impressao            �
	����������������������������������������������������������������*/
	 If (SRA->RA_DEPTO < cDepDe)   .Or. (SRA->RA_DEPTO > cDepAte) .Or. ;
	    (SRA->RA_CC < cCcDe)       .Or. (SRA->RA_CC > cCCAte) .Or. ;
		(SRA->RA_NOME < cNomeDe)   .Or. (SRA->RA_NOME > cNomeAte) .Or. ;
	    (SRA->RA_MAT < cMatDe)     .Or. (SRA->RA_MAT > cMatAte) .Or. ;
	    (SRA->RA_TIPOCO < cTipoDe) .Or. (SRA->RA_TIPOCO > cTipoAte) .Or. ;
	    !Empty(SRA->RA_DEMISSA) .Or. Empty(SRA->RA_DATAFIM) .Or. (SRA->RA_DATAINI > dDataRef)
        fTestaTotal()
        Loop
	 ElseIf cPaisLoc == "PTG" .And. !Empty(cEstab)
		If SQB->QB_CESTAB # cEstab
	        fTestaTotal()
	        Loop
		Endif
	 EndIf

	/*
	�����������������������������������������������������������������������Ŀ
	�Consiste Filiais e Acessos                                             �
	�������������������������������������������������������������������������*/
	IF !( SRA->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
		fTestaTotal()
	   	Loop
	EndIF

    /*
    ��������������������������������������������������������������Ŀ
    � Verifica Data De / Ate da Data Fim do Contrato               �
    ����������������������������������������������������������������*/
    If  nImpRel == 1 // Vencidos
	    If  ! (DtoS(SRA->RA_DATAFIM) < DtoS(dDataRef))
		    fTestaTotal()
		    Loop
	    Endif
    Elseif nImpRel == 2 // A Vencer
	    If  ! (DtoS(SRA->RA_DATAFIM) >= DtoS(dDataRef))
		    fTestaTotal()
		    Loop
	    Endif
    Endif

    /*
    ��������������������������������������������������������������Ŀ
    � Verifica Situacao e Categoria do Funcionario                 �
    ����������������������������������������������������������������*/
    If  !( SRA->RA_SITFOLH $ cSituacao ) .OR. !( SRA->RA_CATFUNC $ cCategoria )
	    fTestaTotal()
	    Loop
    Endif

    /*
    ��������������������������������������������������������������Ŀ
    � Calcula o Bloco para o Funcionario                           �
    ����������������������������������������������������������������*/
    aPosicao1 := { } // Limpa Arrays
    Aadd( aPosicao1 , { 0 } )

    /*
    ��������������������������������������������������������������Ŀ
    � Atualiza o Bloco para os Totalizadores                       �
    ����������������������������������������������������������������*/
    nPos0 := nCont + 1
    Atualiza(@aPosicao1,1,nPos0)

    /*
    ��������������������������������������������������������������Ŀ
    � Atualizando Totalizadores                                    �
    ����������������������������������������������������������������*/
    fAtuCont(@aToTCc1)  // Centro de Custo
    fAtuCont(@aTotFil1) // Filial
    fAtuCont(@aTotEmp1) // Empresa

    /*
    ��������������������������������������������������������������Ŀ
    � Impressao do Funcionario                                     �
    ����������������������������������������������������������������*/
    fImpFun()

    fTestaTotal()  // Quebras e Skips
EndDo

/*
��������������������������������������������������������������Ŀ
� Termino do Relatorio                                         �
����������������������������������������������������������������*/
dbSelectArea( "SRA" )
Set Filter to
dbSetOrder(1)
Set Device To Screen
If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

Return

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �Atualiza      � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Atualiza(aMatriz,nElem,nPos0)					     		�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function Atualiza(aMatriz,nElem,nPos0)

aMatriz[nElem,1] := nPos0

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fTestaTotal   � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fTestaTotal()									     		�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function fTestaTotal

dbSelectArea( "SRA" )
cFilialAnt := SRA->RA_FILIAL              // Iguala Variaveis
cCcAnt     := SRA->RA_CC
dbSkip()

If Eof() .Or. &cInicio > cFim
	fImpCc()
	fImpFil()
	fImpEmp()
Elseif cFilialAnt # SRA->RA_FILIAL
	fImpCc()
	fImpFil()
Elseif cCcAnt # SRA->RA_CC
	fImpCc()
Endif

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fImpFun		  � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fImpFun()									     			�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function fImpFun()
Local cTabGen := If(cPaisLoc == "PER","S013","S011")
/*/
FILIAL C. CUSTO             DEPARTAMENTO         MATRICULA NOME FUNCIONARIO               INICIO   TERMINO  TIPO DE                                               DIAS      DIAS J�  PERMITE   M�XIMO RENOVACOES PERMITE
                                                                                              CONTRATO      CONTRATO                                              RESTANTES VENCIDOS RENOVA��O RENOV. REALIZADAS EXCESSAO

  XX   XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99/99/99 99/99/99 99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9999      9999      X        9999     9999        X
/*/
dbSelectArea("RGE")
dbSetOrder(1) // ordem por RGE_FILIAL+RGE_MAT+RGE_TIPOCO+RGE_MOVIM+DTOS(RGE_ RGE_DATAINI)
dbSeek(xFilial("RGE")+SRA->RA_MAT+SRA->RA_TIPOCO)
nQtRge    := 0 // contador de renovacoes do mesmo tipo de contrato
nQtdRenov := 0// quantidade maxima de renovacoes
While !Eof() .And. RGE->RGE_FILIAL+RGE->RGE_MAT+RGE->RGE_TIPOCO == xFilial("RGE")+SRA->RA_MAT+SRA->RA_TIPOCO
	If RGE->RGE_MOVIM == "R"
		nQtRge++
	Endif
	dbSkip()
EndDo
dbSelectArea("SRA")
nQtdRenov := Val(fDescRCC(cTabGen,SRA->RA_TIPOCO,1,2,65,4)) // quantidade maxima de renovacoes
cTipoCon  := fDescRcc(cTabGen,SRA->RA_TIPOCO,1,2,1,52)
cTipoCon  := Substr(cTipoCon,1,2)+"-"+Substr(cTipoCon,3,50)
cQtRge    := Transform(nQtRge,"9999")
cQtdRenov := Transform(nQtdRenov,"9999")
nPerMin	  := Val(fDescRCC(cTabGen,SRA->RA_TIPOCO,1,2,69,4)) // periodo minimo de renovacao apos a ultima
nPerMax	  := Val(fDescRCC(cTabGen,SRA->RA_TIPOCO,1,2,73,4)) // periodo maximo de renovacao apos a ultima
lExcessao := (nPerMin > 0) .And. (nPerMax > 0) // flag para indicar se os campos de excessao estao preenchidos
cPermite  := Iif(lExcessao,"S","N")
If nImpRel = 1
	cDiasVenc := Iif(SRA->RA_DATAFIM<dDataRef,Transform((dDataRef-SRA->RA_DATAFIM),"9999"),Space(4))
	cDiasRest := Space(4)
ElseIf nImpRel = 2
	cDiasVenc := Space(4)
	cDiasRest := Iif(SRA->RA_DATAFIM>=dDataRef,Transform((SRA->RA_DATAFIM-dDataRef),"9999"),Space(4))
Else
	cDiasVenc := Iif(SRA->RA_DATAFIM<dDataRef,Transform((dDataRef-SRA->RA_DATAFIM),"9999"),Space(4))
	cDiasRest := Iif(SRA->RA_DATAFIM>=dDataRef,Transform((SRA->RA_DATAFIM-dDataRef),"9999"),Space(4))
Endif
/*
         10        20        30        40        50        60        70        80        90        100        110      120       130       140       150       160       170       180       190       200       210       220
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
FILIAL C. CUSTO             DEPARTAMENTO         MATRICULA NOME FUNCIONARIO               INICIO     TERMINO        TIPO DE                                  DIAS      DIAS J�  PERMITE   M�XIMO RENOVACOES PERMITE"
                                                                                              CONTRATO              CONTRATO                                 RESTANTES VENCIDOS RENOVA��O RENOV. REALIZADAS EXCE��O"
*/
cDet := PadR(SRA->RA_FILIAL,Max(FWGETTAMFILIAL,8))+Space(1)+PadR(SRA->RA_CC,20)+Space(1)+Padr(SRA->RA_DEPTO,20)+Space(1)+SRA->RA_MAT+Space(4)+PadR(SRA->RA_NOME,30)
cDet += Space(1)+DtoC(SRA->RA_DATAINI)+Space(1)+DtoC(SRA->RA_DATAFIM)+Space(5)+PadR(cTipoCon,40)+Space(1)+Padr(AllTrim(cDiasRest),9)+Space(1)+PadR(AllTrim(cDiasVenc),8)+Space(1)+PadR(AllTrim(SRA->RA_RENOVA),9)+Space(1)+PadR(AllTrim(cQtdRenov),6)
cDet += Space(1)+PadR(AllTrim(cQtRge),10)+Space(1)+cPermite

Impr(cDet,"C")

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fImpCc		  � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fImpCc()									     			�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function fImpCc()

Local lRetu1 := .T.

If  Len(aTotCc1) == 0 .Or. nOrdem # 2
	Return Nil
Endif

cDet := Repl("-",220)
Impr(cDet,"C")
cDet := STR0015+ cCcAnt +" - "+DescCc(cCcAnt,cFilialAnt) + Space(11)		//"TOTAL C.CUSTO -> "
lRetu1 := fImpComp(aTotCc1) // Imprime

aTotCc1 :={}      // Zera

cDet := Repl("-",220)
Impr(cDet,"C")

/*
��������������������������������������������������������������Ŀ
� Salta de Pagina na Quebra de Centro de Custo (lSalta = .T.)  �
����������������������������������������������������������������*/
If lSalta
	Impr("","G")
Endif

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fImpFil		  � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fImpFil()									     			�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function fImpFil()

Local lRetu1 := .T.
Local cDescFil

If  Len(aTotFil1) == 0
	Return Nil
Endif

If  nOrdem # 2
	cDet := Repl("-",220)
	Impr(cDet,"C")
Endif

cDescFil := aInfo[1]
cDet     := STR0016 + cFilialAnt+" - " + cDescFil + Space(24)	//"TOTAL FILIAL -> "

lRetu1 := fImpComp(aTotFil1) // Imprime

aTotFil1 :={}      // Zera

cDet := Repl("-",220)
Impr(cDet,"C")

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fImpEmp		  � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fImpEmp()									     			�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function fImpEmp()

Local lRetu1 := .T.

If  Len(aTotEmp1) == 0
	Return Nil
Endif

cDet := STR0017+aInfo[3]+Space(3)	//"TOTAL EMPRESA -> "

lRetu1 := fImpComp(aTotEmp1) // Imprime

aTotEmp1 :={}      // Zera

cDet := Repl("-",220)
Impr(cDet,"C")

Impr("","F")

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fImpComp	  � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o � Complemento da Impressao                                   �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fImpComp(aPosicao)							     			�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function fImpComp(aPosicao)

/*
��������������������������������������������������������������Ŀ
� Resultado de Impressao para testar se tudo nao esta zerado   �
����������������������������������������������������������������*/
Local nResImp := 0

/*
��������������������������������������������������������������Ŀ
� Auxiar para Tratamento do Bloco de Codigo                    �
����������������������������������������������������������������*/
AeVal(aPosicao,{ |X| nResImp += X[1] })  // Testa se a Soma == 0

/*
��������������������������������������������������������������Ŀ
� Imprime se Possui Valores                                    �
����������������������������������������������������������������*/
If  nResImp > 0
	cDet += TRANSFORM(aPosicao[1,1],"@E 999,999,999")
	cDet += If( aPosicao[1,1] == 1 ,STR0018,STR0019)	//"  FUNCIONARIO"###"  FUNCIONARIOS"
	Impr(cDet,"C")
	Return( .T. )
Else
	Return( .F. )
Endif

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fAtuCont	  � Autor � Equipe de RH      � Data �04/01/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o � Atualiza Acumuladores                                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fAtuCont(aArray1)							     			�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper190 												    �
�������������������������������������������������������������������������*/
Static Function fAtuCont(aArray1)

If  Len(aArray1) > 0
	aArray1[1,1] += aPosicao1[1,1]
Else
	aArray1      := Aclone(aPosicao1)
Endif

Return Nil
