#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA537.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA537
Cadastro MVC Cadastro de Advogados T161

@author Denis S Naves / Katielly Rezende
@since 05/07/2019
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA537()

	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")

/*
    If TAFAlsInDic("V3Z" )   
        BrowseDef()  
    Else
        Aviso( STR0001, STR0002, { STR0004 }, 3 ) //"AVISO" ##"O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário aplicar o dicionário de dados do REINF 2.0." ##"Encerrar"
    EndIf
*/
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Tratamento para chamada do MenuDef

@author Denis S Naves / Katielly Rezende
@since 05/07/2019
@version 1.0

/*/ 
//-------------------------------------------------------------------
/*
Static Function BrowseDef()

Local oBrw := FWMBrowse():New()

DBSelectArea("V3Z")
DbSetOrder(1)

oBrw:SetDescription(STR0003) //"Cadastro de Advogados"
oBrw:SetAlias( 'V3Z' ) 
oBrw:SetMenuDef( 'TAFA537' )
oBrw:Activate()

Return oBrw
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis S Naves / Katielly Rezende
@since 05/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function MenuDef()

Local aRotina   := {}

aRotina := xFunMnuTAF("TAFA537")

Return( aRotina )
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis S Naves / Katielly Rezende
@since 05/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function ModelDef()

Local oStruV3Z 	:= FWFormStruct( 1, 'V3Z' )
Local oModel	:= MPFormModel():New( 'TAFA537' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_V3Z',, oStruV3Z)
oModel:GetModel( "MODEL_V3Z" ):SetPrimaryKey( { "V3Z_FILIAL","V3Z_ID"} )

Return oModel
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis S Naves / Katielly Rezende
@since 05/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TAFA537' )
Local oStruV3Z := FWFormStruct( 2, 'V3Z' )
Local oView	   := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V3Z', oStruV3Z, 'MODEL_V3Z' )
oView:EnableTitleView( 'VIEW_V3Z', STR0003 ) //"Cadastros de Advogados"
oView:CreateHorizontalBox( 'FIELDSV3Z', 100 )
oView:SetOwnerView( 'VIEW_V3Z', 'FIELDSV3Z' )

oStruV3Z:SetProperty( "V3Z_TPINSC"	, MVC_VIEW_ORDEM, "01" )
oStruV3Z:SetProperty( "V3Z_NRINSC"	, MVC_VIEW_ORDEM, "02" )
oStruV3Z:SetProperty( "V3Z_NOME"	, MVC_VIEW_ORDEM, "03" )

oStruV3Z:RemoveField("V3Z_ID")

Return oView
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author  Denis S Naves / Katielly Rezende
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function SaveModel(oModel)

Begin Transaction 

FwFormCommit( oModel )
			
End Transaction 

Return .T.
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVdTpIns

Ajusta picture do campo V3Z_NRINSC de acordo com o tipo (F/J)
Função chamada no Form Variável - Exibição na Browse

@param  cTipPes - Tipo Pessoa
@return .T.

@author  Denis Souza
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function FvCgc(cTipPes)

	Local cPict := ""

	If cTipPes == "1" //Física
		cPict := "@R 999.999.999-99"
	ElseIf cTipPes == "2" //Jurídica
		cPict := "@R 99.999.999/9999-99"
	EndIf
	cPict := cPict + "%C"

Return cPict
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} PictNrInsc

Ajusta picture do campo V3Z_NRINSC de acordo com o tipo (F/J)
Função chamada no X3_VALID - Exibição no Cadastro

@param  cTipPes - Tipo Pessoa
@return .T.

@author  Denis Souza
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function PictNrInsc( cTipPes )

	Local aSaveLine := {}
	Local oView 	:= Nil
	Local oModel 	:= Nil
	Local alGetV3Z  := {}
	Local oStruV3Z  := Nil 
	Local lRet      := .T.

	If !IsBlind()
		alGetV3Z  := V3Z->( GetArea() )
		aSaveLine := FWSaveRows()    //Salvando a posicao da linha original para restaurar ao final do processamento.
		oModel	  := FWModelActive() //Recuperando o model ativo da interface
		oView 	  := FWViewActive()  //Recuperando a view ativa da interface
		oStruV3Z  := FWFormStruct( 2, 'V3Z' )

		If  cTipPes == '1'		//Fisica
			if Len( alltrim( M->V3Z_NRINSC ) ) == 14
				FwFldPut("V3Z_TPINSC" , &(ReadVar()))
				FwFldPut("V3Z_NRINSC" , Space(11))
			endif
			oStruV3Z:SetProperty( 'V3Z_NRINSC'	, MVC_VIEW_PICT, '@R 999.999.999-99')
		ElseIf cTipPes == '2'	//Juridica
			if Len( alltrim( M->V3Z_NRINSC ) ) == 11
				FwFldPut("V3Z_TPINSC" , &(ReadVar()))
				FwFldPut("V3Z_NRINSC" , Space(14))
			endif
			oStruV3Z:SetProperty( 'V3Z_NRINSC'	, MVC_VIEW_PICT, '@R 99.999.999/9999-99')
		EndIf

		oview:Refresh( 'VIEW_V3Z' )

		//Restaurando a linha original
		FWRestRows( aSaveLine )
		RestArea( alGetV3Z )
	EndIf

Return lRet
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVdNInsc

Valida o CNPJ ou CPF de acordo com o tipo V3Z_TPINSC

@param  
@return lRet

@author  Denis Souza
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafVdNInsc()

Local lRet := .F.

If !IsBlind()
	if "V3Z_TPINSC" $ ReadVar() .And. &(ReadVar()) == '1' //Fisico
		if !Empty(FwFldGet("V3Z_NRINSC")) 
			if ChkCPF( AllTrim(FwFldGet("V3Z_NRINSC")) )
				lRet := .T.
			endif
		else
			lRet := .T.
		endif
	elseif "V3Z_TPINSC" $ ReadVar() .And. &(ReadVar()) == '2' //CNPJ
		if !Empty(FwFldGet("V3Z_NRINSC")) 
			if CGC(Padr(AllTrim(FwFldGet("V3Z_NRINSC")),14,"X"))
				lRet := .T.
			endif
		else
			lRet := .T.
		endif
	elseif "V3Z_NRINSC" $ ReadVar() .And. FwFldGet("V3Z_TPINSC") == "1" //Fisico
		if !Empty( &(ReadVar()) ) 
			if ChkCPF(AllTrim(&(ReadVar())))
				lRet := .T.
			endif
		else
			lRet := .T.
		endif
	elseif "V3Z_NRINSC" $ ReadVar() .And. FwFldGet("V3Z_TPINSC") == "2" //CNPJ
		if !Empty( &(ReadVar())) 
			if CGC(PadR(AllTrim(&(ReadVar())),14,"X"))
				lRet := .T.
			endif
		else
			lRet := .T.
		endif
	elseif "V3Z_NRINSC" $ ReadVar() .And. Empty( FwFldGet("V3Z_TPINSC") )
		Help("",1,"Help","Help",STR0005, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006}) //"O Tipo de Inscrição não foi preenchido."##"Informe o campo Tp Insc Adv"
	endif
else
	lRet := .T.
endif

Return lRet
*/