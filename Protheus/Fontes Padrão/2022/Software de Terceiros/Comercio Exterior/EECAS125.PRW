/*
Programa : EECAS125.PRW
Autor    : Heder M Oliveira    
Data     : 22/06/99 10:46
Revisao  : 22/06/99 10:46
Uso      : Manutencao de Unidades de Medida
*/

#include "EEC.CH"
#INCLUDE "EECAS125.ch"
#COMMAND E_RESET_AREA => SAH->(DBSETORDER(1))
*--------------------------------------------------------------------
/*
Funcao		: EECAS125
Parametros	: Nenhum
Retorno		: .T.
Objetivos	: Montar browse
Autor		: Heder M Oliveira
Data/Hora	: 22/06/99 10:47
Revisao		:
Obs.		:
*/
Function EECAS125(xAutoCab,xAutoItens,nOpcAuto)
   Local lRet:=.T.,cOldArea:=select(),cAlias:="SAH"
   Private cCadastro:=AVTITCAD("SAH") //"Unidades de Medida"
   Private aRotina := MenuDef()
   
   Private lExecAuto := xAutoCab <> NIL
   Private aAutoCab
   
   If !lExecAuto
      Begin sequence
         mBrowse( 6, 1,22,75,cAlias)
      End Sequence
   Else
      aAutoCab := xAutoCab
      MBrowseAuto(nOpcAuto, xAutoCab, "SAH",,)
   EndIf
   
   dbselectarea(cOldArea)
Return lRet


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 24/01/07 - 13:51
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0001, "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
    				{ STR0002, "AS125MAN"  , 0 , VISUALIZAR},; //"Visualizar"
					{ STR0003, "AS125MAN"  , 0 , INCLUIR},; //"Incluir"
					{ STR0004, "AS125MAN"  , 0 , ALTERAR},; //"Alterar"
					{ STR0005, "AS125MAN"  , 0 , EXCLUIR,3} } //"Excluir"
					
//LGS-04/09/2015 - Tabela de/Para - FIERGS
//7 - UN_Medida
IF AvFlags("TABELA_DE_PARA_FIERGS")
   aaDD(aRotina,{STR0008, 'TE110Inclui("8",SAH->AH_UNIMED)'  , 0 , 4})//Tabela de/Para
EndIf

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAS125MNU")
	aRotAdic := ExecBlock("EAS125MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
					
/*
Funcao		: AS125MAN
Parametros	: cAlias:= alias arq.
			  nReg:=num.registro
			  nOpc:=opcao escolhida
Retorno		: .T.
Objetivos	: Manutencao com enchoice
Autor		: Heder M Oliveira
Data/Hora	: 22/06/99 10:55
Revisao		:
Obs.		:
*/
Function AS125MAN(cAlias,nReg,nOpc)
   Local lRet:=.T.,cOldArea:=select(),oDlg,nInc,bVal_OK
   Local lGravaOK:=.T.,nOpcA:=3, bCancel
	
   Private aTela[0][0],aGets[0],nUsado:=0
   Private cNomArq
	
   Begin Sequence
   
      IF nOpc == INCLUIR
		 //CRIAR VARIAVEIS
		 For nInc := 1 TO (cAlias)->(FCount())
			M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
		 Next nInc
		 
		 bVal_OK:={||If(Obrigatorio(aGets,aTela),(nOpcA:=1,If(!lExecAuto, oDlg:End(),)),nOpca:=0)}
      Else
         For nInc := 1 TO (cALIAS)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
         Next nInc
         
         If nOpc = VISUALIZAR
		    bVal_OK:={||If(!lExecAuto, oDlg:End(),)}
 		 ElseIf nOpc==ALTERAR
 		    bVal_OK:={|| If(Obrigatorio(aGets,aTela),(nOpcA:=2,If(!lExecAuto, oDlg:End(),)),nOpca:=0) }
 	 	 ElseIf nOpc = EXCLUIR
              IF ! INTEGREF("SAH")
                 BREAK
              ENDIF
              bVal_OK:={||nOpca:=0,AS125MANE(nOpc),If(!lExecAuto, oDlg:End(),)}
		 EndIf
      Endif
      
      // Work dos Idiomas ...
      bProc := {|| EE2Manut(nOpc,MC_TUNM,MO_DS,AC_WK,{M->AH_UNIMED}) }
      If !lExecAuto
         Processa(bProc)
	  Else
	     Eval(bProc)
      EndIf
	  
      While ( nOpca>=3 )
         nOpcA:=0			
         aTela := {}
         aGets := {}                
         If !lExecAuto   
		    DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      	 
      	       oEnch1 := MsMGet():New( cAlias, nReg, nOpc, , , , ,PosDlgUp(oDlg))   // ACSJ - 18/03/04
      	    
      	       // MsSelect Contatos ...
               EE2Manut(nOpc,MC_TUNM,MO_DS,AC_MS,{oDlg,M->AH_UNIMED})
              
               bCancel := {||nOpcA:=0,oDlg:End()}
			
			   oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
            
            ACTIVATE MSDIALOG oDlg ON INIT ( EE2Manut(nOpc,MC_TUNM,MO_DS,AC_IN,{oDlg,bVal_OK,bCancel,M->AH_UNIMED})) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	     Else
	        bCancel := {||nOpcA:=0}
            If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets,aTela)}, nOpc, aTela)
               Eval(bVal_Ok)
            Else
               Eval(bCancel)
            EndIf
         EndIf 
          
		 Do Case
			Case nOpca==1
                 Begin Transaction
                    bProc := {||lGravaOk:=AS125Grava(.T.,nOpc)}
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
                 SAH->(dbgoto(nReg))  //soh p/confirmar
			 	 bProc := {||lGravaOk:=AS125Grava(.F.,nOpc)}
				  If !lExecAuto
					 Processa(bProc)
				  Else
					 Eval(bProc)
				  EndIf
    	 EndCase
	  Enddo
     // Fecha e Apaga Work de Contatos ...
     EE2Manut(nOpc,MC_TUNM,MO_DS,AC_ER)
   End Sequence
   E_RESET_AREA
   dbselectarea(cOldArea)
   
Return lRet

/*
Funcao		: AS125MANE(nOpc)
Parametros	: Nenhum
Retorno		: .T.
Objetivos	: Excluir Registros
Autor		: Heder M Oliveira
Data/Hora	: 22/06/99 10:5
Revisao		:
Obs.		:
*/
Static Function AS125MANE(nOpc)
   Local lRet:=.T.,cOldArea:=select()
   
   Begin Sequence
      If lExecAuto .Or. Msgnoyes(OemtoAnsi(STR0006),Oemtoansi(STR0007)) //"Confirma ExclusÆo?"###"Aten‡Æo"
	     Reclock("SAH",.F.)
         
         // Work dos Idiomas ...
         bProc := {|| EE2Manut(nOpc,MC_TUNM,MO_DS,AC_DE,{M->AH_UNIMED}) }
		 If !lExecAuto
            Processa(bProc)
	     Else
	        Eval(bProc)
         EndIf
               
		 SAH->(DBDELETE())
		 SAH->(MsUnlock())
	  endif
   End Sequence
   
   dbselectarea(cOldArea)
   
Return lRet
*--------------------------------------------------------------------
/*
Funcao    : AS125Grava(lGrava,nOpc)
Parametros: lGrava:= .T. - append blank
					   .F. - replace
Retorno   : .T.
Objetivos : Gravar Header e mensagens
Autor	    : Heder M Oliveira
Data/Hora : 20/11/98 09:38
Revisao   :
Obs.      :
*/
Static Function AS125Grava(lGrava,nOpc)
Local lRet := .T.,cOldArea:=select(),cCOD,I,;
      aORD := SAVEORD({"EE2"}),;
      aEE2 := {{PORTUGUES,""},;
               {INGLES   ,""},;
               {ESPANHOL ,""}}
* 
Begin Sequence
   E_Grava("SAH",lGrava)
     
   // Work dos Idiomas ...
   EE2Manut(nOpc,MC_TUNM,MO_DS,AC_GR,{M->AH_UNIMED})
		
   // GRAVA DADOS P/ EIC
   SAH->(RECLOCK("SAH",.F.))
   cCOD := AVKEY(SAH->AH_UNIMED,"EE2_COD")
   FOR I := 1 TO LEN(aEE2)
       EE2->(DBSETORDER(2))
       IF (EE2->(DBSEEK(XFILIAL("EE2")+MC_TUNM+TM_GER+cCOD+aEE2[I,1])))
          aEE2[I,2] := EE2->EE2_DESCMA
       ENDIF
   NEXT
   
   // BAK - Tratamento para nao apagar a descricao
   If Empty(aEE2[1,2])
      SAH->AH_DESCPO := M->AH_DESCPO
   Else
      SAH->AH_DESCPO := aEE2[1,2] // PORTUGUES   
   EndIf

   If Empty(aEE2[2,2])
      SAH->AH_DESCIN := M->AH_DESCIN
   Else
      SAH->AH_DESCIN := aEE2[2,2] // PORTUGUES   
   EndIf

   If Empty(aEE2[3,2])
      SAH->AH_DESCES := M->AH_DESCES
   Else
      SAH->AH_DESCES := aEE2[3,2] // PORTUGUES   
   EndIf

   //SAH->AH_DESCPO := aEE2[1,2] // PORTUGUES
   //SAH->AH_DESCIN := aEE2[2,2] // INGLES
   //SAH->AH_DESCES := aEE2[3,2] // ESPANHOL
   SAH->(MSUNLOCK())
End sequence
RESTORD(aORD)
dbselectarea(cOldArea)
Return(lRet)
*--------------------------------------------------------------------
//EOF 

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
	oEasyIntEAI:oMessage:SetMainAlias("SAH")
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAS125(oEasyMessage:GetEAutoArray("SAH"),, oEasyMessage:GetOperation())} )
	oEasyIntEAI:SetModule("EEC",29)
	
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AS125ARECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AS125ARESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	//
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

*------------------------------------------------*
Function AS125ARECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch    := EBatch():New()
Local oRecSAH   := ERec():New()
Local oExecAuto := EExecAuto():New()
Local cCodERP   := EasyGetXMLinfo(,oBusinessCont, "_Code") 
Local cUniMed    := ""
Local nOrdSAH    := SAH->(INDEXORD())

   /* Tratamento para Codigo ERP da Unidade de Medida */
   If !Empty(cCodERP)
      nOrdSAH    := SAH->(INDEXORD())
      SAH->(DbSetOrder(2))
      If SAH->(DbSeek(xFilial()+AvKey(cCodERP,"AH_CODERP")))
         cUniMed    := SAH->AH_UNIMED
      ElseIf Len(cCodERP) <= 2
         cUniMed    := cCodERP
      EndIf
      SAH->(DbSetOrder(nOrdSAH))
   EndIf
   
   oRecSAH:SetField("AH_UNIMED", AvKey(cUnimed, "AH_UNIMED") ) //Codigo
   oRecSAH:SetField("AH_UMRES" , EasyGetXMLinfo("AH_UMRES", oBusinessCont, "_Description" ) )// Descricao
   oRecSAH:SetField("AH_CODERP", AvKey(cCodERP,"AH_CODERP" )) // Cod ERP
    
   oExecAuto:SetField("SAH",oRecSAH)
   oBatch:AddRec(oExecAuto) 
    
Return oBatch

*-------------------------------------------------*
Function AS125ARESB(oMessage) 
*-------------------------------------------------*
Local oXml      := EXml():New()

    If oMessage:HasErrors()     
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf
 
Return oXml

