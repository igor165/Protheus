#include "FIVEWIN.CH"
#include "CFGX031.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CFGx031  � Autor � Jorge Queiroz         � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o Dicionario de campos disponiveis pelo usuario.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � void CFGx031(void)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Sem Argumentos                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Configurador   � Fun��o Relacionada � Entrada Dados (Todos)���
��������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cheyenne    �16/12/99�25544A� VerIficacao de cDBMS antes do GET para   ���
���            �16/12/99�25544A�alteracao do tamanho do campo. Compatibi- ���
���            �16/12/99�25544A�zacao com ORACLE.                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CFGX031
Return APCFG10()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SayConPad� Autor � Ary Medeiros          � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna consulta padrao do campo                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ExpC1 := SayConPad(ExpC2)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Retorna consulta do campo                         ���
���          � ExpC2 := Nome do Campo                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGx031.PRG                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SayConPad(cCampo)
Local cSavAlias := Alias(), cRet := ""

If Empty(cCampo)
	Return Space(29)
EndIf
DbSelectArea("SXB")
nSavRec := Recno()
DbSeek(cCampo+"1")
If Found()
	cRet := cCampo + " - "+OemToAnsi(Substr(XBDESCRI(),1,25))
	DbGoTo(nSavRec)
Else
	DbGoTo(nSavRec)
	DbSelectArea("SX5")
	DbGoTop()
	While X5_TABELA == "00"
		If AllTrim(cCampo) == AllTrim(X5_CHAVE)
			cRet := cCampo +" - "+Substr(X5DESCRI(),1,25)
			Exit
		EndIf
		DbSkip()
	End
EndIf
If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
EndIf
Return If(Empty(cRet),Space(29),cRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetHelp  � Autor � Ary Medeiros          � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Help do campo                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ExpA1 := GetHelp(ExpC2)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Array com Help do Campo                           ���
���          � ExpC2 := Nome do Campo                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGx031.PRG                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetHelp(cCampo)
Local nHlpHdl, xNumEnt,nRegLid,nLerInd,cIndice,nPosHlp:=0, cHelp,cRet
Local cArqHlp := RetHlpFile()

If Empty(cCampo)
	Return Space(200)
EndIf
If File(cArqHlp)
	nHlpHdl := fOpen(cArqHlp,2 + 64) //FO_READWRITE+FO_SHARED
Else
	Return Space(200)
EndIf

xNumEnt := "  "
FSEEK(nHlpHdl,-2,2)
FREAD(nHlpHdl,@xNumEnt,2)
xNumEnt := Bin2I(xNumEnt)
FSEEK(nHlpHdl,(-10*xNumEnt)-2,2)
*����������������������������������������������������������Ŀ
*� Procura a Entrada no Indice                              �
*������������������������������������������������������������
nRegLid := 0
While nRegLid < xNumEnt
	nLerInd := Iif((xNumEnt-nRegLid)>100,100,xNumEnt-nRegLid)
	cIndice := Space(nLerInd*10)
	FREAD(nHlpHdl,@cIndice,nLerInd*10)
	nPosHlp := AT(cCampo,cIndice)
	If nPosHlp > 0
		nPosHlp+=(nRegLid*10)
		Exit
	EndIf
	nRegLid+=nLerInd
End
If nPosHlp == 0
	cRet := Space(200)
Else
	FSEEK(nHlpHdl,((nPosHlp-1)/10)*200,0)
	cHelp := Space(200)
	FREAD(nHlpHdl,@cHelp,200)
	cRet := cHelp
EndIf
FClose(nHlpHdl)
Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  SeleF3  � Autor � Ary Medeiros          � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Combo Box para selecao da consulta padrao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void SeleF3(Void)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Sem Parametros                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGx031.PRG                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SeleF3()
Local nOpc
Local aOpc := {}
Local cSavAlias := Alias()
Local nSavRec

DbSelectArea("SXB")
nSavRec := Recno()
DbGoTop()
AADD(aOpc,Space(31))
While !Eof()
	If XB_TIPO == "1" .and. XB_ALIAS != "SX5"
		AADD(aOpc,XB_ALIAS+" - "+OemToAnsi(Substr(XBDESCRI(),1,25)))
	EndIf
	DbSkip()
End
DbGoTo(nSavRec)
DbSelectArea("SX5")
DbGoTop()
While X5_TABELA == "00"
	AADD(aOpc,SubStr(X5_CHAVE,1,3)+" - "+Capital(OemToAnsi(Substr(X5DESCRI(),1,25))))
	DbSkip()
End

DbSelectArea(cSavAlias)

Return aOpc

Function SeleFolder(cAlias)
Local nOpc
Local aOpc := {}
Local cSavAlias := Alias()

DEFAULT cAlias := ""

DbSelectArea("SXA")
DbSetOrder(1)
DbSeek(cAlias)
Aadd(aOpc,Space(34))
While !Eof() .And. XA_ALIAS == cAlias
	Aadd(aOpc,XA_ORDEM+" - "+OemToAnsi(XADESCRIC()))
	DbSkip()
End
DbSelectArea(cSavAlias)
Return aOpc

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EditHlp  � Autor � Ary Medeiros          � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a edicao do texto do help do campo                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void EditHlp(ExpC1)                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Nome do campo                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGx031.PRG                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function EditHlp(cCampoH,cHelp)
Local GetList := {},nArea,lCriaHelp:=.F.,nTamInd
Local nSeek,nPosAnt,nPosUlt,nRegLid,nRegs:=0,xBuffer,aBut,nPosHlp := 0
Local lGrava:=.F.
Local cArqHlp := RetHlpFile()

If FILE(cArqHlp)
	nHlpHdl := FOPEN(cArqHlp,2+64) //FO_READWRITE + FO_SHARED
Else
	nHlpHdl := MSFCREATE(cArqHlp)
	FWRITE(nHlpHdl,(CHR(0)+CHR(0)),2)
	Commit
EndIf
If nHlpHdl <= 0
	Tone(3500,1)
	help := .F.
	Return .T.
EndIf
*����������������������������������������������������������Ŀ
*� Recupera o indice                                        �
*������������������������������������������������������������
xNumEnt := "  "
FSEEK(nHlpHdl,-2,2)
FREAD(nHlpHdl,@xNumEnt,2)
xNumEnt := Bin2I(xNumEnt)
FSEEK(nHlpHdl,(-10*xNumEnt)-2,2)
*����������������������������������������������������������Ŀ
*� Procura a Entrada no Indice                              �
*������������������������������������������������������������
nRegLid := 0
While nRegLid < xNumEnt
	nLerInd := Iif((xNumEnt-nRegLid)>100,100,xNumEnt-nRegLid)
	cIndice := Space(nLerInd*10)
	FREAD(nHlpHdl,@cIndice,nLerInd*10)
	nPosHlp := AT(cCampoH,cIndice)
	If nPosHlp > 0
		nPosHlp+=(nRegLid*10)
		Exit
	EndIf
	nRegLid+=nLerInd
End
If nPosHlp = 0
	cHelp := Padr(cHelp,200)
	lCriaHelp:=.T.
Else
	lGrava := .T.
EndIf

If lCriaHelp
	/*�������������������������������������������������Ŀ
	  � Adiciona 200 brancos ao arquivo atual           �
	  ���������������������������������������������������*/
	nPosAnt:=FSEEK(nHlpHdl,0,2)-2
	FWRITE(nHlpHdl,Space(200),200)
	FSEEK(nHlpHdl,-2,2) /// Mudei de 0 para -2
	xNumEnt++
	cIndice := cCampoH + I2BIN(xNumEnt)
	FWRITE(nHlpHdl,cIndice,12)
	nPosUlt:=FSEEK(nHlpHdl,0,2)-12
	/*�������������������������������������������������Ŀ
	  � Regrava o indice deslocando 210 posicoes adiante�
	  ���������������������������������������������������*/
	xNumEnt--
	nRegLid:=0
	While nRegLid < (xNumEnt)
		nRegs := Iif((xNumEnt-nRegLid)>100,100,xNumEnt-nRegLid)
		nRegLid+=nRegs
		/*�������������������������������������Ŀ
		  � Le a Posicao original do Indice     �
		  ���������������������������������������*/
		xBuffer:=Space(nRegs*10)
		nPosAnt-=nRegs*10
		FSEEK(nHlpHdl,nPosAnt,0)
		FREAD(nHlpHdl,@xBuffer,(nRegs*10))
		/*�������������������������������������Ŀ
		  � Grava na nova posicao do indice     �
		  ���������������������������������������*/
		nPosUlt-=nRegs*10
		FSEEK(nHlpHdl,nPosUlt,0)
		FWRITE(nHlpHdl,@xBuffer,(nRegs*10))
	End
	/*�������������������������������������������������Ŀ
	  � Posiciona o ponteiro no fim do arquivo.         �
	  ���������������������������������������������������*/
	  nSeek := FSEEK(nHlpHdl,(xNumEnt)*200,0)
	  If nSeek < 0;FSEEK(nHlpHdl,-2,2);EndIf
	  FWRITE(nHlpHdl,cHelp,200)
	  Commit
Else
	  FSEEK(nHlpHdl,0,0)
	  FSEEK(nHlpHdl,(((nPosHlp-1)/10)*200),0)
	  FWRITE(nHlpHdl,cHelp,200)
	  Commit
EndIf
// Acertar Variaveis Globais do Protheus

*����������������������������������������������������������Ŀ
*� Recupera o indice                                        �
*������������������������������������������������������������
xNumEnt := "  "
FSEEK(nHlpHdl,-2,2)
FREAD(nHlpHdl,@xNumEnt,2)
xNumEnt := Bin2I(xNumEnt)
FSEEK(nHlpHdl,(-10*xNumEnt)-2,2)
cIndice := Space(xNumEnt*10)
FREAD(nHlpHdl,@cIndice,xNumEnt*10)
PutGlbValue("HLPIDXSTR"+cArqHlp+GetEnvServer(),cIndice)
PutGlbValue(cCampoH+cArqHlp+GetEnvServer(),cHelp)
FClose(nHlpHdl)
Return nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � X031BrOk � Autor � Ary Medeiros          � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de validacao para a alteracao do Browse             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGx031.PRG                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function X031BrOk(aArray,nEl)
Local i

For i:= 1 to Len(aArray)
	If aArray[i,1] .and. i <> nEl
		Return .t.
	EndIf
Next
Return .F.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �X031LOG     �Autor � Cristiane Maeda      � Data � 24/10/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava Log de Altera�oes p/ campos Numericos                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGx031.PRG                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function X031LOG(cCpo,nRecno,cValAnt)
Local nHdl,cNome,nTam,xBuffer:= Space(30)
Local CR := Chr(13)+Chr(10)

cNome:=__RELDIR+"X031LOG.##R"
If !File(cNome)
	nHdl:= MSFCREATE(cNome,0)
	xBuffer := OemToAnsi(STR0053) +DTOC(dDataBase)+ CR+CR   // "       Atualiza��o da Base de Dados  "
	FWrite(nHdl,xBuffer,Len(xBuffer))
	xBuffer := OemToAnsi(STR0054) + CR  // "Os campos apresentados abaixo tiveram seus valores  truncados ou"
	FWrite(nHdl,xBuffer,Len(xBuffer))
	xBuffer := OemToAnsi(STR0055)+CR  // "zerados, pois os digitos contidos no campo original  excederam o"
	FWrite(nHdl,xBuffer,Len(xBuffer))
	xBuffer := OemToAnsi(STR0056)+CR+CR  // "tamanho do novo campo."
	FWrite(nHdl,xBuffer,Len(xBuffer))
	FClose(nHdl)
EndIf

nHdl:= FOpen(cNome,2+64)
nTam := FSeek(nHdl,0,2)
Fseek(nHdl,nTam,0)
xBuffer := OemToAnsi(STR0057)+ Str(nRecno,4)+CR  // "Registro : "
FWrite(nHdl,xBuffer,Len(xBuffer))
xBuffer :=	OemToAnsi(STR0045)+" : " + cCpo + CR  // "Campo"
FWrite(nHdl,xBuffer,Len(xBuffer))
xBuffer :=	OemToAnsi(STR0092) + cValAnt + CR +CR  // "Valor Anterior : "
FWrite(nHdl,xBuffer,Len(xBuffer))

FClose(nHdl)

Return


/*/
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o  �OpenSx2Exc� Descr � Abre Sx2 Exclusivo 	� Data �28.11.95	���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
���������������������������������������������������������������������������
/*/
Function OpenSx2Excl(cArqSx2,cIndSx2,cSX2Alias)

DEFAULT cSX2Alias := "SX2"

	*�����������������������������������������������������������������������������Ŀ
	*� Aguarda Liberacao de Arquivos por outras estacoes para abrir SX2 Exclusivo  �
	*�������������������������������������������������������������������������������
	DbSelectArea("SX2")
	dBCloseArea()
	cIndSx2 += "1"
	MsOpEndbf(.t. ,__LocalDriver,cArqSX2,cSX2Alias,.f.,.f.)
	While !Used()
			If !NaoExcl()
				 MsOpEndbf(.t. ,__LocalDriver,cArqSX2,cSX2Alias,.t.,.f.)
				 MsOpenIdx( cIndSx2,"X2_CHAVE",.f.,,,cArqSX2 )
				 Return .F.
			EndIf
			MsOpEndbf(.t. ,__LocalDriver,cArqSX2,cSX2Alias,.f.,.f.)
	End
   MsOpenIdx( cIndSx2,"X2_CHAVE",.f.,,,cArqSX2 )
	Return .T.

// ------------------------------------------------------

Function NaoExcl()
Local lRet := .F.,oDlg,oBtn

DEFINE MSDIALOG oDlg FROM	96,72 TO 341,540 TITLE OemToAnsi(STR0105) PIXEL  OF oMainWnd  // "Atualiza��o de Vers�o"

	@ 8, 20 TO 102, 212 OF oDlg  PIXEL
	@ 24, 34 SAY OemToAnsi(STR0100) SIZE 166, 7 OF oDlg PIXEL  // "Para  Atualizar a  Base de Dados , o Sistema n�o poder� estar em "
	@ 38, 34 SAY OemToAnsi(STR0101) SIZE 166, 7 OF oDlg PIXEL  // "uso por outras esta��es. Neste momento est� sEndo aguardada a "
	@ 52, 34 SAY OemToAnsi(STR0102) SIZE 166, 7 OF oDlg PIXEL  // "libera��o dos arquivos.  Tecle o bot�o  <Confirma>  quando todas "
	@ 66, 34 SAY OemToAnsi(STR0103) SIZE 166, 7 OF oDlg PIXEL  // "as  esta��es  j�  estiverem  fora  do sistema para prosseguir com a"
	@ 78, 34 SAY OemToAnsi(STR0104)	SIZE 165, 7 OF oDlg PIXEL // "atualiza��o.                                                  "

	DEFINE SBUTTON oBtn FROM 107,158 TYPE 1 ACTION (lRet := .T.,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON oBtn FROM 107,186 TYPE 2 ACTION (lRet := .F.,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg
Return lRet

***************************************
FUNCTION x031Str(cCampo,cCposDef)

Local nPos := 1

While nPos != 0
	If cCampo == SubStr(cCposDef,2,Len(cCampo))
		Return(.t.)
	EndIf
	nPos     := At( "/",cCposDef )
	cCposDef := SubStr(cCposDef,nPos+1,Len(cCposDef))
End

Return(.f.)
