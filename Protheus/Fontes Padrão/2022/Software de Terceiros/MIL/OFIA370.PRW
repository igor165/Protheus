#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA370.CH"

/*/{Protheus.doc} OFIA370()
VN8 - Tempo por Status do Orçamento

@author Andre Luis Almeida
@since 29/11/2021
@version 1.0
@return NIL
/*/
Function OFIA370()

Private cCadastro := STR0001 // Tempo por Status do Orçamento

oBrwVN8 := FwMBrowse():New()
oBrwVN8:SetDescription(cCadastro)
oBrwVN8:SetAlias('VN8')
oBrwVN8:DisableLocate()
oBrwVN8:DisableDetails()
oBrwVN8:SetAmbiente(.F.)
oBrwVN8:SetWalkthru(.F.)
oBrwVN8:SetInsert(.f.)
oBrwVN8:SetUseFilter()
oBrwVN8:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 29/11/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA370' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 29/11/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVN8 := FWFormStruct(1,"VN8")

oModel := MPFormModel():New("OFIA370", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VN8MASTER",/*cOwner*/ , oStrVN8)

oModel:SetDescription(STR0001) // Tempo por Status do Orçamento

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 29/11/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVN8:= FWFormStruct(2,"VN8")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VN8', oStrVN8, 'VN8MASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VN8', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} OA3700011_Grava_DTHR_Status_Orcamento
Grava Data/Hora do Status do Orcamento

@author Andre Luis Almeida
@since 29/11/2021
/*/
Function OA3700011_Grava_DTHR_Status_Orcamento( cNumOrc , cStatus , cObserv , dDta , cHra , cUsr , cRot )
Local oModVN8 := FWLoadModel( 'OFIA370' )
Local cQuery  := ""
Local cStaOld := "" // Ultimo Status
Local aErro   := {}
Default cNumOrc := ""
Default cStatus := "0"
Default cObserv := ""
Default dDta    := dDataBase
Default cHra    := Time()
Default cUsr    := RetCodUsr()
Default cRot    := FunName()
If !Empty(cNumOrc) .and. !Empty(cStatus) .and. FwAliasInDic("VN8")
	DbSelectArea("VN8")
	cQuery := "SELECT VN8_STATUS "
	cQuery += "  FROM " + RetSqlName('VN8')
	cQuery += " WHERE VN8_FILIAL = '"+xFilial("VN8")+"'"
	cQuery += "   AND VN8_NUMORC = '"+cNumOrc+"'"
	cQuery += " ORDER BY VN8_CODIGO DESC"
	cStaOld := FM_SQL(cQuery) // Pega o ultimo STATUS gravado
	If cStaOld <> cStatus // Somente GRAVA o novo STATUS se for diferente do ultimo gravado
		oModVN8:SetOperation( MODEL_OPERATION_INSERT )
		if oModVN8:Activate()
			oModVN8:LoadValue( "VN8MASTER" , "VN8_NUMORC" , cNumOrc )
			oModVN8:LoadValue( "VN8MASTER" , "VN8_STATUS" , cStatus )
			oModVN8:LoadValue( "VN8MASTER" , "VN8_OBSSTA" , cObserv )
			oModVN8:LoadValue( "VN8MASTER" , "VN8_DATSTA" , dDta )
			oModVN8:LoadValue( "VN8MASTER" , "VN8_HORSTA" , cHra )
			oModVN8:LoadValue( "VN8MASTER" , "VN8_USUSTA" , cUsr )
			oModVN8:LoadValue( "VN8MASTER" , "VN8_ROTINA" , cRot )
			If oModVN8:VldData()
				If oModVN8:CommitData()
				Else
					aErro := oModVN8:GetErrorMessage(.T.)
				EndIf
			Else
				aErro := oModVN8:GetErrorMessage(.T.)
			EndIf
			If len(aErro) > 0
				FMX_HELP("VALIDCOMMITVN8",;
					aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
					aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
					aErro[MODEL_MSGERR_ID         ] + CRLF +;
					aErro[MODEL_MSGERR_MESSAGE    ],;
					aErro[MODEL_MSGERR_SOLUCTION] )
			EndIf
			oModVN8:DeActivate()
		Else
			Help("",1,"ACTIVEVN8",,STR0003,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN8
		EndIf
	EndIf
EndIf
FreeObj(oModVN8)
DbSelectArea("VS1")
Return

/*/
{Protheus.doc} OA3700021_Grava_DTHR_do_Pedido_para_Orcamento
Grava todas Datas/Horas do Pedido para o Orcamento

@author Andre Luis Almeida
@since 29/11/2021
/*/
Function OA3700021_Grava_DTHR_do_Pedido_para_Orcamento( cPedido , cNumOrc )
Local cQuery    := ""
Local cAliasVN8 := "SQLVN8"
If FwAliasInDic("VN8")
	cQuery := "SELECT R_E_C_N_O_ AS RECVN8 "
	cQuery += "  FROM " + RetSqlName('VN8')
	cQuery += " WHERE VN8_FILIAL = '"+xFilial("VN8")+"'"
	cQuery += "   AND VN8_NUMORC = '"+cNumOrc+"'"
	If FM_SQL(cQuery) == 0 // Ainda nao existe registro gravado para o Orcamento
		cQuery := "SELECT VN8_STATUS , "
		cQuery += "       VN8_DATSTA , "
		cQuery += "       VN8_HORSTA , "
		cQuery += "       VN8_USUSTA , "
		cQuery += "       VN8_ROTINA , "
		cQuery += "       VN8_OBSSTA   "
		cQuery += "  FROM " + RetSqlName('VN8')
		cQuery += " WHERE VN8_FILIAL = '"+xFilial("VN8")+"'"
		cQuery += "   AND VN8_NUMORC = '"+cPedido+"'"
		cQuery += " ORDER BY VN8_CODIGO"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVN8, .T., .T. )
		Do While !( cAliasVN8 )->( Eof() )  
			OA3700011_Grava_DTHR_Status_Orcamento( cNumOrc ,;
											( cAliasVN8 )->( VN8_STATUS ) ,;
											( cAliasVN8 )->( VN8_OBSSTA ) ,;
											stod(( cAliasVN8 )->( VN8_DATSTA )) ,;
											( cAliasVN8 )->( VN8_HORSTA ) ,;
											( cAliasVN8 )->( VN8_USUSTA ) ,;
											( cAliasVN8 )->( VN8_ROTINA ) )
			( cAliasVN8 )->(dbSkip())
		Enddo
		( cAliasVN8 )->( dbCloseArea() )
	EndIf
Endif
DbSelectArea("VS1")
Return