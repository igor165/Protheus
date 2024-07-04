#Include "Totvs.Ch"
#Include "FWMVCDEF.Ch"
#INCLUDE "FWMBROWSE.CH"
#Include "VDFM220.Ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDFM220  � Autor � Wagner Mobile Costa   � Data �  10.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Rotina para manuten��o dos inicializadores de portaria      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFA220()                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���            �          �      �                                          ���
�������������������������������������������������������������������������������*/
Function VDFM220()

Local aDir      := Directory("\inicializadores\*.INI", ""), aRegs := {}
Local aCols     := {    { STR0001, "RCC_CODIGO", "C", 02, 0, "" },;		// 'Tipo'
				 	 	{ STR0002, "RCC_DESCRI", "C", 30, 0, "" },;		// 'Descri��o'
				 	 	{ STR0003, "X5_CHAVE", "C", 1, 0, "" },;		// 'Categoria'
				 	 	{ STR0002, "X5_DESCRI", "C", 30, 0, "" } }		// 'Descri��o'
Local aSeek     := { }
Local aIndex    := { { "RCC_CODIGO" }, { "RCC_DESCRI" } } 
Local cPerg	    := "VDFM220", nPos := 1

Aadd( aSeek, {STR0001, {{"", "C", 2 , 0, "RCC_CODIGO",}},1,.T. } )
Aadd( aSeek, {STR0002, {{"", "C", 30, 0, "RCC_DESCRI",}},2,.T. } )

Private cAliasQRY := GetNextAlias()
Private oTmpTable 

MsAguarde({|| LoadData(aCols) }, STR0004,STR0005,.T.)	// 'Manuten�ao dos Inicializadores' ## 'Montando a consulta. Aguarde ...'

DbSelectArea(cAliasQRY)

Pergunte(cPerg, .T.)

SetKey(VK_F12, { || Pergunte(cPerg, .T.) })

oBrowse := FWMBrowse():New()
oBrowse:AddLegend( "RCC_CONFIG = 1",	"GREEN" ,	STR0006)				// 'Configurado'
oBrowse:AddLegend( "RCC_CONFIG = 0",	"RED" 	,	STR0007)				// 'N�o Configurado'
oBrowse:SetAlias(cAliasQRY)
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetTemporary(.T.)
oBrowse:SetSeek(.T.,aSeek)
oBrowse:SetFields(aCols)
oBrowse:Activate()

DbSelectArea(cAliasQRY)
If oTmpTable <> Nil   
	oTmpTable:Delete()  
	oTmpTable := Nil 
EndIf
SetKey(VK_F12, NIL)

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � LoadData � Autor � Wagner Mobile Costa   � Data �  17.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Carga dos Dados                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function LoadData(aCols)

Local aStruct 	:= { }, aCateg := {}, nPos := 01

For nPos := 1 To Len(aCols)
	Aadd(aStruct, { aCols[nPos][2], aCols[nPos][3], aCols[nPos][4], aCols[nPos][5] })
Next
Aadd(aStruct, { "RCC_CONFIG", "N", 1, 0 })

DbSelectArea("SX5")
DbSeek(xFilial() + "28")
While X5_FILIAL == xFilial() .And. X5_TABELA == "28" .And. ! Eof()
	If X5_CHAVE >= "0" .And. X5_CHAVE <= "9" 
		Aadd(aCateg, { AllTrim(X5_CHAVE), AllTrim(X5_DESCRI) })
	EndIf
	DbSkip()
EndDo

BeginSql Alias "QRYRCC"
	SELECT SUBSTRING(RCC_CONTEU, 1, 2) AS RCC_CODIGO, SUBSTRING(RCC_CONTEU, 3, 30) AS RCC_DESCRI
      FROM %table:RCC% RCC
     WHERE %notDel% AND RCC_FILIAL = %Exp:xFilial("RCC")% AND RCC_CODIGO = %Exp:'S101'%
       AND R_E_C_N_O_ IN (%Exp:QryUtRCC({2,30})%)
EndSql

oTmpTable := FWTemporaryTable():New(cAliasQRY)
oTmpTable:SetFields( aStruct ) 
oTmpTable:AddIndex("IND1", {"RCC_CODIGO"})
oTmpTable:AddIndex("IND2", {"RCC_DESCRI"})
oTmpTable:Create() 


While ! QRYRCC->(Eof())
	RecLock(cAliasQry, .T.)
	(cAliasQry)->RCC_CODIGO := QRYRCC->RCC_CODIGO
	(cAliasQry)->RCC_DESCRI := QRYRCC->RCC_DESCRI
	(cAliasQry)->X5_DESCRI  := STR0008		// 'Padr�o'
	(cAliasQry)->RCC_CONFIG := 0
	If File("\inicializadores\s101_cab_" + RTrim(QRYRCC->RCC_CODIGO) + ".ini") .or.;
	   File("\inicializadores\s101_item_" + RTrim(QRYRCC->RCC_CODIGO) + "_p.ini") .or.;
	   File("\inicializadores\s101_itemhist_" + RTrim(QRYRCC->RCC_CODIGO) + "_p.ini")
		(cAliasQry)->RCC_CONFIG := 1
	EndIf		
	MsUnLock()
	
	For nPos := 1 To Len(aCateg)
		RecLock(cAliasQry, .T.)
		(cAliasQry)->RCC_CODIGO := QRYRCC->RCC_CODIGO
		(cAliasQry)->RCC_DESCRI := QRYRCC->RCC_DESCRI
		(cAliasQry)->X5_CHAVE   := aCateg[nPos][1]
		(cAliasQry)->X5_DESCRI  := aCateg[nPos][2]
		(cAliasQry)->RCC_CONFIG := 0
		If File("\inicializadores\s101_item_" + RTrim(QRYRCC->RCC_CODIGO) + "_" + aCateg[nPos][1] + ".ini") .or.;
		   File("\inicializadores\s101_itemhist_" + RTrim(QRYRCC->RCC_CODIGO) + "_" + aCateg[nPos][1] + ".ini")
			(cAliasQry)->RCC_CONFIG := 1
		EndIf
		MsUnLock()
	Next
	QRYRCC->(DbSkip())
EndDo
QRYRCC->(DbCloseArea())

DbSelectArea(cAliasQRY)
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Wagner Mobile Costa   � Data �  13.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Menu Funcional                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0009 	ACTION "VDF220M" 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0	// 'Visualizar' 
ADD OPTION aRotina TITLE STR0010	ACTION "VDF220M" 	OPERATION 9						 	ACCESS 0	// 'Incluir' 
ADD OPTION aRotina TITLE STR0011	ACTION "VDF220M" 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0	// 'Alterar'	 
ADD OPTION aRotina TITLE STR0012	ACTION "VDF220M" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0	// 'Excluir' 
ADD OPTION aRotina TITLE STR0021	ACTION "VDF220L" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0	// 'Legenda' 
ADD OPTION aRotina TITLE STR0036	ACTION "VDF220V" 	OPERATION 7 						ACCESS 0	// 'Vari�veis' 

Return aRotina

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDF220M  � Autor � Wagner Mobile Costa   � Data �  13.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Manuten��o do inicializador selecionado                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDF220M()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Function VDF220M(cAlias, nReg, nOpc)

Local aAdvSize			:= {}      
Local aInfoAdvSize	:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}
Local lRet 			:= .F., lCateg := .F., nFiles := 0
Local bOk      		:= {|| lRet := UpdText(oText, aData, nOpc == 4 .And. ! lCateg, @nFiles, oDlg) }
Local bCancel			:= {||oDlg:End()}, oDlg, aFolder := { STR0013, STR0014, STR0015, STR0016,  STR0017} // 'Cabe�alho' # 'Item para publica��o' # 'Item para hist�ricos' # 'Rodap�' # 'Rodap� Padr�o' 
Local aData            := { "", "", "", "", "" }, nFolder := 1, oText := {}
Local aFiles 			:= { 	"\inicializadores\s101_cab_" + (cAlias)->RCC_CODIGO + ".ini",;
								"\inicializadores\s101_item_" + (cAlias)->RCC_CODIGO + "_p.ini",;
								"\inicializadores\s101_itemhist_" + (cAlias)->RCC_CODIGO + "_p.ini",;
								"\inicializadores\s101_rod_" + (cAlias)->RCC_CODIGO + ".ini",;
								"\inicializadores\s101_rod_p.ini" }

//2=Inclusao
//3=Altera��o
//4=Exclus�o

If nOpc = 2 .And. (cAlias)->RCC_CONFIG = 1
	MsgInfo(STR0018)	// 'Aten��o. Este item j� est� configurado. Favor utilizar o bot�o alterar !'
	Return
ElseIf nOpc = 3 .And. (cAlias)->RCC_CONFIG = 0
	MsgInfo(STR0019) // 'Aten��o. Este item n�o est� configurado. Favor utilizar o bot�o Incluir !'
	Return
EndIf

If (lCateg := ! Empty((cAlias)->X5_CHAVE))
	aFiles 	 := { 	"\inicializadores\s101_item_" + (cAlias)->RCC_CODIGO + "_" + AllTrim((cAlias)->X5_CHAVE) + ".ini",;
					"\inicializadores\s101_itemhist_" + (cAlias)->RCC_CODIGO + "_" + AllTrim((cAlias)->X5_CHAVE) + ".ini" }
	aFolder := { aFolder[2], aFolder[3] }	
	aData   := { "", "" }
EndIf

For nFolder := 1 To Len(aFolder)
	If File(aFiles[nFolder])
		aData[nFolder] := LoadFile(aFiles[nFolder])
	EndIf
Next

Begin Sequence

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
DEFINE MSDIALOG oDlg TITLE STR0020 + 	AllTrim((cAliasQry)->RCC_CODIGO) + '-' + AllTrim((cAliasQry)->RCC_DESCRI) + '-' +;
											AllTrim((cAliasQry)->X5_DESCRI) + ']';		// 'Edi��o Modelo Ato ['
		FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

oFolder := TFolder():New( 0, 0, aFolder, aFolder, oDlg,,,, .T.,,oDlg:NCLIENTWIDTH/2,(oDlg:NCLIENTHEIGHT/2))
//oFolder := TFolder():New( 0, 0, aFolder, aFolder, oDlg,,,, .T.,,aAdvSize[6]/100,aAdvSize[5]/100)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

For nFolder := 1 To Len(aFolder)
	Aadd(oText, tSimpEdit():New( , , , , "",  @aData[nFolder], mv_par01, .F., .F.,oFolder:aDialogs[nFolder]))
	
	oText[Len(oText)]:oSimpEdit:TextFamily("Courier New")
	oText[Len(oText)]:oSimpEdit:TextSize(12) 
	oText[Len(oText)]:oSimpEdit:Load(aData[nFolder])
	 
	If nOpc == 4
		oText[Len(oText)]:oSimpEdit:lReadonly := .T.
	EndIf
Next

//-- Cria��o de editor invisivel para compara��o de editor n�o preenchido
oPnlVis := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,10,10,.T.,.T. )
oPnlVis:Align 	:= CONTROL_ALIGN_BOTTOM
oPnlVis:lVisible := .F.

Aadd(oText, tSimpEdit():New( , , , , "",  "", mv_par01, .F., .F.,oPnlVis))

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

If !ExistDir("\inicializadores")
	MakeDir( "\inicializadores" )
EndIf

If lRet
	RecLock(cAlias, .F.)
	(cAlias)->RCC_CONFIG := 0
	For nFolder := 1 To Len(aFiles) - nFiles
		If Empty(aData[nFolder]) .Or. nOpc = 4 
			Delete File (aFiles[nFolder])
		Else
			
			nHandle := FCreate(aFiles[nFolder])
			FWrite(nHandle, aData[nFolder] + CRLF)
			FClose(nHandle)
			(cAlias)->RCC_CONFIG := 1
		EndIf
	Next
	(cAlias)->(MsUnLock())
EndIf

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDF220L  � Autor � Wagner Mobile Costa   � Data �  17.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Apresenta��o da descri��o da legenda                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDF220L()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Function VDF220L

Local aCores := {	{"ENABLE"	,STR0006},;	// 'Configurado'
					{"DISABLE"	,STR0007 } }  // 'N�o Configurado'
					
BrwLegenda(STR0021,STR0022,aCores) //'Legenda' # 'Situa��o Inicializador'

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDF220V  � Autor �                       � Data �  17.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Apresenta��o das vari�veis dispon�veis                      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDF220V()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Function VDF220V()
	MsgInfo(STR0027 +CHR(10)+CHR(13) +  ;					//"Vari�veis dispon�veis para uso geral:"
			STR0028 +CHR(10)+CHR(13) +  ;					//"  {*[XDOC]*} -> Numero do documento gerado"
			STR0029 +CHR(10)+CHR(13) +  ;					//"  {*[XANO]*} -> Ano do documento gerado"
			STR0030 +CHR(10)+CHR(13) +  ;					//"  {*[data]*} -> Data para assinatura do documento"
			STR0031 +CHR(10)+CHR(13) +  ;					//"  {*[assinatura]*} -> Nome da pessoa que assinar� o documento"
			STR0032 +CHR(10)+CHR(13) +CHR(10)+CHR(13) + ;	//"  {*[assinatura_cargo]*} -> Cargo da pessoa que assinar� o documento"
			STR0024 +CHR(10)+CHR(13) +  ; 					//"Vari�veis dispon�veis na inclus�o do item de nomea��o:"
			STR0025 +CHR(10)+CHR(13) +  ; 					//"  [*dtoc(dPosse)*] - Data da Posse"
			STR0026 +CHR(10)+CHR(13) +CHR(10)+CHR(13) +  ; 	//"  [*dtoc(dNomeac)*] - Data da Nomea��o"
			STR0033 +CHR(10)+CHR(13) +  ;					//"Outras op��es (Exemplos):"
			STR0034 +CHR(10)+CHR(13) +  ;					//"  [*Posicione('SQ3',1,xFilial('SQ3')+SRJ->RJ_CARGO,'Q3_TABFAIX')*]"
			STR0035 +CHR(10)+CHR(13) +CHR(10)+CHR(13);      //"  [*SQG->QG_NOME*]"
			+CHR(13)+CHR(13)) // Quebra de Linha
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � UpdText  � Autor � Wagner Mobile Costa   � Data �  13.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Atualiza as informa��es do objeto text para grava��o        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � UpdText()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function UpdText(oText, aData, lExcPadrao, nFiles, oDlg)

Local nPos := 1, lRet := .T.

For nPos := 1 To Len(aData)
	aData[nPos] := oText[nPos]:GetText()
	If mv_par01 <> 1		//-- Edi��o de Texto com formata��o autom�tica de HTML
		aData[nPos] := VD210Macro(aData[nPos])
	EndIf
	If oText[nPos]:GetText() == oText[Len(oText)]:GetText()
		aData[nPos] := ""
	EndIf
Next

If lExcPadrao
	If ! MsgYesNo(STR0023) // 'Aten��o. Deseja excluir tamb�m o rodap� padr�o que � utilizado em todos os documentos ?'
		nFiles := 1
	EndIf
EndIf

If lRet
	oDlg:End()
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VD210Macro � Autor � Wagner Mobile Costa � Data �  13.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Trata o caractere "-&gt;" que deve ficar como -> no ADVPL   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VD210Macro()                                                  ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function VD210Macro(cTexto)
	
	Local aArea      := GetArea()  
	
	Local cBuffer    := ""
	Local cAux       := ""
	Local cRetorno   := ""
	Local nTamanho   := 0
	Local nInicial   := 0
	Local nFinal     := 0 
	Local I          := 0
	                    
	cBuffer  := cTexto
	nTamanho := Len( cBuffer )
	                                       
	For I:=1 TO nTamanho          
		    
		If (AT("[*",Substr(cBuffer,i,2))> 0) .Or. (AT("[{*",Substr(cBuffer,i,3))> 0) 
			nInicial := I
		Endif
		If (AT("*]",Substr(cBuffer,i,2))> 0)
			nFinal := I + 1
		Endif
		If (AT("*}]",Substr(cBuffer,i,3))> 0)
			nFinal := I + 2  
		Endif
	
		IF (nInicial==0 .And. nFinal==0) 
			cRetorno := cRetorno+Substr(cBuffer,i,1)
		ElseIf 	nInicial<>0 .and. nFinal<>0 
		
			cAux := Substr(cBuffer,nInicial,nFinal-nInicial + 1)
			IF At("-&gt;", cAux) > 0
				cAux := StrTran(cAux, "-&gt;", "->") 
			Endif
			cRetorno += cAux
			 
			I := nFinal
			nInicial:= 0
			nFinal  := 0
		Endif
	Next
	RestArea( aArea ) 
Return(cRetorno)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � LoadFile � Autor � Wagner Mobile Costa   � Data �  13.06.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Carrega o arquivo de modelo da portaria                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � LoadFile()                                                   ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function LoadFile(cFileOpen)

Local cBuffer := ""
                             
FT_FUSE(cFileOpen)         //ABRIR
FT_FGOTOP()                //PONTO NO TOPO    

While !FT_FEOF()
	IncProc()
	cbuffer  := cbuffer+ FT_FREADLN()
	FT_FSKIP()
endDo
FT_FUSE()

                                                                     
Return(cbuffer)