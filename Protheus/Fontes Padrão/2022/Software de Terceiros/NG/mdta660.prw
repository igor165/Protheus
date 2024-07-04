#include "Mdta660.ch"
#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA660
Programa de Cadastro de Componentes
@type    function
@author  Thiago Olis Machado
@since   03/05/2001
@sample  MDTA660()
@return  L�gico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDTA660()

	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM( )
	Local cFiltroTNQ  := ""
	Local lCipatr     := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )
	lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )

	Private cCadastro
	Private lMdtMin  := If( SuperGetMv("MV_MDTMIN",.F.,"N") == "S", .T. , .F. )
	Private cAliasCC := "CTT"
	Private cFilCC   := "CTT->CTT_FILIAL"
	Private cCodCC   := "CTT->CTT_CUSTO"
	Private cDesCC   := "CTT->CTT_DESC01"
	Private aTROCAF3 := {}
	Private lCpoTNQ  := .F.

	If Alltrim(GETMV("MV_MCONTAB")) != "CTB"
		cAliasCC := "SI3"
		cFilCC   := "SI3->I3_FILIAL"
		cCodCC   := "SI3->I3_CUSTO"
		cDesCC   := "SI3->I3_DESC"
	EndIf

	Private aRotina := MenuDef()

	If lSigaMdtps

		cCadastro := OemtoAnsi(STR0009)  //"Clientes"

		DbSelectArea("SA1")
		DbSetOrder(1)

		mBrowse( 6, 1,22,75,"SA1")

	Else

		If TNS->(FieldPos("TNS_PRESEN")) > 0
			aADD(aRotina,{STR0010,"MDTA660Leg", 0 , 6})  //"Legenda"
		EndIf

		// Define o cabecalho da tela de atualizacoes
		cCadastro := OemtoAnsi(STR0006) //"Componentes"
		Private aCHKDEL := {}, bNGGRAVA
		lCpoTNQ := If(TNQ->(FieldPos("TNQ_FILMAT")) > 0,.T.,.F.)
		Private lCpoTNO := If(TNO->(FieldPos("TNO_FILMAT")) > 0,.T.,.F.)
		Private nIndTNQ := NGRETORDEM("TNQ","TNQ_FILIAL+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)",.T.)
		nIndTNQ := If(nIndTNQ > 0,nIndTNQ,RetIndex("TNQ"))
		Private nIndTNO := NGRETORDEM("TNO","TNO_FILIAL+TNO_MANDAT+TNO_FILMAT+TNO_MAT+DTOS(TNO_DTCAND)",.T.)
		nIndTNO := If(nIndTNO > 0,nIndTNO,RetIndex("TNO"))

		// Aplica filtro quando for aberto apartir da GPEA010
		If IsInCallStack( "MDT660DEMI" )
			cFiltroTNQ:= "TNQ_FILIAL ='" + xFilial("TLM") + "'"
			cFiltroTNQ+= " AND TNQ_MAT ='"+ SRA->RA_MAT + "'"
			cFiltroTNQ+= " AND TNQ_DTSAID =''"
		EndIf

		// Endereca a funcao de BROWSE
		DbSelectArea("TNQ")
		DbSetorder(If(lCpoTNQ,nIndTNQ,1))

		If TNS->(FieldPos("TNS_PRESEN")) > 0
			mBrowse( 6, 1,22,75,"TNQ",,,,,,MDTA660Cor(),,,,,,,,cFiltroTNQ)
		Else
			mBrowse( 6, 1,22,75,"TNQ",,,,,,,,,,,,,,cFiltroTNQ)
		EndIf

		DbSelectArea("TNQ")
		DbSetorder(1)
		DbSelectArea("TNO")
		DbSetorder(1)

	EndIf

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CHK660MAN
Checa se j� existe registro relacionado

@type    function
@author  Thiago olis Machado
@since   03/05/2001
@sample  CHK660MAN( .T., 3 )

@param   lPasMDT, L�gico,
@param   nTipCad, Num�rico,

@return  L�gico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function CHK660MAN( lPasMDT, nTipCad )

	Local aArea := GetArea()

	If lSigaMdtps

		If !EXISTCHAV("TNQ",cCliMdtps+M->TNQ_MANDAT+M->TNQ_FILMAT+M->TNQ_MAT,6)
			Return .F.
		EndIf

		If lPasMDT
			If !ExCpoMDT("SRA",M->TNQ_MAT,,.F.)
				MsgStop(STR0011,STR0012)  //"Matr�cula de funcion�rio n�o existe."  //"ATEN��O"
				Return .F.
			EndIf
			If SubStr(SRA->RA_CC,1,nSizeSA1+nSizeLoj) <> cCliMdtps
				MsgStop(STR0013,STR0012)  //"Matr�cula n�o pertence ao cliente."    //"ATEN��O"
				Return .F.
			EndIf
		Else
			If !ExCpoMDT("SRA",M->TNQ_MAT)
				Return .F.
			EndIf
			If SubStr(SRA->RA_CC,1,nSizeSA1+nSizeLoj) <> cCliMdtps
				Return .F.
			EndIf
		EndIf

	Else

		If lCpoTNQ
			If nTipCad == 3
				If !EXISTCHAV("TNQ",M->TNQ_MANDAT+M->TNQ_FILMAT+M->TNQ_MAT,nIndTNQ)
					Return .F.
				EndIf

				If M->TNQ_INDICA == "2" .And. !MDT660INC() //Fun��o para verificar se o funcion�rio pode ser reeleito
					Return .F.
				EndIf

			ElseIf nTipCad == 4 .And. Type("cQ_FILMAT") == "C"
				If M->TNQ_FILMAT <> cQ_FILMAT
					If !EXISTCHAV("TNQ",M->TNQ_MANDAT+M->TNQ_FILMAT+M->TNQ_MAT,nIndTNQ)
						Return .F.
					EndIf
				EndIf
				If M->TNQ_INDICA == "2" .And. !MDT660INC() //Fun��o para verificar se o funcion�rio pode ser reeleito
					Return .F.
				EndIf
			EndIf
		Else
			If !EXISTCHAV("TNQ",M->TNQ_MANDAT+M->TNQ_MAT)
				Return .F.
			EndIf
		EndIf
		If lPasMDT
			If !ExCpoMDT("SRA",M->TNQ_MAT,,.F.)
				MsgStop(STR0011,STR0012)  //"Matr�cula de funcion�rio n�o existe."  //"ATEN��O"
				Return .F.
			EndIf
		Else
			If !ExCpoMDT("SRA",M->TNQ_MAT)
				Return .F.
			EndIf
		EndIf
	EndIf

	If lMdtMin
		dbSelectArea("SRA")
		dbSetOrder(1)
		If dbSeek(xFilial("SRA")+M->TNQ_MAT)
			cSetor   := SRA->RA_CC
			cAreaC   := NGSeek('TLJ', M->TNQ_MANDAT + cSetor ,1,'TLJ->TLJ_AREA')
			M->TNQ_AREA   := cAreaC
			M->TNQ_NOAREA := NGSeek(cAliasCC, cAreaC ,1,cDesCC)
		EndIf
	EndIf

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CHK660DAT
Checa se a data for informada � maior que data da candidatura

@type    function
@author  Thiago Olis Machado
@since   03/05/2001
@sample  CHK660DAT()

@return  L�gico, Verdadeiro se a data for v�lida
/*/
//-------------------------------------------------------------------
Function CHK660DAT()

	Local cSeek := xFilial("TNO")+M->TNQ_MANDAT+M->TNQ_MAT

	If lSigaMdtps

		dDataSai := M->TNQ_DTSAID
		DbSelectArea("TNQ")
		If !Empty(dDataSai)
			DbSelectArea("TNO")
			DbSetorder(6)
			DbSeek(xFilial("TNO")+cCliMdtps+M->TNQ_MANDAT+M->TNQ_FILMAT+M->TNQ_MAT)
			If M->TNQ_DTSAID < TNO->TNO_DTCAND
				Return .F.
			EndIf
		EndIf

	Else

		If lCpoTNO .And. lCpoTNQ
			cSeek := xFilial("TNO")+M->TNQ_MANDAT+M->TNQ_FILMAT+M->TNQ_MAT
		EndIf

		dDataSai := M->TNQ_DTSAID
		DbSelectArea("TNQ")
		If !Empty(dDataSai)
			DbSelectArea("TNO")
			DbSetorder(If(lCpoTNO .And. lCpoTNQ,nIndTNQ,1))
			DbSeek(cSeek)
			If M->TNQ_DTSAID < TNO->TNO_DTCAND
				Return .F.
			EndIf
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT660PROC
Inclui, Altera e Exclui os registros da TNQ

@sample	MDT660PROC()

@author	Denis Hyroshi de Souza
@since	10/04/2005

@return .T., L�gico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Function MDT660PROC( cAlias, nRecno, nOpcx )

	Local nRet
	Local cFil1Tmp
	Local aArea		 := GetArea()
	Local cOldFil	 := cFilAnt
	Local lCpoFilFun := IIf( NGCADICBASE( "TNQ_FILMAT", "A", "TNQ", .F. ), .T., .F. )

	//Vari�veis de perda de estabilidade
	Local lPerdEstab := TNQ->( ColumnPos( "TNQ_DTESTB" ) ) > 0 //Caso o dicion�rio esteja atualizado com os campos da perda da estabilidade
	Local dDtEstbOld := IIf( lPerdEstab, TNQ->TNQ_DTESTB, SToD( "" ) )
	Local cJustifOld := IIf( lPerdEstab, TNQ->TNQ_JUSTIF, "" )
	Local cIndicaOld := TNQ->TNQ_INDICA

	Private aNgButton := {}
	Private nTipInd1
	Private nTipInd2
	Private cTipCand

	//Caso o dicion�rio esteja atualizado com os campos de perda da estabilidade da CIPA e seja uma altera��o
	If lPerdEstab .And. ( nOpcx == 4 .Or. nOpcx == 2 )
		aAdd( aNgButton, { "DOCUMENT", { || MsDocument( cAlias, nRecno, nOpcx ) }, "Conhecimento", "Conhecimento" } )
	EndIf

	//Ao chamar pela fun��o MDT660DEMI, dever� ser feito somente a op��o de altera��o
	If IsInCallStack( "MDT660DEMI" ) .And. nOpcx == 3//Verifica se foi chamado pela MDT660DEMI
		nOpcx := 4 // Muda o nOpcx para Altera��o
		SetAltera()
	EndIf

	If nOpcx == 3
		bNGGRAVA := { || CHK660MAN( .T., 3 ) .And. MDTTNQVALID( 2 ) }
	Else
		If lCpoTNQ
			If !Empty( TNQ->TNQ_FILMAT )
				cFilAnt := TNQ->TNQ_FILMAT
			EndIf
		EndIf

		If nOpcx == 4 .And. lCpoTNQ
			//Condi��o feita, caso for feito a rescis�o do funcion�rio pela rotina GPEM040
			//Pois por essa Rotina o Funcion�rio � desabilitado
			If SRA->RA_MSBLQL == "1" .And. SRA->RA_SITFOLH == "D"
				lAtu := MsgYesNo( STR0035 + CRLF + ; //"N�o � poss�vel alterar o Componente, pois o Funcion�rio n�o est� habilitado."
								STR0036 ) //"Deseja preencher o campo Data de Sa�da com a Data de demiss�o do Funcion�rio ?"

				If lAtu //Se confirmar preenche com a Data de demiss�o
					RecLock( "TNQ", .F. )
					TNQ->TNQ_DTSAID := SRA->RA_DEMISSA
					MsUnlock( "TNQ" )
				EndIf

				Return .T.
			EndIf

			cQ_FILMAT:= TNQ->TNQ_FILMAT
			bNGGRAVA := { || CHK660MAN( .T., 4 ) .And. MDTTNQVALID( 2 ) }
		EndIf
	EndIf

	nTipInd1 := TNQ->TNQ_INDICA
	nRet     := NGCAD01( cAlias, nRecno, nOpcx )
	nTipInd2 := TNQ->TNQ_INDICA
	cTipCand := TNQ->TNQ_TIPCOM

	dbSelectArea( "TNO" )
	dbSetOrder( 2 )
	If dbSeek( xFilial( "TNO" ) + TNQ->TNQ_MAT )
		If !Empty( TNQ->TNQ_INDICA ) .And. nOpcx == 3
			RecLock( "TNO", .F. )
			TNO->TNO_INDICA := TNQ->TNQ_INDICA
			MsUnlock( "TNO" )
		EndIf

		If !Empty( TNQ->TNQ_INDICA ) .And. nOpcx == 4
			RecLock( "TNO", .F. )
			TNO->TNO_INDICA := TNQ->TNQ_INDICA
			MsUnlock( "TNO" )
		EndIf
	EndIf

	cFil1Tmp := cFilAnt
	If lCpoFilFun
		If !Empty( TNQ->TNQ_FILMAT )
			cFil1Tmp := TNQ->TNQ_FILMAT
		EndIf
	EndIf

	//Caso a tela de cadastro for confirmada, n�o for visualiza��o e haver integra��o com o GPE
	If nRet = 1 .And. nOpcx <> 2 .And. SuperGetMv( "MV_MDTGPE", .F., "N" ) == "S"

		//Ajusta a data de estabilidade nos campos RA_DTVTEST e TNQ_DTESTB
		MDT660ESTB( .F., nOpcx, TNQ->TNQ_MANDAT, cFil1Tmp, TNQ->TNQ_MAT, , lPerdEstab, dDtEstbOld, cJustifOld, cIndicaOld )

	EndIf

	If cFilAnt <> cOldFil
		cFilAnt := cOldFil
	EndIf

	bNGGRAVA := {}
	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660FILF
Validacao do campo TNQ_FILMAT

@type    function
@author  Denis Hyroshi de Souza
@since   10/04/2005
@sample  MDT660FILF()
@return  lRet, L�gico, Verdadeiro se o campo for v�lido
/*/
//-------------------------------------------------------------------
Function MDT660FILF

	Local aArea    := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local lRet     := .T.

	Dbselectarea("SM0")
	If !Dbseek(cEmpAnt+M->TNQ_FILMAT)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	Else
		cFilAnt := M->TNQ_FILMAT
		dbSelectArea("SRA")
		dbSetOrder(01)
		If !dbSeek(xFilial("SRA",cFilAnt)+ M->TNQ_MAT )
			M->TNQ_MAT := Space( Len(SRA->RA_MAT) )
			M->TNQ_NOME := " "
		Else
			M->TNQ_NOME := SRA->RA_NOME
		EndIf
	EndIf

	RestArea(aAreaSM0)
	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A660DTCAND
Realizaa valida��o das datas de entrada e sa�da do Candidato

@return lRet L�gico Indica se a data informada est� correta (.T.) ou n�o (.F.)

@param nDtVal Num�rico Indica qual data se esta validando: 1 - Data de Sa�da; 2 - Data de Entrada

@sample A660DTCAND()

@author Denis Hyroshi de Souza Refeito por: Jackson Machado
@since 12/09/2006 Refeito em: 23/07/2014
/*/
//---------------------------------------------------------------------
Function A660DTCAND( nDtVal )

	Local cSolucao:= ""//Receber� a mensagem de solu��o de acordo com a data
	Local dDtValid:= StoD( Space( 8 ) )//Receber� a data a ser validada
	Local dDtTmp	:= NGSeek( "SRA" , M->TNQ_MAT , 1 , "SRA->RA_ADMISSA" )//Recebe a data de admiss�o do Funcion�rio
	Local lRet		:= .T.//Controle de Retorno

	Default nDtVal:= 1

	//Define a data que ser� validada
	If nDtVal == 1//Data de Sa�da
		dDtValid := M->TNQ_DTSAID
		cSolucao := STR0024//"Favor informar uma Data de Sa�da maior."
	ElseIf nDtVal == 2//Data de Entrada
		dDtValid := M->TNQ_DTINIC
		cSolucao := STR0025//"Favor informar uma Data de Entrada menor."
	EndIf

	//Verifica se a data � maior que a data de admiss�o
	If !Empty(dDtValid) .And. !Empty( M->TNQ_MAT ) .And. ValType( dDtTmp ) == "D"
		If dDtTmp > dDtValid
			MsgStop( STR0014 )  //"A data n�o pode ser anterior � data de admiss�o do funcion�rio."
			lRet := .F.
		EndIf
	EndIf

	//Verifica se o update foi rodado e se a valida��o anterior est� correta
	If lRet .And. NGCADICBASE( "TNQ_DTINIC" , "A" , "TNQ" , .F. )
		//Valida somente quando as duas datas est�o preenchidas, verifica se data de entrada � superior a data de sa�da
		If !Empty( M->TNQ_DTINIC ) .And. !Empty( M->TNQ_DTSAID ) .And. M->TNQ_DTINIC > M->TNQ_DTSAID
				ShowHelpDlg( STR0012 , ;//"Aten��o"
								{ STR0023 } , 1 , ;//"Data de Sa�da n�o pode ser inferior a Data de Entrada."
								{ cSolucao } , 1 )
				lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA660Leg
Cria uma janela contendo a legenda da mBrowse

@type    function
@author  Denis Hyroshi de Souza
@since   12/09/2006
@sample  MDTA660Leg()
@return  L�gico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDTA660Leg()

	If Type( "cCadastro" ) == "U"
		Private cCadastro := STR0010  //"Legenda"
	EndIf

	BrwLegenda(	OemToAnsi(cCadastro)	,;	//Titulo do Cadastro
				OemToAnsi( STR0010 )	,; //"Legenda"
				{;
					{"BR_VERDE"		,OemToAnsi(STR0015)	}	,;  //"Titular - Situa��o Normal"
					{"BR_VERMELHO"	,OemToAnsi(STR0016)	}	,;  //"Titular - Com mais de 4 faltas"
					{"BR_AZUL"		,OemToAnsi(STR0017)	}	 ;  //"Suplente"
				};
			)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA660Cor
Define cores do  semaforo no browse

@type    function
@author  Denis Hyroshi de Souza
@since   12/09/2006
@sample  MDTA660Cor()
@return  aCores, Array, Contem o array de cores
/*/
//-------------------------------------------------------------------
Function MDTA660Cor()
	Local aCores	:=	{ { "MDT660TITU(.T.)"  		 , 'BR_VERDE'		},;
						{ "MDT660TITU(.F.)"  		 , 'BR_VERMELHO'	},;
						{ "TNQ->TNQ_TIPCOM == '2'" , 'BR_AZUL' 		}}
Return aCores

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660TITU
Verifica se o titular esta normal

@type    function
@author  Denis Hyroshi de Souza
@since   12/09/2006
@sample  MDT660TITU( .T. )
@param   lNormal, L�gico, Verificando se � normal ate 4 faltas

@return  L�gico, Verdadeiro se o titular est� regular
/*/
//-------------------------------------------------------------------
Function MDT660TITU( lNormal )

	Local nFaltas := 0

	lUPDMDTA4 := NGCADICBASE( "TNQ_DTINIC", "D", "TNQ", .F. ) //Verifica se existe o campo "TNQ_DTINIC" na base.

	If lSigaMdtps
		If TNQ->TNQ_TIPCOM == '1'
			aAreaLeg := GetArea()

			dbSelectarea( "TNR" )
			dbSetorder( 2 ) //TNR_FILIAL+TNR_CLIENT+TNR_LOJA+TNR_MANDAT+DTOS(TNR_DTREUN)+TNR_HRREUN
			dbSeek( xFilial( "TNR" ) + cCliMdtps + TNQ->TNQ_MANDAT )
			While !Eof() .And. xFilial( "TNR" ) + cCliMdtps + TNQ->TNQ_MANDAT == TNR_FILIAL + TNR_CLIENT + TNR_LOJA + TNR_MANDAT .And. nFaltas <= 4

				If lUPDMDTA4
					If TNQ->TNQ_DTINIC > TNR->TNR_DTREAL
						dbSelectarea( "TNR" )
						dbskip()
					EndIf
				EndIf

				If TNR->TNR_TIPREU == '1' .And. !Empty( TNR->TNR_DTREAL )
					dbSelectarea( "TNS" )
					dbSetorder( 5 ) //TNS_FILIAL+TNS_CLIENT+TNS_LOJA+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_MAT
					If dbSeek( xFilial( "TNS" ) + cCliMdtps + TNR->( TNR_MANDAT + DToS( TNR_DTREUN ) + TNR_HRREUN ) + TNQ->TNQ_MAT )
						If TNS->TNS_PRESEN == '3'
							nFaltas++
						EndIf
					EndIf
				EndIf

				dbSelectarea( "TNR" )
				dbskip()
			End

			RestArea( aAreaLeg )

			If lNormal
				//verificando se � normal (ate 4 faltas)
				Return ( nFaltas <= 4 )
			Else
				//verificando se tem + de 4 faltas
				Return ( nFaltas > 4 )
			EndIf
		EndIf

	Else

		If TNQ->TNQ_TIPCOM == '1'
			aAreaLeg := GetArea()

			dbSelectarea( "TNR" )
			dbSetorder( 1 )
			dbSeek( xFilial( "TNR" ) + TNQ->TNQ_MANDAT )
			While !Eof() .And. xFilial( "TNR" ) + TNQ->TNQ_MANDAT == TNR_FILIAL + TNR_MANDAT .And. nFaltas <= 4

				If lUPDMDTA4
					If TNQ->TNQ_DTINIC > TNR->TNR_DTREAL
						dbSelectarea( "TNR" )
						dbskip()
					EndIf
				EndIf

				If TNR->TNR_TIPREU == '1' .And. !Empty( TNR->TNR_DTREAL )
					dbSelectarea( "TNS" )
					dbSetorder( 1 )
					If dbSeek( xFilial( "TNS" ) + TNR->( TNR_MANDAT + DToS( TNR_DTREUN ) + TNR_HRREUN ) + TNQ->TNQ_MAT )
						If TNS->TNS_PRESEN == '3'
							nFaltas++
						EndIf
					EndIf
				EndIf

				dbSelectarea( "TNR" )
				dbskip()
			End

			RestArea( aAreaLeg )

			If lNormal
				//verificando se � normal (ate 4 faltas)
				Return ( nFaltas <= 4 )
			Else
				//verificando se tem + de 4 faltas
				Return ( nFaltas > 4 )
			EndIf
		EndIf
	EndIf

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional

@type    function
@author  Rafael Diogo Richter
@since   29/11/2006
@sample  MenuDef(.T.)
@param   lPersonal, L�gico, Utiliza para a cria��o de menu personalizado
para altera��o do componente da CIPA

@Obs Parametros do array a Rotina:
		1. Nome a aparecer no cabecalho
		2. Nome da Rotina associada
		3. Reservado
		4. Tipo de Transa��o a ser efetuada:
				1 - Pesquisa e Posiciona em um Banco de Dados
			2 - Simplesmente Mostra os Campos
			3 - Inclui registros no Bancos de Dados
			4 - Altera o registro corrente
			5 - Remove o registro corrente do Banco de Dados
		5. Nivel de acesso
		6. Habilita Menu Funcional

@return  aRotina, Array, Op��es da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef( lPersonal )

	Local lSigaMdtPS := SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Local aRotina

	Default lPersonal := IsInCallStack( "MDT660DEMI" )//Utiliza para a cria��o de menu personalizado para altera��o do componente da CIPA

	If lSigaMdtps
		aRotina := { { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
					{ STR0002,   "NGCAD01"   , 0 , 2},; //"Visualizar"
					{ STR0018,   "MDT660COM" , 0 , 4} } //"Componentes CIPA"
	Else
		If lPersonal //Menu personalizado
			aRotina := { { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
							{ STR0002,   "MDT660PROC"   , 0 , 2},; //"Visualizar"
							{ STR0004,   "MDT660PROC"  , 0 , 4} } //"Alterar"
		Else
			aRotina :=	{	{ STR0001,	"AxPesqui"    , 0 , 1},; //"Pesquisar"
							{ STR0002,	"MDT660PROC"  , 0 , 2},; //"Visualizar"
							{ STR0003,	"MDT660PROC"  , 0 , 3},; //"Incluir"
							{ STR0004,	"MDT660PROC"  , 0 , 4},; //"Alterar"
							{ STR0005,	"MDT660PROC"  , 0 , 5, 3} } //"Excluir"

		EndIf

	EndIf
	lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)

	If !lPyme
		AAdd( aRotina, { STR0022, "MsDocument", 0, 4 } )  //"Conhecimento"
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660COM
Monta um browse com os componentes da CIPA

@type    function
@author  Andre Perez Alvarez
@since   19/10/2007
@sample  MDT660COM()

@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDT660COM()

	Local aArea	    := GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad    := cCadastro
	Local aNao      := { 'TNQ_CLIENT', 'TNQ_LOJA', 'TNQ_FILIAL'}
	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA
	nSizeSA1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
	nSizeLoj := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))

	aRotina :=  { { STR0001,	"AxPesqui"    , 0 , 1},; //"Pesquisar"
				{ STR0002,	"MDT660PROC"  , 0 , 2},; //"Visualizar"
				{ STR0003,	"MDT660PROC"  , 0 , 3},; //"Incluir"
				{ STR0004,	"MDT660PROC"  , 0 , 4},; //"Alterar"
				{ STR0005,	"MDT660PROC"  , 0 , 5, 3} } //"Excluir"

	If TNS->(FieldPos("TNS_PRESEN")) > 0
		aADD(aRotina,{STR0010,"MDTA660Leg", 0 , 6})  //"Legenda"
	EndIf
	// Define o cabecalho da tela de atualizacoes
	cCadastro := OemtoAnsi(STR0006) //"Componentes"
	Private aCHKDEL := {}, bNGGRAVA

	aCHOICE := {}

	aCHOICE := NGCAMPNSX3( 'TNQ' , aNao )

	// Endereca a funcao de BROWSE
	DbSelectArea("TNQ")
	Set Filter To TNQ->(TNQ_CLIENT+TNQ_LOJA) == cCliMdtps
	DbSetorder(6)  //TNQ_FILIAL+TNQ_CLIENT+TNQ_LOJA+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)
	If TNS->(FieldPos("TNS_PRESEN")) > 0
		mBrowse( 6, 1,22,75,"TNQ",,,,,,MDTA660Cor())
	Else
		mBrowse( 6, 1,22,75,"TNQ")
	EndIf

	DbSelectArea("TNQ")
	DbSetorder(6)
	DbSelectArea("TNO")
	DbSetorder(6)

	aROTINA := aCLONE(oldROTINA)
	RestArea(aArea)
	cCadastro := oldCad

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660NOM
Mostra o nome do funcionario no browse da TNQ

@type    function
@author  Andre Perez Alvarez
@since   24/06/2008
@sample  MDT660NOM()
@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDT660NOM()

	Local cDesc := ""
	Local aArea := GetArea()

	cDesc := Posicione("SRA",1,xFilial("SRA",TNQ->TNQ_FILMAT)+TNQ->TNQ_MAT,"RA_NOME")

	RestArea(aArea)

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} A660DESTIN
Troca F3 do campo TNQ_MAT

@type    function
@author  Denis Hyroshi de Souza
@since   30/06/2008
@sample  A660DESTIN()

@return  L�gico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function A660DESTIN()

	Local aArea := GetArea()

	aTROCAF3 := {}

	If lSigaMdtPS
		If SuperGetMv("MV_MDTF3CO",.F.,"2") == "1"
			AADD(aTROCAF3,{"TNQ_MAT","MDTTNO"})
		EndIf
		If Len(aTROCAF3) == 0
			AADD(aTROCAF3,{"TNQ_MAT","MDTNGQ"})
		EndIf
	Else
		If SuperGetMv("MV_MDTF3CO",.F.,"2") == "1"
			AADD(aTROCAF3,{"TNQ_MAT","TNO"})
		EndIf
		If Len(aTROCAF3) == 0
			If lCpoTNQ
				AADD(aTROCAF3,{"TNQ_MAT","NGQ"})
			Else
				AADD(aTROCAF3,{"TNQ_MAT","SRA"})
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT660DEMI
Verifica se o funcion�rio demitido faz parte da CIPA, " componente "

@author Guilherme Freudenburg
@since  02/09/2014
@sample GPEA010, MDTA660
@return
/*/
//---------------------------------------------------------------------
Function MDT660DEMI()

	Local lSigaMdtPS := SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Local aAreaSRA := GetArea()//Salva o registro posicionado
	Local aAreaTNQ
	Local nAcao   :=0
	Local lComp   := .F.
	Local lCipatr := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )

	If !Empty(M->RA_DEMISSA) .And. !lSigaMdtps//Verifica se a data de demiss�o esta preenchida
		dbSelectArea("TNQ")
		dbSetOrder(2)//TNQ_FILIAL+TNQ_MAT+TNQ_MANDAT
		If dbSeek(xFilial("TNQ")+SRA->RA_MAT)//Verifica se funcion�rio faz parte dos componentes
			aAreaTNQ := GetArea()
			While TNQ->(!Eof()) .And. xFilial("TNQ") == TNQ->TNQ_FILIAL .And. SRA->RA_MAT == TNQ->TNQ_MAT .And. !lComp
				If Empty(TNQ->TNQ_DTSAID)//Verifica se tem algum mandato com a data de saida vazia
					lComp := .T.
				EndIf
				TNQ->(dbSkip())
			End
			RestArea(aAreaTNQ)
			If lComp
				nAcao := Aviso(STR0012,STR0026+Alltrim(SRA->RA_NOME)+ If(lCipatr,STR0037,STR0027),{STR0030,STR0031,STR0032})//" � um componente da CIPATR, deseja informar a data de Sa�da Manualmente ou pela data de Demiss�o ?" //O Funcion�rio ###" � um componente da CIPA, deseja informar a data de Sa�da Manualmente ou pela data de Demiss�o ?"  ## Manual ## Demiss�o ## Sair
				If nAcao == 1//Manualmente
					MDTA660()//Chama rotina de Componentes da cipa
				EndIf
				If nAcao == 2//Pela data de Demiss�o
					While TNQ->(!Eof()) .And. xFilial("TNQ") == TNQ->TNQ_FILIAL .And. SRA->RA_MAT == TNQ->TNQ_MAT
						If Empty(TNQ->TNQ_DTSAID)//Verifica se a data de saida esta vazia
							Reclock('TNQ',.F.)
								TNQ->TNQ_DTSAID:=SRA->RA_DEMISSA//Prenche a data de Saida com o valo da data de Demiss�o
							TNQ->(MsUnLock())
						EndIf
						TNQ->(dbSkip())
					End
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSRA)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT660SAID
Verifica se a data de Demiss�o � menor que a de saida da CIPA

@author Guilherme Freudenburg
@since 02/09/2014
@sample MDTA660
@return
/*/
//---------------------------------------------------------------------
Function MDT660SAID()

	Local lRet:= .T.
	Local aAreaTNQ := GetArea()//Salva o registro posicionado

	If !Empty(M->TNQ_DTSAID)//Verifica se a data de saida nao esta vazia
		dbSelectArea("SRA")
		dbSetOrder(1)
		dbSeek(xFilial("SRA")+M->TNQ_MAT)
		If !Empty(SRA->RA_DEMISSA)//Verifica se a data de demiss�o esta preenchida
			If SRA->RA_DEMISSA <= M->TNQ_DTSAID//Verifica se a data de demiss�o � menor que a de saida
				ShowHelpDlg(STR0012,{STR0028},1,{STR0029},2)//"ATEN��O" ##"A data de Demiss�o � menor que a de sa�da do Mandato."##"Favor informar uma data de Sa�da maior."
				lRet:= .F.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaTNQ)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT660WHEN
Verifica se o MDTA660 foi chamado pela fun��o MDT660DEMI,
caso isso ocorra fechar� os campos.

@param nCmp Numerico Indica qual campo est� utilizando o When:
1 - TNQ_TIPCOM, 2 - TNQ_INDICA, 3 - TNQ_INDFUN

@author Guilherme Freudenburg
@since  02/09/2014
@sample MDTA660
@return
/*/
//---------------------------------------------------------------------
Function MDT660WHEN(nCmp)
Return !( IsInCallStack( "MDT660DEMI" ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT660INC
Verifica se o Membro esta sendo reeleito pela 2� vez consecutiva.
Conforme a lei n�o � permitido.

@author Jean Pytter da Costa
@since  26/08/2015
@sample MDT660INC
@return
/*/
//---------------------------------------------------------------------
Function MDT660INC()

	Local aArea	:= GetArea()
	Local lRet	:= .T.
	Local nCont	:= 0     // Contador de reelei��es
	Local dMandAnt	:= 0 // Ano do Mandato Anterior do Membro
	Local dMandPost	:= 0 // Ano do Mandato Posterior do Membro
	Local dMandSeg  :=0   // Data dois anos antes ou depois
	Local dMandPri  :=0   // Data um ano antes ou depois
	Local lEleito   := .F.// Se esta sendo eleito, por exemplo entre 2015 e 2017, no caso 2016.
	Local lCipatr   := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )

	cAliasTNN := GetNextAlias()
	cTabTNN := RetSqlName("TNN")
	cTabTNQ := RetSqlName("TNQ")

	//Filtra todos Mandatos que o Membro atual foi eleito por ordem de Data de Inicio
	cQuery := "SELECT TNN.TNN_FILIAL, TNN.TNN_MANDAT, TNN.TNN_DTINIC, TNQ.TNQ_MAT, TNQ.TNQ_MANDAT "
	cQuery += "FROM " + cTabTNQ + " TNQ "
	cQuery += "INNER JOIN " + cTabTNN + " TNN ON "
	cQuery += 		"TNN.TNN_MANDAT = TNQ.TNQ_MANDAT AND "
	cQuery += 		"TNQ.TNQ_MAT = '" + M->TNQ_MAT + "' AND "
	cQuery += 		"TNN.TNN_FILIAL = '" + xFilial("TNN") + "' AND "
	cQuery += 		"TNN.D_E_L_E_T_ != '*' "
	cQuery += "WHERE "
	cQuery += 		"TNQ.D_E_L_E_T_ != '*' AND TNQ.TNQ_INDICA = '2' "
	cQuery += "ORDER BY TNN.TNN_DTINIC "
	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery , cAliasTNN )

	DbSelectArea( "TNN" )
	DbSetOrder(1)//TNN_FILIAL+TNN_MANDAT

	If DbSeek( xFilial( "TNN" ) + M->TNQ_MANDAT )

		dMandAtu := Year( TNN->TNN_DTINIC ) //Ano do mandato que esta sendo incluso

		DbSelectArea( cAliasTNN )
		DbGoTop()

		While !Eof() .And. ( cAliasTNN )->TNQ_MAT == M->TNQ_MAT

			dMandMem := Year( STOD( ( cAliasTNN )->TNN_DTINIC ) ) //Ano em que o membro participou da CIPA

			If ( dMandMem + 2 == dMandAtu .Or. dMandMem - 2 == dMandAtu ) //Verifica se foi eleito dois anos antes ou depois
				nCont++
				dMandSeg := dMandMem
			EndIf
			If ( dMandMem + 1 == dMandAtu .Or. dMandMem - 1 == dMandAtu ) //Verifica se foi eleito um ano antes ou depois
				nCont++
				dMandPri := dMandMem
			EndIf

			//Caso estiver sendo incluso um Membro no ano retroativo
			//-------------------
			dMandAnt	:= If( dMandAtu - 1 == dMandMem, dMandMem, dMandAnt ) //Data Anterior ao incluso
			dMandPost	:= If( dMandAtu + 1 == dMandMem, dMandMem, dMandPost ) //Data Posterior ao incluso
			//-------------------

			//Verifica se ja foi eleito no ano anterior e posterior
			If dMandAnt + 1 == dMandAtu .And. dMandPost - 1 == dMandAtu
				lEleito := .T.
				exit
			EndIf

			//Verifica se no pr�ximo e no outro ano ele � membro, no caso se atual � 2016 e ele ja foi membro em 2017 e 2018
			//No caso esta sendo feito uma inclus�o retroativa
			If dMandAtu + 2 == dMandSeg .And. dMandAtu + 1 == dMandPri
				lEleito := .T.
				exit
			EndIf

			//Verifica datas retroativas, no caso se atual � 2016 e se ele ja foi membro em 2014 e 2015
			//N�o � possivel mais de uma reelei��o em anos seguidos.
			If dMandAtu - 2 == dMandSeg .And. dMandAtu - 1 == dMandPri
				lEleito := .T.
				exit
			EndIf

			DbSelectArea( cAliasTNN )
			( cAliasTNN )->( DbSkip() )
		End

		//Verifica se data de inclus�o esta entre alguma data, por exemplo entre 2014 e 2017.
		//� zerado o contador, pois � possivel incluir.
		If !( lEleito )
			If dMandAnt == 0 .Or. dMandPost == 0
				nCont := 0
			EndIf
		EndIf

		If nCont > 1 .Or. lEleito
			ShowHelpDlg( STR0012 , ;//"Aten��o"
			{ If( lCipatr, STR0038, STR0033) } , 1 , ; //"O mandato dos membros eleitos da CIPATR ter� a dura��o de dois anos, permitida uma reelei��o." //"O mandato dos membros eleitos da CIPA ter� a dura��o de um ano, permitida uma reelei��o."
			{ STR0034 } , 1 ) //"Selecionar outro membro para o mandato, pois esse membro j� foi reeleito uma vez."
			lRet := .F.
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660SEC
Fun��o que valida se o funcion�rio que est� sendo cadastrado como
componente da cipa � igual ao inserido no cadastro do mandato da cipa
de secret�rio titular e suplente.

@type    function
@author  Julia Kondlatsch
@since   18/10/2018
@sample  MDT660SEC( '001', 'D MG 01', '000014', '2' )

@param   cFilComp, Caractere, Filial do componenete
@param   cMatric, Caractere, Matr�cula do componente
@param   cFuncCipa, Caractere, Fun��o do componente dentro da CIPA
( 1-Presidente, 2-Vice-Presidente, 3-Secretario, 4-Secretario Substituto )

@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDT660SEC( cMandat, cFilComp, cMatric, cFuncCipa )

	Local cNomeComp := ''
	Local cNomeCipa := ''
	Local lYesNo    := .F.
	Local cTNNFil   := ''
	Local cTNNMat   := ''
	Local cTipo     := ''

	// Se o componente cadastrado for um secret�rio ou secret�rio substituto
	If !Empty(cFuncCipa) .And. (cFuncCipa == '3' .Or. cFuncCipa == '4')

		cTNNFil := IIf( cFuncCipa == '3', 'TNN->TNN_FILRE1', 'TNN->TNN_FILRE2' )
		cTNNMat := IIf( cFuncCipa == '3', 'TNN->TNN_MATRE1', 'TNN->TNN_MATRE2' )
		cTipo   := IIf( cFuncCipa == '3', STR0039, STR0040 ) //'Secret�rio(a)' # 'Secret�rio Substituto'

		dbSelectArea('TNN') // Mandatos CIPA
		dbSetOrder(1)
		If dbSeek( xFilial('TNN') + cMandat )

			// Se n�o for o mesmo funcion�rio cadastadminrado como secret�rio titular no mandato da CIPA
			If !Empty( &(cTNNMat) ) .And. ( &(cTNNFil) <> cFilComp .Or. &(cTNNMat) <> cMatric )

				cNomeComp := Alltrim(Posicione( 'SRA', 1, xFilial('SRA', cFilComp) + cMatric, 'RA_NOME' ))
				cNomeCipa := Alltrim(Posicione( 'SRA', 1, xFilial('SRA', &(cTNNFil)) + &(cTNNMat), 'RA_NOME' ))

				lYesNo := MsgYesNo( STR0041 + cNomeComp + STR0042 + cTipo + STR0043 + STR0039 + ' ' + cNomeCipa + STR0044, STR0012 )
				// 'ATEN��O' # 'Foi identificado que o componente ' #, que foi cadastrado(a) como ' # ', � diferente do(a) ' #
				// 'Secret�rio(a)' # ' que foi definido no mandato CIPA (TNN). Deseja atualizar o cadastro do mandato?'

			EndIf

			// Se o usu�rio esacolheu sobrescrever ou se o registro est� vazio
			If Empty( &(cTNNMat) ) .Or. lYesNo

				// Grava no mandato o componente cadastrado
				Reclock('TNN',.F.)
					&(cTNNFil) := cFilComp
					&(cTNNMat) := cMatric
				TNN->(MsUnLock())

			EndIf

			If lYesNo
				MsgInfo(STR0045) //'O registro do mandarto CIPA foi modificado.'
			EndIf

		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660ESTB
Ajusta a data de estabilidade aos campos RA_DTVTEST e TNQ_DTESTB referente a CIPA

@return	Nil, Nulo

@param	nOpcx, Num�rico, Opera��o que est� sendo realizada

@sample	MDT660ESTB( 3 )

@author	Luis Fellipy Bett
@since	09/06/2021
/*/
//-------------------------------------------------------------------
Function MDT660ESTB( lSistema, nOpcx, cMandato, cFilComp, cComponente, dDtUltReu, lPerdEstab, dDtEstbOld, cJustifOld, cIndicaOld )

	Local lAltDtEstb := .F.
	Local lAltJustif := .F.
	Local lAltIndica := .F.
	Local dDataEstb	 := SToD( "" )

	Default nOpcx := 4 //Define por padr�o como altera��o nas retiradas de estabilidade por 5 faltas

	//Caso for remo��o de estabilidade por 5 faltas
	If lSistema

		dbSelectArea( "TNQ" )
		dbSetOrder( 3 ) //TNQ_FILIAL+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)
		If dbSeek( xFilial( "TNQ" ) + cMandato + cFilComp + cComponente )

			MDT660SRA( nOpcx, cMandato, cComponente, cFilComp, TNQ->TNQ_TIPCOM, , lPerdEstab, .T., , dDtUltReu )

			//Pega a data e o usu�rio que alterou os campos TNQ_DTESTB e/ou TNQ_JUSTIF
			MDT660USU( .T., cComponente, dDtUltReu )

		EndIf

	Else

		//Caso for altera��o
		If nOpcx == 4
			//Verifica altera��o do campo TNO_INDICA
			lAltIndica := TNQ->TNQ_INDICA <> cIndicaOld

			//Verifica��o de altera��o dos campos de perda de estabilidade
			If lPerdEstab
				lAltDtEstb := TNQ->TNQ_DTESTB <> dDtEstbOld
				lAltJustif := TNQ->TNQ_JUSTIF <> cJustifOld
			EndIf
		EndIf

		If nOpcx == 3 .Or. nOpcx == 5 .Or. ( nOpcx == 4 .And. lAltDtEstb .Or. lAltIndica )
			dDataEstb := MDT660SRA( nOpcx, cMandato, cComponente, cFilComp, TNQ->TNQ_TIPCOM, , lPerdEstab, lAltDtEstb )
		EndIf

		If nOpcx = 3 .Or. nOpcx = 4 //Caso for inclus�o ou altera��o valida
			MDT660SEC( cMandato, cFilComp, cComponente, TNQ->TNQ_INDFUN )
		EndIf

		//Caso o sistema esteja preparado com os campos de perda da estabilidade
		If lPerdEstab

			//Ajusta a estabilidade da TNQ
			If ( nOpcx == 3 .Or. nOpcx == 4 ) .And. !Empty( dDataEstb ) .And. !lAltDtEstb
				MDT660TNQ( cMandato, cComponente, dDataEstb )
			EndIf

			//Pega a data e o usu�rio que alterou os campos TNQ_DTESTB e/ou TNQ_JUSTIF
			If lAltDtEstb .Or. lAltJustif
				MDT660USU()
			EndIf

		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660SRA
Ajusta o campo RA_DTVTEST com a data de estabilidade do candidato referente a CIPA

@return	SRA->RA_DTVTEST, Data, Data de estabilidade a ser considerada no campo RA_DTVTEST

@param	nOpcx, Num�rico, Opera��o que est� sendo realizada
@param	cMandato, Caracter, Mandato da CIPA
@param	cComponente, Caracter, Candidato da CIPA
@param	cFilComp, Caracter, Filial do candidato
@param	cTipComp, Caracter, Tipo de estabilidade
@param	lShowMsg, Boolean, Indica se mostra a mensagem
@param	lPerdEstab, Boolean, Indica se o dicion�rio est� atualizado com os campos da perda da estabilidade
@param	lAltDtEstb, Boolean, Indica se teve altera��o manual na data de estabilidade da TNO
@param	lMDTA645, Boolean, Indica se � chamado pelo MDTA645

@sample	MDT660SRA( 2, "2021 ", "100000", "D MG 01 ", "1", .F., .T., .T., .F. )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Function MDT660SRA( nOpcx, cMandato, cComponente, cFilComp, cTipComp, lShowMsg, lPerdEstab, lAltDtEstb, lMDTA645, dDtUltReu )

	Local lTrcTipCop := IIf( !Empty( dDtUltReu ), .F., nTipInd1 == "2" .And. nTipInd2 == "1" ) //Indica se houve troca no tipo do componente
	Local lSupTemEst := SuperGetMv( "MV_NG2CSUP", .F., "1" ) == "1"
	Local dDtEstAtu	 := SToD( "" )
	Local dDtEstNov	 := SToD( "" )
	Local dDtEleicao := SToD( "" )
	Local dDtVerMsg	 := SToD( "" )
	Local lIsCand	 := .F.
	Local lEntra	 := .F.
	Local aAreaTNO

	Default lShowMsg := .T.
	Default lMDTA645 := .F.
	Default dDtUltReu := SToD( "" )

	//Caso a data na TNQ tenha sido alterado manualmente, ou esteja sendo alterada por 5 faltas ou seja exclus�o do componente
	If lPerdEstab .And. lAltDtEstb .Or. !Empty( dDtUltReu ) .Or. nOpcx == 5
		dDtEstNov := MDT660GTDT( cComponente ) //Busca a data de estabilidade vigente da SR8
	EndIf

	//Busca a data de estabilidade atual referente a CIPA
	dDtEstAtu := fGetEstbAtu( cMandato, @dDtEleicao )

	//Caso tenha um per�odo de estabilidade a ser considerado
	If !Empty( dDtEstAtu )

		//Adiciona a data para verificar se dispara o help
		dDtVerMsg := dDtEstAtu

		dbSelectarea( "SRA" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "SRA", cFilComp ) + cComponente )

			//Caso for chamada pelo MDTA645 ou seja inclus�o ou altera��o
			If lMDTA645 .Or. nOpcx == 3 .Or. nOpcx == 4

				//Caso o componente do tipo "Suplente" ganhar estabilidade ou o componente for "Titular"
				If cTipComp == "1" .Or. ( cTipComp == "2" .And. lSupTemEst )

					//Verifica qual data considerar para a estabilidade
					If !Empty( dDtUltReu ) //Caso for retirada da estabilidade por 5 faltas

						//Caso n�o tenha uma data a ser considerada da SR8 ou a data da SR8 for menor que a data da �ltima reuni�o
						If Empty( dDtEstNov ) .Or. dDtEstNov < dDtUltReu
							dDtEstAtu := dDtUltReu
						Else
							dDtEstAtu := dDtEstNov
						EndIf

						lEntra := .T.

					ElseIf lAltDtEstb //Caso for altera��o manual na data de estabilidade

						//Caso n�o tenha uma data a ser considerada da SR8 ou a data da SR8 for menor que a data inputada manualmente
						If Empty( dDtEstNov ) .Or. dDtEstNov < TNQ->TNQ_DTESTB
							dDtEstAtu := TNQ->TNQ_DTESTB
						Else
							dDtEstAtu := dDtEstNov
						EndIf

						lEntra := .T.

					ElseIf !Empty( dDtEstNov )

						dDtEstAtu := dDtEstNov

					EndIf

					If Empty( SRA->RA_DTVTEST ) .Or. SRA->RA_DTVTEST <= dDtEstAtu .Or. lEntra

						RecLock( "SRA", .F. )

						//Caso for altera��o e a indica��o tenha sido alterado de "Empregados" pra "Empresa", zera a estabilidade
						If Altera .And. lTrcTipCop

							If SRA->RA_DTVTEST == dDtEstAtu

								SRA->RA_DTVTEST := SToD( "" )

							EndIf

							If lShowMsg
								MsgInfo( STR0057 ) //"A partir deste momento o componente deixa de ter estabilidade referente a CIPA!"
							EndIf

							//Manipula a estabilidade do funcion�rio na tabela RFX
							fAddEstRFX( cMandato, cFilComp, cComponente, cTipComp, dDtEstAtu, dDtEstNov, .T. )

						//Caso a data atual da SRA seja menor que a data a ser considerada e a indica��o for igual a "Empregados" ou for retirada da estabilidade por 5 faltas
						ElseIf IIf( Empty( dDtUltReu ), nTipInd2, TNQ->TNQ_INDICA ) == "2" .And. ( SRA->RA_DTVTEST < dDtEstAtu .Or. lEntra )

							SRA->RA_DTVTEST := dDtEstAtu

							If lShowMsg .And. dDtVerMsg == dDtEstAtu
								MsgInfo( STR0008 + DToC( dDtEstAtu ) + "!" ) //"A partir deste momento o Componente da CIPA ter� estabilidade at� XX/XX/XXXX!"
							EndIf

							//Manipula a estabilidade do funcion�rio na tabela RFX
							fAddEstRFX( cMandato, cFilComp, cComponente, cTipComp, dDtEstAtu, dDtEstNov )
						EndIf

						SRA->( MsUnlock() )

					EndIf
				EndIf

			ElseIf nOpcx == 5 //Caso for exclus�o

				//Verifica se o componente � tamb�m um candidato
				lIsCand := fVerCand( cMandato, cFilComp, cComponente )

				dDtEstNov := fDtEstAnt( cFilComp, cComponente, dDtEstNov )

				If SRA->RA_DTVTEST == dDtEstAtu .Or. SRA->RA_DTVTEST == TNQ->TNQ_DTESTB

					RecLock( "SRA", .F. )

					If !Empty( dDtEstNov )
						SRA->RA_DTVTEST := dDtEstNov
					Else
						SRA->RA_DTVTEST := IIf( lIsCand, dDtEleicao, SToD( "" ) )
					EndIf

					MsUnlock( "SRA" )

					If !lIsCand
						MsgInfo( STR0057 ) //"A partir deste momento o componente deixa de ter estabilidade referente a CIPA!"
					EndIf

					fAddEstRFX( cMandato, cFilComp, cComponente, cTipComp, dDtEstAtu, dDtEstNov, .T. )
				EndIf
			EndIf
		EndIf
	EndIf

Return dDtEstAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetEstbAtu
Busca a data de estabilidade atual do componente

@return	dDtEstAtu, Data, Data de estabilidade atual

@param	cMandato, Caracter, Mandato do componente
@param	dDtEleicao, Data, Data de elei��o do mandato

@sample	fGetEstbAtu( "2021", @dDtEleicao )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Static Function fGetEstbAtu( cMandato, dDtEleicao )

	Local lCipatr := SuperGetMv( "MV_NG2NR31", .F., "2" ) == "1"
	Local dDtEstAtu := SToD( "" )

	dbSelectarea( "TNN" )
	dbSetOrder( 1 ) //TNN_FILIAL+TNN_MANDAT
	If dbSeek( xFilial( "TNN" ) + cMandato )

		//Salva a data da elei��o
		dDtEleicao := TNN->TNN_ELEICA

		If lCipatr
			dDtEstAtu := NGSomaAno( TNN->TNN_DTTERM, 2 )
		Else
			dDtEstAtu := NGSomaAno( TNN->TNN_DTTERM, 1 )
		EndIf

	EndIf

Return dDtEstAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerCand
Verifica se o componente � tamb�m candidato

@return	lCand, Boolean, .T. caso o componente seja candidato

@param	cMandato, Caracter, Mandato do componente
@param	cFilComp, Caracter, Filial do componente
@param	cComponente, Caracter, Matr�cula do componente

@sample	fVerCand( "2021", "D MG 01", "100000" )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Static Function fVerCand( cMandato, cFilComp, cComponente )

	Local aArea := GetArea()
	Local lCand := .F.

	dbSelectArea( "TNO" )
	dbSetOrder( 3 ) //TNO_FILIAL+TNO_MANDAT+TNO_FILMAT+TNO_MAT+DTOS(TNO_DTCAND)
	lCand := dbSeek( xFilial( "TNO" ) + cMandato + cFilComp + cComponente )

	//Retorna a �rea
	RestArea( aArea )

Return lCand

//-------------------------------------------------------------------
/*/{Protheus.doc} fAddEstRFX
Manipula as estabilidades do funcion�rio na tabela RFX

@return	Nil, Nulo

@param	dDataEstb, Data, Data de estabilidade inputada no campo RA_DTVTEST
@param	cMatricula, Caracter, Matricula do candidato

@sample	fAddEstRFX( 3, 01/01/2021, "100000" )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Static Function fAddEstRFX( cMandato, cFilComp, cComponente, cTipComp, dDtEstAtu, dDtEstNov, lExcEstb )

	//Variavel de consistencia da RFX
	Local lConsRFX := AliasInDic( "RFX" ) .And. FindFunction( "MDTEstFunc" )
	Local dDtCand  := Posicione( "TNO", 3, xFilial( "TNO" ) + cMandato + cFilComp + cComponente, "TNO_DTCAND" ) //Data de candidatura do funcion�rio
	Local dDtAux   := IIf( !Empty( dDtEstNov ), dDtEstNov, dDtEstAtu )
	Local cTiptAux := ""
	Local nTipoEst := 0

	//Por padr�o define como n�o exclus�o da estabilidade
	Default lExcEstb := .F.

	//Caso tenha consist�ncia em rela��o a RFX
	If lConsRFX

		//Caso candidatura seja superior a data de termino da estabilidade, n�o gera
		If !Empty( dDtCand ) .And. dDtCand <= dDtAux

			//Busca o tipo de estabilidade
			nTipoEst := IIf( cTipComp == "1", 8, 9 )

			//Busca o tipo de estabilidade de acordo com o Tipo do Componente (Titular ou Suplente) - Busca se da pelo tipo de estabilidade eSocial ( 08 - Eleito Titular CIPA;\09 - Eleito Suplente CIPA; )
			If !Empty( cTiptAux := MDTEstFunc( nTipoEst ) )

				dbSelectArea( "RFX" )
				dbSetOrder( 1 ) //RFX_FILIAL+RFX_MAT+RFX_DTOS(RFX_DATI)+RFX_TPESTB

				If lExcEstb //Caso for exclus�o do componente

					If dbSeek( xFilial( "RFX" ) + cComponente + DToS( dDtCand ) + cTiptAux ) //Caso j� tenha a estabilidade, remove a estabilidade
						RecLock( "RFX", .F. )
							RFX->( dbDelete() )
						RFX->( MsUnLock() )
					EndIf

				Else

					If dbSeek( xFilial( "RFX" ) + cComponente + DTOS( dDtCand ) + cTiptAux ) //Caso j� tenha a estabilidade, altera apenas a data fim
						RecLock( "RFX", .F. )
					Else
						RecLock( "RFX", .T. )
					EndIf

					RFX->RFX_FILIAL := xFilial( "RFX" ) //Obrigat�rio
					RFX->RFX_MAT := cComponente //Obrigat�rio
					RFX->RFX_DATAI := dDtCand //Obrigat�rio
					If RFX->( FieldPos( "RFX_HORAI" ) ) > 0
						RFX->RFX_HORAI := "00:00" //Obrigat�rio
					EndIf
					RFX->RFX_TPESTB := cTiptAux
					RFX->RFX_DATAF := dDtAux
					If RFX->( FieldPos( "RFX_HORAF" ) ) > 0
						RFX->RFX_HORAF := "23:59"
					EndIf
					RFX->( MsUnLock() )

				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660TNQ
Ajusta o campo TNQ_DTESTB com a data da estabilidade a ser inclu�da no campo RA_DTVTEST

@return	Nil, Nulo

@param	cMandato, Caracter, Mandato da CIPA
@param	cMatricula, Caracter, Matricula do componente
@param	dDataEstb, Data, Data de estabilidade inputada no campo RA_DTVTEST

@sample	MDT660TNQ( "2022", "100015", 01/03/2021 )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Function MDT660TNQ( cMandato, cMatricula, dDataEstb )

	//Adiciona a data de estabilidade ao campo TNQ_DTESTB
	dbSelectArea( "TNQ" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TNQ" ) + cMandato + cMatricula ) .And. ( Empty( TNQ->TNQ_DTESTB ) .Or. TNQ->TNQ_DTESTB <= dDataEstb )
		RecLock( "TNQ", .F. )
		If Altera .And. nTipInd1 == "2" .And. nTipInd2 == "1"
			TNQ->TNQ_DTESTB := SToD( "" )
		ElseIf TNQ->TNQ_DTESTB < dDataEstb .And. nTipInd2 == "2"
			TNQ->TNQ_DTESTB := dDataEstb
		EndIf
		TNQ->( MsUnlock() )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660USU
Atualiza as informa��es de data e usu�rio que realizou a �ltima
altera��o da estabilidade do componente

@return	Nil, Nulo

@param	lSistema, Boolean, Indica se � retirada autom�tica pelo sistema
@param	cMatricula, Caracter, Matricula do candidato
@param	dDataEstb, Data, Data de estabilidade inputada no campo RA_DTVTEST

@sample	MDT660USU()

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Function MDT660USU( lSistema, cMatricula, dDataEstb )

	Local dDataAlt := dDataBase
	Local cUserAlt := SubStr( IIf( lSistema, STR0054, cUserName ), 1, 40 ) //"Sistema"

	Default lSistema := .F.

	//Caso for altera��o via sistema, posiciona na TNQ com a matr�cula do componente
	If lSistema
		dbSelectArea( "TNQ" )
		dbSetOrder( 2 )
		dbSeek( xFilial( "TNQ" ) + cMatricula )
	EndIf

	//Caso for altera��o do usu�rio ou altera��o pelo sistema e a �ltima altera��o da estabilidade n�o ter sido feita pelo sistema
	If !lSistema .Or. ( lSistema .And. AllTrim( Upper( TNQ->TNQ_USUARI ) ) <> "SISTEMA" )

		RecLock( "TNQ", .F. )
			TNQ->TNQ_DTALT := dDataAlt
			TNQ->TNQ_USUARI := cUserAlt
			If lSistema
				TNQ->TNQ_DTESTB := dDataEstb
				TNQ->TNQ_JUSTIF := STR0055 + CRLF + STR0056 //"Justificativa gerada automaticamente pelo sistema."##"Conforme item 5.30 da NR 5: 'O membro titular perder� o mandato, sendo substitu�do por suplente, quando faltar a mais de quatro reuni�es ordin�rias sem justificativa.'. Componente faltou 5 ou mais vezes em agendas ordin�rias da CIPA, portanto, perdeu sua estabilidade."
			EndIf
		TNQ->( MsUnlock() )

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT660GTDT
Verifica se existe uma data de estabilidade a ser considerada fora a
data da CIPA

@return	dDtEstab, Data, Data de estabilidade a ser cadastrada no campo RA_DTVTEST

@sample	MDT660GTDT()

@author	Luis Fellipy Bett
@since	31/05/2021
/*/
//-------------------------------------------------------------------
Function MDT660GTDT( cMatricula )

	Local dDtEstab	:= SToD( "" )

	Private cAliasSR8 := GetNextAlias()
	Private cAliasDur := ""
	Private nDuracao := 0
	Private oTempTRB
	Private dDtAfast := SToD( "" )
	Private cTipo := ""

	//Busca todos os afastamentos do funcion�rio
	BeginSQL Alias cAliasSR8
		SELECT SR8.R8_SEQ, SR8.R8_TIPOAFA, SR8.R8_DATAINI, SR8.R8_DATAFIM, SR8.R8_DURACAO, SR8.R8_CONTAFA
			FROM %Table:SR8% SR8
			WHERE SR8.R8_FILIAL = %xFilial:SR8% AND
				SR8.R8_MAT = %exp:cMatricula% AND
				SR8.%NotDel%
			ORDER BY SR8.R8_DATAFIM DESC, R8_CONTAFA DESC
	EndSql

	//Filtra os afastamentos buscando apenas os maiores que 15 dias
	dbSelectArea( cAliasSR8 )
	( cAliasSR8 )->( dbGoTop() )
	While ( cAliasSR8 )->( !Eof() ) .And. Empty( dDtAfast )
		fGetDur( ( cAliasSR8 )->R8_SEQ )
		( cAliasSR8 )->( dbSkip() )
	End

	//Caso a tabela tenha sido criada, deleta
	If !Empty( cAliasDur )
		oTempTRB:Delete()
	EndIf

	//Fecha tabela da query
	( cAliasSR8 )->( dbCloseArea() )

	//Caso tenha algum afastamento a ser considerado
	If !Empty( cTipo ) .And. !Empty( dDtAfast )
		dbSelectArea( "RCM" )
		dbSetOrder( 1 ) //RCM_FILIAL+RCM_TIPO
		If dbSeek( xFilial( "RCM" ) + cTipo )
			If RCM->RCM_DIAEST # 0 .And. !Empty( dDtAfast )
				dDtEstab := dDtAfast + RCM->RCM_DIAEST
			EndIf
		EndIf
	EndIf

Return dDtEstab

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetDur
Busca a dura��o de cada afastamento de mesmo tipo maior que 15 dias

@return	dDtEstab, Data, Data de estabilidade a ser cadastrada no campo RA_DTVTEST

@param	cAliasSR8, Caracter, Alias da tabela SR8 contendo os afastamentos

@sample	fGetDur( "SGN00023" )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Static Function fGetDur( cSeq )

	Local aDBF := {}

	//Caso a vari�vel n�o tenha uma tabela adicionada
	If Empty( cAliasDur )
		cAliasDur := GetNextAlias()

		aAdd( aDBF, { "R8_SEQ", "C", 03, 0 } )
		aAdd( aDBF, { "R8_TIPOAFA", "C", 03, 0 } )
		aAdd( aDBF, { "R8_DATAINI", "C", 08, 0 } )
		aAdd( aDBF, { "R8_DATAFIM", "C", 08, 0 } )
		aAdd( aDBF, { "R8_DURACAO", "N", 05, 0 } )
		aAdd( aDBF, { "R8_CONTAFA", "C", 03, 0 } )

		//Cria TRB
		oTempTRB := FWTemporaryTable():New( cAliasDur, aDBF )
		oTempTRB:AddIndex( "1", { "R8_SEQ" } )
		oTempTRB:Create()

		dbSelectArea( cAliasSR8 )
		( cAliasSR8 )->( dbGoTop() )
		While ( cAliasSR8 )->( !Eof() )
			RecLock( cAliasDur, .T. )
				( cAliasDur )->R8_SEQ	  := ( cAliasSR8 )->R8_SEQ
				( cAliasDur )->R8_TIPOAFA := ( cAliasSR8 )->R8_TIPOAFA
				( cAliasDur )->R8_DATAINI := ( cAliasSR8 )->R8_DATAINI
				( cAliasDur )->R8_DATAFIM := ( cAliasSR8 )->R8_DATAFIM
				( cAliasDur )->R8_DURACAO := ( cAliasSR8 )->R8_DURACAO
				( cAliasDur )->R8_CONTAFA := ( cAliasSR8 )->R8_CONTAFA
			( cAliasDur )->( MsUnlock() )
			( cAliasSR8 )->( dbSkip() )
		End
	EndIf

	dbSelectArea( cAliasDur )
	dbSetOrder(1)
	If dbSeek( cSeq )
		If ( ( cAliasDur )->R8_DATAFIM >= DToS( dDataBase ) ) .Or. ( nDuracao > 0 ) //Caso o final do afastamento for maior que a data atual
			If ( cAliasDur )->R8_DURACAO >= 15 .And. nDuracao == 0 //Caso a dura��o for maior que 15 dias
				dDtAfast := SToD( ( cAliasDur )->( R8_DATAFIM ) )
				cTipo := ( cAliasDur )->( R8_TIPOAFA )
			Else
				If nDuracao == 0
					dDtAfast := SToD( ( cAliasDur )->( R8_DATAFIM ) )
					cTipo := ( cAliasDur )->( R8_TIPOAFA )
				EndIf

				nDuracao := nDuracao + ( cAliasDur )->R8_DURACAO

				If nDuracao < 15
					If !Empty( ( cAliasDur )->( R8_CONTAFA ) )
						fGetDur( ( cAliasDur )->( R8_CONTAFA ) )
					Else
						dDtAfast := SToD( "" )
						nDuracao := 0
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTNQWHEN
X3_WHEN dos campos TNQ_DTESTB e TNQ_JUSTIF

@return	lRet, Boolean, Indica se o campo estar� fechado ou aberto

@param	nCampo, Num�rico, Indica o campo a ser validado

@sample	MDTTNQWHEN( 1 )

@author	Luis Fellipy Bett
@since	24/05/2021
/*/
//-------------------------------------------------------------------
Function MDTTNQWHEN( nCampo )

	Local lRet := .F.
	Local lIntegra := SuperGetMv( "MV_MDTGPE", .F., "N" ) == "S"

	//Caso for altera��o, exista integra��o com o GPE, o campo de justificativa estiver vazio
	If ALTERA .And. lIntegra .And. TNQ->TNQ_INDICA == "2"
		If nCampo == 2 //Caso for When do campo de justificativa
			lRet := TNQ->TNQ_DTESTB <> M->TNQ_DTESTB .Or. !Empty( TNQ->TNQ_JUSTIF )
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTNQVALID
X3_VALID dos campos TNQ_DTESTB e TNQ_JUSTIF

@return	lRet, Boolean, Indica se o campo est� consistente ou n�o

@param	nCampo, Num�rico, Indica o campo a ser validado

@sample	MDTTNQVALID( 1 )

@author	Luis Fellipy Bett
@since	24/05/2021
/*/
//-------------------------------------------------------------------
Function MDTTNQVALID( nCampo )

	Local lRet := .T.

	If nCampo == 1 //Caso for valida��o do campo TNQ_DTESTB
		If !Empty( TNQ->TNQ_DTESTB ) .And. Empty( M->TNQ_DTESTB )
			Help( ' ', 1, STR0047, , STR0048, 2, 0, , , , , , { STR0049 } ) //"J� existe uma data fim de estabilidade, a data n�o pode ser exclu�da"##"Favor selecionar uma data para o fim da estabilidade"
			lRet := .F.
		ElseIf M->TNQ_DTESTB > TNQ->TNQ_DTESTB
			Help( ' ', 1, STR0047, , STR0050, 2, 0, , , , , , { STR0051 } ) //"A data fim da estabilidade do funcion�rio n�o pode ser maior que a data j� preenchida"##"Favor selecionar uma data igual ou anterior a data definida"
			lRet := .F.
		EndIf
	ElseIf nCampo == 2 .And. Altera //Caso for valida��o do campo TNQ_JUSTIF e for altera��o
		If ( TNQ->TNQ_DTESTB <> M->TNQ_DTESTB .Or. !Empty( TNQ->TNQ_JUSTIF ) ) .And. Empty( M->TNQ_JUSTIF )
			Help( ' ', 1, STR0047, , STR0052, 2, 0, , , , , , { STR0053 } ) //"O campo de justificativa n�o pode ficar em branco"##"Favor preencher um conte�do no campo"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fDtEstAnt
Busca a data da estabilidade de mandatos anteriores
no momento da exclus�o

@author	Gabriel Sokacheski
@since 06/07/2022

@param cFil, Caractere, Filial do funcion�rio
@param cMat, Caractere, Matr�cula do funcion�rio
@param dEstNov, Data, Data nova da estabilidade

@return	dEst, Data, Estabilidade do mandato anterior
/*/
//-------------------------------------------------------------------
Static Function fDtEstAnt( cFil, cMat, dEstNov )

	Local aArea := GetArea()

	Local dEst := StoD( '  /  /    ' )

	DbSelectArea( 'TNQ' )
	DbSetOrder( 2 )

	If DbSeek( xFilial( 'TNQ' ) + cMat )

		While !( 'TNQ' )->( Eof() ) .And. cMat == TNQ->TNQ_MAT

			If cFil == TNQ->TNQ_FILMAT .And. TNQ->TNQ_DTESTB > dEst
				dEst := TNQ->TNQ_DTESTB
			EndIf

			( 'TNQ' )->( DbSkip() )

		End

	EndIf

	If !Empty( dEstNov ) .And. dEstNov > dEst
		dEst := dEstNov
	EndIf

	RestArea( aArea )

Return dEst
