#INCLUDE "EECAC115.ch"
/*
Programa        : EECAC115.PRW
Objetivo        : Manutencao de exportadores/fornecedores/fabricante (SA2)
Autor           : Heder M Oliveira
Data/Hora       :
Obs.            :
*/
#include "EEC.CH"
#COMMAND E_RESET_AREA => SA2->(DBSETORDER(1))

/*
Funcao      : EECAC115()
Parametros  : nenhum
Retorno     : .T.
Objetivos   : executar mbrowse
Autor       : Heder M Oliveira
Data/Hora   : 09/12/98 10:25
Revisao     :
Obs.        :"Exportador/Fornecedor/Fabricante"
*/
Function EECAC115(xAutoCab,xAutoItens,nOpcAuto)
   Local lRet:=.T.,cOldArea:=select(),cAlias:="SA2"
   Private cCadastro:=AVTITCAD("SA2"),cTipoCad:=CD_SA2
   Private aRotina := MenuDef()
   
   // GFP - 09/12/11 - Tratamento ExecAuto
   Private lExecAuto := xAutoCab <> NIL
   Private aAutoCab
   Private aAutoEE3 := {}
   // ***

   Begin sequence
      (cAlias)->(DBSETORDER(1))
      
      //GFP - 09/12/2011 - Tratamento ExecAuto
      If !lExecAuto
         // *** Processamento via Interface
         mBrowse( 6, 1,22,75,cAlias)
      Else
         // *** Processamento via rotina automática (MsExecAuto).
         aAutoCab   := xAutoCab
         aAutoEE3 := xAutoItens
         MBrowseAuto(nOpcAuto, aAutoCab, cAlias,, .T.)
      EndIf
      
   End sequence
   dbselectarea(cOldArea)
Return lRet

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 17/01/07 - 15:50
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina :=   { { STR0001,   "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
                     { STR0002,   "AC115MAN"  , 0 , VISUALIZAR},; //"Visualizar"
                     { STR0003,   "AC115MAN"  , 0 , INCLUIR},; //"Incluir"
                     { STR0004,   "AC115MAN"  , 0 , ALTERAR},; //"Alterar"
                     { STR0005,   "AC115MAN"  , 0 , EXCLUIR,3} } //"Excluir"


//LGS-04/09/2015 - Tabela de/Para - FIERGS
//7 - Exportador
IF AvFlags("TABELA_DE_PARA_FIERGS")
   aaDD(aRotina,{STR0012, 'TE110Inclui("7",SA2->(A2_COD+A2_LOJA))'  , 0 , 4}) //Tabela de/Para
EndIf

//THTS - 17/03/2017 - Adiantamento para Fornecedor com integração Logix ativada
If AvFlags("ADTFOREAI") 
	aAdd(aRotina,{STR0014,'EECAC116',0,6}) //Adiantamento
EndIf  

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAC115MNU")
	aRotAdic := ExecBlock("EAC115MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf 

Return aRotina

/*
Funcao      : AC115MAN()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Heder M Oliveira
Data/Hora   :
Revisao     :
Obs.        :
*/
Function AC115MAN(cAlias,nReg,nOpc)
   Local lRet:=.T.,cOldArea:=select(),nOLDORDER:=INDEXORD(),oDlg,nInc,bVal_OK
   Local lGravaOK:=.T.,nOpcA:=3,bCancel
   
   Local aButtons := {}
   
   Private oEnch1
   
   Private nOpcRdm115:= nOpc  //TRP - 02/04/2012 - Variável utilizada em rdmake.
   
   Private aTela[0][0],aGets[0],nUsado:=0
   Private cNomArq
   Private nPosA2 := 0
   Begin Sequence

      bCancel := {|| If(!lExecAuto,oDlg:End(),) } //GFP - 12/12/11
   
      IF nOpc == INCLUIR
         //criar variaveis
         For nInc := 1 TO (cAlias)->(FCount())
            M->&((cALIAS)->(FIELDNAME(nInc))) := CRIAVAR((cALIAS)->(FIELDNAME(nInc)))
         Next nInc
         
         If EECFLAGS("INTTRA") .Or. AvFlags("EEC_LOGIX")  // GFP - 16/01/2012 - Integração Logix
            RegToMemory("EYI",.T.) // Para criar os virtuais (Dados Complementares de Exportador)        
         EndIf
   
         // GFP - 09/12/2011 - Tratamento ExecAuto            
         bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. AC175VldOk() .AND. AC115Valid(),(nOpcA:=1,If(!lExecAuto,oDlg:End(),)),nOpca:=0)}  
      
         M->A2_LOJA := IF(EMPTY(M->A2_LOJA),AvKey(".","A2_LOJA"),M->A2_LOJA)
      Else
         For nInc := 1 TO (cALIAS)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
         Next nInc
         
         //ER - 14/08/2007
         If EECFLAGS("INTTRA") .Or. AvFlags("EEC_LOGIX")  // GFP - 16/01/2012 - Integração Logix
            EYI->(DbSetOrder(1))
            If EYI->(DbSeek(xFilial("EYI")+M->A2_COD+M->A2_LOJA))
               RegToMemory("EYI",.T.) // Para criar os virtuais
               For nInc := 1 TO EYI->(FCount())
                   M->&(EYI->(FieldName(nInc))) := EYI->(FieldGet(nInc))
               Next
            Else
               RegToMemory("EYI",.T.) // Para criar os virtuais
            EndIf
         EndIf
                  
         If nOpc = VISUALIZAR
            // GFP - 09/12/2011 - Tratamento ExecAuto             
            bVal_OK:={|| If(!lExecAuto,oDlg:End(),)}
         ElseIf nOpc==ALTERAR
            //GFP - 09/12/2011 - Tratamento ExecAuto
            bVal_OK:={||If(Obrigatorio(aGets,aTela).AND. AC115Valid(),(nOpcA:=2,If(!lExecAuto,oDlg:End(),)),nOpca:=0)}
            If ! SA2->(Reclock("SA2",.F.))  // By JPP - 18/04/2005 - 10:10 - Bloquear o registro durante a alteração.
               Break
            EndIf
         ElseIf nOpc = EXCLUIR
                IF ! INTEGREF("SA2")
                   BREAK
                ENDIF
                //GFP - 09/12/2011 - Tratamento ExecAuto
                bVal_OK:={||nOpca:=0,AC115MANE(nOpc),If(!lExecAuto,oDlg:End(),)}
                If ! SA2->(Reclock("SA2",.F.))  // By JPP - 18/04/2005 - 10:10 - Bloquear o registro durante a Exclusão.
                   Break
                EndIf
         EndIf
      Endif
      
      If EECFlags("INTTRA") .Or. AvFlags("EEC_LOGIX")  // GFP - 16/01/2012 - Integração Logix
         aAdd(aButtons,{"BMPTABLE",{|| EYIMAN("EYI",nReg,nOpc)},"Dados Complementares","D.Compl"}) //"Dados Complementares"### "D.Compl"
      EndIf
      
      // Work dos Contatos ...
      bProc := {|| EE3Manut(nOpc,cTipoCad,AC_WK,{M->A2_COD,M->A2_LOJA}) }
      If !lExecAuto
         Processa(bProc)
      Else
         Eval(bProc)
      EndIf
      
      Private l020Auto := If(Type("l020Auto") == "U",.T.,l020Auto)
      While ( nOpca>=3 )
         nOpcA:=0         
         aTela := {}
         aGets := {}
          
         // GFP - 09/12/2011 - Tratamento ExecAuto 
         If !lExecAuto
            DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
          
               oEnch1 := MsMGet():New( cAlias, nReg, nOpc,,,,,PosDlgUp(oDlg))
               
               //******* IMPORTANTE *******//
               //THTS - 13/01/2022 - OSSME-6528 - ALTERAÇÃO EFETUADA EM CARATER DE URGÊNCIA. 
               //       ESTE TIPO DE MANIPULAÇÃO NÃO DEVE SER EFETUADA SEM A AUTORIZAÇÃO DE UM SUPERIOR
               //**************************//
               If Upper("FWFldGet") $ Upper(GetCBSource(AvSX3("A2_COD_MUN")[7])) .And. (nPosA2 := aScan(oEnch1:AENTRYCTRLS,{|x|  "A2_COD_MUN" $ x:cReadVar})) > 0 //Valid do dicionario de campos
                  oEnch1:AENTRYCTRLS[nPosA2]:bValid := {|x,lResValid,o| o := oEnch1:aEntryCtrls[nPosA2],(lResValid := If(o:lModified .or. (o:Cargo <> NIL .and. o:Cargo <> M->A2_COD_MUN),If((ExistCpo("CC2", M->A2_EST + M->A2_COD_MUN, 1)),(oEnch1:EnchExecTrig('A2_COD_MUN'),.T.),.F.),.T.)),(If(Type('lRefresh') == 'L' .and. lRefresh,oEnch1:EnchRefreshAll(),)),lResValid}
               EndIf

               // MsSelect Contatos ...
               EE3Manut(nOpc,cTipoCad,AC_MS,{oDlg,M->A2_COD})
               oDlg:lMaximized := .T.
            ACTIVATE MSDIALOG oDlg ON INIT (EE3Manut(nOpc,cTipoCad,AC_IN,{oDlg,bVal_OK,bCancel,M->A2_COD, aButtons}), oEnch1:oBox:Align := CONTROL_ALIGN_TOP)
         Else
            If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets, aTela) }, nOpc)
               If Len(aAutoEE3) > 0
                  aEval(aAutoEE3, {|x| If(!lMsErroAuto, EE3Manut(nOpc,cTipoCad,"EXECAUTO", {M->A2_COD,M->A2_LOJA,x}), ) })
               EndIf
               Eval(bVal_Ok)
            Else
               Eval(bCancel)
            EndIf                 
         EndIf 
       
         Do Case
            Case nOpca==0
                 SA2->(MSUnlock()) // By JPP - 18/04/2005 - 10:10 
            Case nOpca==1
               Begin Transaction
                  bProc := {||lGravaOk:=AC115Grava(.T.,nOpc)}
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
            Case nOpca==2
               SYF->(dbgoto(nReg))  //soh p/confirmar
               bProc := {||lGravaOk:=AC115Grava(.F.)}
			   If !lExecAuto
				  Processa(bProc)
			   Else
				  Eval(bProc)
			   EndIf
         EndCase
      Enddo
      // Fecha e Apaga Work de Contatos ...
      EE3Manut(nOpc,cTipoCad,AC_ER)
   End Sequence
   
   E_RESET_AREA
   
   dbselectarea(cOldArea)
   dbsetorder(nOLDORDER)
   
Return lRet

Function EYIMAN(cAlias, nReg, nOpc)
Local lRet := .t.
Local aPos := {}
Local bOk     := {|| oDlg:End()},;
      bCancel := {|| oDlg:End()}
Local oDlg
Local aCposInttra := {"EYI_CODIN ","EYI_NOMEIN"}, aCposLogix := {"EYI_EMPEXE","EYI_FILEXE"}
Local aCampos := {}

Private cTitulo:= AvTitCad(cAlias)
Private aTela[0][0],aGets[0]

Begin Sequence

// GFP - 16/01/2012 - Tratamento de Exibição de Campo
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
Do While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cAlias
   If X3Uso(SX3->X3_USADO)
      If !EECFlags("INTTRA") .and. aScan(aCposInttra, SX3->X3_CAMPO) > 0
         SX3->(DbSkip())
         Loop
      EndIf

      If !AvFlags("EEC_LOGIX") .and. aScan(aCposLogix, SX3->X3_CAMPO) > 0
         SX3->(DbSkip())
         Loop
      EndIf
      aAdd(aCampos, SX3->X3_CAMPO)
   EndIf
   SX3->(DbSkip())
EndDo

   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel
      aPos:= PosDlg(oDlg)
      EnChoice(cAlias,nReg,nOpc,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCampos,aPos,/*aCpos*/,/*nModelo*/,/*nColMens*/,;
                /*cMensagem*/,/*cTudoOk*/,/*oWnd*/,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/,;
                /*aCampos*/,/*aFolder*/,/*lCreate*/,/*lNoMDIStrech*/,/*cTela*/)
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

Return lRet

/*
Funcao      : AC115MANE(nOpc)
Parametros  : nOpc
Retorno     : .T.
Objetivos   : Excluir Registros
Autor       : Heder M Oliveira
Data/Hora   : 07/12/98 14:16
Revisao     :
Obs.        :
*/
Static Function AC115MANE(nOpc)
   Local lRet:=.T.,cOldArea:=select()
    
   Begin sequence
      // GFP - 09/12/2011 - Tratamento ExecAuto
      if lExecAuto .OR. Msgnoyes(STR0006,STR0007) //"Confirma Exclusão?"###"Atenção"
         Reclock("SA2",.F.)
         
         //GFP - 17/12/2012 - Validações de Exclusão.
         If !AC115ValDel()
            Break
         EndIf
         
         //ER - 14/08/2007 - Exclusão dos Dados Complementares
         If EECFLAGS("INTTRA") .Or. AvFlags("EEC_LOGIX")  // GFP - 16/01/2012 - Integração Logix
            EYI->(DbSetOrder(1))
            If EYI->(DbSeek(xFilial("EYI")+M->A2_COD+M->A2_LOJA))
               EYI->(RecLock("EYI",.F.))
               EYI->(DbDelete())
               EYI->(MsUnlock())
            EndIf
         EndIf
            
         // Work dos Contatos ...
         bProc := {|| EE3Manut(nOpc,cTipoCad,AC_DE,{M->A2_COD,M->A2_LOJA}) }
		 If !lExecAuto
            Processa(bProc)
	     Else
	        Eval(bProc)
         EndIf
         
         //ER - 16/05/2007
         If EasyEntryPoint("EECAC115")
            ExecBlock("EECAC115",.F.,.F.,{"EXCLUI"})
         EndIf
           
         SA2->(DBDELETE())
         SA2->(MsUnlock())
      endif
   End Sequence
   dbselectarea(cOldArea)
   
Return lRet

/*
Funcao      : AC115Grava(lGrava,nOpc)
Parametros  : lGrava:= .T. - append blank
                       .F. - replace
              nOpc
Retorno     : .T.
Objetivos   : Gravar Header e mensagens
Autor       : Heder M Oliveira
Data/Hora   : 20/11/98 09:38
Revisao     :
Obs.        :
*/
Static Function AC115Grava(lGrava,nOpc)
    Local lRet:=.T.,cOldArea:=select()
    
    Begin sequence
        E_Grava("SA2",lGrava)
        
        //ER - 14/08/2007 - Gravação dos Dados Complementares
        If EECFLAGS("INTTRA") .Or. AvFlags("EEC_LOGIX")  // GFP - 16/01/2012 - Integração Logix
           EYI->(DbSetOrder(1))
           If EYI->(DbSeek(xFilial("EYI")+AvKey(M->A2_COD,"EYI_COD")+AvKey(M->A2_LOJA,"EYI_LOJA"))) //MCF - 05/08/2016
              
              EYI->(RecLock("EYI",.F.))
              
              AvReplace("M","EYI")
              
              EYI->(MsUnlock())
           
           Else
              
              EYI->(RecLock("EYI",.T.))
              
              AvReplace("M","EYI")
              EYI->EYI_FILIAL := xFilial("EYI")
              EYI->EYI_COD    := M->A2_COD
              EYI->EYI_LOJA   := M->A2_LOJA
          
              EYI->(MsUnlock())
   
           EndIf
        EndIf
        
        // Work dos Contatos ...
        EE3Manut(nOpc,cTipoCad,AC_GR,{M->A2_COD,M->A2_LOJA})
        
        //ER - 16/05/2007
        If EasyEntryPoint("EECAC115")
           ExecBlock("EECAC115",.F.,.F.,{"GRAVA",nOpc})
        EndIf

    End sequence
    dbselectarea(cOldArea)
    
Return lRet
              
Static Function AC115Valid()

Private lRet115:= .T.
//LRS - 13/10/2016 - Correção da validação olhando se existe o campo.
If nModulo == 85 .AND. EasyGParam("MV_ESS0027",,9) >= 10 
	IF (SA2->(FieldPos("A2_NIFEX")) > 0 .And.(!Empty(M->A2_NIFEX))) .AND. (SA2->(FieldPos("A2_MOTNIF")) > 0 .AND. !Empty(M->A2_MOTNIF)) ;
	.OR. (SA2->(FieldPos("A2_NIFEX")) > 0 .And.(Empty(M->A2_NIFEX))) .AND. (SA2->(FieldPos("A2_MOTNIF")) > 0 .AND. Empty(M->A2_MOTNIF))
	   EasyHelp(STR0013,STR0007) // "Somente é possível preencher o campo 'Mot.NIF' caso o NIF não seja informado." ## "Aviso"
	   Return .F.
	EndIf
EndIF

If EasyEntryPoint("EECAC115")
   ExecBlock("EECAC115",.F.,.F.,{"VALIDA_GRAVACAO"})
EndIf

Return lRet115

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Guilherme Fernandes Pilan - GFP
* Data: 09/12/2011 - 14:00 hs
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI


	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SA2")
	oEasyIntEAI:SetModule("EEC",29)
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAC115(oEasyMessage:GetEAutoArray("SA2"),EasyEAutItens("SA2","EE3",oEasyMessage:GetEAutoArray("SA2"),oEasyMessage:GetEAutoArray("EE3"),"A2_FILIAL+'X'+AvKey(A2_COD,'EE3_CONTAT')+AvKey(A2_LOJA,'EE3_COMPL')"), oEasyMessage:GetOperation())} ) // X
	
	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AC115ARECB") //Recebimento de Business
	
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AC115ARESB") //Resposta sobre o Recebimento

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()

/*========================================================================================
 Funcao Adapter: AC115ARECB
 Parametros    : oMessage - Objeto XML com conteúdo da tag "BusinessContent" recebida
 Retorno       : oBatch  - Objeto para geração de ExecAuto
 Objetivos     : Montar o Array de dados da Mensagem única para inserção via ExecAuto
 Autor         : Guilherme Fernandes Pilan - GFP
 Data/Hora     : 22/12/2011 - 15:47 hs 
 Revisao       : 
 Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AC115ARECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch         := EBatch():New()
Local oExecAuto      := EExecAuto():New()
Local oRec            := ERec():New()
Local lObrigat := .T.
Local cCEP := "", cCNPJ := "", cCP := "", cTel := "", cDDD := "", cPais := ""
Local aContatos := {}, k
Local oContatos, oContato

    AddArrayXML(oRec, "A2_COD", oBusinessCont, "_Code" , lObrigat)//Codigo
    oRec:SetField("A2_LOJA", AvKey(".","A2_LOJA" )) //Loja
    AddArrayXML(oRec, "A2_NOME", oBusinessCont, "_CorporateName", lObrigat)	// Razao Social    
    AddArrayXML(oRec, "A2_NREDUZ", oBusinessCont, "_FancyName", lObrigat)//Nome Fanta

    cCNPJ := EasyGetCommonValue(oBusinessCont, "CNPJ")
    oRec:SetField("A2_CGC", AvKey(  cCNPJ, "A2_CGC" ) ) // CNPJ/CEP
    
    If SA2->(FieldPos("A2_NIFEX")) > 0 .AND. !Empty(EasyGetCommonValue(oBusinessCont, "NIF"))
       oRec:SetField("A2_NIFEX", AvKey(EasyGetCommonValue(oBusinessCont, "NIF"),"A2_NIFEX") ) //CNPJ/CPF
    EndIf
    
    oRec:SetField("A2_TIPO", AvKey("J","A2_TIPO")) //Tipo //J=Juridico
    oRec:SetField("A2_ID_FBFN", AvKey("4","A2_ID_FBFN"))//Identificac. //3-Exportadores    

    If IsCpoInXML(oBusinessCont, "_Address")
	    AddArrayXML(oRec, "A2_END", oBusinessCont:_Address, "_Address", lObrigat)//Endereço
	    AddArrayXML(oRec, "A2_EST", oBusinessCont:_Address:_State, "_Code", lObrigat)//Estado    
	    AddArrayXML(oRec, "A2_MUN", oBusinessCont:_Address:_City, "_Description", lObrigat)//Municipio
	    AddArrayXML(oRec, "A2_NR_END", oBusinessCont:_Address ,"_Number")//Numero
	    AddArrayXML(oRec, "A2_COMPLEM"  , oBusinessCont:_Address, "_Complement")	//Complemento
	    
	    cCEP  := EasyFromTo( oBusinessCont:_Address, "_ZIPCode", "SEM_CARACTER_ESPECIAL")
		oRec:SetField("A2_CEP", AvKey( cCEP, "A2_CEP" ) ) //CEP
		
        cCP := EasyFromTo( oBusinessCont:_Address, "_POBox", "SEM_CARACTER_ESPECIAL")		
	    oRec:SetField("A2_CX_POST", AvKey( cCP, "A2_CX_POST" ) ) //Caixa Postal    

   		If IsCpoInXML(oBusinessCont_Address, "_Country")
        	cPais := EasyConvCod( EasyGetXMLInfo(, oBusinessCont:_Address:_Country, "_Code"), "SYA" )
	    	If !Empty(cPais)
			   oRec:SetField("A2_PAIS", AvKey(  cPais, "A2_PAIS" ) ) //Pais
			EndIf
	    EndIf
	EndIf

    If IsCpoInXML(oBusinessCont, "_ContactInformation") .And. IsCpoInXML(oBusinessCont:_ContactInformation,"_CommunicationInformation") 
    	
    	cTel := AllTrim( EasyFromTo( oBusinessCont:_ContactInformation:_CommunicationInformation, "_PhoneNumber", "SEM_CARACTER_ESPECIAL") ) //Retorno -> (XX) XXXXXXXX
    	cFax := AllTrim( EasyFromTo( oBusinessCont:_ContactInformation:_CommunicationInformation, "_FaxNumber", "SEM_CARACTER_ESPECIAL") ) //Retorno -> (XX) XXXXXXXX

	    If !Empty(cTel)
	       nInicio :=  At("(", cTel)+1
	       nFim := (At(")", cTel)-1) - At("(", cTel)
	       
	       /* Tratamento para o DDD */
	       cDDD := AllTrim( SubStr(cTel, nInicio, nFim  ) ) //DDD
	       
	       nInicio := At( ")", cTel)+1 
	       cTel := AllTrim( Right(cTel, 8 ) ) //Telefone Retorno -> XXXXXXXX
	       
	    EndIf    
	    If !Empty(cFax)
	       nInicio :=  At("(", cFax)+1
	       nFim := (At(")", cFax)-1) - At("(", cFax)
	       
	       /* Tratamento para o DDD */
	       If Empty(cDDD)
	          cDDD := AllTrim( SubStr(cFax, nInicio, nFim ) ) //DDD
	       EndIf
	       
	       nInicio := At(")", cFax)+1
	       cFax := AllTrim( Right(cfax, 8 ) ) //Telefone Retorno -> XXXXXXXX
	    EndIf
    	AddArrayXML(oRec, "A2_EMAIL"  , oBusinessCont:_ContactInformation:_CommunicationInformation, "_Email") //Email
    	AddArrayXML(oRec, "A2_HPAGE"  , oBusinessCont:_ContactInformation:_CommunicationInformation, "_HomePage") //Home-Page
    	oRec:SetField("A2_DDD", AvKey(cDDD,"A2_DDD")) //DDD
	    oRec:SetField("A2_TEL", AvKey(cTel,"A2_TEL")) //Telefone
	    oRec:SetField("A2_FAX", AvKey(cFax,"A2_FAX")) //FAX
    EndIf

	aContatos := {}
	If IsCpoInXML(oBusinessCont,"_ListOfContacts") .And. IsCpoInXML(oBusinessCont:_ListOfContacts,"_Contact")
		If ValType(oBusinessCont:_ListOfContacts:_Contact) == "A"
			aContatos := oBusinessCont:_ListOfContacts:_Contact
		Else
			aContatos := {oBusinessCont:_ListOfContacts:_Contact} 
		EndIf
	EndIf

    oContatos := ETab():New()
	For k := 1 To Len(aContatos)
		oContato := ERec():New()
		// Chave - EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL+EE3_SEQ
		oContato:SetField("EE3_CODCAD", AvKey("X","EE3_CODCAD") ) 
		oContato:SetField("EE3_CONTAT", AvKey(EasyGetXMLinfo(, oBusinessCont, "_Code"),'EE3_CONTAT') )
		oContato:SetField("EE3_COMPL", AvKey(".","EE3_COMPL") ) 

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
	Next k
          
    oExecAuto:SetField("SA2",oRec)
    oExecAuto:SetField("EE3",oContatos)
    oBatch:AddRec(oExecAuto)

Return oBatch 


/* ============================================================*
* Função     : AC115ARESB
* Parametros : oMessage
* Objetivo   : Mensagem de retorno com o resultado da integracao 
* Autor      : Felipe Sales Martinez - FSM
* Data       : 06/01/2012 - 11:52 hs
* Revisao    :   
* Obs        : 
* =============================================================*/
*-------------------------------------------------*
Function AC115ARESB(oMessage) 
*-------------------------------------------------*
//Local oXml      := EXml():New()
Local oRespond 

    If !oMessage:HasErrors()
       /*if oMessage:GetOperation() == 3
          cRet := "Exportador incluido com sucesso no Easy Export Control."
       Elseif oMessage:GetOperation() == 4
          cRet := "Exportador alterado com sucesso no Easy Export Control."
       Elseif oMessage:GetOperation() == 5
          cRet := "Exportador excluido com sucesso no Easy Export Control."
       Else
          cRet := "Exportador processado com sucesso no Easy Export Control."
       EndIf
    
       oRespond:SetField('LOG'       ,cRet)
       oRespond:SetField('DateTime'  ,FwTimeStamp(3))
	   oRec:SetField('Message',oRespond)
       oXml:AddRec(oRec)*/ 
       oRespond  := ENode():New() 
       oRespond:SetField('ExternalCode',SA2->A2_COD)
    Else       
       //oXMl := oMessage:GetContentList("RESPONSE")
       oRespond := oMessage:GetContentList("RESPONSE")
    EndIf

Return oRespond

/*
Programa   : AC115ValDel
Objetivo   : Validações de vinculação de fornecedores
Retorno    : lRet - .T./.F.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 17/12/2012 - 17:06
Obs.       : 
*/
*------------------------*
Function AC115ValDel()    
*------------------------*
Local lRet := .T., lTop
Local aOrd := SaveOrd({"EYY","EYU","EYS","EYI"})
Local cCod := M->A2_COD, cLoja := M->A2_LOJA, cQuery := ""

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

   Begin Sequence
   
      /******************************************************************************************/
      /******************************* NOTAS FISCAIS DE REMESSA *********************************/
      /******************************************************************************************/
      If lTop
         cQuery := ""     // GFP - 17/01/2013
         cQuery += "SELECT EYY_FILIAL, EYY_FORN, EYY_FOLOJA "
         cQuery += " FROM " + RetSqlName("EYY")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
         If FWModeAccess("SA2") == "E"
            cQuery += " EYY_FILIAL = '" + xFilial("EYY") + "' AND "
         EndIf
         cQuery += " EYY_FORN = '" + cCod + "' AND EYY_FOLOJA = '" + cLoja + "' "
      
         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EYY", .T., .T.)
      
         If !(WK_EYY->(Eof()) .AND. WK_EYY->(Bof()))
            EasyHelp(STR0009) //"Este registro está vinculado a uma Nota Fiscal de Remessa."
            lRet := .F.
            Break
         EndIf      
      Else
         EYY->(DbGoTop())
         Do While EYY->(!Eof()) .AND. EYY->YW_FILIAL == xFilial("EYY")
            If EYY->EYY_FORN == cCod .AND. EYY->EYY_FOLOJA == cLoja
               EasyHelp(STR0009) //"Este registro está vinculado a uma Nota Fiscal de Remessa."
               lRet := .F.
               Break
            EndIf
            EYY->(DbSkip())
         EndDo
      EndIf
      
      /******************************************************************************************/
      /**************************** DADOS FABR. ITENS EMBARQUE EXP ******************************/
      /******************************************************************************************/
      If lTop
         cQuery := ""     // GFP - 17/01/2013
         cQuery += "SELECT EYU_FILIAL, EYU_FABR, EYU_FA_LOJ "
         cQuery += " FROM " + RetSqlName("EYU")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
         If FWModeAccess("SA2") == "E"
            cQuery += " EYU_FILIAL = '" + xFilial("EYU") + "' AND "
         EndIf
         cQuery += " EYU_FABR = '" + cCod + "' AND EYU_FA_LOJ = '" + cLoja + "' "
      
         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EYU", .T., .T.)
      
         If !(WK_EYU->(Eof()) .AND. WK_EYU->(Bof()))
            EasyHelp(STR0010)  //"Este registro está vinculado a um Embarque."
            lRet := .F.
            Break
         EndIf      
      Else
         EYU->(DbGoTop())
         Do While EYU->(!Eof()) .AND. EYU->YU_FILIAL == xFilial("EYU")
            If EYU->EYU_FABR == cCod .AND. EYU->EYU_FA_LOJ == cLoja
               EasyHelp(STR0010)  //"Este registro está vinculado a um Embarque."
               lRet := .F.
               Break
            EndIf
            EYU->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /************************************ CAPA DA DEREX ***************************************/
      /******************************************************************************************/
      If lTop
         cQuery := ""     // GFP - 17/01/2013
         cQuery += "SELECT EYS_FILIAL, EYS_EXPORT, EYS_LOJA "
         cQuery += " FROM " + RetSqlName("EYS")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
         If FWModeAccess("SA2") == "E"
            cQuery += " EYS_FILIAL = '" + xFilial("EYS") + "' AND "
         EndIf
         cQuery += " EYS_EXPORT = '" + cCod + "' AND EYS_LOJA = '" + cLoja + "' "
      
         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EYS", .T., .T.)
      
         If !(WK_EYS->(Eof()) .AND. WK_EYS->(Bof()))
            EasyHelp(STR0008)   //"Este registro está vinculado a um registro de DEREX."
            lRet := .F.
            Break
         EndIf      
      Else
         EYS->(DbGoTop())
         Do While EYS->(!Eof()) .AND. EYS->YS_FILIAL == xFilial("EYS")
            If EYS->EYS_EXPORT == cCod .AND. EYS->EYS_LOJA == cLoja
               EasyHelp(STR0008) //"Este registro está vinculado a um registro de DEREX."
               lRet := .F.
               Break
            EndIf
            EYS->(DbSkip())
         EndDo
      EndIf
      
      /******************************************************************************************/
      /****************************** DADOS COMPL. DE EXPORTADOR ********************************/
      /******************************************************************************************/
      // THTS - 08/06/2021 - Se for Logix ou INTRA, não consiste o cadastro, pois ele é criado automaticamente e tbm é excluído junto a exclusão do fornecedor
      If !(EECFLAGS("INTTRA") .Or. AvFlags("EEC_LOGIX") )
         If lTop
            cQuery := ""     // GFP - 17/01/2013
            cQuery += "SELECT EYI_FILIAL, EYI_COD, EYI_LOJA  "
            cQuery += " FROM " + RetSqlName("EYI")
            cQuery += " WHERE D_E_L_E_T_ <> '*' AND EYI_FILIAL = '" + xFilial("EYI") + "' AND "
            cQuery += " EYI_COD = '" + cCod + "' AND EYI_LOJA = '" + cLoja + "' "
         
            cQuery := ChangeQuery(cQuery)
            DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EYI", .T., .T.)
         
            If !(WK_EYI->(Eof()) .AND. WK_EYI->(Bof()))
               EasyHelp(STR0011) //"Este registro está vinculado a um Exportador."
               lRet := .F.
               WK_EYI->(DbCloseArea())
               Break
            EndIf      
         Else
            EYI->(DbGoTop())
            Do While EYI->(!Eof()) .AND. EYI->YI_FILIAL == xFilial("EYI")
               If EYI->EYI_COD == cCod .AND. EYI->EYI_LOJA == cLoja
                  EasyHelp(STR0011) //"Este registro está vinculado a um Exportador."
                  lRet := .F.
                  Break
               EndIf
               EYI->(DbSkip())
            EndDo
         EndIf
      EndIf

   End Sequence                 

If Select("WK_EYY") <> 0
   WK_EYY->(DbCloseArea())
EndIf
If Select("WK_EYU") <> 0
   WK_EYU->(DbCloseArea())
EndIf
If Select("WK_EYS") <> 0
   WK_EYS->(DbCloseArea())
EndIf
If Select("WK_EYI") <> 0    // GFP - 17/01/2013
   WK_EYI->(DbCloseArea())
EndIf
RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : AC115ValCpo
Objetivo   : Uso para validacao de campo
Retorno    : lRet : .T. ou .F.
Autor      : Inclusao do cabecalho - Ramon Neves Lacerda Prado - RNLP
Data/Hora  : 11/10/2019
Obs.       : 
*/
Function AC115ValCpo(cCampo)
Local lRet := .T.

Do Case
   Case cCampo == "A2_ID_FBFN"
      If (lRet := ExistCpo("SX5","48"+LEFT(M->A2_ID_FBFN,1)))
         M->A2_ID_FBFN := AvKey(Posicione("SX5",1,xFilial("SX5")+"48"+LEFT(M->A2_ID_FBFN,1),"X5_DESCRI"),"A2_ID_FBFN")
      EndIf
End Case

Return lRet

/*
Programa   : AC115Gatil
Objetivo   : Uso no gatilho do campo A2_ID_FBFN
Retorno    : Conteudo a ser gatilhado ou execucao do fwFldPut quando funcao em MVC
Autor      : Ramon Neves Lacerda Prado - RNLP
Data/Hora  : 11/10/2019
Obs.       : 
*/
*------------------------*
Function AC115Gatil(cCampo)
Local aArea := getArea()
Local oModel := FWModelActive()
Local cConteu := ""
Default cCampo := "A2_ID_FBFN"

Do Case 
   case cCampo == "A2_ID_FBFN"
        If Valtype(oModel) == "O"
	        IF oModel:cId == "CUSTOMERVENDOR"
		        FwFldPut("A2_ID_FBFN",AvKey(Posicione("SX5",1,xFilial("SX5")+"48"+LEFT(M->A2_ID_FBFN,1),"X5_DESCRI"),"A2_ID_FBFN"))
	        EndIf	
        Else
	        cConteu := AvKey(Posicione("SX5",1,xFilial("SX5")+"48"+LEFT(M->A2_ID_FBFN,1),"X5_DESCRI"),"A2_ID_FBFN")
        EndIf
   case cCampo == "A2_EMAIL" .Or.cCampo == "A2_REPR_EM"                                           
        If Valtype(oModel) == "O"
           IF oModel:cId == "CUSTOMERVENDOR"
              FwFldPut(cCampo,Lower(FwFldGet(cCampo)))
           EndIf
        Else
           cCampo := "M->" + cCampo
           cConteu := Lower(&cCampo)
        EndIf
   EndCase

RestArea(aArea)
Return cConteu
*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAC115.PRW                                                  *
*------------------------------------------------------------------------*
