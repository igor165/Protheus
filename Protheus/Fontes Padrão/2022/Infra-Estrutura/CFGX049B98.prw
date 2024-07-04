#Include 'Protheus.ch'

//---------------------------------------------------------------------------------------
/*/ {Protheus.doc} CFGX049B98()
Função que irá tratar a leitura do arquivo CNAB e geração de fonte.

@author	Francisco Oliveira
@since		13/12/2017
@version	P12
@Function  CFGX049B98()
@Return	Array com as informações para alteração
@param
@Obs
/*/
//---------------------------------------------------------------------------------------
Function CFGX049B98()

	Local oDlg			As Object
	Local aPagRec		As Array
	Local aRemRet		As Array
	Local oCombo1		As Object
	Local oCombo2		As Object

	Private cPagRecT	As Character
	Private cEnvRetT	As Character
	Private cBanco		As Character

	oDlg		:= Nil
	aPagRec		:= {"PAG=Contas a Pagar", "REC=Contas a Receber"}
	aRemRet		:= {"REM=Envio", "RET=Retorno"}
	oCombo1		:= Nil
	oCombo2		:= Nil

	cPagRecT	:= Left(aPagRec[1], At('=', aPagRec[1]) - 1)
	cEnvRetT	:= Left(aRemRet[1], At('=', aRemRet[1]) - 1)
	cBanco		:= SPACE(03)

	DEFINE MsDialog oDlg TITLE "Lê Arquivo CNAB" FROM 0,0 TO 250,500 OF oDlg PIXEL

	@ 030,020 SAY "Informe Codigo Banco"	SIZE 150,08 PIXEL Of oDlg
	@ 030,090 MSGET cBanco	PICTURE "@!" 	SIZE 050,08 F3 "SA6" PIXEL OF oDlg Valid !Empty(cBanco)

	@ 050,020 SAY "Informe Modulo"	SIZE 150,08 PIXEL Of oDlg
	oCombo1 := TComboBox():New(045,090,{|u| bChangeCB1(u)},aPagRec,100,30,oDlg,,{||.T.},,,,.T.,,,,,,,,,'cPagRecT')

	@ 070,020 SAY "Informe Tipo"	SIZE 150,08 PIXEL Of oDlg
	oCombo2 := TComboBox():New(070,090,{|u| bChangeCB2(u)},aRemRet,100,30,oDlg,,{||.T.},,,,.T.,,,,,,,,,'cEnvRetT')

	@ 100,090 BUTTON "&Cancelar"	SIZE 36,16 PIXEL ACTION {||oDlg:End()} 				Message "Clique aqui para Cancelar" 	of oDlg
	@ 100,130 BUTTON "&Lê Arquivo"	SIZE 36,16 PIXEL ACTION {||xLeArquivo(),oDlg:End()}	Message "Clique aqui para Ler Arquivo" of oDlg

	ACTIVATE MSDIALOG oDlg CENTER

Return Nil

//---------------------------------------------------------------------------------------
/*/ {Protheus.doc} bChangeCB1()
Função que irá tratar o texto do ComboBox Módulo.

@author	TOTVS SA
@since		28/01/2020
@version	P12
@Return	cRet - Texto do 

/*/
//---------------------------------------------------------------------------------------
Static Function bChangeCB1(u)
	Local cRet     As Character
	Local cReadVar As Character

	Default u := ""

	cRet     := ""
	cReadVar := Upper(Alltrim(ReadVar()))

	If (PCount() > 0 .AND. !(Empty(u)) .AND. cReadVar == "CPAGRECT")
		cRet := u
	Else
		cRet := cPagRecT
	EndIf
Return cRet

//---------------------------------------------------------------------------------------
/*/ {Protheus.doc} bChangeCB2()
Função que irá tratar o texto do campo Tipo de Envio.

@author	TOTVS SA
@since		28/01/2020
@version	P12
@Return	cRet - 

/*/
//---------------------------------------------------------------------------------------
Static Function bChangeCB2(u)
	Local cRet     As Character
	Local cReadVar As Character

	Default u := ""

	cRet     := ""
	cReadVar := Upper(Alltrim(ReadVar()))

	If (PCount() > 0 .AND. !(Empty(u)) .AND. cReadVar == "CENVRETT")
		cRet := u
	Else
		cRet := cEnvRetT
	EndIf
Return cRet

Static Function xLeArquivo()

	Private cCadastro As Character

	cCadastro := "Ler arquivo Texto"

	Processa( {|| xImpArq() }, "Processando Importação de  Arquivo." )

Return Nil

//---------------------------------------------------------------------------------------
/*/ {Protheus.doc} xImpArq()
Função de geração do arquivo de configuração.

@author	Francisco Oliveira
@since		13/12/2017
@version	P12
@Return	Array com as informações para alteração
@param
@Obs
/*/
//---------------------------------------------------------------------------------------
Static Function xImpArq()

	Local nHdlLe		As Numeric
	Local lRet			As Logical
	Local nCount		As Numeric
	Local nCntLin		As Numeric
	Local nQtdLin		As Numeric
	Local cCodFOZ		As Character
	Local cBuffer		As Character
	Local cFileOpen		As Character
	Local cVersaoArq	As Character
	Local cTitulo1  	As Character
	Local cMainPath		As Character
	Local cTime			As Character
	Local aArrayFOQ     As Array

	Private cExtens		As Character

	nHdlLe		:= 0
	lRet		:= .F.
	nCount		:= 1
	nCntLin		:= 1
	nQtdLin		:= 0
	cCodFOZ		:= GetSXENum("FOZ","FOZ_CODIGO")
	cBuffer		:= ""
	cFileOpen	:= ""
	cVersaoArq	:= "INCLCLIE"
	cTitulo1  	:= "Selecione o arquivo"
	cMainPath	:= "C:\"
	cTime		:= SubStr(Time(),1,2) + ":" + SubStr(Time(),4,2) + ":" + SubStr(Time(),7,2)
	aArrayFOQ   := {}

	cExtens	:= "Arquivo Texto | *.*"

	cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)

	If !File(cFileOpen)
		MsgAlert("Arquivo texto: " + cFileOpen + " não localizado",cCadastro)
		Return
	Endif

	nHdlLe	:= fOpen(cFileOpen)

	FT_FUSE(cFileOpen)
	FT_FGOTOP()
	nQtdLin	:= ProcRegua(FT_FLASTREC())

	DbSelectArea("FOZ"); DbSelectArea("FOP"); DbSelectArea("FOQ")

	Begin Transaction
		FOZ->(RecLock("FOZ", .T.))
		FOZ->FOZ_FILIAL	:= FwxFilial("FOZ")
		FOZ->FOZ_CODIGO	:= cCodFOZ
		FOZ->FOZ_BANCO	:= cBanco
		FOZ->FOZ_EDITAV	:= "1"
		FOZ->FOZ_DTGRV	:= DDATABASE
		FOZ->FOZ_MODULO := cPagRecT
		FOZ->FOZ_TIPO   := cEnvRetT
		FOZ->FOZ_USER	:= RETCODUSR()
		FOZ->(MsUnLock())

		ConfirmSX8()

		While !FT_FEOF()
			nCntLin++
			IncProc("Processando registro " + cValToChar(nCntLin) + " de " + cValToChar(nQtdLin) + " Regsitros." )

			cBuffer := FT_FREADLN()

			If (RecLock('FOP', .T.))
				If SubStr(cBuffer,1,1) == "1"
					FOP->FOP_FILIAL	:= FwxFilial("FOP")
					FOP->FOP_CODIGO	:= cCodFOZ
					FOP->FOP_IDELIN	:= Alltrim(SubStr(cBuffer,01,001)) // Identificação da Linha - '1'
					FOP->FOP_HEADET	:= Alltrim(SubStr(cBuffer,02,001)) // Header X Detalhe - '0'
					FOP->FOP_CHALIN	:= Alltrim(SubStr(cBuffer,03,001)) // Chave da Linha - 'H'
					FOP->FOP_IDESEG	:= Alltrim(SubStr(cBuffer,04,001)) // Identificação do Segmento - ' '
					FOP->FOP_BANCO	:= cBanco
					FOP->FOP_DESSEG	:= Iif(SubStr(cBuffer,5,3) == "DET",SubStr(cBuffer,13,22), "")
					FOP->FOP_DESMOV	:= Alltrim(SubStr(cBuffer,05,030)) // Descrição Cabeçalho
					FOP->FOP_CONARQ	:= Alltrim(SubStr(cBuffer,35,100)) // Descrição Dados executar
					FOP->FOP_VERARQ	:= cVersaoArq
					FOP->FOP_BLOQUE	:= "2"
					FOP->FOP_EDITAD	:= "1"
					FOP->FOP_DTGRAV	:= DDATABASE
					FOP->FOP_PAGREC	:= cPagRecT
					FOP->FOP_REMRET	:= cEnvRetT
					FOP->FOP_SEQUEN	:= Alltrim(StrZero(nCount++,3)) // controlador sequencial de linha
				ElseIf SubStr(cBuffer,1,1) == "2"
					FOP->FOP_FILIAL	:= FwxFilial("FOP")
					FOP->FOP_CODIGO	:= cCodFOZ
					FOP->FOP_IDELIN	:= Alltrim(SubStr(cBuffer,01,001)) // Identificação da Linha - '1'
					FOP->FOP_HEADET	:= Alltrim(SubStr(cBuffer,02,001)) // Header X Detalhe - '0'
					FOP->FOP_CHALIN	:= Alltrim(SubStr(cBuffer,03,001)) // Chave da Linha - 'H'
					FOP->FOP_IDESEG	:= Alltrim(SubStr(cBuffer,04,001)) // Identificação do Segmento - ' '
					FOP->FOP_BANCO	:= cBanco
					FOP->FOP_DESSEG	:= Iif(SubStr(cBuffer,1,3) == "DET",SubStr(cBuffer,13,22), "")
					FOP->FOP_POSINI	:= Alltrim(SubStr(cBuffer,20,003)) // Posição Inicial
					FOP->FOP_POSFIM	:= Alltrim(SubStr(cBuffer,23,003)) // Posição Final
					FOP->FOP_DECIMA	:= Alltrim(SubStr(cBuffer,26,001)) // Decimal
					FOP->FOP_DESMOV	:= Alltrim(SubStr(cBuffer,05,015)) // Descrição Cabeçalho
					FOP->FOP_CONARQ	:= Alltrim(SubStr(cBuffer,27,135)) // Descrição Dados executar
					FOP->FOP_VERARQ	:= cVersaoArq
					FOP->FOP_BLOQUE	:= "2"
					FOP->FOP_EDITAD	:= "1"
					FOP->FOP_DTGRAV	:= DDATABASE
					FOP->FOP_PAGREC	:= cPagRecT
					FOP->FOP_REMRET	:= cEnvRetT
					FOP->FOP_SEQUEN	:= Alltrim(StrZero(nCount++,3)) // controlador sequencial de linha
				Endif

				FOP->(MsUnLock())
			EndIf

			FT_FSKIP()
			lRet	:= .T.
		EndDo

		fClose(nHdlLe)

		FT_FUSE()

		If !lRet
			RollBackSxe()

			DisarmTransaction()
		Else
			ConfirmSX8()

			AADD(aArrayFOQ, {"FOQ_FILIAL", FWxFilial("FOQ")})
			AADD(aArrayFOQ, {"FOQ_CODIGO", cCodFOZ } )
			AADD(aArrayFOQ, {"FOQ_DATA"  , DDataBase})
			AADD(aArrayFOQ, {"FOQ_HORA"  , cTime} )
			AADD(aArrayFOQ, {"FOQ_CHVCTR", cBanco + cVersaoArq + cPagRecT + cEnvRetT})
			AADD(aArrayFOQ, {"FOQ_VERTVS", cVersaoArq})
			AADD(aArrayFOQ, {"FOQ_BANCO" , cBanco})
			AADD(aArrayFOQ, {"FOQ_PGRECT", cPagRecT})
			AADD(aArrayFOQ, {"FOQ_ENRETT", cEnvRetT})
			AADD(aArrayFOQ, {"FOQ_CTRVAL", "1"})
			AADD(aArrayFOQ, {"FOQ_CTRVER", "1"})
			AADD(aArrayFOQ, {"FOQ_VERCLI", cVersaoArq})
			AADD(aArrayFOQ, {"FOQ_NOMARQ", cBanco + cVersaoArq + cPagRecT + cEnvRetT })
			AADD(aArrayFOQ, {"FOQ_PGRECC", ""})
			AADD(aArrayFOQ, {"FOQ_ENRETC", ""})
			AADD(aArrayFOQ, {"FOQ_BANCO" , cBanco})

			lRet	:= CFGX049B2A(aArrayFOQ)
			FwFreeArray(aArrayFOQ)

			If lRet
				ConfirmSX8()
				MsgInfo("Processo finalizado")
			Else
				RollBackSxe()
				DisarmTransaction()
				Break
			Endif
		Endif
	End Transaction
Return Nil

