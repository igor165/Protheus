#INCLUDE "CRMA020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"

Static lMVCRMUAZS := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA020

Chamada para rotina de transferencia de contas em MVC - Model View Controller,
verifica tambem se o vendedor que esta acessando essa rotina tem autorizacao.

@sample	CRMA020()

@param		Nenhum

@return		Nenhum

@author		Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA020()

Local aArea	 		:= GetArea()
Local aAreaSA3 		:= SA3->(GetArea())
Local aUserPaper	:= {}
Local cCodUser 		:= ""
Local cCodVend		:= ""
Local cSeqPaper		:= ""
Local cIdEstN	 	:= ""
Local nNvEstN  		:= 0
Local lRetorno 		:= .F.

If FATPDUserAcc()  

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
			
			cCodUser 	:= aUserPaper[USER_PAPER_CODUSR]
			cCodVend	:= aUserPaper[USER_PAPER_CODVEND]
			cIdEstN 	:= aUserPaper[USER_PAPER_IDESTN]
			nNvEstN 	:= aUserPaper[USER_PAPER_NVESTN]
			cSeqPaper	:= aUserPaper[USER_PAPER_SEQUEN] + aUserPaper[USER_PAPER_CODPAPER]	
			
			If !Empty( cCodVend )
				SA3->( DbSetOrder( 1 ) )//A3_FILIAL+A3_COD
				lRetorno := SA3->( DbSeek( xFilial("SA3")+ cCodVend ) )			
			Else	
				ApMsgAlert(STR0006,STR0005)//"Este usuário não esta associado a nenhum vendedor!"#"Atenção"	
			EndIf 
		
		Else
			ApMsgAlert(STR0072,STR0005)//"Não foi possível identificar o papel deste usuário!"#"Atenção"
		EndIf
		
	Else
		
		SA3->( DbSetOrder( 7 ) )//A3_FILIAL+A3_CODUSR
		lRetorno := SA3->( DbSeek( xFilial("SA3") + cCodUser ) )

		If lRetorno
			If nModulo == 73
				DbSelectArea("AO3")
				DbSetOrder(1)		// AO3_FILIAL+AO3_CODUSR
				If AO3->(DbSeek(xFilial("AO3")+cCodUser))
					cIdEstN := AO3->AO3_IDESTN
					nNvEstN := AO3->AO3_NVESTN
				EndIf 	
			Else
				cIdEstN := SA3->A3_NVLSTR
				nNvEstN := SA3->A3_NIVEL		
			EndIf
		Else
			ApMsgAlert(STR0006,STR0005)//"Este usuário não esta associado a nenhum vendedor!"#"Atenção"	
		EndIf
			
	EndIf

	If lRetorno
		If SA3->A3_MODTRF $ "1|2"
			//Posiciona no indice do codigo do vendedor.
			SA3->( DbSetOrder(1) )//A3_FILIAL+A3_COD
			FwMsgRun(,{|| CRM020ExecT(SA3->A3_COD, cIdEstN, nNvEstN, cCodUser, cSeqPaper) },Nil,STR0001)//"Aguarde..."  #"Aguarde
		Else
			ApMsgAlert(STR0003,STR0004)//"Este vendedor não tem permissão para acessar a rotina de transferência de conta!"//"Atenção"
		EndIf
	EndIf	
					
	RestArea(aAreaSA3)  
	RestArea(aArea)

EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020ExecT

Executa a rotina de transferencia de contas em MVC - Model View Controller.

@sample		CRM020ExecT()

@param 		ExpC1 Codigo do vendedor logado no CRM.
			ExpN2 Nivel que vendedor que esta na estrutura de negocio.
			ExpC3 Codigo inteligente da estrutura de negocio.            

@return	Nenhum

@author	Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020ExecT(cCodVend,	cIdEstN, nNvEstN, cCodUser, cSeqPaper) 

Local oModel			:= Nil
Local oView	 		:= Nil
Local aTimeVend 		:= {}
Local oExecView 		:= Nil
Local aButtons 		:= {}
Local aUsersSub		:= {}
Local nX				:= 0
Local nPosVend		:= 0

Default cCodVend	:= ""
Default cIdEstN	:= ""
Default nNvEstN	:= 0
Default cCodUser	:= ""
Default cSeqPaper	:= ""
	
//Verifica se há vendedores subordinados do vendedor logado no CRM.
If !Empty(cIdEstN) .And. nNvEstN > 0
	If lMVCRMUAZS
		aUsersSub := CRMXREstrNeg(cCodUser,/*cCargoSup*/,"I", cSeqPaper) 
		For nX := 1 To Len(aUsersSub)
			If !Empty( aUsersSub[nX][10] )
				nPosVend := aScan( aTimeVend, {|x| x == aUsersSub[nX][10]} )
				If nPosVend == 0
					aAdd(aTimeVend,aUsersSub[nX][10])	
				EndIf
			EndIf
		Next nX
	Else
		aTimeVend := Ft520Sub(cIdEstN)      	
	EndIf 
EndIf
	
//Adiciona o vendedor logado no CRM
nPosVend := aScan( aTimeVend, {|x| x == cCodVend } )
If nPosVend == 0
	aAdd(aTimeVend,cCodVend)        
EndIf
			
//Ordenação por Código
aSort(aTimeVend) 

oModel := FWLoadModel("CRMA020")
oModel:GetModel("SA3DETAIL"):bLoad := {|oMdlSA3| CRM020LdVend(oMdlSA3,aTimeVend) } 
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
	
oView := FWLoadView("CRMA020")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_UPDATE)
	
//Adiciona o botao de transferir;
aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					{.T.,STR0010},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
oExecView := FWViewExec():New()
oExecView:SetTitle( STR0010 ) //Transferir
oExecView:SetSource( "CRMA020" )
oExecView:SetOK({|| CRM020VldForm( oModel, oView ) })
oExecView:SetModal( .F. )
oExecView:SetOperation( MODEL_OPERATION_UPDATE )
oExecView:SetModel( oModel )
oExecView:SetView(oView)
oExecView:SetButtons(aButtons)
oExecView:OpenView( .F. )
oExecView:DeActivate()

Return Nil   

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados da Transferencia de Contas.

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
Local cCampo		:= ""
Local cCpoSA3	 	:= "A3_FILIAL|A3_COD|A3_NOME|A3_EMAIL|A3_DDDTEL|A3_TEL|A3_GRPREP|A3_DSCGRP|A3_UNIDAD|A3_DSCUNID|"
Local cCpoACH	 	:= "ACH_FILIAL|ACH_CODIGO|ACH_LOJA|ACH_RAZAO|ACH_NFANT|ACH_TIPO|ACH_PESSOA|ACH_CGC|ACH_VEND|ACH_EST|ACH_CIDADE|ACH_DDD|ACH_TEL|ACH_EMAIL|ACH_STATUS|ACH_DTCAD|ACH_HRCAD|ACH_DTCONV|ACH_HRCONV|ACH_CODTER|ACH_TPMEM|ACH_CODMEM|"
Local cCpoSUS	 	:= "US_FILIAL|US_COD|US_LOJA|US_NOME|US_NREDUZ|US_TIPO|US_TPESSOA||US_CGC|US_VEND|US_EST|US_MUN|US_DDD|US_TEL|US_EMAIL|US_STATUS|US_DTCAD|US_HRCAD|US_DTCONV|US_HRCONV|US_CODTER|US_TPMEMB|US_CODMEMB|"
Local cCpoSA1	 	:= "A1_FILIAL|A1_COD|A1_LOJA|A1_NOME|A1_NREDUZ|A1_TIPO|A1_PESSOA|A1_CGC|A1_VEND|A1_EST|A1_MUN|A1_DDD|A1_TEL|A1_EMAIL|A1_DTCAD|A1_HRCAD|A1_CODTER|A1_TPMEMB|A1_CODMEMB|"
Local bAvCpoSA3  	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoSA3 }
Local bAvCpoACH	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoACH }
Local bAvCpoSUS	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoSUS }		
Local bAvCpoSA1	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoSA1 }
Local oStructFke	:= FWFormModelStruct():New()
Local oStructSA3	:= FWFormStruct(1,"SA3",bAvCpoSA3,/*lViewUsado*/)  
Local oStructACH	:= FWFormStruct(1,"ACH",bAvCpoACH,/*lViewUsado*/)
Local oStructSUS	:= FWFormStruct(1,"SUS",bAvCpoSUS,/*lViewUsado*/)
Local oStructSA1	:= FWFormStruct(1,"SA1",bAvCpoSA1,/*lViewUsado*/)
Local bCarga 		:= {|| {xFilial("SA3")} }


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira a obrigatoriedade dos campos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructACH:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
oStructSUS:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
oStructSA1:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

//----------Estrutura do campo tipo Model----------------------------

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo filial da tabela fake. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructFke:AddField(STR0011,STR0012,"ZFK_FILIAL","C",FwSizeFilial(),0)//"Filial"//"Filial do Sistema"

oStructACH:SetProperty("*",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,""))
oStructSUS:SetProperty("*",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,""))
oStructSA1:SetProperty("*",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,""))

oStructACH:SetProperty("*",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,""))
oStructSUS:SetProperty("*",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,""))
oStructSA1:SetProperty("*",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,""))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ACH-Suspects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructACH:AddField("","","ACH_MARK","L",1,0,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMA20MrkCta('ACHDETAIL')"),Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo que diz se a conta esta habilitada para transferencia  dos suspects         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructACH:AddField(AllTrim(STR0013),STR0014,"ACH_DISPON","C",1,0,Nil,Nil,{STR0015,STR0016} ,Nil,Nil,Nil,Nil,.T.)//"Disponivel"//"Disponivel p/ Tranferência"//"1=Sim"//"2=Não"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela SUS-Prospects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSUS:AddField("","","US_MARK","L",1,0,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMA20MrkCta('SUSDETAIL')"),Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo que controla o numero de oportunidade de vendas em aberto para os suspects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSUS:AddField(STR0017,STR0018,"US_NROPAB","N",5,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)//"Oport. Aberta"//"Número de oportunidades em aberto."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo que diz se a conta esta habilitada para transferencia  dos Prospects        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSUS:AddField(AllTrim(STR0019),STR0020,"US_DISPON","C",1,0,Nil,Nil,{STR0021,STR0022} ,Nil,Nil,Nil,Nil,.T. )//"Disponivel"//"Disponivel p/ Tranferência"//"1=Sim"//"2=Não"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
//³ Campo de marca da tabela SA1-Clientes. ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSA1:AddField("","","A1_MARK","L",1,0,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMA20MrkCta('SA1DETAIL')"),Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo que controla o numero de oportunidade de vendas em aberto para os clientes. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSA1:AddField(STR0023,STR0024,"A1_NROPAB","N",5,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)//"Oport. Aberta"//"Número de oportunidades em aberto."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo que diz se a conta esta habilitada para transferencia   dos clientes        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSA1:AddField(AllTrim(STR0025),STR0026,"A1_DISPON","C",1,0,Nil,Nil,{STR0027,STR0028} ,Nil,Nil,Nil,Nil,.T. )//"Disponivel"//"Disponivel p/ Tranferência"//"1=Sim"//"2=Não"

//-------------------------------------------------------------------------------------------------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia o modelo de dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := MPFormModel():New("CRMA020",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:SetOnDemand(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no modelo de dados Model / ModelGrid. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddFields("SA3MASTER", /*cOwner*/,oStructFke,/*bPreValidacao*/,/*bPosValidacao*/,bCarga)
oModel:AddGrid("SA3DETAIL","SA3MASTER",oStructSA3,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oModel:AddGrid("ACHDETAIL","SA3DETAIL",oStructACH,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oModel:AddGrid("SUSDETAIL","SA3DETAIL",oStructSUS,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oModel:AddGrid("SA1DETAIL","SA3DETAIL",oStructSA1,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos calculados total de contas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddCalc("CALC_CTA","SA3DETAIL","ACHDETAIL","ACH_DISPON","TOTACH","COUNT",/*bCond*/,/*bInitValue*/,STR0029,/*bFormula*/)//"Suspects"
oModel:AddCalc("CALC_CTA","SA3DETAIL","SUSDETAIL","US_DISPON","TOTSUS","COUNT",/*bCond*/,/*bInitValue*/,STR0030,/*bFormula*/)//"Prospects"
oModel:AddCalc("CALC_CTA","SA3DETAIL","SA1DETAIL","A1_DISPON","TOTSA1","COUNT",/*bCond*/,/*bInitValue*/,STR0031,/*bFormula*/)//"Clientes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos calculados total de oportunidades. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddCalc("CALC_OP","SA3DETAIL","SUSDETAIL","US_NROPAB","TOTOPSUS","SUM",/*bCond*/,/*bInitValue*/,STR0032,/*bFormula*/)//"Prospects"
oModel:AddCalc("CALC_OP","SA3DETAIL","SA1DETAIL","A1_NROPAB","TOTOPSA1","SUM",/*bCond*/,/*bInitValue*/,STR0033,/*bFormula*/)//"Clientes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do relacionamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("SA3DETAIL",{{"A3_FILIAL","xFilial('SA3')"}},SA3->( IndexKey(1)))
oModel:SetRelation("ACHDETAIL",{{"ACH_FILIAL","xFilial('ACH')"},{"ACH_VEND","A3_COD"}} ,ACH->( IndexKey(5) )) 
oModel:SetRelation("SUSDETAIL",{{"US_FILIAL" ,"xFilial('SUS')"},{"US_VEND","A3_COD"}}  ,SUS->( IndexKey(6)))
oModel:SetRelation("SA1DETAIL",{{"A1_FILIAL" ,"xFilial('SA1')"},{"A1_VEND","A3_COD"}}  ,SA1->( IndexKey(10)))

oModel:GetModel('ACHDETAIL'):SetLoadFilter({{"ACH_CODIGO"	,"' '"},{"ACH_LOJA","' '"}})
oModel:GetModel('SUSDETAIL'):SetLoadFilter({{"US_LOJA" 		,"' '"},{"US_LOJA" ,"' '"}}) 
oModel:GetModel('SA1DETAIL'):SetLoadFilter({{"A1_LOJA" 		,"' '"},{"A1_LOJA" ,"' '"}}) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura as propriedades do modelo de dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel("SA3MASTER"):SetOnlyView(.T.)
oModel:GetModel("SA3MASTER"):SetOnlyQuery(.T.)

oModel:GetModel("SA3DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("SA3DETAIL"):SetOptional(.T.)
oModel:GetModel("SA3DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("SA3DETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("ACHDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("ACHDETAIL"):SetOptional(.T.)
oModel:GetModel("ACHDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("ACHDETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("SUSDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("SUSDETAIL"):SetOptional(.T.)
oModel:GetModel("SUSDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("SUSDETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("SA1DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("SA1DETAIL"):SetOptional(.T.)
oModel:GetModel("SA1DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("SA1DETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("SA3MASTER"):SetDescription("Struct Fake")
oModel:SetDescription(STR0034)//"Transferência de Contas"
oModel:SetPrimaryKey({})

  
Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface da Transferencia de Contas.

@sample		ViewDef()

@param	    Nenhum

@return		ExpO - Objeto FWFormView

@author		Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView			:= Nil
Local oModel		:= FWLoadModel("CRMA020")
Local cCampo		:= ""
Local cCpoSA3	 	:= "A3_FILIAL|A3_COD|A3_NOME|A3_EMAIL|A3_DDDTEL|A3_TEL|A3_GRPREP|A3_DSCGRP|A3_UNIDAD|A3_DSCUNID|"
Local cCpoACH	 	:= "ACH_FILIAL|ACH_CODIGO|ACH_LOJA|ACH_RAZAO|ACH_NFANT|ACH_TIPO|ACH_PESSOA|ACH_CGC|ACH_EST|ACH_CIDADE|ACH_DDD|ACH_TEL|ACH_EMAIL|ACH_STATUS|ACH_DTCAD|ACH_HRCAD|ACH_CODTER|ACH_TPMEM|ACH_CODMEM|"
Local cCpoSUS	 	:= "US_FILIAL|US_COD|US_LOJA|US_NOME|US_NREDUZ|US_TIPO|US_TPESSOA||US_CGC|US_EST|US_MUN|US_DDD|US_TEL|US_EMAIL|US_STATUS|US_DTCAD|US_HRCAD|US_CODTER|US_TPMEM|US_CODMEM|"
Local cCpoSA1	 	:= "A1_FILIAL|A1_COD|A1_LOJA|A1_NOME|A1_NREDUZ|A1_TIPO|A1_PESSOA|A1_CGC|A1_EST|A1_MUN|A1_DDD|A1_TEL|A1_EMAIL|A1_DTCAD|A1_HRCAD|A1_CODTER|A1_TPMEM|A1_CODMEM|"
Local bAvCpoSA3  	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoSA3 }
Local bAvCpoACH	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoACH }
Local bAvCpoSUS	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoSUS }
Local bAvCpoSA1	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoSA1 }
Local oStructSA3	:= FWFormStruct(2,"SA3",bAvCpoSA3,/*lViewUsado*/)
Local oStructACH	:= FWFormStruct(2,"ACH",bAvCpoACH,/*lViewUsado*/)
Local oStructSUS	:= FWFormStruct(2,"SUS",bAvCpoSUS,/*lViewUsado*/)
Local oStructSA1	:= FWFormStruct(2,"SA1",bAvCpoSA1,/*lViewUsado*/)
Local oCalcTCtas	:= Nil
Local oCalcTOpor	:= Nil

//----------Estrutura do campo tipo View----------------------------

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ACH-Suspects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructACH:AddField("ACH_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra se as contas Estao disponiveis para Tranferencia ACH-Suspects   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructACH:AddField("ACH_DISPON","02",STR0035,STR0036,{},"C",Nil,Nil,Nil,Nil,Nil,Nil,{STR0037,STR0038},Nil,Nil,.T.)//"Disponivel"//"Disponivel p/ Tranferência"//"1=Sim"//"2=Não"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela SUS-Prospects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSUS:AddField("US_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra se as contas Estao disponiveis para Tranferencia SU5-Pospects   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSUS:AddField("US_DISPON","02",STR0039,STR0040,{},"C",Nil,Nil,Nil,Nil,Nil,Nil,{STR0041,STR0042},Nil,Nil,.T.)//"Disponivel"//"Disponivel p/ Tranferência"//"1=Sim"//"2=Não"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo que controla o numero de oportunidade de vendas em aberto para os suspects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSUS:AddField("US_NROPAB","ZZ",STR0043,STR0044,{STR0045},"N","99999",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)//"Oport. Aberta"//"Nr. de Oport. Aberta"//"Número de oportunidades em aberto."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela SA1-Clientes. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSA1:AddField("A1_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra se as contas Estao disponiveis para Tranferencia SA1-Clientes.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSA1:AddField("A1_DISPON","02",STR0046,STR0047,{},"C",Nil,Nil,Nil,Nil,Nil,Nil,{STR0048,STR0049},Nil,Nil,.T.)//"Disponivel"//"Disponivel p/ Tranferência"//"1=Sim"//"2=Não"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo que controla o numero de oportunidade de vendas em aberto para os clientes. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSA1:AddField("A1_NROPAB","ZZ",STR0050,STR0051,{STR0052},"N","99999",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)//"Oport. Aberta"//"Nr. de Oport. Aberta"//"Número de oportunidades em aberto."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta propriedade PictureVar nos campos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructACH:SetProperty("ACH_CGC",MVC_VIEW_PVAR,FwBuildFeature(STRUCT_FEATURE_PICTVAR,"CRMA20PcPJ('ACH_PESSOA')"))
oStructSUS:SetProperty("US_CGC" ,MVC_VIEW_PVAR,FwBuildFeature(STRUCT_FEATURE_PICTVAR,"CRMA20PcPJ('US_TPESSOA')"))
oStructSA1:SetProperty("A1_CGC" ,MVC_VIEW_PVAR,FwBuildFeature(STRUCT_FEATURE_PICTVAR,"CRMA20PcPJ('A1_PESSOA')"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta propriedade para nao editar os campos das estrutura.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructSA3:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oStructACH:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oStructSUS:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oStructSA1:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta propriedade para editar os campos de marca.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructACH:SetProperty("ACH_MARK"	,MVC_VIEW_CANCHANGE,.T.)
oStructSUS:SetProperty("US_MARK" 	,MVC_VIEW_CANCHANGE,.T.)
oStructSA1:SetProperty("A1_MARK" 	,MVC_VIEW_CANCHANGE,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia a interface Transferência de Contas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView := FWFormView():New()
oView:SetContinuousForm()
oView:SetModel(oModel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no ModelGrid (Vendedores).³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_SA3",oStructSA3,"SA3DETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos no ModelGrid (Contas). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_ACH",oStructACH,"ACHDETAIL")
oView:AddGrid("VIEW_SUS",oStructSUS,"SUSDETAIL")
oView:AddGrid("VIEW_SA1",oStructSA1,"SA1DETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos calculados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCalcTCtas := FWCalcStruct(oModel:GetModel("CALC_CTA"))
oView:AddField("VIEW_CALCCTA",oCalcTCtas,"CALC_CTA")

oCalcTOpor := FWCalcStruct(oModel:GetModel("CALC_OP"))
oView:AddField("VIEW_CALCOP",oCalcTOpor,"CALC_OP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid Vendedores. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("VENDEDORES",45)
oView:EnableTitleView("VIEW_SA3",STR0053 + " " + STR0087 )//"Equipe de Vendas" 

oView:SetViewProperty("VIEW_SA3","ENABLENEWGRID")
oView:SetViewProperty("VIEW_SA3","GRIDFILTER",{.T.})
oView:SetViewProperty("VIEW_SA3","GRIDSEEK",{.T.})
oView:SetViewProperty("VIEW_SA3","GRIDDOUBLECLICK", {{|| CRMA20ClkVend() }} )
oView:SetOwnerView("VIEW_SA3","VENDEDORES")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid com as Contas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("CONTAS",50)
oView:CreateFolder("FOLDER_CONTAS","CONTAS")
oView:AddSheet("FOLDER_CONTAS","FOLHA_ACH",STR0054)//"Suspects"
oView:AddSheet("FOLDER_CONTAS","FOLHA_SUS",STR0055)//"Prospects"
oView:AddSheet("FOLDER_CONTAS","FOLHA_SA1",STR0056)//"Clientes"
oView:CreateHorizontalBox("CONTA_ACH",100,,,"FOLDER_CONTAS","FOLHA_ACH")
oView:CreateHorizontalBox("CONTA_SUS",100,,,"FOLDER_CONTAS","FOLHA_SUS")
oView:CreateHorizontalBox("CONTA_SA1",100,,,"FOLDER_CONTAS","FOLHA_SA1")

//Habilita o GRID e Filtro no grid das contas.
oView:SetViewProperty("VIEW_ACH","ENABLENEWGRID")
oView:SetViewProperty("VIEW_ACH","GRIDFILTER",{.T.})
oView:SetViewProperty("VIEW_ACH","GRIDSEEK",{.T.})
oView:SetOwnerView("VIEW_ACH","CONTA_ACH")

oView:SetViewProperty("VIEW_SUS","ENABLENEWGRID")
oView:SetViewProperty("VIEW_SUS","GRIDFILTER",{.T.})
oView:SetViewProperty("VIEW_SUS","GRIDSEEK",{.T.})
oView:SetOwnerView("VIEW_SUS","CONTA_SUS")

oView:SetViewProperty("VIEW_SA1","ENABLENEWGRID")
oView:SetViewProperty("VIEW_SA1","GRIDFILTER",{.T.})
oView:SetViewProperty("VIEW_SA1","GRIDSEEK",{.T.})
oView:SetOwnerView("VIEW_SA1","CONTA_SA1")

oView:CreateHorizontalBox("TOTAL",5)
oView:CreateVerticalBox("TOTAL_CTA",50,"TOTAL")
oView:EnableTitleView("VIEW_CALCCTA",STR0057)//"Total de Contas"
oView:SetOwnerView("VIEW_CALCCTA","TOTAL_CTA")

oView:CreateVerticalBox("TOTAL_OP",50,"TOTAL")
oView:EnableTitleView("VIEW_CALCOP",STR0058)//"Total de Oportunidades em Aberto"
oView:SetOwnerView("VIEW_CALCOP","TOTAL_OP")
oView:ShowUpdateMsg(.F.)



Return( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020VldForm

Valida o formulario de transferencia de contas.

@sample		CRM020VldForm(oMdlCRM020)

@param			oModel	, objeto	, Modelo de dados(CRMA020)
				oView	, objeto  	, Interface(CRMA020)

@return		ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020VldForm( oModel, oView )

Local oMdlSA3 	 	:= Nil
Local oMdlACH 	 	:= Nil
Local oMdlSUS 	 	:= Nil
Local oMdlSA1 	 	:= Nil
Local oMdlCCTA		:= Nil
Local oMdlCOP  		:= Nil
Local aEntidades 	:= {}
Local aUserPaper	:= aClone( CRMXGetPaper() )
Local nX			:= 0 
Local nY			:= 0 
Local nLenGrid		:= 0
Local lIsSetPaper 	:= .F.
Local lAutomato  	:= IsBlind()

Local lRetorno 		:= .F.

Default oModel		:= FwModelActive()
Default oView		:= FwViewActive()

oMdlSA3 	:= oModel:GetModel("SA3DETAIL")
oMdlACH 	:= oModel:GetModel("ACHDETAIL")
oMdlSUS 	:= oModel:GetModel("SUSDETAIL")
oMdlSA1 	:= oModel:GetModel("SA1DETAIL")
oMdlCCTA	:= oModel:GetModel("CALC_CTA")
oMdlCOP		:= oModel:GetModel("CALC_OP")

aAdd(aEntidades,{oMdlACH,"ACH_MARK"})
aAdd(aEntidades,{oMdlSUS,"US_MARK"})
aAdd(aEntidades,{oMdlSA1,"A1_MARK"})

For nX := 1 To Len(aEntidades)
	
	For nY := 1 To aEntidades[nX][1]:Length()
		aEntidades[nX][1]:GoLine(nY)
		If aEntidades[nX][1]:GetValue(aEntidades[nX][2])
			lRetorno := .T.
			Exit
		EndIf
	Next nY
	
	If lRetorno
		Exit
	EndIf
	
Next nX

If lRetorno
	If !lAutomato
		lRetorno := MsgYesNo(STR0059+AllTrim(oMdlSA3:GetValue("A3_NOME"))+"?",STR0060)//"Deseja transferir as contas do vendedor "//"Transferência de Contas"
	EndIf
	
	If lRetorno
		If lMVCRMUAZS
			AZS->( DbSetOrder(4))	// AZS_FILIAL+AZS_VEND
					
			If AZS->(DBSeek(xFilial("AZS")+oMdlSA3:GetValue("A3_COD")))
				//Seta o papel do vendedor dono da conta como logado.
				CRMXSetPaper( AZS->AZS_CODUSR+AZS->AZS_SEQUEN+AZS->AZS_PAPEL)
				lIsSetPaper := .T.
			EndIf
		EndIf
		
		CRM020Tranf(oMdlSA3,oMdlACH,oMdlSUS,oMdlSA1)
		
		If lIsSetPaper 
			CRMXSetPaper( aUserPaper[USER_PAPER_CODUSR] + aUserPaper[USER_PAPER_SEQUEN] + aUserPaper[USER_PAPER_CODPAPER] )
		EndIf
		
		
		If !lAutomato
			lRetorno := !MsgYesNo(STR0084,STR0060) //"Deseja realizar uma nova transferência?"
		EndIf
			
		If !lRetorno 

			FwModelActive(oModel)    
			FwViewActive(oView)
			
			CursorWait()
			
			//Limpa os grids para um nova transferencia de contas.
			If ( oMdlCCTA:GetValue("TOTACH",1,.F.) > 0 )
				nLenGrid := oMdlACH:Length()
				For nX := 1 To nLenGrid
					oMdlCCTA:SetValue("TOTACH",1,.F.)		
				Next nX 
			EndIf
		
			oMdlACH:ClearData( .T. )
			oMdlACH:InitLine()
			oMdlACH:GoLine(1)
			
			If ( oMdlCCTA:GetValue("TOTSUS") > 0 .Or. oMdlCOP:GetValue("TOTOPSUS ") > 0 )
				nLenGrid := oMdlSUS:Length()
				For nX := 1 To nLenGrid
					oMdlSUS:GoLine( nX ) 
					oMdlCCTA:SetValue("TOTSUS"	,1,.F.)	
					oMdlCOP:SetValue("TOTOPSUS"	,oMdlSUS:GetValue("US_NROPAB"),.F.)	
				Next nX 
			EndIf
				
			oMdlSUS:ClearData( .T. )
			oMdlSUS:InitLine()
			oMdlSUS:GoLine(1)
			
			If ( oMdlCCTA:GetValue("TOTSA1") > 0 .Or. oMdlCOP:GetValue("TOTOPSA1") > 0 )
				nLenGrid := oMdlSA1:Length()
				For nX := 1 To nLenGrid
					oMdlSA1:GoLine( nX )
					oMdlCCTA:LoadValue("TOTSA1"	,1,.F.)
					oMdlCOP:LoadValue("TOTOPSA1",oMdlSA1:GetValue("A1_NROPAB"),.F.)
				Next nX
			EndIf 
		
			oMdlSA1:ClearData( .T. )
			oMdlSA1:InitLine()
			oMdlSA1:GoLine(1)
			
			oView:Refresh()
			
			CursorArrow()
			
		EndIf
		
	EndIf
	
Else 
	Help("",1,"HELP","CRMA020",STR0071,1) //"Não há contas selecionadas para transferir."
EndIf

Return( lRetorno ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020Tranf

Transfere as contas do vendedor proprietario para outro vendedor.

@sample	CRM020Tranf(oMdlSA3,oMdlACH,oMdlSUS,oMdlSA1)

@param		ExpO1 - Modelo de dados Vendedores(SA3DETAIL).
			ExpO2 - Modelo de dados Suspects(ACHDETAIL).
			ExpO3 - Modelo de dados Prospects(SUSDETAIL).
			ExpO4 - Modelo de dados Clientes(SA1DETAIL).

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM020Tranf(oMdlSA3,oMdlACH,oMdlSUS,oMdlSA1)

Local aSize	 		:= FWGetDialogSize( oMainWnd )
Local oModel		:= Nil
Local oView	   		:= Nil
Local oMdlZYX		:= Nil
Local oMdlZYZ		:= Nil
Local oStructZYX    := Nil
Local oStructZYZ	:= Nil
Local aCamposZYX	:= {} 
Local aCamposZYZ    := {}
Local aLoadZYX		:= {}
Local aLoadZYZ		:= {}
Local nX			:= 0
Local nLenGrid		:= 0
Local nLinha		:= 0
Local cNomeEnt		:= ""
Local lRetorno 		:= .T.
Local lAutomato  	:= IsBlind()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o load do model para transferencia de contas entres os vendedores. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel 		:= FWLoadModel("CRMA020A")
oMdlZYX		:= oModel:GetModel("TRFMASTER")
oMdlZYZ 	:= oModel:GetModel("CONTASDET")

oStructZYX	:= oMdlZYX:GetStruct()
aCamposZYX 	:= oStructZYX:GetFields()

oStructZYZ	:= oMdlZYZ:GetStruct()
aCamposZYZ 	:= oStructZYZ:GetFields()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o load da estrutura Dados de Transferencia(TRFMASTER). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLoadZYX := Array(Len(aCamposZYX))
aLoadZYX[1] := oMdlSA3:GetValue("A3_COD")        	// Codigo
aLoadZYX[2] := oMdlSA3:GetValue("A3_NOME")			// Nome do vendedor
aLoadZYX[3] := oMdlSA3:GetValue("A3_EMAIL")			// E-mail
aLoadZYX[4] := oMdlSA3:GetValue("A3_DDDTEL")		// DDD
aLoadZYX[5] := oMdlSA3:GetValue("A3_TEL")			// Telefone 
aLoadZYX[6] := oMdlSA3:GetValue("A3_UNIDAD")		// Codigo da Unidade
aLoadZYX[7] := oMdlSA3:GetValue("A3_DSCUNID")     	// Nome da Unidade

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o load da estrutura Contas(CONTASDET) - Suspects.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeEnt := AllTrim(Posicione("SX2",1,"ACH","X2NOME()"))
nLenGrid := oMdlACH:Length()
For nX := 1 To nLenGrid
	oMdlACH:GoLine(nX)
	If oMdlACH:GetValue("ACH_MARK")
		nLinha += 1
		aAdd(aLoadZYZ,{nLinha,Array(Len(aCamposZYZ))})
		aLoadZYZ[nLinha][2][1] 	:= "ACH"								// Entidade
		aLoadZYZ[nLinha][2][2] 	:= cNomeEnt							// Nome da Entidade
		aLoadZYZ[nLinha][2][3] 	:= oMdlACH:GetValue("ACH_CODIGO")	// Codigo
		aLoadZYZ[nLinha][2][4] 	:= oMdlACH:GetValue("ACH_LOJA")		// Loja
		aLoadZYZ[nLinha][2][5]	:= oMdlACH:GetValue("ACH_RAZAO")		// Razao
		aLoadZYZ[nLinha][2][6]	:= oMdlACH:GetValue("ACH_NFANT")		// Nome Reduzido
		aLoadZYZ[nLinha][2][7]	:= oMdlACH:GetValue("ACH_PESSOA") 	// Pessoa Fisica ou Juridica
		aLoadZYZ[nLinha][2][8]	:= oMdlACH:GetValue("ACH_CGC")		// CNPJ / CPF
		aLoadZYZ[nLinha][2][9]	:= oMdlACH:GetValue("ACH_DDD")		// DDD
		aLoadZYZ[nLinha][2][10]	:= oMdlACH:GetValue("ACH_TEL")		// Telefone
		aLoadZYZ[nLinha][2][11]	:= oMdlACH:GetValue("ACH_EMAIL")	// E-mail
		aLoadZYZ[nLinha][2][12]	:= oMdlACH:GetValue("ACH_EST")		// Estado
		aLoadZYZ[nLinha][2][13]	:= oMdlACH:GetValue("ACH_CIDADE")	// Municipio
		aLoadZYZ[nLinha][2][14]	:= 0								// Nr. Oportunidade de Vendas em Aberto
		aLoadZYZ[nLinha][2][15]	:= "3"								// Acao da oportunidade		
		If ( AIM->(ColumnPos("ACH_CODTER")) .And. AIM->(ColumnPos("ACH_TPMEM")) .And. AIM->(ColumnPos("ACH_CODMEM")) )
			aLoadZYZ[nLinha][2][18]	:= oMdlACH:GetValue("ACH_CODTER")	// Codigo do Territorio
			aLoadZYZ[nLinha][2][19]	:= oMdlACH:GetValue("ACH_TPMEM")	// Tipo do Membro
			aLoadZYZ[nLinha][2][20]	:= oMdlACH:GetValue("ACH_CODMEM")	// Codigo do Membro
			aLoadZYZ[nLinha][2][21]	:= "1"									// Tipo de Transf.
		Else
			aLoadZYZ[nLinha][2][18]	:= "1"									// Tipo de Transf.  
		EndIf
		
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o load da estrutura Contas(CONTASDET) - Prospects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeEnt := AllTrim(Posicione("SX2",1,"SUS","X2NOME()"))
nLenGrid := oMdlSUS:Length()
For nX := 1 To nLenGrid
	oMdlSUS:GoLine(nX)
	If oMdlSUS:GetValue("US_MARK")
		nLinha += 1
		aAdd(aLoadZYZ,{nLinha,Array(Len(aCamposZYZ))})
		aLoadZYZ[nLinha][2][1]	:= "SUS"							// Entidade
		aLoadZYZ[nLinha][2][2]	:= cNomeEnt							// Nome da Entidade
		aLoadZYZ[nLinha][2][3]	:= oMdlSUS:GetValue("US_COD")		// Codigo
		aLoadZYZ[nLinha][2][4]	:= oMdlSUS:GetValue("US_LOJA")		// Loja
		aLoadZYZ[nLinha][2][5]	:= oMdlSUS:GetValue("US_NOME")		// Razao
		aLoadZYZ[nLinha][2][6]	:= oMdlSUS:GetValue("US_NREDUZ")	// Nome Reduzido
		aLoadZYZ[nLinha][2][7]	:= oMdlSUS:GetValue("US_TPESSOA") 	// Pessoa Fisica ou Juridica
		aLoadZYZ[nLinha][2][8]	:= oMdlSUS:GetValue("US_CGC")		// CNPJ / CPF
		aLoadZYZ[nLinha][2][9]	:= oMdlSUS:GetValue("US_DDD")		// DDD
		aLoadZYZ[nLinha][2][10]	:= oMdlSUS:GetValue("US_TEL")		// Telefone
		aLoadZYZ[nLinha][2][11]	:= oMdlSUS:GetValue("US_EMAIL")		// E-mail
		aLoadZYZ[nLinha][2][12]	:= oMdlSUS:GetValue("US_EST")		// Estado
		aLoadZYZ[nLinha][2][13]	:= oMdlSUS:GetValue("US_MUN")		// Municipio
		aLoadZYZ[nLinha][2][14]	:= oMdlSUS:GetValue("US_NROPAB")	// Nr. Oportunidade de Vendas em Aberto
		If oMdlSUS:GetValue("US_NROPAB") > 0
			aLoadZYZ[nLinha][2][15]	:= "2"							// Acao da oportunidade
		Else
			aLoadZYZ[nLinha][2][15]	:= "3"
		EndIf
		If ( AIM->(ColumnPos("US_CODTER")) .And. AIM->(ColumnPos("US_TPMEMB")) .And. AIM->(ColumnPos("US_CODMEMB")) )
			aLoadZYZ[nLinha][2][18]	:= oMdlSUS:GetValue("US_CODTER")	// Codigo do Territorio
			aLoadZYZ[nLinha][2][19]	:= oMdlSUS:GetValue("US_TPMEMB")	// Tipo do Membro
			aLoadZYZ[nLinha][2][20]	:= oMdlSUS:GetValue("US_CODMEMB")	// Codigo do Membro
			aLoadZYZ[nLinha][2][21]	:= "1"									// Tipo de Transf.
		Else
			aLoadZYZ[nLinha][2][18]	:= "1"									// Tipo de Transf.  
		EndIf
		
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o load da estrutura Contas(CONTASDET) - Prospects. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeEnt := AllTrim(Posicione("SX2",1,"SA1","X2NOME()"))
nLenGrid := oMdlSA1:Length()
For nX := 1 To nLenGrid 
	oMdlSA1:GoLine(nX)
	If oMdlSA1:GetValue("A1_MARK")
		nLinha += 1
		aAdd(aLoadZYZ,{nLinha,Array(Len(aCamposZYZ))})
		aLoadZYZ[nLinha][2][1]	:= "SA1"							// Entidade
		aLoadZYZ[nLinha][2][2]	:= cNomeEnt							// Nome da Entidade
		aLoadZYZ[nLinha][2][3]	:= oMdlSA1:GetValue("A1_COD")		// Codigo
		aLoadZYZ[nLinha][2][4]	:= oMdlSA1:GetValue("A1_LOJA")		// Loja
		aLoadZYZ[nLinha][2][5]	:= oMdlSA1:GetValue("A1_NOME")		// Razao
		aLoadZYZ[nLinha][2][6]	:= oMdlSA1:GetValue("A1_NREDUZ")	// Nome Reduzido
		aLoadZYZ[nLinha][2][7]	:= oMdlSA1:GetValue("A1_PESSOA") 	// Pessoa Fisica ou Juridica
		aLoadZYZ[nLinha][2][8]	:= oMdlSA1:GetValue("A1_CGC")		// CNPJ / CPF
		aLoadZYZ[nLinha][2][9]	:= oMdlSA1:GetValue("A1_DDD")		// DDD
		aLoadZYZ[nLinha][2][10]	:= oMdlSA1:GetValue("A1_TEL")		// Telefone
		aLoadZYZ[nLinha][2][11]	:= oMdlSA1:GetValue("A1_EMAIL")		// E-mail
		aLoadZYZ[nLinha][2][12]	:= oMdlSA1:GetValue("A1_EST")		// Estado
		aLoadZYZ[nLinha][2][13]	:= oMdlSA1:GetValue("A1_MUN")		// Municipio
		aLoadZYZ[nLinha][2][14]	:= oMdlSA1:GetValue("A1_NROPAB")	// Nr. Oportunidade de Vendas em Aberto
		If oMdlSA1:GetValue("A1_NROPAB") > 0
			aLoadZYZ[nLinha][2][15]	:= "2"							// Acao da oportunidade
		Else
			aLoadZYZ[nLinha][2][15]	:= "3"
		EndIf
		If ( AIM->(ColumnPos("A1_CODTER")) .And. AIM->(ColumnPos("A1_TPMEMB")) .And. AIM->(ColumnPos("A1_CODMEMB")) )
			aLoadZYZ[nLinha][2][18]	:= oMdlSA1:GetValue("A1_CODTER")	// Codigo do Territorio
			aLoadZYZ[nLinha][2][19]	:= oMdlSA1:GetValue("A1_TPMEMB")	// Tipo do Membro
			aLoadZYZ[nLinha][2][20]	:= oMdlSA1:GetValue("A1_CODMEMB")	// Codigo do Membro
			aLoadZYZ[nLinha][2][21]	:= "1"									// Tipo de Transf.
		Else
			aLoadZYZ[nLinha][2][18]	:= "1"									// Tipo de Transf.  
		EndIf
		
	EndIf
Next nX     

oMdlZYX:bLoad := {|| aLoadZYX }
oMdlZYZ:bLoad := {|| aLoadZYZ }

oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o load da interface para transferencia de contas entres os vendedores. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutomato
	oView := FWLoadView("CRMA020A")
	oView:SetModel(oModel)
	oView:SetOperation(MODEL_OPERATION_UPDATE)
	
	//Adiciona o botao de transferir;
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					{.T.,STR0010},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
					
	oExecView := FWViewExec():New()
	oExecView:SetTitle( STR0061 ) //"Transferir Para:"
	oExecView:SetSource( "CRMA020A" )
	oExecView:SetModal( .F. )
	oExecView:SetOperation( MODEL_OPERATION_UPDATE )
	oExecView:SetModel( oModel )
	oExecView:SetView(oView)
	oExecView:SetButtons(aButtons)
	oExecView:OpenView( .F. )
	
	//Abortou a transferencia de contas entre os vendedores
	If oExecView:GetButtonPress() == 1
		lRetorno := .F.
	EndIf
Else
	//------------------------------------------------------------------------------------
	// Necessário utilização do GetParAuto para efetuar o SetValue direto no fonte
	// de instanciamento do modelo, pois, há campos que utilizam o FwBuildFeature 
	// que utiliza o stack para setar o valor, com o SetValue. Sendo efetuado no 
	// script o stack muda e é apresentado error log nas classes de Framework - ThamaraV 
	//------------------------------------------------------------------------------------
	If FindFunction( "GetParAuto" )
		aRetAuto 	:= GetParAuto( "CRMA020TESTCASE" )
		For nX := 1 To Len( aRetAuto )
			oModel:GetModel( aRetAuto[nX][1] ):SetValue( aRetAuto[nX][2], aRetAuto[nX][3] )  	
		Next nX 
	EndIf
EndIf

If !lAutomato
	oExecView:DeActivate()
	oModel:Destroy()
EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20COpt

Retorna o numero de oportunidades em aberto para o prospects e clientes.

@sample		CRMA20COpt(cCampo)

@param		ExpC - Codigo da entidade (SUS|SA1)

@return		ExpN - Numero de oportunidade em aberto

@author		Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA20COpt(cEntidad)

Local cQuery 		:= ""
Local cTemp		:= GetNextAlias()
Local nNrOport	:= 0

	
//Total Oportunidade por conta
cQuery :=   "	SELECT COUNT(*) TOTAL "
cQuery +=   "	FROM "+RetSqlName("AD1")
cQuery +=   " WHERE AD1_FILIAL = '" + xFilial("AD1") + "'"
If cEntidad == "SUS"
	cQuery +=	" AND AD1_PROSPE = '" + SUS->US_COD	+ "'"
	cQuery +=	" AND AD1_LOJPRO = '" + SUS->US_LOJA	+ "'"
	cQuery +=	" AND AD1_VEND   = '" + SUS->US_VEND	+ "'"
Else
	cQuery +=	" AND AD1_CODCLI = '" + SA1->A1_COD	+ "'"
	cQuery +=	" AND AD1_LOJCLI = '" + SA1->A1_LOJA	+ "'"
	cQuery +=	" AND AD1_VEND   = '" + SA1->A1_VEND	+ "'"
EndIf
cQuery += 	" AND AD1_STATUS = '1'  "
cQuery +=	" AND D_E_L_E_T_ = ' ' "

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)

If (cTemp)->( !Eof() ) 
	nNrOport  := (cTemp)->TOTAL
EndIf

(cTemp)->( DBCloseArea() )
	
Return( nNrOport )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20PcPJ

Formata a picture do campo CGC para pessoa fisica ou juridica das entidades suspects, prospects e clientes.

@sample		CRMA20PcPJ(cCampo)

@param		ExpC - Campo que recebera a picture.

@return		ExpC - Picture para pessoa fisica ou juridica.

@author		Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Function CRMA20PcPJ(cCampo)

Local oModel 	:= FwModelActive()
Local oMdlGrid	:= Nil
Local cPict 	:= ""

If cCampo == "ACH_PESSOA"
	oMdlGrid := oModel:GetModel("ACHDETAIL")
	cTipPes  := oMdlGrid:GetValue("ACH_PESSOA")
ElseIf cCampo == "US_TPESSOA"
	oMdlGrid := oModel:GetModel("SUSDETAIL")
	cTipPes  := oMdlGrid:GetValue("US_TPESSOA")
Else
	oMdlGrid := oModel:GetModel("SA1DETAIL")
	cTipPes  := oMdlGrid:GetValue("A1_PESSOA")
EndIf

If cTipPes $ "F|CF"
	cPict := "@R 999.999.999-99"
Else
	cPict := "@R 99.999.999/9999-99"
Endif

Return( cPict )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020LdVend

Faz load no ModelGrid(SA3DETAIL) para trazer as contas do vendedor logado no CRM e de seu time de vendas de acordo
com a sua posicao na estrutura de vendas caso o vendedor nao estiver na estrutura de vendas trazer todas as contas.

@sample		CRM020LdVend(oMdlSA3,aTimeVend)

@param		ExpO1 - Objeto ModelGrid(SA3DETAIL).
			ExpA2 - Array com o Time de Vendas.

@return		ExpA - Array com os vendedores para fazer a carga no ModelGrid(SA3DETAIL).

@author		Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CRM020LdVend( oMdlSA3, aTimeVend )
Local aAreaSA3	:= SA3->(GetArea())
Local oStructSA3	:= oMdlSA3:GetStruct()
Local aCamposSA3	:= oStructSA3:GetFields()
Local nLenCpo		:= Len(aCamposSA3)
Local aLoadSA3	:= {}
Local nLinha		:= 0
Local nX			:= 0
Local nY			:= 0

Private INCLUI	:= .F.

SA3->( DbSetOrder( 1 ) ) //A3_FILIAL+A3_COD

For nX := 1 To Len(aTimeVend)  
	If SA3->( DBSeek(xFilial("SA3")+aTimeVend[nX]) )
		nLinha += 1 
		aAdd(aLoadSA3,{nLinha,Array(nLenCpo)})
		For nY := 1 To nLenCpo
			If !aCamposSA3[nY][MODEL_FIELD_VIRTUAL]
				aLoadSA3[nLinha][2][nY]	:= SA3->( FieldGet( FieldPos( aCamposSA3[nY][MODEL_FIELD_IDFIELD] ) ) )
			Else
				aLoadSA3[nLinha][2][nY]	:= CriaVar(aCamposSA3[nY][MODEL_FIELD_IDFIELD],.T.)
			EndIf
		Next nY
	EndIf	
Next nX

RestArea(aAreaSA3)

Return( aLoadSA3 )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20ClkVend

Interface para marcação do vendedor.

@sample	CRMA20ClkVend()

@return	Nenhum

@author	Anderson Silva
@since		21/09/2016
@version	12
/*/
//---------------------------------------------------------------------------------------------------------------
Function CRMA20ClkVend()

Local lRet				:= .T.
Local oModel 			:= FwModelActive()
Local oView 			:= FwViewActive()
Local oMdlSA3			:= oModel:GetModel("SA3DETAIL")
Local oMdlACH			:= oModel:GetModel("ACHDETAIL")
Local oMdlSUS			:= oModel:GetModel("SUSDETAIL")
Local oMdlSA1			:= oModel:GetModel("SA1DETAIL")
Local oMdlCCTA		:= oModel:GetModel("CALC_CTA")
Local oMdlCOP  		:= oModel:GetModel("CALC_OP")
Local oStuct			:= Nil
Local oDlg				:= Nil
Local oPanel			:= Nil
Local oChkACH			:= Nil
Local oChkSUS			:= Nil
Local oChkSA1			:= Nil
Local oChkFACH		:= Nil
Local oChkFSUS		:= Nil
Local oChkFSA1		:= Nil
Local oChkMACH		:= Nil
Local oChkMSUS		:= Nil
Local oChkMSA1		:= Nil
Local lACH				:= .T.
Local lSUS				:= .T.
Local lSA1				:= .T.
Local lFACH			:= .F.
Local lFSUS			:= .F.
Local lFSA1			:= .F.
Local lMACH			:= .F.
Local lMSUS			:= .F.
Local lMSA1			:= .F.
Local lDlgOK			:= .F.
Local lPESLVD			:= ExistBlock("CRM20SLVD")
Local cTempEnt		:= GetNextAlias()
Local cFilialSA3		:= xFilial("SA3")
Local cFilialACH		:= xFilial("ACH")
Local cFilialSUS		:= xFilial("SUS")
Local cFilialSA1		:= xFilial("SA1")
Local cWhereACH		:= ""
Local cWhereSUS		:= ""
Local cWhereSA1		:= ""
Local cCodVend		:= ""
Local cFilExpACH		:= ""
Local cFilExpSUS		:= ""
Local cFilExpSA1		:= ""
Local nX				:= 0
Local nCount			:= 0
Local nLineNew		:= 0
Local nLenGrid		:= 0
Local nLenFields		:= 0
Local nMaxLines 		:= 0
Local aFields			:= {}
Local aFieldsPos		:= {}
Local aFilExpACH		:= {}
Local aFilExpSUS		:= {}
Local aFilExpSA1		:= {}
Local aError			:= {}

oDlg := FWDialogModal():New()
oDlg:SetBackground(.F.)	
oDlg:SetTitle(STR0081)	//"Parâmetros"
oDlg:SetEscClose(.T.)	
oDlg:SetSize(90,140) 	
oDlg:EnableFormBar(.T.) 
oDlg:CreateDialog() 	
oDlg:CreateFormBar()
oPanel := oDlg:GetPanelMain()
oDlg:AddButton(STR0074,{|| lDlgOK := .T.,oDlg:DeActivate() },STR0074,,.T.,.F.,.T.) //Confirmar
oDlg:AddButton(STR0075,{|| oDlg:Deactivate() },STR0075,,.T.,.F.,.T.) //Cancelar

@ 010,005 CHECKBOX oChkACH 	VAR lACH 	PROMPT STR0076 SIZE 37,10 OF oPanel PIXEL//"Suspects"
@ 010,045 CHECKBOX oChkFACH	VAR lFACH	PROMPT STR0082 SIZE 37,10 OF oPanel ON CLICK ( IIF( lFACH,CRM020MntFilter("ACH",aFilExpACH,@cFilExpACH,@lFACH), Nil ),oChkFACH:Refresh() ) PIXEL//"Suspects"
@ 010,080 CHECKBOX oChkMSA1	VAR lMACH	PROMPT STR0083 SIZE 50,10 OF oPanel PIXEL//"Prospects"

@ 020,005 CHECKBOX oChkSUS 	VAR lSUS 	PROMPT STR0077 SIZE 37,10 OF oPanel PIXEL//"Prospects"
@ 020,045 CHECKBOX oChkFSUS	VAR lFSUS	PROMPT STR0082 SIZE 37,10 OF oPanel ON CLICK ( IIF( lFSUS,CRM020MntFilter("SUS",aFilExpSUS,@cFilExpSUS,@lFSUS), Nil ),oChkFSUS:Refresh() ) PIXEL//"Prospects"
@ 020,080 CHECKBOX oChkMSA1	VAR lMSUS	PROMPT STR0083 SIZE 50,10 OF oPanel PIXEL//"Prospects"

@ 030,005 CHECKBOX oChkSA1 	VAR lSA1 	PROMPT STR0078 SIZE 37,10 OF oPanel PIXEL//"Clientes"
@ 030,045 CHECKBOX oChkFSA1	VAR lFSA1	PROMPT STR0082 SIZE 37,10 OF oPanel ON CLICK ( IIF( lFSA1,CRM020MntFilter("SA1",aFilExpSA1,@cFilExpSA1,@lFSA1), Nil ),oChkFSA1:Refresh() ) PIXEL//"Clientes"
@ 030,080 CHECKBOX oChkMSA1	VAR lMSA1	PROMPT STR0083 SIZE 50,10 OF oPanel PIXEL//"Prospects"

oDlg:Activate()

If lDlgOK
	
	cCodVend := oMdlSA3:GetValue("A3_COD")
	
	If lPESLVD
		lRet := ExecBlock("CRM20SLVD", .F., .F., { cCodVend, "BEFORE", oModel, oView } )
		If ValType( lRet ) <> "L" 
			lRet := .F.	
		EndIf
	EndIf
	
	CursorWait()
		
	If lRet 
	
		If lACH
			
			If ( oMdlCCTA:GetValue("TOTACH",1,.F.) > 0 )
				nLenGrid := oMdlACH:Length()
				For nX := 1 To nLenGrid
					oMdlCCTA:SetValue("TOTACH",1,.F.)		
				Next nX 
			EndIf
		
			oMdlACH:SetNoInsertLine( .F. )
			oMdlACH:ClearData( .T. )
			oMdlACH:InitLine()
			oMdlACH:GoLine(1)
			aFieldsPos	:= {}
			oStruct 	:= oMdlACH:GetStruct()
			aFields	:= oStruct:GetFields()
			nLenFields	:= Len( aFields )
			nMaxLines	:= oMdlACH:GetMaxLines()
			
			For nX := 1 To nLenFields
				If !aFields[nX][MODEL_FIELD_VIRTUAL]
					aAdd( aFieldsPos, { oStruct:GetFieldPos( aFields[nX][MODEL_FIELD_IDFIELD] ), ACH->( FieldPos( aFields[nX][MODEL_FIELD_IDFIELD]  ) ) } )
				EndIf
			Next nX
			
			nLenFields	:= Len( aFieldsPos )
			
			cWhereACH := "%"
			cWhereACH += " ACH_FILIAL = '" + xFilial("ACH") + "'"
			cWhereACH += " AND ACH_VEND = '" + cCodVend + "'"
			cWhereACH += " AND ACH_DTCONV = ' ' "
			cWhereACH += " AND ACH_HRCONV = ' ' "
				
			If lFACH
				cWhereACH += " AND ( " + cFilExpACH + " ) "
			EndIf
			
			cWhereACH += "%"
			
			BeginSql Alias cTempEnt
				SELECT R_E_C_N_O_
				FROM %Table:ACH%
				WHERE %Exp:cWhereACH%
				AND %NotDel%
			EndSql
			
			While (cTempEnt)->( !Eof() ) 
				
				ACH->( DBGoTo( (cTempEnt)->R_E_C_N_O_ ) )
				
				nCount += 1
				
				If nCount <> 1
					nLineNew := oMdlACH:AddLine()
					If nCount < nLineNew
						lRet := .F.
						Exit
					EndIf
				EndIf
					
				If lRet
					
					oMdlACH:GoLine( nCount )
					 
					For nX := 1 To nLenFields
						lRet := oMdlACH:LdValueByPos( aFieldsPos[nX][1],ACH->( FieldGet( aFieldsPos[nX][2] ) ) )
						If !lRet
							Exit
						EndIf
					Next nX
					
					If lRet 
						oMdlACH:SetValue("ACH_DISPON",CRM020DCta('ACH'))
						If ( lMACH .And. CRMA20MrkCta(/*cModelo*/,oMdlACH) )
							oMdlACH:LdValueByPos( oStruct:GetFieldPos( "ACH_MARK" ), .T. )
						EndIf
					Else
						oMdlACH:SetValue("ACH_DISPON","2")
					EndIf
					
				EndIf
						
				If ( !lRet .Or. nMaxLines == nCount )
					Exit
				EndIf
				
				(cTempEnt)->( DBSkip() )
			
			EndDo
			
			(cTempEnt)->( DBCloseArea() )
			
			If !lRet 
				aError	:= oModel:GetErrorMessage()
				Help("",1,"CRMA20CLKVEND",,aError[6],1)
			EndIf
				
			oMdlACH:SetNoInsertLine( .T. )	
			oMdlACH:GoLine(1)
			
		EndIf
		
		If lRet .And. lSUS
		
			If ( oMdlCCTA:GetValue("TOTSUS") > 0 .Or. oMdlCOP:GetValue("TOTOPSUS ") > 0 )
				nLenGrid := oMdlSUS:Length()
				For nX := 1 To nLenGrid
					oMdlSUS:GoLine( nX ) 
					oMdlCCTA:SetValue("TOTSUS"	,1,.F.)	
					oMdlCOP:SetValue("TOTOPSUS"	,oMdlSUS:GetValue("US_NROPAB"),.F.)	
				Next nX 
			EndIf
			
			oMdlSUS:SetNoInsertLine( .F. )	
			oMdlSUS:ClearData( .T. )
			oMdlSUS:InitLine()
			oMdlSUS:GoLine(1)
			aFieldsPos	:= {}
			nCount		:= 0 
			oStruct 	:= oMdlSUS:GetStruct()
			aFields	:= oStruct:GetFields()
			nLenFields	:= Len( aFields )
			nMaxLines	:= oMdlSUS:GetMaxLines()
		
			For nX := 1 To nLenFields
				If !aFields[nX][MODEL_FIELD_VIRTUAL]
					aAdd( aFieldsPos, { oStruct:GetFieldPos( aFields[nX][MODEL_FIELD_IDFIELD] ), SUS->( FieldPos( aFields[nX][MODEL_FIELD_IDFIELD]  ) ) } )
				EndIf
			Next nX
		
			nLenFields	:= Len( aFieldsPos )
			
			cWhereSUS := "%"
			cWhereSUS += " US_FILIAL = '" + xFilial("SUS") + "'"
			cWhereSUS += " AND US_VEND = '" + cCodVend + "'"
			cWhereSUS += " AND US_DTCONV = ' ' "
			cWhereSUS += " AND US_HRCONV = ' ' "
		
			If lFSUS
				cWhereSUS += " AND ( " + cFilExpSUS + " ) "
			EndIf
			
			cWhereSUS += "%"
		
			BeginSql Alias cTempEnt
				SELECT R_E_C_N_O_
				FROM %Table:SUS%
				WHERE %Exp:cWhereSUS%
				AND %NotDel%
			EndSql
					
			While (cTempEnt)->( !Eof() ) 
				
				SUS->( DBGoTo( (cTempEnt)->R_E_C_N_O_ ) )
				
				nCount += 1
				
				If nCount <> 1
					nLineNew := oMdlSUS:AddLine()
					If nCount < nLineNew
						lRet := .F.
						Exit
					EndIf
				EndIf
				
				If lRet
				
					oMdlSUS:GoLine( nCount )
					
					For nX := 1 To nLenFields
						lRet := oMdlSUS:LdValueByPos( aFieldsPos[nX][1]  ,SUS->( FieldGet( aFieldsPos[nX][2] ) ) )	
						If !lRet
							Exit
						EndIf
					Next nX
					
					If lRet 
						oMdlSUS:SetValue("US_DISPON",CRM020DCta('SUS')) 
						oMdlSUS:SetValue("US_NROPAB",CRMA20COpt('SUS'))
						If ( lMSUS .And. CRMA20MrkCta(/*cModelo*/,oMdlSUS) )
							oMdlSUS:LdValueByPos( oStruct:GetFieldPos( "US_MARK" ), .T. )
						EndIf
					Else
						oMdlSUS:SetValue("US_DISPON","2") 
					EndIf
				
				EndIf
				
				If ( !lRet .Or. nMaxLines == nCount )
					Exit
				EndIf
				
				(cTempEnt)->( DBSkip() )
			End
			
			(cTempEnt)->( DBCloseArea() )
			
			If !lRet 
				aError	:= oModel:GetErrorMessage()
				Help("",1,"CRMA20CLKVEND",,aError[6],1)
			EndIf
			
			oMdlSUS:SetNoInsertLine( .T. )
			oMdlSUS:GoLine(1)
		
		EndIf
		
		If lRet .And. lSA1
			
			If ( oMdlCCTA:GetValue("TOTSA1") > 0 .Or. oMdlCOP:GetValue("TOTOPSA1") > 0 )
				nLenGrid := oMdlSA1:Length()
				For nX := 1 To nLenGrid
					oMdlSA1:GoLine( nX )
					oMdlCCTA:LoadValue("TOTSA1"	,1,.F.)
					oMdlCOP:LoadValue("TOTOPSA1",oMdlSA1:GetValue("A1_NROPAB"),.F.)
				Next nX
			EndIf 
			
			oMdlSA1:SetNoInsertLine( .F. )
			oMdlSA1:ClearData( .T. )
			oMdlSA1:InitLine()
			oMdlSA1:GoLine(1)
			aFieldsPos	:= {}
			nCount	:= 0
			oStruct 	:= oMdlSA1:GetStruct()
			aFields	:= oStruct:GetFields()
			nLenFields	:= Len( aFields )
			nMaxLines	:= oMdlSA1:GetMaxLines()
			
			For nX := 1 To nLenFields
				If !aFields[nX][MODEL_FIELD_VIRTUAL]
					aAdd( aFieldsPos, { oStruct:GetFieldPos( aFields[nX][MODEL_FIELD_IDFIELD] ), SA1->( FieldPos( aFields[nX][MODEL_FIELD_IDFIELD]  ) ) } )
				EndIf
			Next nX
			
			nLenFields	:= Len( aFieldsPos )
			
			cWhereSA1 := "%"
			cWhereSA1 += " A1_FILIAL = '" + xFilial("SA1") + "'"
			cWhereSA1 += " AND A1_VEND = '" + cCodVend + "'"
		
			If lFSA1
				cWhereSA1 += " AND ( " + cFilExpSA1 + " ) "
			EndIf
			
			cWhereSA1 += "%"
		 	
			BeginSql Alias cTempEnt
				SELECT R_E_C_N_O_
				FROM %Table:SA1%
				WHERE %Exp:cWhereSA1%
				AND %NotDel%
			EndSql
			
			While (cTempEnt)->( !Eof() ) 
				
				SA1->( DBGoTo( (cTempEnt)->R_E_C_N_O_ ) )
					
				nCount += 1
				
				If nCount <> 1
					nLineNew := oMdlSA1:AddLine()
					If nCount < nLineNew
						lRet := .F.
						Exit
					EndIf
				EndIf
				
				If lRet 
				
					oMdlSA1:GoLine( nCount )
					
					For nX := 1 To nLenFields
						lRet := oMdlSA1:LdValueByPos( aFieldsPos[nX][1]  ,SA1->( FieldGet( aFieldsPos[nX][2] ) ) )	
						If !lRet
							Exit
						EndIf
					Next nX
					
					If lRet
						oMdlSA1:SetValue("A1_DISPON",CRM020DCta("SA1")) 
						oMdlSA1:SetValue("A1_NROPAB",CRMA20COpt("SA1"))
						If ( lMSA1 .And. CRMA20MrkCta(/*cModelo*/,oMdlSA1) )
							oMdlSA1:LdValueByPos( oStruct:GetFieldPos( "A1_MARK" ), .T. )
						EndIf
					Else
						oMdlSA1:SetValue("A1_DISPON","2") 
					EndIf
				
				EndIf
				
				If ( !lRet .Or. nMaxLines == nCount )
					Exit
				EndIf
				
				(cTempEnt)->( DBSkip() )
				
			EndDo
			
			(cTempEnt)->( DBCloseArea() )
			
			If !lRet 
				aError	:= oModel:GetErrorMessage()
				Help("",1,"CRMA20CLKVEND",,aError[6],1)
			EndIf
			
			oMdlSA1:SetNoInsertLine( .T. )	
			oMdlSA1:GoLine(1)
		
		EndIf
		
		oView:Refresh()

	EndIf
	
	
	If lPESLVD
		lRet := ExecBlock("CRM20SLVD", .F., .F., { cCodVend, "AFTER", oModel, oView } )
		If ValType( lRet ) <> "L" 
			lRet := .F.	
		EndIf
	EndIf
	
	
		
	CursorArrow() 
	
EndIf
	
Return( lRet )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020MntFilter

Monta a expressão de filtro para entidade.

@sample	CRM020MntFilter(cEntity, aExpression, lMark)

@param		cEntity		, Caracter	, Entidade para montar o filtro.
			aExpression	, Array		, Expressões do Filtro.
		cExpression		, Caracter	, Expressao do filtro preparado para execucao no banco de dados.
			lMark			, Logico	, Atualiza a marcação do ckeckbox caso o filtro seja cancelado.

@return	Nenhum

@author	Anderson Silva
@since		21/09/2016
@version	12
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CRM020MntFilter(cEntity, aExpression, cExpression, lMark)

Local oFilEdit 		:= Nil
Local aToken			:= {}
Local nToken			:= 0


Default cEntity		:= ""
Default aExpression	:= {}
Default cExpression	:= "" 
Default lMark			:= .F.

oFilEdit := FWFilterEdit():New(,cEntity)
oFilEdit:DisableExpression()
oFilEdit:DisableFunction()

If !Empty( aExpression )
	oFilEdit:SetFilter( aExpression )
EndIf

oFilEdit:Activate()

aExpression := oFilEdit:GetExpression()

If !Empty( aExpression )

	//-------------------------------------------------------------------
	// Recupera os camponentes da expressão.  
	//-------------------------------------------------------------------	
	aToken := StrTokArr( aExpression[3], "#" )
		
	//-------------------------------------------------------------------
	// Avalia os componentes da expressão.   
	//-------------------------------------------------------------------
	BEGIN SEQUENCE	
		For nToken := 1 To Len( aToken )	
			If ( "FWMNTFILDT" $ Upper( aToken[nToken] ) )
				aToken[nToken] := &( aToken[nToken] )
			EndIf 
		Next nToken	
	END SEQUENCE	

	//-------------------------------------------------------------------
	// Monta a expressão.  
	//-------------------------------------------------------------------
	cExpression := cBIConcatWSep( "", aToken )
	
Else
	lMark := .F.
EndIf

Return

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20MrkCta

Valida quando o usuario marcar os registros dos modelos.
Tambem verifica o campo ***_DISPON do modelo de dados,  se o campo for == 2 não deixa marcar
porque a conta estara indisponivel.

@sample		CRMA20MrkCta(cModelo)

@param		ExpC - Modelo de Dados

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		19/09/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Function CRMA20MrkCta(cModelo,oMdlGrid)

Local oModel 		:= Nil
Local lRetorno 	:= .T.
Local lPEMrkCta	:= ExistBlock("CRM20MKCTA")
Local uRetorno	:= Nil
Local cErrorMsg	:= ""

Default cModelo	:= ""
Default oMdlGrid	:= Nil

If !Empty( cModelo ) 
	oModel		:= FwModelActive()
	oMdlGrid	:= oModel:GetModel(cModelo)
EndIf

If oMdlGrid:IsEmpty()
	cErrorMsg := STR0062 //"Linha em branco"
	lRetorno := .F.
Else
	Do Case 
		Case cModelo == "ACHDETAIL"
			If oMdlGrid:GetValue("ACH_DISPON") == "2"	
				cErrorMsg := STR0063 //"Esta conta não está disponivel para transferencia !" 
				lRetorno := .F.
			Else
				If oMdlGrid:GetValue("ACH_STATUS") == "5"
					cErrorMsg := STR0064 //"Não será possível transferir esta conta a mesma está cancelada."
					lRetorno := .F.
				ElseIf oMdlGrid:GetValue("ACH_STATUS") == "6"
					cErrorMsg := STR0065 //"Não será possível transferir esta conta a mesma foi convertida para prospect."
					lRetorno := .F.
				EndIf
			EndIf
		Case cModelo == "SUSDETAIL"
			If oMdlGrid:GetValue("US_DISPON") == "2"
				cErrorMsg := STR0066 //"Esta conta não está disponivel para transferencia !"
				lRetorno := .F.
			Else
				If oMdlGrid:GetValue("US_STATUS") == "5"
					cErrorMsg	:= STR0067 //"Não será possível transferir esta conta a mesma está cancelada."
					lRetorno	:= .F.
				ElseIf oMdlGrid:GetValue("US_STATUS") == "6"
					cErrorMsg	:= STR0068 //"Não será possível transferir esta conta a mesma foi convertida para cliente."
					lRetorno	:= .F.
				EndIf
			EndIf
		Case cModelo == "SA1DETAIL"
			If oMdlGrid:GetValue("A1_DISPON") == "2"
				cErrorMsg := STR0069 //"Está conta não está disponivel para transferencia!"
				lRetorno := .F.
			EndIf
	EndCase
	
	If lPEMrkCta
		uRetorno := ExecBlock("CRM20MKCTA", .F., .F., {oMdlGrid, lRetorno} )
		If ValType( uRetorno ) == "A"
			lRetorno	:= uRetorno[1]
			cErrorMsg	:= uRetorno[2]
		Else
			cErrorMsg := STR0080 //"O retorno do ponto de entrada CRM20MKCTA inválido..."
			lRetorno := .F.
		EndIf 
	EndIf
	
	If !lRetorno .And. !IsInCallStack("CRMA20CLKVEND")
		Help("",1,"HELP","CRMA020",cErrorMsg,1)
	EndIf

EndIf

Return( lRetorno )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020DCta

Verifica o status das contas e retorna se a conta está disponivel para tranferencia ou nao.

Status:	1 = 'Aguardando Liberacao'
		2 = 'Liberado'
		3 = 'Nao Liberado'
				
@sample	CRM020DCta(cEntidad)

@param		ExpC - Endidate em foco

@return		ExpL - Verdadeiro / Falso

@author		Victor Bitencourt
@since		03/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function CRM020DCta(cEntidad)

Local cRetorno  := "2"
Local cCodCta   := ""
Local cLojCta	:= ""
Local cStatus   := "1"

Do Case
	Case cEntidad == "ACH"
		cCodCta  := ACH->ACH_CODIGO
		cLojCta  := ACH->ACH_LOJA
	Case cEntidad == "SUS"
		cCodCta  := SUS->US_COD
		cLojCta  := SUS->US_LOJA
	Case cEntidad == "SA1"
		cCodCta  := SA1->A1_COD
		cLojCta  := SA1->A1_LOJA
EndCase
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Pesquisando na Tabela AIM  o status  1 porque e o unico status que bloqueia a tranferencia da conta |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("AIM")
DbSetOrder(2) //AIM_FILIAL+AIM_ENTIDA+AIM_CODCTA+AIM_LOJCTA+AIM_STATUS   

If AIM->(!DbSeek(xFilial("AIM")+cEntidad+cCodCta+cLojCta+cStatus))
	cRetorno := "1"
EndIf

Return(cRetorno)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUserAcc
    @description
    Verifica se o usuario logado possui acesso a dados sensiveis e pessoais
    Exibindo mensagem de Help caso usuario não possua acesso.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDUserAcc()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Retorna se Usuario possui acesso a dados protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDUserAcc()

    Local lRet := .T.  

    If FATPDActive()
        lRet := FTPDUserAcc()
    Endif

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