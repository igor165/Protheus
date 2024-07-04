#Include "PLSM170.ch"
#Include "Protheus.CH"
#Include "PLSMGER.CH"

Static oPrepBG9 := Nil
Static oPrepBG9Count := Nil
Static oPrepBT5 := Nil
Static oPrepBQC := Nil
Static oPrepBA3 := Nil
Static oPrepBA3Count := Nil
Static oPrepBA1 := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM170
Atualizacao off-line de arquivo com receita e custos

@author Tulio Cesar / Vinicius Queiros Teixeira
@since 29/05/2004
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLSM170()

   Local cPerg := "PLM170"
   Local cTimeInicial := ""
   Local cMsgFinal := ""

   If BD7->(FieldPos("BD7_CONEMP")) == 0 .Or. BD7->(FieldPos("BD7_VERCON")) == 0 .Or. BD7->(FieldPos("BD7_SUBCON")) == 0 .Or. BD7->(FieldPos("BD7_VERSUB")) == 0     
      MsgAlert(STR0002) //"Necessário executar o Compatinilizador 'UPDPLS68' da FNC - 000000131182010"
      Return()        
   EndIf

   If !Pergunte(cPerg, .T.)
      Return
   Endif

   cTimeInicial := Time()

   oProcess := MsNewProcess():New({|| M170Pro(oProcess, cPerg) }, STR0001, "", .T.)   //"Apurando Receitas e Custos"
   oProcess:Activate()

   cMsgFinal += STR0005+cTimeInicial+STR0006+Time()+"</b>" // "Hora Inicial: <b>" ; "</b><br>Hora Final: <b>"
	cMsgFinal += STR0007+ElapTime(cTimeInicial, Time())+"</b>" // "<br>Tempo de Processamento: <b>"
		
	MsgInfo(cMsgFinal, STR0008) // "Processamento concluído!"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM170
 Atualizacao off-line de arquivo com receita e custos

@author Tulio Cesar / Vinicius Queiros Teixeira
@since 29/05/2004
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function M170PRO(oProcess, cPerg)
   
   Local oDadosPerg := JsonObject():New()

   oDadosPerg["cCodOpe"] := MV_PAR01
   oDadosPerg["cAno"] := MV_PAR02
   oDadosPerg["cGrupoDe"] := MV_PAR03
   oDadosPerg["cGrupoAte"] := MV_PAR04
   oDadosPerg["cContDe"] := MV_PAR05
   oDadosPerg["cVerConDe"] := MV_PAR06
   oDadosPerg["cContAte"] := MV_PAR07 
   oDadosPerg["cVerConAte"] := MV_PAR08
   oDadosPerg["cSubDe"] := MV_PAR09
   oDadosPerg["cVerSubDe"] := MV_PAR10
   oDadosPerg["cSubAte"] := MV_PAR11
   oDadosPerg["cVerSubAte"] := MV_PAR12
   oDadosPerg["cFamDe"] := MV_PAR13
   oDadosPerg["cFamAte"] := MV_PAR14
   oDadosPerg["cUsrDe"] := MV_PAR15
   oDadosPerg["cUsrAte"] := MV_PAR16 
   oDadosPerg["cMesDe"] := MV_PAR17
   oDadosPerg["cMesAte"] := MV_PAR18
   oDadosPerg["nTpRec"] := MV_PAR19  
   
   BA0->(DbSetOrder(1))
   If BA0->(DbSeek(xFilial("BA0")+oDadosPerg["cCodOpe"]))

       // Calcula Receita e Custo no Nivel da Operadora
      CalculaRC("0", oDadosPerg["cMesDe"], oDadosPerg["cMesAte"], oDadosPerg["cAno"], oDadosPerg["cCodOpe"], "", "", "", "", "", "", "", oDadosPerg["nTpRec"], "", "")

      CalculaEmpresas(oDadosPerg, oProcess)
      
   EndIf 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CalculaRC
Calcula a receita e custo do nivel e atualiza arquivo

@author Tulio Cesar / Vinicius Queiros Teixeira
@since 29/05/2004
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CalculaRC(cTipo, cMesDe, cMesAte, cAno, cCodOpe,cCodEmp, cNumCon, cVerCon,;
                          cSubCon, cVerSub, cMatric, cTipReg, nTpRec, cCodPla, cTipUsr)

   Local aReceitas := {}
   Local aCustos := {}
   Local aUsuarios := {}
   Local nRecCalc := {}
   Local nCusCalc := {}
   Local aTotUser	:= {}
   Local nX := 0
   Local cMes := ""
   Local cMacro := ""
   Local nAcuCusOpe := 0  
   Local nAcuRecOpe := 0 
   Local nUsuarios := 0 
   Local lFindReg := .F.

   Default nTpRec	:= 0                                    
   Default cCodPla := ""
   Default cTipUsr := ""

   For nX := Val(cMesDe) To Val(cMesAte)

      cMes := StrZero(nX, 2)
      // Realiza o calculo de cada mês
      nRecCalc := PLSRECCALC(cTipo, cCodOpe, cCodEmp, cNumCon, cVerCon, cSubCon, cVerSub,;
                               cMatric, cTipReg, cAno, cMes, cAno, cMes, nTpRec)[1]            
                         
      nCusCalc := PLSCUSTMOV(cTipo, cCodOpe, cCodEmp, cNumCon, cVerCon, cSubCon, cVerSub,;
                             cMatric, cTipReg, cAno, cMes, cAno, cMes, .F.)[1]
                              
      nAcuCusOpe += nCusCalc
      nAcuRecOpe += nRecCalc
         
      cMacro := "BX9->BX9_VRC"+PLSBusMeses(cMes)
      aadd(aCustos, {cMacro, nCusCalc})

      cMacro := "BX9->BX9_VRR"+PLSBusMeses(cMes)
      aadd(aReceitas, {cMacro, nRecCalc})
                           
      // Calcula quantidade de usuários
      If cTipo $ "1/2/3" // 1 = Empresa; 2 = Contrato; 3 = SubContrato
         aTotUser := PLQTUSEMP(cCodOpe, cCodEmp, cNumCon, cVerCon, cSubCon, cVerSub, Nil, Nil, cMes, cAno)           
                        
         nUsuarios := Len(aTotUser)

         cMacro := "BX9->BX9_USR"+PLSBusMeses(cMes)
         aadd(aUsuarios, {cMacro, nUsuarios})    
      Endif 

   Next nX  

   Do Case
      Case cTipo == "0"
         BX9->(DbSetOrder(1))
         lFindReg := BX9->(DbSeek(xFilial("BX9")+"0"+cAno+cCodOpe))

      Case cTipo == "1"   
         BX9->(DbSetOrder(2))
         lFindReg := BX9->(DbSeek(xFilial("BX9")+"1"+cAno+cCodOpe+cCodEmp))

      Case cTipo == "2"   
         BX9->(DbSetOrder(3))
         lFindReg := BX9->(DbSeek(xFilial("BX9")+"2"+cAno+cCodOpe+cCodEmp+cNumCon+cVerCon))

      Case cTipo == "3"   
         BX9->(DbSetOrder(4))
         lFindReg := BX9->(DbSeek(xFilial("BX9")+"3"+cAno+cCodOpe+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub))

      Case cTipo == "4"   
         BX9->(DbSetOrder(5))
         lFindReg := BX9->(DbSeek(xFilial("BX9")+"4"+cAno+cCodOpe+cCodEmp+cMatric))

      Case cTipo == "5"   
         BX9->(DbSetOrder(6))
         lFindReg := BX9->(DbSeek(xFilial("BX9")+"5"+cAno+cCodOpe+cCodEmp+cMatric+cTipReg))
   EndCase

   If !lFindReg
      BX9->(RecLock("BX9",.T.))
      BX9->BX9_FILIAL := xFilial("BX9")
      BX9->BX9_TIPO := cTipo
      BX9->BX9_ANO := cAno
      BX9->BX9_CODOPE := cCodOpe
      BX9->BX9_CODEMP := cCodEmp
      BX9->BX9_CONEMP := cNumCon
      BX9->BX9_VERCON := cVerCon
      BX9->BX9_SUBCON := cSubCon
      BX9->BX9_VERSUB := cVerSub
      BX9->BX9_MATRIC := cMatric
      BX9->BX9_TIPREG := cTipReg
   Else                         
      BX9->(RecLock("BX9",.F.))
   Endif                        

   If cTipo == "5" // 5 = Usuario
      If !Empty(cTipUsr)
         BX9->BX9_TIPUSR := cTipUsr
      Endif

      If !Empty(cCodPla) 
         BX9->BX9_CODPLA := cCodPla
      Endif
   EndIf
   
   For nX := 1 To Len(aReceitas)
      &(aReceitas[nX,1]) := aReceitas[nX, 2]
   Next        

   For nX := 1 To Len(aCustos)
      &(aCustos[nX,1]) := aCustos[nX, 2]
   Next

   If cTipo $ "1/2/3" // 1 = Empresa; 2 = Contrato; 3 = SubContrato
      For nX := 1 To Len(aUsuarios)
         &(aUsuarios[nX,1]) := aUsuarios[nX, 2]
      Next
   EndIf

   BX9->BX9_VRCACU := nAcuCusOpe
   BX9->BX9_VRRACU := nAcuRecOpe

   If ExistBlock("PL170BX9")
      ExecBlock("PL170BX9",.F.,.F.)
   Endif

   BX9->(MsUnLock())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CalculaEmpresas
Calcula a receita e custo do nivel de Empresa

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CalculaEmpresas(oDadosPerg, oProcess)

   Local cAliasBG9 := ""
   Local cQuery := ""
   Local lRetorno := .F.
   Local cCodEmpresa := ""
   Local oDadosCorrente := JsonObject():New()

   // Define a Regua
   oProcess:SetRegua1(TotalEmpresas(oDadosPerg))

   cAliasBG9 := GetNextAlias()
   cQuery := QueryEmpresas(oDadosPerg)

   dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasBG9, .F., .T.)
               
   If !(cAliasBG9)->(Eof())
      While !(cAliasBG9)->(Eof())

         cCodEmpresa := (cAliasBG9)->BG9_CODIGO

         oProcess:IncRegua1(STR0003+cCodEmpresa) // "Grupo Empresa "

         // Calcula Receita e Custo no Nivel do Grupo/Empresa
         CalculaRC("1", oDadosPerg["cMesDe"], oDadosPerg["cMesAte"], oDadosPerg["cAno"], oDadosPerg["cCodOpe"], cCodEmpresa, "", "", "", "", "", "", oDadosPerg["nTpRec"], "", "") 

         oDadosCorrente["cEmpresa"] := cCodEmpresa

         If (cAliasBG9)->BG9_TIPO == "2" // Pessoa Juridca 
            CalculaContratos(oDadosPerg, oProcess, oDadosCorrente) 
         Else
            CalculaFamilias(oDadosPerg, oProcess, oDadosCorrente)
         EndIf
         
         (cAliasBG9)->(DbSkip())
      EndDo

      lRetorno := .T.
      oProcess:IncRegua1(STR0009) // "Concluido"
   EndIf

   (cAliasBG9)->(DbCloseArea())
 
Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryEmpresas
Retorna Query para utilizar no Calculo da receita e custo do nivel de 
Empresa

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function QueryEmpresas(oDadosPerg, lCount)

   Local cQuery := ""
 
   Default lCount := .F.

   If (ValType(oPrepBG9Count) == "U" .And. lCount) .Or. (ValType(oPrepBG9) == "U" .And. !lCount)

      If lCount
         cQuery := " SELECT COUNT(BG9_CODIGO) CONTADOR FROM "+RetSQLName("BG9")
      Else
         cQuery := " SELECT BG9_CODIGO, BG9_TIPO FROM "+RetSQLName("BG9")
      EndIf

      cQuery += "  WHERE BG9_FILIAL = ?"
      cQuery += "	   AND BG9_CODINT = ?"

      cQuery += "	   AND BG9_CODIGO >= ?"
      cQuery += "	   AND BG9_CODIGO <= ?"

      cQuery += "    AND D_E_L_E_T_= ' ' "

      If !lCount
         cQuery += " ORDER BY BG9_CODINT, BG9_CODIGO"
         oPrepBG9 := FWPreparedStatement():New(cQuery)
      Else
         oPrepBG9Count := FWPreparedStatement():New(cQuery)
      EndIf

   EndIf

   If lCount
      oPrepBG9Count:SetString(1, xFilial("BG9"))
      oPrepBG9Count:SetString(2, oDadosPerg["cCodOpe"])
      oPrepBG9Count:SetString(3, oDadosPerg["cGrupoDe"])
      oPrepBG9Count:SetString(4, oDadosPerg["cGrupoAte"])

      cQuery := oPrepBG9Count:GetFixQuery()
   Else
      oPrepBG9:SetString(1, xFilial("BG9"))
      oPrepBG9:SetString(2, oDadosPerg["cCodOpe"])
      oPrepBG9:SetString(3, oDadosPerg["cGrupoDe"])
      oPrepBG9:SetString(4, oDadosPerg["cGrupoAte"])

      cQuery := oPrepBG9:GetFixQuery()
   EndIf

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} TotalEmpresas
Retorna o total de empresas de acordo com a query de processamento
para montar a regua

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function TotalEmpresas(oDadosPerg)

   Local cQuery := ""
   Local nTotal := 0

   cQuery := QueryEmpresas(oDadosPerg, .T.)

   nTotal := MPSysExecScalar(cQuery, "CONTADOR")

Return nTotal


//-------------------------------------------------------------------
/*/{Protheus.doc} CalculaContratos
Calcula a receita e custo do nivel de Contrato

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CalculaContratos(oDadosPerg, oProcess, oDadosCorrente)

   Local cAliasBT5 := ""
   Local cQuery := ""
   Local lRetorno := .F.
   Local cCodEmpresa := "" 
   Local cContrato := ""
   Local cVerContrato := ""

   cAliasBT5 := GetNextAlias()
   cQuery := QueryContratos(oDadosPerg, oDadosCorrente)
   
   dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasBT5, .F., .T.)
               
   If !(cAliasBT5)->(Eof())
      While !(cAliasBT5)->(Eof())

         cCodEmpresa := (cAliasBT5)->BT5_CODIGO
         cContrato := (cAliasBT5)->BT5_NUMCON
         cVerContrato := (cAliasBT5)->BT5_VERSAO

         // Calcula Receita e Custo no Nivel do Contrato
         CalculaRC("2", oDadosPerg["cMesDe"], oDadosPerg["cMesAte"], oDadosPerg["cAno"], oDadosPerg["cCodOpe"], cCodEmpresa, cContrato,;
                   cVerContrato, "", "", "", "", oDadosPerg["nTpRec"], "", "") 

         oDadosCorrente["cContrato"] := cContrato
         oDadosCorrente["cVerContrato"] := cVerContrato

         CalculaSubContratos(oDadosPerg, oProcess, oDadosCorrente)

         (cAliasBT5)->(DbSkip())
      EndDo

      lRetorno := .T.

   EndIf

   (cAliasBT5)->(DbCloseArea())

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryContratos
Retorna Query para utilizar no Calculo da receita e custo do nivel de 
Contrato

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function QueryContratos(oDadosPerg, oDadosCorrente)

   Local cQuery := ""

   If ValType(oPrepBT5) == "U"
      cQuery := " SELECT BT5_CODIGO, BT5_NUMCON, BT5_VERSAO FROM "+RetSQLName("BT5")
   
      cQuery += "  WHERE BT5_FILIAL = ?"
      cQuery += "	   AND BT5_CODINT = ?"
      cQuery += "	   AND BT5_CODIGO = ?"

      cQuery += "	   AND BT5_NUMCON >= ?"
      cQuery += "	   AND BT5_NUMCON <= ?"

      cQuery += "	   AND BT5_VERSAO >= ?"
      cQuery += "	   AND BT5_VERSAO <= ?"

      cQuery += "    AND D_E_L_E_T_= ' ' "
   
      cQuery += " ORDER BY BT5_CODINT, BT5_CODIGO, BT5_NUMCON, BT5_VERSAO"

      oPrepBT5 := FWPreparedStatement():New(cQuery)
   EndIf

	oPrepBT5:SetString(1, xFilial("BT5"))
	oPrepBT5:SetString(2, oDadosPerg["cCodOpe"])
	oPrepBT5:SetString(3, oDadosCorrente["cEmpresa"])
   oPrepBT5:SetString(4, oDadosPerg["cContDe"])
   oPrepBT5:SetString(5, oDadosPerg["cContAte"])
   oPrepBT5:SetString(6, oDadosPerg["cVerConDe"])
   oPrepBT5:SetString(7, oDadosPerg["cVerConAte"])

	cQuery := oPrepBT5:GetFixQuery()

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} CalculaSubContratos
Calcula a receita e custo do nivel de Subcontratos

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CalculaSubContratos(oDadosPerg, oProcess, oDadosCorrente)

   Local cAliasBQC := ""
   Local cQuery := ""
   Local lRetorno := .F.
   Local cCodEmpresa := ""
   Local cContrato := ""
   Local cVerContrato := ""
   Local cSubContato := ""
   Local cVerSubContrato := ""

   cAliasBQC := GetNextAlias()
   cQuery := QuerySubContratos(oDadosPerg, oDadosCorrente)
   
   dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasBQC, .F., .T.)
               
   If !(cAliasBQC)->(Eof())
      While !(cAliasBQC)->(Eof())

         cCodEmpresa := (cAliasBQC)->BQC_CODEMP
         cContrato := (cAliasBQC)->BQC_NUMCON
         cVerContrato := (cAliasBQC)->BQC_VERCON
         cSubContato := (cAliasBQC)->BQC_SUBCON
         cVerSubContrato := (cAliasBQC)->BQC_VERSUB

         // Calcula Receita e Custo no Nivel do SubContrato
         CalculaRC("3", oDadosPerg["cMesDe"], oDadosPerg["cMesAte"], oDadosPerg["cAno"], oDadosPerg["cCodOpe"], cCodEmpresa, cContrato,;
                   cVerContrato, cSubContato, cVerSubContrato, "", "", oDadosPerg["nTpRec"], "", "")

         CalculaFamilias(oDadosPerg, oProcess, oDadosCorrente)

         (cAliasBQC)->(DbSkip())
      EndDo

      lRetorno := .T.
   EndIf

   (cAliasBQC)->(DbCloseArea())

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} QuerySubContratos
Retorna Query para utilizar no Calculo da receita e custo do nivel do
SubContratos

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function QuerySubContratos(oDadosPerg, oDadosCorrente)

   Local cQuery := ""
 
   If ValType(oPrepBQC) == "U"
      cQuery := " SELECT BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB FROM "+RetSQLName("BQC")

      cQuery += "  WHERE BQC_FILIAL = ?"
      cQuery += "	   AND BQC_CODIGO = ?"
      cQuery += "	   AND BQC_NUMCON = ?"
      cQuery += "	   AND BQC_VERCON = ?"
   
      cQuery += "	   AND BQC_SUBCON >= ?"
      cQuery += "	   AND BQC_SUBCON <= ?"

      cQuery += "	   AND BQC_VERSUB >= ?"
      cQuery += "	   AND BQC_VERSUB <= ?"

      cQuery += "    AND D_E_L_E_T_= ' ' "

      cQuery += " ORDER BY BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB"

      oPrepBQC := FWPreparedStatement():New(cQuery)
   EndIf

	oPrepBQC:SetString(1, xFilial("BQC"))
	oPrepBQC:SetString(2, oDadosPerg["cCodOpe"]+oDadosCorrente["cEmpresa"])
	oPrepBQC:SetString(3, oDadosCorrente["cContrato"])
	oPrepBQC:SetString(4, oDadosCorrente["cVerContrato"])
	oPrepBQC:SetString(5, oDadosPerg["cSubDe"])
	oPrepBQC:SetString(6, oDadosPerg["cSubAte"])
	oPrepBQC:SetString(7, oDadosPerg["cVerSubDe"])
   oPrepBQC:SetString(8, oDadosPerg["cVerSubAte"])
	
	cQuery := oPrepBQC:GetFixQuery()

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} CalculaFamilias
Calcula a receita e custo do nivel da Familia

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CalculaFamilias(oDadosPerg, oProcess, oDadosCorrente)

   Local cAliasBA3 := ""
   Local cQuery := ""
   Local lRetorno := .F.

   Local cCodEmpresa := ""
   Local cContrato := ""
   Local cVerContrato := ""
   Local cSubContato := ""
   Local cVerSubContrato := ""
   Local cMatricula := ""
   Local cTipoFamilia := ""

   // Define a Regua
   oProcess:SetRegua2(TotalFamilias(oDadosPerg, oDadosCorrente))

   cAliasBA3 := GetNextAlias()
   cQuery := QueryFamilias(oDadosPerg, oDadosCorrente)

   dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasBA3, .F., .T.)
               
   If !(cAliasBA3)->(Eof())
      While !(cAliasBA3)->(Eof())

         cCodEmpresa := (cAliasBA3)->BA3_CODEMP
         cContrato := (cAliasBA3)->BA3_CONEMP
         cVerContrato := (cAliasBA3)->BA3_VERCON
         cSubContato := (cAliasBA3)->BA3_SUBCON
         cVerSubContrato := (cAliasBA3)->BA3_VERSUB
         cMatricula := (cAliasBA3)->BA3_MATRIC
         cTipoFamilia := (cAliasBA3)->BA3_TIPOUS

         oProcess:IncRegua2(STR0004+cCodEmpresa+"."+cMatricula) // "Familia "

         // Calcula Receita e Custo no Nivel da Familia
         CalculaRC("4", oDadosPerg["cMesDe"], oDadosPerg["cMesAte"], oDadosPerg["cAno"], oDadosPerg["cCodOpe"], cCodEmpresa, cContrato,;
                   cVerContrato, cSubContato, cVerSubContrato, cMatricula, "", oDadosPerg["nTpRec"], "", cTipoFamilia)

         oDadosCorrente["cFamilia"] := cMatricula            
         
         CalculaBeneficiarios(oDadosPerg, oDadosCorrente)

         (cAliasBA3)->(DbSkip())
      EndDo

      lRetorno := .T.
      oProcess:IncRegua2(STR0009) // "Concluido"
   EndIf

   (cAliasBA3)->(DbCloseArea())

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryFamilias
Retorna Query para utilizar no Calculo da receita e custo do nivel da
Familia

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function QueryFamilias(oDadosPerg, oDadosCorrente, lCount)

   Local cQuery := ""
 
   Default lCount := .F.

   If (ValType(oPrepBA3Count) == "U" .And. lCount) .Or. (ValType(oPrepBA3) == "U" .And. !lCount)

      If lCount
         cQuery := " SELECT COUNT(BA3_MATRIC) CONTADOR FROM "+RetSQLName("BA3")
      Else
         cQuery := " SELECT BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_MATRIC, BA3_TIPOUS FROM "+RetSQLName("BA3")
      EndIf

      cQuery += "  WHERE BA3_FILIAL = ?"
      cQuery += "	   AND BA3_CODINT = ?"
      cQuery += "	   AND BA3_CODEMP = ?"

      cQuery += "	   AND BA3_MATRIC >= ?"
      cQuery += "	   AND BA3_MATRIC <= ?"

      cQuery += "    AND D_E_L_E_T_= ' ' "
      
      If !lCount
         cQuery += " ORDER BY BA3_CODINT, BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_MATRIC"
         oPrepBA3 := FWPreparedStatement():New(cQuery)
      Else
         oPrepBA3Count := FWPreparedStatement():New(cQuery)
      EndIf

   EndIf

   If lCount
      oPrepBA3Count:SetString(1, xFilial("BA3"))
      oPrepBA3Count:SetString(2, oDadosPerg["cCodOpe"])
      oPrepBA3Count:SetString(3, oDadosCorrente["cEmpresa"])
      oPrepBA3Count:SetString(4, oDadosPerg["cFamDe"])
      oPrepBA3Count:SetString(5, oDadosPerg["cFamAte"])

      cQuery := oPrepBA3Count:GetFixQuery()
   Else
      oPrepBA3:SetString(1, xFilial("BA3"))
      oPrepBA3:SetString(2, oDadosPerg["cCodOpe"])
      oPrepBA3:SetString(3, oDadosCorrente["cEmpresa"])
      oPrepBA3:SetString(4, oDadosPerg["cFamDe"])
      oPrepBA3:SetString(5, oDadosPerg["cFamAte"])

      cQuery := oPrepBA3:GetFixQuery()
   EndIf

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} TotalFamilias
Retorna o total de Familias de acordo com a query de processamento
para montar a regua

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function TotalFamilias(oDadosPerg, oDadosCorrente)

   Local cQuery := ""
   Local nTotal := 0

   cQuery := QueryFamilias(oDadosPerg, oDadosCorrente, .T.)

   nTotal := MPSysExecScalar(cQuery, "CONTADOR")

Return nTotal


//-------------------------------------------------------------------
/*/{Protheus.doc} CalculaBeneficiarios
Calcula a receita e custo do nivel do Beneficiário

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CalculaBeneficiarios(oDadosPerg, oDadosCorrente)

   Local cAliasBA1 := ""
   Local cQuery := ""
   Local lRetorno := .F.

   Local cCodEmpresa := ""
   Local cContrato := ""
   Local cVerContrato := ""
   Local cSubContato := ""
   Local cVerSubContrato := ""
   Local cMatricula := ""
   Local cTipoBeneficiario := ""
   Local cTipoFamilia := ""
   Local cCodPlano := ""

   cAliasBA1 := GetNextAlias()
   cQuery := QueryBeneficiarios(oDadosPerg, oDadosCorrente)

   dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasBA1, .F., .T.)
               
   If !(cAliasBA1)->(Eof())
      While !(cAliasBA1)->(Eof())

         cCodEmpresa := (cAliasBA1)->BA1_CODEMP
         cContrato := (cAliasBA1)->BA1_CONEMP
         cVerContrato := (cAliasBA1)->BA1_VERCON
         cSubContato := (cAliasBA1)->BA1_SUBCON
         cVerSubContrato := (cAliasBA1)->BA1_VERSUB
         cMatricula := (cAliasBA1)->BA1_MATRIC
         cTipoBeneficiario := (cAliasBA1)->BA1_TIPREG
         cTipoFamilia := (cAliasBA1)->BA3_TIPOUS 
         cCodPlano := IIf(Empty((cAliasBA1)->BA1_CODPLA), (cAliasBA1)->BA3_CODPLA, (cAliasBA1)->BA1_CODPLA)

         // Calcula Receita e Custo no Nivel do Beneficiário
			CalculaRC("5", oDadosPerg["cMesDe"], oDadosPerg["cMesAte"], oDadosPerg["cAno"], oDadosPerg["cCodOpe"], cCodEmpresa, cContrato,;
                   cVerContrato, cSubContato, cVerSubContrato, cMatricula, cTipoBeneficiario, oDadosPerg["nTpRec"], cCodPlano, cTipoFamilia)

         (cAliasBA1)->(DbSkip())
      EndDo

      lRetorno := .T.
   EndIf

   (cAliasBA1)->(DbCloseArea())

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryBeneficiarios
Retorna Query para utilizar no Calculo da receita e custo do nivel do
Beneficiarios

@author Vinicius Queiros Teixeira
@since 19/04/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function QueryBeneficiarios(oDadosPerg, oDadosCorrente)

   Local cQuery := ""

   If ValType(oPrepBA1) == "U"
      cQuery := " SELECT BA1.BA1_CODEMP, BA1.BA1_CONEMP, BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB, BA1.BA1_MATRIC,"
      cQuery += " BA1.BA1_TIPREG, BA1.BA1_CODPLA, BA3.BA3_TIPOUS, BA3.BA3_CODPLA FROM "+RetSQLName("BA1")+" BA1"

      cQuery += " INNER JOIN "+RetSqlName("BA3")+" BA3"
      cQuery += "     ON BA3.BA3_FILIAL = '"+xFilial("BA3")+"' "
      cQuery += "    AND BA3.BA3_CODINT = BA1.BA1_CODINT "
      cQuery += "    AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
      cQuery += "    AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
      cQuery += "    AND BA3.D_E_L_E_T_ = ' ' "

      cQuery += "  WHERE BA1.BA1_FILIAL = ?"
      cQuery += "	   AND BA1.BA1_CODINT = ?"
      cQuery += "	   AND BA1.BA1_CODEMP = ?"
      cQuery += "	   AND BA1.BA1_MATRIC = ?"
      cQuery += "	   AND BA1.BA1_TIPREG >= ?"
      cQuery += "	   AND BA1.BA1_TIPREG <= ?"

      cQuery += "    AND BA1.D_E_L_E_T_= ' ' "

      cQuery += " ORDER BY BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_MATRIC, BA1_TIPREG"

      oPrepBA1 := FWPreparedStatement():New(cQuery)
   EndIf

	oPrepBA1:SetString(1, xFilial("BA1"))
	oPrepBA1:SetString(2, oDadosPerg["cCodOpe"])
	oPrepBA1:SetString(3, oDadosCorrente["cEmpresa"])
   oPrepBA1:SetString(4, oDadosCorrente["cFamilia"])
   oPrepBA1:SetString(5, oDadosPerg["cUsrDe"])
   oPrepBA1:SetString(6, oDadosPerg["cUsrAte"])

	cQuery := oPrepBA1:GetFixQuery()
  
Return cQuery