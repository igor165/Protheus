#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA062.CH"

STATIC aCmpsAlts := {}
STATIC lTsi 	 := IsInCallStack( "Ws034Proc" ) .Or. IsInCallStack("CommitRegs" ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA062
Cadastro MVC para atender a demanda de emissao de documentos fiscais

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0

/*/
//------------------------------------------------------------------
Function TAFA062
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

Aadd( aFuncao, { "" , "Taf062Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA062" , , aFuncao)

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
Local oStruC20 	:= 	FWFormStruct( 1, 'C20' )
Local oStruC21 	:= 	FWFormStruct( 1, 'C21' )
Local oStruC22 	:= 	FWFormStruct( 1, 'C22' )
Local oStruC23 	:= 	FWFormStruct( 1, 'C23' )
Local oStruC24 	:= 	FWFormStruct( 1, 'C24' )
Local oStruC25 	:= 	FWFormStruct( 1, 'C25' )
Local oStruC26 	:= 	FWFormStruct( 1, 'C26' )
Local oStruC27 	:= 	FWFormStruct( 1, 'C27' )
Local oStruC28 	:= 	FWFormStruct( 1, 'C28' )
Local oStruC29 	:= 	FWFormStruct( 1, 'C29' )
Local oStruC2A 	:= 	FWFormStruct( 1, 'C2A' )
Local oStruC2B 	:= 	FWFormStruct( 1, 'C2B' )
Local oStruC2C 	:= 	FWFormStruct( 1, 'C2C' )
Local oStruC2D 	:= 	FWFormStruct( 1, 'C2D' )
Local oStruC2E 	:= 	FWFormStruct( 1, 'C2E' )
Local oStruC2F 	:= 	FWFormStruct( 1, 'C2F' )
Local oStruC2G 	:= 	FWFormStruct( 1, 'C2G' )
Local oStruC2H 	:= 	FWFormStruct( 1, 'C2H' )
Local oStruC2I 	:= 	FWFormStruct( 1, 'C2I' )
Local oStruC6W 	:= 	FWFormStruct( 1, 'C6W' )
Local oStruC7B 	:= 	FWFormStruct( 1, 'C7B' )
Local oStruCAI 	:= 	FWFormStruct( 1, 'CAI' )
Local oStruCH1 	:= 	FWFormStruct( 1, 'CH1' )
Local oStruCH2 	:= 	FWFormStruct( 1, 'CH2' )
Local oStruT00 	:= 	FWFormStruct( 1, 'T00' )

Local oStruC30 	:= 	FWFormStruct( 1, 'C30' )
Local oStruC31 	:= 	FWFormStruct( 1, 'C31' )
Local oStruC32 	:= 	FWFormStruct( 1, 'C32' )
Local oStruC33 	:= 	FWFormStruct( 1, 'C33' )
Local oStruC34 	:= 	FWFormStruct( 1, 'C34' )
Local oStruC35 	:= 	FWFormStruct( 1, 'C35' )
Local oStruC36 	:= 	FWFormStruct( 1, 'C36' )
Local oStruC37 	:= 	FWFormStruct( 1, 'C37' )
Local oStruC38 	:= 	FWFormStruct( 1, 'C38' )
Local oStruC39 	:= 	FWFormStruct( 1, 'C39' )
Local oStruC3F 	:= 	FWFormStruct( 1, 'C3F' )
Local oStruC3G 	:= 	FWFormStruct( 1, 'C3G' )
Local oStruC3H 	:= 	FWFormStruct( 1, 'C3H' )
Local oStruC3A 	:= 	FWFormStruct( 1, 'C3A' )
Local oStruC3I 	:= 	FWFormStruct( 1, 'C3I' )
Local oStruT60 	:= ""
Local oStruT9Q 	:= {}
Local oStruV4C	:= ""
Local oStruV4D	:= ""
Local oModel 	:= 	MPFormModel():New( 'TAFA062' ,,{ |oModel| ValidModel( oModel ) }, { |oModel| SaveModel(oModel) } )
Local oModelC29	:= Nil
Local lReinf20  := .F.
Local aRelacao	as array

Static lAtu	as logical

/*
------------------------------------------------------------------------------------------------------------------
O tratamento abaixo verifica se o dicionario contempla as alterações na Tabela SX9 (Dicionario TSI 007859).
Se verdadeiro
	Layout T013AL removido da view
	Layout T013AM passa a ser filho do layout T013
Senão
	Layout T013AL implementado na view
	Layout T013AM passa a ser filho do layout T013AL
	Layout T013AL passa a ser filho do layout T013;
*/

lAtu := .F.

if FwSX9Util():SearchX9Paths( 'C20', 'C2D', @aRelacao )
	if aScan( aRelacao, { |x| x[1] == 'C20' .and. x[3] = 'C2D' .and. alltrim(x[4]) == "C2D_CHVNF"  } ) > 0
		lAtu := .T.
	endif
endif


//----------------------------------------------------------------------------------------------------------------
If TAFAlsInDic("T9Q")
	oStruT9Q 	:= 	FWFormStruct( 1, 'T9Q' )
EndIf

If TAFAlsInDic( "T60" )
	 oStruT60 := FWFormStruct( 1, 'T60' )
EndIf

If TAFAlsInDic( "V4D" )
	oStruV4C := FWFormStruct( 1, 'V4C')
	oStruV4D := FWFormStruct( 1, 'V4D')
	lReinf20 := .T.
EndIf

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruC20:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })	
	oStruC21:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC22:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC23:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC24:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC25:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC26:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC27:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC28:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC29:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC2A:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC2B:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	//Proteção caso não tenha sido aplicado o dicionario 007859 TSI
	If lAtu == .F.
		oStruC2C:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIF
	oStruC2D:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC2E:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC2F:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	//oStruC2G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC2H:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC2I:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC6W:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC7B:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	//oStruC30:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC31:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC32:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC33:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC34:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	//oStruC35:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC36:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC37:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC38:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC39:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC3F:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC3G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC3H:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC3A:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruC3I:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	oStruT00:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	
	If TAFAlsInDic( "T60" )
		oStruT60:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf
EndIf

aCmpsAlts	:=	{}

oStruC20:SetProperty( "C20_DTES", MODEL_FIELD_OBRIGAT, IIf(Type( "cIndOpe" ) != "U", IIF(cIndOpe == '0', .T., .F.), .T. ) )
If !IsBlind()
	oStruC20:SetProperty( 'C20_CODMOD' , MODEL_FIELD_WHEN , {|| .F. } )
EndIf
oStruC20:SetProperty( 'C20_CODMOD' , MODEL_FIELD_INIT , {| oModel | MV_PAR01 } )
oStruC20:SetProperty( 'C20_INDOPE' , MODEL_FIELD_INIT , {| oModel | cIndOpe } )

//Para integracoes via tsi, nao deve entrar nessa regra, pois o setvalue retorna negativo em um campo que nao pode ser editado em tela.
if !lTsi
	oStruC20:SetProperty( 'C20_INDOPE' , MODEL_FIELD_WHEN , {|| .F. } )
endif

//Definindo o modelo de dados

//CAPA DO DOCUMENTO FISCAL E SEUS FILHOS
oModel:AddFields('MODEL_C20', /*cOwner*/,  oStruC20 )
//oModel:GetModel( 'MODEL_C20' ):SetFldNoCopy( { 'C20_NUMDOC' } )
oModel:GetModel( 'MODEL_C20' ):SetPrimaryKey( { 'C20_CODMOD' , 'C20_INDOPE' , 'C20_TPDOC' , 'C20_INDEMI' , 'C20_CODPAR' , 'C20_CODSIT' , 'C20_SERIE' , 'C20_SUBSER' , 'C20_NUMDOC' , 'C20_DTDOC' , 'C20_DTES' } )

oModel:AddGrid ( 'MODEL_C21', 'MODEL_C20', oStruC21 )
oModel:GetModel( 'MODEL_C21' ):SetUniqueLine( { 'C21_CODINF' } )
oModel:GetModel( 'MODEL_C21' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C22', 'MODEL_C21', oStruC22 )
oModel:GetModel( 'MODEL_C22' ):SetUniqueLine( { 'C22_NUMERO' } )
oModel:GetModel( 'MODEL_C22' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C23', 'MODEL_C20', oStruC23 )
oModel:GetModel( 'MODEL_C23' ):SetUniqueLine( { 'C23_TIPO' , 'C23_NUMDOC' , 'C23_NDRAW', 'C23_PGPIS', 'C23_PGCOF', 'C23_LES' } )
oModel:GetModel( 'MODEL_C23' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C24', 'MODEL_C20', oStruC24 )
oModel:GetModel( 'MODEL_C24' ):SetUniqueLine( { 'C24_NUMSEQ' } )
oModel:GetModel( 'MODEL_C24' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C25', 'MODEL_C21', oStruC25 )
oModel:GetModel( 'MODEL_C25' ):SetUniqueLine( { 'C25_IDENTI' } )
oModel:GetModel( 'MODEL_C25' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C26', 'MODEL_C21', oStruC26 )
oModel:GetModel( 'MODEL_C26' ):SetUniqueLine( { 'C26_CODMOD' , 'C26_INDEMI' , 'C26_CODPAR' , 'C26_SERIE' , 'C26_SUBSER' , 'C26_NUMDOC' , 'C26_DTDOC' } )
oModel:GetModel( 'MODEL_C26' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C27', 'MODEL_C21', oStruC27 )
oModel:GetModel( 'MODEL_C27' ):SetUniqueLine( { 'C27_CODECF' , 'C27_NUMDOC' , 'C27_DTDOC' } )
oModel:GetModel( 'MODEL_C27' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C28', 'MODEL_C21', oStruC28 )
oModel:GetModel( 'MODEL_C28' ):SetUniqueLine( { 'C28_INDCAR' , 'C28_PARCOL' , 'C28_PARENT' } )
oModel:GetModel( 'MODEL_C28' ):SetOptional( .T. )

oModel:AddFields('MODEL_C29', 'MODEL_C20', oStruC29 )
oModel:GetModel( 'MODEL_C29' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C2A', 'MODEL_C29', oStruC2A ,{ | oMdlG, nLine, cAction, cField, xValNew, xValOld | VldC2APre( oMdlG, nLine, cAction, cField, xValNew, xValOld ) },,,, { |oMdlG| LoadGrid( oMdlG , 'C2A' ) } )
oModel:GetModel( 'MODEL_C2A' ):SetUniqueLine( { 'C2A_NUMPAR' } )
oModel:GetModel( 'MODEL_C2A' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C2A' ):SetNoInsertLine(.T.)
oModel:GetModel( 'MODEL_C2A' ):SetNoDeleteLine(.T.)

oModel:AddGrid ( 'MODEL_C2B', 'MODEL_C20', oStruC2B )
oModel:GetModel( 'MODEL_C2B' ):SetUniqueLine( { 'C2B_CODPAR' , 'C2B_CODVEI' } )
oModel:GetModel( 'MODEL_C2B' ):SetOptional( .T. )
//Proteção caso não tenha sido aplicado o dicionario 007859 TSI
If lAtu == .T.
	oModel:AddGrid ( 'MODEL_C2D', 'MODEL_C20', oStruC2D )
Else
	oModel:AddGrid ( 'MODEL_C2C', 'MODEL_C20', oStruC2C )
	oModel:GetModel( 'MODEL_C2C' ):SetUniqueLine( { 'C2C_CODOBS' } ) 
	oModel:GetModel( 'MODEL_C2C' ):SetOptional( .T. )

	oModel:AddGrid ( 'MODEL_C2D', 'MODEL_C2C', oStruC2D )
Endif
oModel:GetModel( 'MODEL_C2D' ):SetUniqueLine( { 'C2D_CODAJ' , 'C2D_CODITE', 'C2D_IDSUBI', 'C2D_ALQICM' } )
oModel:GetModel( 'MODEL_C2D' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_T00', 'MODEL_C2D', oStruT00 )
oModel:GetModel( 'MODEL_T00' ):SetUniqueLine( { 'T00_IDSUBI','T00_ID','T00_CODIGO' } )
oModel:GetModel( 'MODEL_T00' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C2E', 'MODEL_C20', oStruC2E )
oModel:GetModel( 'MODEL_C2E' ):SetUniqueLine( { 'C2E_CODCON' , 'C2E_TPLIG' , 'C2E_GRPTEN' } )
oModel:GetModel( 'MODEL_C2E' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C2F', 'MODEL_C20', oStruC2F )
oModel:GetModel( 'MODEL_C2F' ):SetUniqueLine( { 'C2F_CODTRI' , 'C2F_CST' , 'C2F_CFOP' , 'C2F_CODSER' , 'C2F_ALIQ' } )
oModel:GetModel( 'MODEL_C2F' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C2G', 'MODEL_C20', oStruC2G )
oModel:GetModel( 'MODEL_C2G' ):SetUniqueLine( { 'C2G_INDSER' , 'C2G_DTINI' , 'C2G_DTFIM' , 'C2G_PERFIS' } )
oModel:GetModel( 'MODEL_C2G' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C2H', 'MODEL_C20', oStruC2H )
oModel:GetModel( 'MODEL_C2H' ):SetUniqueLine( { 'C2H_OPER' , 'C2H_UF' } )
oModel:GetModel( 'MODEL_C2H' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C2I', 'MODEL_C20', oStruC2I )
oModel:GetModel( 'MODEL_C2I' ):SetUniqueLine( { 'C2I_NUMDOC' } )
oModel:GetModel( 'MODEL_C2I' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C3F', 'MODEL_C20', oStruC3F )
oModel:GetModel( 'MODEL_C3F' ):SetUniqueLine( { 'C3F_UFORIG' , 'C3F_CMUNOR' , 'C3F_UFDEST' , 'C3F_CMUNDE' } )
oModel:GetModel( 'MODEL_C3F' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C3G', 'MODEL_C20', oStruC3G )
oModel:GetModel( 'MODEL_C3G' ):SetUniqueLine( { 'C3G_UFORIG' , 'C3G_CMUNOR' , 'C3G_UFDEST' , 'C3G_CMUNDE' } )
oModel:GetModel( 'MODEL_C3G' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C3G' ):SetNoInsertLine( .T. )

oModel:AddGrid ( 'MODEL_C3H', 'MODEL_C20', oStruC3H )
oModel:GetModel( 'MODEL_C3H' ):SetUniqueLine( { 'C3H_UFORIG' , 'C3H_CMUNOR' , 'C3H_UFDEST' , 'C3H_CMUNDE' } )
oModel:GetModel( 'MODEL_C3H' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C3H' ):SetNoInsertLine( .T. )

oModel:AddGrid ( 'MODEL_C3A', 'MODEL_C20', oStruC3A )
oModel:GetModel( 'MODEL_C3A' ):SetUniqueLine( { 'C3A_DESPAC' , 'C3A_CPARRE' , 'C3A_CPARDE' } )
oModel:GetModel( 'MODEL_C3A' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C3I', 'MODEL_C20', oStruC3I )
oModel:GetModel( 'MODEL_C3I' ):SetUniqueLine( { 'C3I_CODMOD' , ' C3I_SERIE' , ' C3I_NUMDOC' } )
oModel:GetModel( 'MODEL_C3I' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C6W', 'MODEL_C20', oStruC6W )
oModel:GetModel( 'MODEL_C6W' ):SetUniqueLine( { 'C6W_NUMERO' } )
oModel:GetModel( 'MODEL_C6W' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C7B', 'MODEL_C20', oStruC7B )
oModel:GetModel( 'MODEL_C7B' ):SetUniqueLine( { 'C7B_UF' } )
oModel:GetModel( 'MODEL_C7B' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_CAI', 'MODEL_C20', oStruCAI )
oModel:GetModel( 'MODEL_CAI' ):SetUniqueLine( { 'CAI_SAFRA','CAI_REFER'} )
oModel:GetModel( 'MODEL_CAI' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_CAI' ):SetNoInsertLine( .T. )

If TAFAlsInDic( "T60" )
	oModel:AddGrid ( 'MODEL_T60', 'MODEL_C20', oStruT60 )
	oModel:GetModel( 'MODEL_T60' ):SetUniqueLine( { 'T60_NUMDOC' , 'T60_SERIE' , 'T60_SUBSER', 'T60_CODPAR' } )
	oModel:GetModel( 'MODEL_T60' ):SetOptional( .T. )
EndIf

oModel:AddGrid ( 'MODEL_CH1', 'MODEL_CAI', oStruCH1 )
oModel:GetModel( 'MODEL_CH1' ):SetUniqueLine( {'CH1_DIA'} )
oModel:GetModel( 'MODEL_CH1' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_CH2', 'MODEL_CAI', oStruCH2 )
oModel:GetModel( 'MODEL_CH2' ):SetUniqueLine( {'CH2_DESDED'} )
oModel:GetModel( 'MODEL_CH2' ):SetOptional( .T. )

//ITENS DO DOCUMENTO FISCAL E SEUS FILHOS

if !lTsi //Para integracoes via tsi, nao deve entrar nessa regra
	oModel:AddGrid ( 'MODEL_C30', 'MODEL_C20', oStruC30 , { |oModelGrid , nLine , cAction , cField , xValNew , xValOld| A62C2FPre( 1 , oModelGrid , nLine , cAction , cField , xValNew , xValOld ) } , { |oModelGrid| A62C30Pos( oModelGrid ) } )
else
	//Tira a obrigatoriedade de informar conteúdo nos campos.
	oStruC30:SetProperty('C30_VLRITE',MODEL_FIELD_OBRIGAT,.f.) 
	oStruC30:SetProperty('C30_TOTAL' ,MODEL_FIELD_OBRIGAT,.f.) 

	oModel:AddGrid ( 'MODEL_C30', 'MODEL_C20', oStruC30 )
endif
oModel:GetModel( 'MODEL_C30' ):SetMaxLine(2000)
oModel:GetModel( 'MODEL_C30' ):SetUniqueLine( { 'C30_NUMITE' } )
oModel:GetModel( 'MODEL_C30' ):SetOptional( .T. )	//Para Bilhetes (Modelos 13, 14, 15 e 16) e RMD (Modelo 18) não eh necessario informar o item

oModel:AddGrid ( 'MODEL_C31', 'MODEL_C30', oStruC31 )
oModel:GetModel( 'MODEL_C31' ):SetUniqueLine( { 'C31_LOTE' } )
oModel:GetModel( 'MODEL_C31' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C32', 'MODEL_C30', oStruC32 )
oModel:GetModel( 'MODEL_C32' ):SetUniqueLine( { 'C32_CCLASS' , 'C32_INDREC' } )
oModel:GetModel( 'MODEL_C32' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C33', 'MODEL_C30', oStruC33 )
oModel:GetModel( 'MODEL_C33' ):SetUniqueLine( { 'C33_INDARM' , 'C33_NUMARM' } )
oModel:GetModel( 'MODEL_C33' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C34', 'MODEL_C30', oStruC34 )
oModel:GetModel( 'MODEL_C34' ):SetUniqueLine( { 'C34_INDVEI' , 'C34_CNPJ' } )
oModel:GetModel( 'MODEL_C34' ):SetOptional( .T. )

if !lTsi //Para integracoes via tsi, nao deve entrar nessa regra
	oModel:AddGrid ( 'MODEL_C35', 'MODEL_C30', oStruC35 , { |oModelGrid , nLine , cAction , cField , xValNew , xValOld| A62C2FPre( 2 , oModelGrid , nLine , cAction , cField , xValNew , xValOld ) } )
else
	oModel:AddGrid ( 'MODEL_C35', 'MODEL_C30', oStruC35 )
endif

oModel:GetModel( 'MODEL_C35' ):SetUniqueLine( { 'C35_CODTRI' , 'C35_CST' , 'C35_ALIQ' } )
oModel:GetModel( 'MODEL_C35' ):SetOptional( .T. )

If lReinf20 
	oModel:AddGrid ( 'MODEL_V4C', 'MODEL_C35', oStruV4C )
	oModel:GetModel( 'MODEL_V4C' ):SetUniqueLine( { 'V4C_TPDEDU' } )
	oModel:GetModel( 'MODEL_V4C' ):SetOptional( .T. )
	
	oModel:AddGrid ( 'MODEL_V4D', 'MODEL_C35', oStruV4D )
	oModel:GetModel( 'MODEL_V4D' ):SetUniqueLine( { 'V4D_IDTPIS' } )
	oModel:GetModel( 'MODEL_V4D' ):SetOptional( .T. )
EndIf

oModel:AddGrid ( 'MODEL_C36', 'MODEL_C30', oStruC36 )
oModel:GetModel( 'MODEL_C36' ):SetUniqueLine( { 'C36_NUMTAN' } )
oModel:GetModel( 'MODEL_C36' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C37', 'MODEL_C30', oStruC37 )
oModel:GetModel( 'MODEL_C37' ):SetUniqueLine( { 'C37_CODMOD' , 'C37_SERIE' , 'C37_NUMDOC' , 'C37_DTDOC', 'C37_CODPAR' } )
oModel:GetModel( 'MODEL_C37' ):SetOptional( .T. )

oModel:AddGrid ( 'MODEL_C38', 'MODEL_C30', oStruC38 )
oModel:GetModel( 'MODEL_C38' ):SetUniqueLine( { 'C38_CCLASS' , 'C38_INDREC' } )
oModel:GetModel( 'MODEL_C38' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C38' ):SetNoInsertLine( .T. )

/* O campo C38_INDREC eh utilizado e se faz obrigatorio no metadados para obrigacoes acessorias EFD contribuicoes \ SPED e CIEF-CE.
Nas integracoes de notas que possuem algum complemento, nao necessariamente precisam desse campo preenchido e se faz uma excecao.
ex: Notas com complemento que nao possuem Ind Rec mas precisam ser integradas para gerar GiA-SP. Se trata de uma NFe de entrada, 
conta de telefone do proprio estabelecimento, o campo referente entende se como receita, o que estaria incorreto de acordo com o tipo de NF.
Ao alterar a nota no MVC, o campo seria solicitado como obrigatorio, informacao que nao procede. */
oStruC38:SetProperty('C38_INDREC',MODEL_FIELD_OBRIGAT,.F.) 

if lTsi //Deverá ser acertado no pacote do TSI a questao de obrigatoriedade desses campos.
	oStruC30:SetProperty('C30_INDMOV',MODEL_FIELD_OBRIGAT,.F.)
	oStruC2F:SetProperty('C2F_DCST',MODEL_FIELD_OBRIGAT,.F.) //campo virtual sem necessidade de ser obrigatorio
endif

oModel:AddGrid ( 'MODEL_C39', 'MODEL_C30', oStruC39 )
oModel:GetModel( 'MODEL_C39' ):SetUniqueLine( { 'C39_UFORIG' , 'C39_CMUNOR' , 'C39_UFDEST' , 'C39_CMUNDE' } )
oModel:GetModel( 'MODEL_C39' ):SetOptional( .T. )

If TAFAlsInDic("T9Q")
	oModel:AddGrid ( 'MODEL_T9Q', 'MODEL_C30', oStruT9Q )
	oModel:GetModel( 'MODEL_T9Q' ):SetUniqueLine({"T9Q_NUMPRO", "T9Q_IDSUSP", "T9Q_CODTRI", "T9Q_TPPROC"})
	oModel:GetModel( 'MODEL_T9Q' ):SetOptional( .T. )
EndIf

//Definindo as relacoes entre os modelos
oModel:SetRelation( 'MODEL_C21' , { { 'C21_FILIAL' , 'xFilial( "C21" )' } , { 'C21_CHVNF' , 'C20_CHVNF' } } , C21->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C22' , { { 'C22_FILIAL' , 'xFilial( "C22" )' } , { 'C22_CHVNF' , 'C20_CHVNF' } , { 'C22_CODINF' , 'C21_CODINF' } } , C22->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C25' , { { 'C25_FILIAL' , 'xFilial( "C25" )' } , { 'C25_CHVNF' , 'C20_CHVNF' } , { 'C25_CODINF' , 'C21_CODINF' } } , C25->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C26' , { { 'C26_FILIAL' , 'xFilial( "C26" )' } , { 'C26_CHVNF' , 'C20_CHVNF' } , { 'C26_CODINF' , 'C21_CODINF' } } , C26->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C27' , { { 'C27_FILIAL' , 'xFilial( "C27" )' } , { 'C27_CHVNF' , 'C20_CHVNF' } , { 'C27_CODINF' , 'C21_CODINF' } } , C27->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C28' , { { 'C28_FILIAL' , 'xFilial( "C28" )' } , { 'C28_CHVNF' , 'C20_CHVNF' } , { 'C28_CODINF' , 'C21_CODINF' } } , C28->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C23' , { { 'C23_FILIAL' , 'xFilial( "C23" )' } , { 'C23_CHVNF' , 'C20_CHVNF' } } , C23->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C24' , { { 'C24_FILIAL' , 'xFilial( "C24" )' } , { 'C24_CHVNF' , 'C20_CHVNF' } } , C24->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C29' , { { 'C29_FILIAL' , 'xFilial( "C29" )' } , { 'C29_CHVNF' , 'C20_CHVNF' } } , C29->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2A' , { { 'C2A_FILIAL' , 'xFilial( "C2A" )' } , { 'C2A_CHVNF' , 'C20_CHVNF' } , { 'C2A_INDEMI' , 'C29_INDEMI' } , { 'C2A_INDTIT' , 'C29_INDTIT' } , { 'C2A_NUMTIT' , 'C29_NUMTIT' } } , C2A->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2B' , { { 'C2B_FILIAL' , 'xFilial( "C2B" )' } , { 'C2B_CHVNF' , 'C20_CHVNF' } } , C2B->( IndexKey( 1 ) ) )
//Proteção caso não tenha sido aplicado o dicionario 007859 TSI
IF lAtu == .T.
	oModel:SetRelation( 'MODEL_C2D' , { { 'C2D_FILIAL' , 'xFilial( "C2D" )' } , { 'C2D_CHVNF' , 'C20_CHVNF' } } , C2D->( IndexKey( 1 ) ) )
Else
	oModel:SetRelation( 'MODEL_C2C' , { { 'C2C_FILIAL' , 'xFilial( "C2C" )' } , { 'C2C_CHVNF' , 'C20_CHVNF' } } , C2C->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'MODEL_C2D' , { { 'C2D_FILIAL' , 'xFilial( "C2D" )' } , { 'C2D_CHVNF' , 'C20_CHVNF' } , { 'C2D_CODOBS' , 'C2C_CODOBS' } } , C2D->( IndexKey( 1 ) ) )
EndIF
oModel:SetRelation( 'MODEL_T00' , { { 'T00_FILIAL' , 'xFilial( "T00" )' } , { 'T00_CHVNF' , 'C20_CHVNF' } , { 'T00_ID' , 'C2D_ID' },{ 'T00_IDSUBI' , 'C2D_IDSUBI' }}, T00->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2E' , { { 'C2E_FILIAL' , 'xFilial( "C2E" )' } , { 'C2E_CHVNF' , 'C20_CHVNF' } } , C2E->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2F' , { { 'C2F_FILIAL' , 'xFilial( "C2F" )' } , { 'C2F_CHVNF' , 'C20_CHVNF' } } , C2F->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2G' , { { 'C2G_FILIAL' , 'xFilial( "C2G" )' } , { 'C2G_CHVNF' , 'C20_CHVNF' } } , C2G->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2H' , { { 'C2H_FILIAL' , 'xFilial( "C2H" )' } , { 'C2H_CHVNF' , 'C20_CHVNF' } } , C2H->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2I' , { { 'C2I_FILIAL' , 'xFilial( "C2I" )' } , { 'C2I_CHVNF' , 'C20_CHVNF' } } , C2I->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C3F' , { { 'C3F_FILIAL' , 'xFilial( "C3F" )' } , { 'C3F_CHVNF' , 'C20_CHVNF' } } , C3F->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C3G' , { { 'C3G_FILIAL' , 'xFilial( "C3G" )' } , { 'C3G_CHVNF' , 'C20_CHVNF' } } , C3G->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C3H' , { { 'C3H_FILIAL' , 'xFilial( "C3H" )' } , { 'C3H_CHVNF' , 'C20_CHVNF' } } , C3H->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C3A' , { { 'C3A_FILIAL' , 'xFilial( "C3A" )' } , { 'C3A_CHVNF' , 'C20_CHVNF' } } , C3A->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C3I' , { { 'C3I_FILIAL' , 'xFilial( "C3I" )' } , { 'C3I_CHVNF' , 'C20_CHVNF' } , { 'C3I_DESPAC' , 'C3A_DESPAC' } , { 'C3I_CPARRE' , 'C3A_CPARRE' } , { 'C3I_CPARDE' , 'C3A_CPARDE' } } , C3I->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C6W' , { { 'C6W_FILIAL' , 'xFilial( "C6W" )' } , { 'C6W_CHVNF' , 'C20_CHVNF' } } , C6W->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C7B' , { { 'C7B_FILIAL' , 'xFilial( "C7B" )' } , { 'C7B_CHVNF' , 'C20_CHVNF' } } , C7B->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CAI' , { { 'CAI_FILIAL' , 'xFilial( "CAI" )' } , { 'CAI_CHVNF' , 'C20_CHVNF' } } , CAI->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CH1' , { { 'CH1_FILIAL' , 'xFilial( "CH1" )' } , { 'CH1_CHVNF' , 'C20_CHVNF' } , { 'CH1_SAFRA' , 'CAI_SAFRA' } , { 'CH1_REFER' , 'CAI_REFER' }} , CH1->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_CH2' , { { 'CH2_FILIAL' , 'xFilial( "CH2" )' } , { 'CH2_CHVNF' , 'C20_CHVNF' } , { 'CH2_SAFRA' , 'CAI_SAFRA' } , { 'CH2_REFER' , 'CAI_REFER' }} , CH2->( IndexKey( 1 ) ) )

oModel:SetRelation( 'MODEL_C30' , { { 'C30_FILIAL' , 'xFilial( "C30" )' } , { 'C30_CHVNF' , 'C20_CHVNF' } } , C30->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C31' , { { 'C31_FILIAL' , 'xFilial( "C31" )' } , { 'C31_CHVNF' , 'C20_CHVNF' } , { 'C31_NUMITE' , 'C30_NUMITE' } , { 'C31_CODITE' , 'C30_CODITE' } } , C31->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C32' , { { 'C32_FILIAL' , 'xFilial( "C32" )' } , { 'C32_CHVNF' , 'C20_CHVNF' } , { 'C32_NUMITE' , 'C30_NUMITE' } , { 'C32_CODITE' , 'C30_CODITE' } } , C32->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C33' , { { 'C33_FILIAL' , 'xFilial( "C33" )' } , { 'C33_CHVNF' , 'C20_CHVNF' } , { 'C33_NUMITE' , 'C30_NUMITE' } , { 'C33_CODITE' , 'C30_CODITE' } } , C33->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C34' , { { 'C34_FILIAL' , 'xFilial( "C34" )' } , { 'C34_CHVNF' , 'C20_CHVNF' } , { 'C34_NUMITE' , 'C30_NUMITE' } , { 'C34_CODITE' , 'C30_CODITE' } } , C34->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C35' , { { 'C35_FILIAL' , 'xFilial( "C35" )' } , { 'C35_CHVNF' , 'C20_CHVNF' } , { 'C35_NUMITE' , 'C30_NUMITE' } , { 'C35_CODITE' , 'C30_CODITE' } } , C35->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C36' , { { 'C36_FILIAL' , 'xFilial( "C36" )' } , { 'C36_CHVNF' , 'C20_CHVNF' } , { 'C36_NUMITE' , 'C30_NUMITE' } , { 'C36_CODITE' , 'C30_CODITE' } } , C36->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C37' , { { 'C37_FILIAL' , 'xFilial( "C37" )' } , { 'C37_CHVNF' , 'C20_CHVNF' } , { 'C37_NUMITE' , 'C30_NUMITE' } , { 'C37_CODITE' , 'C30_CODITE' } } , C37->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C38' , { { 'C38_FILIAL' , 'xFilial( "C38" )' } , { 'C38_CHVNF' , 'C20_CHVNF' } , { 'C38_NUMITE' , 'C30_NUMITE' } , { 'C38_CODITE' , 'C30_CODITE' } } , C38->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C39' , { { 'C39_FILIAL' , 'xFilial( "C39" )' } , { 'C39_CHVNF' , 'C20_CHVNF' } , { 'C39_NUMITE' , 'C30_NUMITE' } , { 'C39_CODITE' , 'C30_CODITE' } } , C39->( IndexKey( 1 ) ) )

If TAFAlsInDic("T9Q")
	oModel:SetRelation( 'MODEL_T9Q' , { { 'T9Q_FILIAL' , 'xFilial( "T9Q" )' } , { 'T9Q_CHVNF' , 'C20_CHVNF' } , { 'T9Q_NUMITE' , 'C30_NUMITE' } , { 'T9Q_ID' 	 , 'C30_CODITE' } } , T9Q->( IndexKey( 1 ) ) )
EndIf

If TAFAlsInDic( "T60" )
	oModel:SetRelation( 'MODEL_T60' , { { 'T60_FILIAL' , 'xFilial( "T60" )' } , { 'T60_CHVNF' , 'C20_CHVNF' } } , T60->( IndexKey( 1 ) ) )
EndIf

If lReinf20
	oModel:SetRelation('MODEL_V4C' , {{'V4C_FILIAL' , 'xFilial( "V4C" )'} , {'V4C_CHVNF' ,  'C20_CHVNF' } , { 'V4C_NUMITE' , 'C30_NUMITE'} , { 'V4C_CODITE' , 'C30_CODITE' } , { 'V4C_CODTRI', 'C35_CODTRI' } } , V4C-> ( IndexKey( 1 ) ) )
	oModel:SetRelation('MODEL_V4D' , {{'V4D_FILIAL' , 'xFilial( "V4D" )'} , {'V4D_CHVNF' ,  'C20_CHVNF' } , { 'V4D_NUMITE' , 'C30_NUMITE'} , { 'V4D_CODITE' , 'C30_CODITE' } , { 'V4D_CODTRI', 'C35_CODTRI' } } , V4D-> ( IndexKey( 1 ) ) )
EndIf

oModel:AddRules( 'MODEL_C20', 'C20_CODMOD', 'MODEL_C2E', 'C2E_CODCON', 2 )
oModel:AddRules( 'MODEL_C35', 'C35_CODTRI', 'MODEL_C35', 'C35_CST', 2 )
oModel:AddRules( 'MODEL_C35', 'C35_CODTRI', 'MODEL_C35', 'C35_MODBC', 2 )
oModel:AddRules( 'MODEL_C2F', 'C2F_CODTRI', 'MODEL_C2F', 'C2F_CST', 2 )

oModel:SetOnDemand(.T.)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= 	FWLoadModel( 'TAFA062' )
Local oView 		:= 	FWFormView():New()

//Estruturas da Capa do Documento Fiscal
Local oStruC20 	:= 	Nil
Local oStruC20B := 	Nil
Local oStruC21 	:= 	FWFormStruct( 2, 'C21' )
Local oStruC22 	:= 	FWFormStruct( 2, 'C22' )
Local oStruC23 	:= 	FWFormStruct( 2, 'C23' )
Local oStruC24 	:= 	FWFormStruct( 2, 'C24' )
Local oStruC25 	:= 	FWFormStruct( 2, 'C25' )
Local oStruC26 	:= 	FWFormStruct( 2, 'C26' )
Local oStruC27 	:= 	FWFormStruct( 2, 'C27' )
Local oStruC28 	:= 	FWFormStruct( 2, 'C28' )
Local oStruC29 	:= 	FWFormStruct( 2, 'C29' )
Local oStruC2A 	:= 	FWFormStruct( 2, 'C2A' )
Local oStruC2B 	:= 	FWFormStruct( 2, 'C2B' )
Local oStruC2C 	:= 	FWFormStruct( 2, 'C2C' )
Local oStruC2D 	:= 	FWFormStruct( 2, 'C2D' )
Local oStruC2E 	:= 	FWFormStruct( 2, 'C2E' )
Local oStruC2F 	:= 	FWFormStruct( 2, 'C2F' )
Local oStruC2G 	:= 	FWFormStruct( 2, 'C2G' )
Local oStruC2H 	:= 	FWFormStruct( 2, 'C2H' )
Local oStruC2I 	:= 	FWFormStruct( 2, 'C2I' )
Local oStruC6W 	:= 	FWFormStruct( 2, 'C6W' )
Local oStruC7B 	:= 	FWFormStruct( 2, 'C7B' )
Local oStruCAI 	:= 	FWFormStruct( 2, 'CAI' )
Local oStruCH1 	:= 	FWFormStruct( 2, 'CH1' )
Local oStruCH2 	:= 	FWFormStruct( 2, 'CH2' )
Local oStruT00 	:= 	FWFormStruct( 2, 'T00' )

Local oStruT60	:= ""

//Estruturas do Item do Documento Fiscal
Local oStruC30 	:= 	FWFormStruct( 2, 'C30' )
Local oStruC31 	:= 	FWFormStruct( 2, 'C31' )
Local oStruC32 	:= 	FWFormStruct( 2, 'C32' )
Local oStruC33 	:= 	FWFormStruct( 2, 'C33' )
Local oStruC34 	:= 	FWFormStruct( 2, 'C34' )
Local oStruC35 	:= 	FWFormStruct( 2, 'C35' )
Local oStruC36 	:= 	FWFormStruct( 2, 'C36' )
Local oStruC37 	:= 	FWFormStruct( 2, 'C37' )
Local oStruC38 	:= 	FWFormStruct( 2, 'C38' )
Local oStruC39 	:= 	FWFormStruct( 2, 'C39' )
Local oStruC3F 	:= 	FWFormStruct( 2, 'C3F' )
Local oStruC3G 	:= 	FWFormStruct( 2, 'C3G' )
Local oStruC3H 	:= 	FWFormStruct( 2, 'C3H' )
Local oStruC3A 	:= 	FWFormStruct( 2, 'C3A' )
Local oStruC3I 	:= 	FWFormStruct( 2, 'C3I' )
Local oStruT9Q	:= 	{}
Local oStruV4C	:=  ""
Local lReinf20  := .F.
Local nTamBox01 := 050
Local nTamBox02 := 050 
Local nTamBox03 := 100
Local cCmpsReinf	:= ""

Local cCodModelo	:=	''

If TAFAlsInDic("T9Q")
	oStruT9Q	:= 	FWFormStruct( 2, 'T9Q' )
EndIf

If TAFAlsInDic( "T60" )
	oStruT60	:= 	FWFormStruct( 2, 'T60' )
EndIf

If TAFAlsInDic( "V4D" )
	oStruV4C	:=  FWFormStruct( 2, 'V4C')
	oStruV4D	:=  FWFormStruct( 2, 'V4D')
	lReinf20 	:= .T.
EndIf

//Tratamento para diferenciar a Inclusao das outras manutencoes
If ( Type( 'INCLUI' ) <> "U" ) .And. INCLUI
	cCodModelo	:=	XFUNPerfil( oModel , cIndOpe )
Else
	cCodModelo	:=	XFUNID2Cd( C20->C20_CODMOD , 'C01' )
EndIf

If ( Type( 'ALTERA' ) <> "U" ) .And. ALTERA
	//Se a nota foi transmitida abrir em modo de visualização
	dbSelectArea("CU0")
	dbSetOrder(6)
	If CU0->(MsSeek(xFilial("CU0")+Substr(AllTrim(C20->C20_SERIE),1,3)+StrZero(Val(C20->C20_NUMDOC),9)+"100"))
		Aviso(STR0086 ,STR0087, {STR0088} )
	End
EndIf

//Filtrando campos a serem exibidos na VIEW
cCmpsFil	:=	'C20_VLDOC|C20_VLDESC|C20_VLMERC|C20_VLSERV|C20_VLRDA|'

If TAFColumnPos("C20_VLABMT")
	cCmpsFil	+= 'C20_VLABMT|'
EndIf

If TAFColumnPos("C20_VLABSU")
	cCmpsFil	+= 'C20_VLABSU|'
EndIf

cCmpsFil    +=  'C20_VLRSEG|C20_VLOUDE|C20_VLRFRT|C20_VLABNT|C20_II|C20_BASEII|C20_VLRADU|C20_VLRIOF|'

If !cCodModelo $ '57,63,67'
	cCmpsFil	+=	'C20_TPCTE|'
EndIf
If !cCodModelo $ '55,56,57,63,65,67'
	cCmpsFil	+=	'C20_CHVELE|C20_CHVREF|'
EndIf
If !cCodModelo $ '06,21,22,28'
	cCmpsFil	+=	'C20_MESTRE|C20_CHVCOD|'
EndIf
If !cCodModelo $ '13,14,15,16,18' .Or. cIndOpe == '0'
	cCmpsFil	+=	'C20_IDRMD|'
EndIf

oStruC20 	:= 	FWFormStruct( 2, 'C20', {|cCampo| !( AllTrim( cCampo )+"|" $ cCmpsFil ) } )//Campos do folder Capa do Documento

cCmpsFil	:=	'C20_VLDOC|C20_VLDESC|C20_VLMERC|C20_VLRDA|'

If TAFColumnPos("C20_VLABMT")
	cCmpsFil	+= 'C20_VLABMT|'
EndIf

If TAFColumnPos("C20_VLABSU")
	cCmpsFil	+= 'C20_VLABSU|'
EndIf

cCmpsFil    +=  'C20_VLRSEG|C20_VLOUDE|C20_VLRFRT|C20_VLABNT|C20_II|C20_BASEII|C20_VLRADU|C20_VLRIOF|'
If !cCodModelo $ '06,21,22,28'
	cCmpsFil	+=	'C20_VLSERV|'
EndIf

cCmpsFil	+=	'C20_VLABSU|'


oStruC20B 	:= 	FWFormStruct( 2, 'C20', {|cCampo| AllTrim( cCampo )+"|" $ cCmpsFil } )	//Campos do folder Totais

oView:SetModel( oModel )

oStruC20:AddGroup ( 'GRP_DOCUMENTO', STR0002 , '' , 1 )	//'Dados do Documento Fiscal'
oStruC20:AddGroup ( 'GRP_REM_DEST' , STR0003 , '' , 1 )	//'Dados do Remetente/Destinatário'
oStruC20:AddGroup ( 'GRP_COMPRA'   , STR0069 , '' , 1 )	//'Compra'
oStruC20:AddGroup ( 'GRP_FRETE'    , STR0004 , '' , 1 )	//'Frete'
oStruC20:AddGroup ( 'GRP_VOLUMES'  , STR0068 , '' , 1 )	//'Volumes'
oStruC20:AddGroup ( 'GRP_PAGAMENTO', STR0005 , '' , 1 )	//'Pagamento Negociado'
oStruC20:AddGroup ( 'GRP_NF_CT_e'  , STR0006 , '' , 1 )	//'Complementos para os Documentos Fiscais Emitidos Eletrônicamente'
oStruC20:AddGroup ( 'GRP_CONV115'  , STR0007 , '' , 1 )	//'Complementos para os Documentos Fiscais Emitidos conforme Convenio 115/2003'


oStruC20:SetProperty( 'C20_CHVNF'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_CODMOD' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_DCODMO' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_INDOPE' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_TPDOC'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_DTPDOC' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_INDEMI' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_CODSIT' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_DCODSI' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_SERIE'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_SUBSER' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_NUMDOC' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_DTDOC'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_DTES'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
//Dicionario da DIEF-CE (12.1.9)
If(AliasInDic("T30"))
	oStruC20:SetProperty( 'C20_DTEXT'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
EndIf
oStruC20:SetProperty( 'C20_NDOCF'  , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )

If TamSX3("C20_CODCTA")[1]  == 36
	oStruC20:SetProperty( 'C20_CTACTB' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
Else
	oStruC20:SetProperty( 'C20_CODCTA' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
EndIf

oStruC20:SetProperty( 'C20_DCODCT' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
oStruC20:SetProperty( 'C20_AIDF'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )

If cCodModelo $ '13,14,15,16,18' .And. cIndOpe == '1'
	oStruC20:SetProperty( 'C20_IDRMD' , MVC_VIEW_GROUP_NUMBER , 'GRP_DOCUMENTO' )
EndIf

If TamSX3("C20_CODPAR")[1] == 36	
	oStruC20:SetProperty( 'C20_CPARTI' , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
	oStruC20:RemoveField( "C20_CODPAR")
	oStruC20:SetProperty( "C20_CPARTI", MVC_VIEW_ORDEM, "10" )
	oStruC20:SetProperty( "C20_DCODPA", MVC_VIEW_ORDEM, "11" )	
Else   
    oStruC20:SetProperty( 'C20_CODPAR' , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
EndIf

oStruC20:SetProperty( 'C20_DCODPA' , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
oStruC20:SetProperty( 'C20_VCNPJ'  , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
oStruC20:SetProperty( 'C20_VCPF'   , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
oStruC20:SetProperty( 'C20_VIE'    , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
oStruC20:SetProperty( 'C20_VLOCAL' , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )

If TAFColumnPos( "C20_UF" )
	oStruC20:SetProperty( 'C20_UF'  , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
	oStruC20:SetProperty( 'C20_DUF' , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
Endif 
oStruC20:SetProperty( 'C20_VFONES' , MVC_VIEW_GROUP_NUMBER , 'GRP_REM_DEST' )
oStruC20:SetProperty( "C20_INDFRT" , MVC_VIEW_GROUP_NUMBER , 'GRP_FRETE' )
oStruC20:SetProperty( "C20_DINDFR" , MVC_VIEW_GROUP_NUMBER , 'GRP_FRETE' )
oStruC20:SetProperty( "C20_NATFRT" , MVC_VIEW_GROUP_NUMBER , 'GRP_FRETE' )
oStruC20:SetProperty( "C20_DNATFR" , MVC_VIEW_GROUP_NUMBER , 'GRP_FRETE' )
	
If cCodModelo $ '07,08,09,10,11,26,27,57,63,67'
	oStruC20:SetProperty("C20_MODAL", MVC_VIEW_GROUP_NUMBER, 'GRP_FRETE')
Else
	oStruC20:RemoveField("C20_MODAL")
EndIf
	
oStruC20:SetProperty( "C20_INDPAG" , MVC_VIEW_GROUP_NUMBER , 'GRP_PAGAMENTO' )

If TamSX3("C20_CODCTA")[1] == 36	
	oStruC20:RemoveField( "C20_CODCTA")
	oStruC20:SetProperty( "C20_CTACTB", MVC_VIEW_ORDEM, "35" )
	oStruC20:SetProperty( "C20_DCODCT", MVC_VIEW_ORDEM, "36" )	
EndIf

If TamSX3("C23_FABRIC")[1] == 36	
	oStruC23:RemoveField( "C23_FABRIC")
	oStruC23:SetProperty( "C23_CFABRI", MVC_VIEW_ORDEM, "23" )
	oStruC23:SetProperty( "C23_DFABRI", MVC_VIEW_ORDEM, "24" )
	oStruC23:SetProperty( "C23_VLDESC", MVC_VIEW_ORDEM, "25" )		
EndIf

If TamSX3("C2B_CODPAR")[1] == 36	
	oStruC2B:RemoveField( "C2B_CODPAR")
	oStruC2B:SetProperty( "C2B_CPARTI", MVC_VIEW_ORDEM, "04" )
	oStruC2B:SetProperty( "C2B_DCODPA", MVC_VIEW_ORDEM, "05" )	
	oStruC2B:SetProperty( "C2B_CODVEI", MVC_VIEW_ORDEM, "06" )			
EndIf

If TamSX3("C28_PARCOL")[1] == 36	
	oStruC28:RemoveField( "C28_PARCOL")
	oStruC28:SetProperty( "C28_CPARCO", MVC_VIEW_ORDEM, "07" )
	oStruC28:SetProperty( "C28_DPARCO", MVC_VIEW_ORDEM, "08" )				
EndIf

If TamSX3("C28_PARENT")[1] == 36	
	oStruC28:RemoveField( "C28_PARENT")
	oStruC28:SetProperty( "C28_CPAREN", MVC_VIEW_ORDEM, "10" )
	oStruC28:SetProperty( "C28_DPAREN", MVC_VIEW_ORDEM, "11" )				
EndIf

If TamSX3("C26_CODPAR")[1] == 36	
	oStruC26:RemoveField( "C26_CODPAR")
	oStruC26:SetProperty( "C26_CPARTI", MVC_VIEW_ORDEM, "09" )
	oStruC26:SetProperty( "C26_DCODPA", MVC_VIEW_ORDEM, "10" )				
	oStruC26:SetProperty( "C26_SERIE",  MVC_VIEW_ORDEM, "11" )
	oStruC26:SetProperty( "C26_SUBSER", MVC_VIEW_ORDEM, "12" )
EndIf

If TamSX3("C24_PAREMI")[1] == 36	
	oStruC24:RemoveField( "C24_PAREMI")
	oStruC24:SetProperty( "C24_CPAREM", MVC_VIEW_ORDEM, "06" )
	oStruC24:SetProperty( "C24_DPAREM", MVC_VIEW_ORDEM, "07" )				
EndIf

If TamSX3("C24_PARTOM")[1] == 36	
	oStruC24:RemoveField( "C24_PARTOM")
	oStruC24:SetProperty( "C24_CPARTO", MVC_VIEW_ORDEM, "09" )
	oStruC24:SetProperty( "C24_DPARTO", MVC_VIEW_ORDEM, "10" )				
	oStruC24:SetProperty( "C24_CODMOD", MVC_VIEW_ORDEM, "11" )
	oStruC24:SetProperty( "C24_DCODMO", MVC_VIEW_ORDEM, "12" )
	oStruC24:SetProperty( "C24_SERIE",  MVC_VIEW_ORDEM, "13" )
	oStruC24:SetProperty( "C24_SUBSER", MVC_VIEW_ORDEM, "14" )	
	oStruC24:SetProperty( "C24_NUMDOC", MVC_VIEW_ORDEM, "15" )
	oStruC24:SetProperty( "C24_DTDOC",  MVC_VIEW_ORDEM, "16" )
	oStruC24:SetProperty( "C24_VALOR",  MVC_VIEW_ORDEM, "17" )
EndIf

If TamSX3("C32_CODPAR")[1] == 36
	oStruC32:RemoveField( "C32_CODPAR")
	oStruC32:SetProperty( "C32_CPARTI", MVC_VIEW_ORDEM, "09" )
EndIf

If TamSX3("C37_CODPAR")[1] == 36
	oStruC37:RemoveField( "C37_CODPAR")
	oStruC37:RemoveField( "C37_CODPRE")
	oStruC37:SetProperty( "C37_CPARTI", MVC_VIEW_ORDEM, "10" )
	oStruC37:SetProperty( "C37_CPARRE", MVC_VIEW_ORDEM, "27" )
EndIf

If TamSX3("C38_CODPAR")[1] == 36
	oStruC38:RemoveField( "C38_CODPAR")
	oStruC38:SetProperty( "C38_CPARTI", MVC_VIEW_ORDEM, "07" )
EndIf

If TamSX3("C3G_CPARCO")[1] == 36
	oStruC3G:RemoveField( "C3G_CPARCO")
	oStruC3G:SetProperty( "C3G_CODPAR", MVC_VIEW_ORDEM, "14" )
EndIf

If TamSX3("C3A_CPARCO")[1] == 36
	oStruC3A:RemoveField( "C3A_CPARCO")
	oStruC3A:RemoveField( "C3A_CPARDE")
	oStruC3A:RemoveField( "C3A_CPAREN")
	oStruC3A:RemoveField( "C3A_CPARRE")
	oStruC3A:SetProperty( "C3A_CDPREM", MVC_VIEW_ORDEM, "04" )
	oStruC3A:SetProperty( "C3A_CDPDES", MVC_VIEW_ORDEM, "07" )
	oStruC3A:SetProperty( "C3A_CDPCOL", MVC_VIEW_ORDEM, "09" )
	oStruC3A:SetProperty( "C3A_CDPENT", MVC_VIEW_ORDEM, "11" )	
EndIf

If TamSX3("C3F_CPARCO")[1] == 36
	oStruC3F:RemoveField( "C3F_CPARCO")	
	oStruC3F:RemoveField( "C3F_CPARRE")
	oStruC3F:SetProperty( "C3F_PARCOS", MVC_VIEW_ORDEM, "13" )		
	oStruC3F:SetProperty( "C3F_PARRED", MVC_VIEW_ORDEM, "16" )
EndIf

If TamSX3("T60_CODPAR")[1] == 36
	oStruT60:RemoveField( "T60_CODPAR")
	oStruT60:SetProperty( "T60_CPARTI", MVC_VIEW_ORDEM, "06" )
EndIf

If TamSX3("C21_CODINF")[1] == 36
	oStruC21:RemoveField( "C21_CODINF")
	oStruC21:SetProperty( "C21_CDINFO", MVC_VIEW_ORDEM, "04" )
EndIf

If TamSX3("C30_NATOPE")[1] == 36
	oStruC30:RemoveField( "C30_NATOPE")
	oStruC30:SetProperty( "C30_CODNAT", MVC_VIEW_ORDEM, "22" )
EndIf

If TamSX3("C30_CODITE")[1] == 36
	oStruC30:RemoveField( "C30_CODITE")
	oStruC30:SetProperty( "C30_ITEM", MVC_VIEW_ORDEM, "04" )
EndIf

If TamSX3("C2D_CODITE")[1] == 36
	oStruC2D:RemoveField( "C2D_CODITE")
	oStruC2D:SetProperty( "C2D_CODAJ",  MVC_VIEW_ORDEM, "04" )
	oStruC2D:SetProperty( "C2D_DCODAJ", MVC_VIEW_ORDEM, "05" )
	oStruC2D:SetProperty( "C2D_DESCRI", MVC_VIEW_ORDEM, "06" )
	oStruC2D:SetProperty( "C2D_ITEM",   MVC_VIEW_ORDEM, "07" )
	oStruC2D:SetProperty( "C2D_DCODIT", MVC_VIEW_ORDEM, "08" )
	oStruC2D:SetProperty( "C2D_BSICM",  MVC_VIEW_ORDEM, "09" )
	oStruC2D:SetProperty( "C2D_ALQICM", MVC_VIEW_ORDEM, "10" )
	oStruC2D:SetProperty( "C2D_VLICM",  MVC_VIEW_ORDEM, "11" )
	oStruC2D:SetProperty( "C2D_VLOUTR", MVC_VIEW_ORDEM, "12" )
	oStruC2D:SetProperty( "C2D_SUBITE", MVC_VIEW_ORDEM, "13" )
	oStruC2D:SetProperty( "C2D_DESCSU", MVC_VIEW_ORDEM, "14" )
	oStruC2D:SetProperty( "C2D_DTVIST", MVC_VIEW_ORDEM, "15" )
	oStruC2D:SetProperty( "C2D_CODMOT", MVC_VIEW_ORDEM, "16" )
	oStruC2D:SetProperty( "C2D_DESMOT", MVC_VIEW_ORDEM, "17" )
EndIf


If cCodModelo $ '55,56,65'
   	oStruC20:SetProperty( "C20_HSAIEN"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_DOCUMENTO'	)
   	oStruC20:SetProperty( "C20_QTDVOL"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_VOLUMES' 	)
   	oStruC20:SetProperty( "C20_ESPVOL"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_VOLUMES' 	)
   	oStruC20:SetProperty( "C20_MARCA" 	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_VOLUMES' 	)
   	oStruC20:SetProperty( "C20_NUMVOL"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_VOLUMES' 	)
   	oStruC20:SetProperty( "C20_PESLIQ"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_VOLUMES' 	)
   	oStruC20:SetProperty( "C20_PESBRT"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_VOLUMES' 	)
   	oStruC20:SetProperty( "C20_LACRES"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_VOLUMES' 	)
   	oStruC20:SetProperty( "C20_NOTEMP"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_COMPRA' 	)
   	oStruC20:SetProperty( "C20_PEDIDO"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_COMPRA' 	)
	oStruC20:SetProperty( "C20_CONTRA"	, MVC_VIEW_GROUP_NUMBER	    , 'GRP_COMPRA' 	)
	oStruC20:SetProperty( "C20_INFCLI"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_NF_CT_e' 	)
	oStruC20:SetProperty( "C20_INFFIS"	, MVC_VIEW_GROUP_NUMBER 	, 'GRP_NF_CT_e' 	)
Else
   	oStruC20:RemoveField("C20_HSAIEN")
   	oStruC20:RemoveField("C20_QTDVOL")
   	oStruC20:RemoveField("C20_ESPVOL")
   	oStruC20:RemoveField("C20_MARCA" )
   	oStruC20:RemoveField("C20_NUMVOL")
   	oStruC20:RemoveField("C20_PESLIQ")
   	oStruC20:RemoveField("C20_PESBRT")
   	oStruC20:RemoveField("C20_LACRES")
   	oStruC20:RemoveField("C20_NOTEMP")
   	oStruC20:RemoveField("C20_PEDIDO")
	oStruC20:RemoveField("C20_CONTRA")
	oStruC20:RemoveField("C20_INFCLI")
	oStruC20:RemoveField("C20_INFFIS")

	oStruC30:RemoveField("C30_DESNFE")
	oStruC30:RemoveField("C30_CSOSN")
EndIf

If TamSX3("C30_CTACTB")[1] == 36
	oStruC30:RemoveField("C30_CTACTB")
	oStruC30:SetProperty( "C30_CODCTA", MVC_VIEW_ORDEM, "36" )	
	oStruC30:SetProperty( "C30_DCTACT", MVC_VIEW_ORDEM, "37" )			
EndIf

If TAFColumnPos("C30_CNATRE")
	oStruC30:RemoveField("C30_CNATRE")
EndIf				 

If TAFAlsInDic("T9Q")	
	oStruT9Q:RemoveField( "T9Q_IDSUSP")
EndIf	

oStruC2D:RemoveField("C2D_IDSUBI")
oStruC2D:RemoveField("C2D_ID")
oStruC2D:RemoveField("C2D_IDTMOT")
oStruT00:RemoveField("T00_IDSUBI")
oStruT00:RemoveField("T00_ID")
oStruC35:RemoveField("C35_IDMINC")
oStruC23:RemoveField("C23_IDMOED")

If cCodModelo == '57,63,67'
	oStruC20:SetProperty( "C20_TPCTE"  , MVC_VIEW_GROUP_NUMBER , 'GRP_NF_CT_e' )
EndIf

If cCodModelo $ '55,56,57,65'
	oStruC20:SetProperty( "C20_CHVELE" , MVC_VIEW_GROUP_NUMBER , 'GRP_NF_CT_e' )
	oStruC20:SetProperty( "C20_CHVREF" , MVC_VIEW_GROUP_NUMBER , 'GRP_NF_CT_e' )
Else
	oStruC20:RemoveField("C20_CHVELE")
	oStruC20:RemoveField("C20_CHVREF")
EndIf

If cCodModelo $ '06,21,22,28'
	oStruC20:SetProperty( "C20_MESTRE" , MVC_VIEW_GROUP_NUMBER , 'GRP_CONV115' )
	oStruC20:SetProperty( "C20_CHVCOD" , MVC_VIEW_GROUP_NUMBER , 'GRP_CONV115' )
EndIf

oStruC20B:AddGroup( 'GRP_TOTAIS_ITENS_SERVICOS', STR0008, '', 1 )	//'Valores Totais dos Itens / Serviços'
oStruC20B:SetProperty( "C20_VLMERC" , MVC_VIEW_GROUP_NUMBER 	, 'GRP_TOTAIS_ITENS_SERVICOS' )
If !cCodModelo $ '06,21,22,28'
	oStruC20B:SetProperty( "C20_VLSERV" , MVC_VIEW_GROUP_NUMBER , 'GRP_TOTAIS_ITENS_SERVICOS' )	//Para estes modelos, usara a C2E, C2G
EndIf

oStruC20B:AddGroup( 'GRP_DESCONTOS', STR0009, '', 1 )	//'Valores Totais de Desconto'
oStruC20B:SetProperty( "C20_VLDESC" , MVC_VIEW_GROUP_NUMBER , 'GRP_DESCONTOS' )
oStruC20B:SetProperty( "C20_VLABNT" , MVC_VIEW_GROUP_NUMBER , 'GRP_DESCONTOS' )

oStruC20B:AddGroup( 'GRP_ACRESCIMOS', STR0010, '', 1 )	//'Valores Totais de Acréscimo'
oStruC20B:SetProperty( "C20_VLRFRT" , MVC_VIEW_GROUP_NUMBER , 'GRP_ACRESCIMOS' )
oStruC20B:SetProperty( "C20_VLRSEG" , MVC_VIEW_GROUP_NUMBER , 'GRP_ACRESCIMOS' )
oStruC20B:SetProperty( "C20_VLRDA"  , MVC_VIEW_GROUP_NUMBER , 'GRP_ACRESCIMOS' )
oStruC20B:SetProperty( "C20_VLOUDE" , MVC_VIEW_GROUP_NUMBER , 'GRP_ACRESCIMOS' )


If cCodModelo $ '55,56,65'
	oStruC20B:AddGroup( 'GRP_IMPORTACAO', STR0070, '', 1 )	//'Valores Totais de Importacão'
	oStruC20B:SetProperty( "C20_BASEII" , MVC_VIEW_GROUP_NUMBER , 'GRP_IMPORTACAO' )
	oStruC20B:SetProperty( "C20_II" 	 , MVC_VIEW_GROUP_NUMBER , 'GRP_IMPORTACAO' )
	oStruC20B:SetProperty( "C20_VLRADU" , MVC_VIEW_GROUP_NUMBER , 'GRP_IMPORTACAO' )
	oStruC20B:SetProperty( "C20_VLRIOF" , MVC_VIEW_GROUP_NUMBER , 'GRP_IMPORTACAO' )
Else
	oStruC20B:RemoveField("C20_II")
	oStruC20B:RemoveField("C20_BASEII")
	oStruC20B:RemoveField("C20_VLRADU")
	oStruC20B:RemoveField("C20_VLRIOF")
EndIf

If TAFColumnPos("C20_IDOBR")
	oStruC20:RemoveField("C20_IDOBR")
EndIf

oStruC20B:AddGroup( 'GRP_TOTAIS', STR0011, '', 1 )	//'Valor Total do Documento'
oStruC20B:SetProperty( "C20_VLDOC"  , MVC_VIEW_GROUP_NUMBER , 'GRP_TOTAIS' )

oStruC20B:AddGroup( 'GRP_ABATIMENTO', STR0091, '', 1 )	//'Abatimento'

If TAFColumnPos("C20_VLABMT")
	oStruC20B:SetProperty( "C20_VLABMT"  , MVC_VIEW_GROUP_NUMBER , 'GRP_ABATIMENTO' )
EndIf

If TAFColumnPos("C20_VLABSU")
	oStruC20B:SetProperty( "C20_VLABSU"  , MVC_VIEW_GROUP_NUMBER , 'GRP_ABATIMENTO' )
EndIf

oStruC29:AddGroup ( 'GRP_FATURA', STR0012, '', 1 )	//'Dados da Fatura do Documento Fiscal'
oStruC29:SetProperty ( "C29_INDEMI" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )
oStruC29:SetProperty ( "C29_INDTIT" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )
oStruC29:SetProperty ( "C29_DESCRI" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )
oStruC29:SetProperty ( "C29_NUMTIT" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )
oStruC29:SetProperty ( "C29_QTDPAR" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )
oStruC29:SetProperty ( "C29_VLRTOT" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )
oStruC29:SetProperty ( "C29_VLRDES" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )
oStruC29:SetProperty ( "C29_VLRLIQ" , MVC_VIEW_GROUP_NUMBER , 'GRP_FATURA' )

oStruC2E:SetProperty( 'C2E_CODCON' , MVC_VIEW_LOOKUP  , { || XFUNChgF3( "C20_CODMOD" , "MODEL_C20" , "EAG" ) } )

oStruC2F:SetProperty( 'C2F_CST'    , MVC_VIEW_LOOKUP  , { || XFUNChgF3() } )
oStruC35:SetProperty( 'C35_CST'    , MVC_VIEW_LOOKUP  , { || XFUNChgF3() } )
oStruC35:SetProperty( 'C35_MODBC'  , MVC_VIEW_LOOKUP  , { || XFUNChgF3( ,,"MBC" ) } )

//Capa do Documento Fiscal
If cCodModelo $ '01,02,04,06,07,08,09,10,11,13,14,15,16,18,1B,21,22,26,27,28,29,37,2D,2E,55,56,57,58,59,60,8B,65,17,20,23,24,25,98,99,63,67,**,'
	oView:AddField( 'VIEW_C20' , oStruC20 , 'MODEL_C20' )
	oView:AddField( 'VIEW_C20B', oStruC20B, 'MODEL_C20' )

	oView:AddGrid ( 'VIEW_C2F', oStruC2F, 'MODEL_C2F' )
	oView:EnableTitleView( 'VIEW_C2F', STR0017 )	//'Valores por Tributo do Documento'

	oView:AddGrid ( 'VIEW_C6W', oStruC6W, 'MODEL_C6W' )

	If !cCodModelo $ '13,14,15,16,18'
		oView:AddGrid( 'VIEW_C30', oStruC30, 'MODEL_C30' )	//Itens do Documentos Fiscais
		if !lTsi //Para integracoes via tsi, nao deve entrar nessa regra de incremento
			oView:AddIncrementField( 'VIEW_C30', 'C30_NUMITE' )
		endif

		oView:AddGrid( 'VIEW_C35', oStruC35, 'MODEL_C35' )	//Tributos

		If lReinf20
			oStruV4D:RemoveField("V4D_IDTPIS")
			oView:AddGrid( 'VIEW_V4C', oStruV4C, 'MODEL_V4C' ) //Deduções
			oView:AddGrid( 'VIEW_V4D', oStruV4D, 'MODEL_V4D' ) //Isenções
		EndIf	

		If TAFAlsInDic("T9Q")	
			oView:AddGrid( 'VIEW_T9Q', oStruT9Q, 'MODEL_T9Q' )	//Reinf Processos
		EndIf
	EndIf

EndIf

If TAFAlsInDic( "T60" )
	If cCodModelo $ '01,02,04,06,13,14,15,16,18,1B,21,22,28,29,37,2D,2E,55,59,60,65,8B,17,20,23,24,25,98,99,**,'
		oView:AddGrid ( 'VIEW_T60', oStruT60, 'MODEL_T60' )
		oView:EnableTitleView( 'VIEW_T60', STR0093 )	
	EndIf
EndIf

If cCodModelo $ '01,1B,04,06,07,08,8B,09,10,11,21,22,26,27,28,29,55,57,65,17,20,23,24,25,98,99,63,67,**'
	oView:AddGrid ( 'VIEW_C21' , oStruC21 , 'MODEL_C21' )
	oView:EnableTitleView( 'VIEW_C21', STR0013 )	//'Informações Complementares do Documento Fiscal'
EndIf

If cCodModelo $ '01,1B,04,55,65,17,20,23,24,25,98,99,**,'

	oView:AddGrid ( 'VIEW_C22', oStruC22, 'MODEL_C22' )	//Processos Referenciados

	oView:AddGrid ( 'VIEW_C25', oStruC25, 'MODEL_C25' )	//Documentos de Arrecadacao Referenciados

	oView:AddGrid ( 'VIEW_C26', oStruC26, 'MODEL_C26' )	//Documentos Fiscais Referenciados

	oView:AddGrid ( 'VIEW_C27', oStruC27, 'MODEL_C27' )	//Cupons Fiscais Referenciados e CF-e

EndIf

If cCodModelo $ '01,1B,04,17,20,23,24,25,98,99,**,'
	oView:AddGrid ( 'VIEW_C28', oStruC28, 'MODEL_C28' )	//Local de Coleta / Entrega
EndIf

If cCodModelo $ '01,55,56,65,17,20,23,24,25,98,99,**,'

	If !cCodModelo $ "55,56,65"
		oView:AddGrid ( 'VIEW_C23', oStruC23, 'MODEL_C23' )

		oView:AddGrid ( 'VIEW_C2B', oStruC2B, 'MODEL_C2B' )
	EndIf

	oView:AddField( 'VIEW_C29', oStruC29, 'MODEL_C29' )

	oView:AddGrid ( 'VIEW_C2A', oStruC2A, 'MODEL_C2A' )
	oView:EnableTitleView( 'VIEW_C2A', STR0014 )	//'Vencimentos da Fatura'
	
	if !cCodModelo $ "56"
		oView:AddGrid( 'VIEW_C33', oStruC33, 'MODEL_C33' )
	endif
	If cCodModelo $ "55,65"
		oView:AddGrid( 'VIEW_CAI', oStruCAI, 'MODEL_CAI' )
		oView:AddGrid( 'VIEW_CH1', oStruCH1, 'MODEL_CH1' )
		oView:EnableTitleView( 'VIEW_CH1', STR0071 )  //"Fornecimento Diário de Cana"
		oView:AddGrid( 'VIEW_CH2', oStruCH2, 'MODEL_CH2' )
		oView:EnableTitleView( 'VIEW_CH2', STR0072 )  //"Deduções - Taxas e Contribuições"
	EndIf

EndIf

//Proteção caso não tenha sido aplicado o dicionario 007859 TSI
If lAtu == .T.
	If cCodModelo $ '01,1B,04,07,08,8B,09,10,11,26,27,55,57,65,17,20,23,24,25,98,99,63,67,**'

		oView:AddGrid ( 'VIEW_C2D', oStruC2D, 'MODEL_C2D' )
		oView:EnableTitleView( 'VIEW_C2D', STR0016 )	//'Ajustes de Documentos Fiscais'

		oView:AddGrid ( 'VIEW_T00', oStruT00, 'MODEL_T00' )
		oView:EnableTitleView( 'VIEW_T00', STR0090 )	//'Autorização de Crédito de ICMS'

	EndIf
Else
	If cCodModelo $ '01,02,1B,04,06,07,08,8B,09,10,11,13,14,15,16,21,22,26,27,28,29,55,57,65,17,20,23,24,25,98,99,63,67,**'
		oView:AddGrid ( 'VIEW_C2C', oStruC2C, 'MODEL_C2C' )
		oView:EnableTitleView( 'VIEW_C2C', STR0015 )	//'Observações dos Lançamentos Fiscais'
		If !cCodModelo $ '02,06,13,14,15,16,21,22,28,60,29'
			oView:AddGrid ( 'VIEW_C2D', oStruC2D, 'MODEL_C2D' )
			oView:EnableTitleView( 'VIEW_C2D', STR0016 )	//'Ajustes de Documentos Fiscais'

			oView:AddGrid ( 'VIEW_T00', oStruT00, 'MODEL_T00' )
			oView:EnableTitleView( 'VIEW_T00', STR0090 )	//'Autorização de Crédito de ICMS'
		EndIf
	EndIf
EndIF

If cCodModelo $ '55,65,**,'
	oView:AddGrid ( 'VIEW_C2H', oStruC2H, 'MODEL_C2H' )
	oView:AddGrid ( 'VIEW_C23', oStruC23, 'MODEL_C23' )
EndIf

// Demetrio - 27/08/2014
If cCodModelo $ '29,**,'
	oView:AddField( 'VIEW_C29', oStruC29, 'MODEL_C29' )
	oView:AddGrid ( 'VIEW_C2A', oStruC2A, 'MODEL_C2A' )
	oView:EnableTitleView( 'VIEW_C2A', STR0014 )	//'Vencimentos da Fatura'
EndIf
If cCodModelo $ '06,28,29,**,'
	oView:AddGrid ( 'VIEW_C2E', oStruC2E, 'MODEL_C2E' )
	oView:AddGrid( 'VIEW_C32', oStruC32, 'MODEL_C32' )
EndIf

If cCodModelo $ '21,22,**,'
	oView:AddGrid ( 'VIEW_C2G', oStruC2G, 'MODEL_C2G' )
	oView:AddGrid( 'VIEW_C38', oStruC38, 'MODEL_C38' )
EndIf

If cCodModelo $ '02,13,14,15,16,**,'
	oView:AddGrid ( 'VIEW_C2I', oStruC2I, 'MODEL_C2I' )
EndIf

If cCodModelo $ '07,57,67,**,'
	oView:AddGrid( 'VIEW_C39', oStruC39, 'MODEL_C39' )
EndIf

If cCodModelo $ '08,8B,09,10,11,26,27,55,65,**,'
	oView:AddGrid( 'VIEW_C3A', oStruC3A, 'MODEL_C3A' )
	oView:EnableTitleView( 'VIEW_C3A', STR0018 )	//'20.Carga Transportada e/ou Local da Coleta/Entrega'

	oView:AddGrid( 'VIEW_C3I', oStruC3I, 'MODEL_C3I' )
	oView:EnableTitleView( 'VIEW_C3I', STR0019 )	//'24.Identificação dos Documentos Fiscais'
EndIf

If cCodModelo $ '08,8B,26,**,'
	oView:AddGrid( 'VIEW_C3F', oStruC3F, 'MODEL_C3F' )
EndIf

If cCodModelo $ '09,**,'
	oView:AddGrid( 'VIEW_C3G', oStruC3G, 'MODEL_C3G' )
EndIf

If cCodModelo $ '10,**,'
	oView:AddGrid( 'VIEW_C3H', oStruC3H, 'MODEL_C3H' )
EndIf

If cCodModelo $ '26,**,'
	oView:AddGrid ( 'VIEW_C24', oStruC24, 'MODEL_C24' )
	oView:AddIncrementField( 'VIEW_C24', 'C24_NUMSEQ' )
EndIf

If cCodModelo $ '01,55,65,17,20,23,24,25,98,99,**,'
	oView:AddGrid( 'VIEW_C31', oStruC31, 'MODEL_C31' )
	oView:AddGrid( 'VIEW_C34', oStruC34, 'MODEL_C34' )
	oView:AddGrid( 'VIEW_C36', oStruC36, 'MODEL_C36' )
	oView:AddGrid( 'VIEW_C37', oStruC37, 'MODEL_C37' )
EndIf

If cCodModelo $ '13,14,15,16,**'
	oView:AddGrid ( 'VIEW_C7B' , oStruC7B , 'MODEL_C7B' )
	oView:EnableTitleView( 'VIEW_C7B', STR0067 )
EndIf

//--------------------------------------------------------------------------------------------------------------------------

//Painel geral
oView:CreateHorizontalBox( 'PAINEL_GERAL', 100 )
oView:CreateFolder( 'PAINEL_GERAL_FOLDERS', 'PAINEL_GERAL' )

If cCodModelo $ '01,02,04,06,07,08,09,10,11,13,14,15,16,18,1B,21,22,26,27,28,29,37,2D,2E,55,56,57,58,59,60,65,8B,17,20,23,24,25,98,99,63,67,**,'
	//(1) - Folder "Documento"
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS', 'ABA01',Iif("ENTRADA" $ Upper( FunDesc() ), STR0020 + " de Entrada",STR0020 + " de Saída") )	//'01.Documento'
	oView:CreateVerticalBox  ( 'PAINEL_GERAL_FOLDERS_ABA01', 100,,, 'PAINEL_GERAL_FOLDERS', 'ABA01' )
	oView:CreateFolder( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS', 'PAINEL_GERAL_FOLDERS_ABA01' )

	//(1), Folder 1 "Informações da Capa do Documento"
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS', 'ABA01', STR0021 )	//'02.Informações da Capa do Documento'
	//Capa do Documento (C20)
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA01', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS', 'ABA01' )

	//(1), Folder 2 "Informações Específicas e Complementares ao Documento"
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS', 'ABA02', STR0022 )	//'03.Informações Específicas e Complementares ao Documento'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS', 'ABA02' )
	oView:CreateFolder( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02' )
EndIf

If TAFAlsInDic( "T60" )
	If cCodModelo $ '01,02,04,06,13,14,15,16,18,1B,21,22,28,29,37,2D,2E,55,65,8B,17,20,23,24,25,59,60,98,99,**,'
		//(1) - Folder "Conhecimentos de Transporte"
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS', 'ABA03', STR0092 )	//'04.Conhecimentos de Transporte'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA03', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS', 'ABA03' )
	EndIf
EndIf

If cCodModelo $ '06,07,08,8B,09,10,11,21,22,26,27,28,29,57,63,67'
	//(1), Folder 2-1 - Informacoes Compelementares/Adicionais (C20 e C21)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA01', STR0023 )	//'04.Infs Complementares'
	//Parte reservada para o real cadastro de informacoes Complementares/Adicionais do documento (C21)
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_B', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA01' )
EndIf

If cCodModelo $ '01,1B,04,55,65,17,20,23,24,25,98,99,**,'
	//(1), Folder 2-1 - Informacoes Compelementares/Adicionais (C20 e C21)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA01', STR0023 )	//'04.Infs Complementares'
	//Parte reservada para informacoes como Convenio 115/2003, Compl. Docs Eletronicos (CHV_NFE, etc...) (C20)
	//oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_A', 040,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA01' )
	//Parte reservada para o real cadastro de informacoes Complementares/Adicionais do documento (C21)
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_B', 040,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA01' )
	//Folders relacionados as Informacoes Complementares/Adicionais
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C', 060,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA01' )
	oView:CreateFolder( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C' )

	//(1), Folder 2-1-1 - Informacoes Compelementares/Adicionais (C22, C25, C26, C27 e C2B)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA01', STR0024 )	//'05.Processos Referenciados'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA01', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA01' )

	//(1), Folder 2-1-3 - Documentos de Arrecadacao (C25)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA02', STR0025 )	//'06.Documentos de Arrecadação Referenciados'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA02', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA02' )

	//(1), Folder 2-1-4 - Documentos Referenciados (C26 e C27)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA03', STR0026 )	//'07.Documentos Fiscais Referenciados'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA03' )
	oView:CreateFolder( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS', 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03' )

	//(1), Folder 2-1-4-1 - Documentos Referenciados - Documento Fiscal (C26)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS', 'ABA01', STR0027 )	//'08.Documentos Fiscais'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS_ABA01', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS', 'ABA01' )

	//(1), Folder 2-1-4-2 - Documentos Referenciados - Cupom Fiscal (C27)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS', 'ABA02', STR0028 )	//'09.Cupons Fiscais / CFs-e'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS_ABA02', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS', 'ABA02' )
EndIf

If cCodModelo $ '01,1B,04,17,20,23,24,25,98,99,**,'
	//(1), Folder 2-1-5 - Local	da Coleta/Entrega (C28)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA05', STR0029 )	//'10.Local da Coleta / Entregua (Mods 01, 1B, 04 e 55)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA05', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS', 'ABA05' )
EndIf

If cCodModelo $ '01,17,20,23,24,25,98,99,**,'
	//(1), Folder 2-2 - Documentos de Importacao (C23)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA02', STR0030 )	//'11.Operações de Importação (Mod. 01)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA02', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA02' )

	//(1), Folder 2-3 - Informações de Combustíveis (C2B)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA03', STR0031 )	//'12.Operações com Combustível (Mod. 01)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA03', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA03' )
EndIf

//Proteção caso não tenha sido aplicado o dicionario 007859 TSI
If lAtu == .T.
	If cCodModelo $ '01,04,1B,07,08,8B,09,10,11,26,27,55,57,65,17,20,23,24,25,98,99,63,67,**,'
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07', STR0032 )	//'13.Obs Lanç. Fiscal'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_B', 050,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07' )
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_C', 050,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07' )
	EndIf
Else
	If cCodModelo $ '01,02,04,1B,06,07,08,8B,09,10,11,13,14,15,16,21,22,26,27,28,29,55,57,65,17,20,23,24,25,98,99,63,67,**,'
		//(1), Folder 2-7 - Observações do Lançamento Fiscal (C2C e C2D)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07', STR0032 )	//'13.Obs Lanç. Fiscal'
		If !cCodModelo $ '02,06,13,14,15,16,21,22,28,60,29'
			oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_A', 050,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07' )
			oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_B', 025,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07' )
			oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_C', 025,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07' )
		Else
			oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_A', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA07' )
		EndIf
	EndIf
EndIf

If cCodModelo $ '55,65,**,'
	//(1), Folder 2-8 - ICMS recolhido em outras UFs (C2H)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA08', STR0033 )	//'14.ICMS/ST Recolhido em outras UFs (Mod. 55)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA08', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA08' )

	//(1), Folder 2-2 - Documentos de Importacao (C23)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA02', STR0030 )	//'11.Operações de Importação (Mod. 55)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA02', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA02' )

EndIf

If cCodModelo $ '01,02,04,06,07,08,09,10,11,13,14,15,16,18,1B,21,22,26,27,28,29,37,2D,2E,55,56,57,58,59,60,8B,65,17,20,23,24,25,98,99,63,67,**,'
	//(1), Folder 2-9 - Processos Referenciados (C6W)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA09', STR0063 )	//'15.Processos Referenciados'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA09', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA09' )
EndIf

If cCodModelo $ '06,28,29,**,'
	//(1), Folder 2-10 - Modelos 06, 28 e 29 (C2E)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA10', STR0035 )	//'16.E.Elétrica, Gás e Água (Mods 06, 28 e 29)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA10', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA10' )
EndIf

If cCodModelo $ '21,22,**,'
	//(1), Folder 2-11 - Modelos 21 e 22 (C2G)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA11', STR0036 )	//'17.Comunicação/Telecomunicação (Mods 21 e 22)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA11', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA11' )
EndIf

If cCodModelo $ '02,13,14,15,16,**,'
	//(1), Folder 2-12 - Modelos 02, 13, 14, 15 e 16 (C2I)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA12', STR0037 )	//'18.Cancelamentos (Mods 02, 13, 14, 15 e 16)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA12', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA12' )
EndIf

If cCodModelo $ '08,8B,26,**,'
	//(1), Folder 2-13 - Complemento Específico - Conh. Rod. de Cargas(08 e 8B) e Conh. Multimodal de Cargas(26) (C3F)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA13', STR0040 )	//'19.Conh. Rod. de Cargas (Mods 08 e 8B) e Conh. Multimodal de Cargas (Mod. 26)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA13' , 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA13' )
EndIf

If cCodModelo $ '08,8B,09,10,11,26,27,55,65,**,'
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA14', STR0041 )	//'20.Carga Transportada, Coleta / Entrega e Docs Fiscais'
	//(1), Folder 2-14 - Carga Transportada (CÓDIGO 08, 8B, 09, 10, 11, 26 e 27), Local de Coleta/Entrega (CÓDIGO 08, 8B, 09, 10, 11 e 26)(C3A)
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA14_A', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS' , 'ABA14' )
	//(1), Folder 2-14 - Identificacao dos Documentos Fiscais (C3I)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA22', STR0089 )	//'21.Aquisição de Cana (Mod. 55)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA22', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS' , 'ABA22' )
EndIf

 If cCodModelo $ '55,65,**,'
	//(1), Folder 2-21 - Aquisicao de Cana (CAI)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA21', STR0070 )	//'21.Aquisição de Cana (Mod. 55)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA21_A', 50,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA21' )
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA21_B', 25,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA21' )
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA21_C', 25,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA21' )
EndIf

If cCodModelo $ '09,**,'
	//(1), Folder 2-16 - Modelo 09 (C3G)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA16', STR0042 )	//'21.Modelo 09'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA16', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA16' )
EndIf

If cCodModelo $ '10,**,'
	//(1), Folder 2-17 - Modelo 10 (C3H)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA17', STR0043 )	//'22.Modelo 10'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA17', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA17' )
EndIf

If cCodModelo $ '26,**,'
	//(1), Folder 2-18 - Modelo 26 (C24)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA18', STR0044 )	//'23.Modais do Transporte(Mod. 26)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA18', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA18' )
EndIf

If cCodModelo $ '13,14,15,16,**,'
	//(1), Folder 2-16 - Complemento Dos Documentos Informados (C7B)
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA19', STR0067 )	//'16.Complemento Dos Documentos Informados'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA19', 100,,, 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS', 'ABA19' )
EndIf

//-------------------------------------------------------------------------------------------------------------------

//Os modelos 13,14,15,16,18 nao necessitam do item
If !cCodModelo $ '13,14,15,16,18'
	If cCodModelo $ '01,02,04,06,07,08,09,10,11,1B,21,22,26,27,28,29,37,2D,2E,55,56,57,58,59,60,8B,65,17,20,23,24,25,98,99,63,67,**,'
		If lReinf20
			nTamBox01 := 040
			nTamBox02 := 060 
			nTamBox03 := 045
		EndIf

		//(2), Folder "Produtos / Servicos"
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS', 'ABA02', STR0045 )	//'50.Produtos / Serviços'
		//(2) Grid do C30 (Itens do documento)
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_A', nTamBox01,,, 'PAINEL_GERAL_FOLDERS', 'ABA02' )

		//(2) Folder dos Complementos dos Itens do Documento Fiscal
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B', nTamBox02,,, 'PAINEL_GERAL_FOLDERS', 'ABA02' )
		oView:CreateFolder( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'PAINEL_GERAL_FOLDERS_ABA02_B' )

		//(2), Folder 1 - Tributos (C30)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA01', STR0046 )	//'51.Tributos do Item'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA01', nTamBox03,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA01' )
		
		If lReinf20		
			//(2), Folder filhos da C30 - Deduções(V4C) e Isenções(V4E)
			oView:CreateHorizontalBox( 'PAINEL_FILHO_C35', 055,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA01' )
			oView:CreateFolder( 'FOLDER_FILHA_C35', 'PAINEL_FILHO_C35')
			oView:AddSheet( 'FOLDER_FILHA_C35', 'ABA01', "Dedução")	
			oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA26', 100,,, 'FOLDER_FILHA_C35', 'ABA01' )

			oView:AddSheet( 'FOLDER_FILHA_C35', 'ABA02', "Isenção")	
			oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA27', 100,,, 'FOLDER_FILHA_C35', 'ABA02' )
		EndIf
	EndIf

	If cCodModelo $ '01,55,65,17,20,23,24,25,98,99,**,'
		//(2), Folder 2 - Medicamentos (C31)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA02', STR0047 )	//'52.Operação com Medicamento (Mods 01 e 55)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA02', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA02' )
	EndIf

	If cCodModelo $ '01,55,65,17,20,23,24,25,98,99,**,'
		//(2), Folder 3 - Armas de Fogo (C33)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA03', STR0048 )	//'53.Operação com Arma de Fogo (Mod. 01 e 55)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA03', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA03' )
	EndIf

	If cCodModelo $ '01,55,65,17,20,23,24,25,98,99,**,'
		//(2), Folder 4 - Veiculos Novos (C34)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA04', STR0049 )	//'54.Operação com Veículo Novo (Mods 01 e 55)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA04', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA04' )

		//(2), Folder 5 - Combustivel (C36)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA05', STR0050 )	//'55.Armazenamento de Combustível (Mods 01 e 55)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA05', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA05' )

		//(2), Folder 6 - Ressarcimento ICMS (C37)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA06', STR0051 )	//'56.Ressarcimento de ICMS em Op. de ST (Mods 01 e 55)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA06', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA06' )
	EndIf

	If cCodModelo $ '06,28,29,**,'
		//(2), Folder 7 - Compl. Modelos 06, 28 e 29 (C32)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA07', STR0053 )	//'57.E.Elétrica, Água e Gás (Mods 06, 28 e 29)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA07', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA07' )
	EndIf

	If cCodModelo $ '21,22,**,'
		//(2), Folder 8 - Compl. Modelos 21 e 22 (C38)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA08', STR0054 )	//'58.Comunicação/Telecomunicação (Mods 21 e 22)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA08', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA08' )
	EndIf

	If cCodModelo $ '07,57,67,**,'
		//(2), Folder 9 - Compl. Modelo 07 (C39)
		oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA09', STR0055 )	//'59.Serviço de Transporte (Mod. 07)'
		oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA09', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA09' )
	EndIf
	
	If cCodModelo $ '01,02,04,06,07,08,09,10,11,1B,21,22,26,27,28,29,37,2D,2E,55,56,57,58,59,60,8B,65,17,20,23,24,25,98,99,63,67,**,'
		If TAFAlsInDic("T9Q")
			//(2), Folder 1 - REINF - Indicativo de Suspensão Processos Administrativos e Judiciais   (T9Q)
			oView:AddSheet( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA25', STR0094) //'60.Indicativo de Suspensão Processos Administrativos e Judiciais'	
			oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA25', 100,,, 'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS', 'ABA25' )
		EndIf
	EndIf
EndIf

//-------------------------------------------------------------------------------------------------------------------

//(3) - Folder "Frete"
//oView:AddSheet( 'PAINEL_GERAL_FOLDERS', 'ABA03', 'Frete')
//oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA03', 100,,, 'PAINEL_GERAL_FOLDERS', 'ABA03' )		//Frete (C20)

//-------------------------------------------------------------------------------------------------------------------

If cCodModelo $ '01,29,55,56,65,17,20,23,24,25,98,99,**,'
	//(4) - Folder "Cobrança"
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS', 'ABA04', STR0056 )	//'80.Fatura (Mod. 01)'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA04_A', 40,,, 'PAINEL_GERAL_FOLDERS', 'ABA04' )	//Fatura (C29)
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA04_B', 60,,, 'PAINEL_GERAL_FOLDERS', 'ABA04' )	//Vencimentos (C2A)

EndIf

//-------------------------------------------------------------------------------------------------------------------

If cCodModelo $ '01,02,04,06,07,08,09,10,11,13,14,15,16,18,1B,21,22,26,27,28,29,37,2D,2E,55,56,57,58,59,60,8B,65,17,20,23,24,25,98,99,63,67,**,'
	//(5) - Folder "Totais"
	oView:AddSheet( 'PAINEL_GERAL_FOLDERS', 'ABA05', STR0057 )	//'90.Totais'
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA05_A', 50,,, 'PAINEL_GERAL_FOLDERS', 'ABA05' )	//Totais dos Itens (C20)
	oView:CreateHorizontalBox( 'PAINEL_GERAL_FOLDERS_ABA05_B', 50,,, 'PAINEL_GERAL_FOLDERS', 'ABA05' )	//Tributos (C2F)
EndIf

//-------------------------------------------------------------------------------------------------------------------

If cCodModelo $ '01,02,04,06,07,08,09,10,11,13,14,15,16,18,1B,21,22,26,27,28,29,37,2D,2E,55,56,57,58,59,60,8B,65,17,20,23,24,25,98,99,63,67,**,'
	oView:SetOwnerView( 'VIEW_C20' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA01'  )
	oView:SetOwnerView( 'VIEW_C20B', 'PAINEL_GERAL_FOLDERS_ABA05_A'  )
	oView:SetOwnerView( 'VIEW_C2F',  'PAINEL_GERAL_FOLDERS_ABA05_B'  )

	If !cCodModelo $ '13,14,15,16,18'
		oView:SetOwnerView( 'VIEW_C30',  'PAINEL_GERAL_FOLDERS_ABA02_A'  )
		oView:SetOwnerView( 'VIEW_C35',  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA01' )
		
		If lReinf20
		oView:SetOwnerView( 'VIEW_V4C',  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA26' )
		oView:SetOwnerView( 'VIEW_V4D',  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA27' )
		EndIf

		If TAFAlsInDic("T9Q")	
			oView:SetOwnerView( 'VIEW_T9Q',  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA25' )
		EndIf
	
	EndIf
	oView:SetOwnerView( 'VIEW_C6W',  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA09' )
EndIf

If TAFAlsInDic( "T60" )
	If cCodModelo $ '01,02,04,06,13,14,15,16,18,1B,21,22,28,29,37,2D,2E,55,65,8B,17,20,23,24,25,59,60,98,99,**,'
		oView:SetOwnerView( 'VIEW_T60', 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA03'  )
	EndIf
EndIf

If cCodModelo $ '13,14,15,16,**'
	oView:SetOwnerView( 'VIEW_C7B' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA19'    )
EndIf

If cCodModelo $ '01,1B,04,06,07,08,8B,09,10,11,21,22,26,27,28,29,55,57,65,17,20,23,24,25,98,99,63,67,**'
	oView:SetOwnerView( 'VIEW_C21' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_B'    )
EndIf

If cCodModelo $ '01,1B,04,55,65,17,20,23,24,25,98,99,**,'
	oView:SetOwnerView( 'VIEW_C22' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA01'    )
	oView:SetOwnerView( 'VIEW_C25' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA02'    )
	oView:SetOwnerView( 'VIEW_C26' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS_ABA01'  )
	oView:SetOwnerView( 'VIEW_C27' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA03_FOLDERS_ABA02'  )
EndIf

If cCodModelo $ '01,1B,04,17,20,23,24,25,98,99,**,'
	oView:SetOwnerView( 'VIEW_C28' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_C_FOLDERS_ABA05' )
EndIf

If cCodModelo $ '01,17,20,23,24,25,98,99,**,'
	oView:SetOwnerView( 'VIEW_C23' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA02'    )
	oView:SetOwnerView( 'VIEW_C2B' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA03'    )
	oView:SetOwnerView( 'VIEW_C33',  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA03' )
EndIf

//Proteção caso não tenha sido aplicado o dicionario 007859 TSI
If lAtu == .T.
	If cCodModelo $ '01,1B,04,07,08,8B,09,10,11,26,27,55,57,65,17,20,23,24,25,98,99,63,67,**'
		oView:SetOwnerView( 'VIEW_C2D' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_B'   )
		oView:SetOwnerView( 'VIEW_T00' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_C'   )
	EndIf
Else
	If cCodModelo $ '01,02,1B,04,06,07,08,8B,09,10,11,13,14,15,16,21,22,26,27,28,29,55,57,65,17,20,23,24,25,98,99,63,67,**'
		oView:SetOwnerView( 'VIEW_C2C' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_A'    )
		If !cCodModelo $ '02,06,13,14,15,16,21,22,28,29'
			oView:SetOwnerView( 'VIEW_C2D' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_B'   )
			oView:SetOwnerView( 'VIEW_T00' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA07_C'   )
		EndIf
	EndIf
EndIf

If cCodModelo $ '01,55,56,29,65,17,20,23,24,25,98,99,**,'
	If cCodModelo $ "55,65"
		oView:SetOwnerView( 'VIEW_C2H' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA08'   )
		oView:SetOwnerView( 'VIEW_C23' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA02'   )
	EndIf
	oView:SetOwnerView( 'VIEW_C29' , 'PAINEL_GERAL_FOLDERS_ABA04_A' )
	oView:SetOwnerView( 'VIEW_C2A' , 'PAINEL_GERAL_FOLDERS_ABA04_B' )
	If cCodModelo $ "55,65"
		oView:SetOwnerView( 'VIEW_C33' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA03' )
		oView:SetOwnerView( 'VIEW_CAI' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA21_A' )
		oView:SetOwnerView( 'VIEW_CH1' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA21_B' )
		oView:SetOwnerView( 'VIEW_CH2' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA21_C' )
	EndIf
EndIf

If cCodModelo $ '06,28,29,**,'
	oView:SetOwnerView( 'VIEW_C2E' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA10'   )
	oView:SetOwnerView( 'VIEW_C32' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA07'  )
EndIf

If cCodModelo $ '21,22,**,'
	oView:SetOwnerView( 'VIEW_C2G' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA11'   )
	oView:SetOwnerView( 'VIEW_C38' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA08'  )
EndIf

If cCodModelo $ '02,13,14,15,16,**,'
	oView:SetOwnerView( 'VIEW_C2I' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA12' )
EndIf

If cCodModelo $ '07,57,67,**,'
	oView:SetOwnerView( 'VIEW_C39' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA09'  )
EndIf

If cCodModelo $ '08,8B,09,10,11,26,27,55,65,**,'
	oView:SetOwnerView( 'VIEW_C3A' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA14_A')
	oView:SetOwnerView( 'VIEW_C3I' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA22')
EndIf

If cCodModelo $ '08,8B,26,**,'
	oView:SetOwnerView( 'VIEW_C3F' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA13'  )
EndIf

If cCodModelo $ '09,**,'
	oView:SetOwnerView( 'VIEW_C3G' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA16'  )
EndIf

If cCodModelo $ '10,**,'
	oView:SetOwnerView( 'VIEW_C3H' ,  'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA17'  )
EndIf

If cCodModelo $ '26,**,'
	oView:SetOwnerView( 'VIEW_C24' , 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA18' )
EndIf

If cCodModelo $ '01,55,65,17,20,23,24,25,98,99,**,' .And. !cCodModelo $ '13,14,15,16,18'
	oView:SetOwnerView( 'VIEW_C31' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA02'  )
	oView:SetOwnerView( 'VIEW_C34' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA04'  )
	oView:SetOwnerView( 'VIEW_C36' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA05'  )
	oView:SetOwnerView( 'VIEW_C37' ,  'PAINEL_GERAL_FOLDERS_ABA02_B_FOLDERS_ABA06'  )
EndIf

//oView:SetOwnerView( 'VIEW_C20C', 'PAINEL_GERAL_FOLDERS_ABA03'  )
//oView:SetOwnerView( 'VIEW_C20E', 'PAINEL_GERAL_FOLDERS_ABA01_FOLDERS_ABA02_FOLDERS_ABA01_A'  )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de valida da inclusao do documento fiscal, chamada no final, no momento da gravacao do modelo

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local	lRet			:=	.T.
Local 	nOperation 		:= 	oModel:GetOperation()
Local	cChvNF 			:= 	oModel:GetValue( 'MODEL_C20' , 'C20_CHVNF' )
Local	cModelo 		:= 	XFUNID2Cd( oModel:GetValue( 'MODEL_C20' , 'C20_CODMOD' ) , 'C01' )
Local	cTipoES 		:= 	oModel:GetValue( 'MODEL_C20' , 'C20_INDOPE' )
Local	cSitDoc			:=	XFUNID2Cd( oModel:GetValue( 'MODEL_C20' , 'C20_CODSIT' ) , 'C02')
Local 	oModelC2A 		:= 	oModel:GetModel( 'MODEL_C2A' )
Local 	oModelC2E 		:= 	oModel:GetModel( 'MODEL_C2E' )
Local 	oModelC2G 		:= 	oModel:GetModel( 'MODEL_C2G' )
Local 	oModelC24 		:= 	oModel:GetModel( 'MODEL_C24' )
Local 	oModelC30 		:= 	oModel:GetModel( 'MODEL_C30' )
Local 	oModelC32 		:= 	oModel:GetModel( 'MODEL_C32' )
Local 	oModelC38 		:= 	oModel:GetModel( 'MODEL_C38' )
Local 	oModelC39 		:= 	oModel:GetModel( 'MODEL_C39' )
Local 	oModelC3A 		:= 	oModel:GetModel( 'MODEL_C3A' )
Local 	oModelC3F 		:= 	oModel:GetModel( 'MODEL_C3F' )
Local 	oModelC3G 		:= 	oModel:GetModel( 'MODEL_C3G' )
Local 	oModelC3H 		:= 	oModel:GetModel( 'MODEL_C3H' )
Local 	oModelC3I 		:= 	oModel:GetModel( 'MODEL_C3I' )
Local	cMensagem		:=	""
Local	nCtd			:=	0
Local	cString			:=	""
Local	lProcMILE	:=	Iif( Type( 'lMILE' ) <> 'U' .And. lMILE , lMILE , .F. )

//No caso de exclusao nao devo realizar a validacao de integridade, essa regra foi criada para que
//o MVC nao proiba o usuario de excuir um cadastro integrado de maneira invalida ( campo obrigatorios
//em branco )
If nOperation == MODEL_OPERATION_DELETE
	
	lRet := Taf62LEMChk( TafGetMtrz( oModel:GetValue( 'MODEL_C20' , 'C20_FILIAL' ) ), cChvNF )

Else
	
	//Validacao da Chave Unica
	If nOperation == MODEL_OPERATION_INSERT
	
		lRet	:=	XFUNVldUni( "C20" , 1 , xFilial( "C20" ) + cChvNF )
	
	EndIf
	
	//Funcao que exibe mensagem dos reflexos dos ajustes dos documentos
	If !IsBlind() .AND. lRet
		lRet := XFUNReflex( nOperation , aCmpsAlts , 'TAFA062' )
	EndIf
	
	//Se a chave unica estiver OK, prossigo com as validacoes de conteudo
	If lRet .And. !(cModelo $ "13,14,15,16,18") //Somente para Bilhetes (Modelos 13, 14, 15 e 16) e RMD (Modelo 18) não eh necessario informar o item
	
		If !(cSitDoc $ "02,03,04,05")	
	
			nCtd		:=	A062PrcMdl( oModelC30 )
	
			If nCtd == 0
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= STR0065 + 'T015'	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + " 50"	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF017",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal deve ser preenchido antes de gravar o formulário.
			EndIf
	
		EndIf
	EndIf
	
	//Se a validacao do item retornar OK.
	If lRet
	
		//Validacoes dos modelos de documentos fiscais de Energia Eletrica, Gas e Agua Canalizada
		Do Case
		Case cModelo == "01"
	
			//Somente quando o pagamento eh a prazo se torna obrigatoria a informacao dos
			//titulos, essa regra eh estipulada no registro C140 do Sped Fiscal
			If FwFldGet("C20_INDPAG") == "1"
				nCtd		:=	A062PrcMdl( oModelC2A )
	
				If nCtd == 0
	
					//Caso Seja uma Nota Fiscal de Complemento de Frete/IPI/ICMS nao deve ser obrigatoria a inclusao de FATURAS, mesmo
					//para Notas Fiscais modelo 01
					If !TafNfCompl()
						lRet		:=	.F.
					Else
						lRet		:=	.T.
					EndIf
	
		            //Caso seja uma Nota Fiscal de Beneficiamento nao deve ser obrigatoria a inclusao de FATURAS,
		            //mesmo para Notas Fiscais modelo 01
		            If FwFldGet("C20_TPDOC") == "000006"
		                lRet        :=  .T.
		            EndIf
	
					//Caso Seja uma Nota Fiscal de Devolucao nao deve ser obrigatoria a inclusao de FATURAS, mesmo
					//para Notas Fiscais modelo 01
					If FwFldGet("C20_TPDOC") == "000002"
						lRet := .T.
					EndIf
					If lProcMILE
						cMensagem	:= STR0065 + 'T013AI e/ou T013AJ'	//'Informar o registro: '
					Else
						cMensagem	:= STR0058 + " 80"	//'Pasta'
					EndIf
					Help( ,,"TAFHLPNF001",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal deve ser preenchido antes de gravar o formulário.
				EndIf												//S:Para documentos fiscais de modelo 01 informar os campos correspondentes aos dados da Fatura.
			EndIf
	
		Case cModelo $ "06/28/29"
			
			//Desabilitado pois não iremos enviar o layout T013AN e não podemos bloquear o lançamento da NF na ausência do layout
			/*
			nCtd		:=	A062PrcMdl( oModelC2E )
			If lProcMILE
				cString	:=	'T013AN'
			Else
				cString	:=	"16(01->03->16)"
			EndIf
			*/
	
			//Se os registros da C2E estiverem OK, faco o tratamento do filho (ITEM), senao nem faco!!!
			If !( ( nCtd == 0 .And. cTipoES == '1' ) .Or. ( nCtd > 0 .And. cTipoES == '0' ) )
	
				nCtd		:=	A062PrcMdl( oModelC32 )
				If lProcMILE
					cString	:=	'T015AB'
				Else
					cString	:=	"57(50->57)"
				EndIf
			EndIf
	
			If nCtd == 0
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= STR0065 + cString	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' ' + cString	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF002",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal deve ser preenchido antes de gravar o formulário.
			EndIf												//S:Para documentos fiscais modelos 06, 28 e/ou 29 é necessário informar registros complementares com informações específicas desses modêlos.
	
		Case cModelo $ "21/22"
	
			nCtd		:=	A062PrcMdl( oModelC2G )
			If lProcMILE
				cString	:=	'T013AR'
			Else
				cString	:=	"17(01->03->17)"
			EndIf
	
			//Se os registros da C2G estiverem OK, faco o tratamento do filho (ITEM), senao nem faco!!!
			If !( ( nCtd == 0 .And. cTipoES == '1' ) .Or. ( nCtd > 0 .And. cTipoES == '0' ) )
	
				nCtd		:=	A062PrcMdl( oModelC38 )
				If lProcMILE
					cString	:=	'T015AH'
				Else
					cString	:=	"58(50->58)"
				EndIf
			EndIf
	
			Do Case
			Case nCtd == 0 .And. cTipoES == '1'			//Saída
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= STR0065 + cString	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' ' + cString		//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF003",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal deve ser preenchido antes de gravar o formulário.
																//S:Para documentos fiscais de Saída modelo 21 e/ou 22, deve-se informar os campos complementares.
			Case nCtd > 0 .And. cTipoES == '0'
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= STR0066 + cString + CRLF		//'NAO informar o registro: '
				Else
					cMensagem	:=	STR0058 + ' ' + cString		//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF004",,cMensagem, 5, 0 )	//H:O complemento informado para o este modêlo de documento fiscal está inválido.
																//S:Para documentos fiscais modêlo 21 e/ou 22 de Entrada, os campos complementares NAO devem ser preenchidos.
			EndCase
	
		Case cModelo $ "07"
	
			nCtd		:=	A062PrcMdl( oModelC39 )
	
			Do Case
			Case nCtd == 0 .And. cTipoES == '1'			//Saída
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= STR0065 + 'T015AI'	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' 59(50->59)'		//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF005",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal selecionado deve ser preenchido antes de gravar o formulário.
																//S:Para documentos fiscais de Saída modelo 07, os campos complementares devem ser informados.
			Case nCtd > 0 .And. cTipoES == '0'
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= STR0066 + 'T015AI' + CRLF	//'NAO informar o registro: '
				Else
					cMensagem	:=	STR0058 + ' 59(50->59)'		//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF006",,cMensagem, 5, 0 )	//H:O complemento informado para o este modêlo de documento fiscal está inválido.
																//S:Para documentos fiscais modêlo 07 de Entrada, os campos complementares NAO devem ser preenchidos.
			EndCase
	
		Case cModelo $ "08/8B"
	
			nCtd		:=	A062PrcMdl( oModelC3F )
	
			Do Case
			Case nCtd == 0 .And. cTipoES == '1'			//Saída
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= STR0065 + 'T013AO'	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' 19(01->03->19)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF007",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal selecionado deve ser preenchido antes de gravar o formulário.
																//S:Para documentos fiscais de Saída modelo 08 e/ou 8B, os campos complementares devem ser informados.
			Case nCtd > 0 .And. cTipoES == '0'
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0066 + 'T013AO' + CRLF 	//'NAO informar o registro: '
				Else
					cMensagem	:=	STR0058 + ' 19(01->03->19)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF008",,cMensagem, 5, 0 )	//H:O complemento informado para o este modêlo de documento fiscal está inválido.
																//S:Para documentos fiscais modêlo 08 e/ou 8B de Entrada, os campos complementares NAO devem ser preenchidos.
			EndCase
	
		Case cModelo == "09"
	
			nCtd		:=	A062PrcMdl( oModelC3G )
	
			Do Case
			Case nCtd == 0 .And. cTipoES == '1'			//Saída
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0065 + 'T013AU'	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' 21(01->03->21)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF009",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal selecionado deve ser preenchido antes de gravar o formulário.
																//S:Para documentos fiscais de Saída modelo 09, os campos complementares devem ser informados.
			Case nCtd > 0 .And. cTipoES == '0'
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0066 + 'T013AU' + CRLF	//'NAO informar o registro: '
				Else
					cMensagem	:=	STR0058 + ' 21(01->03->21)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF010",,cMensagem, 5, 0 )	//H:O complemento informado para o este modêlo de documento fiscal está inválido.
																//S:Para documentos fiscais modêlo 09 de Entrada, os campos complementares NAO devem ser preenchidos.
			EndCase
	
		Case cModelo == "10"
	
			nCtd		:=	A062PrcMdl( oModelC3H )
	
			Do Case
			Case nCtd == 0 .And. cTipoES == '1'			//Saída
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0065 + 'T013AV'	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' 22(01->03->22)'	//'Pasta'
				EndIF
				Help( ,,"TAFHLPNF011",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal selecionado deve ser preenchido antes de gravar o formulário.
																//S:Para documentos fiscais de Saída modelo 10, os campos complementares devem ser informados.
			Case nCtd > 0 .And. cTipoES == '0'
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0066 + 'T013AV' + CRLF	//'NAO informar o registro: '
				Else
					cMensagem	:=	STR0058 + ' 22(01->03->22)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF012",,cMensagem, 5, 0 )	//H:O complemento informado para o este modêlo de documento fiscal está inválido.
																//S:Para documentos fiscais modêlo 10 de Entrada, os campos complementares NAO devem ser preenchidos.
			EndCase
	
		Case cModelo == "26"
	
			nCtd		:=	A062PrcMdl( oModelC24 )
	
			Do Case
			Case nCtd == 0 .And. cTipoES == '1' 			//Saida
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0065 + 'T013AD'	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' 23(01->03->23)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF013",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal selecionado deve ser preenchido antes de gravar o formulário.
																//S:Para documentos fiscais de Saída modelo 26, os campos complementares devem ser informados.
			Case nCtd > 0 .And. cTipoES == '0'
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0066 + 'T013AD' + CRLF	//'NAO informar o registro: '
				Else
					cMensagem	:=	STR0058 + ' 23(01->03->23)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF014",,cMensagem, 5, 0 )	//H:O complemento informado para o este modêlo de documento fiscal está inválido.
																//S:Para documentos fiscais modêlo 26 de Entrada, os campos complementares NAO devem ser preenchidos.
			EndCase
	
		EndCase
	
		//Tratamento para todos os modelos de transporte. Acima tem os CASEs separados por modelo,
		//	porem essa consistencia abrange todos da mesma forma
		If lRet .And. cModelo $ "08/8B/09/10/11/26/27"
	
			nCtd		:=	A062PrcMdl( oModelC3A )
	
			//Se os registros da C3A estiverem OK, faco o tratamento do filho, senao nem faco!!! Verificacao apenas para modelo de NF 10
			If cModelo $ "10"
				If !( ( nCtd == 0 .And. cTipoES == '1' ) .Or. ( nCtd > 0 .And. cTipoES == '0' ) )
					nCtd := A062PrcMdl( oModelC3I )
				EndIf
			EndIf
	
			Do Case
			Case nCtd == 0 .And. cTipoES == '1' .And.  cModelo <> '27' //Saida
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0065 + 'T013AQ e/ou T013AW'	//'Informar o registro: '
				Else
					cMensagem	:= STR0058 + ' 20(01->03->20)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF015",,cMensagem, 5, 0 )	//H:Informações complementares referentes ao modêlo de documento fiscal selecionado deve ser preenchido antes de gravar o formulário.
																//S:Para documentos fiscais de Saída modelos 08, 8B, 09, 10, 11, 26 e/ou 27, os campos complementares devem ser informados.
			Case nCtd > 0 .And. cTipoES == '0' .And.  cModelo <> '27'
				lRet		:=	.F.
				If lProcMILE
					cMensagem	:= 	STR0066 + 'T013AQ e/ou T013AW' + CRLF	//'NAO informar o registro: '
				Else
					cMensagem	:=	STR0058 + ' 20(01->03->20)'	//'Pasta'
				EndIf
				Help( ,,"TAFHLPNF016",,cMensagem, 5, 0 )	//H:O complemento informado para o este modêlo de documento fiscal está inválido.
																//S:Para documentos fiscais modêlo 08, 8B, 09, 10, 11, 26 e/ou 27 de Entrada, os campos complementares NAO devem ser preenchidos.
			EndCase
		EndIf
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A062PrcMdl
Funcao generica que processa um grid do model e verifica se ha linhas e se algum campo nao foi preenchido

@param  oModel  - Modelo de dados a ser processado

@return nQtd - Quantidade de registros processados no for que representa os itens do GRID

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A062PrcMdl( oModel )
Local	nI			:=	0
Local	nCtd		:=	0

For nI := 1 To oModel:Length()
	oModel:GoLine( nI )

	If !oModel:IsDeleted()	//NAO considera deletados

		//Conto somente se foi inserido a linha e atualizado os campos, ou somente quando houver atualizacao de uma linha jah existente.
		If ( oModel:IsInserted() .And. oModel:IsUpdated() ) .Or. oModel:IsUpdated()

			nCtd++

		//Conto somente as linhas que nao tiveram manutencao e que jah existiam.
		//	Se foi feito uma coisa ou outra (Insert ou Update), nao conto.
		ElseIf !oModel:IsInserted() .And. !oModel:IsUpdated()

			nCtd++

		EndIf
	EndIf
Next nI

Return nCtd
//-------------------------------------------------------------------
/*/{Protheus.doc} TafNfCompl
Função que verifica se é uma nota fiscal complementar de ICMS, IPI ou Frete.
Se for uma nota fiscal de um dos tipos descritos acima, retorna True.
Caso seja de um tipo diferente, retorna False.
Esta funcao deve ser chamada do dicionario(X7_CONDIC) dos campos de QUANTIDADE, VALOR DO ITEM e do DESCONTO,
além de ser utilizada nas funções: A62TotItem (TAFA062.PRW) e XFUNVldVal (TAFXFUN.PRW)
@param
@return Operador Lógico.
@author Leandro Prado
@since 09/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafNfCompl( lValid )
Private	lRet	:=	.F.

Default lValid := .F.

	If lValid
		//Tratamento incluido pois foi existe a chamada desta funcao em
		//validacoes genericas no TAFXFUN, assim existem situacoes onde nao
		//se trata da Nota Fiscal, e nestes casos, ao realizar a comparacao
		//abaixo tinhamos error log.
		If Valtype( C20->C20_TPDOC ) <> "U"
			lRet	:= C20->C20_TPDOC $ "000003|000004|000005"
		Else
			lRet    := .F.
		EndIf
	Else
		//Tratamento incluido pois foi existe a chamada desta funcao em
		//validacoes genericas no TAFXFUN, assim existem situacoes onde nao
		//se trata da Nota Fiscal, e nestes casos, ao realizar a comparacao
		//abaixo tinhamos error log.
		If Valtype( FWFLDGET("C20_TPDOC") ) <> "U"
			lRet	:= FWFLDGET("C20_TPDOC")$"000003|000004|000005"
		Else
			lRet    := .F.
		EndIf
	EndIf

	/*	FWFLDGET( "C20_TPDOC" ) $ "000003" .Or. ;	//Icms
		FWFLDGET( "C20_TPDOC" ) $ "000004" .Or. ;	//IPI
		FWFLDGET( "C20_TPDOC" ) $ "000005"			//Frete */
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A62TotItem
Funcao de totalizacao dos valores de item para apresentar o folder de Totais do Documento.
	Esta funcao deve ser chamada do dicionario(X3_VALID) dos campos de QUANTIDADE, VALOR DO ITEM e do DESCONTO

@param  oModelC30  - Modelo de dados do ITEM a ser processado (GRID)

@return lRet    - Sempre .T.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A62TotItem( oModelC30 )
Local   cMensagem   := ""
Local	nI			:=	0
Local	nVlMerc		:=	0
Local	nVlDesc		:=	0
Local	oModelC20	:=	Nil
Local 	aSaveLine	:= 	Nil
Local	oView 		:= 	Nil
Local	oModel		:=	Nil
Local	lRet		:=	.T.
Local	lProcMILE	:=	Iif( Type( 'lMILE' ) <> 'U' .And. lMILE , lMILE , .F. )

If !lProcMILE	//Tratamento para nao processar esta funcao quando vier do MILE

	aSaveLine	:= 	FWSaveRows()		//Salvando a posicao da linha original para restaurar ao final do processamento.
	oView 		:= 	FWViewActive()	//Recuperando a view ativa da interface
	oModel		:=	FWModelActive()	//Recuperando o model ativo da interface

	//Se o model do GRID nao for passado, obtenho ele para poder processar os itens
	If oModelC30 == Nil
		oModelC30	:=	oModel:GetModel( 'MODEL_C30' )
	EndIf

	//Obtendo o model dos Totais para efetuar a atualizacao
	oModelC20	:=	oModel:GetModel( 'MODEL_C20' )

	//Processando o GRID de itens
	For nI := 1 To oModelC30:Length()
		oModelC30:GoLine( nI )

		If !oModelC30:IsDeleted()	//Se o item nao estiver deletado, NAO considero na soma
			//Quando a Nota for de Complemento de ICMS, IPI ou Frete o valor dos itens não devem ser multiplicados
			// pela quantidade, pois ela deverá estar zerada nesses casos.
			If TafNfCompl()

				//Tratamento para que Quando Nota Fiscal de Complemento nao possa utilizar quantidade maior do que 0.
				If oModelC30:GetValue( 'C30_QUANT' ) > 0
					cMensagem := " Para Nota Fiscal de Complemento de IPI, ICMS ou Frete este campo deve ser 0 ( zero )."
					Help( ,,,,cMensagem, 5, 0 )
					lRet := .F.
				EndIf

				nVlMerc	+=	oModelC30:GetValue( 'C30_VLRITE' )
				oModelC30:SetValue( 'C30_TOTAL' , oModelC30:GetValue( 'C30_VLRITE' ) )
			else
				nVlMerc	+=	oModelC30:GetValue( 'C30_QUANT' ) * oModelC30:GetValue( 'C30_VLRITE' )
			EndIf

			nVlDesc	+=	oModelC30:GetValue( 'C30_VLDESC' )
		EndIf
	Next nI

	//Atualizando valores totais do documento
	oModelC20:SetValue( 'C20_VLMERC' , nVlMerc )
	oModelC20:SetValue( 'C20_VLDESC' , nVlDesc )

	If !IsBlind()
		//Efetuando REFRESH da view de totais
		oview:Refresh( 'VIEW_C20B' )
	EndIf		  
	//Restaurando a linha original
	FWRestRows( aSaveLine )
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A62C2FPre
Funcao de utilizada em dois momentos:
	1) Para atualizar valores do GRID de resultado (Totalizador) no daso de DELETE ou UNDELETE de linhas do GRID de origem.
		Exemplo: C35 eh GRID origem para o C2F, entao dependendo da manutencao do C35 atualizo o C2F

@param oModelGrid	- Modelo de dados de chamada da funcao
		nLine     	- Linha do cursor no GRID
		cAction   	- Acao de manutencao do GRID. Ex: DELETE / UNDELETE
		cField    	- Campo alterado
		xValNew	- Novo conteudo informado no campo editado
		xValOld	- Valor anterior da edicao do campo

@return lRet		- Sempre .T.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62C2FPre( nTipo , oModelEdit , nLine , cAction , cField , xValNew , xValOld )
Local	lRet 		:= 	.T.
Local	nI			:=	0
Local	oModel 		:= 	oModelEdit:GetModel()
Local	nOperation 	:= 	oModel:GetOperation()
Local	oView 		:= 	Nil
Local	oModelC2F	:=	Nil
Local	oModelC30	:=	Nil
Local	oModelC35	:=	Nil
Local	oModelT9Q	:=	Nil
Local	lAchou		:=	.F.
Local	lAdd		:=	.F.
Local	lProcMILE	:=	Iif( Type( 'lMILE' ) <> 'U' .And. lMILE , lMILE , .F. )
Local	lDel_UnDel	:=	( cAction == 'DELETE' .Or. cAction == 'UNDELETE' ) .And. ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT )

//O tratamento do VALTYPE eh para compatibilizacao com recurso de FRAME criado neste produto
If ( !ValType( xValNew ) == 'U' .And. !ValType( xValOld ) == 'U' .And. !lProcMILE ) .Or.;		//Tratamento para nao processar esta funcao quando vier do MILE
	lDel_UnDel	//Tratamento somente para DELETE ou UNDELETE, quando estiver em uma operacao de INCLUSAO ou ALTERACAO do model.

If !IsBlind()
	oView 		:= 	FWViewActive()	//Recuperando a view ativa da interface
endif

	//Obtendo o model dos Totais para efetuar a atualizacao
	oModelC2F	:=	oModel:GetModel( 'MODEL_C2F' )

	If nTipo == 1
		//Obtendo o model dos itens para tratar os campos de Cod Tributo, CST e Aliquota
		oModelC35	:=	oModel:GetModel( 'MODEL_C35' )
		oModelC30	:=	oModelEdit	//Atribuindo o objeto do model em edicao a variavel correta para tratamentos posteriores
		
		If TAFAlsInDic("T9Q")
			oModelT9Q	:=  oModel:GetModel( 'MODEL_T9Q' )
		EndIf
	
	ElseIf nTipo == 2
		//Obtendo o model dos itens para tratar o CFOP
		oModelC30	:=	oModel:GetModel( 'MODEL_C30' )
		oModelC35	:=	oModelEdit	//Atribuindo o objeto do model em edicao a variavel correta para tratamentos posteriores

		If TAFAlsInDic("T9Q")
			oModelT9Q	:=  oModelEdit
		EndIf
	EndIf

	//Tratamento somente para DELETE ou UNDELETE, quando estiver em uma operacao de INCLUSAO ou ALTERACAO do model.
	If lDel_UnDel

		If nTipo == 1
		
		If TAFAlsInDic("T9Q")
		// Se estiver deletando/recriando o item, é necessário deletar/recriar os processos do REINF.
			For nI := 1 To oModelT9Q:Length()
				oModelT9Q:GoLine( nI )
				If oModelT9Q:IsDeleted() //Se C30 estiver deletado, significa que está sendo recriado.
					oModelT9Q:UnDeleteLine() //Recria o processo
				Else
					If !oModelT9Q:IsDeleted()
						oModelT9Q:DeleteLine() //Deleta o processo
					EndIf
				EndIf
				If !IsBlind()
					oview:Refresh("VIEW_T9Q")
				endif
			Next nI
		EndIf
		// Se estiver deletando/recriando o item, é necessário deletar/recriar os impostos correspondentes a ele.
			For nI := 1 To oModelC35:Length()
				oModelC35:GoLine( nI )
				If oModelC30:IsDeleted() //Se C30 estiver deletado, significa que está sendo recriado.
					oModelC35:UnDeleteLine() //Recria o imposto (Automaticamente calcula C2F, entrando nessa rotina com nTipo = 2)
				Else
					If !oModelC35:IsDeleted()
						oModelC35:DeleteLine() //Deleta o imposto (Automaticamente calcula C2F, entrando nessa rotina com nTipo = 2)
					EndIf
				EndIf
				If !IsBlind()
					oview:Refresh("VIEW_C35")
				endif
			Next nI
		Else
		// Ao deletar ou recriar um imposto (C35) é necessário efetuar as verificações de subtração/soma para o modelo C2F.
			For nI := 1 To oModelC2F:Length()
				oModelC2F:GoLine( nI )

				If	oModelC2F:GetValue( 'C2F_CODTRI' ) == oModelC35:GetValue( 'C35_CODTRI' ) .And.;
					oModelC2F:GetValue( 'C2F_CST' ) == oModelC35:GetValue( 'C35_CST' ) .And.;
					oModelC2F:GetValue( 'C2F_CFOP' ) == oModelC30:GetValue( 'C30_CFOP' ) .And.;
					oModelC2F:GetValue( 'C2F_CODSER' ) == oModelC30:GetValue( 'C30_CODSER' ) .And.;
					oModelC2F:GetValue( 'C2F_ALIQ' ) == oModelC35:GetValue( 'C35_ALIQ' )

					//Se estiver deletado restaura para aproveitar o registro.
					If oModelC2F:IsDeleted()
						oModelC2F:UnDeleteLine()
					EndIf

					lAchou	:=	.T.
					Exit
				EndIf

			Next nI

			//Caso nao encontre o imposto relacionado, adiciono a linha para atualiza-la
			If !lAchou
				lAdd	:=	.T.
				oModelC2F:AddLine()
				oModelC2F:SetValue( 'C2F_CODTRI', oModelC35:GetValue( 'C35_CODTRI' ) )
				oModelC2F:SetValue( 'C2F_CST'  	, oModelC35:GetValue( 'C35_CST' ) )
				oModelC2F:SetValue( 'C2F_CFOP' 	, oModelC30:GetValue( 'C30_CFOP' ) )
				oModelC2F:SetValue( 'C2F_CODSER', oModelC30:GetValue( 'C30_CODSER' ) )
				oModelC2F:SetValue( 'C2F_ALIQ' 	, oModelC35:GetValue( 'C35_ALIQ' ) )
			EndIf

			//Caso nao encontre o imposto relacionado ou tenha adicionado um novo (UNDELETE)
			If lAchou .Or. lAdd
				If cAction == 'DELETE'
					A62Sub( oModelC2F , oModelC35 )
				Else
					A62Sum( oModelC2F , oModelC35 )
				EndIf

				//Tratamento para quando o totalizador ficar zerado ao deletar uma linha no item, tambem deletar nele.
				A62Del( oModelC2F )

				oModelC2F:GoLine( 1 )

				//Efetuando REFRESH da view de totais
				If !IsBlind()
					oview:Refresh("VIEW_C2F")
				endif
			EndIf

		EndIf

	Else
		If cField + '|' $ 'C30_CFOP|' 
			XFUNVldCmp("C0Y",3)		//Se realmente a edicao do campo, tenho que efetuar o VALID abaixo para forcar o tratamento da Troca do codigo para o ID.
			xValNew := oModelC30:GetValue( 'C30_CFOP' )
		EndIf
		lRet	:=	A62TotTrb( oModelC2F , oModelC30 , oModelC35 , oView , cField , xValNew , xValOld )
	   	A62AtuTrib( oModelC2F , oModelC30 , oModelC35 , oview, cField , xValNew , xValOld  )
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A62TotTrb
Funcao responsavel por efetuar a SUBTRACAO dos valores de tributos para apresentar o folder de Totais do Documento.
	Esta funcao deve ser chamada na pre-validacao do modelo GRID.

@param  oModelC35  - Sub-Modelo de dados a ser processado (GRID)
		 oView      - View do modelo de dados
		 cFiled     - Campo de edicao do modelo

@return lRet    - Sempre .T.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62TotTrb( oModelC2F , oModelC30 , oModelC35 , oView , cField , xValNew , xValOld )
Local	cCmpVar		:=	ReadVar()
Local	cCmp		:=	AllTrim( SubStr( cCmpVar , 4 ) )
Local	nI			:=	0
Local 	aSaveLine	:= 	{}
Local	lRet		:=	.T.
Local	lAchou		:=	.F.
Local	cAlias		:=  ''
Local	cString		:=	''

//Garanto processamento somente para os campos previstos na C2F (Totalizador)
If cField + '|' $ 'C30_CFOP|C30_CODSER|C35_CODTRI|C35_CST|C35_ALIQ|C35_BASE|C35_VALOR|C35_BASEQT|C35_VLRPAU|C35_BASENT|C35_VLNT|C35_VLISEN|C35_VLOUTR|'

	If cField + '|' $ 'C30_CFOP|C30_CODSER|' //.And. cCmp == cField
		For nI := 1 To oModelC35:Length()
			oModelC35:GoLine( nI )

			If !Empty( oModelC35:GetValue( 'C35_CODTRI' ) )
				lAchou	:=	.T.
				Exit
			EndIf
		Next nI
	Else
		lAchou	:=	.T.
	EndIf

	If lAchou
		//Condicao para chamar a funcao de validacao de valor quando um campo em processamento for o mesmo editado (READVAR).
		If !( lRet := cCmp != cField )	//Se o campo for diferenco do READVAR, processo normalmente a funcao / Se for o mesmo, tenho que efetuar o VALID abaixo
			lRet	:=	cCmp == cField .And. XFUNVldVal( )
		EndIf

		//Por se tratar de uma pre-validacao, a informacao do campo ainda eh a velha, então preciso efetuar a valida para a nova e atribuir o valor
		//	conforme conversao tratada pela funcao, para posteriormente trabalhar com este valor convertido.
		If lRet .And. cCmp + '|' $ 'C35_CODTRI|'
			lRet	:=	XFUNVldCmp("C3S",3)	//Se realmente a edicao do campo, tenho que efetuar o VALID abaixo para forcar o tratamento da Troca do codigo para o ID.
		EndIf

		//Por se tratar de uma pre-validacao, a informacao do campo ainda eh a velha, então preciso efetuar a valida para a nova e atribuir o valor
		//	conforme conversao tratada pela funcao, para posteriormente trabalhar com este valor convertido.
		If lRet .And. cCmp + '|' $ 'C35_CST|'

	   		//Tratamento para utilizar o cString quando for passado, pois neste caso o campo de TRIBUTO nao existe e devo utilizar esta variavel para vincular o mesmo
			cString	:=	Iif( Empty( cString ) , FWFLDGET( 'C35_CODTRI' ) , cString )

			//ISSQN
			If !Empty( cCmp ) .And. cString $ "000001/000016"
				cAlias	:=	"C0H"

			//ICMS e ICMS/ST
			ElseIf !Empty( cCmp ) .And. cString $ "000002/000003/000004/000017/000026"
				cAlias	:=	"C14"

			//IPI
			ElseIf !Empty( cCmp ) .And. cString $ "000005"
				cAlias	:=	"C15"

			//PIS/Pasep/Cofins
			ElseIf !Empty( cCmp ) .And. cString $ "000006/000008/000010/000014/000007/000009/000011/000015"
				cAlias	:=	"C17"
			EndIf
			If !Empty(cAlias)
				lRet	:=	XFUNVldCmp(cAlias,3)	//Se realmente a edicao do campo, tenho que efetuar o VALID abaixo
													//para forcar o tratamento da Troca do codigo para o ID.
			Else
				lRet	:= .F.
			EndIf

		EndIf

		//Por se tratar de uma pre-validacao, a informacao do campo ainda eh a velha, então preciso efetuar a valida para a nova e atribuir o valor
		//	conforme conversao tratada pela funcao, para posteriormente trabalhar com este valor convertido.
		If lRet .And. cCmp + '|' $ 'C30_CFOP|' .and. !(Empty(cCmp)) 
			lRet	:=	XFUNVldCmp("C0Y",3)		//Se realmente a edicao do campo, tenho que efetuar o VALID abaixo para forcar o tratamento da Troca do codigo para o ID.
		EndIf

		//Por se tratar de uma pre-validacao, a informacao do campo ainda eh a velha, então preciso efetuar a valida para a nova e atribuir o valor
		//	conforme conversao tratada pela funcao, para posteriormente trabalhar com este valor convertido.
		If lRet .And. cCmp + '|' $ 'C30_CODSER|'
			lRet	:=	XFUNVldCmp("C0B",3)		//Se realmente a edicao do campo, tenho que efetuar o VALID abaixo para forcar o tratamento da Troca do codigo para o ID.
		EndIf

		If lRet

			//Salvando a posicao da linha original para restaurar ao final do processamento.
			aSaveLine	:= 	FWSaveRows()

			//Chamo a rotina de atualizacao. Foi criada a funcao abaixo para evitar duplicidade de codigo, que passou a se repetir em outros locais do fonte.
			A62RCalTri( oModelC2F , oModelC30 , oModelC35 ,oview, cField , xValNew , xValOld )

			oModelC2F:GoLine( 1 )

			//Efetuando REFRESH da view de totais
			If !IsBlind()
				oview:Refresh("VIEW_C2F")
			endif

			//Restaurando a linha original
			FWRestRows( aSaveLine )

		EndIf
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A62Sum
Funcao de SOMA dos valores de tributos a serem totalizados para apresentar o folder de Totais do Documento

@param oModelSum - Modelo de dados destino da aglutinacao dos valores
		oModel    - Modelo de dados base (detalhe) com os valores a serem aglutinados
		cCmpVar   - Campo em alteracao
		xValNew   - Novo conteudo informado no campo

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62Sum( oModelSum , oModel , cCmpVar , xValNew )
Local	cCampo			:=	''

Default	cCmpVar	:=	''

//Se nao for passado campo, refaco o calculo somente para o campo passado
If !Empty( cCmpVar )
	cCampo		:=	AllTrim( SubStr( cCmpVar , 4 ) )
	oModelSum:SetValue( 'C2F' + cCampo   , oModelSum:GetValue( 'C2F' + cCampo   ) + xValNew )

//Se nao for passado campo nenhum, refaco o calculo pra todos
Else
	oModelSum:SetValue( 'C2F_BASE'   , oModelSum:GetValue( 'C2F_BASE'   ) + oModel:GetValue( 'C35_BASE'   ) )
	oModelSum:SetValue( 'C2F_VALOR'  , oModelSum:GetValue( 'C2F_VALOR'  ) + oModel:GetValue( 'C35_VALOR'  ) )
	oModelSum:SetValue( 'C2F_BASEQT' , oModelSum:GetValue( 'C2F_BASEQT' ) + oModel:GetValue( 'C35_BASEQT' ) )
	oModelSum:SetValue( 'C2F_VLRPAU' , oModelSum:GetValue( 'C2F_VLRPAU' ) + oModel:GetValue( 'C35_VLRPAU' ) )
	oModelSum:SetValue( 'C2F_BASENT' , oModelSum:GetValue( 'C2F_BASENT' ) + oModel:GetValue( 'C35_BASENT' ) )
	oModelSum:SetValue( 'C2F_VLNT'   , oModelSum:GetValue( 'C2F_VLNT'   ) + oModel:GetValue( 'C35_VLNT'   ) )
	oModelSum:SetValue( 'C2F_VLISEN' , oModelSum:GetValue( 'C2F_VLISEN' ) + oModel:GetValue( 'C35_VLISEN' ) )
	oModelSum:SetValue( 'C2F_VLOUTR' , oModelSum:GetValue( 'C2F_VLOUTR' ) + oModel:GetValue( 'C35_VLOUTR' ) )
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} A62Sub
Funcao de SOMA dos valores de tributos a serem totalizados para apresentar o folder de Totais do Documento

@param oModelSub - Modelo de dados destino da subtracao dos valores
		oModel    - Modelo de dados base (detalhe) com os valores a serem subtraidos
		cCmpVar   - Campo em alteracao
		xValOld   - Conteudo do campo antes da alteracao

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62Sub( oModelSub , oModel , cCmpVar , xValOld )
Local	cCampo			:=	''

Default	cCmpVar	:=	''

//Se nao for passado campo, refaco o calculo somente para o campo passado
If !Empty( cCmpVar )
	cCampo		:=	AllTrim( SubStr( cCmpVar , 4 ) )
	oModelSub:SetValue( 'C2F' + cCampo   , oModelSub:GetValue( 'C2F' + cCampo   ) - xValOld )

//Se nao for passado campo nenhum, refaco o calculo pra todos
Else
	oModelSub:SetValue( 'C2F_BASE'   , oModelSub:GetValue( 'C2F_BASE'   ) - oModel:GetValue( 'C35_BASE'   ) )
	oModelSub:SetValue( 'C2F_VALOR'  , oModelSub:GetValue( 'C2F_VALOR'  ) - oModel:GetValue( 'C35_VALOR'  ) )
	oModelSub:SetValue( 'C2F_BASEQT' , oModelSub:GetValue( 'C2F_BASEQT' ) - oModel:GetValue( 'C35_BASEQT' ) )
	oModelSub:SetValue( 'C2F_VLRPAU' , oModelSub:GetValue( 'C2F_VLRPAU' ) - oModel:GetValue( 'C35_VLRPAU' ) )
	oModelSub:SetValue( 'C2F_BASENT' , oModelSub:GetValue( 'C2F_BASENT' ) - oModel:GetValue( 'C35_BASENT' ) )
	oModelSub:SetValue( 'C2F_VLNT'   , oModelSub:GetValue( 'C2F_VLNT'   ) - oModel:GetValue( 'C35_VLNT'   ) )
	oModelSub:SetValue( 'C2F_VLISEN' , oModelSub:GetValue( 'C2F_VLISEN' ) - oModel:GetValue( 'C35_VLISEN' ) )
	oModelSub:SetValue( 'C2F_VLOUTR' , oModelSub:GetValue( 'C2F_VLOUTR' ) - oModel:GetValue( 'C35_VLOUTR' ) )
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} A62Del
Funcao que verifica se todos os valores importantes do registros estao ZERADOs e caso esteja, deleta o registro.

@param oModelC2F - Modelo de dados de resumo do documento fiscal

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62Del( oModelC2F )
	//Tratamento para quando o totalizador ficar zerado ao deletar uma linha no item, tambem deletar nele.
	If( oModelC2F:GetValue( 'C2F_BASE' ) + oModelC2F:GetValue( 'C2F_VALOR' ) + oModelC2F:GetValue( 'C2F_BASEQT' ) +;
		oModelC2F:GetValue( 'C2F_VLRPAU' ) + oModelC2F:GetValue( 'C2F_BASENT' ) + oModelC2F:GetValue( 'C2F_VLNT' ) +;
		oModelC2F:GetValue( 'C2F_VLISEN' ) + oModelC2F:GetValue( 'C2F_VLOUTR' ) ) <= 0
		oModelC2F:DeleteLine()
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} A62RatVcts
Funcao de rateio do valor total da fatura para quantidade de vencimentos (parcelas) configurada
	Esta funcao deve ser chamada do dicinario(X3_VALID) dos campos Parcela e Valor da Fatura.

@return lRet    - Sempre .T.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A62RatVcts()
Local	lRet      := .T.
Local	cCmpVar   := ReadVar()
Local	cCmp      := AllTrim( SubStr( cCmpVar , 4 ) )
Local	nI        := 0
Local	oView     := FWViewActive()
Local	oModel    := FWModelActive()
Local	oModelC29 := Nil
Local	oModelC2A := Nil
Local	nQtdPar   := 0
Local	nValor    := 0
Local	nValorX   := 0
Local	nVlrUlt   := 0
Local   nVlrTot   := 0
Local   nVlrDes   := 0
Local	lProcMILE := Iif( Type( 'lMILE' ) <> 'U' .And. lMILE , lMILE , .F. )

oModelC2A	:=	oModel:GetModel( 'MODEL_C2A' )

oModelC2A:SetNoInsertLine(.F.)
oModelC2A:SetNoDeleteLine(.F.)

//Garanto processamento somente para os campos previstos na C2F (Totalizador)
If !lProcMILE .And.;	//Processamento atraves do MILE nao utilizo o facilitador das parcelas
	cCmp + '|' $ 'C29_QTDPAR|C29_VLRTOT|C29_VLRDES|C29_VLRLIQ|'

	//Obtendo o model dos Totais para efetuar a atualizacao
	oModelC29	:=	oModel:GetModel( 'MODEL_C29' )

	nVlrTot	:=	oModelC29:GetValue('C29_VLRTOT')
	nVlrDes	:=	oModelC29:GetValue('C29_VLRDES')
	nValorX	:=	nVlrTot - nVlrDes	

	If nVlrTot > nVlrDes
		//Tratamento para exibir a mensagem de refazer o GRID de vencimentos somente se tiver valor informado, pois neste caso, jah foi populado em outro momento.
		If nValorX > 0 
			If  IsBlind() .OR. MsgYesNo( STR0059 , STR0060 )	//"Os vencimentos da fatura serão redistribuídos, alterando-se os dados atuais, como 'Parcela', 'Vencimento' e 'Valor'. Deseja continuar ?"###'Alteração dos vencimentos da fatura'
			
				nQtdPar	    :=	oModelC29:GetValue( 'C29_QTDPAR' )

				nValor	:=	Round( nValorX / nQtdPar , 2 )	//Calculo as parcelas

				//Tratamento da diferenca de arredondamento para abater na ultima parcela
				If ( nValor * nQtdPar )  > nValorX					//Se a soma das parcelas for maior que o total da fatura
					nVlrUlt	:=	nValorX - ( nValor * nQtdPar )

				ElseIf ( nValor * nQtdPar )  < nValorX				//Se a soma das parcelas for menor que o total da fatura
					nVlrUlt	:=	nValorX - ( nValor * nQtdPar )
				EndIf
				nVlrUlt	:=	nValor + nVlrUlt

				//Deletando os itens existentes no GRID e adicionando novos

				For nI := 1 To oModelC2A:Length()
					oModelC2A:GoLine( nI )
					//So permito a exclusao se algum dos campos estiver preenchido. Evitando que fique uma linha deletada em branco, fazendo com que a
					// experiencia do usuario na tela seja mais amigavel/agradavel.
					if	!Empty(oModelC2A:GetValue( 'C2A_VLRPAR')) .Or. !Empty(oModelC2A:GetValue( 'C2A_NUMPAR'));
					.Or.	!Empty(oModelC2A:GetValue( 'C2A_VECTO'))
						oModelC2A:DeleteLine()
					EndIf

				Next nI
				oModelC2A:GoLine( 1 )

				//Processo a distribuicao calculada acima nas parcelas
				For nI := 1 To nQtdPar 
					//So permito a criacao de uma novalinha se a primeira estiver deletada ou nao estiver setado na primeira linha.
					// Evitando que fique uma linha deletada ou em branco, fazendo com que a  experiencia do usuario na tela seja mais amigavel/agradavel.
					if oModelC2A:IsDeleted() .Or. nI > 1
						oModelC2A:AddLine()
					EndIf
					oModelC2A:LoadValue( 'C2A_NUMPAR' , AllTrim( StrZero( nI , 4 ) ) )
					oModelC2A:LoadValue( 'C2A_VECTO' , dDataBase + (30 * nI ) )

					//Tratamento para efetuar abatimento/acrescimos dos centavos de diferenca na ultima parcela
					If nI == nQtdPar .And. nVlrUlt > 0
						oModelC2A:LoadValue( 'C2A_VLRPAR' , nVlrUlt )
					Else
						oModelC2A:LoadValue( 'C2A_VLRPAR' , nValor )
					EndIf
				Next nI
				oModelC2A:GoLine( 1 )
				If  !IsBlind() 	   
					oview:Refresh("VIEW_C2A")
				EndIf	
			EndIf		
		Else
			Help( ,, "HELP",, STR0110, 1, 0,,,,,, { STR0111 } ) // "Vencimentos da Fatura não atualizados" "Informe nova quantidade de parcelas ou valor total para que os vencimentos da fatura sejam atualizados."
			lRet := .f.
		EndIf	
	Elseif nValorX <= 0 .and. nVlrTot > 0

		Help(,,  STR0103, , STR0102, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0104})
		lRet := .f.
	EndIf
EndIf

oModelC2A:SetNoInsertLine(.T.)
oModelC2A:SetNoDeleteLine(.T.)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A62C30Pos
Funcao utilizada para fazer a pos validacao de uma linha no grid

@param  oModelGrid - Objeto do GRID ativo

@return lRet       - .T. para processamento OK
					    .F. para processamento invalido

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62C30Pos( oModelGrid )
Local	lRet	:=	.T.

/*If Empty( oModelGrid:GetValue( 'C30_CFOP' ) + oModelGrid:GetValue( 'C30_CODSER' ) )
	Help( ,,"TAFHLPNF018",,,,)	//H:Deve ser informado o Código Fiscal de Operação/Prestação( CFOP ) ou um Código da Lista de Serviço válido para cada item existente no documento fiscal.
								//S:Será necessário rever o documento fiscal antes da gravação do mesmo, sem essa informação é impossível consluir a operação de inclusão/alteração.
	lRet	:=	.F.
EndIf*/

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A062LogAlt
Funcao utilizada para atualizar uma variavel STATIC tratada no SAVE no modelo.
	Tratamento passado por framework para podermos identificar os campos alterados
	no modelo para podermos exibir alguns alertas.

@param  Nil

@return Sempre .T.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A062LogAlt()

If ValType( aCmpsAlts ) == "A" .And. aScan( aCmpsAlts , ReadVar() ) == 0
	aAdd( aCmpsAlts , ReadVar() )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A62AtuTrib
Funcao responsavel por efetuar atualizacao dos tributos para apresentar o folder de Totais do Documento a partir do modelo C30 (Itens)
Originalmente programada para atualizar CFOP, mas podera ser utilizada para outras informacoes que se repitam entre oModel35 e oModelC2F.
Seu funcionamento consiste em ao se atulizar uma informacao do oModelC2F que se tenha sido informada no oModelC30, percorrendo todos os registros
do modelo C35 (Impostos dos Itens) para poder saber quais informacoes devem ser atualizadas no C2F

@param  oModelC35  - Sub-Modelo de dados a ser processado (GRID)
		 oView      - View do modelo de dados
		 cFiled     - Campo de edicao do modelo

@return lRet    - Sempre .T.

@author Leandro Prado
@since 16/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62AtuTrib( oModelC2F , oModelC30 , oModelC35 ,oview, cField , xValNew , xValOld )
Local	cCmpVar	:=	ReadVar()
Local	cCmp		:=	AllTrim( SubStr( cCmpVar , 4 ) )
Local	nInc		:=	0
Local	lRet		:=	.T.
Local	lAchou		:= .F.

//Garanto processamento somente para os campos previstos na C2F (Totalizador)
If cField + '|' $ 'C30_CFOP|C30_CODSER|'
	aSaveLine	:= 	FWSaveRows()
	//Condicao para chamar a funcao de validacao de valor quando um campo em processamento for o mesmo editado (READVAR).
	If !( lRet := cCmp != cField )	//Se o campo for diferenco do READVAR, processo normalmente a funcao / Se for o mesmo, tenho que efetuar o VALID abaixo
		lRet	:=	cCmp == cField .And. XFUNVldVal( )
	EndIf

	//Por se tratar de uma pre-validacao, a informacao do campo ainda eh a velha, então preciso efetuar a valida para a nova e atribuir o valor
	//	conforme conversao tratada pela funcao, para posteriormente trabalhar com este valor convertido.
	If lRet .And. cCmp + '|' $ 'C30_CFOP|'
		lRet	:=	XFUNVldCmp("C0Y",1)		//Se realmente a edicao do campo, tenho que efetuar o VALID abaixo para forcar o tratamento da Troca do codigo para o ID.
	EndIf

	For nInc := 1 To oModelC35:Length()
		oModelC35:GoLine( nInc )
	   	lAchou := .F.

        // Garanto que so vai passar aqui quando estiver no segundo item do oModelC35, pois o primeiro foi atualizado na rotina que foi
        // chamada anteriormente. Evitando assim, que itens com chaves iguais a anterior sejam atualizados de forma errada.
		If lRet .And. nInc > 1
            // Chama a rotina de recalculo para cada item do oModelC35
			A62RCalTri( oModelC2F , oModelC30 , oModelC35 ,oview, cField , xValNew , xValOld)
		EndIf
	Next nInc
	oModelC2F:GoLine( 1 )

	FWRestRows( aSaveLine )

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A62RCalTri
Funcao responsavel por efetuar a atualizacao dos valores de tributos para apresentar o folder de Totais do Documento.
Todo o codigo dessa funcao foi criado pelo Gustavo Rueda originalmente na funcao A62TotTrb e com o passar do tempo passou, tambem, a fazer parte
da funcao A62AtuTrib. Para evitar a duplicidade de codigo foi criado essa funcao e ela esta sendo chamada dentro dessas duas citadas.

@param  oModelC35  - Sub-Modelo de dados a ser processado (GRID)
		 oView      - View do modelo de dados
		 cFiled     - Campo de edicao do modelo

@return lRet    - Sempre .T.

@author Leandro Prado
@since 22/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A62RCalTri( oModelC2F , oModelC30 , oModelC35 ,oview, cField , xValNew , xValOld)
Local	cCmpVar		:= ReadVar()
Local	cCmp		:= AllTrim( SubStr( cCmpVar , 4 ) )
Local	lRet		:= .T.
Local	lAchou		:= .F.
Local	bCondIf		:= {|| .T. }
Local	bCondFor	:= {|| .T. }
Local	cCdTrbAnt	:= ''
Local	cCstAnt		:= ''
Local	cCfopAnt	:= ''
Local	cServAnt	:= ''
Local	cCdTrbNw	:= ''
Local	cCstNw		:= ''
Local	cCfopNw		:= ''
Local	cServNw		:= ''
Local   cC2FSerNw	:= ''
Local	nI			:= 0
Local	nIAux		:= 0
Local	nInc		:= 0
Local	nI_Bkp		:= 0
Local	nAliqAnt	:= 0
Local	nBsTriAnt	:= 0
Local	nVlTriAnt	:= 0
Local	nAliqNw		:= 0
Local   nBsTriNw	:= 0
Local   nVlTriNw	:= 0
Local   nQtdProd	:= 0

Default cField		:= ''

nQtdProd := oModelC30:Length()

cCfopAnt	:= Iif( cField == 'C30_CFOP' 	, xValOld , oModelC30:GetValue( 'C30_CFOP'   ))
cServAnt	:= Iif( cField == 'C30_CODSER'	, xValOld , oModelC30:GetValue( 'C30_CODSER' ))

cCdTrbAnt	:= Iif( cField == 'C35_CODTRI'	, xValOld , oModelC35:GetValue( 'C35_CODTRI' ))
cCstAnt		:= Iif( cField == 'C35_CST' 	, xValOld , oModelC35:GetValue( 'C35_CST' 	 ))
nAliqAnt	:= Iif( cField == 'C35_ALIQ' 	, xValOld , oModelC35:GetValue( 'C35_ALIQ' 	 ))
nBsTriAnt 	:= Iif( cField == 'C35_BASE' 	, xValOld , oModelC35:GetValue( 'C35_BASE'   ))
nVlTriAnt	:= Iif( cField == 'C35_VALOR' 	, xValOld , oModelC35:GetValue( 'C35_VALOR'  ))

cCfopNw		:= Iif( cField == 'C30_CFOP' 	, xValNew , oModelC30:GetValue( 'C30_CFOP' 	 ))
cServNw		:= Iif( cField == 'C30_CODSER'  , xValNew , oModelC30:GetValue( 'C30_CODSER' ))

cCdTrbNw	:= Iif( cField == 'C35_CODTRI'	, xValNew , oModelC35:GetValue( 'C35_CODTRI' ))
cCstNw		:= Iif( cField == 'C35_CST' 	, xValNew , oModelC35:GetValue( 'C35_CST' 	 ))
nAliqNw		:= Iif( cField == 'C35_ALIQ' 	, xValNew , oModelC35:GetValue( 'C35_ALIQ'   ))
nBsTriNw 	:= Iif( cField == 'C35_BASE' 	, xValNew , oModelC35:GetValue( 'C35_BASE'   ))
nVlTriNw	:= Iif( cField == 'C35_VALOR' 	, xValNew , oModelC35:GetValue( 'C35_VALOR'  ))

lAchou		:= .F.

//Se não trabalhar com código de serviço e possuir apenas um produto/serviço no documento de entrada.
If "TAFA062E" $ Upper(funname()) .And. Empty(cServNw) .And. nQtdProd == 1
	bCondIf	:=	{|| !oModelC2F:IsDeleted() .And.;
					oModelC2F:GetValue( 'C2F_CODTRI' ) == cCdTrbAnt .And.;
					oModelC2F:GetValue( 'C2F_CST' )    == cCstAnt 	.And.;
					oModelC2F:GetValue( 'C2F_CFOP' )   == cCfopAnt 	.And.;
					oModelC2F:GetValue( 'C2F_ALIQ' )   == nAliqAnt }
Else //Funcionamento Padrão
	bCondIf	:=	{|| !oModelC2F:IsDeleted() .And.;
					oModelC2F:GetValue( 'C2F_CODTRI' ) == cCdTrbAnt .And.;
					oModelC2F:GetValue( 'C2F_CST' )    == cCstAnt 	.And.;
					oModelC2F:GetValue( 'C2F_CFOP' )   == cCfopAnt 	.And.;
					oModelC2F:GetValue( 'C2F_CODSER' ) == cServAnt 	.And.;
					oModelC2F:GetValue( 'C2F_ALIQ' )   == nAliqAnt }
EndIf

//Processando o GRID de tributos dos totais do documento para encontrar a linha a ser atualizada.
For nI := 1 To oModelC2F:Length()
	oModelC2F:GoLine( nI )
	If Eval( bCondIf )
		lAchou	:=	.T.
		Exit
	EndIf
Next nI

If !lAchou .And. nQtdProd == 1
	/* Se possuir apenas um produto/serviço no documento de entrada e não localizou o item no totalizador
	com a chave Código tributo + Cst + Cfop + Código Serviço + Alíquota, retiro o código de serviço.*/
	bCondIf	:=	{|| !oModelC2F:IsDeleted() .And.;
					oModelC2F:GetValue( 'C2F_CODTRI' ) == cCdTrbAnt .And.;
					oModelC2F:GetValue( 'C2F_CST' )    == cCstAnt 	.And.;
					oModelC2F:GetValue( 'C2F_CFOP' )   == cCfopAnt 	.And.;
					oModelC2F:GetValue( 'C2F_ALIQ' )   == nAliqAnt }

	//Processando o GRID de tributos dos totais do documento para encontrar a linha a ser atualizada.
	For nI := 1 To oModelC2F:Length()
		oModelC2F:GoLine( nI )
		If Eval( bCondIf )
			lAchou	:=	.T.
			Exit
		EndIf
	Next nI
endif
//Obtenho o último código de serviço digitado na aba totalizador de acordo com a base alterada na C35.
if lAchou
	cC2FSerNw := oModelC2F:GetValue( 'C2F_CODSER' )
endif

/* Se possuir apenas um produto/serviço no documento de entrada e digitado um código de serviço(C2F_CODSER) 
no totalizador(folder90) que difere do informado no produto (C30_CODSER ). */
If "TAFA062E" $ Upper(funname()) .And. nQtdProd == 1 .And. !Empty( cC2FSerNw ) .And. cC2FSerNw <> cServNw
	oModelC2F:SetValue( 'C2F_CODTRI' , cCdTrbNw		)
	oModelC2F:SetValue( 'C2F_CST'  	 , cCstNw 		)
	oModelC2F:SetValue( 'C2F_CFOP' 	 , cCfopNw 		)
	oModelC2F:SetValue( 'C2F_CODSER' , cC2FSerNw 	)
	oModelC2F:SetValue( 'C2F_BASE' 	 , nBsTriNw 	)
	oModelC2F:SetValue( 'C2F_ALIQ' 	 , nAliqNw 		)
	oModelC2F:SetValue( 'C2F_VALOR'	 , nVlTriNw		)
else 
	/*Funcionamento Padrão, se achar o registro no resumo, deleto os valores jah calculados e se o 
	registro ficar ZERADO deleto tambem o registro para criar outro novo.*/
	If lAchou
		A62Sub( oModelC2F , oModelC35 )
		A62Del( oModelC2F )	//Se a subtracao deixar o registro em ZERADO, removo o registro.
	EndIf

	lAchou	:=	.F.
	//Faco o tratamento de quebra da C2F  para fazer a atualizacao do resumo. Primeiro laco eh para encontrar outra linha
	//	com a mesma chave para agrupar os valores
	bCondIf	:=	{|| ( oModelC2F:GetValue( 'C2F_CODTRI' ) == cCdTrbNw .And.;
					oModelC2F:GetValue( 'C2F_CST' )  == cCstNw .And.;
					oModelC2F:GetValue( 'C2F_CFOP' ) == cCfopNw .And.;
					oModelC2F:GetValue( 'C2F_CODSER' ) == cServNw .And.;
					oModelC2F:GetValue( 'C2F_ALIQ' ) == nAliqNw ) .Or. ;
					Empty( oModelC2F:GetValue( 'C2F_CODTRI' ) ) .Or.;
				(Empty( oModelC2F:GetValue( 'C2F_CST' ) )  .And.  oModelC2F:GetValue( 'C2F_CODTRI' ) == cCdTrbNw)}

	//Processando o GRID de tributos dos totais do documento para encontrar a linha a ser atualizada
	For nI := 1 To oModelC2F:Length()
		oModelC2F:GoLine( nI )

		If Eval( bCondIf )
			//Se a linha estiver deletada, restaura ela para re-utilizar
			If oModelC2F:IsDeleted()
				nI_Bkp	:=	nI
				Loop
			EndIf
			lAchou	:=	.T.
			Exit
		EndIf
	Next nI

	//Se eu nao encontra a chave do novo registro, procuro por um com a chave anterior
	If !lAchou
		If nI_Bkp > 0	//Recupero o registro deletado que foi encontrado com a nova chave informada para uso.
			oModelC2F:GoLine( nI_Bkp )
			oModelC2F:UnDeleteLine()
			lAchou	:=	.T.
		Else
			//Faco o tratamento de quebra da C2F  para fazer a atualizacao do resumo
			bCondIf	:=	{|| oModelC2F:GetValue( 'C2F_CODTRI' ) == cCdTrbAnt .And.;
							oModelC2F:GetValue( 'C2F_CST' )  == cCstAnt .And.;
							oModelC2F:GetValue( 'C2F_CFOP' ) == cCfopAnt .And.;
							oModelC2F:GetValue( 'C2F_CODSER' ) == cServAnt .And.;
							oModelC2F:GetValue( 'C2F_ALIQ' ) == nAliqAnt }

			//Processando o GRID de tributos dos totais do documento para encontrar a linha a ser atualizada
			For nI := 1 To oModelC2F:Length()
					oModelC2F:GoLine( nI )

					If Eval( bCondIf )
						//Se a linha estiver deletada, restaura ela para re-utilizar
						If oModelC2F:IsDeleted()
							nI_Bkp	:=	nI
							Loop
						EndIf
						lAchou	:=	.T.
						oModelC2F:UnDeleteLine()
						// Se for CFOP ou CODSER e o registro encontrado nao estiver deletado volto a variavel para false para que seja criado uma
						// nova linha. Nos outros casos nao faco isso pois implicaria de forma incorreta na atualizacao de valores (aglutinacao / quebras)
						If (cCmp + '|' $ 'C30_CFOP|C30_CODSER|C35_ALIQ|') .And. nI_Bkp <= 0
							lAchou := .F.
						EndIf

						Exit
					EndIf
			Next nI
		EndIf
	EndIf

	//Caso nao encontre o imposto relacionado, adiciono a linha para atualiza-la
	If !lAchou
		If nI_Bkp > 0	//Recupero o registro deletado que foi encontrado com a nova chave informada para uso.
			oModelC2F:GoLine( nI_Bkp )
			oModelC2F:UnDeleteLine()
		Else
			oModelC2F:AddLine()
			nI	:=	oModelC2F:Length()
		EndIf
	EndIf

	//Se o registro posicionado estiver vazio, uso para o totalizador em questao
	oModelC2F:SetValue( 'C2F_CODTRI' , cCdTrbNw )
	oModelC2F:SetValue( 'C2F_CST'  	 , cCstNw )
	oModelC2F:SetValue( 'C2F_CFOP' 	 , cCfopNw )
	oModelC2F:SetValue( 'C2F_CODSER' , cServNw )
	oModelC2F:SetValue( 'C2F_ALIQ' 	 , nAliqNw )

	//Quando o valor incluido/alterado for maior que zero realizo tratamento default para calculo dos impostos
	If !( cField + '|' $ 'C30_CFOP|C30_CODSER|C35_CODTRI|C35_CST|C35_ALIQ|C35_BASE|C35_VALOR|' ) .Or.;
			( ( cField + '|' $ 'C35_BASE|C35_VALOR|' ) .And. xValNew > 0 )

			//Refaco valor do Campo que foi alterado
			A62Sub( oModelC2F , oModelC35 , cField , xValOld )
			A62Sum( oModelC2F , oModelC35 , cField , xValNew )

			/*Refaco o Calculo de todos os Campos envolvidos na tela de acordo com o valor
			alterado no campo acima*/
			A62Sum( oModelC2F , oModelC35 )
		
	Else
		//Caso a Alteracao seja no campo referente a Aliquota e valor menor ou igual a 0 (Zero)
		If ( cField + '|' $ 'C35_ALIQ|' ) .And. xValNew <= 0
			/*
			Caso o valor informado seja menor ou igual a 0 (Zero) eu zero tambem
			o valor do tributo e atualizo a valor da base de calculo na tabela C2F,
			este tratamento se fez necessario pois quando informado valor 0 (Zero )
			o valid do campo que eh alimentado via gatilho nao eh disparado, assim
			apenas o valor de aliquota ficava correto enquanto os valores de Base e tributo
			ficavam incorretos.
			*/
			A62Sum( oModelC2F, oModelC35, "C2F_VALOR", 0 )
			A62Sum( oModelC2F, oModelC35, "C2F_BASE", oModelC35:GetValue("C35_BASE") )
		Else
			A62Sum( oModelC2F , oModelC35 )
		EndIf
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()
Local aRetChk 	 := {}
Local lOK 		 := .T.
Local cFilMatriz := TafGetMtrz( M->C20_FILIAL )

//Verifica se a nota fiscal (legado) que esta sendo excluída foi utilizada no detalhamento das notas fiscais na apuracao do reinf (espelho).
if nOperation == MODEL_OPERATION_DELETE
	if "TAFA062E" $ Upper(funname()) //Doc.Entrada R-2010 / C20->T96->T95
		aRetChk := Taf62T96Chk( cFilMatriz, M->C20_CHVNF, AllTrim( M->C20_NUMDOC ), Alltrim( M->C20_SERIE ) )
		if len(aRetChk) >= 4 .And. aRetChk[1]
			if Taf62T95Chk( cFilMatriz, aRetChk[3], aRetChk[4] )				
				//#"Integridade do registro."#"Esta nota possui vínculo com o registro apurado no Reinf que já foi transmitido ou aguarda retorno do RET."
				//#"Deseja prosseguir com a exclusão mesmo assim?"
				if !MsgYesNo( STR0097 + CRLF + CRLF + STR0098  + CRLF + CRLF + STR0099 )
					oModel:SetErrorMessage( ,,,,, "Operação cancelada.", "Retorne e selecione a opção desejada.",, ) //#"Operação cancelada.", #"Retorne e selecione a opção desejada."
					lOK := .F.
				endif
			endif
		endif
	elseif "TAFA062S" $ Upper(funname()) //Doc.Saida R-2020 / C20->CRO->CMN
		aRetChk := Taf62CROChk( cFilMatriz, M->C20_CHVNF, AllTrim( M->C20_NUMDOC ), AllTrim( M->C20_SERIE ) )
		if len(aRetChk) >= 4 .And. aRetChk[1]
			if Taf62CMNChk( cFilMatriz, aRetChk[3], aRetChk[4] )
				//#"Integridade do registro."#"Esta nota possui vínculo com o registro apurado no Reinf que já foi transmitido ou aguarda retorno do RET."
				//#"Deseja prosseguir com a exclusão mesmo assim?"
				if !MsgYesNo( STR0097 + CRLF + CRLF + STR0098  + CRLF + CRLF + STR0099 )
					oModel:SetErrorMessage( ,,,,, "Operação cancelada.", "Retorne e selecione a opção desejada.",, ) //#"Operação cancelada." #"Retorne e selecione a opção desejada."
					lOK := .F.
				endif
			endif
		endif
	endif
Else	
	if TAFAlsInDic("V4D")
	//Dedução
		if FWFLDGET( "V4C_TPDEDU" ) $ '234' .And. Empty(FWFLDGET("V4C_NUMPRE") ) 
			lOk := .F.	
			oModel:SetErrorMessage( ,,,,, STR0119, STR0120,, ) //"O N° de Inscrição da Previdêcia se torna obrigatório quando o Tipo Dedução é igual 2,3 ou 4."
	//Isenção
		elseif 	 FWFLDGET("V4D_CTPISE") $ '99' .And. Empty( FWFLDGET( "V4D_DRENDI") ) 
			lOk := .F.	
			oModel:SetErrorMessage( ,,,,, STR0121, STR0120,, ) //"A descrição da isenção se torna obrigatória quando o Tipo da Isenção é igual 99=Outros"
		endif
	endif
endif

if lOK
	Begin Transaction
		If nOperation == MODEL_OPERATION_UPDATE
			TAFAltStat( "C20", " " )
		EndIf
		If FwFormCommit( oModel )
			If FindFunction('TafEndGRV')
				TafEndGRV( "C20","C20_PROCID", '', C20->(Recno())  )
				If TAFColumnPos("C20_PRID40" )
					TafEndGRV( "C20","C20_PRID40", '', C20->(Recno())  )
				ENDIF
			EndIf
		EndIf
	End Transaction
endif 

Return lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF062Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF062Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local cC21Key		:= ""
Local cC22Key		:= ""
Local cC23Key		:= ""
Local cC24Key		:= ""
Local cC25Key		:= ""
Local cC26Key		:= ""
Local cC27Key		:= ""
Local cC28Key		:= ""
Local cC29Key		:= ""
Local cC30Key		:= ""
Local cC31Key		:= ""
Local cC32Key		:= ""
Local cC33Key		:= ""
Local cC34Key		:= ""
Local cC35Key		:= ""
Local cC36Key		:= ""
Local cC37Key		:= ""
Local cC38Key		:= ""
Local cC39Key		:= ""
Local cC2AKey		:= ""
Local cC2BKey		:= ""
Local cC2CKey		:= ""
Local cC2DKey		:= ""
Local cC2EKey		:= ""
Local cC2FKey		:= ""
Local cC2GKey		:= ""
Local cC2HKey		:= ""
Local cC2IKey		:= ""
Local cC3FKey		:= ""
Local cC3GKey		:= ""
Local cC3HKey		:= ""
Local cC3AKey		:= ""
Local cC3IKey		:= ""
Local cC6WKey		:= ""
Local cC7BKey		:= ""

Local cT60Key		:= ""

Local cCodigo		:= ""
Local cPeriodo		:= ""
Local cModelo		:= Posicione( "C01", 3, xFilial("C01") + C20->C20_CODMOD, "C01_CODIGO" )
Local nVlrCmp		:= 0
Local nValor		:= 0
Local cCFOP		:= ""
Local cIdModelos	:= ""
Local nCont       := 0
Local cSitDoc		:= ""

Default lJob := .F.

cSitDoc :=	XFUNID2Cd( C20->C20_CODSIT , 'C02' )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C20->( Recno() )

If C20->C20_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C20->C20_CODMOD)
		AADD(aLogErro,{"C20_CODMOD","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	Else

		cCodModelo  := POSICIONE("C01",3, xFilial("C01")+C20->C20_CODMOD ,"C01_CODIGO")

		If cCodModelo $ ( "55|57|65|63|67" ) .AND. Len(AllTrim(C20->C20_SERIE)) <> 3
			AADD(aLogErro,{"C20_SERIE","000687", "C20",nRecno }) //STR0687 - "Para o Modelos de Documento Fiscal com o código igual a 55,56, 57 ou 65 o Número de série se torna obrigatório com apenas três posições para NF-e"
		EndIf
		If cCodModelo $ ( "55|57|65|63|67" ) .AND. Empty(C20->C20_SERIE)
			AADD(aLogErro,{"C20_SERIE","000688", "C20",nRecno }) //STR0688 - "Se não existir Série para NF-e ou NFC-e informar 000."
		EndIf
	EndIf

	If Empty(C20->C20_INDOPE)
		AADD(aLogErro,{"C20_INDOPE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C20->C20_TPDOC)
		AADD(aLogErro,{"C20_TPDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C20->C20_INDEMI)
		AADD(aLogErro,{"C20_INDEMI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio" 
	EndIf

	If cSitDoc <> '05' .AND. Empty(C20->C20_CODPAR)
		AADD(aLogErro,{"C20_CODPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C20->C20_CODSIT)
		AADD(aLogErro,{"C20_CODSIT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C20->C20_NUMDOC)
		AADD(aLogErro,{"C20_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C20->C20_DTDOC)
		AADD(aLogErro,{"C20_DTDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C20->C20_INDPAG)
		AADD(aLogErro,{"C20_INDPAG","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf


	If Empty(C20->C20_INDFRT)
		AADD(aLogErro,{"C20_INDFRT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty(C20->C20_CODMOD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_CODMOD
		xValRegTab("C01",cChave,3,,@aLogErro,, { "C20", "C20_CODMOD", nRecno } )
	EndIf

	If !Empty(C20->C20_TPDOC)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_TPDOC
		xValRegTab("C0U",cChave,3,,@aLogErro,, { "C20", "C20_TPDOC", nRecno })
	EndIf

	If !Empty(C20->C20_CODPAR)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_CODPAR
		xValRegTab("C1H",cChave,5,,@aLogErro,,{ "C20", "C20_CODPAR", nRecno })
	EndIf

	If !Empty(C20->C20_CODSIT)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_CODSIT
		xValRegTab("C02",cChave,3,,@aLogErro,, { "C20", "C20_CODSIT", nRecno } )
	EndIf

	If !Empty(C20->C20_CODCTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_CODCTA
		xValRegTab("C1O",cChave,3,,@aLogErro,,{ "C20", "C20_CODCTA", nRecno })
	EndIf

	If !Empty(C20->C20_INDFRT)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_INDFRT
		xValRegTab("C0X",cChave,3,,@aLogErro,, { "C20", "C20_INDFRT", nRecno })
	EndIf
	
	If !Empty(C20->C20_UF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_UF
		xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C20_UF", nRecno })
	EndIf

	If !Empty(C20->C20_NATFRT)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_NATFRT
		xValRegTab("C3P",cChave,3,,@aLogErro,, { "C20", "C20_NATFRT", nRecno })
	EndIf

	If !Empty(C20->C20_AIDF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C20->C20_AIDF
		xValRegTab("C0T",cChave,1,,@aLogErro,,{ "C20", "C20_AIDF", nRecno })
	EndIf

	//--------
	// Combos
	//--------
	If !C20->C20_INDOPE $ ('0|1')
		AADD(aLogErro,{"C20_INDOPE","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf

	If !C20->C20_INDEMI $ ('0|1')
		AADD(aLogErro,{"C20_INDEMI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf

	If !C20->C20_INDPAG $ ('0|1|2|9')
		AADD(aLogErro,{"C20_INDPAG","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf

	If !C20->C20_TPCTE $ (' |0|1|2|3')
		AADD(aLogErro,{"C20_TPCTE","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf

	//--------------------
	// Regras específicas
	//--------------------
	//Valid Campo C20_VLDOC

	/*CONFORME ORIENTADO PELO GUSTAVO ESSE TIPO DE VALIDACAO NAO PODE OCORRER POIS ENVOLVE REGRA DE
	//NEGOCIO
	If !Empty( C20->C20_VLDOC )

		nValor := ( C20->C20_VLMERC + C20->C20_VLSERV ) - ( C20->C20_VLDESC + C20->C20_VLABNT ) + C20->C20_VLRFRT + C20->C20_VLRSEG + C20->C20_VLRDA + C20->C20_VLOUDE

		nValor  := xFunTAFRnd( nValor )
		nVlrCmp := xFunTAFRnd( C20->C20_VLDOC )

		//condica de validacao: Valor informado deve ser igual ao calculado e nao pode ser negativo
		If ( nVlrCmp <> nValor .or. nValor < 0 ) .and. !TafNfCompl( .T. )
			aAdd( aLogErro, { "C20_VLDOC", "000573", "C20", nRecno } ) //STR0573 - "O valor deve corresponder à soma dos campos 'Vlr Merc', 'Vlr Serviços', 'Vlr Frete', 'Vlr Seguro', 'Vlr Desp' e 'Vlr Out.Desp' subtraindo os campos 'Vlr Desc' e 'Vlr Abat NT'."
		EndIf
	EndIf
	*/

	//--------------------
	//Valid Campo C20_DTEXT
	If AliasInDic("T30") .And. ((cSitDoc $ "|01|03|" .And. Empty(C20->C20_DTEXT)) .Or.	(!cSitDoc $ "|01|03|" .And. !Empty(C20->C20_DTEXT)))
		AADD(aLogErro,{"C20_DTEXT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	C21->( DBSetOrder(1) )
	cC21Key := C20->C20_CHVNF
	If C21->( MsSeek( xFilial("C21") + cC21Key ) )

		Do While !C21->( Eof() ) .And. cC21Key == C21->C21_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C21->C21_CODINF)
				AADD(aLogErro,{"C21_CODINF","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C21->C21_CODINF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C21->C21_CODINF
				xValRegTab("C3Q",cChave,3,,@aLogErro,, { "C20", "C21_CODINF", nRecno } )
			EndIf

			C22->( DBSetOrder(1) )
			cC22Key := C21->C21_CODINF
			If C22->( MsSeek( xFilial("C22") + cC22Key ) )

				Do While !C22->( Eof() ) .And. cC22Key == C22->C22_CODINF

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C22->C22_NUMERO)
						AADD(aLogErro,{"C22_NUMERO","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C22->C22_NUMERO)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C22->C22_NUMERO
						xValRegTab("C1G",cChave,3,,@aLogErro,, { "C20", "C22_NUMERO", nRecno } )
					EndIf

					C22->( DbSkip() )
				EndDo
			EndIf

			C25->( DBSetOrder(1) )
			cC25Key := C21->C21_CODINF
			If C25->( MsSeek( xFilial("C25") + cC25Key ) )

				Do While !C25->( Eof() ) .And. cC25Key == C25->C25_CODINF

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C25->C25_IDENTI)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C25->C25_IDENTI
						xValRegTab("C0R",cChave,3,,@aLogErro,, { "C20", "C25_IDENTI", nRecno } )
					EndIf

					C25->( DbSkip() )
				EndDo
			EndIf

			C26->( DBSetOrder(1) )
			cC26Key := C21->C21_CODINF
			If C26->( MsSeek( xFilial("C26") + cC26Key ) )

				Do While !C26->( Eof() ) .And. cC26Key == C21->(C21_CHVNF + C21_CODINF)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C26->C26_CODMOD)
						AADD(aLogErro,{"C26_CODMOD","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C26->C26_INDOPE)
						AADD(aLogErro,{"C26_INDOPE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C26->C26_INDEMI)
						AADD(aLogErro,{"C26_INDEMI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C26->C26_CODPAR)
						AADD(aLogErro,{"C26_CODPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C26->C26_NUMDOC)
						AADD(aLogErro,{"C26_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C26->C26_DTDOC)
						AADD(aLogErro,{"C26_DTDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C26->C26_CODMOD)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C26->C26_CODMOD
						xValRegTab("C01",cChave,3,,@aLogErro,, { "C20", "C26_CODMOD", nRecno } )
					EndIf

					If !Empty(C26->C26_CODPAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C26->C26_CODPAR
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C26_CODPAR", nRecno })
					EndIf

					//--------
					// Combos
					//--------
					If !C26->C26_INDOPE $ ("0|1")
						aAdd( aLogErro, { "C26_INDOPE", "000006", "C20", nRecno } ) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					If !C26->C26_INDEMI $ ("0|1")
						AADD(aLogErro,{"C26_INDEMI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					//--------
					// Motivo da Referência
					//--------
					If !Empty( C26->C26_CODMOT )
						If !( Alltrim( C26->C26_CODMOT ) $ " 4|11|13|99" )
							aAdd(aLogErro,{"C26_CODMOT","000691","C26",nRecno}) //STR0691 - "Código do Motivo da Referência Inválido"
						EndIf
					EndIF

					C26->( DbSkip() )
				EndDo
			EndIf

			//INICIO C27
			C27->( DBSetOrder(1) )

			cC27Key := C21->C21_CODINF
			If C27->( MsSeek( xFilial("C27") + cC27Key ) )

				Do While !C27->( Eof() ) .And. cC27Key == C27->C27_CODINF

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C27->C27_CODECF)
						AADD(aLogErro,{"C27_CODECF","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C27->C27_CODMOD)
						AADD(aLogErro,{"C27_CODMOD","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C27->C27_NUMDOC)
						AADD(aLogErro,{"C27_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C27->C27_DTDOC)
						AADD(aLogErro,{"C27_DTDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C27->C27_CODECF)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C27->C27_CODECF
						xValRegTab("C0W",cChave,4,,@aLogErro,, { "C20", "C27_CODECF", nRecno } )
					EndIf

					If !Empty(C27->C27_CODMOD)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C27->C27_CODMOD
						xValRegTab("C01",cChave,3,,@aLogErro,,{ "C20", "C27_CODMOD", nRecno })
					EndIf

					C27->( DbSkip() )
				EndDo
			EndIf

			C28->( DBSetOrder(1) )
			cC28Key := C21->C21_CODINF
			If C28->( MsSeek( xFilial("C28") + cC28Key ) )

				Do While !C28->( Eof() ) .And. cC28Key == C28->C28_CODINF

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C28->C28_INDCAR)
						AADD(aLogErro,{"C28_INDCAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C28->C28_PARCOL)
						AADD(aLogErro,{"C28_PARCOL","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C28->C28_PARENT)
						AADD(aLogErro,{"C28_PARENT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C28->C28_INDCAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C28->C28_INDCAR
						xValRegTab("C16",cChave,3,,@aLogErro,, { "C20" , "C28_INDCAR", nRecno } )
					EndIf

					If !Empty(C28->C28_PARCOL)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C28->C28_PARCOL
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C28_PARCOL", nRecno } )
					EndIf

					If !Empty(C28->C28_PARENT)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C28->C28_PARENT
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C28_PARENT", nRecno } )
					EndIf

					C28->( DbSkip() )
				EndDo
			EndIf

			C21->( DbSkip() )
		EndDo
	EndIf

	//INICIO C23
	C23->( DBSetOrder(1) )

	cC23Key := C20->C20_CHVNF
	If C23->( MsSeek( xFilial("C23") + cC23Key ) )

		Do While !C23->( Eof() ) .And. cC23Key == C23->C23_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			/*
			If Empty(C23->C23_TIPO)
				AADD(aLogErro,{"C23_TIPO","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C23->C23_NUMDOC)
				AADD(aLogErro,{"C23_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			*/

			/*NAO PODE VALIDAR POIS TANTO NOTA FISCAL DE SERVICO QUANTO NORMAL USAM A TABELA C23
			If Empty(C23->C23_LES)
				AADD(aLogErro,{"C23_LES","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C23->C23_VLTOT)
				AADD(aLogErro,{"C23_VLTOT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			*/

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C23->C23_UFDES)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C23->C23_UFDES
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C23_UFDES", nRecno })
			EndIf

			//--------
			// Combos
			//--------
			If !C23->C23_TIPO $ (' |0|1')
				AADD(aLogErro,{"C23_TIPO","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C23->C23_LES $ (' |0|1')
				AADD(aLogErro,{"C23_LES","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			C23->( DbSkip() )
		EndDo
	EndIf
	//FIM C23

	//INICIO C24
	C24->( DBSetOrder(1) )

	cC24Key := C20->C20_CHVNF
	If C24->( MsSeek( xFilial("C24") + cC24Key ) )

		Do While !C24->( Eof() ) .And. cC24Key == C24->C24_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C24->C24_INDEMI)
				AADD(aLogErro,{"C24_INDEMI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C24->C24_PAREMI)
				AADD(aLogErro,{"C24_PAREMI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C24->C24_PARTOM)
				AADD(aLogErro,{"C24_PARTOM","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C24->C24_CODMOD)
				AADD(aLogErro,{"C24_CODMOD","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C24->C24_NUMDOC)
				AADD(aLogErro,{"C24_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C24->C24_DTDOC)
				AADD(aLogErro,{"C24_DTDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C24->C24_VALOR)
				AADD(aLogErro,{"C24_VALOR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C24->C24_PAREMI)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C24->C24_PAREMI
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C24_PAREMI", nRecno }  )
			EndIf

			If !Empty(C24->C24_PARTOM)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C24->C24_PARTOM
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C24_PARTOM", nRecno } )
			EndIf

			If !Empty(C24->C24_CODMOD)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C24->C24_CODMOD
				xValRegTab("C01",cChave,3,,@aLogErro,, { "C20", "C24_CODMOD", nRecno } )
			EndIf

			//--------
			// Combos
			//--------
			If !C24->C24_INDEMI $ ('0|1')
				AADD(aLogErro,{"C24_INDEMI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			C24->( DbSkip() )
		EndDo
	EndIf
	//FIM C24

	//INICIO C29
	C29->( DBSetOrder(1) )

	cC29Key := C20->C20_CHVNF
	If C29->( MsSeek( xFilial("C29") + cC29Key ) )

		Do While !C29->( Eof() ) .And. cC29Key == C29->C29_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C29->C29_INDEMI)
				AADD(aLogErro,{"C29_INDEMI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C29->C29_INDTIT)
				AADD(aLogErro,{"C29_INDTIT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C29->C29_NUMTIT)
				AADD(aLogErro,{"C29_NUMTIT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C29->C29_QTDPAR)
				AADD(aLogErro,{"C29_QTDPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C29->C29_VLRTOT)
				AADD(aLogErro,{"C29_VLRTOT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			/* - Demetrio - 20/08/2014 - Retirada a obrigatoriedade do campo.
			If Empty(C29->C29_VLRLIQ)
				AADD(aLogErro,{"C29_VLRLIQ","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf*/

			//--------
			// Combos
			//--------
			If !C29->C29_INDEMI $ ('0|1')
				AADD(aLogErro,{"C29_INDEMI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C29->C29_INDTIT $ ('00|01|02|03|99')
				AADD(aLogErro,{"C29_INDTIT","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			//--------------------
			// Regras específicas
			//--------------------
			//Valid Campo C29_DESCRI
			If C29->C29_INDTIT == "99" .and. Empty( C29->C29_DESCRI )
				aAdd( aLogErro, { "C29_DESCRI", "000010", "C20", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//INICIO C2A
			C2A->( DBSetOrder(1) )

			cC2AKey := C20->C20_CHVNF + C29->(C29_INDEMI + C29_INDTIT + C29_NUMTIT)
			If C2A->( MsSeek( xFilial("C2A") + cC2AKey ) )

				Do While !C2A->( Eof() ) .And. cC2AKey == C2A->(C2A_CHVNF + C2A_INDEMI + C2A_INDTIT + C2A_NUMTIT)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C2A->C2A_NUMPAR)
						AADD(aLogErro,{"C2A_NUMPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C2A->C2A_VECTO)
						AADD(aLogErro,{"C2A_VECTO","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C2A->C2A_VLRPAR)
						AADD(aLogErro,{"C2A_VLRPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//--------
					// Combos
					//--------
					If !C2A->C2A_INDEMI $ (' |0|1')
						AADD(aLogErro,{"C2A_INDEMI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					If !C2A->C2A_INDTIT $ (' |00|01|02|03|99')
						AADD(aLogErro,{"C2A_INDTIT","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					C2A->( DbSkip() )
				EndDo
			EndIf
			//FIM C2A

			C29->( DbSkip() )
		EndDo
	EndIf
	//FIM C29
	
	If TAFAlsInDic( "T60" )
		T60->( DBSetOrder(1) )
		
		cT60Key := C20->C20_CHVNF
		If T60->( MsSeek( xFilial("T60") + cT60Key ) )
	
			Do While !T60->( Eof() ) .And. cT60Key == C20->C20_CHVNF
	
				//---------------------
				// Campos obrigatórios
				//---------------------
				If Empty(T60->T60_NUMDOC)
					AADD(aLogErro,{"T60_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
	
				If Empty(T60->T60_SERIE)
					AADD(aLogErro,{"T60_SERIE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
	
				If Empty(T60->T60_CODPAR)
					AADD(aLogErro,{"T60_CODPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
				
				//------------------
				// Consultas padrão
				//------------------
				If !Empty(T60->T60_CODPAR)
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := T60->T60_CODPAR
					xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "T60_CODPAR", nRecno })
				EndIf
	
				T60->( DbSkip() )
			EndDo
		EndIf
	EndIf
	
	//INICIO C30
	C30->( DBSetOrder(1) )

	cC30Key := C20->C20_CHVNF
	If C30->( MsSeek( xFilial("C30") + cC30Key ) )

		Do While !C30->( Eof() ) .And. cC30Key == C30->C30_CHVNF
			nCont++
			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C30->C30_NUMITE)
				AADD(aLogErro,{"C30_NUMITE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C30->C30_CODITE)
				AADD(aLogErro,{"C30_CODITE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C30->C30_UM)
				AADD(aLogErro,{"C30_UM","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C30->C30_ORIGEM)
				AADD(aLogErro,{"C30_ORIGEM","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C30->C30_VLRITE)
				AADD(aLogErro,{"C30_VLRITE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C30->C30_TOTAL)
				AADD(aLogErro,{"C30_TOTAL","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C30->C30_CFOP)
				AADD(aLogErro,{"C30_CFOP","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			// Demetrio - 20/08/2014 -
			// Realizado o tratamento somente para notas modelo 01;1B;04 e 55
			cIdModelos := 		AllTrim(XFUNCh2ID( "01" , 'C01' ))
			cIdModelos += "|" + 	AllTrim(XFUNCh2ID( "1B" , 'C01' ))
			cIdModelos += "|" + 	AllTrim(XFUNCh2ID( "04" , 'C01' ))
			cIdModelos += "|" + 	AllTrim(XFUNCh2ID( "55" , 'C01' ))

			If Empty(C30->C30_INDMOV) .AND. (C20->C20_CODMOD)$cIdModelos
				AADD(aLogErro,{"C30_INDMOV","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C30->C30_CODITE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_CODITE
				xValRegTab("C1L",cChave,3,,@aLogErro,, { "C20", "C30_CODITE",  nRecno } )
			EndIf

			If !Empty(C30->C30_UM)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_UM
				xValRegTab("C1J",cChave,3,,@aLogErro,, { "C20", "C30_UM", nRecno } )
			EndIf

			If !Empty(C30->C30_ORIGEM)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_ORIGEM
				xValRegTab("C03",cChave,3,,@aLogErro,, { "C20", "C30_ORIGEM", nRecno } )
			EndIf

			If !Empty(C30->C30_CFOP)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C20", "C30_CFOP", nRecno } )
			EndIf

			If !Empty(C30->C30_CODSER)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_CODSER
				xValRegTab("C0B",cChave,3,,@aLogErro,, { "C20", "C30_CODSER", nRecno } )
			EndIf

			If !Empty(C30->C30_NATOPE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_NATOPE
				xValRegTab("C1N",cChave,3,,@aLogErro,, { "C20", "C30_NATOPE", nRecno } )
			EndIf

			If !Empty(C30->C30_SELO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_SELO
				xValRegTab("C3U",cChave,3,,@aLogErro,, { "C20", "C30_SELO", nRecno } )
			EndIf

			If !Empty(C30->C30_CLENQ)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_CLENQ
				xValRegTab("C3T",cChave,3,,@aLogErro,, {"C20", "C30_CLENQ", nRecno } )
			EndIf

			If !Empty(C30->C30_NATBCC)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_NATBCC
				xValRegTab("C11",cChave,3,,@aLogErro,, { "C20", "C30_NATBCC", nRecno } )
			EndIf

			If !Empty(C30->C30_CTACTB)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_CTACTB
				xValRegTab("C1O",cChave,3,,@aLogErro,, { "C20", "C30_CTACTB", nRecno } )
			EndIf

			If !Empty(C30->C30_CCUSTO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C30->C30_CCUSTO
				xValRegTab("C1P",cChave,3,,@aLogErro,, { "C20", "C30_CCUSTO", nRecno } )
			EndIf

			//--------
			// Combos
			//--------
			If !C30->C30_INDMOV $ ('0|1')
				AADD(aLogErro,{"C30_INDMOV","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C30->C30_ESTOQ $ (' |1|2|3')
				AADD(aLogErro,{"C30_ESTOQ","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C30->C30_NATREC $ (' |0|1')
				AADD(aLogErro,{"C30_NATREC","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C30->C30_ORICRE $ (' |0|1')
				AADD(aLogErro,{"C30_ORICRE","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C30->C30_INDAPU $ (' |0|1')
				AADD(aLogErro,{"C30_INDAPU","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf


			If !Empty(C30->C30_CSOSN) .AND. !C30->C30_CSOSN $ ('|101|102|103|201|202|203|300|400|500|900')
				AADD(aLogErro,{"C30_CSOSN","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			//--------------------
			// Regras específicas
			//--------------------
			// Validação do campo C30_TOTAL
			If !Empty(C30->C30_VLRITE) .And. !Empty(C30->C30_VLDESC)
				If TafNfCompl( .T. )
					nValor := C30->(C30_VLRITE - C30_VLDESC)
				Else
					nValor := C30->((C30_QUANT * C30_VLRITE) - C30_VLDESC)
				EndIf

				If !(C30->C30_TOTAL == nValor)
					AADD(aLogErro,{"C30_TOTAL","000580", "C20",nRecno }) //STR0580 - "O valor deve corresponder à subtração do campo 'Vlr. Item' menos 'Vlr. Desc.'."
				EndIf
			EndIf

			// Validação do campo C30_CFOP
			If !Empty(C30->C30_CFOP)
				cCFOP := Left(Posicione("C0Y",3,xFilial("C0Y") + C30->C30_CFOP,"C0Y_CODIGO"),1)

				If ((C20->C20_INDOPE == '0') .And. !(cCFOP $ '123')) .Or. ((C20->C20_INDOPE == '1') .And. !(cCFOP $ '567'))
					AADD(aLogErro,{"C30_CFOP","000581", "C20",nRecno }) //STR0581 - "O código do CFOP informado deve inciar por 1,2 ou 3 quando se tratar de Documentos Fiscais Recebidos (Entrada) ou 5,6 e 7 quando se tratar de Documentos Fiscais Emitidos (Saída)."
				EndIf
			EndIf

			//INICIO C31
			C31->( DBSetOrder(1) )

			cC31Key := C30->(C30_NUMITE+C30_CODITE)
			If C31->( MsSeek( xFilial("C31") + cC31Key ) )

				Do While !C31->( Eof() ) .And. cC31Key == C31->(C31_NUMITE+C31_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C31->C31_LOTE)
						AADD(aLogErro,{"C31_LOTE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C31->C31_QUANT)
						AADD(aLogErro,{"C31_QUANT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C31->C31_DTFAB)
						AADD(aLogErro,{"C31_DTFAB","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C31->C31_DTVAL)
						AADD(aLogErro,{"C31_DTVAL","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C31->C31_INDMED)
						AADD(aLogErro,{"C31_INDMED","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C31->C31_TPPROD)
						AADD(aLogErro,{"C31_TPPROD","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C31->C31_VLTBMX)
						AADD(aLogErro,{"C31_VLTBMX","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//--------
					// Combos
					//--------
					If !C31->C31_INDMED $ ('0|1|2|3|4')
						AADD(aLogErro,{"C31_INDMED","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					If !C31->C31_TPPROD $ ('0|1|2|3|4')
						AADD(aLogErro,{"C31_TPPROD","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					//--------------------
					// Regras específicas
					//--------------------
					If C31->C31_VLTBMX <= 0
						AADD(aLogErro,{"C31_VLTBMX","000520", "C20",nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
					EndIf

					C31->( DbSkip() )
				EndDo
			EndIf
			//FIM C31

			//INICIO C32
			C32->( DBSetOrder(1) )

			cC32Key := C30->(C30_NUMITE+C30_CODITE)
			If C32->( MsSeek( xFilial("C32") + cC32Key ) )

				Do While !C32->( Eof() ) .And. cC32Key == C32->(C32_NUMITE+C32_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C32->C32_CCLASS)
						AADD(aLogErro,{"C32_CCLASS","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C32->C32_INDREC)
						AADD(aLogErro,{"C32_INDREC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C32->C32_CONS)
						AADD(aLogErro,{"C32_CONS","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					/*
					If Empty(C32->C32_CODPAR)
						AADD(aLogErro,{"C32_CODPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf
					*/

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C32->C32_CCLASS)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C32->C32_CCLASS
						xValRegTab("C0K",cChave,4,,@aLogErro,, { "C20","C32_CCLASS", nRecno } )
					EndIf

					If !Empty(C32->C32_CODPAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C32->C32_CODPAR
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20","C32_CODPAR", nRecno })
					EndIf

					//--------
					// Combos
					//--------
					If !C32->C32_INDREC $ ('0|1')
						AADD(aLogErro,{"C32_INDREC","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					C32->( DbSkip() )
				EndDo
			EndIf
			//FIM C32

			//INICIO C33
			C33->( DBSetOrder(1) )

			cC33Key := C30->(C30_NUMITE+C30_CODITE)
			If C33->( MsSeek( xFilial("C33") + cC33Key ) )

				Do While !C33->( Eof() ) .And. cC33Key == C33->(C33_NUMITE+C33_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C33->C33_INDARM)
						AADD(aLogErro,{"C33_INDARM","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C33->C33_NUMARM)
						AADD(aLogErro,{"C33_NUMARM","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C33->C33_DESCRI)
						AADD(aLogErro,{"C33_DESCRI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//--------
					// Combos
					//--------
					If !C33->C33_INDARM $ ('0|1')
						AADD(aLogErro,{"C33_INDARM","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					C33->( DbSkip() )
				EndDo
			EndIf
			//FIM C33

			//INICIO C34
			C34->( DBSetOrder(1) )

			cC34Key := C30->(C30_NUMITE+C30_CODITE)
			If C34->( MsSeek( xFilial("C34") + cC34Key ) )

				Do While !C34->( Eof() ) .And. cC34Key == C34->(C34_NUMITE+C34_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C34->C34_INDVEI)
						AADD(aLogErro,{"C34_INDVEI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C34->C34_CHASSI)
						AADD(aLogErro,{"C34_CHASSI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C34->C34_UF)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C34->C34_UF
						xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C34_UF", nRecno } )
					EndIf

					If !Empty(C34->C34_CODCOR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C34->C34_CODCOR
						xValRegTab("CEL",cChave,1,,@aLogErro,, { "C20", "C34_CODCOR", nRecno })
					EndIf

					If !Empty(C34->C34_TPCOMB)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C34->C34_TPCOMB
						xValRegTab("CAX",cChave,1,,@aLogErro,,{ "C20", "C34_TPCOMB", nRecno })
					EndIf

					If !Empty(C34->C34_ESPVEI)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C34->C34_ESPVEI
						xValRegTab("CAK",cChave,1,,@aLogErro,,{ "C20", "C34_ESPVEI", nRecno })
					EndIf

					If !Empty(C34->C34_CORDEN)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C34->C34_CORDEN
						xValRegTab("CAL",cChave,1,,@aLogErro,,{ "C20", "C34_CORDEN", nRecno })
					EndIf

					//--------
					// Combos
					//--------
					If !C34->C34_INDVEI $ ('0|1|2|3|9')
						AADD(aLogErro,{"C34_INDVEI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					If !C34->C34_TPPINT $ (' |1|2')
						AADD(aLogErro,{"C34_TPPINT","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					If !C34->C34_CONVIN $ (' |R|N')
						AADD(aLogErro,{"C34_CONVIN","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					If !C34->C34_CONVEI $ (' |1|2|3')
						AADD(aLogErro,{"C34_CONVEI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					//--------------------
					// Regras específicas
					//--------------------
					If (C34->C43_INDVEI == "1") .And. Empty(C43->C43_CNPJ)
						AADD(aLogErro,{"C34_CNPJ", "000010", "C20", nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//Valido o campo de CNPJ, passando o terceiro parametro da funcao CGC como .F.
					//Para que nao seja apresentado o alert de validacao
					If !Empty(C34->C34_CNPJ)
						If !CGC(C34->C34_CNPJ,,.F.)
							AADD(aLogErro,{"C34_CNPJ", "000005", "C20", nRecno }) //STR0005 - "CPF/CNPJ Inconsistente"
						EndIf
					EndIf

					C34->( DbSkip() )
				EndDo
			EndIf
			//FIM C34

			//INICIO C35
			C35->( DBSetOrder(1) )

			cC35Key := C30->(C30_NUMITE+C30_CODITE)
			If C35->( MsSeek( xFilial("C35") + cC35Key ) )

				Do While !C35->( Eof() ) .And. cC35Key == C35->(C35_NUMITE+C35_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C35->C35_CODTRI)
						AADD(aLogErro,{"C35_CODTRI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C35->C35_CODTRI)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C35->C35_CODTRI
						xValRegTab("C3S",cChave,3,,@aLogErro,, { "C20", "C35_CODTRI", nRecno } )
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If AliasInDic("CWZ")
						If !Empty(C35->C35_IDMINC)
							cChave := C35->C35_IDMINC
							xValRegTab("CWZ",cChave,1,,@aLogErro,, { "C20", "C35_IDMINC", nRecno } )
						EndIf
					EndIf

					//--------
					// Combos
					//--------
					If !C35->C35_CODANT $ (' |1|2|3|4|5|6')
						AADD(aLogErro,{"C35_CODANT","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					//--------------------
					// Regras específicas
					//--------------------
					//Valid Campo C35_CST
					If !Empty( C35->C35_CST )
						cChave := C35->C35_CST

						If !C35->C35_CODTRI $ "000001/000002/000003/000004/000005/000006/000007/000008/000009/000010/000011/000014/000015/000016/000017/000026"
							aAdd( aLogErro, { "C35_CST", "000576", "C20", nRecno } ) //STR0576 - "O Código de Situação Tributária (CST) somente é necessária para os tributos ICMS, IPI, ISS, PIS/Pasep e/ou Cofins. Se não for o caso, deixá-lo em branco."
						ElseIf C35->C35_CODTRI $ "000001/000016"
							//Chave de busca na tabela FILHO ou Consulta padrao
							xValRegTab( "C0H", cChave, 3,, @aLogErro,, { "C20", "C35_CST", nRecno } )
						ElseIf C35->C35_CODTRI $ "000002/000003/000004/000017/000026"
							//Chave de busca na tabela FILHO ou Consulta padrao
							xValRegTab( "C14", cChave, 3,, @aLogErro,, { "C20", "C35_CST", nRecno } )
						ElseIf C35->C35_CODTRI $ "000005"
							//Chave de busca na tabela FILHO ou Consulta padrao
							xValRegTab( "C15", cChave, 3,, @aLogErro,, { "C20", "C35_CST", nRecno } )
						ElseIf C35->C35_CODTRI $ "000006/000008/000010/000014/000007/000009/000011/000015"
							//Chave de busca na tabela FILHO ou Consulta padrao
							xValRegTab( "C17", cChave, 3,, @aLogErro,,{ "C20", "C35_CST", nRecno } )
						EndIf
					EndIf

					//Valid Campo C35_MODBC
					If !Empty( C35->C35_MODBC )
						cChave := C35->C35_MODBC

						If !C35->C35_CODTRI $ "000002/000003/000004/000017/000026"
							aAdd( aLogErro, { "C35_MODBC", "000582", "C20", nRecno } ) //STR0582 - "A Modalidade de determinação da Base de Calculo somente é necessária para o ICMS. Se não for o caso, deixar em branco."
						ElseIf C35->C35_CODTRI $ "000002/000003/000017/000026"
							//Chave de busca na tabela FILHO ou Consulta padrao
							xValRegTab( "C04", cChave, 3,, @aLogErro,, { "C20", "C35_MODBC", nRecno } )
						ElseIf C35->C35_CODTRI $ "000004"
							//Chave de busca na tabela FILHO ou Consulta padrao
							xValRegTab( "C05", cChave, 3,, @aLogErro,,{ "C20", "C35_MODBC", nRecno })
						EndIf
					EndIf

					C35->( DbSkip() )
				EndDo
			EndIf
			//FIM C35

			//INICIO C36
			C36->( DBSetOrder(1) )

			cC36Key := C30->(C30_NUMITE+C30_CODITE)
			If C36->( MsSeek( xFilial("C36") + cC36Key ) )

				Do While !C36->( Eof() ) .And. cC36Key == C36->(C36_NUMITE+C36_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C36->C36_NUMTAN)
						AADD(aLogErro,{"C36_NUMTAN","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C36->C36_QUANT)
						AADD(aLogErro,{"C36_QUANT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C36->C36_UFCONS)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C36->C36_UFCONS
						xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C36_UFCONS", nRecno } )
					EndIf

					C36->( DbSkip() )
				EndDo
			EndIf
			//FIM C36

			//INICIO C37
			C37->( DBSetOrder(1) )

			cC37Key := C30->(C30_NUMITE+C30_CODITE)
			If C37->( MsSeek( xFilial("C37") + cC37Key ) )

				Do While !C37->( Eof() ) .And. cC37Key == C37->(C37_NUMITE+C37_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C37->C37_CODMOD)
						AADD(aLogErro,{"C37_CODMOD","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C37->C37_NUMDOC)
						AADD(aLogErro,{"C37_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C37->C37_DTDOC)
						AADD(aLogErro,{"C37_DTDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C37->C37_CODPAR)
						AADD(aLogErro,{"C37_CODPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C37->C37_QUANT)
						AADD(aLogErro,{"C37_QUANT","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C37->C37_VLITEM)
						AADD(aLogErro,{"C37_VLITEM","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C37->C37_VLBCST)
						AADD(aLogErro,{"C37_VLBCST","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C37->C37_CODMOD)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C37->C37_CODMOD
						xValRegTab("C01",cChave,3,,@aLogErro,, { "C20", "C37_CODMOD", nRecno } )
					EndIf

					If !Empty(C37->C37_CODPAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C37->C37_CODPAR
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C37_CODPAR", nRecno } )
					EndIf

					//--------------------
					// Regras específicas
					//--------------------
					If C37->C37_NUMDOC <= 0
						AADD(aLogErro,{"C37_NUMDOC","000520", "C20",nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
					EndIf

					C37->( DbSkip() )
				EndDo
			EndIf
			//FIM C37

			//INICIO C38
			C38->( DBSetOrder(1) )

			cC38Key := C30->(C30_NUMITE+C30_CODITE)
			If C38->( MsSeek( xFilial("C38") + cC38Key ) )

				Do While !C38->( Eof() ) .And. cC38Key == C38->(C38_NUMITE+C38_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C38->C38_CCLASS)
						AADD(aLogErro,{"C38_CCLASS","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C38->C38_CODPAR)
						AADD(aLogErro,{"C38_CODPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C38->C38_INDREC)
						AADD(aLogErro,{"C38_INDREC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C38->C38_CCLASS)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C38->C38_CCLASS
						xValRegTab("C0K",cChave,4,,@aLogErro,, { "C20", "C38_CCLASS", nRecno } )
					EndIf

					If !Empty(C38->C38_CODPAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C38->C38_CODPAR
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C38_CODPAR", nRecno } )
					EndIf

					//--------
					// Combos
					//--------
					If !C38->C38_INDREC $ ('0|1|2|3|4|5|9')
						AADD(aLogErro,{"C38_INDREC","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf

					C38->( DbSkip() )
				EndDo
			EndIf
			//FIM C38

			//INICIO C39
			C39->( DBSetOrder(1) )

			cC39Key := C30->(C30_NUMITE+C30_CODITE)
			If C39->( MsSeek( xFilial("C39") + cC39Key ) )

				Do While !C39->( Eof() ) .And. cC39Key == C39->(C39_NUMITE+C39_CODITE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C39->C39_UFORIG)
						AADD(aLogErro,{"C39_UFORIG","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C39->C39_CMUNOR)
						AADD(aLogErro,{"C39_CMUNOR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C39->C39_UFDEST)
						AADD(aLogErro,{"C39_UFDEST","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C39->C39_CMUNDE)
						AADD(aLogErro,{"C39_CMUNDE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C39->C39_UFORIG)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C39->C39_UFORIG
						xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C39_UFORIG", nRecno } )
					EndIf

					If !Empty(C39->C39_CMUNOR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C39->C39_CMUNOR
						xValRegTab("C07",cChave,4,,@aLogErro,, { "C20", "C39_CMUNOR", nRecno })
					EndIf

					If !Empty(C39->C39_UFDEST)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C39->C39_UFDEST
						xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C39_UFDEST", nRecno })
					EndIf

					If !Empty(C39->C39_CMUNDE)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C39->C39_CMUNDE
						xValRegTab("C07",cChave,4,,@aLogErro,, { "C20", "C39_CMUNDE", nRecno })
					EndIf

					If !Empty(C39->C39_CODVEI)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C39->C39_CODVEI
						xValRegTab("C0Q",cChave,4,,@aLogErro,,{ "C20", "C39_CODVEI", nRecno })
					EndIf

					C39->( DbSkip() )
				EndDo
			EndIf
			//FIM C39

			C30->( DbSkip() )
		EndDo
	EndIf
	//FIM C30

	//INICIO C2B
	C2B->( DBSetOrder(1) )

	cC2BKey := C20->C20_CHVNF
	If C2B->( MsSeek( xFilial("C2B") + cC2BKey ) )

		Do While !C2B->( Eof() ) .And. cC2BKey == C2B->C2B_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			/*
			If Empty(C2B->C2B_CODPAR)
				AADD(aLogErro,{"C2B_CODPAR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			*/

			If Empty(C2B->C2B_CODVEI)
				AADD(aLogErro,{"C2B_CODVEI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C2B->C2B_HORA)
				AADD(aLogErro,{"C2B_HORA","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C2B->C2B_QTDVOL)
				AADD(aLogErro,{"C2B_QTDVOL","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C2B->C2B_CODPAR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2B->C2B_CODPAR
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C2B_CODPAR", nRecno } )
			EndIf

			If !Empty(C2B->C2B_CODVEI)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2B->C2B_CODVEI
				xValRegTab("C0Q",cChave,4,,@aLogErro,, { "C20", "C2B_CODVEI", nRecno } )
			EndIf

			//--------------------
			// Regras específicas
			//--------------------
			//Valido o campo de CPF, passando o terceiro parametro da funcao CGC como .F.
			//Para que nao seja apresentado o alert de validacao
			If !Empty(C2B->C2B_CPF)
				If !CGC(C2B->C2B_CPF,,.F.)
					AADD(aLogErro,{"C2B_CPF", "000005", "C20", nRecno }) //STR0005 - "CPF/CNPJ Inconsistente"
				EndIf
			EndIf

			C2B->( DbSkip() )
		EndDo
	EndIf
	//FIM C2B

	//Proteção caso não tenha sido aplicado o dicionario 007859 TSI
	If lAtu == .F.
		//INICIO C2C
		C2C->( DBSetOrder(1) )

		cC2CKey := C20->C20_CHVNF
		If C2C->( MsSeek( xFilial("C2C") + cC2CKey ) )

			Do While !C2C->( Eof() ) .And. cC2CKey == C2C->C2C_CHVNF

				//---------------------
				// Campos obrigatórios
				//---------------------
				If Empty(C2C->C2C_CODOBS)
					AADD(aLogErro,{"C2C_CODOBS","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf

				//------------------
				// Consultas padrão
				//------------------
				If !Empty(C2C->C2C_CODOBS)
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2C->C2C_CODOBS
					xValRegTab("C3R",cChave,3,,@aLogErro,, { "C20", "C2C_CODOBS", nRecno } )
				EndIf

				//INICIO C2D
				C2D->( DBSetOrder(1) )

				cC2DKey := C20->C20_CHVNF + C2C->C2C_CODOBS
				If C2D->( MsSeek( xFilial("C2D") + cC2DKey ) )

					Do While !C2D->( Eof() ) .And. cC2DKey == C2D->(C2D_CHVNF + C2D_CODOBS)

						//---------------------
						// Campos obrigatórios
						//---------------------
						If Empty(C2D->C2D_CODAJ)
							AADD(aLogErro,{"C2D_CODAJ","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
						EndIf

						If Empty(C2D->C2D_CODITE)
							AADD(aLogErro,{"C2D_CODITE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
						EndIf

						//------------------
						// Consultas padrão
						//------------------
						If !Empty(C2D->C2D_CODAJ)
							//Chave de busca na tabela FILHO ou Consulta padrao
							cChave := C2D->C2D_CODAJ
							xValRegTab("C0J",cChave,3,,@aLogErro,, { "C20", "C2D_CODAJ", nRecno } )
						EndIf

						If !Empty(C2D->C2D_CODITE)
							//Chave de busca na tabela FILHO ou Consulta padrao
							cChave := C2D->C2D_CODITE
							xValRegTab("C1L",cChave,3,,@aLogErro,, { "C20", "C2D_CODITE", nRecno } )
						EndIf

						//--------------------
						// Regras específicas
						//--------------------
						//Valid Campo C2D_VLICM
						If !Empty( C2D->C2D_VLICM )
							nValor := C2D->C2D_BSICM * C2D->C2D_ALQICM / 100

							nValor  := xFunTAFRnd( nValor )
							nVlrCmp := xFunTAFRnd( C2D->C2D_VLICM )

							//condica de validacao: Valor informado deve ser igual ao calculado e nao pode ser negativo
							If ( nVlrCmp <> nValor .or. nValor < 0 ) .and. !TafNfCompl( .T. )
								aAdd( aLogErro, { "C2D_VLICM", "000574", "C20", nRecno } ) //STR0574 - "O valor deve corresponder ao percentual de 'Alq ICMS' aplicado em 'Bs ICMS'."
							EndIf
						EndIf

						C2D->( DbSkip() )
					EndDo
				EndIf
				//FIM C2D

				C2C->( DbSkip() )
			EndDo
		EndIf
		//FIM C2C
	Else
		//INICIO C2D
		C2D->( DBSetOrder(1) )

		cC2DKey := C20->C20_CHVNF
		If C2D->( MsSeek( xFilial("C2D") + cC2DKey ) )

			Do While !C2D->( Eof() ) .And. cC2DKey == C2D->C2D_CHVNF

				//---------------------
				// Campos obrigatórios
				//---------------------
				If Empty(C2D->C2D_CODAJ)
					AADD(aLogErro,{"C2D_CODAJ","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf

				If Empty(C2D->C2D_CODITE)
					AADD(aLogErro,{"C2D_CODITE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf

				//------------------
				// Consultas padrão
				//------------------
				If !Empty(C2D->C2D_CODAJ)
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2D->C2D_CODAJ
					xValRegTab("C0J",cChave,3,,@aLogErro,, { "C20", "C2D_CODAJ", nRecno } )
				EndIf

				If !Empty(C2D->C2D_CODITE)
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2D->C2D_CODITE
					xValRegTab("C1L",cChave,3,,@aLogErro,, { "C20", "C2D_CODITE", nRecno } )
				EndIf

				//--------------------
				// Regras específicas
				//--------------------
				//Valid Campo C2D_VLICM
				If !Empty( C2D->C2D_VLICM )
					nValor := C2D->C2D_BSICM * C2D->C2D_ALQICM / 100
					nValor  := xFunTAFRnd( nValor )
					nVlrCmp := xFunTAFRnd( C2D->C2D_VLICM )

					//condica de validacao: Valor informado deve ser igual ao calculado e nao pode ser negativo
					If ( nVlrCmp <> nValor .or. nValor < 0 ) .and. !TafNfCompl( .T. )
						aAdd( aLogErro, { "C2D_VLICM", "000574", "C20", nRecno } ) //STR0574 - "O valor deve corresponder ao percentual de 'Alq ICMS' aplicado em 'Bs ICMS'."
					EndIf
				EndIf

				C2D->( DbSkip() )
			EndDo
		EndIf
		
		//FIM C2D
	EndIf

	//INICIO C2E
	C2E->( DBSetOrder(1) )

	cC2EKey := C20->C20_CHVNF
	If C2E->( MsSeek( xFilial("C2E") + cC2EKey ) )

		Do While !C2E->( Eof() ) .And. cC2EKey == C2E->C2E_CHVNF

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C2E->C2E_GRPTEN)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2E->C2E_GRPTEN
				xValRegTab("C0N",cChave,3,,@aLogErro,, { "C20", "C2E_GRPTEN", nRecno } )
			EndIf

			//--------
			// Combos
			//--------
			If !C2E->C2E_TPLIG $ (' |1|2|3')
				AADD(aLogErro,{"C2E_TPLIG","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			//--------------------
			// Regras específicas
			//--------------------
			//Valid Campo C2E_CODCON
			If !Empty( C2E->C2E_CODCON )
				If !cModelo $ "06/28/29"
					aAdd( aLogErro, { "C2E_CODCON", "000575", "C20", nRecno } ) //STR0575 - "O Código da Classe de Consumo informado somente é válido para documentos fiscais com modelo de emissão 06, 28 ou 29. Caso contrário, deixar em branco."
				ElseIf cModelo $ "06/28"
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2E->C2E_CODCON
					xValRegTab( "C0L", cChave, 3,, @aLogErro,, { "C20", "C2E_CODCON", nRecno } )
				ElseIf cModelo $ "29"
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2E->C2E_CODCON
					xValRegTab( "C0O", cChave, 3,, @aLogErro,, { "C20", "C2E_CODCON", nRecno }  )
				EndIf
			EndIf

			//Valid TP_LIGACAO/COD_GRUPO_TENSAO
			If cModelo == "06" .and. C20->C20_INDOPE == "1"
				If Empty( C2E->C2E_TPLIG )
					aAdd( aLogErro, { "C2E_TPLIG", "000010", "C20", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf

				If Empty( C2E->C2E_GRPTEN )
					aAdd( aLogErro, { "C2E_GRPTEN", "000010", "C20", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
			EndIf

			C2E->( DbSkip() )
		EndDo
	EndIf
	//FIM C2E

	//INICIO C2F
	C2F->( DBSetOrder(1) )

	cC2FKey := C20->C20_CHVNF
	If C2F->( MsSeek( xFilial("C2F") + cC2FKey ) )

		Do While !C2F->( Eof() ) .And. cC2FKey == C2F->C2F_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C2F->C2F_CODTRI)
				AADD(aLogErro,{"C2F_CODTRI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C2F->C2F_CODTRI)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2F->C2F_CODTRI
				xValRegTab("C3S",cChave,3,,@aLogErro,, { "C20", "C2F_CODTRI", nRecno } )
			EndIf

			If !Empty(C2F->C2F_CFOP)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2F->C2F_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C20", "C2F_CFOP", nRecno })
			EndIf

			If !Empty(C2F->C2F_CODSER)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2F->C2F_CODSER
				xValRegTab("C0B",cChave,3,,@aLogErro,, { "C20", "C2F_CODSER", nRecno })
			EndIf

			//--------------------
			// Regras específicas
			//--------------------
			//Valid Campo C2F_CST
			If !Empty( C2F->C2F_CST )
				//Tratamento para apresentar help para os tributos que nao precisam do CST
				If !C2F->C2F_CODTRI $ "000001/000002/000003/000004/000005/000006/000007/000008/000009/000010/000011/000014/000015/000016/000017"
					aAdd( aLogErro, { "C2F_CST", "000576", "C20", nRecno } ) //STR0576 - "O Código de Situação Tributária (CST) somente é necessária para os tributos ICMS, IPI, ISS, PIS/Pasep e/ou Cofins. Se não for o caso, deixá-lo em branco."
				//ISSQN
				ElseIf C2F->C2F_CODTRI $ "000001/000016"
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2F->C2F_CST
					xValRegTab( "C0H", cChave, 3,, @aLogErro,, { "C20", "C2F_CST", nRecno } )
				//ICMS e ICMS/ST
				ElseIf C2F->C2F_CODTRI $ "000002/000003/000004/000017/000026"
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2F->C2F_CST
					xValRegTab( "C14", cChave, 3,, @aLogErro,,{ "C20", "C2F_CST", nRecno } )
				//IPI
				ElseIf C2F->C2F_CODTRI $ "000005"
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2F->C2F_CST
					xValRegTab( "C15", cChave, 3,, @aLogErro,,{ "C20", "C2F_CST", nRecno } )
				//PIS/Pasep/Cofins
				ElseIf C2F->C2F_CODTRI $ "000006/000008/000010/000014/000007/000009/000011/000015"
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C2F->C2F_CST
					xValRegTab( "C17", cChave, 3,, @aLogErro,,{ "C20", "C2F_CST", nRecno } )
				EndIf
			EndIf

			//Valid Campo C2F_CFOP
			If !Empty( C2F->C2F_CFOP )
				If Empty( cCodigo := xFunID2Cd( C2F->C2F_CFOP, "C0Y" ) )
					cCodigo := C2F->C2F_CFOP
				EndIf

				cCodigo := Left( cCodigo, 1 )

				If C20->C20_INDOPE == "0" .and. !cCodigo $ "123"
					aAdd( aLogErro, { "C2F_CFOP", "000577", "C20", nRecno } ) //STR0577 - "CFOP incorreto ao tipo de documento(Deve ser 123 para Entrada ou 567 para Saida)."
				ElseIf C20->C20_INDOPE == "1" .and. !cCodigo $ "567"
					aAdd( aLogErro, { "C2F_CFOP", "000577", "C20", nRecno } ) //STR0577 - "CFOP incorreto ao tipo de documento(Deve ser 123 para Entrada ou 567 para Saida)."
				EndIf
			EndIf

			C2F->( DbSkip() )
		EndDo
	EndIf
	//FIM C2F

	//INICIO C2G
	C2G->( DBSetOrder(1) )

	cC2GKey := C20->C20_CHVNF
	If C2G->( MsSeek( xFilial("C2G") + cC2GKey ) )

		Do While !C2G->( Eof() ) .And. cC2GKey == C2G->C2G_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			/*
			If Empty(C2G->C2G_INDSER)
				AADD(aLogErro,{"C2G_INDSER","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C2G->C2G_DTINI)
				AADD(aLogErro,{"C2G_DTINI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C2G->C2G_DTFIM)
				AADD(aLogErro,{"C2G_DTFIM","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			*/
			If Empty(C2G->C2G_PERFIS)
				AADD(aLogErro,{"C2G_PERFIS","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C2G->C2G_TPASSI)
				AADD(aLogErro,{"C2G_TPASSI","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C2G->C2G_INDREC)
				AADD(aLogErro,{"C2G_INDREC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C2G->C2G_INDREC)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2G->C2G_INDREC
				xValRegTab("C10",cChave,3,,@aLogErro,, {"C20", "C2G_INDREC", nRecno } )
			EndIf

			If !Empty(C2G->C2G_CCONS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2G->C2G_CCONS
				xValRegTab("C0M",cChave,3,,@aLogErro,, {"C20", "C2G_CCONS", nRecno })
			EndIf

			//--------
			// Combos
			//--------
			If !C2G->C2G_INDSER $ ('0|1|2|3|4|9')
				AADD(aLogErro,{"C2G_INDSER","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C2G->C2G_TPASSI $ ('1|2|3|4|5|6')
				AADD(aLogErro,{"C2G_TPASSI","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			//--------------------
			// Regras específicas
			//--------------------
			//Valid Campos C2G_DTINI/C2G_DTFIM
			If C2G->C2G_DTINI > C2G->C2G_DTFIM
				aAdd( aLogErro, { "C2G_DTINI", "000578", "C20", nRecno } ) //STR0578 - "Data inicial deve ser menor que Data final."
			EndIf

			//Valid Campo C2G_PERFIS
			If !Empty( C2G->C2G_PERFIS )
				cPeriodo := Right( C2G->C2G_PERFIS, 4 ) + Left( C2G->C2G_PERFIS, 2 )

				If !Empty( C2G->C2G_DTINI ) .and. !Empty( C2G->C2G_DTFIM )
					If cPeriodo < StrTran( Left( DToS( C2G->C2G_DTINI ), 6 ), "/", "" ) .or. cPeriodo > StrTran( Left( DToS( C2G->C2G_DTFIM ), 6 ), "/", "" )
						aAdd( aLogErro, { "C2G_PERFIS", "000579", "C20", nRecno } ) //STR0579 - "Período fiscal divergente de data inicial ou final."
					EndIf
				ElseIf !Empty( C2G->C2G_DTINI )
					If cPeriodo < StrTran( Left( DToS( C2G->C2G_DTINI ), 6 ), "/", "" )
						aAdd( aLogErro, { "C2G_PERFIS", "000579", "C20", nRecno } ) //STR0579 - "Período fiscal divergente de data inicial ou final."
					EndIf
				ElseIf !Empty( C2G->C2G_DTFIM )
					If cPeriodo > StrTran( Left( DToS( C2G->C2G_DTFIM ), 6 ), "/", "" )
						aAdd( aLogErro, { "C2G_PERFIS", "000579", "C20", nRecno } ) //STR0579 - "Período fiscal divergente de data inicial ou final."
					EndIf
				EndIf
			EndIf

			C2G->( DbSkip() )
		EndDo
	EndIf
	//FIM C2G

	//INICIO C2H
	C2H->( DBSetOrder(1) )

	cC2HKey := C20->C20_CHVNF
	If C2H->( MsSeek( xFilial("C2H") + cC2HKey ) )

		Do While !C2H->( Eof() ) .And. cC2HKey == C2H->C2H_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C2H->C2H_OPER)
				AADD(aLogErro,{"C2H_OPER","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C2H->C2H_UF)
				AADD(aLogErro,{"C2H_UF","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C2H->C2H_UF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C2H->C2H_UF
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C2H_UF", nRecno } )
			EndIf

			//--------
			// Combos
			//--------
			If !C2H->C2H_OPER $ ('0|1')
				AADD(aLogErro,{"C2H_OPER","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			C2H->( DbSkip() )
		EndDo
	EndIf
	//FIM C2H

	//INICIO C2I
	C2I->( DBSetOrder(1) )

	cC2IKey := C20->C20_CHVNF
	If C2I->( MsSeek( xFilial("C2I") + cC2IKey ) )

		Do While !C2I->( Eof() ) .And. cC2IKey == C2I->C2I_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C2I->C2I_NUMDOC)
				AADD(aLogErro,{"C2I_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			C2I->( DbSkip() )
		EndDo
	EndIf
	//FIM C2I

	//INICIO C3F
	C3F->( DBSetOrder(1) )

	cC3FKey := C20->C20_CHVNF
	If C3F->( MsSeek( xFilial("C3F") + cC3FKey ) )

		Do While !C3F->( Eof() ) .And. cC3FKey == C3F->C3F_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C3F->C3F_UFORIG)
				AADD(aLogErro,{"C3F_UFORIG","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3F->C3F_CMUNOR)
				AADD(aLogErro,{"C3F_CMUNOR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3F->C3F_UFDEST)
				AADD(aLogErro,{"C3F_UFDEST","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3F->C3F_CMUNDE)
				AADD(aLogErro,{"C3F_CMUNDE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			// Demetrio - 26/08/2014 - Campo deve ser obrigatório apenas se Frete - Sem pagamento.
			If Empty(C3F->C3F_VLIQFR) .AND. !(C20->C20_INDFRT=="9")
				AADD(aLogErro,{"C3F_VLIQFR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C3F->C3F_UFORIG)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3F->C3F_UFORIG
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C3F_UFORIG", nRecno } )
			EndIf

			If !Empty(C3F->C3F_CMUNOR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3F->C3F_CMUNOR
				xValRegTab("C07",cChave,3,,@aLogErro,, { "C20", "C3F_CMUNOR", nRecno })
			EndIf

			If !Empty(C3F->C3F_UFDEST)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3F->C3F_UFDEST
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C3F_UFDEST", nRecno })
			EndIf

			If !Empty(C3F->C3F_CMUNDE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3F->C3F_CMUNDE
				xValRegTab("C07",cChave,3,,@aLogErro,, { "C20", "C3F_CMUNDE", nRecno })
			EndIf

			If !Empty(C3F->C3F_CODVEI)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3F->C3F_CODVEI
				xValRegTab("C0Q",cChave,4,,@aLogErro,, { "C20", "C3F_CODVEI", nRecno })
			EndIf

			If !Empty(C3F->C3F_CPARCO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3F->C3F_CPARCO
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C3F_CPARCO", nRecno })
			EndIf

			If !Empty(C3F->C3F_CPARRE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3F->C3F_CPARRE
				xValRegTab("C1H",cChave,5,,@aLogErro,,{ "C20", "C3F_CPARRE", nRecno })
			EndIf

			//--------
			// Combos
			//--------
			If !C3F->C3F_INDRED $ (' |0|1|2|9')
				AADD(aLogErro,{"C3F_INDRED","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !C3F->C3F_INDNAT $ (' |0|1')
				AADD(aLogErro,{"C3F_INDNAT","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			C3F->( DbSkip() )
		EndDo
	EndIf
	//FIM C3F

	//INICIO C3G
	C3G->( DBSetOrder(1) )

	cC3GKey := C20->C20_CHVNF
	If C3G->( MsSeek( xFilial("C3G") + cC3GKey ) )

		Do While !C3G->( Eof() ) .And. cC3GKey == C3G->C3G_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C3G->C3G_CMUNOR)
				AADD(aLogErro,{"C3G_CMUNOR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3G->C3G_UFDEST)
				AADD(aLogErro,{"C3G_UFDEST","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3G->C3G_CMUNDE)
				AADD(aLogErro,{"C3G_CMUNDE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C3G->C3G_UFORIG)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3G->C3G_UFORIG
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C3G_UFORIG", nRecno } )
			EndIf

			If !Empty(C3G->C3G_CMUNOR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3G->C3G_CMUNOR
				xValRegTab("C07",cChave,3,,@aLogErro,, { "C20", "C3G_CMUNOR", nRecno })
			EndIf

			If !Empty(C3G->C3G_UFDEST)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3G->C3G_UFDEST
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C3G_UFDEST", nRecno })
			EndIf

			If !Empty(C3G->C3G_CMUNDE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3G->C3G_CMUNDE
				xValRegTab("C07",cChave,3,,@aLogErro,, { "C20", "C3G_CMUNDE", nRecno })
			EndIf

			If !Empty(C3G->C3G_CODVEI)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3G->C3G_CODVEI
				xValRegTab("C0Q",cChave,4,,@aLogErro,, { "C20", "C3G_CODVEI", nRecno })
			EndIf

			If !Empty(C3G->C3G_CPARCO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3G->C3G_CPARCO
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C3G_CPARCO", nRecno })
			EndIf

			C3G->( DbSkip() )
		EndDo
	EndIf
	//FIM C3G

	//INICIO C3H
	C3H->( DBSetOrder(1) )

	cC3HKey := C20->C20_CHVNF
	If C3H->( MsSeek( xFilial("C3H") + cC3HKey ) )

		Do While !C3H->( Eof() ) .And. cC3HKey == C3H->C3H_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C3H->C3H_UFORIG)
				AADD(aLogErro,{"C3H_UFORIG","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3H->C3H_CMUNOR)
				AADD(aLogErro,{"C3H_CMUNOR","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3H->C3H_UFDEST)
				AADD(aLogErro,{"C3H_UFDEST","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C3H->C3H_CMUNDE)
				AADD(aLogErro,{"C3H_CMUNDE","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C3H->C3H_UFORIG)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3H->C3H_UFORIG
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C3H_UFORIG", nRecno } )
			EndIf

			If !Empty(C3H->C3H_CMUNOR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3H->C3H_CMUNOR
				xValRegTab("C07",cChave,3,,@aLogErro,, { "C20", "C3H_CMUNOR", nRecno })
			EndIf

			If !Empty(C3H->C3H_UFDEST)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3H->C3H_UFDEST
				xValRegTab("C09",cChave,3,,@aLogErro,,{ "C20", "C3H_UFDEST", nRecno })
			EndIf

			If !Empty(C3H->C3H_CMUNDE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3H->C3H_CMUNDE
				xValRegTab("C07",cChave,3,,@aLogErro,, { "C20", "C3H_CMUNDE", nRecno })
			EndIf

			If !Empty(C3H->C3H_CODVEI)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3H->C3H_CODVEI
				xValRegTab("C0Q",cChave,4,,@aLogErro,, { "C20", "C3H_CODVEI", nRecno })
			EndIf

			//--------
			// Combos
			//--------
			If !C3H->C3H_INDTAR $ (' |0|1|2|9')
				AADD(aLogErro,{"C3H_INDTAR","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			C3H->( DbSkip() )
		EndDo
	EndIf
	//FIM C3H

	//INICIO C3A
	C3A->( DBSetOrder(1) )

	cC3AKey := C20->C20_CHVNF
	If C3A->( MsSeek( xFilial("C3A") + cC3AKey ) )

		Do While !C3A->( Eof() ) .And. cC3AKey == C3A->C3A_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C3A->C3A_TPCARG)
				AADD(aLogErro,{"C3A_TPCARG","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C3A->C3A_CPARRE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3A->C3A_CPARRE
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C3A_CPARRE", nRecno } )
			EndIf

			If !Empty(C3A->C3A_CPARDE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3A->C3A_CPARDE
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C3A_CPARDE", nRecno })
			EndIf

			If !Empty(C3A->C3A_CPARCO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3A->C3A_CPARCO
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C20", "C3A_CPARCO", nRecno })
			EndIf

			If !Empty(C3A->C3A_CPAREN)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3A->C3A_CPAREN
				xValRegTab("C1H",cChave,5,,@aLogErro,,{ "C20", "C3A_CPAREN", nRecno })
			EndIf

			//--------
			// Combos
			//--------
			If !C3A->C3A_TPCARG $ ('0|1|2|3|4|5|9')
				AADD(aLogErro,{"C3A_TPCARG","000006", "C20",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			//INICIO C3I
			C3I->( DBSetOrder(1) )

			cC3IKey := C20->C20_CHVNF + C3A->(C3A_DESPAC + C3A_CPARRE + C3A_CPARDE)
			If C3I->( MsSeek( xFilial("C3I") + cC3IKey ) )

				Do While !C3I->( Eof() ) .And. cC3IKey == C3I->(C3I_CHVNF + C3I_DESPAC + C3I_CPARRE + C3I_CPARDE)

					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C3I->C3I_CODMOD)
						AADD(aLogErro,{"C3I_CODMOD","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C3I->C3I_NUMDOC)
						AADD(aLogErro,{"C3I_NUMDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C3I->C3I_DTDOC)
						AADD(aLogErro,{"C3I_DTDOC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C3I->C3I_VLMERC)
						AADD(aLogErro,{"C3I_VLMERC","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C3I->C3I_CODMOD)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C3I->C3I_CODMOD
						xValRegTab("C01",cChave,3,,@aLogErro,, { "C20", "C3I_CODMOD", nRecno } )
					EndIf

					//--------------------
					// Regras específicas
					//--------------------
					// Validação do campo C3I_NUMDOC
					If C3I->C3I_NUMDOC <= 0
						AADD(aLogErro,{"C3I_NUMDOC","000520", "C20",nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
					EndIf

					// Validação do campo C3I_VLMERC
					If C3I->C3I_VLMERC <= 0
						AADD(aLogErro,{"C3I_VLMERC","000520", "C20",nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
					EndIf

					C3I->( DbSkip() )
				EndDo
			EndIf
			//FIM C3I

			C3A->( DbSkip() )
		EndDo
	EndIf
	//FIM C3A

	//INICIO C6W
	C6W->( DBSetOrder(1) )

	cC6WKey := C20->C20_CHVNF
	If C6W->( MsSeek( xFilial("C6W") + cC6WKey ) )

		Do While !C6W->( Eof() ) .And. cC6WKey == C6W->C6W_CHVNF

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C6W->C6W_NUMERO)
				AADD(aLogErro,{"C6W_NUMERO","000010", "C20",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C6W->C6W_NUMERO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C6W->C6W_NUMERO
				If xValRegTab("C1G",cChave,3,,@aLogErro,, { "C20", "C6W_NUMERO", nRecno } )
					//--------
					// Combos
					//--------
					If !C1G->C1G_INDPRO $ ('0|1|2|3|9')
						aAdd( aLogErro, { "C1G_INDPRO", "000006", "C20", nRecno } ) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIf
				EndIf
			EndIf

			C6W->( DbSkip() )
		EndDo
	EndIf
	//FIM C6W

	//INICIO C7B
	C7B->( DBSetOrder(1) )

	cC7BKey := C20->C20_CHVNF
	If C7B->( MsSeek( xFilial("C7B") + cC7BKey ) )

		Do While !C7B->( Eof() ) .And. cC7BKey == C7B->C7B_CHVNF

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C7B->C7B_UF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C7B->C7B_UF
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C20", "C7B_UF", nRecno } )
			EndIf

			If !Empty(C7B->C7B_CODMUN)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C7B->C7B_CODMUN
				xValRegTab("C07",cChave,4,,@aLogErro,, { "C20", "C7B_CODMUN", nRecno })
			EndIf

			C7B->( DbSkip() )
		EndDo
	EndIf
	//FIM C7B

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C20", cStatus )

Else
	AADD(aLogErro,{"C20_CHVNF","000305","C20",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc}  LoadGrid
Funcao que carrega as informações e ordena a grid

@author Luccas Curcio
@since 10/05/2016
@version 1.0

/*/
//-------------------------------------------------------------------
static function LoadGrid( oGrid , cAlias )

local aRet        := {}
local cQuery      := ''
local cAliasQuery := GetNextAlias()
local aArea       := GetArea()

if cAlias == 'C2A'
	cQuery += " SELECT DISTINCT * "
	cQuery += " FROM " + RetSqlName('C2A') +" C2A "
	cQuery += " WHERE C2A_FILIAL = '" + xFilial('C2A') + "' "
	cQuery += " AND C2A_CHVNF = '" + C20->C20_CHVNF + "' "
	cQuery += " AND C2A.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY C2A_VECTO "
endif

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQuery, .F., .T. )

aRet := FWLoadByAlias( oGrid, cAliasQuery, cAlias )

aEval( aRet , { |x| x[ 2 , 3 ] := SToD( x[ 2 , 3 ] ) } )

(cAlias)->(DBGoto(0))

(cAliasQuery)->(DbCloseArea())
RestArea(aArea)

return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} Taf62T96Chk

Funcao que disponibiliza o Recno, Id, Versao na T96 para posterior uso

@return {lExist, nRecno , Id, Versao }

@author Denis Souza Naves
@since 15/10/2018
@version 1.0
*/
//-------------------------------------------------------------------
Static Function Taf62T96Chk( cFil, cChv, cNumDoc, cSerie )

Local lRet 		:= .F.
Local cSelect  	:= ""
Local cFrom    	:= ""
Local cWhere  	:= ""
Local cAliasQry	:= GetNextAlias()

Local aRet      := {}
Default cFil 	:= ""
Default cChv 	:= ""

aRet := { lRet , 0 , "" , "" }

cSelect := " T96.R_E_C_N_O_, T96.T96_ID, T96.T96_VERSAO "
cFrom	:= RetSqlName( "T96" ) + " T96 "

cWhere  := " T96.T96_FILIAL = '" + xFilial("T96",cFil) + "' AND "
cWhere  += " T96.T96_CHVNF = '" + cChv + "' AND "
cWhere  += " T96.T96_NUMDOC = '" + cNumDoc + "' AND "
cWhere  += " T96.T96_SERIE = '" + cSerie + "' AND "
cWhere  += " T96.D_E_L_E_T_ = ' ' "

cSelect := "%"	+	cSelect	+	"%"
cFrom   := "%"	+	cFrom  	+	"%"
cWhere	:= "%"	+	cWhere 	+	"%"

If !Empty(cSelect)
	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
EndIf

If (cAliasQry)->R_E_C_N_O_ > 0
	aRet := { .T. , (cAliasQry)->R_E_C_N_O_, (cAliasQry)->T96_ID, (cAliasQry)->T96_VERSAO }
EndIf

(cAliasQry)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf62T95Chk

Funcao que verifica se o ID no T95 em algum momento já foi transmitido.

@return lFound

@author Denis Souza Naves
@since 15/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Taf62T95Chk( cFil, cId, cVersao )

Local lRet 		:= .F.
Local cSelect 	:= ""
Local cFrom    	:= ""
Local cWhere  	:= ""
Local cAliasQry	:= GetNextAlias()

Default cFil 	:= ""
Default cId 	:= ""
Default cVersao	:= ""

//Verifica se o ID independente da versão em algum momento foi transmitido.
cSelect := " T95.R_E_C_N_O_ "
cFrom	:= RetSqlName( "T95" ) + " T95 "

cWhere  := " T95.T95_FILIAL = '" + xFilial("T95",cFil) + "' AND "
cWhere  += " T95.T95_ID = '" + cId + "' AND "
//cWhere  += " T95.T95_VERSAO = '" + cVersao + "' AND "
cWhere  += " T95.D_E_L_E_T_ = ' ' AND "
cWhere  += " T95.T95_STATUS IN ( '2','4','6','7' ) "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere	:= "%" + cWhere  + "%"

If !Empty(cSelect)
	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
EndIf

If (cAliasQry)->R_E_C_N_O_ > 0
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf62LEMChk
Avalia a integridade entre as tabelas C20 e LEM no momento da exclusão. 
Caso haja um registro na LEM para a nota, será exibida uma pergunta para o usuário decidir se a fatura deverá ser excluída ou não.

@return lRet, Logico, Retorna se será permitido a 

@author Leandro F. Dourado
@since 15/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Taf62LEMChk( cFil, cChvNF )

Local aArea      := GetArea()
Local lRet 		 := .T.
Local cSelect 	 := ""
Local cFrom    	 := ""
Local cWhere  	 := ""
Local cLjoin	 := ""
Local cAliasQry	 := GetNextAlias()
Local oMdlLEM    := Nil
Local oMdlV3U    := Nil
Local aRecLEM    := {}
Local cBD		 := ""
Local cIsNullSQL := ""
Local nlA        := 0
Default cFil 	 := ""
Default cChvNF 	 := ""

cBD := TcGetDb()

If cBD $ "INFORMIX*ORACLE"
	cIsNullSQL := "NVL"
ElseIf  cBD $ "DB2*POSTGRES"  .OR. ( cBD == "DB2/400" .And. Upper(cSrvType) == "ISERIES" )
	cIsNullSQL := "COALESCE" 
Else
	cIsNullSQL := "ISNULL"
EndIf

DbSelectArea("LEM")

//Verifica se o ID independente da versão em algum momento foi transmitido.
cSelect := " LEM.R_E_C_N_O_ RECLEM "
cFrom	:= RetSqlName( "LEM" ) + " LEM "

if TAFAlsInDic("V3U") .And. "TAFA062E" $ Upper(funname())
	cSelect += " , " + cIsNullSQL + " ( V3U.R_E_C_N_O_ , 0 ) RECV3U "
	cLjoin  := RetSqlName( "V3U" ) + " V3U ON V3U.V3U_FILIAL = LEM.LEM_FILIAL AND V3U.V3U_NUMERO = LEM.LEM_NUMERO "
	cLjoin  := "%" + cLjoin + "%"
endif

cWhere  := " LEM.LEM_FILIAL = '" + xFilial("LEM",cFil)                    + "' AND "
cWhere  += " LEM.LEM_DOCORI = '" + Padr(cChvNF  ,TamSx3("LEM_DOCORI")[1]) + "' AND "
cWhere  += " LEM.D_E_L_E_T_ = ' ' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere	:= "%" + cWhere  + "%"

if TAFAlsInDic("V3U") .And. "TAFA062E" $ Upper(funname())
	If !Empty(cSelect)
		BeginSql Alias cAliasQry
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			LEFT JOIN
				%Exp:cLjoin%
			WHERE
				%Exp:cWhere%
		EndSql
	EndIf
else
	If !Empty(cSelect)
		BeginSql Alias cAliasQry
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
		EndSql
	EndIf
endif

(cAliasQry)->(DbGoTop())

If (cAliasQry)->(!Eof())
	If IsBlind()
		lRet := .F.
	Else
		If MsgYesNo(STR0122,STR0123) //"Esse documento fiscal está vínculado a uma ou mais faturas. Deseja efetuar a exclusão dessas faturas agora?"###"Validação de exclusão"

			Begin Transaction

				While (cAliasQry)->(!Eof())

					//Antes -> Exclui os Pagamentos (devido o relacionamento SX9)
					if TAFAlsInDic("V3U") .And. "TAFA062E" $ Upper(funname()) .And. FindFunction("TAFA535") .And. (cAliasQry)->RECV3U != 0
						V3U->(DbGoTo((cAliasQry)->RECV3U))

						oMdlV3U := FwLoadModel("TAFA535")
						oMdlV3U:SetOperation(MODEL_OPERATION_DELETE)
						oMdlV3U:Activate()

						lRet := oMdlV3U:VldData()
						If !lRet
							Help(,,'HELP',,STR0126,1,0) //"Ocorreu erro na exclusão do Pagamento. Acesse o cadastro de Pgto (TAFA535) para realizar a exclusão manualmente!"
							Exit
						Endif
						lRet := oMdlV3U:CommitData()
						If !lRet
							Help(,,'HELP',,STR0126,1,0) //"Ocorreu erro na exclusão do Pagamento. Acesse o cadastro de Pgto (TAFA535) para realizar a exclusão manualmente!"
							Exit
						Endif
						oMdlV3U:DeActivate()
					endif

					//Adiciona os recnos da fatura
					if aScan(aRecLEM,(cAliasQry)->RECLEM) == 0
						aadd( aRecLEM, (cAliasQry)->RECLEM  )
					endif
					(cAliasQry)->(DbSkip())
				EndDo

				//Depois -> Exclui Faturas (devido o relacionamento SX9)
				if lRet
					if Len( aRecLEM ) > 0
						for nlA := 1 to len(aRecLEM)
							LEM->(DbGoTo(aRecLEM[nlA]))

							oMdlLEM := FwLoadModel("TAFA448")
							oMdlLEM:SetOperation(MODEL_OPERATION_DELETE)
							oMdlLEM:Activate()

							lRet := oMdlLEM:VldData()
							If !lRet
								Help(,,'HELP',, STR0124,1,0 ) //"Ocorreu erro na exclusão da fatura. Acesse o cadastro de faturas (TAFA448) para realizar a exclusão manualmente!"
								Exit
							Endif
							lRet := oMdlLEM:CommitData()
							If !lRet
								Help(,,'HELP',, STR0124,1,0 ) //"Ocorreu erro na exclusão da fatura. Acesse o cadastro de faturas (TAFA448) para realizar a exclusão manualmente!"
								Exit
							Endif
							oMdlLEM:DeActivate()
						Next nlA
					endif
				endif

				If !lRet
					DisarmTransaction()
				endif
			End Transaction
		Else
			lRet := .F.	
			Help(,,'HELP',, STR0125,1,0 ) //"Não foi possível excluir o documento fiscal por conta do vínculo com uma ou mais faturas!"
		EndIf
	EndIf	
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Taf62CROChk

Funcao que disponibiliza o Recno, Id, Versao na CRO para posterior uso

@return {lExist, nRecno , Id, Versao }

@author Denis Souza Naves
@since 16/10/2018
@version 1.0
*/
//-------------------------------------------------------------------
Static Function Taf62CROChk( cFil, cChv, cNumDoc, cSerie )

Local lRet 		:= .F.
Local cSelect  	:= ""
Local cFrom    	:= ""
Local cWhere  	:= ""
Local cAliasQry	:= GetNextAlias()

Local aRet      := {}
Default cFil 	:= ""
Default cChv 	:= ""

aRet := { lRet , 0 , "" , "" }

cSelect := " CRO.R_E_C_N_O_, CRO.CRO_ID, CRO.CRO_VERSAO "
cFrom	:= RetSqlName( "CRO" ) + " CRO "

cWhere  := " CRO.CRO_FILIAL = '" + cFil + "' AND "
cWhere  += " CRO.CRO_CHVNF = '" + cChv + "' AND "
cWhere  += " CRO.CRO_NUMDOC = '" + cNumDoc + "' AND "
cWhere  += " CRO.CRO_SERIE = '" + cSerie + "' AND "
cWhere  += " CRO.D_E_L_E_T_ = ' ' "

cSelect := "%"	+	cSelect	+	"%"
cFrom   := "%"	+	cFrom  	+	"%"
cWhere	:= "%"	+	cWhere 	+	"%"

If !Empty(cSelect)
	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
EndIf

If (cAliasQry)->R_E_C_N_O_ > 0
	aRet := { .T. , (cAliasQry)->R_E_C_N_O_, (cAliasQry)->CRO_ID, (cAliasQry)->CRO_VERSAO }
EndIf

(cAliasQry)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} Taf62CMNChk

Funcao que verifica se o ID no CMN em algum momento já foi transmitido.

@return lFound

@author Denis Souza Naves
@since 15/10/2018
@version 1.0
*/
//-------------------------------------------------------------------
Static Function Taf62CMNChk( cFil, cId, cVersao )

Local lRet 		:= .F.
Local cSelect 	:= ""
Local cFrom    	:= ""
Local cWhere  	:= ""
Local cAliasQry	:= GetNextAlias()

Default cFil 	:= ""
Default cId 	:= ""
Default cVersao	:= ""

//Verifica se o ID independente da versão em algum momento foi transmitido.
cSelect := " CMN.R_E_C_N_O_ "
cFrom	:= RetSqlName( "CMN" ) + " CMN "

cWhere  := " CMN.CMN_FILIAL = '" + cFil + "' AND "
cWhere  += " CMN.CMN_ID = '" + cId + "' AND "
//cWhere  += " CMN.CMN_VERSAO = '" + cVersao + "' AND "
cWhere  += " CMN.D_E_L_E_T_ = ' ' AND "
cWhere  += " CMN.CMN_STATUS IN ( '2','4','6','7' ) "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere	:= "%" + cWhere  + "%"

If !Empty(cSelect)
	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
EndIf

If (cAliasQry)->R_E_C_N_O_ > 0
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldC2APre

Função auxiliar utilizada para permitir sim ou não a edição do campo C2A_VECTO ( grid da aba 80.Fatura( Mod. 01 e 55 )  )

@param oGridC2A  - objeto FormGrid 
@param nLine     - linha atual
@param cAction   - identificação da ação
@param cField    - campo que será atualizado
@param xNewValue - novo valor a ser atribuído
@param xOldValue - valor atual do campo

@return lOk -  Action CANSETVALUE - indica se o campo poderá sim/não ser editado
               Action SETVALUE    - indica se o campo poderá sim/não ser atualizado com novo valor 

@author Wesley Pinheiro
@since 25/03/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function VldC2APre( oGridC2A, nLine, cAction, cField, xNewValue, xOldValue )

		Local lOk       := .F.
		Local nx        := 1
		Local nLenRows  := 0
		Local oModel    := Nil
		Local aSaveLine	:= { }

        If !( cAction $ "SETVALUE|CANSETVALUE" )
            
			lOK := .T.

		ElseIf ( cAction == "CANSETVALUE" ) .and. ( cField == "C2A_VECTO" )
            
			lOk := .T.

		ElseIf ( cAction == "CANSETVALUE" ) .and. ( cField == "C2A_VLRPAR" )
				
			lOk := .T.

		ElseIf (( cAction == "SETVALUE" ) .and. ( cField == "C2A_VLRPAR" )) .or. (( cAction == "SETVALUE" ) .and. ( cField == "C2A_VECTO" ))
			
			lOk    := .T.	

		EndIf

Return lOk

//-------------------------------------------------------------------
/*{Protheus.doc} TAF062Cbox
Função de combo box para o campo V4C_TPDEDU, necessário pois as opções ultrapassam o tamanho máx. 

@author Katielly feitosa
@since 17/07/2019
@version 1.0
*/
Function TAF062Cbox( cCampo ) 

Local cString	:=	""
	cString := "1=" + STR0112 
	cString += "2=" + STR0113 
	cString += "3=" + STR0114 
	cString += "4=" + STR0115 
	cString += "5=" + STR0116 
	cString += "6=" + STR0117 
	cString += "7=" + STR0118 
Return( cString )

//-------------------------------------------------------------------
/*{Protheus.doc} REINF20
Função que realiza a validação dos campos das tabelas V4C e V4D, é chamda nos campos V4C_NUMPRE e V4D_DRENDI. 
@author Katielly feitosa
@since 17/07/2019
@version 1.0
*/

Function REINF20( cCampo )
lOk := .T.

Default cCampo:= "0"

If cCampo=='1'
	If FwFldGet("V4C_TPDEDU")$'234' .And. Empty( M->V4C_NUMPRE ) 
		Help("",1,"Help","Help",STR0119, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0120}) //"O N° de Inscrição da Previdêcia se torna obrigatório quando o Tipo Dedução é igual 2,3 ou 4."
		lOk := .F.
	EndIf
ElseIf cCampo=='2'
	If FwFldGet("V4D_CTPISE")$'99' .And. Empty( M-> V4D_DRENDI ) 
		Help("",1,"Help","Help",STR0121, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0120}) //"A descrição da isenção se torna obrigatória quando o Tipo da Isenção é igual 99=Outros"
		lOk := .F.
	EndIf
EndIf

Return lOk
