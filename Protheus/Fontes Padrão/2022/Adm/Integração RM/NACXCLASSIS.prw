#Include 'Protheus.ch'
#Include 'NacXClassis.ch'

#Define NCODRM  1
#Define NCODPR  2
#Define NCOLDES 3
#Define NCOLID  4
#Define NCOLPRO 5

//-------------------------------------------------------------------
/*/{Protheus.doc} ClsNacio
Tela para amarracao de/para de nacionalidade - integracao Protheus X RM

@protected
@author   Cláudio Luiz da SIlva
@since    22/03/2013 
@version  P10
@obs
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------
Function ClsNacio()
   Local cCadastro   := STR0001 //"Amarração Nacionalidade"
   Local aCabec      := {}
   Local aDados      := {}
   Local lRet        := .T.
   Local nXi         := 0
   Local oDlg, oBrowse, oSayCRM, oBtnCan, oBtnCon

   //Cabecalho do browse
   Aadd(aCabec,{STR0002 /*"Código RM"*/,       "@!","LEFT", "S", "NAC_COD_RM"})
   Aadd(aCabec,{STR0003 /*"Código Protheus"*/, "@!","LEFT", "S", "NAC_COD_PR"})
   Aadd(aCabec,{STR0004 /*"Descrição RM"*/,    "@!","LEFT", "S", "NAC_DESCRICAO"})
   Aadd(aCabec,{STR0005 /*"ID"*/,              "",  "RIGHT","N", "NAC_ID"})
   Aadd(aCabec,{"Cod.Pr.Old",                  "@!","LEFT", "N", "NAC_COD_PR"})

   //Verifica existencia tabela de integracao
   lRet:= Tabint("INT_NACIONALIDADE")

   If lRet
      //Busca dados na tabela de integracao
      MsgRun(STR0006 /*"Buscando Nacionalidade. Aguarde..."*/,STR0007 /*"Buscando Nacionalidade"*/, {|| CursorWait(), lRet := CarDad(aCabec, @aDados), CursorArrow()})
   EndIf

   If lRet
      oDlg:= MSDIALOG():New(000, 000, 460, 560, cCadastro,,,,,,,,,.T.)

      oDlg:lMaximized := .F.
      oDlg:LEscClose  := .F.

      oGroup  := tGroup():New(10,05,205,280,STR0001 /*"Amarração Nacionalidade"*/,oDlg,,,.T.)
      oBrowse := MsBrGetDBase():New(20,10,265,175,,,, oGroup,,,,,,,,,,,, .F., "", .T.,, .F., ,, )
      oSayCRM := TSay():New( 195,010,{||STR0008 /*"Duplo Click na linha edita o registro."*/},oDlg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)

      //Cria colunas do browse
      For nXi:= 1 to Len(aCabec)
         If aCabec[nXi,4]=="S" //Apresenta no browse
            bColumn :=  &("{ || aDados[oBrowse:nAt,"+cValToChar(nXi)+"] }")
            oBrowse:AddColumn(TCColumn():New(  aCabec[nXi,1] ,bColumn , aCabec[nXi,2] ,,,  aCabec[nXi,3]  ,,.F.,.F.,,,,.F.,))
         EndIf
      Next nXi

      oBrowse:SetArray(aDados)
      oBrowse:bLDblClick:= {|| EdiReg(oBrowse,aDados)}
      oBrowse:nScrollType:= 1 // Define a barra de rolagem VCR
      oBrowse:Refresh()

      oBtnCon:=tButton():New(210,180,STR0009 /*"Confirmar"*/,oDlg,{|| ;
         Processa({|| Confirm(aDados)}, STR0010 /*"Atualizando"*/, STR0011 /*"Atualizando tabela de amarração de Nacionalidade. Aguarde..."*/,.F.), ;
         oDlg:End()},45,12,,,,.T.)
      oBtnCan:=tButton():New(210,230,STR0012 /*"Cancelar"*/ ,oDlg,{||oDlg:End()},45,12,,,,.T.)

      oDlg:lCentered := .T.
      oDlg:Activate()
   EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Tabint
Valida existencia de tabela na base intermediaria

@author    Claudio Luiz da Silva
@since     22/03/2013
@version   P10
@param     cNomTab  Nome da Tabela
@return    lRet     .T. Tabela Existente  .F. Nao existe
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo 
/*/
//------------------------------------------------------------------
Static Function Tabint(cNomTab)
   Local lRet      := .T.
   Local cMsgPro   := ""
   Local cMsgSol   := ""

   //Verifica existencia da tabela
   lRet:= TCCanOpen(cNomTab)

   If !lRet
      cMsgPro   := STR0013 /*"Tabela ("*/ + Alltrim(cNomTab) + STR0014 /*") inexistente."*/
      cMsgSol   := STR0015 /*"Rode compatibilizador UPDF011 de Integração Protheus X RM!"*/
      ShowHelpDlg(STR0016 /*"Integração"*/, {cMsgPro}, 2, {cMsgSol}, 5)
   EndIf
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} CarDad
Carrega Arquivo Temporario

@protected
@author    Cláudio Luiz da Silva
@since     22/03/2013
@version   P10
@param     aCabec    Cabecalho do browse
@param     aDados    Dados do browse
@return    lRet      .T. Existem dados  .F. nao existem dados
@obs
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------
Static Function CarDad(aCabec,aDados)
   Local cAliTmp   := GetNextAlias()
   Local aDadAux   := {}
   Local nXi       := 0
   Local nPos      := 0
   Local lRet      := .F.

   //Gera cursor em area de trabalho
   BeginSql alias cAliTmp
      SELECT
         NAC_ID,
         NAC_COLIGADA,
         NAC_FILIAL,
         NAC_COD_PR,
         NAC_COD_RM,
         NAC_DESCRICAO
      FROM
         INT_NACIONALIDADE
      WHERE
         NAC_COLIGADA = %exp:cEmpAnt%
         AND (NAC_FILIAL = %exp:cFilAnt% OR NAC_FILIAL = %exp:PadR('', 12, ' ')%)
      ORDER BY NAC_DESCRICAO
   EndSql

   //Alimenta array de dados
   (cAliTmp)->(dbGotop())
   While (cAliTmp)->(!Eof())
      lRet:= .T.
      aDadAux:= Array(Len(aCabec))
      For nXi:= 1 to Len(aCabec)
         If (nPos:=(cAliTmp)->(FieldPos(aCabec[nXi,5]))) <> 0
            aDadAux[nXi]:= (cAliTmp)->(FieldGet(nPos)) 
         EndIf
      Next nXi
      Aadd(aDados,aClone(aDadAux))

      (cAliTmp)->(dBskip())
   EndDo

   //Fecha cursor
   (cAliTmp)->(dbCloseArea())

   If !lRet
      ApMsgStop(STR0017 /*"Tabela INT_NACIONALIDADE não possui dados. Verifique!"*/)
   Else
      If Empty(aDados)
         aDados:= Array(Len(aCabec))
         AFill(aDados, "")
      EndIf
   EndIf
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} EdiReg
Processo de edicao da coluna Nacionalidade Protheus

@protected
@author   Cláudio Luiz da Silva
@since    22/03/2013 
@version  P10
@param    oBrowse     Objeto de cargas
@param    aDados      Array com cargas
@obs
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador        Motivo
/*/
//-------------------------------------------------------------------
Static Function EdiReg(oBrowse,aDados)
   Local cCodPRO := aDados[oBrowse:nAt,NCODPR]
   Local cCodRM  := aDados[oBrowse:nAt,NCODRM]
   Local cDescRM := aDados[oBrowse:nAt,NCOLDES]
   Local cDescPRO:= Posicione("SX5",1,xFilial("SX5")+"34"+cCodPRO,"X5_DESCRI")
   Local nConfirm:= 0
   Local lValida := .T.
   Local oDlgNac,oGrpNac
   Local oSayCRM,oSayDRM,oSayCPR,oSayDPR
   Local oGetCRM,oGetDRM,oGetCPR,oGetDPR
   Local oBtnCon,oBtnCan

   oDlgNac:= MSDialog():New( 091,232,289,640,STR0001 /*"Amarração Nacionalidade"*/,,,.F.,,,,,,.T.,,,.T. )
   oGrpNac:= TGroup():New( 004,004,075,200,STR0018 /*"Nacionalidade"*/,oDlgNac,CLR_BLACK,CLR_WHITE,.T.,.F. )
   oSayCRM:= TSay():New( 020,009,{||STR0002 /*"Código RM"*/},oGrpNac,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
   oSayDRM:= TSay():New( 033,009,{||STR0004 /*"Descrição RM"*/},oGrpNac,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
   oSayCPR:= TSay():New( 045,009,{||STR0003 /*"Código Protheus"*/},oGrpNac,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
   oSayDPR:= TSay():New( 058,009,{||STR0019 /*"Descrição Protheus"*/},oGrpNac,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
   oGetCRM:= TGet():New( 016,053,{|u| If(PCount()>0,cCodRM:=u,cCodRM)},oGrpNac,058,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","cCodRM",,)
   oGetDRM:= TGet():New( 029,053,{|u| If(PCount()>0,cDescRM:=u,cDescRM)},oGrpNac,135,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","cDescRM",,)
   oGetCPR:= TGet():New( 044,053,{|u| If(PCount()>0,cCodPRO:=u,cCodPRO)},oGrpNac,059,008,'',{|| lValida:= (Empty(cCodPRO) .Or. EXISTCPO("SX5","34"+cCodPRO)), cDescPRO:= Posicione("SX5",1,xFilial("SX5")+"34"+cCodPRO,"X5_DESCRI")},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"34","cCodPRO",,,,.T.)
   oGetDPR:= TGet():New( 058,053,{|u| If(PCount()>0,cDescPRO:=u,cDescPRO)},oGrpNac,059,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","cDescPRO",,)
   oBtnCon:= TButton():New( 080,112,STR0009 /*"Confirmar"*/,oDlgNac,{|| nConfirm:= 1, oDlgNac:End()},037,012,,,,.T.,,"",,,,.F. )
   oBtnCan:= TButton():New( 080,160,STR0012 /*"Cancelar"*/,oDlgNac,{|| nConfirm:= 0, oDlgNac:End()},037,012,,,,.T.,,"",,,,.F. )
   oDlgNac:lCentered := .T.
   oDlgNac:Activate()

   //Atualiza registro editado
   If lValida .And. nConfirm==1
      aDados[oBrowse:nAt,NCODPR]:= cCodPRO
   EndIf

   oBrowse:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Confirm
Confirma dados atualizados

@protected
@author    Cláudio Luiz da Silva
@since     22/03/2013
@version   P10
@param     aDados    Dados do browse
@obs
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------
Static Function Confirm(aDados)
   Local lGrava   := .T.
   Local nXi      := 0

   ProcRegua(Len(aDados))

   BeginTran()
      For nXi:= 1 To Len(aDados)
         IncProc()
         //Atualiza somente as linhas que tiveram alteracao
         If (aDados[nXi,NCODPR]<>aDados[nXi,NCOLPRO])
            lGrava:=GrvNac(aDados[nXi])
            If !lGrava
               Exit
            EndIf
         EndIf
      Next nXi

      If lGrava
         //Efetiva transacao
         EndTran()
      Else
         //Disarmo a transação
         DisarmTransaction()
      EndIf

   MsUnlockAll()

   If !lGrava
      ApMsgStop(STR0020 /*"Ocorreu erro ao efetuar a atualização. Dados não atualizados!"*/,STR0021 /*".:Atenção:."*/)
   EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvNac
Efetua gravacao do registro

@protected
@author    Cláudio Luiz da Silva
@since     22/03/2013 
@version   P10
@param     aDados    Dados do browse
@return    lRet      .T. Gravado com sucesso  .F. Erro de Gravacao
@obs
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//------------------------------------------------------------------
Static Function GrvNac(aDados)
   Local cQuery    := ""
   Local lRet      := .T.
   Local nRet      := 0

   cQuery   := "UPDATE INT_NACIONALIDADE "
   cQuery   += "SET NAC_COD_PR='"+aDados[NCODPR]+"' "
   cQuery += "WHERE NAC_ID="+cValToChar(aDados[NCOLID])

   nRet:= TCSQLExec(cQuery)
   If nRet <> 0
      lRet:= .F.
      ApMsgStop(TCSqlError())
   EndIf
Return(lRet)