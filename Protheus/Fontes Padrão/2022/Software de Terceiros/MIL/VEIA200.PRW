#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA200.CH"

/*/{Protheus.doc} VEIA200()
Liberação de Crédito de Clientes para geração de NF de Consórcios / Seguros / Serviços Diversos

@author Andre Luis Almeida
@since 20/10/2020
@version 1.0
@return NIL
/*/
Function VEIA200()
Local aSizeAut	:= MsAdvSize(.f.)
Private oModel

oVEIA200 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0001,,,,128,,,,,.t.) // Liberação de Crédito de Clientes para geração de NF de Consórcios / Seguros / Serviços Diversos

oTPanVRO := TPanel():New(0,0,"",oVEIA200,NIL,.T.,.F.,NIL,NIL,100,(oVEIA200:nClientHeight/4)-10,.F.,.F.)
oTPanVRO:Align := CONTROL_ALIGN_TOP

oTPanVQ9 := TPanel():New(0,0,"",oVEIA200,NIL,.T.,.F.,NIL,NIL,100,(oVEIA200:nClientHeight/4)-10,.F.,.F.)
oTPanVQ9:Align := CONTROL_ALIGN_BOTTOM 

oBrwVRO := FWMBrowse():New()
oBrwVRO:SetAlias("VRO")
oBrwVRO:SetOwner(oTPanVRO)
oBrwVRO:SetDescription(STR0001) // Liberação de Crédito de Clientes para geração de NF de Consórcios / Seguros / Serviços Diversos
oBrwVRO:AddFilter( STR0002 , " VRO_TIPO == '2' ") // Consórcios
oBrwVRO:AddFilter( STR0003 , " VRO_TIPO == '3' ") // Seguros
oBrwVRO:AddFilter( STR0004 , " VRO_TIPO == '4' ") // Serviços Diversos
oBrwVRO:AddLegend( "VRO_STATUS='0'"                                                                   , "BR_BRANCO"   , STR0005 ) // Solicitação Pendente
oBrwVRO:AddLegend( "VRO_STATUS='1'.and. Empty(VRO_USRUTI).and.DTOS(VRO_DATVAL)>='"+dtos(dDataBase)+"'", "BR_AMARELO"  , STR0006 ) // Solicitação Liberada e aguardando utilização
oBrwVRO:AddLegend( "VRO_STATUS='1'.and.!Empty(VRO_USRUTI)"                                            , "BR_VERDE"    , STR0007 ) // Solicitação Liberada e foi utilizada dentro do prazo de validade
oBrwVRO:AddLegend( "VRO_STATUS='1'.and. Empty(VRO_USRUTI).and.DTOS(VRO_DATVAL)<'"+dtos(dDataBase)+"'" , "BR_LARANJA"  , STR0008 ) // Solicitação Liberada e não foi utilizada dentro do prazo de validade
oBrwVRO:AddLegend( "VRO_STATUS='2'"                                                                   , "BR_VERMELHO" , STR0009 ) // Solicitação Rejeitada
oBrwVRO:DisableDetails()
oBrwVRO:Activate()
oBrwVRO:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oBrwVQ9 := FWMBrowse():New()
oBrwVQ9:SetAlias("VQ9")
oBrwVQ9:SetOwner(oTPanVQ9)
oBrwVQ9:SetDescription(STR0029) // Parcelas que utilizaram a Liberação da Solcitação de Crédito do Cliente
oBrwVQ9:SetMenuDef('')
oBrwVQ9:AddFilter( STR0030 , " !Empty(VQ9_CODVRO) ",.t.,.t.,) // Filtro Padrão
oBrwVQ9:DisableDetails()
oBrwVQ9:Activate()
oBrwVQ9:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwVRO , oBrwVQ9 , { { "VQ9_FILIAL" , "VRO_FILIAL" } , { "VQ9_CODVRO" , "VRO_CODIGO" } , { "VQ9_TIPO" , "VRO_TIPO" } } )
oRelac:Activate()

oVEIA200:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 20/10/2020
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
Local cOrdem  := ""
Local nCntFor := 0
Local lJaOfic := .f.

ADD OPTION aRotina TITLE STR0010 ACTION 'OA2000011_LiberaRejeita_Solicitacao("1")' OPERATION 4 ACCESS 0 // Liberar
ADD OPTION aRotina TITLE STR0011 ACTION 'OA2000011_LiberaRejeita_Solicitacao("2")' OPERATION 4 ACCESS 0 // Rejeitar
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.VEIA200' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0013 ACTION 'OA2000061_VerificaMotivo()' OPERATION 2 ACCESS 0 // Verifica o Motivo
ADD OPTION aRotina TITLE STR0014 ACTION 'OA2000051_PosicaoCliente()' OPERATION 2 ACCESS 0 // Posição do Cliente

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 20/10/2020
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVRO := FWFormStruct(1,"VRO")

oModel := MPFormModel():New("VEIA200", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VROMASTER",/*cOwner*/ , oStrVRO)

oModel:GetModel("VROMASTER"):SetDescription(STR0001) // Liberação de Crédito de Clientes para geração de NF de Consórcios / Seguros / Serviços Diversos
oModel:SetDescription(STR0001) // Liberação de Crédito de Clientes para geração de NF de Consórcios / Seguros / Serviços Diversos

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 20/10/2020
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVRO:= FWFormStruct(2, "VRO")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VRO', oStrVRO, 'VROMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox( "VRO", 100)
oView:SetOwnerView("VIEW_VRO","VRO")

Return oView

/*/{Protheus.doc} OA2000011_LiberaRejeita_Solicitacao
	Libera ou Rejeita a Solcitação de Credito para o Cliente

	@author Andre Luis Almeida
	@since 20/10/2020
/*/
Function OA2000011_LiberaRejeita_Solicitacao(cStatus)
Local aMotLBR := {} // Motivo da / Rejeição
Local cHora   := Time()
Local dDtVld  := ( dDataBase + GetNewPar("MV_MIL0159",0) ) // Dias para Validade
DbSelectArea("VRO")
If VRO->(RecNo()) > 0
	If OA2000071_VerificaPermissaoUsuario(cStatus,VRO->VRO_VLRSOL)
		If VRO->VRO_STATUS == "0"
			If cStatus == "1" // Liberar
				aMotLBR := OFA210MOT("000025","A",VRO->VRO_FILIAL,VRO->VRO_CODIGO,.T.) // Filtro da consulta do motivo
			ElseIf cStatus == "2" // Rejeitar
				aMotLBR := OFA210MOT("000024","A",VRO->VRO_FILIAL,VRO->VRO_CODIGO,.T.) // Filtro da consulta do motivo
			EndIf
			If Len(aMotLBR) > 0
				DbSelectArea("VRO")
				RecLock("VRO",.f.)
				VRO->VRO_DATLBR := dDataBase
				VRO->VRO_HORLBR := substr(cHora,1,2)+substr(cHora,4,2)
				VRO->VRO_USRLBR := __cUserID
				VRO->VRO_STATUS := cStatus
				VRO->VRO_MOTLBR := aMotLBR[1]
				VRO->VRO_DATVAL := dDtVld
				MsUnLock()
			EndIf
		Else
			MsgStop(STR0016,STR0015) // Impossível realizar a operação devido ao Status da Solicitação! / Atenção
		EndIf
	EndIf
	DbSelectArea("VRO")
EndIf
Return

/*/{Protheus.doc} OA2000021_Existe_Solicitacao
	Verifica a existencia de Solcitação de Credito para o Cliente

	@author Andre Luis Almeida
	@since 20/10/2020
/*/
Function OA2000021_Existe_Solicitacao(cTipo,cCodCli,cLojCli,cStatus,nVlrSol,dDtaVal,lMsg)
Local cQuery    := ""
Local cSQLAlias := "SQLVRO"
Local cTit      := ""
Local cMsg      := ""
Local nRecVRO   := 0
Default nVlrSol := 0
Default dDtaVal := ctod("")
Default lMsg    := .t.
cQuery := "SELECT R_E_C_N_O_ AS RECVRO "
If lMsg
	cQuery += " , VRO.* " // Trazer os campos para mostrar na Mensagem
EndIf
cQuery += "  FROM "+RetSQLName("VRO")+" VRO "
cQuery += " WHERE VRO_FILIAL='"+xFilial("VRO")+"'"
cQuery += "   AND VRO_TIPO='"+cTipo+"'"
cQuery += "   AND VRO_CODCLI='"+cCodCli+"'"
cQuery += "   AND VRO_LOJCLI='"+cLojCli+"'"
cQuery += "   AND VRO_STATUS='"+cStatus+"'"
cQuery += "   AND VRO_VLRSOL>="+Alltrim(str(nVlrSol))
If !Empty(dDtaVal)
	cQuery += "   AND VRO_DATVAL>='"+dtos(dDtaVal)+"'"
EndIf
cQuery += "   AND VRO_USRUTI=' '"
cQuery += "   AND D_E_L_E_T_=' '"
If nVlrSol > 0
	cQuery += " ORDER BY VRO_VLRSOL"
Else
	cQuery += " ORDER BY R_E_C_N_O_ DESC"
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
If !(cSQLAlias)->(Eof())
	nRecVRO := (cSQLAlias)->( RECVRO )
	If lMsg
		cQuery := "SELECT A1_NOME "
		cQuery += "  FROM "+RetSQLName("SA1")
		cQuery += " WHERE A1_FILIAL='"+xFilial("SA1")+"'"
		cQuery += "   AND A1_COD='"+cCodCli+"'"
		cQuery += "   AND A1_LOJA='"+cLojCli+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		cMsg := STR0017+": "+cCodCli+"-"+cLojCli+" "+left(FM_SQL(cQuery),30)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Cliente
		cMsg += STR0018+": " // Tipo
		Do Case
			Case cTipo == "2" // Consorcios
				cMsg += STR0002 // Consórcios
			Case cTipo == "3" // Seguros
				cMsg += STR0003 // Seguros
			Case cTipo == "4" // Servicos Diversos
				cMsg += STR0004 // Serviços Diversos
		EndCase
		cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg += STR0019+": "+Transform(stod((cSQLAlias)->( VRO_DATSOL )),"@D")+" "+Transform((cSQLAlias)->( VRO_HORSOL ),"@R 99:99")+CHR(13)+CHR(10) // Solicitacao
		cMsg += (cSQLAlias)->( VRO_USRSOL )+" - "+left(UPPER(UsrRetName((cSQLAlias)->( VRO_USRSOL ))),20)+CHR(13)+CHR(10)
		cMsg += STR0020+": "+Transform((cSQLAlias)->( VRO_VLRSOL ),"@E 999,999,999.99")+CHR(13)+CHR(10) // Valor
		Do Case
			Case cStatus == "0" // Pendente
				cTit := STR0022 // Cliente com Liberação de Crédito Pendente
				cMsg += STR0021+": "+Transform(stod((cSQLAlias)->( VRO_DATVAL )),"@D") // Validade
			Case cStatus == "1" // Liberada
				cTit := STR0024 // Cliente com Liberação de Crédito
				cMsg += CHR(13)+CHR(10)
				cMsg += STR0025+": "+Transform(stod((cSQLAlias)->( VRO_DATLBR )),"@D")+" "+Transform((cSQLAlias)->( VRO_HORLBR ),"@R 99:99")+CHR(13)+CHR(10) // Liberacao
				cMsg += (cSQLAlias)->( VRO_USRLBR )+" - "+left(UPPER(UsrRetName((cSQLAlias)->( VRO_USRLBR ))),20)+CHR(13)+CHR(10)
				cMsg += STR0020+": "+Transform((cSQLAlias)->( VRO_VLRSOL ),"@E 999,999,999.99")+" - " // Valor
				cMsg += STR0021+": "+Transform(stod((cSQLAlias)->( VRO_DATVAL )),"@D")+CHR(13)+CHR(10) // Validade
				cQuery := "SELECT VS0_DESMOT "
				cQuery += "  FROM "+RetSQLName("VS0")
				cQuery += " WHERE VS0_FILIAL='"+xFilial("VS0")+"'"
				cQuery += "   AND VS0_TIPASS='000025'"
				cQuery += "   AND VS0_CODMOT='"+(cSQLAlias)->( VRO_MOTLBR )+"'"
				cQuery += "   AND D_E_L_E_T_=' '"
				cMsg += STR0027+": "+(cSQLAlias)->( VRO_MOTLBR )+" - "+FM_SQL(cQuery) // Motivo
			Case cStatus == "2" // Rejeitada
				cTit := STR0023 // Cliente com Liberação de Crédito Rejeitada
				cMsg += CHR(13)+CHR(10)
				cMsg += STR0026+": "+Transform(stod((cSQLAlias)->( VRO_DATLBR )),"@D")+" "+Transform((cSQLAlias)->( VRO_HORLBR),"@R 99:99")+CHR(13)+CHR(10) // Rejeicao
				cMsg += (cSQLAlias)->( VRO_USRLBR )+" - "+left(UPPER(UsrRetName((cSQLAlias)->( VRO_USRLBR ))),20)+CHR(13)+CHR(10)
				cQuery := "SELECT VS0_DESMOT "
				cQuery += "  FROM "+RetSQLName("VS0")
				cQuery += " WHERE VS0_FILIAL='"+xFilial("VS0")+"'"
				cQuery += "   AND VS0_TIPASS='000024'"
				cQuery += "   AND VS0_CODMOT='"+(cSQLAlias)->( VRO_MOTLBR )+"'"
				cQuery += "   AND D_E_L_E_T_=' '"
				cMsg += STR0027+": "+(cSQLAlias)->( VRO_MOTLBR )+" - "+FM_SQL(cQuery) // Motivo
		EndCase
		AVISO(cTit, cMsg, { "OK" } , 3)
	EndIf

EndIf
(cSQLAlias)->(dbCloseArea())
DbSelectArea("VRO")
Return nRecVRO

/*/{Protheus.doc} OA2000031_Cria_Solicitacao
	Cria Solcitação de Credito para o Cliente

	@author Andre Luis Almeida
	@since 20/10/2020
/*/
Function OA2000031_Cria_Solicitacao(cTipo,cCodCli,cLojCli,nVlrSol)
Local cHora  := Time()
Local dDtVld := ( dDataBase + GetNewPar("MV_MIL0159",0) ) // Dias para Validade
DbSelectArea("VRO")
RecLock("VRO",.t.)
	VRO->VRO_FILIAL := xFilial("VRO")
	VRO->VRO_CODIGO := GetSXENum("VRO","VRO_CODIGO")
	VRO->VRO_TIPO   := cTipo
	VRO->VRO_STATUS := "0" // Pendente
	VRO->VRO_CODCLI := cCodCli
	VRO->VRO_LOJCLI := cLojCli
	VRO->VRO_DATSOL := dDataBase
	VRO->VRO_HORSOL := substr(cHora,1,2)+substr(cHora,4,2)
	VRO->VRO_USRSOL := __cUserID
	VRO->VRO_VLRSOL := nVlrSol
	VRO->VRO_DATVAL := dDtVld
MsUnLock()
ConfirmSx8()
Return .t.

/*/{Protheus.doc} OA2000041_Utiliza_Solicitacao
	Utiliza Solcitação de Credito para o Cliente

	@author Andre Luis Almeida
	@since 21/10/2020
/*/
Function OA2000041_Utiliza_Solicitacao(nRecVRO,nVlrUti)
Local cHora := Time()
DbSelectArea("VRO")
If nRecVRO > 0
	DbGoTo(nRecVRO)
	RecLock("VRO",.f.)
	VRO->VRO_DATUTI := dDataBase
	VRO->VRO_HORUTI := substr(cHora,1,2)+substr(cHora,4,2)
	VRO->VRO_USRUTI := __cUserID
	VRO->VRO_VLRUTI := nVlrUti
	MsUnLock()
EndIf
Return .t.

/*/{Protheus.doc} OA2000051_PosicaoCliente
	Visualiza a Posicao do Cliente

	@author Andre Luis Almeida
	@since 22/10/2020
/*/
Function OA2000051_PosicaoCliente()
If OA2000071_VerificaPermissaoUsuario("1",0)
	DBSelectArea("SA1")
	DBSetOrder(1)
	If DBSeek(xFilial("SA1")+VRO->VRO_CODCLI+VRO->VRO_LOJCLI)  
		FC010CON() // Tela de Consulta -> Posicao do Cliente
	EndIf
EndIf
Return

/*/{Protheus.doc} OA2000061_VerificaMotivo
	Verifica o Motivo da Solcitação de Credito para o Cliente

	@author Andre Luis Almeida
	@since 22/10/2020
/*/
Function OA2000061_VerificaMotivo()
If OA2000071_VerificaPermissaoUsuario("1",0)
	PutMv("MV_CKCLIXX","")
	DBSelectArea("VRO")
	FG_CKCLINI(VRO->VRO_CODCLI+VRO->VRO_LOJCLI,.t.,.t.)
EndIf
Return

/*/{Protheus.doc} OA2000071_VerificaPermissaoUsuario
	Verifica Permissao do Usuario

	@author Andre Luis Almeida
	@since 22/10/2020
/*/
Function OA2000071_VerificaPermissaoUsuario(cStatus,nVlr)
Local lRet       := .t.
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
If VAI->VAI_LIBCCD <> "1" // conteudo diferente de SIM
	MsgStop(STR0028,STR0015) // Usuário sem permissão! / Atenção
	lRet := .f.
Else
	If nVlr > 0 .and. cStatus == "1" // Tem Valor e esta Liberando
		If VAI->VAI_ALLCCD < nVlr
			MsgStop(STR0031+CHR(13)+CHR(10)+;
					STR0032+": "+Transform(VAI->VAI_ALLCCD,"@E 999,999,999.99")+CHR(13)+CHR(10)+;
					STR0033+": "+Transform(nVlr,"@E 999,999,999.99"),STR0015) // Usuário sem alçada! / Valor Permitido / Valor Solicitado / Atenção
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet