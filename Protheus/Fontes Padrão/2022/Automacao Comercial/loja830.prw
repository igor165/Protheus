#INCLUDE "Protheus.ch"
#INCLUDE "LOJA830.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 

Static lR7	:= GetRpoRelease("R7")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA830   บAutor  ณ Vendas Clientes    บ Data ณ  27/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de vales-presentes                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA830()
Local aCores :=	{{ "MDD_STATUS == '1'", "BR_VERDE"		},;		// Vale Ativo
				 	{ "MDD_STATUS == '2'", "BR_AMARELO"	},;		// Vale Vendido
				 	{ "MDD_STATUS == '3'", "BR_VERMELHO"	},;		// Vale Recebido
				 	{ "MDD_STATUS == '4'", "BR_PRETO"		},;		// Vale Inativo
				 	{ "MDD_STATUS == '5'", "BR_LARANJA"	}}		// Vale Utilizado

Private aRotina	:= MenuDef()
Private cCadastro	:= OemToAnsi(STR0001)			//"Cadastro de Vales Presentes"

If lR7
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MDD')
	AEval(aCores,{|x| oBrowse:AddLegend(x[1],x[2])}) //Atribuo a legenda ao browse.
	oBrowse:SetDescription(OemToAnsi(STR0001))
	oBrowse:Activate()
Else
	mBrowse( 6, 1,22,75,"MDD",,"MDD_STATUS",,,, aCores )
EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo de dados.

@author Vendas & CRM
@since 03/08/2012
@version 11
@return  oModel - Retorna o model com todo o conteudo dos campos preenchido

*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMDD 	:= FWFormStruct(1,"MDD") // Estrutura da tabela MDD
Local oModel 		:= Nil						// Objeto do modelo de dados

//-----------------------------------------
//Monta o modelo do formulแrio 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA830",/*Pre-Validacao*/,{|oModel| Lj830TOk(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("MDDMASTER", Nil/*cOwner*/, oStructMDD ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("MDDMASTER"):SetDescription(STR0001)  //"Cadastro de Vales Presentes"

FWMemoVirtual(oStructMDD,{{"MDD_MEMO1","MDD_MOTINA"}})

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Interface do programa

@author		Vendas & CRM
@version	11
@since 		03/08/2012
@return		oView - Retorna o objeto que representa a interface do programa

*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  		:= Nil						// Objeto da interface
Local oModel  		:= FWLoadModel("LOJA830")	// Objeto do modelo de dados
Local oStructMDD 	:= FWFormStruct(2,"MDD")	// Estrutura da tabela MDD

//-----------------------------------------
//Monta o modelo da interface do formulแrio
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "MDDMASTER" , oStructMDD )
oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "MDDMASTER" , "HEADER" )
oView:SetViewAction( 'BUTTONOK' ,{ |oView| Lj830Insert(oModel) } ) 
oView:SetAfterViewActivate({|oView| Lj830UsrBt(oView)})
                
Return oView

 //-------------------------------------------------------------------
/* {Protheus.doc} Lj830UsrBt
Funcao de criacao de botoes de usuario

@param		oView - Objeto da interface
@author		Vendas & CRM
@since		03/08/2012
@version	11 
*/
//-------------------------------------------------------------------

Static Function Lj830UsrBt(oView)
Local nOpc   	:= oView:GetOperation()	// Numero da operacao (1: Visualizacao, 3: Inclusao, 4: Alteracao, 5: Exclusao)
Local oModel 	:= FwModelActive()		// Modelo de dados Ativo 
Local aButton	:= {}						// Array com os botoes
Local nX		:= 0						// Variavel utilizada no For

oView:aUserButtons := {}

If nOpc == 4
	aAdd( aButton, { "PMSINFO", {|| LJ830Inat() }, STR0005+"/"+STR0002, STR0003} )//"Reativar Vale Presente"#"Reativar" 
EndIf

FOR nX := 1 to Len(aButton)
	oView:AddUserButton(aButton[nX][3], aButton[nX][1],aButton[nX][2]) 
Next nX

Return

//-------------------------------------------------------------------
/* {Protheus.doc} Lj830TOk
Realiza validacoes do modelo de dados

@param		oModel - Objeto do modelo de dados
@author 	Vendas & CRM
@since 		02/08/2012
@version 	11
@return		lRet - .T. se passar por todas as validacoes / .F. se houver alguma irregularidade, nao permitindo que a operacao conclua
*/
//-------------------------------------------------------------------
Function Lj830TOk(oModel)
Local lRet := .T.						// Retorno da funcao
Local nReg := MDD->(Recno())			// Registro posicionado
Local nOpc := oModel:GetOperation()	// Numero da operacao (1: Visualizacao, 3: Inclusao, 4: Alteracao, 5: Exclusao)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// Ponto de entrada para validar se permite ou nao a manutencao manual   ณ    
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("LJMANVP")
	lRet := U_LJMANVP( "MDD", nReg, nOpc )
   
	If ValType(lRet) != "L"
		lRet := .T.
	EndIf 
Endif

If lRet .AND. nOpc == 5
	lRet := LJ830VldEx()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ830Leg  บAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua as operacoes de Inclusao, Alteracao e Exclusao dos  บฑฑ
ฑฑบ          ณ vales presentes.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA830                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ830Man( cAlias, nReg, nOpc )
Local aButton	:= {}		// Array para botoes na EnchoiceBar
Local lLJMANVP	:= FindFunction("U_LJMANVP")	// Ponto de entrada para validar se permite ou nao a manutencao manual
Local lRet      := .T. 	// Retorno do p.e. lLJMANVP
Local xRet				// Retorno do Ponto de Entrada

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// Ponto de entrada para validar se permite ou nao a manutencao manual   ณ    
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lLJMANVP
	xRet := U_LJMANVP( cAlias, nReg, nOpc )
   
	If ValType(xRet) == "L"
		lRet := xRet
	EndIf
   
	If !lRet
		Return (Nil)
	Endif   
Endif

If nOpc == 3
	AxInclui( cAlias, nReg, nOpc )
ElseIf nOpc == 4
	If MDD->MDD_STATUS == "4"
		aAdd( aButton, { "PMSINFO", {|| LJ830Inat() }, STR0002, STR0003} )//"Reativar Vale Presente"#"Reativar" 
	Else
		aAdd( aButton, { "PMSINFO", {|| LJ830Inat() }, STR0004, STR0005 } )//"Inativar Vale Presente"#"Inativar"
	EndIf
	AxAltera( cAlias, nReg, nOpc,,,,,,,, aButton ) 
Else
	cDelFunc := "LJ830VldEx()"
	AxDeleta( cAlias, nReg, nOpc )
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ830Inat บAutor  ณVendas Cliente      บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inativa um vale-presente mediante senha do superior        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LJ830Man                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ830Inat()
Local cSuper	:= Space(25) 
Local oModel	:= Nil			// Objeto do modelo de dados
Local oView	:= Nil			// Objeto da interface
Local cStatus := ""			// Status do Vale-Presente

If lR7
	oModel := FwModelActive()
	oView	:= FwViewActive()
	cStatus:= oModel:GetValue("MDDMASTER","MDD_STATUS")
	
	If cStatus == "3"		// Recebido
		MsgInfo(STR0007,STR0009)//Atencao#"Este vale presente jแ foi vendido e recebido, portanto, nใo poderแ ser inativado."#"Ok"
	ElseIf LJProfile( 23, @cSuper )
		If cStatus <> "4"
			oModel:SetValue("MDDMASTER","MDD_USUINA",cUserName)
			oModel:SetValue("MDDMASTER","MDD_SUPINA",cSuper)
			oView:ValidField("MDDMASTER","MDD_STATUS","4")
			oModel:GetModel("MDDMASTER"):GetStruct():SetProperty('MDD_MOTINA', MODEL_FIELD_OBRIGAT,.T.)//Ao inativar o vale presente, o motivo eh obrigatorio.
			MsgInfo(STR0010,STR0009)//"Vale-Presente inativado com sucesso."#"Aviso"
		ElseIf cStatus == "4"
			If Empty( M->MDD_CLIV ) .AND. Empty( M->MDD_CLIR )
				oModel:SetValue("MDDMASTER","MDD_USUINA",CriaVar("MDD_USUINA"))
				oModel:SetValue("MDDMASTER","MDD_SUPINA",CriaVar("MDD_SUPINA"))
				oModel:GetModel("MDDMASTER"):GetStruct():SetProperty('MDD_MOTINA', MODEL_FIELD_OBRIGAT,.F.)
				oModel:SetValue("MDDMASTER","MDD_MOTINA","")
				oView:ValidField("MDDMASTER","MDD_STATUS","1") // A funcao valid field tambem atribui valor. A diferenca eh que o formulario reconhece a alteracao.
			ElseIf Empty( M->MDD_CLIR )
				oModel:SetValue("MDDMASTER","MDD_USUINA",CriaVar("MDD_USUINA"))
				oModel:SetValue("MDDMASTER","MDD_SUPINA",CriaVar("MDD_SUPINA"))
				oModel:SetValue("MDDMASTER","MDD_MOTINA","")
				oModel:GetModel("MDDMASTER"):GetStruct():SetProperty('MDD_MOTINA', MODEL_FIELD_OBRIGAT,.F.)			
				oView:ValidField("MDDMASTER","MDD_STATUS","2")
			EndIf
			MsgInfo(STR0011,STR0009)//"Vale-Presente reativado com sucesso."#"Aviso"
		EndIf
	Else
		MsgInfo(STR0012,STR0009)//Aviso# "Voc๊ nใo tem permissใo para inativar vales-presentes."
	EndIf

Else
	If M->MDD_STATUS == "3"		// Recebido
		Aviso( STR0006, STR0007, {STR0008} ) //Atencao#"Este vale presente jแ foi vendido e recebido, portanto, nใo poderแ ser inativado."#"Ok"
	ElseIf LJProfile( 23, @cSuper )
		If M->MDD_STATUS <> "4" .AND. LJ830MotIn( @M->MDD_MOTINA )
			M->MDD_USUINA	:= cUserName
			M->MDD_SUPINA	:= cSuper
			M->MDD_STATUS	:= "4"
			M->MDD_MEMO1    := MSMM(,80,,M->MDD_MOTINA,1,,,"MDD","MDD_MEMO1")
			MsgInfo(STR0010,STR0009)//"Aviso"#"Vale-Presente inativado com sucesso."
		ElseIf M->MDD_STATUS == "4"
			If Empty( M->MDD_CLIV ) .AND. Empty( M->MDD_CLIR )
				M->MDD_USUINA	:= Space(25)
				M->MDD_SUPINA	:= Space(25)
				M->MDD_STATUS	:= "1"
			ElseIf Empty( M->MDD_CLIR )
				M->MDD_USUINA	:= Space(25)
				M->MDD_SUPINA	:= Space(25)
				M->MDD_STATUS	:= "2"
			EndIf
			Aviso(STR0009, STR0011, {STR0008} )//Aviso#"Vale-Presente reativado com sucesso."
		EndIf
	Else
		Aviso(STR0009,STR0012, {STR0008} )//Aviso# "Voc๊ nใo tem permissใo para inativar vales-presentes."
	EndIf
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ830MotInบAutor  ณVendas Cliente      บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Solicita o motivo da inativacao do vale-presente           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LJ830Man                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJ830MotIn( cMotivo )
Local lRet		:= .F.	// Variavel de retorno
Local oDlgMot			// Objeto dialogo
Local oGrp				// Objeto grupo
Local oSay				// Label "Informe o motivo da inativa็ใo do vale-presente"
Local oMotivo			// Objeto Get para o motivo
Local oOk				// Botใo OK
Local oCancelar			// Botใo Cancelar

cMotivo := PadR( cMotivo, 255 )

oDlgMot := MSDIALOG():Create()
oDlgMot:cName := "oDlgMot"
oDlgMot:cCaption := STR0013 //"Motivo da Inativa็ใo"
oDlgMot:nLeft := 0
oDlgMot:nTop := 0
oDlgMot:nWidth := 459
oDlgMot:nHeight := 214
oDlgMot:lShowHint := .F.
oDlgMot:lCentered := .T.

oGrp := TGROUP():Create(oDlgMot)
oGrp:cName := "oGrp"
oGrp:nLeft := 8
oGrp:nTop := 8
oGrp:nWidth := 434
oGrp:nHeight := 138
oGrp:lShowHint := .F.
oGrp:lReadOnly := .F.
oGrp:Align := 0
oGrp:lVisibleControl := .T.

oMotivo := TMultiGET():Create(oDlgMot)
oMotivo:cName := "oMotivo"
oMotivo:nLeft := 15
oMotivo:nTop := 40
oMotivo:nWidth := 419
oMotivo:nHeight := 97
oMotivo:lShowHint := .F.
oMotivo:lReadOnly := .F.
oMotivo:Align := 0
oMotivo:cVariable := "cMotivo"
oMotivo:bSetGet := {|u| If(PCount()>0,cMotivo:=u,cMotivo) }
oMotivo:lVisibleControl := .T.

oOk := SBUTTON():Create(oDlgMot)
oOk:cName := "oOk"
oOk:cCaption := "Ok"
oOk:nLeft := 325
oOk:nTop := 152
oOk:nWidth := 52
oOk:nHeight := 22
oOk:lShowHint := .F.
oOk:lReadOnly := .F.
oOk:Align := 0
oOk:lVisibleControl := .T.
oOk:nType := 1
oOk:bAction := {|| If( Empty(cMotivo), Aviso(STR0006,STR0014, {STR0008}), ( lRet := .T., oDlgMot:End() ) ) }//"Aten็ใo"# "O motivo deve ser informado."# "Ok"

oCancelar := SBUTTON():Create(oDlgMot)
oCancelar:cName := "oCancelar"
oCancelar:cCaption := STR0015 //"Cancelar"
oCancelar:nLeft := 389
oCancelar:nTop := 152
oCancelar:nWidth := 52
oCancelar:nHeight := 22
oCancelar:lShowHint := .F.
oCancelar:lReadOnly := .F.
oCancelar:Align := 0
oCancelar:lVisibleControl := .T.
oCancelar:nType := 2
oCancelar:bAction := {|| oDlgMot:End() }

oSay := TSAY():Create(oDlgMot)
oSay:cName := "oSay"
oSay:cCaption := STR0016 //"Informe o motivo da inativa็ใo do vale-presente"
oSay:nLeft := 17
oSay:nTop := 17
oSay:nWidth := 260
oSay:nHeight := 17
oSay:lShowHint := .F.
oSay:lReadOnly := .F.
oSay:Align := 0
oSay:lVisibleControl := .T.
oSay:lWordWrap := .F.
oSay:lTransparent := .F.

oDlgMot:Activate()

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ830VldExบAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a exclusao do vale-presente. So permite excluir     บฑฑ
ฑฑบ          ณ quando status = Ativo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LJ830Man                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ830VldEx()
Local lRet := MDD->MDD_STATUS == "1"			// Variavel de retorno

If !lRet
	Help('',1,'INVLDSTATUS',,STR0017,1,0) //"Somente vales-presentes com status 'Ativo' podem ser excluํdos."
EndIf

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA830   บAutor  ณVendas Cliente      บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ830Lot()
Local cPerg		:= "LJA830"			// Grupo de perguntas da rotina
Local aSays		:= {}				// Matriz de 
Local aButtons	:= {}
Local lLJMANLOT	:= ExistBlock("LJMANLOT")  	// Ponto de entrada para validar se permite a geracao em lote
Local lRet      := .T. // Retorno do p.e. lLJMANLOT

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// Ponto de entrada para validar se permite a geracao em lote              บฑฑ               
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
If lLJMANLOT
   lRet :=    ExecBlock("LJMANLOT",.F.,.F.)

   If !lRet
      Return (Nil)
   Endif   
Endif                

Pergunte( cPerg, .F. )

aAdd( aSays,STR0018 )	// "Esta rotina tem como objetivo criar novos vales-presentes de"
aAdd( aSays,STR0019)	//"acordo com os parโmetros informados." 

aAdd( aButtons, { 5, .T., {|| Pergunte( cPerg, .T. ) } } )
aAdd( aButtons, { 1, .T., {|| LJ830Gera( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09  ) } } )
aAdd( aButtons, { 2, .T., {|| FechaBatch() } } )

FormBatch( STR0020, aSays, aButtons )//"Gera็ใo de vales-presentes"

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ830Gera บAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao em lote de Vales-Presentes                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Codigo para o primeiro vale-presente do lote       บฑฑ
ฑฑบ          ณ ExpC2 - Codigo para o ultimo vale-presente do lote         บฑฑ
ฑฑบ          ณ ExpC3 - Codigo do produto                                  บฑฑ
ฑฑบ          ณ ExpN4 - Valor de face dos vales                            บฑฑ
ฑฑบ          ณ ExpC5 - Loja do vale-presente                              บฑฑ
ฑฑบ          ณ ExpD6 - Data inicial de vigencia dos vales                 บฑฑ
ฑฑบ          ณ ExpD7 - Data final de vigencia dos vales                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ830Gera( cCodIni, cCodFim, cProduto, nValor, cLoja, dDataIni, dDataFim, VlrMin, VlrMax )
Local nGerados	:= 0	// Contador de vales gerados
Local nTamVales   := TamSX3("MDD_CODIGO")[1]   		// Tamanho do campo Vale Presente na Base de Dados    
Local nTamcCods   := Iif(Len(Alltrim(cCodIni))>Len(Alltrim(cCodFim)),Len(Alltrim(cCodIni)),Len(Alltrim(cCodFim))) // Pega o tamanho da variavel maior
Local lTemZeroEsq := If(Substr(Alltrim(cCodIni),1,1)=="0" .Or. Substr(Alltrim(cCodFim),1,1)=="0",.T.,.F.)		  // Verifica se um dos parametros tem zeros a esquerda

Default VlrMin := 0
Default VlrMax := 0
	
// Inseridos Zeros a esquerda com finalidade de fazer as comparacoes corretamente
// Na gravacao da tabela MDD esta sendo tratado a gravacao com Zeros e sem Zeros, dependendo do que foi digitado nos parametros.
cCodIni := Padl(Alltrim(cCodIni),nTamVales,"0")
cCodFim := Padl(Alltrim(cCodFim),nTamVales,"0")

// Valida o preenchimento de todos os parametros
If Empty( cCodIni ) .OR. Empty( cCodFim ) .OR. Empty( cProduto ) .OR. Empty( nValor ) .OR.;
   Empty( cLoja ) .OR. Empty( dDataIni ) .OR. Empty( dDataFim )
	Aviso( STR0006, STR0021, {STR0008} )//Aten็ใo#"Todos os parโmetros devem ser informados."#"Ok"
	Return .F.
EndIf

// Valida codigos inicial e final
If cCodIni > cCodFim
	Aviso( STR0008, STR0022, {STR0008} )//Atencao#"O c๓digo do vale presente inicial nใo pode ser maior que o c๓digo final."#OK
	Return .F.
EndIf

// Valida o codigo do produto
SB1->( dbSetOrder(1) )
If SB1->( !dbSeek( xFilial("SB1")+cProduto ) )
	Aviso( STR0008,STR0023 , {STR0008} )//Aten็ใo#"Produto nใo encontrado no cadastro do Controle de Lojas."#Ok
	Return .F.
ElseIf SB1->B1_VALEPRE <> "1"
	Aviso( STR0008,STR0024+Alltrim(cProduto)+STR0025, {STR0008} )//Aten็ใo# "O produto "" nใo estแ configurado como vale-presente."
	Return .F.
EndIf

// Valida datas de vigencia
If dDataIni > dDataFim
	Aviso( STR0008,STR0026 , {STR0008} )//Aten็ใo#"A data de vig๊ncia inicial nใo pode ser maior que a data do fim da vig๊ncia."#Ok
	Return .F.
EndIf

// Inicia o processamento
Processa( {|lEnd| nGerados := RunIt( @lEnd, cCodIni, cCodFim, cProduto, nValor, cLoja, dDataIni, dDataFim, nTamcCods, lTemZeroEsq, VlrMin, VlrMax ) },STR0027,, .T. )//"Gera็ใo de vales-presente"

If nGerados == 1
	Aviso( STR0028,STR0029, {STR0008} )//"Processo concluํdo"#"1 vale-presente gerado com sucesso."
ElseIf nGerados > 1
	Aviso( STR0028, Alltrim(Str(nGerados))+STR0038, {STR0008} )//"Processo concluํdo"#"  vales-presente gerados com sucesso."
Else
	Aviso( STR0008,STR0030, {STR0008} )//Aten็ใo#"Nenhum vale-presente foi gerado. Revise os parโmetros."
EndIf

Return nGerados > 0



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunIt     บAutor  ณ Vendas Clientes    บ Data ณ  27/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da gera็ใo de vales-presentes                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LJ830Gera                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RunIt( lEnd, cCodIni, cCodFim, cProduto, nValor, cLoja, dDataIni, dDataFim, nTamcCods, lTemZeroEsq, VlrMin, VlrMax )
Local nGerados		:= 0		// Contador de vales presentes gerados
Local cCodValePre 	:= ""       // Codigo do Vale Presente

Default VlrMin := 0
Default VlrMax := 0

ProcRegua( Val( cCodFim ) - Val( cCodIni ) + 1 )

MDD->( dbSetOrder(1) )

While cCodIni <= cCodFim .AND. !lEnd
	
	IncProc(STR0031)//"Gerando vales-presente..."
	
	If !lTemZeroEsq
		cCodValePre	:= Alltrim( Right(cCodIni,nTamcCods) ) // Se nao tem Zeros a esqueda, ้ retirado os Zeros de cCodIni
	Else
		cCodValePre	:= Padl( Alltrim(Right(cCodIni,nTamcCods)) ,nTamcCods,"0" ) // Se tem Zeros ้ gravado de acordo com nTamcCods
	Endif	
		                             
	If MDD->( !dbSeek( xFilial("MDD")+cCodValePre ) )
		RecLock("MDD", .T.)                                 
		MDD->MDD_FILIAL	:= xFilial("MDD")                   
		// Inicialmente as variaveis cCodIni e cCodFim chegam da funcao LJ830Gera com zeros a esquerda de acordo com o tamanho do campo na base.
		// Aqui verifica se na "DIGITACAO" dos parametros foram colocados zeros a esquerda.
		// Se nao foi digitado zeros, ้ retitado da variavel cCodIni na gravacao no momento de gravar.
		// Se foi digitado zeros a esquerda, ้ gravado conforme a quantidade de digitos informado nos paramentros.

		MDD->MDD_CODIGO	:= cCodValePre
		MDD->MDD_PROD	:= cProduto
		MDD->MDD_LOJA	:= cLoja
		MDD->MDD_VALOR	:= nValor
		MDD->MDD_STATUS	:= "1"				// Ativo
		MDD->MDD_USUCAD	:= cUserName
		MDD->MDD_DTINI	:= dDataIni
		MDD->MDD_DTFIM	:= dDataFim
		MDD->MDD_VALDE   := VlrMin
		MDD->MDD_VALATE  := VlrMax
		
		
		MDD->( msUnlock() )

		nGerados++
	EndIf
	
	cCodIni := PadR( Soma1( Alltrim( cCodIni ) ), Len( cCodIni ) )
End

Return nGerados



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLl830VlProบAutor  ณ Vendas Cliente     บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o codigo do produto informado esta relacionado   บฑฑ
ฑฑบ          ณ a um produto valido e que esteja como Vale Presente = Sim  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA830                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj830VlPro()
Local lRet	:= ExistCpo("SB1")			// Variavel de retorno

If lRet
	lRet := Posicione( "SB1", 1, xFilial("SB1")+&(ReadVar()), "B1_VALEPRE" ) == "1"
	
	If !lRet
		Help('',1,'PRODINVLD',,STR0032,1,0)
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLl830VlValบAutor  ณ Vendas Cliente     บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o valor de face do vale-presente bate exatamente บฑฑ
ฑฑบ          ณ com o preco de venda 1 do produto na SB0.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Em caso de divergencia, apenas alerta, mas nao impede.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA830                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj830VlVal( cProd, nValor )
Local nResp    
Local lRet      := .T.
Local lLjValVp  := SuperGetMV("MV_LJVALVP",, .T.)
Local nPrcPrd   := 0        
Local lCenVenda := SuperGetMv("MV_LJCNVDA",,.F.)	//Integra com cenario de vendas
                         
If lCenVenda
	LjxeValPre(@nPrcPrd, cProd, /*cCliente*/, /*cLoja*/)
	
	If !Empty( cProd ) .AND. nValor <> nPrcPrd
		If lLjValVp  // Permite valor divergente entre a tabela de pre็o e o valor de face do Vale presente
			nResp := Aviso( STR0008, STR0033+Alltrim(Transform(nPrcPrd,"@E 999,999.99")), {STR0034,STR0035} )
			//Aten็ใo#"O valor de face informado nใo corresponde ao valor de venda do produto ("#"). Deseja prosseguir com o valor divergente?"#Sim#Nใo
	  	  	lRet  := (nResp == 1)  	  
		Else
			MsgInfo(STR0036+Alltrim(Transform(nPrcPrd,"@E 999,999.99"))+STR0037, STR0009)      
	      	//Aten็ใo#"O valor de face informado nใo corresponde ao valor de venda do produto ("#")."
	      	lRet := .F.
		Endif 	
	EndIf      
	
Else	
	If !Empty( cProd ) .AND. nValor <> Posicione( "SB0", 1, xFilial("SB0")+cProd, "B0_PRV1" )
		If lLjValVp  // Permite valor divergente entre a tabela de pre็o e o valor de face do Vale presente
			nResp := Aviso( STR0008, STR0033+Alltrim(Transform(SB0->B0_PRV1,"@E 999,999.99")), {STR0034,STR0035} )
	  	  	//Aten็ใo#"O valor de face informado nใo corresponde ao valor de venda do produto ("#"). Deseja prosseguir com o valor divergente?"#Sim#Nใo
	  	  	lRet  := (nResp == 1)  	  
		Else  
			MsgInfo(STR0036+Alltrim(Transform(nPrcPrd,"@E 999,999.99"))+STR0037, STR0009)        
	      	//Aten็ใo#"O valor de face informado nใo corresponde ao valor de venda do produto ("#")."
	      	lRet := .F.
		Endif 	
	EndIf      
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ830Leg  บAutor  ณ Vendas Clientes    บ Data ณ  26/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe a legenda de cores da mBrowse                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA830                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ830Leg()

BrwLegenda( cCadastro, "Legenda", {	{ "BR_VERDE"	, "Ativo"		},;
									{ "BR_AMARELO"	, "Vendido"		},;
									{ "BR_VERMELHO"	, "Recebido"	},;
									{ "BR_LARANJA"	, "Utilizado"	},;
									{ "BR_PRETO"	, "Inativo"		} } )
	
Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Vendas Clientes       ณ Data ณ 26/03/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ    1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {}

If lR7
	ADD OPTION aRotina TITLE STR0039 ACTION "PesqBrw"      	OPERATION 0                                                                                                     ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0040 ACTION "VIEWDEF.LOJA830"	OPERATION MODEL_OPERATION_VIEW   	ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0041 ACTION "VIEWDEF.LOJA830" 	OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0042 ACTION "VIEWDEF.LOJA830"	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0043 ACTION "VIEWDEF.LOJA830"	OPERATION MODEL_OPERATION_DELETE	ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0044 ACTION "LJ830Lot"     	OPERATION 3    						ACCESS 0 //"Gerar Lote"
	ADD OPTION aRotina TITLE STR0045 ACTION "LJ830Leg"     	OPERATION 0    	 					ACCESS 0 //"Legenda"
Else
	aRotina :=  { 	{ STR0039	, "AxPesqui", 0, 1 },;
						{ STR0040	, "AxVisual", 0, 2 },;
						{ STR0041	, "LJ830Man", 0, 3 },;
						{ STR0042	, "LJ830Man", 0, 4 },;
						{ STR0043	, "LJ830Man", 0, 5 },;
						{ STR0044	, "LJ830Lot", 0, 3 },;
						{ STR0045	, "LJ830Leg", 0 ,2 } }
EndIf

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} Lj830Insert
Atualiza็ใo de campos adicionais

@param  oModel  Model
@author  Varejo
@version P1180
@since   07/01/2015
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj830Insert(oModel)

Local aArea		:= GetArea()	// Guarda area corrente
Local nOperation	:= oModel:GetOperation()	//Operacao executada no modelo de dados.
	
If nOperation == MODEL_OPERATION_INSERT .AND. SuperGetMv("MV_LJBXPAR",,.F.) .And. MDD->(FieldPos("MDD_SALDO")) > 0
	RecLock( "MDD", .F. )
	/* 
		Atualiza o campo MDD_SALDO com o conteudo do MDD_VALOR para realizar
		os calculos do vale presente caso esteja ativo o parametro 
		MV_LJBXPAR (baixa parcial) 
	*/
	MDD->MDD_SALDO	:= M->MDD_VALOR
	MsUnLock()
EndIf
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} Lj830VldMDD
Valida campo Vlr Max e Vlr Min da tabela MDD

@param   
@author  Varejo
@version P1180
@since   14/04/2015
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj830VldMDD()

Local lRet := .F.
	
If MDD->(FieldPos("MDD_VALATE")) > 0 .AND. MDD->(FieldPos("MDD_VALDE")) > 0

	If M->MDD_VALATE <= M->MDD_VALDE
		HELP(,,"Vlr Max",,STR0046,1,0) //O Vlr Max nใo pode ser menor ou igual que o Vlr Min.
	Else 	
		lRet := .T.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} Lj830VldX1
Valida campo Vlr Max e Vlr Min da tabela SX1

@param   
@author  Varejo
@version P1180
@since   14/04/2015
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj830VldX1(mv_par08,mv_par09)

Local lRet := .F. //Variavel de retorno

Default mv_par08 := 0
Default mv_par09 := 0
	
If SuperGetMV("MV_LJVPVAR",,.F.)
	If mv_par08 > 0 .AND. mv_par09 > 0
	
		If mv_par09 <= mv_par08
			HELP(,,"Vlr Max",,STR0046,1,0) //O Vlr Max nใo pode ser menor ou igual que o Vlr Min.
		Else 	
			lRet := .T.
		EndIf
	
	EndIf
Else
	lRet := .T.	
EndIf	

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Lj830VldVP
Valida sele็ใo do campo do tipo do vale presente.

@param   oMdl		- Formulario da rotina
@param   cCampo	- Nome do campo da valida็ใo
@param   cNewInfo	- Nova informa็ใo do campo
@param   cOldInfo	- Antiga informa็ใo do campo
@author  Varejo
@version P12.1.7
@since   30/03/2016
@return  lRet = .T. - Valida็ใo ok / .F. - Campo invalido.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj830VldVP(oMdl,cCampo,cNewInfo,cOldInfo)
Local lRet			:= .T.
Local cCodProd	:= ""
Local cDescProd	:= ""

Default oMdl		:= Nil
Default cNewInfo	:= "P"

If ValType(oMdl) == "O" .And. cNewInfo == "C"
	cCodProd := oMdl:GetValue("MDD_PROD")
	If !Empty(cCodProd)
		cDescProd := Posicione("SB1",1,xFilial("SB1")+AllTrim(cCodProd),"B1_DESC")
	EndIf 
	If (Empty(cDescProd) .Or. !("VALE PRESENTE" $ UPPER(cDescProd) .Or. "VALE CREDITO" $ UPPER(cDescProd)))
		lRet := .F.
		MsgInfo(STR0047 + CHR(10)+CHR(13) +; //"Para vale do tipo 'Cr้dito' a descri็ใo do produto do tipo vale presente deve conter o seguinte texto: 'vale presente' ou 'vale credito'."
				STR0048  + iIf(!Empty(cDescProd),cDescProd,STR0049) + Replic(CHR(10)+CHR(13),2) +; //"Descri็ใo atual do produto: " #"Produto nใo informado!"
				STR0050, STR0051) //"Favor efetuar os devidos ajustes." #"Aten็ใo"
	Endif
EndIf

Return lRet
