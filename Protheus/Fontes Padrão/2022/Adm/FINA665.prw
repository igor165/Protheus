#INCLUDE "FINA665.ch"
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#Include 'FWEDITPANEL.CH'

#DEFINE _DATAINI  6
#DEFINE _DATAFIM  7
#DEFINE _CODORI   2
#DEFINE _DESORI   3
#DEFINE _CODDES   4
#DEFINE _DESDES   5 
#DEFINE OPER_CONFER		7
#DEFINE OPER_APROVA		8
#DEFINE OPER_CUSTO		9

Static __nOper 			:= 0 // Operacao da rotina
Static __cProcPrinc  	:= "FINA665"
Static __lConfirmar     := .T.
Static __lConfReprova 	:= .F.
Static __lBTNEstornar	:= .F.
Static __cQueryFLU		:= Nil
Static __aBind			:= Nil

/*/{Protheus.doc}FINA665
Cadastro de Viagens - Integração Reserve.
@author William Matos Gundim Junior
@since  11/10/2013
@version 11.90
/*/
Function FINA665()
Local oBrowse  := FWmBrowse():New()
Local lF665Fil := ExistBlock("F665FilBrw")
Local cFiltro  := ''
Private aUsuario := {}
aUsuario := FN683PARTI()
If(!aUsuario[1] == 'NO')
	oBrowse:SetAlias('FL5')
	If !aUsuario[1] == 'ALL' 
		If lF665Fil
			cFiltro := ExecBlock("F665FilBrw",.F.,.F.,{aUsuario})
		Else
			cFiltro := 'F665Filtro(aUsuario)'
		EndIf
		oBrowse:SetFilterDefault(cFiltro)
	EndIf	
	oBrowse:SetDescription(STR0001) // Solicitação de Viagens. 
	//Adiciona Legenda                                           
	oBrowse:AddLegend("FL5_STATUS == '1' " , "GREEN" ,STR0023) //Aguardando Conferencia
	oBrowse:AddLegend("FL5_STATUS == '2' " , "YELLOW",STR0024) //Conferida
	oBrowse:AddLegend("FL5_STATUS == '3' " , "RED"   ,STR0025) //Fechada
	oBrowse:AddLegend("FL5_STATUS == 'X' " , "LBLUE" ,STR0005)	//Adiantamento Bloqueado
	oBrowse:AddLegend("FL5_STATUS == '4' " , "BLACK" ,STR0004)	//Cancelada.		
	oBrowse:AddLegend("FL5_STATUS == '5' " , "BROWN" ,STR0081)	//Aguardando Aprovação
	oBrowse:AddLegend("FL5_STATUS == '6' " , "BLUE"  ,STR0085)  //Solicitada
	oBrowse:AddLegend("FL5_STATUS == '7' " , "ORANGE"  ,STR0075)//Fatura Antecipada
	oBrowse:Activate()
	F665ClrTmp()
Else
	Help(" ",1,"F665ACESSO",,STR0016,1,0)	
EndIf
Return

/*/{Protheus.doc} F665Filtro
Filtros 	usuários com acessos.
@author		William Matos Gundim Junior
@since  	16/10/2013
@version 	11.90
@param 		aUsuario, array, participantes que o usuário logado tem acesso
@return		logical, se usuário logado por ou não visualizar a viagem
/*/
Function F665Filtro(aUsuario As Array) As Logical

	Local aArea			As Array
	Local cAliasTMP		As Character
	Local cBindIn		As Character	
	Local lFiltro		As Logical
	Local nX			As Numeric

	Default aUsuario	:= {}

	cAliasTMP	:= ""
	cBindIn		:= ""
	lFiltro		:= .F.
	nX			:= 1

	If Empty(aUsuario)
		Return lFiltro
	EndIf

	aArea 		:= GetArea()

	If __cQueryFLU == Nil .Or. __aBind == Nil
		__aBind := {FL5->FL5_FILIAL, FL5->FL5_VIAGEM}

		For nX := 1 To Len(aUsuario)
			cBindIn += ",?"
			AAdd(__aBind, aUsuario[nX])
		Next nX

		cBindIn := "(" + SubStr(cBindIn, 2) + ")"

		__cQueryFLU := " SELECT FLU_VIAGEM FROM " + RetSQLName("FLU") + " FLU "
		__cQueryFLU += " WHERE FLU_FILIAL = ? "
		__cQueryFLU += " AND D_E_L_E_T_ = ' ' "  
		__cQueryFLU += " AND FLU_VIAGEM = ? AND FLU_PARTIC IN " + cBindIn
		__cQueryFLU := ChangeQuery(__cQueryFLU)
	Else
		__aBind[1] := FL5->FL5_FILIAL //Filial
		__aBind[2] := FL5->FL5_VIAGEM //Viagem
	EndIf
 
	cAliasTMP := GetNextAlias()

 	DbUseArea(.T., "TOPCONN", TcGenQry2(Nil, Nil, __cQueryFLU, __aBind), cAliasTMP, .T., .T.)
	(cAliasTMP)->(DbGoTop())
	If !(cAliasTMP)->(EoF())
		lFiltro := .T.
	EndIf

	(cAliasTMP)->(DbCloseArea())
	RestArea(aArea)

Return lFiltro

/*/{Protheus.doc} F665ClrTmp
Limpa variáveis static na saída da rotina.

@author		Rafael Riego
@since  	04/03/2021
/*/
Function F665ClrTmp()

	__cQueryFLU := Nil
	FwFreeArray(__aBind)
	__aBind		:= Nil

Return Nil

/*/{Protheus.doc}F665IncItem
Incrementa automaticamente os itens
@author William Matos Gundim Junior
@since  11/10/2013
@version 11.90
/*/
Function F665IncItem(oModel,cCampo)
Local cRet	
	If oModel:Length() > 0 
		oModel:GoLine( oModel:Length() )
		cRet := Soma1(oModel:GetValue(cCampo))
	Else
		cRet := '01' 
	EndIf	
Return cRet 

/*/{Protheus.doc} ModelDef
Modelo de negócio do cadastro de viagens.
@author William Matos Gundim Junior
@since  11/10/2013
@version 11.90
/*/
Static Function ModelDef()
Local oModel    := MPFormModel():New('FINA665')  // Cria objeto do modelo de dados.
Local oStruFL5  := FWFormStruct(1,'FL5')		  // FL5 - Solicitação de Viagens	
Local oStruFLC  := FWFormStruct(1,'FLC')         // FLC - Passageiros.		 
Local oStruFLD  := FWFormStruct(1,'FLD')		  // FLD - Adiantamentos.
Local oStruFl7  := FWFormStruct(1,'FL7')		  // FL7 - Passagem Aerea.
Local oStruFL9  := FWFormStruct(1,'FL9')		  // FL9 - Hospedagem.
Local oStruFL8  := FWFormStruct(1,'FL8')		  // FL8 - Rodoviario.
Local oStruFLB  := FWFormStruct(1,'FLB')		  // FLB - Locação.
Local oStruFLA  := FWFormStruct(1,'FLA')		  // FLA - Seguros.
Local oStruFLJ  := FWFormStruct(1,'FLJ')		  // FLJ - Aprovadores.
Local oStruFLH  := FWFormStruct(1,'FLH')		  // FLH - Rateio CC.
Local oStruFL6  := FWFormStruct(1,'FL6')		  // FL6 - SUP_RESERVas.
Local oStruFLU  := FWFormStruct(1,'FLU')         // FLU - Passageiro por Reserva.
Local oStruFW7  := FWFormStruct(1,'FW7')         // FW7 - Outros

Local aRelacFL6 := {}
Local aRelacFLC := {}
Local aRelacFLD := {}
Local aRelacFL7 := {}
Local aRelacFL8 := {}
Local aRelacFL9 := {}
Local aRelacFLA := {}
Local aRelacFLB := {}
Local aRelacFLJ := {}
Local aRelacFLH := {}
Local aRelacFLU := {}
Local aRelacFW7 := {}

//trigger na estrutura da FW7
oStruFW7:AddTrigger("FW7_CODORI"  	, "FW7_DESORI"	  	, {|| .T. }  , {|| FN665ODesc() }  )
oStruFW7:AddTrigger("FW7_CODDES"  	, "FW7_DESDES"	  	, {|| .T. }  , {|| FN665DDesc() }  )
If __nOper == OPER_CONFER
	oStruFL6:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFL9:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFL8:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFLA:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFLB:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFLJ:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFL7:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFW7:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFLC:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFLU:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFL6:SetProperty('FL6_TIPO', MODEL_FIELD_WHEN, {|| .F.}  )
EndIf

oStruFL6:SetProperty('FL6_ITEM'  ,MODEL_FIELD_INIT,{|o|F665IncItem(o,'FL6_ITEM')})
oStruFL9:SetProperty('FL9_SUBITM',MODEL_FIELD_INIT,{|o|F665IncItem(o,'FL9_SUBITM')})
oStruFL8:SetProperty('FL8_SUBITM',MODEL_FIELD_INIT,{|o|F665IncItem(o,'FL8_SUBITM')})
oStruFLA:SetProperty('FLA_SUBITM',MODEL_FIELD_INIT,{|o|F665IncItem(o,'FLA_SUBITM')})
oStruFLB:SetProperty('FLB_SUBITM',MODEL_FIELD_INIT,{|o|F665IncItem(o,'FLB_SUBITM')})
oStruFLJ:SetProperty('FLJ_SUBITM',MODEL_FIELD_INIT,{|o|F665IncItem(o,'FLJ_SUBITM')})
oStruFL7:SetProperty('FL7_SUBITM',MODEL_FIELD_INIT,{|o|F665IncItem(o,'FL7_SUBITM')})
oStruFW7:SetProperty('FW7_SUBITM',MODEL_FIELD_INIT,{|o|F665IncItem(o,'FW7_SUBITM')})

//Descricao para a tabela de pedidos - FW7.
oStruFW7:SetProperty("FW7_DESORI",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FL5->FL5_DESORI'))
oStruFW7:SetProperty("FW7_DESDES",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FL5->FL5_DESDES'))
//Cria campo Descricao para a tabela de centro de custo - FLH.
oStruFLH:AddField(STR0076,"","Desc","C",50,0,,,,.F.,,,,.T.,) //"Descrição"
oStruFLH:SetProperty('Desc'		 ,MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'Posicione("CTT",1,xFilial("CTT")+FLH->FLH_CC,"CTT_DESC01")'))
oStruFLH:SetProperty('FLH_DSCLVL',MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'Posicione("CTH",1,xFilial("CTH")+FLH->FLH_CLVL,"CTH_DESC01")'))
oStruFLH:SetProperty('FLH_DSITCT',MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'Posicione("CTD",1,xFilial("CTD")+FLH->FLH_ITECTA,"CTD_DESC01")'))
//Cria campo virtual para a FL6/FLD;
oStruFL6:AddField(' ','FL6_LEG' ,'FL6_LEG'	,'BT',1,0,/*bValid*/, /*bWhen*/,,.F.,{||F665Leg('FL6')})		
oStruFLD:AddField(' ','FLD_LEG' ,'FLD_LEG'	,'BT',1,0,/*bValid*/, /*bWhen*/,,.F.,{||F665Leg('FLD')})		

oModel:AddFields('FL5MASTER',/*Pai(cOwner)*/,oStruFL5)

oModel:AddGrid('FLCDETAIL','FL5MASTER',oStruFLC)
oModel:AddGrid('FLDDETAIL','FLCDETAIL',oStruFLD)
oModel:AddGrid('FL6DETAIL','FL5MASTER',oStruFL6)
oModel:AddGrid('FL7DETAIL','FL6DETAIL',oStruFL7)
oModel:AddGrid('FL9DETAIL','FL6DETAIL',oStruFL9)
oModel:AddGrid('FL8DETAIL','FL6DETAIL',oStruFL8)
oModel:AddGrid('FLBDETAIL','FL6DETAIL',oStruFLB)
oModel:AddGrid('FLADETAIL','FL6DETAIL',oStruFLA)
oModel:AddGrid('FLJDETAIL','FL6DETAIL',oStruFLJ)
oModel:AddGrid('FLHDETAIL','FL6DETAIL',oStruFLH)
oModel:AddGrid('FLUDETAIL','FL6DETAIL',oStruFLU)
oModel:AddGrid('FW7DETAIL','FL6DETAIL',oStruFW7)
	

oModel:SetPrimaryKey({"FL5_FILIAL", "FL5_VIAGEM"})

//Cria relacionamento FL6 -> FL5 (SUP_RESERVas X Viagem)
aAdd(aRelacFL6,{'FL6_FILIAL','xFilial("FL6")'})
aAdd(aRelacFL6,{'FL6_VIAGEM','FL5_VIAGEM'})

//Cria relacionamento FLC -> FL5 (Passageiro X Viagem)
aAdd(aRelacFLC,{'FLC_FILIAL','xFilial("FLC")'})
aAdd(aRelacFLC,{'FLC_VIAGEM','FL5_VIAGEM'})

//Cria relacionamento FLD -> FLC (Adiantamento X Passageiro)
aAdd(aRelacFLD,{'FLD_FILIAL','xFilial("FLD")'})
aAdd(aRelacFLD,{'FLD_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFLD,{'FLD_PARTIC','FLC_PARTIC'})

//Cria relacionamento FL7 -> FL6 (Aerea X SUP_RESERVa)
aAdd(aRelacFL7,{'FL7_FILIAL','xFilial("FL7")'})
aAdd(aRelacFL7,{'FL7_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFL7,{'FL7_ITEM'  ,'FL6_ITEM'})

//Cria relacionamento FW7 -> FL6 (Outros X Pedidos)
aAdd(aRelacFW7,{'FW7_FILIAL','xFilial("FW7")'})
aAdd(aRelacFW7,{'FW7_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFW7,{'FW7_ITEM'  ,'FL6_ITEM'  })

//Cria relacionamento FL8 -> FL6 (Rodoviario X SUP_RESERVa)
aAdd(aRelacFL8,{'FL8_FILIAL','xFilial("FL8")'})
aAdd(aRelacFL8,{'FL8_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFL8,{'FL8_ITEM'  ,'FL6_ITEM'  })
	
//Cria relacionamento FL9 -> FL6 (Hospedagem X SUP_RESERVa)	
aAdd(aRelacFL9,{'FL9_FILIAL','xFilial("FL9")'})
aAdd(aRelacFL9,{'FL9_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFL9,{'FL9_ITEM'  ,'FL6_ITEM'  })

//Cria relacionamento FLA -> FL6 (Seguro X SUP_RESERVa)	
aAdd(aRelacFLA,{'FLA_FILIAL','xFilial("FLA")'})
aAdd(aRelacFLA,{'FLA_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFLA,{'FLA_ITEM'  ,'FL6_ITEM'  })

//Cria relacionamento FLB -> FL6 (Locação X SUP_RESERVa)	
aAdd(aRelacFLB,{'FLB_FILIAL','xFilial("FLB")'})
aAdd(aRelacFLB,{'FLB_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFLB,{'FLB_ITEM'  ,'FL6_ITEM'  })

//Cria relacionamento FLU -> FL6 (Passag. Pedido X Pedidos)
aAdd(aRelacFLU,{'FLU_FILIAL','xFilial("FLU")'})
aAdd(aRelacFLU,{'FLU_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFLU,{'FLU_ITEM'  ,'FL6_ITEM'  })

//Cria relacionamento FLJ -> FL6 (Aprovadores X SUP_RESERVa)	
aAdd(aRelacFLJ,{'FLJ_FILIAL','xFilial("FLJ")'})
aAdd(aRelacFLJ,{'FLJ_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFLJ,{'FLJ_ITEM'  ,'FL6_ITEM'  })

//Cria relacionamento FLH -> FL6 (Rateio X SUP_RESERVa)
aAdd(aRelacFLH,{'FLH_FILIAL','xFilial("FLH")'})
aAdd(aRelacFLH,{'FLH_VIAGEM','FL5_VIAGEM'})
aAdd(aRelacFLH,{'FLH_ITEM'  ,'FL6_ITEM'  })

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FLCDETAIL', aRelacFLC , FLC->(IndexKey(1)))
oModel:SetRelation( 'FLDDETAIL', aRelacFLD , FLD->(IndexKey(1)))
oModel:SetRelation( 'FL7DETAIL', aRelacFL7 , FL7->(IndexKey(1)))
oModel:SetRelation( 'FL8DETAIL', aRelacFL8 , FL8->(IndexKey(1)))
oModel:SetRelation( 'FL9DETAIL', aRelacFL9 , FL9->(IndexKey(1)))
oModel:SetRelation( 'FLADETAIL', aRelacFLA , FLA->(IndexKey(1)))
oModel:SetRelation( 'FLBDETAIL', aRelacFLB , FLB->(IndexKey(1)))
oModel:SetRelation( 'FLJDETAIL', aRelacFLJ , FLJ->(IndexKey(1)))
oModel:SetRelation( 'FLHDETAIL', aRelacFLH , FLH->(IndexKey(1)))
oModel:SetRelation( 'FL6DETAIL', aRelacFL6 , FL6->(IndexKey(1)))
oModel:SetRelation( 'FLUDETAIL', aRelacFLU , FLU->(IndexKey(1)))
oModel:SetRelation( 'FW7DETAIL', aRelacFW7 , FW7->(IndexKey(1)))
	
//Deixa o preenchimento como opcional
oModel:GetModel( 'FLDDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FL7DETAIL' ):SetOptional( .T. ) // Aereo.
oModel:GetModel( 'FLHDETAIL' ):SetOptional( .T. ) // Centro de Custo.
oModel:GetModel( 'FL9DETAIL' ):SetOptional( .T. ) // Hospedagem.
oModel:GetModel( 'FL8DETAIL' ):SetOptional( .T. ) // Rodoviario.
oModel:GetModel( 'FLBDETAIL' ):SetOptional( .T. ) // Locação.
oModel:GetModel( 'FLJDETAIL' ):SetOptional( .T. ) // Aprovadores.
oModel:GetModel( 'FLADETAIL' ):SetOptional( .T. ) // Seguros.
oModel:GetModel( 'FLCDETAIL' ):SetOptional( .T. ) // Passageiro.
oModel:GetModel( 'FLUDETAIL' ):SetOptional( .T. ) // Passag. por Pedidos.
oModel:GetModel( 'FW7DETAIL' ):SetOptional( .T. ) // Outros

//Descricao
oModel:SetDescription(STR0001)                          //Cadastro de Viagens
oModel:GetModel('FL5MASTER'):SetDescription(STR0001) //Cadastro de Viagens
oModel:GetModel('FLCDETAIL'):SetDescription(STR0006) //Passageiros
oModel:GetModel('FLUDETAIL'):SetDescription(STR0006) //Passageiros
oModel:GetModel('FLDDETAIL'):SetDescription(STR0007) //Adiantamentos
oModel:GetModel('FL6DETAIL'):SetDescription(STR0008) //Pedidos
oModel:GetModel('FLHDETAIL'):SetDescription(STR0086) //Custos
oModel:GetModel('FLJDETAIL'):SetDescription(STR0010) //Aprovadores

Return oModel

/*/{Protheus.doc} F655Gat
Gatilho para o campo FL6_TIPO
@author William Matos Gundim Junior
@since  11/10/2013
@version 11.90
/*/
Function F655Gat(oModel)
Local oModelFL6 := oModel:GetModel('FL6DETAIL')
Local oView   := FWViewActive()
Local nPos    := oModelFL6:GetValue('FL6_TIPO')   
Local iCount  := 1 

If !Empty(nPos) .AND. Val(nPos) > 0 
	For iCount := 0 To 6
		oView:HideFolder('PASTA_TIPOS',iCount,2) 
    Next iCount
    oView:SelectFolder('PASTA_TIPOS',Val(nPos),2)
EndIf

If __nOper == OPER_CONFER
	oView:HideFolder('PASTA_DIR',1,2)
EndIf

Return .T. 

/*/{Protheus.doc} ViewDef
Interface do cadastro de viagens.
@author William Matos Gundim Junior
@since  11/10/2013
@version 11.90
/*/
Static Function ViewDef()
Local oModel   := FWLoadModel('FINA665')         //Carrega o model
Local oStruFL5 := FWFormStruct(2,'FL5')		  // FL5 - Solicitação de Viagens	
Local oStruFLC := FWFormStruct(2,'FLC')          // FLC - Passageiros.		 
Local oStruFLD := FWFormStruct(2,'FLD')		  // FLD - Adiantamentos.
Local oStruFL7 := FWFormStruct(2,'FL7')		  // FL7 - Passagem Aerea.
Local oStruFL9 := FWFormStruct(2,'FL9')		  // FL9 - Hospedagem.	
Local oStruFL8 := FWFormStruct(2,'FL8')		  // FL8 - Rodoviario.
Local oStruFLB := FWFormStruct(2,'FLB')		  // FLB - Locação.
Local oStruFLA := FWFormStruct(2,'FLA')		  // FLA - Seguros.
Local oStruFLJ := FWFormStruct(2,'FLJ')		  // FLJ - Aprovadores.
Local oStruFLH := FWFormStruct(2,'FLH')		  // FLH - Rateio CC.
Local oStruFL6 := FWFormStruct(2,'FL6')		  // FL6 - SUP_RESERVas.
Local oStruFLU := FWFormStruct(2,'FLU')          // FLU - Passag. por Pedido.
Local oStruFW7 := FWFormStruct(2,'FW7')          // FW7 - Outros.
Local oView     := FWFormView():New()	          //Objeto da view

//Remove campos da estrutura.
oStruFLC:RemoveField( 'FLC_VIAGEM' )
oStruFLC:RemoveField( 'FLC_IDRESE' )
oStruFL7:RemoveField( 'FL7_VIAGEM' )
oStruFL7:RemoveField( 'FL7_ITEM'	)
oStruFL8:RemoveField( 'FL8_VIAGEM' )
oStruFL8:RemoveField( 'FL8_ITEM'	)
oStruFL9:RemoveField( 'FL9_VIAGEM' )
oStruFL9:RemoveField( 'FL9_ITEM'	)
oStruFLA:RemoveField( 'FLA_VIAGEM' )
oStruFLA:RemoveField( 'FLA_ITEM'	)
oStruFLB:RemoveField( 'FLB_VIAGEM' )
oStruFLB:RemoveField( 'FLB_ITEM'	)
oStruFLU:RemoveField( 'FLU_VIAGEM' )
oStruFLU:RemoveField( 'FLU_IDRESE' )
oStruFLU:RemoveField( 'FLU_ITEM'	)
oStruFW7:RemoveField( 'FW7_VIAGEM' )
oStruFW7:RemoveField( 'FW7_ITEM'	)
oStruFLH:RemoveField( 'FLH_VIAGEM' )	
oStruFLH:RemoveField( 'FLH_ITEM'	)
oStruFLJ:RemoveField( 'FLJ_VIAGEM' )
oStruFLJ:RemoveField( 'FLJ_ITEM'	)
oStruFLD:RemoveField( 'FLD_VIAGEM' )
oStruFLD:RemoveField( 'FLD_ITEM'	)
oStruFLD:RemoveField( 'FLD_SOLIC'  )
oStruFLD:RemoveField( 'FLD_APROV'  )
oStruFLD:RemoveField( 'FLD_PARTIC' )
oStruFLD:RemoveField( 'FLD_NOMEPA' )
oStruFL6:RemoveField( 'FL6_EXTRA2' )
oStruFL6:RemoveField( 'FL6_EXTRA3' )
oStruFL5:RemoveField( 'FL5_ADIANT' )
oStruFL5:RemoveField( 'FL5_CC'	   )
oStruFL5:RemoveField( 'FL5_LICRES')
oStruFL5:RemoveField( 'FL5_IDRESE')
oStruFL5:RemoveField( 'FL5_CLIENT')
oStruFL5:RemoveField( 'FL5_LOJA')
oStruFL5:RemoveField( 'FL5_NOME')
oStruFLC:RemoveField( 'FLC_BILHET') 
oStruFL6:RemoveField( 'FL6_LICENC')
oStruFL6:RemoveField( 'FL6_BKOFAT') 
oStruFL6:RemoveField( 'FL6_IDSOL')
oStruFL6:RemoveField( 'FL6_IDRESP')
oStruFL6:RemoveField( 'FL6_PARTSO')
oStruFL6:RemoveField( 'FL6_PARTRE')

oView:SetModel( oModel ) 				  //Modelo usado pela view

oStruFL6:RemoveField( 'FL6_VIAGEM' )

oView:AddField('VIEW_FL5',oStruFL5,'FL5MASTER')

oStruFLH:AddField("Desc","05",'Descrição','Descrição',,"")

//Adiciona campo legenda.
oStruFL6:AddField( 'FL6_LEG','01','','',/*aHelp*/,"BT")
oStruFLD:AddField( 'FLD_LEG','01','','',/*aHelp*/,"BT")

//-----------Cria Grid-----------------------//
oView:AddGrid('VIEW_FLC',oStruFLC,'FLCDETAIL')
oView:AddGrid('VIEW_FLD',oStruFLD,'FLDDETAIL')
oView:AddGrid('VIEW_FL7',oStruFL7,'FL7DETAIL')
oView:AddGrid('VIEW_FL9',oStruFL9,'FL9DETAIL')
oView:AddGrid('VIEW_FL8',oStruFL8,'FL8DETAIL')
oView:AddGrid('VIEW_FLB',oStruFLB,'FLBDETAIL')
oView:AddGrid('VIEW_FLU',oStruFLU,'FLUDETAIL')
oView:AddGrid('VIEW_FLA',oStruFLA,'FLADETAIL')
oView:AddGrid('VIEW_FLJ',oStruFLJ,'FLJDETAIL')
oView:AddGrid('VIEW_FLH',oStruFLH,'FLHDETAIL')
oView:AddGrid('VIEW_FL6',oStruFL6,'FL6DETAIL')
oView:AddGrid('VIEW_FW7',oStruFW7,'FW7DETAIL')

//---------Verifica tipo da viagem a cada troca de linha---------------//
oView:SetViewProperty("VIEW_FL5","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:SetViewProperty("VIEW_FL6","CHANGELINE",{{||F655Gat(oModel)}})

//Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_FL7', 'FL7_SUBITM' )
oView:AddIncrementField( 'VIEW_FL9', 'FL9_SUBITM' )
oView:AddIncrementField( 'VIEW_FL8', 'FL8_SUBITM' )
oView:AddIncrementField( 'VIEW_FLB', 'FLB_SUBITM' )
oView:AddIncrementField( 'VIEW_FLA', 'FLA_SUBITM' )
oView:AddIncrementField( 'VIEW_FLJ', 'FLJ_SUBITM' )
oView:AddIncrementField( 'VIEW_FW7', 'FW7_SUBITM' )
oView:AddIncrementField( 'VIEW_FL6', 'FL6_ITEM'	 )
oView:AddIncrementField( 'VIEW_FLU', 'FLU_ITEM'	 )

//----------Cria Box------------------------//
oView:CreateVerticalBox( 'DIR' , 70 )
oView:CreateVerticalBox( 'ESQ' , 30 )

//----------Cria Folder na view-----------------//
oView:CreateFolder('PASTA_SUPERIOR','ESQ')
oView:CreateFolder('PASTA_DIR','DIR')

//----------Cria abas no Folder-----------------------------------------------//
oView:AddSheet( 'PASTA_DIR'  , 'ABA_PASSAG' ,STR0007) // Aba Passageiro.
oView:AddSheet( 'PASTA_DIR'  , 'ABA_SUP_RESERV' ,STR0008   ) // Aba Pedidos.

//-------------Criar box Passageiros e grids relacionados---------------------------//
oView:CreateVerticalBox(   'CONF_PASSAG'  , 100,,,'PASTA_DIR', 'ABA_PASSAG' )
oView:CreateHorizontalBox( 'DADOS_PASSAG' , 050,'CONF_PASSAG',, 'PASTA_DIR', 'ABA_PASSAG' )
oView:CreateHorizontalBox( 'ADIANT'        , 050,'CONF_PASSAG',, 'PASTA_DIR', 'ABA_PASSAG' )

//------------------------------------------------------------------------------//
oView:CreateHorizontalBox( 'SUP_RESERV', 040,,,'PASTA_DIR','ABA_SUP_RESERV')
oView:CreateHorizontalBox('MEIO_DIR' ,030 ,,,'PASTA_DIR','ABA_SUP_RESERV')
oView:CreateHorizontalBox('INF_DIR',040,'MEIO_DIR',, 'PASTA_DIR', 'ABA_SUP_RESERV' )
//----------Cria pasta Tipos de Viagem-----------------------------------//
oView:CreateFolder('PASTA_TIPOS','MEIO_DIR')

//
oView:CreateFolder('PASTA_APROV','INF_DIR')

//------------Cria abas dentro da SUP_RESERVas(Tipos Viagem)----------------//
oView:AddSheet('PASTA_TIPOS','ABA_AEREO'       ,STR0011)      // Aba Aereo.
oView:AddSheet('PASTA_TIPOS','ABA_HOSPEDAGEM' ,STR0012)      // Aba Hospedagem.
oView:AddSheet('PASTA_TIPOS','ABA_LOCAC'       ,STR0014)		 // Aba Locação.
oView:AddSheet('PASTA_TIPOS','ABA_SEG'         ,STR0015)		 // Aba Seguro.
oView:AddSheet('PASTA_TIPOS','ABA_RODOV'       ,STR0013)		 // Aba Rodoviario.     
oView:AddSheet('PASTA_TIPOS','ABA_OUTROS'      ,STR0031)		 // Aba Outros.

//------------Cria abas dentro da SUP_RESERVas(Aprova/CC)-------//
oView:AddSheet('PASTA_APROV','ABA_CC'   ,STR0086)          // Aba CC.
oView:AddSheet('PASTA_APROV','ABA_APROV',STR0010)		 // Aba Aprovadores.
oView:AddSheet('PASTA_APROV','ABA_PASSAG'		 ,STR0006)		 // Aba Passageiro.

//-----------Cria box da aba SUP_RESERVA------------------------------------//
oView:CreateHorizontalBox('GRID_AEREO',100,,,'PASTA_TIPOS', 'ABA_AEREO' )
oView:CreateHorizontalBox('GRID_HOSP',100,,,'PASTA_TIPOS','ABA_HOSPEDAGEM')
oView:CreateHorizontalBox('GRID_RODOV',100,,,'PASTA_TIPOS','ABA_RODOV')
oView:CreateHorizontalBox('GRID_LOCAC',100,,,'PASTA_TIPOS','ABA_LOCAC')
oView:CreateHorizontalBox('GRID_SEG',100,,,'PASTA_TIPOS','ABA_SEG')
oView:CreateHorizontalBox('GRID_OUTROS',100,,,'PASTA_TIPOS','ABA_OUTROS')

//-----------Cria box da Aba CC/Aprov------------------------------------//
oView:CreateHorizontalBox('GRID_CC',100,,,'PASTA_APROV', 'ABA_CC' )
oView:CreateHorizontalBox('GRID_APROV',100,,,'PASTA_APROV','ABA_APROV')
oView:CreateHorizontalBox('GRID_PASSAG',100,,,'PASTA_APROV','ABA_PASSAG')

//----------Amarra o box com id da view---------------------------------//
oView:SetOwnerView('VIEW_FL5','ESQ')	  
oView:SetOwnerView('VIEW_FLC','CONF_PASSAG')
oView:SetOwnerView('VIEW_FLC','DADOS_PASSAG')
oView:SetOwnerView('VIEW_FLD','ADIANT')
oView:SetOwnerView('VIEW_FL7','GRID_AEREO')
oView:SetOwnerView('VIEW_FL9','GRID_HOSP')
oView:SetOwnerView('VIEW_FL8','GRID_RODOV')
oView:SetOwnerView('VIEW_FLB','GRID_LOCAC')
oView:SetOwnerView('VIEW_FLU','GRID_PASSAG')
oView:SetOwnerView('VIEW_FLA','GRID_SEG')
oView:SetOwnerView('VIEW_FW7','GRID_OUTROS')
oView:SetOwnerView('VIEW_FLJ','GRID_APROV')
oView:SetOwnerView('VIEW_FLH','GRID_CC')
oView:SetOwnerView('VIEW_FL6','SUP_RESERV')

//-----Coloca titulo----------------------//
oView:EnableTitleView( 'VIEW_FL5' )
oView:EnableTitleView( 'VIEW_FLC' )
oView:EnableTitleView( 'VIEW_FLD' )
oView:EnableTitleView( 'VIEW_FL6' )
oView:EnableTitleView( 'VIEW_FLH' )
oView:EnableTitleView( 'VIEW_FLJ' )
oView:EnableTitleView( 'VIEW_FLU' ) 
//
oView:SetAfterViewActivate({|oModel|F655Gat(oModel)})

oView:AddUserButton(STR0050,'',{|oView|F665legenda()}) //'Legenda'

If __nOper == OPER_CONFER
	oView:AddUserButton(STR0047,STR0052,{|oView|F665RePro(oView)}) //'Reprovar'#'Ok'
	oView:AddUserButton(STR0049,STR0052,{|oView|F665Final(oView)}) //'Finalizar'#'Ok'
	oView:AddUserButton(STR0048,STR0052,{|oView|F665Conf(oView)}) //'Confirmar'#'Ok'
	//Pedidos
	oView:SetNoInsertLine('VIEW_FL6')
	oView:SetNoDeleteLine('VIEW_FL6')
	//Aéreo
	oView:SetNoInsertLine('VIEW_FL7')
	oView:SetNoDeleteLine('VIEW_FL7')
	//Hotel
	oView:SetNoInsertLine('VIEW_FL9')
	oView:SetNoDeleteLine('VIEW_FL9')
	//Carro
	oView:SetNoInsertLine('VIEW_FLB')
	oView:SetNoDeleteLine('VIEW_FLB')
	//Seguro
	oView:SetNoInsertLine('VIEW_FLA')
	oView:SetNoDeleteLine('VIEW_FLA')
	//Rodoviario
	oView:SetNoInsertLine('VIEW_FL8')
	oView:SetNoDeleteLine('VIEW_FL8')
	//Outros
	oView:SetNoInsertLine('VIEW_FW7')
	oView:SetNoDeleteLine('VIEW_FW7')
	//Aprovadores
	oView:SetOnlyView('VIEW_FLJ')
	//Participantes
	oView:SetOnlyView('VIEW_FLU')
	//Viagem
	oView:SetOnlyView('VIEW_FL5')

EndIf

If __nOper == OPER_CUSTO

	oView:SetOnlyView('VIEW_FLJ')
	oView:SetOnlyView('VIEW_FLU')
	oView:SetOnlyView('VIEW_FL5')
	oView:SetOnlyView('VIEW_FLC')
	oView:SetOnlyView('VIEW_FL6')
	oView:SetOnlyView('VIEW_FLD')
	oView:SetOnlyView('VIEW_FL8')
	oView:SetOnlyView('VIEW_FLA')
	oView:SetOnlyView('VIEW_FL7')
	oView:SetOnlyView('VIEW_FL9')
	oView:SetOnlyView('VIEW_FLB')
	oView:SetOnlyView('VIEW_FW7')
	oView:SetNoInsertLine('VIEW_FLH')
	oView:SetNoDeleteLine('VIEW_FLH')
	
EndIf

If __nOper == OPER_APROVA
	
	oView:AddUserButton(STR0051,STR0052,{|oView|FN665AAPR(oView)}) //'Aprovar'#'Ok'
	oView:AddUserButton(STR0047,STR0052,{|oView|FN665AREP(oView)}) //'Reprovar'#'Ok'
	
EndIf

Return oView

/*/{Protheus.doc} MenuDef
Menu Funcional.
@author William Matos Gundim Junior
@since  11/10/2013
@version 11.90
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0018  Action 'FN665PESQ'		OPERATION 1 ACCESS 0	//'Pesquisar'	
ADD OPTION aRotina Title STR0019  Action 'VIEWDEF.FINA665'	OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina Title STR0020  Action 'FINA667A'			OPERATION 4 ACCESS 0	//'Solic. Adiant.'
ADD OPTION aRotina Title STR0021  Action 'FN693FAT'			OPERATION 5 ACCESS 0	//'Gerar Pedido'
ADD OPTION aRotina Title STR0032  Action 'FINA692'		    OPERATION 6 ACCESS 0	//' Gerar Pedido (Lote)'
ADD OPTION aRotina Title STR0026  Action 'FN693DEL'			OPERATION 6 ACCESS 0	//'Estornar Pedido' //"Estornar Pedido"
ADD OPTION aRotina Title STR0053  Action 'FN665CSL' 		OPERATION 7 ACCESS 0	//'Confer. Solicitação'
ADD OPTION aRotina Title STR0054  Action 'FN665ASL'  		OPERATION 8 ACCESS 0	//'Aprov. Solicitação'
ADD OPTION aRotina Title STR0082  Action 'FN665ALP()'  		OPERATION 9 ACCESS 0	//'Aprov. (Lote)'
ADD OPTION aRotina Title STR0088  Action 'FN665CUST()' 		OPERATION 9 ACCESS 0	//'Alterar Ent. Custos' 

Return aRotina

/*/{Protheus.doc} F665INC
Inclusão de pedidos
@author William Matos Gundim Junior
@param aTabelas  array com valores
@param nGrupo código do grupo da viagem
@param lExcluido pedido excluido
@param lAdian Pedido com adiantamento
@since  11/10/2013
@version 11.90
/*/
Function F665INC(aTabelas,nGrupo,lExcluido,lAdian,nIdPedido,oPedidos)
Local nX			:= 1
Local nY			:= 1
Local oAux			:= Nil
Local oStruct		:= Nil
Local aAux			:= {}
Local aRet			:= {}
Local nPos			:= 0
Local lRet			:= .T.
Local nCount		:= 0
Local lNovoReg		:= .F.
Local cLog			:= ''
Local cPedido		:= ""
Local cHistorico	:= ""
Local cLicenc		:= ""
Local cViagem		:= ""
Local lVincPas 		:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),1,1) == "1" //Verifica se utiliza Vinculo Passageiro .
Local lVinccli 		:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),2,1) == "1" //Verifica se utiliza Vinculo Data .
Local lVincdat 		:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),3,1) == "1" //Verifica se utiliza Vinculo Cliente .
Local lVincCC  		:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),4,1) == "1" //Verifica se utiliza Vinculo CCusto .
Local nOper			:= 0
Local oModel		:= Nil

Default aTabelas	:= {}
Default lExcluido	:= .F.
Default lAdian		:= .F.
 
//------------------------------ //
//	Array[X][ ] - Nome do Model  //
//	Array[ ][X][ ] - Nome do Campo//
// Array[ ][ ][X] - Valor do Campo//	
//-----------------------------	--//

If lVincPas .or. lVincDat .or. lVincCli .or. lVincCC 
	aRet := F665VINC(opedidos)
	If aRet[1] .and. len(aRet) = 2  // Se for mais que uma "viagem" é viagem nova 
		nOper := 4
		DbSelectArea('FL5')
		DbSetOrder(1)		
		DbSeek(xFilial('FL5')+ aRet[2])
	Else
		//-----Posiciona na viagem e define a operação.
		DbSelectArea('FL5')
		aRet := F665Busca(nGrupo) // Retorna um array com duas posições ( 1 - Encontrou | 2 - Se encontrou retorna código da viagem)
		If aRet[1]
			nOper := 4
			DbSetOrder(1)
			DbSeek(xFilial('FL5')+ PadL(aRet[2],TamSX3('FL5_VIAGEM')[1]))
		Else
			nOper := 3
			lNovoReg := .T.
		EndIf
	EndIf
Else
	//-----Posiciona na viagem e define a operação.
	DbSelectArea('FL5')
	aRet := F665Busca(nGrupo) // Retorna um array com duas posições ( 1 - Encontrou | 2 - Se encontrou retorna código da viagem)
	If aRet[1]
    	nOper := 4
		DbSetOrder(1)
		DbSeek(xFilial('FL5')+ PadL(aRet[2],TamSX3('FL5_VIAGEM')[1]))
    Else
    	nOper := 3
    	lNovoReg := .T.
    EndIf
EndIf  

If ExistBlock("F665INC")
	lRet := ExecBlock("F665INC",.F.,.F.,{ nOper })
	If lRet
		lNovoReg := .T.
		nOper := 3
	EndIf
EndIf


oModel := FWLoadModel('FINA665')
oModel:SetOperation(nOper)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
oModel:Activate()
If !lExcluido // Pedidos cancelados serão processados em outra função.
	For nCount := 1 To Len(aTabelas)

	    //-------------Cadastro de Viagens.-----------------
		If aTabelas[nCount,1] == 'FL5MASTER'
			oAux := oModel:GetModel( aTabelas[nCount][1] )
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()			
			If lNovoReg
				For nY := 2 To Len(aTabelas[nCount])
					If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aTabelas[nCount,nY,1]) } ) ) > 0
						oModel:SetValue(aTabelas[nCount,1],aTabelas[nCount,nY,1],If(aTabelas[nCount,nY,2] <> Nil,aTabelas[nCount,nY,2],''))
					EndIf
				Next nY
			Else
				
				//Atualiza campos se a data de inicio do pedido for inferior.
				If (oModel:GetValue('FL5MASTER','FL5_DTINI') > aTabelas[nCount,_DATAINI,2])
					oModel:SetValue('FL5MASTER','FL5_DTINI',aTabelas[nCount,_DATAINI,2]) // Data Inicio.
					oModel:SetValue('FL5MASTER','FL5_CODORI',aTabelas[nCount,_CODORI,2]) // Cód.Origem.
					oModel:SetValue('FL5MASTER','FL5_DESORI',Left(Alltrim(aTabelas[nCount,_DESORI,2]),TamSX3("FL5_DESORI")[1])) // Des.Origem.
				EndIf
				
				//Atualiza campos se a data destino for maior que a atual.
				If (oModel:GetValue('FL5MASTER','FL5_DTFIM') < aTabelas[nCount,_DATAFIM,2])
					oModel:SetValue('FL5MASTER','FL5_DTFIM',aTabelas[nCount,_DATAFIM,2]) // Data Final.
					oModel:SetValue('FL5MASTER','FL5_CODDES',aTabelas[nCount,_CODDES,2]) // Cód.Origem.
					oModel:SetValue('FL5MASTER','FL5_DESDES',aTabelas[nCount,_DESDES,2]) // Des.Origem.
				EndIf
					
			EndIf	
		ElseIf aTabelas[nCount,1] <> 'FL5MASTER'
			oAux := oModel:GetModel( aTabelas[nCount][1] )
			oAux:GoLine(oAux:Length())
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
		//Valida a existencia do passageiro.
			lRet := If(aTabelas[nCount,1] == 'FLCDETAIL',F665Reg(oModel:GetValue('FL5MASTER','FL5_VIAGEM'),aTabelas[nCount]),.T.)     
			//Acrescenta uma linha nova no model caso seja uma alteração.			
			If !oAux:IsEmpty() .and. lRet
				oAux:AddLine()
			EndIf
		    if lRet
				For nY := 2 To Len(aTabelas[nCount])
					If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aTabelas[nCount,nY,1]) } ) ) > 0
						oModel:SetValue(aTabelas[nCount,1],aTabelas[nCount,nY,1],If(aTabelas[nCount,nY,2] <> Nil,aTabelas[nCount,nY,2],''))
					EndIf
				next
			endif	
		EndIf
	next
			
	If lNovoReg
		oModel:SetValue("FL5MASTER","FL5_VIAGEM", FXRESNUM( oModel:GetValue("FL5MASTER","FL5_NACION") ) ) //Numeração diferenciada.
	EndIf

	//--Ponto de entrada para gravação complementar da viagem----
	If ExistBlock("FN665COMPL")
		ExecBlock("FN665COMPL",.F.,.F.,{oPedidos})
	EndIf
	
	//Validação do modelo de dados.
	If !oModel:VldData()
		lRet := .F.	
		For nX := 1 To Len(oModel:GetErrorMessage())
			cLog += Iif(ValType(oModel:GetErrorMessage()[nX])=="U","",oModel:GetErrorMessage()[nX])		
		Next nX
	Else	
	 	If ExistBlock("FN665VLD")
			aRet := ExecBlock("FN665VLD",.F.,.F.,{oPedidos})
			
			If Len(aRet) == 2 .AND.	!aRet[1] .AND. !Empty(aRet[2])
				lRet := .F.
				cLog := STR0087 + aRet[2]
			Else
				lRet := .T.
			EndIf
		EndIf
	EndIf
	
	If lRet 	
		
		oModel:CommitData()
		
		//-------------------------------------------
		// Atualiza o historico do pedido no Reserve
		//-------------------------------------------
		cLicenc		:= oModel:GetValue('FL6DETAIL','FL6_LICENC') //Codigo do licenciado Reserve
		cPedido		:= oModel:GetValue('FL6DETAIL','FL6_IDRESE') //Codigo do Pedido de Viagem no Reserve
		cViagem		:= oModel:GetValue('FL5MASTER','FL5_VIAGEM') //Codigo da viagem no Protheus
		cHistorico	:= I18N(STR0022,{cViagem,DToC(dDataBase),Time()}) //"Pedido incluído no Protheus sob a Viagem #1[Codigo da Viagem]# em #2[Data]# às #3[Hora]#."
		FN661Hist(cLicenc,cPedido,cHistorico)

		//Gera Prestação de Contas.
		cLog += F677GerPC(oModel)
		
		If FinXValPC(oModel:GetValue('FLCDETAIL','FLC_PARTIC'),.F.,cLicenc,cPedido,cViagem) //Valida se participante tem prestação de conta atrasada.
			//Gera adiantamento.
			If Upper(AllTrim(oModel:GetValue('FL6DETAIL','FL6_EXTRA1'))) == 'SIM'
				cLog += F667GeraAdian(oModel)
			EndIf
		EndIf	
	EndIf
Else
	cLog += FNXRESCANC(oModel,nIdPedido)
EndIf
oModel:DeActivate()	

Return cLog

/*/{Protheus.doc} F665Busca
Busca por pedido na FL6 - Pedidos.
@author William Matos Gundim Junior
@since  24/10/2013
@version 11.90
/*/
Function F665Busca(nGrupo)
Local cQuery := ''
Local aRet := {}
Local aArea     := GetArea()
	dbSelectArea("FL6")
	dbSelectArea("FL5")
	
	cQuery += 'SELECT FL5_VIAGEM,FL5_IDRESE FROM ' + RetSqlName("FL5") + " FL5 "
	cQuery += "WHERE FL5_FILIAL = '" + xFilial("FL5") + "'"
	cQuery += "AND FL5_IDRESE = '" + cValToChar(nGrupo) + "'" 
	cQuery += "AND D_E_L_E_T_ = ' ' " 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cFiltro",.T.,.T.)
    dbSelectArea("cFiltro")
  	dbGoTop()
	
	If cFiltro->(Eof()) //---Não encontrou nenhum pedido na viagem então busca nos pedidos para encontrar a viagem.  
    	cFiltro->(DbCloseArea())
    	cQuery := ''
    	cQuery += 'SELECT FL6_VIAGEM FROM ' + RetSqlName("FL6") + " FL6"
    	cQuery += "WHERE FL6_FILIAL = '" + xFilial("FL6") + "'"
		cQuery += "AND FL6_IDRESE = '" + cValToChar(nGrupo) + "'" 
		cQuery += "AND D_E_L_E_T_ = ' ' " 
		cQuery := ChangeQuery(cQuery)
    	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cFiltro",.T.,.T.)
    	dbSelectArea("cFiltro")
  		dbGoTop()
  		If cFiltro->(Eof()) //--Cria nova viagem.
  			aAdd(aRet,.F.)
  		Else
  			aAdd(aRet,.T.)
    		aAdd(aRet,cFiltro->FL6_VIAGEM)
    	EndIf		
    Else
    	aAdd(aRet,.T.)
    	aAdd(aRet,cFiltro->FL5_VIAGEM)
    End		
	
	cFiltro->(DbCloseArea())
	RestArea(aArea)
	
Return aRet

/*/{Protheus.doc} F665Reg
Busca pelo registro para não duplicar.
@author William Matos Gundim Junior
@since  09/11/2013
@version 11.90
/*/
Function F665Reg(cViagem,aTabela)
Local lRet := .T.

DbSelectArea('FLC')
DbSetOrder(1)
If DbSeek(xFilial('FLC') + cViagem + aTabela[2,2])
       lRet := .F.
EndIf        

Return lRet

/*/{Protheus.doc} LMLegenda
Monta a legenda dos registros apresentados no Grid.
@author William Matos Gundim Junior.
@since 05/11/2013
@version 11.9
/*/
Function F665Legenda()
Local oLegenda:=FwLegend():New()

oLegenda:add('FL6->FL6_STATUS==3','RED' ,STR0077) //'Cancelado'
oLegenda:add('Empty(FL6->FL6_STATUS) .OR. FL6->FL6_STATUS $ "0|1|2" ','GREEN',STR0055)		
oLegenda:View()
oLegenda:=nil       

Return .T.

/*/{Protheus.doc} F686Leg
Monta a legenda dos registros apresentados no Grid.
@author William Matos Gundim Junior.
@since 22/08/2014
@version 12
/*/
Function F665Leg(cAlias)
Local cRet:=''

If cAlias == 'FL6'
	If (cAlias)->FL6_STATUS == '3'	 //Cancelado.
		cRet		:= 'br_vermelho'
	Else
	  cRet	:= 'br_verde'
	EndIf
Else
	If (cAlias)->FLD_STATUS == '9'	 //Cancelado.
		cRet		:= 'br_vermelho'
	Else
	  cRet	:= 'br_verde'
	EndIf
EndIf	

Return cRet

/*/{Protheus.doc} FN665PESQ
Pesquisa pelos pedidos ou viagens pelo IDReserve.
@author William Matos Gundim Junior.
@since 15/12/14
@version 12
/*/
Function FN665PESQ()
Local aSize 	:= {}
Local oPanel	:= Nil
Local oGet		:= Nil
Local cID		:= "0000000"

aSize := FwGetDialogSize(oMainWnd)          
oPanel := TDialog():New(aSize[1],aSize[2],200,975,STR0027,,,,,,,,,.T.,,,,300,100)	//
//Identificador Reserve:
TSay():New(15,04,{||STR0028},oPanel,,,,,,.T.)
//
oGet 	  := TGet():New(15,58,{|u| if( Pcount( )>0, cID := u, cID) },oPanel,40,8,"9999999999",/*bValid*/,/*Cor*/,/*Cor*/,/*oFont*/,.F.,/*oObj*/,.T.,/*C*/,.F.,/*bWhen*/,.F.,.F.,/*bChange*/,.F.,.F.,,)
//Buscar.
oButton  := TButton():New(15,100,STR0029,oPanel,{||If(FN665VIEW(cID),oPanel:End(),Nil)}, 37,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 

oPanel:Activate(,,,.T.,,,)

Return 

/*/{Protheus.doc} FN665VIEW
Exibição da tela de viagens conforme a busca rapida.
@author William Matos Gundim Junior.
@since 15/12/14
@version 12
/*/
Function FN665VIEW(cID)
Local 	lRet	:= .T.
Local	cFilAux := cFilAnt
Local	lSeek	:= .F.
Default cID 	:= ""

dbSelectArea('FL5')
dbSelectArea('FL6')
FL6->(dbSetOrder(3)) //FL6_FILIAL + FL6_IDRESE
If FL6->(dbSeek(xFilial("FL6") +  PadR(cID,TamSx3("FL6_IDRESE")[1])))
	FL5->(dbSeek(xFilial("FL5") + FL6->FL6_VIAGEM))
	lSeek := .T.
Else	//Busca registro nas demais filiais
	dbSelectArea('SM0')
	SM0->(dbGoTop())
	SM0->(dbSetOrder(1))
	While !SM0->(Eof())
		If FL6->(dbSeek(xFilial("FL6",AllTrim(SM0->M0_CODFIL)) +  PadR(cID,TamSx3("FL6_IDRESE")[1])))
			FL5->(dbSeek(xFilial("FL5",AllTrim(SM0->M0_CODFIL)) + FL6->FL6_VIAGEM))
			cFilAnt := SM0->M0_CODFIL	//Posiciona na filial correta do reg p/ fazer o Relation no LoadModel
			lSeek   := .T.
			Exit
		EndIf
		SM0->(dbSkip())
	EndDo
EndIf
If !lSeek
	Help( ,,"BUSCA",,STR0030, 1, 0 )
	lRet := .F.
Else 
	FWExecView( STR0019 , 'FINA665', MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. })
EndIf
cFilAnt := cFilAux

Return lRet

/*/{Protheus.doc} FN665CSL()
Conferência da solicitação
@author Antonio Florêncio Domingos Filho
@since 22/06/2015
@version 12.1.6
/*/
Function FN665CSL(cAlias,nReg,nOpc,lAutomato)
Local lRet			:= .T.
Local aArea         := GetArea()
Local cTitulo       := ""
Local cPrograma     := ""
Local aEnableButtons:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local bOk			:= {||}
Local aUsers		:= {}

Default lAutomato	:= .F.

//Valida acesso do usuário
aUsers := FN683PARTI()
//
If lRet .And. FL5->FL5_STATUS <> '6' //Solicitada
	Help(" ",1,"F665VLDCF",,STR0080,1,0) // "Não é possivel Conferir solicitação com esse status."
	lRet := .F.
EndIf

If !Alltrim(aUsers[1]) == "ALL"
	Help(" ",1,"F665USER",,STR0034,1,0) // "Apenas usuários do departamento de viagens deverão ter acesso a essa rotina."
	lRet := .f.
EndIf

//Executa a rotina da Aprovação da Viagem Solicitada
If lRet
	FL5->(MsRLock())

	__nOper      	:= OPER_CONFER
	cTitulo      	:= STR0035 //"Conferência da Viagem Solicitada"
	cPrograma    	:= 'FINA665'
	__lConfReprova 	:= .F.
	bOk          	:= {|| lRet := MsgYesNo(STR0078) } // "Confirma a Conferência da viagem solicitada? "

	If !lAutomato
		FWExecView( cTitulo , cPrograma, MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	Else
		F665Final(Nil,lAutomato)
	EndIf
	FL5->(MsRUnlock())
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F665RePro
Reprovação da Solicitação

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function F665RePro(oView)
	Local lRet      As Logical
	Local nX        As Numeric
	Local nRecnoFLD As Numeric
	Local aArea     As Array
	Local oModel    As Object
	Local oModelFLC As Object
	Local oModelFLD As Object	
	Local cStatus   As Character
	Local cTo       As Character
	Local cAssunto  As Character
	Local cEntidade As Character
	Local cRegistro As Character
	Local cMensagem As Character
	Local cProcesso As Character
	Local cLog      As Character
	Local cObs      As Character	
	Local cViagem   As Character
	Local cChaveFLD As Character	
	
	//Inicializa variáveis.
	lRet      := .T.
	nX        := 0
	nRecnoFLD := 0	
	aArea     := GetArea()
	oModel    := FWModelActive()
	oModelFLC := Nil
	oModelFLD := Nil	
	cStatus   := STR0070 //Reprovada
	cTo       := ""
	cAssunto  := STR0071 //Viagem Solicitada Reprovada-pela conferência
	cEntidade := "FL5"
	cRegistro := ""
	cMensagem := ""
	cProcesso := ""
	cLog      := ""
	cObs      := ""	
	cViagem   := oModel:GetValue("FL5MASTER","FL5_VIAGEM")
	cChaveFLD := ""
	
	oModel:Activate()
	dbSelectArea("FL5")
	cRegistro := STR0058 + " " + oModel:GetValue('FL5MASTER','FL5_VIAGEM') //viagem
	cProcesso := STR0069 + " " + oModel:GetValue('FL5MASTER','FL5_IDSOL')  //Solicitação
	
	//Abre a tela do Motivo da Reprovação da Viagem Solicitada 
	If FN665DMOT(@cObs)
		//Atualiza o Status da Viagem
		oModel:LoadValue("FL5MASTER", "FL5_OBS", cObs)   //Conferida - 1=Aguardando Conferencia;2=Conferida;3=Finalizada;4=Cancelada;5-Aguardando Aprovação
		oModel:LoadValue("FL5MASTER", "FL5_STATUS", "4") //Cancelada - 1=Aguardando Conferencia;2=Conferida;3=Finalizada;4=Cancelada;5-Aguardando Aprovação
		
		If oModel:VldData()
			oModel:CommitData()
			
			//Envia email para o Solicitante			
			cTo := Posicione("RD0",1,xFilial('RD0')+FW3->FW3_USER,"RD0_EMAIL")
			cTo := AllTrim(cTo)
			
			oModelFLC:= oModel:GetModel("FLCDETAIL")
			oModelFLD:= oModel:GetModel("FLDDETAIL")
			
			For nX := 1 To oModelFLC:Length()				
				oModelFLC:GoLine(nX)				
				
				If !oModelFLD:IsEmpty()
					DbSelectArea("FLD")
					FLD->(DbSetOrder(1)) //FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC
					cChaveFLD := (xFilial("FLD")+cViagem+oModelFLD:GetValue("FLD_PARTIC"))
					
					If FLD->(DbSeek(cChaveFLD))						
						If nRecnoFLD == 0
							nRecnoFLD := FLD->(Recno())
						EndIf
						
						While !FLD->(Eof()) .And. FLD->(FLD_FILIAL+FLD->FLD_VIAGEM+FLD_PARTIC) == cChaveFLD 
							FI667APGES(FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT, .T.)
							F667CanFlu(FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT)
							FLD->(DbSkip())
						EndDo
					EndIf
				EndIf
			Next nX
			
			If nRecnoFLD > 0
				FLD->(DbGoto(nRecnoFLD))
			EndIf
			
			If !Empty(cTO)			
				cMensagem += FN665DtVg(oView,cStatus) //Detalhamento da Viagem					
				FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto)		
			Else
				Help(" ",1,"F665NOEMAIL",,STR0036,1,0) //Solicitante não tem email cadastrado!	
			EndIf

			//Atualiza o Status da Solicitação
			RecLock("FW3",.F.)
			FW3->FW3_STATUS := "2" //Cancelada - Status 0=Em Aberto;1=Conferencia;2=Cancelada;3=Aguardando Aprovacao;4=Finalizada
			FW3->(MsUnlock())
			lRet := .F.
		Else
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - ' + cValToChar(oModel:GetErrorMessage()[6]);
					+ ' - ' + cValToChar(oModel:GetErrorMessage()[8])
			lRet := .T.
		EndIf
	Endif
	
	RestArea(aArea)
	
	If !lRet
		oView:ShowUpdateMsg(.F.)		//nao exibe a mensagem de atualizacao
		oView:ButtonCancelAction()
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F665Final()
Finalização da Conferência da Viagem Solicitada

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function F665Final(oView,lAutomato)
Local aArea 		:= GetArea()
Local oModel    	:= FWLoadModel('FINA665')
Local cTo       	:= ""
Local cAssunto		:= STR0038
Local cMensagem		:= ""
Local cRegistro		:= ""
Local cEntidade 	:= "FL5"
Local cProcesso 	:= ""
Local lOk       	:= .F.
Local cStatus   	:= STR0003 //"Finalizada" 
Local aAprv 		:= FResAprov("3")//"3" = Solicitação de Viagem
Local lEmail		:= SuperGetMV("MV_RESAVIS",/**/,"2") == "1"
Local cLog			:= ""

Default lAutomato := .F.	

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Após a solicitação da viagem (.T. or .F.)
	aAprv[2] - Após a conferência da solicitação (.T. or .F.)
*/

oModel:Activate()
dbSelectArea("FL5")
cRegistro := STR0058+" "+oModel:GetValue('FL5MASTER','FL5_VIAGEM') //viagem
cProcesso := STR0069+" "+oModel:GetValue('FL5MASTER','FL5_IDSOL')  //Solicitação

//-----------------------------------------
//Processo de Atualizacao da Solicitacao
//-----------------------------------------
dbSelectArea("FW3")
dbSetOrder(1)
dbSeek(xFilial("FW3")+FL5->FL5_IDSOL)

If lAutomato .Or. MsgYesNo(STR0084) //"Confirma a finalização da conferencia?"
	 If Found()
	
		//-----------------------------------------
		//Atualiza Status da Viagem para 5-Aguardando Aprovacao
		//-----------------------------------------
		oModel:DeActivate()
		oModel:SetOperation(4)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
		oModel:Activate()
		If aAprv[2]
			oModel:SetValue('FL5MASTER','FL5_STATUS','5') //Aguardando Aprovação - 1=Aguardando Conferencia;2=Conferida;3=Finalizada;4=Cancelada;5-Aguardando Aprovação
		Else	
			oModel:SetValue('FL5MASTER','FL5_STATUS','1') // Aguardando Conferencia
		Endif
		lOk := oModel:VldData()
		If !lOk 
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - ' + cValToChar(oModel:GetErrorMessage()[6]);
				 + ' - ' + cValToChar(oModel:GetErrorMessage()[8])
		Else	
			oModel:CommitData()
		EndIf
	
	
		//-----------------------------------------
		//Atualiza Status da Solicitação - 4 Finalizada
		//-----------------------------------------
		RECLOCK("FW3",.F.)
		FW3->FW3_STATUS := "4" //Finalizada //Status 0=Em Aberto;1=Conferencia;2=Cancelada;3=Aguardando Aprovacao;4=Finalizada
		MSUNLOCK()

		If oView != Nil
			oView:lModify := .T.
			oModel:lModify := .T.
			oView:ShowUpdateMsg(.F.)
			oView:ButtonOkAction(.T.)
		EndIf
	
		If aAprv[2] .and. lEmail
			//-----------------------------------------
			//Envia email para o Aprovador
			//-----------------------------------------
			dbSelectArea("FLJ")
			dbSetOrder(1)
			dbSeek(xFilial("FLJ")+FL5->FL5_VIAGEM,.T.) 
			
			If Found() .And. FLJ->FLJ_FILIAL==xFilial("FLJ") .And. FLJ->FLJ_VIAGEM == FL5->FL5_VIAGEM
			
				dbSelectArea("RD0")
				dbSetOrder(1)
				dbSeek(xFilial("RD0")+FLJ->FLJ_PARTIC)
				
				cTo := alltrim(RD0->RD0_EMAIL)
				
				If !Empty(cTO)
					
					cMensagem += FN665DtVg(oView,cStatus) //Detalhamento da Viagem			
					
					FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto)
				
				Else
					Help(" ",1,"F665NOEMAIL",,STR0036,1,0) //Aprovador não tem email cadastrado	
				EndIf
		
			EndIf
		Elseif !aAprv[2]
			cLog += F677GerPC(oModel)
		Endif
	Else
		Help(" ",1,"F665NOSOLIC",,STR0037,1,0) //Solicitante não cadastrada!"
	EndIf
EndIf

RestArea(aArea)

Return .F.	

//-------------------------------------------------------------------
/*/{Protheus.doc} F665Conf()
Confirmação da Solicitação

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function F665Conf(oView)

If oView != Nil .and. MsgYesNo(STR0083)
	oView:ShowUpdateMsg(.F.)
	oView:ButtonOKAction(.T.)
EndIf

Return .F.	

/*/{Protheus.doc} FN665ASL()
Aprovação da solicitação
@author Antonio Florêncio Domingos Filho
@since 23/06/2015
@version 12.1.6
/*/
Function FN665ASL(cAlias,nReg,nOpc,lAutomato,cOpcAut)
Local aArea  		:= GetArea()
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local lRet          := .T.
Local aEnableButtons:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local bOk			:= {||}

Default lAutomato	:=  .F.
Default cOpcAut	:= 0

If UsrApprover()	//Se usuario pode aprovar a viagem

	If ExistBlock("F665ASL")
		lRet := ExecBlock("F665ASL",.F.,.F.,{lRet})
	Else			
		If lRet .And. FL5->FL5_STATUS <> '5' //Aguardando Aprovação
			Help(" ",1,"F665VLDCF",,STR0066,1,0) // "Não é possivel Aprovar solicitação com esse status."
			lRet := .F.
		EndIf
	Endif

	If lRet
		FL5->(MsRLock())
	
		__nOper      	:= OPER_APROVA
		cTitulo      	:= ""
		cPrograma    	:= 'FINA665'
		nOperation   	:= MODEL_OPERATION_UPDATE
		__lConfAprova  	:= .F.
		bOk          	:= {|| lRet := MsgYesNo(STR0079) } // "Confirma a aprovação da viagem solicitada? "

		If !lAutomato
			nRet := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
		Else
			If cOpcAut == "A"
				FN665AAPR(Nil)
			Else
				FN665AREP(Nil)
			EndIf
		EndIf
		__nOper      	:= 0
	
		FL5->(MsRUnlock())
	EndIf
Else
	Help(" ",1,"F665NOEMAIL",,STR0074,1,0) //"Aprovador não autorizado para esta viagem"	
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} FN665DMOT
Abre Tela para digitar motivo da Reprovação
@author Antonio Florêncio Domingos Filho
@since 23/06/2015
@version 12.1.6
/*/
Function FN665DMOT(cObservacao)
Local aSize 	:= {}
Local oPanel	:= Nil
Local oGet		:= Nil
Local cObs		:= Space(TAMSX3("FL5_OBS")[1])
Local lRet		:= .F.

Default cObservacao := ""

aSize := FwGetDialogSize(oMainWnd)          
oPanel := TDialog():New(003,010,900,975,STR0067,,,,,,,,,.T.,,,,600,300) //"Motivo da Reprovação"
	//"Motivo da Reprovação"
	TSay():New(15,03,{||STR0068+": "},oPanel,,,,,,.T.) //"Motivo"
	//
	@ 015,035 GET oGet VAR cObs MEMO SIZE 248,93 PIXEL OF oPanel 
	//Confirma
	oButton  := TButton():New(120,243,STR0039,oPanel,{||lRet := .T.,oPanel:End()}, 37,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirma"
oPanel:Activate(,,,.T.,,,)

If lRet
	cObservacao := cObs
Else
	cOBservacao := ""
Endif

Return(lRet)

/*/{Protheus.doc} F666CfeOK
Salva as alterações da Model
@author Antonio Florêncio Domingos Filho
@since 23/06/2015
@version 12.1.6
/*/
Function F666CfeOK(oView)
Local lRet     := .T.
Local oModel   := FWLoadModel('FINA665')         //Carrega o model

If lRet

	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModel:VldData() )

		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		lRet := oModel:CommitData()

	EndIf

EndIf

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} F665DUser(cCodUser)

Retorna nome e mail de usuario

@param oModel Objeto com os dados necessarios.

@author Antonio Florêncio Domingos Filho
@since  17/06/2015
@version 12.1.6
/*/ 
//-------------------------------------------------------------------
Function F665DUser(cCodUser)
Local cRet 	:= ""
Local aArea	:= GetArea()
 
dbSelectArea("RD0")
dbSetOrder(1)//RD0_FILIAL + RD0_CODIGO 
If RD0->(dbSeek(xFilial("RD0") + cCodUser)) 
	cRet := RD0->RD0_EMAIL 
EndIf 

RestArea( aArea )
 
Return cRet


/*/{Protheus.doc} FN665AAPR(oView)
Aprovação da Viagem Solicitada

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN665AAPR(oView)
Local aArea 		:= GetArea()
Local oModel    	:= FWModelActive()
Local oModelFLC		:= Nil
Local oModelFLD		:= Nil
Local cTo       	:= ""
Local cAssunto		:= STR0040 //"Aprovação da Viagem Solicitada"
Local cMensagem		:= ""
Local cRegistro		:= ""
Local cEntidade 	:= "FL5"
Local cProcesso 	:= ""
Local cStatus   	:= STR0002 //"Aprovada" 
Local cLog			:= ""
Local cViagem		:= oModel:GetValue('FL5MASTER','FL5_VIAGEM')
Local nX			:= 0
Local aAprv			:= FResAprov("1") //"1" = Adiantamentos
Local lAprov		:= .F.

/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/

dbSelectArea("FL5")
cRegistro := STR0058+" "+oModel:GetValue('FL5MASTER','FL5_VIAGEM') //viagem
cProcesso := STR0069+" "+oModel:GetValue('FL5MASTER','FL5_IDSOL')  //Solicitação

//-----------------------------------------
//Processo de Atualização da Solicitação
//-----------------------------------------
dbSelectArea("FW3")
dbSetOrder(1)
If FW3->(dbSeek(xFilial("FW3")+oModel:GetValue('FL5MASTER','FL5_IDSOL')))
	
	//Gera Prestação de Contas.
	cLog += F677GerPC(oModel)
	//Aprova os Adiantamentos.
	If !aAPrv[1] .AND. !aAPrv[2] // Aprovação Automatica.
		lAprov := .T.
	ElseIf !aAPrv[2] // Aprovação Automatica.
		lAprov := MsgYesNo(STR0092, STR0093)//"Deseja Aprovar todos os Adiantamentos vinculados nesta Solicitação de Viagem?" "Atenção!"
	EndIf
	
	If lAprov
	
		oModelFLC:= oModel:GetModel("FLCDETAIL")
		oModelFLD:= oModel:GetModel("FLDDETAIL")
		DbSelectArea("FLD")
		FLD->( DbSetOrder(1) ) // FLD_FILIAL + FLD_VIAGEM + FLD_PARTIC
		For nX := 1 To oModelFLC:Length()
			
			oModelFLC:GoLine(nX)
			
			If !oModelFLD:IsEmpty()
				If FLD->( DbSeek( xFilial('FLD') + cViagem + oModelFLD:GetValue("FLD_PARTIC") ) )
					
					oModelFLD:LoadValue("FLD_VALAPR", oModelFLD:GetValue("FLD_VALOR") )
					oModelFLD:LoadValue("FLD_DTPREV", F666DtPrev() )
				EndIf
			EndIf
		Next nX
	EndIf
	
	/*/-----------------------------
		Atualiza o Status da Viagem
	/*/
	If FindFunction("FW4IsType6") .and. FW4IsType6()		// Se a viagem so tem servico do tipo Outros
		oModel:SetValue("FL5MASTER",'FL5_STATUS','2') // Conferida
	Else
		oModel:SetValue("FL5MASTER",'FL5_STATUS','1') // Aguardando Conferencia
	EndIf

	If oView != Nil
		oView:Refresh()
	EndIf
	If oModel:VldData()
		oModel:CommitData()
		
		If lAprov
			oModelFLC:= oModel:GetModel("FLCDETAIL")
			oModelFLD:= oModel:GetModel("FLDDETAIL")
			
			For nX := 1 To oModelFLC:Length()
				
				oModelFLC:GoLine(nX)
				
				If !oModelFLD:IsEmpty()
					DbSelectArea("FLD")
					FLD->( DbSetOrder(1) ) // FLD_FILIAL + FLD_VIAGEM + FLD_PARTIC
					If FLD->( DbSeek( xFilial('FLD') + cViagem + oModelFLD:GetValue("FLD_PARTIC") ) )
						
						FI667APGES( FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT, .F. )
						F667CanFlu( FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT )
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf
	//-----------------------------------------
	//Atualiza o Status da Solicitação Para Finalizada
	//-----------------------------------------
	RECLOCK("FW3",.F.)
		FW3->FW3_STATUS := "4" //Finalizada //Status 0=Em Aberto;1=Conferencia;2=Cancelada;3=Aguardando Aprovacao;4=Finalizada
	FW3->(MSUNLOCK())

	//-----------------------------------------
	//Envia email para o Aprovador
	//-----------------------------------------
	dbSelectArea("FLJ")
	dbSetOrder(1)
	dbSeek(xFilial("FLJ")+oModel:GetValue('FL5MASTER','FL5_VIAGEM'),.T.) 
	
	If Found() .And. FLJ->FLJ_FILIAL==xFilial("FLJ") .And. FLJ->FLJ_VIAGEM == FL5->FL5_VIAGEM
	
		dbSelectArea("RD0")
		dbSetOrder(1)
		dbSeek(xFilial("RD0")+FLJ->FLJ_PARTIC)
		
		cTo := alltrim(RD0->RD0_EMAIL)
		
		If !Empty(cTO)
			
			cMensagem += FN665DtVg(oView,cStatus) //Detalhamento da Viagem
			
			FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto)
		
		Else
			Help(" ",1,"F665NOEMAIL",,STR0041,1,0) //Aprovador não tem email cadastrado	
		EndIf
	EndIf
Else
	Help(" ",1,"F665NOSOLIC",,STR0037,1,0) //Solicitante não cadastrada!"
EndIf

If oView != Nil
	oView:ButtonOkAction(.T.)
EndIf

RestArea(aArea)

Return .F.	

//-------------------------------------------------------------------
/*/{Protheus.doc} FN665AREP()
Reprovação da Viagem

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN665AREP(oView)
Local aArea			:= GetArea()
Local oModel		:= FWModelActive()
Local oModelFLC		:= Nil
Local oModelFLD		:= Nil
Local cTo			:= ""
Local cAssunto		:= STR0042 //"Viagem Solicitada Reprovada"
Local cMensagem		:= ""
Local cRegistro		:= ""
Local cEntidade		:= "FL5"
Local cProcesso		:= ""
Local cStatus		:= "Reprovada"
Local nX			:= 0
Local cViagem		:= oModel:GetValue('FL5MASTER','FL5_VIAGEM')
Local cChaveFLD     := ""
Local nRecnoFLD     := 0

oModel:Activate()
dbSelectArea("FL5")
cRegistro := STR0058+" "+oModel:GetValue('FL5MASTER','FL5_VIAGEM') //viagem
cProcesso := STR0069+" "+oModel:GetValue('FL5MASTER','FL5_IDSOL')  //Solicitação

//-----------------------------------------
//Processo de Atualização da Solicitação
//-----------------------------------------
dbSelectArea("FW3")
dbSetOrder(1)
dbSeek(xFilial("FW3")+oModel:GetValue('FL5MASTER','FL5_IDSOL'))

If Found()
	//-----------------------------------------
	//Atualiza o Status da solicitação para Cancelada
	//-----------------------------------------
	RECLOCK("FW3",.F.)
	FW3->FW3_STATUS := "2" //Cancelada - Status 0=Em Aberto;1=Conferencia;2=Cancelada;3=Aguardando Aprovacao;4=Finalizada
	FW3->(MSUNLOCK())
	
	//-----------------------------------------
	//Atualiza o Status da Viagem para Cancelada
	//-----------------------------------------
	oModel:SetValue("FL5MASTER",'FL5_STATUS','4') //Cancelada - 1=Aguardando Conferencia;2=Conferida;3=Finalizada;4=Cancelada;5-Aguardando Aprovação
	
	If oView != Nil
		oView:Refresh()
	EndIf
	
	If oModel:VldData()
		oModel:CommitData()		
		oModelFLC:= oModel:GetModel("FLCDETAIL")
		oModelFLD:= oModel:GetModel("FLDDETAIL")		
		
		For nX := 1 To oModelFLC:Length()
			oModelFLC:GoLine(nX)
			
			If !oModelFLD:IsEmpty()
				DbSelectArea("FLD")
				FLD->(DbSetOrder(1)) //FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC
				cChaveFLD := (xFilial("FLD")+cViagem+oModelFLD:GetValue("FLD_PARTIC"))
				
				If FLD->(DbSeek(cChaveFLD))
					If nRecnoFLD == 0
						nRecnoFLD := FLD->(Recno())
					EndIf					
					
					While !FLD->(Eof()) .And. FLD->(FLD_FILIAL+FLD->FLD_VIAGEM+FLD_PARTIC) == cChaveFLD						
						FI667APGES(FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT, .T.)
						F667CanFlu(FLD->FLD_VIAGEM, FLD->FLD_PARTIC, FLD->FLD_ADIANT)
						FLD->(DbSkip())
					EndDo
				EndIf
			EndIf
		Next nX		
	EndIf
	
	If nRecnoFLD > 0
		FLD->(DbGoto(nRecnoFLD))
	EndIf	
	
	//Envia email para o Solicitante
	cTo := Posicione("RD0",1,xFilial('RD0')+FW3->FW3_USER,"RD0_EMAIL")
	cTo := AllTrim(cTo)		
	
	If !Empty(cTO)
		cMensagem += FN665DtVg(oView,cStatus) //Detalhamento da Viagem	
		FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto)
	Else
		Help(" ",1,"F665NOEMAIL",,STR0036,1,0) //Solicitante não tem email cadastrado!	
	EndIf
Else
	Help(" ",1,"F665NOSOLIC",,STR0037,1,0) //Solicitante não cadastrada!"
EndIf

If oView != Nil
	oView:ButtonOkAction(.T.)
EndIf

RestArea(aArea)
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FN665DtVg()
Detalhamento da Viagem - Servicos FL6

@author Antonio Florêncio Domingos Filho

@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function FN665DtVg(oView as Object, cStatus as Character) as Character

Local aArea     as Array
Local aSrv      as Array
Local aViaj     as Array
Local cMensagem as Character
Local cObs      as Character
Local cServico  as Character
Local nI        as Numeric
Local nX        as Numeric
Local oModel    as Object
Local oModelFL5 as Object

aArea     := GetArea()
aViaj     := {}
cMensagem := ""
cObs      := ""
cServico  := ""
nI        := 1
nX        := 1
oModel    := FWLoadModel("FINA665") //Carrega o Model
oModelFL5 := oModel:GetModel("FL5MASTER")

oModelFL5:Activate()

//Monta um Array com a Quantidade de Serviços
aSrv:= RetSrvFl6(oModelFL5:GetValue('FL5_VIAGEM'))

cMensagem := "<HTML><HEAD></HEAD><BODY><Font face='arial'>"

//Monta Cabeçalho da Viagem
cMensagem += "<table width=700>"
cMensagem += "<thead>"
cMensagem += "<tr width=700>"
cMensagem += "<th colspan=6 width=2000 bgColor=#538ED5><font color=White><b><h2>"+ STR0097 /*Viagem*/ + " " + oModelFL5:GetValue('FL5_VIAGEM')+"</h2></b></th>" 
cMensagem += "</tr>"		
cMensagem += "</thead>"
cMensagem += "<tbody>"
cMensagem += "<tr>"        		
cMensagem += "<td width=400 align=center>"+STR0098+"</th>" //Solicitação
cMensagem += "<td width=400 align=center>"+STR0099+"</th>" //Status
cMensagem += "<td width=400 align=center>"+STR0100+"</th>" //Origem
cMensagem += "<td width=400 align=center>"+STR0101+"</th>" //Destino
cMensagem += "<td width=400 align=center>"+STR0102+"</th>" //Data inicial
cMensagem += "<td width=400 align=center>"+STR0103+"</th>" //Data Final 	
cMensagem += "<tr>"        
cMensagem += "<td width=400 align=center><b>"+oModelFL5:GetValue('FL5_IDSOL')+"</b></td>"
cMensagem += "<td width=400 align=center>"+cStatus+"</td>"
cMensagem += "<td width=400 align=center>"+Alltrim(oModelFL5:GetValue('FL5_DESORI'))+"</td>"
cMensagem += "<td width=400 align=center>"+Alltrim(oModelFL5:GetValue('FL5_DESDES'))+"</td>"
cMensagem += "<td width=400 align=center>"+DTOC(oModelFL5:GetValue('FL5_DTINI'))+"</td>"
cMensagem += "<td width=400 align=center>"+DTOC(oModelFL5:GetValue('FL5_DTFIM'))+"</td>"  	
cMensagem += "</tr>"    
cMensagem += "</tbody>"
cMensagem += "</table>" 

//Caso o Campo Observação esteja Preenchido carrega no HTML
If !Empty(oModelFL5:GetValue('FL5_OBS'))
	cMensagem += "<br>"	
	cMensagem += "<table width='700'>"   	        	    
	cMensagem += "<tr>"
	cMensagem += "<th colspan=2 width=700 bgColor=#538ED5 align=left><font color=White>"+STR0104+"</th>" //Justificativa Reprovação   	
	cMensagem += "</tr>"
	cMensagem += '<td width=700 align=left><p align="justify">'+oModelFL5:GetValue('FL5_OBS')+"</p></td>"
	cMensagem += "</tr>"    
	cMensagem += "</table>" 
	cMensagem += "<br>"	
Endif

//Monta Solicitação de Adiantamento
cMensagem += AdtHtml(oModelFL5:GetValue('FL5_VIAGEM'))
cMensagem += "<table width=700>"
cMensagem += "<tr width=700>"
cMensagem += "<td colspan=12 width=2000 bgColor=#538ED5><font color=White><b>"+STR0105+"</b></font></td></tr>" //Descrição do(s) Serviço(s)		
cMensagem += "</tr>"

//Inicio do descritivo dos Serviços
	
	dbSelectArea("FW4")
	FW4->(dbSetOrder(1))

For nX := 1 to Len(aSRV)

	If nX > 1
		cMensagem += "<table width=700>"   
	Endif
			
	cMensagem += "<tr>"    
	cMensagem += "<th width=350 align=center>"+STR0106+"</th>"   //Serviço
	cMensagem += "<th width=350 align=center>"+STR0107+"</th>"   //Participantes  	
	cMensagem += "<th width=350 align=center>"+STR0108+"</th>"   //Valor
	cMensagem += "</tr>"	

	aViaj := RetViaj(oModelFL5:GetValue('FL5_VIAGEM')) //Retorna o Participantes do serviço	

	If aSrv[nX][3] == '1'
		cServico := STR0011 //"Aereo"
	ElseIf aSrv[nX][3] == '2'	 
		cServico := STR0012 //"Hotel"
	ElseIf aSrv[nX][3] == '3'	 
		cServico := STR0014 // "Carro"
	ElseIf aSrv[nX][3] == '4'	 
		cServico := STR0015 //"Seguro"
	ElseIf aSrv[nX][3] == '5'	 
		cServico := STR0013 //"Rodoviario"
	Else	 
		cServico := STR0031 //"Outros"																					
	Endif			
	
	cMensagem += "<tr>"		
	cMensagem += "<td Rowspan=3 width=200 align=center>"+cServico+"</td>" 	
	cMensagem += "</tr>"    				
	
	For nI := 1 to Len(aViaj) 
		cMensagem += "<tr>"		
		cMensagem += "<td width=350 align=center>"+Alltrim(aViaj[nI][2])+"</td>" 
		cMensagem += "<td width=200 align=center>&nbsp;</td>"		
		cMensagem += "</tr>"
	Next
		
	cMensagem += "<tr>"	
	cMensagem += "<td align=Center >&nbsp;</b></td>"  		
	cMensagem += "<td align=Center >&nbsp;</b></td>"  			
	cMensagem += "<td align=Center >"+ Alltrim(Str(aSrv[nX][4],17,2))+"</b></td>"  	
	cMensagem += "</tr>"	
	cMensagem += "</Table>"
	
	If FW4->(dbSeek(xFilial("FW4")+oModelFL5:GetValue('FL5_IDSOL')+aSrv[nX][2])) 
		
		cObs :=  FW4->FW4_OBS

		If !Empty(cObs)
			cMensagem += "<table>"
    		cMensagem += "<tr>"
    		cMensagem += "<td colspan=3 width=680 Align=Center><b>"+STR0109+"</b>" //Observação
			cMensagem += "</td>"    	
			cMensagem += "</tr>"
			cMensagem += "<td  width=350 align=center>"+cObs+"</td>"    	
    		cMensagem += "</tr>"   
			cMensagem += "<tr>"	
			cMensagem += "<td colspan=3 width=350 align=Right>&nbsp;</td>"  		
			cMensagem += "</tr>"	
			cMensagem += "</table>"    
		Endif
	Endif

	aViaj := {} //Zera o Array para deixar pronto para o proximo serviço

Next

//Finaliza o HTML
cMensagem += "</Font></BODY></HTML>"

RestArea(aArea) //Restaura a Area

Return cMensagem		

//-------------------------------------------------------------------
/*/{Protheus.doc} AdtHtml()
Monta HTML da Solicitação de Adiantamento - FLD

@author Victor Tomio Furukawa

@since 20/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function AdtHtml(cViag as Character) as Character 

Local aArea   as Array
Local cAlias  as Character
Local cMsgAdt as Character
Local cQuery  as Character

cMsgAdt := ""
cQuery  := ""

Default cViag := ""

If !Empty(cViag)	

	aArea   := GetArea()
	cAlias  := GetNextAlias()

	cQuery := "SELECT "
	cQuery +=    "FLD.FLD_PARTIC, " 	
	cQuery +=    "FLD.FLD_VALOR, " 	
	cQuery +=    "RD0.RD0_NOME "
	cQuery += "FROM " + RetSqlName("FLD") + " FLD "
	cQuery +=    "INNER JOIN " + RetSqlName("RD0") + " RD0 ON RD0.RD0_CODIGO = FLD.FLD_PARTIC AND RD0.RD0_FILIAL = '"+ xFilial("RD0") + "' "
	cQuery += "WHERE "
	cQuery +=    "FLD.FLD_FILIAL = '"+ xFilial("FLD") + "' AND "
	cQuery +=    "FLD.FLD_VIAGEM = '"+ cViag +"' AND "	
	cQuery +=    "FLD.FLD_ITEM = '01' AND "
	cQuery +=    "FLD.D_E_L_E_T_ = ' ' AND "
	cQuery +=    "RD0.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)		

		cMsgAdt := "<TABLE width=700>"
		cMsgAdt += "<tr width=700>"
		cMsgAdt += "<td colspan=12 width=2000 bgColor=#538ED5><font color=White><b>"+STR0110+"</b></font></td></tr>" //Adiantamentos		
		cMsgAdt += "<br>"    
		cMsgAdt += "<tr>"    
		cMsgAdt += "<th width=350 align=center>"+STR0111+"</th>"    //Nome do Participante
		cMsgAdt += "<th width=350 align=center>"+STR0108+"</th>"    //Valor
		cMsgAdt += "</tr>"    
		cMsgAdt += "<tr>"	
		cMsgAdt += "<td width=200 align=center></td>"    		
		cMsgAdt += "<td width=200 align=center></td>"    		
		cMsgAdt += "</tr>"

		While (cAlias)->(!EOF())

			cMsgAdt += "<tr>"	
			cMsgAdt += "<td width=200 align=center>"+Alltrim((cAlias)->RD0_NOME)+"</td>"    		
			cMsgAdt += "<td width=200 align=center>"+Alltrim(Str((cAlias)->FLD_VALOR,17,2))+"</td>"    		
			cMsgAdt += "</tr>" 

			(cAlias)->(DbSkip())
		EndDo

		cMsgAdt += "</table>" 
		cMsgAdt += "<br>"	

	(cAlias)->(DbCloseArea()) //Fecha a Tabela
	RestArea(aArea) //Restaura a Area
	FwFreeArray(aArea) //Libera a Memoria

Endif

Return cMsgAdt

//-------------------------------------------------------------------
/*/{Protheus.doc} RetViaj()
Retorna um Array com os Viajantes da Solicitação de Viagem - FLD

@author Victor Tomio Furukawa

@since 20/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetViaj(cViag as Character) as Array

Local aArea  as Array
Local aRet   as Array
Local cAlias as Character
Local cQuery as Character

aRet   := {}
cQuery := ""

Default cViag   := ""

If !Empty(cViag)

	aArea  := GetArea()
	cAlias := GetNextAlias()

	cQuery := "SELECT "
	cQuery +=    "FLD.FLD_PARTIC, "
	cQuery +=    "RD0.RD0_NOME "
	cQuery +="FROM " + RetSqlName("FLD") + " FLD "
	cQuery +=    "INNER JOIN " + RetSqlName("RD0") + " RD0 ON RD0.RD0_CODIGO = FLD.FLD_PARTIC AND RD0.RD0_FILIAL = '"+ xFilial("RD0") + "' "
	cQuery +="WHERE "
	cQuery +=    "FLD.FLD_FILIAL = '"+ xFilial("FLD") + "' AND "
	cQuery +=    "FLD.FLD_VIAGEM = '"+ cViag +"' AND " 
	cQuery +=    "FLD.FLD_ITEM = '01' AND "
	cQuery +=    "FLD.D_E_L_E_T_ = ' ' AND "
	cQuery +=    "RD0.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)	
		
	While (cAlias)->(!EOF())
		Aadd(aRet, {(cAlias)->FLD_PARTIC,(cAlias)->RD0_NOME})
		(cAlias)->(DbSkip())
	EndDo			

	(cAlias)->(DbCloseArea()) //Fecha a Tabela
	RestArea(aArea) //Restaura a Area
	FwFreeArray(aArea) //Libera a Memoria

Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetQtdFl6
Retorna um Array com os serviços envolvidos na viagem

@author Victor Tomio Furukawa

@since 20/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function RetSrvFl6(cViagem as Character) as Array

Local aArea   as Array
Local aSrv    as Array
Local cAlias  as Character
Local cQuery  as Character

cMsgAdt := ""
cQuery  := ""
aSrv    := {}

Default cViagem := ""

If !Empty(cViagem)	

	aArea   := GetArea()
	cAlias  := GetNextAlias()

	cQuery := "SELECT "
	cQuery +=    "FL6_VIAGEM, " 
	cQuery +=    "FL6_ITEM, "
	cQuery +=    "FL6_TIPO, "
	cQuery +=    "FL6_TOTAL "
	cQuery += "FROM " + RetSqlName("FL6") 	
	cQuery += " WHERE "
	cQuery +=    "FL6_FILIAL = '"+ xFilial("FL6") + "' AND "
	cQuery +=    "FL6_VIAGEM = '"+ cViagem +"' AND "	
	cQuery +=    "D_E_L_E_T_ = ' '"	

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)	

	While (cAlias)->(!EOF())

		Aadd(aSrv, {(cAlias)->FL6_VIAGEM, (cAlias)->FL6_ITEM, (cAlias)->FL6_TIPO, (cAlias)->FL6_TOTAL})			
		(cAlias)->(DbSkip())

	EndDo

	(cAlias)->(DbCloseArea()) //Fecha a Tabela
	RestArea(aArea) //Restaura a Area
	FwFreeArray(aArea) //Libera a Memoria

Endif

Return aSrv

/*/{Protheus.doc} F665VINC
Busca por Vinculos
@author Anderson Reis
@since  06/05/2015
@version 12.
/*/
Function F665VINCX(cViagem,oPedidos)
Local cQuery := ''
Local aRet := {}
Local aArea     := GetArea()
Local cAliasFL5   := GetNextAlias()

BeginSql Alias cAliasFL5	

	SELECT FL5_VIAGEM, FL5_CODORI,FL5_CODDES
	FROM %Table:FL5% FL5,
		%Table:FL6% FL6
	WHERE
		FL5.FL5_FILIAL  =  %xFilial:FL6%     AND
		FL5.FL5_VIAGEM  =  FL6.FL6_VIAGEM    AND 
		FL5.%NotDel%                         AND
		FL6.%NotDel%                         AND
		SE8.E8_FILIAL = %xFilial:SE8% AND
		SE8.E8_BANCO = SA6.A6_COD AND 
		SE8.E8_AGENCIA = SA6.A6_AGENCIA AND
		SE8.E8_CONTA = SA6.A6_NUMCON AND
		SE8.%NotDel% AND
		SE8.E8_DTSALAT = ( SELECT MAX(TMP.E8_DTSALAT)
							FROM %Table:SE8% TMP
							WHERE 
								TMP.E8_FILIAL = %xFilial:SE8% AND
								TMP.E8_BANCO = SA6.A6_COD AND 
								TMP.E8_AGENCIA = SA6.A6_AGENCIA AND
								TMP.E8_CONTA = SA6.A6_NUMCON AND
								TMP.E8_DTSALAT <= %Exp:dData% AND
								TMP.%NotDel% )
        ORDER BY E8_FILIAL,E8_BANCO,E8_AGENCIA,E8_CONTA,E8_DTSALAT
EndSql		
	
	dbSelectArea("FL6")
	dbSelectArea("FL5")
	
	cQuery += 'SELECT FL5_VIAGEM,FL5_IDRESE FROM ' + RetSqlName("FL5") + " FL5 "
	cQuery += "WHERE FL5_FILIAL = '" + xFilial("FL5") + "'"
	cQuery += "AND FL5_IDRESE = '" + cValToChar(nGrupo) + "'" 
	cQuery += "AND D_E_L_E_T_ = ' ' " 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cFiltro",.T.,.T.)
    dbSelectArea("cFiltro")
  	dbGoTop()
	
	If cFiltro->(Eof()) //---Não encontrou nenhum pedido na viagem então busca nos pedidos para encontrar a viagem.  
    	cFiltro->(DbCloseArea())
    	cQuery := ''
    	cQuery += 'SELECT FL6_VIAGEM FROM ' + RetSqlName("FL6") + " FL6"
    	cQuery += "WHERE FL6_FILIAL = '" + xFilial("FL6") + "'"
		cQuery += "AND FL6_IDRESE = '" + cValToChar(nGrupo) + "'" 
		cQuery += "AND D_E_L_E_T_ = ' ' " 
		cQuery := ChangeQuery(cQuery)
    	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cFiltro",.T.,.T.)
    	dbSelectArea("cFiltro")
  		dbGoTop()
  		If cFiltro->(Eof()) //--Cria nova viagem.
  			aAdd(aRet,.F.)
  		Else
  			aAdd(aRet,.T.)
    		aAdd(aRet,cFiltro->FL6_VIAGEM)
    	EndIf		
    Else
    	aAdd(aRet,.T.)
    	aAdd(aRet,cFiltro->FL5_VIAGEM)
    End		
	
	cFiltro->(DbCloseArea())
	RestArea(aArea)
	
Return aRet

/*/{Protheus.doc} F665VINC
Busca por Vinculos
@author Anderson Reis
@since  06/05/2015
@version 12.
/*/
Function F665VINC(oPedidos)
Local cQuery    	:= ''
Local aRet       	:= {}
Local aArea      	:= GetArea()
Local lCliente	:= SubStr(SuperGetMV("MV_RESCAD",.F.,"000"),2,1) == "1" //Verifica se utiliza cliente.
Local lVincPas 	:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),1,1) == "1" //Verifica se utiliza Vinculo Passageiro .
Local lVinccli 	:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),2,1) == "1" //Verifica se utiliza Vinculo Data .
Local lVincdat 	:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),3,1) == "1" //Verifica se utiliza Vinculo Cliente .
Local lVincCC  	:= SubStr(SuperGetMV("MV_FILVIAG",.F.,"0000"),4,1) == "1" //Verifica se utiliza Vinculo CCusto .
Local aAux       	:= {}
Local aAuxA      	:= {}
Local lExist     	:= .F.
Local lExistA    	:= .F.
Local nA		 	:= 0
Local nX		 	:= 0		
Local nB 		 	:= 0
Local nQtdVinc 	:= SuperGetMV("MV_RESVINC",.F.,"0")  //Verifica qtd de dias no Vínculo automático
Local nQtdReg	 	:= 0
Local cViag		:= ""
Local cDtLim		:= ""
Local lPEVinc		:= ExistBlock("F665PEVINC")

If oPedidos <> NIL 

	cQuery := " SELECT  FL5_VIAGEM VIAGEM " + CRLF
	cQuery += " FROM " + RetSqlName("FL5") + " FL5 " + CRLF
	cQuery += " LEFT JOIN " + RetSqlName("FL6")+ " FL6 " + " ON FL5.FL5_FILIAL = FL6.FL6_FILIAL" + CRLF
	cQuery += " AND FL5.FL5_VIAGEM = FL6.FL6_VIAGEM AND FL6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " WHERE   FL6_FILIAL = '" + xFilial("FL6") + "' AND " + CRLF
	cQuery += " FL6.D_E_L_E_T_ = ' ' " + CRLF
	
	If lVincDat .and. nQtdVinc > 0    // Habilitado Data
		cDtLim := DTOS(StoD(Subs(STRTRAN(oPedidos:cDataEmissao,'-',''),1,8)) + nQtdVinc)
		cQuery += " AND FL6.FL6_DTEMIS BETWEEN '" +DTOS(StoD(Subs(STRTRAN(oPedidos:cDataEmissao,'-',''),1,8)))+ "'" + CRLF
		cQuery += " AND '" + cDtLim + "'"
	EndIf
	// Só pega em Aberto
	cQuery += " AND FL5.FL5_STATUS = '1' "
	
	If lVincCli  .AND. lCliente    // Habilitado Clientes
		cQuery += " AND FL5.FL5_CLIENT = '" +Substr(AllTrim(oPedidos:cProjeto),1,6) + "'" + CRLF
		cQuery += " AND FL5.FL5_LOJA   = '" +Substr(AllTrim(oPedidos:cProjeto),7,2) + "'" + CRLF
	EndIf

	cQuery += "      GROUP BY FL5_VIAGEM "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUsearea(.T.,"TOPCONN",TCGenQry(,,cQuery), "cFiltro") 
	
	Count to nQtdReg
	cFiltro->(DBGotop()) 
	Do While cFiltro->(!EOF()) 
	
		cViag := cFiltro->VIAGEM
		If lVincCC        // Habilitado Centro de Custo
			
			DbSelectArea('FLH')
			DbSetOrder(1)
			If DbSeek(xFilial('FLH')+cFiltro->VIAGEM)
			
				If (oPedidos:OWSCCUSTOS <> Nil)
				
					For nX := 1 To Len(oPedidos:OWSCCUSTOS:OWSCCUSTO)						
						//Casos do mesmo centro de custo no pedido.
						For nA := 1 To Len(aAux)
							If 	oPedidos:OWSCCUSTOS:OWSCCUSTO[nX]:cCCusto == aAux[nA]
								lExist := .T.	
							EndIf	 
						Next
						
						If !lExist
							aAdd(aAux,oPedidos:OWSCCUSTOS:OWSCCUSTO[nX]:cCCusto)
						EndIf
						
						If !lExist .and. FLH->FLH_CC = oPedidos:OWSCCUSTOS:OWSCCUSTO[nx]:cCCusto
							
							If Len(aRet) > 0
	    						For nB := 2 To Len(aRet)
									If 	cFiltro->VIAGEM <> aRet[nb] .AND. Empty(aScan( aRet, { |x| AllTrim(x) == cFiltro->VIAGEM }))
										aAdd(aRet,.T.)
	    								aAdd(aRet,cFiltro->VIAGEM)	
									EndIf
									nB++	 
								Next    					
	    					Else
	    						aAdd(aRet,.T.)
	    						aAdd(aRet,cFiltro->VIAGEM)	
	    					EndIf
						EndIf	
					Next
		    	EndIf	
			EndIf
		EndIf
			
		If lVincPas // oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[1]:nIDaa
			
			DbSelectArea('FLC')
			DbSetOrder(1)
			If DbSeek(xFilial('FLC')+cFiltro->VIAGEM)
			
				If (oPedidos:OWSPASSAGEIROS <> Nil)
				
					For nX := 1 To Len(oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO)	
						
						//Casos do mesmo passageiro.
						For nA := 1 To Len(aAuxA)
							If 	oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nA]:nId == aAuxA[nA]
								lExistA := .T.	
							EndIf	 
						Next
						
						If!lExistA
							aAdd(aAuxA,oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:nId)
						Endif
						
						If !lExistA .and. Val(FLC->FLC_IDRESE) = oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:nID
							
							If Len(aRet) > 0
	    						For nB := 2 To Len(aRet)
									If 	cFiltro->VIAGEM <> aRet[nb] .AND. Empty(aScan( aRet, { |x| AllTrim(x) == cFiltro->VIAGEM }))
										aAdd(aRet,.T.)
	    								aAdd(aRet,cFiltro->VIAGEM)	    								
									EndIf
									nB++	 
								Next 
	    					Else
	    						aAdd(aRet,.T.)
	    						aAdd(aRet,cFiltro->VIAGEM)	
	    					EndIf
						EndIf	
					Next
		    	EndIf	
			EndIf
			
		EndIf
		
		cFiltro->(DBSkip()) 
		
	EndDo
	
	If lPEVinc
		aRet := ExecBlock("F665PEVINC",.F.,.F.,{oPedidos})
	EndIf
		
	If Len(aRet) = 0 
		aAdd(aRet,.F.)
	ElseIf !aRet[1]
		aAdd(aRet,.F.)
	EndIf
	
	cFiltro->(DbCloseArea()) 	
Else
	AADD(aRet, .F.)
	AADD(aRet, "")	 	
EndIf

RestArea(aArea)

Return aRet

/*/{Protheus.doc} FN665CUST
Opção para alterar classe de valor e item contabil, será permitida apenas alteração e não inclusão de novas linhas.
@author william.gundim
@since  12/02/16
@version 12
/*/
Function FN665CUST()
Local cTitulo 	:= ''
Local cPrograma := ''
Local aEnableButtons:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	If Empty(FL5->FL5_IDSOL)
		__nOper      	:= OPER_CUSTO
		cTitulo      	:= STR0001
		cPrograma    	:= 'FINA665'
		__lConfReprova 	:= .F.
		FWExecView( cTitulo , cPrograma, MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,{|| .T. } , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	Else
		Help(" ",1,"F665ALTCC",,STR0089,1,0)	
	EndIf
	
Return 

/*/{Protheus.doc} F665OKCC
Validação do centro de custo.
@author william.gundim
@since  01/06/16
@version 12
/*/

Function F665OKCC(oModel)
Local nSum	:= 0
Local nX	:= 0
Local lRet	:= .T.

	For nX := 1 To oModel:Length()
		If !oModel:IsDeleted( nX )
			nSum += oModel:GetValue('FLH_PORCEN', nX)
		EndIf
	Next nX
	
	If nSum != 100
		lRet := .F.
		Help(" ",1,"F665PORCC",,STR0091,1,0)
	EndIf
	
Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} F665ODesc
Função de Busca descrição do Local de Destino

@author Thiago Murakami
@since 15/06/2016
@version 12.1.11
/*/
//-----------------------------------------------------------------
Function FN665ODesc()
Local oModel	:= FWModelActive()
Local cDesc  := ""

If !Empty(oModel:GetValue("FL5MASTER","FL5_CODORI"))
	If oModel:GetValue("FL5MASTER","FL5_NACION") == '1' //Nacional
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW7DETAIL","FW7_CODORI")),"X5_DESCRI")
	Else
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW7DETAIL","FW7_CODORI")),"X5_DESCRI")
		If Empty(cDesc)
			cDesc := Posicione("SX5",1,xFilial("SX5") + "BH" + AllTrim(oModel:GetValue("FW7DETAIL","FW7_CODORI")),"X5_DESCRI")
		EndIf
	EndIf
EndIf

Return ALLTRIM(cDesc)

//-----------------------------------------------------------------
/*/{Protheus.doc} F665DDesc
Função de Busca descrição do Local de Destino

@author Thiago Murakami
@since 15/06/2016
@version 12.1.11
/*/
//-----------------------------------------------------------------
Function FN665DDesc()
Local oModel := FWModelActive()
Local cDesc  := ""

If !Empty(oModel:GetValue("FL5MASTER","FL5_CODDES"))
	If oModel:GetValue("FL5MASTER","FL5_NACION") == '1' //Nacional
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW7DETAIL","FW7_CODDES")),"X5_DESCRI")
	Else
		cDesc := Posicione("SX5",1,xFilial("SX5") + "12" + AllTrim(oModel:GetValue("FW7DETAIL","FW7_CODDES")),"X5_DESCRI")
		If Empty(cDesc)
			cDesc := Posicione("SX5",1,xFilial("SX5") + "BH" + AllTrim(oModel:GetValue("FW7DETAIL","FW7_CODDES")),"X5_DESCRI")
		EndIf
	EndIf
EndIf

Return ALLTRIM(cDesc)

//-------------------------------------------------------------------
/*/{Protheus.doc} FNOperAut
Define a opera‡?o quando executado pelo Rob“ de Testes 

@author Automacao
@since  19/05/2016
/*/
//-------------------------------------------------------------------
Function FNOperAut(nOper) //-- Automacao

__nOper := nOper

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} UsrApprover
Valida se o usuario logado pode aprovar a viagem

@author Igor Nascimento
@since 18/08/2021
@version 12.1.33
/*/
//-----------------------------------------------------------------
Static Function UsrApprover() As Logical

	Local aArea		As Array
	Local aUser		As Array
	Local cChaveFW5 As Char
	Local lOk		As Logical

	aArea := GetArea()
	aUser := {}
	lOk	  := FINXUser(__cUserId,aUser)

	If lOk
		dbSelectArea("FLJ")
		dbSetOrder(1)
		If dbSeek(xFilial("FLJ")+FL5->FL5_VIAGEM)
			While FLJ->(!Eof()) .AND. FLJ->FLJ_FILIAL==xFilial("FLJ") .And. FLJ->FLJ_VIAGEM == FL5->FL5_VIAGEM .AND. !lOk
				If aUser[1] == FLJ->FLJ_PARTIC
					lOk := .T.
				EndIf
				FLJ->(dbSkip())
			EndDo
		EndIf
		
		If !lOk			//Valida se é substituto
			cChaveFW5 := xFilial("FW5")+FL5->FL5_IDSOL
			dbSelectArea("RD0")
			dbSelectArea("FW5")
			RD0->(dbSetOrder(1))
			FW5->(dbSetOrder(1))
			If FW5->(dbSeek(cChaveFW5))
				While FW5->(!EoF()) .and. FW5->(FW5_FILIAL+FW5_SOLICI) == cChaveFW5 .and. !lOk
					If RD0->(dbSeek(xFilial("RD0") + FW5->FW5_PARTIC))
						lOk := RD0->RD0_APSUBS == aUser[1] .or. RD0->RD0_APROPC == aUser[1]
					EndIf
					FW5->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lOk





	
	
	