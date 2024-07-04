#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA061.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			    CRIADO PROGRAMA FCIXFUN QUE CONTEM AS FUNCTIONS (PUBLICAS) E INTEGRACOES COM MATERIAIS
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

//DEFINE DE PARAMETROS (SX6)
#DEFINE MV_FCITR		01
#DEFINE MV_FCIVE		02
#DEFINE MV_FCICL		03
#DEFINE MV_FCIVI		04
#DEFINE MV_FCIALIQ		05
#DEFINE MV_FCIMI		06
#DEFINE MV_FCIGTIN		07
#DEFINE MV_FCICALC		08
#DEFINE MV_ESTADO		09
#DEFINE MV_FCINWPR		10
#DEFINE MV_FCIPRV		11
#DEFINE MV_FCINTHD  12
#DEFINE MV_FCITOUT  13

//DEFINE DE FIELDPOS (SX3)
#DEFINE FP_MV_FCIGTIN	01
#DEFINE FP_BZ_FCIPRV	02

//DEFINE DO ARRAY aDadosINI
#DEFINE INI_CODPRO    01
#DEFINE INI_DESCPRO   02
#DEFINE INI_PRCVEN    03
#DEFINE INI_DTVEN     04
#DEFINE INI_USAFCI    05

// TEXTO
#DEFINE PULALINHA CHR(13)+CHR(10)

Static aX6Content := {}
Static aX3FieldP  := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA061

Funcao de geracao e importacao do arquivo magnetico da FCI

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Function FISA061( aWizJob , aFilJob , cDirJob , cArqJob , nTipo )
Local aWizard	:= {}
Local aLisFil	:= {}
Local lMultFil	:= .F.
Local cFilDe	:= ""
Local cFilAte	:= ""
Local aError	:= {}
Local lJob		:= .F.
Local cMsgValid := ""

Default aWizJob := {}
Default aFilJob := {}
Default cDirJob := ""
Default cArqJob := ""
Default nTipo   := 1

Private	oObjClass

//Quando for chamado via JOB, as informacoes do WIZARD serao passadas como parametro na funcao
If (lJob := Len(aWizJob) > 0)
	PtInternal(1,"FCI (Execucao Automática) - Emp: "+cEmpAnt+" - Filial: "+cFilAnt)
	aWizard	:= aWizJob
	aLisFil := aFilJob
EndIf

x061LoadCache(.T.)

aError := XFciError()

//Monta perguntas iniciais da rotina
If xFciIniEnv( @aWizard , @lMultFil , @aLisFil , @cFilDe , @cFilAte , aError , lJob )
	
	//Validações iniciais das perguntas
	If Empty(aWizard[1][1]) .Or. Empty(aWizard[1][2])
		cMsgValid := STR0073 // Data inicial / final não preenchida. O processamento será interrompido.
	ElseIf ( aWizard[1][2] < aWizard[1][1] )	
		cMsgValid := STR0100 //"Data inicial menor que Data final. O processamento será interrompido."
	ElseIf lJob .And. nTipo != 1  //Validar se diretorio selecionado para execução da rotina é o mesmo que STARTPATH, evitando error.log na rotina xFunGetDir -nOpc = 3 na função MsCopyFile		
		cMsgValid := ValidPerg(cDirJob, iIf(nTipo = 3,"",cArqJob))
	EndIf	
	
	If Empty(cMsgValid)
		x061ShowProg( aWizard , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob , nTipo )
	Else
		If lJob
			QOut(cMsgValid) 
		Else
			MsgAlert(cMsgValid)
		EndIf	
	EndIf
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061ShowProg

Funcao que cria a arvore de processos da rotina

@param	aWizard		-> Array com conteudo dos campos preenchidos na wizard
					   da Rotina
		lMultFil	-> Indica se o processamento sera feito utilizando selecao
					   de filiais 
		aLisFil		-> Array com as filiais que serao processadas
		cFilDe		-> Filial Inicial
		cFilAte		-> Filial Final

@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061ShowProg( aWizard , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob , nTipo )
Local aInfCust  := {}
Local bProcess  := {}
Local cMsg,cMsg2,cMsg3 := ""
Local oProcess
Local cTxtIntro :=	STR0001 + CRLF +; 		//"Rotina responsável pela geração e importação do Arquivo da FCI."
					STR0002 + CRLF + CRLF+;	//"Para executar o processamento do período selecionado, clique no botão abaixo e aguarde a conclusão do processo."
					STR0003 + CRLF +; 		//"Log de Processos: Log de todos os processos executados desta rotina"
					STR0004 + CRLF +; 		//"Gera Txt: Função responsável pela geração do Arquivo Texto."
					STR0005 + CRLF //+; 		//"Importação: Função responsável pela importação dos códigos retornados pela Sefaz."
					//STR0006 				//"Relatório: Função responsável pela impressão do relatório de conferência."
Default lJob := .F.

Aadd(	aInfCust,	{ STR0007,	{ |oCenterPanel| x061Txt	( oCenterPanel , aWizard , @cMsg2 , lMultFil , aLisFil , cFilDe , cFilAte ) },	"PROCESSA",		{ {} , {} } } ) //"Gera Txt"
Aadd(	aInfCust,	{ STR0008,	{ |oCenterPanel| x061Load	( oCenterPanel , aWizard , @cMsg3 , lMultFil , aLisFil , cFilDe , cFilAte ) },	"PROCESSA",		{ {} , {} } } ) //"Importação"

//Relatorio disponivel apenas para o metodo de calculo 2
If aX6Content[MV_FCICALC] == 2
	Aadd(	aInfCust,	{ STR0009,	{ |oCenterPanel| x061Report ( oCenterPanel , aWizard , lMultFil , aLisFil , cFilDe , cFilAte ) },			"RELATORIO",	{ {} , {} } } ) //"Relatório"
Endif

If lJob
	If nTipo == 1
		x061Processa( aWizard , lMultFil , aLisFil , cFilDe , cFilAte , @cMsg , oProcess , Nil , lJob )
	ElseIf nTipo == 2
		x061Load(  , aWizard , @cMsg3 , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob )
	ElseIf nTipo == 3
		x061Txt (  , aWizard , @cMsg2 , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob )
	EndIf
Else
	bProcess := { |oSelf| x061Processa( aWizard , lMultFil , aLisFil , cFilDe , cFilAte , @cMsg , oProcess , oSelf , lJob ) }
	oProcess := tNewProcess():New( "FISA061" , "FCI" , bProcess , cTxtIntro , Nil , aInfCust , , , , , .T. )
EndIf

If !lJob
	If !Empty(cMsg)
		oProcess:SaveLog(OemToAnsi(cMsg))
		cMsg := ""
	Endif
	If !Empty(cMsg2)
		oProcess:SaveLog(OemToAnsi(cMsg2))
		cMsg2 := ""
	Endif
	If !Empty(cMsg3)
		oProcess:SaveLog(OemToAnsi(cMsg3))
		cMsg3 := ""
	Endif
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} x061Load

Inicializacao da funcionalidade de importacao dos codigos da FCI

@param	oCenterPanel-> Objeto para compatibilizacao
		aWizard		-> Array com conteudo dos campos preenchidos na wizard
					   da Rotina
		cMsg3		-> Mensagem que sera apresentada no Log de Processos
		lMultFil	-> Indica se o processamento sera feito utilizando selecao
					   de filiais 
		aLisFil		-> Array com as filiais que serao processadas
		cFilDe		-> Filial Inicial
		cFilAte		-> Filial Final
		
@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061Load( oCenterPanel , aWizard , cMsg3 , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob )
Local dDataAte  := SToD(aWizard[1][2])
Local cAnoCalc  := x061RetYear( Alltrim(Str(Year(dDataAte))) , StrZero( Month(dDataAte), 2 ), 1 )
Local cMesCalc  := x061RetYear( Alltrim(Str(Year(dDataAte))) , StrZero( Month(dDataAte), 2 ), 2 )
Local cAnoWiz   := Alltrim(Str(Year(dDataAte)))
Local cMesWiz   := StrZero(Month(dDataAte), 2)

Default lJob    := .F.
Default cDirJob := ""
Default cArqJob := ""

If lJob

	x061Load2Tab( oCenterPanel , aWizard , @cMsg3 , lMultFil , aLisFil , cFilDe , cFilAte , cMesCalc , cAnoCalc, cMesWiz, cAnoWiz , lJob , cDirJob , cArqJob )

ElseIf MsgYesNo(STR0010+;			//"Esta função irá importar arquivo magnético da FCI retornado pela Sefaz "
				STR0011+;			//"após transmissão pelo Contribuinte. Os códigos retornados serão importados para utilização em "
				Mes(SToD ( cAnoCalc + cMesCalc + "01" ) ) + STR0016+Alltrim( cAnoCalc )+". "+;
				STR0012 , STR0028 )	//"Esteja certo de que o arquivo que está sendo importado é o correto. Deseja continuar?" ## "Atenção"

	Processa({||x061Load2Tab( oCenterPanel , aWizard , @cMsg3 , lMultFil , aLisFil , cFilDe , cFilAte , cMesCalc , cAnoCalc, cMesWiz, cAnoWiz )}, "Importação","Preparando ambiente para Importação..." )

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Load2Tab

Funcao responsavel pelo processo de importacao dos codigos da FCI para
os produtos retornados no arquivo da Sefaz

@param	oCenterPanel-> Objeto para compatibilizacao
		aWizard		-> Array com conteudo dos campos preenchidos na wizard
					   da Rotina
		cMsg3		-> Mensagem que sera apresentada no Log de Processos
		lMultFil	-> Indica se o processamento sera feito utilizando selecao
					   de filiais 
		aLisFil		-> Array com as filiais que serao processadas
		cFilDe		-> Filial Inicial
		cFilAte		-> Filial Final
		cMesCalc	-> Mes em que serao utilizados os codigos da FCI
		cAnoCalc	-> Ano em que serao utilizados os codigos da FCI
		
@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061Load2Tab( oCenterPanel , aWizard , cMsg3 , lMultFil , aLisFil , cFilDe , cFilAte , cMesCalc , cAnoCalc, cMesWiz, cAnoWiz, lJob, cDirJob, cArqJob )
Local aWiz2Tab   := {}
Local cReg       := ""
Local cFileRet   := ""
Local cFilePath  := ""
Local cStartPath := Nil
Local nHandle    := 0
Local cValidPerg	 := ''	

Default lJob     := .F.
Default cDirJob  := ""
Default cArqJob  := ""

If lJob
	aAdd(aWiz2Tab,{""})
	aWiz2Tab[1,1] := cDirJob+cArqJob
Else
	aWiz2Tab    := x061Wiz2File(2)

	If Len(aWiz2Tab) > 0
		cValidPerg 	:= ValidPerg(aWiz2Tab[1][1])
	Else
		cValidPerg  := STR0101 //"Rotina Cancelada."
	EndIf	
EndIf
			
If Len(aWiz2Tab) > 0 .And. Empty(cValidPerg)

	//------------------------------------------------------
	// Verifica existencia do arquivo no diretorio informado
	//------------------------------------------------------
	If File(cFileRet := Alltrim(aWiz2Tab[1][1]) )

		If lJob .Or. MsgYesNo(STR0013 + cFileRet+CRLF+CRLF+; //"Importando arquivo texto: "
					STR0014 + Mes(SToD ( cAnoCalc + cMesCalc + "01" ) ) +; //"Os códigos deste arquivo serão utilizados em "
					STR0016 + Alltrim( cAnoCalc ) + STR0015 , STR0028 )

			//---------------------------
			// Leitura do arquivo texto
			//---------------------------
			If xFunGetDir( 3 , cFileRet , , @cStartPath , @nHandle , .T. , @cFilePath )

				//------------------------------------------------------
				// Seleciona indice da tabela CFD, para importar os codigos
				//------------------------------------------------------
				CFD->(DbSetOrder(2)) //-> CFD_FILIAL+CFD_COD+CFD_PERCAL+CFD_PERVEN

				FSeek(nHandle , 0 , 0)
				FT_FUse(cStartPath+cFilePath)
				FT_FGoTop()

				While !(FT_FEof())

					//Leitura da linha do arquivo
					cReg := FT_FReadLn()

					//---------------------------------------------------------------------------------
					// Quando estiver lendo os registros 5020, faco a importacao dos codigos da FCI
					//---------------------------------------------------------------------------------
					If Substr(cReg,1,4) == "5020"

						If x061ImpCod( cReg , cMesCalc , cAnoCalc, cMesWiz, cAnoWiz )
							If !lJob
								MsgInfo(STR0019) //"Importação realizada com sucesso!"
								cMsg3 := STR0017 + cMesCalc + "/" + cAnoCalc //"Importação realizada com sucesso; Período para utilização dos códigos FCI: "
							EndIf
						Else
							If !lJob
								MsgInfo(STR0020) //"Não foram encontrados códigos para importação!"
								cMsg3 := STR0018 + cMesCalc + "/" + cAnoCalc //"Não foram encontrados códigos para importação; Período para utilização dos códigos FCI: "
							EndIf
						Endif

						//Posso abandonar while, pois os registros 5020 sao gerados em sequencia
						Exit
					Endif

					FT_FSkip()
				End

				//----------------------------
				// Libera Handle do arquivo
				//----------------------------
				xFunGetDir(2,,,,nHandle)

			Endif
		Endif
	Else
		If !lJob
			MsgInfo(STR0021 , STR0022) //"Arquivo não encontrado" ### "Erro!"
		EndIf
	Endif
Else
	If lJob
		QOut(cValidPerg + CRLF + STR0105)  //"A rotina de importação sera finalizada, para executa-la novamente, saia da rotina e redefina os parametros na rotina principal."
	Else
		MsgAlert(cValidPerg + CRLF + STR0105) //"A rotina de importação sera finalizada, para executa-la novamente, saia da rotina e redefina os parametros na rotina principal."
	EndIf		
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Txt

Inicializacao da funcionalidade de geracao do arquivo txt

@param	oCenterPanel-> Objeto para compatibilizacao
		aWizard		-> Array com conteudo dos campos preenchidos na wizard
					   da Rotina
		cMsg2		-> Mensagem que sera apresentada no Log de Processos
		lMultFil	-> Indica se o processamento sera feito utilizando selecao
					   de filiais 
		aLisFil		-> Array com as filiais que serao processadas
		cFilDe		-> Filial Inicial
		cFilAte		-> Filial Final
		
@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061Txt( oCenterPanel , aWizard , cMsg2 , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob )
Local cProdDe   := aWizard[1][3]
Local cProdAte  := aWizard[1][4]
Local dDataDe   := SToD(aWizard[1][1])
Local dDataAte  := SToD(aWizard[1][2])
Local cVersao   := aWizard[1][6]

Default lJob    := .F.
Default cDirJob := ""
Default cArqJob := ""

If lJob

	x61Reg2Txt( oCenterPanel , cProdDe , cProdAte , dDataDe , dDataAte , cVersao , @cMsg2 , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob )

ElseIf MsgYesNo(	STR0024 + CRLF + CRLF +;	//"Esta função irá gerar o arquivo magnético da FCI baseado nas informações processada na tabela CFD - Ficha de Conteúdo de Importação."
				STR0025 + CRLF + CRLF +;	//"Confirme abaixo o período base em que as informações serão processadas e, se necessário, ajuste os parâmetros da rotina."
				STR0026 + Mes(dDataDe)+ STR0016 + Alltrim(Str(Year(dDataDe))) + CRLF + CRLF +;	//"Período: " ### " de "
				STR0027, STR0028 )			//"Deseja continuar?" ## "Atenção"

	Processa({||x61Reg2Txt( oCenterPanel , cProdDe , cProdAte , dDataDe , dDataAte , cVersao , @cMsg2 , lMultFil , aLisFil , cFilDe , cFilAte )}, "Gera Txt","Preparando ambiente para Geração..." )

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg2Txt

Funcao responsavel por consultar as informacoes gravadas a partir da apuracao
e imprimi-las em um arquivo texto

@param	oCenterPanel-> Objeto para compatibilizacao
		cProdDe		-> Produto inicial selecionado no filtro
		cProdAte	-> Produto final selecionado no filtro
		dDataDe		-> Data inicial
		dDataAte	-> Data Final
		cVersao		-> Versao do layout da fci
		cMsg2		-> Mensagem que sera apresentada no Log de Processos
		lMultFil	-> Indica se o processamento sera feito utilizando selecao
					   de filiais 
		aLisFil		-> Array com as filiais que serao processadas
		cFilDe		-> Filial Inicial
		cFilAte		-> Filial Final
		
@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x61Reg2Txt( oCenterPanel , cProdDe , cProdAte , dDataDe , dDataAte , cVersao , cMsg2 , lMultFil , aLisFil , cFilDe , cFilAte , lJob , cDirJob , cArqJob )
Local aWiz2Txt   := {}
Local aReg5020   := {}
Local aAreaSM0   := SM0->(GetArea())
Local cAlsQryFD  := ""
Local cArq       := Nil
Local cStartPath := Nil
Local cPerCal    := ""
Local cPerApu    := ""
Local cB1GTIN    := aX6Content[MV_FCIGTIN]
Local nHandle    := 0
Local nTotFLin   := 0
Local nTotRg5020 := 0
Local nFilial    := 0
Local cFile      := Nil
Local bWhileSM0  := {||!SM0->(Eof ()) .And. ((!lMultFil .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) .Or. (lMultFil .And. Len(aLisFil)>0 .And. cEmpAnt==SM0->M0_CODIGO))}
Local cDataDe    := StrZero(Month(dDataDe), 2) + Alltrim(Str(Year(dDataDe)))
Local lProssegue := .F.
Local cValid	 := ''

Default lJob     := .F.
Default cDirJob  := ""
Default cArqJob  := ""

//---------------------------------------------------------------------------------------------------------
//Tratamento para validação e adequação da string com o caminho do diretório para gravação do arquivo
//---------------------------------------------------------------------------------------------------------
While !lProssegue

	If lJob
		aAdd(aWiz2Txt,{"",""})
		aWiz2Txt[1,1] := cDirJob
		aWiz2Txt[1,2] := cArqJob
	Else
		aWiz2Txt := x061Wiz2File(1)
	EndIf

	If Len(aWiz2Txt) > 0
		cValid	:= ValidPerg(aWiz2Txt[1][1])
	Else //Se saiu da rotina ou parametros de diretorio e arquivo nao foram informados portanto sai da rotina
		If lJob
			QOut(STR0101) //"Rotina Cancelada."
		Else
			Alert(STR0101) //"Rotina Cancelada."
		EndIf

		Return
	EndIf	
				
	If !Empty(cValid)
		Alert(cValid + CRLF + STR0102) //'Por favor verifique estas informações'
		lProssegue := .F.
	Else
		If Substr(Alltrim(aWiz2Txt[1][1]), Len(Alltrim(aWiz2Txt[1][1])), 1) <> "\"
			aWiz2Txt[1][1] := Alltrim(aWiz2Txt[1][1]) + "\"
		EndIf

		lProssegue := .T.
	EndIF

EndDo

//----------------------
//Periodos
//----------------------
cPerCal := x061RetYear( Alltrim(Str(Year(dDataAte))) , StrZero( Month(dDataAte), 2 ), 2 ) + x061RetYear( Alltrim(Str(Year(dDataAte))) , StrZero( Month(dDataAte), 2 ), 1 )
cPerApu := StrZero(Month(dDataDe),2) + Alltrim(Str(Year(dDataDe)))

//----------------------
// Criacao do arquivo
//----------------------
If Len(aWiz2Txt) > 0
	If Alltrim(aWiz2Txt[1][1]) != "" .AND. Alltrim(aWiz2Txt[1][2]) != ""
		cFile := Alltrim(aWiz2Txt[1][1])+Alltrim(aWiz2Txt[1][2])
	EndIf
EndIf

If cFile <> Nil .And. xFunGetDir( 1 , , @cArq , @cStartPath , @nHandle )

	DbSelectArea("SM0")
	SM0->(DbGoTop ())
	SM0->(DbSeek (cEmpAnt+cFilDe,.T.))

	//--------------------------------------------
	//Bloco de execucao, processamento de Filiais
	//--------------------------------------------
	Do While Eval(bWhileSM0)

		cFilAnt := FWGETCODFILIAL

		If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
			nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
			If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
				SM0->(dbSkip())
				Loop
			EndIf
		Else
			If lMultFil  //Somente faz skip se a opcao de selecionar filiais estiver como Sim.
				SM0->(dbSkip())
				Loop
			EndIf
		EndIf

		If lMultFil
			x061LoadCache(.F.)
		EndIf

		/*--------------------------------------------------------------------
		 Parametros para executar query:
		   [1] - "Txt" 		->	Indica que a chamada da query eh para geracao do txt
		   [2] - cPercal	->	Periodo de Calculo
		   [3] - cProdDe	->	Produto De
		   [4] - cProdAte	->	Produto Ate
		   [5] - cB1GTIN	->	Campo da tabela SB1 que preenche o codigo GTIN
		   [6] - cDataDe -> Periodo informado na wizard (sem tratamento pela x061RetYear())
		--------------------------------------------------------------------*/
		If x061GetQry( @cAlsQryFD , { "Txt" , cPerCal , cProdDe , cProdAte , cB1GTIN, cDataDe } , , "CFD" )

			x61Reg5020( cAlsQryFD , @aReg5020 , @nTotRg5020 , cB1GTIN )

		Endif

		SM0->(dbSkip())
	End

	//Restauro a area do SM0
	RestArea(aAreaSM0)
	cFilAnt := FWGETCODFILIAL

	//---------------------------------------------------------------------------------------
	// Chamada das funcoes que vao gerar e gravar os blocos no arquivo texto
	//---------------------------------------------------------------------------------------
	x061Bloco0( nHandle , {,,,cVersao} , @nTotFLin )					//-> Bloco 0: Abertura do Arquivo
	x061Bloco5( nHandle , aReg5020 , nTotRg5020 , @nTotFLin )			//-> Bloco 5: Dados da Mercadoria
	x061Bloco9( nHandle , nTotRg5020 , nTotFLin )						//-> Bloco 9: Totalizacao de Registros

	//---------------------------------------------------------------------------------------
	// Liberacao de handle e copia do arquivo para o diretorio destino
	//---------------------------------------------------------------------------------------
	If xFunGetDir( 2 , , , , nHandle )

		
		If xFunGetDir( 3 , cFile , cArq , cStartPath )
			If !lJob
				MsgInfo( STR0023 ) //"Arquivo gerado com sucesso!"
				cMsg2 := STR0029 + cPerApu + STR0030 + Alltrim(aWiz2Txt[1][2]) //"Arquivo Texto gerado; Período Apurado: " ## "; Arquivo: "
			EndIf
		Endif
	Endif

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Wiz2File

Wizard utilizada nos processos de geracao e importacao de arquivo txt

@param	nTipo	-> Tipo do processamento que esta chamando a funcao:
					1 - Geracao de arquivo
					2 - Importacao de arquivo
		
@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061Wiz2File( nTipo )
Local aFirstTxt := {}
Local aGetParam := {}
Local aWiz2File := {}
Local cNameWiz  := Iif( nTipo==1 , "FSA061AT"+FWGETCODFILIAL , "FSA061AI"+FWGETCODFILIAL )
Local cTxtEvent := Iif( nTipo==1 , "Geração" , "Importação")

//---------------------------------------------------------------------------------------
// Montagem da wizard para as opcoes de Gera Txt (opcao 1) ou Importacao (opcao 2)
//---------------------------------------------------------------------------------------

aAdd (aFirstTxt, "Rotina de "+cTxtEvent+" do Arquivo Magnético da FCI.")
aAdd (aFirstTxt, "")	
aAdd (aFirstTxt, "Preencha corretamente os campos abaixo para "+cTxtEvent+" do arquivo.")
aAdd (aFirstTxt, "Informações necessárias para a "+cTxtEvent+" do Arquivo Magnético da FCI.")

aAdd (aGetParam, {})
aAdd (aGetParam[1], "Preencha corretamente as informações solicitadas.")
aAdd (aGetParam[1], "Parâmetros para "+cTxtEvent)
aAdd (aGetParam[1], {})

If nTipo == 1

	aAdd (aGetParam[1][3], {1,"Diretório do Arquivo Destino",,,,,,})
	aAdd (aGetParam[1][3], {2,,Replicate("X",50),1,,,,50})

	aAdd (aGetParam[1][3], {0,"",,,,,,})
	aAdd (aGetParam[1][3], {0,"",,,,,,})

	aAdd (aGetParam[1][3], {1,"Nome do Arquivo Destino",,,,,,})
	aAdd (aGetParam[1][3], {2,,Replicate("X",30),1,,,,30})

Else

	aAdd(aGetParam[1][3], {1,"Arquivo de retorno:",,,,,,})
	aAdd(aGetParam[1][3], {2,,Replicate("X",250),1,,,,250,,.T.})

Endif

If xMagWizard (aFirstTxt, aGetParam, cNameWiz)
	xMagLeWiz(cNameWiz,@aWiz2File,.T.)
Endif

Return aWiz2File

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Processa

Funcao responsavel pela Apuracao da FCI

@param	aWizard		-> Array com conteudo dos campos preenchidos na wizard
					   da Rotina
		lMultFil	-> Indica se o processamento sera feito utilizando selecao
					   de filiais 
		aLisFil		-> Array com as filiais que serao processadas
		cFilDe		-> Filial Inicial
		cFilAte		-> Filial Final
		cMsg		-> Mensagem que sera apresentada no Log de Processos
		oProcess	-> Objeto responsavel pelo armazenamento do Log de processos
		oSelf		-> Objeto para compatibilizacao
		
@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061Processa( aWizard , lMultFil , aLisFil , cFilDe , cFilAte , cMsg , oProcess , oSelf , lJob )
Local cAlsQryB1	:= ""
Local cProdDe	:= aWizard[1][3]
Local cProdAte	:= aWizard[1][4]
Local dDataDe	:= SToD(aWizard[1][1])
Local dDataAte	:= SToD(aWizard[1][2])
Local nCountReg	:= 0
Local nFilial	:= 0
Local aAreaSM0	:= SM0->(GetArea ())
Local bWhileSM0	:= {||!SM0->(Eof ()) .And. ((!lMultFil .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) .Or. (lMultFil .And. Len(aLisFil)>0 .And. cEmpAnt==SM0->M0_CODIGO))}
Local cMes		:= Alltrim( StrZero( Month( dDataDe ) , 2 ) )
Local cAno		:= Alltrim( Str( Year ( dDataDe ) ) )
Local lProdBlqd := IIf(Len(aWizard[1]) >= 7, SubStr(aWizard[1][7], 1, 1) $ "1", .T.)
Local lProdFaix := IIf(Len(aWizard[1]) >= 8, SubStr(aWizard[1][8], 1, 1) $ "1", .T.)
Local lGrvReg   := .F.
Local nQtdThd   := IIf(aX6Content[MV_FCINTHD] <= 5, aX6Content[MV_FCINTHD], 5)
Local lMultiThd := nQtdThd > 1
Local cSemaphore:= "FISA061PROC"
Local aDadosINI := {}
Local nTotErro  := 0
Local aThreads  := {}
Local nGravados := 0

Default lJob := .F.

If lJob .Or. MsgYesNo( STR0031 + CRLF + CRLF +;	//"Esta função irá Processar o Conteúdo de Importação dos valores praticados no último Período de Apuração."
				STR0032 + Mes( dDataDe ) +;	//"Período que será apurado: "
				STR0016 + cAno + "." +;		//" de "
				CRLF    + CRLF +;			//	 
				STR0033 + CRLF + CRLF +;	//"Verifique no Log de Processos se este período já foi apurado. Caso clique em continuar, os dados já processados serão apagados."
				STR0062 + CRLF + CRLF +;	//"Os produtos com Código de FCI já importados não serão considerados no reprocessamento!"
				STR0027, STR0028 )			// "Deseja continuar?" ## "Atenção"
	
	/*------------------------------------------------------------------------------------------------------------
								Definicao do Metodo de Calculo do Conteudo de Importacao
	
	    O parametro MV_FCICALC define como o conteudo de importacao sera apurado. Eh um parametro numerico e
	    possui 3 opcoes:
	    
	    	1 - Media ponderada atraves do campo D3_PERIMP:
	    		-> Campo preenchido no apontamento da producao com o CI da movimentacao que esta sendo incluida
	    		-> A funcao FCIMediaP() retorna o percentual com base no Produto Acabado e Periodo informado
	    		-> Nessa situacao o controle de lote nao influencia no calculo
	    		
	    	2 - Apuracao atraves do ultimo apontamento de Producao:
	    		-> A rotina pesquisa pelo ultimo apontamente de producao (PR0) na tabela SD3 do Produto Acabado
	    		   e apura com base nas requicioes desta ordem de producao apenas.
	    		-> Esta opcao pode ser usada para os contribuintes que nao possuem variacao nos movimento de producao,
	    		   pois a rotina se torna mais rapida ja que calcula com base em apenas uma movimentacao
	    		-> Para cada requisicao do apontamento de producao, pesquisa pelos documentos de entrada da
	    		   materia prima (SD1)
	    		-> Quando utilizar controle de lote, a tabela CFD sera gerada por Produto e OP, e fara uma media
	    		   dos registros gravados, fornecendo assim um unico CI para cada produto. Existe a quebra por OP
	    		   para que o percentual seja apurado com maior precisao e para consistencia do relatorio de conferencia.
	    		   Nesta hipotese, a rotina ira se basear no ultimo apontamento de cada lote vendido, diferente de quando
	    		   nao utiliza o controle de lote onde a rotina se baseia em apenas um apontamento por produto acabado
	    		   
	    	3 - Execucao da Pre-Apuracao e Apuracao:
	    		-> A pre-apuracao eh utilizada para apurar a media ponderada de todos os apontamentos e todas as entradas
	    		   de materia prima do periodo. Ela ira registrar a media do valor importado para cada produto.
	    		-> Essa opcao grava uma tabela secundaria, que sera consultada pela Apuracao principal para calcular o 
	    		   conteudo de importacao, com base no valor da parcela importada calculado pela pre-apuracao e valor
	    		   da saida calculado pela apuracao.
	    		   
	------------------------------------------------------------------------------------------------------------*/
	If lJob
		QOut( STR0034 ) //"Preparando ambiente..."
	Else
		oSelf:IncRegua1( STR0034 ) //"Preparando ambiente..."
	EndIf
	/*------------------------------------------------------------------------------------------------------------
	|                                                                                                            |
	|                                                                                                            |
	|												Bloco de Reprocessamento                                     |
	|                                                                                                            |
	|                                                                                                            |
	------------------------------------------------------------------------------------------------------------*/
	If lJob
		QOut( STR0069 ) //"Verificando Reprocessamento..."
	Else
		oSelf:IncRegua1( STR0069 ) //"Verificando Reprocessamento..."
	EndIf
	DbSelectArea("SM0")
	SM0->(DbGoTop())
	SM0->(DbSeek(cEmpAnt+cFilDe,.T.))

	//Bloco de execucao, processamento de Filiais
	Do While Eval(bWhileSM0)

		cFilAnt := FWGETCODFILIAL

		If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
			nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
			If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
				SM0->(dbSkip())
				Loop
			EndIf
		Else
			If lMultFil  //Somente faz skip se a opcao de selecionar filiais estiver como Sim.
				SM0->(dbSkip())
				Loop
			EndIf
		EndIf

		If lMultFil
			x061LoadCache(.F.)
		EndIf

		//---------------------------------------------------------------
		//	x061ChkMov ()
		//---------------------------------------------------------------
		// Verifico se ja existe processamento neste periodo
		//---------------------------------------------------------------
		x061ChkMov( cMes , cAno , cProdDe , cProdAte )
		
		SM0->(dbSkip())
	End

	/*------------------------------------------------------------------------------------------------------------
	|                                                                                                            |
	|                                                                                                            |
	|											Bloco de Apuracao/Calculo                                        |
	|                                                                                                            |
	|                                                                                                            |
	------------------------------------------------------------------------------------------------------------*/

	//Volta ao inicio do SIGAMAT e ira processar com base nas filiais selecionadas
	SM0->(DbGoTop())
	SM0->(DbSeek(cEmpAnt+cFilDe, .T.))

	If lMultiThd
		ConOut("")
		ConOut("*** FISA061 - MultiThread Ativo ***")	
		ConOut("")
		ConOut("Inicio de Processamento: " + Time())
		ConOut("")
	EndIf

	PutGlbVars("FCIGRAVADOS", 0)

	//Bloco de execucao, processamento de Filiais
	Do While Eval(bWhileSM0)

		cFilAnt := FWGETCODFILIAL
		nTotErro := 0
		nIPCGO := 0

		If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
			nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
			If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
				SM0->(dbSkip())
				Loop
			EndIf
		Else
			If lMultFil  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
				SM0->(dbSkip())
				Loop
			EndIf
		EndIf

		If lMultFil
			x061LoadCache(.F.)
		EndIf

		// Se for processamento em multi-thread, inicializo as threads e as deixo em espera.
		If lMultiThd

			ConOut(STR0088) // "Inicializando Threads..."

			aThreads := x061IniThd(cSemaphore,nQtdThd)

			If Empty(aThreads)
				If lJob
					QOut(STR0090+PULALINHA+STR0091) //"Uma ou mais threads nao puderam ser inicializadas."###"O Processamento sera interrompido."
				Else
					MsgAlert(STR0090+PULALINHA+STR0091) //"Uma ou mais threads nao puderam ser inicializadas."###"O Processamento sera interrompido."
				EndIf
				x061EndThd(cSemaphore, aThreads, @nTotErro)
				Exit
			EndIf

			ConOut(STR0089) // "Threads inicializadas."
		EndIf

		ConOut("")

		/*------------------------------------------------------------------------------------------------------------
		|										Funcao de Pre-Apuracao (Metodo 3)                                 	 |
		------------------------------------------------------------------------------------------------------------*/
		ConOut("Pre-apuracao - INICIO: " + Time())
		If aX6Content[MV_FCICALC] == 3
			If lJob
				QOut( STR0068 ) //"Executando Pré-Apuração (Tabela SA8)..."
			Else
				oSelf:IncRegua1( STR0068 ) //"Executando Pré-Apuração (Tabela SA8)..."
			EndIf
			FciMatCalc( cMes , cAno , cProdDe , cProdAte )
		Endif
		ConOut("Pre-apuracao - FIM: " + Time())

		If lMultiThd
			ConOut("")
			ConOut("INICIO (MT) - Filial: " + AllTrim(SM0->M0_CODFIL) + " - " + AllTrim(SM0->M0_FILIAL) + " - " + Time())
			ConOut("")
		EndIf

		//---------------------------------------------------------------
		//
		// Executa query procurando por movimentacao de saida enquadrada
		// nas Regras da FCI (Contador para Regua)
		//
		//---------------------------------------------------------------

		If x061GetQry( @cAlsQryB1 , { cProdDe , cProdAte , DToS(dDataAte), aX3FieldP[FP_BZ_FCIPRV], lProdBlqd } , @nCountReg , "INI" )
			If !lJob
				oSelf:SetRegua1( nCountReg )
			EndIf
			If Select( cAlsQryB1 ) <> 0
				( cAlsQryB1 )->( DbCloseArea () )
			Endif
		Endif

		/*-----------------------------------------------------------------------------------------------------

		 Executo query na tabela SB1, pesquisando a ultima venda dos produtos que foram selecionados
		 no range dos filtros da rotina: Produto De/Ate
		
		 Segundo as regras do Convenio 38/2013:
		  - Calcula utilizando os valores do penultimo periodo de apuracao
		  - No caso de nao encontrar saidais interestaduais no penultimo periodo, devo considerar
		    saidas internas
		  - No caso de nao possuir saidais interestaduais ou internas no penultimo periodo, devo
		    procurar pelo ultimo periodo em que houve movimentacao de saida
		
		 Considerando as regras acima, apos obter a ultima venda de cada produto, apuro os valores e 
		 quantidades vendidos no periodo de cada produto, calculando assim a media ponderada das saidas
		
		-----------------------------------------------------------------------------------------------------*/
		
		If x061GetQry( @cAlsQryB1 , { cProdDe , cProdAte , DToS(dDataAte), aX3FieldP[FP_BZ_FCIPRV], lProdBlqd } , , "INI" )
		    
		    // ----------------------------------------
			// INI - 1
			// Inicio do Laco da Query inicial "INI"
			// --------------------------------------->>
			
			/*-------------------------------------------------------------------------------------
			 Componentizado o trecho de código responsavel pelo calculo do CI para
			 poder fazer a execucao com multithread. Este trecho virou a funcao x061PrFCI,
			 executada com ou sem multi-thread ativo. 
			 A diferenca eh que, com multithread, ela sera chamada mais de uma vez ao mesmo tempo.
			 -------------------------------------------------------------------------------------*/
			
			Begin Transaction
			
				While !(cAlsQryB1)->(Eof())

					If Empty(aDadosINI) .Or. aDadosINI[INI_CODPRO] <> (cAlsQryB1)->(B1_COD)

						/*---------------------------------------------------------------------------
							O array aDadosINI deve SEMPRE conter todos os campos que a query
						   "INI" retornar, independente de ser multithread ou nao, pois a funcao
						   x061PrFCI nao pode receber o alias cAlsQryB1. Desta forma, carrego no
						   array os dados que estariam no Alias.
						   
						   *** ATENCAO PARA OS DEFINES DESTE ARRAY NO INICIO DO FONTE !!!! ***						   
						---------------------------------------------------------------------------*/ 

						aDadosINI := {}

						aAdd(aDadosINI, (cAlsQryB1)->( B1_COD ))  //01 - Codigo do Produto
						aAdd(aDadosINI, (cAlsQryB1)->( B1_DESC )) //02 - Descricao do Produto

						// O parametro MV_FCIPRV define qual a origem do valor estimado de venda (SB1 ou SB5)

						If aX6Content[MV_FCIPRV] == 1
							aAdd(aDadosINI, (cAlsQryB1)->B1_PRV1)   //03 - Valor Estimado de Venda
						Elseif aX6Content[MV_FCIPRV] == 2
							aAdd(aDadosINI, (cAlsQryB1)->B5_FCIPRV) //03 - Valor Estimado de Venda
						Elseif aX6Content[MV_FCIPRV] == 3
							aAdd(aDadosINI, (cAlsQryB1)->BZ_FCIPRV) //03 - Valor Estimado de Venda
						Endif

						aAdd(aDadosINI, (cAlsQryB1)->D2_EMISSAO)   //04 - Dt. de Emissao da Ultima Venda
						aAdd(aDadosINI, lProdFaix)                 //05 - Usa Cod.FCI anterior mesma faixa

						/* ---------------------------------------------------------------------------------
		   				  Neste momento verifico se o registro deste produto para o periodo nao foi apagado
		   				  devido ao fato de ja possuir codigo de fci importado.

		   				  Nesse caso a funcao x061ChkMov() nao exclui os registros da tabela CFD e ao
		   				  tentar gravar o produto ocorreria erro de chave duplicada.
		 				 ---------------------------------------------------------------------------------*/

						If CFD->(MsSeek(xFilial("CFD") + aDadosINI[INI_CODPRO] + x061RetYear(cAno, cMes, 2) + x061RetYear(cAno, cMes, 1)))
							(cAlsQryB1)->(DbSkip())
							Loop
						Endif
					EndIf
					If lJob
						QOut(STR0035 + Alltrim( aDadosINI[INI_DESCPRO] ) + STR0036 + Alltrim( SM0->M0_FILIAL ) ) //"Calculando Produto: "###//" para a Filial: "
					Else
						oSelf:IncRegua1(STR0035 + Alltrim( aDadosINI[INI_DESCPRO] ) + STR0036 + Alltrim( SM0->M0_FILIAL ) ) //"Calculando Produto: "###//" para a Filial: "
					EndIf
					If lMultiThd

						/*---------------------------------------------------------------------------------------
						  Verifico se ha alguma thread disponivel (Status 1) para fazer a chamada de IPCGO.
						  A chamada de IPCGO executa a funcao x061PrFCI para o produto atual. Se a chamada
						  for bem sucedida, rodo o alias para o proximo produto.
						  Se a chamada de IPCGO nao for bem sucedida ocorreu algum erro (nTotErro > 0), ou 
						  nao existe nenhuma thread disponivel no momento. Se ocorreu algum erro, o processamento
						  sera abortado. Caso contrario, aguarda 1s e verifica novamente se alguma thread 
						  finalizou seu processamento e está aguardando uma chamada. 
						 ---------------------------------------------------------------------------------------*/

						If IpcCount(cSemaphore) > 0 .And. x061ChkThd(aThreads, @nTotErro) > 0
							If IPCGo(cSemaphore, "PROC", aDadosINI, dDataDe, dDataAte)
								( cAlsQryB1 )->( DbSkip () )
							EndIf
						Else
							If nTotErro > 0 // Se alguma thread deu erro, abortar processamento.
								Exit
							Else
								Sleep(1000) // Caso contrario, aguardar 1s p/ tentar novamente pois todas as threads estao processando. 
							EndIf
						EndIf
					Else
						If x061PrFCI(aDadosINI, dDataDe, dDataAte, lJob)
							nGravados++
						EndIf
						( cAlsQryB1 )->( DbSkip () )
					EndIf
				
				EndDo

				// ----------------------------------------
				// FIM - 1
				// Fim do Laco da Query inicial "INI"
				// --------------------------------------->>

				/*------------------------------------------------------------------------------------------
				 Apos o fim do laco da query INI, verifico se todas as threads finalizaram seu processamento
				 e faco a chamada de IPCGO com "EXIT" (x061EndThd). Neste momento tambem verifico se alguma
				 thread esta com status de erro (3) e, caso esteja, informa que ocorreu algum erro.
				 ------------------------------------------------------------------------------------------*/

				If lMultiThd

					nTotErro := 0
					x061EndThd(cSemaphore, aThreads, @nTotErro)

					If nTotErro == 0
						ConOut("")
						ConOut("FIM (MT) - Filial: " + AllTrim(SM0->M0_CODFIL) + " - " + AllTrim(SM0->M0_FILIAL) + " - " + Time())	
					ElseIf lJob
						QOut(STR0085+STR0086+STR0087+aDadosINI[INI_CODPRO]+aDadosINI[INI_DESCPRO])
					Else
						MsgAlert(STR0085	+; // "Ocorreram erros no processamento." 
						PULALINHA+PULALINHA	+;
						STR0086  			+; // "Por favor acione o suporte TOTVS em posse dos arquivos de LOG." 
						STR0087  			+; // "Ultimo produto processado: "
						aDadosINI[INI_CODPRO]+aDadosINI[INI_DESCPRO])
					EndIf

				EndIf

				If Select( cAlsQryB1 ) <> 0
					( cAlsQryB1 )->( DbCloseArea () )
				Endif

			End Transaction

		Endif

		SM0->(dbSkip())
	End

	If lMultiThd
		ConOut("")
		ConOut("Fim de Processamento: " + Time())

		GetGlbVars("FCIGRAVADOS", @nGravados)
		ClearGlbValue("FCIGRAVADOS")
	EndIf

	lGrvReg := nGravados > 0

	//------------------------------------------------------
	// Mensagem que sera gravada no log de processamentos
	// Registro da tabela SXU vinculado ao codigo da rotina
	//------------------------------------------------------
	If lGrvReg
		cMsg	:=	STR0037+StrZero(Val(cMes),2) + "/" + cAno	//"Registros Processados; Período Apurado: "
		If lJob
			QOut(STR0038) //"Registros processados com sucesso!"
		Else
			MsgInfo(STR0038) //"Registros processados com sucesso!"
		EndIf
	Else
		cMsg	:=	STR0039+StrZero(Val(cMes),2) + "/" + cAno	//"Não foram encontrados registros para o Período: "
		If lJob
			QOut(STR0041) //"Não foram encontrados registros para os parametros informados!"
		Else
			MsgAlert(STR0041) //"Não foram encontrados registros para os parametros informados!"
		EndIf
	Endif
	
Endif

//Restauro a area do SM0
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} x061OrdArr

Ordena, consolida e calcula a media para os produtos que estao sendo apurados

@param	aInfFPrd	-> Array com as informacoes que foram apuradas para
					   determinado produto
		cMes		-> Mes de Apuracao
		cAno		-> Ano de Apuracao
		lGravouCFD	-> Flag para indicar se houve manipulacao da tabela CFD
		
@return Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061OrdArr( aInfFPrd, cMes, cAno, lGravouCFD, lNewProd, lJob, lProdFaix )
Local nCI		:= 0
Local cChave	:= ""
Local nVlParIm	:= 0
Local nVlMSaida	:= 0
Local nX		:= 0
Local nY		:= 0
Local aArr2Tab	:= {}

Default lNewProd	:= .F.
Default lJob		:= .F.
Default lProdFaix	:= .F.

//------------------------------
//  Ordena o array
//------------------------------
aSort( aInfFPrd , , , { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+x[3]  } )
//------------------------------
//  Indico finalizacao do array
//------------------------------
aAdd( aInfFPrd, { "FINALIZA" , "FINALIZA" } )

/*-----------------------------------------------------------------------------------------------------------------
 Laco no array aInfFPrd -> este array possui o detalhe de cada linha retornada na query das vendas, quebrando 
  por Produto (Media Pond.) ou Produto+Lote+SubLote (Rastro).

 A chave que foi utilizada na funcao x061Processa eh Filial+Produto+OP, portanto essa chave nao ira se repetir 
  na tabela CFD, porem podemos ter mais de um registro por Filial+Produto, que devera gerar apenas um 5020 no arquivo texto.

 O laco eh utilizado para calcular uma media dos valores apurados em cada linha do array, dessa forma poderei informar
  os valores unitarios e o Conteudo de importacao com maior precisao.
-----------------------------------------------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// cChave recebe conteudo do primeiro elemento, para que nao fure o fluxo
//-----------------------------------------------------------------------------
cChave	:=	aInfFPrd[1][1]+aInfFPrd[1][2]

For nX := 1 To Len( aInfFPrd )

	//-------------------------------------------------------------------------------------------
	// Verifico se ainda estou processando a mesma chave Filial+Produto, pois ainda que repetir
	//  esta chave na tabela CFD, os valores deverao ser os mesmos na impressao do txt
	//-------------------------------------------------------------------------------------------
	If aInfFPrd[nX][1]+aInfFPrd[nX][2] <> cChave
	    
	    //---------------------------------------------------------------------------------------------------
		// Se estiver tratando de outra chave Filial+Produto, faco o calculo para os valores unitarios
		//  utilizando as variaveis totalizadoras nVlParIm para Parcela Importada e nVlMSaida para Saidas
		//  interestaduais. Divido as variaveis por nY, que eh um contador de ponderacao
		//---------------------------------------------------------------------------------------------------
		nVlParIm	:=	Round( nVlParIm / nY , 2 )
		nVlMSaida	:=	Round( nVlMSaida / nY , 2 )
		nCI			:=	Round( ( nVlParIm / nVlMSaida ) * 100 , 2 )
			
	    //---------------------------------------------------------------------------------------------------
		// Com os valores unitarios e o Conteudo de Importacao em maos, utilizo o array aArr2Tab que
		//  guardou as linhas que serao geradas na tabela CFD e junto com os valores gravo as informacoes
		//  na tabela da FCI
		//---------------------------------------------------------------------------------------------------
		lGravouCFD := x061GrvCFD( aArr2Tab , cMes , cAno , nVlParIm , nVlMSaida , nCI, lNewProd, lJob, lProdFaix )

		//-----------------------------------------------------------------------------
		// Reseto as variaveis para inicializar calculo de outra chave Filial+Produto
		//-----------------------------------------------------------------------------
		nVlParIm	:=	0
		nVlMSaida	:=	0
		nCI			:=	0
		nY			:=	0
		aArr2Tab	:=	{}
		
	Endif
	
	If aInfFPrd[nX][1] <> "FINALIZA"
	
		nVlParIm	+=	aInfFPrd[nX][4]
		nVlMSaida	+=	aInfFPrd[nX][5]
		nY			+=	aInfFPrd[nX][6]
		
		aAdd( aArr2Tab, {	aInfFPrd[nX][1],;
							aInfFPrd[nX][2],;
							aInfFPrd[nX][3]	,;
							aInfFPrd[nX][7]}	)
							
		
		cChave	:=	aInfFPrd[nX][1]+aInfFPrd[nX][2]
	Endif
	
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061GrvCFD

Realiza a gravacao na tabela CFD

@param	aArr2Tab	-> Array consolidado com informacoes para gravacao na tabela
					   CFD
		cMes		-> Mes de Apuracao
		cAno		-> Ano de Apuracao
		nVlParIm	-> Valor calculado da Parcela Importada
		nVlMSaida	-> Valor calculado das Saidas
		nCI			-> Percentual do Conteudo de Importacao calculado
		
@return lRet	-> Indica se houve gravacao na tabela CFD

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061GrvCFD( aArr2Tab , cMes , cAno , nVlParIm , nVlMSaida , nCI, lNewProd, lJob, lProdFaix )
Local nX		:= 0
Local cFciCod	:= ""
Local cAnoCalc	:= ""
Local cPerVen	:= ""
Local cOrigem	:= ""
Local lAchouCFD	:= .F.
Local lRet		:= .F.
Local aInfHist	:= {}
Local lUsaHist	:= .F.
Local aCFDRegs	:= {}
Local msg		:= " "
Local nMes		:= 0
Local nAno		:= 0
Local nPos1		:= 0
Local nPos2		:= 0

Default	lNewProd := .F.
Default lJob     := .F.
Default lProdFaix:= .F.

//-------------------------------------------------------------
//  Caso esteja processando Dezembro, atualizo ano posterior
//-------------------------------------------------------------
cAnoCalc := x061RetYear(cAno, cMes, 1)
cMesCalc := x061RetYear(cAno, cMes, 2)
cPerVen  := If(cMes <> "12", StrZero(Val(cMes) + 1 ,2) + cAno, "01"+ Soma1(cAno)) // Acrescento 1 pois a validacao eh feita com base no penultimo periodo

// --------------------------------------------------------------------------------------------
//A funcao CIxOrigem retorna o codigo da origem conforme o Conteudo de Importacao informado
// --------------------------------------------------------------------------------------------
cOrigem := CIxOrigem( nCI )

//-------------------------------------------------------------
//  Verifico se este produto ja foi processado em outro periodo
//-------------------------------------------------------------
If CFD->(MsSeek(aArr2Tab[1][1] + aArr2Tab[1][2]))
	While !CFD->(Eof()) .And. aArr2Tab[1][2] == CFD->CFD_COD
		/*---------------------------------------------------------------------------------
		  Procuro o ultimo periodo anterior (ou atual) em que o produto foi processado.
		
		  A tabela neste momento esta ordenada por Produto + Periodo
		  
		  Enquanto o periodo do processamento for maior que o registro posicionado,
		  continuo procurando por novos registros.
		  
		  Guardo as informacoes do ultimo registro encontrado no array aInfHist, e no caso
		  de nao possuir alteracao no CI que implique em alteracao da aliquota, utilizo
		  as informacoes do historico para gravar o registro na tabela CFD
		---------------------------------------------------------------------------------*/
		If (SubStr(cPerVen,3,6)+ SubStr(cPerVen,1,2)) >= (SubStr(CFD->CFD_PERCAL,3,6)+ SubStr(CFD->CFD_PERCAL,1,2)) .AND.  nAno <= Val(Substr(CFD->CFD_PERCAL,3,4)) .AND. nMes	<=  Val(Substr(CFD->CFD_PERCAL,1,2))
			aAdd(aInfHist,{ 0 , 0 , 0 , "" , "" })
			nPos1 := Len(aInfHist)
			aInfHist[nPos1,1] := CFD->CFD_CONIMP
			aInfHist[nPos1,2] := CFD->CFD_VPARIM
			aInfHist[nPos1,3] := CFD->CFD_VSAIIE
			aInfHist[nPos1,4] := CFD->CFD_FCICOD
			aInfHist[nPos1,5] := CFD->CFD_ORIGEM
			nMes		:= Val(Substr(CFD->CFD_PERCAL,1,2))
			nAno		:= Val(Substr(CFD->CFD_PERCAL,3,4))
			lAchouCFD	:= .T.
			If cOrigem == aInfHist[nPos1,5] .And. !Empty(aInfHist[nPos1,4]) 
				nPos2 := nPos1
			EndIf
		Endif
		CFD->(DbSkip())
	End
Endif

/* --------------------------------------------------------------------------------------------
 No caso de encontrar o produto processado em periodos anteriores, verifico se houve alteracao
 na origem que implique em alteracao da aliquota no faturamento

 Caso o percentual alterado nao implique em alteracao na aliquota, mantenho as informacoes ja
 apuradas no periodo anterior.
 --------------------------------------------------------------------------------------------*/
 
// Adicionado tratamento p/ identificar alteracao de faixa 40% < CI <= 70% (origem 3) p/ CI > 70% (origens 1 e 8) e oposto.
If lAchouCFD
	lUsaHist :=	!(	( cOrigem $ "0|5"   .And. aInfHist[nPos1,5] $ "1|3|8") .Or.;
					( cOrigem $ "1|3|8" .And. aInfHist[nPos1,5] $ "0|5"  ) .Or.;
					( cOrigem $ "1|8"   .And. aInfHist[nPos1,5] $ "3"    ) .Or.;
					( cOrigem $ "3"     .And. aInfHist[nPos1,5] $ "1|8"  ) )

	// Ocorreu alteracao de faixa:
	// Se num momento futuro o bem ou mercadoria voltar a ter a mesma faixa de Conteúdo de Importação de uma FCI anteriormente transmitida,
	// o contribuinte industrializador poderá utilizar o número de controle da mesma, pois a entrega de nova FCI para um mesmo produto não substitui a anteriormente apresentada. 
	If lProdFaix .And. !lUsaHist .And. nPos2 > 0
		lUsaHist := .T.
		nPos1 := nPos2
	EndIf

	If lUsaHist
		nCI       := aInfHist[nPos1,1]
		nVlParIm  := aInfHist[nPos1,2]
		nVlMSaida := aInfHist[nPos1,3]
		cFciCod   := Upper(aInfHist[nPos1,4])
		cOrigem   := aInfHist[nPos1,5]
	EndIf
Endif

For nX := 1 To Len( aArr2Tab )
	CFD->(DbSetOrder(2)) //CFD_FILIAL+CFD_COD+CFD_PERCAL+CFD_PERVEN
	If  CFD->(MsSeek(xFilial("CFD") + aArr2Tab[nX][2]+(cMes + cAno))) .And. lNewProd
		Loop
	Else
		//tratamento para não estourar o CFD_CONIMP
		If Len(AllTrim(str(ROUND(nCI,2))))>6
			AADD(aCFDRegs,aArr2Tab[nX][1])
			AADD(aCFDRegs,iif(lNewProd,cMes+cAno,cMesCalc+cAnoCalc))
			AADD(aCFDRegs,cMes + cAno)
			AADD(aCFDRegs,aArr2Tab[nX][2])
			AADD(aCFDRegs,aArr2Tab[nX][3])
			AADD(aCFDRegs,aArr2Tab[nX][4])
			AADD(aCFDRegs,nVlParIm)
			AADD(aCFDRegs,nVlMSaida)
			AADD(aCFDRegs,nCI)
			AADD(aCFDRegs,cFciCod)
			AADD(aCFDRegs,cOrigem)
			msg  = STR0074 + Chr(13) + Chr(10) +"'"
			msg += "CFD_FILIAL = '" + aCFDRegs[1]+ Chr(13) + Chr(10) +"'"
			msg += "CFD_PERCAL = '" + aCFDRegs[2]+ Chr(13) + Chr(10) +"'"
			msg += "CFD_PERVEN = '" + aCFDRegs[3]+ Chr(13) + Chr(10) +"'"
			msg += "CFD_COD    = '" + aCFDRegs[4]+ Chr(13) + Chr(10) +"'"
			msg += "CFD_OP     = '" + aCFDRegs[5]+ Chr(13) + Chr(10) +"'"
			msg += "CFD_FILOP  = '" + aCFDRegs[6]+ Chr(13) + Chr(10) +"'"
			msg += "CFD_VPARIM = '" + str(aCFDRegs[7])+ Chr(13) + Chr(10) +"'"
			msg += "CFD_VSAIIE = '" + str(aCFDRegs[8])+ Chr(13) + Chr(10) +"'"
			msg += "CFD_CONIMP = '" + str(aCFDRegs[9])+ Chr(13) + Chr(10) +"'"
			msg += "CFD_FCICOD = '" + aCFDRegs[10]+ Chr(13) + Chr(10) +"'"
			msg += "CFD_ORIGEM = '" + aCFDRegs[11]+ Chr(13) + Chr(10) +"'"
			msg += STR0075 + Chr(13) + Chr(10) +"'"
			msg += STR0076
			If lJob
				QOut(msg)
			Else
				MsgAlert(msg)
			EndIf
			msg := ""
		Else
			//------------------------------
			//  Gravacao da tabela CFD
			//------------------------------
			RecLock("CFD",.T.)
			CFD->CFD_FILIAL	:= aArr2Tab[nX][1]
			CFD->CFD_PERCAL	:= IIF(lNewProd,cMes + cAno,cMesCalc + cAnoCalc)
			CFD->CFD_PERVEN	:= cMes + cAno
			CFD->CFD_COD	:= aArr2Tab[nX][2]
			CFD->CFD_OP		:= aArr2Tab[nX][3]
			CFD->CFD_FILOP	:= aArr2Tab[nX][4]
			CFD->CFD_VPARIM	:= nVlParIm
			CFD->CFD_VSAIIE	:= nVlMSaida
			CFD->CFD_CONIMP	:= ROUND(nCI,2)
			CFD->CFD_FCICOD	:= cFciCod
			CFD->CFD_ORIGEM	:= cOrigem
			MsUnLock()
		EndIf
		lRet := .T.
	EndIf
Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x061WhlD3

Funcao responsavel pela apuracao da Parcela Importada do produto

@param	cCodProd	-> Codigo do produto
		dDtEmis		-> Data de emissao do Documento de Saida
		cOrdProd	-> Ordem de Producao
		cNumLote	-> Lote
		cLoteCtl	-> SubLote 
		cFilOrig	-> Filial Origem (quando transferencia)
		cFilOp		-> Filial da Ordem de Producao (quando transferencia entre
					   filiais ou armazem)
		aPesquisa	-> Array utilizado para controle de recursividade
		cTpProd		-> Tipo do Produto
		
@return nMpParcIm	-> Valor da Parcela Importada

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//------------------------------------------------------------------- 
Static Function x061WhlD3( cCodProd , dDtEmis , cOrdProd , cNumLote , cLoteCtl , cFilOrig , cFilOp , aPesquisa , cTpProd, aNFEntrada )
Local aArea      := GetArea()
Local aParQry    := {}
Local nMpParcIm  := 0
Local nMpParcIm2 := 0
Local nPR0_Quant  := 0
Local cAlsQryPR0 := ""
Local cAlsQryRE1 := ""
Local cAlsQryD1  := ""
Local cPR0_Data  := ""
Local cPR0_Op    := ""
Local cPR0_Cod   := ""
Local cPR0_Fil   := ""
Local cNumLoteRE1:= ""
Local cLoteCtlRE1:= ""
Local cPRO_Numseq:= ""
Local nPosaNfEnt := 0

Default	cFilOrig  := Nil
Default	cFilOp    := ""
Default aPesquisa := {}
Default cTpProd   := ""
Default aNFEntrada:= {}

/*-------------------------------------------------------------------------------
   Pesquiso uma OP de Produto (Producao PR0)
   Se o retorno for Nil, significa que se trata de uma MP e posso buscar
   a entrada deste produto (SD1) e usar para calculo da parcela de importacao
  
   Se encontrar OP deste produto, significa que se trata de uma producao da
   empresa. Neste Caso devo usar a funcao de forma recursiva, sempre consultando
   novamente pelos itens RE1 para compor a base de calculo.
  -------------------------------------------------------------------------------*/
aParQry	:=	{ cCodProd , DToS(dDtEmis), cNumLote, cLoteCtl , cFilOrig }

If x061GetQry( @cAlsQryPR0 , aParQry , , "PRD" )

	// --------------------------------------------------------------------
	// Utilizo a variavel aPesquisa para controlar a recursividade da funcao
	// e nao utilizar repetidamente o mesmo produto, evitando uma
	// recursividade infinita
	// --------------------------------------------------------------------
	If aScan(aPesquisa, {|x|x[1]==cCodProd .And. x[2]==DToS(dDtEmis) })>0
	
		If Select(cAlsQryPR0) > 0
			(cAlsQryPR0)->(DbCloseArea())
		Endif
	
		RestArea(aArea)
		Return nMpParcIm
	Else
		Aadd(aPesquisa, {cCodProd,DToS(dDtEmis)})
	EndIf

	cPR0_Fil	:= (cAlsQryPR0)->D3_FILIAL
	cPR0_Data	:= (cAlsQryPR0)->D3_EMISSAO
	cPR0_Op		:= (cAlsQryPR0)->D3_OP
	cPR0_Cod	:= (cAlsQryPR0)->D3_COD
	nPR0_Quant	:= (cAlsQryPR0)->D3_QUANT
	cPRO_Numseq	:= (cAlsQryPR0)->D3_NUMSEQ
	
	//-----------------------------------------------------------------------------------
	// Fecha area da Query para que nao existam muitas areas abertas, evitando
	// um consumo muito grande de areas/memoria. Todas as informacoes necessarias foram
	// guardadas nas variaveis acima
	//-----------------------------------------------------------------------------------
	If Select(cAlsQryPR0) > 0
		(cAlsQryPR0)->(DbCloseArea())
	Endif
    
	//----------------------------------------------------------------
	//  Procuro pelos produtos utilizados na producao retornada acima
	//  Retornar os registros RE1 vinculados a OP do PR0
	//----------------------------------------------------------------
	If x061GetQry( @cAlsQryRE1 , { cPR0_Data , cPR0_Op , cFilOrig ,cPRO_Numseq } , , "MPR")
            
    	While !(cAlsQryRE1)->(Eof())
    		
    		//----------------------------------------------------------------------------------------
			// 							Para ambiente com Rastreabilidade !
			// Se a producao utilizou controle de lote, devo pesquisar os lotes utilizados pelas MP's
			//  fazendo uma consulta na tabela SD5, utilizando a OP da producao e o Lote da producao
			//----------------------------------------------------------------------------------------
			If SB1->( MsSeek( Iif( cFilOrig <> Nil , cFilOrig , xFilial("SB1") ) +(cAlsQryRE1)->D3_COD ) )
				If SB1->B1_RASTRO $ "SL"
					x061LoteRE1( cPR0_Op , (cAlsQryRE1)->D3_COD , cPR0_Data , @cNumLoteRE1 , @cLoteCtlRE1 , cFilOrig , SB1->B1_RASTRO )
	    		Endif
			Endif
            
			//----------------------------------------------------------------------
			// Antes de buscar a NF da MP, eh feita uma chamada recursiva desta 
			// funcao, afim de apurar se a potencial MP nao eh, na verdade, um
			// produto intermediario. Se for o caso, o valor utilizado na ponderacao
			// eh exatamente o retorno desta funcao
			//----------------------------------------------------------------------
			(cAlsQryRE1)->(nMpParcIm2 := x061WhlD3( D3_COD , SToD(D3_EMISSAO) , D3_OP , cNumLoteRE1 , cLoteCtlRE1 , cFilOrig , , aPesquisa))

			//-----------------------------------------------------------
			//Ponderando Parcela Importada com a quantidade de MP usada
			//-----------------------------------------------------------
			nMpParcIm += nMpParcIm2*(cAlsQryRE1)->D3_QUANT

			(cAlsQryRE1)->(DbSkip())
		End
		
		//-----------------------
		// Fecha area da Query
		//-----------------------
		If Select(cAlsQryRE1) > 0
			(cAlsQryRE1)->(DbCloseArea())
		Endif
        
        //----------------------------------------------------------------------------------
		// Calculo para a parcela de importacao unitaria (Base Total / Quantidade produzida)
		//----------------------------------------------------------------------------------
		nMpParcIm /= nPR0_Quant
		
	EndIf
	
	//-----------------------
	// Fecha area da Query
	//-----------------------
	If Select(cAlsQryRE1) > 0
		(cAlsQryRE1)->(DbCloseArea())
	Endif

Else

	//------------------------------------
	//    Fecha area da Query
	//------------------------------------
	If Select(cAlsQryPR0) > 0
		(cAlsQryPR0)->(DbCloseArea())
	Endif
	
	//--------------------------------------------------------------------------------------------
	// Abaixo uma pesquisa eh feita para  buscar a NF de entrada
	// Retorna a quantidade de entrada e o valor da Mercadoria + Frete + Seguro (Convenio 38/2013)
	//   ou
	// Identificador que se trata de um produto transferido entre filiais
	//--------------------------------------------------------------------------------------------
	aParQry	:=	{ cCodProd , DToS(dDtEmis) , cNumLote , cLoteCtl , cFilOrig }
	
	If x061GetQry( @cAlsQryD1 , aParQry , , "ENT")
	    
	    //-------------------------------------
		//Indica uma transferencia de filiais
		//-------------------------------------
		If !Empty((cAlsQryD1)->(F1_FILORIG+F1_CLIORI+F1_LOJAORI)) .And. !(cAlsQryD1)->(Eof())
			
			// Se for uma transferencia e a entrada ja foi processada, nao posso processar novamente pois a recursividade será infinita.
			If aScan( aNFEntrada, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == ( cAlsQryD1 )->F1_FILORIG + ( cAlsQryD1 )->F1_DOC    +;
																			( cAlsQryD1 )->F1_SERIE   + ( cAlsQryD1 )->F1_CLIORI +; 
																			( cAlsQryD1 )->F1_LOJAORI} ) > 0
																																			
				( cAlsQryD1 )->( dbSkip() )				
			Else	
				aAdd(aNFEntrada, {})
				
				nPosaNfEnt := Len(aNFEntrada)
				
				aAdd( aNFEntrada[nPosaNfEnt],( cAlsQryD1 )->F1_FILORIG )
				aAdd( aNFEntrada[nPosaNfEnt],( cAlsQryD1 )->F1_DOC )
				aAdd( aNFEntrada[nPosaNfEnt],( cAlsQryD1 )->F1_SERIE )
				aAdd( aNFEntrada[nPosaNfEnt],( cAlsQryD1 )->F1_CLIORI )
				aAdd( aNFEntrada[nPosaNfEnt],( cAlsQryD1 )->F1_LOJAORI )
				
				nMpParcIm	:=	x61ChkTFil( cAlsQryD1 , @cPR0_Op , @cPR0_Fil , aPesquisa , cTpProd, aNFEntrada)	
			EndIf
		
		//-----------------------------------------
		// Calcula Parcela de Importacao Unitaria
		//
		// Quando estiver processando o registro do Produto Acabado nao devo buscar pela entrada, evitando
		// assim fazer um calculo de produto revendido
		//-----------------------------------------
		Elseif (cAlsQryD1)->D1_CLASFIS $ aX6Content[MV_FCICL] .And. cTpProd <> "PA"
		    
			// ------------------------------------------------------------------------------
			// Quando utilizar o campo D1_CONIMP, devo utilizar as regras do Convenio 38/2013
			// para fazer os calculos da Parcela Importada.
			// ------------------------------------------------------------------------------
			If (cAlsQryD1)->D1_CONIMP > 0
		    
				/* ------------------------------------------------------------------
				                         CONVENIO 38/2013                            
				   ------------------------------------------------------------------
				   Origem "1" -> Mercadoria importada diretamente (exterior)
				     - 100% importada
				
				   Origem diferente de "1" -> Adquirida no mercado interno (nacional)
				     - Devo procurar o Conteudo de Importacao atraves do documento
				       de entrada e definir o percentual conforme regras:
				        - Conteudo de Importacao ate 40% -> Considerar nacional
				        - Conteudo de Importacao entre 40% e 70% -> 50% importado
				        - Conteudo de Importacao acima de 70% -> 100% importado
				   ------------------------------------------------------------------*/
				
				// --------------------------------------------
				// Origem 1 ou Conteudo de Importacao > 70%
				//  - 100% importado
				// --------------------------------------------
				If SubStr((cAlsQryD1)->D1_CLASFIS, 1, 1) == "1" .Or. (cAlsQryD1)->D1_CONIMP > 70
				
					nMpParcIm	:=	x61ChkMpD1(cAlsQryD1, SubStr((cAlsQryD1)->D1_CLASFIS, 1, 1))
				
				// --------------------------------------------
				// Conteudo de importacao entre 40% e 70%
				//  - 50% importado
				// --------------------------------------------
				Elseif (cAlsQryD1)->D1_CONIMP > 40 .And. (cAlsQryD1)->D1_CONIMP <= 70
				
					nMpParcIm	:=	x61ChkMpD1(cAlsQryD1, SubStr((cAlsQryD1)->D1_CLASFIS, 1, 1))
					nMpParcIm	:=	nMpParcIm / 2
				
				Endif
			
			// ------------------------------------------------------------------------
			// Se nao possuir o campo D1_CONIMP, posso me basear nos codigos de origem
			// ------------------------------------------------------------------------
			Else
			
				// --------------------------------------------
				// Origem 1, 2 ou 8: Conteudo de Importacao > 70%
				//  - 100% importado
				// --------------------------------------------
				If SubStr((cAlsQryD1)->D1_CLASFIS, 1, 1) $ "1|2|8"
				
					nMpParcIm	:=	x61ChkMpD1(cAlsQryD1, SubStr((cAlsQryD1)->D1_CLASFIS, 1, 1))
					
				// --------------------------------------------
				// Origem 3: Conteudo de importacao entre 40% e 70%
				//  - 50% importado
				// --------------------------------------------
				Elseif SubStr((cAlsQryD1)->D1_CLASFIS, 1, 1) == "3"
				
					nMpParcIm	:=	x61ChkMpD1(cAlsQryD1, SubStr((cAlsQryD1)->D1_CLASFIS, 1, 1))
					nMpParcIm	:=	nMpParcIm / 2
				
				Endif
			Endif
		Endif
	Endif
	
	//---------------------------
	//  Fecha area da Query SD1
	//---------------------------
	If Select(cAlsQryD1) > 0
		(cAlsQryD1)->(DbCloseArea())
	Endif
				
Endif

cOrdProd	:=	cPR0_Op
cFilOp		:=	cPR0_Fil

RestArea(aArea)
Return nMpParcIm

//-------------------------------------------------------------------
/*/{Protheus.doc} x061ChkMov

Verifica se possui registros para o periodo em questao e deleta

@param	cMes	-> Mes de Apuracao
		cAno	-> Ano de Apuracao
		cProdDe	-> Produto inicial
		cProdAte-> Produto Final
		
@return Nil


@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061ChkMov( cMes , cAno , cProdDe , cProdAte )
Local	cPeriod		:=	""
Local	cMesCalc	:=	""
Local	cAnoCalc	:=	""
Local	aAreaCFD	:=	CFD->(GetArea())	

//-------------------------------------------------------------
//  Caso esteja processando Dezembro, atualizo ano posterior
//-------------------------------------------------------------
cMesCalc	:=	x061RetYear( cAno , cMes , 2 )
cAnoCalc	:=	x061RetYear( cAno , cMes , 1 )

//---------------------------------
//  Componho conteudo do periodo
//---------------------------------
cPeriod	:=	cMesCalc + cAnoCalc

CFD->(DbSetOrder(1)) //->CFD_FILIAL+CFD_PERCAL+CFD_PERVEN+CFD_COD

//-------------------------------------------------------------
//  Verifico se ja existe processamento no periodo e pergunto se
//  deseja reprocessar
//-------------------------------------------------------------
If CFD->( MsSeek( xFilial("CFD") + cPeriod ) )

	//----------------------------------
	//  Deleto registros do periodo
	//----------------------------------
	While !CFD->(Eof()) .And. CFD->( CFD_FILIAL + CFD_PERCAL ) == xFilial("CFD")+cPeriod
	    
		//--------------------------------------------------------------------------------------------------
		// Verifico se o produto esta no filtro de processamento e se ja nao possui codigo de FCI importado.
		//--------------------------------------------------------------------------------------------------
		If ( CFD->CFD_COD >= cProdDe .And. CFD->CFD_COD <= cProdAte ) .And. Empty( CFD->CFD_FCICOD )
	
			RecLock("CFD",.F.)
			CFD->(DbDelete())
			MsUnLock()
			
		Endif
		
		CFD->(DbSkip())
	End

Endif

If CFD->( MsSeek( xFilial("CFD")+(cMes+cAno)+(cMes+cAno)))

	//----------------------------------
	//  Deleto registros do periodo
	//----------------------------------
	While !CFD->(Eof()) .And. CFD->( CFD_FILIAL + CFD_PERCAL ) == xFilial("CFD")+(cMes+cAno)
	    
		//--------------------------------------------------------------------------------------------------
		// Verifico se o produto esta no filtro de processamento e se ja nao possui codigo de FCI importado.
		//--------------------------------------------------------------------------------------------------
		If ( CFD->CFD_COD >= cProdDe .And. CFD->CFD_COD <= cProdAte ) .And. Empty( CFD->CFD_FCICOD )
	
			RecLock("CFD",.F.)
			CFD->(DbDelete())
			MsUnLock()
			
		Endif
		
		CFD->(DbSkip())
	End

Endif

RestArea(aAreaCFD)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061GetQry

Funcao que executa query da rotina, conforme necessidade do layout do
Arquivo da FCI.

@param  cAlsQry		-> 	Variavel que retorna alias da query
 	   	aParam		->	Parametros do processamento
 	   	nCountReg	->	Contagem de registros para regua
 	   	cQuery		->	Tipo de processamento que foi selecionado

@return	lRet	->	Query retornou registros

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function x061GetQry( cAlsQry , aParam , nCountReg , cQuery )
Local	cSelect		:=	""
Local	cFrom		:=	""
Local	cWhere		:=	""
Local	cGroup		:=	""
Local	cOrder		:=	""
Local	lRet		:=	.F.
Local	lCount		:=	nCountReg <> Nil
Local cDbType  	:= TCGetDB() 
Local cFuncNull	:= ""

Default	nCountReg	:=	0

Do Case // Nome da funcao do banco de dados que substitui NULL por 0
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case "ORACLE" $ cDbType
		cFuncNull	:= "NVL"
	Otherwise
		cFuncNull	:= "ISNULL"
EndCase
	
//------------------------------------------------------------------------

//			QUERY INICIAL - PESQUISA ULTIMA SAIDA DOS PRODUTOS

//------------------------------------------------------------------------

//Consulta o Cadsatro de Produtos, relacionando a tabela de itens de saida
//retornando a ultima saida de cada produto

//------------------------------------------------------------------------
If cQuery == "INI"

	//----------------------------------------------------------
	//						SELECT
	//----------------------------------------------------------
	//Tabelas: 	SB1 - Cadastro do Produto
	//			SD2 - Item Documento de Saida
	//----------------------------------------------------------
	If lCount
		cSelect	+=	"COUNT(*) COUNTREG"
	Else
		cSelect	+=	"SB1.B1_FILIAL,"
		cSelect	+=	"SB1.B1_COD,"
		cSelect	+=	"SB1.B1_DESC,"						
		cSelect	+=	"MAX ( SD2.D2_EMISSAO ) D2_EMISSAO"		
		If aX6Content[MV_FCIPRV] == 1		
			cSelect	+=	",( SELECT B1_PRV1 FROM " + RetSqlName( "SB1" ) + " SB12 " 
			cSelect	+=	" 	WHERE SB1.B1_FILIAL = SB12.B1_FILIAL AND "
			cSelect	+=	" 		SB1.B1_COD = SB12.B1_COD AND "
			cSelect	+=	" 		SB12.D_E_L_E_T_ = ' ' " 
			cSelect	+=	"   ) B1_PRV1 "
		ElseIf aX6Content[MV_FCIPRV] == 2					
			cSelect	+=	",( SELECT B5_FCIPRV FROM " + RetSqlName( "SB5" ) + " SB52 "  
			cSelect	+=	"   WHERE SB52.B5_FILIAL  = '" + xFilial( "SB5" ) + "' AND "
			cSelect	+=	"  		SB52.B5_COD = SB1.B1_COD AND "
			cSelect	+=	" 		SB52.D_E_L_E_T_ = ' ' "
			cSelect	+=	"  ) B5_FCIPRV "
		ElseIf aParam[4] .AND. aX6Content[MV_FCIPRV] == 3 	// FieldPos -> BZ_FCIPRV
			cSelect	+=	",( SELECT BZ_FCIPRV FROM " + RetSqlName( "SBZ" ) + " SBZ "  
			cSelect	+=	"   WHERE SBZ.BZ_FILIAL  = '" + xFilial( "SBZ" ) + "' AND "
			cSelect	+=	"  		SBZ.BZ_COD = SB1.B1_COD AND "
			cSelect	+=	" 		SBZ.D_E_L_E_T_ = ' ' "
			cSelect	+=	"  ) BZ_FCIPRV "
		EndIf  
		
	Endif
	//----------------------------------------------------------
	//						FROM
	//----------------------------------------------------------
	//Tabelas: 	SD2 - Item Documento de Saida
	//			SB1 - Cadastro do Produto (Join)
	//----------------------------------------------------------
	cFrom	+=	RetSqlName( "SB1" ) + " SB1 "

	//----> Left Join com SD2 (devido as condicoes retorna apenas 1 registro, mesmo com LEFT JOIN) 
	cFrom	+=	"LEFT JOIN " + RetSqlName( "SD2" ) + " SD2 ON "
	cFrom	+=	"	SD2.D2_FILIAL = '" + xFilial( "SD2" ) + "' AND "
	cFrom	+=	"	SD2.D2_COD = SB1.B1_COD AND "
	cFrom	+=	"	SD2.D2_TIPO <> 'I' AND SD2.D2_TIPO <> 'P' AND "
	cFrom	+=	"	SD2.D2_EMISSAO <= '" + aParam[3] + "' AND "	
	cFrom	+=	"	SD2.D2_CF IN (" + aX6Content[MV_FCIVI] + "," + aX6Content[MV_FCIVE] +")  AND "
	cFrom	+=	"	SD2.D_E_L_E_T_ = ' ' "
		
	//----------------------------------------------------------
	//						WHERE
	//----------------------------------------------------------
	//Tabelas: 	SB1 - Cadastro do Produto
	//----------------------------------------------------------
	cWhere	+=	"SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' AND "
	cWhere	+=	"SB1.B1_COD >= '" + aParam[1] + "' AND "
	cWhere	+=	"SB1.B1_COD <= '" + aParam[2] + "' AND "
	
	// Filtro p/ desconsiderar produtos bloqueados no processamento da FCI.
	If !aParam[5]
		cWhere += "SB1.B1_MSBLQL <> '1' AND " 
	EndIf
		
	cWhere	+=	"SB1.D_E_L_E_T_ = ' '"

	//----------------------------------------------------------
	//						GROUP BY
	//----------------------------------------------------------
	//Tabelas: 	SB1 - Cadastro do Produto
	//----------------------------------------------------------
	//Chave do Grupo: Produto
	//----------------------------------------------------------
	If !lCount
		cGroup	+=	" GROUP BY SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC"
	Endif

	
//------------------------------------------------------------------------

//				MOVIMENTACOES DE SAIDA DO PERIODO (APURACAO)

//------------------------------------------------------------------------

//Consulta por registros de saida para processamento da apuracao

//------------------------------------------------------------------------
Elseif cQuery == "APU"

	//----------------------------------------------------------
	//						SELECT
	//----------------------------------------------------------
	//Tabelas: 	SB1 - Cadastro do Produto
	//			SD2 - Item Documento de Saida
	//----------------------------------------------------------
	cSelect	+=	"SD2.D2_FILIAL FILIAL, "
	cSelect	+=	"SD2.D2_COD B1_COD, "
	cSelect	+=	"SD2.D2_NUMLOTE NUMLOTE, "
	cSelect	+=	"SD2.D2_LOTECTL LOTECTL, "
	cSelect	+=	"MIN(SD2.D2_EMISSAO) EMISSAO, "
	
	//SubQuery - Valor de Saidas internas (CFOP 5xxx)
	cSelect	+=	"(	SELECT "
	cSelect	+=	"		SUM(SD22.D2_VALBRUT)-SUM(SD22.D2_VALICM)-SUM(SD22.D2_VALIPI)-SUM(SD22.D2_ICMSRET) "
	cSelect	+=	"	FROM "
	cSelect	+=	RetSqlName( "SD2" ) + " SD22 "
	cSelect	+=	"	WHERE "
	cSelect	+=	"		SD2.D2_FILIAL	= SD22.D2_FILIAL		AND "
	cSelect	+=	"		SD2.D2_COD 		= SD22.D2_COD			AND "
	cSelect	+=	"		SD2.D2_NUMLOTE	= SD22.D2_NUMLOTE	AND "
	cSelect	+=	"		SD2.D2_LOTECTL	= SD22.D2_LOTECTL	AND "
	cSelect	+=	"		SD22.D2_EMISSAO	>=	'"+ DToS( aParam[2] ) +"'		AND "
	cSelect	+=	"		SD22.D2_EMISSAO	<=	'"+ DToS( aParam[3] ) +"'		AND "
	cSelect	+=	"		SD22.D2_CLASFIS IN ( " + aX6Content[MV_FCICL] + " ) AND "
	cSelect	+=	"		SD22.D2_CF IN ( " + aX6Content[MV_FCIVI] + " ) AND "
	cSelect	+=	"		SD22.D_E_L_E_T_ = ' ' "
	cSelect	+=	"		) SAIDA_IN , "
	
	//SubQuery - Quantidade - Saidas internas (CFOP 5xxx)
	cSelect	+=	"(	SELECT "
	cSelect	+=	"		SUM(SD23.D2_QUANT) "
	cSelect	+=	"	FROM "
	cSelect	+=	RetSqlName( "SD2" ) + " SD23 "
	cSelect	+=	"	WHERE "
	cSelect	+=	"		SD2.D2_FILIAL	= SD23.D2_FILIAL		AND "
	cSelect	+=	"		SD2.D2_COD 		= SD23.D2_COD			AND "
	cSelect	+=	"		SD2.D2_NUMLOTE	= SD23.D2_NUMLOTE	AND "
	cSelect	+=	"		SD2.D2_LOTECTL	= SD23.D2_LOTECTL	AND "
	cSelect	+=	"		SD23.D2_EMISSAO	>=	'"+ DToS( aParam[2] ) +"'		AND "
	cSelect	+=	"		SD23.D2_EMISSAO	<=	'"+ DToS( aParam[3] ) +"'		AND "
	cSelect	+=	"		SD23.D2_CLASFIS IN ( " + aX6Content[MV_FCICL] + " ) AND "
	cSelect	+=	"		SD23.D2_CF IN ( " + aX6Content[MV_FCIVI] + " ) AND "
	cSelect	+=	"		SD23.D_E_L_E_T_ = ' ' "
	cSelect	+=	"		) QUANT_IN , "
	
	//SubQuery - Valor de Saidas interestaduais (CFOP 6xxx)
	cSelect	+=	"(	SELECT "
	cSelect	+=	"		SUM(SD24.D2_VALBRUT)-SUM(SD24.D2_VALICM)-SUM(SD24.D2_VALIPI)-SUM(SD24.D2_ICMSRET) "
	cSelect	+=	"	FROM "
	cSelect	+=	RetSqlName( "SD2" ) + " SD24 "
	cSelect	+=	"	WHERE "
	cSelect	+=	"		SD2.D2_FILIAL	= SD24.D2_FILIAL		AND " 
	cSelect	+=	"		SD2.D2_COD 		= SD24.D2_COD			AND "
	cSelect	+=	"		SD2.D2_NUMLOTE 	= SD24.D2_NUMLOTE	AND "
	cSelect	+=	"		SD2.D2_LOTECTL 	= SD24.D2_LOTECTL	AND "
	cSelect	+=	"		SD24.D2_EMISSAO	>=	'"+ DToS( aParam[2] ) +"'		AND "
	cSelect	+=	"		SD24.D2_EMISSAO	<=	'"+ DToS( aParam[3] ) +"'		AND "
	cSelect	+=	"		SD24.D2_CLASFIS IN ( " + aX6Content[MV_FCICL] + " ) AND "
	cSelect	+=	"		SD24.D2_CF IN ( " + aX6Content[MV_FCIVE] + " ) AND "
	cSelect	+=	"		SD24.D_E_L_E_T_ = ' ' "
	cSelect	+=	"		) SAIDA_IE , "
	
	//SubQuery - Quantidade - Saidas interestaduais (CFOP 6xxx)
	cSelect	+=	"(	SELECT "
	cSelect	+=	"		SUM(SD25.D2_QUANT) "
	cSelect	+=	"	FROM "
	cSelect	+=	RetSqlName( "SD2" ) + " SD25 "
	cSelect	+=	"	WHERE "
	cSelect	+=	"		SD2.D2_FILIAL	= SD25.D2_FILIAL		AND " 
	cSelect	+=	"		SD2.D2_COD 		= SD25.D2_COD			AND "
	cSelect	+=	"		SD2.D2_NUMLOTE 	= SD25.D2_NUMLOTE	AND "
	cSelect	+=	"		SD2.D2_LOTECTL 	= SD25.D2_LOTECTL	AND "
	cSelect	+=	"		SD25.D2_EMISSAO	>=	'"+ DToS( aParam[2] ) +"'		AND "
	cSelect	+=	"		SD25.D2_EMISSAO	<=	'"+ DToS( aParam[3] ) +"'		AND "
	cSelect	+=	"		SD25.D2_CLASFIS IN ( " + aX6Content[MV_FCICL] + " ) AND "
	cSelect	+=	"		SD25.D2_CF IN ( " + aX6Content[MV_FCIVE] + " ) AND "
	cSelect	+=	"		SD25.D_E_L_E_T_ = ' ' "
	cSelect	+=	"		) QUANT_IE "
	
	
	//----------------------------------------------------------
	//						FROM
	//----------------------------------------------------------
	//Tabelas: 	SD2 - Item Documento de Saida
	//			SB1 - Cadastro do Produto (Join)
	//----------------------------------------------------------
	cFrom	+=	RetSqlName("SD2")+" SD2 "
	
	//----> Join com SB1
	cFrom	+=	"JOIN "+RetSqlName("SB1")+" SB1 ON "
	cFrom	+=	"SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cFrom	+=	"SD2.D2_COD = SB1.B1_COD AND "
	cFrom	+=	"SB1.D_E_L_E_T_ = ' '"
	
	//----------------------------------------------------------
	//						WHERE
	//----------------------------------------------------------
	//Tabelas: 	SD2 - Item Documento de Saida
	//----------------------------------------------------------			
	cWhere	+=	"SD2.D2_FILIAL	=	'"+xFilial("SD2")+"' AND "
	cWhere	+=	"SD2.D2_EMISSAO	>=	'"+ DToS( aParam[2] ) +"' AND "
	cWhere	+=	"SD2.D2_EMISSAO	<=	'"+ DToS( aParam[3] ) +"' AND "
	cWhere	+=	"SD2.D2_COD		=	'"+aParam[1]+"' AND "   
	cWhere	+=	"SD2.D2_PICM IN ( "+ aX6Content[MV_FCIALIQ] +" ) AND "
	cWhere	+=	"SD2.D2_CLASFIS IN ( " + aX6Content[MV_FCICL] + " ) AND "
	cWhere	+=	"SD2.D2_CF IN ( " + aX6Content[MV_FCIVI] + "," + aX6Content[MV_FCIVE] + " ) AND "
	cWhere	+=	"SD2.D_E_L_E_T_ = ' ' "
	
	//----------------------------------------------------------
	//						GROUP BY
	//----------------------------------------------------------
	//Tabelas: 	SD2 - Item Documento de Saida
	//			SB1 - Cadastro do Produto
	//----------------------------------------------------------
	//Chave do Grupo: Produto , Descricao
	//----------------------------------------------------------
	cGroup	+=	"GROUP BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_NUMLOTE, SD2.D2_LOTECTL "

	//----------------------------------------------------------
	//						ORDER BY
	//----------------------------------------------------------
	//Tabelas: 	SD2 - Item Documento de Saida
	//----------------------------------------------------------
	//Ordeno por codigo de produto
	//----------------------------------------------------------
	cOrder	+=	"ORDER BY SD2.D2_COD"


//------------------------------------------------------------------------

//				ULTIMA PRODUCAO DO PRODUTO ACABADO

//------------------------------------------------------------------------

//Retorna uma chave com a ultima Producao e OP

//------------------------------------------------------------------------

Elseif cQuery == "PRD"

	//cSelect	+=	"%MAX(SD3.D3_EMISSAO+SD3.D3_OP+SD3.D3_COD) CHAVE_D3%"
	
	cSelect	+=	"SD3.D3_FILIAL, "
	cSelect	+=	"SD3.D3_EMISSAO, "
	cSelect	+=	"SD3.D3_OP, "
	cSelect	+=	"SD3.D3_COD, "
	cSelect	+=	"SD3.D3_QUANT, "
	cSelect	+=	"SD3.D3_NUMSEQ "
	
	cFrom	+=	RetSqlName("SD3")+" SD3"
	
	cWhere	+=	"SD3.D3_FILIAL	= '"+ Iif(aParam[5] <> Nil, aParam[5] , xFilial("SD3") ) +"' AND "
	cWhere	+=	"SD3.D3_COD = '"+aParam[1]+"' AND "
	cWhere	+=	"SD3.D3_CF IN ('PR0','PR1') AND "
	cWhere	+=	"SD3.D3_EMISSAO <= '"+aParam[2]+"' AND "
	cWhere	+=	"SD3.D3_ESTORNO = ' ' AND "
	cWhere	+=	"SD3.D3_QUANT > 0 AND "
	cWhere	+=	"SD3.D_E_L_E_T_ = ' ' AND "
	cWhere += "SD3.D3_NUMSEQ = (SELECT MAX(SD32.D3_NUMSEQ) FROM "+RetSqlName("SD3")+" SD32 " 
	cWhere += 			" WHERE SD32.D3_FILIAL = SD3.D3_FILIAL AND "
	cWhere += 			"	SD32.D3_COD = SD3.D3_COD AND "
	cWhere += 			"	SD32.D3_CF = SD3.D3_CF AND "	
	cWhere += 			"	SD32.D3_EMISSAO = SD3.D3_EMISSAO AND "
	cWhere += 			"	SD32.D3_OP = SD3.D3_OP AND "	 			
	cWhere += 			"	SD32.D3_ESTORNO = ' ' AND "
	cWhere += 			"	SD32.D3_QUANT > 0 AND "
	cWhere += 			"	SD32.D_E_L_E_T_ = ' ') " 
		
	cOrder	+=	"ORDER BY SD3.D3_EMISSAO DESC"


	
//------------------------------------------------------------------------

//				PESQUISA DE MATERIAS PRIMAS POR OP

//------------------------------------------------------------------------

//Retorna as materias primas de uma OP

//------------------------------------------------------------------------

Elseif cQuery == "MPR"
    
	cSelect	+=	"SD3.D3_COD, " 
	cSelect	+=	"SD3.D3_EMISSAO, "
	cSelect	+=	"SD3.D3_QUANT, "
	cSelect	+=	"SD3.D3_NUMLOTE, "
	cSelect	+=	"SD3.D3_LOTECTL, "
	cSelect	+=	"SD3.D3_OP"
	
	cFrom	+=	RetSqlName("SD3")+" SD3"
	
	cWhere	+=	"SD3.D3_FILIAL	= '"+ Iif(aParam[3] <> Nil, aParam[3] , xFilial("SD3") ) +"' AND "
	cWhere	+=	"SD3.D3_CF IN ( " + aX6Content[MV_FCIMI] + " ) AND "
	cWhere	+=	"SD3.D3_EMISSAO = '"+aParam[1]+"' AND "   //-> emisao da op PR0
	cWhere	+=	"SD3.D3_OP = '"+aParam[2]+"' AND "			//-> codigo da op PR0
	cWhere += "SD3.D3_NUMSEQ = '"+aParam[4]+"' AND "	//-> numseq da op PR0
	cWhere	+=	"SD3.D3_ESTORNO = ' ' AND "
	cWhere	+=	"SD3.D_E_L_E_T_ = ' '"


//------------------------------------------------------------------------

//				BUSCA O DOCUMENTO DE ENTRADA DA MATERIA PRIMA

//------------------------------------------------------------------------

//Utilizada para calculo da parcela de importacao

//------------------------------------------------------------------------
	
Elseif cQuery == "ENT"

   cSelect		+=	"SD1.D1_FILIAL, "
   cSelect		+=	"SD1.D1_QUANT, "
	cSelect	+=	"SD1.D1_EMISSAO, "
	cSelect	+=	"SD1.D1_COD, "
	cSelect	+=	"SD1.D1_CLASFIS, "
	cSelect	+=	"SD1.D1_TOTAL, "
	cSelect	+=	"SD1.D1_VALFRE, "
	cSelect	+=	"SD1.D1_SEGURO, "
	cSelect	+=	"SD1.D1_VALICM, "
	cSelect	+=	"SD1.D1_VALIPI, "
	cSelect	+=	"SD1.D1_ICMSRET, "			 
	cSelect	+= "( CASE WHEN SF4.F4_AGREG IN ('B','C') THEN "  //Tratamento do EIC	
	cSelect	+= cFuncNull + "( "
	cSelect	+= " 		 (SELECT (WN_IIVAL+WN_DESPADU) "
	cSelect	+= " 		       FROM  "+ RetSqlName( "SWN" ) + " SWN "
	cSelect	+= " 		    	WHERE SWN.WN_FILIAL = SD1.D1_FILIAL AND "
	cSelect	+= " 		     		SWN.WN_DOC = SD1.D1_DOC AND "
	cSelect	+= " 		       	SWN.WN_SERIE = SD1.D1_SERIE AND "
	cSelect	+= " 		       	(SWN.WN_TEC||SWN.WN_EX_NCM||SWN.WN_EX_NBM) = SD1.D1_TEC AND "
	cSelect	+= " 		       	SWN.WN_FORNECE = SD1.D1_FORNECE AND "	
	cSelect	+= " 		       	SWN.WN_LOJA = SD1.D1_LOJA AND "
	cSelect	+= " 		       	SWN.WN_PRODUTO = SD1.D1_COD AND "	 
	cSelect	+= " 		       	SWN.WN_LINHA = CAST(SD1.D1_ITEM AS DECIMAL(20)) AND "
	cSelect	+= " 		       	SWN.D_E_L_E_T_ = ' '),0) "	
	cSelect	+= " ELSE SD1.D1_II "
	cSelect	+= "  END) AS D1_II, "		
	cSelect	+=	"SD1.D1_TEC, "
	cSelect	+=	"SD1.D1_CONIMP, "
	cSelect	+=	"SF4.F4_AGREG, "
	cSelect	+=	"SF1.F1_FILORIG, "
	cSelect	+=	"SF1.F1_DOC, "
	cSelect	+=	"SF1.F1_SERIE, "
	cSelect	+=	"SF1.F1_CLIORI, "
	cSelect	+=	"SF1.F1_LOJAORI "
	
	cFrom	+=	RetSqlName("SD1")+" SD1 "
	
	//----> JOIN SF1
	cFrom	+=	"JOIN " + RetSqlName( "SF1" ) + " SF1 ON "
	cFrom	+=	"SF1.F1_FILIAL 	= '"+ Iif(aParam[5] <> Nil, aParam[5] , xFilial( "SF1" ) ) +"' AND "
	cFrom	+=	"SF1.F1_DOC 	= SD1.D1_DOC AND "
	cFrom	+=	"SF1.F1_SERIE 	= SD1.D1_SERIE AND "
	cFrom	+=	"SF1.F1_FORNECE = SD1.D1_FORNECE AND "
	cFrom	+=	"SF1.F1_LOJA 	= SD1.D1_LOJA AND "
	cFrom	+=	"SF1.D_E_L_E_T_	= ' ' "
	
	//----> JOIN SF4 -- F4_FILIAL+F4_CODIGO
	cFrom	+=	"JOIN " + RetSqlName( "SF4" ) + " SF4 ON "
	cFrom	+=	"SF4.F4_FILIAL 	= '"+ Iif( aParam[5] <> Nil, x061RetFil(aParam[5], "SF4") , xFilial( "SF4" ) ) +"' AND "
	cFrom	+=	"SF4.F4_CODIGO 	= SD1.D1_TES AND "
	cFrom	+=	"SF4.D_E_L_E_T_	= ' ' "
	
	// ----------------------
	// aParam[5] -> cFilOrig
	// ----------------------
	cWhere	+=	"SD1.D1_FILIAL	= '"+ Iif(aParam[5] <> Nil, aParam[5] , xFilial("SD1") ) +"' AND "
	cWhere	+=	"SD1.D1_COD = '"+aParam[1]+"' AND "
	cWhere	+=	"SD1.D1_EMISSAO <= '"+aParam[2]+"' AND "
	cWhere	+=	"SD1.D1_NUMLOTE = '"+aParam[3]+"' AND "
	cWhere	+=	"SD1.D1_LOTECTL = '"+aParam[4]+"' AND "
	cWhere	+=	"( SD1.D1_CLASFIS IN (" + aX6Content[MV_FCICL] + ") OR SD1.D1_CF IN ("+ aX6Content[MV_FCITR] +") ) AND "
	cWhere	+=	"SD1.D1_TIPO = 'N' AND "
	cWhere	+=	"SD1.D_E_L_E_T_ = ' ' "
	
	cOrder	+=	"ORDER BY SD1.D1_EMISSAO DESC"


//------------------------------------------------------------------------

//				CONSULTA REGISTROS DE FCI POR PERIODO

//------------------------------------------------------------------------

//Retornar espelho do arquivo magnetico - registros 5020

//------------------------------------------------------------------------
Elseif cQuery == "CFD"

	//----------------------------------------------------------
	//						SELECT
	//----------------------------------------------------------
	//Tabelas: 	SB1 - Cadastro do Produto
	//			CFD - Ficha de Conteudo de Importacao
	//----------------------------------------------------------
	cSelect	+=	"SB1.B1_DESC, " 
	cSelect	+=	"SB1.B1_POSIPI, "
	cSelect	+=	"SB1.B1_COD, "
	cSelect	+=	"SB1.B1_UM, "
	cSelect	+=	"CFD.CFD_FILIAL, "
	cSelect	+=	"CFD.CFD_OP, "
	cSelect	+=	"CFD.CFD_FILOP, "
	cSelect	+=	"CFD.CFD_VSAIIE, "
	cSelect	+=	"CFD.CFD_VPARIM, "
	cSelect	+=	"CFD.CFD_PERCAL, "
	cSelect	+=	"CFD.CFD_FCICOD, "
	cSelect	+=	"CFD.CFD_CONIMP, "
	cSelect	+=	"SAH.AH_UMFCI "
	
	//-------------------
	// Codigo GTIN
	//-------------------
	If !Empty ( aParam[5] )
		cSelect	+=	", SB1."+aParam[5]
	Endif
	
	//----------------------------------------------------------
	// Verificao da primeira posicao do array aParam
	// Define o filtro a partir da rotina de Origem (relatorio ou txt)
	//----------------------------------------------------------
	If aParam[1] == "Report"
		cSelect	+=	", SD31.D3_CF MP_CF, SD31.D3_COD MP_COD, SD31.D3_QUANT MP_QUANT, SD31.D3_CUSTO1 MP_PRECO, SD3.D3_NUMLOTE NUMLOTE, SD3.D3_LOTECTL LOTECTL"
	
	Endif	
	
	//----------------------------------------------------------
	//						FROM
	//----------------------------------------------------------
	//Tabelas: 	CFD - Ficha de Conteudo de Importacao
	//----------------------------------------------------------
	cFrom	+=	RetSqlName("CFD")+" CFD "
	
	//----> Join com SB1
	cFrom	+=	"JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND CFD.CFD_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' "
	
	//----------------------------------------------------------
	// Verificao da primeira posicao do array aParam
	// Define o filtro a partir da rotina de Origem (relatorio ou txt)
	//----------------------------------------------------------
	If aParam[1] == "Report"
		//----> Join com SD3
		cFrom	+=	" JOIN " + RetSqlName("SD3") + " SD3 ON "
		cFrom	+=	"	SD3.D3_FILIAL = CFD.CFD_FILOP	AND "
		cFrom	+=	"	SD3.D3_OP = CFD.CFD_OP 			AND "
		cFrom	+=	"	SD3.D3_COD = CFD.CFD_COD  		AND " 
		cFrom	+=	"	SD3.D3_ESTORNO = ' ' 			AND "
		cFrom	+=	"	SD3.D_E_L_E_T_ = ' ' "
		
		//----> Left Join com SD3 - Materias Primas
		cFrom	+=	" LEFT JOIN " + RetSqlName("SD3") + " SD31 ON "
		cFrom	+=	"	SD31.D3_FILIAL = SD3.D3_FILIAL 					AND "
		cFrom	+=	"	SD3.D3_OP = SD31.D3_OP 							AND "
		cFrom	+=	"	SD31.D3_CF IN ( " + aX6Content[MV_FCIMI] + " ) 	AND "
		cFrom	+=	"	SD31.D3_ESTORNO = ' ' 							AND "
		cFrom	+=	"	SD31.D_E_L_E_T_ = ' ' "
	
	Endif
	
	//----> Left Join com SAH
	cFrom	+=	" LEFT JOIN " + RetSqlName( "SAH" ) + " SAH ON "
	cFrom	+=	"	SAH.AH_FILIAL = '" + xFilial( "SAH" ) + "'	AND "
	cFrom	+=	"	SB1.B1_UM = SAH.AH_UNIMED 					AND "
	cFrom	+=	"	SAH.D_E_L_E_T_ = ' ' "
	
	//----------------------------------------------------------
	//						WHERE
	//----------------------------------------------------------
	//Tabelas: 	CFD - Ficha de Conteudo de Importacao
	//----------------------------------------------------------
	cWhere	+=	"CFD.CFD_FILIAL = '"+xFilial("CFD")+"' AND "
	// CFD_PERCAL = CFD_PERVEN = aParam[6]: Tratamento p/ que os produtos novos sejam levados para o relatorio/arquivo.
	// aParam[2] contem o periodo calculado (+ 2 Meses) e, desta forma, os produtos novos acabam sendo desconsiderados.
	cWhere	+=	"((CFD.CFD_PERCAL = '"+aParam[2]+"') OR ((CFD.CFD_PERCAL = '"+aParam[6]+"') AND (CFD.CFD_PERCAL = CFD.CFD_PERVEN))) AND "
	
	//----------------------------------------------------------
	// Verificao da primeira posicao do array aParam
	// Define o filtro a partir da rotina de Origem (relatorio ou txt)
	//----------------------------------------------------------
	If aParam[1] == "Txt"
	    
		//----------------------------------------------------------
		// Faco a verificacao do campo CFD_FCICOD apenas na geracao do arquivo magnetico
		//----------------------------------------------------------
		cWhere	+=	"CFD.CFD_FCICOD = ' ' AND "
		cWhere	+=	"CFD.CFD_VPARIM > 0 AND "
		cWhere	+=	"CFD.CFD_CONIMP > 0 AND "

	Endif
	
	cWhere	+=	"CFD.CFD_COD >= '"+aParam[3]+"' AND CFD.CFD_COD <= '"+aParam[4]+"' AND "
	cWhere	+=	"CFD.D_E_L_E_T_ = ' ' "
	
	If aParam[1] == "Report"
		cOrder	+=	"ORDER BY CFD.CFD_FILIAL, SB1.B1_COD, CFD.CFD_OP"
	Endif

//------------------------------------------------------------------------

//						PESQUISA LOTE DAS MP'S

//------------------------------------------------------------------------
Elseif cQuery == "LMP"

	cSelect	+=	"SD5.D5_NUMLOTE, SD5.D5_LOTECTL "
	cFrom	+=	RetSqlName("SD5")+" SD5 "
	cWhere	+=	"SD5.D5_FILIAL = '" + aParam[1] + "' AND "
	cWhere	+=	"SD5.D5_PRODUTO = '" + aParam[3] + "' AND "
	cWhere	+=	"SD5.D5_OP = '" + aParam[2] + "' AND "
	cWhere	+=	"SD5.D5_DATA = '" + aParam[4] + "' AND "
	cWhere	+=	"SD5.D5_ESTORNO = ' ' AND "
	cWhere	+=	"SD5.D_E_L_E_T_ = ' '"

Elseif cQuery == "SA8"

	cSelect +=	"MAX(SA8.A8_PERIOD) A8_PERIOD, SUM(SA8.A8_VLRVI) A8_VLRVI, SA8.A8_COD, "
	cSelect += 	"SUBSTRING(A8_PERIOD,3,4)||SUBSTRING(A8_PERIOD,1,2) AS PERIODO "
	cFrom	+=	RetSqlName( "SA8" )+" SA8 "
	cWhere	+=	"SA8.A8_FILIAL = '" + xFilial( "SA8" ) + "' AND "
	cWhere	+=	"SA8.A8_COD = '" + aParam[1] + "' AND "
	cWhere +=	"SUBSTRING(SA8.A8_PERIOD,3,4) || SUBSTRING(SA8.A8_PERIOD,1,2) <= '" + aParam[3]+aParam[2]+ "' AND "
	cWhere	+=	"SA8.A8_PROCOM = 'P' AND "
	cWhere	+=	"SA8.D_E_L_E_T_ = ' '"
	cGroup	+=	" GROUP BY SA8.A8_COD, SA8.A8_PERIOD "
	cOrder	+=	" ORDER BY 4 DESC"

Endif

//----------------------------------------------------------
//    Definindo Estrutura para Execucao do BeginSql
//----------------------------------------------------------
cSelect  := "%" + cSelect  + "%" 
cFrom    := "%" + cFrom    + "%" 
cWhere   := "%" + cWhere + cGroup + cOrder + "%" 

//-----------------------
//Execucao da query
//-----------------------
If (TcSrvType ()<>"AS/400")
	
	cAlsQry	:=	GetNextAlias()
	
	BeginSql Alias cAlsQry
	
		SELECT 
			%Exp:cSelect%
	
		FROM 
			%Exp:cFrom%
	
		WHERE 
			%Exp:cWhere%

	EndSql
Endif

//Retorno .T. se a query retornar registros
(cAlsQry)->(DbGoTop())
If !(cAlsQry)->(Eof())
	lRet	:=	.T.
	
	//Retorno quantidade de registros
	If lCount
		nCountReg	+=	(cAlsQry)->COUNTREG
	Endif
	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Bloco0

Bloco 0: Identificacao do Contribuinte

@param	nHandle		->	Acesso ao arquivo de trabalho
		aParam		->	Parametros de identificacao da rotina
		nTotFLin	->	Total de registros do arquivo

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function x061Bloco0(nHandle,aParam,nTotFLin)

x61Reg0000(nHandle,aParam)	//-> Registro 0000: Identificacao do Contribuinte
x61Reg0001(nHandle)			//-> Registro 0001: Identificacao do inicio do Bloco
x61Reg0010(nHandle)			//-> Registro 0010: Informacoes do estabelecimento/Contribuinte informante
x61Reg0990(nHandle)			//-> Registro 0990: Finalizacao do Bloco 0

//Apenas uma ocorrencia por registro neste bloco
nTotFLin	+=	4

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Bloco5

Bloco 5: Dados da Mercadoria

@param	nHandle		->	Acesso ao arquivo de trabalho
		aReg5020	->	Array com registros 5020
		nTotRg5020	->	Total de registros 5020
		nTotFLin	->	Total de registros do arquivo

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function x061Bloco5( nHandle , aReg5020 , nTotRg5020 , nTotFLin )

x61Reg5001( nHandle )										//-> Registro 5001: Inicio do bloco de produtos e mercadorias
x061GrvReg( aReg5020 , nHandle )
x61Reg5990( nHandle , nTotRg5020+2 )						//-> Registro 5990: Finalizacao do Bloco 5

//Uma ocorrencia para os registros 5001 e 5990 + total de registros 5020
nTotFLin	+=	2+nTotRg5020

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Bloco9

Bloco 9: Totalizacao de Registros

@param	nHandle		->	Acesso ao arquivo de trabalho
		nTotRg5020	->	Total de registros 5020
		nTotFLin	->	Total de registros do arquivo

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function x061Bloco9(nHandle,nTotRg5020,nTotFLin)

x61Reg9001(nHandle)				//-> Registro 9001: Identificacao do inicio do Bloco
x61Reg9900(nHandle,nTotRg5020)	//-> Registro 9900: Totalizadores de Registros Anteriores
x61Reg9990(nHandle)				//-> Registro 9990: Encerramento do Bloco 9

//Uma ocorrencia para os registros 9001 e 9990 + 3 ocorrencias do registro 9900 + o registro 9999
nTotFLin	+=	6

x61Reg9999(nHandle,nTotFLin)	//-> Registro 9999: Encerramento do Arquivo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg0000

Registro 0000: Identificacao do Contribuinte

@param	nHandle	->	Acesso ao arquivo de trabalho
		aParam	->	Parametros de identificacao da rotina

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg0000(nHandle,aParam)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "0000")
aAdd (aReg[nPos], xMagConType(xMagChkID(SM0->M0_CGC)))
aAdd (aReg[nPos], SM0->M0_NOMECOM)
aAdd (aReg[nPos], aParam[4])
//aAdd (aReg[nPos], Nil /*Preenchido no retorno*/)
//aAdd (aReg[nPos], Nil /*Preenchido no retorno*/)
//aAdd (aReg[nPos], Nil /*Preenchido no retorno*/)
//aAdd (aReg[nPos], Nil /*Preenchido no retorno*/)
//aAdd (aReg[nPos], Nil /*Preenchido no retorno*/)

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg0001

Registro 0001: Identificacao do inicio do Bloco

@param	nHandle	->	Acesso ao arquivo de trabalho

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg0001(nHandle)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "0001")
aAdd (aReg[nPos], EnCodeUtf8 ( "Texto em caracteres UTF-8: (dígrafo BR)'ção',(dígrafo espanhol-enhe)'ñ',(trema)'Ü',(ordinais)'ªº',(ligamento s+z alemão)'ß'.") )

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg0010

Registro 0010: Informacoes do estabelecimento/Contribuinte informante

@param	nHandle	->	Acesso ao arquivo de trabalho

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg0010(nHandle)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "0010")
aAdd (aReg[nPos], xMagConType(xMagChkID(SM0->M0_CGC)))
aAdd (aReg[nPos], SM0->M0_NOMECOM)
aAdd (aReg[nPos], xMagConType(xMagChkID(SM0->M0_INSC,.F.,.F.)))
aAdd (aReg[nPos], xMagConType(SM0->M0_ENDENT))
aAdd (aReg[nPos], xMagConType(SM0->M0_CEPENT))
aAdd (aReg[nPos], xMagConType(SM0->M0_CIDENT))
aAdd (aReg[nPos], SM0->M0_ESTENT)

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg0990

Registro 0990: Finalizacao do Bloco 0

@param	nHandle	->	Acesso ao arquivo de trabalho

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg0990(nHandle)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "0990")
aAdd (aReg[nPos], "4")

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg5001

Registro 5001: Inicio do bloco de produtos e mercadorias

@param	nHandle	->	Acesso ao arquivo de trabalho

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg5001(nHandle)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "5001")

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg5990

Registro 5001: Inicio do bloco de produtos e mercadorias

@param	nHandle		->	Acesso ao arquivo de trabalho
		nTotRgBl5	->	Total de registros do blOco 5

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg5990(nHandle,nTotRgBl5)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "5990")
aAdd (aReg[nPos], Alltrim(Str(nTotRgBl5)))

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg9001

Registro 9001: Identificacao do inicio do Bloco

@param	nHandle	->	Acesso ao arquivo de trabalho

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg9001(nHandle)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "9001")

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg9900

Registro 9900: Totalizadores de Registros Anteriores

@param	nHandle		->	Acesso ao arquivo de trabalho
		nTotRg5020	->	Total de registros 5020

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg9900(nHandle,nTotRg5020)
Local	aReg	:=	{}
Local	aRegs	:=	{"0000","0010","5020"}
Local	nPos	:=	0
Local	nX		:=	0
Local	nTotReg	:=	0

For nX := 1 To 3

	nTotReg	:=	Iif(nX == 3, nTotRg5020, 1)
	
	aAdd(aReg, {})
	nPos	:=	Len(aReg)
	aAdd (aReg[nPos], "9900")
	aAdd (aReg[nPos], aRegs[nX])
	aAdd (aReg[nPos], Alltrim(Str(nTotReg)))
Next nX

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg9990

Registro 9990: Encerramento do Bloco 9

@param	nHandle	->	Acesso ao arquivo de trabalho

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg9990(nHandle)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "9990")
aAdd (aReg[nPos], "5")

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg9999

Registro 9999: Encerramento do Arquivo

@param	nHandle	->	Acesso ao arquivo de trabalho
		nTotFLin->	Total de linhas geradas no arquivo texto

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x61Reg9999(nHandle,nTotFLin)
Local	aReg	:=	{}
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len(aReg)
aAdd (aReg[nPos], "9999")
aAdd (aReg[nPos], Alltrim(Str(nTotFLin)))

x061GrvReg(aReg,nHandle)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061GrvReg

Funcao que grava o registro no arquivo de trabalho

@param	aReg	->	Array com os registros que serao gravados
		nHandle	->	Acesso ao arquivo de trabalho

@return

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x061GrvReg(aReg,nHandle)
Local	cSepar	:=	"|"
Local	cReg	:=	""
Local	nX		:=	0
Local	nY		:=	0

//Composicao da linha inteira do registro
For nX := 1 To Len(aReg)

	//cReg	:=	cSepar

	For nY := 1 To Len(aReg[nX])
	
		cReg	+=	x061RetCmp(aReg[nX][nY],2)
		
		If !(nY == Len(aReg[nX]))
			cReg	+=	 cSepar
		Endif	
		
	Next nY
	
	//Controle de linhas
	cReg	:=	AllTrim(cReg) + CHR(13)+CHR(10)
	
	//Gravo no arquivo
	FWrite (	nHandle,;	//-> nHandle
				cReg,;		//-> cBuffer
				Len(cReg))	//-> nQtdBytes
				
	cReg	:=	""
	
Next nX

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} x061RetCmp

Funcao que formata string para gravacao

@param	xContent	->	Conteudo que sera formatado
		nDec		->	Decimais
		lSepDate	->	Indica se ira utilizar barra separadora
						do campo tipo data

@return	xStr	Conteudo formatado

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x061RetCmp(xContent,nDec,lSepDate)
Local	xStr
Default	lSepDate	:=	.F.

//Para conteudo Nulo, retorno campo em branco
If xContent == Nil
	xStr	:=	""
//Para conteudo numerico, utilizo as casas decimais
Elseif (ValType (xContent)=="N")
	If xContent == 0
		xStr	:=	"0"
	Else
		xStr	:=	AllTrim (StrTran (Str (xContent,,nDec), ".", ","))
	EndIf
//Para conteudo caracter, utilizo apenas Alltrim	
ElseIf (ValType (xContent)=="C")
	xStr	:=	AllTrim (xContent)
//Para conteudo data, converto para o format dd/mm/aaaa ou ddmmaaaa
ElseIf (ValType (xContent)=="D")
	If !lSepDate
		xStr	:=	StrZero (Day(xContent),2)+StrZero(Month(xContent),2)+StrZero(Year(xContent),4)
	Else
		xStr	:=	StrZero (Day(xContent),2)+"/"+StrZero(Month(xContent),2)+"/"+StrZero(Year(xContent),4)
	Endif	
Else
	xStr	:=	""
EndIf

Return(xStr)

//-------------------------------------------------------------------
/*/{Protheus.doc} x061ImpCod

Realiza a importacao dos codigos de FCI para a tabela CFD

@param	cReg	->	Registro que sera lido
		cMesCalc->	Mes de utilizacao do codigo
		cAnoCal	->	Ano de utilizacao do codigo

@return	lRecCod	-> Houve registro importado

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function x061ImpCod( cReg , cMesCalc , cAnoCalc, cMesWiz, cAnoWiz )
Local	cCmp04		:=	""
Local	cFilProd	:=	""
Local	cCodProd	:=	""
Local	cCodFCI		:=	""
Local	cDescProd	:=	""
Local	cPerCalc	:=	cMesCalc+cAnoCalc
Local cPerNwPrd := cMesWiz + cAnoWiz
Local	lRecCod		:=	.F.
Local	bWhileFTL	:=	{||!(FT_FEof()) .And. Substr((cReg := FT_FReadLn()),1,4) == "5020"}
Local lFoundCFD := .F.
Local lWhlCFD := .F.
Local lCFDNwPrd := .F.
Local lFCINwPrd := aX6Content[MV_ESTADO] $ aX6Content[MV_FCINWPR]

IncProc( STR0051 )	//"Importando Códigos da FCI..."

//-----------------------------------------------------------------------------------------
//									Begin Transaction
//-----------------------------------------------------------------------------------------
//Este comando define que as operacoes seguintes, delimitadas pelo comando END TRANSACTION, 
//devem ser processadas como uma transacao, ou seja, como um bloco unico e indivisivel. 
//Durante uma recuperacao de falha, todas as operacoes de manipulacao de dados realizadas 
//serao integralmente desfeitas, alem de prover isolamento entre acessos concorrentes 
//na mesma massa de dados. 
//-----------------------------------------------------------------------------------------
Begin Transaction

//--------------------------------------------------------
// Bloco de codigo para verificacao do registro 5020
//--------------------------------------------------------
While Eval(bWhileFTL)
	
	//--------------------------------------------------------
	// xMagLeReg -> Realiza leitura de determinado campo dentro de um arquivo e retorna
	//    o conteudo do campo, conforme parametros enviados
	//--------------------------------------------------------
	cCmp04		:=	xMagLeReg( cReg , 4 , , .T. )
	cCodFCI		:=	xMagLeReg( cReg , 10 , , .T. )
	cDescProd	:=	xMagLeReg( cReg , 2 , , .T. )
	
	//--------------------------------------------------------------------------------------------------
	// Composicao do Codigo do produto e do codigo da filial
	// Preciso desta validacao porque no arquivo texto o campo do codigo do produto eh composto 
	//  por Produto+Filial. Desta forma, preciso separar os codigos para efetuar o Seek na tabela CFD
	//--------------------------------------------------------------------------------------------------
				
	cCodProd	:=	Padr(Substr( cCmp04 , 1 , TamSX3("B1_COD")[1] ),  TamSX3("B1_COD")[1] )
	cFilProd	:=	PadR( Substr( cCmp04 , Len( cCodProd ) + 1 ) , Len( cFilAnt ) )
	
	lFoundCFD := ((CFD->( MsSeek( cFilProd + cCodProd + cPerCalc ) )) .Or. ( lFCINwPrd .And. CFD->( MsSeek( cFilProd + cCodProd + cPerNwPrd ) ) .And. CFD->( CFD_PERCAL ) == CFD->( CFD_PERVEN ) ) )   
	
	If lFoundCFD .And. Empty( CFD->CFD_FCICOD )
	
		lWhlCFD := CFD->( CFD_FILIAL + CFD_COD + CFD_PERCAL ) == cFilProd + cCodProd + cPerCalc
		lCFDNwPrd := CFD->( CFD_FILIAL + CFD_COD + CFD_PERCAL ) == cFilProd + cCodProd + cPerNwPrd .And. CFD->( CFD_PERCAL ) == CFD->( CFD_PERVEN ) 
		
		While !CFD->(Eof()) .And. (lWhlCFD .Or. lCFDNwPrd) 
		
			/* ------------------------------------------------------------------------------------------------------------
			  Tag:
				[nFCI] Numero de controle da FCI - Ficha de Conteudo de Importacao
			  Observacao:
			  	Informação relacionada com a Resolucao 13/2012 do Senado Federal. Formato: Algarismos, letras MAIUSCULAS
				de "A" a "F" e o caractere hifen. Exemplo: B01F70AF-10BF-4B1F-848C-65FF57F616FE
			 ------------------------------------------------------------------------------------------------------------ */
		
			RecLock("CFD",.F.)
			CFD->CFD_FCICOD	:=	Upper( cCodFCI )
			MsUnLock()
			
			CFD->(DbSkip())
			lWhlCFD := CFD->( CFD_FILIAL + CFD_COD + CFD_PERCAL ) == cFilProd + cCodProd + cPerCalc
			lCFDNwPrd := CFD->( CFD_FILIAL + CFD_COD + CFD_PERCAL ) == cFilProd + cCodProd + cPerNwPrd .And. CFD->( CFD_PERCAL ) == CFD->( CFD_PERVEN ) 
		End
		
		//--------------------------------------------------------
		// Flag para indicar que houve registro gravado
		//--------------------------------------------------------
		lRecCod	:=	.T.
	
	Endif
	
	FT_FSkip()
End

End Transaction

Return lRecCod



//-------------------------------------------------------------------
/*/{Protheus.doc} x61ChkTFil

Pesquisa pelos registros de transferencia entre filiais

@param	cAlsQryD1	-> Alias da query feita para o documento de entrada
		cOrdProd	-> Ordem de Producao
		cFilOp		-> Filial da Ordem de Producao
		cTpProd		-> Tipo do Produto

@return	nMpParcIm2	-> Valor da Parcela Importada

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x61ChkTFil( cAlsQryD1 , cOrdProd , cFilOp , aPesquisa , cTpProd, aNfEntrada )
Local	nMpParcIm2	:=	0

//------------------------------------------------------
// Pesquisa a nota fiscal de saida na Filial de origem da
//  transferencia efeutada
//------------------------------------------------------
If SF2->( MsSeek ( (cAlsQryD1)->F1_FILORIG+(cAlsQryD1)->F1_DOC+(cAlsQryD1)->F1_SERIE+(cAlsQryD1)->F1_CLIORI+(cAlsQryD1)->F1_LOJAORI ) )
	
	//------------------------------------------------------
	// Pesquisa o item da nota fiscal de saida (mesmo item
	//  que esta sendo processado na origem da chamada desta
	//  funcao
	//------------------------------------------------------
	If SD2->( MsSeek ( (cAlsQryD1)->F1_FILORIG+(cAlsQryD1)->F1_DOC+(cAlsQryD1)->F1_SERIE+(cAlsQryD1)->F1_CLIORI+(cAlsQryD1)->F1_LOJAORI+(cAlsQryD1)->D1_COD ) )
		
		//------------------------------------------------------
		// Chamada recursiva da funcao x061WhlD3 para procurar
		//  a producao deste produto (ou uma outra transferencia)
		//------------------------------------------------------
		nMpParcIm2	:=	x061WhlD3( SD2->D2_COD , SD2->D2_EMISSAO , @cOrdProd , SD2->D2_NUMLOTE , SD2->D2_LOTECTL , (cAlsQryD1)->F1_FILORIG , @cFilOp , aPesquisa , cTpProd, aNfEntrada )
		
	Endif

Endif


Return nMpParcIm2

//-------------------------------------------------------------------
/*/{Protheus.doc} x061RetYear

@param	cAno	-> Ano do processamento
		cMes	-> Mes do processamento
		nTipo	-> Tipo de Resposta: Mes ou Ano do Calculo
		
@return	cNwYear	-> Mes ou Ano conforme parametros enviados

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061RetYear( cAno , cMes, nTipo )
Local	cNwYear	:= ""
Default nTipo	:= 1

//----------------------------------------------------------------------
//  Caso esteja processando Novembro ou Dezembro, atualizo ano posterior
//----------------------------------------------------------------------
If nTipo == 1		// Ano
	If cMes $ "11/12"
		cNwYear := Alltrim( Str( Val( cAno ) +1 ) )
	Else
		cNwYear := cAno
	Endif
Else				// Mes
	If cMes = "11"
		cNwYear := "01"
	ElseIf cMes == "12"
		cNwYear := "02"
	Else
		cNwYear := StrZero( Val(cMes)+2, 2)
	Endif
EndIf

Return cNwYear

//-------------------------------------------------------------------
/*/{Protheus.doc} x61Reg5020

@param	cAlsQryFD	-> Alias da query feita na tabela CFD para o periodo
		aReg5020	-> Array com os registros 5020
		nTotRg5020	-> Total de registros 5020
		cB1GTIN		-> Campo utilizado para o codigo GTIN
		
@return	Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x61Reg5020( cAlsQryFD , aReg5020 , nTotRg5020 , cB1GTIN )
Local	nPos	:=	0
Local	cUm		:=	Nil
Local	cGTIN	:=	Nil

ProcRegua( (cAlsQryFD)->(RecCount()) )

//---------------------------------------------------------------------------------------
// Laco na query procurando pelos produtos que serao gerados no arquivo texto
// Os registros serao adicionados ao array aReg5020, com a chave Filial+Produto
//---------------------------------------------------------------------------------------
While !(cAlsQryFD)->(Eof())

	//----------------------------------------------------
	//  			   Unidade de Medida
	// Prioriza utilizacao do campo AH_UMFCI, que contem
	// os codigos especificos conforme o manual da FCI.
	//----------------------------------------------------
	cUm := Iif(!Empty((cAlsQryFD)->AH_UMFCI), (cAlsQryFD)->AH_UMFCI, (cAlsQryFD)->B1_UM)

	//----------------------------------------------------
	//  			     Codigo GTIN
	//Conteudo do campo preenchido no parametro MV_FCIGTIN
	//----------------------------------------------------
	cGTIN := Iif(!Empty(cB1GTIN), (cAlsQryFD)->(&(cB1GTIN) ), Nil)

	IncProc( STR0052 + Alltrim( (cAlsQryFD)->B1_DESC) ) //"Processando Produto: "

	If (nPos := aScan(aReg5020, {|x| x[4] == (cAlsQryFD)->(B1_COD+CFD_FILIAL)})) == 0
		aAdd(aReg5020, {})
		nPos := Len(aReg5020)
		aAdd (aReg5020[nPos], "5020")
		aAdd (aReg5020[nPos], (cAlsQryFD)->B1_DESC)				//NOME_MERCADORIA
		aAdd (aReg5020[nPos], (cAlsQryFD)->B1_POSIPI)			//CODIGO_NCM
		aAdd (aReg5020[nPos], (cAlsQryFD)->(B1_COD+CFD_FILIAL))	//CODIGO_MERCADORIA
		aAdd (aReg5020[nPos], cGTIN)							//CODIGO_GTIN
		aAdd (aReg5020[nPos], cUm)								//UNIDADE_MERCADORIA
		aAdd (aReg5020[nPos], (cAlsQryFD)->CFD_VSAIIE)			//VALOR_SAIDA_MERCADORIA_INTERESTADUAL
		aAdd (aReg5020[nPos], (cAlsQryFD)->CFD_VPARIM)			//VALOR_PARCELA_IMPORTADA_EXTERIOR
		aAdd (aReg5020[nPos], (cAlsQryFD)->CFD_CONIMP)			//CONTEUDO_IMPORTACAO_CI
		nTotRg5020	+=	1
	Endif
	(cAlsQryFD)->(DbSkip())
End

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061LoteRE1

Pesquisa o lote das materias primas utilizadas no processo produtivo

@param	cPR0_Op		-> Ordem de Producao
		cCodProd	-> Codigo do Produto
		cPR0_Data	-> Data da producao
		cNumLoteRE1	-> Lote da materia prima utilizada
		cLoteCtlRE1	-> SubLote da materia prima utilizada
		cFilOrig	-> Filial de origem
		cTpLote		-> Tipo do Lote (S/L)
		
@return	Nil

@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061LoteRE1( cPR0_Op , cCodProd , cPR0_Data , cNumLoteRE1 , cLoteCtlRE1 , cFilOrig , cTpLote )
Local	cFilSD5		:=	Iif( cFilOrig <> Nil , cFilOrig , xFilial("SD5") )
Local	cAlsQryD5	:=	""

If x061GetQry( @cAlsQryD5 , { cFilSD5 , cPR0_Op , cCodProd , cPR0_Data } , , "LMP" )

	cLoteCtlRE1	:=	(cAlsQryD5)->D5_LOTECTL
	
	If cTpLote == "S"
		cNumLoteRE1	:=	(cAlsQryD5)->D5_NUMLOTE
	EndIf
	
Endif

//------------------------------------
//    Fecha area da Query
//------------------------------------
If Select(cAlsQryD5) > 0
	(cAlsQryD5)->(DbCloseArea())
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061Report


@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061Report( oCenterPanel , aWizard , lMultFil , aLisFil , cFilDe , cFilAte )
Local	aDevice		:=	{}
Local	cAliasQry	:=  ""
Local	cSession	:= GetPrinterSession()
Local	cDevice		:= GetProfString( cSession, "PRINTTYPE", "SPOOL", .T. )
Local	cProdDe		:=	aWizard[1][3]
Local	cProdAte	:=	aWizard[1][4]
Local	nPrintType	:= 0
Local	nLocal		:= 0
Local	nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW
Local	oSetup		:= Nil
Local	dDataDe		:=	SToD(aWizard[1][1])
Local	dDataAte	:=	SToD(aWizard[1][2])
Local	cMesCalc	:=	x061RetYear( Alltrim(Str(Year(dDataAte))) , StrZero( Month(dDataAte), 2 ), 2 )			// StrZero( Month(dDataAte)+2 , 2 )
Local	cAnoCalc	:=	x061RetYear( Alltrim(Str(Year(dDataAte))) , StrZero( Month(dDataAte), 2 ), 1 )			// x061RetYear( Alltrim(Str(Year(dDataAte))) , cMesCalc )
Private oPrint	    := FWMSPrinter():New( XFciFileName() , IMP_SPOOL , .F., , .T., , oSetup )

AADD(aDevice,"DISCO") 
AADD(aDevice,"SPOOL") 
AADD(aDevice,"EMAIL") 
AADD(aDevice,"EXCEL") 
AADD(aDevice,"HTML" ) 
AADD(aDevice,"PDF"  )

nPrintType := aScan(aDevice,{|x| x == cDevice }) 
nLocal     := If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )

oSetup := FWPrintSetup():New(nFlags, "TOTVS | FCI")
oSetup:SetUserParms( {|| MsgInfo(STR0054, STR0028) } )	//"Parâmetros já definidos!"| "Atenção"
oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
oSetup:SetPropert(PD_ORIENTATION , 2) 
oSetup:SetPropert(PD_DESTINATION , nLocal)
oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
oSetup:SetPropert(PD_PAPERSIZE   , 2)
	
// --------------------------------------------------------------------------------------------
// Confirmando a tela de Configuracao eu inicio a Impressao do Relatorio
// --------------------------------------------------------------------------------------------
If oSetup:Activate() == PD_OK                		 			
	x061RepFont( cAliasQry , oSetup , dDataDe , lMultFil , aLisFil , cFilDe , cFilAte , cMesCalc , cAnoCalc , cProdDe , cProdAte ) // Inicializa o relatorio mesmo que a query nao retorne nada, pois ainda preciso imprimir as paginas sem movimento			
Else
	MsgInfo( STR0053 ) //"RELATÓRIO CANCELADO PELO USUARIO."
EndIf


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} x061RepFont


@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061RepFont( cAliasQry , oSetup , dDataDe , lMultFil , aLisFil , cFilDe , cFilAte , cMesCalc , cAnoCalc , cProdDe , cProdAte )

Private cTitulo     := "FCI"
Private oCourN08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
Private oCourN10	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
Private oArial08	:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oArial10	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oArial10N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oArial14N	:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
Private oArial12N	:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Private oArial08N	:= TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
Private nLin        := 60

MsgRun( STR0055 ,"",{|| CursorWait(), x061RepPrin( cAliasQry , oSetup , dDataDe , lMultFil , aLisFil , cFilDe , cFilAte , cMesCalc , cAnoCalc , cProdDe , cProdAte ) ,CursorArrow()}) //"GERANDO RELATÓRIO, AGUARDE."

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} x061RepPrin


@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061RepPrin( cAliasQry , oSetup , dDataDe , lMultFil , aLisFil , cFilDe , cFilAte , cMesCalc , cAnoCalc , cProdDe , cProdAte )
Local	cChave  	:=	""
Local	cUm			:=	""
Local	cGTIN		:=	""
Local	cB1GTIN		:=	aX6Content[MV_FCIGTIN]
Local	bWhileSM0	:=	{||!SM0->(Eof ()) .And. ((!lMultFil .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) .Or. (lMultFil .And. Len(aLisFil)>0 .And. cEmpAnt==SM0->M0_CODIGO))}
Local	aAreaSM0	:=	SM0->(GetArea())
Local	aAreaSM02	:=	{}
Local	aProdCab	:=	{}
//Local	aProdItens	:=	{}
Local	aInfMP		:=	{}
Local	nPos		:=	0
Local	nPosIt		:=	0
Local	nX			:=	0
Local	nY			:=	0
Local	lProcessing	:=	.F.
Local cDataDe := StrZero(Month(dDataDe), 2) + Alltrim(Str(Year(dDataDe)))
Private nPag		:= 0
Private lAbortPrint	:=.F.	

// ----------------------------------------------
// Inicializacao do objeto grafico
// ----------------------------------------------
oPrint:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
oPrint:SetResolution(75)
oPrint:SetLandscape() 
oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(60,60,60,60)
                      
//Formato da impressao -> Retrato
oPrint:SetLandscape()

// ----------------------------------------------
// Define saida de impressão
// ----------------------------------------------
If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
	oPrint:nDevice := IMP_SPOOL
	// ----------------------------------------------
	// Salva impressora selecionada
	// ----------------------------------------------
	WriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.) 
	oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]
ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
	oPrint:nDevice := IMP_PDF
	// ----------------------------------------------
	// Define para salvar o PDF
	// ----------------------------------------------
	oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
Endif

DbSelectArea("SM0")
SM0->(DbGoTop ())
SM0->(DbSeek (cEmpAnt+cFilDe,.T.))

//----------------------
//Bloco de execucao, processamento de Filiais
//----------------------
Do While Eval(bWhileSM0)
	
	cFilAnt := FWGETCODFILIAL
		
	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
       nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
	   If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->( dbSkip() ) 
			Loop
		EndIf
	Else
		If lMultFil  //Somente faz skip se a opcao de selecionar filiais estiver como Sim.
			 SM0->(dbSkip())
			 Loop
		EndIf		
	EndIf
	
	If lMultFil
		x061LoadCache(.F.)
	EndIf
    
	//--------------------------------------------------------------------
	// Parametros para executar query:
	//   [1] - "Report" 			->	Indica que a chamada da query eh para geracao do txt
	//   [2] - cMesCalc+cAnoCalc	->	Periodo de Calculo
	//   [3] - cProdDe				->	Produto De
	//   [4] - cProdAte				->	Produto Ate
	//   [5] - cB1GTIN				->	Campo da tabela SB1 que preenche o codigo GTIN
	//   [6] - cDataDe -> Periodo informado na wizard (sem tratamento pela x061RetYear())
	//--------------------------------------------------------------------

	aParam	:=	{ 	"Report",;
					cMesCalc+cAnoCalc ,;
					cProdDe,;
					cProdAte,;
					cB1GTIN,;
					cDataDe }
		   
	x061GetQry( @cAliasQry , aParam , , "CFD" )
	
	While !(cAliasQry)->(Eof())
	
		//-------------------------------------------
		//  			Unidade de Medida
		// Prioriza utilizacao do campo AH_UMFCI, que contem
		// os codigos especificos conforme o manual da FCI.
		//-------------------------------------------
		cUm	:=	Iif( !Empty( (cAliasQry)->AH_UMFCI ) , (cAliasQry)->AH_UMFCI , (cAliasQry)->B1_UM )
		
		//----------------------------------------------------
		//  			     Codigo GTIN
		//Conteudo do campo preenchido no parametro MV_FCIGTIN
		//----------------------------------------------------
		cGTIN	:=	Iif( !Empty( cB1GTIN ) , (cAliasQry)->( &(cB1GTIN) ) , "" )
	
		// --------------------------------------------------------------------------------------
		// Este flag indica se estou gravando registros de algum produto
		//  Se nao estiver gravando no array, preciso pular a linha da query, porem
		//  se estiver adicionando no array, ja terei pulado a linha e estarei posicionado
		//  no proximo registro de cabecalho
		// --------------------------------------------------------------------------------------
		lProcessing	:=	.F.
	
		cChave	:=	(cAliasQry)->(CFD_FILIAL+B1_COD+CFD_OP+CFD_FILOP)
	
		If ( nPos := aScan( aProdCab, { |x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->(CFD_FILIAL+B1_COD+CFD_OP+CFD_FILOP) } ) ) == 0
		    
			// ------------------------------------------------
			// Criacao do cabecalho do produto acabado vendido
			// ------------------------------------------------
			aAdd(aProdCab, {})
			nPos	:=	Len(aProdCab)
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_FILIAL)		//01 - FILIAL
			aAdd (aProdCab[nPos], (cAliasQry)->B1_COD)			//02 - CODIGO DO PRODUTO
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_OP)			//03 - ORDEM DE PRODUCAO
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_FILOP)		//04 - FILIAL DA OP
			aAdd (aProdCab[nPos], (cAliasQry)->B1_DESC)		//05 - DESCRICAO DO PRODUTO
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_CONIMP)		//06 - CONTEUDO DE IMPORTACAO
			aAdd (aProdCab[nPos], (cAliasQry)->B1_POSIPI)		//07 - NCM
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_PERCAL)		//08 - PERIODO DE UTILIZACAO DO CODIGO DA FCI
			aAdd (aProdCab[nPos], (cAliasQry)->NUMLOTE)		//09 - LOTE
			aAdd (aProdCab[nPos], (cAliasQry)->LOTECTL)		//10 - SUB LOTE
			aAdd (aProdCab[nPos], cUm)							//11 - UNIDADE DE MEDIDA
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_FCICOD)		//12 - CODIGO DA FCI
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_VPARIM)		//13 - VALOR DA PARCELA IMPORTADA
			aAdd (aProdCab[nPos], (cAliasQry)->CFD_VSAIIE)		//14 - VALOR DA SAIDA
			aAdd (aProdCab[nPos], cGTIN)						//15 - CODIGO GTIN

			While (cAliasQry)->(CFD_FILIAL+B1_COD+CFD_OP+CFD_FILOP) == cChave
			
				aAreaSM02	:=	SM0->(GetArea())
				SM0->( MsSeek( cEmpAnt + (cAliasQry)->CFD_FILOP ) )
				If SB1->( MsSeek( (cAliasQry)->CFD_FILOP + (cAliasQry)->MP_COD ) ) .Or. SB1->( MsSeek( xFilial("SB1") + (cAliasQry)->MP_COD ) )
					aInfMP	:=	{ SB1->B1_DESC , SB1->B1_POSIPI }
				Else
					aInfMP	:=	{ "" , "" }	
				Endif 
				RestArea(aAreaSM02)
			
				lProcessing	:=	.T.
			
				aAdd(aProdCab[nPos], {})
				nPosIt	:=	Len(aProdCab[nPos])
				aAdd (aProdCab[nPos][nPosIt], Alltrim( (cAliasQry)->MP_COD ) )
				aAdd (aProdCab[nPos][nPosIt], Alltrim( aInfMP[1] ) )
				aAdd (aProdCab[nPos][nPosIt], Alltrim( Transform( (cAliasQry)->MP_QUANT , X3Picture("D3_QUANT") ) ) )
				aAdd (aProdCab[nPos][nPosIt], Alltrim( Transform( NoRound( (cAliasQry)->(MP_PRECO / MP_QUANT) ) , X3Picture("D3_CUSTO1") ) ) )
				aAdd (aProdCab[nPos][nPosIt], Transform( aInfMP[2] , "@R 99.99.9999" ) )
			
				(cAliasQry)->(DbSkip())
			End
		
		Endif
		
		If lProcessing
			Loop
		Else
			(cAliasQry)->(DbSkip())
		Endif
	End
	
	(cAliasQry)->(DBCloseArea())
	
	SM0->(dbSkip())
End

RestArea(aAreaSM0)
	
// ----------------------------------------------
// Valida se no período informado houve movimentacoes,
// se nao houve, imprime pagina com a mensagem:
// "NAO HOUVE MOVIMENTO"
// ----------------------------------------------
If Len( aProdCab ) <= 0	
	
	x061RepLay( .T. , @nPag , , , , dDataDe )
	
	oPrint:Say( 330,310,STR0056,oArial14N) //"Não existem Dados a serem exibidos."
				
	oPrint:EndPage() 
	oPrint:Preview()
	
	Return
Endif

For nX := 1 To Len( aProdCab )
	
	// ----------------------------------------------
	// Cria cabecalho e pagina
	// ----------------------------------------------
	x061RepLay( , @nPag , .T. , , aProdCab[nX] , dDataDe )
	nLin := 150
	
	For nY := 1 To Len( aProdCab[nX] )
	
		If ValType( aProdCab[nX][nY] ) == "A"
			// ----------------------------------------------
			// Impressao dos itens
			// ----------------------------------------------
			oPrint:SayAlign(nLin, 023 , aProdCab[nX][nY][1]	,oArial08,100,100,,0)
			
			oPrint:SayAlign(nLin, 143 ,	 aProdCab[nX][nY][2]	,oArial08,400,400,,0)
			
			oPrint:SayAlign(nLin, 553 ,	 aProdCab[nX][nY][3]	,oArial08,100,100,,0)
			
			oPrint:SayAlign(nLin, 618 ,	 aProdCab[nX][nY][4] 	,oArial08,100,100,,0)
			
			oPrint:SayAlign(nLin, 732 ,	 aProdCab[nX][nY][5]	,oArial08,100,100,,0)
				
			nLin += 10
			
			If nLin > 500 				
				nLin := 150
				x061RepLay( , @nPag , , , aProdCab[nX] , dDataDe )
			EndIf
			
			If Interrupcao(@lAbortPrint)
				Exit
			Endif
		Endif
		
	Next nY				 			      			
				
	/*If nLin > 500 				
		nLin := 150
		x061RepLay( , @nPag , , , aProdCab[nX] , dDataDe )
	EndIf*/
	
	If Interrupcao(@lAbortPrint)
		Exit
	Endif
			
Next nX
	
// ----------------------------------------------
// Finaliza Pagina e abre o Preview
// ----------------------------------------------
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL
oPrint:EndPage()         
oPrint:Preview() 
		                                                                                                                                                                   
Return(.T.)  

//-------------------------------------------------------------------
/*/{Protheus.doc} x061RepLay


@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061RepLay( lNoReg, nPag, lCriaPag, lInicFeix , aProdCab , dDataDe )
Default nPag		:=	1   
Default lCriaPag	:=	.T.
Default lInicFeix	:=	.F.
Default	lNoReg		:=	.F.

// ----------------------------------------------
// Verifica se deve criar uma nova pagina
// ----------------------------------------------
If lCriaPag
	
	// ----------------------------------------------
	// Inicializa a Pagina
	// ----------------------------------------------
	nLin := 210
   	oPrint:StartPage()    	   	
   	   	
	// ----------------------------------------------
	// Monto o Layout solicitado
	// ----------------------------------------------
   	x061RepStruc( lNoReg , aProdCab , dDataDe )
		
	// ----------------------------------------------
	// Verifica se vai somar mais um na pagina ou vai utilizar a numeracao
	// contida no parametro do relatorio
	// ----------------------------------------------
	If !lInicFeix
	  	nPag += 1
	Else
		nPag := nPagIni
	EndIf
		
	// ----------------------------------------------
	// Realiza a impressao da numeracao da pagina
	// ----------------------------------------------
	/*oPrint:Say( 100,50,Transform(StrZero(nPag,6),"@R 999.999"),oArial08)*/
Else	
	// ----------------------------------------------
	// Finaliza a Pagina Corrente
	// ----------------------------------------------
   	oPrint:EndPage()   
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} x061RepStruc


@author Luccas Curcio 
@since 13/05/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061RepStruc( lNoReg , aProdCab , dDataDe )
Local	cPeriodo	:=	""
Local	cMes		:=	""
Local	cCod		:=	Iif ( !lNoReg , Alltrim( aProdCab[2] ) , "" )
Local	cDesc		:=	Iif ( !lNoReg , Alltrim( aProdCab[5] ) , "" )
Local	cNcm		:=	Iif ( !lNoReg , Transform( aProdCab[7] , "@R 99.99.9999" ) , "" )
Local	cCI			:=	Iif ( !lNoReg , Alltrim( Transform( aProdCab[6] , "@E 999.99" ) ) , "" )
Local	cNumLote	:=	Iif ( !lNoReg .And. !Empty( aProdCab[9] ) , Alltrim( aProdCab[9] ) , "" )
Local	cSubLote	:=	Iif ( !lNoReg .And. !Empty( aProdCab[10] ), Alltrim( aProdCab[10] ) , "" )
Local	cUM			:=	Iif ( !lNoReg , Alltrim( aProdCab[11] ) , "" )
Local	cFciCod		:=	Iif ( !lNoReg , Alltrim( aProdCab[12] ) , "" )
Local	cVParIm		:=	Iif ( !lNoReg , Alltrim( Transform( aProdCab[13] , "@E 999,999,999.99" ) ) , "" )
Local	cVSaiIE		:=	Iif ( !lNoReg , Alltrim( Transform( aProdCab[14] , "@E 999,999,999.99" ) ) , "" )
Local	cCGC		:=	Alltrim( Transform ( SM0->M0_CGC, "@R 99.999.999/9999-99" ) )
Local	cGTIN		:=	Iif ( !lNoReg , Alltrim( aProdCab[15] ) , "" )
Default	lNoReg	:=	.F.

// ----------------------------------------------
// Busca o nome do mes por extenso
// ----------------------------------------------
cMes	:=	MesExtenso( SubStr( DToS( dDataDe ) , 5 , 2 ) )
cPeriodo:=	cMes+"/"+SubStr(DToS(dDataDe),1,4)                                                         

/*	Modelo dos metodos Box e Say --------------------------------

	oObj:Box ( LinhaInicial , ColunaInicial , LinhaFinal , ColunaFinal )
	oObj:Say ( LinhaInicial , ColunaInicial , Conteudo , Fonte )

	------------------------------------------------------------	*/

// --

// ------------------------------------
// Cria o box total do relatorio
// ------------------------------------		
oPrint:Box( 010 , 020 , 580 , 825 , "-2" )  
// ------------------------------------

// --

// ------------------------------------
// Cria o Titulo do Relatorio
// ------------------------------------	
oPrint:Box( 010 , 020 , 040 , 825 , "-2" )  
oPrint:Say( 020 , 021 , STR0070 ,	oArial08N )	//"FICHA DE CONTEUDO DE IMPORTACAO"
// ------------------------------------

// --

// ------------------------------------
// Cria o box do cabecalho 1
// ------------------------------------
oPrint:Box( 035 , 020 , 150 , 825 , "-2" )
// ------------------------------------

// ------------------------------------
// Cria o box do cabecalho 2
// ------------------------------------
oPrint:Box( 075 , 020 , 150 , 825 , "-2" )
// ------------------------------------

// --

// ------------------------------------
// Informacoes do Cabecalho
// ------------------------------------


/*
|--------------------------------------------------------------------------------------------------|
|Ficha de Conteudo de Importacao                                                                   |
|--------------------------------------------------------------------------------------------------|
|Razao Social:                                                                                     |
|Endereco:								Municipio:							UF:                    |
|Insc. Estadual:						CNPJ:                                                      |
|--------------------------------------------------------------------------------------------------|
|Descricao do Produto:					NCM:              					Unidade de Medida:     |
|Codigo do Produto:						Periodo de Apuracao:				Codigo da FCI:         |
|Valor da Parcela Importada:			Valor da Saida Interestadual:		Conteudo de Importacao:|
|GTIN:									Lote:								Sub-Lote:			   |
|--------------------------------------------------------------------------------------------------|
|Codigo da MP | Descricao da MP 						| Quantidade | Valor Unitario | NCM        |
|             |                                         |            |                |            |
|--------------------------------------------------------------------------------------------------|
*/
oPrint:Say( 050 , 021 , "Razão Social:" , 				oArial08N )	//"Razão Social"
oPrint:Say( 050 , 065  , Alltrim ( SM0->M0_NOMECOM ) , oArial08 )

oPrint:Say( 060 , 021 , "Endereço:" , 					oArial08N )	//"Endereço"
oPrint:Say( 060 , 054  , Alltrim ( SM0->M0_ENDCOB ) ,	oArial08 )

oPrint:Say( 060 , 340 , "Município:" , 					oArial08N )	//"Município"
oPrint:Say( 060 , 375  , Alltrim ( SM0->M0_CIDCOB ) ,	oArial08 )

oPrint:Say( 060 , 660 , "UF:" , 						oArial08N )	//"UF"
oPrint:Say( 060 , 672  , Alltrim ( SM0->M0_ESTCOB ) ,	oArial08 )

oPrint:Say( 070 , 021 , "Insc. Estadual:" , 			oArial08N )	//"Insc. Estadual"
oPrint:Say( 070 , 070  , Alltrim ( SM0->M0_INSC ) ,	oArial08 )

oPrint:Say( 070 , 340 , "CNPJ:"	, 						oArial08N )	//"CNPJ"
oPrint:Say( 070 , 365  , cCGC	,						oArial08 )

// --

oPrint:Say( 085 , 021 , "Descrição do Produto:",		oArial08N )	//"Descrição do Produto"
oPrint:Say( 085 , 089 , cDesc ,							oArial08 )

oPrint:Say( 085 , 340 , "N.C.M.:" ,						oArial08N )	//"N.C.M."
oPrint:Say( 085 , 368 , cNcm ,							oArial08 )

oPrint:Say( 085 , 660 , "Unidade de Medida:" , 			oArial08N )	//"Unidade de Medida"
oPrint:Say( 085 , 720  , cUM	,						oArial08 )

oPrint:Say( 095 , 021 , "Código do Produto:" ,			oArial08N )	//"Código do Produto"
oPrint:Say( 095 , 082 , cCod ,							oArial08 )

oPrint:Say( 095 , 340 , "Período de Apuração:" ,		oArial08N ) //"Período de Apuracao"
oPrint:Say( 095 , 405 , cPeriodo, 						oArial08 )

oPrint:Say( 095 , 660 , "Codigo da FCI:" 			, 	oArial08N )	//"Codigo da FCI"
oPrint:Say( 095 , 710  , cFciCod	,					oArial08 )

oPrint:Say( 105 , 021 , "Valor da Parcela Importada:" ,	oArial08N )	//"Valor da Parcela Importada"
oPrint:Say( 105 , 102 , cVParIm ,						oArial08 )

oPrint:Say( 105 , 340 , "Valor da Saida Interestadual:",oArial08N ) //"Valor da Saida Interestadual"
oPrint:Say( 105 , 430 , cVSaiIE, 						oArial08 )

oPrint:Say( 105 , 660 , "Conteúdo de Importação: " ,	oArial08N )	//"Conteúdo de Importação: "
oPrint:Say( 105 , 740 , cCI	,							oArial08 )

oPrint:Say( 115 , 021 , "GTIN: " ,						oArial08N )	//"GTIN: "
oPrint:Say( 115 , 040 , cGTIN ,							oArial08 )

If !Empty( cNumLote )
	oPrint:Say( 115 , 340 , "Lote: " ,					oArial08N )	//"Lote: "
	oPrint:Say( 115 , 372 , cNumLote ,					oArial08 )
Endif

If !Empty( cSubLote )        	                                            
	oPrint:Say( 115 , 660 , "Sub-Lote: " ,				oArial08N )	//"Sub-Lote:"
	oPrint:Say( 115 , 720 , cSubLote ,					oArial08 )
Endif
// ------------------------------------

// --

// ------------------------------------
// Cria box para as colunas dos itens
// ------------------------------------	                                            
oPrint:Box( 120 , 020 , 140 , 825 , "-2" )
oPrint:Box( 120 , 020 , 140 , 730 , "-2" )
oPrint:Box( 120 , 020 , 140 , 615 , "-2" )
oPrint:Box( 120 , 020 , 140 , 550 , "-2" )
oPrint:Box( 120 , 020 , 140 , 140 , "-2" )
// ------------------------------------

// --

// ------------------------------------
// Titulos das informacoes dos itens
// ------------------------------------
oPrint:Say( 133 , 23,  "Código MP",			oArial08N)
oPrint:Say( 133 , 143, "Descrição MP",		oArial08N)
oPrint:Say( 133 , 553, "Quantidade",		oArial08N)
oPrint:Say( 133 , 618, "Valor Unitário",	oArial08N)
oPrint:Say( 133 , 733, "NCM",				oArial08N)
// ------------------------------------

// --

// ------------------------------------
If !lNoReg
	oPrint:Box( 140 , 020 , 580 , 825 , "-2" )
	oPrint:Box( 140 , 020 , 580 , 730 , "-2" )
	oPrint:Box( 140 , 020 , 580 , 615 , "-2" )
	oPrint:Box( 140 , 020 , 580 , 550 , "-2" )
	oPrint:Box( 140 , 020 , 580 , 140 , "-2" )
EndIf
// ------------------------------------                               

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciRetMv_

Retorna conteudo especifico dos parametros utilizados na rotina ou
valida conteudo preenchido nos parametros

@param	cMv		-> Parametro a ser validado ou manipulado
		cDefault-> Conteudo padrao do parametro

@return cRet	-> Conteudo do parametro

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio 
@since 22/07/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Function XFciRetMv_( cMv , cDefault )
Local	xRet	:=	Nil
Default	cDefault:=	""

// ------------------------------------------------------------------------------
// Para os parametros MV_FCIVE / MV_FCIVI / MV_FCITR / MV_FCICL / MV_FCIMI
// Utilizo a funcao LeParSeq (FISXFUN) para que possibilite ao usuario utilizar um
// sequencial de parametros. Exemplo: MV_FCIVE01; MV_FCIVE02; MV_FCIVE03...
// ------------------------------------------------------------------------------
If cMv $ "MV_FCIVE | MV_FCIVI | MV_FCITR | MV_FCICL | MV_FCIMI"

	xRet	:=	LeParSeq( cMv , "/" + cDefault )
	xRet	:=	SubStr( StrTran( xRet , "/" , "," ) , 2 )
	xRet	:=	SubStr( StrTran( xRet , "'" , "" )  , 1 )	//Mantenho este tratamento pois no legado os parametros tinham "'"
	xRet	:=	XFciX6ToQry( xRet )

// ------------------------------------------------------------------------------
// Permito que o parametro MV_FCIGTIN esteja em branco, mas caso seja preenchido
// valido o conteudo verificando se o campo esta na tabela SB1
// ------------------------------------------------------------------------------
Elseif cMv == "MV_FCIGTIN"
    xRet := "B1_"
    If !Empty( aX6Content[MV_FCIGTIN] )
		If ( xRet := SubStr( aX6Content[MV_FCIGTIN] , 1 , 3 ) ) <> "B1_" .Or. !( aX3FieldP[FP_MV_FCIGTIN] )
			xRet :=	""
		Endif
	Endif

// ------------------------------------------------------------------------------
// Validacao do parametro MV_FCICALC:
// Permito apenas conteudo 1, 2 ou 3
// ------------------------------------------------------------------------------
Elseif cMv == "MV_FCICALC"
	xRet := "123"
	If aX6Content[MV_FCICALC] == 0 .Or. aX6Content[MV_FCICALC] > 3
		xRet := "X"	
	Endif

// ------------------------------------------------------------------------------
// Validacao do parametro MV_FCIPRV:
// Valido se o conteudo do parametro esta de acordo com as necessidades da rotina
// ------------------------------------------------------------------------------
Elseif cMv == "MV_FCIPRV"
	xRet := .T.
	If 	( aX6Content[MV_FCIPRV] == 3 .And. !aX3FieldP[FP_BZ_FCIPRV] ) .Or. ;
			aX6Content[MV_FCIPRV] < 1 .Or. ;
			aX6Content[MV_FCIPRV] > 3
		xRet :=	.F.
	Endif
Endif

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x61ChkMpD1

Retorna valor na entrada da Materia Prima para calculo da Parcela
Importada

@return nRet	-> Valor da entrada

@author Luccas Curcio 
@since 29/07/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x61ChkMpD1( cAlsQryD1 , cOrigem )
Local	nRet		:=	0

nRet	:=	Round( ( cAlsQryD1 )->&(XFciVIEnt( F4_AGREG ) ) , 2 )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciGetVI

Funcao que encaminha a rotina para o metodo de calculo do valor da parcela importada.
Cada metodo utiliza um processamento e funcionalidades diferentes para apuracao
do Valor da Parcela Importada.

@param	nMethod		->	Metodo de calculo para a apuracao
		cAlsQry		->	Query/Tabela com informacoes do produto apurado
		cFil		->	Filial do Produto que esta sendo calculado
		nVlMSaida	->	Valor medio das saidas
		aInfFPrd	->	Array utilizado na gravacao da tabela CFD. Retorna o conteudo que devera ser
						gravado na tabela que ira gerar o arquivo txt. (Referencia)
		dDataDe		->	Data Inicial da Apuracao
		dDataAte	->	Data Final da Apuracao
		lNewProd	->	Indica que a apuracao sera para Produtos Novos (Nunca vendidos)		

@return	Nil

@owner	SIGAFIS - Livros Fiscais 

@author Luccas Curcio 
@since 03/09/2013
@version 11.0

/*/
//-------------------------------------------------------------------
Static Function XFciGetVI( nMethod , cAlsQry , nVlMSaida , aInfFPrd , dDataDe , dDataAte , lNewProd, aDadosINI )
Local	nVlParIm	:=	0
Local	nD3_PerImp	:=	0
Local	cCodProd	:=	""
Local	cNumLote	:=	""
Local	cLoteCtl	:=	""
Local	cFilOp		:=	""
Local	cOrdProd	:=	""
Local	cAlsQrySA8	:=	""
Local	dEmissao	:=	Nil
Local	aPesquisa	:=	{}
Local aNFEntrada := {}

Default lNewProd	:=	.F.
Default aDadosINI := {}

/*-----------------------------------------------------------------------------------------------------------------------------

														 METODO 1

													*Apuracao do Periodo*
													
	Estrutura de Processos da Apuracao da Ficha de Conteudo de Importacao:
	
		1. 	(LACO 1)
			Query na tabela SB1 retornando a ultima venda de cada produto selecionado no filtro da rotina
		2. 	(LACO 1.1)
			Query na tabela SD2, consolidando as vendas do periodo da ultima venda retornada no passo 1. Nesta consulta
			tambem retorno duas colunas com valor de saidas internas (SAIDA_IN) e outra com saidas interestaduais (SAIDA_IE),
			desta forma utilizo apenas uma das colunas para apurar a media ponderada das saidas.
		3.	(LACO 1.1.1)
			Consolido os valores de cada saida na variavel nVlMSaida, e considero que neste momento ja possuo a media ponderada
			das saidas
		4.	(CONSULTA 1.1.2)
			Chamada da funcao FCIMediaP() que retorna a media ponderadas dos percentuais informados no campo D3_PERIMP
		5.	Realizo gravacao na tabela CFD por Produto apenas (nao gravo os campos CFD_OP e CFD_FILOP)
		
-----------------------------------------------------------------------------------------------------------------------------*/
If nMethod == 1
    
	cCodProd	:=	aDadosINI[INI_CODPRO]//(cAlsQry)->B1_COD
	/*----------------------------------------------------------------------------
		Chamada da Funcao FCIMediaP() que retornar a media ponderada com base no 
		conteudo do campo D3_PERIMP	preenchido pelo usuario
	
		O campo D3_PERIMP eh preenchido com o percentual de CI de cada apontamento
		de producao. Esta funcao retorna a media dos percentuais.
	------------------------------------------------------------------------------*/
	If ( nD3_PerImp	:=	FCIMediaP( xFilial("SD3") , cCodProd , dDataDe , dDataAte ) ) > 0 .And. nVlMSaida > 0
	
		//--------------------------------------------------------------------------------------------------
		// Utilizo o valor das variaveis nVlMSaida e nD3_PerImp para calcular o valor da parcela importada
		//--------------------------------------------------------------------------------------------------
		nVlParIm	:=	( nVlMSaida * nD3_PerImp ) / 100
			
		aAdd( aInfFPrd ,;
			{ xFilial( "CFD" )	,;		//-> Filial
			cCodProd			,;		//-> Codigo do produto
			""					,;		//-> Ordem de producao (nao preencho neste metodo - media)
			nVlParIm			,;		//-> Valor da Parcela de Importacao
			nVlMSaida			,;		//-> Valor de Saida Interestadual
			1					,;		//-> Quantidade usada para ponderacao
			"" 					} )		//-> Filial da Op (nao preencho neste metodo - media)
	Endif
			
/*-----------------------------------------------------------------------------------------------------------------------------

														 METODO 2

													*Apuracao do Periodo*
													
	Estrutura de Processos da Apuracao da Ficha de Conteudo de Importacao:
	
		1. 	(LACO 1)
			Query na tabela SB1 retornando a ultima venda de cada produto selecionado no filtro da rotina
		2. 	(LACO 1.1)
			Query na tabela SD2, consolidando as vendas do periodo da ultima venda retornada no passo 1. Nesta consulta
			tambem retorno duas colunas com valor de saidas internas (SAIDA_IN) e outra com saidas interestaduais (SAIDA_IE),
			desta forma utilizo apenas uma das colunas para apurar a media ponderada das saidas.
		3.	(LACO 1.1.1)
			Query na tabela SD3, pesquisando a ultima producao ou o lote da producao
		4.	(CONSULTA 1.1.2)
			Query na tabela SD1 retornando o valor de entrada de cada materia prima utilizada no processo produtivo, a fim
			de calcular o valor da Parcela Importada
		5.	Realizo gravacao na tabela CFD por Produto(+Lote+SubLote no caso de utilizar Rastro)
		
-----------------------------------------------------------------------------------------------------------------------------*/
Elseif nMethod == 2
    
	If !lNewProd
		// ----------------------------------------
		// INI - 2
		// Inicio do Laco da Query de Apuracao "APU"
		// --------------------------------------->>
		While !( cAlsQry )->( Eof () )
		
			//------------------------------------------------------
			// Informacoes utilizadas no processamento por item
			//------------------------------------------------------
			cCodProd	:=	(cAlsQry)->B1_COD
			dEmissao	:=	SToD((cAlsQry)->EMISSAO)
			cNumLote	:=	(cAlsQry)->NUMLOTE
			cLoteCtl	:=	(cAlsQry)->LOTECTL
			
		    //------------------------------------------------------
			// Calcula valor da parcela importada
			//------------------------------------------------------
			If ( nVlParIm	:=	x061WhlD3( cCodProd , dEmissao , @cOrdProd , cNumLote , cLoteCtl , , @cFilOp , aPesquisa , "PA" , aNFEntrada ) ) >= 0
			
				//------------------------------------------------------
				// Adiciono os valores para aInfFPrd -> array utilizado 
				// na gravacao da tabela CFD
				//------------------------------------------------------
				If ( nPos := aScan( aInfFPrd, { |x| x[1]+x[2]+x[3]+x[7] == xFilial("CFD")+cCodProd+cOrdProd+cFilOp } ) ) == 0
			
					aAdd( aInfFPrd	,;
						{ xFilial( "CFD" ),;		//-> Filial
						cCodProd,;					//-> Codigo do produto
						cOrdProd,;					//-> Ordem de producao
						nVlParIm,;					//-> Valor da Parcela de Importacao
						nVlMSaida,;					//-> Valor de Saida Interestadual
						1,;							//-> Quantidade usada para ponderacao
						cFilOp } )					//-> Filial da Op
											
				Else
					aInfFPrd[nPos][4]	+=	nVlParIm					//-> Valor da Parcela de Importacao
					aInfFPrd[nPos][5]	+=	nVlMSaida					//-> Valor de Saida Interestadual
					aInfFPrd[nPos][6]	+=	1							//-> Valor de Saida Interestadual
				Endif
			
			Endif
			
			// Limpando as variaveis para nao ocorrer estouro de memoria
			aPesquisa := {}
			aSize ( aPesquisa , 0 )
			
			aNFEntrada := {}
			aSize ( aNFEntrada , 0 )
						
			( cAlsQry )->( DbSkip () )
		// ----------------------------------------
		// FIM - 2
		// Fim do Laco da Query de Apuracao "APU"
		// --------------------------------------->>
		End
	
	// --- Tratamento para Produtos Novos ---
	Elseif nVlMSaida > 0
	
		//------------------------------------------------------
		// Informacoes utilizadas no processamento por item
		//------------------------------------------------------
		cCodProd	:=	aDadosINI[INI_CODPRO]
		dEmissao	:=	dDataAte
	
		//------------------------------------------------------
		// Calcula valor da parcela importada
		//------------------------------------------------------
		If ( nVlParIm	:=	x061WhlD3( cCodProd , dEmissao , @cOrdProd , cNumLote , cLoteCtl , , @cFilOp , aPesquisa , "PA" , aNFEntrada ) ) > 0
		
			//------------------------------------------------------
			// Adiciono os valores para aInfFPrd -> array utilizado 
			// na gravacao da tabela CFD
			//------------------------------------------------------
			If ( nPos := aScan( aInfFPrd, { |x| x[1]+x[2]+x[3]+x[7] == xFilial("SB1")+cCodProd+cOrdProd+cFilOp } ) ) == 0
		
				aAdd( aInfFPrd	,;
					{ xFilial( "CFD" ),;		//-> Filial
					cCodProd,;					//-> Codigo do produto
					cOrdProd,;					//-> Ordem de producao
					nVlParIm,;					//-> Valor da Parcela de Importacao
					nVlMSaida,;					//-> Valor de Saida Interestadual
					1,;							//-> Quantidade usada para ponderacao
					cFilOp } )					//-> Filial da Op
										
			Else
				aInfFPrd[nPos][4]	+=	nVlParIm					//-> Valor da Parcela de Importacao
				aInfFPrd[nPos][5]	+=	nVlMSaida					//-> Valor de Saida Interestadual
				aInfFPrd[nPos][6]	+=	1							//-> Valor de Saida Interestadual
			Endif
		Endif
	
	Endif	

/*-----------------------------------------------------------------------------------------------------------------------------

														 METODO 3

													*Apuracao do Periodo*
													
	Estrutura de Processos da Apuracao da Ficha de Conteudo de Importacao:
	
		1. 	(LACO 1)
			Query na tabela SB1 retornando a ultima venda de cada produto selecionado no filtro da rotina
		2. 	(LACO 1.1)
			Query na tabela SD2, consolidando as vendas do periodo da ultima venda retornada no passo 1. Nesta consulta
			tambem retorno duas colunas com valor de saidas internas (SAIDA_IN) e outra com saidas interestaduais (SAIDA_IE),
			desta forma utilizo apenas uma das colunas para apurar a media ponderada das saidas.
		3.	(LACO 1.1.1)
			Consolido os valores de cada saida na variavel nVlMSaida, e considero que neste momento ja possuo a media ponderada
			das saidas
		4.	(CONSULTA 1.1.2)
			Seek na tabela SA8 com o produto que esta sendo calculado. Esta tabela foi processada durante a Pre-Apuracao, e
			contem os registros que serao utilizados no calculo do CI.
		5.	Realizo gravacao na tabela CFD por Produto apenas (nao gravo os campos CFD_OP e CFD_FILOP)
		
-----------------------------------------------------------------------------------------------------------------------------*/
Elseif nMethod == 3

	cMes		:=	Alltrim( StrZero( Month( dDataDe ) , 2 ) )
	cAno		:=	Alltrim( Str( Year ( dDataDe ) ) )
	cCodProd	:=	aDadosINI[INI_CODPRO]
	
	//-------------------------------------------------------------------------
	// Utilizo o valor da Parcela Importada calculado pela Pre-Apuracao (SA8)
	//-------------------------------------------------------------------------
	If x061GetQry( @cAlsQrySA8 , { cCodProd , cMes , cAno } , , "SA8" )
		
		nVlParIm := (cAlsQrySA8)->A8_VLRVI
		
		//----------------------------------------------------------------
		// Verifico se trata-se de um registro de produto industrializado
		//----------------------------------------------------------------
		If nVlMSaida > 0 
	
			aAdd( aInfFPrd ,;
				{ xFilial( "CFD" )	,;		//-> Filial
				cCodProd			,;		//-> Codigo do produto
				""					,;		//-> Ordem de producao (nao preencho neste metodo - media)
				nVlParIm			,;		//-> Valor da Parcela de Importacao
				nVlMSaida			,;		//-> Valor de Saida Interestadual
				1					,;		//-> Quantidade usada para ponderacao
				"" 					} )		//-> Filial da Op (nao preencho neste metodo - media)
		Endif
	Endif
	
	If Select( cAlsQrySA8 ) <> 0
		( cAlsQrySA8 )->( DbCloseArea () )
	Endif
	
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciX6Cache

Cacheamento dos conteudos SX6 da rotina

@return aSX6	->	Array com conteudo dos parametros

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio 
@since 02/09/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Function XFciX6Cache()
Local	aSX6	:=	{}

// ******************************************************************************************
// Sempre que incluir um novo parametro, deve ser verificado a NECESSIDADE de tratamento
// na funcao xFciIniEnv(), onde sao feitas as validacoes de conteudo dos parametros.
// ******************************************************************************************
aAdd( aSX6 , XFciRetMv_("MV_FCITR"  , "1151,1152,1408,1409,2151,2152,2408,2409" ) )
aAdd( aSX6 , XFciRetMv_("MV_FCIVE"  , "6107,6101,6103,6105,6109,6111,6113,6116,6118,6122,6124,6125,6401,6402,6403,6404" ) )
aAdd( aSX6 , XFciRetMv_("MV_FCICL"  , "100,110,120,170,190,200,210,220,270,290,300,310,320,370,390" ) )
aAdd( aSX6 , XFciRetMv_("MV_FCIVI"  , "5107,5101,5103,5105,5109,5111,5113,5116,5118,5122,5124,5125,5401,5402,5403,5404" ) )
aAdd( aSX6 , GetNewPar ("MV_FCIALIQ", "4,17,18") )
aAdd( aSX6 , XFciRetMv_("MV_FCIMI"  , "RE1" ) )
aAdd( aSX6 , GetNewPar ("MV_FCIGTIN", "B1_CODBAR") )
aAdd( aSX6 , GetNewPar ("MV_FCICALC", 2 ) )
aAdd( aSX6 , GetNewPar ("MV_ESTADO" , "" ) )
aAdd( aSX6 , GetNewPar ("MV_FCINWPR", "SP" ) )
aAdd( aSX6 , GetNewPar ("MV_FCIPRV" , 1 ) )
aAdd( aSX6 , GetNewPar ("MV_FCINTHD" , 0 ) )
aAdd( aSX6 , GetNewPar ("MV_FCITOUT" , 190000000 ) )

Return aSX6

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciX3Cache

Cacheamento dos conteudos SX3 da rotina

@return aSX3	->	Array com fieldpos dos campos

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio 
@since 04/09/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Function XFciX3Cache()
Local	aSX3	:=	{}

aAdd( aSX3 , SB1->( FieldPos ( aX6Content[MV_FCIGTIN]	) ) > 0 )
aAdd( aSX3 , SBZ->( FieldPos ( "BZ_FCIPRV"				) ) > 0 )

Return aSX3

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciError

Retornar array com os possiveis erros de inicializacao da rotina

@return aError	->	Array com os erros que devem ser apresentados

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio 
@since 04/09/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function XFciError()
Local	aError	:=	{}

aAdd( aError , { xGetSrvEnv() == "DBF"				, STR0040 } )	//"Rotina não disponível para ambiente DBF."
aAdd( aError , { Empty(aX6Content[MV_FCITR]) 		, STR0043 } )	//"Parâmetro MV_FCITR não possui conteúdo."
aAdd( aError , { Empty(aX6Content[MV_FCIVE]) 		, STR0044 } )	//"Parâmetro MV_FCIVE não possui conteúdo."
aAdd( aError , { Empty(aX6Content[MV_FCICL]) 		, STR0045 } )	//"Parâmetro MV_FCICL não possui conteúdo."
aAdd( aError , { Empty(aX6Content[MV_FCIALIQ]) 	, STR0046 } )	//"Parâmetro MV_FCIALIQ não possui conteúdo."
aAdd( aError , { Empty(aX6Content[MV_FCIVI]) 		, STR0047 } )	//"Parâmetro MV_FCIVI não possui conteúdo."
aAdd( aError , { Empty(aX6Content[MV_FCIMI])		, STR0063 } )	//"Parâmetro MV_FCIMI não possui conteúdo."
aAdd( aError , { Empty(XFciRetMv_( "MV_FCIGTIN" ))	, STR0064 } )	//"O campo preenchido no parâmetro MV_FCIGTIN não pertence a tabela SB1."
aAdd( aError , { XFciRetMv_( "MV_FCICALC" ) == "X"	, STR0065 } )	//"Método de cálculo não foi definido através do parâmetro MV_FCICALC."
aAdd( aError , { XFciRetMv_( "MV_FCICALC" ) == "A8", STR0071 } )	//"Para o método de cálculo selecionado será necessário a criação da tabela SA8 - Pré-Apuração FCI."
aAdd( aError , { !XFciRetMv_( "MV_FCIPRV" , 1 )	, STR0072 } )	//"Verifique se o dicionário de dados está de acordo com a opção selecionada no parâmetro MV_FCIPRV"

Return aError
//-------------------------------------------------------------------
/*/{Protheus.doc} x061RetFil

// Com base no layout do SM0 e no codigo passado em cFilOrigem, 
// retorna o codigo a ser utilizado no filtro de filial da tabela destino,
// passada em cTabela.

@return cFilFiltro	->	Filial a ser utilizada no filtro

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 09/05/2014
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061RetFil(cFilOrigem, cTabela)

Local cLayoutSM0 := AllTrim(FWSM0Layout())
Local cModeAcc := "" 
Local cChar := ""
Local cFilFiltro := ""
Local nCont := 0
Local nPosChar := 0
Local aFilData := {}

/*

Layout aFilData

[1]: Identificador - Empresa(E), Unidade(U) ou Filial(F). 
[2]: Posicao inicial no layout do SIGAMAT.
[3]: Tamanho no layout do SIGAMAT.

*/

// Obtendo estrutura do layout SM0.

aAdd(aFilData, {"E", 0, 0})
aAdd(aFilData, {"U", 0, 0})
aAdd(aFilData, {"F", 0, 0})

For nCont := 1 to Len(cLayoutSM0)

	cChar := SubStr(cLayoutSM0, nCont, 1)
	
	// Posicao inicial de cada segmento dentro do layout.
	nPosChar := aScan(aFilData, {|x| x[1] == cChar})
	
	If aFilData[nPosChar][2] == 0 
		aFilData[nPosChar][2] := nCont
	EndIf
	
	// Tamanho de cada segmento dentro do layout.
	aFilData[nPosChar][3] += 1 	
	
Next nCont

// Configuracoes de compartilhamento da tabela destino.
cModeAcc := FWModeAccess(cTabela, 1) + FWModeAccess(cTabela, 2) + FWModeAccess(cTabela, 3)

If cModeAcc == "CCC" // Se for 100% compartilhada(CCC), posso usar o xFilial da propria tabela.
	cFilFiltro := xFilial(cTabela)
ElseIf cModeAcc == "EEE" // Se for 100% exclusiva(EEE), posso passar o próprio F1_FILORI.
	cFilFiltro := cFilOrigem
Else // Caso contrario, preciso montar a filial p/ o filtro de acordo com as configs. de compartilhamento da tabela destino.
	cFilFiltro := x061DivFil(aFilData, cModeAcc, cFilOrigem)
EndIf 

Return cFilFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} x061RetFil

// Com base nos dados obtidos pela funcao x061RetFil, monta o codigo da
// filial que será retornado. 

@return cRet	->	Codigo da filial que sera utilizada no JOIN.

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 04/09/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061DivFil(aFilData, cModeAcc, cFilOrigem)

Local cRet := ""

Local cEmpExc := ""
Local cUndExc := ""
Local cFilExc := ""

Local cEmpCpt := ""
Local cUndCpt := ""
Local cFilCpt := ""

Local nPosE := aScan(aFilData, {|x| x[1] == "E"}) 
Local nPosU := aScan(aFilData, {|x| x[1] == "U"})
Local nPosF := aScan(aFilData, {|x| x[1] == "F"})

// Montando strings de cada segmento compartilhado ou exclusivo conforme o tamanho do layout.
// O objetivo eh facilitar a leitura do trecho abaixo, que efetua a montagem do codigo a ser retornado.

cEmpCpt := Replicate(" ", aFilData[nPosE][3]) 
cUndCpt := Replicate(" ", aFilData[nPosU][3])
cFilCpt := Replicate(" ", aFilData[nPosF][3])

cEmpExc := SubStr(cFilOrigem, aFilData[nPosE][2], aFilData[nPosE][3])
cUndExc := SubStr(cFilOrigem, aFilData[nPosU][2], aFilData[nPosU][3])
cFilExc := SubStr(cFilOrigem, aFilData[nPosF][2], aFilData[nPosF][3])

// Montando codigo a ser retornado, conforme compartilhamento da tabela destino.
// Por razões de integridade, as combinacoes CCE, CEC, CEE e ECE não podem ser feitas (atualmente) no Configurador.
// Contudo, foram implementadas para fechar o escopo da funcao.

Do Case
	Case cModeAcc == "EEC"
		cRet := cEmpExc + cUndExc + cFilCpt
	Case cModeAcc == "ECC" 
		cRet := cEmpExc + cUndCpt + cFilCpt
	Case cModeAcc == "CCE"
		cRet := cEmpCpt + cUndCpt + cFilExc
	Case cModeAcc == "CEC"
		cRet := cEmpCpt + cUndExc + cFilCpt
	Case cModeAcc == "CEE"
		cRet := cEmpCpt + cUndExc + cFilExc
	Case cModeAcc == "ECE"
		cRet := cEmpExc + cUndCpt + cFilExc
EndCase
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x061LoadCache

Funcao responsavel por efetuar o cache dos parametros (SX6) e FieldPos
(SX3) utilizados no processamento da FCI.

@param lLoadX3 -> Flag para realizar o cache de SX3.
        lLoadX6 -> Flag para realizar o cache de SX6.

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061LoadCache(lLoadX3, lLoadX6)

DEFAULT lLoadX6 := .T.
DEFAULT lLoadX3 := .F.

// Parametros
If lLoadX6
	aX6Content	:= XFciX6Cache()
EndIf

// Campos (FieldPos)
If lLoadX3
	aX3FieldP	:=	XFciX3Cache()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061PrFCI

Funcao responsavel pela apuracao do conteudo de importacao do produto
passado por parametro (aDadosINI). Esta funcao sera executada uma vez
para cada produto retornado na query "INI" executada na funcao x061Processa.

@param aDadosINI -> Array com os dados do produto a ser processado.
        dDataDe    -> Data inicial para processamento dos movimentos.
        dDataAte  ->  Data final para processamento dos movimentos.

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061PrFCI(aDadosINI, dDataDe, dDataAte, lJob)

Local cAlsQry   := GetNextAlias()
Local cAlsQryNov:= ""
Local nVSaiIE	:= 0
Local nQntIE	:= 0
Local nVSaiIN	:= 0
Local nQntIN	:= 0
Local nCmpVSai	:= 0
Local nCmpQnt	:= 0
Local nVlMSaida	:= 0
Local lGravouCFD:= .F.
Local lGrvReg	:= .F.
Local aInfFPrd	:= {}
Local cMes		:= Alltrim( StrZero( Month( dDataDe ) , 2 ) )
Local cAno		:= Alltrim( Str( Year ( dDataDe ) ) )
Local dPerRecal := CTOD("  /  /    ")
Local cMesRecal := ""
Local cAnoRecal := ""
Local _aRetPE001:= {}
Local lNewProd  := .F.
Local lProdFaix := aDadosINI[INI_USAFCI]

aSize ( aInfFPrd , 0 )

/*-------------------------------------------------------------------------------------------
	No caso de utilizar Ponto de Entrada, forneco Produto e Periodo para que o PE retorne
	o valor da parcela importada, valor da saidas e Conteudo de Importacao.
	
	Nao faco os processamentos comuns da rotina, apenas utilizo o retorno do PE.
	
	Estrutura do array
	
	_aRetPe001:
		[1] - Valor da Parcela Importada
		[2] - Valor das Saidas
-------------------------------------------------------------------------------------------*/

If ExistBlock( "FCIPROC001" )

	_aRetPE001	:=	ExecBlock( "FCIPROC001" , .F. , .F. , { aDadosINI[INI_CODPRO] , dDataDe , dDataAte  } )
	
	If _aRetPE001[2] > 0
	
		aAdd(aInfFPrd,{xFilial("CFD")	,;		//-> Filial
						 aDadosINI[INI_CODPRO],;	//-> Codigo do Produto
						 ""					,;		//-> Ordem de Producao
						 _aRetPE001[1]	,;		//-> Valor da Parcela de Importacao
						 _aRetPE001[2]	,;		//-> Valor de Saida Interestadual
						 1					,;		//-> Quantidade usada para ponderacao
						 "" 				} )		//-> Filial da Op
	Endif


/*-------------------------------------------------------------------------------------------
	Executo uma consulta no periodo das vendas, a fim de apurar a media ponderada das saidas

   	Esta consulta possui uma quebra por Lote+SubLote alem do produto, essa situacao sera
   	tratada no momento de gravar as informacoes na CFD.
-------------------------------------------------------------------------------------------*/
Elseif x061GetQry( @cAlsQry , { aDadosINI[INI_CODPRO] , FirstDay( SToD( aDadosINI[INI_DTVEN] ) ) , LastDay( SToD( aDadosINI[INI_DTVEN] ) ) } , , "APU" )


		/*-------------------------------------------------------------------------------------------				
		   Conforme Legislacao, devo considerar os valores de saidas interestaduais para efeito de
		   calculo, apenas s enao houver esse tipo de operacao, considero as saidas internas.
	    -------------------------------------------------------------------------------------------*/
	    While !( cAlsQry )->( Eof () )
			nVSaiIE		+=	(cAlsQry)->SAIDA_IE // Valor das saidas interestaduais
	    	nQntIE		+=	(cAlsQry)->QUANT_IE // Quantidade das saidas interestaduais
	    	nVSaiIN		+=	(cAlsQry)->SAIDA_IN // Valor das saidas internas
	    	nQntIN		+=	(cAlsQry)->QUANT_IN // Quantidade das saidas internas
	    	(cAlsQry)->(DbSkip())
	    EndDo
	    
	    nCmpVSai	:=	Iif( nVSaiIE > 0, nVSaiIE, nVSaiIN )
	    nCmpQnt		:=	Iif( nQntIE  > 0 , nQntIE,  nQntIN )
	    nVlMSaida	:=	Round( ( nCmpVSai / nCmpQnt ) , 2 )
	    
	    //-------------------------------------------------------------------
	    //  	                                                           	  /\
	    ( cAlsQry )->( DbGoTop () )		  //GoTop na query de apuracao	  ||
	    //							  									 	      	  ||
	    //-------------------------------------------------------------------*/
		
		/*-------------------------------------------------------------------------------------------				
									   		|	XFciGetVI()   |
			
			Funcao que calcula o Valor da Parcela Importada, conforme metodo configurado
			no parametro MV_FCICALC.
			
	    -------------------------------------------------------------------------------------------*/
		XFciGetVI(	aX6Content[MV_FCICALC]	,;	// 1 - Metodo de Calculo ( MV_FCICALC )
					cAlsQry 				,;	// 2 - Query da Apuracao
					nVlMSaida				,;	// 3 - Valor medio das saidas
					@aInfFPrd 				,;	// 4 - Array utilizado na gravacao da tabela CFD
					dDataDe 				,;	// 5 - Data Inicial da Apuracao
					dDataAte 				,;	// 6 - Data Final da Apuracao
					lNewProd				,;	// 7 - Indica que a apuracao sera para Produtos Novos (Nunca vendidos)
					aDadosINI            ) // 8 - Array c/ os dados da query "INI" pois nao posso manipular o Alias quando eh MultiThread
// ------------------------------------------

// ----- Tratamento para Produtos Novos -----

// ------------------------------------------
Elseif aX6Content[MV_ESTADO] $ aX6Content[MV_FCINWPR] 
	
	lNewProd := .T.
	nVlMSaida	:=	aDadosINI[INI_PRCVEN]

	// Caso não seja encontrado valor com as regras acima 
	//Verifico se houve apuração do produto novo no mês anterior e recupero o VSAIIE   
	If nVlMSaida == 0 					   
		//Trabalho a data para pesquisar o período anterior na CFD     
		dPerRecal := MonthSub(CTOD("01/"+cMes+"/"+"/"+cAno),1)						           
		cMesRecal :=  StrZero(Month( dPerRecal ),2) 						       
		cAnoRecal :=  Str(Year( dPerRecal ),4)                      
		//Tentativa de consulta na CFD para o período anterior     
		x061GetQry( @cAlsQryNov , {,cMesRecal+cAnoRecal,aDadosINI[INI_CODPRO],aDadosINI[INI_CODPRO],,"",,} , , "CFD" )
		//Recuperação do VSAIIE do período anterior para o período seguinte
		nVlMSaida := (cAlsQryNov)->CFD_VSAIIE
		(cAlsQryNov)->(dbCloseArea())
	EndIf

	XFciGetVI(	aX6Content[MV_FCICALC] ,;	// 1 - Metodo de Calculo ( MV_FCICALC )
				""     	 			  ,;	// 2 - Query de Produtos
				nVlMSaida				  ,;	// 3 - Valor medio das saidas
				@aInfFPrd 				  ,;	// 4 - Array utilizado na gravacao da tabela CFD
				dDataDe 				  ,;	// 5 - Data Inicial da Apuracao
				dDataAte 				  ,;	// 6 - Data Final da Apuracao
				lNewProd				  ,;	// 7 - Indica que a apuracao sera para Produtos Novos (Nunca vendidos)
				aDadosINI              )  // 8 - Array c/ os dados da query "INI" pois nao posso manipular o Alias quando eh MultiThread
Endif

/*------------------------------------------------------------------------------------------------------------
|                                                                                                            |
|                                                                                                            |
|											 Bloco de Gravacao                                         		 |
|                                                                                                            |
|                                                                                                            |
------------------------------------------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------------------
//									Begin Transaction
//-----------------------------------------------------------------------------------------
//Este comando define que as operacoes seguintes, delimitadas pelo comando END TRANSACTION, 
//devem ser processadas como uma transacao, ou seja, como um bloco unico e indivisivel. 
//Durante uma recuperacao de falha, todas as operacoes de manipulacao de dados realizadas 
//serao integralmente desfeitas, alem de prover isolamento entre acessos concorrentes 
//na mesma massa de dados. 
//-----------------------------------------------------------------------------------------

If Len( aInfFPrd ) > 0
	Begin Transaction
	
	x061OrdArr( aInfFPrd, cMes, cAno, @lGravouCFD, lNewProd, lJob, lProdFaix)
	
	End Transaction
Endif

// ----------------------------------------------------------
// Flag da mensagem que sera apresentada no Log de Processos
// ----------------------------------------------------------
If !lGrvReg
	lGrvReg	:=	lGravouCFD
Endif

// ---------------------------------------
// Fecha area da query de apuracao
// ---------------------------------------
If Select(cAlsQry) <> 0
	(cAlsQry)->(DbCloseArea())
Endif

Return lGrvReg

//-------------------------------------------------------------------
/*/{Protheus.doc} x061NewThd

Funcao responsavel pelo processamento em MultiThread.

@param cSemaphore -> Semaforo de processamento multithread.
        cJob        -> Nome do job (thread).
        cEmp        -> Empresa utilizada p/ abertura do ambiente.
		cFil        -> Filial utilizada p/ abertura do ambiente.
		
@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Function x061NewThd(cSemaphore,cJob,cEmp,cFil)

Local uParam1,uParam2,uParam3,uParam4
Local oError
Local bError := { |e| oError := e , Break(e) }
Local bErrorBlock := ErrorBlock( bError )
Local lError := .F.
Local cHoraIni := Time()
//Local cHoraFim := ""
Local nReg := 0
Local cLogFile := ""
//Local cHrProdIni := "" 

PutGlbValue( cJob , "0" ) // Inicializando...
GlbUnLock()

RpcSetType(3) 
RpcSetEnv(cEmp,cFil)

BEGIN SEQUENCE

	SM0->(DbGoTop ())
	SM0->(MsSeek (cEmp+cFil, .T.))
	
	cFilAnt := FWGETCODFILIAL
	cLogFile := xFCILogName(cJob)
	
	// Fazendo o cache pois a nova thread não enxerga os STATICS já preenchidos.
	x061LoadCache(.T.)

	While !KillApp()
	
		PutGlbValue( cJob , "1" ) // 1 - Aguardando Chamada
		GlbUnLock()
		
		/*------------------------------------------------------------------------------
		
		 Parametros IPCWaitEx:
		 
		 Estes parametros (a partir do 3) sao passados a partir da chamada de IPCGO(), 
		 e sao a "entrada" de dados na thread, ou seja, sao utilizados para a passagem
		 de valores entre a thread "principal" e as demais. Dados utilizados na funcao
		 x061PrFCI devem ser passados desta forma, e nao na funcao x061NewThd pois a
		 nova thread nao ira reconhecer os parametros da funcao x061NewThd.
		 
		 1 - Semaforo (Padrao). 						Não Alterar
		 2 - Tempo de TimeOut (Padrao). 				Não Alterar.
		 3 - uParam1: Mensagem p/ controle de execucao. Não alterar.
		 
		 4 - uParam2: Array aDadosINI
		 5 - uParam3: dDataDe
		 6 - uParam4: dDataAte
		
		-------------------------------------------------------------------------------*/
		
		If IPCWaitEx(cSemaphore, aX6Content[MV_FCITOUT], @uParam1, @uParam2, @uParam3, @uParam4)
										
			If AllTrim(uParam1) == "EXIT"
				
				PutGlbValue( cJob , "4" ) // 4 - Finalizada
				GlbUnLock()
								
				xFCIProcLog(cLogFile,;
							 PULALINHA + ;
							 "----------------------------------------------------------------------" + PULALINHA + ;
							 "                                 RESUMO                               " + PULALINHA + ;
							 "----------------------------------------------------------------------" + PULALINHA + ;
							 "Inicio: " + cHoraIni + PULALINHA + ;
							 "Fim:    " + Time() + PULALINHA + ;
							 "Registros Gravados: " + cValToChar(nReg) + PULALINHA + ;
							 "----------------------------------------------------------------------")
				Exit
			EndIf	
			
			PutGlbValue( cJob , "2" ) // 2 - Processando...
			GlbUnLock()										
			
			// Chamada da função x061PrFCI para efetuar o cálculo do CI.
			If x061PrFCI(uParam2, uParam3, uParam4)
				nReg++
				PutGlbVars("FCIGRAVADOS", nReg)					
				xFCIProcLog(cLogFile, uParam2[INI_CODPRO] + uParam2[INI_DESCPRO])
			EndIf

		Else
		
			PutGlbValue( cJob , "1" ) // Timeout - Retorna p/ "Aguardando Chamada"
			GlbUnLock()
			Exit
			
		Endif
	
	EndDo
	
RECOVER
	lError := .T.
END SEQUENCE

ErrorBlock( bErrorBlock )

If lError
	PutGlbValue( cJob , "3" ) // 3 - Erro no processamento
	GlbUnLock()
	xFCIProcLog(cLogFile,STR0093				+ PULALINHA +; // "************* ERRO DE PROCESSAMENTO *************"
	         	 	      oError:Description 	+ PULALINHA +; 
	         	 	      oError:ErrorStack		+ PULALINHA +; // "************* ERRO DE PROCESSAMENTO *************"
	         	 	      STR0093)
	ConOut(oError:Description + '-' + oError:ErrorStack)
EndIf

RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x061IniThd

Inicializa as threads utilizadas no processamento MultiThread. 

@param cSemaphore -> Semaforo de processamento multithread.
        nQtdThd    -> Quantidade de threads utilizadas no processamento.        

@return aRet -> Array com as informacoes das threads criadas.

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061IniThd(cSemaphore,nQtdThd)

Local aRet := {}
Local nThread := 0
Local nPos := 0
Local nErros := 0
Local cLogFile := ""
Local nTry := 0
Local nMaxTry := 300

For nThread := 1 to nQtdThd

	cJob := "FISA061" + StrZero(nThread, 2)
	cLogFile := xFCILogName(cJob)  
	
	StartJob("x061NewThd",GetEnvServer(),.F.,cSemaphore,cJob,cEmpAnt,cFilAnt)
	
	// Alimentando array com as informações da(s) thread(s) criada(s).
	aAdd(aRet, {})
	nPos := Len(aRet)
	aAdd(aRet[nPos], cJob) 	   // 01 - Nome do Job
	aAdd(aRet[nPos], cLogFile) // 02 - Arquivo de Log de Processamento da Thread.
	
	// Verifica se o arquivo de LOG ja existe. Se existir, exclui.
	If File(cLogFile)
		fErase(cLogFile)
	EndIf
	
	// Gero o cabecalho do arquivo.
	xFCIProcLog(cLogFile,;
	 			 PULALINHA + ;
				 "-----------------------------------------------------------------------" 	+ PULALINHA + ;
				 "                              THREAD " + cJob                      	 	+ PULALINHA + ;
				 "-----------------------------------------------------------------------"	+ PULALINHA + ;
				 PULALINHA + ;
				 STR0092 																				+ PULALINHA + ; // "PRODUTOS PROCESSADOS: "
				 PULALINHA)
Next nThread

// Verifica se todas as threads foram inicializadas e estao aguardando chamada (Status = 1)
// Enquanto isso nao acontecer, espera 1s e tenta novamente.
While IpcCount(cSemaphore) <> nQtdThd .Or. x061ChkThd(aRet, @nErros) <> nQtdThd
	
	// Se alguma das threads nao for inicializada zero o array pois vou abortar o processamento.
	// nTry sera incrementado a cada segundo. Tempo maximo p/ inicializacao: 5 minutos.
	If nErros > 0 .Or. nTry == nMaxTry
		aRet := {}
		Exit
	Else
		Sleep(1000)
		nTry++
	EndIf
	
EndDo

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x061ChkThd

Retorna a quantidade de threads disponiveis, no status 1 - Aguardando 
Chamada e contabiliza as threads no status 3 - Erro de Processamento.

@param aThreads   -> Array com os dados de todas as threads.
        nTotErro   -> Contador das threads que apresentaram erro.

@return nRet -> Quantidade de threads no status 1 - Aguardando Chamada

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061ChkThd(aThreads, nTotErro)

Local nThread := 0
Local nRet := 0

nTotErro := 0

For nThread := 1 to Len(aThreads)
		
	cJob := aThreads[nThread][1]
		
	If GetGlbValue(cJob) == "1"
		nRet++
	ElseIf GetGlbValue(cJob) == "3"
		nTotErro++	
	EndIf
	
Next nThread		

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x061EndThd

Verifica se as threads finalizaram o processamento e envia o
IPCGo com "EXIT" para encerrar.

@param cSemaphore -> Semaforo de processamento multithread.
        aThreads   -> Array com os dados de todas as threads.
        nTotErro   -> Contador das threads que apresentaram erro.

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini 
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Static Function x061EndThd(cSemaphore, aThreads, nTotErro)

Local nThread := 0

ConOut(STR0077) // Verificando status das threads...
ConOut("")

For nThread := 1 to Len(aThreads)
		
	cJob := aThreads[nThread][1]
	
	While .T.
		
		Do Case
		
			// 1 - Aguardando Chamada (Ociosa). Posso enviar o IPCGO com "Exit" para Finalizar.
			Case GetGlbValue(cJob) == "1"
				
				ConOut(STR0078 + cJob + STR0079) // Processamento Finalizado.
				Exit
		
			// 2 - Thread ainda processando. Aguardar 5 segundos e tentar novamente.
			Case GetGlbValue(cJob) == "2"
				
				ConOut(STR0078 + cJob + STR0080) // Processando. Aguardando Finalizacao...
				Sleep(3000)
							
			// 3 - Erro de processamento. 
			Case GetGlbValue(cJob) == "3"
			
				ConOut(STR0078 + cJob + STR0081) // Encerrada por Erro no Processamento.
				nTotErro++
				Exit
				
			// 4 - Finalizada.
			Case GetGlbValue(cJob) == "4"
				
				ConOut(STR0078 + cJob + STR0082) // Encerrada.
				Exit

		EndCase
		
	EndDo

	ClearGlbValue(cJob)
	Sleep(1000)
		
Next nX

ConOut("")
ConOut(STR0083) // "Finalizando Threads..."
ConOut("")

While IpcCount(cSemaphore) > 0
	IPCGo(cSemaphore, "EXIT")
EndDo

ConOut(STR0084) // "Threads Finalizadas."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg()
@description Função que que irá fazer validações das perguntas iniciais
			   para geração do arquivo
@return	Mensagem de erro
@author pereira.weslley
@since 05/09/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ValidPerg(cDirJob, cArqJob)
	Local cLib		:= ''
	Local nRemType	:= GetRemoteType(@cLib)
	Local lHtml		:= Iif(nRemType == 5, .T., .F. )
	Local cMensagem	:= ''
	Local nCount	:= 0

	Default cArqJob		:= ""

	If Right(Alltrim(cDirJob),1) == "\" .And. Empty(cArqJob)
		nCount := Len(Alltrim(cDirJob))
		cDirJob := SubStr(Alltrim(cDirJob),1,nCount - 1) 
	Endif
	If Empty(cDirJob) .OR. (Len(Directory(cDirJob + cArqJob,"D")) == 0 .And. !lHtml )	//Verifica se o diretório informado é válido
		cMensagem	:= STR0103 //"É necessário informar um diretório local válido para geração do arquivo.""
	ElseIf "SYSTEM"$UPPER(cDirJob) .Or. VerifPath(Alltrim(cDirJob)) == VerifPath(GetSrvProfString("Startpath","")) 
		cMensagem	:= STR0104 //'Não é possível a geração do arquivo na pasta System, informe outro diretório local.'
	EndIf
Return cMensagem

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifPath()
@description Valida nome do diretorio selecionado para importação de arquivo, levando em consideração tambem se ambiente Linux
@return	Nome do diretorio padronizado
@author Thiago Yoshiaki Miyabara NAscimento - Shiny
@since 22/04/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function VerifPath(cPath)

Local cPathPosP := SubStr(cPath,1,1) //Primeira Posição do cPath
Local cPathPosU := SubStr(cPath,Len(cPath),1) //Ultima Posição do cPath

	//Tratamento para Linux onde a barra e invertida                      
	If GetRemoteType()==2 // REMOTE_LINUX  
		If (cPathPosP <> "/") .And. (cPathPosP <> "\")
			cPath	:=	"/"+cPath
		EndIf	
		If (cPathPosU <> "/") .And. (cPathPosU <> "\")
			cPath	+=	"/"
		EndIf
	Else    
		If (cPathPosP <> "\") .And. (cPathPosP <> "/")
			cPath	:=	"\"+cPath
		EndIf
		If (cPathPosU <> "\") .And. (cPathPosU <> "/")
			cPath	+=	"\"
		EndIf	                
	EndIf

Return Upper(cPath)
