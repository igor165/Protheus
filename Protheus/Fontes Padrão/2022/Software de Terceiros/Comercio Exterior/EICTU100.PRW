#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Average.ch"
#INCLUDE "EEC.CH"
#INCLUDE "EICTU100.CH"

/*
Programa   : EICTU100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08 
Obs.       : Criado com gerador automático de fontes 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08 
*/ 
Static Function MenuDef()
Local   aRotina := {}

   If !EasyHasMVC()
      Private cAvStaticCall := "EICTU100"
      Return StaticCall(EICCADGE, MenuDef) 
   EndIf
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"         OPERATION 1 ACCESS 0	//"Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.EICTU100" OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.EICTU100" OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.EICTU100" OPERATION 4 ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.EICTU100" OPERATION 5 ACCESS 0	//"Excluir"
  

Return aRotina 

Function MVC_EICTU100()
Local oBrowse                    
Local oAvObject := AvObject():New()
Private aRotina := {}

If Type("lSJ5ExecAuto") <> "L" .Or. !lSJ5ExecAuto 
	//CRIAÇÃO DA MBROWSE
	oBrowse := FWMBrowse():New() //Instanciando a Classe
	oBrowse:SetAlias("SJ5") //Informando o Alias                                             `
	oBrowse:SetMenuDef("EICTU100") //Nome do fonte do MenuDef
	oBrowse:SetDescription(STR0001)//Cotação de Moedas
	oBrowse:Activate()
Else
	aRotina := MenuDef()
    oModel := ModelDef()
    If nOpcAuto == 3
       nOpcAuto := If(EasySeekAuto("SJ5",aAutoCab,1),4,3)
    EndIf
    lMsErroAuto := !EasyMVCAuto("EICTU100",nOpcAuto,{{"SJ5MASTER" ,aAutoCab}},@oAvObject)
	If lMsErroAuto
       AEval(oAvObject:aError,{|X| AutoGrLog(x)})
    EndIf	
EndIf

Return Nil    

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJ5 := FWFormStruct( 1, "SJ5") //Monta a estrutura da tabela SJ5
Local bPosValidacao := {|oMdl| TU100Vld(oMdl)}
Local bCommit := {|oMdl| TU100Commit(oMdl)}  // GFP - 01/09/2014

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EICTU', /*bPreValidacao*/, bPosValidacao, bCommit, /*bCancel*/ )

//THTS - 04/09/2017 - NOPADO, pois o campo J5_COD_I ja esta como usado no AtuSX e ja consta no oStruSJ5, nao precisando ser adicionado.
/*If !lSJ5ExecAuto
   oStruSJ5:AddField("Produto" , "" , "J5_COD_I" , "C" , 30 ,0, ;
                     nil,nil, {} , Nil ,  , Nil , Nil , .F.)
EndIf
*/

//Modelo para criação da antiga Enchoice com a estrutura da tabela SJ5
oModel:AddFields( 'SJ5MASTER',/*nOwner*/,oStruSJ5, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Cotação de Moedas

//Utiliza a chave primaria
oModel:SetPrimaryKey({'J5_FILIAL','J5_DE','J5_PARA','J5_COD_I','J5_FORN','J5_FORLOJ'})

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICTU100")

// Cria a estrutura a ser usada na View
Local oStruSJ5:=FWFormStruct(2,"SJ5")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('SJ5MASTER', oStruSJ5)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'SJ5MASTER') 

If Type("lAbriuExp") == "L" .And. lAbriuExp
   oView:addUserButton( "Pesquisa de Produtos" ,"",{ |oModel| EDCAC400HLP(oModel:GetModel():GetValue('SJ5MASTER',"J5_COD_I" ))   },"") //"Embarque"
EndIf

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 

Static Function TU100Vld(oMdl)
Local lRet := .T. 
Local nOpc := oMdl:GetOperation()

If nOpc == 3 .OR. nOpc == 4
   lRet := TU100Valid("",nOpc)
   If lRet .AND. nOpc == 4  // GFP - 19/08/2014
      lRet := TU100TotReg()
      If AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
         lRet := TU100TotReg(2)
      EndIf
   EndIf
EndIf

If nOpc == 5 // MCF - 12/06/2015
   lRet := TU100TotReg()
   If AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
      lRet := TU100TotReg(2) 
   EndIf
Endif

Return lRet

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Guilherme Fernandes Pilan - GFP
* Data: 30/11/2011 - 15:00 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SJ5")
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EICTU100(oEasyMessage:GetEAutoArray("SJ5"),, oEasyMessage:GetOperation())} )
	oEasyIntEAI:SetModule("EEC",29)

	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "TU100ARECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "TU100ARESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	// ***
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "TU100ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 


//5 ultimos caracteres da funcao de manutenção + "A" + 
//"REC" (Recebimeto)/ "RES" (Resposta) / "SEN" (Envio) +
//"B" (Business Message) / "R" (Response Message)
*------------------------------------------------*
Function TU100ARECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch    := EBatch():New()
Local oRecSJ5   := ERec():New()
Local oExecAuto := EExecAuto():New()
Local lObrigat  := .T.
Local cUnimedDe := ""
Local cUnimedPara := ""
Local cCodERPDe   := EasyGetXMLinfo(,oBusinessCont, "_UnitofMeasureOriginCode")
Local cCodERPPara := EasyGetXMLinfo(,oBusinessCont, "_UnitofMeasureDestinationCode") 
Local nOrdSAH := SAH->(INDEXORD())

   /* Tratamento para Codigo ERP da Unidade de Medida Origem */
   SAH->(DbSetOrder(2))
   If SAH->(DbSeek(xFilial()+AvKey(cCodERPDe,"AH_CODERP")))
      cUniMedDe    := SAH->AH_UNIMED
   EndIf
   
   /* Tratamento para Codigo ERP da Unidade de Medida Destino */
   If SAH->(DbSeek(xFilial()+AvKey(cCodERPPara,"AH_CODERP")))
      cUniMedPara    := SAH->AH_UNIMED
   EndIf

   SAH->(DbSetOrder(nOrdSAH))
   
   oRecSJ5:SetField("J5_DE"        , AVKEY(cUniMedDe,  "J5_DE")     )	
   oRecSJ5:Setfield("J5_PARA"      , AVKEY(cUniMedPara,"J5_PARA")   )	   
   oRecSJ5:SetField("J5_COD_I"     , Space(AVSX3("J5_COD_I",3))	    ) 
   AddArrayXML(oRecSJ5, "J5_COEF"  , oBusinessCont,"_MultiplicationFactorValue" ,lObrigat)
   
   oExecAuto:SetField("SJ5",oRecSJ5)
   oBatch:AddRec(oExecAuto) 
    
Return oBatch

*-------------------------------------------------*
Function TU100ARESB(oMessage) 
*-------------------------------------------------*

Local oXml      := EXml():New()

    If !oMessage:HasErrors()  
       /*
       If oMessage:GetOperation() == 3 
          oRespond:SetField('LOG',"Conversão de Unidade de Medida incluída com sucesso no ERP Protheus")
       ElseIf oMessage:GetOperation() == 4
          oRespond:SetField('LOG',"Conversão de Unidade de Medida alterada com sucesso no ERP Protheus")
       ElseIf oMessage:GetOperation() == 5
          oRespond:SetField('LOG',"Conversão de Unidade de Medida excluída com sucesso no ERP Protheus")
       EndIf   
       
       oRespond:SetField('DateTime'  ,FwTimeStamp(3))
	   oRec:SetField('Message',oRespond)	
       oXml:AddRec(oRec)  
       */    
    Else       
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf
 
Return oXml

Function TU100ASENB(oEasyMessage) 
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oEvent  := ENode():New()
Local oRec      := ENode():New()
Local oIdent    := ENode():New()
Local oKeyNode
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","UnitofMeasureOriginCode"))
   oKeyNode:SetField(ETag():New("" ,SJ5->J5_DE))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","UnitofMeasureDestinationCode"))
   oKeyNode:SetField(ETag():New("" ,SJ5->J5_PARA))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oEvent:SetField("Entity", "EICTU100")
   If INCLUI .Or. ALTERA
      oEvent:SetField("Event" ,"upsert" )
   Else
      oEvent:SetField("Event" ,"delete" )
   EndIf
   oEvent:SetField("Identification",oIdent)

   oBusiness:SetField("UnitofMeasureOriginCode",SJ5->J5_DE)
   oBusiness:SetField("UnitofMeasureDestinationCode",SJ5->J5_PARA)
   oBusiness:SetField("MultiplicationFactorValue",SJ5->J5_COEF)

   oRec:SetField('BusinessEvent',oEvent)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)
   
Return oXml

/*
Funcao     : TU100Commit()
Parametros : Nenhum
Retorno    : lRet
Objetivos  : Chamada de gravação do registro
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 01/09/2014
*/
*-------------------------------*
Static Function TU100Commit()
*-------------------------------*
Local lRet := .T.
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()

FWFormCommit(oModel)
If nOperation == 3 .OR. nOperation == 4
   If SJ5->(RecLock("SJ5",.F.))
      SJ5->J5_COD_I := M->J5_COD_I
      SJ5->(MsUnlock())
   EndIf
EndIf

Return lRet