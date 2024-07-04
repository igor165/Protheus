#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA424.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA424
Cadastro MVC Cadastro de Tipo de Valor de Apuração

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA424()
Local oBrw as object

oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Tipo de Valor de Apuração	
oBrw:SetAlias( 'T2T')
oBrw:SetMenuDef( 'TAFA424' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA424" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruT2T  as object 
Local oModel    as object

oStruT2T := FWFormStruct( 1, 'T2T' )// Cria a estrutura a ser usada no Modelo de Dados
oModel   := MPFormModel():New('TAFA424' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_T2T', /*cOwner*/, oStruT2T)
oModel:GetModel( 'MODEL_T2T' ):SetPrimaryKey( { 'T2T_FILIAL' , 'T2T_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Vitor Siqueira
@since 17/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	as object
Local oStruT2T	as object
Local oView		as object

oModel		:= FWLoadModel( 'TAFA424' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruT2T	:= FWFormStruct( 2, 'T2T' )// Cria a estrutura a ser usada na View
oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_T2T', oStruT2T, 'MODEL_T2T' )

oView:EnableTitleView( 'VIEW_T2T',  STR0001 ) //Cadastro de Códigos da Receita

oView:CreateHorizontalBox( 'FIELDST2T', 100 )

oView:SetOwnerView( 'VIEW_T2T', 'FIELDST2T' )

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
Static Function FAtuCont( nVerEmp as numeric, nVerAtu as numeric)
Local aHeader as array
Local aBody	  as array
Local aRet	  as array

aHeader	:=	{}
aBody	:=	{}
aRet	:=	{}

nVerAtu := 1029.22

If nVerEmp < nVerAtu
	aAdd( aHeader, "T2T_FILIAL" )
	aAdd( aHeader, "T2T_ID" )
	aAdd( aHeader, "T2T_CODIGO" )
	aAdd( aHeader, "T2T_DESCRI" )
	aAdd( aHeader, "T2T_VALIDA" )

	aAdd( aBody, { "", "000001", "11", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA NORMAL", "" } )
	aAdd( aBody, { "", "000002", "12", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 15 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000003", "13", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 20 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000004", "14", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 25 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000005", "15", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000006", "21", "VALOR TOTAL DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO À PREVIDÊNCIA SOCIAL", "" } )
	aAdd( aBody, { "", "000007", "22", "VALOR DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO AO SEST", "" } )
	aAdd( aBody, { "", "000008", "23", "VALOR DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO AO SENAT", "" } )
	aAdd( aBody, { "", "000009", "31", "VALOR PAGO AO TRABALHADOR A TÍTULO DE SALÁRIO-FAMÍLIA", "" } )
	aAdd( aBody, { "", "000010", "32", "VALOR PAGO AO TRABALHADOR A TÍTULO DE SALÁRIO-MATERNIDADE", "" } )
	aAdd( aBody, { "", "000011", "91", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BASE DE CÁLCULO (BC) DA CONTRIBUIÇÃO PREVIDENCIÁRIA (CP) NORMAL", "" } )
	aAdd( aBody, { "", "000012", "92", "INCID. SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 15 ANOS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000013", "93", "INCID. SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 20 ANOS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000014", "94", "INCID. SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 25 ANOS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000015", "16", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 15 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000016", "17", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 20 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000017", "18", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 25 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000018", "19", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA EXCLUSIVA DO EMPREGADO", "" } )
	aAdd( aBody, { "", "000019", "95", "INCID. SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP NORMAL - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000020", "96", "INCID. SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 15 ANOS DE TRABALHO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000021", "97", "INCID. SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 20 ANOS DE TRABALHO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000022", "98", "INCID. SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 25 ANOS DE TRABALHO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000023", "41", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA NORMAL", "" } )
	aAdd( aBody, { "", "000024", "42", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 15 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000025", "43", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 20 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000026", "44", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 25 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000027", "45", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL NORMAL - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000028", "46", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 15 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000029", "47", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 20 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000030", "48", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 25 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000031", "49", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA EXCLUSIVA DO EMPREGADO", "" } )
	aAdd( aBody, { "", "000032", "81", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BASE DE CÁLCULO (BC) DA CONTRIBUIÇÃO PREVIDENCIÁRIA (CP) NORMAL", "" } )
	aAdd( aBody, { "", "000033", "82", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 15 ANOS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000034", "83", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 20 ANOS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000035", "84", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 25 ANOS DE TRABALHO", "" } )
	aAdd( aBody, { "", "000036", "85", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP NORMAL - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000037", "86", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 15 ANOS DE TRABALHO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000038", "87", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 20 ANOS DE TRABALHO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000039", "88", "INCIDÊNCIA SUSPENSA EM DECORRÊNCIA DE DECISÃO JUDICIAL - BC CP APOSENTADORIA ESPECIAL AOS 25 ANOS DE TRABALHO - EXCLUSIVA DO EMPREGADOR", "" } )

	aAdd( aRet, { aHeader, aBody } )
	

EndIf



Return( aRet )