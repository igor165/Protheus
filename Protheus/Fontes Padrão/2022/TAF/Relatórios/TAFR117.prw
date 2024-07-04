#Include "Protheus.Ch"
#INCLUDE "TAFR117.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

//Grupos do Evento Tribut�rio
#DEFINE GRUPO_RESULTADO_OPERACIONAL	 	1		//Resultado Cont�bil - Operacional
#DEFINE GRUPO_RESULTADO_NAO_OPERACIONAL	2		//Resultado Cont�bil - N�o operacional
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ1	 	 	3		//Receita Bruta - Al�quota 1
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ2	 	 	4		//Receita Bruta - Al�quota 2
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ3	 	 	5		//Receita Bruta - Al�quota 3
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ4			6		//Receita Bruta - Al�quota 4
#DEFINE GRUPO_DEMAIS_RECEITAS	 	 		7		//Demais Receitas
#DEFINE GRUPO_BASE_CALCULO	 				8		//Base de C�lculo
#DEFINE GRUPO_ADICOES_LUCRO		 			9		//Adi��es do Lucro
#DEFINE GRUPO_ADICOES_DOACAO				10		//Adi��es por Doa��o
#DEFINE GRUPO_EXCLUSOES_LUCRO				11		//Exclus�es do Lucro
#DEFINE GRUPO_EXCLUSOES_RECEITA				12		//Exclus�es da Receita
#DEFINE GRUPO_COMPENSACAO_PREJUIZO			13		//Compensa��o de Preju�zo
#DEFINE GRUPO_DEDUCOES_TRIBUTO				14		//Dedu��es do Tributo
#DEFINE GRUPO_COMPENSACAO_TRIBUTO			15		//Compensa��o do Tributo
#DEFINE GRUPO_ADICIONAIS_TRIBUTO			16		//Adicionais do Tributo
#DEFINE GRUPO_RECEITA_LIQUIDA_ATIVIDA		17		//Receita L�quida p/Atividade
#DEFINE GRUPO_LUCRO_EXPLORACAO				18		//Lucro da Explora��o

//Par�metros do Array de Grupos
#DEFINE PARAM_GRUPO_ID					1
#DEFINE PARAM_GRUPO_NOME					2
#DEFINE PARAM_GRUPO_DESCRICAO			3
#DEFINE PARAM_GRUPO_TIPO					4

//Par�metros Apura��o
/*Todos os define dos Grupos do Evento Tribut�rio
GRUPO_RESULTADO_OPERACIONAL	 		1		//Resultado Cont�bil - Operacional
GRUPO_RESULTADO_NAO_OPERACIONAL		2		//Resultado Cont�bil - N�o operacional
GRUPO_RECEITA_BRUTA_ALIQ1	 	 	3		//Receita Bruta - Al�quota 1
GRUPO_RECEITA_BRUTA_ALIQ2	 	 	4		//Receita Bruta - Al�quota 2
GRUPO_RECEITA_BRUTA_ALIQ3	 	 	5		//Receita Bruta - Al�quota 3
GRUPO_RECEITA_BRUTA_ALIQ4			6		//Receita Bruta - Al�quota 4
GRUPO_DEMAIS_RECEITAS	 	 		7		//Demais Receitas
GRUPO_BASE_CALCULO	 				8		//Base de C�lculo
GRUPO_ADICOES_LUCRO		 			9		//Adi��es do Lucro
GRUPO_ADICOES_DOACAO					10		//Adi��es por Doa��o
GRUPO_EXCLUSOES_LUCRO				11		//Exclus�es do Lucro
GRUPO_EXCLUSOES_RECEITA				12		//Exclus�es da Receita
GRUPO_COMPENSACAO_PREJUIZO			13		//Compensa��o de Preju�zo
GRUPO_DEDUCOES_TRIBUTO				14		//Dedu��es do Tributo
GRUPO_COMPENSACAO_TRIBUTO			15		//Compensa��o do Tributo
GRUPO_ADICIONAIS_TRIBUTO				16		//Adicionais do Tributo
GRUPO_RECEITA_LIQUIDA_ATIVIDA		17		//Receita L�quida p/Atividade
GRUPO_LUCRO_EXPLORACAO				18		//Lucro da Explora��o
Mais os listados abaixo*/
#DEFINE ALIQUOTA_RECEITA_1					19
#DEFINE ALIQUOTA_RECEITA_2					20
#DEFINE ALIQUOTA_RECEITA_3					21
#DEFINE ALIQUOTA_RECEITA_4					22
#DEFINE ALIQUOTA_IMPOSTO						23
#DEFINE ALIQUOTA_IR_ADICIONAL_IMPOSTO		24
#DEFINE PARCELA_ISENTA						25
#DEFINE INICIO_PERIODO						26
#DEFINE FIM_PERIODO							27
#DEFINE ITENS_PROPORCAO_DO_LUCRO			28
//Parametros dos itens da propor��o do lucro
	#DEFINE PROUNI								1
	#DEFINE PERCENTUAL_REDUCAO					2
	#DEFINE TIPO_ATIVIDADE						3
	#DEFINE VALOR									4
	#DEFINE ID_TABELA_ECF						5
	#DEFINE ORIGEM								6
	#DEFINE ID_TABELA_ECF_DED					7
#DEFINE TIPO_TRIBUTO							29
#DEFINE POEB									30
#DEFINE PERCENTUAL_COMP_PREJU				31
#DEFINE VLR_DEVIDO_PERIODOS_ANTERIORES		32
#DEFINE VLR_PAGO_PERIODOS_ANTERIORES		33
#DEFINE VLR_PREJUIZO_OPERACIONAL			34
#DEFINE VLR_PREJUIZO_NAO_OPERACIONAL		35
#DEFINE VLR_PREJUIZO_COMP_NO_PERIODO		36

//Tributos
#DEFINE TIPO_TRIBUTO_IRPJ	"000019"
#DEFINE TIPO_TRIBUTO_CSLL	"000018"

//Paramentros de impress�o do relatorio
#DEFINE PAR_RELATORIO_GRUPO			1
#DEFINE PAR_RELATORIO_COD_ECF		2
#DEFINE PAR_RELATORIO_ORIGEM		3
#DEFINE PAR_RELATORIO_DESCRICAO		4
#DEFINE PAR_RELATORIO_VALOR			5
#DEFINE PAR_RELATORIO_RURAL			6

//Grupos do relat�rio de apura��o
#DEFINE GRUPO_REL_LAIR					1
#DEFINE GRUPO_REL_CABECALHO				2
#DEFINE GRUPO_REL_ADICOES				3
#DEFINE GRUPO_REL_EXCLUSOES				4
#DEFINE GRUPO_REL_COMP_PREJ				5
#DEFINE GRUPO_REL_ADICIONAIS_TRIB		6
#DEFINE GRUPO_REL_DEDUCOES_TRIBUTO		7
#DEFINE GRUPO_REL_COMP_TRIBUTO			8
#DEFINE GRUPO_REL_IMPOSTO_A_PAGAR		9
#DEFINE GRUPO_REL_RECEITA_LIQ_ATIV		10
#DEFINE GRUPO_REL_LUCRO_EXPLORACAO		11

//Origem
#DEFINE ORIGEM_CONTA_CONTABIL		'1'		//Conta Cont�bil
#DEFINE ORIGEM_LALUR_PARTE_B		'2'		//Lalur - Parte B
#DEFINE ORIGEM_EVENTO_TRIBUTARIO	'3'		//Evento Tribut�rio
#DEFINE ORIGEM_LANCAMENTO_MANUAL	'4'		//Lan�amento Manual
#DEFINE ORIGEM_APURACAO				'5'		//Apura��o

/*/{Protheus.doc} TAFR117
Relat�rio do LALUR parte A gerado a partir de um per�odo de apura��o
@author david.costa
@since 03/05/2017
@version 1.0
@param aParametro, array, par�metros da Apura��o
@param aDadosRel, array, Dados do relat�rio para impress�o
@param cLogErros, character, Log de erros do processo
@param oModelPeri, object, Model do per�odo de apura��o com os valores j� apurados
@param aParRural, array, par�metros da Apura��o
@return ${Nil}, ${Nulo}
/*/Function TAFR117( aParametro, aDadosRel, cLogErros, oModelPeri, aParRural )

Local nPrintType as numeric
Local nLocal     as numeric
Local oSetup     as object
Local aDevice	 as array

//Variaveis necessarias para o Objeto FwPrintsetup() que define as opcoes para a emissao do relatorio
Local cSession		:= GetPrinterSession()
Local cDevice		:= GetProfString( cSession, "PRINTTYPE", "SPOOL", .T. )
Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPREVIEW+PD_DISABLEPAPERSIZE
Local cIdTrib		:= ""

Private cTitulo		:= ""
Private oPrint		as object
Private cTitRel 	:= ""

aDevice := {}

//Define os Tipos de Impressao validos para este relat�rio
AADD(aDevice,"DISCO")
AADD(aDevice,"SPOOL")
AADD(aDevice,"EMAIL")
AADD(aDevice,"EXCEL")
AADD(aDevice,"HTML" )
AADD(aDevice,"PDF"  )

//Realiza as configuracoes necessarias para a impressao
nPrintType := aScan(aDevice,{|x| x == cDevice })
nLocal     := If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
//Realizo poscione para saber qual o tributo que ser� impresso
cIdTrib    := Posicione( "T0J", 1, xFilial( "T0J" ) + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ), "T0J->T0J_TPTRIB" )

If cIdTrib $ "000018|000027"
	cTitulo := STR0051
	cTitRel := STR0052
Else
	cTitulo := STR0002
	cTitRel := STR0025
Endif

oSetup := FWPrintSetup():New( nFlags, STR0003 ) //"Par�metros para impress�o"
oSetup:SetUserParms( {|| .T. } )
oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
oSetup:SetPropert(PD_ORIENTATION , 1)
oSetup:SetPropert(PD_DESTINATION , nLocal)
oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
oSetup:SetPropert(PD_PAPERSIZE   , 2) //A4

oPrint := FWMSPrinter():New( cTitulo, IMP_PDF , .F., , .T., , oSetup )

//Confirmando a tela de Configuracao eu inicio a Impressao do Relatorio
If oSetup:Activate() == PD_OK
	
	MsgRun( STR0004, "", {|| CursorWait(), GerarRel( oSetup, aDadosRel, aParametro, oModelPeri, aParRural ) ,CursorArrow() } )   //Gerando Relat�rio			
Else
	AddLogErro( STR0005, @cLogErros ) //"Relat�rio cancelado pelo usu�rio."
	oPrint:Deactivate()  //Libera o arquivo criado da memoria para que possa ser usado novamente caso o usuario entre na rotina de novo.
EndIf

Return( Nil )

/*/{Protheus.doc} GerarRel
Fun��o para gerar o Relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param oSetup, object, Obejeto com os default da impress�o
@param aDadosRel, array, Dados do relat�rio para impress�o
@param aParametro, array, par�metros da Apura��o
@param oModelPeri, object, Model do per�odo de apura��o com os valores j� apurados
@param aParRural, array, par�metros da Apura��o
@return ${Nil}, ${Nulo}
/*/Static Function GerarRel( oSetup, aDadosRel, aParametro, oModelPeri, aParRural )

Local nLinha		as numeric
Local nColuna		as numeric
Local nIndice		as numeric

//Fator de propor��o da Pagina
Local nFatorLarg	as numeric
Local nFatorAltu	as numeric
Local nVlrImp 		as numeric

Private oArial01		as object
Private oArial02		as object
Private oFont01		as object
Private nLargurPag 	as numeric
Private nAlturaPag	as numeric
Private aDadosCabe	as array

aDadosCabe := {}
nLinha		:= oSetup:GetProperty(PD_MARGIN)[2]
nColuna	:= oSetup:GetProperty(PD_MARGIN)[1]
nIndice	:= 0
nFatorLarg	:= 4.04
nFatorAltu	:= 3.77
oArial01	:= TFont():New( "Calibri", 10, 10, , .T., , , , .T., .F. )
oArial02	:= TFont():New( "Calibri", 10, 10, , .F., , , , .T., .F. )
oFont01	:= TFont():New( "Calibri", 13, 13, , .T., , , , .T., .F. )
nVlrImp := 0

//Define saida de impress�o
If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
	oPrint:nDevice := IMP_SPOOL
	WriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
	oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]

ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
	oPrint:nDevice := IMP_PDF
	oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
Endif

oPrint:StartPage()

nLargurPag := ( oPrint:nPageWidth / nFatorLarg ) - oSetup:GetProperty(PD_MARGIN)[1] - oSetup:GetProperty(PD_MARGIN)[3]
nAlturaPag := ( oPrint:nPageHeight / nFatorAltu ) - oSetup:GetProperty(PD_MARGIN)[2]

//Cabe�alho
aDadosCabe := aDadosRel[ aScan( aDadosRel, { |x| x[ PAR_RELATORIO_GRUPO ] == GRUPO_REL_CABECALHO } ) ]
GetCabeRel( @nLinha, oSetup )

/*Paginna Completa (Referencia A4 Retrato)
oPrint:Box( 1, 1, 841, 594, "-4")*/

If !Empty( Posicione( "T0N", 1, xFilial( "T0N" ) + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ), "T0N->T0N_IDEVEN" ) )
	oPrint:Box( nLinha, nColuna, nLinha + 20, nColuna + nLargurPag, "-4")
	oPrint:SayAlign( nLinha + 5, nColuna + 2, STR0043, oArial01, nLargurPag, 20, , 0, 0) //"ATIVIDADE GERAL"
	nLinha += 20
EndIf

AddBaseCalc( @nLinha, @oSetup, @aDadosRel, @aParametro, .F., oModelPeri )

If !Empty( Posicione( "T0N", 1, xFilial( "T0N" ) + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ), "T0N->T0N_IDEVEN" ) )
	oPrint:Box( nLinha, nColuna, nLinha + 20, nColuna + nLargurPag, "-4")
	oPrint:SayAlign( nLinha + 5, nColuna + 2, STR0044, oArial01, nLargurPag, 20, , 0, 0) //"ATIVIDADE RURAL"
	nLinha += 20
	
	AddBaseCalc( @nLinha, @oSetup, @aDadosRel, @aParRural, .T., oModelPeri )
	AddTotGrup( @nLinha, STR0045, VlrLucReal( aParametro, aParRural ), oSetup ) //"BASE DE C�LCULO (ATIVIDADE GERAL + ATIVIDADE RURAL) "
EndIf

//Imposto apurado
EstimarPag( aDadosRel, @nLinha, oSetup )
oPrint:Box( nLinha, nColuna, nLinha + 20, nColuna + nLargurPag, "-4")
oPrint:SayAlign( nLinha + 5, nColuna + 2, Iif( aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ, STR0019, STR0035 ), oArial01, nLargurPag, 20, , 0, 0) //"IMPOSTO DE RENDA APURADO"; "CONTRIBUI��O SOBRE O LUCRO L�QUIDO APURADA"
nLinha += 20

if VlrLucReal( aParametro, aParRural ) > 0; nVlrImp := VlrBCxAliq( aParametro, aParRural ); endif
AddTotGrup( @nLinha, FormatStr( STR0020, { AllTrim( TRANSFORM( aParametro[ ALIQUOTA_IMPOSTO ] * 100, "@E 999,999,999,999.99" ) ) } ), nVlrImp, oSetup, 10, oArial01 ) //"Al�quota de @1%"

If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
	AddTotGrup( @nLinha, FormatStr( STR0021, { AllTrim( TRANSFORM( aParametro[ ALIQUOTA_IR_ADICIONAL_IMPOSTO ] * 100, "@E 999,999,999,999.99" ) ) } ), VlrAdiciIR( aParametro, aParRural ), oSetup, 10, oArial01 ) //"Adicional ( al�quota @1% )"
EndIf

AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_ADICIONAIS_TRIB, STR0033 )//"ADICIONAIS DO TRIBUTO"
AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_RECEITA_LIQ_ATIV, STR0049 )//"RECEITA L�QUIDA POR ATIVIDADE"
AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_LUCRO_EXPLORACAO, STR0050 )//"LUCRO DA EXPLORACAO"
AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_DEDUCOES_TRIBUTO, STR0022 )//"DEDU��ES"

If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ .and. oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )
	AddItemGru( @nLinha, oSetup, { ,"N630.24", " ", STR0037, AllTrim( TRANSFORM( aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ], "@E 999,999,999,999.99" ) ) }, oArial01 )//"(-) Imposto de Renda Mensal Pago por Estimativa"
ElseIf aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
	AddItemGru( @nLinha, oSetup, { ,"N620.20", " ", STR0031, AllTrim( TRANSFORM( aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ], "@E 999,999,999,999.99" ) ) }, oArial01 )//"(-) Imposto de Renda Devido em Meses Anteriores"
	
	if ( nVlrImp := VlrDeviMes(aParametro) ) < 0; nVlrImp := 0; endif	
	AddItemGru( @nLinha, oSetup, { ,"N620.20.01", " ", STR0032, AllTrim( TRANSFORM( nVlrImp, "@E 999,999,999,999.99" ) ) }, oArial01 )	//"(-) Imposto de Renda Devido no M�s"
ElseIf aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_CSLL .and. oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )
	AddItemGru( @nLinha, oSetup, { ,"N670.19", " ", STR0038, AllTrim( TRANSFORM( aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ], "@E 999,999,999,999.99" ) ) }, oArial01 )//"(-) CSLL Mensal Paga por Estimativa"
ElseIf aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_CSLL
	AddItemGru( @nLinha, oSetup, { ,"N660.12", " ", STR0039, AllTrim( TRANSFORM( aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ], "@E 999,999,999,999.99" ) ) }, oArial01 )//"(-) CSLL Devida em Meses Anteriores"
	
	if ( nVlrImp := VlrDeviMes(aParametro) ) < 0; nVlrImp := 0; endif	
	AddItemGru( @nLinha, oSetup, { ,"N660.12.01", " ", STR0040, AllTrim( TRANSFORM( nVlrImp, "@E 999,999,999,999.99" ) ) }, oArial01 )	//"CSLL Devida no M�s"
EndIf

AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_COMP_TRIBUTO, STR0023 )//"COMPENSA��ES DO TRIBUTO"
AddTotGrup( @nLinha, Iif( aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ, STR0024, STR0036 ),;
			 aDadosRel[ aScan( aDadosRel, { |x| x[ PAR_RELATORIO_GRUPO ] == GRUPO_REL_IMPOSTO_A_PAGAR } ) ][ PAR_RELATORIO_VALOR ], oSetup ) //"IMPOSTO DE RENDA A PAGAR"; "CSLL � PAGAR"

oPrint:EndPage()

oPrint:Preview()

Return( Nil )

/*/{Protheus.doc} AddGrupRel
Adiciona um Grupo ao Relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param nLinha, numeric, N�mero da linha no relat�rio
@param oSetup, object, Obejeto com os default da impress�o
@param aDadosRel, array, Dados do relat�rio para impress�o
@param nGrupo, numeric, Id do Grupo
@param cCabecalho, character, Descri��o do Cabe�alho, se for passado em branco n�o ser� gerado cabe�alho para o Grupo
@param cDescTotal, character, Descri��o da Linha total do grupo, se for passado em branco n�o ser� gerado o total
@param nTotal, numeric, Valor total do Grupo
@return ${Nil}, ${Nulo}
@example
AddGrupRel( @nLinha, oSetup, aDadosRel, nGrupo, cCabecalho, cDescTotal, nTotal, lRural )
/*/Static Function AddGrupRel( nLinha, oSetup, aDadosRel, nGrupo, cCabecalho, cDescTotal, nTotal, lRural )

Local nIndice as numeric
Local nColuna := oSetup:GetProperty(PD_MARGIN)[1]

Default cCabecalho := ""
Default lRural := .F.

If aScan( aDadosRel, { |x| x[ PAR_RELATORIO_GRUPO ] == nGrupo } ) > 0
	//cabe�alho do grupo
	If !Empty( cCabecalho )
		oPrint:Box( nLinha, nColuna, nLinha + 20, nColuna + nLargurPag, "-4")
		oPrint:SayAlign( nLinha + 5, nColuna + 2, cCabecalho, oArial01, nLargurPag, 20, , 0, 0)
		nLinha += 20
	EndIf
	
	For nIndice := 1 to Len( aDadosRel )
		If nGrupo == aDadosRel[ nIndice, PAR_RELATORIO_GRUPO ] .and. lRural == aDadosRel[ nIndice, PAR_RELATORIO_RURAL ]
			AddItemGru( @nLinha, oSetup, aDadosRel[ nIndice ] )
		EndIf
	Next nIndice
	
	AddTotGrup( @nLinha, cDescTotal, nTotal, oSetup, 10 )
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddItemGru
Adiciona um item ao Grupo do Relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param nLinha, numeric, N�mero da linha no relat�rio
@param oSetup, object, Obejeto com os default da impress�o
@param aDados, array, Dados do relat�rio para impress�o
@param oFonte, object, Fonte para o item
@return ${Nil}, ${Nulo}
@example
AddItemGru( @nLinha, oSetup, aDados, oFonte )
/*/Static Function AddItemGru( nLinha, oSetup, aDados, oFonte )

Local nColuna := oSetup:GetProperty(PD_MARGIN)[1]
Default oFonte := oArial02

If nLinha >= nAlturaPag
	QuebraPag( @nLinha, oSetup )
EndIf

oPrint:Box( nLinha, nColuna, nLinha + 10, nColuna + 50, "-4")
oPrint:Say( nLinha + 8, nColuna + 2, aDados[ PAR_RELATORIO_COD_ECF ], oFonte )
oPrint:Box( nLinha, nColuna + 50, nLinha + 10, nColuna + 150, "-4")
oPrint:Say( nLinha + 8, nColuna + 52, aDados[ PAR_RELATORIO_ORIGEM ], oFonte )
oPrint:Box( nLinha, nColuna + 150, nLinha + 10, nLargurPag + nColuna - 80, "-4")
oPrint:Say( nLinha + 8, nColuna + 152, aDados[ PAR_RELATORIO_DESCRICAO ], oFonte )
oPrint:Box( nLinha, nLargurPag + nColuna - 80, nLinha + 10, nLargurPag + nColuna, "-4")
oPrint:SayAlign( nLinha, nLargurPag + nColuna - 78, aDados[ PAR_RELATORIO_VALOR ], oFonte, 76, 10, , 1, 0)
nLinha += 10

Return( Nil )

/*/{Protheus.doc} AddTotGrup
Adiciona o total a um Grupo do Relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param nLinha, numeric, N�mero da linha no relat�rio
@param cDescTotal, character, Descri��o da Linha total do grupo, se for passado em branco n�o ser� gerado o total
@param nTotal, numeric, Valor total do Grupo
@param oSetup, object, Obejeto com os default da impress�o
@param nAltura, numeric, Valor para a altura do quadro (default 20)
@param oFonte, object, Fonte para o item
@return ${Nil}, ${Nulo}
@example
AddTotGrup( @nLinha, cDescTotal, nTotal, oSetup, nAltura, oFonte )
/*/Static Function AddTotGrup( nLinha, cDescTotal, nTotal, oSetup, nAltura, oFonte )

Local nColuna := oSetup:GetProperty(PD_MARGIN)[1]
Default oFonte := oArial01
Default nAltura := 20

If !Empty( cDescTotal )
	oPrint:Box( nLinha, nColuna, nLinha + nAltura, nColuna + nLargurPag - 78, "-4")
	oPrint:Say( nLinha + 8, nColuna + 2, cDescTotal, oFonte )
	oPrint:Box( nLinha, nLargurPag + nColuna - 80, nLinha + nAltura, nLargurPag + nColuna, "-4")
	oPrint:SayAlign( nLinha, nLargurPag + nColuna - 78, Alltrim( TRANSFORM( nTotal, "@E 999,999,999,999.99" ) ), oFonte, 76, nAltura, , 1, 0)
	nLinha += nAltura
EndIf

Return( Nil )

/*/{Protheus.doc} FormatStr
Formata uma string conforme os parametros passados
@author david.costa
@since 03/05/2017
@version 1.0
@param cTexto, character, Mensagem para que ser� formatada
@param aParam, Array, Array com valores para sibstituir variav�is na mensagem, 
	as variaveis na mensagem dever�o iniciar com @ seguido de um sequencial
@return ${cTexto}, ${Mensagem tratada}
@example
FormatStr( "O valor @1 do campo @2 est� incorreto", { 38, "AAA_TESTES" } )
A mensagem ficar� gravada assim: "O valor 38 do campo AAA_TESTES est� incorreto"
/*/Static Function FormatStr( cTexto, aParam )

Local nIndice	as numeric

Default cTexto	:=	""
Default aParam	:=	{}

nIndice	:=	0

For nIndice := 1 To Len( aParam )
	If ValType( aParam[ nIndice ] ) == "N"
		aParam[ nIndice ] := Str( aParam[ nIndice ] )
	EndIf

	cTexto := StrTran( cTexto, "@" + AllTrim( Str( nIndice ) ), AllTrim( aParam[ nIndice ] ) )
Next nIndice

Return( cTexto )

/*/{Protheus.doc} GetCabeRel
Adiciona um cabe�alho na p�gina do relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param nLinha, numeric, N�mero da linha no relat�rio
@param oSetup, object, Obejeto com os default da impress�o
@return ${Nil}, ${Nulo}
@example
GetCabeRel( @nLinha, oSetup )
/*/Static Function GetCabeRel( nLinha, oSetup )

Local nColuna := oSetup:GetProperty(PD_MARGIN)[1]

oPrint:SayAlign( nLinha, nColuna, cTitRel, oFont01, nLargurPag, 10, , 2, 0)//"LALUR - PARTE A"
nLinha += 20
oPrint:Say( nLinha, nColuna, STR0026, oArial02 ) //"NOME EMPRESARIAL: "
oPrint:Say( nLinha, nColuna + 83, AllTrim(left(aDadosCabe[ 2 ], 45 ) ), oArial01 )
nColuna += 300
oPrint:Say( nLinha, nColuna, STR0027, oArial02 ) //"CNPJ: "
oPrint:Say( nLinha, nColuna + 24, aDadosCabe[ 3 ], oArial01 )
nLinha += 15
nColuna := oSetup:GetProperty(PD_MARGIN)[1]
oPrint:Say( nLinha, nColuna, STR0028, oArial02 ) //"PER�ODO DE APURA��O: "
oPrint:Say( nLinha, nColuna + 95, aDadosCabe[ 4 ], oArial01 )
nLinha += 15

//Cabe�alho do detalhamento
AddItemGru( @nLinha, oSetup, { GRUPO_REL_CABECALHO, STR0006, STR0007, STR0008, STR0009 }, oArial01 ) //"C�D. ECF";"ORIGEM";"DESCRI��O DO ITEM TRIBUT�RIO";"VALOR"

Return( Nil )

/*/{Protheus.doc} GetPerRel
Retorna a descri��o para o per�do do relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param aParametro, array, par�metros da Apura��o
@param oModelPeri, object, Model do per�odo de apura��o com os valores j� apurados
@return ${Nil}, ${Nulo}
@example
GetPerRel( aParametro, oModelPeri )
/*/Static Function GetPerRel( aParametro, oModelPeri )

Local cDescPer	as character
Local cTipoRel	as character

If oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )
	cTipoRel := STR0029	//"A00 - Anual"
Else 
	cTipoRel := ""
EndIf

cDescPer := FormatStr( "@1 � @2 @3", { dToc( aParametro[ INICIO_PERIODO ] ), dToc( aParametro[FIM_PERIODO] ), cTipoRel } )

Return( cDescPer )

/*/{Protheus.doc} SetDadosRe
Prepara o Array com os dados para impress�o do relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param aDadosRel, array, Dados do relat�rio para impress�o
@param aParametro, array, par�metros da Apura��o
@param oModelEven, object, Model do Evento Apurado
@param oModelPeri, object, Model do per�odo de apura��o com os valores j� apurados
@param aGrupos, array, Grupos do Evento
@param lSimula, booleano, Informa se o processo esta sendo executado por uma simula��o
@param aParRural, array, par�metros da Apura��o Atividade Rural
@return ${Nil}, ${Nulo}
/*/Static Function SetDadosRe( aDadosRel, aParametro, oModelEven, oModelPeri, aGrupos, lSimula, aParRural )

Local oModelCWX	 as object
Local oModelT0O	 as object
Local oModelLanM as object
Local nIndice	 as numeric
Local nIdGrupo	 as numeric
Local nValor	 as numeric
Local nIndcGrupo as numeric
Local nIndcFil	 as numeric
Local cCodECF	 as character
Local cOrigem	 as character
Local cDescricao as character
Local cDecFilial as character
Local aGrupo	 as array
Local aSM0		 as array
Local lRural	 as logical
Local cChaveT0O  as character
Local cIdCC		 as character
Local cIdParteB	 as character
Local cIDOutroEv as character

oModelCWX  := Nil
oModelT0O  := Nil
oModelLanM := Nil
aGrupo	   := {}
aSM0	   := {}
lRural	   := .F.
nIndice	   := 0
nIdGrupo   := 0
nValor	   := 0
nIndcGrupo := 0
cCodECF	   := ""
cOrigem	   := ""
cDescricao := ""
cDecFilial := ""
cChaveT0O  := ""
cIdCC	   := ""
cIdParteB  := ""
cIDOutroEv := ""

cDecFilial := Posicione( "C1E", 3, xFilial("C1E") + cFilant, "C1E_NOME" )

aSM0 := FWLoadSM0( .T. )
nIndcFil := aScan( aSM0, { |x| x[SM0_GRPEMP] == cEmpAnt .and. x[SM0_CODFIL] == cFilant } )

aAdd( aDadosRel, { GRUPO_REL_CABECALHO , AllTrim( cDecFilial ), TRANSFORM( Val( aSM0[ nIndcFil, SM0_CGC ] ), "@E 99,999,999/9999-99" ), GetPerRel( aParametro, oModelPeri ) } )

oModelCWX := oModelPeri:GetModel( "MODEL_CWX" )
oModelLanM := oModelEven:GetModel( "MODEL_LEC" )

For nIndice := 1 to oModelCWX:Length()
	oModelCWX:GoLine( nIndice )
	cIDOutroEv := ""	
	If !oModelCWX:IsDeleted()
		cDescricao := ""
		nIdGrupo := Val( Posicione( "LEE", 1, xFilial( "LEE" ) + oModelCWX:GetValue( "CWX_IDCODG" ), "LEE_CODIGO" ) )
		nIndcGrupo	:= aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == nIdGrupo } )
		If nIndcGrupo > 0
			aGrupo := aGrupos[ nIndcGrupo ]
			If nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA .or. nIdGrupo == GRUPO_LUCRO_EXPLORACAO
				cIDOutroEv := GetIdEvExp( oModelEven:GetValue( "MODEL_T0N", "T0N_ID" ) )
				cChaveT0O := xFilial( "T0O" )
				cChaveT0O += cIDOutroEv
				cChaveT0O += STR( nIdGrupo, 2 )
				cChaveT0O += oModelCWX:GetValue( "CWX_SEQITE" )
				T0O->( MsSeek( cChaveT0O ) )
				cIdCC := T0O->T0O_IDCC
				cIdParteB := T0O->T0O_IDPARB
				cDescricao := T0O->T0O_DESCRI
			Else
				oModelT0O := oModelEven:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] )
				oModelT0O:SeekLine( { { "T0O_IDGRUP", nIdGrupo }, { "T0O_SEQITE", oModelCWX:GetValue( "CWX_SEQITE" ) } } )
				cIdCC := oModelT0O:GetValue( "T0O_IDCC" )
				cIdParteB := oModelT0O:GetValue( "T0O_IDPARB" )
				cDescricao := oModelT0O:GetValue( "T0O_DESCRI" )
			EndIf
			
			If !Empty( oModelCWX:GetValue( "CWX_IDLAL" ) )
				cCodECF := AllTrim( Posicione( "CH8", 1, xFilial("CH8") + oModelCWX:GetValue( "CWX_IDLAL" ), "ALLTRIM(CH8_CODREG) + '.' + ALLTRIM(CH8_CODIGO)" ) )
			Else
				cCodECF := AllTrim( Posicione( "CH6", 1, xFilial("CH6") + oModelCWX:GetValue( "CWX_IDECF" ), "ALLTRIM(CH6_CODREG) + '.' + ALLTRIM(CH6_CODIGO)" ) )
			EndIf
			
			If oModelT0O:GetValue( "T0O_ORIGEM" ) == ORIGEM_EVENTO_TRIBUTARIO
				cOrigem := STR0048 // "Evento Tribut�rio"
			ElseIf oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_CONTA_CONTABIL
				cOrigem := AllTrim( Posicione( "C1O", 3, xFilial("C1O") + cIdCC ,"C1O_CODIGO" ) )
				If Empty( cDescricao )
					cDescricao := SubStr( Posicione( "C1O", 3, xFilial("C1O") + cIdCC ,"C1O_DESCRI" ), 1, 51 )
				Else
					cDescricao := SubStr( cDescricao, 1, 51 )
				EndIf
				
			ElseIf oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_LALUR_PARTE_B
				cOrigem := XFUNID2Cd( cIdParteB, "T0S", 1 )
				If Empty( cDescricao )
					cDescricao := SubStr( Posicione( "T0S", 1, xFilial("T0S") + cIdParteB ,"T0S->( AllTrim( T0S_DESCRI ) )" ), 1, 51 )
				Else
					cDescricao := SubStr( cDescricao, 1, 51 )
				EndIf
			ElseIf oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_LANCAMENTO_MANUAL

				cOrigem := STR0030	//"Lan�amento Manual"
				oModelLanM:SeekLine( { { "LEC_CODLAN", oModelCWX:GetValue( "CWX_SEQITE" ) } } )
				If !Empty(cIDOutroEv) 
					If !Empty(AllTrim(SubStr( Posicione( "LEC", 1, xFilial("LEC") + cIDOutroEv + oModelCWX:GetValue( "CWX_SEQITE" ),"LEC_HISTOR" ), 1, 51 )))
						cDescricao := SubStr( Posicione( "LEC", 1, xFilial("LEC") + cIDOutroEv + oModelCWX:GetValue( "CWX_SEQITE" ),"LEC_HISTOR" ), 1, 51 ) 
					Else 
						cDescricao := SubStr( Posicione("CH6",1, xFilial("CH6") + LEC->LEC_IDCODE,"CH6_DESCRI"),1,51)
					Endif
				ElseIf !Empty( oModelLanM:GetValue( "LEC_HISTOR" ) ) 
					cDescricao := SubStr( oModelLanM:GetValue( "LEC_HISTOR" ), 1, 51 )
				ElseIf !Empty( oModelCWX:GetValue( "CWX_IDLAL" ) )
					cDescricao := SubStr( Posicione( "CH8", 1, xFilial("CH8") + oModelCWX:GetValue( "CWX_IDLAL" ), "CH8_DESCRI" ), 1, 51 )
				Else
					cDescricao := SubStr( Posicione( "CH6", 1, xFilial("CH6") + oModelCWX:GetValue( "CWX_IDECF" ), "CH6_DESCRI" ), 1, 51 )
				EndIf
			ElseIf oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_APURACAO .and. "N620" $ cCodECF
				cOrigem := ""
				If ! lSimula
					aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ] := oModelCWX:GetValue( "CWX_VALOR" )
				EndIf
			EndIf
	
			nValor := oModelCWX:GetValue( "CWX_VALOR" )
			lRural := oModelCWX:GetValue( "CWX_RURAL" ) == "1"
			
			If nIdGrupo == GRUPO_RESULTADO_OPERACIONAL .or. nIdGrupo == GRUPO_RESULTADO_NAO_OPERACIONAL
				aAdd( aDadosRel, { GRUPO_REL_LAIR , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural } )
			ElseIf nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO
				aAdd( aDadosRel, { GRUPO_REL_ADICOES , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			ElseIf nIdGrupo == GRUPO_EXCLUSOES_LUCRO .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
				aAdd( aDadosRel, { GRUPO_REL_EXCLUSOES , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			ElseIf nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO
				aAdd( aDadosRel, { GRUPO_REL_COMP_PREJ , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO
				aAdd( aDadosRel, { GRUPO_REL_ADICIONAIS_TRIB , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			ElseIf nIdGrupo == GRUPO_DEDUCOES_TRIBUTO
				aAdd( aDadosRel, { GRUPO_REL_DEDUCOES_TRIBUTO , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			ElseIf nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO .and. !Empty( cOrigem )
				aAdd( aDadosRel, { GRUPO_REL_COMP_TRIBUTO , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			ElseIf nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA .and. !Empty( cOrigem )
				aAdd( aDadosRel, { GRUPO_REL_RECEITA_LIQ_ATIV , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			ElseIf nIdGrupo == GRUPO_LUCRO_EXPLORACAO .and. !Empty( cOrigem )
				aAdd( aDadosRel, { GRUPO_REL_LUCRO_EXPLORACAO , cCodECF, cOrigem, cDescricao, Alltrim( TRANSFORM( nValor, "@E 999,999,999,999.99" ) ), lRural  } )
			EndIf
			If ! lSimula
				If lRural
					aParRural[ nIdGrupo ] += nValor
				Else
					aParametro[ nIdGrupo ] += nValor
				EndIf
			EndIf
		EndIf
	EndIf
Next nIndice

aAdd( aDadosRel, { GRUPO_REL_IMPOSTO_A_PAGAR ,,,, oModelPeri:GetValue( "MODEL_CWV", "CWV_APAGAR" ) } )

Return( Nil )

/*/{Protheus.doc} RelApuraca
Gera o relat�rio do LALUR Parte A a partir dos models do evento e do periodo
@author david.costa
@since 03/05/2017
@version 1.0
@param oModelEven, object, Model do Evento Apurado
@param oModelPeri, object, Model do per�odo de apura��o com os valores j� apurados
@param cLogErros, character, Log de erros do processo
@return ${Nil}, ${Nulo}
@example
RelApuraca( oModelEven, oModelPeri, @cLogErros )
/*/Function RelApuraca( oModelEven, oModelPeri, cLogErros, aParametro, aParRural )

Local aDadosRel	as Array
Local aGrupos		as Array

Default aParametro	:= {}
Default aParRural		:= {}

aDadosRel	:= {}
aGrupos	:= {}

//Carrega os grupos do evento tribut�rio
aGrupos := GrupoEvnto( , .T. )

If Len( aParametro ) > 1
	//Para o relat�rio a data inicial ser� sempre a do per�odo
	aParametro[ INICIO_PERIODO ] := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
	aParRural[ INICIO_PERIODO ] := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
	
	//Prepara os dados para impress�o
	SetDadosRe( @aDadosRel, aParametro, oModelEven, oModelPeri, aGrupos, .T., @aParRural )
Else
	//Carrega os parametros da apura��o
	LoadParam( @aParametro, oModelPeri, oModelEven )
	LoadParam( @aParRural, oModelPeri, oModelEven )
	

	//Prepara os dados para impress�o
	SetDadosRe( @aDadosRel, @aParametro, oModelEven, oModelPeri, aGrupos,, @aParRural )
EndIf

If Empty( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ) )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_IDEVEN", oModelEven:GetValue( "MODEL_T0N", "T0N_ID" ) )
EndIf

TAFR117( aParametro, aDadosRel, @cLogErros, oModelPeri, aParRural )
		
Return( Nil )

/*/{Protheus.doc} QuebraPag
Adiciona uma nova pagina ao relat�rio
@author david.costa
@since 03/05/2017
@version 1.0
@param nLinha, numeric, N�mero da linha no relat�rio
@param oSetup, object, Obejeto com os default da impress�o
@return ${Nil}, ${Nulo}
@example
QuebraPag( nLinha, oSetup )
/*/Static Function QuebraPag( nLinha, oSetup )

nLinha := oSetup:GetProperty(PD_MARGIN)[2]

oPrint:EndPage()
oPrint:StartPage()

GetCabeRel( @nLinha, oSetup )

Return( Nil )

/*/{Protheus.doc} EstimarPag
Estima o tamanho do Quadro "IMPOSTO DE RENDA APURADO" e seus dependentes, se n�o coberem na mesma pagaina uma nova pagina � adicionada
@author david.costa
@since 03/05/2017
@version 1.0
@param aDadosRel, array, Dados do relat�rio para impress�o
@param nLinha, numeric, N�mero da linha no relat�rio
@param oSetup, object, Obejeto com os default da impress�o
@return ${Nil}, ${Nulo}
@example
EstimarPag( aDadosRel, nLinha, oSetup )
/*/Static Function EstimarPag( aDadosRel, nLinha, oSetup )

Local nDiponivel	as numeric
Local nNecessario	as numeric
Local nItensGrup	as numeric
Local nIndice		as numeric

nNecessario := 20		//Quadro "IMPOSTO DE RENDA APURADO"
nNecessario += 10		//Quadro Al�quota do imposto
nNecessario += 10		//Quadro Al�quota adicionar IR
nNecessario += 20		//Quadro "IMPOSTO DE RENDA A PAGAR"
nItensGrup := 0

For nIndice := 1 to Len( aDadosRel )
	If GRUPO_REL_DEDUCOES_TRIBUTO == aDadosRel[ nIndice, PAR_RELATORIO_GRUPO ]
		nItensGrup++
	EndIf
Next nIndice

nNecessario += 20						//Grupo "DEDU��ES" - Cabe�alho
nNecessario += 10 * nItensGrup		//Grupo "DEDU��ES" - Itens

nItensGrup := 0
For nIndice := 1 to Len( aDadosRel )
	If GRUPO_REL_COMP_TRIBUTO == aDadosRel[ nIndice, PAR_RELATORIO_GRUPO ]
		nItensGrup++
	EndIf
Next nIndice

nNecessario += 20						//Grupo "COMPENSA��ES DO TRIBUTO" - Cabe�alho
nNecessario += 10 * nItensGrup		//Grupo "COMPENSA��ES DO TRIBUTO" - Itens

nDiponivel := nAlturaPag - nLinha

If nNecessario > nDiponivel
	QuebraPag( @nLinha, oSetup )
EndIf

Return( Nil )

/*/{Protheus.doc} AddBaseCalc
Adiciona os campos e grupos referentes a 
@author david.costa
@since 22/12/2017
@version 1.0
/*/Static Function AddBaseCalc( nLinha, oSetup, aDadosRel, aParametro, lRural, oModelPeri )

AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_LAIR, STR0011, ;
		Iif( aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ, STR0010, STR0034 ), VlrResCont( aParametro ), lRural )//"LAIR";"Lucro antes do Imposto de Renda"; "Lucro antes da CSLL"
AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_ADICOES, STR0012, STR0013, VlrAdicoes( aParametro ) + VlrDoacoes( aParametro ), lRural )//"ADI��ES";"Total de adi��es:"
AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_EXCLUSOES, STR0014, STR0015, VlrExcluso( aParametro ), lRural )//"EXCLUS�ES";"Total das exclus�es:"
AddTotGrup( @nLinha, Iif( aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ, STR0016, STR0041 ),;
 		VlrLRAntes( aParametro ), oSetup ) //"LUCRO REAL ANTES DA COMPENSA��O DE PREJU�ZOS ANTERIORES", "LUCRO REAL ANTES DA COMPENSA��O DA BASE NEGATIVA"
AddGrupRel( @nLinha, oSetup, aDadosRel, GRUPO_REL_COMP_PREJ, Iif( aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ, STR0017, STR0042 ),,, lRural)//"COMPENSA��O DE PREJU�ZOS FISCAIS DE PER�ODOS ANTERIOES"; "COMPENSA��O DE BASE NEGAIVA DE PER�ODOS ANTERIOES" 

If lRural
	AddTotGrup( @nLinha, STR0046, VlrLucReal( aParametro ), oSetup ) //"LUCRO REAL (ATIVIDADE RURAL)"
ElseIf !Empty( Posicione( "T0N", 1, xFilial( "T0N" ) + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ), "T0N->T0N_IDEVEN" ) )
	AddTotGrup( @nLinha, STR0047, VlrLucReal( aParametro ), oSetup ) //"LUCRO REAL (ATIVIDADE GERAL)"
Else
	AddTotGrup( @nLinha, STR0018, VlrLucReal( aParametro ), oSetup ) //"LUCRO REAL"
EndIf

Return()
