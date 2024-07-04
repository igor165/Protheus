#INCLUDE "CRMA020A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW	2 
#DEFINE TYPE_FORM_SOL_CONTAS  1          

Static lMVCRMUAZS := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Transferencia de contas entre os vendedores.

@sample		CRMA020A()

@param		Nenhum
@return		Nenhum

@author		Anderson Silva     
@since		19/09/2013 
@version	11.90               
/*/
//------------------------------------------------------------------------------
Function CRMA020A
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados da transferencia de contas entre os vendedores.

@sample		ModelDef() 

@param		Nenhum

@return		ExpO - Objeto MPFormModel

@author		Anderson Silva
@since		19/09/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	 	:= Nil
Local oStructVen	:= Nil
Local oStructCta	:= Nil
Local bCarga		:= {|| }
Local bLoad		:= {|| {} }
Local bPosValid	:= {|oModel| CRMA20APVd(oModel) }
Local bCommit		:= {|oModel| CRMA20APCommit(oModel) }
Local bActive		:= {|oModel| CRMA20AActive(oModel) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as estruturas fake ZYX / ZYZ do tipo model para receber os dados da transferencia de contas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructVen := FWFormModelStruct():New()
oStructVen:AddTable("ZYX",{},STR0001)					//"Dados para Transferencia"
MntScruct(oStructVen,"ZYX",TYPE_MODEL)

oStructCta := FWFormModelStruct():New()
oStructVen:AddTable("ZYZ",{},STR0002)					//"Contas"
MntScruct(oStructCta,"ZYZ",TYPE_MODEL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia o modelo de dados transferencia de contas entre os vendedores. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := MPFormModel():New("CRMA020A",/*bPreValidacao*/,bPosValid,bCommit,/*bCancel*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no modelo de dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddFields("TRFMASTER", /*cOwner*/,oStructVen,/*bPreValidacao*/,/*bPosValidacao*/,bCarga)
oModel:AddGrid("CONTASDET","TRFMASTER",oStructCta,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,bLoad)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura as propriedades do modelo de dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel("TRFMASTER"):SetOnlyQuery(.T.)

oModel:GetModel("CONTASDET"):SetOnlyQuery(.T.)
oModel:GetModel("CONTASDET"):SetOptional(.T.)
oModel:GetModel("CONTASDET"):SetNoInsertLine(.T.)
oModel:GetModel("CONTASDET"):SetNoDeleteLine(.T.)

oModel:GetModel("TRFMASTER"):SetDescription(STR0003)//"Transferencia"
oModel:GetModel("CONTASDET"):SetDescription(STR0004)//"Contas"
oModel:SetDescription(STR0005)//"Transferência de Contas"
oModel:SetActivate(bActive)
oModel:SetPrimaryKey({})          

Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20AActive

Bloco de ativação do model Transferencia de contas entre os vendedores.

@sample	CRMA20AActive(oModel)

@param		Nenhum
@return	Nenhum

@author	Anderson Silva     
@since		25/10/2016 
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function CRMA20AActive(oModel)

Local lPEActive := ExistBlock("CRM20AMDA")

If lPEActive
	ExecBlock("CRM20AMDA",.F.,.F.,{oModel})
EndIf  
 
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface da transferencia de contas entre os vendedores.

@sample		ViewDef()

@param		Nenhum

@return		ExpO - Objeto FWFormView

@author		Anderson Silva
@since		19/09/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView			:= Nil
Local oModel		:= FWLoadModel("CRMA020A")
Local oStructVen	:= Nil
Local oStructCta	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as estruturas fake ZYX / ZYZ do tipo view para receber os dados da transferencia de contas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructVen := FWFormViewStruct():New()
MntScruct(oStructVen,"ZYX",TYPE_VIEW)

oStructCta := FWFormViewStruct():New()
MntScruct(oStructCta,"ZYZ",TYPE_VIEW)

oStructVen:AddGroup("GRP_PROP_CONTA",STR0006,"",2)//"Proprietário da Conta"
oStructVen:AddGroup("GRP_VEND_DEST",STR0007,"",2)//"Transferir para:"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia a interface. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView := FWFormView():New()
oView:SetModel(oModel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no Model(Dados para Transferencia). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddField("VIEW_DADOS_TRANS",oStructVen,"TRFMASTER")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no ModelGrid (Contas). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_CONTA",oStructCta,"CONTASDET")
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fields Dados para Transferencia. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("DADOS_TRANSF",70)
oView:EnableTitleView("VIEW_DADOS_TRANS",STR0008) //"Dados para Transfêrencia:"
oView:SetOwnerView("VIEW_DADOS_TRANS","DADOS_TRANSF")
oView:ShowUpdateMsg(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid Contas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("CONTAS",30)
oView:EnableTitleView("VIEW_CONTA",STR0009)   //"Contas:"
oView:SetOwnerView("VIEW_CONTA","CONTAS") 

oView:AddUserButton(STR0126,"",{|oView| CRMA20ARFCI(oView) })   //"Replicar F.C.I"


Return( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntScruct

Monta a estrutura de dados do tipo Model / View.

@sample		MntScruct(oStruct,cAliasFake,nType)

@param		ExpO1 - Objeto FWFormModelStruct / FWFormViewStruct
			ExpC2 - Objeto Alias Fake
			ExpN3 - Tipo Model / View 
			
@return		ExpO - Objeto FWFormView

@author		Anderson Silva
@since		19/09/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function MntScruct(oStruct,cAliasFake,nType)

Local aDadosCpo	:= {}
Local aAuxTrig	:= {}

If nType == TYPE_MODEL
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual
	
	
	// Cabeçalho
	If cAliasFake == "ZYX"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos dados para transferencia. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosCpo := TxSX3Campo("A3_COD")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0010),"ZYX_CVPROP",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Código do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_NOME")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0011),"ZYX_NVPROP",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Nome do vendedor proprietário da conta"

		aDadosCpo := TxSX3Campo("A3_EMAIL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0012),"ZYX_EMPROP",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Email do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_DDDTEL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0013),"ZYX_DTPROP",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"DDD do telefone do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_TEL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0014),"ZYX_TLPROP",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Telefone do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_UNIDAD")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0015),"ZYX_UNPROP",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              //"Unidade de negócio do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_DSCUNID")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0016),"ZYX_DUPROP",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Descrição da unidade de negócio do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_COD")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0017),"ZYX_CODVEN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],FwBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SA3',FwFldGet('ZYX_CODVEN'),1) .AND. CRMA20AVdVP()"),Nil,Nil,.T.)//"Vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_NOME")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0018),"ZYX_NVEND",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Nome do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_EMAIL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0019),"ZYX_EMAIL",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Email do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_DDDTEL")
		oStruct:AddField(aDadosCpo[1],AllTrim(STR0020),"ZYX_DDDTEL",aDadosCpo[6],aDadosCpo[3]	,aDadosCpo[4])              	//"DDD do telefone do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_TEL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0021),"ZYX_TEL",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4] )              		//"Telefone do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_UNIDAD")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0022),"ZYX_UNIDAD",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Unidade de negócio do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_DSCUNID")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0023),"ZYX_DSCUNI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Descrição da unidade de negócio do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("AIM_CODMOT")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0024),"ZYX_CODMOT",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],FwBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SX5','AE'+FwFldGet('ZYX_CODMOT'))"),Nil,Nil,.T. )              	//"Motivo da transferência da conta"
		
		aDadosCpo := TxSX3Campo("AIM_DSCMOT")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0025),"ZYX_DSCMOT",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Descrição do motivo da transferência da conta"
		
		aDadosCpo := TxSX3Campo("AIM_OBSMOT")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0026),"ZYX_OBSMOT",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],Nil,Nil,Nil,.T.)              	//"Observações do motivo da transferência da conta"
				
		oStruct:AddField(STR0027,STR0028,"ZYX_EVMAIL","C",1,0,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMA20AVdE()"),Nil,{STR0029,STR0030},Nil,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'2'"),Nil,Nil,.T. )              	//"Env E-mail"//"Envia um e-mail para o vendedor que receberá a conta."//"1=Sim"//"2=Não"
				
		aAuxTrig := FwStruTrigger("ZYX_CODVEN","ZYX_NVEND",'AllTrim(Posicione("SA3",1,xFilial("SA3")+FwFldGet("ZYX_CODVEN"),"A3_NOME"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])
		
		aAuxTrig := FwStruTrigger("ZYX_CODVEN","ZYX_EMAIL",'AllTrim(Posicione("SA3",1,xFilial("SA3")+FwFldGet("ZYX_CODVEN"),"A3_EMAIL"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])
		
		aAuxTrig := FwStruTrigger("ZYX_CODVEN","ZYX_DDDTEL",'AllTrim(Posicione("SA3",1,xFilial("SA3")+FwFldGet("ZYX_CODVEN"),"A3_DDDTEL"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])
		
		aAuxTrig := FwStruTrigger("ZYX_CODVEN","ZYX_TEL",'AllTrim(Posicione("SA3",1,xFilial("SA3")+FwFldGet("ZYX_CODVEN"),"A3_TEL"))',.F.,Nil,Nil,Nil)                 
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])
		
		aAuxTrig := FwStruTrigger("ZYX_CODVEN","ZYX_UNIDAD",'AllTrim(Posicione("SA3",1,xFilial("SA3")+FwFldGet("ZYX_CODVEN"),"A3_UNIDAD"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])
	
		aAuxTrig := FwStruTrigger("ZYX_CODVEN","ZYX_DSCUNI",'Posicione("ADK",1,XFILIAL("ADK")+FwFldGet("ZYX_UNIDAD"),"ADK_NOME")',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])      
	
		aAuxTrig := FwStruTrigger("ZYX_CODMOT","ZYX_DSCMOT",'AllTrim(Posicione("SX5",1,xFilial("SX5")+"AE"+FwFldGet("ZYX_CODMOT"),"X5DESCRI()"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])      
		
	ElseIf cAliasFake == "ZYZ"
		
		aDadosCpo := TxSX3Campo("AIM_ENTIDA")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0031),"ZYZ_ENTIDA",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Entidade que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("AIM_NOMENT")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0032),"ZYZ_NOMENT",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Nome da entidade que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("AIM_CODCTA")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0033),"ZYZ_CODCTA",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Código da conta que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("AIM_LOJCTA")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0034),"ZYZ_LOJCTA",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Loja da conta que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("AIM_NOMCTA")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0035),"ZYZ_NOMCTA",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4] ) 				//"Nome da conta que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("A1_NREDUZ")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0036),"ZYZ_NREDUZ",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])    //"Nome reduzido da conta"
		
		aDadosCpo := TxSX3Campo("A1_PESSOA")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0037),"ZYZ_PESSOA",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])    //"Tipo de pessoa Física ou Jurídica"
		
		aDadosCpo := TxSX3Campo("A1_CGC")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0038),"ZYZ_CGC",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])    //"CNPJ ou CPF da conta"
		
		aDadosCpo := TxSX3Campo("A1_DDD")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0039),"ZYZ_DDD",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"DDD da Conta"
	
		aDadosCpo := TxSX3Campo("A1_TEL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0040),"ZYZ_TEL",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Telefone da Conta"
		
		aDadosCpo := TxSX3Campo("A1_EMAIL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0041),"ZYZ_EMAIL",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Email da Conta"
		
		aDadosCpo := TxSX3Campo("A1_EST")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0042),"ZYZ_EST",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Estado da Conta"
		
		aDadosCpo := TxSX3Campo("A1_MUN")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0043),"ZYZ_MUN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4]) //"Estado da Conta"
			
		oStruct:AddField(STR0044,STR0045,"ZYZ_NROPAB","N",2,0,Nil,Nil,;//"Oport. Aberta"//"Número de oportunidades em aberto."
					Nil,Nil,FwBuildFeature(STRUCT_FEATURE_INIPAD,"0"),Nil,Nil,.T.)   	
		
		oStruct:AddField(STR0046,STR0047,"ZYZ_ACOPOR","C",1,0,Nil,FwBuildFeature(STRUCT_FEATURE_VALID,'CRMA20AAOP()'),;//"Ação Oport."//"Define uma acao para as oportunidades de vendas em aberto."
		{STR0048,STR0049,STR0050},Nil,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'3'"),Nil,Nil,.T. )              	//"1=Transferir para o Vendedor"//"2=Encerrar como perdida"//"3=Sem Ação"
		
		aDadosCpo := TxSX3Campo("AIM_FCIOPO")
		oStruct:AddField(STR0127,STR0127,"ZYZ_FCIOPO",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],;//"F.C.I Oport."
		FwBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SX5','A6'+FwFldGet('ZYZ_FCIOPO'))"),;
		FwBuildFeature(STRUCT_FEATURE_WHEN,"IIF(FwFldGet('ZYZ_ACOPOR')=='2',.T.,.F.)"))      
		
		aDadosCpo := TxSX3Campo("AIM_DSCFCI")
   		oStruct:AddField(STR0128,STR0128,"ZYZ_DSCFCI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4]) //"Desc. F.C.I"
   		
		If ( AIM->(ColumnPos("AIM_CODTER")) .And. AIM->(ColumnPos("AIM_TPMEM")) .And. AIM->(ColumnPos("AIM_CODMEM")) )
			//Campos Território
			aDadosCpo := TxSX3Campo("AIM_CODTER")
			oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0142),"ZYZ_CODTER",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],Nil,Nil,Nil,.F.)	//"Código do Território"
			
			aDadosCpo := TxSX3Campo("AIM_TPMEM")
			oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0143),"ZYZ_TPMEM",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],Nil,Nil,Nil,.F.)		//"Tipo do Membro"
			
			aDadosCpo := TxSX3Campo("AIM_CODMEM")
			oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0144),"ZYZ_CODMEM",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],Nil,Nil,Nil,.F.)	//"Código do Membro"
		EndIf
		
   		aAuxTrig := FwStruTrigger("ZYZ_FCIOPO","ZYZ_DSCFCI",'AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+FwFldGet("ZYZ_FCIOPO"),"X5DESCRI()"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])  
		
		aAuxTrig := FwStruTrigger("ZYZ_ACOPOR","ZYZ_FCIOPO",'IIF(FwFldGet("ZYZ_ACOPOR") <> "2","",FwFldGet("ZYZ_FCIOPO"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])    
	    
	    aAuxTrig := FwStruTrigger("ZYZ_ACOPOR","ZYZ_DSCFCI",'IIF(FwFldGet("ZYZ_ACOPOR") <> "2","",FwFldGet("ZYZ_DSCFCI"))',.F.,Nil,Nil,Nil)
		oStruct:AddTrigger(aAuxTrig[1],aAuxTrig[2],aAuxTrig[3],aAuxTrig[4])    
		
		//"Indica qual será o tipo de transferencia 1=Aprovação Solicitação / 2=Aprovação Direta "	
		oStruct:AddField(STR0155,STR0156,"ZYZ_TPTRAN","C",1,0,Nil,Nil,{STR0157,STR0158},.F.,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'1'"),Nil,Nil,.T. )     //"Tipo Tranf."#"Indica tipo de transferência"#"1=Aprovação Solicitação"#"2=Aprovação Direta"    
		
		                                                                           
	EndIf                                     
	
ElseIf nType == TYPE_VIEW
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	
	If cAliasFake == "ZYX"
	
		aDadosCpo := TxSX3Campo("A3_COD")
		oStruct:AddField("ZYX_CVPROP","01",aDadosCpo[1],aDadosCpo[2],{STR0051},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil ,"GRP_PROP_CONTA")//"Vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_NOME")
		oStruct:AddField("ZYX_NVPROP","02",aDadosCpo[1],aDadosCpo[2],{STR0052},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_PROP_CONTA")//"Nome do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_EMAIL")
		oStruct:AddField("ZYX_EMPROP","03",aDadosCpo[1],aDadosCpo[2],{STR0053},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_PROP_CONTA"	 )//"Email do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_DDDTEL")
		oStruct:AddField("ZYX_DTPROP","04",aDadosCpo[1],aDadosCpo[2],{STR0054},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil,"GRP_PROP_CONTA")//"DDD do telefone do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_TEL")
		oStruct:AddField("ZYX_TLPROP","05",aDadosCpo[1]	,aDadosCpo[2],{STR0055},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_PROP_CONTA"	 )//"Telefone do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_UNIDAD")
		oStruct:AddField("ZYX_UNPROP","06",aDadosCpo[1],aDadosCpo[2],{STR0056},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_PROP_CONTA"	 )//"Unidade de negócio do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_DSCUNID")
		oStruct:AddField("ZYX_DUPROP","07",aDadosCpo[1],aDadosCpo[2],{STR0057},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_PROP_CONTA"	 )//"Descrição da unidade de negócio do vendedor proprietário da conta"
		
		aDadosCpo := TxSX3Campo("A3_COD")
		oStruct:AddField("ZYX_CODVEN","08",aDadosCpo[1],aDadosCpo[2],{STR0058},aDadosCpo[6],aDadosCpo[5],Nil,"SA3",.T.,Nil,"GRP_VEND_DEST")              //"Vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_NOME")
		oStruct:AddField("ZYX_NVEND","09",aDadosCpo[1],aDadosCpo[2],{STR0059},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_VEND_DEST" )             //"Nome do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_EMAIL")
		oStruct:AddField("ZYX_EMAIL","10",aDadosCpo[1],aDadosCpo[2],{STR0060},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_VEND_DEST" )              //"Email do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_DDDTEL")
		oStruct:AddField("ZYX_DDDTEL","11",aDadosCpo[1],aDadosCpo[2],{STR0061},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_VEND_DEST"  )          //"DDD do telefone do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_TEL")
		oStruct:AddField("ZYX_TEL","12",aDadosCpo[1],aDadosCpo[2],{STR0062},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_VEND_DEST" )              //"Telefone do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("A3_UNIDAD")
		oStruct:AddField("ZYX_UNIDAD","13",aDadosCpo[1],aDadosCpo[2],{STR0063},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_VEND_DEST" 	 )              //"Unidade de negócio do vendedor que receberá as contas"
	
		aDadosCpo := TxSX3Campo("A3_DSCUNID")
		oStruct:AddField("ZYX_DSCUNI","14",aDadosCpo[1],aDadosCpo[2],{STR0064},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_VEND_DEST"  )          //"Descrição da unidade de negócio do vendedor que receberá as contas"
		
		aDadosCpo := TxSX3Campo("AIM_CODMOT")
		oStruct:AddField("ZYX_CODMOT","15",aDadosCpo[1],aDadosCpo[2],{STR0065},aDadosCpo[6],aDadosCpo[5],Nil,"AE",.T.,Nil,"GRP_VEND_DEST"  )              //"Motivo da transferência da conta"
		
		aDadosCpo := TxSX3Campo("AIM_DSCMOT")
		oStruct:AddField("ZYX_DSCMOT","16",aDadosCpo[1],aDadosCpo[2],{STR0066},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_VEND_DEST"  )             //"Descrição do motivo da transferência da conta"
		
		aDadosCpo := TxSX3Campo("AIM_OBSMOT")
		oStruct:AddField("ZYX_OBSMOT","17",aDadosCpo[1],aDadosCpo[2],{STR0067},"M",aDadosCpo[5],Nil,"",.T.,Nil,"GRP_VEND_DEST" )          //"Observações do motivo da transferência da conta"
		                            
		oStruct:AddField("ZYX_EVMAIL","18",STR0068,STR0069,{STR0070},"C","@!",Nil,Nil,.T.,Nil,"GRP_VEND_DEST",{STR0071,STR0072} 	)             //"Env E-mail"//"Envia E-mail para o Vendedor"//"Envia um e-mail para o vendedor que receberá a conta."//"1=Sim"//"2=Não"
		
	ElseIf cAliasFake == "ZYZ"
		/*
		//Comentado o campo entidade para nao exibir para usuario. Caso haja necessidade descomentar
		aDadosCpo := TxSX3Campo("AIM_ENTIDA")
		oStruct:AddField("ZYZ_ENTIDA","01",aDadosCpo[1],aDadosCpo[2],{STR0073},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.)              //"Entidade que será transferida para o vendedor"
		*/
		
		aDadosCpo := TxSX3Campo("AIM_NOMENT")
		oStruct:AddField("ZYZ_NOMENT","02",aDadosCpo[1],aDadosCpo[2],{STR0074},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.  )             //"Nome da entidade que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("AIM_CODCTA")
		oStruct:AddField("ZYZ_CODCTA","03",aDadosCpo[1],aDadosCpo[2],{STR0075},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 		)             //"Código da conta que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("AIM_LOJCTA")
		oStruct:AddField("ZYZ_LOJCTA","04",aDadosCpo[1],aDadosCpo[2],{STR0076},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 		 )              		//"Loja da conta que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("AIM_NOMCTA")
		oStruct:AddField("ZYZ_NOMCTA","05",aDadosCpo[1]	,aDadosCpo[2],{STR0077},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 	) //"Nome da conta que será transferida para o vendedor"
		
		aDadosCpo := TxSX3Campo("A1_NREDUZ")
		oStruct:AddField("ZYZ_NREDUZ","06",aDadosCpo[1],aDadosCpo[2],{STR0078},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.)   //"Nome reduzido da conta"
		
		aDadosCpo := TxSX3Campo("A1_PESSOA")
		oStruct:AddField("ZYZ_PESSOA","07",aDadosCpo[1],aDadosCpo[2],{STR0079},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,Nil,{STR0080,STR0081,STR0135})//"Tipo de pessoa Fisíca ou Juridíca"//"F=Fisíca"//"J=Jurídica"//"CF=Fisíca"
		
		aDadosCpo := TxSX3Campo("A1_CGC")
		oStruct:AddField("ZYZ_CGC","08",aDadosCpo[1],aDadosCpo[2],{STR0082},aDadosCpo[6],aDadosCpo[5],FwBuildFeature(STRUCT_FEATURE_PICTVAR,"IIF(FwFldGet('ZYZ_PESSOA') $ 'F|CF','@R 999.999.999-99','@R 99.999.999/9999-99')"),Nil,.F.)//"CNPJ ou CGC da conta"
		
		aDadosCpo := TxSX3Campo("A1_DDD")
		oStruct:AddField("ZYZ_DDD","09",aDadosCpo[1],aDadosCpo[2],{STR0083},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 	) //"DDD da Conta"
		
		aDadosCpo := TxSX3Campo("A1_TEL")
		oStruct:AddField("ZYZ_TEL","10",aDadosCpo[1],aDadosCpo[2],{STR0084},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.)  //"Telefone da Conta"
		
		aDadosCpo := TxSX3Campo("A1_EMAIL")
		oStruct:AddField("ZYZ_EMAIL","11",aDadosCpo[1],aDadosCpo[2],{STR0085},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.) //"E-mail da Conta"
		
		aDadosCpo := TxSX3Campo("A1_EST")
		oStruct:AddField("ZYZ_EST","12",aDadosCpo[1],aDadosCpo[2],{STR0086},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 	) //"Estado da Conta"
		
		aDadosCpo := TxSX3Campo("A1_MUN")
		oStruct:AddField("ZYZ_MUN","13",aDadosCpo[1],aDadosCpo[2],{STR0087},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 	)  //"Município da Conta"
		
		oStruct:AddField("ZYZ_NROPAB","14",STR0088,STR0089,{STR0090},;//"Oport. Aberta"//"Nr. de Oport. Aberta"//"Número de oportunidades em aberto."
		"N","99",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)  
		
		oStruct:AddField("ZYZ_ACOPOR","15",STR0091,STR0092,{STR0093},;//"Ação Oport."//"Ação da Oportunidade"//"Define uma acao para as oportunidades de vendas em aberto."
		"C","@!",Nil,Nil,.T.,Nil,Nil,{STR0094,STR0095,STR0096}	)//"1=Transferir para Vendedor"//"2=Encerrar como perdida"//"3=Sem Ação"
		
	 	aDadosCpo := TxSX3Campo("AD1_FCI")
		oStruct:AddField("ZYZ_FCIOPO","16",STR0127,STR0129,{STR0130},; 
		aDadosCpo[6],aDadosCpo[5],Nil,"A6",.T.,Nil,Nil,Nil	) //"F.C.I Oport."//"Fator Crít. de Insucesso"//"Informa o fator crítico de insucesso para as oportunidades que serão encerradas."
		
		aDadosCpo := TxSX3Campo("AD1_DESFCI")
		oStruct:AddField("ZYZ_DSCFCI","17",STR0128,STR0131,{STR0132},;
		aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,Nil,Nil	) //"Desc. F.C.I"//"Desc. Fator Crít. de Ins."//"Descrição do fator crítico de insucesso para as oportunidades que serão encerradas."
		
		If ( AIM->(ColumnPos("AIM_CODTER")) .And. AIM->(ColumnPos("AIM_TPMEM")) .And. AIM->(ColumnPos("AIM_CODMEM")) )
			//Campos Território
			aDadosCpo := TxSX3Campo("AIM_CODTER")
			oStruct:AddField("ZYZ_CODTER","18",aDadosCpo[1]	,aDadosCpo[2],{STR0142},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 	)  //"Código do Território"
			
			aDadosCpo := TxSX3Campo("AIM_TPMEM")
			oStruct:AddField("ZYZ_TPMEM","19",aDadosCpo[1]	,aDadosCpo[2],{STR0143},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 	) //"Tipo do Membro"
			
			aDadosCpo := TxSX3Campo("AIM_CODMEM")
			oStruct:AddField("ZYZ_CODMEM","20",aDadosCpo[1]	,aDadosCpo[2],{STR0144},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F. 	) //"Código do Membro"
		EndIf
			
	EndIf
	
EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CRMA20APVd

Valida o formulario MVC antes gravacao.

@sample		CRMA20APVd( oModel )

@param		ExpO - Objeto FWFormModel

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		09/10/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function CRMA20APVd( oModel )

Local oMdlZYZ 		:= oModel:GetModel("CONTASDET")
Local lRetorno		:= .T.
Local nX				:= 0

For nX := 1 To oMdlZYZ:Length()
	oMdlZYZ:GoLine(nX)
	If oMdlZYZ:GetValue("ZYZ_ACOPOR") == "2" .AND. Empty(oMdlZYZ:GetValue("ZYZ_FCIOPO"))
		Help("",1,"HELP","CRMA20APVd",STR0133+cValToChar(nX)+STR0134,1)//"Na linha "//" informe um Fator Crítico de Insucesso."
		lRetorno := .F.                  
		Exit
	EndIf	
Next nX

Return(lRetorno)


//---------------------------------------------------------------------
/*/{Protheus.doc} CRMA20APCommit

Efetua o processamento da transferencia de contas entre os vendedores.

@sample	CRMA20APCommit( oModel )

@param		ExpO1 - Objeto MPFormModel

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		19/09/2013
@versison	11.90               
/*/
//------------------------------------------------------------------------------
Static Function CRMA20APCommit( oModel )
Local cTimeIni := Time() 
Processa({|| CRMA20ACommit( oModel )  },STR0146, "",.T.) //"Realizando a transferência contas...."
ApMsgInfo(STR0147 + ElapTime( cTimeIni, Time() ) + "." ) //"Tempo de processamento: "
Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} CRMA20ACommit

Efetua a gravacao da transferencia de contas entre os vendedores.

@sample	CRMA20ACommit( oModel )

@param		ExpO1 - Objeto MPFormModel

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		19/09/2013
@versison	11.90               
/*/
//------------------------------------------------------------------------------
Static Function CRMA20ACommit( oModel )

Local aArea			:= GetArea()
Local aAreaAD1		:= AD1->(GetArea())
Local aAreaAIN		:= AIN->(GetArea())
Local aAreaACH		:= ACH->(GetArea())
Local aAreaSUS 		:= SUS->(GetArea())
Local aAreaSA1 		:= SA1->(GetArea())
Local aAreaSA3		:= SA3->(GetArea())
Local aUserPaper	:= {}
Local oMdlZYX 		:= oModel:GetModel("TRFMASTER")
Local oMdlZYZ 		:= oModel:GetModel("CONTASDET")
Local cCodVenAnt	:= oMdlZYX:GetValue("ZYX_CVPROP") 
Local cCodVenAtu	:= oMdlZYX:GetValue("ZYX_CODVEN")
Local cCodMotivo	:= oMdlZYX:GetValue("ZYX_CODMOT")
Local cObsMotivo	:= oMdlZYX:GetValue("ZYX_OBSMOT")
Local cCodUser 		:= ""
Local cEntidad		:= ""
Local cCodCta		:= ""
Local cLojCta		:= ""
Local cCodVend		:= ""
Local lRetorno		:= .F.
Local lPECommit		:= ExistBlock("CRM20ACMT")
Local nX			:= 0
Local nLenZYZ		:= 0
Local cLogError		:= ""
Local cLogEntity	:= ""
Local cLine			:= Replicate( "-", 80 )
Local cRetTransf	:= ""
Local aErroAuto		:= {}
Local cErroAuto		:= ""
Local nI			:= 0
Local aErrorEnt		:= {}

Private lMsErroAuto	:= .F. 
Private lAutoErrNoFile	:= .T.

If lPECommit
	ExecBlock("CRM20ACMT", .F., .F., {"COMMITBEFORE",oModel} )	
EndIf

If lMVCRMUAZS == Nil  
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

IF lMVCRMUAZS
	cCodUser := CRMXCodUser()
Else
	cCodUser := RetCodUsr()
EndIf
	
If lMVCRMUAZS
	//Retorna codigo inteligente e o nivel da estrutura de negocio de acordo com
	//papel do usuario logado no sistema.
	aUserPaper	:= CRMXGetPaper()
	If !Empty( aUserPaper )
		cCodVend := aUserPaper[USER_PAPER_CODVEND]
		If !Empty( cCodVend )
			SA3->( DbSetOrder( 1 ) )//A3_FILIAL+A3_COD
			lRetorno := SA3->( DbSeek( xFilial("SA3")+ cCodVend ) )
		EndIf
	EndIf
Else
	SA3->( DbSetOrder( 7 ) )//A3_FILIAL+A3_CODUSR
	lRetorno := SA3->( DbSeek( xFilial("SA3") + cCodUser ) )
EndIf

If lRetorno
	
	SA3->( DbSetOrder( 1 ) )//A3_FILIAL+A3_COD
	// Transferencia Direta
	If SA3->A3_MODTRF == "1"
		
		nLenZYZ := oMdlZYZ:Length()
		
		ProcRegua( nLenZYZ )
		IncProc()
		
		For nX := 1 To nLenZYZ
		
			oMdlZYZ:GoLine(nX)
			
			//Incrementa a regua de processsamento...
			IncProc(STR0148 + AllTrim( oMdlZYZ:GetValue("ZYZ_NOMCTA") ) ) //"Transferindo a conta: "
			
			cEntidad := oMdlZYZ:GetValue("ZYZ_ENTIDA") 
			cCodCta  := oMdlZYZ:GetValue("ZYZ_CODCTA")
			cLojCta  := oMdlZYZ:GetValue("ZYZ_LOJCTA")
			
			cRetTransf := CRM20ATrfCta(oMdlZYX,oMdlZYZ)
			
			If !Empty( cRetTransf )
				
				cLogEntity 	+= cLine + CRLF
				cLogEntity 	+= STR0149	+ CRM20BEntName( oMdlZYZ:GetValue("ZYZ_ENTIDA") ) + CRLF 	//"Entidade: "
				cLogEntity 	+= STR0150	+ oMdlZYZ:GetValue("ZYZ_CODCTA") + CRLF 						//"Codigo: "
				cLogEntity 	+= STR0151	+ oMdlZYZ:GetValue("ZYZ_LOJCTA") + CRLF  						//"Loja: "
				cLogEntity		+= STR0152	+ AllTrim( oMdlZYZ:GetValue("ZYZ_NOMCTA") ) + CRLF  			//"Nome da Conta: "
				cLogEntity 	+= cLine 	+ CRLF
				cLogEntity 	+= STR0153	+ CRLF  //" ***** Inconsistência encontrada nesta entidade! ***** "
				cLogEntity		+= cRetTransf
				cLogEntity 	+= CRLF+CRLF	
				
				aAdd( aErrorEnt,{oMdlZYZ:GetValue("ZYZ_ENTIDA"),oMdlZYZ:GetValue("ZYZ_CODCTA"),oMdlZYZ:GetValue("ZYZ_LOJCTA")} )			

			EndIf
	
			
		Next nX
		
		If lRetorno
			If (oMdlZYX:GetValue("ZYX_EVMAIL") == "1")
				EnviaEmail(oMdlZYX,oMdlZYZ,SA3->A3_MODTRF,cEntidad,cCodCta,cLojCta,aErrorEnt)
			EndIf
		EndIf
		
	// Transferencia por solicitacao
	ElseIf SA3->A3_MODTRF == "2"
		
		nLenZYZ := oMdlZYZ:Length()
		ProcRegua( nLenZYZ )
		IncProc()
		
		For nX := 1 To nLenZYZ
			
			oMdlZYZ:GoLine(nX)
			
			cEntidad := oMdlZYZ:GetValue("ZYZ_ENTIDA") 
			cCodCta  := oMdlZYZ:GetValue("ZYZ_CODCTA")
			cLojCta  := oMdlZYZ:GetValue("ZYZ_LOJCTA")
							
			If oMdlZYZ:GetValue("ZYZ_TPTRAN") == "1" .Or. Empty( oMdlZYZ:GetValue("ZYZ_TPTRAN") )
				
				//Incrementa a regua de processsamento...
				IncProc(STR0148 + AllTrim( oMdlZYZ:GetValue("ZYZ_NOMCTA") ) ) //"Transferindo a conta: "
		
				aExecAuto := {{"AIM_ENTIDA",oMdlZYZ:GetValue("ZYZ_ENTIDA")	,Nil},;
								{"AIM_CODCTA",oMdlZYZ:GetValue("ZYZ_CODCTA"),Nil},;
								{"AIM_LOJCTA",oMdlZYZ:GetValue("ZYZ_LOJCTA"),Nil},;
								{"AIM_VENPRO",cCodVenAnt			   		,Nil},;
								{"AIM_VENSOL",cCodVenAtu				   	,Nil},;
								{"AIM_CODMOT",cCodMotivo					,Nil},;
								{"AIM_OBSMOT",cObsMotivo					,Nil},;
								{"AIM_DTSOL" ,MsDate()						,Nil},;
								{"AIM_HRSOL" ,SubStr(Time(),1,5)			,Nil},;
								{"AIM_NROPAB",oMdlZYZ:GetValue("ZYZ_NROPAB"),Nil},;
								{"AIM_ACOPOR",oMdlZYZ:GetValue("ZYZ_ACOPOR"),Nil}}

				If oMdlZYZ:GetValue("ZYZ_ACOPOR") == "2"
					aAdd(aExecAuto,{"AIM_FCIOPO",oMdlZYZ:GetValue("ZYZ_FCIOPO"),Nil})
				EndIf
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Abre a solicitacao da conta. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MSExecAuto( {|a,b,c| CRMA020C(/*cEntidad*/,/*cCodCta*/,/*cLojCta*/,/*cCodVend*/,a,b,c) },TYPE_FORM_SOL_CONTAS,MODEL_OPERATION_INSERT,aExecAuto)
				
				If lMsErroAuto
				
					cLogEntity	+= cLine + CRLF
					cLogEntity	+= STR0149	+ CRM20BEntName( oMdlZYZ:GetValue("ZYZ_ENTIDA") ) + CRLF 	//"Entidade: "
					cLogEntity	+= STR0150	+ oMdlZYZ:GetValue("ZYZ_CODCTA") + CRLF 						//"Codigo: "
					cLogEntity	+= STR0151	+ oMdlZYZ:GetValue("ZYZ_LOJCTA") + CRLF  						//"Loja: "
					cLogEntity	+= STR0152	+ AllTrim( oMdlZYZ:GetValue("ZYZ_NOMCTA") ) + CRLF  			//"Nome da Conta: "
					cLogEntity	+= cLine 	+ CRLF
					cLogEntity	+= STR0153	+ CRLF  //" ***** Inconsistência encontrada nesta entidade! ***** "
					
					aErroAuto := GetAutoGRLog()
					cErroAuto := ""
					
					For nI := 1 To Len(aErroAuto)
						cErroAuto += aErroAuto[nI]
					Next nI
					
					cLogEntity 	+= CRLF+CRLF
					
					aAdd( aErrorEnt,{oMdlZYZ:GetValue("ZYZ_ENTIDA"),oMdlZYZ:GetValue("ZYZ_CODCTA"),oMdlZYZ:GetValue("ZYZ_LOJCTA")} )				
				
				EndIf
				
			Else
			
				//Incrementa a regua de processsamento...
				IncProc(STR0148 + AllTrim( oMdlZYZ:GetValue("ZYZ_NOMCTA") ) ) //"Transferindo a conta: "
				
				cRetTransf := CRM20ATrfCta(oMdlZYX,oMdlZYZ)
			
				If !Empty( cRetTransf )
					
					cLogEntity	+= cLine + CRLF
					cLogEntity	+= STR0149	+ CRM20BEntName( oMdlZYZ:GetValue("ZYZ_ENTIDA") ) + CRLF 	//"Entidade: "
					cLogEntity	+= STR0150	+ oMdlZYZ:GetValue("ZYZ_CODCTA") + CRLF 						//"Codigo: "
					cLogEntity	+= STR0151	+ oMdlZYZ:GetValue("ZYZ_LOJCTA") + CRLF  						//"Loja: "
					cLogEntity	+= STR0152	+ AllTrim( oMdlZYZ:GetValue("ZYZ_NOMCTA") ) + CRLF  			//"Nome da Conta: "
					cLogEntity	+= cLine 	+ CRLF
					cLogEntity	+= STR0153	+ CRLF  //" ***** Inconsistência encontrada nesta entidade! ***** "
					cLogEntity	+= cRetTransf
					cLogEntity	+= CRLF+CRLF		
						
					aAdd( aErrorEnt,{oMdlZYZ:GetValue("ZYZ_ENTIDA"),oMdlZYZ:GetValue("ZYZ_CODCTA"),oMdlZYZ:GetValue("ZYZ_LOJCTA")} )
				
				EndIf
				
			EndIf
			
			
		Next nX
		
		If lRetorno
			If oMdlZYX:GetValue("ZYX_EVMAIL") == "1"
				EnviaEmail(oMdlZYX,oMdlZYZ,SA3->A3_MODTRF,oMdlZYZ:GetValue("ZYZ_ENTIDA"),oMdlZYZ:GetValue("ZYZ_CODCTA"),oMdlZYZ:GetValue("ZYZ_LOJCTA"),aErrorEnt)
			EndIf
		EndIf
		
	EndIf
	
EndIf

If !Empty( cLogEntity )
	
	cLogError += cLine + CRLF
	cLogError += STR0154 + CRLF //"LOG de Transferência de Contas"
	cLogError += cLogEntity
	
	CRMA950Viewer( cLogError )
	
EndIf

If lPECommit
	ExecBlock("CRM20ACMT", .F., .F., {"COMMITAFTER",oModel} )	
EndIf
	
RestArea(aAreaAD1)
RestArea(aAreaAIN)
RestArea(aAreaACH)
RestArea(aAreaSUS)
RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aArea)

Return( .T. ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} CRM20ATrfCta

Efetua a gravacao da transferencia de contas entre os vendedores.

@sample	CRM20ATrfCta( oMdlZYX, oMdlZYZ )

@param		oMdlZYX ,objeto	,Cabeçalho da Transferencia.
			oMdlZYZ ,objeto	,Conta selecionada para Transferencia. 

@return	lRetorno ,logico	,Verdadeiro / Falso se a transferencia foi concluida.

@author	Anderson Silva
@since		19/09/2013
@versison	11.90               
/*/
//------------------------------------------------------------------------------
Static Function CRM20ATrfCta( oMdlZYX, oMdlZYZ )

Local cCodVenAnt		:= oMdlZYX:GetValue("ZYX_CVPROP")
Local cCodVenAtu		:= oMdlZYX:GetValue("ZYX_CODVEN")
Local cCodMotivo		:= oMdlZYX:GetValue("ZYX_CODMOT")
Local cObsMotivo		:= oMdlZYX:GetValue("ZYX_OBSMOT")
Local cCodUnProp		:= oMdlZYX:GetValue("ZYX_UNPROP")
Local cCodUnAtu		:= oMdlZYX:GetValue("ZYX_UNIDAD")
Local cEntidad		:= oMdlZYZ:GetValue("ZYZ_ENTIDA") 
Local cCodCta			:= oMdlZYZ:GetValue("ZYZ_CODCTA")
Local cLojCta			:= oMdlZYZ:GetValue("ZYZ_LOJCTA")
Local cAcaoOpor		:= oMdlZYZ:GetValue("ZYZ_ACOPOR")
Local cCodFCI			:= oMdlZYZ:GetValue("ZYZ_FCIOPO")
Local nNrOptAbr		:= oMdlZYZ:GetValue("ZYZ_NROPAB")
Local aErroAuto		:= {}
Local nI				:= 0
Local cReturn			:= ""

Private lMsErroAuto 		:= .F.
Private lAutoErrNoFile	:= .T.

Begin Transaction 
					
	//Suspects
	If cEntidad == "ACH"
		aExecAuto := {{"ACH_CODIGO"	,cCodCta		,Nil},;
						{"ACH_LOJA"	,cLojCta		,Nil},;
						{"ACH_VEND"	,cCodVenAtu	,Nil}	}
		MSExecAuto( {|x,y| TMKA341(x,y) },aExecAuto,MODEL_OPERATION_UPDATE)
		//Prospects
	ElseIf cEntidad == "SUS"
		aExecAuto := {{"US_COD"		,cCodCta		,Nil},;
						{"US_LOJA"		,cLojCta		,Nil},;
						{"US_VEND"		,cCodVenAtu	,Nil}	}
		MSExecAuto( {|x,y| TMKA260(x,y) },aExecAuto,MODEL_OPERATION_UPDATE)
		//Clientes
	Else
		aExecAuto := {{"A1_COD"		,cCodCta		,Nil},;
						{"A1_LOJA"		,cLojCta		,Nil},;
						{"A1_VEND"		,cCodVenAtu	,Nil}	}
		MSExecAuto( {|x,y| MATA030(x,y) },aExecAuto,4)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Transfere ou encerra como perdida as oportunidades de venda em aberto das contas Suspects / Clientes. ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If !lMsErroAuto .And. cEntidad $ "SUS|SA1" .And. cAcaoOpor $ "1|2" .And. nNrOptAbr > 0
		CRMA20AOport(cEntidad,cCodCta,cLojCta,cAcaoOpor,cCodVenAnt,cCodVenAtu,cCodFCI)
	EndIf
		
	If !lMsErroAuto
		
		aExecAuto := {{"AIN_ENTIDA",cEntidad		,Nil},;
						{"AIN_CODCTA",cCodCta		,Nil},;
						{"AIN_LOJCTA",cLojCta		,Nil},;
						{"AIN_CODMOT",cCodMotivo		,Nil},;
						{"AIN_OBSMOT",cObsMotivo		,Nil},;
						{"AIN_VENDCS",cCodVenAnt		,Nil},;
						{"AIN_VENANT",cCodVenAnt		,Nil},;
						{"AIN_UNDANT",cCodUnProp		,Nil},;
						{"AIN_VENATU",cCodVenAtu		,Nil},;
						{"AIN_UNDATU",cCodUnAtu		,Nil}	}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Grava o Log de Transfer?cia de contas. ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		MSExecAuto( {|x,y| CRMA030(x,y) },aExecAuto,MODEL_OPERATION_INSERT)
	EndIf
	
	If lMsErroAuto
		DisarmTransaction()  
		aErroAuto := GetAutoGRLog()
		For nI := 1 To Len(aErroAuto)
			cReturn += aErroAuto[nI]
		Next nI
	EndIf

End Transaction 
			
Return( cReturn )

                                      
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20AVdVP

Verifica se o vendedor que recebera a conta nao e o proprietario. 

@sample	CRMA20AVdVP()

@param		Nenhum

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		23/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20AVdVP()

Local lRetorno 	:= .T.
Local oModel		:= FwModelActive()
Local oMdlZYX		:= oModel:GetModel("TRFMASTER") 
Local cCodVendP		:= oMdlZYX:GetValue("ZYX_CVPROP")
Local cUserProp		:= ""
Local cCodVendS		:= oMdlZYX:GetValue("ZYX_CODVEN")
Local cUserSol		:= ""
Local aUsrSup		:= {}
Local cCargoSup	:= SuperGetMV("MV_CRMCARS",.F.,"")

If cCodVendP == cCodVendS
	Help("",1,"HELP","CRMA020AVPRO",STR0097,1)//"Este vendedor já é o proprietário da conta!"
	lRetorno := .F.
// Vendedor esta no topo da estrutura de venda.
Else
	If lMVCRMUAZS == Nil  
		lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
	EndIf

	If ! lMVCRMUAZS
		cUserProp	:= Posicione("SA3",1,xFilial("SA3")+cCodVendP,"A3_CODUSR")
		cUserSol	:= Posicione("SA3",1,xFilial("SA3")+cCodVendS,"A3_CODUSR")
		If CRMXTopAdm(cUserProp, cUserSol)   
			Help("",1,"HELP","CRMA020AVPRO",STR0141,1)//"Este vendedor está no topo da estrutura de negócio."
			lRetorno := .F.
		EndIf 
	Else
		AZS->( DBSetOrder(4) )	
					
		If ( AZS->( DBSeek(xFilial("AZS") + cCodVendS ) ) ) .And. ! ( Empty( AZS->AZS_IDESTN ) )
			aUsrSup := CRMXREstrNeg( AZS->AZS_CODUSR, cCargoSup, "S", AZS->AZS_SEQUEN + AZS->AZS_PAPEL )
			If ( Len( aUsrSup ) == 0 )
				Help("",1,"HELP","CRMA020AVPRO",STR0141,1)//Não será possível transferir esta conta, pois o este vendedor é o superior imediato do proprietário da conta.
				lRetorno := .F.
			EndIf
		Else
			Help( "", 1, "HELP", "CRMA020AVPRO", STR0145, 1 )//"Este vendedor não pertence a uma estrutura de negócio."
			lRetorno := .F.
		EndIf
	EndIf			
EndIf
 
Return( lRetorno )   

//------------------------------------------------------------------------------
/*/{Protheus.doc} EnviaEmail

Dispara e-mail para o vendedores envolvido na transferencia das contas

@sample	EnviaEmail(oModel)

@param		ExpO1 - Dados da transferencia 
			ExpO2 - Contas 
			ExpC3 - Modo de Tranferencia
			ExpC4 - Entidade da conta que está sendo processada
			ExpC5 - Codigo da conta que está sendo processada
			ExpC6 - Loja da conta que está sendo processada
			ExpA7 - Entidades que tiveram erro na transferencia.

@return	    Nenhum

@author 	Thiago Tavares
@since		18/05/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function EnviaEmail(oMdlZYX,oMdlZYZ,cModTransf,cEntida,cCodigo,cLoja, aErrorEnt)

Local nX	  			:= 0
Local cFrom			:= ""
Local cTo	  			:= ""
Local cBody			:= "" 
Local nErrorEnt		:= 0
Local nLenGrid		:= 0
Local lSendMail		:= .F.

Default cEntida 		:= ""
Default cCodigo 		:= ""
Default cLoja   		:= ""
Default aErrorEnt		:= {}

// Transferencia direta
If cModTransf == "1"
	
	cBody := '<html>' + ;                                     
				'<head>' + ;
					'<style type="text/css">' + ;
						'td { font-family:verdana; font-size:12px}' + ; 
						'p  { font-family:verdana; font-size:12px}' + ; 
					'</style>' + ;
				'</head>' + ;
				'<body>' + ;
					'<p>'+STR0098 + AllTrim(oMdlZYX:GetValue("ZYX_NVEND")) + ', </p>' + ;//"Caro(a) "
					'<p>'+STR0099 + oMdlZYX:GetValue("ZYX_NVPROP") + STR0100+'<br>' + ;//"O(A) vendedor(a) "//"está lhe tranferindo as contas de venda:"
					STR0101 + oMdlZYX:GetValue("ZYX_CODMOT") + ' - ' + AllTrim(Posicione("SX5",1,xFilial("SX5")+"AE"+oMdlZYX:GetValue("ZYX_CODMOT"),"X5DESCRI()")) +'<br>'+; //"Motivo: "
	                STR0102+ IIF(Empty(oMdlZYX:GetValue("ZYX_OBSMOT")), cBody += "<br>", cBody += AllTrim(oMdlZYX:GetValue("ZYX_OBSMOT")) + "<br>")//"Observaçoes: "
	
	cBody +=		STR0103+'(' + AllTrim(oMdlZYX:GetValue("ZYX_DTPROP")) + ')' + oMdlZYX:GetValue("ZYX_TLPROP") + '<br>' + ;//"Contato: "
					STR0104 + oMdlZYX:GetValue("ZYX_UNPROP") + ' - ' + oMdlZYX:GetValue("ZYX_DUPROP") + '</p>' + ;//"Unidade: "
					'<table cellpadding="2" width="100%">' + ;
						'<tr>' + ;
							'<td colspan="12" align="center" bgcolor="#08364D">' + ;
								'<span style="color:white;font-size:15px;"><b>'+STR0105+'<b></span>' + ;//"Transferência de Contas"
							'</td>' + ;
						'</tr>' + ;
						'<tr bgcolor="#EDEDED">' + ;
							'<td align="center">'+STR0106+'</td>' + ;//"Entidade"
							'<td align="center">'+STR0107+'</td>' + ;//"Nome da Entidade"
							'<td align="center">'+STR0108+'</td>' + ;//"Código"
							'<td align="center">'+STR0109+'</td>' + ;//"Loja"
							'<td align="center">'+STR0110+'</td>' + ;//"Nome"
							'<td align="center">'+STR0111+'</td>' + ; //"Nome Fantasia"
							'<td align="center">'+STR0112+'</td>' + ;  //"Pessoa"
							'<td align="center">'+STR0113+'</td>' + ;//"CNPJ/CPF"
							'<td align="center">'+STR0114+'</td>' + ;  //"Telefone"
							'<td align="center">'+STR0115+'</td>' + ;  //"E-mail"
							'<td align="center">'+STR0116+'</td>' + ; //"Estado"
							'<td align="center">'+STR0117+'</td>' + ;//"Municipio"
						'</tr>'
	
	
	nLenGrid := oMdlZYZ:Length()
	For nX := 1 To nLenGrid
			
		IIF(nX % 2 == 0, cBgColor := "#B3CBE7", cBgColor := "#FFFFFF") 
					
		oMdlZYZ:GoLine(nX)
		
		nErrorEnt := aScan( aErrorEnt, {|x| x[1] == oMdlZYZ:GetValue("ZYZ_ENTIDA") .And. x[2] == oMdlZYZ:GetValue("ZYZ_CODCTA") .And. x[3] == oMdlZYZ:GetValue("ZYZ_LOJCTA") } )
		
		If nErrorEnt == 0
			lSendMail := .T.
			cBody +=		'<tr bgcolor="' + cBgColor + '">' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_ENTIDA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_NOMENT") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_CODCTA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_LOJCTA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_NOMCTA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_NREDUZ") + '</td>' + ;
								'<td align="center">' + IIF(oMdlZYZ:GetValue("ZYZ_PESSOA")=="F",STR0118,IIF(oMdlZYZ:GetValue("ZYZ_PESSOA")=="J",STR0119,"")) + '</td>' + ;//"Fisica"//"Juridica"
								'<td align="center">' + Transform(oMdlZYZ:GetValue("ZYZ_CGC"),IIF(oMdlZYZ:GetValue("ZYZ_PESSOA") $ "F|CF","@R 999.999.999-99","@R 99.999.999/9999-99"))  + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_DDD") + "-" + oMdlZYZ:GetValue("ZYZ_TEL") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_EMAIL") + '</td>' + ; 
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_EST") + '</td>' + ;  
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_MUN") + '</td>' + ;
							'</tr>'
		EndIf
			 Next nX 
			 
	cBody +=			'<tr>' + ;
							'<td colspan="12" align="center" bgcolor="#08364D">' + ;
								'<span style="color:white;font-size:10px;"><b>'+STR0120+'<b></span>' + ;//"TOTVS S.A. - TODOS OS DIREITOS RESERVADOS"
							'</td>' + ;
						'</tr>' + ;
						'<tr><td colspan="12" align="center">'+STR0121+'</td></tr>' + ;//"Mensagem automática favor não responder."
					'</table>' + ;
				'</body>' + ;
			'</html>'
	
ElseIf cModTransf == "2"  

	cBody := '<html>' + ;                                     
				'<head>' + ;
					'<style type="text/css">' + ;
						'td { font-family:verdana; font-size:12px}' + ; 
						'p  { font-family:verdana; font-size:12px}' + ; 
					'</style>' + ;
				'</head>' + ;
				'<body>' + ;
					'<p>'+ STR0098 + AllTrim(oMdlZYX:GetValue("ZYX_NVEND")) + ', </p>' + ;//"Caro(a) "
					'<p>'+ STR0099 + oMdlZYX:GetValue("ZYX_NVPROP") + STR0136 +'<br>' + ;//"O(A) vendedor(a) "// "abriu uma solicitação de transferência de contas, por favor aguarde o processo de liberação."
					STR0101 + oMdlZYX:GetValue("ZYX_CODMOT") + ' - ' + AllTrim(Posicione("SX5",1,xFilial("SX5")+"AE"+oMdlZYX:GetValue("ZYX_CODMOT"),"X5DESCRI()")) +'<br>'+; //"Motivo: "
	                STR0102 + IIF(Empty(oMdlZYX:GetValue("ZYX_OBSMOT")), cBody += "<br>", cBody += AllTrim(oMdlZYX:GetValue("ZYX_OBSMOT")) + "<br>")//"Observaçoes: "
	
	cBody +=		STR0103 +'(' + AllTrim(oMdlZYX:GetValue("ZYX_DTPROP")) + ')' + oMdlZYX:GetValue("ZYX_TLPROP") + '<br>' + ;//"Contato: "
					STR0104 + oMdlZYX:GetValue("ZYX_UNPROP") + ' - ' + oMdlZYX:GetValue("ZYX_DUPROP") + '</p>' + ;//"Unidade: "
					'<table cellpadding="2" width="100%">' + ;
						'<tr>' + ;
							'<td colspan="12" align="center" bgcolor="#08364D">' + ;
								'<span style="color:white;font-size:15px;"><b>'+STR0137+'<b></span>' + ;//"Solicitação de Transferência de Contas"
							'</td>' + ;
						'</tr>' + ;
						'<tr bgcolor="#EDEDED">' + ;
							'<td align="center">'+STR0106+'</td>' + ;//"Entidade"
							'<td align="center">'+STR0107+'</td>' + ;//"Nome da Entidade"
							'<td align="center">'+STR0108+'</td>' + ;//"Código"
							'<td align="center">'+STR0109+'</td>' + ;//"Loja"
							'<td align="center">'+STR0110+'</td>' + ;//"Nome"
							'<td align="center">'+STR0111+'</td>' + ; //"Nome Fantasia"
							'<td align="center">'+STR0112+'</td>' + ; //"Pessoa"
							'<td align="center">'+STR0113+'</td>' + ;//"CNPJ/CPF"
							'<td align="center">'+STR0114+'</td>' + ;  //"Telefone"
							'<td align="center">'+STR0115+'</td>' + ;  //"E-mail"
							'<td align="center">'+STR0116+'</td>' + ; //"Estado"
							'<td align="center">'+STR0117+'</td>' + ;//"Municipio"
						'</tr>'
						
	nLenGrid := oMdlZYZ:Length()   
	For nX := 1 To nLenGrid
	
		IIF(nX % 2 == 0, cBgColor := "#B3CBE7", cBgColor := "#FFFFFF") 
					
		oMdlZYZ:GoLine(nX)
		
		nErrorEnt := aScan( aErrorEnt, {|x| x[1] == oMdlZYZ:GetValue("ZYZ_ENTIDA") .And. x[2] == oMdlZYZ:GetValue("ZYZ_CODCTA") .And. x[3] == oMdlZYZ:GetValue("ZYZ_LOJCTA") } )
	
		If nErrorEnt == 0
			lSendMail := .T.
			cBody +=		'<tr bgcolor="' + cBgColor + '">' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_ENTIDA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_NOMENT") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_CODCTA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_LOJCTA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_NOMCTA") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_NREDUZ") + '</td>' + ;
								'<td align="center">' + IIF(oMdlZYZ:GetValue("ZYZ_PESSOA")=="F",STR0118,IIF(oMdlZYZ:GetValue("ZYZ_PESSOA")=="J",STR0119,"")) + '</td>' + ;//"Fisica"//"Juridica"
								'<td align="center">' + Transform(oMdlZYZ:GetValue("ZYZ_CGC"),IIF(oMdlZYZ:GetValue("ZYZ_PESSOA") $ "F|CF","@R 999.999.999-99","@R 99.999.999/9999-99"))  + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_DDD") + "-" + oMdlZYZ:GetValue("ZYZ_TEL") + '</td>' + ;
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_EMAIL") + '</td>' + ; 
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_EST") + '</td>' + ;  
								'<td align="center">' + oMdlZYZ:GetValue("ZYZ_MUN") + '</td>' + ;
							'</tr>'
		EndIf

	Next nX 
		 
	cBody +=			'<tr>' + ;
						'<td colspan="12" align="center" bgcolor="#08364D">' + ;
							'<span style="color:white;font-size:10px;"><b>'+STR0120+'<b></span>' + ;//"TOTVS S.A. - TODOS OS DIREITOS RESERVADOS"
						'</td>' + ;
					'</tr>' + ;
					'<tr><td colspan="12" align="center">'+STR0121+'</td></tr>' + ;//"Mensagem automática favor não responder."
				'</table>' + ;
			'</body>' + ;
		'</html>'
			
EndIf

If lSendMail
	cFrom := Lower(oMdlZYX:GetValue("ZYX_EMPROP"))
	cTo	  := Lower(oMdlZYX:GetValue("ZYX_EMAIL"))     	 
	/*Transferencia em lote Referente A da Atividade ficara em branco.
	*/
	If nLenGrid > 1
		cEntida 	:= ""
		cCodigo	:= ""
		cLoja		:= ""	
	EndIf
	                
	CRM170EMAI(cFrom, cTo,"","",STR0122,cBody,cEntida,cCodigo,cLoja)//"Transferência de Conta"
EndIf

Return Nil 
                                    
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20AOport

Transfere a oportunidade para o vendedor atual da conta ou encerra a mesma como
perdida.

@sample	CRMA20AOport(cEntidad,cCodCta,cLojCta,cAcaoOpor,cCodVenAtu,cCodFCI)

@param		ExpC1 - Entidade da conta
			ExpC2 - Codigo da conta
			ExpC3 - Loja da conta 
			ExpC4 - Acao Transferir / Encerrar a oportunidade
			ExpC5 - Vendedor anterior da conta
			ExpC6 - Vendedor atual da conta
			ExpC7 - Codigo do Fator Critico de Insucesso
			
@return	    Nenhum

@author		Anderson Silva
@since		23/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20AOport(cEntidad,cCodCta,cLojCta,cAcaoOpor,cCodVenAnt,cCodVenAtu,cCodFCI)

Local aArea 		:= GetArea()
Local aAreaAD1 		:= AD1->(GetArea())
Local cQuery 		:= ""
Local cAlias		:= GetNextAlias()  
Local aCabecAD1		:= {}

Default cEntidad	:= ""
Default cCodCta		:= ""
Default cLojCta		:= ""
Default cAcaoOpor	:= ""
Default cCodVenAnt	:= ""
Default cCodVenAtu	:= ""
Default cCodFCI		:= ""

DbSelectArea("AD1")
DbSetOrder(1)//AD1_FILIAL+AD1_NROPOR+AD1_REVISA                                                                                                                                
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Total da oportunidade por conta   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=   "SELECT AD1_FILIAL, AD1_NROPOR, AD1_REVISA "
cQuery +=   "  FROM "+RetSqlName("AD1")+" AD1 "
cQuery +=   " WHERE AD1.AD1_FILIAL = '"+xFilial("AD1")+"' "
If cEntidad == "SUS"
	cQuery +=	" 	AND AD1.AD1_PROSPE = '"+cCodCta+"' "
	cQuery +=	" 	AND AD1.AD1_LOJPRO = '"+cLojCta+"' "
Else
	cQuery +=	" 	AND AD1.AD1_CODCLI = '"+cCodCta+"' "
	cQuery +=	" 	AND AD1.AD1_LOJCLI = '"+cLojCta+"' "
EndIf                                                   
cQuery +=	"  AND AD1.AD1_VEND	  = '"+cCodVenAnt+"' " 
cQuery += 	"  AND AD1.AD1_STATUS = '1'  "
cQuery +=  	"  AND AD1.D_E_L_E_T_ = ' ' "
	
IIF(Select(cAlias)>0,(cAlias)->(DbCloseArea()),Nil)
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While (cAlias)->(!Eof())

	If AD1->(DbSeek((cAlias)->AD1_FILIAL+(cAlias)->AD1_NROPOR+(cAlias)->AD1_REVISA))

		//Transfere para vendedor ou encerra a oportunidade como perdida.
		If cAcaoOpor == "1"
			aCabecAD1 := {{"AD1_FILIAL", (cAlias)->AD1_FILIAL, Nil},;
			              {"AD1_NROPOR", (cAlias)->AD1_NROPOR, Nil},;
			              {"AD1_REVISA", (cAlias)->AD1_REVISA, Nil},;
			              {"AD1_VEND",   cCodVenAtu,           Nil}}	
		Else 
			aCabecAD1 := {{"AD1_FILIAL", (cAlias)->AD1_FILIAL, Nil},;
			              {"AD1_NROPOR", (cAlias)->AD1_NROPOR, Nil},;
			              {"AD1_REVISA", (cAlias)->AD1_REVISA, Nil},;
			              {"AD1_FCI",    cCodFCI,              Nil},;
			              {"AD1_STATUS", "2",                  Nil}}
		EndIf

		FATA300(MODEL_OPERATION_UPDATE,aCabecAD1)     

	EndIf
	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

RestArea(aAreaAD1)
RestArea(aArea)

FreeObj(aAreaAD1)
FreeObj(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20AVdE

Valida o campo ZYX_EMAIL existe um e-mail cadastrado para notificar o vendedor.

@sample	    CRMA20AVdE()

@param		Nenhum

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20AVdE()

Local lRetorno := .T. 

If FwFldGet("ZYX_EVMAIL") == "1" .AND. Empty(FwFldGet("ZYX_EMAIL"))
	Help("",1,"HELP","CRMA20AAOP",STR0123,1)//"Vendedor não possui e-mail cadastrado!"
	lRetorno := .F. 	
EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20AAOP

Valida o campo ZYZ_ACOPOR para determinar uma acao que sera efetuada para as
contas com oportunidades em aberto.

@sample	CRMA20AAOP()

@param		Nenhum

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20AAOP()

Local lRetorno := .T.

If Pertence("123")
	If FwFldGet("ZYZ_ACOPOR") $ "1|2" .AND. FwFldGet("ZYZ_NROPAB") == 0
		Help("",1,"HELP","CRMA20AAOP",STR0124,1)	//"Esta ação só poderá ser alterada para contas (Prospects / Clientes) com oportunidades de venda em aberto."
		lRetorno := .F.
	ElseIf FwFldGet("ZYZ_ACOPOR") == "3" .AND. FwFldGet("ZYZ_NROPAB") > 0
		Help("",1,"HELP","CRMA20AAOP",STR0125,1)	//"Esta ação não poderá ser utilizada para contas (Prospects / Clientes) com oportunidades de venda em aberto."
		lRetorno := .F.	
	EndIf
Else
	lRetorno := .F.
EndIf

Return( lRetorno )  

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20ARFCI

Replica o fator de critico de insucesso para contas.

@sample	    CRMA20ARFCI()

@param		Nenhum

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20ARFCI()          

Local oModel 		:= FwModelActive()
Local oMdlZYZ 	:= oModel:GetModel("CONTASDET") 
Local lRetorno	:= .F.  
Local nX			:= 0
Local cCodFCI		:= oMdlZYZ:GetValue("ZYZ_FCIOPO")
Local cDescFCI	:= ""
                                                    
If !Empty(cCodFCI)  

	cDescFCI := Upper(AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+cCodFCI,"X5DESCRI()")))
	
	lRetorno := MsgYesNo(STR0138 +cCodFCI+" / "+ cDescFCI + STR0139,STR0005) //"Deseja replicar este Fator Crítico de Insucesso "//" para todas as contas durante o encerramento de oportunidade?" //"Transferença de Contas"
						  			
	If lRetorno
		nLinha  := oMdlZYZ:GetLine()  
		For nX := 1 To oMdlZYZ:Length()
			If nLinha <> nX .AND. oMdlZYZ:GetValue("ZYZ_ACOPOR") == "2"
				oMdlZYZ:GoLine(nX)
				oMdlZYZ:SetValue("ZYZ_FCIOPO",cCodFCI)
			EndIf
		Next nX
		oMdlZYZ:GoLine(nLinha)
	EndIf  
	
Else
	MsgAlert(STR0140,STR0005)//"Selecione uma conta com Fator Crítico de Insucesso para replicar."//"Transferença de Contas"
	lRetorno := .F.
EndIf
						   
Return( lRetorno ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM20BEntName

Retorna o nome da entidade.

@sample	CRM20BEntName( cEntity )

@param		cEntity 	 	, caracter, Entidade.

@return	cEntityName	, caracter, Nome da Entidade.

@author	Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function CRM20BEntName( cEntity )

Local cEntityName := ""

If cEntity == "ACH"
	cEntityName := STR0159 //"Suspect"
ElseIf cEntity == "SUS"
	cEntityName := STR0160 //"Prospect"
Else
	cEntityName := STR0161 //"Cliente"
EndIf

Return( cEntityName )