#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "CRMA980BRA.CH"  

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980BRA
Cadastro de clientes para localiza��o Brasil.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Function CRMA980BRA()
	Local oMBrowse 	:= BrowseDef()
	
	Private aRotina	:= MenuDef()
	
	//------------------------------------------------------------
	// Variaveis ser�o mantidas at� descontinuar o fonte MATA030
	// devido o uso nas valida��es de campos.
	//------------------------------------------------------------
	Private lCGCValido 	:= .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup) 
	Private l030Auto   	:= .F. // Variavel usada para saber se � rotina autom�tica
	
	oMBrowse:SetMenuDef("CRMA980BRA")
	oMBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Configura��es do browse de clientes para localiza��o Brasil.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oMBrowse := FWLoadBrw("CRMA980")
Return oMBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de clientes para localiza��o Brasil.

@param		Nenhum

@return		Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 		:= FWLoadModel("CRMA980")
	Local oStructFOJ	:= Nil
	Local oEvtBRA		:= CRM980EventBRA():New()
	Local oEvtBRAFIS	:= CRM980EventBRAFIS():New()
	
	//------------------------------------------
	// Tipos de Reten��o.
	//------------------------------------------
	If (FindFunction("FTemMotor") .and. FTemMotor())
	
		oStructFOJ := FWFormStruct(1,"FOJ")
		oModel:AddGrid("FOJDETAIL","SA1MASTER",oStructFOJ)
		
		oStructFOJ:AddField( STR0003															,;	// [01] Titulo do campo "Detalhamento do tipo de reten��o"
							 STR0004															,;	// [02] ToolTip do campo 	//"Descri��o"
							"FOJ_DESCR"															,;	// [03] Id do Field
							"C"																	,;	// [04] Tipo do campo
							40																	,;	// [05] Tamanho do campo
							0																	,;	// [06] Decimal do campo
							{ || .T. }															,;	// [07] Code-block de valida��o do campo
							{ || .T. }															,;	// [08] Code-block de valida��o When do campo
																								,;	// [09] Lista de valores permitido do campo
							.F.																	,;	// [10]	Indica se o campo tem preenchimento obrigat�rio
							FWBuildFeature(STRUCT_FEATURE_INIPAD, "C980CDesc('FOJ_DESCR', 2)")	,;	// [11] Inicializador Padr�o do campo
																								,; 	// [12] Indica se trata de um campo chave
																								,; 	// [13] Indica se o campo pode receber valor em uma opera��o de update.
							.T.	) 																	// [14] Virtual
		
		oStructFOJ:AddTrigger("FOJ_CODIGO", "FOJ_DESCR", { || .T.}, { || C980CDesc("FOJ_DESCR", 1)})		
		oModel:SetRelation("FOJDETAIL", {{ 'FOJ_FILIAL'	, 'xFilial("FOJ")' } ,;
										 { 'FOJ_CLIENT'	, 'A1_COD' }		 ,;
										 { 'FOJ_LOJA'	, 'A1_LOJA' } }, FOJ->(IndexKey(1)) )
		
		oModel:GetModel("FOJDETAIL"):SetOptional(.T.)
		oModel:GetModel("FOJDETAIL"):SetUniqueLine({"FOJ_CODIGO"})
	EndIf
	
	//------------------------------------------
	// Instala��o do evento por modulo Brasil.
	//------------------------------------------
	oModel:InstallEvent("LOCBRA"	,/*cOwner*/,oEvtBRA)
	oModel:InstallEvent("LOCBRAFIS"	,/*cOwner*/,oEvtBRAFIS)
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados de clientes para localiza��o Brasil.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView := FWLoadView("CRMA980")
	Local lMa030Dbt := ExistBlock( "MA030DBT" )
	Local aButtons := {}
	Local aUsrBut := {}
	local nDel := 0
	local nPos := 0
	
	If AliasInDic("FOJ") .AND. FindFunction("FINA024CLI")
		oView:AddUserButton(STR0005,'FOJDETAIL',{|| A010FOJTRet(oView) }) //"Tipo de Reten��es"
	EndIf

	If lMa030Dbt
		If ValType( aUsrBut := Execblock( "MA030DBT", .F., .F. ) ) == "A"
			aButtons := aClone( oView:aUserButtons )
			For nDel := 1 To Len( aUsrBut )
				If ( nPos := aScan( aButtons, { |x| Upper( x[1] ) == Upper( aUsrBut[nDel][1] ) } ) ) > 0
					aButtons[nPos][6] := aUsrBut[nDel][2]
				EndIf
			Next nDel
			oView:aUserButtons := aButtons
		EndIf
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do cadastro de clientes para localiza��o Brasil.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		30/06/2017 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := FWLoadMenuDef("CRMA980")
	
	If HistFiscal()
		ADD OPTION aRotina TITLE STR0002 ACTION "A030Hist()" OPERATION 4 ACCESS 0  //"Hist�rico"
	EndIf
Return aRotina 
