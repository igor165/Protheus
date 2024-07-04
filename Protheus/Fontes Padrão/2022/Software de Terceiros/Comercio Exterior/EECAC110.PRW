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
Function EECAC110(xAutoCab,xAutoItens,nOpcAuto)

   Local nOldArea:=select(),cAlias:="SA6"
   
   Private cCadastro:=AVTITCAD("SA6"),cTipoCad:=CD_SA6
   Private aRotina := MenuDef()
   
   // FSM - 08/12/11 - *** Processamento via rotina automática (MsExecAuto).
   Private lExecAuto := xAutoCab <> NIL
   Private aAutoCab
   Private aAutoEE3 := {}
   // ***

   Begin sequence
   
      (cAlias)->(DBSETORDER(1))
      // FSM - 08/12/11
      If !lExecAuto
		 // *** Processamento via Interface.
         mBrowse( 6, 1,22,75,cAlias)
      Else
		 // *** Processamento via rotina automática (MsExecAuto).
		 aAutoCab   := xAutoCab
		 aAutoEE3   := xAutoItens
		 MBrowseAuto(nOpcAuto, aAutoCab, cAlias,, .T.)
		 
      EndIf
      
   End Sequence
   
   dbselectarea(nOldArea)
  
Return .T.                     

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 17/01/07 - 16:00
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina :=  { { STR0001,   "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
                    { STR0002,   "AC110MAN"  , 0 , VISUALIZAR},; //"Visualizar"
				    { STR0003,   "AC110MAN"  , 0 , INCLUIR},; //"Incluir"
				    { STR0004,   "AC110MAN"  , 0 , ALTERAR},; //"Alterar"
				    { STR0005,   "AC110MAN"  , 0 , EXCLUIR,3} } //"Excluir"
                
//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAC110MNU")
	aRotAdic := ExecBlock("EAC110MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf               

Return aRotina

/*
Funcao		: AC110MAN()
Parametros	:
Retorno		:
Objetivos	:
Autor		: Heder M Oliveira
Data/Hora	:
Revisao		:
Obs.		:
*/
Function AC110MAN(cAlias,nReg,nOpc)
   Local nSelect := Select(), i
   Local nOrder := SA6->(INDEXORD())
   Local oDlg,nInc,bVal_OK, bCancel
   Local lGravaOK:=.T.,nOpcA:=3

   Private aTela[0][0],aGets[0],nUsado:=0
   Private cNomArq
   Private cNomArqECI
   Private lPortador := .F.
   Private lOkPortador := .T.
   //Arrays para GetDados
   Private aHeader := {}
   Private aCols   := {}
   Private aAlter  := {}
   Private aCampoEnch // By JPP - 15/03/2006 - 10:00
   Private aAC110Parm := {} //LGS-30/06/2016
   Begin Sequence
       
      IF nOpc == INCLUIR
         // ** By JBJ - 05/09/02 - 15:05
         bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. AC110VldOk(),(lOkPortador := .F.,nOpca:=1,If(!lExecAuto,oDlg:End(),)),nOpca:=3)} //FSM - 08/12/11 - ExecAuto 
	     //bVal_OK:={||nOpcA:=1,oDlg:End()}
          
         dbSelectArea(cAlias)
         For nInc := 1 TO (cAlias)->(FCount())
	        M->&(FIELDNAME(nInc)) := CRIAVAR(FIELDNAME(nInc))
	     Next nInc
            
      Else
         dbSelectArea(cAlias)
	     For nInc := 1 TO (cAlias)->(FCount())
	        M->&(FIELDNAME(nInc)) := FieldGet(nInc)
	     Next nInc
	      
         If nOpc = VISUALIZAR
	        bVal_OK:={|| If(!lExecAuto,oDlg:End(),)} //FSM - 08/12/11 - ExecAuto 
	     
	     ElseIf nOpc==ALTERAR
            // ** By JBJ - 05/09/02 - 15:10
            bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. AC110VldOk(),(lOkPortador := .F.,nOpca:=2,If(!lExecAuto,oDlg:End(),)),nOpca:=3)} //FSM - 08/12/11 - ExecAuto 
	        //bVal_OK:={||nOpca:=2,oDlg:End()}
	        If ! SA6->(Reclock("SA6",.F.))  // By JPP - 18/04/2005 - 11:55 - Bloquear o registro durante a alteração.
              Break
           EndIf  
	     
	     ElseIf nOpc = EXCLUIR
               IF ! INTEGREF("SA6")
                  BREAK
               ENDIF
               bVal_OK:={||If(AC110VldOk(), (lOkPortador := .F., nOpca:=0,AC110MANE(nOpc),If(!lExecAuto,oDlg:End(),)),)} //FSM - 08/12/11 - ExecAuto 
               If ! SA6->(Reclock("SA6",.F.))  // By JPP - 18/04/2005 - 11:55 - Bloquear o registro durante a alteração.
                  Break
               EndIf
	     EndIf
      Endif
      
      // Work dos Contatos ...
      bProc := {|| EE3Manut(nOpc,cTipoCad,AC_WK,{M->A6_COD,M->A6_AGENCIA}) }
	  If !lExecAuto
         Processa(bProc)
	  Else
	     Eval(bProc)
      EndIf

      If EasyEntryPoint("EECAC110") // By JPP - 15/03/2006 - 10:00
         ExecBlock("EECAC110",.F.,.F.,{ "PE_INI_TELA",nOpc,cAlias})
      Endif 
       
      If ValType(aCampoEnch) <> "A"
         aCampoEnch := {}
         SX3->(DbSetOrder(1))
         SX3->(DbSeek("SA6"))
         While SX3->(!Eof() .And. X3_ARQUIVO == "SA6")
            If !X3Uso(SX3->X3_USADO)
               SX3->(DbSkip())
               Loop
            EndIf
            aAdd(aCampoEnch, SX3->X3_CAMPO)
            SX3->(DbSkip())
         EndDo
      EndIf
      
      aAdd(aCampoEnch, "A6_MOEEASY")
      aAdd(aCampoEnch, "A6_CONEXP")
       
      
      While ( nOpca>=3 ) .Or. lOkPortador
         
         nOpcA:=0			
         aTela := {}
         aGets := {}
	     
	     bCancel := {||lOkPortador := .F.,nOpcA:=0,If(!lExecAuto,oDlg:End(),)} //FSM - 08/12/11 - ExecAuto 
         
         //FSM - 08/12/11 - ExecAuto 
         If !lExecAuto
	         DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
	         
	            oEnch1 := MsMGet():New(cAlias, nReg, nOpc,,,,aCampoEnch,PosDlgUp(oDlg))
	            
	            // MsSelect Contatos ...
	            EE3Manut(nOpc,cTipoCad,AC_MS,{oDlg,M->A6_COD})
	               
	            
	         ACTIVATE MSDIALOG oDlg ON INIT (EE3Manut(nOpc,cTipoCad,AC_IN,{oDlg,bVal_OK,bCancel,M->A6_COD}), oEnch1:oBox:Align :=   CONTROL_ALIGN_TOP)
	     
	     Else
	     	 For i := 1 To 10  // GFP - 25/02/2014
              If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets, aTela) }, nOpc, aCampoEnch)
                 Exit
              EndIf
           Next

			 If lRet
			    If Len(aAutoEE3) > 0
			       aEval(aAutoEE3, {|x| If(!lMsErroAuto, EE3Manut(nOpc,cTipoCad,"EXECAUTO", {M->A6_COD,M->A6_AGENCIA,x}), ) })
			    EndIf
			    Eval(bVal_Ok)
			 Else
			    Eval(bCancel)
			 EndIf
	     
	     EndIf
	          
         Do Case
            Case nOpca==0
                 SA6->(MSUnlock()) // By JPP - 18/04/2005 - 11:40
            Case nOpca==1 //.and. Obrigatorio(aGets,aTela) // ** By JBJ - 05/09/02 - 14:50
          	   Begin Transaction
          	      bProc := {||lGravaOk:=AC110Grava(.T.,nOpc)}
			      If !lExecAuto
				     Processa(bProc)
			      Else
				     Eval(bProc)
			      EndIf

          		  If !lGravaOk
          		     Help(" ",1,"A110NAORE")
       			  Else
          		     //Processa Gatilhos
          			 EvalTrigger()
          			 If __lSX8
          				ConfirmSX8()
          			 Endif
          		  EndIf
          	   End Transaction
            Case nOpca==2 // .and. Obrigatorio(aGets,aTela) // ** By JBJ - 05/09/02 - 14:55
               Begin Transaction
           	       bProc := {||lGravaOk:=AC110Grava(.F.,nOpc)}
				   If !lExecAuto
					  Processa(bProc)
				   Else
					  Eval(bProc)
				   EndIf

               End Transaction
         EndCase
      Enddo
      // Fecha e Apaga Work de Contatos ...
      EE3Manut(nOpc,cTipoCad,AC_ER)
   End Sequence
   
   SA6->(dbsetorder(nOrder))
   SA6->(dbGoTo(nReg))
    
   Select(nSelect)
    
Return NIL

/*
Funcao          : AC110MANE(nOpc)
Parametros      : nOpc
Retorno		: .T.
Objetivos	: Excluir Registros
Autor		: 
Data/Hora	: 
Revisao		:
Obs.		:
*/
Static Function AC110MANE(nOpc)
    Begin sequence
	   if lExecAuto .Or. Msgnoyes(STR0006,STR0007) //"Confirma Exclusão?"###"Atenção" //FSM - 08/12/11 - ExecAuto 
	      SA6->(Reclock("SA6",.F.))
          
          // Work dos Contatos ...
          bProc := {|| EE3Manut(nOpc,cTipoCad,AC_DE,{M->A6_COD,M->A6_AGENCIA}) }
		  If !lExecAuto
             Processa(bProc)
	      Else
	         Eval(bProc)
	      EndIf

          If EasyEntryPoint("EECAC110") // By JPP - 15/03/2006 - 10:00
             ExecBlock("EECAC110",.F.,.F.,{ "PE_EXCLUIR",nOpc})
          Endif 
		  SA6->(DBDELETE())
		  SA6->(MsUnlock())
	   Endif
    End
    
Return .T.

/*                         
Funcao		: AC110Grava(lGrava)
Parametros	: lGrava:= .T. - append blank
					   .F. - replace
Retorno		: .T.
Objetivos	: Gravar Header e mensagens
Autor		: Cristiano A. Ferreira
Data/Hora	: 08/06/99 11:06
Revisao		:
Obs.		:
*/
Function AC110Grava(lGrava,nOpc)
    Local lRet:=.T.,nInc,nYnc
	Local xVar, BVar:={||.t.}	
    
    Begin sequence
		E_Grava("SA6",lGrava)
        
        // Work dos Contatos ...
        EE3Manut(nOpc,cTipoCad,AC_GR,{M->A6_COD,M->A6_AGENCIA})
		If EasyEntryPoint("EECAC110") // By JPP - 15/03/2006 - 10:00
           ExecBlock("EECAC110",.F.,.F.,{ "PE_FIM_GRV",nOpc,lGrava})
        Endif
    End sequence
Return lRet

/*
Funcao          : AC110VldOk()
Parametros      : AC110VldOk_IncAltExc
Objetivos       : Retornar .T. ou .F. no botão Ok final na Inclusão, Alteração e Exclusão de Bancos
Autor           : Diogo Felipe dos Santos
Data/Hora       : 25/11/2010/10:00
Revisao         : Wilsimar Fabrício da Silva
Obs             :
*/      

*------------------------------*
Function AC110VldOk()
*------------------------------*
                                 
Private lValBancos := .T.

IF EasyEntryPoint("EECAC110") 
   ExecBlock("EECAC110",.F.,.F.,{"AC110VldOk_IncAltExc",lValBancos})
Endif

// MPG - 26/10/2018 - VALIDAÇÃO PARA QUE NÃO PERMITA O CADASTRO DE UM BANCO COM AS MOEDAS DIFERENTES DE ACORDO COM MÓDULOS E PARÂMETROS
if EasyGParam("MV_AVG0131",,.F.) == .T.
      if SYF->( dbsetorder(1),dbseek(xfilial("SYF")+M->A6_MOEEASY) ) .and. M->A6_MOEDA <> SYF->YF_MOEFAT
            lValBancos := .F.
            msgstop("Os campos de moeda não podem estar diferentes um do outro.","Atenção")
      endif
endif

Return lValBancos


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
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SA6")
	oEasyIntEAI:SetModule("EEC",29)
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAC110(oEasyMessage:GetEAutoArray("SA6"),EasyEAutItens("SA6","EE3",oEasyMessage:GetEAutoArray("SA6"),oEasyMessage:GetEAutoArray("EE3"),"A6_FILIAL+'B'+AvKey(A6_COD,'EE3_CONTAT')+A6_AGENCIA"), oEasyMessage:GetOperation())} )
	
	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AC110ARECB") //RECEBIMENTO DE BUSINESS
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AC110ARESB") //RESPOSTA SOBRE O RECEBIMENTO

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

/*========================================================================================
Funcao Adapter: AC110ARECB
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
Function AC110ARECB(oMessage)
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
Local cProduct := ""

   //MPG - 06/11/2018 - Armazenar dados em Array para evitar loops repetitivos na tabela XXD
   if oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_Product <> nil ;
   .and. oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId <> nil ;
   .and. oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_BranchID <> nil

         cProduct := oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_Product:_name:text
         cBranchId := oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_BranchID:text
         cCompanId := oMessage:oXML:_TOTVSMESSAGE:_MessageInformation:_CompanyId:text
         
         aEmpFil := FWEAIEMPFIL(cCompanId,cBranchId,cProduct)

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

         AddArrayXML(oRec, "A6_COD"      , oBusinessCont ,"_Code" , lObrigat  )	// CODIGO REGISTRO
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
Function AC110ARESB(oMessage) 
*-------------------------------------------------*
Local oXml      := EXml():New()

    If oMessage:HasErrors()
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf

Return oXml
*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAC110.PRW                                           *
*------------------------------------------------------------------------*
