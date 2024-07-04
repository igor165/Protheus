#Include "Protheus.Ch"
#INCLUDE "TAFR118.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWPrintSetup.ch"

//Tipo Lançamento Parte B
#DEFINE TIPO_LANC_DEBITO					'1'
#DEFINE TIPO_LANC_CREDITO				'2'
#DEFINE TIPO_LANC_CONSTITUIR_SALDO		'3'

//Natureza conta LALUR Parte B
#DEFINE NATUREZA_ADICAO						'1'
#DEFINE NATUREZA_EXCLUSAO					'2'
#DEFINE NATUREZA_COMP_PREJ_BASE_NEGATIVA	'3'
#DEFINE NATUREZA_DEDUCA_COMP_TRIBUTO		'4'
#DEFINE NATUREZA_ADIC_EXCL					'5'

/*/{Protheus.doc} TAFR118
Relatório do LALUR parte B gerado a partir de um período de apuração
@author david.costa
@since 04/05/2017
@version 1.0
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@param cLogErros, character, Log de erros do processo
@return ${Nil}, ${Nulo} 
@example
TAFR118( oModelPeri, @cLogErros )
/*/Function TAFR118( oModelPeri, cLogErros )

Local nPrintType	as numeric
Local nLocal		as numeric
Local oSetup		as object
Local aDevice		as array

//Variaveis necessarias para o Objeto FwPrintsetup() que define as opcoes para a emissao do relatorio
Local cSession	:= GetPrinterSession()
Local cDevice		:= GetProfString( cSession, "PRINTTYPE", "SPOOL", .T. )
Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPREVIEW+PD_DISABLEPAPERSIZE

Private cTitulo	:= STR0002 //"Relatorio_LALUR_PARTE_B"
Private oPrint	as object

aDevice		:= {}
nPrintType		:= 0
nLocal			:= 0

//Define os Tipos de Impressao validos para este relatório
AADD(aDevice,"DISCO")
AADD(aDevice,"SPOOL")
AADD(aDevice,"EMAIL")
AADD(aDevice,"EXCEL")
AADD(aDevice,"HTML" )
AADD(aDevice,"PDF"  )

//Realiza as configuracoes necessarias para a impressao
nPrintType := aScan(aDevice,{|x| x == cDevice })
nLocal     := If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )

oSetup := FWPrintSetup():New( nFlags, STR0003 ) //"Parâmetros para impressão"
oSetup:SetUserParms( {|| .T. } )
oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
oSetup:SetPropert(PD_ORIENTATION , 1)
oSetup:SetPropert(PD_DESTINATION , nLocal)
oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
oSetup:SetPropert(PD_PAPERSIZE   , 2) //A4

oPrint := FWMSPrinter():New( cTitulo, IMP_PDF , .F., , .T., , oSetup )

//Confirmando a tela de Configuracao eu inicio a Impressao do Relatorio
If oSetup:Activate() == PD_OK
	MsgRun( STR0004, "", {|| CursorWait(), GerarRel( oSetup, oModelPeri ) ,CursorArrow() } )   //"Gerando Relatório"			
Else
	AddLogErro( STR0005, @cLogErros ) //"Relatório cancelado pelo usuário."
	oPrint:Deactivate()  //Libera o arquivo criado da memoria para que possa ser usado novamente caso o usuario entre na rotina de novo.
EndIf

Return( Nil )

/*/{Protheus.doc} GerarRel
Função para gerar o Relatório
@author david.costa
@since 04/05/2017
@version 1.0
@param oSetup, object, Obejeto com os default da impressão
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@return ${Nil}, ${Nulo}
@example
GerarRel( oSetup, oModelPeri )
/*/Static Function GerarRel( oSetup, oModelPeri )

Local nLinha		as numeric
Local nColuna		as numeric
Local nIndice		as numeric
Local cAliasQry	as character
Local oModelParB	as object

//Fator de proporção da Pagina
Local nFatorLarg	as numeric
Local nFatorAltu	as numeric

Private oFont01		as object
Private oFont02		as object
Private oFont03		as object
Private nLargurPag 	as numeric
Private nAlturaPag	as numeric

nIndice	:= 0
nLargurPag	:= 0
nAlturaPag	:= 0
nFatorLarg	:= 4.04
nFatorAltu	:= 3.77
nColuna	:= oSetup:GetProperty(PD_MARGIN)[1]
nLinha		:= oSetup:GetProperty(PD_MARGIN)[2]
aDadosCabe	:= {}
oFont01	:= TFont():New( "Calibri", 10, 10, , .T., , , , .T., .F. )
oFont02	:= TFont():New( "Calibri", 10, 10, , .F., , , , .T., .F. )
oFont03	:= TFont():New( "Calibri", 13, 13, , .T., , , , .T., .F. )

//Define saida de impressão
If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL 
	oPrint:nDevice := IMP_SPOOL
	WriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
	oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]

ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF 
	oPrint:nDevice := IMP_PDF
	oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
Endif

oPrint:StartPage()

//Calcula a largura e altura da pagina
nLargurPag := ( oPrint:nPageWidth / nFatorLarg ) - oSetup:GetProperty(PD_MARGIN)[1] - oSetup:GetProperty(PD_MARGIN)[3]
nAlturaPag := ( oPrint:nPageHeight / nFatorAltu ) - oSetup:GetProperty(PD_MARGIN)[2]

//Cabeçalho
GetCabeRel( @nLinha, oSetup, oModelPeri )

/*Paginna Completa (Referencia A4 Retrato)
oPrint:Box( 1, 1, 841, 594, "-4")*/

//Selecionas as contas da Parte B do período
cAliasQry := GetContasB( oModelPeri )

//Adiciona as contas ao Relatório
While ( cAliasQry )->( !Eof() )
	If LoadContaB( ( cAliasQry )->R_E_C_N_O_, @oModelParB )
		AddContRel( oModelPeri, oModelParB, @nLinha, oSetup )
	EndIf
	( cAliasQry )->( DbSkip() )
EndDo

oPrint:EndPage()

oPrint:Preview()

Return( Nil )

/*/{Protheus.doc} GetCabeRel
Adiciona um cabeçalho na página do relatório
@author david.costa
@since 04/05/2017
@version 1.0
@param nLinha, numeric, Número da linha no relatório
@param oSetup, object, Obejeto com os default da impressão
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@return ${Nil}, ${Nulo}
@example
GetCabeRel( @nLinha, oSetup, oModelPeri )
/*/Static Function GetCabeRel( nLinha, oSetup, oModelPeri )

Local nColuna 		as numeric
Local aSM0			as array
Local cDecFilial	as character
Local nIndcFil		as numeric

aSM0		:= {}
cDecFilial	:= ""
nIndcFil	:= 0
nColuna 	:= oSetup:GetProperty(PD_MARGIN)[1]

cDecFilial := Posicione( "C1E", 3, xFilial("C1E") + cFilant, "C1E_NOME" )

aSM0 := FWLoadSM0( .T. )
nIndcFil := aScan( aSM0, { |x| x[SM0_GRPEMP] == cEmpAnt .and. x[SM0_CODFIL] == cFilant } )

oPrint:SayAlign( nLinha, nColuna, STR0006, oFont03, nLargurPag, 10, , 2, 0)//"LALUR - PARTE B"
nLinha += 20
oPrint:Say( nLinha, nColuna, STR0007, oFont02 ) //"NOME EMPRESARIAL: "
oPrint:Say( nLinha, nColuna + 83, AllTrim(left( cDecFilial, 45 ) ), oFont01 )
nColuna += 300
oPrint:Say( nLinha, nColuna, STR0008, oFont02 ) //"CNPJ: "
oPrint:Say( nLinha, nColuna + 24, TRANSFORM( Val( aSM0[ nIndcFil, SM0_CGC ] ), "@E 99,999,999/9999-99" ), oFont01 )
nLinha += 15
nColuna := oSetup:GetProperty(PD_MARGIN)[1]
oPrint:Say( nLinha, nColuna, STR0009, oFont02 ) //"PERÍODO DE APURAÇÃO: "
oPrint:Say( nLinha, nColuna + 95, GetPerRel( oModelPeri ), oFont01 )
nLinha += 15

Return( Nil )

/*/{Protheus.doc} QuebraPag
Adiciona uma nova pagina ao relatório
@author david.costa
@since 04/05/2017
@version 1.0
@param nLinha, numeric, Número da linha no relatório
@param oSetup, object, Obejeto com os default da impressão
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@return ${Nil}, ${Nulo}
@example
QuebraPag( nLinha, oSetup )
/*/Static Function QuebraPag( nLinha, oSetup, oModelPeri )

nLinha := oSetup:GetProperty(PD_MARGIN)[2]

oPrint:EndPage()
oPrint:StartPage()

GetCabeRel( @nLinha, oSetup, oModelPeri )

Return( Nil )

/*/{Protheus.doc} GetPerRel
Retorna a descrição para o perído do relatório
@author david.costa
@since 04/05/2017
@version 1.0
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@return ${Nil}, ${Nulo}
@example
GetPerRel( oModelPeri )
/*/Static Function GetPerRel( oModelPeri )

Local cDescPer	as character
Local cTipoRel	as character

If oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )
	cTipoRel := STR0010	//"A00 - Anual"
Else 
	cTipoRel := ""
EndIf

// Utilizo a FirstYDate para pegar o primeiro dia do ano sempre. Como esse relatório é por estimativa, 01/01 sempre será o saldo inicial
cDescPer := FormatStr( "@1 à @2 @3", { dToc( FirstYDate(oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )) ), dToc( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ), cTipoRel } )

Return( cDescPer )

/*/{Protheus.doc} FormatStr
Formata uma string conforme os parametros passados
@author david.costa
@since 03/05/2017
@version 1.0
@param cTexto, character, Mensagem para que será formatada
@param aParam, Array, Array com valores para sibstituir variavéis na mensagem, 
	as variaveis na mensagem deverão iniciar com @ seguido de um sequencial
@return ${cTexto}, ${Mensagem tratada}
@example
FormatStr( "O valor @1 do campo @2 está incorreto", { 38, "AAA_TESTES" } )
A mensagem ficará gravada assim: "O valor 38 do campo AAA_TESTES está incorreto"
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

/*/{Protheus.doc} GetContasB
Busca no banco de dados as contas da parte B que serão geradas no relatório
@author david.costa
@since 05/05/2017
@version 1.0
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@return ${cAliasQry}, ${Resultado da consulta ao banco}
@example
GetContasB( oModelPeri )
/*/Static Function GetContasB( oModelPeri )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cOrderBy	as character

cAliasQry	:=	GetNextAlias()
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""

cSelect	:= " T0S.R_E_C_N_O_ "
cFrom		:= RetSqlName( "T0S" ) + " T0S "
cFrom		+= " JOIN " + RetSqlName( "LE9" ) + " LE9 "
cFrom		+= " 	ON LE9.LE9_ID = T0S.T0S_ID AND LE9.D_E_L_E_T_ = '' "
cWhere		:= " T0S.D_E_L_E_T_ = '' "
cWhere		+= " AND T0S.T0S_FILIAL = '" + xFilial( "T0S" ) + "' "
cWhere		+= " AND LE9.LE9_IDCODT = '" + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) + "' "
cOrderBy	:= " T0S.T0S_CODIGO "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"
cOrderBy 	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

( cAliasQry )->( DbGoTop() )

Return( cAliasQry )

/*/{Protheus.doc} LoadContaB
Carrega a conta da Parte B
@author david.costa
@since 04/05/2017
@version 1.0
@param nRecno, numeric, Recno do Registro
@param oModelParB, objeto, Objeto que receberá a conta da parte B
@return ${lRet}, ${Retorna verdadeiro se a conta for carregada corretamente}
@example
LoadContaB( nRecno, oModelParB )
/*/Static Function LoadContaB( nRecno, oModelParB )

Local lRet		as logical

lRet	:=	.F.

Begin Sequence

	DBSelectArea( "T0S" )
	T0S->( DbGoTo( nRecno ) )
	oModelParB := FWLoadModel( 'TAFA436' )
	oModelParB:SetOperation( MODEL_OPERATION_VIEW )
	oModelParB:Activate()
	lRet := .T.
	
End Sequence

Return( lRet )

/*/{Protheus.doc} AddCabCont
Adiciona o Cabeçalho de uma determinada conta no relatório da parte B
@author david.costa
@since 30/06/2017
@version 1.0
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@param oModelParB, objeto, Objeto que receberá a conta da parte B
@param nLinha, numeric, Número da linha no relatório
@param oSetup, object, Obejeto com os default da impressão
@return ${lRet}, ${lRet}
@example
AddCabCont( oModelPeri, oModelParB, nLinha, oSetup )
/*/Static Function AddCabCont( oModelPeri, oModelParB, nLinha, oSetup )

Local nColuna 	as numeric
Local lRet			as logical

lRet	:=	.T.

If nLinha >= nAlturaPag
	QuebraPag( @nLinha, oSetup, oModelPeri )
EndIf

nColuna := oSetup:GetProperty(PD_MARGIN)[1]

oPrint:Box( nLinha, nColuna, nLinha + 20, nLargurPag + nColuna, "-4")
oPrint:Box( nLinha+10, nColuna, nLinha+10, nLargurPag + nColuna, "-4")
oPrint:Say( nLinha + 8, nColuna + 2, STR0018, oFont01 ) //"Código da Conta:Descrição da Conta:"
oPrint:Say( nLinha + 8, nColuna + 80, oModelParB:GetValue( "MODEL_T0S", "T0S_CODIGO" ), oFont02 )
oPrint:Say( nLinha + 18, nColuna + 2, STR0019, oFont01 ) //"Descrição da Conta:"
oPrint:Say( nLinha + 18, nColuna + 100, left(oModelParB:GetValue( "MODEL_T0S", "T0S_DESCRI" ),80), oFont02 )
nLinha += 20

AddItemLan( @nLinha, oSetup, { STR0011, STR0012, STR0013, STR0014, STR0015 }, oFont01, 2, oModelPeri ) //"Data", "Histórico", "Débito", "Crédito", "Saldo"

Return( lRet )

/*/{Protheus.doc} AddContRel
Adiciona uma conta e seus lançamentos no relatório da parte B
@author david.costa
@since 05/05/2017
@version 1.0
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@param oModelParB, objeto, Objeto que receberá a conta da parte B
@param nLinha, numeric, Número da linha no relatório
@param oSetup, object, Obejeto com os default da impressão
@return ${Nil}, ${Nulo}
@example
AddContRel( oModelPeri, oModelParB, nLinha, oSetup )
/*/Static Function AddContRel( oModelPeri, oModelParB, nLinha, oSetup )

Local oModelLan		as object
Local nIndice		as numeric
Local nIndiceTri	as numeric
Local nColuna		as numeric
Local nSaldoIni		as numeric
Local cDebitos		as character
Local cCreditos		as character
Local cData			as character
Local lAddCabeca	as logical
Local cTpSaldo		as character
Local cGrpDet		as character
Local oModelLE9		as object

cData		:= ""
cCreditos	:= ""
cDebitos	:= ""
nIndice		:= 0
nSaldoIni	:= 0
nIndiceTri	:= 0
nColuna		:= oSetup:GetProperty(PD_MARGIN)[1]
lAddCabeca	:= .T.
cGrpDet		:= ""

oModelLE9	:= oModelParB:GetModel( "MODEL_LE9" )

//Posiciona na LE9 no imposto correto
if oModelLE9:SeekLine( { { "LE9_IDCODT", oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) } } )
	oModelLan	:= oModelParB:GetModel( "MODEL_T0T" )

	If oModelLan:SeekLine( { { "T0T_IDCODT", oModelLE9:GetValue( "LE9_IDCODT" ) } } )
		
		if TAFColumnPos( "LE9_ISLDIN" ) .and. !Empty(oModelLE9:GetValue( "LE9_ISLDIN" ))
			cTpSaldo	:= Iif(oModelLE9:GetValue( "LE9_ISLDIN" )	=="1","D","C")	
		else
			cTpSaldo	:= ""
		endif

		//Saldo Inicial
		nSaldoIni := AddSaldoInicial( @nLinha, oModelPeri, oModelParB, oSetup, oModelLan, cTpSaldo )

		lAddCabeca := nSaldoIni == 0
		For nIndice := 1 to oModelLan:Length()
			oModelLan:GoLine( nIndice )
			// Utilizo a FirstYDate para pegar o primeiro dia do ano sempre. Como esse relatório é por estimativa, 01/01 sempre será o saldo inicial
			If oModelLan:GetValue( "T0T_DTLANC" ) >= FirstYDate(oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )) .and. ;
				oModelLan:GetValue( "T0T_DTLANC" ) <= oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) .and. ;
				!oModelLan:IsEmpty()
				
				//Cabeçalho
				lAddCabeca := lAddCabeca .and. !AddCabCont( oModelPeri, oModelParB, @nLinha, oSetup )
				cGrpDet := alltrim(oModelLan:GetValue('T0T_IDDETA')) 
				
				nSaldoIni := TAFA436RetSaldo( nSaldoIni, oModelParB:GetValue( "MODEL_T0S", "T0S_NATURE" ),;
								oModelLan:GetValue( "T0T_TPLANC" ), oModelLan:GetValue( "T0T_VLLANC" ),@cTpSaldo, cGrpDet )

						
				cDescricao	:= SubStr( AllTrim( oModelLan:GetValue( "T0T_HISTOR" ) ), 1, 32 )
				cDebitos	:= GetDebitos( oModelLan, oModelParB:GetValue( "MODEL_T0S", "T0S_NATURE" ), cGrpDet )
				cCreditos	:= GetCredito( oModelLan, oModelParB:GetValue( "MODEL_T0S", "T0S_NATURE" ), cGrpDet )
				cSaldoIni	:= FormatSald( nSaldoIni, oModelParB:GetValue( "MODEL_T0S", "T0S_NATURE" ), cTpSaldo)
				cData		:= AllTrim( DToC( oModelLan:GetValue( "T0T_DTLANC" ) ) )
				
				AddItemLan( @nLinha, oSetup, { cData, cDescricao, cDebitos, cCreditos, cSaldoIni },,,oModelPeri )
				lExiteLan := .T.
			EndIf
		Next nIndice
	EndIf
Endif

nLinha += 10

Return( Nil )

/*/{Protheus.doc} AddItemLan
Adiciona lançamentos de uma determinada conta no relatório da parte B
@author david.costa
@since 05/05/2017
@version 1.0
@param nLinha, numeric, Número da linha no relatório
@param oSetup, object, Obejeto com os default da impressão
@param aDados, array, Dados do lançamento da parte B para impressão no relatório
@param oFont, objeto, Objeto Da fonte para a impressão do item
@param nAlign, numeric, Alinhamento horizontal dos campos
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@return ${Nil}, ${Nulo}
@example
AddItemLan( nLinha, oSetup, aDados, oFont, nAlign )
/*/Static Function AddItemLan( nLinha, oSetup, aDados, oFont, nAlign, oModelPeri )

Local nColuna		as numeric
Local lRet			as logical

Default oFont		:= oFont02
Default nAlign	:= 1

lRet	:=	.T.

If nLinha >= nAlturaPag
	QuebraPag( @nLinha, oSetup, oModelPeri )
EndIf

nColuna	:= oSetup:GetProperty(PD_MARGIN)[1]

oPrint:Box( nLinha, nColuna, nLinha + 10, nLargurPag + nColuna, "-4")
oPrint:Say( nLinha + 8, nColuna + 2, aDados[ 1 ], oFont )
oPrint:Say( nLinha + 8, nColuna + 57, aDados[ 2 ], oFont )
oPrint:SayAlign( nLinha - 2, 252, aDados[ 3 ], oFont, 98, 10, , nAlign, 0 )
oPrint:SayAlign( nLinha - 2, 352, aDados[ 4 ], oFont, 98, 10, , nAlign, 0 )
oPrint:SayAlign( nLinha - 2, nLargurPag + nColuna - 100, aDados[ 5 ], oFont, 98, 10, , nAlign, 0 )

nLinha += 10

Return( lRet )

/*/{Protheus.doc} FormatSald
Formata o Saldo adicionando a indicação de credor/devedor (C e D)
@author david.costa
@since 05/05/2017
@version 1.0
@param nSaldo, numeric, Valor do Saldo
@param cNatureza, caracter, Natureza da conta
@param cTpSaldo, caracter, Indicador do Saldo
@return ${cSaldo}, ${Saldo Formatado}
@example
FormatSald( nSaldo )
/*/Static Function FormatSald( nSaldo, cNatureza, cTpSaldo )

Local cSaldo	as character

Default cTpSaldo := ""

cSaldo	:= ""

cSaldo := FormataVLR( nSaldo )

if Empty(cTpSaldo)
	cSaldo += Iif( cNatureza $ "|1|", " C", " D" )
else
	cSaldo += " "+cTpSaldo
endif


Return( cSaldo )

/*/{Protheus.doc} GetDebitos
Retorna o valor de débitos formatado
@author david.costa
@since 05/05/2017
@version 1.0
@param oModelLan, object, Model de Lançamentos da conta da Parte B
@param cNatureza, character, Natureza da conta
@return ${cDebitos}, ${Valor de debitos formatado}
@example
GetDebitos( oModelLan )
/*/Static Function GetDebitos( oModelLan, cNatureza, cGrpDet )

Local cDebitos	as character
Default cGrpDet	 := ""

cDebitos	:= "0,00"

If cNatureza == NATUREZA_ADIC_EXCL .and.;
	( oModelLan:GetValue( "T0T_TPLANC" ) == TIPO_LANC_CONSTITUIR_SALDO .and.;
	(!Empty(cGrpDet) .and. GrpConsSld( cGrpDet )  <> '09') )
	
	cDebitos := FormataVLR( oModelLan:GetValue( "T0T_VLLANC" ) )

ElseIf oModelLan:GetValue( "T0T_TPLANC" ) == TIPO_LANC_DEBITO .or.;
	( oModelLan:GetValue( "T0T_TPLANC" ) == TIPO_LANC_CONSTITUIR_SALDO .and.;
	cNatureza != NATUREZA_ADICAO .and. cNatureza <> NATUREZA_ADIC_EXCL )
	
	cDebitos := FormataVLR( oModelLan:GetValue( "T0T_VLLANC" ) )
EndIf

Return( cDebitos )

/*/{Protheus.doc} GetCredito
Retorna o valor de créditos formatado
@author david.costa
@since 05/05/2017
@version 1.0
@param oModelLan, object, Model de Lançamentos da conta da Parte B
@param cNatureza, character, Natureza da conta
@return ${cCreditos}, ${Valor de créditos formatado}
@example
GetCredito( oModelLan )
/*/Static Function GetCredito( oModelLan, cNatureza,cGrpDet)

Local cCreditos	as character
Default cGrpDet	 := ""

cCreditos	:= "0,00"
If cNatureza == NATUREZA_ADIC_EXCL .and.;
	( oModelLan:GetValue( "T0T_TPLANC" ) == TIPO_LANC_CONSTITUIR_SALDO .and.;
	(!Empty(cGrpDet) .and. GrpConsSld( cGrpDet )  == '09') )
	
	cCreditos := FormataVLR( oModelLan:GetValue( "T0T_VLLANC" ) )

ElseIf oModelLan:GetValue( "T0T_TPLANC" ) == TIPO_LANC_CREDITO .or.;
	( oModelLan:GetValue( "T0T_TPLANC" ) == TIPO_LANC_CONSTITUIR_SALDO .and.;
	cNatureza == NATUREZA_ADICAO )
	
	cCreditos := FormataVLR( oModelLan:GetValue( "T0T_VLLANC" ) )
EndIf

Return( cCreditos )

/*/{Protheus.doc} FormataVLR
Retorna um valor formatado na mascara "@E 999,999,999,999.99"
@author david.costa
@since 05/05/2017
@version 1.0
@param nVal, numeric, Valor para ser formatado
@return ${cCreditos}, ${Valor de créditos formatado}
@example
FormataVLR( nVal )
/*/Static Function FormataVLR( nVal )

Local cVal	as character

cVal	:= ""

cVal := Alltrim( TRANSFORM( nVal, "@E 999,999,999,999.99" ) )

Return( cVal )

/*/{Protheus.doc} AddSaldoInicial
Adiciona o Saldo Inicial da Conta
@author david.costa
@since 08/05/2017
@version 1.0
@param nLinha, numeric, Número da linha no relatório
@param oModelPeri, object, Model do período de apuração com os valores já apurados
@param oModelParB, objeto, Objeto que receberá a conta da parte B
@param oSetup, object, Obejeto com os default da impressão
@param oModelLan, object, Model de Lançamentos da conta da Parte B
@return ${nSaldoIni}, ${Valor do Saldo inicial}
@example
AddSaldoInicial( nLinha, oModelPeri, oModelParB, oSetup )
/*/Static Function AddSaldoInicial( nLinha, oModelPeri, oModelParB, oSetup, oModelLan, cTpSaldo )

Local cDescricao	as character
Local cDebitos	as character
Local cCreditos	as character
Local cSaldoIni	as character
Local cData		as character
Local nSaldoIni	as numeric

Default cTpSaldo := ""

cDescricao	:= ""
cDebitos	:= ""
cCreditos	:= ""
cSaldoIni	:= ""
cData		:= ""
nSaldoIni	:= 0

//Saldo Inicial
cDescricao	:= STR0016			//"Saldo inicial no período"
cDebitos	:= "0,00"
cCreditos	:= "0,00"
nSaldoIni	:= TAFA436SaldoAnt( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ),;
				oModelParB:GetValue( "MODEL_T0S", "T0S_ID" ),;
 				oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) )
cSaldoIni	:= FormatSald( nSaldoIni, oModelParB:GetValue( "MODEL_T0S", "T0S_NATURE" ), cTpSaldo )
// Utilizo a FirstYDate para pegar o primeiro dia do ano sempre. Como esse relatório é por estimativa, 01/01 sempre será o saldo inicial
cData		:= DTOC(FirstYDate(oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ))) 

If oModelLan:GetValue( "T0T_DTLANC" ) >= oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) .and. ;
	oModelLan:GetValue( "T0T_DTLANC" ) <= oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) .and. ;
	!oModelLan:IsEmpty() .or. nSaldoIni > 0
	//Cabeçalho
	AddCabCont( oModelPeri, oModelParB, @nLinha, oSetup )
	//Saldo inicial
	AddItemLan( @nLinha, oSetup, { cData, cDescricao, cDebitos, cCreditos, cSaldoIni },,,oModelPeri )
EndIf

Return( nSaldoIni )
