#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA062.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA062S
Cadastro MVC para atender a demanda de emissao de documentos fiscais de saida(Saída de Mercadorias / Serviços Prestados)

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA062S
Local	oBrw	:= FWmBrowse():New()

Local cRelacao	:= 'IIF(!INCLUI .AND. !EMPTY(C20->C20_IDOBR),POSICIONE("T9C",1,XFILIAL("T9C")+C20->C20_IDOBR,"T9C_DSCOBR"),"")'

Private	cIndOpe	:=	'1'	//Utilizado no TAFA062

If Upper(Alltrim(GetSx3Cache("C20_DESOBR", "X3_RELACAO"))) == cRelacao

	//Cria log para campos pessoais/sensiveis
	if findFunction('FwPDLogUser'); FwPDLogUser(ProcName(),2); endif
	
	oBrw:SetDescription( STR0064 )	//"Documento Fiscal de Saída( Saída de Mercadorias / Serviços Prestados )"
	oBrw:SetAlias( 'C20' )
	oBrw:SetMenuDef( 'TAFA062S' )
	oBrw:SetCacheView(.F.)
	oBrw:DisableDetails()
	oBrw:SetFilterDefault( "C20_INDOPE=='1'" )	//1=Saida
	oBrw:AddLegend( "C20_CODSIT=='000001'"     	, "GREEN"	, STR0073 )//"Documento REGULAR"
	oBrw:AddLegend( "C20_CODSIT$'000003/000004'" 	, "RED"  	, STR0074 )//"Documento CANCELADO"
	oBrw:AddLegend( "C20_CODSIT$'000005/000006/'"	, "BLUE" 	, STR0075 )//"Documento DENEGADO/INUTILIZADO"
	oBrw:AddLegend( "C20_CODSIT=='000007'"      	, "YELLOW"	, STR0076 )//"Documento COMPLEMENTAR"
	oBrw:AddLegend( "C20_CODSIT$'000002/000008/'"	, "GRAY" 	, STR0077 )//"Documento EXTEMPORANEO"
	oBrw:AddLegend( "C20_CODSIT=='000009'"      	, "BLACK" 	, STR0078 )//"Documento REGIME ESPECIAL"
	oBrw:Activate()  
Else 
	TafAviso(STR0096, STR0095, {"Ok"}, 3)//"Dicionário Incompatível" "Atenção, foi identificada uma incompatibilidade em seu dicionário de dados. A execução da rotina UPDTAF é obrigatoria para utilização deste cadastro."
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aFuncao := {}
Local aRotina := {}
Local nOpcRot := 0

Local aFuncao := {}

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA062S' OPERATION 2 ACCESS 0
Else
	Aadd( aFuncao, { "" , "Taf062Vld" , "2" } )
	aRotina	:=	xFunMnuTAF( "TAFA062S" , , aFuncao)     
	nOpcRot := aRotina[Len(aRotina)][4]      
/*	aAdd( aRotina, { STR0079 , "TAFNFeStat()"	, 0, nOpcRot++ , 0, Nil } ) //"Status Sefaz"
	aAdd( aRotina, { STR0080 , "TAFAWIZD()"		, 0, nOpcRot++ , 0, Nil } ) //"Wizard. Conf"
	aAdd( aRotina, { STR0081 , "TAFSPNFE()"		, 0, nOpcRot++ , 0, Nil } ) //"Transmissão"
	aAdd( aRotina, { STR0082 , "TAFAMON(.T.)"	, 0, nOpcRot++ , 0, Nil } ) //"Monitor"
	aAdd( aRotina, { STR0083 , "TAFDanfe()"		, 0, nOpcRot++ , 0, Nil } ) //"Danfe" 
	aAdd( aRotina, { STR0084 , "TAFCancNFe()"	, 0, nOpcRot++ , 0, Nil } ) //"Cancela NFe"  
	aAdd( aRotina, { STR0085 , "TAFNFePar()"	, 0, nOpcRot++ , 0, Nil } ) //"Modalidade" */
EndIf      

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FWLoadModel( 'TAFA062' )
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View para atender a necessidade de exibir uma pergunta somente na inclusao. 
	As outras opcoes de manutencao utilizam a VIEW do TAFA062

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Return FWLoadView( 'TAFA062' )
