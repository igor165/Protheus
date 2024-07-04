#include "CRMA260.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
  
Static oTree := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA260

Cadastro de Respostas de Campanha.

@sample		CRMA260()

@param			Nenhum

@return		Nenhum

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function CRMA260()
Private aRotina := MenuDef()

//-------------------------------
// Browse Respostas de Campanha.
//-------------------------------
BrowseDef( /*oMBrowse*/ )


Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse de Respostas de Campanha.

@sample	BrowseDef( oMBrowse )

@param		oMBrowse	, Objeto	, Browse criado pelo Widget da Area de Trabalho.
		
@return	oMBrowse	, Objeto	, Retorna o objeto FWMBrowse.

@author	Anderson Silva
@since		05/12/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef( oMBrowse )

Local cFiltro		:= ""
Local cFiltroAO4	:= CRMXFilEnt( "AOD", .T. )
Local oTableAtt		:= Nil
Local lWidget		:= .F.

Default oMBrowse	:= Nil

If IsInCallStack("TMKA310") .Or. IsInCallStack("CRMA360")
	cFiltro	:= "AOD_CHVCAM=='"+xFilial("SUO")+SUO->UO_CODCAMP+"'"
ElseIf IsInCallStack("CRMA260")
	cFiltro	:= "AOD_CHVCAM=='"+xFilial("AOC")+AOC->AOC_CODIGO+"'"
EndIf

//----------------
// Cria o Browse 
//----------------
If Empty( oMBrowse )
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("AOD") // Resposta de Campanha
Else
	lWidget	:= .T.
EndIf

If !Empty( cFiltroAO4 )
	oMBrowse:DeleteFilter( "AO4_FILENT" )
	oMBrowse:AddFilter( STR0043 , cFiltro, .T., .T., "AO4", , , "AO4_FILENT" )      // "Filtro do CRM"		       
	oMBrowse:ExecuteFilter() 
EndIf

oMBrowse:SetCanSaveArea(.T.) 
oMBrowse:SetChgAll(.F.)	
oMBrowse:SetSeeAll(.F.)

If !Empty( cFiltro )
	oMBrowse:SetFilterDefault( cFiltro )
EndIf

oMBrowse:SetDescription(STR0001) //"Cadastro de Resposta de Campanha"

If !lWidget 
	oTableAtt := TableAttDef()
	oMBrowse:SetAttach( .T. )
	oMBrowse:SetChartsDefault(oTableAtt:aCharts)
	oMBrowse:SetIDChartDefault( "Resp" )
	oMBrowse:SetTotalDefault("AOD_CODIGO","COUNT",STR0047) // "Total de Registros"
	oMBrowse:Activate()
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados do Cadastro de Resposta de Campanhas.

@sample		ModelDef()

@param			Nenhum

@return		oModel		Objeto MPFormModel

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStruAOD 		:= FWFormStruct(1,"AOD",/*bAvalCampo*/,/*lViewUsado*/,/*lVirtual*/)
Local bCommit		:= {|oModel| CRM260Cmt(oModel)}
Local bPosValidacao	:= {|oModel| CRM260PosVld(oModel)}

oStruAOD:SetProperty("AOD_STATUS" , MODEL_FIELD_VALID, {|oModel| CRM260Status(oModel)} )
oStruAOD:SetProperty("AOD_CHAVE"  , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "CRM260VCHV()" ) ) 

oModel := MPFormModel():New("CRMA260",/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)

oModel:AddFields("AODMASTER",/*cOwner*/,oStruAOD,/*bPreValidacao*/,bPosValidacao,/*bCarga*/)

oModel:SetPrimaryKey({ 'AOD_FILIAL', 'AOD_CODIGO' })	

oModel:SetDescription(STR0002)//"Cadastro de Resposta de Campanha"
oModel:GetModel("AODMASTER"):SetDescription("AOD")

Return (oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface do Cadastro de Resposta de Campanhas.	

@sample		ViewDef()

@param			Nenhum

@return		oView		Objeto FWFormView

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel("CRMA260") 
Local oStruAOD 	:= FWFormStruct(2,"AOD")
Local aComboEnt	:=	{}
Local cEntAOC	:= ""

If nModulo <> 73
	aComboEnt := {"",STR0006}//"4=Contato"
	oStruAOD:SetProperty("AOD_ENTIDA" , MVC_VIEW_COMBOBOX, aComboEnt )
ElseIf nModulo == 73 .And. IsInCallStack("CRMA250")
	cEntAOC := CRM260EntAOC()
	Do Case
		Case cEntAOC == "SA1"
			aComboEnt 	:= {" ",STR0007}//"1= Cliente"
		Case cEntAOC == "SUS"
			aComboEnt := {" ",STR0008}//"3= Prospect"
		Case cEntAOC == "ACH"
			aComboEnt := {" ",STR0009}//"2= Suspect"
		Case cEntAOC == "SU5"
			aComboEnt := {" ",STR0010}//"4= Contato"
	End Do
	oStruAOD:SetProperty("AOD_ENTIDA" , MVC_VIEW_COMBOBOX, aComboEnt )                                                                                  
EndIf
                                          
// Remove campo
oStruAOD:RemoveField( "AOD_CODCAM" )

oView := FWFormView():New()
oView:SetModel(oModel)

oView := CRMXAddAct("AOD",oView) //Adcionar Rotinas no 'Ações relacionadas' do Formulário

oView:AddField("VIEW_AOD",oStruAOD,"AODMASTER")

oView:CreateHorizontalBox("TELA",100)

oView:SetOwnerView("VIEW_AOD","TELA")


Return (oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação.

@sample		MenuDef()

@param			Nenhum

@return   		aRotina - Array das operações

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function MenuDef()

Local nPos        := 0
Local aRotina     := {}
Local aEntRelac   := {}
Local aAtiv       := {}
Local aAnotac     := {}

ADD OPTION aRotina TITLE STR0011 	ACTION 'PesqBrw'				OPERATION 1	ACCESS 0 // STR0011//"Pesquisar"
ADD OPTION aRotina TITLE STR0012 	ACTION 'VIEWDEF.CRMA260'		OPERATION 2	ACCESS 0 // STR0012//"Visualizar"
ADD OPTION aRotina TITLE STR0013 	ACTION 'CRM260Incl'			OPERATION 3	ACCESS 0 // STR0013//"Incluir"
ADD OPTION aRotina TITLE STR0014 	ACTION 'CRMA260Alt'			OPERATION 4	ACCESS 0 // STR0014//"Alterar"
ADD OPTION aRotina TITLE STR0015 	ACTION 'VIEWDEF.CRMA260'		OPERATION 5	ACCESS 0 // STR0015//"Excluir"
ADD OPTION aRotina TITLE STR0016 	ACTION 'CRM260Copy()'		OPERATION 6	ACCESS 0 // STR0016//"Copiar"

If nModulo == 73// SIGACRM 
	
	ADD OPTION aRotina   TITLE STR0017   ACTION 'CRMA260Conv()'		OPERATION 7	ACCESS 0 //"Converter Resposta de Campanha"
	ADD OPTION aEntRelac TITLE STR0018   ACTION "CRMA200('AOD')" 	OPERATION 8  ACCESS 0 //STR0018//"Privilégios
	
	aEntRelac := CRMXINCROT( "AOD", aEntRelac )
	
	nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
	If nPos > 0 
		ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
		Adel(aEntRelac,nPos)
		Asize(aEntRelac,Len(aEntRelac)-1)
	EndIf
	
	nPos := ASCAN(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
	If nPos > 0
		ADD OPTION aAtiv   TITLE STR0048 ACTION "CRMA180(,,,3,,)" OPERATION 3  ACCESS 0 //"Nova Atividade" 
		ADD OPTION aAtiv   TITLE STR0049 ACTION "CRMA180()" OPERATION 8  ACCESS 0 //"Todas as ATividades"
		aEntRelac[nPos][2] := aAtiv
	EndIf

	nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
	If nPos > 0
		ADD OPTION aAnotac   TITLE STR0050 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anotação"
		ADD OPTION aAnotac   TITLE STR0051 ACTION "CRMA090()" OPERATION 8  ACCESS 0 //"Todas as Anotações" 
		aEntRelac[nPos][2] := aAnotac
	EndIf

EndIf

Asort(aEntRelac,,,{ | x,y | y[1] > x[1] } )
ADD OPTION aRotina TITLE  STR0052 ACTION aEntRelac 	    OPERATION 8  ACCESS 0//"Relacionadas"

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260Inc()

Chama a rotina para inclusão.

@sample		CRM260Inc()

@param			Nenhum

@return   		Nenhum

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function CRM260Incl()
If FunName() == "TMKA310" .Or. FunName() == "CRMA360" .Or. FunName() == "CRMA290"

	CRMA260Inc("SUO", SUO->( Recno() ))

ElseIf FunName() == "CRMA250" .Or. FunName() == "TMKA061" .Or. FunName() == "CRMA530"

	CRMA260Inc("AOC", AOC->( Recno() ))

EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260Copy()

Chama a rotina para copiar o registro.

@sample		CRM260Copy()

@param			Nenhum

@return   		Nenhum

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function CRM260Copy()

If FunName() == "TMKA310" .Or. FunName() == "CRMA360"

	CRMA260Inc("SUO", SUO->( Recno() ),.T.)

ElseIf FunName() == "CRMA250" .Or. FunName() == "TMKA061" .Or. FunName() == "CRMA530"

	CRMA260Inc("AOC", AOC->( Recno() ),.T.)

EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA260Inc

Inclusão do cadastro. 

@sample		CRMA260Inc(lCopy)

@param			lCopy 	- .T. Copiar

@return		Nenhum

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function CRMA260Inc(cAlias, nRecNo, lCopy)

Local aArea		:= GetArea()
Local aAreaAOC	:= {}
Local aAreaSUO	:= {}

Local oModel    := Nil 
Local oView     := Nil
Local aSize     := FWGetDialogSize( oMainWnd ) 
Local dHoraAtu	:= Time()
Local cChvCamp	:= ""
Local cTipCamp	:= ""
Local cEntidade	:= ""
Local cTipEnt	:= ""
Local cCamp		:= ""
Local cNomeCamp	:= ""

Default lCopy		:= .F.
Default cAlias		:= Alias()
Default nRecNo		:= ( cAlias )->( RecNo() )

oModel := FWLoadModel("CRMA260")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

If cAlias=="SUO"
	aAreaSUO	:= SUO->(GetArea())	
	DbSelectArea("SUO")
	DbSetOrder(1)
	SUO->(DbGoTo(nRecNo))
	
	cChvCamp	:= xFilial("SUO")+SUO->UO_CODCAMP
	cNomeCamp  := SUO->UO_DESC
	cCamp		:= SUO->UO_CODCAMP
	cTipCamp	:= "1"
	M->AOD_CODCAM := SUO->UO_CODCAMP
Else
	aAreaAOC	:= AOC->(GetArea())
	DbSelectArea("AOC")
	DbSetOrder(1)
	AOC->(DbGoTo(nRecNo))
	
	cChvCamp	:= xFilial("AOC")+AOC->AOC_CODIGO	
	cNomeCamp  := AOC->AOC_DESCAM
	cCamp		:= AOC->AOC_CODIGO
	cTipCamp	:= "2"
	M->AOD_CODCAM := AOC->AOC_CODIGO
	cEntidade := CRM260EntAOC()	
	Do Case 
		Case cEntidade == "SA1"	
			cTipEnt := "1"
	 	Case cEntidade == "ACH"
	 		cTipEnt := "2"
	 	Case cEntidade == "SUS"
	 		cTipEnt := "3"
	 	Case cEntidade == "SU5"
	 		cTipEnt := "4"
	EndCase
EndIf	

If cAlias=="AOC"
	oModel:GetModel("AODMASTER"):SetValue("AOD_ENTIDA",cTipEnt) 
EndIf

//Campos 
If lCopy
	oModel:GetModel("AODMASTER"):SetValue("AOD_ASSUNT",AOD->AOD_ASSUNT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_DESCRI",AOD->AOD_DESCRI)
	oModel:GetModel("AODMASTER"):SetValue("AOD_ENTIDA",AOD->AOD_ENTIDA)
	oModel:GetModel("AODMASTER"):SetValue("AOD_CHAVE",AOD->AOD_CHAVE)
	oModel:GetModel("AODMASTER"):SetValue("AOD_NOMENT",AOD->AOD_NOMENT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_DDIENT",AOD->AOD_DDIENT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_DDDENT",AOD->AOD_DDDENT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_TELENT",AOD->AOD_TELENT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_MAIENT",AOD->AOD_MAIENT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_ENDENT",AOD->AOD_ENDENT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_ESTENT",AOD->AOD_ESTENT)
	oModel:GetModel("AODMASTER"):SetValue("AOD_ORIGEM",AOD->AOD_ORIGEM)
	oModel:GetModel("AODMASTER"):SetValue("AOD_CLASSI",AOD->AOD_CLASSI)
	oModel:GetModel("AODMASTER"):SetValue("AOD_PRIORI",AOD->AOD_PRIORI)
	oModel:GetModel("AODMASTER"):SetValue("AOD_FECHAR",AOD->AOD_FECHAR)
	If !AOD->AOD_STATUS $ "3|4|5" // Se não for convertido
		oModel:GetModel("AODMASTER"):SetValue("AOD_STATUS",AOD->AOD_STATUS)
		oModel:GetModel("AODMASTER"):SetValue("AOD_MSBLQL",AOD->AOD_MSBLQL)
		oModel:GetModel("AODMASTER"):SetValue("AOD_DESQUA",AOD->AOD_DESQUA)		
	EndIf
EndIf

oModel:GetModel("AODMASTER"):SetValue("AOD_HRRECB", Left(dHoraAtu,5))
oModel:GetModel("AODMASTER"):SetValue("AOD_TPCAMP", cTipCamp)
oModel:GetModel("AODMASTER"):SetValue("AOD_CHVCAM", cChvCamp)
oModel:GetModel("AODMASTER"):SetValue("AOD_CODCAM", cCamp)
oModel:GetModel("AODMASTER"):SetValue("AOD_DESCAM", cNomeCamp)

oView := FWLoadView("CRMA260")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT) 
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
            
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0019)//"Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()
FATPDLogUser("CRMA260INC")

If !Empty(aAreaSUO)
	RestArea( aAreaSUO )
Else	
	RestArea( aAreaAOC )
EndIf	
RestArea( aArea )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA260Alt

Alteração do cadastro. 

@sample		CRMA260Alt()

@param			Nenhum

@return		Nenhum

@author		Cristiane Nishizaka
@since			27/03/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function CRMA260Alt()

Local oModel     	:= Nil 
Local oView      	:= Nil
Local aSize     	:= FWGetDialogSize( oMainWnd ) 

oModel := FWLoadModel("CRMA260")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

If AOD->AOD_MSBLQL == "1"	
	Help("",1,"HELP",,STR0020,1)	//"Esta Resposta de Campanha não pode ser alterada pois está inativa."
	oModel:DeActivate()
Else
	oView := FWLoadView("CRMA260")
	oView:SetModel(oModel)
	oView:SetOperation(MODEL_OPERATION_UPDATE) 
	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)
	            
	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aSize[1],aSize[2])
	oFWMVCWin:SetSize(aSize[3],aSize[4])
	oFWMVCWin:SetTitle(STR0021)//"Alterar"
	oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
	oFWMVCWin:Activate()
	FATPDLogUser("CRMA260ALT")
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA260Conv

Tela de Conversão de Resposta de Campanha. 

@sample		CRMA260Conv()

@param			Nenhum 

@return		lRet		.T.

@author		Vendas CRM
@since			31/03/2014
@version		P12
/*/
//------------------------------------------------------------------------------

Function CRMA260Conv()

Local oModel		:= FWLoadModel("CRMA260")

Local oDlgConv		:= Nil
Local oPanel		:= Nil
Local oConvSusp     := Nil
Local oDesq    		:= Nil
Local oGrpConvSusp	:= Nil
Local oGrpProsp		:= Nil
Local oGrpOpp		:= Nil
Local oGrpDesq		:= Nil
Local oF3Susp		:= Nil
Local oF3Prosp		:= Nil
Local oF3Opp		:= Nil
Local oCbEnt		:= Nil
Local oOpp			:= Nil
Local oDescDesq		:= Nil
Local oConvProsp	:= Nil

Local lConvSusp		:= .F.
Local lConvProsp	:= .F.
Local lDesq			:= .F.
Local lOpp			:= .F.
Local lEnt			:= .F.
Local lRet          := .T.
Local lCRMA250		:= .F.

Local cF3Susp 		:= Space(30)
Local cF3Prosp 		:= Space(30)
Local cF3Opp 		:= Space(30)
Local cCbEnt		:= Space(30)
Local cDescDesq		:= Space(80)
Local cEntAOC		:= ""

Local nConvSusp 	:= 0

Local aConversao	:= {STR0023,STR0022,STR0024,STR0025}//"Converter em Prospect"//"Converter em Suspect"//"Criar uma Oportunidade"//"Desqualificar"
Local aEntidade		:= {"","Cliente","Prospect"}

Private cEntIni		:= ""	// Guarda a entidade cadastrada
Private cChvIni		:= ""	// Guarda a Chave da entidade cadastrada

If AOD->AOD_MSBLQL == '1'
	Help("",1,"HELP",,STR0026,1)//"Esta Resposta de Campanha não pode ser convertida pois está inativa."
	lRet := .F.	
EndIf

If lRet
	cEntIni := AOD->AOD_ENTIDA
	cChvIni := AOD->AOD_CHAVE
	
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	
	DEFINE MSDIALOG oDlgConv TITLE STR0027 FROM 9,0 TO 30.5,35.4 OF oMainWnd   //"Converter Resposta de Campanha"
		@ 000, 000 MSPANEL oPanel   PROMPT '' SIZE 101,165 OF oDlgConv //COLOR CLR_RED, CLR_RED
		oPanel:Align := CONTROL_ALIGN_TOP 
		
		//Converter em Suspect
		@ 002,002 GROUP oGrpConvSusp 	TO 20, 140 		PROMPT "" 							OF oPanel PIXEL
		@ 006,005 CHECKBOX oConvSusp 	VAR lConvSusp 	PROMPT STR0028 	OF oPanel SIZE 070, 010 PIXEL//"Converter em Suspect"
	
		//Converter em Prospect
		@ 023,002 GROUP oGrpProsp 		TO 42, 140 		PROMPT "" 							OF oPanel PIXEL
		@ 027,005 CHECKBOX oConvProsp 		VAR lConvProsp 	PROMPT STR0029 	OF oPanel SIZE 070, 010 PIXEL;//"Converter em Prospect"
		ON CLICK (CRM260Click(lConvProsp,oF3Prosp), ;
					Iif(lConvProsp,(CRM260AOGEnt(oModel,"Suspect"),oOpp:Disable()),(cF3Prosp := Space(30),Iif(!lCRMA250,oOpp:Enable(),))))
		@ 027,088 MSGET oF3Prosp 		VAR cF3Prosp F3 "AOG" 								OF oPanel SIZE 048, 010 PIXEL
				
		//Criar uma Oportunidade
		@ 045,002 GROUP oGrpOpp 			TO 88, 140 		PROMPT "" 							OF oPanel PIXEL
		@ 049,005 CHECKBOX oOpp 			VAR lOpp 			PROMPT STR0030 OF oPanel SIZE 070, 010 PIXEL;//"Criar uma Oportunidade"
		ON CLICK (Iif(Empty(cCbEnt),CRM260Click(lOpp,oCbEnt),(CRM260Click(lOpp,oF3Opp),CRM260AOGEnt(oModel,cCbEnt))),;
					Iif(!lOpp,(cF3Opp := Space(30), Iif(!lCRMA250,(cCbEnt := aEntidade[1],oConvProsp:Enable()),), CRM260Click(lOpp,oF3Opp)),oConvProsp:Disable()))
		@ 061,005 SAY STR0031 																OF oPanel SIZE 070, 010 	PIXEL//"Entidade"
		@ 060,088 MSCOMBOBOX oCbEnt 	VAR cCbEnt ITEMS aEntidade							OF oPanel 	SIZE 048, 010 PIXEL;
		ON CHANGE (CRM260Click(lOpp,oF3Opp), cF3Opp := Space(30), Iif(lOpp,CRM260AOGEnt(oModel,cCbEnt),))
		@ 073,005 SAY STR0032							  							OF oPanel SIZE 070, 010 	PIXEL//"Código da Entidade"
		@ 073,088 MSGET oF3Opp 			VAR cF3Opp F3 "AOG" 									OF oPanel 	SIZE 048, 010 PIXEL
			
		//Desqualificar
		@ 091,002 GROUP oGrpDesq 		TO 144, 140 		PROMPT "" 							OF oPanel PIXEL
		@ 095,005 CHECKBOX oDesq 		VAR lDesq 			PROMPT STR0033 			OF oPanel SIZE 070, 010 	PIXEL;//"Desqualificar"
		ON CLICK (CRM260Click(lDesq,oDescDesq))
		@ 107,005 SAY STR0034  										OF oPanel SIZE 090, 010 	PIXEL //"Descrição de desqualificação"
		@ 119,005 MSGET oDescDesq		VAR cDescDesq 										OF oPanel SIZE 132, 020 PIXEL 
		
		DEFINE SBUTTON oBut1 FROM 147, 80 	TYPE 1 ENABLE OF oPanel PIXEL ACTION {((),;
		Iif(!CRMA260Cnt(lConvSusp, lConvProsp, lOpp, lDesq),Help("",1,"HELP",,STR0035,1),;//"Selecione somente um tipo de conversão."
		Iif(lConvSusp, (CRM260Act("1"),	oDlgConv:END()),;
		Iif(lConvProsp .And. !Empty(cF3Prosp),(CRM260AOGEnt(oModel,,cF3Prosp,.T.), CRM260Act("2",cF3Prosp), oDlgConv:END()),; 
		Iif(lOpp .And. !Empty(cF3Opp),(CRM260AOGEnt(oModel,,cF3Opp,.T.), CRM260Act("3",cF3Opp,cCbEnt), oDlgConv:END()),; 
		Iif(lDesq .And. !Empty(cDescDesq),(CRM260Act("4",cDescDesq),oDlgConv:END()),Help("",1,"HELP",,STR0036,1)))))))}//"Forneça uma descrição para a desqualificação."
		DEFINE SBUTTON oBut2 FROM 147, 110 TYPE 2 ENABLE OF oPanel PIXEL ACTION {lRet:=.F.,oDlgConv:End()}
	
		If !lConvProsp
			oF3Prosp:Disable()
			// Se recebida de suspect existente preenche a consulta de conversão "Converter em Prospect"
			If Val(AOD->AOD_ENTIDA) == 2 .And. !Empty(AOD->AOD_CHAVE) 
				cF3Prosp := AOD->AOD_CHAVE
				lConvProsp := .T.
				oConvSusp:Disable()
				oOpp:Disable()
				oDesq:Disable()
				oConvProsp:Disable()
			EndIf
		EndIf
		If !lOpp
			oF3Opp:Disable()
			oCbEnt:Disable()
			// Se recebida de cliente existente preenche a consulta de conversão "Criar uma Oportunidade"
			If Val(AOD->AOD_ENTIDA) == 1 .And. !Empty(AOD->AOD_CHAVE) 
				cCbEnt	:= aEntidade[2]
				cF3Opp := AOD->AOD_CHAVE
				lOpp	:= .T.
				oConvSusp:Disable()
				oOpp:Disable()
				oDesq:Disable()
				oConvProsp:Disable()
				
				// Se recebida de prospect existente preenche a consulta de conversão "Criar uma Oportunidade"
			ElseIf Val(AOD->AOD_ENTIDA) == 3 .And. !Empty(AOD->AOD_CHAVE)
				cCbEnt	:= aEntidade[3]
				cF3Opp := AOD->AOD_CHAVE
				lOpp	:= .T.
				oConvSusp:Disable()
				oOpp:Disable()
				oDesq:Disable()
				oConvProsp:Disable()
			EndIf
		EndIf
		
		//Habilita apenas a desqualificação e a conversão em Suspect quando a entidade não for preenchida.
		If Empty( AOD->AOD_ENTIDA )
			oConvSusp:Enable()
			oOpp:Disable()
			oDesq:Enable()
			oConvProsp:Disable() 
		EndIf
				
		If !lDesq
			oDescDesq:Disable()
		EndIf
		If Val(AOD->AOD_ENTIDA) == 4 .And. !Empty(AOD->AOD_CHAVE)
			 oConvProsp:Disable()
			 oOpp:Disable()
		EndIf		
		If IsInCallStack("CRMA250")
			cEntAOC := CRM260EntAOC()
			If cEntAOC $ "SUS,SA1"
				oConvProsp:Disable()
				If cEntAOC == "SUS"
					cCbEnt := "Prospect"
				Else
					cCbEnt := "Cliente"
				EndIf
			ElseIf cEntAOC == "ACH"
				oOpp:Disable()
			EndIf
			lCRMA250 := .T.
		EndIf
	ACTIVATE MSDIALOG oDlgConv CENTERED
	FATPDLogUser("CRMA260CONV")
Endif

Return(lRet)

//----------------------------------------------------------
/*/{Protheus.doc} CRM260Click()
 
Habilita ou desabilita campos.

@sample	CRM260Click(lFlag,oObj)

@param	  	lFlag 		Flag para permitir as alterações
		 	oObj 		Objeto que está sendo manipulado          
            
@return   	Nenhum

@author   	Cristiane Nishizaka
@since    	01/04/2014
@version  	12.0
/*/
//----------------------------------------------------------	

Static Function CRM260Click(lFlag,oObj)

Default oObj := Nil

If lFlag 
	If oObj <> Nil 
		oObj:Enable()                                                                           
		oObj:Refresh() 
	EndIf                                                                   
Else
	If oObj <> Nil 
		oObj:Disable()
		oObj:Refresh()
	EndIf                                     
EndIF

Return

//----------------------------------------------------------
/*/{Protheus.doc} CRM260AOGEnt()
 
Seta a entidade selecionada para filtar a consulta padrão AOG.

@sample	CRM260AOGEnt(oModel,cEntidade,cCodEnt,lConfirm)

@param	  	oModel 		- Objeto do modelo
		 	cEntidade 	- Entidade selecionada          
		 	cCodEnt	- Alias
		 	lConfirm	- Flag para autorizar commit
            
@return   	lRet	- 	.T. Gravou
						.F. Não gravou

@author   	Cristiane Nishizaka
@since    	01/04/2014
@version  	12.0
/*/
//----------------------------------------------------------	

Static Function CRM260AOGEnt(oModel,cEntidade,cCodEnt,lConfirm)

Local lRet			:= .F.

Default cEntidade	:= ""
Default lConfirm	:= .F.
Default cCodEnt		:= ""

If !Empty(cEntidade)
	Do Case
		Case cEntidade == "Suspect"
			oModel:GetModel("AODMASTER"):SetValue('AOD_ENTIDA',"2")
		Case cEntidade == "Cliente"
			oModel:GetModel("AODMASTER"):SetValue('AOD_ENTIDA',"1")
		Case cEntidade == "Prospect"
			oModel:GetModel("AODMASTER"):SetValue('AOD_ENTIDA',"3")
	End Case
EndIf

If lConfirm
	oModel:GetModel("AODMASTER"):SetValue('AOD_CHAVE',cCodEnt)
	FWFormCommit(oModel)
	lRet := .T.
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} CRMA260Cnt()
 
Valida quantidade de conversões selecionadas.

@sample	CRMA260Cnt(lConvSusp, lConvProsp, lOpp, lDesq)

@param	  	lConvSusp 		Suspect selecionado 
			lConvProsp		Prospect selecionado
			lOpp			Oportunidade selecionado
			lDesq			Desqualificar selecionado
            
@return   	lRet			.T. Contou
							.F. Não contou

@author   	Cristiane Nishizaka
@since    	08/04/2014
@version  	12.0
/*/
//----------------------------------------------------------	

Static Function CRMA260Cnt(lConvSusp, lConvProsp, lOpp, lDesq)

Local lRet		:= .F.
Local nCount 	:= 0

Iif(lConvSusp,nCount++,)
Iif(lConvProsp,nCount++,)
Iif(lOpp,nCount++,)
Iif(lDesq,nCount++,)

If nCount == 1
	lRet		:= .T.
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} CRM260Act()
 
Chama as rotinas de cadastro de acordo com a opção escolhida.

@sample	CRM260Act(cOpc,cConteudo,cEntidade)

@param	  	cOpc 		1 = Converter em Suspect
						2 = Converter em Prospect
						3 = Criar uma Oportunidade
						4 = Desqualificar
			cConteudo	Conteudo do campo		
            cEntidade	Alias
            
@return   	Nenhum

@author   	Cristiane Nishizaka
@since    	01/04/2014
@version  	12.0
/*/
//----------------------------------------------------------	

Static Function CRM260Act(cOpc,cConteudo,cEntidade)

Local lConfirm	:= .F.
Local lContInd	:= .F.
Local oModel		:= FWModelActive()

Default cConteudo	:= ""
Default cEntidade	:= ""

//Valida o modelo de Dados para não abrir a tela duas vezes e/ou apresentar error log, devido ao Modelo Ativo ser outro.
If oModel:cId == "CRMA260"

	Do Case 
		Case cOpc == "1"
			If CRM260CvSus(oModel)
				oModel:GetModel("AODMASTER"):SetValue('AOD_STATUS',"3")
				oModel:GetModel("AODMASTER"):SetValue('AOD_MSBLQL',"1")
				lConfirm	:= .T.
				lContInd	:= .T.
			EndIf
		Case cOpc == "2"
			If CRM260CvProsp(cConteudo)
				oModel:GetModel("AODMASTER"):SetValue('AOD_STATUS',"4")
				oModel:GetModel("AODMASTER"):SetValue('AOD_MSBLQL',"1")
				FWExecView(STR0037 ,"VIEWDEF.TMKA260",4,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)//"Alterar"
				lConfirm	:= .T.
				lContInd	:= .T.
			EndIf
		Case cOpc == "3"
			If CRM260NwOpp()
				oModel:GetModel("AODMASTER"):SetValue('AOD_STATUS',"5")
				oModel:GetModel("AODMASTER"):SetValue('AOD_MSBLQL',"1")		
				lConfirm	:= .T.	
				lContInd	:= .T.
			Else
				// Retorna os valores originais
				oModel:GetModel("AODMASTER"):SetValue('AOD_CHAVE',cChvIni)	
				oModel:GetModel("AODMASTER"):SetValue('AOD_ENTIDA',cEntIni)
				lConfirm	:= .T.
			EndIf
		Case cOpc == "4" 
				oModel:GetModel("AODMASTER"):SetValue('AOD_STATUS',"6")
				oModel:GetModel("AODMASTER"):SetValue('AOD_MSBLQL',"1")
				oModel:GetModel("AODMASTER"):SetValue('AOD_DESQUA',cConteudo)	
				lConfirm	:= .T.	
				lContInd	:= .T.			
	EndCase	
	
EndIf

If lConfirm
	FWFormCommit(oModel)	
EndIf

If lContInd
	CRMA260CtInd(cOpc)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260CvSus()
                                   
Rotina para chamar a tela de inclusão do cadastro de Suspects

@sample	CRM260CvSus()  

@param	  	Nenhum
            
@return   	.T.

@author   	Cristiane Nishizaka
@since    	02/04/2014
@version  	12.0         
/*/
//------------------------------------------------------------------------------

Function CRM260CvSus()  

Local oModel  		:= FWLoadModel("TMKA341")
Local oView    		:= Nil
Local aSize	 		:= FWGetDialogSize( oMainWnd )	
Local bCloseOnOk 	:= {|| } 

Local lRet				:= .F.
Local lCancel			:= .F.

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
If !Empty(AOD->AOD_NOMENT)
	oModel:GetModel("ACHMASTER"):SetValue("ACH_RAZAO "	,AOD->AOD_NOMENT)
EndIf	
If !Empty(AOD->AOD_TELENT)
		oModel:GetModel("ACHMASTER"):SetValue("ACH_TEL"		,AOD->AOD_TELENT)
EndIf			
If !Empty(AOD->AOD_MAIENT)
		oModel:GetModel("ACHMASTER"):SetValue("ACH_EMAIL"	,AOD->AOD_MAIENT)
EndIf	
If !Empty(AOD->AOD_ENDENT)
		oModel:GetModel("ACHMASTER"):SetValue("ACH_END"		,AOD->AOD_ENDENT)
EndIf	
If !Empty(AOD->AOD_MUNENT)
		oModel:GetModel("ACHMASTER"):SetValue("ACH_CIDADE"	,AOD->AOD_MUNENT)
EndIf	
If !Empty(AOD->AOD_ESTENT)
		oModel:GetModel("ACHMASTER"):SetValue("ACH_EST"		,AOD->AOD_ESTENT)
EndIf	
If !Empty(AOD->AOD_DDIENT)
		oModel:GetModel("ACHMASTER"):SetValue("ACH_DDI"		,AOD->AOD_DDIENT)
EndIf
If !Empty(AOD->AOD_DDDENT)
		oModel:GetModel("ACHMASTER"):SetValue("ACH_DDD"		,AOD->AOD_DDDENT)
EndIf
  		
oModel:GetModel("ACHMASTER"):SetValue("ACH_TPCAMP"		,AOD->AOD_TPCAMP)
oModel:GetModel("ACHMASTER"):SetValue("ACH_CHVCAM"		,AOD->AOD_CHVCAM)  		
oModel:GetModel("ACHMASTER"):SetValue("ACH_ORIGEM"		,"2")  	
  		
oView := FWLoadView("TMKA341")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT) 
  
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
	
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0038)//"Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| lRet:=.T.  }
oFWMVCWin:oView:oModel:BCancel := {|| lCancel:=.T.  }
oFWMVCWin:Activate()
FATPDLogUser("CRM260CVSUS")  	
If lCancel
	lRet := .F.
EndIf  	
  	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260CvProsp()
                                   
Converte Suspect para Prospect.

@sample	CRM260CvProsp(cConteudo)

@param	  	cConteudo	Chave da entidade 
            
@return   	.T.

@author   	Cristiane Nishizaka
@since    	02/04/2014
@version  	12.0         
/*/
//------------------------------------------------------------------------------

Static Function CRM260CvProsp(cConteudo)

Local lRet		:= .F.
Local lGrava	:= .F.
Local cCGC		:= ""

DbSelectArea("ACH")
ACH->(DbSetOrder(1))	// ACH_FILIAL+ACH_CODIGO+ACH_LOJA

If ACH->(DbSeek(Rtrim(cConteudo)))
	lGrava 	:= .T.
	cCGC	:= Alltrim(ACH->ACH_CGC)

	If !Empty(cCGC)
		// Se o CNPJ do Suspect já existir no cadastro do Prospect não faz a conversão
		DbSelectArea("SUS")
		SUS->(DbSetOrder(4)) // US_FILIAL+US_CGC
		If DbSeek(xFilial("SUS") + cCGC)
			Help("",1,"HELP",,STR0039,1)//"Não foi possível executar a conversão, o CNPJ do Suspect já existe no cadastro de Prospect."
			lGrava	:= .F.
		EndIf
		// Se o CNPJ do Suspect já existir no cadastro do Cliente não faz a conversão
		DbSelectArea("SA1")
		SA1->(DbSetOrder(3)) // A1_FILIAL+A1_CGC
		If DbSeek(xFilial("SA1") + cCGC)
			Help("",1,"HELP",,STR0040,1)//"Não foi possível executar a conversão, o CNPJ do Suspect já existe no cadastro de Clientes."
			lGrava	:= .F.
		EndIf
	EndIf
EndIf

If lGrava
	If TK341GrvSTP(ACH->ACH_CODIGO,ACH->ACH_LOJA,NIL)
		lRet	:= .T.
	EndIf
EndIf	

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260NwOpp()
                                   
Rotina para chamar a tela de inclusão do cadastro de Oportunidades.

@sample	CRM260NwOpp()  

@param	  	Nenhum
            
@return   	lRet	.T. Gravou
					.F. Não Gravou

@author   	Cristiane Nishizaka
@since    	02/04/2014
@version  	12.0         
/*/
//------------------------------------------------------------------------------

Function CRM260NwOpp()  

Local oModel  		:= FWLoadModel("FATA300")
Local oView    		:= Nil
Local aSize	 		:= FWGetDialogSize( oMainWnd )	
Local bCloseOnOk 	:= {|| } 
Local cCodVend		:= ""

Local lRet			:= .F.
Local lCancel		:= .F.

cCodVend := CRMXRetVend()

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
If !Empty(AOD->AOD_ASSUNT)
	oModel:GetModel("AD1MASTER"):SetValue("AD1_DESCRI"	,AOD->AOD_ASSUNT)
EndIf
If !Empty(AOD->AOD_DESCRI)
	oModel:GetModel("AD1MASTER"):SetValue("AD1_MEMO"	,AOD->AOD_DESCRI)
EndIf 
If !Empty(AOD->AOD_CHAVE)
	If AllTrim(AOD->AOD_ENTIDA) == "1"
		oModel:GetModel("AD1MASTER"):SetValue("AD1_CODCLI"	,SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+1,TAMSX3("A1_COD")[1]))
		oModel:GetModel("AD1MASTER"):SetValue("AD1_LOJCLI"	,SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+TAMSX3("A1_COD")[1]+1,TAMSX3("A1_LOJA")[1]))
		oModel:GetModel("AD1MASTER"):SetValue("AD1_NOMCLI"	,Posicione( "SA1", 1, xFilial("SA1") + SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+1,TAMSX3("A1_COD")[1]) + SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+TAMSX3("A1_COD")[1]+1,TAMSX3("A1_LOJA")[1]), "A1_NOME" ))			
	ElseIf AllTrim(AOD->AOD_ENTIDA) == "3"
		oModel:GetModel("AD1MASTER"):SetValue("AD1_PROSPE"	,SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+1,TAMSX3("US_COD")[1]))
		oModel:GetModel("AD1MASTER"):SetValue("AD1_LOJPRO"	,SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+TAMSX3("US_COD")[1]+1,TAMSX3("US_LOJA")[1]))
		oModel:GetModel("AD1MASTER"):SetValue("AD1_NOMCLI"	,Posicione( "SUS", 1, xFilial("SUS") + SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+1,TAMSX3("US_COD")[1]) + SubStr(AOD->AOD_CHAVE,Len(AOD_FILIAL)+TAMSX3("US_COD")[1]+1,TAMSX3("US_LOJA")[1]), "US_NOME" ))
	EndIf
EndIf	
oModel:GetModel("AD1MASTER"):SetValue("AD1_VEND"		,cCodVend)  	
oModel:GetModel("AD1MASTER"):SetValue("AD1_DTINI"	,MSDATE())  		
oModel:GetModel("AD1MASTER"):SetValue("AD1_TPCAMP"	,AOD->AOD_TPCAMP)
oModel:GetModel("AD1MASTER"):SetValue("AD1_CHVCAM"	,AOD->AOD_CHVCAM)
  		
oView := FWLoadView("FATA300")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT)
  
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
	
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0038)//"Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| lRet:=.T.  }
oFWMVCWin:oView:oModel:BCancel := {|| lCancel:=.T.  }
oFWMVCWin:Activate()
FATPDLogUser("CRM260NWOPP")  	
If lCancel
	lRet := .F.
EndIf  	
  	
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA260CtInd() 

Alimenta os campos de indicadores das campanhas. 

@sample		CRMA260CtInd(cOpc) 

@param	  		cOpc 		1 = Converter em Suspect
							2 = Converter em Prospect
							3 = Criar uma Oportunidade
							4 = Desqualificar

@return		ExpC - 	Filtro

@author		Vendas CRM
@since			25/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function CRMA260CtInd(cOpc) 

Local oModel	:= Nil
Local nIndic	:= 0
Local lRet		:= .F.
Local cModId	:= ""
Local cCampo	:= ""
Local cSufixo	:= ""

oModel	:= FWLoadModel(Iif(IsInCallStack("TMKA310") .Or. IsInCallStack("CRMA360"),'TMKA310','CRMA250'))

oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate() 

Do Case
	Case cOpc == "1" // Suspect
		cSufixo := "_SUSPEC"
	Case cOpc == "2" // Prospect
		cSufixo := "_PROSPE"
	Case cOpc == "3" // Oportunidade
		cSufixo := "_OPORTU"
	Case cOpc == "4" // Desqualificado 
		cSufixo := "_DESQUA"
End Case

If IsInCallStack("TMKA310") .Or. IsInCallStack("CRMA360")
	cModId := "SUOMASTER"
	cCampo	:= "UO"+cSufixo
ElseIf IsInCallStack("CRMA250")
	cModId	:= "AOCMASTER"
	cCampo	:= "AOC"+cSufixo
EndIf

nIndic := oModel:GetValue(cModId,cCampo)
nIndic++
oModel:GetModel(cModId):SetValue(cCampo,nIndic)

If nIndic > 0
	FWFormCommit(oModel)
	lRet := .T. 
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260AOGFil()
                                   
Monta o filtro da consulta padrão AOG.

@sample	CRM260AOGFil(cTpFiltro)  

@param	  	cTpFiltro	Tipo do filtro
            
@return   	cRet		Conteúdo

@author   	Cristiane Nishizaka
@since    	03/04/2014
@version  	12.0         
/*/
//------------------------------------------------------------------------------

Function CRM260AOGFil(cTpFiltro)

Local cEnt		   	:= ""
Local cRet		   	:= ""
Local oAODMASTER 	:= Nil
Local oModel     	:= FWModelActive()

Default cTpFiltro := ""

If oModel <> Nil .AND. oModel:cId == "CRMA260"

	oAODMASTER := oModel:GetModel("AODMASTER")

	If !Empty(cTpFiltro) .AND. oAODMASTER <> Nil
		Do Case
			Case cTpFiltro == "CHVCAM"
				cRet	:= oAODMASTER:GetValue("AOD_CHVCAM")
			Case cTpFiltro == "TIPCAM"
				cRet	:= AllTrim(oAODMASTER:GetValue("AOD_TPCAMP"))
			Case cTpFiltro == "ENTIDA"
				cEnt	:= AllTrim(oAODMASTER:GetValue("AOD_ENTIDA"))
				Do Case
					Case cEnt == "1" // Cliente
						cEnt := "SA1"
					Case cEnt == "2" // Suspect
						cEnt := "ACH"
					Case cEnt == "3" // Prospect
						cEnt := "SUS"
					Case cEnt == "4" // Contato
						cEnt := "SU5"
				EndCase
				cRet	:= cEnt
		EndCase
	EndIf
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260PosVld

Bloco de PosValidação. 

@sample		CRM260PosVld(oModel)

@param			oModel 		Objeto do modelo 

@return		lRet		.T. Ok
							.F. Falta descrição

@author		Vendas CRM
@since			25/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function CRM260PosVld(oModel)

Local lRet	:= .T.

If FWFldGet("AOD_STATUS") == "6" .And. FWFldGet("AOD_MSBLQL") == "1" .And. Empty(FWFldGet("AOD_DESQUA"))
	Help("",1,"HELP",,STR0042,1)//"Forneça uma descrição para a desqualificação."
	lRet := .F.
EndIf

Return lRet
                                  
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260Cmt

Bloco de Commit. 

@sample		CRM260Cmt(oModel)

@param			oModel 		Objeto do modelo 

@return		lRet		.T.

@author		Vendas CRM
@since			25/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function CRM260Cmt( oModel )

Local aArea       := GetArea()                             
Local aAreaAO4    := AO4->(GetArea())
Local lRet        := .T.                   
Local nOpc        := oModel:GetOperation()   
Local aExecAuto   := {}
Local aNvlEstrut  := {}
Local cChave      := "" 
Local lContinua   := .T.

If nOpc == MODEL_OPERATION_UPDATE

	// Se a Resposta for Desqualificada
	If FWFldGet("AOD_STATUS") == "6" .And. FWFldGet("AOD_MSBLQL") == "1"
		CRMA260CtInd("4") 
	EndIf

EndIf

FWFormCommit(oModel,Nil,{|oModel,cId,cAlias| CRM260CmtAft(oModel,cId,cAlias) })

RestArea( aAreaAO4 )
RestArea( aArea )

Return( lRet )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM260CmtAft

Bloco de transacao durante o commit do model. 

@sample	CRM260CmtAft(oModel,cId,cAlias)

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author	Anderson Silva
@since		06/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRM260CmtAft(oModel,cId,cAlias)

Local nOperation	:= oModel:GetOperation()
Local cChave    	:= ""		
Local aAutoAO4  	:= {}
Local lRetorno 		:= .T.
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona ou Remove o privilegios deste registro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cId == "AODMASTER" .AND. ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE ) 
	cChave 	:= PadR(xFilial("AOD")+oModel:GetValue("AOD_CODIGO"),TAMSX3( "AO4_CHVREG")[1])
	aAutoAO4	:= CRMA200PAut(nOperation,"AOD",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
	lRetorno	:= CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
EndIf 

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260EntAOC() 

Obtem a entidade da lista. 

@sample		CRM260EntAOC() 

@param			Nenhum 

@return		cRet		Entidade

@author		Vendas CRM
@since			25/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function CRM260EntAOC()

Local cRet	:= ""

DbSelectArea("SU4")
SU4->(DbSetOrder(1)) // U4_FILIAL+U4_LISTA+DTOS(U4_DATA)

If SU4->(DbSeek(xFilial("SU4")+Left(AOC->AOC_CHVLST,Len(U4_LISTA+DTOS(U4_DATA)))))
	cRet := SU4->U4_ENTIDA
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM260EntAOC() 

Obtem a entidade da lista. 

@sample		CRM260EntAOC() 

@param			Nenhum 

@return		cRet		Entidade

@author		Vendas CRM
@since			25/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function CRM260Status(oModel)

Local nOpc	:= oModel:GetOperation()  
Local lRet	:= .T.

If nOpc == MODEL_OPERATION_INSERT
	If FWFldGet("AOD_STATUS") $ "3,4,5"
		lRet		:= .F.
		Help("",1,"HELP",,STR0045,1) // "Para a inclusão de Respostas de Campanha são válidas somente as opções 1=Aberto, 2=Em Andamento e 6=Desqualificado do campo Status."
	EndIf
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos padrão para Campanhas Rápidas.

@sample	TableAttDef()

@param		Nenhum

@return	ExpA - Array de Objetos com as Visoes.

@author	Aline Kokumai
@since		06/06/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt := FWTableAtt():New()
Local oResp     := Nil

//-------------------
// Cria os Gráficos
//-------------------
oResp := FWDSChart():New()                        
oResp:SetName( STR0046 ) //"Status de Resposta de Campanhas"
oResp:SetTitle( STR0046 )//"Status de Resposta de Campanhas"
oResp:SetID("Resp") 
oResp:SetPublic( .T. )                    
oResp:SetSeries( { { "AOD", "AOD_CODIGO", "COUNT" } } )
oResp:SetCategory( { { "AOD", "AOD_STATUS" } } )
oResp:SetType( "PIECHART" ) //Grafico de Pizza
oResp:SetLegend( CONTROL_ALIGN_BOTTOM )//Inferior
oResp:SetTitleAlign( CONTROL_ALIGN_CENTER )

oTableAtt:AddChart(oResp)

Return(oTableAtt)


//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValidChave

Função para validar a chave do incluida pelo usuário 

@sample	ValidChave()

@param		ExpO - Modelo de dados

@return	ExpL - lRet indica se o valor do campo foi validado

@author	Victor Bitencourt
@since		23/09/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRM260VCHV() 

Local lRet       := .T.
Local cAlias     := ""
Local cChave 	 := ""
Local nTamFilial := TAMSX3("AOD_FILIAL")[1]
Local nTamCMP    := TAMSX3("AOD_CHAVE")[1] - nTamFilial
Local oModel     := FwModelActive()

Default oModel := Nil

If oModel <> Nil .AND. oModel:cId == "CRMA260"
	
	cAlias := CRM260AOGFil("ENTIDA")
	cChave := oModel:GetModel("AODMASTER"):GetValue("AOD_CHAVE") 
	
	If !Empty(cChave)
		If ExistCpo(cAlias,Right(cChave,nTamCMP),1) // Validando se o registro existe na tabela de origem
			If !Empty(cAlias) .AND. !Empty(cChave)
				lRet :=  CRMXLibReg(cAlias,Right(cChave,nTamCMP))
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf		

EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
