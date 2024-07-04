#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA217.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA220
Cadastro MVC de Classificação de Serviços Sujeitos a Retenção de Contribuição Previdênciária

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA217()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Classificação de Serviços Sujeitos a Retenção de Contribuição Previdênciária	
oBrw:SetAlias( 'C8C')
oBrw:SetMenuDef( 'TAFA217' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA217" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruC8C := FWFormStruct( 1, 'C8C' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA217' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_C8C', /*cOwner*/, oStruC8C)
oModel:GetModel( 'MODEL_C8C' ):SetPrimaryKey( { 'C8C_FILIAL' , 'C8C_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA217' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC8C		:= FWFormStruct( 2, 'C8C' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C8C', oStruC8C, 'MODEL_C8C' )

oView:EnableTitleView( 'VIEW_C8C',  STR0001 ) //Cadastro de Classificação de Serviços Sujeitos a Retenção de Contribuição Previdênciária	

oView:CreateHorizontalBox( 'FIELDSC8C', 100 )

oView:SetOwnerView( 'VIEW_C8C', 'FIELDSC8C' )

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

nVerAtu := 1021.04

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8C_FILIAL" )
	aAdd( aHeader, "C8C_ID" )
	aAdd( aHeader, "C8C_CODIGO" )
	aAdd( aHeader, "C8C_DESCRI" )
	aAdd( aHeader, "C8C_VALIDA" )
	aAdd( aHeader, "C8C_CREINF" )

	aAdd( aBody, { "", "000001", "01", "LIMPEZA, CONSERVACAO OU ZELADORIA", "", "100000001" } )
	aAdd( aBody, { "", "000002", "02", "VIGILANCIA OU SEGURANCA", "", "100000002" } )
	aAdd( aBody, { "", "000003", "03", "CONSTRUCAO CIVIL", "", "100000003" } )
	aAdd( aBody, { "", "000004", "04", "SERVICOS DE NATUREZA RURAL", "", "100000004" } )
	aAdd( aBody, { "", "000005", "05", "DIGITACAO", "", "100000005" } )
	aAdd( aBody, { "", "000006", "06", "PREPARACAO DE DADOS PARA PROCESSAMENTO", "", "100000006" } )
	aAdd( aBody, { "", "000007", "07", "ACABAMENTO", "", "100000007" } )
	aAdd( aBody, { "", "000008", "08", "EMBALAGEM", "", "100000008" } )
	aAdd( aBody, { "", "000009", "09", "ACONDICIONAMENTO", "", "100000009" } )
	aAdd( aBody, { "", "000010", "10", "COBRANCA", "", "100000010" } )
	aAdd( aBody, { "", "000011", "11", "COLETA OU RECICLAGEM DE LIXO OU DE RESIDUOS", "", "100000011" } )
	aAdd( aBody, { "", "000012", "12", "COPA", "", "100000012" } )
	aAdd( aBody, { "", "000013", "13", "HOTELARIA", "", "100000013" } )
	aAdd( aBody, { "", "000014", "14", "CORTE OU LIGACAO DE SERVICOS PUBLICOS", "", "100000014" } )
	aAdd( aBody, { "", "000015", "15", "DISTRIBUICAO", "", "100000015" } )
	aAdd( aBody, { "", "000016", "16", "TREINAMENTO E ENSINO", "", "100000016" } )
	aAdd( aBody, { "", "000017", "17", "ENTREGA DE CONTAS E DE DOCUMENTOS", "", "100000017" } )
	aAdd( aBody, { "", "000018", "18", "LIGACAO DE MEDIDORES", "", "100000018" } )
	aAdd( aBody, { "", "000019", "19", "LEITURA DE MEDIDORES", "", "100000019" } )
	aAdd( aBody, { "", "000020", "20", "MANUTENCAO DE INSTALACOES, DE MAQUINAS OU DE EQUIPAMENTOS", "", "100000020" } )
	aAdd( aBody, { "", "000021", "21", "MONTAGEM", "", "100000021" } )
	aAdd( aBody, { "", "000022", "22", "OPERACAO DE MAQUINAS, DE EQUIPAMENTOS E DE VEICULOS", "", "100000022" } )
	aAdd( aBody, { "", "000023", "23", "OPERACAO DE PEDAGIO OU DE TERMINAL DE TRANSPORTE", "", "100000023" } )
	aAdd( aBody, { "", "000024", "24", "OPERACAO DE TRANSPORTE DE PASSAGEIROS", "", "100000024" } )
	aAdd( aBody, { "", "000025", "25", "PORTARIA, RECEPCAO OU ASCENSORISTA", "", "100000025" } )
	aAdd( aBody, { "", "000026", "26", "RECEPCAO, TRIAGEM OU MOVIMENTACAO DE MATERIAIS", "", "100000026" } )
	aAdd( aBody, { "", "000027", "27", "PROMOCAO DE VENDAS OU DE EVENTOS", "", "100000027" } )
	aAdd( aBody, { "", "000028", "28", "SECRETARIA E EXPEDIENTE", "", "100000028" } )
	aAdd( aBody, { "", "000029", "29", "SAUDE", "", "100000029" } )
	aAdd( aBody, { "", "000030", "30", "TELEFONIA OU TELEMARKETING", "", "100000030" } )
	aAdd( aBody, { "", "000031", "31", "TRABALHO TEMPORARIO NA FORMA DA LEI Nº 6.019, DE JANEIRO DE 1974", "", "100000031" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )