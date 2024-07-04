#INCLUDE "CTBA620.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE OPER_IMPORTAR       16

Static __nOper :=  0

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA620
Rotina Configuração de Auditoria de lançamentos Contábeis


@author	Alvaro Camillo Neto
@since		24/10/2013
@version	MP11.90
		
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              		:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Programador 	: Data  	: BOPS 		    : Motivo da Alteracao                    	:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Jonathan Glz	:25/06/15	:PCREQ-4256	:Se elimina de la funcion CWBF3SX3 el	:
:             	:        	:           	:dbUseArea por OpenSxs por motivo de	:
:             	:        	:          		:adecuacion a fuentes a nuevas estruc-	:
:             	:        	:          		:turasSX para Version 12					:
:             	:        	:          		:                                      		:
:Jonathan Glz	:09/10/15   :PCREQ-4261     :Merge v12.1.8                         :
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

/*/
//-------------------------------------------------------------------

Function CTBA620()
Local aArea		:= {}
Local oBrowse
PRIVATE cCadastro := STR0001 //"Configuração de Auditoria de lançamentos Contábeis"  
PRIVATE aRotina := Menudef()

aArea := GetArea()


If FindFunction("FWHASMVC") .And. FWHASMVC()
	If AliasInDic("CWA") .And. AliasInDic('CWB') .And. AliasInDic("CWC")
		dbSelectArea("CWA")
		dbSelectArea('CWB')
		dbSelectArea("CWC")
					
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('CWA')
		oBrowse:SetDescription(STR0001) //"Configuração de Auditoria de lançamentos Contábeis"  
		oBrowse:Activate()
	Else
		Help(" ",1,"CTBA620TAB",,STR0002, 1, 0 ) //"Dicionário de dados e RPO desatualizados. Essa funcionalidade deve ser utilizada a partir da versão 11.90 ou superior."
	EndIf
Else
	Help(" ",1,"CTBA620MVC",,STR0003, 1, 0 ) //"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "
Endif



RestArea(aArea)
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF
Função de definição do Menu da Rotina

@author	Alvaro Camillo Neto
@since		24/10/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
   

Static Function MenuDef()     
Local aRotina

aRotina	:= {}
ADD OPTION aRotina TITLE STR0004  			ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0		//'Pesquisar'
ADD OPTION aRotina TITLE STR0007 			ACTION 'VIEWDEF.CTBA620'  		OPERATION 2 ACCESS 0 	//'Visualizar'
ADD OPTION aRotina TITLE STR0047			ACTION 'CTBC620CON(,,3)' 		OPERATION 2 ACCESS 0		//"Consultar"
ADD OPTION aRotina TITLE STR0006 			ACTION 'VIEWDEF.CTBA620' 		OPERATION 4 ACCESS 0	    //"Alterar"		
ADD OPTION aRotina TITLE STR0008			ACTION 'VIEWDEF.CTBA620' 		OPERATION 5 ACCESS 0 	//'Excluir'
ADD OPTION aRotina TITLE STR0009			ACTION 'CT620CPY' 				OPERATION 2 ACCESS 0 	//'Copiar'
ADD OPTION aRotina TITLE STR0048			ACTION 'CT620Imp'    	  		OPERATION 3 ACCESS 0 	//'Importar CSV'


Return(Aclone(aRotina))


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct(1,'CWA')
Local oStr2:= FWFormStruct(1,'CWB')
Local oStr3:= FWFormStruct(1,'CWC')

oModel := MPFormModel():New('CTBA620',,{|| CTBA620VLD()})

oModel:SetDescription(STR0050)//'Configuração de Auditoria'

oStr1:SetProperty('CWA_COD',MODEL_FIELD_KEY,.T.)

oModel:addFields('CWAMASTER',,oStr1)

oStr2:SetProperty('CWB_KEY',MODEL_FIELD_NOUPD,.F.)

oStr2:AddField(STR0017,STR0017 , 'KEYDESC', 'C',200,,,,,,{|| CHAVEDESC("CWB->CWB_KEY")},,.T.,.T. )//'Chave'
oStr2:AddField(STR0018,STR0018 , 'FILTRODESC', 'C',200,,,,,,{|| CWBFILDESC()},,.T.,.T. )//'Filtro'
oStr2:AddField(STR0019,STR0019 , 'VALORDESC', 'C',30,,,,,,{|| CWBVALDESC()},,.T.,.T. )//'Valor'
oStr2:AddField(STR0020,STR0020 , 'DATADESC', 'C',30,,,,,,{|| CWBDTDESC()},,.T.,.T. )//'Data'

oStr3:AddField(STR0021,STR0021 , 'KEYORIDESC', 'C',200,,,,,,{|| CHAVEDESC("CWC->CWC_KEYORI")},,,.T. )//'Chave Ori'
oStr3:AddField(STR0022,STR0022,'KEYDESDESC', 'C',200,,,,,,{|| CHAVEDESC("CWC->CWC_KEYDES")},,,.T. )//'Chave Dest'

oModel:addGrid('CWBDETAIL','CWAMASTER',oStr2)
oModel:addGrid('CWCDETAIL','CWAMASTER',oStr3)

oModel:SetRelation('CWCDETAIL', { { 'CWC_FILIAL', 'xFilial("CWC")' }, { 'CWC_CDAUDT', 'CWA_COD' } }, CWC->(IndexKey(1)) )
oModel:SetRelation('CWBDETAIL', { { 'CWB_FILIAL', 'xFilial("CWB")' }, { 'CWB_CDAUDT', 'CWA_COD' } }, CWB->(IndexKey(1)) )

oModel:getModel('CWAMASTER'):SetDescription(STR0023)//'Cabeçalho'
oModel:getModel('CWBDETAIL'):SetDescription(STR0024)//'Entidade de Auditoria'
oModel:getModel('CWCDETAIL'):SetDescription(STR0025)//'Dependencia Auditoria'
oModel:getModel('CWBDETAIL'):SetOptional(.T.)
oModel:getModel('CWCDETAIL'):SetOptional(.T.)

If __nOper != OPER_IMPORTAR
	oModel:getModel('CWBDETAIL'):SetNoDeleteLine(.T.)
	oModel:getModel('CWCDETAIL'):SetNoDeleteLine(.T.)
	oModel:getModel('CWBDETAIL'):SetNoInsertLine(.T.)
	oModel:getModel('CWCDETAIL'):SetNoInsertLine(.T.)
	oModel:getModel('CWBDETAIL'):SetNoUpdateLine( .T. )
	oModel:getModel('CWCDETAIL'):SetNoUpdateLine(.T.)
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA620VLD
Pos Validação do Modelo

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------


Function CTBA620VLD()

Local lRet := .T.
Local oModel 	:= FWModelActive()
Local cCodAud	:= oModel:GetValue("CWAMASTER","CWA_COD")
Local aArea	:= GetArea()

CWA->(dbSetOrder(1))
If oModel:getoperation() == MODEL_OPERATION_INSERT
	If CWA->(dbSeek(xFilial("CWA") + cCodAud ))
		lRet := .F.
		Help(" ",1,"CT620CPY",,STR0081 ,1,0)//"Código já utilizado."
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'CWA')
Local oStr3:= FWFormStruct(2, 'CWB')
Local oStr4:= FWFormStruct(2, 'CWC')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'CWAMASTER' )
oView:AddGrid('FORM5' , oStr3,'CWBDETAIL')
oView:AddGrid('FORM7' , oStr4,'CWCDETAIL')

oView:CreateHorizontalBox( 'BOXFORM1', 29)


oView:CreateHorizontalBox( 'BOX3', 71)
oView:CreateFolder( 'FOLDER4', 'BOX3')

oView:AddSheet('FOLDER4','SHEET5',STR0026)//'Entidade'
oView:AddSheet('FOLDER4','SHEET6',STR0027)//'Dependência '

oStr3:RemoveField( 'CWB_FILTRO' )
oStr3:RemoveField( 'CWB_DATA' )
oStr3:RemoveField( 'CWB_VALOR' )
oStr3:RemoveField( 'CWB_KEY' )
oStr3:RemoveField( 'CWB_CDAUDT' )

oStr4:RemoveField( 'CWC_CDAUDT' )
oStr4:RemoveField( 'CWC_KEYORI' )
oStr4:RemoveField( 'CWC_KEYDES' )

oView:CreateHorizontalBox( 'BOXFORM7', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET6')


oStr3:SetProperty('CWB_ITEM',MVC_VIEW_ORDEM,'01')
oStr3:SetProperty('CWB_ENT',MVC_VIEW_ORDEM,'02')
oStr3:AddField( 'KEYDESC','03',STR0030,STR0030,, 'Get',,,,.F.,,,,,,.T. )//'Chave'
oStr3:AddField( 'FILTRODESC','04',STR0033,STR0033,, 'Get',,,,.F.,,,,,,.T. )//'Filtro'
oStr3:SetProperty('CWB_TIPO',MVC_VIEW_ORDEM,'05')
oStr3:AddField( 'VALORDESC','06',STR0036,STR0036,, 'Get',,,,.F.,,,,,,.T. )//'Valor'
oStr3:AddField( 'DATADESC','07',STR0039,STR0039,, 'Get',,,,.F.,,,,,,.T. )//'Data'


oStr4:SetProperty('CWC_ITEM',MVC_VIEW_ORDEM,'01')
oStr4:SetProperty('CWC_ENTORI',MVC_VIEW_ORDEM,'02')
oStr4:AddField( 'KEYORIDESC','03',STR0021,STR0021,, 'Get',,,,.F.,,,,,,.T. )//'Chave Ori'
oStr4:SetProperty('CWC_ENTDES',MVC_VIEW_ORDEM,'04')
oStr4:AddField( 'KEYDESDESC','05',STR0021,STR0021,, 'Get',,,,.F.,,,,,,.T. )//'Chave Dest'

oStr3:SetProperty('CWB_ENT',MVC_VIEW_CANCHANGE,.F.)

oView:CreateHorizontalBox( 'BOXFORM5', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET5')

oView:SetOwnerView('FORM1','BOXFORM1')
oView:SetOwnerView('FORM5','BOXFORM5')
oView:SetOwnerView('FORM7','BOXFORM7')
oView:SetViewProperty('FORM7' , 'ENABLEDGRIDDETAIL' , {70} )

oView:SetViewProperty('FORM5' , 'ENABLEDGRIDDETAIL' , {70} )

oView:AddIncrementField('FORM5' , 'CWB_ITEM' )
oView:AddIncrementField('FORM7' , 'CWC_ITEM' )

oView:EnableTitleView('FORM5' , STR0040 )//'Entidades de Auditoria'
oView:EnableTitleView('FORM7' , STR0041 )//'Dependência Auditoria'
oView:EnableTitleView('FORM1' , STR0042 )//'Cabeçalho Configuração'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CT620CPY
Copia da configuração de auditoria contábil

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function CT620CPY(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cCod       	:= CWA->CWA_COD
Local lRet          := .T.
Local oModel		:= Nil
Local nRet			:= 0

CWA->(dbSetOrder(1)) //CWA_FILIAL + CWA_COD

If CWA->(MsSeek(xFilial("CWA") + cCod))

	cTitulo      := STR0009 //"Cópia"
	cPrograma    := 'CTBA620'
	nOperation   := MODEL_OPERATION_INSERT
	
	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	oModel:LoadValue("CWAMASTER","CWA_COD","")
	oModel:LoadValue("CWAMASTER","CWA_CONTA","")
	nRet  := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
EndIf

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CWBFILDESC
Inicialização do campo

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CWBFILDESC()
Local cDesc  		:= ""
Local cAlias 		:= CWB->CWB_ENT
Local cFiltro		:= CWB->CWB_FILTRO

If !INCLUI .And. !Empty(cAlias) .And. !Empty(cFiltro)
	cDesc 	:= MontDescr(cAlias,cFiltro,.T.,.F.)
EndIf

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} CWBVALDESC
Inicialização do campo

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CWBVALDESC()
Local cDesc  		:= ""
Local cConteud		:= CWB->CWB_VALOR

If !INCLUI .And. !Empty(cConteud)
	cDesc 	:= C620DesCPO(cConteud)
	cDesc := PadR( cDesc, TamSX3("CWB_VALOR")[1] )
EndIf

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} CWBDTDESC
Inicialização do campo

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CWBDTDESC()
Local cDesc  		:= ""
Local cConteud	:= CWB->CWB_DATA

If !INCLUI .And. !Empty(cConteud)
	cDesc 	:= C620DesCPO(cConteud)
	cDesc := PadR( cDesc, TamSX3("CWB_DATA")[1] )
EndIf

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} CHAVEDESC
Inicialização do campo

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CHAVEDESC(cCampo)
Local cDesc  		:= ""
Local cConteud	:= &(cCampo)

If !INCLUI .And. !Empty(cConteud)
	cDesc 	:= C620DesCPO(cConteud)
	cDesc := PadR( cDesc, TamSX3("CWB_KEY")[1] )
EndIf

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} C620DesCPO
Retorna a descrição dos campos

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function C620DesCPO(cConteud)
Local cDesc := ""
Local aCpo  := {}
Local aArea := GetArea()
Local aAreaSX3 := SX3->(GetArea())
Local nX := ""

aCPO := StrtoKarr(cConteud,"+")
SX3->(dbSetOrder(2))

For nX := 1 to Len(aCPO)

	If SX3->(dbSeek(aCPO[nX]))
		cDesc += Alltrim(SX3->(X3TITULO())) + "+"
	EndIf

Next nX

cDesc := Left(cDesc,Len(cDesc)-1)

RestArea(aAreaSX3)
RestArea(aArea)
Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} CWBDTBTN
Botao para consulta do campo de valor
@author alvaro.camillo
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function CWBDTBTN()
Local cCampo 	:= "CWB_DATA"
Local cCont  	:= ""
Local cDesc  	:= ""
Local oModel 	:= FWModelActive()
Local oModelCWB	:= oModel:GetModel("CWBDETAIL")
Local oView		:= FWViewActive()
Local cEntidade := oModelCWB:GetValue("CWB_ENT")

CWBF3SX3(cCampo,@cCont,@cDesc,cEntidade)

oModelCWB:LoadValue("CWB_DATA", cCont )
oModelCWB:LoadValue("DATADESC", cDesc )

If oView != Nil
	oView:Refresh()
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CWBDTBTN
Botao para consulta do campo de valor
@author alvaro.camillo
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function CWBVALBTN()
Local cCampo 	:= "CWB_VALOR"
Local cCont  	:= ""
Local cDesc  	:= ""
Local oModel 	:= FWModelActive()
Local oModelCWB	:= oModel:GetModel("CWBDETAIL")
Local oView		:= FWViewActive()
Local cEntidade := oModelCWB:GetValue("CWB_ENT")

CWBF3SX3(cCampo,@cCont,@cDesc,cEntidade)

oModelCWB:LoadValue("CWB_VALOR", cCont )
oModelCWB:LoadValue("VALORDESC", cDesc )

If oView != Nil
	oView:Refresh()
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CWBF3SX3
Consulta padrao dos campos de valor e data de referencia

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function CWBF3SX3(cCampo,cCont,cDesc,cEntidade)
Local aArea     := GetArea()
Local lRet      := .F.
Local cFiltro   := ""
Local cTipo 	:= "N"

Local oDlg
Local oBrowse
Local oMainPanel
Local oPanelBtn
Local oBtnOK
Local oBtnCan
Local oColumn1
Local oColumn2
Local oColumn3
Local oColumn4

If cCampo $ "CWB_VALOR"
	cTipo := "N"
ElseIf cCampo $ "CWB_DATA"
	cTipo := "D"
EndIf


If !Empty(cEntidade)
	cFiltro := " CWBSX3->X3_CONTEXT!='V' .And. CWBSX3->X3_TIPO=='"+cTipo+"' .And. CWBSX3->X3_ARQUIVO == '" + Alltrim(cEntidade) + "' "
EndIf

If Select( 'CWBSX3' ) == 0
	
	OpenSxs(,,,,cEmpAnt,'SX3' + cEmpAnt + '0',"CWBSX3",,.F.,,,)

	dbSetIndex( 'SX3' + cEmpAnt + '0' + IndexExt() )
EndIf

Define MsDialog oDlg From 0, 0 To 390, 515 Title STR0010 Pixel Of oMainWnd		//"Consulta Padrão - Campos do Sistema"

@00, 00 MsPanel oMainPanel Size 250, 80
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

@00, 00 MsPanel oPanelBtn Size 250, 15
oPanelBtn:Align := CONTROL_ALIGN_BOTTOM

Define FWBrowse oBrowse DATA TABLE ALIAS 'CWBSX3'  NO CONFIG  NO REPORT ;
DOUBLECLICK { || lRet := .T.,  oDlg:End() } Of oMainPanel
ADD COLUMN oColumn1  DATA { || CWBSX3->X3_CAMPO   }  Title STR0011  Size Len( CWBSX3->X3_CAMPO   ) Of oBrowse // "Campo"
ADD COLUMN oColumn2  DATA { || X3Titulo()         }  Title STR0012 Size Len( X3Titulo() ) Of oBrowse			//"Titulo"
ADD COLUMN oColumn3  DATA { || X3DescriC()        }  Title STR0013 Size Len( X3DescriC()) Of oBrowse		//"Descrição"

If !Empty( cFiltro )
	oBrowse:SetFilterDefault( cFiltro )
EndIf
oBrowse:Activate()

Define SButton oBtnOK  From 02, 02 Type 1 Enable Of oPanelBtn ONSTOP STR0014 ;				//"Ok <Ctrl-O>"
Action ( lRet := .T., oDlg:End() )

Define SButton oBtnCan From 02, 32 Type 2 Enable Of oPanelBtn ONSTOP STR0015 ;				//"Cancelar <Ctrl-X>"
Action ( lRet := .F., oDlg:End() )

cCont := CWBSX3->X3_CAMPO
cDesc := X3Titulo()

Activate MsDialog oDlg Centered

CWBSX3->( dbClearFilter() )
CWBSX3->(dbCloseArea())

RestArea( aArea )

Return




//-------------------------------------------------------------------
/*/{Protheus.doc} CWBFILTBTN
Botão para montar a expressão do filtro

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CWBFILTBTN()
Local oModel 	:= FWModelActive()
Local oModelCWB	:= oModel:GetModel("CWBDETAIL")
Local oView		:= FWViewActive()
Local cFiltro	:= oModelCWB:GetValue("CWB_FILTRO")
Local cAlias	:= oModelCWB:GetValue("CWB_ENT")
Local cDesc		:= ""

//BuildExpr ( cAlias, [ oWnd ] ,[ cFilter ], [ lTopFilter ], [ bOk ], [ oDlg ], [ aUsado ], [ cDesc ], [ nRow ] ,[ nCol ], [ aCampo ], [ lVisibleTopFilter ], [ lExpBtn ], [ cTopFilter ] )
If !Empty(cAlias)
	cFiltro := BuildExpr(cAlias ,  , cFiltro , .T. ,  , , , ,  , , , .T. , .F. )
	cDesc 	:= MontDescr(cAlias,cFiltro,.T.,.F.)
	oModelCWB:LoadValue("CWB_FILTRO", cFiltro )
	oModelCWB:LoadValue("FILTRODESC", cDesc )
	
	If oView != Nil
		oView:Refresh()
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CT620Exp
Pergunta de exportacao de configuração de auditoria

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function CT620Exp()
Local aRet		:=	{}
Local cCodAud	:= CWA->CWA_COD

SaveInter()

If ParamBox({	{6,STR0051,padr("",150),"",,"",90 ,.T.,STR0052+" .CSV |*.CSV","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},"",@aRet)//"Estrutura de Auditoria"##" Arquivo"
	MsgRun( STR0053 ,, {||	lRet := ExportAud(cCodAud,aRet[1] ) } )//"Exportando Auditoria... "
EndIf

RestInter()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExportAud
Realiza a exportação da configuração

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ExportAud(cCodAud,cArq)

Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaCWA	:= CWA->(GetArea())
Local aAreaCWB	:= CWB->(GetArea())
Local aAreaCWC	:= CWC->(GetArea())

Local aTabela	:= {}
Local nX			:= 0
Local nY			:= 0
Local cID		:= ""
Local cLin		:= ""

Local aStrCWA	:= CWA->(DbStruct())
Local aStrCWB	:= CWB->(DbStruct())
Local aStrCWC	:= CWC->(DbStruct())

Local nHandle 	:= 0
Local aStruct	:= {}


Default cArq := ""

CWA->(dbSetOrder(1))//CWA_FILIAL+CWA_COD
CWB->(dbSetOrder(1))//CWB_FILIAL+CWB_CDAUDT+CWB_ITEM
CWC->(dbSetOrder(1))//CWC_FILIAL+CWC_CDAUDT+CWC_ITEM

If lRet .And. CWA->(!MsSeek( xFilial("CWA") + cCodAud  ))
	Help(" ",1,"CT620IMP01",,STR0054 ,1,0)//"Configuração não encontrada"
	lRet := .F.
EndIf

IF lRet .And. Empty( cArq )
	Help(" ",1,"CT620IMP02",,STR0055 ,1,0)//"Arquivo nao informado!"
	lRet := .F.
Endif

If lRet
	
	aAdd(aTabela,{"CWA",aStrCWA})
	aAdd(aTabela,{"CWB",aStrCWB})
	aAdd(aTabela,{"CWC",aStrCWC})
	
	If At('.',cArq) == 0
		cArq	:=	AllTrim(cArq)+'.CSV'
	EndIf
	
	If (nHandle := FCreate(cArq))== -1
		Help(" ",1,"CT620IMP02",,STR0056 ,1,0)//"Erro na criacao do arquivo!"
	Return
	EndIf
	
	// Lista de tabelas
	cLin:="0"
	For nY := 1 to len(aTabela)
		cLin += ';'+aTabela[nY,1]
	Next
	cLin += CRLF
	FWrite(nHandle,cLin,Len(cLin))
	
	//Lista de Campos das tabelas
	For nY := 1 to len(aTabela)
		cId		:= Alltrim(str(nY))
		cLin 		:= cId
		aStruct	:= aTabela[nY,2]
		For nX:=1 To Len(aStruct)
			cLin	+=	';'+aStruct[nX,1]
		Next nX
		cLin += CRLF
		FWrite(nHandle,cLin,Len(cLin))
	Next nY
	
	CWA->(!MsSeek( xFilial("CWA") + cCodAud ))
	While CWA->(!EOF()) .And. CWA->(CWA_FILIAL+CWA_COD) == xFilial("CWA") + cCodAud
		
		cID	:= "1"
		cLin  := ExpLinAud("CWA", aStrCWA, CWA->(Recno()),cId )
		FWrite(nHandle,cLin,Len(cLin))
		
		CWB->(MsSeek(  xFilial("CWB") + CWA->(CWA_COD) ))
		While CWB->(!EOF()) .And. CWB->(CWB_FILIAL+CWB_CDAUDT) == xFilial("CWB") + CWA->(CWA_COD)
			
			cID	:= "2"
			cLin  := ExpLinAud("CWB", aStrCWB, CWB->(Recno()),cId )
			FWrite(nHandle,cLin,Len(cLin))
						
			CWB->(dbSkip())
		EndDo
		
		CWC->(MsSeek(  xFilial("CWC") + CWA->(CWA_COD) ))
		While CWC->(!EOF()) .And. CWC->(CWC_FILIAL+CWC_CDAUDT) == xFilial("CWC") + CWA->(CWA_COD)
			
			cID	:= "3"
			cLin  := ExpLinAud("CWC", aStrCWC, CWC->(Recno()),cId )
			FWrite(nHandle,cLin,Len(cLin))
						
			CWC->(dbSkip())
		EndDo
		
		CWA->(dbSkip())
	EndDo
	
	FClose(nHandle)
	
	Aviso(STR0057,STR0058,{STR0059})//"Finalizado"##"Exportacao gerada com sucesso"##"OK"
	
EndIf


RestArea(aAreaCWC)
RestArea(aAreaCWB)
RestArea(aAreaCWA)
RestArea(aArea)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ExpLinAud
Monta a linha da exportacao

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ExpLinAud(cTab, aStruct, nRecno,cId)
Local aArea := GetArea()
Local cRet	:= ""
Local nX		:= 0

DbSelectArea(cTab)
(cTab)->(DbGoTo(nRecno))

cRet :=cId
For nX := 1 To Len(aStruct)
	Do Case
	Case aStruct[nX,2] == "C"
		cRet += ';'+(cTab)->( FieldGet(FieldPos(aStruct[nX,1])) )
	Case aStruct[nX,2] == "L"
		cRet += ';'+(cTab)->(IIf(FieldGet(FieldPos(aStruct[nX,1])),"T","F"))
	Case aStruct[nX,2] == "D"
		cRet += ';'+(cTab)->(Dtos(FieldGet(FieldPos(aStruct[nX,1]))))
	Case aStruct[nX,2] == "N"
		cRet += ';'+(cTab)->(Str(FieldGet(FieldPos(aStruct[nX,1]))))
	Otherwise
		cRet += ';'
	EndCase
Next
cRet += CRLF



RestArea(aArea)
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CT620Imp
Pergunta de exportacao de configuração de auditoria

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function CT620Imp()
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aRet		:= {}
Local aPerg		:= {}
Local nTamCod	:= TamSx3("CWA_COD")[1]

SaveInter()

aAdd(aPerg,{6,STR0060,padr("",150),"",,"", 90 ,.T.,STR0052+" .CSV |*.CSV" ,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})//"Estrutura Auditoria"##" Arquivo"
aAdd(aPerg,{1,STR0061	,padr("",nTamCod),"@!","ExistChav('CWA',MV_PAR02)","",,60,.T.}) 	//"Config Auditoria"

If ParamBox(aPerg, "",@aRet)
	aRetP1 	:= AjRetParam(aRet,aPerg)
	__nOper := OPER_IMPORTAR
	MsgRun( STR0062,, {||	lRet := ImportAud(aRetP1[1],aRetP1[2]) } ) //"Processando Importação ..."
	__nOper := 0

	If lRet
		Aviso(STR0063,STR0064,{STR0059})//"Processamento"##"Importação Finalizada com Sucesso"##"OK"
	EndIf

EndIf

RestInter()
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportAud
Realiza a importação da configuração

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImportAud(cArq,cCodAud)
Local lRet 		:= .T.
Local nHandle  	:= 0
Local aTabela		:= {}
Local aLinha		:= {}
Local aEstruct	:= {}
Local aDados		:= {}
Local aDadosAux	:= {}
Local cTabela		:= ""
Local nX			:= 0
Local nY			:= 0
Local nEtapa 		:= 0
Local nItem  		:= 0
Local nCfg			:= 0
Local aCWA			:= {}
Local aCWB 		:= {}
Local aCWC 		:= {}
Local cArqDest	:= ""
Local cExt			:= ""

SplitPath(cArq,,,@cArqDest,@cExt)

If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	lRet:= .F.
EndIf

If lRet
	nTot:=FT_FLASTREC()
	FT_FGOTOP()
	
	//Realiza a Leitura da 1 linha para capturar as tabelas
	aLinha := C620RDLN()
	FT_FSKIP()
	
	If Alltrim(aLinha[1]) != "0"
		Aviso(STR0065,STR0066,{STR0067})//"Estrutura incorreta."##"Cabecalho nao encontrado"##"Abandona"
		lRet := .F.
	EndIf
	
	If lRet
		For nX := 2 to Len(aLinha)
			AADD( aTabela, {aLinha[nX], {} } )
		Next nX
	EndIf
	
	// Carrega a estrutura da tabela
	If lRet
		For nX := 1 to Len(aTabela)
			aLinha := C620RDLN()
			aEstruct := {}
			
			For nY := 2 to Len(aLinha)
				aAdd(aEstruct,aLinha[nY])
			Next nX
			
			aTabela[nX][2] := aClone(aEstruct)
			
			FT_FSKIP()
		Next nX
	EndIf
	
	//Realiza a Leitura dos dados
	Do While lRet .And. !FT_FEOF()
		
		aLinha := C620RDLN()
		
		If Len(aLinha) <= 0
			FT_FSKIP()
			Loop
		EndIf
		
		nId := Val(aLinha[1])
		
		If nId <= 0 .Or. nId > Len(aTabela)
			lRet:= .F.
			Aviso(STR0065,STR0068,{STR0067})//"Estrutura incorreta."##"1º Elemento da Linha não contem Id da Tabela, por favor conferir layout"##"Abandona"
			Exit
		EndIf
		
		aDel(aLinha,1)
		aSize(aLinha,Len(aLinha)-1)
		
		cTabela	:= Alltrim(aTabela[nId][1])
		aEstruct := aTabela[nId][2]
		
		If ( Len(aLinha) ) != Len( aEstruct )
			lRet:= .F.
			Aviso(STR0065,STR0069,{STR0067})//"Estrutura incorreta."##"Quantidade de colunas de dados não confere com a quantidade de campos configurados nas primeiras linhas"##"Abandona"
			Exit
		EndIf
		
		aDadosAux := {}
		
		For nX := 1 to Len(aLinha)
			aAdd(aDadosAux,{ aEstruct[nX] , aLinha[nX] } )
		Next nX
		
		// Prepara as informações
		// Convertendo para os tipos corretos e verificando se o campo existe no dicionario
		aDados := Ct620Dado(cTabela,aDadosAux)
		
		If cTabela == "CWA"
			
			aCWA := aClone(aDados)
			
		ElseIf cTabela == "CWB"
			
			If (nItem := aScan( aDados, { |x| AllTrim( x[1] ) ==  "CWB_ITEM" } ) ) > 0
				aAdd(aCWB, { aDados[nItem][2] , aClone(aDados) } )
			EndIf
			
		ElseIf cTabela == "CWC"
			
			If (nItem := aScan( aDados, { |x| AllTrim( x[1] ) ==  "CWC_ITEM" } ) ) > 0
				aAdd(aCWC, { aDados[nItem][2] , aClone(aDados) } )
			EndIf
		EndIf
		
		FT_FSKIP()
	EndDo
	
	FT_FUSE()
	
	If lRet
		lRet := CT620AUT(aCWA,aCWB,aCWC,3,cCodAud)
	EndIf
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct620Dado
Prepara as informações,Convertendo para os tipos corretos
  e verificando se o campo existe no dicionario
  
@author alvaro.camillo

Rotina de criação automatica de projetos.

Parametros:
Estruta dos Arrays
aCWA
[ [ cCampo , xConteudo ] ]
[ [ cCampo , xConteudo ] ]

aCWB
[ cItem , [ [cCampo , xConteudo ] ] ]
[ cItem , [ [cCampo , xConteudo ] ] ]

aCWC
[ cItem , [ [cCampo , xConteudo ] ] ]
[ cItem , [ [cCampo , xConteudo ] ] ]

nOperation : Opção para executar a importação

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CT620AUT(aCWA,aCWB,aCWC,nOperation,cCodAud)
Local lRet 			:= .T.
Local nCampo			:= 0
Local nEtapa   		:= 0
Local nItem			:= 0
Local nCFG 			:= 0
Local oModel			:= Nil
Local oModelCWA		:= Nil
Local oModelCWB		:= Nil
Local oModelCWC		:= Nil

Local aCpoCWA  		:= {}
Local aCpoCWB			:= {}
Local aCpoCWC 		:= {}

Local aAuxCWB 	 	:= {}
Local aAuxCWC 		:= {}

Local nLinCWB			:= 0
Local nLinCWC			:= 0

Local nPos				:= 0
Local cDetalhe		:= ""
Local aArea			:= GetArea()
Local aAreaCWA		:= CWA->(GetArea())

Local lExistAud		:= .F.
Local nOper

Local nItErro			:= 0


Default nOperation   := MODEL_OPERATION_INSERT


//Ordenação dos array de entrada
aSort(aCWB,,,{|x,y| x[1] < y[1] })
aSort(aCWC,,,{|x,y| x[1] < y[1] })


CWA->(DBSetOrder(1)) //CWA_FILIAL+CWA_COD

lExistAud := CWA->(MSSeek(xFilial("CWA") + cCodAud ))

If lExistAud //  Retorno da função
	lRet := .F.
	Help(" ",1,"CT620IMPNAO",,STR0070 ,1,0)//"Essa configuração já existe."
EndIf

If lRet
	oModel := FWLoadModel( 'CTBA620' )
	oModel:SetOperation( nOperation )
	lRet := oModel:Activate()
EndIf

If lRet
	oModelCWA	:= oModel:GetModel( "CWAMASTER" )
	oModelCWB	:= oModel:GetModel( "CWBDETAIL" )
	oModelCWC	:= oModel:GetModel( "CWCDETAIL" )

	
	aCpoCWA	:= oModelCWA:GetStruct():GetFields()
	aCpoCWB	:= oModelCWB:GetStruct():GetFields()
	aCpoCWC	:= oModelCWC:GetStruct():GetFields()

EndIf


//Carrega Cabeçalho
If lRet
	For nCampo := 1 To Len( aCWA )
		If ( nPos := aScan( aCpoCWA, { |x| AllTrim( x[3] ) ==  AllTrim( aCWA[nCampo][1] ) } ) ) > 0
			If !( lAux := CT620SetVl("CWA",oModelCWA,aCWA[nCampo][1], aCWA[nCampo][2] ,cCodAud ) )
				lRet    := .F.
				Exit
			EndIf
		EndIf
	Next nCampo
EndIf

If lRet
	nLinCWB := 1
	
	For nItem := 1 To Len( aCWB )
		aDadosCWB	:= aCWB[nItem][2]
		cItem		:= aCWB[nItem][1]
		
		If nLinCWB > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oModelCWB:AddLine() ) != nLinCWB
				// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit
			EndIf
		EndIf
		
		For nCampo := 1 To Len( aDadosCWB )
			If ( nPos := aScan( aCpoCWB, { |x| AllTrim( x[3] ) ==  AllTrim( aDadosCWB[nCampo][1] ) } ) ) > 0
				If !( lAux := CT620SetVl("CWB",oModelCWB,aDadosCWB[nCampo][1], aDadosCWB[nCampo][2] ,cCodAud ) )
					lRet    := .F.
					nItErro := nLinCWB
					Exit
				EndIf
			EndIf
		Next nCampo
		
		nLinCWB++
		
		If !lRet
			Exit
		EndIf
			
	Next nItem
	
	nLinCWC := 1
	
	For nItem := 1 To Len( aCWC )
		aDadosCWC	:= aCWC[nItem][2]
		cItem		:= aCWC[nItem][1]
		
		If nLinCWC > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oModelCWC:AddLine() ) != nLinCWC
				// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit
			EndIf
		EndIf
		
		For nCampo := 1 To Len( aDadosCWC )
			If ( nPos := aScan( aCpoCWC, { |x| AllTrim( x[3] ) ==  AllTrim( aDadosCWC[nCampo][1] ) } ) ) > 0
				If !( lAux := CT620SetVl("CWC",oModelCWC,aDadosCWC[nCampo][1], aDadosCWC[nCampo][2] ,cCodAud) )
					lRet    := .F.
					nItErro := nLinCWC
					Exit
				EndIf
			EndIf
		Next nCampo
		
		nLinCWC++
		
		If !lRet
			Exit
		EndIf
			
	Next nItem
	
EndIf

If lRet .And. oModel:VldData()
	
	cCodAud := oModelCWA:GetValue("CWA_COD")

	oModel:CommitData()
	
	
	If lRet
		If oModel != Nil
			oModel:DeActivate()
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

If oModel != Nil .And. !lRet
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()
	// A estrutura do vetor com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior

	AutoGrLog( STR0071 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulário de origem:"
	AutoGrLog( STR0072 + ' [' + AllToChar( aErro[2]  ) + ']' )//"Id do campo de origem:     "
	AutoGrLog( STR0073 + ' [' + AllToChar( aErro[3]  ) + ']' )//"Id do formulário de erro:  "
	AutoGrLog( STR0074 + ' [' + AllToChar( aErro[4]  ) + ']' )//"Id do campo de erro:       "
	AutoGrLog( STR0075 + ' [' + AllToChar( aErro[5]  ) + ']' )//"Id do erro:                "
	AutoGrLog( STR0076 + ' [' + AllToChar( aErro[6]  ) + ']' )//"Mensagem do erro:          "
	AutoGrLog( STR0077 + ' [' + AllToChar( aErro[7]  ) + ']' )//"Valor atribuido:           "
	AutoGrLog( STR0078  + ' [' + AllToChar( aErro[8]  ) + ']' )//"Valor atribuido:           "
	AutoGrLog( STR0079 + ' [' + AllToChar( aErro[9]  ) + ']' )//"Valor anterior:            "
	
	If nItErro > 0
		AutoGrLog( STR0080 + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )//" Erro na Importação, verifique "
	EndIf
	
	MostraErro()
	If oModel != Nil
	// Desativamos o Model
		oModel:DeActivate()
	EndIf
EndIf



RestArea(aAreaCWA)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CT620SetVl
Valida o campo para importação
  
@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CT620SetVl(cTabela,oModel,cCampo,cConteudo,cCodAud)
Local lRet 		:= .T.
Local aArea 		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

cCampo := Alltrim(cCampo)

SX3->(dbSetOrder(2)) // X3_CAMPO

If cCampo == "CWB_ITEM"  .Or. cCampo == "CWC_ITEM" // Campos Auto Incrementados pela View
	lRet := oModel:LoadValue( cCampo , cConteudo )
ElseIf '_FILIAL' $ cCampo
	lRet := oModel:LoadValue( cCampo , xFilial(cTabela) )
ElseIf 'CWA_COD' == cCampo .Or. 'CDAUDT' $ cCampo
	lRet := oModel:LoadValue( cCampo , cCodAud )
Else
	If SX3->(MsSeek(cCampo))
		If X3USO(SX3->X3_USADO) .And. SX3->X3_VISUAL != "V" .And. SX3->X3_CONTEXT != "V" .And. !( "_MSBLQL" $ SX3->X3_CAMPO )
			If !Empty(cConteudo)
				If Empty(oModel:GetValue(cCampo))
					lRet := oModel:SetValue( cCampo , cConteudo )
				EndIf
			EndIf
		EndIf
	EndIf
EndIf



RestArea(aAreaSX3)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct620Dado
Prepara as informações,Convertendo para os tipos corretos
  e verificando se o campo existe no dicionario
@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function Ct620Dado(cTabela,aDados)
Local aRet 		:= {}
Local aStruct  := (cTabela)->(dbStruct())
Local nX			:= 0
Local nPos		:= 0


For nX := 1 to Len(aDados)
	If ( nPos := aScan( aStruct, { |x| AllTrim( x[1] ) ==  AllTrim( aDados[nX][1] ) } ) ) > 0
		Do Case
			Case aStruct[nPos][2] == "C"
				AADD(aRet,{aStruct[nPos][1] , Alltrim(aDados[nX][2]) })
				
			Case aStruct[nPos][2] == "L"
				AADD(aRet,{aStruct[nPos][1] , aDados[nX][2]=="T" })
				
			Case aStruct[nPos][2] == "D"
				AADD(aRet,{aStruct[nPos][1] , STOD( aDados[nX][2] ) })
				
			Case aStruct[nPos][2] == "N"
				AADD(aRet,{aStruct[nPos][1] , Val( aDados[nX][2] ) })
		EndCase
	EndIf
Next nX


Return aClone(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} C620RDLN
Realiza a Leitura da Linha e retorna um array com os dados já separados

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620RDLN()
Local aLinha := {}
Local cLinha := ""

//Tratamento para linhas com tamanho superior a 1020 Bytes
If ( Len(FT_FREADLN()) < 1023 )
	cLinha	:= FT_FREADLN()
Else
	cLinha	:= ""
	While .T.
		/*Verifica se encontrou o final da linha.*/
		If ( Len(FT_FREADLN()) < 1023 )
			cLinha += FT_FREADLN()
			Exit
		Else
			cLinha += FT_FREADLN()
			FT_FSKIP()
		EndIf
	EndDo
EndIf

aLinha := StrToKarr( cLinha, ";" )

Return aLinha

//-------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Ajusta as repostas do parambox

@author alvaro.camillo

@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AjRetParam(aRet,aParamBox)

Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif
	Next nX
ENDIF

Return aRet
