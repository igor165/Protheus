#INCLUDE "EECAC175.ch"
/*
Programa    : EECAC175()
Objetivo    : Manutencao de Empresas
Autor       : Heder M Oliveira
Data/Hora   : 07/12/98 11:43
Obs.        :
*/
#include "EEC.CH"
#COMMAND E_RESET_AREA => SY5->(DBSETORDER(1));SY5->(DBGOTO(nREG))

/*
Funcao      : EECAC175()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao de tipos de Empresas
Autor       : Heder M Oliveira
Data/Hora   : 07/12/98 11:39
Revisao     :
Obs.        :
*/
Function EECAC175(xAutoCab,xAutoItens,nOpcAuto)
   Local lRet:=.T.,cOldArea:=select(),cAlias:="SY5"
   Private aRotina := MenuDef()
   Private cCadastro:= If(cModulo="EIC",STR0006,STR0007) //"Cadastro de Armadores"###"Empresas"
   Private cTipoCad := CD_SY5

   If cModulo == "EIC"  //Executa o Filtro
      SY5->(DbSetFilter({||LEFT(SY5->Y5_TIPOAGE,1) == "4"}, "LEFT(SY5->Y5_TIPOAGE,1) == '4'"))
   Endif

   // GFP - 08/12/11 - Tratamento ExecAuto
   Private lExecAuto := xAutoCab <> NIL
   Private aAutoCab
   Private aAutoEE3 := {}
   // ***

   Begin sequence

  (cAlias)->(DBSETORDER(1))
  (cALIAS)->(DBSEEK(XFILIAL(cALIAS)))

   //GFP - 08/12/2011
   If !lExecAuto
      // *** Processamento via Interface
      mBrowse( 6, 1,22,75,cAlias)
   Else
      // *** Processamento via rotina automática (MsExecAuto).
      aAutoCab   := xAutoCab
  	  aAutoEE3   := xAutoItens
      MBrowseAuto(nOpcAuto, aAutoCab, cAlias,, .T.)
   EndIf

      If cModulo == "EIC"
         Set Filter To  //Libera o Filtro
      Endif

   End Sequence
   dbselectarea(cOldArea)

Return lRet


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 17/01/07 - 16:50
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina :=  { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
                    { STR0002, "AC175MAN"  , 0 , 2},; //"Visualizar"
                    { STR0003, "AC175MAN"  , 0 , 3},; //"Incluir"
                    { STR0004, "AC175MAN"  , 0 , 4},; //"Alterar"
                    { STR0005, "AC175MAN"  , 0 , 5,3} } //"Excluir"

//LGS-04/09/2015 - Tabela de/Para - FIERGS
//5 - Despachante
IF AvFlags("TABELA_DE_PARA_FIERGS")
   aaDD(aRotina,{STR0011, 'TE110Inclui("5",SY5->Y5_COD)'  , 0 , 4})//Tabela de/Para
EndIf

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAC175MNU")
	aRotAdic := ExecBlock("EAC175MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

/*
Funcao      : AC175MAN()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Heder M Oliveira
Data/Hora   :
Revisao     :
Obs.        :
*/
Function AC175MAN(cAlias,nReg,nOpc)
   Local lRet:=.T.,cOldArea:=select(),nInc,bVal_OK,oObj
   Local lGravaOK:=.T.,bCancel
   Local cClassif := ''
   Local cCamMemo
   Local aCpoEnc
   Local aCampoEnch  // GFP - 08/12/2011

   Private oDlg
   Private aTela[0][0],aGets[0],nUsado:=0
   Private aMemos:={{"Y5_OBS","Y5_VM_OBS"}}
   Private cNomArq,cNomArq2
   Private lTabArm  := .t.
   Private nOpcA:=3	//JWJ 12/09/05 - Private p/ poder modificar em EE3Manut()
   Private oTarifa , lDemurrage := AvFlags("DEMURRAGE") //.AND. Left(SY5->Y5_TIPOAGE,1) == "4" // FSM - 10/03/11 - Demurrage por Container  // GFP - 24/04/2012 - Demurrage só pode ser tratado quando registro for Armador.
   Private cCadCont := ""   //DFS - 19/09/12 - Retirado título do campo para que, não inclua quando não tiver tabela de armador ou demurrage.

   Begin Sequence

      If lDemurrage
         oTarifa := EasyTarArm():New("Tarifas do Armador", "EWU", "EWV") //FSM
      EndIf


      IF nOpc == INCLUIR

         For nInc := 1 TO (cAlias)->(FCount()) //CRIAR VARIAVEIS
            M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
         Next nInc
         M->Y5_VM_OBS := ""

         If cModulo == "EIC" //Executa o Filtro
            SY5->(DbSetFilter({||LEFT(SY5->Y5_TIPOAGE,1) == "4"} , "LEFT(SY5->Y5_TIPOAGE,1) == '4'"))
         Endif

         // GFP - 08/12/2011 - Tratamento ExecAuto
         bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. AC175VldOk(),(nOpcA:=1,If(!lExecAuto,oDlg:End(),)),nOpca:=0)}

      Else
         For nInc := 1 TO (cALIAS)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
         Next nInc

         //M->Y5_VM_OBS := ""
         //M->Y5_VM_OBS := MSMM(SY5->Y5_OBS,AVSX3("Y5_OBS")[3],,,3) // By JPP - 07/03/2005 18:10 - Esta linha foi removida porque é desnecessária. O X3_RELAÇÃO DO CAMPO Y5_VM_OBS carrega o conteúdo do campo automáticamente.

         IF nOpc = VISUALIZAR
            // GFP - 08/12/2011 - Tratamento ExecAuto
            bVal_OK:={|| If(!lExecAuto,oDlg:End(),)}

         ElseIf nOpc==ALTERAR

            If cModulo == "EIC" //Executa o Filtro
               SY5->(DbSetFilter({||LEFT(SY5->Y5_TIPOAGE,1) == "4"} , "LEFT(SY5->Y5_TIPOAGE,1) == '4'"))
            Endif

            IF EasyEntryPoint("EECAC175")        // By JPP - 21/07/2005 - 11:20  - Inclusão do Ponto de Entrada.
               ExecBlock("EECAC175",.F.,.F.,{"INI_ALT",nOpc})
            Endif

            // GFP - 08/12/2011 - Tratamento ExecAuto
            bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. AC175VldOk(),(nOpcA:=2,If(!lExecAuto,oDlg:End(),)),nOpca:=0)}
         ElseIf nOpc = EXCLUIR
            IF ! INTEGREF("SY5")
               BREAK
            ENDIF
               // GFP - 08/12/2011 - Tratamento ExecAuto
               bVal_OK:={||If(AC175VldOk(), (nOpca:=0,AC175MANE(nOpc),If(!lExecAuto,oDlg:End(),) ),)}
         EndIf
      Endif

      If cModulo == "EIC" // Libera o Filtro
         Set Filter To
      Endif

      // Work dos Contatos ...
      bProc := {|| EE3Manut(nOpc,cTipoCad,AC_WK,{M->Y5_COD}) }
	  If !lExecAuto
         Processa(bProc)
	  Else
	     Eval(bProc)
      EndIf

      If !EECFlags("INTTRA")
         aCpoEnc := AvCposEnc("SY5", Nil, {"Y5_SCAC", "Y5_CODIN"})//Nunca exibe os campos "Y5_SCAC" e "Y5_CODIN", se a integração com Inttra estiver desligada.
      EndIf

      If lDemurrage //FSM - Criação de Works
         oTarifa:CriaWork() //Work de capa e Detalhes das Tarifas
         oTarifa:CarregaWork(nOpc)//carregando work de capa e detalhes das Tarifas
      EndIf

      While nOpca>=3 .And. nOpca <> 0
         nOpcA:=0   //JWJ 12/09/05
         aTela := {}
         aGets := {}

         // GFP - 08/12/2011 - Tratamento ExecAuto
         bCancel := {|| nOpcA:=0,If(!lExecAuto,oDlg:End(),)}

         If !lExecAuto


            DEFINE MSDIALOG oDlg TITLE cCadastro + cCadCont FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

            IF nOpc = INCLUIR
               cCamMemo := M->Y5_VM_OBS
            ENDIF

            oEnch1 := MsMGet():New()( cAlias, nReg, nOpc,,,, aCpoEnc,PosDlgUp(oDlg))

            IF nOpc = INCLUIR
               M->Y5_VM_OBS := cCamMemo
            ENDIF

            // MsSelect Contatos ...
            EE3Manut(nOpc,cTipoCad,AC_MS,{oDlg,M->Y5_COD})

            oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
            ACTIVATE MSDIALOG oDlg ON INIT (EE3Manut(nOpc,cTipoCad,AC_IN,{oDlg,bVal_OK,bCancel,M->Y5_COD})) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

         Else
            If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets, aTela) }, nOpc, aCpoEnc)
			    If Len(aAutoEE3) > 0
			       aEval(aAutoEE3, {|x| If(!lMsErroAuto, EE3Manut(nOpc,cTipoCad,"EXECAUTO", {M->Y5_COD,,x}), ) })
			    EndIf
			    Eval(bVal_Ok)
			Else
			    Eval(bCancel)
			EndIf
         EndIf

         Do Case
             Case nOpca==1 .and. Obrigatorio(aGets,aTela)
                 Begin Transaction
                      bProc := {||lGravaOk:=AC175Grava(.T.,nOpc)}
					  If !lExecAuto
						 Processa(bProc)
					  Else
						 Eval(bProc)
					  EndIf
                     If !lGravaOk
                         Help(" ",1,"A110NAORE")
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
                 Exit
             Case nOpca==2 .and. Obrigatorio(aGets,aTela)
                 SY5->(dbgoto(nReg))  //soh p/confirmar
                 bProc := {||lGravaOk:=AC175Grava(.F.,nOpc)}
				  If !lExecAuto
					 Processa(bProc)
				  Else
					 Eval(bProc)
				  EndIf
                 Exit
             Case nOpca==0
                 If __lSX8
                    RollBackSXE()
                 EndIf
                 Exit
             Otherwise
                 Loop
         EndCase
      Enddo

      /* FSM - 10/03/11 */
      If lDemurrage .And. nOpca <> 0 .And. Obrigatorio(aGets,aTela)
          oTarifa:GravaTarifas(nOpc)
      EndIf

      // Fecha e Apaga Work de Contatos ...
      EE3Manut(nOpc,cTipoCad,AC_ER)

      /* FSM - 10/03/11 */
      If lDemurrage
         oTarifa:ExcluiWork(.T.)
         oTarifa:ExcluiWork(.F.)
      EndIf
   End Sequence

   If cModulo == "EIC" //Executa o Filtro
      SY5->(DbSetFilter({||LEFT(SY5->Y5_TIPOAGE,1) == "4"} , "LEFT(SY5->Y5_TIPOAGE,1) == '4'"))
   Endif

   E_RESET_AREA
   dbselectarea(cOldArea)
   oDlg := Nil

   CursorArrow()

Return lRet

*--------------------*
Function VALIDAC175()
*--------------------*
Local cOutros   := ''
Local nRecSY5:=SY5->(RECNO())
Local cOrigem   := FunName()

Do Case

Case cOrigem == "EECAC175"

    If cModulo == "EIC"
        SY5->(DBSETORDER(1))
        If SY5->(DBSEEK(xFilial("SY5")+M->Y5_COD))
            cOutros  := Tabela('YE',Left(SY5->Y5_TIPOAGE,1))
            cOutros  := Left(SY5->Y5_TIPOAGE,1) + "-" +cOutros

            If Alltrim(Upper(cOutros)) # "4-ARMADOR"
                Msginfo("O código já foi inserido como sendo do Cadastro de " +cOutros, "MENSAGEM")
                SY5->(DBGOTO(nRecSY5))
                Return .F.
            EndIf
        Endif
    Endif

    SY5->(DBGOTO(nRecSY5))

Case cOrigem == "EICA050"

    SY5->(DBSETORDER(1))
    If SY5->(DBSEEK(xFilial("SY5")+M->Y5_COD))
    cOutros  := Tabela('YE',Left(SY5->Y5_TIPOAGE,1))
    cOutros  := Left(SY5->Y5_TIPOAGE,1) + "-" +cOutros

    If Alltrim(Upper(cOutros)) # "6-DESPACHANTE"
        Msginfo("O código já foi inserido como sendo do Cadastro de " +cOutros, "MENSAGEM")
        SY5->(DBGOTO(nRecSY5))
        Return .F.
    EndIf
    Endif
    SY5->(DBGOTO(nRecSY5))

EndCase

Return .T.


/*
Funcao      : AC175MANE(nOpc)
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Excluir Registros
Autor       : Heder M Oliveira
Data/Hora   : 07/12/98 14:16
Revisao     :
Obs.        :
*/
Static Function AC175MANE(nOpc)
   Local lRet:=.T.,cOldArea:=select()
   Private lDelEmpresa := lRet

   Begin Sequence

      //DFS - 17/11/10 - Criação de ponto de entrada para exclusão de empresas.
      If EasyEntryPoint("EECAC175")
         Execblock("EECAC175",.F.,.F.,{"AC175MANE_EXCLUIR", nOpc})
      EndIf

      // GFP - 08/12/2011 - Tratamento ExecAuto
      if lExecAuto .OR. Msgnoyes(OemtoAnsi(STR0008),Oemtoansi(STR0009)) //"Confirma ExclusÆo?"###"Aten‡Æo"
         Reclock("SY5",.F.)

         If ValType(lDelEmpresa) == "L" .And. !lDelEmpresa
            lRet:= lDelEmpresa
            Break
         EndIf

         // Work dos Contatos ...
         bProc := {|| EE3Manut(nOpc,cTipoCad,AC_DE,{M->Y5_COD}) }
		 If !lExecAuto
		    Processa(bProc)
		 Else
		    Eval(bProc)
		 EndIf

         //TRP - 11/09/2012 - Exclusão das tarifas do Armador (Capa/Detalhe)
         If lDemurrage

            EWV->(DbSetOrder(1))
            WORKEWV->(dbGoTop())
            While WORKEWV->(!Eof())

               If EWV->( DBSeek( xFilial("EWV") + SY5->Y5_COD + WorkEWV->EWV_CODTAB + WorkEWV->EWV_CODCON + WorkEWV->EWV_PERINI) )
                  If EWV->(RecLock("EWV",.F.))
                     EWV->(DbDelete())
                     EWV->(MsUnLock())
                  EndIf
               EndIf
               WORKEWV->(dbSkip())
            Enddo

            EWU->(DbSetOrder(1))
            WorkEWU->(DbGoTop())
            While WorkEWU->(!EOF())
               If EWU->( DBSeek( xFilial("EWU") + SY5->Y5_COD + WorkEWU->EWU_CODTAB ) )
                  If EWU->(RecLock("EWU",.F.))
                     EWU->(DbDelete())
                     EWU->(MsUnLock())
                  EndIf
               EndIf
               WorkEWU->(DbSkip())
            EndDo

         Endif
         SY5->(DBDELETE())
         SY5->(MsUnlock())

        If EasyEntryPoint("EECAC175")
            Execblock("EECAC175",.F.,.F.,"POS_EXCLUSAO")
        EndIf
      endif
   End Sequence

   dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AC175Grava(lGrava,nOpc)
Parametros  : lGrava:= .T. - append blank
                       .F. - replace
Retorno     : .T.
Objetivos   : Gravar Header e mensagens
Autor       : Heder M Oliveira
Data/Hora   : 20/11/98 09:38
Revisao     :
Obs.        :
*/
Static Function AC175Grava(lGrava,nOpc)
   Local lRet:=.T.,cOldArea:=select()

   Begin Sequence
      IF EasyEntryPoint("EECAC175")        // By JPP - 11/07/2005 - 11:20  - Inclusão do Ponto de Entrada.
         ExecBlock("EECAC175",.F.,.F.,{"INI_GRV",nOpc})
      Endif

      If Type('lExecAuto') <> 'U' .And. lExecAuto .And. nOpc <> 5                    //NCF - 07/05/2014 - Manter a classificação na alteração via integração
         If !Empty(SY5->Y5_TIPOAGE)
            M->Y5_TIPOAGE := SY5->Y5_TIPOAGE
         EndIf
      EndIf

      E_Grava("SY5",lGrava)

      If ! lGrava
         //excluir antes
         MSMM(M->Y5_OBS,,,,EXCMEMO)
      EndIf

      MSMM(,AVSX3("Y5_VM_OBS",AV_TAMANHO),,M->Y5_VM_OBS,INCMEMO,,,"SY5","Y5_OBS")

      Reclock("SY5",.F.)
      If cModulo = "EIC"
           SY5->Y5_TIPOAGE := "4-"+Tabela('YE',Left("4",1))
      EndIf
      SY5->(MsUnlock())

      // Work dos Contatos ...
      EE3Manut(nOpc,cTipoCad,AC_GR,{M->Y5_COD})

      IF EasyEntryPoint("EECAC175")        // By JPP - 11/07/2005 - 11:20  - Inclusão do Ponto de Entrada.
         ExecBlock("EECAC175",.F.,.F.,{"FIM_GRV",nOpc})
      Endif

   End Sequence

   dbselectarea(cOldArea)

Return lRet

/*
Funcao          : AC165TPAG()
Parametros      : Nenhum
Objetivos       : Retornar descricao de tipo de agente
Autor           : Heder M Oliveira
Data/Hora       : 13/11/98 16:15
Revisao         :
Obs                     :
*/
Function AC165TPAG()
    Local lRet:=.T.,cOldArea:=select(),cX5_DESC
    Begin sequence

       If !EMPTY(cX5_DESC:=Tabela('YE',Left(M->Y5_TIPOAGE,1)))
           M->Y5_TIPOAGE:=Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
       Else
           M->Y5_TIPOAGE:=SPACE(AVSX3("Y5_TIPOAGE")[3])
           lRet:=.F.
       EndIf

       //DFS - 03/10/12 - Tratamento para impedir cadastrar uma tabela de armador quando utilizar tipo de agente diferente de 4-ARMADOR
       If AvFlags("DEMURRAGE") .And. Type("oTarifa") == "O"
          EWU->(DbSetOrder(1))
          WorkEWU->(DbSetOrder(1))
          If M->Y5_TIPOAGE <> "4-ARMADOR" .AND. EWU->(DbSeek(xFilial("EWU")+M->Y5_COD)) .OR. M->Y5_TIPOAGE <> "4-ARMADOR" .AND. WorkEWU->(DbSeek(M->Y5_COD))
             MsgInfo(STR0010, STR0009) //"Para que seja possível alterar a Classificação, é necessário excluir a Tabela de Armador vinculada neste cadastro!" ### "Atenção"
             lRet := .F.
          EndIf
       EndIf

    Endsequence
    lRefresh:=.T.

    dbselectarea(cOldArea)
Return lRet

/*
Funcao          : AC175VldOk()
Parametros      : AC175VldOk_IncAltExc
Objetivos       : Retornar .T. ou .F. no botão Ok final na Inclusão, Alteração e Exclusão de Empresas
Autor           : Diogo Felipe dos Santos
Data/Hora       : 25/11/2010/10:00
Revisao         : Wilsimar Fabrício da Silva
Obs             :
*/

*------------------------------*
Function AC175VldOk()
*------------------------------*

Private lValidCadEmp := .T.

IF EasyEntryPoint("EECAC175")
   ExecBlock("EECAC175",.F.,.F.,{"AC175VldOk_IncAltExc",lValidCadEmp})
Endif

Return lValidCadEmp

/* ============================================================*
* Função     : IntegDef
* Parametros : cXML, nTypeTrans, cTypeMessage
* Objetivo   : Efetua integração com Logix
* Autor      : Guilherme Fernandes Pilan - GFP
* Data       : 08/12/2011 - 11:16 hs
* Revisao    : FSM - 06/01/2012
* Aviso *    : Esta integDef  é utilizada para o cadastros de
* Import./Cliente, Fornecedores e Empresas.
* =============================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:SetModule("EEC",29)

	/*
	* Existe um Pre-Adapter que verifica a qual tipo a Mensagem Unica
	* CustomerVendor se refere.
	*/
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AC175PARVD") //Pre-Adapter de Recebimento de Business

	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AC175ARESB") //Resposta sobre o Recebimento

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


/*========================================================================================
Funcao Adapter: AC175PARVD
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida
Retorno       : oBatch onde:
Objetivos     : Funcao para validar qual adapter chamar
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 05/01/2012 - 15:00 hs
Revisao       : FSM - 06/01/2012
Obs.          :
==========================================================================================*/
Function AC175PARVD(oMessage)
Local oBusinessCont := oMessage:GetMsgContent()
Local cTipo := UPPER( EasyGetXMLinfo(, oBusinessCont, "_Type") )
Local xRet, oBatch1, oBatch2, i


If cTipo == "CUSTOMER" .Or. cTipo == "BOTH"
   oBatch1 := AC100ARECB(oMessage)//Adapter de Clientes
EndIf

If cTipo == "VENDOR" .Or. cTipo == "BOTH"
   oBatch2 := AC175ARECB(oMessage)//Adapter de Empresas
EndIf

/* Tratamento para agregar os dois ExecAuto */
If ValType(oBatch2) == "O" .AND. ValType(oBatch1) == "O"

   xRet := EBatch():New()

   For i := 1 To oBatch1:RecCount()
      xRet:AddRec(oBatch1:GetRec(i))
   Next i

   For i := 1 To oBatch2:RecCount()
      xRet:AddRec(oBatch2:GetRec(i))
   Next i

ElseIf ValType(oBatch1) == "O"
   xRet := oBatch1
Else
   xRet := oBatch2
EndIf

Return xRet

/*========================================================================================
 Funcao Adapter: AC175ARECB
 Parametros    : oMessage - Objeto XML com conteúdo da tag "BusinessContent" recebida
 Retorno       : oBatch  - Objeto para geração de ExecAuto
 Objetivos     : Montar o Array de dados da Mensagem única para inserção via ExecAuto
 Autor         : Guilherme Fernandes Pilan - GFP
 Data/Hora     : 22/12/2011 - 15:47 hs
 Revisao       : FSM - 06/01/2012
 Obs.          :
==========================================================================================*/
*------------------------------------------------*
Function AC175ARECB(oMessage)
*------------------------------------------------*
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch := EBatch():New()
Local oExecAuto := EExecAuto():New()
Local oSA2ExecAuto := EExecAuto():New()
Local oRec := ERec():New()
Local cEnd := "", cCNPJ := "", cCEP := "", cCodPais := "", cCodERP := "", cObs := "", cEnd := ""
Local cTipo := "", cCP := ""
Local nCont := 0
Local lObrigat := .T.
Local aContatos := {}, k
Local oContatos, oContato

/*
   ATENCAO:
   Tratamento para Execauto de fornecedores
*/
   AddArrayXML(oRec, "A2_COD"  , oBusinessCont,"_Code" , lObrigat)	//Codigo
   oRec:SetField("A2_LOJA", AvKey(".","A2_LOJA") ) //Loja
   AddArrayXML(oRec, "A2_NREDUZ" , oBusinessCont,"_ShortName" , lObrigat) //Nome Fantasia
   AddArrayXML(oRec, "A2_NOME" , oBusinessCont,"_Name" , lObrigat) //Razao Social

   If IsCpoInXML(oBusinessCont, "_Address")
      AddArrayXML(oRec, "A2_CEP" , oBusinessCont:_Address, "_ZIPCode")
      AddArrayXML(oRec, "A2_CX_POST" , oBusinessCont:_Address, "_POBox")
      //AddArrayXML(oRec, "A2_END" , oBusinessCont:_Address, "_Address") //NCF - 19/08/2019 - Tag "Address" pode vir com o conteúdo na tag pai que também é "Address".
      cEnd := If( Empty(Alltrim(EasyGetXMLinfo("A2_END", oBusinessCont:_Address, "_Address"))) , Alltrim(EasyGetXMLinfo("A2_END", oBusinessCont, "_Address")) , Alltrim( EasyGetXMLinfo("A2_END", oBusinessCont:_Address, "_Address"))  )
      oRec:SetField("A2_END", cEnd)
      AddArrayXML(oRec, "A2_EST" , oBusinessCont:_Address:_State, "_Code") //Estado
      AddArrayXML(oRec, "A2_MUN" , oBusinessCont:_Address:_City, "_Description") //Municipio
      AddArrayXML(oRec, "A2_NR_END" , oBusinessCont:_Address, "_Number") //Numero
      AddArrayXML(oRec, "A2_COMPLEM" , oBusinessCont:_Address, "_Complement") //Complemento
      If IsCpoInXML(oBusinessCont:_Address, "_Country")
         cCodPais := AvKey(EasyConvCod( oBusinessCont:_Address:_Country:_Code:Text, "SYA" ), "A2_PAIS")
         If !Empty(cCodPais)
            oRec:SetField("A2_PAIS", cCodPais)
         Endif
      EndIf
   EndIf

   cTipo := AllTrim(UPPER( EasyGetXMLinfo(, oBusinessCont, "_EntityType") ))
   If cTipo == "PERSON"
      cTipo := "F"
   ElseIf cTipo == "COMPANY"
      cTipo := "J"
   EndIf
   oRec:SetField("A2_TIPO", AvKey(cTipo,"A2_TIPO") ) //Tipo

   cCNPJ := EasyGetCommonValue(oBusinessCont, "CNPJ")
   oRec:SetField("A2_CGC", AvKey(cCNPJ,"A2_CGC") ) //CNPJ/CPF

   If SA2->(FieldPos("A2_NIFEX")) > 0 .AND. !Empty(EasyGetCommonValue(oBusinessCont, "NIF"))
      oRec:SetField("A2_NIFEX", AvKey(EasyGetCommonValue(oBusinessCont, "NIF"),"A2_NIFEX") ) //CNPJ/CPF
   EndIf

   oRec:SetField("A2_ID_FBFN", AvKey("3","A2_ID_FBFN") ) //Identificac.

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
			AddArrayXML(oContato, "EE3_FAX", aContatos[k]:_CommunicationInformation,"_FaxNumber")
 			AddArrayXML(oContato, "EE3_EMAIL", aContatos[k]:_CommunicationInformation,"_Email")
		EndIf

		oContatos:AddRec(oContato)
	Next k

   oSA2ExecAuto:SetField("SA2",oRec)
   oSA2ExecAuto:SetField("EE3",oContatos)

   oParams := ERec():New()
   oParams:SetField("cMainAlias","SA2")
   oParams:SetField("bFunction",{|oEasyMessage| EECAC115(oEasyMessage:GetEAutoArray("SA2"),EasyEAutItens("SA2","EE3",oEasyMessage:GetEAutoArray("SA2"),oEasyMessage:GetEAutoArray("EE3"),"A2_FILIAL+'X'+AvKey(A2_COD,'EE3_CONTAT')+AvKey(A2_LOJA,'EE3_COMPL')"), oEasyMessage:GetOperation())}) // X
   oSA2ExecAuto:SetField("PARAMS",oParams)

   /*
   ATENCAO:
   Tratamento para Execauto de Empresas
   */

   oRec := ERec():New()

   AddArrayXML(oRec, "Y5_COD"  , oBusinessCont,"_Code" , lObrigat)	//Codigo
   AddArrayXML(oRec, "Y5_FORNECE",  oBusinessCont, "_Code" ) //Fornecedor
   oRec:SetField("Y5_LOJAF", AvKey(".", "Y5_LOJAF" ) )
   AddArrayXML(oRec, "Y5_NOME" , oBusinessCont,"_Name" , lObrigat) //Razao Social
   oRec:SetField("Y5_TIPOAGE", AvKey("7", "Y5_TIPOAGE") )	//Classificacao - ATIVIDADE EXERCIDA
   cCNPJ := EasyGetCommonValue(oBusinessCont, "CNPJ")
   oRec:SetField("Y5_NRCPFCG", AvKey(  cCNPJ, "Y5_NRCPFCG" ) ) // CNPJ
   oRec:SetField("Y5_VM_OBS", EasyGetXMLinfo(, oBusinessCont,"_Comments")) //Observacoes

	If IsCpoInXML(oBusinessCont, "_Address")
	    cCP := EasyFromTo( oBusinessCont:_Address, "_POBox", "SEM_CARACTER_ESPECIAL")
	    cCEP  := EasyFromTo(oBusinessCont:_Address, "_ZIPCode", "SEM_CARACTER_ESPECIAL")
	    cEnd := AllTrim(EasyGetXMLinfo(, oBusinessCont:_Address,"_Address")) + ", " +; //AllTrim(EasyGetXMLinfo(,oBusinessCont:_Address, "_Number")) + " - " + AllTrim(EasyGetXMLinfo(,oBusinessCont:_Address, "_Complement"))
	    If( IsCpoInXML(oBusinessCont:_Address, "_Number") , AllTrim(EasyGetXMLinfo(,oBusinessCont:_Address, "_Number")) , "")+;
	    If( IsCpoInXML(oBusinessCont:_Address, "_Complement") , AllTrim(EasyGetXMLinfo(,oBusinessCont:_Address, "_Complement")), "")

	    oRec:SetField("Y5_END" , AvKey(cEnd, "Y5_END") ) //Endereço
	    oRec:SetField("Y5_CX_POST", AvKey( cCP, "Y5_CX_POST" ) ) //Caixa postal
	    oRec:SetField("Y5_CEP", AvKey( cCEP, "Y5_CEP" ) ) //CEP
	    AddArrayXML(oRec, "Y5_CIDADE" , oBusinessCont:_Address:_City, "_Description") //Razao Social
	    AddArrayXML(oRec, "Y5_BAIRRO", oBusinessCont:_Address, "_District") //Bairro
	    AddArrayXML(oRec, "Y5_EST",  oBusinessCont:_Address:_State,"_Code" ) //Estado

	    cCodPais := ""
	    If IsCpoInXML(oBusinessCont:_Address, "_Country")
	       cCodERP := AllTrim(EasyGetXMLinfo(, oBusinessCont:_Address:_Country, "_Code")) //Pais
	       cCodPais  := EasyConvCod( oBusinessCont:_Address:_Country:_Code:Text, "SYA" )
	    EndIf

	    If !Empty(cCodPais)
	       oRec:SetField("Y5_PAIS", AvKey(cCodPais,"Y5_PAIS" )) //Codigo Pais
	    EndIf
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
		oContato:SetField("EE3_CODCAD", AvKey("E","EE3_CODCAD") )
		oContato:SetField("EE3_CONTAT", AvKey(EasyGetXMLinfo(, oBusinessCont, "_Code"),'EE3_CONTAT') )
		oContato:SetField("EE3_COMPL", AvKey("","EE3_COMPL") )

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

   oExecAuto:SetField("SY5",oRec)
   oExecAuto:SetField("EE3",oContatos)

   /* Tratamento para execução da funcao de execAuto correspondente a este adapter */
   oParams := ERec():New()
   oParams:SetField("cMainAlias","SY5")
   oParams:SetField("bFunction",{|oEasyMessage| EECAC175(oEasyMessage:GetEAutoArray("SY5"),EasyEAutItens("SY5","EE3",oEasyMessage:GetEAutoArray("SY5"),oEasyMessage:GetEAutoArray("EE3"),"Y5_FILIAL+'E'+AvKey(Y5_COD,'EE3_CONTAT')+AvKey('','EE3_COMPL')"), oEasyMessage:GetOperation())})  //E
   oExecAuto:SetField("PARAMS",oParams)

   If AllTrim(Upper(oMessage:GetBsnEvent())) == "DELETE"
      oBatch:AddRec(oExecAuto)
      oBatch:AddRec(oSA2ExecAuto)
   Else
      oBatch:AddRec(oSA2ExecAuto)
      oBatch:AddRec(oExecAuto)
   EndIf

Return oBatch


/* ============================================================*
* Função     : AC175ARESB
* Parametros : oMessage
* Objetivo   : Mensagem de retorno com o resultado da integracao
* Autor      : Felipe Sales Martinez - FSM
* Data       : 06/01/2012 - 11:52 hs
* Revisao    :
* Obs        :
* =============================================================*/
*-------------------------------------------------*
Function AC175ARESB(oMessage)
*-------------------------------------------------*
Local oRespond
Local cTipo := ""
Local cCVC  := ""

   If !oMessage:HasErrors()

      if iscpoinxml(oMessage:oXML:_Totvsmessage:_BusinessMessage:_BusinessContent:_type,"Text")
         cTipo := upper(oMessage:oXML:_Totvsmessage:_BusinessMessage:_BusinessContent:_type:text)
      endif

      if valtype(oMessage:cMainAlias) == 'C'
         cXAlias := oMessage:cMainAlias
      endif

      if (cTipo == "CUSTOMER" .or. cTipo == "BOTH") .or. cXAlias == "SA1"
         cCVC := SA1->A1_COD
      else
         cCVC := SA2->A2_COD
      endif
 

      oRespond  := ENode():New()
      oRespond:SetField('CustomerVendorCode' , cCVC )
      oRespond:SetField('ExternalCode'       , cCVC )
   Else
      oRespond := oMessage:GetContentList("RESPONSE")
   EndIf

Return oRespond
*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAC175.PRW                                                  *
*------------------------------------------------------------------------*
