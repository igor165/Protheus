#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU06D01.CH'

/*/{Protheus.doc} RU06D01


@author Andrews Egas
@since 22/12/2016
@version P10
/*/
Function RU06D01()
Local oBrowse

// Initalization of tables, if they do not exist.
DBSelectArea("FIZ")
FIZ->(DbSetOrder(1))
DBSelectArea("F42")
F42->(DbSetOrder(1))

If pergunte('RU06D01',.T.)
	If MV_PAR01 == 1
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('FIZ')
		oBrowse:SetDescription(STR0012) // FI SIGNERS
		oBrowse:Activate()
	Else
		RU06D01a() //Call Function Report x Signers	
	EndIf

EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003	 		ACTION 'VIEWDEF.RU06D01' OPERATION 2 ACCESS 0 // View
ADD OPTION aRotina TITLE STR0002    		ACTION 'VIEWDEF.RU06D01' OPERATION 3 ACCESS 0 // Add
ADD OPTION aRotina TITLE STR0004    		ACTION 'VIEWDEF.RU06D01' OPERATION 4 ACCESS 0 // Edit
ADD OPTION aRotina TITLE STR0005    		ACTION 'VIEWDEF.RU06D01' OPERATION 5 ACCESS 0 // Delete

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFIZ := FWFormStruct( 1, 'FIZ', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruF42 := FWFormStruct( 1, 'F42')
Local oModel
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('RU06D01', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )


oModel:AddFields( 'FIZMASTER', /*cOwner*/, oStruFIZ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 	'F42DETAIL', 'FIZMASTER', oStruF42, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetPrimaryKey( { "FIZ_FILIAL", "FIZ_COD"} )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'F42DETAIL', {{ 'F42_FILIAL', 'xFilial( "F42" )' },  { 'F42_ROLE', 'FIZ_COD' }}, F42->( IndexKey( 1 ) ) )

oModel:GetModel( 'F42DETAIL' ):SetUniqueLine( { 'F42_REPORT','F42_ITEM' } )


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0012 )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FIZMASTER' ):SetDescription( STR0012 )
oModel:GetModel( 'F42DETAIL' ):SetDescription( STR0011 )
// Liga a validasso da ativacao do Modelo de Dados
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'RU06D01' )
// Cria a estrutura a ser usada na View
Local oStruFIZ 	:= FWFormStruct( 2, 'FIZ' ) 
Local oStruF42 := FWFormStruct( 2, 'F42' )
Local oView

oStruFIZ:SetNoFolder()
oStruF42:RemoveField("F42_ROLE")

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados sers utilizado
oView:SetModel( oModel )


//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 	'FIELD_FIZ', oStruFIZ, 'FIZMASTER' )
oView:AddGrid( 	'GRID_F42', oStruF42, 'F42DETAIL')

oView:AddIncrementField('GRID_F42','F42_ITEM')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 30 )
oView:CreateHorizontalBox( 'TELA2' , 70 )


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'FIELD_FIZ', 'TELA' )
oView:SetOwnerView( 'GRID_F42', 'TELA2' )


Return oView

Function R0601aVld()
Local lRet
Local oModelDT := FwModelActive()
Local oDetail := oModelDT:GetModel('F42DETAIL')
Local cReadVar := ReadVar()
Local cCampo := If("DFROM" $ cReadVar, "F42_DATETO", "F42_DFROM")

lRet	:= Vazio() .Or. oDetail:GetValue("F42_DFROM") <= oDetail:GetValue("F42_DATETO") .Or. Empty(oDetail:GetValue(cCampo))

Return lRet

/*/{Protheus.doc} ChkSigAcc
ChkSigAcc must check if chief acc. can sign this report or not.
@author felipe.morais
@since 28/09/2017
@version undefined

@type function
/*/

Function ChkSigAcc(dDate as date, cReport As Char)
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array
Default cReport	:= "TORG12"
DEFAULT dDate  := Ctod("//")
if EMPTY(dDate)
    dDate := Iif(Empty(F35->F35_PDATE),dDataBase,F35->F35_PDATE)
endif


lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

cReport	+= "|ALL|"

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "CHFACC")
		If (AllTrim(F42->F42_REPORT) $ cReport)
			If ((dDate >= F42->F42_DFROM) .And. (dDate <= F42->F42_DATETO))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} ChkSigDir
ChkSigDir must check if chief dir. can sign this report or not.
@author felipe.morais
@since 28/09/2017
@version undefined

@type function
/*/

Function ChkSigDir(dDate as date, cReport As Char)
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array
Default cReport	:= "TORG12"
DEFAULT dDate  := Ctod("//")

if EMPTY(dDate)
    dDate := Iif(Empty(F35->F35_PDATE),dDataBase,F35->F35_PDATE)
endif


lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

cReport	+= "|ALL|"

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "CHFDIR")
		If (AllTrim(F42->F42_REPORT) $ cReport)
			If ((dDate >= F42->F42_DFROM) .And. (dDate <= F42->F42_DATETO))
				lRet := .T.
			Endif
		Endif

	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} ChkSigStc
ChkSigStc must check if stockman can sign this report or not.
@author felipe.morais
@since 28/09/2017
@version undefined

@type function
/*/

Function ChkSigStc()
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array

lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "STCMAN")
		If (FwIsInCallStack("RU02R01") .Or. FwIsInCallStack("MATA101N"))
			If (AllTrim(F42->F42_REPORT) $ "M4|ALL|")
				If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO))
					lRet := .T.
				Endif
			Endif
		Else
			If (AllTrim(F42->F42_REPORT) $ "TORG12|ALL|")
				If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO))
					lRet := .T.
				Endif
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)



/*/{Protheus.doc} ChkSigDir
ChkSigDir must check if chief dir. can sign this report or not.
@author Nikitenko Artem
@since 16/03/2018
@version undefined

@type function
/*/

Function ChkCHMCOM()
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array

lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "CHMCOM")
		If (AllTrim(F42->F42_REPORT) $ "TORG-1|TORG-2|M-7|ALL|")
			If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} ChkSigDir
ChkSigDir must check if chief dir. can sign this report or not.
@author Nikitenko Artem
@since 16/03/2018
@version undefined

@type function
/*/

Function ChkMEMCOM()
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array

lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "MEMCOM")
		If (AllTrim(F42->F42_REPORT) $ "TORG-1|TORG-2|M-7|ALL|")
			If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)



/*/{Protheus.doc} SRAoverFIL
This function provides the UI for a specific standard query, which selects employees over all the filials.
@author artem.kostin
@since 11/06/2018
@type function
/*/
Function SRAoverFIL()
Static cEmplCode := ""
Static cEmplName := ""

Local cQuery := ""
Local lRet := .T.
Local oDlg := nil
Local aIndex := {}
Local aSeek   := {}

Local bOk := { || TRB->(dbGoTo(oBrowse:At())),;
				cEmplCode := TRB->RA_MAT,;
				cEmplName := SubStr(TRB->RA_NSOCIAL,1,GetSX3Cache("F42_NAME", "X3_TAMANHO")),;
				oDlg:End();
			}

cQuery := " select RA_FILIAL, RA_MAT, RA_NOME, RA_NSOCIAL from " + RetSQLName("SRA") + " where d_e_l_e_t_ = ' ' order by ra_filial, ra_mat, RA_NOME;"

Aadd( aIndex, "RA_FILIAL" )
Aadd( aIndex, "RA_MAT" )
Aadd( aIndex, "RA_NOME" )

Aadd( aSeek, { "Filial + Code" , {;
	{"","C",GetSX3Cache("RA_FILIAL", "X3_TAMANHO"),0,STR0008};
	,{"","C",GetSX3Cache("RA_MAT", "X3_TAMANHO"),0,STR0009};
	} } )
Aadd( aSeek, { "Filial + Name + Code" , {;
	{"","C",GetSX3Cache("RA_FILIAL", "X3_TAMANHO"),0,STR0008};
	,{"","C",GetSX3Cache("RA_NOME", "X3_TAMANHO"),0,STR0009};
	,{"","C",GetSX3Cache("RA_MAT", "X3_TAMANHO"),0,STR0010};
	} } )

DEFINE MSDIALOG oDlg FROM 0,0 TO 600,800 PIXEL
	DEFINE FWFORMBROWSE oBrowse DATA QUERY ALIAS "TRB" QUERY cQuery FILTER SEEK ORDER aSeek INDEXQUERY aIndex DOUBLECLICK bOk OF oDlg
		ADD BUTTON oButton TITLE "Ok" ACTION bOk OF oBrowse
		ADD BUTTON oButton TITLE "Cancel" ACTION { || oDlg:End() } OF oBrowse
		ADD COLUMN oColumn DATA { ||  RA_FILIAL  } TITLE STR0008    SIZE GetSX3Cache("RA_FILIAL", "X3_TAMANHO") OF oBrowse
		ADD COLUMN oColumn DATA { ||  RA_MAT     } TITLE STR0009    SIZE GetSX3Cache("RA_MAT", "X3_TAMANHO") OF oBrowse
		ADD COLUMN oColumn DATA { ||  RA_NOME } TITLE STR0010	SIZE 50 OF oBrowse
	ACTIVATE FWFORMBROWSE oBrowse
ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)



/*/{Protheus.doc} ret1SRAoverFIL
This function returns the content of the static variable, which holds an employee's code.
@author artem.kostin
@since 11/06/2018
@type function
/*/
Function ret1SRAoverFIL()
Return(cEmplCode)



/*/{Protheus.doc} ret2SRAoverFIL
This function returns the content of the static variable, which holds an employee's name.
@author artem.kostin
@since 11/06/2018
@type function
/*/
Function ret2SRAoverFIL()
Return(cEmplName)
