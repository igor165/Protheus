#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA539.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA539
Cadastro MVC Pagamento Reembolso PLS / T164

@author Denis S Naves
@since 11/07/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA539()

	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")


/*
If TAFAlsInDic("V4B")
	BrowseDef()
Else
	Aviso( STR0001, STR0002, { STR0004 }, 3 ) //"AVISO" ##"O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário aplicar o dicionário de dados do REINF 2.0." ##"Encerrar"
EndIf
*/

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Tratamento para chamada do MenuDef

@author Denis S Naves
@since 11/07/2019
@version 1.0

/*/ 
//-------------------------------------------------------------------
/*
Static Function BrowseDef()

Local oBrw := FWMBrowse():New()

DBSelectArea("V4B")
DbSetOrder(1)

oBrw:SetDescription(STR0003) //"Pagamento Reembolso PLS"
oBrw:SetAlias( 'V4B' )
oBrw:SetMenuDef( 'TAFA539' )
oBrw:Activate()

Return oBrw
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis S Naves
@since 11/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function MenuDef()

Local aRotina   := {}

aRotina := xFunMnuTAF("TAFA539")

Return( aRotina )
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis S Naves
@since 11/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function ModelDef()

Local oStruV4B 	:= FWFormStruct( 1, 'V4B' )
Local oModel	:= MPFormModel():New( 'TAFA539' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_V4B',, oStruV4B)
oModel:GetModel( "MODEL_V4B" ):SetPrimaryKey( { "V4B_FILIAL","V4B_ID"} )

Return oModel
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis S Naves
@since 11/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TAFA539' )
Local oStruV4B := FWFormStruct( 2, 'V4B' )
Local oView	   := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V4B', oStruV4B, 'MODEL_V4B' )
oView:EnableTitleView( 'VIEW_V4B', STR0003) //"Pagamento Reembolso PLS"
oView:CreateHorizontalBox( 'FIELDSV4B', 100 )
oView:SetOwnerView( 'VIEW_V4B', 'FIELDSV4B' )

oStruV4B:SetProperty( "V4B_CNPJ"	, MVC_VIEW_ORDEM, '001' )
oStruV4B:SetProperty( "V4B_DESPLS"	, MVC_VIEW_ORDEM, '002' )
oStruV4B:SetProperty( "V4B_DTPGTO"	, MVC_VIEW_ORDEM, '003' )
oStruV4B:SetProperty( "V4B_INDBEN"	, MVC_VIEW_ORDEM, '004' )
oStruV4B:SetProperty( "V4B_CODPAR"	, MVC_VIEW_ORDEM, '005' )
oStruV4B:SetProperty( "V4B_DPARTC"	, MVC_VIEW_ORDEM, '006' )
oStruV4B:SetProperty( "V4B_CODDEP"	, MVC_VIEW_ORDEM, '007' )
oStruV4B:SetProperty( "V4B_DDEPEN"	, MVC_VIEW_ORDEM, '008' )
oStruV4B:SetProperty( "V4B_TPPGTO"	, MVC_VIEW_ORDEM, '009' )
oStruV4B:SetProperty( "V4B_VLRPGT"	, MVC_VIEW_ORDEM, '010' )
oStruV4B:SetProperty( "V4B_VRBANT"	, MVC_VIEW_ORDEM, '011' )
oStruV4B:SetProperty( "V4B_TPINSC"	, MVC_VIEW_ORDEM, '012' )
oStruV4B:SetProperty( "V4B_NRINSC"	, MVC_VIEW_ORDEM, '013' )

oStruV4B:RemoveField("V4B_ID")
oStruV4B:RemoveField("V4B_IDPLS")
oStruV4B:RemoveField("V4B_IDPART")

Return oView
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author  Denis S Naves
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function SaveModel(oModel)

Local lRtn := .T.
Local nOperation := oModel:GetOperation()

if nOperation <> MODEL_OPERATION_DELETE
	if FwFldGet("V4B_INDBEN") == '2' .And. Empty( FwFldGet("V4B_CODDEP") ) 
		lRtn := .F.	
		oModel:SetErrorMessage( ,,,,, STR0007, STR0008,, ) //"O código do dependente se torna obrigatório quando o Beneficiário é a opção 2-Dependente."#"Informe um código válido."
	elseif FwFldGet("V4B_TPPGTO") == '2' .And. ( Empty( FwFldGet("V4B_TPINSC") ) .Or. Empty( FwFldGet("V4B_NRINSC" ) ) )
		lRtn := .F.
		oModel:SetErrorMessage( ,,,,, STR0009, STR0010,, ) //"O Tipo e Nr° de Inscrição do Prestador de Serviço de Assistência Médica se torna obrigatório quando Tipo Pagamento = 2-Reembolso" #"Preencha o(s) campo(s) necessário(s)."
	endif
endif

if lRtn
	Begin Transaction
		FwFormCommit( oModel )
	End Transaction
endif

Return lRtn
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafPctV4B

Ajusta picture do campo V4B_NRINSC de acordo com o tipo (F/J)
Função chamada no X3_VALID - Exibição no Cadastro

@param  cTipPes - Tipo Pessoa
@return .T.

@author  Denis Souza
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafPctV4B( cTipPes )

Local aSaveLine := {}
Local oView 	:= Nil
Local oModel 	:= Nil
Local alGetV4B  := {}
Local oStruV4B  := Nil 

If !IsBlind()
	alGetV4B  := V4B->( GetArea() )
	aSaveLine := FWSaveRows()    //Salvando a posicao da linha original para restaurar ao final do processamento.
	oModel	  := FWModelActive() //Recuperando o model ativo da interface
	oView 	  := FWViewActive()  //Recuperando a view ativa da interface
	oStruV4B  := FWFormStruct( 2, 'V4B' )

	If  cTipPes == '1'		//Juridica
		FwFldPut("V4B_TPINSC" , &(ReadVar()))
		FwFldPut("V4B_NRINSC" , Space(14))
		oStruV4B:SetProperty( 'V4B_NRINSC'	, MVC_VIEW_PICT, '@R 99.999.999/9999-99')
	
	ElseIf cTipPes == '2'	//Fisica
		FwFldPut("V4B_TPINSC" , &(ReadVar()))
		FwFldPut("V4B_NRINSC" , Space(11))
		oStruV4B:SetProperty( 'V4B_NRINSC'	, MVC_VIEW_PICT, '@R 999.999.999-99')
	EndIf
	oview:Refresh( 'VIEW_V4B' )

	//Restaurando a linha original
	FWRestRows( aSaveLine )
	RestArea( alGetV4B )
EndIf

Return .T.
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVlV3R
Validacao de código do dependente

@param  
@return lRet
@author  Denis Souza
@since   15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafVlV3R()

Local lRet := .T.
Local alGetV3R := V3R->( GetArea() )

If !IsBlind()
	dbSelectArea("V3R")
	V3R->(dbSetOrder(1)) //V3R_FILIAL+V3R_ID+V3R_CODIGO

	if !Empty( M->V4B_CODDEP )
		if !V3R->( DbSeek( xFilial("V3R") + (FwFldGet("V4B_IDPART")) + M->V4B_CODDEP ) )
			lRet := .F.
			Help("",1,"Help","Help",STR0011 + AllTrim( FwFldGet("V4B_CODPAR") ) , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0008}) //"O código do dependente não foi vinculado ao participante: "#"Informe um código válido."
		endif
	endif

	RestArea( alGetV3R )
endif

Return lRet
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} VfCgc

Ajusta picture do campo V4B_NRINSC de acordo com o tipo (F/J)
Função chamada no Form Variável - Exibição na Browse

@param  cTipPes - Tipo Pessoa
@return .T.

@author  Denis Souza
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function VfCgc(cTipPes)

Local cPict := ""

if Empty( cTipPes )
	cTipPes := &(ReadVar())
endif

If cTipPes == "1" //Jurídica
	cPict := "@R 99.999.999/9999-99"
ElseIf cTipPes == "2" //Física
	cPict := "@R 999.999.999-99"
EndIf
cPict := cPict + "%C"

Return cPict
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafV4BCGC

Valida o CNPJ ou CPF de acordo com o tipo V4B_TPINSC

@param  
@return lRet

@author  Denis Souza
@since   10/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafV4BCGC()

Local lRet 	 := .F.

If !IsBlind()
	//Tratamento P/ limpar o Nr quando selecionado Vazio no Tipo
	if Empty(FwFldGet("V4B_TPINSC"))
		FwFldPut("V4B_NRINSC", Space(14) )
		FwFldPut("V4B_TPINSC", " " )
	endif 

	if "V4B_TPINSC" $ ReadVar() .And. &(ReadVar()) == '1' //CNPJ
		if !Empty(FwFldGet("V4B_NRINSC")) 
			if CGC(Padr(AllTrim(FwFldGet("V4B_NRINSC")),14,"X"))
				lRet := .T.
			endif
		else
			lRet := .T.
		endif		
	elseif "V4B_TPINSC" $ ReadVar() .And. &(ReadVar()) == '2' //Fisico
		if !Empty(FwFldGet("V4B_NRINSC")) 
			if ChkCPF( AllTrim(FwFldGet("V4B_NRINSC")) )
				lRet := .T.
			endif
		else
			lRet := .T.
		endif
	elseif "V4B_NRINSC" $ ReadVar() .And. FwFldGet("V4B_TPINSC") == "1" //CNPJ
		if !Empty( &(ReadVar())) 
			if CGC(PadR(AllTrim(&(ReadVar())),14,"X"))
				lRet := .T.
			endif
		else
			lRet := .T.
		endif
	elseif "V4B_NRINSC" $ ReadVar() .And. FwFldGet("V4B_TPINSC") == "2" //Fisico
		if !Empty( &(ReadVar()) ) 
			if ChkCPF(AllTrim(&(ReadVar())))
				lRet := .T.
			endif
		else
			lRet := .T.
		endif
	elseif "V4B_NRINSC" $ ReadVar() .And. Empty( FwFldGet("V4B_TPINSC") )
		Help("",1,"Help","Help",STR0005, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006}) //"O Tipo de Inscrição não foi preenchido."##"Informe o campo Tp Insc Adv"
	else
		lRet := .T.
	endif
else
	lRet := .T.
endif

Return lRet
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVlV4B
Validacao de campo para proteger erro de chave duplicada
V4B_FILIAL+V4B_CNPJ+DTOS(V4B_DTPGTO)+V4B_INDBEN+V4B_CODPAR+V4B_CODDEP+V4B_TPPGTO

@param  
@return lRet
@author  Denis Souza
@since   15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafVlV4B()

Local lRet 		:= .T.
Local alGetV4B 	:= V4B->( GetArea() )

If !IsBlind()
	dbSelectArea("V4B")
	V4B->(dbSetOrder(2)) //V4B_FILIAL+V4B_CNPJ+DTOS(V4B_DTPGTO)+V4B_INDBEN+V4B_CODPAR+V4B_CODDEP+V4B_TPPGTO

	//Tratamento protecao chave duplicada
	if V4B->( DbSeek( xFilial("V4B") + FwFldGet("V4B_CNPJ") + Dtos(FwFldGet("V4B_DTPGTO")) + FwFldGet("V4B_INDBEN") + FwFldGet("V4B_CODPAR") + FwFldGet("V4B_CODDEP") + FwFldGet("V4B_TPPGTO") ) )
		if V4B->V4B_ID <> FwFldGet("V4B_ID")
			lRet := .F.
			Help("",1,"Help","Help",STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013})//"O conteúdo preenchido forma uma chave já cadastrada."#"Informe outro contéudo."
		endif
	endif

	RestArea( alGetV4B )
endif

Return lRet
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} ParDepV4B
Tratamento P/ limpar o Cod Dependente quando Alterado o Participante

@param  
@return  lRet
@author  Denis Souza
@since   15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function ParDepV4B()

Local cCodPar := V4B->V4B_CODPAR

if cCodPar <> FwFldGet("V4B_CODPAR")
	FwFldPut("V4B_CODDEP", Space(6) )
endif

Return .T.
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVlDep
Valida Preenchimento do Campo V4B_CODDEP

@param  
@return  lRet
@author  Denis Souza
@since   15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafVlDep()

Local lRtn := .T.

If !IsBlind()
	if FwFldGet("V4B_INDBEN") == '2' .And. Empty( M->V4B_CODDEP ) //Dependente	
		lRtn := .F.
		Help("",1,"Help","Help",STR0014, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0008}) //"O código do dependente se torna obrigatório quando o Beneficiário é a opção 2-Dependente."#"Informe um código válido."
	endif
endif

Return lRtn
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVTpIn
Valida Preenchimento do Campo V4B_TPINSC

@param  
@return  lRtn
@author  Denis Souza
@since   15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafVTpIn()

Local lRtn := .T.

If !IsBlind()
	if FwFldGet("V4B_TPPGTO") == '2' .And. Empty( M->V4B_TPINSC ) //Reembolso	
		Help("",1,"Help","Help",STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) //"O Tipo de Inscrição do Prestador de Serviço de Assistência Médica se torna obrigatório quando Tipo Pagamento = 2-Reembolso"#"Preencha os campos necessários."
		lRtn := .F.
	endif
endif

Return lRtn
*/
//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVNrIn
Valida Preenchimento do Campo V4B_NRINSC

@param  
@return  lRtn
@author  Denis Souza
@since   15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Function TafVNrIn()

Local lRtn := .T.

If !IsBlind()
	if FwFldGet("V4B_TPPGTO") == '2' .And. Empty( M->V4B_NRINSC ) //Reembolso	
		Help("",1,"Help","Help",STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) //"O N° de Inscrição do Prestador de Serviço de Assistência Médica se torna obrigatório quando Tipo Pagamento = 2-Reembolso"#"Preencha os campos necessários."
		lRtn := .F.
	endif
endif

Return lRtn
*/
/*/{Protheus.doc} TAF539Dep
Função utilizada para verificar a existencia do dependente na base de dados T0003AB
                
@author Henrique Pereira
@since 30/07/2019
@version 1.0
*/
/*
function TAF539Dep(cDep, cIdPart)
local cRet      as character
local cAlias    as character

default cDep 	:= '' 
default cIdPart := ''

cRet	:= ''   

	if TAFAlsInDic("V3R") .and. !empty(cDep) .and. !empty(cIdPart)
		//-----------------------------------------------
		// Inicialização variáveis do tipo caracter 
		//-----------------------------------------------
		cAlias      :=  getnextalias()
		cRet    := ''

			if len(cIdPart) < 36 .and. !empty(cIdPart)
				cIdPart := POSICIONE("C1H",1,XFILIAL("C1H")+cIdPart,"C1H_ID") 
			endif

			beginsql alias cAlias
				SELECT V3R.V3R_CODIGO  
				FROM %TABLE:V3R% V3R
				
				WHERE V3R.D_E_L_E_T_        <> %Exp:'*'% 
					AND V3R.V3R_FILIAL    = %xFilial:V3R%
					AND V3R.V3R_ID        =  %Exp:cIdPart%
					AND V3R.V3R_CODIGO    =  %Exp:cDep%
			endsql 

			(cAlias)->(DbGoTop())
			if (cAlias)->(!EOF())
				cRet := (cAlias)->V3R_CODIGO
			endif
	endif
return(cRet)
*/