#INCLUDE "RWMAKE.CH"
#INCLUDE "MATA410.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "APWIZARD.CH"

Static __lNumItem := .F.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A410EntraB� Autor � Waldemiro L. Lustosa � Data � 19.09.94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao de Produtos atraves de Leitora de Barras.         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata410                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador�Data    �   BOPS    � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Aline Vale �26/08/99�    ----   �Alteracao da Picture do ListBox       ���
���Dora vega  �08/06/17�TSSERMI0-91�Modificacion en la funcion Ma410PvNfs ���
���           �        �TSSERMI0-92�para mostrar el grupo de preguntas    ���
���           �        �           �PVXARG para el punto de venta. (ARG)  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410EntraBarra(oGetD)

LOCAL cCodigo1, k, j, nX, i
LOCAL nPosItem, nPosQtd, nPosValor, nPosPrc
LOCAL oDlg, oCod
Local cPictCBar := PESQPICTQT("C6_QTDVEN",15)
Local cItem := "01"
Local nOpcA := 0
Local aCposItPed := {}
Local nPosCpo := 0
Local lM410EBAR	:= ExistBlock("M410EBAR")
Local aColsAux := {}

PRIVATE oListBox
PRIVATE aCodigos := {}, nPosCodBarra

For nX=1 to Len(aHeader)
	If Trim(aHeader[nX][2]) == "C6_PRODUTO"
		nPosCodBarra := nX
		exit
	EndIf
Next nX

cTitulo :=STR0272	//"Entrada por C�digo de Barras"
cCodigo1:=Space(Len(SB1->B1_CODBAR))

PRIVATE aListBox:={{Space(Len(SB1->B1_COD)),Space(Len(SB1->B1_DESC)),0}}

cVar:=NIL
SetKey(VK_F5,{||A410GetQuant()})
SetKey(VK_F6,{||A410ApagItem()})
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(cTitulo) FROM  180,080 TO 450,550 PIXEL OF oMainWnd
	@ 10,10 SAY OemToAnsi(STR0273) SIZE 50,8 OF oDlg PIXEL		//"C�digo do Produto"
	@ 10,60 MSGET oCod VAR cCodigo1 PICTURE "@!" VALID a410ChecaB1(@cCodigo1,oCod) F3 "SB1" SIZE 160,10 OF oDlg PIXEL
	@ 28,10 TO 110, 227 LABEL "" OF oDlg PIXEL
	@ 33,12 LISTBOX oListBox VAR cVar FIELDS HEADER OemToAnsi(STR0274),OemToAnsi(STR0275),OemToAnsi(STR0276) ON DBLCLICK A410GetQuant() SIZE 214,76 PIXEL			//"C�digo"###"Descri��o"###"Quantidade"
	oListBox:bGotFocus:={||SetFocus(oCod:hWnd)}
	oListBox:SetArray(aListBox)
	oListBox:bLine:={||{aListBox[oListBox:nAt,1],;
						aListBox[oListBox:nAt,2],;
						Transform(aListBox[oListBox:nAt,3],cPictCBar)}}
    DEFINE SBUTTON FROM 115, 172 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 115, 200 TYPE 2 ACTION (nOpca:=3,oDlg:End()) ENABLE OF oDlg
	@ 115,10 SAY OemToAnsi(STR0277) SIZE 100,8 OF oDlg PIXEL		//"[F5] Quantidade [F6] Excluir"
ACTIVATE MSDIALOG oDlg
SetKey(VK_F5,NIL)
SetKey(VK_F6,NIL)

While nOpcA==1
	For i:=1 to Len(aListBox)
		If !Empty(aListBox[i,1])
			AADD(aCodigos,{aListBox[i,1],aListBox[i,3]})
		Endif
	Next
	If Len(aCodigos)==0
		Exit
	Endif
	Asort(aCodigos,,,{|x,y|x[1]<y[1]})
	For nX=1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == "C6_ITEM"
			nPosItem := nX
		ElseIf Trim(aHeader[nX][2]) == "C6_PRODUTO"
			nPosCodBarra := nX
		ElseIf Trim(aHeader[nX][2]) == "C6_QTDVEN"
			nPosQtd := nX
		ElseIf Trim(aHeader[nX][2]) == "C6_PRCVEN"
			nPosPrc := nX
		ElseIf Trim(aHeader[nX][2]) == "C6_VALOR"
			nPosValor := nX
		EndIf
	Next nX

	aColsAux := aClone(aCols)
	lCB := .F.
	cItem := (aColsAux[Len(aColsAux)][1])
    
	For k := 1 To Len(aCodigos)		
		SB1->(dbSeek(xFilial("SB1")+aCodigos[k,1]))
		If !Empty(aColsAux[Len(aColsAux)][nPosCodBarra])
			Aadd(aColsAux,{})
			cItem := Soma1(cItem)
		Else
			aColsAux[Len(aColsAux)] := {}
		EndIf
		
		//�������������������������������������������������������������Ŀ
		//�Ponto de entrada para preechimento de outras colunas do aCols�
		//���������������������������������������������������������������
		If lM410EBAR
			aCposItPed := ExecBlock("M410EBAR",.f.,.f.,aCodigos[k])
			If ValType(aCposItPed) <> "A"
				aCposItPed := {}
			Endif
		Endif
		
		For j := 1 To Len(aHeader)
			Do Case
				Case j == nPosItem
					Aadd(aColsAux[Len(aColsAux)],cItem)
				Case j == nPosCodBarra
					Aadd(aColsAux[Len(aColsAux)],aCodigos[k,1])
				Case j == nPosQtd
					Aadd(aColsAux[Len(aColsAux)],0)
				Case AllTrim(aHeader[j][2]) == "C6_ENTREG"
					If Empty(CriaVar("C6_ENTREG",.T.))
						Aadd(aColsAux[Len(aColsAux)],dDataBase)
					Else
						Aadd(aColsAux[Len(aColsAux)],CriaVar("C6_ENTREG",.T.))
					EndIf
				Case AllTrim(aHeader[j][2]) == "C6_TPPROD"
					If Empty(CriaVar("C6_TPPROD",.T.))
						Aadd(aColsAux[Len(aColsAux)],"1")
					Else
						Aadd(aColsAux[Len(aColsAux)],CriaVar("C6_TPPROD",.T.))
					EndIf	
				Otherwise
					If AllTrim(aHeader[j,2]) == "C6_REC_WT"
						Aadd(aColsAux[Len(aColsAux)],0)
					ElseIf AllTrim(aHeader[j,2]) == "C6_ALI_WT"
						Aadd(aColsAux[Len(aColsAux)],"SC6")
					Else
						Aadd(aColsAux[Len(aColsAux)],CriaVar(aHeader[j][2],.F.))
					EndIf
			EndCase
		Next j
		
		Aadd(aColsAux[Len(aColsAux)],.F.)
		
		aCols := aClone(aColsAux)
		lCB := .T.
		
		A410Produto(,.T.)

		If ExistTrigger("C6_PRODUTO")
			RunTrigger(2,Len(aCols))
		EndIf

		A410MultT("C6_QTDVEN",aCodigos[k,2])

		If ExistTrigger("C6_QTDVEN ")
			RunTrigger(2,Len(aCols))
		EndIf		
		
		//�������������������������������������������������������������Ŀ
		//�Preechimento de outras colunas do aCols                      �
		//���������������������������������������������������������������		
		If !Empty(aCposItPed)
			For nX := 1 To Len(aCposItPed)
				If ValType(aCposItPed[nX]) == "A"   .And.;
				   Len(aCposItPed[nX]) == 2         .And.;
				   ValType(aCposItPed[nX,1]) == "C" .AND.;
				   !(AllTrim(aCposItPed[nX,1]) $ "C6_ITEM,C6_PRODUTO,C6_QTDVEN")
					nPosCpo := Ascan(aHeader,{|x| AllTrim(x[2]) == AllTrim(aCposItPed[nX,1])})
					If nPosCpo > 0
						aCols[Len(aCols),nPosCpo] := aCposItPed[nX,2]
						If ExistTrigger(aHeader[nPosCpo,2])
							RunTrigger(2,Len(aCols))
						Endif
					Endif
				Endif
			Next
		Endif
		
		lCB := .F.
		If MV_PAR01 == 1
			lCB := .T.
			MaIniLiber(M->C5_NUM,aCodigos[k,2],Len(aCols),.T.)
			lCB := .F. 
		Endif
		aColsAux := aClone(aCols)
	Next k
	Exit
End
oGetd:ForceRefresh()
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a410GetQuant�Autor� Juan Jose Pereira     � Data � 30.09.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Aciona Get para alteracao da quantidade em entrada por      ���
���          �leitora por codigo de barras                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410GetQuant()

Local oDlgGet, nQuant, cTitulo:=STR0276, nOpcGet:=2, nPos		//"Quantidade"

nPos:=oListBox:nAt

If !Empty(aListBox[nPos,1])
	cProduto:=Alltrim(aListBox[nPos,1])+" - "+Alltrim(aListBox[nPos,2])
	nQuant:=aListBox[nPos,3]
	DEFINE MSDIALOG oDlgGet TITLE OemtoAnsi(cTitulo) FROM  200,80 TO 300,560 PIXEL OF oMainWnd
		@ 01,03 TO 25, 231 LABEL "" OF oDlgGet PIXEL
		@ 10,10 say OemToAnsi(cProduto) SIZE 150,08 OF oDlgGet PIXEL
   	    @ 10,179 MSGET nQuant PICTURE "@E 99999999999" VALID NaoVazio(nQuant) SIZE 50,08 OF oDlgGet PIXEL
		DEFINE SBUTTON FROM 30, 175 TYPE 1 ACTION (nOpcGet:=1,oDlgGet:End()) ENABLE OF oDlgGet
		DEFINE SBUTTON FROM 30, 204 TYPE 2 ACTION (nOpcGet:=2,oDlgGet:End()) ENABLE OF oDlgGet
	ACTIVATE MSDIALOG oDlgGet
	If nQuant>0
		aListBox[nPos,3]:=nQuant
		oListBox:SetArray(aListBox)
		oListBox:bLine:={||{aListBox[oListBox:nAt,1],;
							aListBox[oListBox:nAt,2],;
							xPadl(Str(aListBox[oListBox:nAt,3]),100)}}
		oListBox:Refresh()
	Endif
Endif
Return NIL

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a410ApagItem�Autor� Juan Jose Pereira     � Data � 30.09.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Apaga itens da entrada por leitora de codigo de barras      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A410ApagItem()

Local nPos	:= oListBox:nAt

If !Empty(aListBox[nPos,1])
	If Len(aListBox)==1
		aListBox[1,1]:=Space(Len(SB1->B1_COD))
		aListBox[1,2]:=Space(Len(SB1->B1_DESC))
		aListBox[1,3]:=0
	Else
		ADEL(aListBox,nPos)	
		ASIZE(aListBox,Len(aListBox)-1)	
	Endif
Endif                

oListBox:nAt := 1
oListBox:SetArray(aListBox)
oListBox:bLine:={||{aListBox[oListBox:nAt,1],;
					aListBox[oListBox:nAt,2],;
					xPadl(Str(aListBox[oListBox:nAt,3]),100)}}
oListBox:Refresh()
Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ma410Ativa� Rev.  �Eduardo Riera          � Data �11.03.99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Estabelece os parametros do Pedido de Venda                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a410ativa()

Local aArea	:=	GetArea()

Pergunte("MTA410",.T.)
RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TransNum � Autor � Claudinei M. Benzi    � Data � 10.01.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Transforma Variavel numerica em caracter baseado no SX3    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TransNum(cCampo)

Local xAlias	:= Alias()
Local nConteudo
Local cAlias1
Local cRet

IF AT("_",cCampo) != 0
    SX3->(dbSetOrder(2))
    SX3->(dbSeek(cCampo))
    SX3->(dbSetOrder(1))
    cAlias1 := "S" + Subs( cCampo, AT("_",cCampo)-2,2)
    dbSelectArea(cAlias1)
EndIf

nConteudo := &cCampo
cRet := Transform(nConteudo,Trim(X3Picture(cCampo)))
dbSelectArea(xAlias)
Return cRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A410AcrFin� Autor � Waldemiro L. Lustosa � Data � 22.04.94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Registra Acrescimo Financeiro no Pedido de Vendas          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410AcrFin()

Local cCondPag
Local xAlias		:= Alias()
Local nEndereco
Local nRegSX3		:= SX3->(Recno())

cCondPag := &(ReadVar())
dbSelectArea("SE4")
If dbSeek(cFilial+cCondPag)
	//������������������������������������������������������������������������Ŀ
	//�Verifica se o pedido nao utiliza o fornecedor para calcular acrescimo   �
	//��������������������������������������������������������������������������
	If (M->C5_TIPO <> "D" .And. M->C5_TIPO <> "B")
	    M->C5_ACRSFIN := E4_ACRSFIN
    	nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "C5_ACRSFIN" } )
	    If nEndereco > 0
    	    aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2),2,.F.))][Val(Subs(aGets[nEndereco],3,1))*2] := TransNum("E4_ACRSFIN")
	    EndIf
	Endif
EndIf

SX3->(dbGoTo(nRegSX3))
dbSelectArea(xAlias)
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A410ZERA  � Autor � Cristina Ogura        � Data � 11.05.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Zera Nota Fiscal de Origem e Serie da Nota                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410Zera()

Local cVar      := ReadVar()
Local nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})

If M->C5_TIPO == "D" .And. cVar == "M->C6_PRCVEN"
	If nPNumLote <> 0
		aCols[n][nPNumLote] := CriaVar("C6_NUMLOTE",.F.)
	EndIf
	If nPLoteCtl <> 0
		aCols[n][nPLoteCtl] := CriaVar("C6_LOTECTL",.F.)
	EndIf
EndIf
Return .T.

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MA410PvNfs� Autor � Eduardo Riera         � Data �25.07.2005 ���
��������������������������������������������������������������������������Ĵ��
���          �Funcao de calculo prepara��o do doocumento de sa�da.         ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do Pedido de Venda                              ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao efetua a prepara��o do documento de sa�da, para o���
���          �pedido de venda posicionado.                                 ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Ma410PvNfs(cAlias,nReg,nOpc)

Local aArea		:= GetArea()
Local aAreaSF2	:= {}
Local aPvlNfs		:= {}
Local aTexto		:= {}
Local aBloqueio	:= {{"","","","","","","",""}}
Local aNotas		:= {}
Local cAliasSC9	:= "SC9"
Local nItemNf		:= 0
Local nX			:= 0
Local cSerie		:= ""
Local lOk			:= .F.
Local oWizard		:= NIL
Local oListBox	:= NIL
Local lContinua	:= .T.
Local lCond9		:= GetNewPar("MV_DATAINF",.F.)	//Caso existam diferentes c�digos de servi�o no Pedido de Vendas, dever� ser gerada uma nota fiscal para cada c�digo.
Local cFunName	:= FunName()
Local lTxMoeda	:= .F.
Local dDataMoe	:= dDataBase  
Local lConfirma	:= .T.
Local lDataFin	:= .F.
Local lNfeQueb	:= GetNewPar("MV_NFEQUEB",.F.) .And. cPaisLoc == "BRA"
Local lBlqISS		:= .T.
Local bCondExec	:= {||}
Local nY			:= 0
Local lReajuste	:= .F.
Local aTotsNF		:= {}
Local lUsaNewKey	:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local cSerieId	:= IIf( lUsaNewKey , SerieNfId("SF2",4,"F2_SERIE",dDataBase,A460Especie(cSerie),cSerie) , cSerie )
Local lM410ALDT	:= ExistBlock("M410ALDT")
Local lM461DINF	:= ExistBlock("M461DINF")
Local lAGRUBS		:= SuperGetMV("MV_AGRUBS",.F.,.F.)
Local cTrcNum		:= ""
Local lTrcNum		:= IIf(lAGRUBS,SC5->(ColumnPos("C5_TRCNUM"))>0,.F.)	//Campo da Agroindustria
Local lAgrMoeda	:= .F.
Local aAgrArea	:= {}
Local cOldArea	:= ""
Local cFilSF2		:= xFilial("SF2")
Local lA461NAdian 	:= FindFunction("A461NAdian")
Local lPedComAd 	:= .T.
Local lRetornoDCL	:= .T.

// Se lMudouNum for .T. significa que o usuario alterou o numero da nota em MV_TPNRNFS == "3"
// e o sistema deve respeitar o novo numero contido em cNumero
Private lMudouNum		:= .F.
Private cNumero		:= ""

Private cIdPV			:= ""
Private cPV410		:= ""

// variaveis criadas para chamada da funcao A460AcumIt() no fonte MATA460 - calcular o total da nota e bloquear se total inferior ao valor minimo a faturar (parametro 12 do pergunte MT460A)
Private nAcresFin		:= SC5->C5_ACRSFIN
Private cMVARREFAT	:= SuperGetMv("MV_ARREFAT")
Private aTamSX3		:= TamSX3("F2_VALBRUT")
Private nBaseFIcm		:= 0
Private nBaseFIpi		:= 0
Private nBaseISS		:= 0  
Private nBaseIRF		:= 0
Private nBItemInss	:= 0
Private nBaseInss		:= 0
Private nDecimal		:= TamSx3("F2_VALBRUT")[2]

If !ctbValiDt( Nil, dDataBase, .T., Nil, Nil, { "FAT003" }, Nil )
	Return Nil
EndIf

If ExistTemplate("FATDOCSA")
    lRetornoDCL := ExecTemplate("FATDOCSA",.F.,.F.,{Nil,SC5->C5_NUM})
    If !lRetornoDCL
        Return Nil
    EndIf
EndIf

lCond9   := IIf(ValType(lCond9)<>"L",.F.,lCond9)

//������������������������������������������������������������������������Ŀ
//�Retorna o SetFunName que iniciou a rotina                               �
//��������������������������������������������������������������������������

SetFunName("MATA461")

//������������������������������������������������������������������������Ŀ
//� Montagem da Interface                                                  �
//��������������������������������������������������������������������������
aadd(aTexto,{})
aTexto[1] := STR0278+CRLF //"Esta rotina tem como objetivo ajuda-lo na prepara��o do documento "
aTexto[1] += STR0279+SC5->C5_NUM+STR0280+CRLF+CRLF //"de sa�da do pedido de venda n�mero: "###"."
aTexto[1] += STR0281 //"O pr�ximo passo ser� verificar o status de libera��o do pedido de venda."
aadd(aTexto,"")
aTexto[2] := PadC(STR0282+SC5->C5_NUM,160)+CRLF+CRLF //"Pedido de Venda: "
aTexto[2] += STR0283 //"O assistente identificou que o pedido de venda encontra-se liberado e ir� utilizar "
aTexto[2] += STR0284+CRLF+CRLF //"os itens aptos a faturar para preparar o documento de sa�da."
aTexto[2] += STR0285  //"Caso o pedido n�o esteja totalmente liberado, os itens n�o liberados ser�o desprezados."
aadd(aTexto,"")
aTexto[3] := PadC(STR0282+SC5->C5_NUM,160)+CRLF+CRLF //"Pedido de Venda: "
aTexto[3] += STR0286 //"O assistente identificou que o pedido de venda n�o possui itens liberados e ir� realizar "
aTexto[3] += STR0287  //"a libera��o de todos os itens do pedido de venda, conforme os par�metros do sistema."
aadd(aTexto,"")
aTexto[4] := PadC(STR0282+SC5->C5_NUM,160)+CRLF+CRLF //"Pedido de Venda: "
aTexto[4] += STR0288 //"O assistente identificou que o pedido de venda esta liberado (totalmente ou parcialmente) e ir� utilizar "
aTexto[4] += STR0289  //"os itens liberados para preparar o documento de sa�da."
aadd(aTexto,"")
aTexto[5] := PadC(STR0282+SC5->C5_NUM,160)+CRLF+CRLF //"Pedido de Venda: "
aTexto[5] += STR0290 //"O assistente concluiu com sucesso todos os passos para prepara��o do documento "
aTexto[5] += STR0291 +CRLF+CRLF //"de sa�da. "
aTexto[5] += STR0292 //"O documento de sa�da ser� gerado ap�s a confirma��o da s�rie do documento de sa�da."
aadd(aTexto,"")
aTexto[6] := PadC(STR0282+SC5->C5_NUM,160)+CRLF+CRLF //"Pedido de Venda: "
aTexto[6] += STR0290 //"O assistente concluiu com sucesso todos os passos para prepara��o do documento "
aTexto[6] += STR0291 +CRLF+CRLF //"de sa�da. "
aTexto[6] += STR0293 //"O documento de sa�da n�o ser� gerado neste momento, pois n�o h� itens aptos a faturar. "

If lNfeQueb
	aadd(aTexto,"")
	aTexto[7] := PadC(STR0282+SC5->C5_NUM,160)+CRLF+CRLF //"Pedido de Venda: "
	aTexto[7] += STR0306 +CRLF+CRLF //"O documento de sa�da n�o poder� ser� gerado por esta rotina, pois este pedido de vendas possui itens com c�digos de servi�o diferentes."
	aTexto[7] += STR0307 +CRLF+CRLF	//"De acordo com configura��o do par�metro MV_NFEQUEB, ser� gerado uma nota fiscal para cada c�digo de servi�o, portanto utilize a rotina de prepara��o de Documento de Sa�da para faturar este pedido."
	aTexto[7] += STR0308			//"Esta rotina est� localizada em Atualiza��es-> Faturamento-> Documento de Sa�da (MATA460A) e ir� fazer o tratamento de quebra dos itens gerando as notas fiscais."
EndIf

If ( ExistBlock("M410PVNF") )
	lContinua := ExecBlock("M410PVNF",.f.,.f.,nReg)
EndIf

//���������������������������������������������������Ŀ
//�Verifica se o usuario tem premissao para gerar   o �
//�documento de saida                                 �
//�����������������������������������������������������
If cPaisLoc <> "BRA" .AND. SC5->(ColumnPos("C5_CATPV")) > 0 .AND. !Empty(SC5->C5_CATPV) .AND. AliasIndic("AGS") //Tabela que relaciona usuario com os Tipos de Pedidos de vendas que ele tem acesso
	AGS->(DBSetOrder(1))
	If AGS->(DBSeek(xFilial("AGS") + __cUserId)) //Se n�o encontrar o usu�rio na tabela, permite ele alterar o pedido
		If AG5->(! DBSeek(xFilial("AGS") + __cUserId + SC5->C5_CATPV)) //Verifica se o usuario tem premissao
			MsgStop(STR0300 + " " + STR0301 + " " + STR0302)//"Este usuario nao tem permissao para gerar documentos de saida para pedidos de venda com esse tipo."
			lContinua := .F.
		EndIf
	EndIf
EndIf

If lContinua .And. FindFunction("AcdFatOsep") .AND. !(AcdFatOsep(cAliasSC9, ))
	lContinua := .F.
Endif

If lContinua .AND. Substr(cAcesso,51,1) != "S"
	cOldArea	:= Alias()
	aAreaSF2	:= SF2->(GetArea())
	SF2->(DbSetOrder(3))	//F2_FILIAL+F2_ECF+DTOS(F2_EMISSAO)+F2_PDV+F2_SERIE+F2_MAPA+F2_DOC
	SF2->(MsSeek(cFilSF2+Space(Len(SF2->F2_ECF))+"z",.T.))
	SF2->(DbSkip(-1))
	If ( dDataBase < SF2->F2_EMISSAO )
		Help(" ",1,"DATNF")
		lContinua := .F.
	EndIf
	If lContinua
		SF2->(MsSeek(cFilSF2+"S"+"z",.T.))
		SF2->(DbSkip(-1))
		If ( dDataBase < SF2->F2_EMISSAO )
			Help(" ",1,"DATNF")
			lContinua := .F.
		EndIf
	EndIf
	RestArea(aAreaSF2)
	DbSelectArea(cOldArea)
EndIf

If lContinua .And. cPaisLoc <> "BRA" .And. FindFunction("FxValStock")
	lContinua := FxValStock(cAlias, nReg)
EndIf

If lContinua
	If cPaisLoc $ "EUA|MEX|COL|PER"
		SC5->(MsGoTo(nReg))
		RecLock("SC5",.F.)
	Endif
	
	If !lNfeQueb
		bCondExec := {|| Ma410LbNfs(1,@aPvlNfs,@aBloqueio),;
						 oWizard:SetPanel(IIf(!Empty(aPvlNfs).Or.!Empty(aBloqueio),1,2))}	
	Else
		//Verifica se existem itens com c�digos de servi�o diferentes quando o par�metro MV_NFEQUEB estiver ativo.
		lBlqISS := A410BloqIss(SC5->C5_NUM)
		
		If !lBlqISS
			bCondExec := {|| oWizard:SetPanel(7)}	
		Else
			bCondExec := {|| Ma410LbNfs(1,@aPvlNfs,@aBloqueio),;
							 oWizard:SetPanel(IIf(!Empty(aPvlNfs).Or.!Empty(aBloqueio),1,2))}	
		EndIF
	EndIf
	
	DEFINE WIZARD oWizard ;
		TITLE STR0294; //"Assistente para prepara��o do documento de sa�da"
		HEADER STR0295; //"Aten��o"
		MESSAGE STR0296; //"Siga atentamente os passos para prepra��o do documento de sa�da."
		TEXT aTexto[1] ;
		NEXT {|| Eval(bCondExec),.T.} ;
		FINISH {||.T.}	

	CREATE PANEL oWizard  ;
		HEADER STR0297; //"Libera��o de pedido de venda"
		MESSAGE ""	;
		BACK {|| aPvlNfs:={},aBloqueio:={},oWizard:SetPanel(2),.T.} ;
		NEXT {|| oWizard:SetPanel(3),.T.} ;
		PANEL
	@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[2]

	CREATE PANEL oWizard  ;
		HEADER STR0297; //"Libera��o de pedido de venda"
		MESSAGE ""	;
		BACK {|| aPvlNfs:={},aBloqueio:={},oWizard:SetPanel(2),.T.} ;
		NEXT {|| Ma410LbNfs(2,@aPvlNfs,@aBloqueio),Ma410LbNfs(1,@aPvlNfs,@aBloqueio)} ;
		FINISH {|| .T.} ;
		PANEL
	@ 010,010 GET aTexto[3] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]

	CREATE PANEL oWizard  ;
		HEADER STR0297; //"Libera��o de pedido de venda"
		MESSAGE ""	;
		BACK {|| aPvlNfs:={},aBloqueio:={},oWizard:SetPanel(2),.T.} ;
		NEXT {|| oWizard:SetPanel(IIf(!Empty(aBloqueio),4,IIf(Empty(aPvlNfs),5,6))),(IIf(!Empty(aBloqueio),(oListBox:SetArray(aBloqueio),oListBox:bLine := { || aBloqueio[oListBox:nAT]}),.T.)),.T.} ;
		FINISH {|| .T.} ;	
		PANEL	
	@ 010,010 GET aTexto[4] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[4]

	CREATE PANEL oWizard  ;
		HEADER STR0297; //"Libera��o de pedido de venda"
		MESSAGE STR0298	; //"Os itens abaixo encontram-se bloqueados, caso continue os mesmos ser�o desprezados."
		BACK {|| aPvlNfs:={},aBloqueio:={},oWizard:SetPanel(2),.T.} ;
		NEXT {|| oWizard:SetPanel(IIf(Empty(aPvlNfs),5,6)),.T.} ;
		FINISH {|| .T.} ;	
		PANEL	
	oListBox := TWBrowse():New(004,003,285,130,,{RetTitle("C9_PEDIDO"),RetTitle("C9_ITEM"),RetTitle("C9_SEQUEN"),RetTitle("C9_PRODUTO"),RetTitle("C9_QTDLIB"),RetTitle("C9_BLCRED"),RetTitle("C9_BLEST"),RetTitle("C9_BLWMS")},,oWizard:oMPanel[5],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aBloqueio)
	oListBox:bLine := { || aBloqueio[oListBox:nAT]}

	CREATE PANEL oWizard  ;
		HEADER STR0299; //"Prepara��o do documento de sa�da."
		MESSAGE "";
		BACK {|| aPvlNfs:={},aBloqueio:={},oWizard:SetPanel(2),.T.} ;
		NEXT {|| .f.} ;
		FINISH {|| lOk := .F.} ;
		PANEL
	@ 010,010 GET aTexto[6] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[6]

	CREATE PANEL oWizard  ;
		HEADER STR0299; //"Prepara��o do documento de sa�da."
		MESSAGE "";
		BACK {|| aPvlNfs:={},aBloqueio:={},oWizard:SetPanel(2),.T.} ;
		FINISH {|| lOk := .T.} ;
		PANEL
	@ 010,010 GET aTexto[5] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[7]

	If lNfeQueb .And. !lBlqISS
		CREATE PANEL oWizard  ;
			HEADER STR0299; //"Prepara��o do documento de sa�da."
			MESSAGE STR0295;
			BACK {|| lBlqISS:=.T.,oWizard:SetPanel(2),.T.} ;
			FINISH {|| .T.} ;
			PANEL
		@ 010,010 GET aTexto[7] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[8]
	EndIf
	
	ACTIVATE WIZARD oWizard CENTERED
	
	If !Empty(aPvlNfs) .And. lOk
		If cPaisLoc<>"BRA"
			aReg:={}
			For nX:=1 To Len(aPvlNfs)
				Aadd(aReg,aPvlNfs[nX][8])
			Next
			If SC5->C5_DOCGER=="2"		//gerar remision
				ProcRegua(Len(aReg))
				Pergunte("MT462A",.F.)
				aParams:={MV_PAR09,MV_PAR10,MV_PAR11,MV_PAR12,01,SC5->C5_MOEDA}
				cMarca:=GetMark(,'SC9','C9_OK')
				cMarcaSC9:=cMarca
				For nX:=1 To Len(aReg)
					IncProc()
					SC9->(DbGoTo(aReg[nX]))
					RecLock("SC9",.F.)
					Replace SC9->C9_OK With cMarca
					SC9->(MsUnLock())
				Next
				If cPaisLoc == "ARG"
				 	If !Pergunte("PVXARG",.T.)
						Return .F.
					Endif
					cLocxNFPV := MV_PAR01
					lLocxAuto  := .F.
					cIdPVArg := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
					If !F083ExtSFP(MV_PAR01, .T.)
						Return .F.
					EndIf
				EndIf
				SetInvert(.F.)
				A462ANGera(Nil,cMarca,.T.,aReg,.F.,aParams)
			Else						//gerar fatura
				IF Pergunte("MTA410FAT",.T.)
					aParams :=	{SC5->C5_NUM,SC5->C5_NUM,; //Pedido de - ate
					             SC5->C5_CLIENTE,SC5->C5_CLIENTE,; //Cliente de - ate
					             SC5->C5_LOJACLI,SC5->C5_LOJACLI,; //Loja de - ate
					             MV_PAR01,MV_PAR02,; //Grupo de - ate
					             MV_PAR03,MV_PAR04,; //Agregador de - ate
					             MV_PAR05,MV_PAR06,MV_PAR07,; //lDigita # lAglutina # lGeraLanc
					             2       ,MV_PAR08,MV_PAR09,; //lInverte# lAtuaSA7  # nSepara
					             MV_PAR10, 2,; //nValorMin# proforma
					             "",'zzzzzzzzzzz',;//Trasnportadora de - ate
					             MV_PAR11,MV_PAR12,;//Reajusta na mesma nota  # Fatura Ped. Pela
					             MV_PAR13,MV_PAR14,; // Moeda para Faturamento			
					             If(SC5->C5_TIPO<>"N",2,1)} // Tipo de Pedido
					If (cPaisLoc == "ARG")
						If Pergunte("PVXARG",.T.) .AND. F083ExtSFP(MV_PAR01, .T.)
							//Controle de ponto de venda para argentina.
							cPV410 := MV_PAR01
							cIdPV	:= POSICIONE("CFH",1, xFilial("CFH")+MV_PAR01,"CFH_IDPV")
							a468NFatura("SC9",aParams,aReg,Nil)
						EndIf
					Else
						a468NFatura("SC9",aParams,aReg,Nil)
					EndIf
				Endif
			Endif
		Else
			If Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),,,,@cSerieId,dDataBase ) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX
				nItemNf  := a460NumIt(cSerie)
				//���������������������������������������������������������������Ŀ
				//� Define variaveis de parametrizacao de lancamentos             �
				//�����������������������������������������������������������������
				//���������������������������������������������������������������Ŀ
				//� mv_par01 Mostra Lan�.Contab ?  Sim/Nao                        �
				//� mv_par02 Aglut. Lan�amentos ?  Sim/Nao                        �
				//� mv_par03 Lan�.Contab.On-Line?  Sim/Nao                        �
				//� mv_par04 Contb.Custo On-Line?  Sim/Nao                        �
				//� mv_par05 Reaj. na mesma N.F.?  Sim/Nao                        �
				//� mv_par06 Taxa deflacao ICMS ?  Numerico                       �
				//� mv_par07 Metodo calc.acr.fin?  Taxa defl/Dif.lista/% Acrs.ped �
				//� mv_par08 Arred.prc unit vist?  Sempre/Nunca/Consumid.final    �
				//� mv_par09 Agreg. liberac. de ?  Caracter                       �
				//� mv_par10 Agreg. liberac. ate?  Caracter                       �
				//� mv_par11 Aglut.Ped. Iguais  ?  Sim/Nao                        �
				//� mv_par12 Valor Minimo p/fatu?                                 �
				//� mv_par13 Transportadora de  ?                                 �
				//� mv_par14 Transportadora ate ?                                 �
				//� mv_par15 Atualiza Cli.X Prod?                                 �
				//� mv_par16 Emitir             ?  Nota / Cupom Fiscal            �
				//�����������������������������������������������������������������		
				
				//Limpa a pergunta, para n�o gerar nota fiscal com cota��o errada.
				SetMVValue("MT460A","MV_PAR21",cTod("//"))	//"Dt. Ref. Convers�o ?"

				If ( Pergunte("MT460A",.T.) )
					If mv_par16 == 2 .And. !ExistBlock("M461IMPF")
						Aviso(STR0038,STR0309,{STR0040})	//"A emiss�o de Cupons Fiscais s� � poss�vel com o ponto de entrada M461IMPF"
					ElseIf mv_par16 == 3 .And. SuperGetMV("MV_LJPAFEC",,.F.) .AND. LjNfPafEcf(SM0->M0_CGC)
						If SC9->(dbSeek(xFilial("SC9")+aPvlNfs[1][1]))
							//Para ambientes do tipo PAF-ECF, nao emite nota - apenas gera orcamento no loja (DAV)
							MA461OrcLj()
						EndIf
					Else
						aadd(aNotas,{})
					   	For nX := 1 To Len(aPvlNfs)
							lConfirma:= .T.
					    	If Len(aNotas[Len(aNotas)])>=nItemNf
					    		aadd(aNotas,{})
								__lNumItem := .T.
					    	EndIf
							//�����������������������������������������������������������������Ŀ
						    //� Se o item gerar duplicata, verifica se a data do movimento n�o ��
							//� menor que data limite de movimentacao no financeiro configurada �
							//� no parametro MV_DATAFIN.									    �
							//�������������������������������������������������������������������
							If aPvlNfs[nX][18] .And. !DtMovFin(,.F.)
								lDataFin := .T.
								lConfirma:= .F.
							EndIf
							//Valida se a condi��o de pagamento � de adiantamento, e valida se o pedido possui adiantamentos associados.
							If lConfirma .And. lA461NAdian .And. cPaisLoc $ "BRA|MEX" .And. aPvlNfs[nX][18] .And. A410UsaAdi(SC5->C5_CONDPAG)
								SetFunName(cFunName)	//Foi necess�rio voltar o funname, para que n�o de erro na op��o de inclus�o do RA direto no contas a receber
								lPedComAd := A461NAdian( aPvlNfs[nX,1], SC5->C5_CONDPAG, aPvlNfs, .F., .F., SC5->C5_CLIENTE, SC5->C5_LOJACLI, {}, 0, SC5->C5_MOEDA )
								SetFunName("MATA461")
								If !lPedComAd	//Se n�o possuir adiantamentos associados, n�o continua o faturamento do pedido
									aNotas := {}
									Exit
								EndIf
							EndIf
	                        If lConfirma
						    	aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
							EndIf
						Next nX         
						
						If lM410ALDT			
	   						dDataBase := If(ValType(dDataPE := ExecBlock("M410ALDT", .F., .F.))=='D', dDataPE , dDataBase) 
		   				Endif
						
						For nX := 1 To Len(aNotas)
								// Verifica se o total da nota � menor que o parametro de valor minimo de faturamento
							lReajuste:= IIF(MV_PAR05==1,.T.,.F.)
							nTotalNF:=0  
							aTotsNF:={}
							nBaseFIcm:=0 
							nBaseFIpi:=0 
							nBaseISS:=0  
							nBaseIRF:=0  
							nBItemInss:=0
							nBaseInss:=0
							For nY := 1 To Len(aNotas[nX])
								// posiciona no item da SC9 - FILIAL + PEDIDO + ITEM + SEQUEN + PRODUTO
								SC9->(dbSeek(xFilial("SC9")+aNotas[nX][nY][1]+aNotas[nX][nY][2]+aNotas[nX][nY][3]+aNotas[nX][nY][6]))
								// posiciona no item da SC6   - FILIAL + PEDIDO + ITEM + PRODUTO
								SC6->(dbSeek(xFilial("SC6")+aNotas[nX][nY][1]+aNotas[nX][nY][2]+aNotas[nX][nY][6])) 
								A460AcumIt(@aTotsNF,SC9->C9_QTDLIB,lReajuste,0)
								nTotalNF += aTotsNF[ Len(aTotsNF ) ][4]
							Next nY
							If nTotalNF >= MV_PAR12									// valor minimo de faturamento							
								//PONTO PARA VERIFICA��O DA AGROINDUSTRIA.
								//VERIFICA SE O PEDIDO VEM DE UMA TROCA PARA QUE A MOEDA DO DIA SEJA DESCONSIDERADA.				
								If lAGRUBS .And. lTrcNum
									aAgrArea := GetArea()
									cTrcNum   := Posicione("SC5",1,FWxFilial("SC5")+SC9->C9_PEDIDO,"C5_TRCNUM")
									lAgrMoeda := !Empty(cTrcNum)								
									RestArea(aAgrArea)
									If !Empty(aNotas[nX])
										If lAgrMoeda .Or. !( xMoeda( 1, SC5->C5_MOEDA, 1, dDataBase ) = 0 ) 										
											MaPvlNfs(aNotas[nX],cSerie,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05==1,MV_PAR07,MV_PAR08,MV_PAR15==1,MV_PAR16==2,,,,,,dDataMoe)
										Else 
											lTxMoeda := .T.
										EndIf
									EndIf
								Else							
									dDataMoe := IIf(!Empty(MV_PAR21),MV_PAR21,dDatabase)
									// Verifica se bloqueia faturamento quando o 1o vencto < emissao da NF na cond.pgto tipo 9 (T = Bloqueia , F = Fatura)
									// Bloqueia faturamento se a moeda nao estiver cadastrada
									// Neste momento o SC5 esta posicionado no item que ir� gerar a nota fiscal.
									If !(( lCond9 .And. SC5->C5_DATA1 < dDataBase .And. !Empty(SC5->C5_DATA1) );
											.Or. ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataMoe, TamSX3("M2_MOEDA2")[2] ) = 0 ))		
										If !Empty(aNotas[nX])
											MaPvlNfs(aNotas[nX],cSerie,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05==1,MV_PAR07,MV_PAR08,MV_PAR15==1,MV_PAR16==2,,,,,,dDataMoe)
										EndIf
									Else
										If ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataMoe ) = 0 )
											lTxMoeda := .T.
										EndIf
									EndIf
								EndIf					
		
								//���������������������������������������������������������������������������������������Ŀ
								//�P.E . para exibir mensagem com motivo de n�o faturar de acordo com parametro MV_DATAINF�
								//�����������������������������������������������������������������������������������������
								If (lCond9 .And. SC5->C5_DATA1 < dDataBase .And. !Empty(SC5->C5_DATA1) ) .And. lM461DINF 
									ExecBlock( "M461DINF", .f., .f. ) 
								EndIf
							Endif
						Next nX
					Endif
				EndIf
			EndIf
		EndIf
	EndIf

	If cPaisLoc $ "EUA|MEX|COL|PER"
		SC5->(MSUNLOCK())
	Endif
EndIf
//������������������������������������������������������������������������Ŀ
//�Retorna o SetFunName que iniciou a rotina                               �
//��������������������������������������������������������������������������
SetFunName(cFunName)
	
//Mensagem para o usu�rio em caso de existirem notas com datas onde n�o foram encontrados valores de moeda cadastrados
If lTxMoeda
	Aviso(STR0295,STR0303,{STR0304}) //"Mensagens"###"Alguns pedidos nao foram gerados pois nao existe taxa para a moeda na data!"
EndIf
If lDataFin
	Aviso(STR0295,STR0305,{STR0304})	//"Alguns itens n�o foram gerados, pois n�o s�o permitidas movimenta��es financeiras com datas menores que a data limite de movimenta��es no Financeiro. Verificar o par�metro MV_DATAFIN."
EndIf

//Limpa controle de quebra de NF / Rateio de Frete.
__lNumItem := .F.  
MaNfsEnd(.T.)

//������������������������������������������������������������������������Ŀ
//�Carrega perguntas do MATA410                                            �
//��������������������������������������������������������������������������
Pergunte("MTA410",.F.)
RestArea(aArea)
Return

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MA410LbNfs� Autor � Eduardo Riera         � Data �25.07.2005 ���
��������������������������������������������������������������������������Ĵ��
���          �Funcao de libera��o do pedido venda para a prepara��o do     ���
���          �documento de sa�da                                           ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Tipo de liberacao                                     ���
���          �       [2] Libera Pedidos                                    ���
���          �       [1] Verifica se h� pedidos liberados                  ���
���          �ExpA2: Array com os itens a serem gerados               (OPC)���
���          �ExpA3: Array com os itens bloqueados                    (OPC)���
���          �       [1] Produto                                           ���
���          �       [2] Descricao                                         ���
���          �       [3] Quantidade                                        ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao efetua a prepara��o do documento de sa�da, para o���
���          �pedido de venda posicionado.                                 ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Ma410LbNfs(nTipo,aPvlNfs,aBloqueio)

Local aArea     := GetArea()
Local aRegistros:= {}
Local lQuery    := .F.
Local cAliasSC9 := "SC9"
Local cAliasSC6 := "SC6"
Local nPrcVen   := 0
Local nQtdLib   := 0
Local lPedFact  := .T.

#IFDEF TOP
	Local cQuery    := ""
#ENDIF

DEFAULT aPvlNfs    := {}

aBloqueio  := {}

Do Case
	Case nTipo == 1
		//��������������������������������������������������������������Ŀ
		//�Verifica se h� itens liberados                                �
		//����������������������������������������������������������������
		#IFDEF TOP
			cAliasSC9 := "MA410PVNFS"
			lQuery := .T.
			cQuery    := "SELECT SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_QTDLIB,SC9.C9_QTDLIB2,SC9.C9_PRCVEN,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_BLCRED,SC9.C9_BLEST,SC9.C9_BLWMS,SC9.R_E_C_N_O_ SC9RECNO "
			cQuery    += "FROM "+RetSqlName("SC9")+" SC9 "
			cQuery    += "WHERE "
			cQuery    += "SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
			cQuery    += "SC9.C9_PEDIDO = '"+SC5->C5_NUM+"' AND "
			cQuery    += "SC9.D_E_L_E_T_=' ' "
			cQuery    += "ORDER BY " + SqlOrder(SC9->(IndexKey(1)))
			
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9)
			
			If (TamSX3("C9_QTDLIB")[2] > 8 .Or. TamSX3("C9_QTDLIB2")[2] > 8)
				TcSetField(cAliasSC9,"C9_QTDLIB","N",TamSX3("C9_QTDLIB")[1],TamSX3("C9_QTDLIB")[2])
				TcSetField(cAliasSC9,"C9_QTDLIB2","N",TamSX3("C9_QTDLIB2")[1],TamSX3("C9_QTDLIB2")[2])
			Endif
			
		#ELSE
			dbSelectArea("SC9")
			dbSetOrder(1)
			MsSeek(xFilial("SC9")+SC5->C5_NUM)
		#ENDIF
	
		While (cAliasSC9)->(!Eof()) .And. xFilial("SC9") == (cAliasSC9)->C9_FILIAL .And. SC5->C5_NUM == (cAliasSC9)->C9_PEDIDO
			lPedFact := .T.
			If cPaisLoc $ "EUA|MEX|COL|PER"
				SC9->(MsGoTo((cAliasSC9)->SC9RECNO))
				lPedFact := Iif(Empty(SC9->C9_NFISCAL),lPedFact,.F.)
			EndIf
			If Empty((cAliasSC9)->C9_BLCRED+(cAliasSC9)->C9_BLEST) .And.;
			   ( Empty((cAliasSC9)->C9_BLWMS)  .Or.;
			     (cAliasSC9)->C9_BLWMS == "05" .Or.;
				 (cAliasSC9)->C9_BLWMS == "07" ) .And. lPedFact
		
				//��������������������������������������������������������������Ŀ
				//�Posiciona registros                                           �
				//����������������������������������������������������������������
				SC6->(DbSetOrder(1))
				SC6->(MsSeek(xFilial("SC6")+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_PRODUTO))
				
				SE4->(DbSetOrder(1))
				SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )
		
				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		
				SB2->(DbSetOrder(1))
				SB2->(MsSeek(xFilial("SB2")+(cAliasSC9)->C9_PRODUTO+(cAliasSC9)->C9_LOCAL))
		
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
				//������������������������������������������������Ŀ
				//� Verifica se o produto est� sendo inventariado  �
				//��������������������������������������������������
				If SF4->F4_ESTOQUE == 'S' .And. BlqInvent((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_LOCAL)
					Help(" ",1,"BLQINVENT",,(cAliasSC9)->C9_PRODUTO+" Almox: "+(cAliasSC9)->C9_LOCAL,1,11)
				Else
					//��������������������������������������������������������������Ŀ
					//�Calcula o preco de venda                                      �
					//����������������������������������������������������������������		
					nPrcVen := (cAliasSC9)->C9_PRCVEN
					If ( SC5->C5_MOEDA <> 1 )
						nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8)
					EndIf
					
					//��������������������������������������������������������������Ŀ
					//�Monta array para geracao da NF                                �
					//����������������������������������������������������������������
					aadd(aPvlNfs,{ (cAliasSC9)->C9_PEDIDO,;
									(cAliasSC9)->C9_ITEM,;
									(cAliasSC9)->C9_SEQUEN,;
									(cAliasSC9)->C9_QTDLIB,;
									nPrcVen,;
									(cAliasSC9)->C9_PRODUTO,;
									SF4->F4_ISS=="S",;
									If(lQuery,(cAliasSC9)->SC9RECNO,SC9->(RecNo())),;
									SC5->(RecNo()),;
									SC6->(RecNo()),;
									SE4->(RecNo()),;
									SB1->(RecNo()),;
									SB2->(RecNo()),;
									SF4->(RecNo()),;
									(cAliasSC9)->C9_LOCAL,;
									0,;
									(cAliasSC9)->C9_QTDLIB2,;
									SF4->F4_DUPLIC=="S"})
				EndIf
			ElseIf (cAliasSC9)->C9_BLCRED<>"10" .And. (cAliasSC9)->C9_BLEST <>"10" .And.  lPedFact
				aadd(aBloqueio,{(cAliasSC9)->C9_PEDIDO,(cAliasSC9)->C9_ITEM,(cAliasSC9)->C9_SEQUEN,(cAliasSC9)->C9_PRODUTO,TransForm((cAliasSC9)->C9_QTDLIB,X3Picture("C9_QTDLIB")),(cAliasSC9)->C9_BLCRED,(cAliasSC9)->C9_BLEST,(cAliasSC9)->C9_BLWMS})
			EndIf
			dbSelectArea(cAliasSC9)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSC9)
			dbCloseArea()
			dbSelectArea("SC9")
		EndIf
	Case nTipo == 2
		//��������������������������������������������������������������Ŀ
		//� Se n�o h� itens liberados, libera!                           �
		//����������������������������������������������������������������
		If Empty(aPvlNfs)
			//������������������������������������������������������������������������Ŀ
			//�Carrega perguntas do MATA440                                            �
			//��������������������������������������������������������������������������
			Pergunte("MTA440",.F.)
			lLiber := MV_PAR02 == 1
			lTransf:= MV_PAR01 == 1  
			#IFDEF TOP
				lQuery := .T.
				cAliasSC6 := "Ma410PvlNfs"
			
				cQuery := "SELECT SC6.R_E_C_N_O_ C6RECNO,SC5.R_E_C_N_O_ C5RECNO,"
				cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_ITEM,SC6.C6_QTDVEN,SC6.C6_QTDEMP,SC6.C6_QTDENT,"
				cQuery += "SC6.C6_ENTREG,SC6.C6_BLQ "
				cQuery += " FROM "+RetSqlName("SC6")+" SC6,"
				cQuery += RetSqlName("SC5")+" SC5 "
				cQuery += " WHERE SC6.C6_FILIAL = '"+xFilial('SC6')+"' AND "
				cQuery += " SC6.C6_NUM ='"+SC5->C5_NUM+"' AND "
				cQuery += " SC6.C6_BLQ NOT IN ('S ','R ') AND "
				cQuery += " (SC6.C6_QTDVEN-SC6.C6_QTDEMP-SC6.C6_QTDENT)>0 AND "
				cQuery += " SC6.D_E_L_E_T_ = ' ' AND "
				cQuery += " SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
				cQuery += " SC5.C5_NUM=SC6.C6_NUM AND "
				cQuery += " SC5.D_E_L_E_T_ = ' ' "
		
				cQuery := ChangeQuery(cQuery)
		
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasSC6)
		
				TcSetField(cAliasSC6,"C6_ENTREG","D",8,0)
				If TamSX3("C6_QTDVEN")[2] > 8
					TcSetField(cAliasSC6,"C6_QTDVEN","N",TamSX3("C6_QTDVEN")[1],TamSX3("C6_QTDVEN")[2])
				EndIf
			#ELSE
				dbSelectArea("SC6")
				dbSetOrder(1)
				MsSeek(xFilial("SC6")+SC5->C5_NUM)
			#ENDIF
			While (cAliasSC6)->(!Eof()) .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6") .And. (cAliasSC6)->C6_NUM == SC5->C5_NUM 
			
				aRegistros := {}
		
				While (cAliasSC6)->(!Eof()) .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6") .And. (cAliasSC6)->C6_NUM == SC5->C5_NUM
					If !AllTrim((cAliasSC6)->C6_BLQ) $ "SR"
						//������������������������������������������������������������������������Ŀ
						//�Calcula a Quantidade Liberada                                           �
						//��������������������������������������������������������������������������
						nQtdLib := ( (cAliasSC6)->C6_QTDVEN - ( (cAliasSC6)->C6_QTDEMP + (cAliasSC6)->C6_QTDENT ) )
						If nQtdLib > 0
							If RecLock("SC5")
								//������������������������������������������������������������������������Ŀ
								//�Posiciona item do pedido de venda                                       �
								//��������������������������������������������������������������������������				
								If ( lQuery )
									SC6->(MsGoto((cAliasSC6)->C6RECNO))
								Else
									SC6->(MsGoto((cAliasSC6)->(RecNo())))
								EndIf
								//������������������������������������������������������������������������Ŀ
								//�Recalcula a Quantidade Liberada                                         �
								//��������������������������������������������������������������������������
								RecLock("SC6")
								nQtdLib := ( SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT ) )
								If nQtdLib > 0
									//������������������������������������������������������������������������Ŀ
									//�Verifica o tipo de Liberacao                                            �
									//��������������������������������������������������������������������������
									If ( SC5->C5_TIPLIB == "1" )
										//������������������������������������������������������������������������Ŀ
										//�Libera por Item de Pedido                                               �
										//��������������������������������������������������������������������������
										Begin Transaction
											MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.F.,.T.,.T.,lLiber,lTransf)
										End Transaction
									Else
										//������������������������������������������������������������������������Ŀ
										//�Libera por Pedido                                                       �
										//��������������������������������������������������������������������������			
										Begin Transaction
											RecLock("SC6")
											SC6->C6_QTDLIB := nQtdLib
											MsUnLock()
											aadd(aRegistros,SC6->(RecNo()))
										End Transaction
									EndIf
								EndIf
								SC6->(MsUnLock())
							EndIf
						EndIf
					EndIf
					dbSelectArea(cAliasSC6)
					dbSkip()
				EndDo
				//������������������������������������������������������������������������Ŀ
				//�Libera por Total de Pedido                                              �
				//��������������������������������������������������������������������������
				If ( Len(aRegistros) > 0 )
					Begin Transaction
						SC6->(MaAvLibPed(SC5->C5_NUM,lLiber,lTransf,.F.,aRegistros,Nil,Nil,Nil,Nil))
					End Transaction
				EndIf
				//������������������������������������������������������������������������Ŀ
				//�Atualiza o Flag do Pedido de Venda                                      �
				//��������������������������������������������������������������������������
				Begin Transaction
					SC6->(MaLiberOk({SC5->C5_NUM},.F.))
				End Transaction
				//������������������������������������������������������������������������Ŀ
				//�Controle de cancelamento por solicitacao do usuario                     �
				//��������������������������������������������������������������������������
				dbSelectArea(cAliasSC6)
			EndDo
			If lQuery
				dbSelectArea(cAliasSC6)
				dbCloseArea()
				dbSelectArea("SC6")
			EndIf
			//������������������������������������������������������������������������Ŀ
			//�Carrega perguntas do MATA410                                            �
			//��������������������������������������������������������������������������
			Pergunte("MTA410",.F.)
		EndIf
EndCase
RestArea(aArea)
Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410NoDlvr
Chamada no trigger do campo de cliente de entrega, apaga o conte�do da loja caso 
o c�digo do cliente de entrega esteja em branco.  

@sample 	A410NoDlvr() 
@return	cLoja, c�digo da loja - vazio se n�o houver c�digo de cliente de entrega preenchido. 

@author		Renato Cunha
@since		03/05/17    
@version	P12.1.16 
/*/
//------------------------------------------------------------------------------ 
Function A410NoDlvr()

Local 	cLoja	:= M->C5_LOJAENT

If !Empty( M->C5_LOJAENT ) .AND. Empty( M->C5_CLIENT )
	cLoja := Space( TAMSX3("C5_LOJAENT")[2] )
	A410ReCalc()
EndIf
Return cLoja

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410LojEnt
Valida��es do campo de Loja de entrega. 
N�o permite deixar apenas o campo de Loja de entrega preenchido caso o formul�rio
esteja sendo editado por usut�rio.

@sample 	A410LojEnt() 
@return	lRet, L�gico  - Conte�do do campo est� Ok. 

@author		Renato Cunha
@since		03/05/17    
@version	P12.1.16 
/*/
//------------------------------------------------------------------------------ 
Function A410LojEnt()

Local lRet := .T. 

If Type("l410Auto") <> "U" .And. !l410Auto
	If ( !Empty( M->C5_LOJAENT ) .And. Empty( M->C5_CLIENT ) ).Or.  ( !Empty( M->C5_CLIENT ) .And. Empty( M->C5_LOJAENT ) )
		lRet := .F. 
		Help(" ",1,"A410LJENTR")
	EndIf
EndIf

If lRet
	If ! Empty(M->C5_LOJAENT)
		lRet := A410Loja() .And. A410ReCalc()
	Else
		A410ReCalc()
	EndIf
EndIf
Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} a410IsNItem
Identifica se o pedido ser� quebrado em mais de uma nota caso o numero de itens
do pedido for maior que o parametro MV_NUMITEN. Valor default do parametro � 99.

@sample 	a410IsNItem() 
@return	lRet, L�gico  - Pedido ter� quebra

@author		SQUAD CRM / FAT
@since		03/05/18   
@version	P12.1.17 
/*/
//------------------------------------------------------------------------------ 
Function a410IsNItem()
Return(__lNumItem)  

//------------------------------------------------------------------------------
/*/{Protheus.doc} a410CdBar
Realiza a inclus�o de produtos via C�digo de Barra

@sample 	a410CdBar(lM410Bar, oGetD, nOpc) 
@param		lM410Bar, L�gico	, Utiliza o Ponto de Entrada M410CODBAR
@param		oGetD	, Objeto	, Objeto MsGetDados do Pedido de Venda
@param		nOpc	, Num�rico	, Informa a opera��o realizada
@return		Nil

@author		SQUAD CRM / FAT
@since		19/10/18   
@version	P12.1.17 
/*/
//------------------------------------------------------------------------------ 
Function a410CdBar(lM410Bar, oGetD, nOpc)

Local nPosProd 	:= 0
	
SetKey(VK_F10,Nil)
	
If Type("lCodBarra") <> "U"
	nPosProd 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	n	:= Len(aCols)
	If Empty(aCols[n][nPosProd]) .Or. (Len(aCols) > 0 .And. A410LinOk())
		IIF(lCodBarra .And. !lM410Bar,a410EntraBarra(oGetD),IIF(lCodBarra .And. lM410Bar,Execblock("M410CODBAR",.F.,.F.,{nOpc,oGetD}),))
	EndIf
EndIf
SetKey(VK_F10,{||a410CdBar(lM410Bar, oGetD, nOpc)})

oGetd:Refresh()
Return
