#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA223.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA223
Cadastro MVC de Tipo de Contribuição

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA223()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Tipo de Contribuição 	
oBrw:SetAlias( 'C8H')
oBrw:SetMenuDef( 'TAFA223' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA223" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruC8H := FWFormStruct( 1, 'C8H' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA223' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_C8H', /*cOwner*/, oStruC8H)
oModel:GetModel( 'MODEL_C8H' ):SetPrimaryKey( { 'C8H_FILIAL' , 'C8H_ID' } )
Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA223' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC8H		:= FWFormStruct( 2, 'C8H' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C8H', oStruC8H, 'MODEL_C8H' )

oView:EnableTitleView( 'VIEW_C8H',  STR0001 ) //Cadastro de Tipo de Contribuição

oView:CreateHorizontalBox( 'FIELDSC8H', 100 )

oView:SetOwnerView( 'VIEW_C8H', 'FIELDSC8H' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1005.03

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8H_FILIAL" )
	aAdd( aHeader, "C8H_ID" )
	aAdd( aHeader, "C8H_CODIGO" )
	aAdd( aHeader, "C8H_DESCRI" )
	aAdd( aHeader, "C8H_VALIDA" )

	aAdd( aBody, { "", "000001", "101", "CONTRIB. PATRONAL INCIDENTE SOBRE A REMUNERACAO DE EMPREGADOS E AVULSOS", "" } )
	aAdd( aBody, { "", "000002", "102", "CONTRIB. GILRAT", "" } )
	aAdd( aBody, { "", "000003", "103", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 15 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000004", "104", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 20 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000005", "105", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 25 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000006", "106", "CONTRIB. ADIC. INCIDENTE SOBRE A REMUNERACAO DE EMPREGADOS E AVULSOS", "" } )
	aAdd( aBody, { "", "000007", "107", "CONTRIB GILRAT - OPERADOR PORTUARIO", "" } )
	aAdd( aBody, { "", "000008", "111", "CONTRIB PATRONAL INCIDENTE SOBRE A REMUNERACAO DE CONTRIBUINTES INDIVIDUAIS", "" } )
	aAdd( aBody, { "", "000009", "113", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 15 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000010", "114", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 20 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000011", "115", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 25 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000012", "116", "CONTRIB. ADIC. INCIDENTE SOBRE A REMUNERACAO DE CONTRIBUINTES INDIVIDUAIS", "" } )
	aAdd( aBody, { "", "000013", "121", "CONTRIB. PATRONAL INCIDENTE SOBRE A REMUNERACAO DE EMPREGADO DOMESTICO", "" } )
	aAdd( aBody, { "", "000014", "122", "CONTRIB. GILRAT", "" } )
	aAdd( aBody, { "", "000015", "131", "CONTRIB. PATRONAL INCID. SOBRE A REMUNERACAO DE EMPREGADO DO MEI", "" } )
	aAdd( aBody, { "", "000016", "201", "CONTRIB. PATRONAL INCIDENTE SOBRE A REMUNERACAO DE EMPREGADOS E AVULSOS (ATIV. CONCOMITANTE)", "" } )
	aAdd( aBody, { "", "000017", "202", "CONTRIB. GILRAT (ATIV. CONCOMITANTE)", "" } )
	aAdd( aBody, { "", "000018", "203", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 15 ANOS DE CONTRIBUICAO (ATIV. CONCOMITANTE)", "" } )
	aAdd( aBody, { "", "000019", "204", "CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 20 ANOS DE CONTRIBUICAO (ATIV. CONCOMITANTE)", "" } )
	aAdd( aBody, { "", "000020", "205", "5CONTRIB. ADIC. PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL APOS 25 ANOS DE CONTRIBUICAO (ATIV. CONCOMITANTE)", "" } )
	aAdd( aBody, { "", "000021", "211", "CONTRIB PATRONAL INCIDENTE SOBRE A REMUNERACAO DE CONTRIBUINTES INDIVIDUAIS (ATIV. CONCOMITANTE)", "" } )
	aAdd( aBody, { "", "000022", "301", "CONTRIB. INCIDENTE SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO", "" } )
	aAdd( aBody, { "", "000023", "302", "CONTRIB. ADICIONAL INCID. SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO – APOSENTADORIA ESPECIAL APOS 15 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000024", "303", "CONTRIB. ADICIONAL INCID. SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO – APOSENTADORIA ESPECIAL APOS 20 ANOS DE CONTRIBUICAO (ART 1º, §1º DA LEI 10.666/03)", "" } )
	aAdd( aBody, { "", "000025", "304", "CONTRIB. ADICIONAL INCID. SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO – APOSENTADORIA ESPECIAL APOS 25 ANOS DE CONTRIBUICAO (ART 1º, §1º DA LEI 10.666/03)", "" } )
	aAdd( aBody, { "", "000026", "311", "CONTRIB. INCIDENTE SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO", "" } )
	aAdd( aBody, { "", "000027", "312", "CONTRIB. ADICIONAL INCID. SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO – APOSENTADORIA ESPECIAL APOS 15 ANOS DE CONTRIBUICAO", "" } )
	aAdd( aBody, { "", "000028", "313", "CONTRIB. ADICIONAL INCID. SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO – APOSENTADORIA ESPECIAL APOS 20 ANOS DE CONTRIBUICAO (ART 1º, §1º DA LEI 10.666/03)", "" } )
	aAdd( aBody, { "", "000029", "314", "CONTRIB. ADICIONAL INCID. SOBRE NOTAS FISCAIS DE SERVICOS PRESTADOS POR COOPERADOS POR INTERMEDIO DE COOPERATIVA DE TRABALHO – APOSENTADORIA ESPECIAL APOS 25 ANOS DE CONTRIBUICAO (ART 1º, §1º DA LEI 10.666/03)", "" } )
	aAdd( aBody, { "", "000030", "401", "CONTRIB. INCIDENTE SOBRE A AQUISICAO DE PRODUCAO DE PRODUTOR RURAL PESSOA FISICA OU SEGURADO ESPECIAL", "" } )
	aAdd( aBody, { "", "000031", "402", "GILRAT INCIDENTE SOBRE A AQUISICAO DE PRODUCAO DE PRODUTOR RURAL PESSOA FISICA OU SEGURADO ESPECIAL", "" } )
	aAdd( aBody, { "", "000032", "411", "AQUISICAO PRODUCAO RURAL PF 2,0% (ADQUIRENTE ENTIDADE PAA)", "" } )
	aAdd( aBody, { "", "000033", "412", "GILRAT AQUISICAO PROD RURAL PF - 0,1% (ADQUIRENTE ENTIDADE DO PAA)", "" } )
	aAdd( aBody, { "", "000034", "413", "AQUISICAO PRODUCAO RURAL PJ 2,5% (ADQUIRENTE ENTIDADE PAA)", "" } )
	aAdd( aBody, { "", "000035", "414", "GILRAT AQUISICAO PROD RURAL PJ - 0,1% (ADQUIRENTE ENTIDADE DO PAA)", "" } )
	aAdd( aBody, { "", "000036", "421", "VALOR DA CONTRIBUICAO PREVIDENCIARIA DECORRENTE DA COMERCIALIZACAO DA PRODUCAO PELO PRODUTOR RURAL PESSOA JURIDICA OU AGROINDUSTRIA.", "" } )
	aAdd( aBody, { "", "000037", "422", "VALOR DA GILRAT DECORRENTE DA COMERCIALIZACAO DA PRODUCAO PELO PRODUTOR RURAL PESSOA JURIDICA OU AGROINDUSTRIA", "" } )
	aAdd( aBody, { "", "000038", "431", "VALOR DA CONTRIBUICAO PREVIDENCIARIA DECORRENTE DA COMERCIALIZACAO DA PRODUCAO PELO PRODUTOR RURAL PESSOA FISICA OU SEGURADO ESPECIAL", "" } )
	aAdd( aBody, { "", "000039", "432", "VALOR DA GILRAT DECORRENTE DA COMERCIALIZACAO DA PRODUCAO PELO PRODUTOR RURAL PESSOA FISICA OU SEGURADO ESPECIAL", "" } )
	aAdd( aBody, { "", "000040", "501", "CONTRIBUICAO SOBRE VALORES PAGOS A TITULO DE PATROCINIO, PUBLICIDADE, USO DE MARCAS, LICENCIAMENTO, ETC.", "" } )
	aAdd( aBody, { "", "000041", "502", "CONTRIBUICAO INCIDENTE SOBRE A RECEITA DA REALIZACAO DE ESPETACULO DESPORTIVO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )