#include "protheus.ch"

/*
Funcao      : UPDX1CI150
Objetivos   : Ajustar o SX1
Autor       : Carlos Eduardo Olivieri
Data 	      : 04/04/2018
*/
Static Function UPDX1CI150(o, cGrupo, nOrdem, aCpos, aVals)

   Local aStru := {}
   Local aData := {}

   SX1->(dbSetOrder(1))
   If SX1->(dbSeek(AvKey(cGrupo, "X1_GRUPO")+AvKey(StrZero(nOrdem,2),"X1_ORDEM") ))

      aStru := {'X1_GRUPO', 'X1_ORDEM'}
      aData := {cGrupo, StrZero(nOrdem,2)}

      aSize(aStru, Len(aStru)+Len(aCpos))
      aCopy(aCpos, aStru, 1, Len(aCpos), 3)

      aSize(aData, Len(aData)+Len(aVals))
      aCopy(aVals, aData, 1, Len(aVals), 3)

      o:TableStruct('SX1', aStru)
      o:TableData('SX1', aData)
   EndIf

Return

//AQUISIÇÃO
/*
Programa   : ESSPS01()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 22/11/2012 
*/
Function ESSPS01()
Local oEDCPEDTST
Local oReport 
Local lRet      := .T.
Local lShowMsg  := .T.
Local lPergunte := .T.  
Private TpReg   := "A"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSPS01",lShowMsg)//Relatorio - Processos Aquisição Seviços
   
   lRet := !oEDCPEDTST:lError
   lPergunte := SicoServSx1("ESSPS001")
   
   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
      
   EndIf

End Sequence

Return lRet

/*
Programa   : ESSPS02()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 22/11/2012 
*/
Function ESSPS02()//Relatorio - Processos Aquisição Pendente Seviços
Local oEDCPEDTST
Local oReport 
Local lRet      := .T. 
Local lShowMsg  := .T. //Mostra Mensagem de erro
Local lPergunte := .T.
Private TpReg   := "A"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSPS02",lShowMsg)//Relatorio - Registros Aquisição Seviços
   
   lRet := !oEDCPEDTST:lError
   lPergunte := SicoServSx1("ESSPS002")
   
   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
   EndIf
   
End Sequence

Return lRet

/*
Programa   : ESSRS01()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 04/12/2012 
*/
Function ESSRS01()//Relatorio - Processos Aquisição Serviços
Local oEDCPEDTST
Local oReport 
Local lRet      := .T. 
Local lShowMsg  := .T. //Mostra Mensagem de erro
Local lPergunte := .T.
Private TpReg   := "A"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSRS01",lShowMsg)//Relatorio - Processos Seviços Pendentes 
   
   lRet := !oEDCPEDTST:lError
   lPergunte := SicoServSx1("ESSRS002") //RRC - 07/01/2013 - Alterada sequência de perguntes
   
   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
   EndIf
   
End Sequence

Return lRet

/*
Programa   : ESSRS02()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 04/12/2012 
*/
Function ESSRS02()//Relatorio - Processos Aquisição Pendente de Registro
Local oEDCPEDTST
Local oReport 
Local lRet      := .T. 
Local lShowMsg  := .T. //Mostra Mensagem de erro
Local lPergunte := .T.
Private TpReg   := "A"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSRS02",lShowMsg)
   
   lRet := !oEDCPEDTST:lError
   
   lPergunte := SicoServSx1("ESSRS003") //RRC - 07/01/2013 - Alterada sequência de perguntes
   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
   EndIf
   
End Sequence

Return lRet


//VENDA
/*
Programa   : ESSPS03()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 22/11/2012 
*/
Function ESSPS03()//Relatorio - Processos Venda de Processo
Local oEDCPEDTST
Local oReport 
Local lRet      := .T.
Local lShowMsg  := .T. //Mostra Mensagem de erro
Local lPergunte := .T. 
Private TpReg   := "V"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSPS03",lShowMsg)//Relatorio - Processos Seviços

   lRet := !oEDCPEDTST:lError
   lPergunte := SicoServSx1("ESSPS001")

   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
   EndIf

End Sequence

Return lRet

/*
Programa   : ESSPS04()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 22/11/2012 
*/
Function ESSPS04()//Relatorio - Processos Venda Pendente de Processo
Local oEDCPEDTST
Local oReport 
Local lRet      := .T. 
Local lShowMsg  := .T. //Mostra Mensagem de erro
Local lPergunte := .T.
Private TpReg   := "V"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSPS04",lShowMsg)//Relatorio - Registros Seviços
   
   lRet := !oEDCPEDTST:lError
   lPergunte := SicoServSx1("ESSPS002")
   
   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
   EndIf
   
End Sequence

Return lRet

/*
Programa   : ESSRS03()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 04/12/2012 
*/
Function ESSRS03()//Relatorio - Processos Venda de Registro
Local oEDCPEDTST
Local oReport 
Local lRet      := .T. 
Local lShowMsg  := .T. //Mostra Mensagem de erro
Local lPergunte := .T.
Private TpReg   := "V"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSRS03",lShowMsg)//Relatorio - Processos Seviços Pendentes 
   
   lRet := !oEDCPEDTST:lError
   lPergunte := SicoServSx1("ESSRS002") //RRC - 07/01/2013 - Alterada sequência de perguntes
   
   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
   EndIf
   
End Sequence

Return lRet

/*
Programa   : ESSRS04()
Objetivo   : Função para a chamada da da classe EasyTReport a partir do menu.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 04/12/2012 
*/
Function ESSRS04() //Relatorio - Processos de Venda Pendente de Registro
Local oEDCPEDTST
Local oReport 
Local lRet      := .T. 
Local lShowMsg  := .T. //Mostra Mensagem de erro
Local lPergunte := .T.
Private TpReg   := "V"
Begin Sequence

   oEDCPEDTST:= EasyTReport():New("ESSRS04",lShowMsg)
   
   lRet := !oEDCPEDTST:lError
   
   lPergunte := SicoServSx1("ESSRS003") //RRC - 07/01/2013 - Alterada sequência de perguntes
   If lRet .And. lPergunte
      oReport := oEDCPEDTST:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCPEDTST:PrintReport()
   EndIf
   
End Sequence

Return lRet


/*
Programa   : ESSCIValid()
Objetivo   : Verifica se o valor inserido no pergunte existe na tabela diferenciando se aquisição ou venda.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 01/12/2012 
*/
Function ESSCIValid(cCampo,lPar)
Local   lRet   := .T.
Local   aOrd   := SaveOrd({"EJW","EJY"})
Local   cAux   := "" //A=Aquisição; V=Venda
Default cCampo := "" //Empedir error log caso nao informe parametro.
Default lPar   := .F.//Parametro para pergunte "SiscoRel3"
cAux := TpReg

Do Case
   Case Upper(cCampo) == "PROCESSO" 
      If cAux $ "A/V"
         EJW->(dbSetOrder(1))
         If lPar
            lRet := EJW->(DbSeek(xFilial("EJW")+cAux+AvKey(MV_PAR01,"EJW_PROCES") )) .And. EJW->EJW_STTPED$"1/2"
         Else
            lRet := Empty(MV_PAR02) .Or. EJW->(DbSeek(xFilial("EJW")+cAux+AvKey(MV_PAR02,"EJW_PROCES") )) //MCF - 11/05/2015                    
         End If
      /*   
      ElseIf MV_PAR01 == 3
         EJW->(dbSetOrder(2))
         If lPar 
            lRet := EJW->(DbSeek(xFilial("EJW")+AvKey(MV_PAR02,"EJW_PROCES") ))//.And. EJW->EJW_STTPED$"1/2"
         Else
            lRet := EJW->(DbSeek(xFilial("EJW")+AvKey(MV_PAR03,"EJW_PROCES") ))
         End If
      */
      End If
      
   Case Upper(cCampo) == "REGISTRO"
      If cAux $ "A/V"
         EJY->(dbSetOrder(1))
         If lPar 
            lRet := EJY->(DbSeek(xFilial("EJY")+cAux+AvKey(MV_PAR02,"EJY_REGIST") )) .And. EJY->EJY_STTSIS$"1/2"
         Else
            lRet := EJY->(DbSeek(xFilial("EJY")+cAux+AvKey(MV_PAR02,"EJY_REGIST") )) .And. (EJY->EJY_STTSIS$"1/2".OR. PendenteEL9(cAux,AvKey(MV_PAR02,"EJY_REGIST")) )
         End If
      /* 
      ElseIf MV_PAR01 == 3
         EJY->(dbSetOrder(2)) 
         lRet := EJY->(DbSeek(xFilial("EJY")+AvKey(MV_PAR03,"EJY_REGIST") ))
      */
      End If
      
   Otherwise
      MsgInfo("Erro na função ESSCIValid(), parâmetro informado inválido.")
      
End Case

If(!lRet,MsgInfo("Conteúdo não cadastrado na tabela ou conteúdo do parâmetro inválido."),)

RestOrd(aOrd, .T.)
   
Return lRet

/*
Programa   : ESSCIQtd()
Objetivo   : Verifica se o valor inserido no pergunte existe na tabela diferenciando se aquisição ou venda.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 01/12/2012 
*/
//cTpSeek = QTD   - para retornar quantidade de serviços pendentes.
//cTpSeek = VALOR - para retornar valor total dos serviços pendentes.
Function ESSCIQtd(cTipo,cProcesso,cTpSeek)//Função usado no relatório de processos pendentes
Local   nQtd   := 0
Local   nValor := 0
Default cTipo   := ""
Default cProcesso := ""
Default cTpSeek := ""
cTipo   := AvKey(cTipo  ,"EJX_TPPROC")
cProcesso := AvKey(cProcesso,"EJX_PROCES")
DBSELECTAREA("EJX")
EJX->(DBSETORDER(1))//EJX_FILIAL+EJX_TPPROC+EJX_PROCES+EJX_SEQPRC 
EJX->(DBSEEK(xFilial("EJW")+cTipo+cProcesso ))//alterar para pegar status apenas 1 e 2.

Do Case
   Case Upper(cTpSeek) == "QTD"
      While(!EJX->(EOF()) .And. cTipo==EJX->EJX_TPPROC .And. cProcesso==EJX->EJX_PROCES .And.;
            IF(MV_PAR04 == 3,EJX->EJX_STTPED $"1/2",EJX->EJX_STTPED == AllTrim(STR(MV_PAR04)) ) ) //MCF - 25/05/2015
         nQtd += 1
         EJX->(dbskip())
      End Do
      Return nQtd
      
   Case Upper(cTpSeek) == "VALOR"
      While(!EJX->(EOF()) .And. cTipo==EJX->EJX_TPPROC .And. cProcesso==EJX->EJX_PROCES .And.;
            IF(MV_PAR04 == 3,EJX->EJX_STTPED $"1/2",EJX->EJX_STTPED == AllTrim(STR(MV_PAR04)) ) ) //MCF - 25/05/2015
         nValor += EJX->EJX_VL_MOE
         EJX->(dbskip())
      End Do
      Return nValor   
End Case

Return "Erro na função ESSCIQtd() parametro incorreto."   

/*
Programa   : ESSCIFilt()
Objetivo   : Utilizada para o filtro do Protheus Report.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 01/12/2012
Parametros : 
cTipo A-Aquisição V-Venda
cTpFiltro := tipo do filtro a ser aplicado
*/
Function ESSCIFilt(cTipo,cTpFiltro)
Local   lRet      := .T.
Local   cStatus
Default cTpFiltro := ""
cTpFiltro := Upper(cTpFiltro)
cTipo     := Upper(cTipo)

Do Case
   
   Case cTpFiltro == "PED_SERVICO"//Processo Serviço: Aquisição/Venda *Capa, Pergunte: SISCOREL1 
      cStatus := Avkey(MV_PAR05,"EJW_STTPED")
            
      lRet := EJW->EJW_TPPROC == cTipo .AND.;
      IF(EMPTY(MV_PAR02),.T.,AvKey(MV_PAR02,"EJW_PROCES") == EJW->EJW_PROCES).AND.;
      IF(EMPTY(MV_PAR03),.T.,MV_PAR03 <= EJW->EJW_DTPROC)                    .AND.;
      IF(EMPTY(MV_PAR04),.T.,MV_PAR04 >= EJW->EJW_DTPROC)                    .AND.;
      IF(cStatus=="5"   ,.T.,cStatus  == EJW->EJW_STTPED)

   Case cTpFiltro == "PED_PENDENTE"//Processo Pendente: Aquisição/Venda *Capa, Pergunte: SISCOREL3 
      If(MV_PAR04 == 3, cStatus := "1/2" ,cStatus := Avkey(MV_PAR03,"EJW_STTPED") )

      lRet := EJW->EJW_TPPROC == cTipo                                       .AND.; 
      If(Empty(MV_PAR01),.T.,AvKey(MV_PAR01,"EJW_PROCES") == EJW->EJW_PROCES).AND.;
      If(Empty(MV_PAR02),.T.,MV_PAR02 <= EJW->EJW_DTPROC)                    .AND.;
      If(Empty(MV_PAR03),.T.,MV_PAR03 >= EJW->EJW_DTPROC)                    .AND.;
      If(Empty(MV_PAR04),.T.,EJW->EJW_STTPED $ cStatus)
   
   Case cTpFiltro == "REG_SERVICO"//Registro Serviço: Aquisição/Venda *Capa, Pergunte: SISCOREL2 
      cStatus := Avkey(MV_PAR05,"EJY_STTSIS")
      
      lRet := EJY->EJY_TPPROC == cTipo                                       .AND.;
      IF(EMPTY(MV_PAR02),.T.,AvKey(MV_PAR02,"EJY_REGIST") == EJY->EJY_REGIST).AND.;
      IF(EMPTY(MV_PAR03),.T.,MV_PAR03 <= EJY->EJY_DTPROC)                    .AND.;
      IF(EMPTY(MV_PAR04),.T.,MV_PAR04 >= EJY->EJY_DTPROC)                    .AND.;
      IF(cStatus=="4"   ,.T.,cStatus  == EJY->EJY_STTSIS)
      
   Case cTpFiltro == "REG_PENDENTE"//Registro Pendentes Aquisição/Venda *Capa, Pergunte: SISCOREL4 
      If(MV_PAR05 == 3, cStatus := "1/2" ,cStatus   := Avkey(MV_PAR05,"EJY_STTSIS") )
      
      lRet := EJY->EJY_TPPROC == cTipo                                           .AND.;
      If(Empty(MV_PAR02),.T.,AvKey(MV_PAR02,"EJY_REGIST") == EJY->EJY_REGIST)    .AND.;
      If(Empty(MV_PAR03),.T.,MV_PAR03 <= EJY->EJY_DTPROC)                        .AND.;
      If(Empty(MV_PAR04),.T.,MV_PAR04 >= EJY->EJY_DTPROC)                        .AND.;                      
      FiltRegPendente()

   Case cTpFiltro == "REG_ANA_PEN"//Filtro de detalhes:Registro Pendentes - Registro Analitico Pendente 
      //cStatus := Avkey(MV_PAR05,"EJZ_STTSIS")
      If(MV_PAR05 == 3, cStatus := "1/2" ,cStatus   := Avkey(MV_PAR05,"EJY_STTSIS") )
      lRet := EJZ->EJZ_TPPROC == cTipo    .AND.;
      EJZ->EJZ_REGIST == EJY->EJY_REGIST

   Case cTpFiltro == "PAG_ANA_PEN"//Filtro de detalhes: Registro Pendentes - detalhes de pagamento
      lRet := EL9->EL9_TPPROC == cTipo    .AND.;
      EL9->EL9_REGIST == EJY->EJY_REGIST  .AND.;
      EL9->EL9_STTSIS $"1/3"
      
   OtherWise
      MsgInfo("Parametro incorreto informado na função ESSCIFilt().")
      lRet := .F.

End Case

Return lRet

/*
Programa   : SicoServSx1()
Objetivo   : Verificar se existe os perguntes dos siscoserv.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 17/12/2012
*/
Static Function SicoServSx1(Parametro)
Local lRet := .T.
Local i
Local aPergunte
Local oUPDCI150
Local cOpcao
Local aCpos := {}
Local aVals := {}

Default aPergunte := {"ESSPS001","ESSPS002","ESSRS002","ESSRS003"}

If ValType(Parametro) == "C"
   aPergunte := {Parametro} 
Else
   aPergunte := Parametro
End If

Begin Sequence
   For i:= 1 to Len(aPergunte)
      If !SX1->(DbSeek(aPergunte[i]))
         lRet := .F.
         MsgStop("Não será possivel executar esta rotina, por favor execute o update USSIGAESS.")
         Break
      Else
         If TpReg == "A"
            cOpcao = "Aquisição"
         ElseIf TpReg == "V"
            cOpcao = "Venda"
         EndIf

         oUPDCI150 := AvUpdate01():New()

         aCpos := {'X1_GSC', 'X1_TAMANHO', 'X1_CNT01'}
         aVals := {'S', 10, cOpcao}

         oUPDCI150:aChamados := { {nModulo, {|o| UPDX1CI150(o, Parametro, 6, aCpos, aVals)}, .F.} }
         oUPDCI150:Init(,.T.)
      
      End If      
   Next
End Sequence

Return lRet

/*
Programa   : PendenteEL9()
Objetivo   : Verificar se existe pagamento pendentes no registro na tabela EL9.
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 15/10/2013
*/
Function PendenteEL9(cTipo,cRegistro)
Local lRet := .F.
Local aOrd := SaveOrd({"EL9"}) 
Begin Sequence

EL9->(dbSetOrder(1)) 
EL9->(dbSeek(xFilial("EL9")+AvKey(cTipo,"EL9_TPPROC")+AvKey(cRegistro,"EL9_REGIST") )  )
Do While EL9->EL9_REGIST == AvKey(cRegistro,"EJY_REGIST") .AND. !EL9->(EOF())
   If EL9->EL9_STTSIS $ "1/3" 
      lRet := .T.
      Break
   End If  
   EL9->(dbSkip())
End Do

RestOrd(aOrd, .T.) 
End Sequence

Return lRet 

/*
Programa   : FiltRegPendente()
Objetivo   : Condição para o filtro do relatorio de registro pendente
Retorno    : Logico.
Autores    : Fabio Satoru Yamamoto
Data/Hora  : 07/11/2013
*/
Static Function FiltRegPendente()
Local lRet := .F.

Begin Sequence

If Valtype(MV_PAR05) == "U"
   MsgInfo("Erro na Função FiltRegPendente() do fonte ESSCI150")
   Return .T.
End If
Do Case

   Case MV_PAR05 == 1   
      lRet := EJY_STTSIS$"1"

   Case MV_PAR05 == 2
      lRet := EJY_STTSIS$"2"   .Or.(EJY_STTSIS$"3" .And. PendenteEL9(EJY->EJY_TPPROC,EJY->EJY_REGIST))

   Case MV_PAR05 == 3
      lRet := EJY_STTSIS$"1/2" .Or. PendenteEL9(EJY->EJY_TPPROC,EJY->EJY_REGIST)
   
   Otherwise
      MsgInfo("Erro na Função FiltRegPendente() do fonte ESSCI150")
   
End Case

End Sequence

Return lRet