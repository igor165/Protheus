#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EECAT140.CH"

/*
Programa   : EECAT140
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:10 
Obs.       : Criado com gerador automático de fontes 
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:10 
*/ 
Static Function MenuDef() 
Local   aRotina := {}
//Local   aRotAdic := {} 
Private nOpc                        

   If !EasyHasMVC()
      Private cAvStaticCall := "EECAT140"
      Return StaticCall(EECCAD00, MenuDef)
   EndIf
   
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAT140" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAT140" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAT140" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAT140" OPERATION 5 ACCESS 0

// P.E. utilizado para adicionar itens no Menu da mBrowse
/*If EasyEntryPoint("EAT140MNU")
   aRotAdic := ExecBlock("EAT140MNU",.f.,.f.)
   If ValType(aRotAdic) == "A"
      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf */
    
Return aRotina 
    

// CRF
Function MVC_EEC140AT()
Local oBrowse                    
Local oAvObject := AvObject():New()
/* FSM - 04/01/12 - Tratamento para ExecAuto:
* lExecAuto/aAutoCab/nOpcAuto  - Variaveis Privates do fonte EECCAD00.PRW
*/
Private aRotina := {}

If Type("lExecAuto") <> "L" .Or. !lExecAuto 
	//CRIAÇÃO DA MBROWSE
	oBrowse := FWMBrowse():New() //Instanciando a Classe
	oBrowse:SetAlias("SYE") //Informando o Alias                                             `
	oBrowse:SetMenuDef("EECAT140") //Nome do fonte do MenuDef
	oBrowse:SetDescription(STR0001)//Cotação de Moedas
	oBrowse:Activate()
Else
	//FWMVCRotAuto(ModelDef(),"SYE", nOpcAuto, {{"EECP013_SYE" ,aAutoCab}}, .F.)
	aRotina := MenuDef()
    oModel := ModelDef()
    lMsErroAuto := !EasyMVCAuto("EECAT140",nOpcAuto,{{"EECP013_SYE" ,aAutoCab}},@oAvObject)
	If lMsErroAuto
       AEval(oAvObject:aError,{|X| AutoGrLog(x)})
    EndIf	
EndIf

Return Nil    

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSYE := FWFormStruct( 1, "SYE") //Monta a estrutura da tabela SYE
Local bPosValidacao := { |oMdl| IF(EECATVAlid(oMdl:GetOperation(),oMdl),.T.,EasyHelp(STR0002))} //MCF - 26/06/2015
Local bCommit  := {|oMdl| AT140Grv(oMdl)}

/*Criação do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP013', /*bPreValidacao*/, bPosValidacao, bCommit, /*bCancel*/ )

If IsIntEnable("001") .Or. EasyGParam("MV_EECFAT",,.F.)
	oStruSYE:AddField(AvSx3("YE_MOE_FIN", AV_TITULO), AvSx3("YE_MOE_FIN", AV_TITULO), "YE_MOE_FIN", AvSx3("YE_MOE_FIN", AV_TIPO), AvSx3("YE_MOE_FIN", AV_TAMANHO), AvSx3("YE_MOE_FIN", AV_DECIMAL), , ,, .F.,, .F., , .F.)
EndIf

//Modelo para criação da antiga Enchoice com a estrutura da tabela SYE
oModel:AddFields( 'EECP013_SYE',/*nOwner*/,oStruSYE, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Cotação de Moedas

//Utiliza a chave primaria
oModel:SetPrimaryKey({'YE_FILIAL'},{'DTOS(YE_DATA)'},{'YE_MOEDA'})
  
Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAT140")

// Cria a estrutura a ser usada na View
Local oStruSYE:=FWFormStruct(2,"SYE")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

If IsIntEnable("001")
	oStruSYE:AddField( 	; // Ord. Tipo Desc.
						'YE_MOE_FIN' , ; // [01] C Nome do Campo
						AvSx3("YE_MOE_FIN", AV_ORDEM) , ; // [02] C Ordem
						AvSx3("YE_MOE_FIN", AV_TITULO), ; // [03] C Titulo do campo
						AvSx3("YE_MOE_FIN", AV_TITULO), ; // [04] C Descrição do campo
						, ; // [05] A Array com Help
						AvSx3("YE_MOE_FIN", AV_TIPO) , ; // [06] C Tipo do campo
						AvSx3("YE_MOE_FIN", AV_PICTURE), ; // [07] C Picture
						NIL , ; // [08] B Bloco de Picture Var
						'' , ; // [09] C Consulta F3
						.F. , ; // [10] L Indica se o campo é evitável
						AvSx3("YE_MOE_FIN", AV_FOLDER) , ; // [11] C Pasta do campo
						NIL , ; // [12] C Agrupamento do campo
						, ; // [13] A Lista de valores permitido do campo (Combo)
						NIL , ; // [14] N Tamanho Maximo da maior opção do combo
						NIL , ; // [15] C Inicializador de Browse
						.F. , ; // [16] L Indica se o campo é virtual
						NIL ) // [17] C Picture Variável
EndIf

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP013_SYE', oStruSYE)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP013_SYE') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 

Static Function AT140EnvEAI(oMdl)
Local nOrdSYF := SYF->(IndexOrd())
Local nRecSYF := SYF->(Recno())
Local nOperation	:= oMdl:GetOperation()
Local lRet := .F.

  EasyEAIBuffer("INICIO")

  If nOperation <> 5
     nOperation := 3
  EndIf

  SYF->(DbSetOrder(1))
  If SYF->(DbSeek(xFilial("SYF")+AvKey(SYE->YE_MOEDA,"YF_MOEDA")))
                                      //MFR 09/04/2019 OSSME-2708
     If !Empty(SYF->YF_CODFERP) .And. EasyFindAdpt("EECAT141") // Taxa de Fiscal
        EasyEnvEAI("EECAT141",nOperation)
     EndIf
                                      //MFR 09/04/2019 OSSME-2708
     If !Empty(SYF->YF_CODCERP) .And. EasyFindAdpt("EECAT142")  // Taxa de compra
        EasyEnvEAI("EECAT142",nOperation)
     EndIf
                                      //MFR 09/04/2019 OSSME-2708
     If !Empty(SYF->YF_CODVERP) .And. EasyFindAdpt("EECAT143")// Taxa de venda
        EasyEnvEAI("EECAT143",nOperation)
     EndIf
  EndIf
  
  lRet := EasyEAIBuffer("FIM")

  SYF->(DbSetOrder(nOrdSYF))
  SYF->(DBGoTo(nRecSYF))

Return lRet

Static Function AT140Grv(oMdl)
Local lRet := .T.

Begin Transaction
   FWFormCommit(oMdl)
   If SYF->(FieldPos("YF_CODFERP")) > 0 .And. !IsInCallStack("IntegDef") //LBL - 16/09/2013 
      If !(lRet := AT140EnvEAI(oMdl))
         Break
      EndIf
   EndIf
   
   If IsIntEnable("001") .Or. EasyGParam("MV_EECFAT",, .F.)   //LRS - 09/09/2014
      At140GrvInt(.F.)
   EndIf
End Transaction

Return lRet

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Guilherme Fernandes Pilan - GFP
* Data: 01/12/2011 - 15:12 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
Local aArray := {}

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SYE")
	oEasyIntEAI:SetModule("EEC",29)
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAT140(oEasyMessage:GetEAutoArray("SYE"), , oEasyMessage:GetOperation())} )
	
	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AT140ARECB") //RECEBIMENTO DE BUSINESS
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AT140ARESB") //RESPOSTA SOBRE O RECEBIMENTO

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


/*========================================================================================
* Funcao Adapter: AT140ARECB 
* Parametros    : oMessage - Objeto XML com conteúdo da tag "BusinessContent" recebida
* Retorno       : oBatch  - Objeto para geração de ExecAuto
* Objetivos     : Montar o Array de dados da Mensagem única para inserção via ExecAuto
* Autor         : Guilherme Fernandes Pilan - GFP
* Data/Hora     : 22/12/2011 - 15:17 hs 
* Revisao       : Felipe Sales Martinez - FSM - 03/01/2012 
* Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AT140ARECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch    := EBatch():New()
Local oExecAuto, oRec
Local cData := "", cMoeda := "", cCampoTX := ""
Local nCont := 0
Local cCodERP := EasyGetXMLinfo(,oBusinessCont, "_CurrencyCode")
Local lObrigat := .T. //Obrigatoriedade do campo
Local nOrdSYF := SYF->(IndexOrd())
Local nRecSYF := SYF->(Recno())
Local aMoedas := {}
Local nMoeda

    /* Tratamento para Codigo ERP da Moeda */
    If !Empty(cCodERP)
        SYF->(DbSetOrder(4))
        If SYF->(DbSeek(xFilial()+AvKey(cCodERP,"YF_CODCERP")))
           cMoeda := SYF->YF_MOEDA
           cCampoTX := "YE_TX_COMP"
		   aAdd(aMoedas,{cMoeda,cCampoTX})
        EndIf

        SYF->(DbSetOrder(5))
        If SYF->(DbSeek(xFilial()+AvKey(cCodERP,"YF_CODVERP")))
           cMoeda := SYF->YF_MOEDA
           cCampoTX := "YE_VLCON_C"
		   aAdd(aMoedas,{cMoeda,cCampoTX})
        EndIf

        SYF->(DbSetOrder(6))
        If SYF->(DbSeek(xFilial()+AvKey(cCodERP,"YF_CODFERP")))        	
           cMoeda := SYF->YF_MOEDA
           cCampoTX := "YE_VLFISCA"
		   aAdd(aMoedas,{cMoeda,cCampoTX})
        EndIf
    EndIf
    
    If ValType(oBusinessCont:_ListOfQuotation:_Quotation) <> "A"
       XmlNode2Arr(oBusinessCont:_ListOfQuotation:_Quotation,"_Quotation")
    EndIf

    For nCont := 1 To Len(oBusinessCont:_ListOfQuotation:_Quotation)

		For nMoeda := 1 To Len(aMoedas)

			cMoeda  := aMoedas[nMoeda][1]
			cCampoTX:= aMoedas[nMoeda][2]

			oExecAuto := EExecAuto():New()
			oRec      := ERec():New()

			/* Tratamento para Data */
			cData := AllTrim(StrZero(Val(EasyGetXMLinfo(,oBusinessCont:_Period, "_Year")),4)) + AllTrim(StrZero(Val(EasyGetXMLinfo(,oBusinessCont:_Period, "_Month")),2)) + AllTrim(StrZero(Val(EasyGetXMLinfo(,oBusinessCont:_ListOfQuotation:_Quotation[nCont], "_Day")),2))

			oRec:SetField("YE_DATA"  , SToD(cData) ) //Data

			oRec:SetField("YE_MOEDA" , AVKey(cMoeda,"YE_MOEDA") ) //Moeda

			If !Empty(cMoeda)
				//Caso exclusão, o registro é alterado com o valor zero e nao é deletado da base
				If AllTrim(Upper(oMessage:GetBsnEvent())) <> "DELETE"
					AddArrayXML(oRec, cCampoTX, oBusinessCont:_ListOfQuotation:_Quotation[nCont],"_Value" , lObrigat) //Tx.Venda / Taxa Fiscal/ Tx. Compra
				Else
					oRec:SetField(cCampoTX, 0.0)
				EndIf
			EndIf

			oExecAuto:SetField("SYE",oRec)

			//Caso exclusao, o registro é apenas alterado
			If AllTrim(Upper(oMessage:GetBsnEvent())) == "DELETE"
			   oParams := ERec():New()
			   oParams:SetField("nOpc",4)
			   oExecAuto:SetField("PARAMS",oParams)
			Endif

			oBatch:AddRec(oExecAuto)

		Next nMoeda
    Next

SYF->(DbSetOrder(nOrdSYF))
SYF->(DBGoTo(nRecSYF))
    
Return oBatch 


*-------------------------------------------------*
Function AT140ARESB(oMessage) 
*-------------------------------------------------*
Local oXml      := EXml():New()

    If !oMessage:HasErrors()
       /*oRespond:SetField('LOG'       ,"Cotacao de Moeda gravada com sucesso no ERP Protheus")
       oRespond:SetField('DateTime'  ,FwTimeStamp(3))
	   oRec:SetField('Message',oRespond)
       oXml:AddRec(oRec)*/
    Else       
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf

Return oXml


*--------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAT140.PRW                                                    *
*--------------------------------------------------------------------------*
