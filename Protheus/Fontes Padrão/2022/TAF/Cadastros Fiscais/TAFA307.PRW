#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "TAFA307.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA307
Cadastro MVC - Operações das Instituições Financeiras

@author Denis R de Oliveira
@since 07/03/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA307
PRIVATE	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001) //"Operações das Instituições Financeiras"                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
oBrw:SetAlias( 'CA2' )
oBrw:SetMenuDef( 'TAFA307' )
oBrw:Activate()  


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Denis R de Oliveira
@since 13/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF307Vld" , "2" } }
Local aRotina := {}

//Indica se o menu tera todas as opções de cadastro ou apenas a visualização
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.TAF307' OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina	:=	xFunMnuTAF( "TAFA307" , , aFuncao )
EndIf


Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 07/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCA2 	:= 	FWFormStruct( 1, 'CA2' )
Local oStruCA3 	:= 	FWFormStruct( 1, 'CA3' )
Local oStruCA4 	:= 	FWFormStruct( 1, 'CA4' )
Local oStruCA5 	:= 	FWFormStruct( 1, 'CA5' )
Local oStruCA6 	:= 	FWFormStruct( 1, 'CA6' )
Local oStruCA7 	:= 	FWFormStruct( 1, 'CA7' )
Local oStruCA8 	:= 	FWFormStruct( 1, 'CA8' )
Local oModel	:=	MPFormModel():New( 'TAFA307' , , , {|oModel| SaveModel( oModel ) })

//Identificação da Pessoa Jurídica - CA2     
oModel:AddFields('MODEL_CA2', /*cOwner*/, oStruCA2 )   

//Consolidação das Operações do Período - CA3
oModel:AddGrid('MODEL_CA3', 'MODEL_CA2', oStruCA3)  
oModel:GetModel( 'MODEL_CA3' ):SetUniqueLine({'CA3_CSTPC','CA3_SEQREG'} )

//Processo Referenciado - CA4
oModel:AddGrid('MODEL_CA4', 'MODEL_CA3', oStruCA4)   
oModel:GetModel( 'MODEL_CA4' ):SetUniqueLine({'CA4_IDPROC'})
oModel:GetModel( 'MODEL_CA4' ):SetOptional( .T. )

//Detalhamento das Receitas, Deduções e/ou Exclusões do Período - CA5
oModel:AddGrid('MODEL_CA5', 'MODEL_CA3', oStruCA5)   
oModel:GetModel( 'MODEL_CA5' ):SetUniqueLine({'CA5_NUMCPO', 'CA5_CODDET', 'CA5_CODCTA'})
oModel:GetModel( 'MODEL_CA5' ):SetOptional( .T. )

//Processo Referenciado - CA6
oModel:AddGrid('MODEL_CA6', 'MODEL_CA5', oStruCA6)   
oModel:GetModel( 'MODEL_CA6' ):SetUniqueLine({'CA6_IDPROC'})
oModel:GetModel( 'MODEL_CA6' ):SetOptional( .T. )  

//Informações Complementares de Receitas, Deduções e/ou Exclusões do Período - CA7
oModel:AddGrid('MODEL_CA7', 'MODEL_CA5', oStruCA7)  
oModel:GetModel( 'MODEL_CA7' ):SetUniqueLine({'CA7_CODCOM', 'CA7_CONTA'})
oModel:GetModel( 'MODEL_CA7' ):SetOptional( .T. )

//Processo Referenciado - CA8
oModel:AddGrid('MODEL_CA8', 'MODEL_CA7', oStruCA8)   
oModel:GetModel( 'MODEL_CA8' ):SetUniqueLine({'CA8_IDPROC'})
oModel:GetModel( 'MODEL_CA8' ):SetOptional( .T. )
 
/*-----------------------------------------------------------------------------------
Amarração das tabelas
-------------------------------------------------------------------------------------*/

oModel:SetRelation( 'MODEL_CA3', { { 'CA3_FILIAL', 'xFilial( "CA3" )' }, { 'CA3_ID' , 'CA2_ID' } } , CA3->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CA4', { { 'CA4_FILIAL', 'xFilial( "CA4" )' }, { 'CA4_ID' , 'CA2_ID' }, { 'CA4_CSTPC' , 'CA3_CSTPC'  }, { 'CA4_SEQREG', 'CA3_SEQREG' }}, CA4->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CA5', { { 'CA5_FILIAL', 'xFilial( "CA5" )' }, { 'CA5_ID' , 'CA2_ID' }, { 'CA5_CSTPC' , 'CA3_CSTPC'  }, { 'CA5_SEQREG', 'CA3_SEQREG' }}, CA5->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CA6', { { 'CA6_FILIAL', 'xFilial( "CA6" )' }, { 'CA6_ID' , 'CA2_ID' }, { 'CA6_CSTPC' , 'CA3_CSTPC'  }, { 'CA6_SEQREG', 'CA3_SEQREG' }, { 'CA6_NUMCPO' , 'CA5_NUMCPO' }, { 'CA6_CODDET', 'CA5_CODDET' }, { 'CA6_CODCTA', 'CA5_CODCTA' }} , CA6->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CA7', { { 'CA7_FILIAL', 'xFilial( "CA7" )' }, { 'CA7_ID' , 'CA2_ID' }, { 'CA7_CSTPC' , 'CA3_CSTPC'  }, { 'CA7_SEQREG', 'CA3_SEQREG' }, { 'CA7_NUMCPO' , 'CA5_NUMCPO' }, { 'CA7_CODDET', 'CA5_CODDET' }, { 'CA7_CONTA',  'CA5_CODCTA' }} , CA7->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CA8', { { 'CA8_FILIAL', 'xFilial( "CA8" )' }, { 'CA8_ID' , 'CA2_ID' }, { 'CA8_CSTPC' , 'CA3_CSTPC'  }, { 'CA8_SEQREG', 'CA3_SEQREG' }, { 'CA8_NUMCPO' , 'CA5_NUMCPO' }, { 'CA8_CODDET', 'CA5_CODDET' }, { 'CA8_CODCTA', 'CA5_CODCTA' }, { 'CA8_CODCOM', 'CA7_CODCOM' }},/*{ 'CA8_CONTA', 'CA7_CONTA' }} ,*/ CA8->( IndexKey( 1 ) ) )

//Define a chave única de gravação das informações
oModel:GetModel( "MODEL_CA2" ):SetPrimaryKey( {'CA2_FILIAL','CA2_PERIOD','CA2_CNPJ','CA2_INDATV'} )                                                                                                                      


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 07/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA307' )
Local oStruCA3 	:= 	Nil
Local oStruCA2 	:= 	FWFormStruct( 2, 'CA2' )
Local oStruCA4 	:= 	FWFormStruct( 2, 'CA4' )
Local oStruCA5 	:= 	FWFormStruct( 2, 'CA5' ) 
Local oStruCA6 	:= 	FWFormStruct( 2, 'CA6' ) 
Local oStruCA7 	:= 	FWFormStruct( 2, 'CA7' ) 
Local oStruCA8 	:= 	FWFormStruct( 2, 'CA8' ) 
Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

/*-----------------------------------------------------------------------------------
Estrutura da View de Consolidação das Operações do Período - CA3
-------------------------------------------------------------------------------------*/
cGrpOperP := "CA3_VLREC|CA3_CSTPC|CA3_DCSTPC|CA3_VLGER|CA3_VLESP|CA3_VLBCPI|CA3_ALQPIS|CA3_VLPIS|CA3_VLBCCO|CA3_ALQCOF|CA3_VLCOF|CA3_INFCOM|"

cCmpFil   := cGrpOperP
oStruCA3 := FwFormStruct( 2, "CA3",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Consolidação das Operações do Período


/*-----------------------------------------------------------------------------------------
Grupo de campos de Consolidação das Operações do Período - CA3
-------------------------------------------------------------------------------------------*/
oStruCA3:AddGroup( "GRP_OPERACOES", STR0004, "", 1 ) 

oStruCA3:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_OPERACOES")  


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/

oView:AddField( 'VIEW_CA2', oStruCA2, 'MODEL_CA2' )
oView:EnableTitleView( 'VIEW_CA2', STR0003)//Identificação da Pessoa Jurídica 

oView:AddGrid ( 'VIEW_CA3', oStruCA3, 'MODEL_CA3' )
oView:EnableTitleView( 'VIEW_CA3', STR0004)//Consolidação das Operações do Período 

oView:AddGrid ( 'VIEW_CA4', oStruCA4, 'MODEL_CA4' )

oView:AddGrid ( 'VIEW_CA5', oStruCA5, 'MODEL_CA5' )

oView:AddGrid ( 'VIEW_CA6', oStruCA6, 'MODEL_CA6' )

oView:AddGrid ( 'VIEW_CA7', oStruCA7, 'MODEL_CA7' )

oView:AddGrid ( 'VIEW_CA8', oStruCA8, 'MODEL_CA8' )
oView:EnableTitleView( 'VIEW_CA8', STR0005)//Processo Referenciado 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox( 'CMPOCA2', 22 )
oView:CreateFolder( 'FOLDER1', 'CMPOCA2' ) 

oView:CreateHorizontalBox( 'GRIDCA3', 20 )
oView:CreateFolder( 'FOLDER2', 'GRIDCA3' )

oView:CreateHorizontalBox( 'PANFOLDER1', 20 )
oView:CreateFolder( 'FOLDER3', 'PANFOLDER1' )  

oView:CreateHorizontalBox( 'PANFOLDER2', 20 )
oView:CreateFolder( 'FOLDER4', 'PANFOLDER2' )

oView:CreateHorizontalBox( 'GRIDCA8', 18 )
oView:CreateFolder( 'FOLDER5', 'GRIDCA8' )


/*-----------------------------------------------------------------------------------
Estrutura das Abas
-------------------------------------------------------------------------------------*/
oView:AddSheet( 'FOLDER3', 'ABA01', STR0006)
oView:CreateHorizontalBox( 'GRIDCA5', 100,,, 'FOLDER3', 'ABA01' ) 
oView:AddSheet( 'FOLDER3', 'ABA02', STR0005)  
oView:CreateHorizontalBox( 'GRIDCA4', 100,,, 'FOLDER3', 'ABA02' )  

oView:AddSheet( 'FOLDER4', 'ABA01', STR0007)
oView:CreateHorizontalBox( 'GRIDCA7', 100,,, 'FOLDER4', 'ABA01' )  
oView:AddSheet( 'FOLDER4', 'ABA02', STR0005) 
oView:CreateHorizontalBox( 'GRIDCA6', 100,,, 'FOLDER4', 'ABA02' )

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
If TamSX3("CA5_CODCTA")[1] == 36
	oStruCA5:RemoveField( "CA5_CODCTA")
	oStruCA5:SetProperty( "CA5_CTACTB", MVC_VIEW_ORDEM, "09" )
EndIf

If TamSX3("CA7_CONTA")[1] == 36
	oStruCA7:RemoveField( "CA7_CONTA")
	oStruCA7:SetProperty( "CA7_CTACTB", MVC_VIEW_ORDEM, "11" )
EndIf		
oView:SetOwnerView( 'VIEW_CA2', 'CMPOCA2' )
oView:SetOwnerView( 'VIEW_CA3', 'GRIDCA3' )
oView:SetOwnerView( 'VIEW_CA4', 'GRIDCA4' )
oView:SetOwnerView( 'VIEW_CA5', 'GRIDCA5' )
oView:SetOwnerView( 'VIEW_CA6', 'GRIDCA6' )  
oView:SetOwnerView( 'VIEW_CA7', 'GRIDCA7' )
oView:SetOwnerView( 'VIEW_CA8', 'GRIDCA8' )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.                                


@author Denis R de Oliveira
@since 07/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE  
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsavel por setar o Status do registro para Branco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat( "CA2", " " )
		
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF307Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R de Oliveira
@since 07/03/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF307Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro  := {}
Local cStatus   := ""
Local cPeriodo  := AllTrim(CA2->CA2_PERIOD)
Local aCarc_Esp := {}
Local i			:= 0
Local nPIS		:= 0
Local nCOF		:= 0
Local cCstPC  := ""

Default lJob := .F.
Default nRecno := (cAlias)->(Recno())

If CA2->CA2_STATUS $ ( " |1" )
	
	//------------------------------------------------------------------------------------------------//
	/* Valida os Fields da Identificação da Pessoa Jurídica  - CA2                                    */
	//------------------------------------------------------------------------------------------------//
	
	//Valida se o periodo está no formato MMAAAA
	If (Left(cPeriodo,2) < "01" .Or. Left(cPeriodo,2) > "12") .Or. (Substr(cPeriodo,3,4) < "1949" .Or. Substr(cPeriodo,3,4) > "2049") .Or. Len(cPeriodo) <> 6 //Formato MMAAAA
		
		AADD(aLogErro,{"CA2_PERIOD","000318","CA2", nRecno }) //STR0318 - "Informar o mˆs/ano (formato MMAAAA)
		
	EndIf
	
	//Imputa os Caracteres Especiais no Array de Controle
	AADD(aCarc_Esp,{"!", "Exclamacao"})
	AADD(aCarc_Esp,{"@", "Arroba"})
	AADD(aCarc_Esp,{"#", "Sustenido"})
	AADD(aCarc_Esp,{"$", "Cifrao"})
	AADD(aCarc_Esp,{"%", "Porcentagem"})
	AADD(aCarc_Esp,{"*", "Asterisco"})
	AADD(aCarc_Esp,{"/", "Barra"})
	AADD(aCarc_Esp,{"(", "Parentese"})
	AADD(aCarc_Esp,{")", "Parentese"})
	AADD(aCarc_Esp,{"+", "Mais"})
	AADD(aCarc_Esp,{"¨", ""})
	AADD(aCarc_Esp,{"=", "Igual"})
	AADD(aCarc_Esp,{"~", "Til"})
	AADD(aCarc_Esp,{"^", "Circunflexo"})
	AADD(aCarc_Esp,{"]", "Chave"})
	AADD(aCarc_Esp,{"[", "Chave"})
	AADD(aCarc_Esp,{"{", "Colchete"})
	AADD(aCarc_Esp,{"}", "Colchete"})
	AADD(aCarc_Esp,{";", "Ponto e Virgula"})
	AADD(aCarc_Esp,{":", "Dois Pontos"})
	AADD(aCarc_Esp,{">", "Maior"})
	AADD(aCarc_Esp,{"<", "Menor"})
	AADD(aCarc_Esp,{"?", "Interrogacao"})
	AADD(aCarc_Esp,{"_", "Underline"})
	AADD(aCarc_Esp,{",", "Virgula"})
	AADD(aCarc_Esp,{" ", "Espaco"})
	AADD(aCarc_Esp,{"'", "Aspas"})
	
	//Verifica se o periodo contém algum caracter especial
	For i:= 1 to Len(aCarc_Esp)
		If At(aCarc_Esp[i,1], cPeriodo) <> 0
			AADD(aLogErro,{"CA2_PERIOD","000419","CA2", nRecno }) //STR0318 - "O campo possui caracteres especiais"
		EndIf
	Next
	
	//Valida o CNPJ
	If Empty(CA2->CA2_CNPJ)
		Aadd( aLogErro, { "CA2_CNPJ", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
	Else
		If !CGC(CA2->CA2_CNPJ, , .F.)
			Aadd( aLogErro, { "CA2_CNPJ", "000005", "CA2", nRecno } ) //000005 - CPF/CNPJ Inconsistente
		EndIf
	EndIf
	
	//Indicativo Atividade
	cTpIndAt:= Alltrim(Posicione("CA0",1,xFilial("CA0")+CA2->CA2_INDATV,"CA0_CODIGO"))
	
	If Empty(CA2->CA2_INDATV)
		Aadd( aLogErro, { "CA2_INDATV", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
	Else
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CA2->CA2_INDATV
		xValRegTab("CA0",cChave,1,,@aLogErro, , { "CA2", "CA2_INDATV", nRecno })
		
		If !(cTpIndAt $ ("01|02|03|04|05|06"))
			AADD(aLogErro,{"CA2_INDATV","000006","CA2", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			
		EndIf
		
	EndIf
	
	//------------------------------------------------------------------------------------------------//
	/* Valida a Grid Consolidação das Operações do Período - CA3                                      */
	//------------------------------------------------------------------------------------------------//
	CA3-> (dbSetorder(1))
	CA3->(MsSeek(xFilial("CA3")+CA2->(CA2_ID)))
	While !CA3->(Eof()) .And. xFilial("CA2")+CA2->(CA2_ID) == CA3->(CA3_FILIAL+CA3_ID)
		
		cCSTPC:= Posicione("C17",3,xFilial("C17")+CA3->CA3_CSTPC,"C17_CODIGO")
		//Valida o Valor recebido
		If !(CA3->CA3_VLREC > 0) .Or. Empty(CA3->CA3_VLREC)
			Aadd( aLogErro, { "CA3_VLREC", "000010", "CA3", nRecno } ) //Campo Inconsistente ou Vazio
		EndIF
		
		//Valida o CSTPC
		If Empty(CA3->CA3_CSTPC)
			Aadd( aLogErro, { "CA3_CSTPC", "000010", "CA3", nRecno } ) //Campo Inconsistente ou Vazio
		Else
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := CA3->CA3_CSTPC
			xValRegTab("C17",cChave,3,,@aLogErro,, { "CA3", "CA3_CSTPC", nRecno })
			
			If (CA3->CA3_ALQCOF== 4 .or. CA3->CA3_ALQCOF== 3) .and. Alltrim(cCSTPC)<>"01"
				Aadd( aLogErro, { "CA3_ALQCOF", "000593", "CA3", nRecno } ) //Para a validação da alíquota de 4% ou de 3%, deve a pessoa jurídica informar o CST '01 – Operação Tributável com Alíquota Básica', no campo 'Cst Pis/Cof '  
			Endif
		EndIf
		
		//Valida o Valor PIS
		If !Empty(CA3->CA3_VLPIS)
			
			nPIS:= (CA3->CA3_VLBCPI * CA3->CA3_ALQPIS)/100
			If ! CA3->CA3_VLPIS == nPIS
				Aadd( aLogErro, { "CA3_VLPIS", "000010", "CA2", nRecno } ) //STR0528 - O valor do campo VLPIS deve corresponder ao valor da base de cálculo(VLBCPI) multiplicado pela alíquota aplicável(ALQPIS).O resultado deverá ser dividido pelo valor “100”.
			EndIf
			
		EndIf
		
		//Valida o Valor COFINS
		If !Empty(CA3->CA3_VLCOF)
			
			nCOF:= (CA3->CA3_VLBCCO * CA3->CA3_ALQCOF)/100
			If ! CA3->CA3_VLCOF == nCOF
				Aadd( aLogErro, { "CA3_VLCOF", "000010", "CA2", nRecno } ) //STR0529 - O valor do campo VLPIS deve corresponder ao valor da base de cálculo(VLBCPI) multiplicado pela alíquota aplicável(ALQPIS).O resultado deverá ser dividido pelo valor “100”.
			EndIf
			
		EndIf
		
		//------------------------------------------------------------------------------------------------//
		/* Valida a Grid Processo Referenciado - CA4                                                      */
		//------------------------------------------------------------------------------------------------//
		CA4->(dbSetorder(1))
		CA4->(MsSeek(xFilial("CA4")+CA3->(CA3_ID+CA3_CSTPC+CA3_SEQREG)))
		While !CA4->(Eof()) .And. xFilial("CA3")+CA3->(CA3_ID+CA3_CSTPC+CA3_SEQREG) == CA4->(CA4_FILIAL+CA4_ID+CA4_CSTPC+CA4_SEQREG)
			
			//Valida o ID PROC CA4
			If Empty(CA4->CA4_IDPROC)
				Aadd( aLogErro, { "CA4_IDPROC", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CA4->CA4_IDPROC
				xValRegTab("C1G",cChave,3,,@aLogErro, , { "CA2", "CA4_IDPROC", nRecno })
				
				cOriPrc1:= Alltrim(Posicione("C1G",3,xFilial("C1G")+CA4->CA4_IDPROC,"C1G_INDPRO"))
				
				If !(cOriPrc1 $ ("1|3|9"))
					AADD(aLogErro,{"CA4_IDPROC","000006","CA2", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
				EndIf
				
			EndIf
			CA4->(dbSkip())
			
		EndDo
		
		//------------------------------------------------------------------------------------------------//
		/* Valida a Grid Detalhamento das Receitas, Deduções e/ou Exclusões do Período - CA5              */
		//------------------------------------------------------------------------------------------------//
		CA5-> (dbSetorder(1))
		CA5->(MsSeek(xFilial("CA5")+CA3->(CA3_ID+CA3_CSTPC+CA3_SEQREG)))
		While !CA5->(Eof()) .And. xFilial("CA3")+CA3->(CA3_ID+CA3_CSTPC+CA3_SEQREG) == CA5->(CA5_FILIAL+CA5_ID+CA5_CSTPC+CA5_SEQREG)
			
			//Valida o Numero Campo
			If Empty(CA5->CA5_NUMCPO)
				Aadd( aLogErro, { "CA5_NUMCPO", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
			EndIF
			
			//Valida o Codigo Detalhe
			If Empty(CA5->CA5_CODDET)
				Aadd( aLogErro, { "CA5_CODDET", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CA5->CA5_CODDET
				xValRegTab("CUY",cChave,1,,@aLogErro, , { "CA2", "CA5_CODDET", nRecno })
			EndIf
			
			//Valida o Codigo Conta
			If Empty(CA5->CA5_CODCTA)
				Aadd( aLogErro, { "CA5_CODCTA", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CA5->CA5_CODCTA
				xValRegTab("C1O",cChave,3,,@aLogErro, , { "CA2", "CA5_CODCTA", nRecno })
			EndIf                                                                                                                                         
			
			//------------------------------------------------------------------------------------------------//
			/* Valida a Grid Processo Referenciado - CA6                                                      */
			//------------------------------------------------------------------------------------------------//
			CA6-> (dbSetorder(1))
			CA6->(MsSeek(xFilial("CA6")+CA5->(CA5_ID+CA5_CSTPC+CA5_SEQREG+CA5_NUMCPO+CA5_CODDET+CA5_CODCTA)))
			While !CA6->(Eof()) .And. xFilial("CA5")+CA5->(CA5_ID+CA5_CSTPC+CA5_SEQREG+CA5_NUMCPO+CA5_CODDET+CA5_CODCTA) == CA6->(CA6_FILIAL+CA6_ID+CA6_CSTPC+CA6_SEQREG+CA6_NUMCPO+CA6_CODDET+CA6_CODCTA)
				
				//Valida o ID PROC CA6
				If Empty(CA6->CA6_IDPROC)
					Aadd( aLogErro, { "CA6_IDPROC", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
				Else
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := CA6->CA6_IDPROC
					xValRegTab("C1G",cChave,3,,@aLogErro, , { "CA2", "CA6_IDPROC", nRecno })
					
					cOriPrc2:= Alltrim(Posicione("C1G",3,xFilial("C1G")+CA6->CA6_IDPROC,"C1G_INDPRO"))
					
					If !(cOriPrc2 $ ("1|3|9"))
						AADD(aLogErro,{"CA6_IDPROC","000006","CA2", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf
					
				EndIf
				CA6->(dbSkip())
				
			EndDo
			
			//------------------------------------------------------------------------------------------------//
			/* Informações Complementares de Receitas, Deduções e/ou Exclusões do Período - CA7               */
			//------------------------------------------------------------------------------------------------//
			CA7-> (dbSetorder(1))
			CA7->(MsSeek(xFilial("CA7")+CA5->(CA5_ID+CA5_CSTPC+CA5_SEQREG+CA5_NUMCPO+CA5_CODDET+CA5_CODCTA)))
			While !CA7->(Eof()) .And. xFilial("CA5")+CA5->(CA5_ID+CA5_CSTPC+CA5_SEQREG+CA5_NUMCPO+CA5_CODDET+CA5_CODCTA) == CA7->(CA7_FILIAL+CA7_ID+CA7_CSTPC+CA7_SEQREG+CA7_NUMCPO+CA7_CODDET+CA7_CODCTA)
				
				//Valida o Codigo Complemento
				If Empty(CA7->CA7_CODCOM)
					Aadd( aLogErro, { "CA7_CODCOM", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
				Else
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := CA7->CA7_CODCOM
					xValRegTab("CUZ",cChave,1,,@aLogErro, , { "CA2", "CA7_CODCOM", nRecno })
				EndIf
				
				//Valida o Codigo Conta
				If Empty(CA7->CA7_CONTA)
					Aadd( aLogErro, { "CA7_CONTA", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
				Else
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := CA7->CA7_CONTA
					xValRegTab("C1O",cChave,3,,@aLogErro, , { "CA2", "CA7_CONTA", nRecno })
				EndIf
				
				//------------------------------------------------------------------------------------------------//
				/* Valida a Grid Processo Referenciado - CA8                                                      */
				//------------------------------------------------------------------------------------------------//
				CA8-> (dbSetorder(1))
				CA8->(MsSeek(xFilial("CA8")+CA7->(CA7_ID+CA7_CSTPC+CA7_SEQREG+CA7_NUMCPO+CA7_CODDET+CA7_CODCTA+CA7_CODCOM+CA7_CONTA)))
				While !CA8->(Eof()) .And. xFilial("CA7")+CA7->(CA7_ID+CA7_CSTPC+CA7_SEQREG+CA7_NUMCPO+CA7_CODDET+CA7_CODCTA+CA7_CODCOM+CA7_CONTA) == CA8->(CA8_ID+CA8_CSTPC+CA8_SEQREG+CA8_NUMCPO+CA8_CODDET+CA8_CODCTA+CA8_CODCOM+CA8_CONTA)
					
					//Valida o ID PROC CA8
					If Empty(CA8->CA8_IDPROC)
						Aadd( aLogErro, { "CA8_IDPROC", "000010", "CA2", nRecno } ) //Campo Inconsistente ou Vazio
					Else
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CA8->CA8_IDPROC
						xValRegTab("C1G",cChave,3,,@aLogErro, , { "CA2", "CA8_IDPROC", nRecno })
						
						cOriPrc3:= Alltrim(Posicione("C1G",3,xFilial("C1G")+CA8->CA8_IDPROC,"C1G_INDPRO"))
						
						If !(CA8->cOriPrc3 $ ("1|3|9"))
							AADD(aLogErro,{"CA8_IDPROC","000006","CA2", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
						EndIf
					EndIf
					CA8->(dbSkip())
					
				EndDo
				CA7->(dbSkip())
				
			EndDo
			CA5->(dbSkip())
			
		EndDo
		CA3->(dbSkip())
		
	EndDo

	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "CA2", cStatus )
	
	//Else
	//	AADD(aLogErro,{"CA2_ID","000305","CA2",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xValLogEr(aLogErro)
EndIf	


Return(aLogErro)