#INCLUDE "EECAT170.ch"
#include "EEC.CH"
#include "TOPCONN.CH"

/*
Funcao      : EECAT170()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao de tipos de embalagens
Autor       : Heder M Oliveira
Data/Hora   : 04/12/98 17:11
Revisao     :
Obs.        :
*/
Function EECAT170(xAutoCab,xAutoItens,nOpcAuto,xAutItEmb)

Local lRet:=.T.,cOldArea:=select()

Private cCadastro := AVTITCAD("EE5")//"Embalagens"
Private aRotina   := MenuDef()

// Processamento via rotina automática (MsExecAuto).
Private lExecAuto := xAutoCab <> NIL
Private aAutoCab
Private aAutoEE2
Private aAutoEEK //AOM - 06/01/2012
//

EEK->(dbSetOrder(1))

Begin Sequence
	If !lExecAuto
		// Processamento via Interface.
		mBrowse(6,1,22,75,"EE5")
		//
	Else
		// Processamento via rotina automática (MsExecAuto).
		aAutoCab := xAutoCab
		aAutoEEK := If(ValType(xAutItEmb)  == "A", xAutItEmb, {})  //NCF - 13/01/2014
		aAutoEE2 := If(ValType(xAutoItens) == "A", xAutoItens, {}) //AOM - 06/01/2012
		MBrowseAuto(nOpcAuto, xAutoCab, "EE5",, .T.)
        //
	EndIf
End Sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 17/01/07 - 17:51
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina :=  {  { STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { STR0002,"AT170MAN" , 0 , 2},; //"Visualizar"
                     { STR0003,   "AT170MAN" , 0 , 3},; //"Incluir"
                     { STR0004,   "AT170MAN" , 0 , 4},; //"Alterar"
                     { STR0005,   "AT170MAN" , 0 , 5,3} } //"Excluir"

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAT170MNU")
	aRotAdic := ExecBlock("EAT170MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf                     

Return aRotina

/*
Funcao       : AT170MAN
Parametros   : cAlias:= alias arq.
               nReg:=num.registro
               nOpc:=opcao escolhida
Retorno      : .T.
Objetivos    : Executar enchice
Autor        : Heder M Oliveira
Data/Hora    : 07/06/99 17:36
Revisao      : 
Obs.         :
*/
Function AT170MAN(cAlias,nReg,nOpc)

   Local lRet:=.T.,cOldArea:=Select(),oDlg,nInc,bVal_OK
   Local lGravaOK:=.T.,bCancel := {|| If(!lExecAuto, oDlg:End(),) }
   Local cArq1,cArq2, nOpcA:=3
   Local aButtons
   Local cQry,cMsg,nEmb
   Local bEmbEEK := {|| nOpcA:= 7, AT170Embalagem(nOpc) } //AOM - 06/01/2011
   Local lAutItEmb := aAutoEEK <> Nil .And. !Empty(aAutoEEK)//AOM - 06/01/2011
   
   Private aTela[0][0],aGets[0],nUsado:=0
   Private cNomArq
   Private aHeader[0], aCampos := Array(EEK->(FCount())), aCpoEnc
   Private aDelete := {}
   Private cCodEmba:=""
   Private lBreak := .f.
    
   Begin Sequence
      // *** Cria work para relacao de embalagens
      aCampos:= Array(EEK->(FCount()))
      aSemSX3:= {{"WKRECNO","N",7,0}}
      //TRP - 26/01/07 - Campos do WalkThru
      AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
      AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
      aAdd(aSemSX3,{"DBDELETE"  ,"L",1 ,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      cArq1  := E_CriaTrab("EEK",aSemSX3,"Work")
      IndRegua("Work",cArq1+TEOrdBagExt(),"EEK_SEQ+EEK_EMB")
       
      cArq2  := CriaTrab(,.f.)
      IndRegua("Work",cArq2+TEOrdBagExt(),"EEK_EMB")
       
      dbClearInd() // Fecha os indices do Work
      dbSetIndex(cArq1+TEOrdBagExt())
      dbSetIndex(cArq2+TEOrdBagExt())
      
      IF nOpc == INCLUIR
         // CRIAR VARIAVEIS DE MEMORIA ...
         For nInc := 1 TO (cAlias)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
         Next nInc
      
         bVal_OK:={||If(Obrigatorio(aGets,aTela),(nOpcA:=1, If(!lExecAuto, oDlg:End(), )),nOpca:=0)}
      Else
         For nInc := 1 TO (cALIAS)->(FCount())
             M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
         Next nInc

         // *** Carrega work com dados do EEK ...
         AT170GrvWork()
         
         If nOpc = VISUALIZAR
            bVal_OK:={|| If(!lExecAuto, oDlg:End(),)}
         ElseIf nOpc==ALTERAR
            bVal_OK:={||If(Obrigatorio(aGets,aTela),(nOpcA:=2, If(!lExecAuto, oDlg:End(),) ),nOpca:=0)}
            If ! EE5->(Reclock("EE5",.F.))  // By JPP - 18/04/2005 - 10:45 - Bloquear o registro durante a alteração.
               Break
            EndIf
         ElseIf nOpc = EXCLUIR
                IF ! INTEGREF("EE5")
                   BREAK
                ENDIF
                
                // ** JPM - consistência para não permitir que uma embalagem que seja contenedora de outra não possa ser excluída.
                //          Foi utilizada query pois não há índice por EEK_EMB
                
                cQry := " SELECT EEK_CODIGO " +;
                           " FROM "+RetSqlName("EEK")+" EEK " + ;
                           " WHERE D_E_L_E_T_ <> '*' AND EEK_FILIAL = '" + xFilial("EEK") + "'" +;
                           " AND EEK_CODIGO <> '" + EE5->EE5_CODEMB + "'" +;
                           " AND EEK_TIPO = 'E' " +;
                           " AND EEK_PEDIDO = '" + Space(AvSx3("EEK_PEDIDO",AV_TAMANHO))+ "'" +;
                           " AND EEK_EMB = '" + EE5->EE5_CODEMB + "'"

                cQry := ChangeQuery(cQry)
                TcQuery cQry Alias "Qry" New
                cMsg := ""
                nEmb := 0
                While Qry->(!EoF())
                      nEmb++
                      cMsg += AllTrim(Qry->EEK_CODIGO) + ", "
                      Qry->(DbSkip())
                EndDo
                Qry->(DbCloseArea())

                If !Empty(cMsg)                        
                   If nEmb = 1
                      MsgInfo(StrTran(STR0013,"###",cMsg),STR0008) //"Esta embalagem está sendo utilizada na embalagem ###portanto, não poderá ser excluída." ### "Atenção"
                   Else
                      MsgInfo(StrTran(STR0012,"###",cMsg),STR0008) //"Esta embalagem está sendo utilizada nas embalagens ###portanto, não poderá ser excluída." ### "Atenção"
                   EndIf
                   lBreak := .t.
                EndIf

                //MFR 10/03/2020 OSSME-4412 Verifica se a embalagem é utilizada no cadastro de produto
                cQry := " SELECT B1_COD " +;
                           " FROM "+RetSqlName("SB1")+" SB1 " + ;
                           " WHERE D_E_L_E_T_ <> '*' AND B1_FILIAL = '" + xFilial("SB1") + "'" +;
                           " AND B1_CODEMB = '" + EE5->EE5_CODEMB + "'"

                cQry := ChangeQuery(cQry)
                TcQuery cQry Alias "Qry" New
                cMsg := ""
                nEmb := 0
                While Qry->(!EoF())
                      nEmb++
                      cMsg += AllTrim(Qry->B1_COD) + ", "
                      Qry->(DbSkip())
                EndDo
                Qry->(DbCloseArea())

                If !Empty(cMsg)                        
                   If nEmb = 1
                      MsgInfo(StrTran(STR0016,"###",cMsg),STR0008) //"Esta embalagem está sendo utilizada no produto ###portanto, não poderá ser excluída." ### "Atenção"
                   Else
                      MsgInfo(StrTran(STR0015,"###",cMsg),STR0008) //"Esta embalagem está sendo utilizada nos produtos ###portanto, não poderá ser excluída." ### "Atenção"
                   EndIf
                   lBreak := .t.
                EndIf

                cCodEmba := EE5->EE5_CODEMB
                If ExistBlock("EECAT170")
                   ExecBlock("EECAT170", .F., .F., {"VALID_EXCLUSAO"})
                EndIf
                    
                If lBreak 
                   Break
                EndIf

                bVal_OK:={||nOpca:=0,AT170MANE(nOpc), If(!lExecAuto, oDlg:End(),)}
                If ! EE5->(Reclock("EE5",.F.))  // By JPP - 18/04/2005 - 10:45 - Bloquear o registro durante a Exclusão.
                   Break
                EndIf
         EndIf
      ENDIF
      
      // Work dos Idiomas ...
      bProc := {|| EE2Manut(nOpc,MC_TEMB,MO_MM,AC_WK,{M->EE5_CODEMB}) }
	  If !lExecAuto
         Processa(bProc)
	  Else
	     Eval(bProc)
      EndIf
      
      If !EECFlags("INTTRA")
         aCpoEnc := AvCposEnc("EE5", Nil, "EE5_CODINT")//Nunca exibe o campo "EE5_CODINT", se a integração com Inttra estiver desligada.
      EndIf
      
      // aButtons := {{"DBG14",{|| nOpcA:=7,oDlg:End()},"Manut. Embalagens"}}
      aButtons := {{"CONTAINR",{|| nOpcA:=7,oDlg:End()},STR0006, STR0014}} //"Manut. Embalagens"

      While ( nOpca>=3 )
         nOpcA := 0
         aTela := {}
         aGets := {}

		If !lExecAuto
         DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

            oEnch1 := MsMGet():New(cAlias, nReg, nOpc, , , , aCpoEnc,PosDlgUp(oDlg))

            oDlg:lMaximized := .T.
           
            // MsSelect dos Idiomas ...
            EE2Manut(nOpc,MC_TEMB,MO_MM,AC_MS,{oDlg,M->EE5_CODEMB})
            oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
            
         ACTIVATE MSDIALOG oDlg;
               ON INIT ( EE2Manut(nOpc,MC_TEMB,MO_MM,AC_IN,{oDlg,bVal_Ok,bCancel,M->EE5_CODEMB,aButtons})) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		Else
			If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets,aTela)}, nOpc, aCpoEnc)
			   If Len(aAutoEE2) > 0
			      aEval(aAutoEE2, {|x| If(!lMsErroAuto, EE2Manut(nOpc,MC_TEMB,MO_MM,"EXECAUTO", {M->EE5_CODEMB, x}), ) })
			   EndIf
			    If !lMsErroAuto
   		           //AOM - 06/01/2012 - Tratamento pra executar automaticamente a manutenção de grupo de embalagens
		          If lAutItEmb 
		             Eval(bEmbEEK)
		             If !lMsErroAuto
		                Eval(bVal_Ok)
		             Else
		                Eval(bCancel)
		             EndIf
		          Else
		             Eval(bVal_Ok)
		          EndIf
			    Else
			       Eval(bCancel)
			    EndIf
			Else
			   Eval(bCancel)
			EndIf
		EndIf
                       
         Do Case
            Case nOpcA==0
                 EE5->(MSUnlock()) // By JPP - 18/04/2005 - 10:45 
                 If __lSX8
                    RollBackSXE()
                 EndIf
            Case nOpcA==1 
                Begin Transaction
                    bProc := {|| lGravaOk:=AT170Grava(.T.,nOpc),AT170GrvEEK() }
					If !lExecAuto
					   Processa(bProc)
					Else
					   Eval(bProc)
					EndIf
					
                    If !lGravaOk
                       Help(" ",1,"A110NAORE")
                       nOpca:=3 //forcar loop
                       If __lSX8
                          RollBackSXE()
                       EndIf
                    Else
                       //Processa Gatilhos
                       EvalTrigger()
                       If __lSX8
                          ConfirmSX8()
                       Endif
                    EndIf
                End Transaction
               
            Case nOpcA==2 
                EE5->(dbGoTo(nReg))
                Begin Transaction
                   bProc := {|| lGravaOk:=AT170Grava(.F.,nOpc),AT170GrvEEK() }
				   If !lExecAuto
					  Processa(bProc)
				   Else
					  Eval(bProc)
				   EndIf
                   
                   If !lGravaOk
                      Help(" ",1,"A110NAORE")
                      nOpcao:=3 // forcar llop
                      If __lSX8
                         RollBackSXE()
                      EndIf
                   Else
                      //Processa Gatilhos
                      EvalTrigger()
                      If __lSX8
                         ConfirmSX8()
                      Endif
                   EndIf
                End Transaction
                 
            Case nOpcA == 7
               AT170Embalagem(nOpc)

         EndCase
      Enddo
      // Fecha Work dos Idiomas ...
      EE2Manut(nOpc,MC_TEMB,MO_MM,AC_ER)

   End Sequence
   Work->(E_EraseArq(cArq1,cArq2))
   dbselectarea(cOldArea)
   
Return lRet

/*
Autor.....: AWR
Data/Hora.: 23/06/99 17:30
Obs. .....: Chamada do X3_VALID (EE5_CCOM)
Revisão
Autor.....: WFS - Na versão 10 o X3_VALID do campo EE5_CCOM chama a função POSITIVO().
            Esta função foi adaptada para ser chamada sempre após a confirmação da entrada de dados no cadastro
            de embalagens, para a gravação correta da String Dimensão (campo EE5_DIMENS).  
Data/Hora.: 17/10/08 11:30
*/
Function AT170dimensao()
/* WFS 17/10/2008 ------------------------------------------------------------------------------------------
Tratamento para declaração dos campos de acordo com o dicionário de dados

IF EMPTY(M->EE5_DIMENS) .AND.;
  !EMPTY(M->EE5_HALT  ) .AND.;
  !EMPTY(M->EE5_LLARG ) .AND.;
  !EMPTY(M->EE5_CCOM  )

   M->EE5_DIMENS:= ALLTRIM(STR(M->EE5_CCOM ,10,2))+" x "+;
                   ALLTRIM(STR(M->EE5_LLARG,10,2))+" x "+;
                   ALLTRIM(STR(M->EE5_HALT ,10,2))
   */                
   
   // GFP - 27/06/2012 - Retirado espaço da string " X "
   M->EE5_DIMENS:= ALLTRIM(STR(M->EE5_CCOM ,AvSx3("EE5_CCOM" , AV_TAMANHO),AvSx3("EE5_CCOM" , AV_DECIMAL)))+"X"+;
                   ALLTRIM(STR(M->EE5_LLARG,AvSx3("EE5_LLARG", AV_TAMANHO),AvSx3("EE5_LLARG", AV_DECIMAL)))+"X"+;
                   ALLTRIM(STR(M->EE5_HALT ,AvSx3("EE5_HALT", AV_TAMANHO),AvSx3("EE5_HALT", AV_DECIMAL)))
   lRefresh:=.T.  
//ENDIF          
//-----------------------------------------------------------------------------------------------WFS 17/10/2008
Return .T.

/*
Funcao       : AT130MANE(nOpc)
Parametros   : Nenhum
Retorno      : .T.
Objetivos    : Excluir Registros
Autor        : Heder M Oliveira
Data/Hora    : 25/11/98 11:22
Revisao      :
Obs.         :
*/
Static Function AT170MANE(nOpc)
   Local lRet:=.T.,cOldArea:=Select(),cFilJF:=Xfilial("EE2")
   
   Begin Sequence
   
      if lExecAuto .Or. Msgnoyes(STR0007,STR0008) //"Confirma Exclusão?"###"Atenção"
         Reclock("EE5",.F.)
         
         // Eliminar descricoes em outro idioma ...
         bProc := {|| EE2Manut(nOpc,MC_TEMB,MO_MM,AC_DE,{M->EE5_CODEMB}) }
		 If !lExecAuto
            Processa(bProc)
	     Else
	        Eval(bProc)
         EndIf
            
         IF EEK->(DBSEEK(xFilial()+OC_EMBA+EE5->EE5_CODEMB))
            While !EEK->(EOF()) .AND. ;
                  xFilial("EEK")+OC_EMBA+EE5->EE5_CODEMB == EEK->EEK_FILIAL+EEK->EEK_TIPO+EEK->EEK_CODIGO
               RECLOCK("EEK",.F.)
               EEK->(DBDELETE())
               EEK->(MsUnlock())
               EEK->(DBSKIP(1))
            Enddo
         EndIf

         EE5->(DBDELETE())
         EE5->(MsUnlock())
      endif
   End Sequence
   
   dbselectarea(cOldArea)
   
Return lRet

/*
Funcao       : AT170EEKDEL()
Parametros   : Nenhum
Retorno      : .T. se possivel deletar
               .F. se nao ha oke deletar
Objetivos    : Testar se eh possivel deletar registros no EEK
Autor        : Heder M Oliveira
Data/Hora    : 25/11/98 11:33
Revisao      :
Obs.         :
*/
/*
Static Function AT170EEKDEL()
   Local lRet:=.T.,cOldArea:=select()
   
   Begin Sequence
      If (WORK->(EOF()) .AND. WORK->(BOF()))
         HELP(" ",1,"AVG0005009") //MSGSTOP("Não existem registros para serem excluidos !","Aviso")
         lRet:=.F.
      EndIf
   End Sequence
   
   dbselectarea(cOldArea)
   
Return lRet
*/
/*
Funcao        : AT170Grava(lGrava,nOpc)
Parametros    : lGrava:= .T. - append blank
                         .F. - replace
Retorno       : .T.
Objetivos     : Gravar Header e mensagens
Autor         : Heder M Oliveira
Data/Hora     : 07/06/99 18:13
Revisao       :
Obs.          :
*/
Static Function AT170Grava(lGrava,nOpc)
   Local lRet:=.T.,cOldArea:=select()

   Begin Sequence
      // WFS 17/10/2008
      AT170dimensao()

      E_Grava("EE5",lGrava)
       
      // Gravar descricoes em outro idioma ...
      EE2Manut(nOpc,MC_TEMB,MO_MM,AC_GR,{M->EE5_CODEMB})
        
   End Sequence
    
   dbselectarea(cOldArea)
    
Return lRet

/*
Funcao        : AT170GrvWork()
Parametros    : nehum
Retorno       : NIL
Objetivos     : Gravar Work com dados do EEK
Autor         : Cristiano A. Ferreira
Data/Hora     : 06/07/99 10:13
Revisao       :
Obs.          :
*/
Static Function AT170GrvWork()

EEK->(dbSeek(xFilial()+OC_EMBA+M->EE5_CODEMB))

While !EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
      EEK->EEK_CODIGO == M->EE5_CODEMB .And. EEK->EEK_TIPO == OC_EMBA

   Work->(dbAppend())

   AvReplace("EEK","Work")
   Work->WKRECNO := EEK->(RecNo())
   Work->TRB_ALI_WT:= "EEK"
   Work->TRB_REC_WT:= EEK->(Recno())
   
   EEK->(dbSkip())
Enddo

Return NIL

/*
Funcao        : AT170GrvEEK()
Parametros    : nehum
Retorno       : NIL
Objetivos     : Gravar EEK com dados do Work
Autor         : Cristiano A. Ferreira
Data/Hora     : 06/07/99 10:47
Revisao       :
Obs.          :
*/
Static Function AT170GrvEEK()
Local nOrdEEK := 0
Local nRecEEK := 0
Local i:=0

ProcRegua(Len(aDelete)+Work->(LastRec()))
    
Work->(dbGoTop())
nRecEEK := EEK->(Recno())
nOrdEEK := EEK->(IndexOrd())

While ! Work->(Eof())

   IncProc(STR0009) //"Gravando relação de embalagens ..."

   //IF Work->WKRECNO != 0
   //   EEK->(dbGoTo(Work->WKRECNO))
   //   EEK->(RecLock("EEK",.F.))
   //Else
   //   EEK->(RecLock("EEK",.T.))
   //Endif
   EEK->(DbSetOrder(1)) // EEK_FILIAL+EEK_TIPO+EEK_CODIGO+EEK_SEQ
   IF EEK->(DbSeek(xFilial("EEK")+AvKey(OC_EMBA,"EEK_TIPO")+AvKey(M->EE5_CODEMB,"EEK_CODIGO")+AvKey(Work->EEK_SEQ,"EEK_SEQ")))
      EEK->(RecLock("EEK",.F.))
   Else
      EEK->(RecLock("EEK",.T.))
   Endif

   AvReplace("Work","EEK")
   
   EEK->EEK_FILIAL := xFilial("EEK")
   EEK->EEK_TIPO   := OC_EMBA
   EEK->EEK_CODIGO := M->EE5_CODEMB

   EEK->(MSUnlock())

   Work->(dbSkip())
Enddo

For i:=1 To Len(aDelete)
   IncProc(STR0010) //"Atualizando informações de embalagens ..."
   EEK->(dbGoTo(aDelete[i]))

   EEK->(RecLock("EEK",.F.))
   EEK->(dbDelete())
   EEK->(MSUnlock())
Next i

EEK->(DbSetOrder(nOrdEEK))
EEK->(DbGoTo(nRecEEK))

Return NIL

/*
Funcao        : AT170Embalagem()
Parametros    : nehum
Retorno       : NIL
Objetivos     : Manutencao de embalagens
Autor         : Cristiano A. Ferreira
Data/Hora     : 06/07/99 11:11
Revisao       :
Obs.          :
*/
Static Function AT170Embalagem(nOpc)
   Local oDlg, oBrw
   Local aCampoEEK:= { ColBrw("EEK_SEQ","Work"),;
                       ColBrw("EEK_EMB","Work"),;
                       ColBrw("EEK_QTDE","Work") }

   Local bOk := {|| nOpcA:=1, IF(!lExecAuto,oDlg:End(),) }   
   Local bCancel := {|| oDlg:End() }
   Local nOpcA := 3
   
   Local cNewTit:=STR0011+M->EE5_CODEMB //"Embalagens da Embalagem " 
   Local nPos := 0, i := 0
         
   Work->(dbGoTop())
      
   Begin Sequence
                     
      nOpcA := 0
      
      If !lExecAuto
       
         DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
         
            EnChoice("EE5",,3,,,,,PosDlgUp(oDlg),IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),{},),3)

            oBrw       := MsSelect():New("Work",,,aCampoEEK,,,PosDlgDown(oDlg))
            oBrw:bAval := {||IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AT170EEKMAN(VIS_DET,cNewTit,oBRW),AT170EEKMAN(ALT_DET,cNewTit,oBRW)) }
         oDlg:lMaximized := .T.
         ACTIVATE MSDIALOG oDlg;
            ON INIT AVBar(nOpc,oDlg,bOk,bCancel,ENCH_ADD,{|opc| AT170EEKMAN(opc,cNewTit,oBrw)})
            
      Else
      
        //AOM - 06/01/2012
        For i:= 1 to Len(aAutoEEK)
           If (nOpc == 4 .OR. nOpc == 5) .And. EasySeekAuto("Work", aAutoEEK[i],1,,,"EEK_SEQ")
              If (nPos := aScan(aAutoEEK[i], {|x| x[1] == "AUTDELETA" .AND. x[2] == "S" })) > 0 
                 AT170EEKMAN(EXC_DET,,,aAutoEEK[i]) //Exclusao 
              Else
                 AT170EEKMAN(ALT_DET,,,aAutoEEK[i]) //Alteração
              EndIf
           Else
              AT170EEKMAN(INC_DET,,,aAutoEEK[i]) //Inclusão
           EndIf
           Eval(bOk)
        Next i
      
      EndIf
      
   End Sequence
   
Return NIL

/*
Funcao       : AT170EEKMAN(nTipo)
Parametros   : nTipo := INC_DET/ALT_DET/EXC_DET/VIS_DET
Retorno      : .T. 
Objetivos    : Permitir manutencao de EMBALAGENS
Autor        : Cristiano A. Ferreira
Data/Hora    : 06/07/99 11:47
Revisao      :
Obs.         :
*/
Static Function AT170EEKMAN(nTipo,cNewTit,oBrw,aItEmbAut)
   Local nAreaOld := Select()
   Local oDlg,nInc,nOpcA := 0
   Local cField
   
   Private aTela[0][0], aGets[0]

   Begin Sequence
      If nTipo # INC_DET .And. Work->(EOF()) .AND. Work->(BOF())
         HELP(" ",1,"AVG0000632") //MSGINFO("Não existem registros para a manutenção !","Aviso")
         BREAK
      EndIf

      IF nTipo == INC_DET
         SX3->(DbSetOrder(2))
         For nInc := 1 TO Work->(FCount())
            cField := Work->(FieldName(nInc))
            IF cField = "DBDELETE" .Or. cField = "WKRECNO" .Or. !SX3->(DbSeek(Work->(FieldName(nInc))))
               Loop
            Endif
            M->&(cField) := CriaVar(cField)
         Next nInc
         
         M->EEK_SEQ := EEK_NextSeq()
      Else
         For nInc := 1 TO Work->(FCount())
            M->&(Work->(FIELDNAME(nInc))) := Work->(FIELDGET(nInc))
         Next nInc
      Endif
      
      //AOM - 06/01/2012 - Rotina para execução automatica
      If !lExecAuto
       
         DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

            EnChoice("EEK",,3,,,,,PosDlg(oDlg),IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)
      
         ACTIVATE MSDIALOG oDlg;
            ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,IF(Obrigatorio(aGets,aTela),oDlg:End(),nOpcA:=0)},{||oDlg:End()}))
      Else
         
         If nTipo == EXC_DET .OR. EnchAuto("EEK", aItEmbAut, {|| Obrigatorio(aGets,aTela)}, (nTipo-1), ) 
            nOpcA:=1
         EndIf
      
      EndIf     
                               
      If nOpcA # 0
         IF nTipo == EXC_DET // Exclusao
            IF Work->WKRECNO != 0
               aAdd(aDelete,Work->WKRECNO)
            Endif
            Work->(dbDelete())
         Endif

         If nTipo == INC_DET
            Work->(DBAPPEND())
         EndIf

         If ! Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
            AvReplace("M","Work")
         EndIf
         
         //AOM - 06/01/2012
         If !lExecAuto
            oBrw:oBrowse:Refresh()
         EndIf
      EndIf
   End Sequence
   
   Select(nAreaOld)
      
Return NIL

/*
Funcao       : AT170VldEEK(cCpo)
Parametros   : cCpo := Campo a ser validado
Retorno      : .T./.F. 
Objetivos    : Consistencias de campos do EEK
Autor        : Cristiano A. Ferreira
Data/Hora    : 06/07/99 14:17
Revisao      :
Obs.         : Chamado pelo SX3
*/
Function AT170VldEEK( cCpo )

Local lRet := .T.
Local nRecEE5 := EE5->(RecNo())
Local nRecWrk := Work->(RecNo())

cCpo := Upper(AllTrim(cCpo))

Begin Sequence
   DO CASE
      CASE cCpo == "EMB"
         IF M->EE5_CODEMB == M->EEK_EMB
            HELP(" ",1,"AVG0005010") //MsgStop("Código da embalagem deve ser difirente da embalagem atual !","Atenção")
            lRet := .F.
            Break
         Endif

         IF ! ExistCpo("EE5",M->EEK_EMB)
            lRet := .F.
            Break
         Endif
         
         Work->(dbSetOrder(2))
         lRet := ! Work->(dbSeek(M->EEK_EMB))
         Work->(dbSetOrder(1))
         IF ! lRet
            HELP(" ",1,"AVG0005011") //MsgStop("Embalagem já cadastrada !","Atenção")
            Break
         Endif
   ENDCASE         
End Sequence

EE5->(dbGoTo(nRecEE5))
Work->(dbGoTo(nRecWrk))

Return lRet      

/*
Funcao       : EEK_SeqNext
Parametros   : nenhum
Retorno      : cSeq := Proxima sequencia
Objetivos    : Apurar a proxima sequencia a ser cadastrada
Autor        : Cristiano A. Ferreira
Data/Hora    : 16/07/99 11:45
Revisao      :
Obs.         : 
*/
Static FUNCTION EEK_NextSeq()

LOCAL cSeq   := "00"
LOCAL nRecNo := Work->(RecNo())

Work->(dbGoBottom())
IF ! Work->(Eof())
   cSeq := StrZero(Val(Work->EEK_SEQ)+1,2)
   Work->(dbGoTo(nRecNo))
Else
   cSeq := "01"
Endif

Return cSeq

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EE5")
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAT170(oEasyMessage:GetEAutoArray("EE5"), oEasyMessage:GetEAutoArray("EE2"),oEasyMessage:GetOperation() )} )
	oEasyIntEAI:SetModule("EEC",29) 
		
	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AT170ARECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AT170ARESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

*------------------------------------------------*
Function AT170ARECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch    := EBatch():New()
Local oRecEE5   := ERec():New()
Local oRecEE2   := ERec():New()
Local oRecItEE2 := ETab():New() 
Local oExecAuto := EExecAuto():New()
Local aOrdEE5   := SaveOrd("EE5")

    AddArrayXML(oRecEE5, "EE5_CODEMB" , oBusinessCont,"_Code"         , .T.)    // CODIGO
    AddArrayXML(oRecEE5, "EE5_DESC"   , oBusinessCont,"_Description"  , .T.)	// DESCRIÇÃO DA EMBALAGEM
    AddArrayXML(oRecEE5, "EE5_PESO"   , oBusinessCont,"_Weight"       , .F.)	// PESO
    
    If (IsCpoInXML(oBusinessCont, "_Depth" ) .And. !Empty(oBusinessCont:_Depth:Text)) .Or.;
       (IsCpoInXML(oBusinessCont, "_Width" ) .And. !Empty(oBusinessCont:_Width:Text)) .Or.;
       (IsCpoInXML(oBusinessCont, "_Height") .And. !Empty(oBusinessCont:_Height:Text))
    	
       AddArrayXML(oRecEE5, "EE5_CCOM"   , oBusinessCont,"_Depth"        , .F.)			// COMPRIMENTO
       AddArrayXML(oRecEE5, "EE5_LLARG"  , oBusinessCont,"_Width"        , .F.)			// LARGURA
       AddArrayXML(oRecEE5, "EE5_HALT"   , oBusinessCont,"_Height"       , .F.)			// ALTURA
       
       oRecEE5:SetField("EE5_DIMENS", AllTrim(oBusinessCont:_Depth:Text) + " X " + AllTrim(oBusinessCont:_Width:Text) + " X " + AllTrim(oBusinessCont:_Height:Text))
    
    ElseIf IsCpoInXML(oBusinessCont, "_Volume")
       oRecEE5:SetField("EE5_CCOM"  , 1 )                                               // COMPRIMENTO
       oRecEE5:SetField("EE5_LLARG" , 1 )                                               // LARGURA
       AddArrayXML(oRecEE5, "EE5_HALT"   , oBusinessCont,"_Volume"       , .F.)			// ALTURA
       
       oRecEE5:SetField("EE5_DIMENS", AllTrim(oBusinessCont:_Volume:Text))              //NCF - 04/09/2014
       
	EndIf
	
	//NCF - 10/12/2013 - Considerar trecho somente na inclusão pois o Logix so possui uma descricao de Embalagem e a envia nas duas tags. Se alterada a descricao de embalagem 
    //                   no Protheus, em uma próxima integração a descrição alterada é sobreposta.
	EE5->(DbSetOrder(1))
	If IsCpoInXML(oBusinessCont, "_Code" ) 
	   If !EE5->(DbSeek( xFilial("EE5")+AvKey(oBusinessCont:_Code:Text,"EE5_CODEMB") ))         
	      If IsCpoInXML(oBusinessCont, "_EnglishDescription") .And. !Empty(oBusinessCont:_EnglishDescription:TEXT)
	         oRecEE2:SetField("EE2_IDIOMA"  ,  AvGetKeyID(Alltrim(EasyGParam("MV_AVG0037",, "INGLES"))) )  // IDIOMA             //NCF - 24/09/2013 - Para retornar a chave do idioma corretamente
		     AddArrayXML(oRecEE2, "EE2_VM_TEX"  , oBusinessCont,"_EnglishDescription", .T.)	          // LARGURA
	      EndIf
	   EndIf
	EndIf
	
	oRecItEE2:AddRec(oRecEE2) 

    oExecAuto:SetField("EE5",oRecEE5)
    oExecAuto:SetField("EE2",oRecItEE2)
    oBatch:AddRec(oExecAuto)
    
Return oBatch


*-------------------------------------------------*
Function AT170ARESB(oMessage) 
*-------------------------------------------------*

Local oXml      := EXml():New()

   If oMessage:HasErrors()  
      oXMl := oMessage:GetContentList("RESPONSE")
   EndIf
 
Return oXml

*--------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAT170.PRW                                             *
*--------------------------------------------------------------------------*
