#INCLUDE "EECAC110.ch"
/*
Programa        : EECAC110.PRW
Objetivo        : Manutencao de Bancos (SA6)
Autor           : Cristiano A. Ferreira
Data/Hora       : 08/06/1999 10:40
Obs.            :
*/
#include "EEC.CH"

/*
Funcao		: EECAC110()
Parametros	: nenhum
Retorno		: .T.
Objetivos	: executar mbrowse
Autor		: Cristiano A. Ferreira
Data/Hora	: 08/06/99 10:41
Revisao		:
Obs.		:"Bancos"
*/
Function EECAC199(xAutoCab,xAutoItens,nOpcAuto)

EasyEnvEAI("EECAC199", 3)
Return
/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Felipe Sales Martinez - FSM
* Data: 30/11/2011
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
	
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.002")
	oEasyIntEAI:oMessage:SetMainAlias("SA6")
	oEasyIntEAI:SetModule("EIC",29)
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAC110(oEasyMessage:GetEAutoArray("SA6"),EasyEAutItens("SA6","EE3",oEasyMessage:GetEAutoArray("SA6"),oEasyMessage:GetEAutoArray("EE3"),"A6_FILIAL+'B'+AvKey(A6_COD,'EE3_CONTAT')+A6_AGENCIA"), oEasyMessage:GetOperation())} )
	
	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AC199ARECB") //RECEBIMENTO DE BUSINESS
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AC199ARESB") //RESPOSTA SOBRE O RECEBIMENTO

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

/*========================================================================================
Funcao Adapter: AC199ARECB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida
Retorno       : aExecAuto onde:
                aExecAuto[1] = Array com os dados de capa para ExecAuto
                         [1][1] = Identificador de capa ("CAB")
                         [1][2] = Id do Formulario de Capa
                         [1][3] = Array com os registros para ExecAuto 
                aExecAuto[2] = Array com os dados de detalhe para ExecAuto
                         [2][1] = Identificador de detalhe ("DET")
                         [2][2] = Id do Formulario de Detalhe
                         [2][3] = Array com os registros para ExecAuto  
Objetivos     : Montar o Array de dados da Mensagem única para inserção via ExecAuto
Autor         : Guilherme Fernandes Pilan - GFP
Data/Hora     : 12/01/2012 - 12:26
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AC199ARECB(oMessage)
*------------------------------------------------* 
Local oBusinessCont := oMessage:GetMsgContent()
Local oRec
Local oExecAuto
Local oParams   := ERec():New()
Local oBatch    := EBatch():New()
Local aAgency := {}, aAccount := {}
Local lObrigat := .T.
Local cCodERP := "", cAgencia := "", cCodVerAg := "", cConta := "", cCodVerCon := "", cFilialCta := ""
Local cCEP := ""
Local i, j, k
Local aEmpLogix := {}
Local aEmpFil := {}
Local cCompanId := ""
Local cBranchId := ""
Local cProdutct := ""

    //MPG - 06/11/2018 - Armazenar dados em Array para evitar loops repetitivos na tabela XXD
    if oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_Product <> nil ;
    .and. oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId <> nil ;
    .and. oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_BranchID <> nil

        cProdutct := oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_Product:_name:text
        cCompanId := oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId:text
        cBranchId := oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_BranchID:text
        
        aEmpFil := FWEAIEMPFIL(cCompanId,cBranchId,cProdutct)

        if len(aEmpFil) > 0
            aAdd(aEmpLogix,{cCompanId,cBranchId,aEmpFil[1],aEmpFil[2]})
        endif
    endif
    
    If IsCpoInXML(oBusinessCont,"_ListOfAgency")    
       If ValType(oBusinessCont:_ListOfAgency:_Agency) == "A"
          aAgency := oBusinessCont:_ListOfAgency:_Agency
       Else
          aAgency := {oBusinessCont:_ListOfAgency:_Agency} 
       EndIf
	ElseIf !Empty((cCodBanco := EasyGetXMLinfo("A6_COD", oBusinessCont, "_Code"))) .AND. AllTrim(Upper(oMessage:GetBsnEvent())) == "DELETE" 
	   SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	   SA6->(dbSeek(xFilial()+cCodBanco))
	   Do While SA6->(!Eof() .AND. A6_COD == cCodBanco)
	      oRec := ERec():New()
          oExecAuto := EExecAuto():New()
		  
		  oRec:LoadRec("SA6")
		  
          oExecAuto:SetField("SA6",oRec)
          oBatch:AddRec(oExecAuto)
		  
	      SA6->(dbSkip())
	   EndDo
   EndIf
    
    For i := 1 To Len(aAgency)  // Looping no array de Agencias
	
       If IsCpoInXML(aAgency[i],"_ListOfAccount") .And. IsCpoInXML(aAgency[i]:_ListOfAccount,"_Account")
          If ValType(aAgency[i]:_ListOfAccount:_Account) == "A"
             aAccount := aAgency[i]:_ListOfAccount:_Account
         Else
             aAccount := {aAgency[i]:_ListOfAccount:_Account} 
          EndIf
       EndIf

       aContatos := {}
       If IsCpoInXML(aAgency[i],"_ListOfContactInformation")
          If ValType(aAgency[i]:_ListOfContactInformation:_ContactInformation) == "A"
             aContatos := aAgency[i]:_ListOfContactInformation:_ContactInformation
          Else
             aContatos := {aAgency[i]:_ListOfContactInformation:_ContactInformation} 
          EndIf
       EndIf
       
       For j := 1 To Len(aAccount) 	// Looping no array de Contas
          
          oRec := ERec():New()
          oExecAuto := EExecAuto():New()

          AddArrayXML(oRec, "A6_COD"       , oBusinessCont ,"_Code" , lObrigat  )	// CODIGO REGISTRO

          AddArrayXML(oRec, "A6_NUMBCO"   , oBusinessCont ,"_Code"  )				// CODIGO BANCO
          AddArrayXML(oRec, "A6_NOME"     , oBusinessCont ,"_Name" , lObrigat )		// NOME BANCO
	      AddArrayXML(oRec, "A6_NREDUZ"   , oBusinessCont ,"_ShortName" )			// NOME REDUZIDO
          
          cAgencia := aAgency[i]:_Number:TEXT
          If At("-",cAgencia) > 0
             cCodVerAg  := Alltrim(SubStr(cAgencia, At("-",cAgencia)+1))               
             cAgencia := SubStr(cAgencia, 1, At("-",cAgencia)-1)
          EndIf
          
          oRec:SetField("A6_AGENCIA",AvKey(cAgencia,"A6_AGENCIA"))					// NR AGENCIA
          
          If !Empty(cCodVerAg)
             oRec:SetField("A6_DVAGE",AvKey(cCodVerAg,"A6_DVAGE"))					// DIGITO AGENCIA
          EndIf
          
		  If IsCpoInXML(aAgency[i],"_Address")
             AddArrayXML(oRec, "A6_END"      , aAgency[i]:_Address ,"_Address" )		// ENDERECO
   	         AddArrayXML(oRec, "A6_MUN"      , aAgency[i]:_Address:_City ,"_Description" )	// CIDADE
			 
   	      
   	         If IsCpoInXML(aAgency[i]:_Address,"_ZIPCode")
   	            cCEP := aAgency[i]:_Address:_ZIPCode:TEXT
   	         EndIf
   	      
   	         If !Empty(cCEP)
   	            cCEP := StrTran(cCEP , "-" , "" )
                oRec:SetField("A6_CEP",AvKey(cCEP,"A6_CEP"))								// CEP
             EndIf
   	      
   	         AddArrayXML(oRec, "A6_EST"      , aAgency[i]:_Address:_State ,"_Code" )	// ESTADO
   	    
		     cCodERP := ""
   	         If IsCpoInXML(aAgency[i]:_Address:_Country,"_Code")
   	            cCodERP := aAgency[i]:_Address:_Country:_Code:TEXT
   	         EndIf
   	      		  
		     cCodPais := EasyConvCod( cCodERP, "SYA" )
             If !Empty(cCodPais)  
                oRec:SetField( "A6_COD_P", cCodPais)				// PAIS
             EndIf 
          EndIf
		  
 	      AddArrayXML(oRec, "A6_CORRENT"  , aAccount[j] ,"_Name"  )					// CORRENTISTA
 	      
 	           
 	      cConta := aAccount[j]:_Number:TEXT
          If At("-",cConta) > 0
             cCodVerCon  := Alltrim(SubStr(cConta, At("-",cConta)+1))
             cConta := SubStr(cConta, 1, At("-",cConta)-1)
          EndIf
          
          oRec:SetField("A6_NUMCON",AvKey(cConta,"A6_NUMCON"))						// CONTA CORRENTE
          
          If !Empty(cCodVerCon)
             oRec:SetField("A6_DVCTA",AvKey(cCodVerCon,"A6_DVCTA"))					// DIGITO CONTA CORRENTE
          EndIf

          oContatos := ETab():New()
          
          For k := 1 To Len(aContatos)
            If IsCpoInXML(aContatos[k],"_Name") .And. !Empty(EasyGetXMLinfo(, aContatos[k], "_Name"))         //NCF - 11/09/2013 - Ignora Contatos sem a tag "Name" informada
                oContato := ERec():New()
                // Chave - EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL+EE3_SEQ
                oContato:SetField("EE3_CODCAD", AvKey("B","EE3_CODCAD") ) 
                oContato:SetField("EE3_CONTAT", AvKey(EasyGetXMLinfo(, oBusinessCont, "_Code"),'EE3_CONTAT') )
             
                oContato:SetField("EE3_COMPL", AvKey(cAgencia,"A6_AGENCIA") ) 

                oContato:SetField("EE3_SEQ", StrZero(k,AvSX3("EE3_SEQ",AV_TAMANHO)) )
                AddArrayXML(oContato, "EE3_NOME", aContatos[k] ,"_Name"  )
                AddArrayXML(oContato, "EE3_CARGO", aContatos[k] ,"_Title"  )
                AddArrayXML(oContato, "EE3_DEPART", aContatos[k] ,"_Department"  )

                If IsCpoInXML(aContatos[k],"_CommunicationInformation")
                   AddArrayXML(oContato, "EE3_FONE", aContatos[k]:_CommunicationInformation,"_PhoneNumber")
 				   //AddArrayXML(oRec, "EE3_FONE", aContatos[k]:_CommunicationInformation,"_PhoneExtension")
 				   AddArrayXML(oContato, "EE3_FAX", aContatos[k]:_CommunicationInformation,"_FaxNumber")
 				   //AddArrayXML(oRec, "EE3_FAX", aContatos[k]:_CommunicationInformation,"_FaxNumberExtension")
 				   //AddArrayXML(oRec, "", aContatos[k]:_CommunicationInformation,"_HomePage")
 				   AddArrayXML(oContato, "EE3_EMAIL", aContatos[k]:_CommunicationInformation,"_Email")
                EndIf
               
               oContatos:AddRec(oContato)
            Else
               Loop
            EndIf
         Next k

         aEmpFil := {}
         //MPG - 06/11/2018 - Armazenar dados em Array para evitar loops repetitivos na tabela XXD
         if IsCpoInXML(aAccount[j],"_CompanyID")
            
            IF !Empty(aAccount[j]:_CompanyID:Text)
               cCompanId := aAccount[j]:_CompanyID:Text
            endif

            if IsCpoInXML(aAccount[j],"_BranchID")
               IF !Empty(aAccount[j]:_BranchID:Text)
                  cBranchId := aAccount[j]:_BranchID:Text
               endif
            endif

            aEmpFil := FWEAIEMPFIL(cCompanId,cBranchId,cProduct)

            if len(aEmpFil) > 0
               aEmpLogix := {{cCompanId,cBranchId,aEmpFil[1],aEmpFil[2]}}
            endif
         
         endif

         if len(aEmpFil) == 0
            oMessage:Warning("Não existe cadastro De\Para para o produto: " + alltrim(cProduct) + " empresa Logix: " + alltrim(cCompanId) + " filial Logix: " + alltrim(cBranchId) )
            Loop
         endif

          //MPG - 06/11/2018 - Retirar a leitura das tabelas de framework (XX4, XXD, SXH)
          cFilialCta := Posicione("EYI", 1, xFilial("EYI")+aAccount[j]:_CompanyId:Text, "EYI_FILEXE")
          //NCF - 22/05/2014 - Quando não informada no Cadastro de empresas, pegar a filial do cadastro DE/PARA do SIGACFG posicionado pelo EAI
          If Empty(cFilialCta)
             If (nPosEmpLgx := aScan(aEmpLogix,{|x| Alltrim(x[1]) == Alltrim(aAccount[j]:_CompanyId:Text) }) ) > 0
                If Len(aEmpLogix[nPosEmpLgx][4]) > FWSizeFilial()
                   cFilialCta := Left(aEmpLogix[nPosEmpLgx][4],FWSizeFilial())
                Else
                   cFilialCta := aEmpLogix[nPosEmpLgx][4]+Space(FWSizeFilial()-Len(aEmpLogix[nPosEmpLgx][4]))
                Endif
             EndIf
          EndIf 
         
         If Empty(cFilialCta)
             oMessage:Warning('Erro ao cadastrar a conta '+AllTrim(aAccount[j]:_Number:TEXT) + ' da agência ' + AllTrim(aAgency[i]:_Number:TEXT) +', pois a empresa ' + aAccount[j]:_CompanyId:Text + ' não possui filial em seu cadastro.')
             Loop
         EndIf  
          
          oParams   := ERec():New()
          oParams:SetField("CFILANT", cFilialCta)
          oParams:SetField("cMainAlias","SA6")
          oExecAuto:SetField("PARAMS",oParams)
          oExecAuto:SetField("SA6",oRec)
          oExecAuto:SetField("EE3",oContatos)
          
          oBatch:AddRec(oExecAuto)
	   Next j
	Next i    

Return oBatch

*-------------------------------------------------*
Function AC199ARESB(oMessage) 
*-------------------------------------------------*
Local oXml      := EXml():New()

    If oMessage:HasErrors()
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf

Return oXml
*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAC110.PRW                                           *
*------------------------------------------------------------------------*
