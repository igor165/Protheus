#Include 'TmsA390.ch'
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH" 

/*{Protheus.doc} ViewDef
    @type Static Function
    @author Felipe Barbiere
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA390() - Prazos de Regiões
    (examples)
    @see (links_or_references)
*/
Function TMSA390(aRotAuto, nOpcAuto)

Private lMsHelpAuto := .F.
Private l390Auto    := ( Valtype(aRotAuto) == "A" )
Private aRotina     := MenuDef()

If l390Auto
	lMsHelpAuto := .T.
    FwMvcRotAuto(ModelDef(), "DTD", nOpcAuto, {{"MdFieldDTD", aRotAuto}},.T.,.T.)	 //-- Chamada da rotina automatica atraves do MVC
Else
	oBrowse:= FwMBrowse():New()
	oBrowse:SetAlias("DTD")
	oBrowse:SetDescription(OemToAnsi(STR0001))	//'Prazos de Regioes'
	oBrowse:Activate()
EndIf

Return NIL

/*{Protheus.doc} Modeldef
    @type Static Function
    @author Felipe Barbiere
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA390()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel   := Nil
Local oStruDTD := FwFormStruct(1,"DTD")
Local lDMO	   := AliasIndic("DMO")
Local oStruDMO := IIf(lDMO, FwFormStruct(1,"DMO"), "")

oModel:= MpFormModel():New("TMSA390",/*bPre*/,{||TMSA390TOk(oModel)} /*bPos*/,/*bCommit*/,/*bCancel*/)

oModel:SetDescription(OemToAnsi(STR0001)) //'Prazos de Regioes'

oModel:AddFields("MdFieldDTD",Nil, oStruDTD)

If lDMO
	oModel:AddGrid('MdGridDMO', 'MdFieldDTD', oStruDMO, /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/, /*BLoad*/ )
	oModel:SetRelation("MdGridDMO", {{ "DMO_FILIAL", "xFilial( 'DMO' )"},  { "DMO_CDRORI", "DTD_CDRORI" },  { "DMO_CDRDES", "DTD_CDRDES" },  { "DMO_TIPTRA", "DTD_TIPTRA" } }, DMO->(IndexKey(1)))
	oModel:GetModel("MdGridDMO"):SetUniqueLine( { "DMO_SERVIC"} )
	oModel:GetModel( "MdGridDMO" ):SetOptional( .T. )
EndIf

oModel:GetModel("MdFieldDTD"):SetDescription(STR0001)	//'Prazos de Regioes'
oModel:SetPrimaryKey({"DTD_FILIAL","DTD_CDRORI","DTD_CDRDES","DTD_TIPTRA"})

Return (oModel)

/*{Protheus.doc} ViewDef
    @type Static Function
    @author Felipe Barbiere
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA390()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()                  
Local oView    := Nil
Local oModel   := FwLoadModel("TMSA390")
Local oStruDTD := FwFormStruct(2,"DTD")
Local lDMO	   := AliasIndic("DMO")
Local oStruDMO := IIf(lDMO, FwFormStruct(2,"DMO"), "")
                                 
oView:= FwFormView():New()   

oView:SetModel(oModel)

oView:AddField("VwFieldDTD",oStruDTD,"MdFieldDTD") 

If lDMO
	oView:AddGrid ( 'VwGridDMO', oStruDMO , 'MdGridDMO' )
	oView:CreateHorizontalBox( 'Field'  , 60 )
	oView:CreateHorizontalBox( 'DETDMO' , 40 )
	oView:SetOwnerView("VwFieldDTD","Field")
	oView:SetOwnerView( 'VwGridDMO' , 'DETDMO' )
Else
	oView:CreateHorizontalBox("Field", 100)
EndIf

oView:EnableTitleView("VwFieldDTD", STR0001)	//'Prazos de Regioes'

Return (oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA390TOk ³ Autor ³ Antonio C Ferreira   ³ Data ³10.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA390TOk(oModel)

Local aAreaDTD := DTD->( GetArea() )
Local aAreaDVN := DVN->( GetArea() )
Local lRet     := .T.
Local nReg     := if(!INCLUI, Recno(), 0)
Local nOper    := oModel:GetOperation()

DbSelectArea( "DTD" )
DbSetOrder( 1 )

If (nOper == MODEL_OPERATION_INSERT);
	.And. MsSeek( xFilial("DTD") + oModel:GetValue('MdFieldDTD','DTD_CDRORI') + oModel:GetValue('MdFieldDTD','DTD_CDRDES') + oModel:GetValue('MdFieldDTD','DTD_TIPTRA') )
	Help(' ', 1, 'TMSA39001')	//-- Prazo ja cadastrado!
	lRet := .F.
EndIf
DVN->(DbSetOrder(1))
If	nOper == MODEL_OPERATION_DELETE .Or. nOper == MODEL_OPERATION_UPDATE //Se for alteracao ou exclusao
	If DVN->(MsSeek(xFilial('DVN')+oModel:GetValue('MdFieldDTD','DTD_CDRORI') + oModel:GetValue('MdFieldDTD','DTD_CDRDES') + oModel:GetValue('MdFieldDTD','DTD_TIPTRA') ) )
			If !MsgYesNo(STR0010,STR0009) //"Existem clientes utilizando este prazo, confirma alteracao?"
				lRet := .F.
			EndIf
	EndIf
EndIf

RestArea( aAreaDTD )
RestArea( aAreaDVN )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA390Vld³ Autor ³ Alex Egydio           ³ Data ³16.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA390Vld()

Local aAreaDTD := DTD->(GetArea())
Local cCampo   := ReadVar()
Local lRet     := .T.
Local lSinc    := TmsSinc() //chamada do sincronizador 
Local nTamTmp  := Len(DTD->DTD_TMEMBI) //-- Tamanho campos tempo
Local cCpoTmp  := StrZero(0,nTamTmp)

//-- Prazo informado por cliente
If !lSinc
	//-- Nao permitir que o prazo minimo, seja maior que o prazo estipulado na regiao
	If	cCampo == 'M->DTD_TMEMBI'

		If	M->DTD_TMEMBI > M->DTD_TMEMBF .And. M->DTD_TMEMBF <> cCpoTmp
			cCampo := AllTrim(RetTitle('DTD_TMEMBI'))
			lRet := .F.
		EndIf

	ElseIf cCampo == 'M->DTD_TMTRAI'

		If	M->DTD_TMTRAI > M->DTD_TMTRAF .And. M->DTD_TMTRAF <> cCpoTmp
			cCampo := AllTrim(RetTitle('DTD_TMTRAI'))
			lRet := .F.
		EndIf

	ElseIf cCampo == 'M->DTD_TMDISI'

		If	M->DTD_TMDISI > M->DTD_TMDISF .And. M->DTD_TMDISF <> cCpoTmp
			cCampo := AllTrim(RetTitle('DTD_TMDISI'))
			lRet := .F.
		EndIf
	//-- Nao permitir que o prazo maximo, seja menor que o prazo minimo estipulado na regiao
	ElseIf cCampo == 'M->DTD_TMEMBF'

		If	M->DTD_TMEMBF < M->DTD_TMEMBI .And. M->DTD_TMEMBI <> cCpoTmp
			cCampo := AllTrim(RetTitle('DTD_TMEMBF'))
			lRet := .F.
		EndIf

	ElseIf cCampo == 'M->DTD_TMTRAF'

		If	M->DTD_TMTRAF < M->DTD_TMTRAI .And. M->DTD_TMTRAI <> cCpoTmp
			cCampo := AllTrim(RetTitle('DTD_TMTRAF'))
			lRet := .F.
		EndIf

	ElseIf cCampo == 'M->DTD_TMDISF'

		If	M->DTD_TMDISF < M->DTD_TMDISI .And. M->DTD_TMDISI <> cCpoTmp
			cCampo := AllTrim(RetTitle('DTD_TMDISF'))
			lRet := .F.
		EndIf

	EndIf
	If ! lRet
		Help('',1,'TMSA39002',,cCampo,4,1) //--"O tempo informado esta maior que o tempo especificado para a regiao"
	EndIf
EndIf

RestArea(aAreaDTD)

Return(lRet)

/*{Protheus.doc} MenuDef
    @type Static Function
    @author Felipe Barbiere
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA390()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()

Private aRotina	:= {	{ STR0002 ,'AxPesqui'		,0,1,0,.F.},; //'Pesquisar'
						{ STR0003 ,'VIEWDEF.TMSA390',0,2,0,NIL},; //'Visualizar'
						{ STR0004 ,'VIEWDEF.TMSA390',0,3,0,NIL},; //'Incluir'
						{ STR0005 ,'VIEWDEF.TMSA390',0,4,0,NIL},; //'Alterar'
						{ STR0006 ,'VIEWDEF.TMSA390',0,5,0,NIL} } //'Excluir'

If ExistBlock("TMA390MNU")
	ExecBlock("TMA390MNU",.F.,.F.)
EndIf

Return(aRotina)