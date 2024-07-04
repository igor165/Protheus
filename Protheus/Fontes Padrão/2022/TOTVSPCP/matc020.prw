#INCLUDE "FIVEWIN.CH"
#INCLUDE "MATC020.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATC020  � Autor � Marcelo A. Iuspa      � Data �17.08.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe o Histograma da Carga Maquina    / v12               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � MATC020()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATC020()
Local aUso := {}          

Processa({|| aUso := C020Init()})
If select("SH8") > 0
	dbSelectArea("SH8")
	dbCloseArea()
Endif
dbSelectArea("SH1")
C020Visual(aUso)
dbSelectArea("SH1")
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C020Init � Autor � Ary Medeiros          � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria arquivo de trabalho para histograma                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � aUso := C020Init()                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function C020Init()
Local cDirPcp := Alltrim(GetMV("MV_DIRPCP")), cCargaFile, nHdl, nCalHdl
Local cBuffer, aCarga := Array(8), cString, cCalStr, nAloc, nTrab, i
Local nPct, aUso := {}  
Local cNameCarga	:= ""        
Local cEmp690 		:= Alltrim(STR(a690FilNum(FwCodFil())))
Default lAutoMacao  := .F.

cNameCarga := "CARGA"+cEmp690

ProcRegua(SH1->(LastRec()))
If Empty(cDirPCP)
	IF !lAutoMacao
		HELP(' ',1,STR0004 ,,STR0005,2,0,,,,,,{STR0006}) 
		//"Configura��o de Parametros" - "Parametro n�o configurado" - "Definir as informa��es dos parametros MV_DIRPCP, pelo configurador" 
		return
	ENDIF
Else
	cDirPCP += IIf( Right(cDirPCP,1) # "\" , "\" , "" )
EndIf

If OpenSemSH8()
	//��������������������������������������������������������������Ŀ
	//� Le arquivo CARGA.MAQ para montar array de controle           �
	//� aCarga[1] := Handler do arquivo                              �
	//� aCarga[2] := Dia da geracao da carga de maquinas             �
	//� aCarga[3] := Periodo                                         �
	//� aCarga[4] := Precisao                                        �
	//� aCarga[5] := Numero de maquinas                              �
	//� aCarga[6] := Indice                                          �
	//� aCarga[7] := Tamanho do registro                             �
	//� aCarga[8] := Handler do arquivo de calendario                �
	//����������������������������������������������������������������
	//
	//dbSelectArea("SX2")
	dbSetOrder(1)
	dbSeek("SH8")
	cCargaFile := cDirPCP+cNameCarga+".MAQ"
	nHdl := FOpen(cCargaFile,0+64)
	If nHdl == -1
		Help(" ",1,"SemCarga")
		Return aUso
	Endif
	cCalFile := cDirPCP+cNameCarga+".CAL"
	nCalHdl  := FOpen(cCalFile,0+64)
	If nCalHdl == -1
		Help(" ",1,"SemCarga")
		Return aUso
	Endif
	cBuffer := Space(8)
	aCarga[1] := nHdl
	Fseek(nHdl,-8,2)
	FRead(nHdl,@cBuffer,8)
	aCarga[2] := CtoD(cBuffer) // Dia da carga
	cBuffer := Space(2)
	Fseek(nHdl,-10,2)
	Fread(nHdl,@cBuffer,2)
	aCarga[3] := Bin2I(cBuffer) // Periodo
	Fseek(nHdl,-12,2)
	Fread(nHdl,@cBuffer,2)
	aCarga[4] := Bin2I(cBuffer) // Precisao
	FSeek(nHdl,-14,2)
	FRead(nHdl,@cBuffer,2)
	aCarga[5] := Bin2I(cBuffer) // Numero de maquinas
	cBuffer := Space(7*aCarga[5])
	FSeek(nHdl,-14-(7*aCarga[5]),2)
	FRead(nHdl,@cBuffer,7*aCarga[5])
	aCarga[6] := cBuffer // Indice da carga de maquinas
	aCarga[7] := (24 * aCarga[3] * aCarga[4]) / 8 // Tamanho do registro
	aCarga[8] := nCalHdl
	
	dbSelectArea("SH1")
	dbSeek(xFilial("SG1"))	
	
	While !Eof() .and. H1_FILIAL = xFilial("SG1") 
		IncProc(STR0001 + " " + AllTrim(SH1->H1_DESCRI)) // "Recurso"
		cString := Space( aCarga[7] )
		cCalStr := Space( aCarga[7] )
		FSeek(aCarga[1],PosiMaq(H1_CODIGO,aCarga[6])*aCarga[7])
		FRead(aCarga[1],@cString,aCarga[7])
		FSeek(aCarga[8],PosiMaq(H1_CODIGO,aCarga[6])*aCarga[7])
		FRead(aCarga[8],@cCalStr,aCarga[7])
		nAloc := 0
		nTrab := 0
		If Len(cCalStr) > 0
			For i:= 1 to (aCarga[7]*8)
				IF !lAutoMacao
					If BitOn(cCalStr,i,1,aCarga[7]) = 0
						nTrab++
					ElseIf BitOn(cString,i,1,aCarga[7]) = 0
						nAloc++
					EndIf
				ENDIF
			Next i
		Endif
		nPct := (nAloc/((aCarga[7]*8)-nTrab))*100
		Aadd(aUso, {SH1->H1_DESCRI, nPct, Nil, Nil})
		dbSelectArea("SH1")
		dbSkip()
	End
	FClose(nHdl)
	FClose(nCalHdl)
	
	//-- Fecha Semaforo do SH8 para permitir seu uso
	ClosSemSH8()

EndIf
return aUso

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �C020Visual� Autor � Marcelo A. Iuspa      � Data �17.08.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o formulario para exibicao do Histograma e exibe     ���
���          � os recursos e o respectivo meter baseado no array aUso     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �C020Visual(aUso)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aUso                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function C020Visual(aUso)
Local oDlg , oScrollBox
Local cVar := "", nVar := 0, x
Default lAutoMacao := .F.

If Len(aUso) == 0
	Return Nil
Endif	

oFont:=TFont():New("Arial",0,-10)
IF !lAutoMacao
	DEFINE MSDIALOG oDlg TITLE STR0002 FROM 0,0 TO 325,625 PIXEL  // "Histograma da Carga M�quina"
	oScrollBox := TScrollBox():new(oDlg,20,10, 120,295,.T.,.T.,.T.)
	DEFINE SBUTTON FROM 147,265 TYPE  2 ACTION oDlg:End() ENABLE OF oDlg PIXEL

	For x := 1 to Len(aUso)
		@ (20 * x)-7,004 Say   aUso[x, 3] PROMPT cVar FONT oFont SIZE 42,14 Of oScrollBox PIXEL
		@ (20 * x)-6,050 METER aUso[x, 4] VAR    nVar TOTAL 100  SIZE 225,8 OF oScrollBox NOPERCENTAGE PIXEL
		aUso[x, 3]:bSetGet := &("{|u| If(pCount() == 0, aUso["+Str(x)+",1], aUso["+Str(x)+",1]:=u)}")
		aUso[x, 4]:bSetGet := &("{|u| If(pCount() == 0, aUso["+Str(x)+",2], aUso["+Str(x)+",2]:=u)}")	
		aUso[x, 3]:SetText(aUso[x,1])
		aUso[x, 4]:Set(    aUso[x,2])
	next


	@ (20 * x)-10, 010 Say " " SIZE 40,8 Of oScrollBox PIXEL  // Para margem inferior no ScrollBox
	For x := 0 to 100 step 5
		If x % 10 = 0
			@ 12, 57 + (225 * x / 100) say oSay PROMPT cVar FONT oFont SIZE 25,8 Of oDlg PIXEL
			oSay:bSetGet := &("{|u| If(pCount() == 0, "+Str(x,3)+", cVar:=u)}")	
			oSay:SetText(Str(x, 3))
		Else
			@ 15, 61 + (225 * x / 100) say "'" SIZE 8,8 Of oDlg PIXEL
		Endif	
	Next	
	@ 03, 127 say STR0003 Font TFont():New("Arial",0,-14)CENTER SIZE 65,8 Of oDlg PIXEL   // "Aloca��o (em %)"

	ACTIVATE MSDIALOG oDlg CENTER
ENDIF

Return Nil

