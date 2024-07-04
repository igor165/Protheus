#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������	������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAC470  � Autor � Taina Alberto Cardoso � Data � 01/12/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta de Historico de Fatores de Emissoes               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGASGA                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function SGAC470()

//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM()

Private cCadastro := "Consulta de Historico de fatores de Emissao" //"Consulta de Historico de fatores de Emissao"
Private aRotina := MenuDef()

If !SGAUPDGEE()//Verifica se o update de GEE esta aplicado
	Return .F.
Endif
If !SGAUPDCAMP()
	Return .F.
EndIf

dbSelectArea("TD2")
DbSetOrder(1)
mBrowse( 6, 1,22,75,"TD2",,,,,,)

//�������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK) 	    	 �
//���������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .t.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �18/01/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :=	{ { "Pesquisar"   ,	"AxPesqui"	, 0 , 1},; //"Pesquisar"
					     { "Visualizar"	,	"SG470INC"	, 0 , 2},; //"Visualizar"
					     { "Hist�rico"	,	"SAF470HI"	, 0 , 2}} //"Hist�rico"

Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �18/01/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef2()
Local aRotina :=	{ { "Pesquisar"   ,	"SGC470PES"	, 0 , 1},; //"Pesquisar"
					     { "Visualizar"	,	"SGC470VI"	, 0 , 2}}  //"Visualizar"


Return aRotina
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGA470HI  �Autor  �Taina A. Cardoso    � Data �  01/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera o Historico dos Produtos.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAC470                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  SAF470HI()

Local oTempTRB

aDBFB := {}

Aadd(aDBFB,{"DATAIN"   ,"D", 08,0})
Aadd(aDBFB,{"HORAIN"   ,"C", 08,0})
Aadd(aDBFB,{"GASES"    ,"C", 03,0})
Aadd(aDBFB,{"CONSUMO"  ,"C", 03,0})
Aadd(aDBFB,{"FONTE"    ,"C", 03,0})

oTempTRB := FWTemporaryTable():New( "TRB470", aDBFB )
oTempTRB:AddIndex( "1", {"DATAIN","HORAIN"} )
oTempTRB:Create()

aTRB :=	{{"Data"          ,"DATAIN" ,"D",08,0,"99/99/99"},;   //Data
          {"Hora"          ,"HORAIN" ,"C",08,0,"99:99:99"},;   //"Hora"
          {"Alterou Gases"  ,"GASES"  ,"C",03,0,"@!"      },;   //"Altera Gases"
          {"Alterou Consumo","CONSUMO","C",03,0,"@!"      },;   //"Altera Consumo"
          {"Alterou Fonte"  ,"FONTE"  ,"C",03,0,"@!"      }}    //"Altera Fonte"


Processa({ |lEnd| SGAFLTRB() }, "Aguarde ..Processando Arquivo de S.S.") //"Aguarde ..Processando Arquivo de S.S."

Private aRotina := MenuDef2()

DbSelectarea("TRB470")
dbSetOrder(1)
DbGotop()
mBrowse(6,1,22,75,"TRB470",aTRB)

oTempTRB:Delete()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAFLTRB  �Autor  �Taina A. Cardoso    � Data �  02/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Filtras as Tabelas de Historicos TD5, TD6, TD7              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SGAC470                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAFLTRB()

Private cAliasTMI := GetNextAlias()

//Verifica alteracao em Locais de Consumo
dbSelectArea("TD6")
dbSetOrder(1)
dbSeek(xFilial("TD6")+TD2->TD2_CODPRO)
While !Eof() .And. TD6->TD6_CODPRO == TD2->TD2_CODPRO

	Dbselectarea("TRB470")
	Dbgotop()
	If !Dbseek(DTOS(TD6->TD6_DATA)+TD6->TD6_HORA)
		RecLock("TRB470",.T.)
		TRB470->DATAIN  := TD6->TD6_DATA
		TRB470->HORAIN  := TD6->TD6_HORA
		TRB470->GASES   := "N�o"
		TRB470->CONSUMO := "Sim"
		TRB470->FONTE   := "N�o"
		MsUnlock("TRB470")
	Endif
	dbSelectArea("TD6")
	dbSkip()
End

//Veirifica alteracao em Gases

dbSelectArea("TD7")
dbSetOrder(1)
dbSeek(xFilial("TD7")+TD2->TD2_CODPRO)
While !Eof() .And. TD7->TD7_CODPRO == TD2->TD2_CODPRO

	Dbselectarea("TRB470")
	Dbgotop()
	If Dbseek(DTOS(TD7->TD7_DATA)+TD7->TD7_HORA)
		RecLock("TRB470",.F.)
		TRB470->GASES := "Sim"
		MsUnlock("TRB470")
	ElseIf !Dbseek(DTOS(TD7->TD7_DATA)+TD7->TD7_HORA)
		RecLock("TRB470",.T.)
		TRB470->DATAIN  := TD7->TD7_DATA
		TRB470->HORAIN  := TD7->TD7_HORA
		TRB470->GASES   := "Sim"
		TRB470->CONSUMO := "N�o"
		TRB470->FONTE   := "N�o"
		MsUnlock("TRB470")
	Endif
	dbSelectArea("TD7")
	dbSkip()
End

//Verifica alteracao em Fonte
dbSelectArea("TD8")
dbSetOrder(1)
dbSeek(xFilial("TD8")+TD2->TD2_CODPRO)
While !Eof() .And. TD8->TD8_CODPRO == TD2->TD2_CODPRO

	Dbselectarea("TRB470")
	Dbgotop()
	If Dbseek(DTOS(TD8->TD8_DATA)+TD8->TD8_HORA)
		RecLock("TRB470",.F.)
		TRB470->FONTE := "Sim"
		MsUnlock("TRB470")
	ElseIf !Dbseek(DTOS(TD8->TD8_DATA)+TD8->TD8_HORA)
		RecLock("TRB470",.T.)
		TRB470->DATAIN  := TD8->TD8_DATA
		TRB470->HORAIN  := TD8->TD8_HORA
		TRB470->GASES   := "N�o"
		TRB470->CONSUMO := "N�o"
		TRB470->FONTE   := "Sim"
		MsUnlock("TRB470")
	Endif
	dbSelectArea("TD8")
	dbSkip()
End

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGC470VI  �Autor  �Taina A. Cardoso    � Data �  02/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualiza o Historico de Produtos.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAC470                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGC470VI()

	Local cTitulo := "Hist�ricos de Produtos Geradores de Gases - GEE"
	Local i
	Local lOk := .F.
	Local aPages:= {},aTitles:= {}
	Local oDlg470,oFolder470,oSplitter
	Local oPanelTop,oPanelBot,oPanelF1,oPnlLgnd
	Local oPanelH1, oPanelH2,oPnlBtn, oMenu
	Local nIdx := 0

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Variaveis da GetDados
	Local cGetWhlGas  := "", cGetWhlFon:= ""
	Private aColsGas  := {}, aColsFon  := {}, aColsEst := {}
	Private aHeadGas  := {}, aHeadFon  := {}, aHeadEst := {}
	Private aSvGasCols:= {}, aSvFonCols:= {}, aSvEstCols := {}
	Private nTD4 := 0, nTD5 := 0//Variaveis para o When dos campos TD4_CODGAS e TD5_CODFON
	Private oGetEst, oGetFon

	//Variaveis de Tela
	Private aTela := {}, aGets := {}

	//Variaveis para Estrutura Organizacional e TRB
	Private aLocal := {}, aMarcado := {}, aDefinido := {}, aHeadLocal := {}
	Private oTree
	Private aTRB := SGATRBEST(.T.)
	Private aItensCar := {},nNivel := 0,nMaxNivel := 0
	Private cCodEst := "001", cDesc := NGSEEK("TAF","001000",1,"TAF->TAF_NOMNIV")
	Private lRateio := NGCADICBASE("TAF_RATEIO"	,"D","TAF",.F.)
	Private lRetS 	:= NGCADICBASE("TAF_ETAPA"	,"A","TAF",.F.)

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	Aadd(aObjects,{030,030,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)


	dbSelectArea("TAF")
	dbSetOrder(1)
	If !dbSeek(xFilial("TAF")+cCodest+"000")
		ShowHelpDlg("Aten��o",{"N�o existe Estrutura Organizacional cadastrada para este M�dulo."},2,; //"Aten��o"###"N�o existe Estrutura Organizacional cadastrada para este M�dulo."
									{"Favor cadastrar uma Estrutura Organizacional."}) //"Favor cadastrar uma Estrutura Organizacional."
		Return .F.
	Endif

	//Cria arquivo temporario
	cTRBSGA := aTRB[3]
	oTempTRBSGA := FWTemporaryTable():New( cTRBSGA, aTRB[1] )
	For nIdx := 1 To Len( aTRB[2] )
		oTempTRBSGA:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), aTRB[2,nIdx] )
	Next nIdx
	oTempTRBSGA:Create()

	//������������������������������������Ŀ
	//� Cria variaveis de Fontes de Emissao�
	//��������������������������������������
	aCols := {}
	aHeader := {}

	//Criacao do aCols com estrutura e nivel
	cGetWhlFon := "TD8->TD8_FILIAL == '"+xFilial("TD8")+"' .AND. TD8->TD8_CODPRO == '"+TD2->TD2_CODPRO+"'"
	FillGetDados( 1, "TD8", 1, "TD2->TD2_CODPRO", {|| }, {|| .T.},{"TD8_CODPRO"},,,,{|| NGMontaAcols("TD8", TD2->TD2_CODPRO,cGetWhlFon)})
	aColsFFon := aClone(aCols)

	aSvFonCols:= aClone(aColsFFon)

	aCols := {}
	aHeader := {}
	//Criacao de aHeader sem estrutura e nivel
	cGetWhlFon := "TD5->TD5_FILIAL == '"+xFilial("TD5")+"' .AND. TD5->TD5_CODPRO == '"+TD2->TD2_CODPRO+"'"


	aHeadFon := aClone(aHeader)

	//Cria os Folders
	Aadd(aTitles,OemToAnsi("Locais de Consumo")) //"Locais de Consumo"
	Aadd(aPages,"Header 1")
	Aadd(aTitles,OemToAnsi("Gases Gerados")) //"Gases Gerados"
	Aadd(aPages,"Header 2")



	Define MsDialog oDLG470 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

	//������������������������������������Ŀ
	//� Monta Estrutura da Tela            �
	//��������������������������������������
	oSplitter := tSplitter():New(0,0,oDlg470,100,100,1 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelTop := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
	oPanelTop:nHeight := 6
	oPanelTop:Align := CONTROL_ALIGN_TOP

	oPanelBot := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
	oPanelBot:Align := CONTROL_ALIGN_BOTTOM

	//������������������������������������Ŀ
	//� Parte de Superior da Tela          �
	//��������������������������������������
	Dbselectarea("TD2")
	RegToMemory("TD2",(2 == 3))
	oEnc470 := MsMGet():New("TD2",TD2->(Recno()),2,,,,,aPosObj[1],,,,,,oPanelTop)
	oEnc470:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//������������������������������������Ŀ
	//� Parte Inferior da Tela             �
	//��������������������������������������
	oFolder470 := TFolder():New(0,0,aTitles,aPages,oPanelBot,,,,.T.,.f.)
	oFolder470:aDialogs[1]:oFont := oDLG470:oFont
	oFolder470:aDialogs[2]:oFont := oDLG470:oFont
	oFolder470:Align := CONTROL_ALIGN_ALLCLIENT

	//������������������������������������Ŀ
	//� Folder 01 - Locais de Consumo      �
	//��������������������������������������
	oPanelH1 := TPanel():New(0,0,,oFolder470:aDialogs[1],,,,,RGB(67,70,87),200,200,.F.,.F.)
	oPanelH1:Align := CONTROL_ALIGN_TOP
	oPanelH1:nHeight := 20

	@ 002,004 Say OemToAnsi("Escolha o Local Consumidor clicando duas vezes sobre a pasta.") Of oPanelH1 Color RGB(255,255,255) Pixel //"Escolha o Local Consumidor clicando duas vezes sobre a pasta."

	oPanelF1 := TPanel():New(0,0,,oFolder470:aDialogs[1],,,,,,10,10,.F.,.F.)
	oPanelF1:Align := CONTROL_ALIGN_ALLCLIENT



	oTree := DbTree():New(005, 022, 170, 302, oPanelF1,,, .t.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	nCnf := 0

	dbSelectArea("TD6")
	dbSetOrder(1)
	dbSeek(xFilial("TD6")+TD2->TD2_CODPRO)
	While !eof() .and. xFilial("TD6")+TD2->TD2_CODPRO == TD6->TD6_FILIAl+TD6->TD6_CODPRO
		If DTOS(TD6->TD6_DATA) + TD6->TD6_HORA > DTOS(TRB470->DATAIN) + TRB470->HORAIN
		dbSelectArea("TD6")
		DbSkip()
			Loop
	Else
			nCnt := aScan(aLocal, {|x| Trim(Upper(x[1])) == TD6->TD6_CODNIV})
			If nCnt == 0
				aAdd(aLocal,{TD6->TD6_CODNIV, TD6->TD6_PORCEN,TD6->TD6_DATA,TD6->TD6_HORA, .T.} )
				nCnt := Len(aLocal)
			ElseIf !(DTOS(TD6->TD6_DATA) + TD6->TD6_HORA > DTOS(aLocal[nCnt][3]) + aLocal[nCnt][4])
				dbSelectArea("TD6")
				dbSkip()
				Loop
			EndIf
			If nCnt > 0 .And. TD6->TD6_OPERAC == "3"
				aDel(aLocal,nCnt)
				aSize(aLocal, Len(aLocal)-1)
				dbSelectArea("TD6")
				dbSkip()
				Loop
			EndIf
		EndIf
		dbSelectArea("TD6")
		dbSkip()
	End

	dbSelectArea("TD6")
	dbSetOrder(2)
	dbSeek(xFilial("TD6")+TD2->TD2_CODPRO)
	While !eof() .and. xFilial("TD6")+TD2->TD2_CODPRO == TD6->TD6_FILIAl+TD6->TD6_CODPRO
		If DTOS(TD6->TD6_DATA) + TD6->TD6_HORA > DTOS(TRB470->DATAIN) + TRB470->HORAIN
		dbSelectArea("TD6")
		DbSkip()
			Loop
		Else
			For i:=1 to Len(aLocal)
				If aLocal[i][1] == TD6->TD6_CODNIV .And. aLocal[i][2] <> TD6->TD6_PORCEN
					aLocal[i][2] := TD6->TD6_PORCEN
				EndIf
			Next
			dbSelectArea("TD6")
			dbSkip()
		EndIf
	End
	//Carrega estrutura organizacional
	aMarcado := aClone(aLocal)
	SG470TREE(1)

	If Str(2,1) $ "2/5"
		oTree:bChange	:= {|| SG470TREE(2)}
		oTree:BlDblClick:= {|| SGC470FON(oTree:GetCargo(),.T.)}
	Else
		oTree:bChange	:= {|| SG470TREE(2)}
		oTree:blDblClick:= {|| SG470MRK()}
	EndIf

	//������������������������������������Ŀ
	//� Painel de Legenda                  �
	//��������������������������������������
	oPnlBtn := TPanel():New(00,00,,oPanelF1,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	oBtnMrk  := TBtnBmp():NewBar("ng_ico_altid","ng_ico_altid",,,,{|| SG470MRK()},,oPnlBtn,,,"Marcar Localiza��o",,,,,"")//"Marcar Localiza��o"
	oBtnMrk:Align  := CONTROL_ALIGN_TOP
	oBtnMrk:lVisible := Inclui .or. Altera

	oBtnFon  := TBtnBmp():NewBar("ng_ico_relac","ng_ico_relac",,,,{|| SGC470FON(oTree:GetCargo(),.T.)},,oPnlBtn,,,"Fontes de Emiss�o",,,,,"")//"Fontes de Emiss�o"
	oBtnFon:Align  := CONTROL_ALIGN_TOP
	oBtnFon:lVisible := .T.

	//������������������������������������Ŀ
	//� Painel de Legenda                  �
	//��������������������������������������
	oPnlLgnd := TPanel():New(00,00,,oPanelF1,,,,,RGB(200,200,200),12,12,.F.,.F.)
	oPnlLgnd:Align := CONTROL_ALIGN_BOTTOM
	oPnlLgnd:nHeight := 30

	@ 002,010 Bitmap oLgnd1 Resource "Folder10" Size 25,25 Pixel Of oPnlLgnd Noborder When .F.
	@ 005,025 Say OemToAnsi("Localiza��o Normal") Of oPnlLgnd Pixel //"Localiza��o Normal"

	@ 002,100 Bitmap oLgnd1 Resource "Folder7" Size 25,25 Pixel Of oPnlLgnd Noborder When .F.
	@ 005,115 Say OemToAnsi("Local Consumidor") Of oPnlLgnd Pixel //"Local Consumidor"

	//������������������������������������Ŀ
	//� Folder 02 - Gases Gerados          �
	//��������������������������������������
	oPanelH2 := TPanel():New(0,0,,oFolder470:aDialogs[2],,,,,RGB(67,70,87),200,200,.F.,.F.)
	oPanelH2:Align := CONTROL_ALIGN_TOP
	oPanelH2:nHeight := 20

	@ 002,004 Say OemToAnsi("Informe os Gases gerados pelo Produto.") Of oPanelH2 Color RGB(255,255,255) Pixel //"Informe os Gases gerados pelo Produto."

	nUsado := 0
	aCols := {}
	aHeadGas := {}

	//cGetWhlGas := "TD7->TD7_FILIAL == '"+xFilial("TD7")+"' .AND. TD7->TD7_CODPRO = '"+TD2->TD2_CODPRO+"'"

	aNao := {"TD7_CODPRO","TD7_OPERAC"}

	aHeadGas  := CABECGETD("TD7",aNao)

	If Empty(aColsGas)
	aColsGas := BlankGetd(aHeadGas)
	Endif

	nCodGas := aScan(aHeadGas, {|x| AllTrim(Upper(X[2])) == "TD7_CODGAS"})
	nData   := aScan(aHeadGas, {|x| AllTrim(Upper(X[2])) == "TD7_DATA" })
	nHora   := aScan(aHeadGas, {|x| AllTrim(Upper(X[2])) == "TD7_HORA" })

	nCnt := 0
	nItens := 0

	cSeekTD7 := xFilial("TD7")+TD2->TD2_CODPRO
	cCondTD7 := "TD7_FILIAL+TD7_CODPRO"

	dbSelectArea("TD7")
	dbSetOrder(2)
	dbSeek(cSeekTD7)
	Do While !eof() .And. cSeekTD7 == &(cCondTD7)
		If DTOS(TD7->TD7_DATA) + TD7->TD7_HORA > DTOS(TRB470->DATAIN) + TRB470->HORAIN
			DbSkip()
		Else
			nCnt := nCnt + 1
				Dbskip()
		EndIf
	End

	If nCnt > 0
		aColsGas := {}

		dbSelectArea("TD7")
		dbSetOrder(1)
		dbSeek(cSeekTD7)
		Do While !EOF() .And. cSeekTD7 == &(cCondTD7)
			If DTOS(TD7->TD7_DATA) + TD7->TD7_HORA > DTOS(TRB470->DATAIN) + TRB470->HORAIN
			DbSkip()
		Else
				nCnt := aScan(aColsGas, {|x| X[nCodGas] == TD7->TD7_CODGAS})
				If nCnt == 0
					aAdd(aColsGas,Array(Len(aHeadGas)+1))
					nCnt := Len(aColsGas)
				ElseIf !(DTOS(TD7->TD7_DATA) + TD7->TD7_HORA > DTOS(aColsGas[nCnt][nData]) + aColsGas[nCnt][nHora])
					dbSelectArea("TD7")
					dbSkip()
					Loop
				EndIf
				If nCnt > 0 .And. TD7->TD7_OPERAC == "3"
					aDel(aColsGas,nCnt)
					aSize(aColsGas, Len(aColsGas)-1)
					dbSelectArea("TD7")
					dbSkip()
					Loop
				EndIf
				For i:=1 to Len(aHeadGas)+1
					If i > Len(aHeadGas)
						aColsGas[nCnt][i] := .F.
						Exit
					EndIf
					If ExistIni(aHeadGas[i][2])
						aColsGas[nCnt][i] := InitPad( GetSx3Cache( aHeadGas[i][2], 'X3_RELACAO' ) )
					Else
					aColsGas[nCnt][i] := &("TD7->"+aHeadGas[i][2])//TD7_CODGAS
					Endif
				Next
				nItens := nItens + 1
				dbSelectArea("TD7")
			dbSkip()
			EndIf
		End
	EndIf

	oGetGG := MsNewGetDados():New(005, 005, 100, 200,,,,,,,9999,,,,oFolder470:aDialogs[2],aHeadGas, aColsGas)
	oGetGG:oBrowse:Default()
	oGetGG:oBrowse:Refresh()
	oGetGG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	PutFileInEof("TD4")

	Activate Dialog oDLG470 On Init (EnchoiceBar(oDLG470,{|| lOk:=.T.,If(SG470TUDOK(2),(lOk:=.T.,oDLG470:End()),lOk:=.F.)},;
																					{|| lOk:=.F.,oDLG470:End()})) Centered

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG470FON  �Autor  �Roger Rodrigues     � Data �  23/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Abre tela para definicao de fontes geradoras da localizacao ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA470                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGC470FON(cCargo,lVerif)

	Local j, i, nPos
	Local lOk := .T.
	Local oPanelHlp
	Local nPosCod, nPosFCod, nPosEst, nPosNiv, nPosLin
	Local cCodNiv := Substr(cCargo,1,3)//Codigo do nivel
	Local cTipo   := Substr(cCargo,7,1)//Tipo de Marcacao
	Default lVerif := .F.//Indica se deve verificar marcacao
	Private aColsEF := {}, aHeadEF := aClone(aHeadFon)

	If lVerif .and. cTipo != "2"
		ShowHelpDlg("Aten��o", {"Esta op��o s� se aplica a localiza��es definidas como poss�veis locais de consumo"},1)//"Aten��o"##"Esta op��o s� se aplica a localiza��es definidas como poss�veis locais de consumo"
		Return .F.
	Endif

	Define MsDialog oDlgFon Title "Fontes de Emiss�o das Localiza��es" From 08,15 To 30,115 Of oMainWnd//"Fontes de Emiss�o das Localiza��es"

	//������������������������������������Ŀ
	//� Painel de Help                     �
	//��������������������������������������
	oPanelHlp := TPanel():New(0,0,,oDlgFon,,,,,RGB(67,70,87),200,200,.F.,.F.)
	oPanelHlp:Align := CONTROL_ALIGN_TOP
	oPanelHlp:nHeight := 20

	@ 002,004 Say OemToAnsi("Defina as Fontes de Emiss�o de Gases para a Localiza��o.") Of oPanelHlp Color RGB(255,255,255) Pixel//"Defina as Fontes de Emiss�o de Gases para a Localiza��o."

	//������������������������������������Ŀ
	//� Monta Array                        �
	//��������������������������������������

	aNao := {"TD8_CODPRO","TD8_OPERAC"}

	aHeadFFon  := CABECGETD("TD8",aNao)


	nPosEst  := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD8_ESTRUT"})
	nPosNiv  := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD8_CODNIV"})
	nPosFCod := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD8_CODFON"})
	nPosData := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD8_DATA"})
	nPosHora := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD8_HORA"})



	//Monta array somente com informacoes do nivel
	nCnt := 0
	dbSelectArea("TD8")
	dbSetOrder(1)
	dbSeek(xFilial("TD8")+TD2_CODPRO+cCodEst+SubStr(oTree:GetCargo(),1,3))
	While !eof() .and. xFilial("TD8")+TD2->TD2_CODPRO == TD8->TD8_FILIAl+TD8->TD8_CODPRO
	If DTOS(TD8->TD8_DATA) + TD8->TD8_HORA > DTOS(TRB470->DATAIN) + TRB470->HORAIN
		DbSkip()
	Else
		nCnt := nCnt + 1
			Dbskip()
	EndIf
	End

	If nCnt > 0
		aColsEF := {}

		dbSelectArea("TD8")
		dbSetOrder(1)
		dbSeek(xFilial("TD8")+TD2_CODPRO+cCodEst+SubStr(oTree:GetCargo(),1,3))
		Do While !eof() .and. xFilial("TD8")+TD2->TD2_CODPRO+cCodEst  == TD8->TD8_FILIAl+TD8->TD8_CODPRO+TD8->TD8_ESTRUT
		If DTOS(TD8->TD8_DATA) + TD8->TD8_HORA > DTOS(TRB470->DATAIN) + TRB470->HORAIN
			DbSkip()
		ElseIf SubStr(oTree:GetCargo(),1,3) <> TD8->TD8_CODNIV
			DbSkip()
		Else
				nCnt := aScan(aColsEF, {|x| X[nPosFCod] == TD8->TD8_CODFON})
				If nCnt == 0
					aAdd(aColsEF,Array(Len(aHeadFFon)+1))
					nCnt := Len(aColsEF)
				ElseIf !(DTOS(TD8->TD8_DATA) + TD8->TD8_HORA > DTOS(aColsEF[nCnt][nPosData]) + aColsEF[nCnt][nPosHora])
					dbSelectArea("TD8")
					dbSkip()
					Loop
				EndIf
				If nCnt > 0 .And. TD8->TD8_OPERAC == "3"
					aDel(aColsEF,nCnt)
					aSize(aColsEF, Len(aColsEF)-1)
					dbSelectArea("TD8")
					dbSkip()
					Loop
				EndIf
				For i:=1 to Len(aHeadFFon)+1
					If i > Len(aHeadFFon)
						aColsEF[nCnt][i] := .F.
						Exit
					EndIf
					If ExistIni(aHeadFFon[i][2])
						aColsEF[nCnt][i] := InitPad( GetSx3Cache( aHeadFFon[i][2], 'X3_RELACAO' ) )
					Else
					aColsEF[nCnt][i] := &("TD8->"+aHeadFFon[i][2])//TD7_CODGAS
					Endif
				Next
				nItens := nItens + 1
				dbSelectArea("TD8")
			dbSkip()
			EndIf
		End
	EndIf

	//������������������������������������Ŀ
	//� GetDados                           �
	//��������������������������������������
	oGetFon := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"SG470LINOK('TD8')","AllWaysTrue()",,,,9999,,,"SG470DELOK('TD8')",oDlgFon,aHeadFFon, aColsEF)
	oGetFon:oBrowse:Default()
	oGetFon:oBrowse:Refresh()
	oGetFon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	PutFileInEof("TD8")

	Activate MsDialog oDlgFon On Init EnchoiceBar(oDlgFon,{|| lOk := .F.,oDlgFon:End()},{|| lOk := .F.,oDlgFon:End()}) Centered

Return lOk
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGC50PESQ �Autor  �Roger Rodrigues     � Data �  23/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pesquisa informa��es no TRB e retorna no Browse             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAC050                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGC470PES()
local oDlgPesq, oOrdem, oChave, oBtOk, oBtCan, oBtPar
Local cOrdem	:= "Data + Hora"
Local cChave	:= Space(20)
Local aOrdens	:= {}
Local nOrdem := 1
Local nOpcA := 0


aOrdens := {"Data + Hora"}

Define msDialog oDlgPesq Title "Pesquisar" From 00,00 To 100,500 pixel //"Pesquisar"

@ 005, 005 combobox oOrdem var cOrdem items aOrdens size 210,08 PIXEL OF oDlgPesq ON CHANGE nOrdem := oOrdem:nAt
@ 020, 005 msget oChave var cChave size 210,08 of oDlgPesq pixel


define sButton oBtOk  from 05,218 type 1 action (nOpcA := 1, oDlgPesq:End()) enable of oDlgPesq pixel
define sButton oBtCan from 20,218 type 2 action (nOpcA := 0, oDlgPesq:End()) enable of oDlgPesq pixel
define sButton oBtPar from 35,218 type 5 when .F. of oDlgPesq pixel

Activate MsDialog oDlgPesq Center

If nOpca == 1
	cChave := AllTrim(cChave)
	DbSelectArea("TRB470")
	dbSetOrder(1)
	DbSeek(cChave,.T.)
EndIf

DbSelectArea("TRB470")
DbSetOrder(1)

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAUPDCAMP�Autor  �Roger Rodrigues     � Data �  08/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o update de GEE foi aplicado                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA450/SGAA460/SGAA470/SGAC470/SGAR170                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAUPDCAMP()

dbSelectArea("SX3")
dbSetOrder(2)
If !dbSeek("TD0_PAG")
	If !NGINCOMPDIC("UPDSGA03","00000029198/2010")
		Return .F.
	Endif
EndIf

Return .T.