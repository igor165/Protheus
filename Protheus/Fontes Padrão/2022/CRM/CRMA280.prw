#INCLUDE "CRMA280.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------
/*/{Protheus.doc} CRMA280()
 
Chamada para rotina Cadastro de Complementos de Email para modelos de Email

@param	   Nenhum
       
@return   Nenhum   

@author   Victor Bitencourt
@since    21/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRMA280()

Local oMBrowse    := Nil 
Local oDlgOwner   := Nil

Local oTableAtt 	:= TableAttDef()

Private aRotina   := MenuDef()

oMBrowse    := FWMBrowse():New()

oMBrowse:SetAlias("AOE")
oMBrowse:SetDescription(STR0002)//"Complemento de Email"
		
oMBrowse:SetAttach( .T. )
oMBrowse:SetViewsDefault( oTableAtt:aViews ) 
		
oMBrowse:SetTotalDefault('AOE_FILIAL','COUNT',STR0029) // "Total de Registros"
		
oMBrowse:Activate()
		
Return


//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gráficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oAtivos		:= Nil // Complementos de E-mail Ativos
Local oInativos	:= Nil // Complementos de E-mail Inativos
Local oTableAtt 	:= FWTableAtt():New()

oTableAtt:SetAlias("AOE")

// Complementos de E-mail Ativos 
oAtivos := FWDSView():New()
oAtivos:SetName(STR0027) // "Complementos de E-mail Ativos"
oAtivos:SetOrder(1) // AOE_FILIAL+AOE_ENTIDA+AOE_CMPCOM
oAtivos:SetCollumns({"AOE_CAPCOM","AOE_ENTIDA","AOE_DESCRI","AOE_ENTEST","AOE_ORDEM",;
						"AOE_CHAVE","AOE_CAMPO","AOE_DESCCH","AOE_CHVORI"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0027, "AOE_MSBLQL == '2'") // "Complementos de E-mail Ativos"

oTableAtt:AddView(oAtivos)
oAtivos:SetID("Ativos") 

// Complementos de E-mail Inativos
oInativos := FWDSView():New()
oInativos:SetName(STR0028) // "Complementos de E-mail Inativos"
oInativos:SetOrder(1) // AOE_FILIAL+AOE_ENTIDA+AOE_CMPCOM
oInativos:SetCollumns({"AOE_CAPCOM","AOE_ENTIDA","AOE_DESCRI","AOE_ENTEST","AOE_ORDEM",;
						"AOE_CHAVE","AOE_CAMPO","AOE_DESCCH","AOE_CHVORI"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0028, "AOE_MSBLQL == '1'") // "Complementos de E-mail Inativos"

oTableAtt:AddView(oInativos)
oInativos:SetID("Inativos") 

Return (oTableAtt)	

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
 
Model - Modelo de dados de Cadastro de Complementos de Email

@param	  Nenhum
       
@return  oModel - objeto contendo o modelo de dados 

@author   Victor Bitencourt
@since    24/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel      := Nil
Local oStructAOE  := FWFormStruct(1,"AOE")

oModel := MPFormModel():New("CRMA280",/*bPreValidacao*/,/*bPosValidacao*/,{ |oModel| ModelCommit(oModel) },/*bCancel*/)	
oModel:SetDescription(STR0003)//"Complemento de Email"

oModel:AddFields("AOEMASTER",/*cOwner*/,oStructAOE,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/) 

oModel:SetPrimaryKey({"AOE_FILIAL" ,"AOE_ENTIDA","AOE_CMPCOM"})

oModel:GetModel("AOEMASTER"):SetDescription(STR0004)//"Complemento de Email"

return (oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
 
ViewDef - Visão do model de cadastro de Complementos de Email

@param	  Nenhum
       
@return  oView - objeto contendo a visão criada

@author   Victor Bitencourt
@since    24/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView	      := FWFormView():New() 
Local oModel	      := FwLoadModel("CRMA280")

Local oStructAOE    :=  FWFormStruct(2,"AOE")	 

oView:SetContinuousForm()

oStructAOE:AddGroup( "GRUPO01", STR0005, "", 2 )//"Informações do Comp. Email"    
oStructAOE:AddGroup( "GRUPO02", STR0006, "", 2 )//"Entidade Estrangeira"

oStructAOE:SetProperty("AOE_ENTIDA" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStructAOE:SetProperty("AOE_DESCRI" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStructAOE:SetProperty("AOE_CMPCOM" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStructAOE:SetProperty("AOE_CHVORI" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )

oStructAOE:SetProperty("AOE_ENTEST" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAOE:SetProperty("AOE_ORDEM"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAOE:SetProperty("AOE_CAMPO"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAOE:SetProperty("AOE_CHAVE"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAOE:SetProperty("AOE_DESCCH" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		
oStructAOE:SetProperty("AOE_ENTIDA" , MVC_VIEW_ORDEM, "01" )	 
oStructAOE:SetProperty("AOE_CMPCOM" , MVC_VIEW_ORDEM, "02" )
oStructAOE:SetProperty("AOE_CHVORI" , MVC_VIEW_ORDEM, "03" )
oStructAOE:SetProperty("AOE_DESCRI" , MVC_VIEW_ORDEM, "04" )

oStructAOE:SetProperty("AOE_ENTEST" , MVC_VIEW_ORDEM, "04" )	 
oStructAOE:SetProperty("AOE_ORDEM"  , MVC_VIEW_ORDEM, "05" )
oStructAOE:SetProperty("AOE_CHAVE"  , MVC_VIEW_ORDEM, "06" )
oStructAOE:SetProperty("AOE_DESCCH" , MVC_VIEW_ORDEM, "07" )
oStructAOE:SetProperty("AOE_CAMPO"  , MVC_VIEW_ORDEM, "08" )
//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel( oModel )	//define que a view vai usar o model 
oView:SetDescription(STR0007) //"Complemento de Email"

//--------------------------------------
//		Montagem da tela Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "LINEONE", 100 )

oView:AddField("VIEW_CMPCOMP_GRID", oStructAOE, "AOEMASTER" )

oView:SetOwnerView( "VIEW_CMPCOMP_GRID", "LINEONE") 

Return (oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
                                   
Rotina para criar as opções de menu disponiveis para a tela de Complementos de Email

@param		Nenhum	

@return	aRotina - array contendo as opções disponiveis  

@author	Victor Bitencourt
@since		24/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
     
Local aRotina := {}

   aRotina :=  FwMvcMenu("CRMA280")

Return(aRotina)


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280ORDC()
                                   
Rotina para consulta da ordem de pesquisa da tabela estrangeira

@param		Nenhum	

@return	lRet  

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Function CRM280ORDC()

Local cAlias 	    := FwFldGet("AOE_ENTEST")
Local nX          := 1 

Local lRet        := .F.

Local aAreaSIX    := {}
Local aIndic      := {}

local oBrwMark    := Nil
Local oDlg        := Nil
Local oColEnt     := Nil
Local oPanel      := Nil

Local lConfirma   := Nil

Static nCRM280ORD := 0 //receberá a ordem escolhida pelo usuario

If Select("SIX") > 0
	aAreaSIX := SIX->(GetArea())	
Else
	DbSelectArea("SIX")//Arquivo de indíce
EndIf	
SIX->(DbSetOrder(1))//INDICE+ORDEM

If !Empty(cAlias)
	
	If SIX->(DbSeek(cAlias))
		While SIX->(!EOF()) .AND. SIX->INDICE == cAlias
			AAdd(aIndic,{SIX->ORDEM,SIX->DESCRICAO,SIX->CHAVE,nX++})
			SIX->(DbSkip())
		EndDo 
       
       oDlg := FWDialogModal():New()
			oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela 
			oDlg:SetTitle(STR0024)//"Ordem de Pesquisa"
			oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
			oDlg:SetSize(200,300) //cria a tela maximizada (chamar sempre antes do CreateDialog)
			oDlg:EnableFormBar(.T.) 
	
			oDlg:CreateDialog() //cria a janela (cria os paineis)
			oPanel := oDlg:getPanelMain()
			oDlg:createFormBar()//cria barra de botoes
       	    oDlg:addYesNoButton()	
       
       		DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aIndic LINE BEGIN 1 OF oPanel
				ADD COLUMN oColEnt DATA &("{ || aIndic[oBrwMark:At()][1] }") TITLE STR0009 TYPE "C" SIZE 03 OF oBrwMark//"Ordem"
				ADD COLUMN oColEnt DATA &("{ || aIndic[oBrwMark:At()][2] }") TITLE STR0010 TYPE "C" SIZE 30 OF oBrwMark//"Descrição"
			ACTIVATE FWBROWSE oBrwMark	
       oDlg:Activate() 
       If oDlg:getButtonSelected() > 0
       	  IIF( (nCRM280ORD := aIndic[oBrwMark:At()][4]) > 0 , lRet := .T., lRet := .F.)
       Else
       	  lRet := .F.	
       EndIf 	
        		 
	EndIf
Else
	MsgAlert(STR0013)//"Selecione uma entidadade estrangeira !"
	lRet := .F.
EndIf

If !Empty(aAreaSIX)
	RestArea(aAreaSIX)
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA280VLDO()
                                   
Rotina para fazer a validaçlão do Indice e inserir os dados referente a ele nos campos correspondentes do modelo

@param		Nenhum	

@return	lRet

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Function CRMA280VLDO()

Local cAlias      := FwFldGet("AOE_ENTEST")
Local nOrdem      := FwFldGet("AOE_ORDEM")
Local lRet        := .F.
Local aAreaSIX    := {}

Local oModel      := FwModelActive()

If Select("SIX") > 0
	aAreaSIX := SIX->(GetArea())	
Else
	DbSelectArea("SIX")
EndIf	
SIX->(DbSetOrder(1))//INDICE+ORDEM

If !Empty(cAlias) .AND. nOrdem > 0 
	If SIX->(DbSeek(cAlias+RetAsc(nOrdem,1,.T.)))
	    // Tirando a Filial do indice, porque na rotina de mesclagem "CRM170MEEM" já é atribuida automaticamente
		cChave := SubStr(AllTrim(SIX->CHAVE) ,At("_FILIAL",UPPER(SIX->CHAVE))+8 ,Len(AllTrim(SIX->CHAVE)))
		oModel:GetModel("AOEMASTER"):SetValue("AOE_DESCCH" ,AllTrim(SIX->DESCRICAO) )
		oModel:GetModel("AOEMASTER"):SetValue("AOE_CHAVE"  ,cChave )
		lRet := .T.
	EndIF 
Else
	lRet := .F.	
EndIf

If !Empty(aAreaSIX)
	RestArea(aAreaSIX)
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280ORDR()
                                   
Rotina que retornará o conteudo do campo "nCRM280ORD". para a consulta padrão "AOEORD"

@param		Nenhum	

@return	nCRM280ORD - ordem escolhida pelo usuario

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Function CRM280ORDR() 

Return nCRM280ORD 



//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280CMPC()
                                   
Rotina para consulta do Campo da tabela estrangeira, que retornará seu conteudo.

@param		Nenhum	

@return	lRet 

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Function CRM280CMPC()

Local 	 cAlias      := FwFldGet("AOE_ENTEST")

Local 	 lRet        := .F.

Local   aAreaSX3    := {}
Local   aCampos     := {}

Local   oDlg        := Nil
Local 	 oColEnt     := Nil
Local   oBrwMark    := Nil
Local   oPanel      := Nil

Static  cCRM280CMP  := ""  //Variavel que receberá o valor do campo, para ser retornada pela função "CRM280CMPR()" na consulta padrão

If Select("SX3") > 0
	aAreaSX3 := SX3->(GetArea())	
Else
	DbSelectArea("SX3")//Arquivo de Campos
EndIf
SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM

If !Empty(cAlias)
	If SX3->(DbSeek(cAlias))
	   
	 	Do While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cAlias
	 		If	SX3->X3_CONTEXT <> "V" 
				AAdd( aCampos,{SX3->X3_CAMPO,SX3->X3_DESCRIC} )
			EndIf	
	 		SX3->( DbSkip())
	 	EndDo 
       
       oDlg := FWDialogModal():New()
			oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela 
			oDlg:SetTitle(STR0025)//"Campo de Retorno" 
			oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
			oDlg:SetSize(200,300) //cria a tela maximizada (chamar sempre antes do CreateDialog)
			oDlg:EnableFormBar(.T.) 
	
			oDlg:CreateDialog() //cria a janela (cria os paineis)
			oPanel := oDlg:getPanelMain()
			oDlg:createFormBar()//cria barra de botoes
       	oDlg:addYesNoButton()	

       	DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oPanel
				ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][1] }") TITLE STR0014 TYPE "C" SIZE 11 OF oBrwMark//"Campo"
				ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][2] }") TITLE STR0015 TYPE "C" SIZE 30 OF oBrwMark//"Descrição"
			ACTIVATE FWBROWSE oBrwMark	
		oDlg:Activate() 
       If oDlg:getButtonSelected() > 0
       	  cCRM280CMP := AllTrim(aCampos[oBrwMark:At()][1])
       	  lRet := .T.
       Else
       	  lRet := .F.	
       EndIf 	
	EndIf
Else
	MsgAlert(STR0018)//"Selecione uma entidadade estrangeira !"
	lRet := .F.
EndIf

If !Empty(aAreaSX3)
	RestArea(aAreaSX3)
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280CMPR()
                                   
Rotina que retornará o conteudo do campo "cCRM280CMP". para a consulta padrão "AOECMP"

@param		Nenhum	

@return	cCRM280CMP - Campo escolhido pelo usuario

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Function CRM280CMPR() 

Return cCRM280CMP



//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280ORIC()
                                   
Rotina para consulta da chave de origem 

@param		Nenhum	

@return	lRet 

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Function CRM280ORIC()

Local 	 cAlias      := FwFldGet("AOE_ENTIDA")

Local   cTGet       := ""
Local 	 lRet        := .F.
Local   lMark       := .F.

Local   aAreaSX3    := {}
Local   aCampos     := {}

Local   oDlg        := Nil
Local 	oColEnt     := Nil
Local 	oLINEONE    := Nil
Local   oLINETWO    := Nil
Local   oTGet       := Nil
Local   oPanel      := Nil

Local   oBrwMark    := .F.

Static  cCRM280ORI  := ""  //variavel que receberá a chave de origem

If Select("SX3") > 0
	aAreaSX3 := SX3->(GetArea())	
Else
	DbSelectArea("SX3")//Arquivo de Campos
EndIf
SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM

If !Empty(cAlias)
	If SX3->(DbSeek(cAlias))
	    
 		Do While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cAlias
 			If	SX3->X3_CONTEXT <> "V" 
 				AAdd( aCampos,{lMark,SX3->X3_CAMPO,SX3->X3_DESCRIC} )
 			EndIf	
 			SX3->( DbSkip())
 		EndDo 
       
       oDlg := FWDialogModal():New()
			oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela 
			oDlg:SetTitle(STR0026)//"Chave de Origem"
			oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
			oDlg:SetSize(200,300) //cria a tela maximizada (chamar sempre antes do CreateDialog)
			oDlg:EnableFormBar(.T.) 
	
			oDlg:CreateDialog() //cria a janela (cria os paineis)
			oPanel := oDlg:getPanelMain()
			oDlg:createFormBar()//cria barra de botoes
       	oDlg:addYesNoButton()	

			oFwLayer := FwLayer():New()
			oFwLayer:init(oPanel,.F.) 
			oFWLayer:AddLine( "LINEONE",10, .F.)
			oFWLayer:AddLine( "LINETWO",90, .F.)
			oLINEONE := oFwLayer:GetLinePanel("LINEONE")
			oLINETWO := oFwLayer:GetLinePanel("LINETWO")
	
			oTGet := TGet():New( 03,05,{||cTGet},oLINEONE,0290,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet,,,, )
			
       	DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oLINETWO  
              ADD MARKCOLUMN oColEnt DATA {|| IIF(aCampos[oBrwMark:At()][1],"LBOK","LBNO") } DOUBLECLICK {||aCampos[oBrwMark:At()][1] := !aCampos[oBrwMark:At()][1] ,MntChaveORI(oBrwMark,aCampos,oTGet,@cTGet)} OF oBrwMark 
				ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][2] }") TITLE STR0019 TYPE "C" SIZE 11 OF oBrwMark//"Campo"
				ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][3] }") TITLE STR0020 TYPE "C" SIZE 30 OF oBrwMark//"Descrição"
			ACTIVATE FWBROWSE oBrwMark	

       oDlg:Activate() 
       If oDlg:getButtonSelected() > 0
       	  cCRM280ORI := cTGet
       	  lRet := .T.
       Else
       	  lRet := .F.	
       EndIf     
	EndIf
Else
	MsgAlert(STR0023)//"Selecione uma entidadade !"
	lRet := .F.
EndIf

If !Empty(aAreaSX3)
	RestArea(aAreaSX3)
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280ORIR()
                                   
Rotina que retornará o conteudo do campo "cCRM280ORI". para a consulta padrão "AOEORI"

@param		Nenhum	

@return	cCRM280ORI - Chave de origem

@author	Victor Bitencourt
@since		31/03/2014
@version	12.0                
/*/
//------------------------------------------------------------------------------
Function CRM280ORIR() 

Return cCRM280ORI

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntChaveORI()
                                   
Rotina para gerar o a chave de Origem para a mesclagem

@param	  	ExpO1 = objeto do Browse que será manipulado
		  	ExpA1 = Array contendo os dados dos registros que o Browse utiliza
		  	ExpO2 = Objeto do campo Get que será manipulado
		 	ExpC1 = Variavel onde será atribuido o Codigo Gerado

@return	Nenhum

@author	Victor Bitencourt
@since		31/03/2014
@version	12.0                
/*/
//-----------------------------------------------------------------------------
Static Function MntChaveORI(oBrwMark,aCampos,oTGet,cTGet)

Local   cMais    := "+"

Default aCampos  := {}
Default oTGet    := Nil
Default oBrwMark := Nil

cTGet := Upper(cTGet)

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos) 
	If aCampos[oBrwMark:At()][1] == .T.
		If At(aCampos[oBrwMark:At()][2],cTGet) <= 0 
		   If !Empty(cTGet)
		   		cTGet += cMais + aCampos[oBrwMark:At()][2]
		   Else
		   		cTGet += aCampos[oBrwMark:At()][2]
		   EndIf
		EndIf
	ElseIf aCampos[oBrwMark:At()][1] == .F.	
	 	If At(cMais+aCampos[oBrwMark:At()][2],cTGet) > 0
	 		cTGet := StrTran(cTGet,cMais+Upper(aCampos[oBrwMark:At()][2]),"",,1)
	 	ElseIf  At(aCampos[oBrwMark:At()][2]+cMais,cTGet) > 0
	 		cTGet := StrTran(cTGet,Upper(aCampos[oBrwMark:At()][2]+cMais),"",,1)
	 	ElseIf At(aCampos[oBrwMark:At()][2],cTGet) > 0
	 	 	cTGet := StrTran(cTGet,Upper(aCampos[oBrwMark:At()][2]),"",,1)
	 	EndIf 	
	EndIf		
	If ValType(oTGet) == "O"
		oTGet:CtrlRefresh() 
	EndIf
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280VLDT()
                                   
Rotina para validar se existe o Campo Complementar definido para entidade a cadastrar

@param	    Nenhum

@return	lRet - Se foi encontrado ou não a chave

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//-----------------------------------------------------------------------------
Function CRM280VLDT()
 
Local cEntida  := FwFldGet("AOE_ENTIDA")
Local cCMPCOM  := FwFldGet("AOE_CMPCOM")
Local lRet     := .T.
Local aAreaAOE := {}     

If Select("AOE") > 0
	aAreaAOE := AOE->(GetArea())	
Else
	DbSelectArea("AOE")//Cadastro de Tag
EndIf
AOE->(DbSetOrder(1)) //AOE_FILIAL+AOE_ENTIDA+AOE_CMPCOM

If !Empty(cEntida) .AND. !Empty(cCMPCOM)
	If AOE->(DbSeek(xFilial("AOE")+AllTrim(cEntida+cCMPCOM)))
		lRet := .F.
	EndIf
EndIf

If !Empty(aAreaAOE)
	RestArea(aAreaAOE)
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM280VLDC()
                                   
Rotina para validar se o campo de retorno existe na SX3

@param	    Nenhum

@return	lRet - Se existe ou não o campo

@author	Victor Bitencourt
@since		28/03/2014
@version	12.0                
/*/
//-----------------------------------------------------------------------------
Function CRM280VLDC()
 
Local cCampo   := FwFldGet("AOE_CAMPO")
Local lRet     := .T.
Local aAreaSX3 := {}     

If Select("SX3") > 0
	aAreaSX3 := SX3->(GetArea())	
Else
	DbSelectArea("SX3")//Arquivo de Campos
EndIf
SX3->(DbSetOrder(2)) //X3_CAMPO

If !Empty(cCampo) 
	If SX3->(DbSeek(cCampo))
		lRet := .T.
	Else
		lRet := .F.
	EndIf
EndIf

If !Empty(aAreaSX3)
	RestArea(aAreaSX3)
EndIf

Return lRet


//----------------------------------------------------------
/*/{Protheus.doc} ModelCommit()
 
Validação dos Dados , após dar o Commit no model.. verifica qual a operação 
que estava sendo realizada , para poder enviar os dados para o exchange 

@param	  ExpO1 = oModel .. objeto do modelo de dados corrente.
       
@return  .T.

@author   Victor Bitencourt
@since    25/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelCommit(oModel)

Local nOperation  := oModel:GetModel("AOEMASTER"):GetOperation()

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE 
	oModel:SetValue("AOEMASTER","AOE_CMPCOM",StrTran(FwFldGet("AOE_CMPCOM")," ",""))//Tirando os espaços do campo
EndIf	
 
FWFormCommit(oModel)//Salvando o formulario.

Return (.T.)