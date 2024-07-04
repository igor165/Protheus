#include "TMSMWZE012.ch"
#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
		  
Function TMSMWZE012(aCabAuto,aItemAuto,nOpcAuto)

Local oMBrowse	:= Nil

If aCabAuto != Nil
	
	TECA250( "TMSMWZE012", aCabAuto, Nil, Nil, aItemAuto, nOpcAuto )
Else	
	oMBrowse	:= FwMBrowse():New()
	oMBrowse:SetAlias( 'AAM' )
	oMBrowse:SetDescription( OemToAnsi(STR0001) )  // "Contrato Cliente"
	oMBrowse:Activate()
EndIf

Return

Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  	ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA013" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.TMSA013" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.TMSA013" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.TMSA013" OPERATION 5 ACCESS 0 // "Excluir"
	
Return aRotina

Static Function ModelDef()

Local oModel := Nil
Local oStruAAM := FwFormStruct( 1, 'AAM' )
Local oStruDUX := FwFormStruct( 1, 'DUX' )
Local aCpos	:= {"DUX_NCONTR"}
Local nCpo

oModel := MpFormModel():New( 'TMSMWZE012', /*bPre*/, /*bPost*/, {|| .T. }, /*bCancel*/ )
oModel:SetDescriptin( STR0001 ) // "Contrato Cliente"

oModel:AddFields( 'MdFieldAAM', Nil, oStruAAM )

oModel:AddGrid('MdGridDUX','MdFieldAAM',oStruDUX)

For nCpo := 1 To Len(aCpos)
	If AScan( oStruDUX:aFields, {|x| AllTrim(x[3]) == aCpos[nCpo] }) == 0
		If ExistCpo("SX3",aCpos[nCpo] ,2 , , .F.)

			oStruDUX:AddField( ;                          				// Ord. Tipo Desc. 
				aCpos[nCpo]                           	 			, ; // [01]  C   Nome do Campo 
				Trim( GetSX3Cache(aCpos[nCpo], "X3_DESCRIC") )      , ; // [02]  C   ToolTip do campo 
				aCpos[nCpo]                              			, ; // [03]  C   identificador (ID) do Field 
				GetSX3Cache(aCpos[nCpo], "X3_TIPO")                 , ; // [04]  C   Tipo do campo 
				GetSX3Cache(aCpos[nCpo], "X3_TAMANHO")    			, ; // [05]  N   Tamanho do campo 
				GetSX3Cache(aCpos[nCpo], "X3_DECIMAL")              , ; // [06]  N   Decimal do campo 
				FwBuildFeature( STRUCT_FEATURE_VALID , '{||.T.} ') 	, ; // [07]  B   Code-block de validação do campo 
				FwBuildFeature(2, "{||.T.}" )              			, ; // [08]  B   Code-block de validação When do campo 
				StrTokArr( AllTrim(X3CBox()),';')                  	, ; // [09]  A   Lista de valores permitido do campo 
				X3Obrigat( aCpos[nCpo] )                            , ; // [10]  L   Indica se o campo tem preenchimento obrigatório 
				FwBuildFeature( STRUCT_FEATURE_INIPAD, "") 			, ; // [11]  B   Code-block de inicializacao do campo 
				NIL                                   				, ; // [12]  L   Indica se trata de um campo chave 
				NIL                                    				, ; // [13]  L   Indica se o campo pode receber valor em uma operação de update. 
				( .F. )                             				 )  // [14]  L   Indica se o campo é virtual 
	 
		Endif
	Endif
Next nCpo

oModel:SetRelation( 'MdGridDUX', { { 'DUX_FILIAL', 'xFilial( "DUX" ) ' } , { 'DUX_NCONTR', 'AAM_CONTRT' } } , DUX->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey( { 'AAM_FILIAL', 'AAM_CONTRT' } )

                                                                                                   
Return( oModel )
