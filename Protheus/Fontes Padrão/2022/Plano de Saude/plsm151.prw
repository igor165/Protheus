// nao esta calculando comissao quando o usuario eh transferido, pois a matricula eh alterada
// corrigir o CH de não pode excluir porque já pagou ou já contabilizou

#Include "topconn.ch"
#Include "plsm151.ch"
#Include "protheus.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSM151  ³ Autor ³ Cesar Valadao         ³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo das Comissoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSM151()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAPLS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracoes desde sua construcao inicial                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 19/05/06 ³99557 ³ Sandro H.   ³ Inclusao Regras Composicao Base de    ³±±
±±³          ³      ³             ³ Calculo das Comissoes. Ajuste no      ³±±
±±³          ³      ³             ³ rateio da comissao para a equipe.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Array com a comissao
#DEFINE C_TAM_ARRAY		25				// Numero de elementos do array
#DEFINE C_CODVEN			 1
#DEFINE C_CODEQU			 2
#DEFINE C_PREFIXO			 3
#DEFINE C_NUM				 4
#DEFINE C_PARCELA			 5
#DEFINE C_TIPO   			 6
#DEFINE C_CODEMP			 7
#DEFINE C_MATRIC			 8
#DEFINE C_TIPREG			 9
#DEFINE C_DIGITO			10
#DEFINE C_NUMCON			11
#DEFINE C_VERCON			12
#DEFINE C_SUBCON			13
#DEFINE C_VERSUB			14
#DEFINE C_SEQBXO			15
#DEFINE C_NUMPAR			16
#DEFINE C_BASEMI			17
#DEFINE C_BASBAI			18
#DEFINE C_PERCOM			19
#DEFINE C_VALCOM			20
#DEFINE C_PERBAI			21
#DEFINE C_PEREMI			22
#DEFINE C_REFERE			23
#DEFINE C_BAIXA 			24
#DEFINE C_SINIST 			25

Function PLSM151()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpca 	  := 0
Local aSays 	  := {}, aButtons := {}
Private cCadastro := STR0001 //"Calculo das Comissões"
Private cPerg     := "PLM151"
Private aLog	  := {}
Private lMultCalc   := GETNEWPAR("MV_PLMLTCM", .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da nova função tNewProcess() a partir do Release R1.1 da v.10                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetRpoRelease()=="R1.1"
    tNewProcess():New("PLSM151",cCadastro,{|oSelf|Pls151Calc(oSelf) },STR0001,cPerg,,.F.,,,.T.,.T. )
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta texto para janela de processamento                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aSays,STR0002) //"Efetua o calculo de comissoes conforme parametros informados."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta botoes para janela de processamento                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe janela de processamento                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FormBatch( cCadastro, aSays, aButtons,, 160 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa calculo                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  nOpca == 1
		msAguarde( {|| Pls151Calc() }, STR0003,"", .T.) //"Calculando Comissões ..."
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se existe log de ocorrencias                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  len(aLog) > 0
    PLSCRIGEN(aLog,{{STR0004,"@!",70},{STR0005,"@!",70},{STR0006,"@!",70}},STR0007,nil,nil) //"IdentIficacao"###"Conteudo"###"Mensagem"###"Calculo da Programacao para Pagamento de Comissoes - Log de Ocorrencias"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do programa                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS151CALC³ Autor ³ Cesar Valadao         ³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula comissoes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLS151CALC()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLS151CALC(oSelf)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nInd	         := 0
Local aStruc         := {}
Local i		         := 0
Local xx             := 0
Local cQuery         := ""
Local lAchou         := .F.
Local aBXQ 	         := {}           
Local lEquipe        := .F.   
Local lRateio        := .F.
Local nRateio        := 0
Local cCodVen        := ""
Local cCodVen1       := ""
Local aRateio        := {}
Local cRateio        := ""
Local cVenAnt        := ""
Local ii             := 0
Local cGruRat        := ""
Local lSEQBXS        := BXO->(FieldPos("BXO_SEQBXS")) > 0
Local nTotBai        := 0
Local nTotEmi        := 0
Local nBai           := 0
Local nEmi           := 0
Local aRet           := {}
Local nValCom        := 0
Local nPerCom        := 0
Local nValor         := 0
Local nValAbt        := 0
Local lComissao      := .F.
Local lMesAnt	 		:= .F.
Local aRet1          := {}
Local lBXP_SINIST    := BXP->(FieldPos("BXP_SINIST")) > 0
Local lPL151STIT     := ExistBlock("PL151STIT")
Local lPL151COM      := ExistBlock("PL151COM")
Local lPL151VLD      := ExistBlock("PL151VLD")  
Local lArrend := .F.
Private nVlrComSobra := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_PAR01 - Mes Base Movimento ³
//³ MV_PAR02 - Ano Base Movimento ³
//³ MV_PAR03 - Operadora          ³
//³ MV_PAR04 - Empresa de         ³
//³ MV_PAR05 - Empresa Ate        ³
//³ MV_PAR06 - Contrato De        ³
//³ MV_PAR07 - Contrato Ate       ³
//³ MV_PAR08 - Sub-Contrato De    ³
//³ MV_PAR09 - Sub-Contrato Ate   ³
//³ MV_PAR10 - Vendedor De        ³
//³ MV_PAR11 - Vendedor Ate       ³
//³ MV_PAR12 - Equipe De          ³
//³ MV_PAR13 - Equipe Ate         ³
//³ MV_PAR14 - Processamento      ³
//³ MV_PAR15 - Emissao de         ³
//³ MV_PAR16 - Emissao ate        ³
//³ MV_PAR17 - Baixa de           ³
//³ MV_PAR18 - Baixa ate          ³
//³ MV_PAR19 - Considera mes ant. ³
//³ MV_PAR20 - Realiza Arredondamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

cMes    := MV_PAR01
cAno    := MV_PAR02
cOper   := MV_PAR03
cEmpDe  := MV_PAR04
cEmpAte := MV_PAR05
cConDe  := MV_PAR06
cConAte := MV_PAR07
cSubDe  := MV_PAR08
cSubAte := MV_PAR09
cVenDe  := MV_PAR10
cVenAte := MV_PAR11
cEquDe  := MV_PAR12
cEquAte := MV_PAR13
nProc   := MV_PAR14
dEmiDe  := MV_PAR15
dEmiAte := MV_PAR16
dBaiDe  := MV_PAR17
dBaiAte := MV_PAR18 
If Type("MV_PAR19") == "N"
	lMesAnt := MV_PAR19 == 1
Endif

If Type("MV_PAR20") == "N"
	lArrend := MV_PAR20 == 1
Endif

If  nProc <> 1 .and. ;
    nProc <> 2
    msgalert(STR0020)
    Return()
EndIf    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para verIficar se ja houve calculo                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("BXQ")

cQuery := " SELECT COUNT(*) COUNT " 
cQuery += "  FROM " + RetSQLName("BXQ") + " BXQ "
cQuery += "  WHERE BXQ.BXQ_FILIAL =  '"  + xFilial("BXQ")    + "' "
cQuery += "    AND BXQ.BXQ_CODINT =  '"  + cOper             + "' "
cQuery += "    AND BXQ.BXQ_CODEMP >= '"  + cEmpDe            + "' "
cQuery += "    AND BXQ.BXQ_CODEMP <= '"  + cEmpAte           + "' "
cQuery += "    AND BXQ.BXQ_NUMCON >= '"  + cConDe            + "' "
cQuery += "    AND BXQ.BXQ_NUMCON <= '"  + cConAte           + "' "
cQuery += "    AND BXQ.BXQ_SUBCON >= '"  + cSubDe            + "' "
cQuery += "    AND BXQ.BXQ_SUBCON <= '"  + cSubAte           + "' "
cQuery += "    AND BXQ.BXQ_CODVEN >= '"  + cVenDe            + "' "
cQuery += "    AND BXQ.BXQ_CODVEN <= '"  + cVenAte           + "' "
cQuery += "    AND BXQ.BXQ_CODEQU >= '"  + cEquDe            + "' "
cQuery += "    AND BXQ.BXQ_CODEQU <= '"  + cEquAte           + "' "
cQuery += "    AND BXQ.BXQ_ANO    =  '"  + cAno              + "' "
cQuery += "    AND BXQ.BXQ_MES    =  '"  + cMes              + "' "
cQuery += "    AND BXQ.D_E_L_E_T_ <> '*' " 

cQuery	:= ChangeQuery(cQuery)
TcQuery cQuery New Alias "BXQTMP" 
TcSetField("BXQTMP","COUNT","N",15,0)

If !(lMultCalc)
    nQtdReg := COUNT
else 
    if nProc==1
        nQtdReg := 0
    else 
        nQtdReg := COUNT
    endif
endif        
BXQTMP->( DbCloseArea() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Novo Calculo   e   Ja Tem Calculo Realizado                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nProc == 1 .and. nQtdReg > 0 
	Aviso(STR0008, STR0009, {"Ok"}) //"Cálculo de Comissões"###"Não será possível realizar novo cálculo, pois já existe comissão calculada para os parametros informados. Selecione Descálculo ou Reprocessar."
	Return()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cancelamento de Calculo                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nProc == 2  // Quer cancelar calculo 
    If  nQtdReg == 0 // Nao Tem Calculo Realizado
  	    Aviso(STR0008, STR0010, {"Ok"}) //"Cálculo de Comissões"###"Não é possível fazer o descálculo pois não existem comissões cálculadas para os parametros informados."
	    Return()
    Else
        cQuery := " SELECT COUNT(*) COUNT " 
        cQuery += " FROM " + RetSQLName("BXQ") + " BXQ "
        cQuery += " WHERE BXQ.BXQ_FILIAL =  '"  + xFilial("BXQ")    + "' "
        cQuery += "    AND BXQ.BXQ_CODINT =  '"  + cOper             + "' "
        cQuery += "    AND BXQ.BXQ_CODEMP >= '"  + cEmpDe            + "' "
        cQuery += "    AND BXQ.BXQ_CODEMP <= '"  + cEmpAte           + "' "
        cQuery += "    AND BXQ.BXQ_NUMCON >= '"  + cConDe            + "' "
        cQuery += "    AND BXQ.BXQ_NUMCON <= '"  + cConAte           + "' "
        cQuery += "    AND BXQ.BXQ_SUBCON >= '"  + cSubDe            + "' "
        cQuery += "    AND BXQ.BXQ_SUBCON <= '"  + cSubAte           + "' "
        cQuery += "    AND BXQ.BXQ_CODVEN >= '"  + cVenDe            + "' "
        cQuery += "    AND BXQ.BXQ_CODVEN <= '"  + cVenAte           + "' "
        cQuery += "    AND BXQ.BXQ_CODEQU >= '"  + cEquDe            + "' "
        cQuery += "    AND BXQ.BXQ_CODEQU <= '"  + cEquAte           + "' "
        cQuery += "    AND BXQ.BXQ_ANO    =  '"  + cAno              + "' "
        cQuery += "    AND BXQ.BXQ_MES    =  '"  + cMes              + "' " 
        
        If  BXQ->(FieldPos("BXQ_LAGER")) > 0 .and. BXQ->(FieldPos("BXQ_LAPAG")) > 0
            cQuery += "    AND (BXQ.BXQ_DTGER  <> '        ' OR BXQ.BXQ_LAGER <> ' ' OR BXQ.BXQ_LAPAG <> ' ') "
        Else
            cQuery += "    AND BXQ.BXQ_DTGER  <> '        ' "
        EndIf 
        
        cQuery += "    AND BXQ.D_E_L_E_T_ <> '*' "
        
		cQuery	:= ChangeQuery(cQuery)
		TcQuery cQuery New Alias "BXQTMP"
		TcSetField("BXQTMP","COUNT","N",15,0)
		
        if !(lMultCalc)
            nQtdReg := COUNT
        else 
            nQtdReg := 0
        endif      
        
        BXQTMP->( DbCloseArea() )
        If  nQtdReg > 0 // Tem Calculo Realizado Ja Enviado para Pagamento
  	        Aviso(STR0008, STR0011, {"Ok"}) //"Cálculo de Comissões"###"Não é possível fazer o descálculo porque ja houve liberação para pagamento de comissões para os parametros informados."
	        Return()
        EndIf
    EndIf
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se deve excluir comissoes calculadas                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nProc == 2
	If  Aviso(STR0008, STR0012, {STR0013, STR0014}) == 1 //"Cálculo de Comissões"###"Todas as comissões calculadas para os parametros informados serão apagadas."###"Confirma"###"Cancelar"
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Efetuando a exclusao da comissao                                   ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT R_E_C_N_O_ RECBXQ FROM "+RetSqlName("BXQ")
	    cQuery += " WHERE BXQ_FILIAL =  '" + xFilial("BXQ")  + "' "
        cQuery += "    AND BXQ_CODINT =  '" + cOper   + "' "
        cQuery += "    AND BXQ_CODEMP >= '" + cEmpDe  + "' "
        cQuery += "    AND BXQ_CODEMP <= '" + cEmpAte + "' "
        cQuery += "    AND BXQ_NUMCON >= '" + cConDe  + "' "
        cQuery += "    AND BXQ_NUMCON <= '" + cConAte + "' "
        cQuery += "    AND BXQ_SUBCON >= '" + cSubDe  + "' "
        cQuery += "    AND BXQ_SUBCON <= '" + cSubAte + "' "
        cQuery += "    AND BXQ_CODVEN >= '" + cVenDe  + "' "
        cQuery += "    AND BXQ_CODVEN <= '" + cVenAte + "' "
        cQuery += "    AND BXQ_CODEQU >= '" + cEquDe  + "' "
        cQuery += "    AND BXQ_CODEQU <= '" + cEquAte + "' "
        cQuery += "    AND BXQ_ANO    =  '" + cAno    + "' "
        cQuery += "    AND BXQ_MES    =  '" + cMes    + "' " 
        if lMultCalc
            CQUERY += "    AND BXQ_DTGER  = '        '"
        endif
        
        cQuery  += "    AND D_E_L_E_T_ <> '*' "
		cQuery	:= ChangeQuery(cQuery)
        dbusearea( .T. ,"TOPCONN",TCGenQry(,,cQuery),"TMPBXQ", .F. , .T. )
		TcSetField("TMPBXQ","RECBXQ","N",15,0) 
		
        TMPBXQ->(DbGoTop())
        Do While ! TMPBXQ->(Eof())
           BXQ->(DbGoTo(TMPBXQ->RECBXQ))
           RecLock("BXQ", .F.)
               BXQ->(DbDelete())
           BXQ->(MsUnlock())
           TMPBXQ->(DbSkip())
        EndDo
        TMPBXQ->(DbCloseArea())
		TCRefresh("BXQ")
		Return()
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor com estrutura das equipes com base no ultimo dia do periodo de ³
//³ emissao para o qual esta sendo calculada a comissao                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEquipe := {}
BXL->(dbSetOrder(1))
BXM->(dbSetOrder(1))
BXL->(dbseek(xFilial("BXL")))
While ! BXL->(eof()) .and. BXL->BXL_FILIAL == xFilial("BXL")
   If  BXL->BXL_VLDINI <= dEmiAte .and. ;
      (empty(BXL->BXL_VLDFIM) .or. BXL->BXL_VLDFIM >= dEmiAte) 
       aadd(aEquipe,ARRAY(5))
       i := Len(aEquipe)
       aEquipe[i][1] := BXL->BXL_CODEQU
       aEquipe[i][2] := BXL->BXL_CODVEN  // cod. vendedor da equipe
       aEquipe[i][3] := {}
       aEquipe[i][4] := BXL->BXL_VLDINI
       aEquipe[i][5] := BXL->BXL_VLDFIM
       BXM->(dbseek(xFilial("BXM")+BXL->BXL_SEQ))
       While ! BXM->(eof()) .and. BXM->BXM_FILIAL == xFilial("BXM") .and. ;
                                   BXM->BXM_SEQBXL == BXL->BXL_SEQ
          aadd(aEquipe[i][3],Array(8))
		  j := Len(aEquipe[i][3])
		  aEquipe[i][3][j][1] := BXM->BXM_CODVEN
		  aEquipe[i][3][j][2] := BXM->BXM_ID_VEN
		  aEquipe[i][3][j][3] := BXM->BXM_RATEIO
		  aEquipe[i][3][j][4] := BXM->BXM_COMSUP
		  aEquipe[i][3][j][5] := BXM->BXM_PERSUP
		  aEquipe[i][3][j][6] := BXM->BXM_COMGER
		  aEquipe[i][3][j][7] := BXM->BXM_PERGER
		  aEquipe[i][3][j][8] := IIf(BXM->(FieldPos("BXM_GRURAT")) > 0, BXM->BXM_GRURAT, "")
          
          BXM->(dbSkip())
       End
   EndIf
   BXL->(dbSkip())
End    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os titulos que foram emitidos e/ou baixados no periodo informado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("BXO")
dbSelectArea("BXP")
dbSelectArea("SE1")
dbSelectArea("BM1")
dbSelectArea("BFQ")
dbSelectArea("BXQ")	
	
cQuery := " SELECT BXO.BXO_CODVEN CODVEN, SE1.E1_EMISSAO EMISSAO, SE1.E1_BAIXA   BAIXA,   SE1.E1_PREFIXO PREFIXO, "
cQuery += "        SE1.E1_NUM     NUM,    SE1.E1_TIPO    TIPO,    SE1.E1_PARCELA PARCELA, BM1.BM1_CODEMP CODEMP, "
cQuery += "        BM1.BM1_MATRIC MATRIC, BM1.BM1_TIPREG TIPREG,  BM1.BM1_DIGITO DIGITO,  BXO.BXO_SEQ    SEQBXO, "
cQuery += "        BXP.BXP_PERCON PERCOM, BXP.BXP_VALCON VALCOM, "
if lBXP_SINIST
   cQuery += "        BXP.BXP_SINIST SINIST,  "
endif
cQuery += "        BM1.BM1_NUMPAR NUMPAR,  BM1.BM1_TIPO TIPO_BM1, BM1.BM1_CODINT CODINT, "
cQuery += "        BM1.BM1_VALOR  VALOR, BXP.BXP_BENEF  BENEF,  BXO.BXO_CODEQU CODEQU,  BXO.BXO_NUMCON NUMCON, BM1.BM1_MES BM1_MES, "
cQuery += "        BXO.BXO_VERCON VERCON, BXO.BXO_SUBCON SUBCON, BXO.BXO_VERSUB VERSUB,  BM1.BM1_CODTIP CODTIP, BM1.BM1_ANO BM1_ANO, "
cQuery += "        BM1.BM1_NUMPAR, BXP.BXP_QTDDE, BXP.BXP_QTDATE "  

If lSEQBXS
	cQuery += " , BXO.BXO_SEQBXS SEQBXS "
EndIf    

cQuery += " FROM " + RetSqlName("SE1") +  " SE1 "
cQuery += " INNER JOIN " + RetSqlName("BM1") + " BM1 ON( "
cQuery += " 	BM1.BM1_FILIAL = '" + xFilial("BM1") + "' "
cQuery += " 	AND BM1.BM1_PREFIX = SE1.E1_PREFIXO "
cQuery += " 	AND BM1.BM1_NUMTIT = SE1.E1_NUM "
cQuery += " 	AND BM1.BM1_PARCEL = SE1.E1_PARCELA "  
cQuery += " 	AND BM1.BM1_TIPTIT = SE1.E1_TIPO "
cQuery += " ) "

cQuery += " INNER JOIN " + RetSqlName("BXO") +  " BXO ON( "
cQuery += "   BXO.BXO_FILIAL = '" + xFilial("BXO") + "' "
cQuery += "   AND BXO.BXO_FILIAL = '" + xFilial("BXO") + "' " 
cQuery += "   AND BXO.BXO_CODINT  = BM1.BM1_CODINT "
cQuery += "   AND BXO.BXO_CODEMP = BM1.BM1_CODEMP "
cQuery += "   AND BXO.BXO_MATRIC  = BM1.BM1_MATRIC  "
cQuery += "   AND BXO.BXO_TIPREG  =  BM1.BM1_TIPREG  "
cQuery += " ) "

cQuery += " INNER JOIN " + RetSqlName("BXP") +  " BXP ON( "
cQuery += "   BXP.BXP_FILIAL  = '" + xFilial("BXP") + "' " 
cQuery += "   AND BXP.BXP_FILIAL = BXO.BXO_FILIAL "
cQuery += "   AND BXP.BXP_SEQBXO = BXO.BXO_SEQ "
cQuery += " ) "

cQuery += " INNER JOIN " + RetSqlName("BFQ") +  " BFQ ON( "
cQuery += "   BFQ.BFQ_FILIAL  = '" + xFilial("BFQ") + "' "
cQuery += "   AND BFQ.BFQ_CODINT = BM1.BM1_CODINT " 
cQuery += "   AND BFQ.BFQ_PROPRI||BFQ.BFQ_CODLAN = BM1.BM1_CODTIP "
cQuery += " ) "

cQuery += " WHERE "
cQuery += "   SE1.E1_FILIAL   = '" + xFilial("SE1") + "' "
cQuery += "   AND (SE1.E1_EMISSAO BETWEEN '"+DToS(dEmiDe)+"' AND '"+DToS(dEmiAte)+"' OR "
cQuery += "        SE1.E1_BAIXA   BETWEEN '"+DToS(dBaiDe)+"' AND '"+DToS(dBaiAte)+"') "
cQuery += "   AND BXO.BXO_CODINT = '"+cOper+"' "
cQuery += "   AND BXO.BXO_CODEMP BETWEEN '"+cEmpDe+"' AND '"+cEmpAte+"' "
cQuery += "   AND (BXO.BXO_NUMCON = '' OR BXO.BXO_NUMCON BETWEEN '"+cConDe+"' AND '"+cConAte+"') "
cQuery += "   AND (BXO.BXO_SUBCON = '' OR BXO.BXO_SUBCON BETWEEN '"+cSubDe+"' AND '"+cSubAte+"') "
cQuery += "   AND BXO.BXO_CODVEN BETWEEN '"+cVenDe+"' AND '"+cVenAte+"' "
cQuery += "   AND BXO.BXO_CODEQU BETWEEN '"+cEquDe+"' AND '"+cEquAte+"' "
cQuery += "   AND BFQ.BFQ_COMISS = '1' "

If lMesAnt
	cQuery += "   AND (( BM1.BM1_ANO = '"+cAno+"' AND BM1.BM1_MES = '"+cMes+"') "
	cQuery += "			  OR (BM1.BM1_ANO = '"+Substr(Alltrim(PLSDIMAM(cAno, cMes, "0")), 1, 4)+"' "
	cQuery += "			      AND BM1.BM1_MES = '"+Substr(Alltrim(PLSDIMAM(cAno, cMes, "0")), 5, 2)+"')) "
Else
	cQuery += "   AND BM1.BM1_ANO = '"+cAno+"' "
	cQuery += "   AND BM1.BM1_MES = '"+cMes+"' "	
Endif
 
cQuery += "    AND SE1.D_E_L_E_T_ <> '*' "
cQuery += "    AND BM1.D_E_L_E_T_ <> '*' "
cQuery += "    AND BXO.D_E_L_E_T_ <> '*' "
cQuery += "    AND BXP.D_E_L_E_T_ <> '*' "
cQuery += "    AND BFQ.D_E_L_E_T_ <> '*' "

cQuery += " ORDER BY CODVEN, PREFIXO, NUM, PARCELA, CODEMP, MATRIC, TIPREG, DIGITO, TIPO_BM1 "    

If lPL151STIT	
	cQuery := ExecBlock("PL151STIT",.F.,.F.,{cQuery})
Endif 

cQuery	:= ChangeQuery(cQuery)
dbusearea( .T. ,"TOPCONN",TCGenQry(,,CQUERY),"TMP", .F. , .T. )

If  TMP->(EOF())
	TMP->( DbCloseArea() )
	Aviso(STR0008, STR0015, {"Ok"}) //"Cálculo de Comissões"###"Com os parâmetros informados, não foi possível Localizar nenhum registro a ser processado."
	Return(NIL)
Else
	aStruc := DbStruct()
	For nInd:= 1 To Len(aStruc)
	    If ( aStruc[nInd,2]<>"C" )
		   	TcSetField("TMP",aStruc[nInd,1],aStruc[nInd,2],aStruc[nInd,3],aStruc[nInd,4])
		EndIf
	Next nInd
EndIf 
    
// Necessario setfield para campos data
TcSetField("TMP","EMISSAO","D",8,0)
TcSetField("TMP","BAIXA","D",8,0)
TcSetField("TMP","BXP_QTDDE","N",3,0)
TcSetField("TMP","BXP_QTDATE","N",3,0)

cVenAnt := ""
aRateio := {}

While ! TMP->(EOF())
	If Val(TMP->BM1_NUMPAR) < TMP->BXP_QTDDE .or. Val(TMP->BM1_NUMPAR) > TMP->BXP_QTDATE
         TMP->(dbSkip())
         Loop
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  	//³ Se já existir calculo, não calcular novamente para mesma parcela.		³
  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	
	//BXQ_FILIAL+BXQ_ANO+BXQ_MES+BXQ_CODVEN+BXQ_PREFIX+BXQ_NUM+BXQ_PARC+BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG+BXQ_DIGITO+BXQ_PAGCOM+BXQ_REFERE
    BXQ->(dBSetOrder(1))
    If BXQ->(msSeek(xFilial("BXQ")+TMP->BM1_ANO+TMP->BM1_MES+TMP->CODVEN+TMP->PREFIXO+Alltrim(TMP->NUM)+TMP->PARCELA+Alltrim(TMP->CODINT)+Alltrim(TMP->CODEMP)+Alltrim(TMP->MATRIC)))
         TMP->(dbSkip())
         Loop
    EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se o Codigo do Lancamento de Faturamento nao estiver presente na regra  ³
   //³ de composicao da base de calculo das comissoes, despreza registro       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
   If GetRpoRelease()=="R1.1"
	   If oSelf:lEnd
			Exit
	   EndIf
       oSelf:IncRegua1(STR0003)
   EndIf

   If lSEQBXS .And. PLSALIASEX("BXS")
	   If ! Empty(TMP->SEQBXS)
		  BXS->(DbSetOrder(2))
		  If BXS->(MsSeek(xFilial("BXS")+TMP->SEQBXS))
	         If ! TMP->CODTIP $ BXS->BXS_CODLAN
			      TMP->(DbSkip())
			      Loop
			 EndIf
		  EndIf
	   EndIf
   EndIf
   
   If lPL151COM
       aRet := ExecBlock("PL151COM",.F.,.F.,{	TMP->CODEQU,  TMP->CODVEN, TMP->BENEF,   TMP->VALCOM,  TMP->PERCOM, ;
												TMP->CODTIP,  TMP->VALOR,  TMP->NUMPAR,  TMP->PREFIXO, TMP->NUM, ;
												TMP->PARCELA, TMP->TIPO,   TMP->EMISSAO, TMP->BAIXA,   TMP->CODEMP, ;
												TMP->NUMCON,  TMP->VERCON, TMP->SUBCON,  TMP->VERSUB,  TMP->MATRIC, ;
												TMP->TIPREG,  TMP->DIGITO, TMP->TIPO_BM1 })
       nValCom := aRet[1]
       nPerCom := aRet[2]
       nValor  := aRet[3]
       
       If Len(aRet) > 3
       		nValAbt := aRet[4]
       Else
       		nValAbt := 0
       EndIf
         
   Else 
       nValCom := TMP->VALCOM
       nPerCom := TMP->PERCOM
       nValor  := TMP->VALOR
       If TMP->TIPO_BM1 = '1' // débito 
           	nValAbt := 0  //sem credito para abater
       Else
       		nValAbt  := TMP->VALOR ////abater o credito 
       EndIf
   EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ponto de entrada validador de registro...                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
   If lPL151VLD
       aRet1 := ExecBlock("PL151VLD",.F.,.F.,{	TMP->CODEQU,  TMP->CODVEN, TMP->BENEF,   TMP->VALCOM,  TMP->PERCOM, ;
												TMP->CODTIP,  TMP->VALOR,  TMP->NUMPAR,  TMP->PREFIXO, TMP->NUM, ;
												TMP->PARCELA, TMP->TIPO,   TMP->EMISSAO, TMP->BAIXA,   TMP->CODEMP, ;
												TMP->NUMCON,  TMP->VERCON, TMP->SUBCON,  TMP->VERSUB,  TMP->MATRIC, ;
												TMP->TIPREG,  TMP->DIGITO, TMP->TIPO_BM1 })

       If !aRet1[1]
           TMP->( dbSKip() )
           Loop
       EndIf
   EndIf
	   
   //procura se há algum lançamento de débito para tirar o credito se houver
   i := aScan(aBXQ, {|x|	x[C_CODVEN ] == TMP->CODVEN  .And. ;
   							x[C_PREFIXO] == TMP->PREFIXO .And. ;
                           	x[C_NUM    ] == TMP->NUM     .And. ;
                           	x[C_PARCELA] == TMP->PARCELA .And. ;
                           	x[C_TIPO   ] == TMP->TIPO    .And. ;
                           	x[C_CODEMP ] == TMP->CODEMP  .And. ;
                           	x[C_MATRIC ] == TMP->MATRIC  .And. ;
                           	x[C_TIPREG ] == TMP->TIPREG  .And. ;
                           	x[C_DIGITO ] == TMP->DIGITO  .And. ;
                           	x[C_PERCOM ] == nPerCom .And. ;
                           	(!lBXP_SINIST .Or. x[C_SINIST ] == TMP->SINIST) })
                           	
   If i > 0 .and. nValAbt > 0   
   		SA3->(dbSetOrder(1))
    	SA3->(dbSeek(xFilial("SA3")+TMP->CODVEN))
		If  SA3->A3_ALBAIXA > 0  // na baixa
			If  nValCom = 0 // se não for valor fixo de comissao
  				aBXQ[i][C_BASBAI] -= nValAbt
    		EndIf
    	EndIf
		If  SA3->A3_ALEMISS > 0  // na emissão
 			If  nValCom = 0 // se não for valor fixo de comissao
 				aBXQ[i][C_BASEMI] -= nValAbt
    		EndIf
    	EndIf
    	dbSkip()
    	Loop
   ElseIf i = 0 .and.  TMP->TIPO_BM1 = '2' //Quando for credito e não existir lançamentos de débitos para abater( para evitar gerar Negativo).
   		dbSkip()
    	Loop   	  
   EndIf
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ IdentIfica vendedor                                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cCodVen := TMP->CODVEN
   If  cCodVen <> cVenAnt
       aRateio := {}
   EndIf
   cVenAnt := TMP->CODVEN
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ IdentIfica se o titulo foi emitido / baixado no periodo                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If  TMP->EMISSAO >= dEmiDe  .and. ;
       TMP->EMISSAO <= dEmiAte
       lEmissao := .T.
   Else
       lEmissao := .F.
   EndIf
   If  TMP->BAIXA   >= dBaiDe  .and. ;
       TMP->BAIXA   <= dBaiAte
       lBaixa   := .T.
   Else
       lBaixa   := .F.
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Tratamento para equipe                                                  ³
   //³ VerIfica se deve gerar comissao para supervisor / gerente               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   lEquipe := .F.
   lRateio := .F.
   If  ! empty(TMP->CODEQU)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Localiza a equipe                                                   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	   x := aScan(aEquipe, {|x| x[1] == TMP->CODEQU})
	   If  x == 0
	       msgalert(STR0016 + TMP->CODEQU + STR0017) // ??? //"Equipe nao encontrada: "###"   Nao sera processada."
           dbSkip()
           Loop
       EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ VerIfica se existe rateio na equipe                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       For ii := 1 to len(aEquipe[x][3])
           If  aEquipe[x][3][ii][3] <> 0
               lRateio := .T.
               Exit
           EndIf
       Next
       If  TMP->BENEF <> "1"
           If  TMP->BENEF == "4" // Equipe
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³ Quando o beneficiario eh a equipe, o vendedor passa a ser o vendedor       ³
               //³ correspondente a equipe                                                    ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               cCodVen := aEquipe[x][2]
               lEquipe := .T.
   	       Else 
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³ Quando o beneficiario eh o supervisor ou o gerente, busca na composicao    ³
               //³ da equipe o codigo de vendedor (do supervisor ou do gerente)               ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               lAchou := .F.
               For ii := 1 to len(aEquipe[x][3])
                   If  aEquipe[x][3][ii][2] == TMP->BENEF
                       cCodVen := aEquipe[x][3][ii][1]
                       lAchou := .T.
                       Exit
                   EndIf
               Next
               If  ! lAchou
	               msgalert(X3Combo("BXK_BENEF", TMP->BENEF) + STR0018 + aEquipe[x][1] + STR0019 + aEquipe[x][2]) //" nao encontrado - Equipe: "###"   Vendedor: "
                   dbSkip()
                   Loop
               EndIf
           EndIf
       Else
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ VerIfica se no vendedor indica que deve pagar comissao para o              ³
           //³ supervisor/gerente                                                         ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           lAchou := .F.
           For ii := 1 to len(aEquipe[x][3])
               If  aEquipe[x][3][ii][1] == TMP->CODVEN  // achou o vendedor
                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ VerIfica se paga comissao ao supervisor                                    ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If  aEquipe[x][3][ii][4] == "1" // paga comissao ao supervisor
                       nPer    := aEquipe[x][3][ii][5] // % de comissao
  	                   For xx := 1 to len(aEquipe[x][3]) // procura o supervisor
                           If  aEquipe[x][3][xx][2] == "2"
                               cCod    := aEquipe[x][3][xx][1]  // codigo de vendedor do supervisor
                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Grava comissao para o supervisor                                           ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                           	   i := aScan(aBXQ, {|x| x[C_CODVEN ] == cCod         .And. ;
                         						     x[C_PREFIXO] == TMP->PREFIXO .And. ;
                           							 x[C_NUM    ] == TMP->NUM     .And. ;
                           							 x[C_PARCELA] == TMP->PARCELA .And. ;
                           							 x[C_TIPO   ] == TMP->TIPO    .And. ;
                           							 x[C_CODEMP ] == TMP->CODEMP  .And. ;
                           							 x[C_MATRIC ] == TMP->MATRIC  .And. ;
                           							 x[C_TIPREG ] == TMP->TIPREG  .And. ;
                           							 x[C_DIGITO ] == TMP->DIGITO  .And. ;
                           							 x[C_PERCOM ] == nPerCom })
                               If  i == 0
                           		   AAdd(aBXQ, Array(C_TAM_ARRAY))
                           		   i := Len(aBXQ)
                           		   aBXQ[i][C_CODVEN ] := cCod   
                           		   aBXQ[i][C_CODEQU ] := TMP->CODEQU
                           		   aBXQ[i][C_PREFIXO] := TMP->PREFIXO
                           		   aBXQ[i][C_NUM    ] := TMP->NUM
                           		   aBXQ[i][C_PARCELA] := TMP->PARCELA
                           		   aBXQ[i][C_TIPO   ] := TMP->TIPO
                           		   aBXQ[i][C_CODEMP ] := TMP->CODEMP
                           		   aBXQ[i][C_MATRIC ] := TMP->MATRIC
                           		   aBXQ[i][C_TIPREG ] := TMP->TIPREG
                           		   aBXQ[i][C_DIGITO ] := TMP->DIGITO
                           		   aBXQ[i][C_NUMCON ] := TMP->NUMCON
                           		   aBXQ[i][C_VERCON ] := TMP->VERCON
                           		   aBXQ[i][C_SUBCON ] := TMP->SUBCON
                           		   aBXQ[i][C_VERSUB ] := TMP->VERSUB
                           		   aBXQ[i][C_SEQBXO ] := TMP->SEQBXO
                           		   aBXQ[i][C_NUMPAR ] := TMP->NUMPAR
                           		   aBXQ[i][C_BASEMI ] := 0
                           		   aBXQ[i][C_BASBAI ] := 0
                           		   aBXQ[i][C_PERCOM ] := nPer
                           		   aBXQ[i][C_VALCOM ] := 0    
                           		   aBXQ[i][C_PERBAI ] := 0
                           		   aBXQ[i][C_PEREMI ] := 0
                           		   aBXQ[i][C_REFERE ] := ""
                           		   aBXQ[i][C_BAIXA  ] := lBaixa
                           		   if lBXP_SINIST
                           		      aBXQ[i][C_SINIST ] := TMP->SINIST
                           		   endif
                           	   EndIf
                           	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Calcula o valor de comissao a ser pago na EMISSAO e/ou na BAIXA ³
                           	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                           	   SA3->(dbSetOrder(1))
                           	   SA3->(dbSeek(xFilial("SA3")+cCod))
                               //If  lBaixa .And. SA3->A3_ALBAIXA > 0
                           	   If  SA3->A3_ALBAIXA > 0
                           		   aBXQ[i][C_PERBAI] := SA3->A3_ALBAIXA
                                   If  nValCom > 0 // valor fixo de comissao
                           		       aBXQ[i][C_BASBAI] += Round(nValCom * SA3->A3_ALBAIXA / 100, 2)
						    	       aBXQ[i][C_VALCOM] := aBXQ[i][C_BASBAI]
                           		   Else
                           		       aBXQ[i][C_BASBAI] += Round(nValor  * SA3->A3_ALBAIXA / 100, 2)		
                           		   EndIf
                           	   EndIf
                               //If  lEmissao .And. SA3->A3_ALEMISS > 0
                           	   If  SA3->A3_ALEMISS > 0
                           		   aBXQ[i][C_PEREMI] := SA3->A3_ALEMISS
                                   If  nValCom > 0 // valor fixo de comissao
                           		       aBXQ[i][C_BASEMI] += Round(nValCom * SA3->A3_ALEMISS / 100, 2)
						    	       aBXQ[i][C_VALCOM] := aBXQ[i][C_BASEMI]
                           		   Else
                           		       aBXQ[i][C_BASEMI] += Round(nValor  * SA3->A3_ALEMISS / 100, 2)		
                           		   EndIf
                           	   EndIf
                               Exit
                           EndIf
                       Next
                   EndIf
                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ VerIfica se paga comissao ao gerente                                       ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If  aEquipe[x][3][ii][6] == "1" // paga comissao ao gerente
                       nPer    := aEquipe[x][3][ii][7] // % de comissao
  	                   For xx := 1 to len(aEquipe[x][3]) // procura o gerente
                           If  aEquipe[x][3][xx][2] == "3"
                               cCod    := aEquipe[x][3][xx][1]  // codigo de vendedor do gerente
                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Grava comissao para o gerente                                              ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                           	   i := aScan(aBXQ, {|x| x[C_CODVEN ] == cCod         .And. ;
                           			  		         x[C_PREFIXO] == TMP->PREFIXO .And. ;
                           							 x[C_NUM    ] == TMP->NUM     .And. ;
                           							 x[C_PARCELA] == TMP->PARCELA .And. ;
                           							 x[C_TIPO   ] == TMP->TIPO    .And. ;
                           							 x[C_CODEMP ] == TMP->CODEMP  .And. ;
                           							 x[C_MATRIC ] == TMP->MATRIC  .And. ;
                           							 x[C_TIPREG ] == TMP->TIPREG  .And. ;
                           							 x[C_DIGITO ] == TMP->DIGITO  .And. ;
                           							 x[C_PERCOM ] == nPerCom .And. ;
							                         (!lBXP_SINIST .Or. x[C_SINIST ] == TMP->SINIST) })
                           							 
                               If  i == 0
                           		   AAdd(aBXQ, Array(C_TAM_ARRAY))
                           		   i := Len(aBXQ)
                           		   aBXQ[i][C_CODVEN ] := cCod   
                           		   aBXQ[i][C_CODEQU ] := TMP->CODEQU
                           		   aBXQ[i][C_PREFIXO] := TMP->PREFIXO
                           		   aBXQ[i][C_NUM    ] := TMP->NUM
                           		   aBXQ[i][C_PARCELA] := TMP->PARCELA
                           		   aBXQ[i][C_TIPO   ] := TMP->TIPO
                           		   aBXQ[i][C_CODEMP ] := TMP->CODEMP
                           		   aBXQ[i][C_MATRIC ] := TMP->MATRIC
                           		   aBXQ[i][C_TIPREG ] := TMP->TIPREG
                           		   aBXQ[i][C_DIGITO ] := TMP->DIGITO
                           		   aBXQ[i][C_NUMCON ] := TMP->NUMCON
                           		   aBXQ[i][C_VERCON ] := TMP->VERCON
                           		   aBXQ[i][C_SUBCON ] := TMP->SUBCON
                           		   aBXQ[i][C_VERSUB ] := TMP->VERSUB
                           		   aBXQ[i][C_SEQBXO ] := TMP->SEQBXO
                           		   aBXQ[i][C_NUMPAR ] := TMP->NUMPAR
                           		   aBXQ[i][C_BASEMI ] := 0
                           		   aBXQ[i][C_BASBAI ] := 0
                           		   aBXQ[i][C_PERCOM ] := nPer
                           		   aBXQ[i][C_VALCOM ] := 0
                           		   aBXQ[i][C_PERBAI ] := 0
                           		   aBXQ[i][C_PEREMI ] := 0
                           		   aBXQ[i][C_REFERE ] := ""
                           		   aBXQ[i][C_BAIXA  ] := lBaixa
                           		   if lBXP_SINIST       
                          		         aBXQ[i][C_SINIST ] := TMP->SINIST
                          		   endif	
                           	   EndIf
                           	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Calcula o valor de comissao a ser pago na EMISSAO e/ou na BAIXA ³
                           	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                           	   SA3->(dbSetOrder(1))
                           	   SA3->(dbSeek(xFilial("SA3")+cCod))
                               //If  lBaixa .And. SA3->A3_ALBAIXA > 0
                           	   If  SA3->A3_ALBAIXA > 0
                           		   aBXQ[i][C_PERBAI] := SA3->A3_ALBAIXA
                                   If  nValCom > 0 // valor fixo de comissao
                           		       aBXQ[i][C_BASBAI] += Round(nValCom * SA3->A3_ALBAIXA / 100, 2)
						    	       aBXQ[i][C_VALCOM] := aBXQ[i][C_BASBAI]
                           		   Else
                           		       aBXQ[i][C_BASBAI] += Round(nValor  * SA3->A3_ALBAIXA / 100, 2)	
                           		   EndIf
                           	   EndIf
                               //If  lEmissao .And. SA3->A3_ALEMISS > 0
                           	   If  SA3->A3_ALEMISS > 0
                           		   aBXQ[i][C_PEREMI] := SA3->A3_ALEMISS
                                   If  nValCom > 0 // valor fixo de comissao
                           		       aBXQ[i][C_BASEMI] += Round(nValCom * SA3->A3_ALEMISS / 100, 2)
						    	       aBXQ[i][C_VALCOM] := aBXQ[i][C_BASEMI]
                           		   Else
                           		       aBXQ[i][C_BASEMI] += Round(nValor  * SA3->A3_ALEMISS / 100, 2)		
                           		   EndIf
                           	   EndIf
                               Exit
                           EndIf
                       Next
                   EndIf
               EndIf
           Next
       EndIf
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ VerIfica se deve tratar rateio                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If  lEquipe .and. lRateio
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ VerIfica a que Grupo de Rateio pertence o vendedor do registro atual    ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       i    := aScan(aEquipe[x][3], { |x| x[1] == TMP->CODVEN })
       If i > 0
          cGruRat := aEquipe[x][3][i][8] 
        Else
          cGruRat := ""
       EndIf
       nTotEmi := 0
       nTotBai := 0

       For ii := 1 to len(aEquipe[x][3])
           If aEquipe[x][3][ii][8] <> cGruRat
              Loop
           EndIf
           cCodVen1 := aEquipe[x][3][ii][1] 
           nRateio  := aEquipe[x][3][ii][3] 
           i := aScan(aBXQ, {|x| x[C_CODVEN ] == cCodVen1  .And. ;
						         x[C_PREFIXO] == TMP->PREFIXO .And. ;
						         x[C_NUM    ] == TMP->NUM     .And. ;
						         x[C_PARCELA] == TMP->PARCELA .And. ;
						         x[C_TIPO   ] == TMP->TIPO    .And. ;
						         x[C_CODEMP ] == TMP->CODEMP  .And. ;
						         x[C_MATRIC ] == TMP->MATRIC  .And. ;
						         x[C_TIPREG ] == TMP->TIPREG  .And. ;
						         x[C_DIGITO ] == TMP->DIGITO  .And. ;
						         x[C_PERCOM ] == nPerCom .And. ;
							     (!lBXP_SINIST .Or. x[C_SINIST ] == TMP->SINIST) })
						         
           If  i == 0
	           AAdd(aBXQ, Array(C_TAM_ARRAY))
	           i := Len(aBXQ)
	           aBXQ[i][C_CODVEN ] := cCodVen1
  	           aBXQ[i][C_CODEQU ] := TMP->CODEQU
	           aBXQ[i][C_PREFIXO] := TMP->PREFIXO
	           aBXQ[i][C_NUM    ] := TMP->NUM
	           aBXQ[i][C_PARCELA] := TMP->PARCELA
	           aBXQ[i][C_TIPO   ] := TMP->TIPO
	           aBXQ[i][C_CODEMP ] := TMP->CODEMP
	           aBXQ[i][C_MATRIC ] := TMP->MATRIC
	           aBXQ[i][C_TIPREG ] := TMP->TIPREG
	           aBXQ[i][C_DIGITO ] := TMP->DIGITO
       	       aBXQ[i][C_NUMCON ] := TMP->NUMCON
       	       aBXQ[i][C_VERCON ] := TMP->VERCON
		   	   aBXQ[i][C_SUBCON ] := TMP->SUBCON
       	       aBXQ[i][C_VERSUB ] := TMP->VERSUB
       	       aBXQ[i][C_SEQBXO ] := TMP->SEQBXO
       	       aBXQ[i][C_NUMPAR ] := TMP->NUMPAR
	           aBXQ[i][C_BASEMI ] := 0
	           aBXQ[i][C_BASBAI ] := 0
	           aBXQ[i][C_PERCOM ] := nPerCom
	           aBXQ[i][C_VALCOM ] := 0
	           aBXQ[i][C_PERBAI ] := 0
	           aBXQ[i][C_PEREMI ] := 0
      		   aBXQ[i][C_REFERE ] := ""
       		   aBXQ[i][C_BAIXA  ] := lBaixa
       		   if lBXP_SINIST
   		         aBXQ[i][C_SINIST ] := TMP->SINIST
   		       endif
       		
           EndIf
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Calcula o valor de comissao a ser pago na EMISSAO e/ou na BAIXA         ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           SA3->(dbSetOrder(1))
           SA3->(dbSeek(xFilial("SA3")+cCodVen)) // posiciona no vendedor indicado na Equipe
           //If  lBaixa .And. SA3->A3_ALBAIXA > 0
           If  SA3->A3_ALBAIXA > 0
               aBXQ[i][C_PERBAI] := SA3->A3_ALBAIXA
               If  nValCom > 0 // valor fixo de comissao
                   cRateio := cCodVen1 + TMP->CODEMP  + TMP->MATRIC  + TMP->TIPREG  + TMP->DIGITO  + ;
                                         TMP->NUMCON  + TMP->VERCON  + TMP->SUBCON  + TMP->VERSUB
                   If  aScan(aRateio,cRateio) == 0
                       aadd(aRateio,cRateio)
    		           aBXQ[i][C_BASBAI] += Round(Round(nValCom * SA3->A3_ALBAIXA / 100, 2) * nRateio / 100, 2)
    	           	   aBXQ[i][C_VALCOM] := aBXQ[i][C_BASBAI]
			           nTotBai 			 := aBXQ[i][C_BASBAI]
    		       EndIf
               Else
  		           aBXQ[i][C_BASBAI] += Round(Round(nValor  * SA3->A3_ALBAIXA / 100, 2) * nRateio / 100, 2)	
		           nTotBai 			 += Round(Round(nValor  * SA3->A3_ALBAIXA / 100, 2) * nRateio / 100, 2)
               EndIf
           EndIf
           //If  lEmissao .And. SA3->A3_ALEMISS > 0
           If  SA3->A3_ALEMISS > 0
	           aBXQ[i][C_PEREMI] := SA3->A3_ALEMISS
               If  nValCom > 0 // valor fixo de comissao
                   cRateio := cCodVen1 + TMP->CODEMP  + TMP->MATRIC  + TMP->TIPREG  + TMP->DIGITO  + ;
                                         TMP->NUMCON  + TMP->VERCON  + TMP->SUBCON  + TMP->VERSUB
                   If  aScan(aRateio,cRateio) == 0
                       aadd(aRateio,cRateio)
	                   aBXQ[i][C_BASEMI] += Round(Round(nValCom * SA3->A3_ALEMISS / 100, 2) * nRateio / 100, 2)
			           aBXQ[i][C_VALCOM] := aBXQ[i][C_BASEMI]
			           nTotEmi  		 := aBXQ[i][C_BASEMI]
	               EndIf
	           Else
	               aBXQ[i][C_BASEMI] += Round(Round(nValor  * SA3->A3_ALEMISS / 100, 2) * nRateio / 100, 2)
		           nTotEmi 			 += Round(Round(nValor  * SA3->A3_ALEMISS / 100, 2) * nRateio / 100, 2)
	           EndIf
           EndIf
       Next
   //EndIf
   Else
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Comissao do vendedor                                                    ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       i := AScan(aBXQ, {|x| x[C_CODVEN ] == cCodVen     .And. ;
	     					     x[C_PREFIXO] == TMP->PREFIXO .And. ;
		       				  x[C_NUM    ] == TMP->NUM     .And. ;
						         x[C_PARCELA] == TMP->PARCELA .And. ;
						         x[C_TIPO   ] == TMP->TIPO    .And. ;
    						     x[C_CODEMP ] == TMP->CODEMP  .And. ;
	    					     x[C_MATRIC ] == TMP->MATRIC  .And. ;
		    				     x[C_TIPREG ] == TMP->TIPREG  .And. ;
			    			     x[C_DIGITO ] == TMP->DIGITO  .And. ;
			    			     x[C_PERCOM ] == nPerCom .And. ;
    	                      (!lBXP_SINIST .Or. x[C_SINIST ] == TMP->SINIST) })
			    			     
       If  i == 0
    	   AAdd(aBXQ, Array(C_TAM_ARRAY))
	       i := Len(aBXQ)
	       aBXQ[i][C_CODVEN ] := cCodVen
  	       aBXQ[i][C_CODEQU ] := TMP->CODEQU
	       aBXQ[i][C_PREFIXO] := TMP->PREFIXO
	       aBXQ[i][C_NUM    ] := TMP->NUM
	       aBXQ[i][C_PARCELA] := TMP->PARCELA
	       aBXQ[i][C_TIPO   ] := TMP->TIPO
	       aBXQ[i][C_CODEMP ] := TMP->CODEMP
	       aBXQ[i][C_MATRIC ] := TMP->MATRIC
	       aBXQ[i][C_TIPREG ] := TMP->TIPREG
 	       aBXQ[i][C_DIGITO ] := TMP->DIGITO
           aBXQ[i][C_NUMCON ] := TMP->NUMCON
           aBXQ[i][C_VERCON ] := TMP->VERCON
           aBXQ[i][C_SUBCON ] := TMP->SUBCON
           aBXQ[i][C_VERSUB ] := TMP->VERSUB
	       aBXQ[i][C_SEQBXO ] := TMP->SEQBXO
	       aBXQ[i][C_NUMPAR ] := TMP->NUMPAR
	       aBXQ[i][C_BASEMI ] := 0
	       aBXQ[i][C_BASBAI ] := 0
	       aBXQ[i][C_PERCOM ] := nPerCom
	       aBXQ[i][C_VALCOM ] := 0
	       aBXQ[i][C_PERBAI ] := 0
	       aBXQ[i][C_PEREMI ] := 0
           aBXQ[i][C_REFERE ] := ""
           aBXQ[i][C_BAIXA  ] := lBaixa
           if lBXP_SINIST
              aBXQ[i][C_SINIST ] := TMP->SINIST
           endif
	   EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Calcula o valor de comissao a ser pago na EMISSAO e/ou na BAIXA         ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SA3->(dbSetOrder(1))
       SA3->(dbSeek(xFilial("SA3")+cCodVen))
       //If  lBaixa .And. SA3->A3_ALBAIXA > 0
       If  SA3->A3_ALBAIXA > 0
           aBXQ[i][C_PERBAI] := SA3->A3_ALBAIXA
           If  nValCom > 0 // valor fixo de comissao
  		       aBXQ[i][C_BASBAI] += Round(nValCom * SA3->A3_ALBAIXA / 100, 2)
    	       aBXQ[i][C_VALCOM] := aBXQ[i][C_BASBAI]
           Else
  		       aBXQ[i][C_BASBAI] += Round(nValor  * SA3->A3_ALBAIXA / 100, 2)
           EndIf
       EndIf
       //If  lEmissao .And. SA3->A3_ALEMISS > 0
       If  SA3->A3_ALEMISS > 0
	       aBXQ[i][C_PEREMI] := SA3->A3_ALEMISS
           If  nValCom > 0 // valor fixo de comissao
	           aBXQ[i][C_BASEMI] += Round(nValCom * SA3->A3_ALEMISS / 100, 2)
    	       aBXQ[i][C_VALCOM] := aBXQ[i][C_BASEMI]
	       Else
	           aBXQ[i][C_BASEMI] += Round(nValor  * SA3->A3_ALEMISS / 100, 2)	
	       EndIf
       EndIf
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se tem rateio, faz ajuste no ultimo item do array para que nao ocorra   ³
   //³ dIferenca entre a soma do rateio e o valor a ser rateado.               ³
   //³ BOPS 105870 - Passou a verIficar se existe base antes de ajustar para   ³
   //³               que nao ocorra de ficar base negativa.                    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lEquipe .and. lRateio
   //If lBaixa .And. SA3->A3_ALBAIXA > 0
      If SA3->A3_ALBAIXA > 0
         If  nValCom > 0 
             nTotBai := Round(nValCom * SA3->A3_ALBAIXA / 100, 2) - nTotBai
         Else
             nTotBai := Round(nValor  * SA3->A3_ALBAIXA / 100, 2) - nTotBai
         EndIf
      EndIf
      //If lEmissao .And. SA3->A3_ALEMISS > 0
      If SA3->A3_ALEMISS > 0
         If  nValCom > 0 
             nTotEmi := Round(nValCom * SA3->A3_ALEMISS / 100, 2) - nTotEmi
         Else
             nTotEmi := Round(nValor  * SA3->A3_ALEMISS / 100, 2) - nTotEmi
         EndIf
      EndIf
      Do While nTotBai <> 0 .Or. nTotEmi <> 0
		  nBai := nTotBai
		  nEmi := nTotEmi
	      For i := Len(aBXQ) To 1 Step -1
			  If nTotBai == 0 .And. nTotEmi == 0
				  Exit
			  EndIf 
    	  	  If aBXQ[i][C_BASBAI] <> 0 .And. ; // Existe base para o vendedor
	      	     (nTotBai > 0 .Or. (nTotBai < 0 .And. aBXQ[i][C_BASBAI] >= (nTotBai * -1))) // Vr Ajuste > 0 ou se Vr Ajuste < 0 mas base suporta ajuste
				  aBXQ[i][C_BASBAI] += IIf(nTotBai > 0, 0.01, -0.01)
				  nTotBai += IIf(nTotBai > 0, -0.01, 0.01)
			  EndIf
    	  	  If aBXQ[i][C_BASEMI] <> 0 .And. ; // Existe base para o vendedor
      		     (nTotEmi > 0 .Or. (nTotEmi < 0 .And. aBXQ[i][C_BASEMI] >= (nTotEmi * -1))) // Vr Ajuste > 0 ou se Vr Ajuste < 0 mas base suporta ajuste
				  aBXQ[i][C_BASEMI] += IIf(nTotEmi > 0, 0.01, -0.01)
				  nTotEmi += IIf(nTotEmi > 0, -0.01, 0.01)
			  EndIf
    	  Next i
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ A condicao abaixo existe para evitar que ocorra um loop infinito.        ³
		  //³ Se "nTotBai" e "nTotEmi" sairem do "For" sem que tenham sido alterados,  ³
		  //³ com certeza ocorrera um loop infinito. Neste caso, forca o fim do loop.  ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	  If nBai == nTotBai .And. nEmi == nTotEmi
    	  	  Exit
    	  EndIf
      EndDo
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Acessa proximo registro                                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSkip()
   lComissao := .T.
End

TMP->( DbCloseArea() )

If GetRpoRelease()=="R1.1" .and. lComissao
    oSelf:SaveLog(STR0021)//"Calculo de Comissão Realizado ! "
EndIf

BEGIN TRANSACTION
For i := 1 To Len(aBXQ)
	If  aBXQ[i][C_BASEMI] <> 0			// Pagamento na Emissao
		GravaBXQ(aBXQ[i], "1","1",lArrend )
	EndIf
	If  aBXQ[i][C_BASBAI] <> 0			// Pagamento na Baixa
		GravaBXQ(aBXQ[i], "2","1",lArrend )
	EndIf
	If  aBXQ[i][C_BASBAI] <> 0 	.and. ; // Pagamento na Baixa
	    aBXQ[i][C_BAIXA ]        		// Houve Baixa
		GravaBXQ(aBXQ[i], "2","2",lArrend )
	EndIf
End
END TRANSACTION
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GravaBXQ     ³Autor ³ Cesar Valadao        ³Data³ 26/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a gravacao do BXQ                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GravaBXQ(aBXQ,cPagCom,cRefere,lArrend )

Local lNovo  	:= .T.
Local cChave	:=	""
Local nVlrCom	:=	0
Local nDecimal	:=	X3Decimal("BXQ_VLRCOM")
Local nVlrComSobra := 0
Local lBXQ_SINIST := BXQ->(FieldPos("BXQ_SINIST")) > 0

Default lArrend	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se ja existe regsitro ref ao calculo       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BXQ->(dbSetOrder(4))
cChave := xFilial("BXQ")+aBXQ[C_CODVEN]+aBXQ[C_PREFIXO]+aBXQ[C_NUM]+aBXQ[C_PARCELA]+cOper+aBXQ[C_CODEMP]+aBXQ[C_MATRIC]+aBXQ[C_TIPREG]+aBXQ[C_DIGITO]+cPagCom+cRefere

If  BXQ->(dbSeek(cChave))
	While ! BXQ->(eof()) .and. ;
		cChave == BXQ->(BXQ_FILIAL+BXQ_CODVEN+BXQ_PREFIX+BXQ_NUM+BXQ_PARC+BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG+BXQ_DIGITO+BXQ_PAGCOM+BXQ_REFERE)
		If  BXQ->BXQ_PERCOM == aBXQ[C_PERCOM].AND. (!lBXQ_SINIST .Or. BXQ->BXQ_SINIST == aBXQ[C_SINIST])
			lNovo := .F.
		EndIf
		BXQ->(dbSkip())
	Enddo
EndIf
If  lNovo
	RecLock("BXQ",.T.)
	BXQ->BXQ_FILIAL := xFilial("BXQ")
	BXQ->BXQ_SEQ    := GetSX8Num("BXQ","BXQ_SEQ")
	BXQ->BXQ_ANO    := cAno
	BXQ->BXQ_MES    := cMes
	BXQ->BXQ_CODVEN := aBXQ[C_CODVEN]
	BXQ->BXQ_CODEQU := aBXQ[C_CODEQU]
	BXQ->BXQ_PREFIX := aBXQ[C_PREFIXO] 
	BXQ->BXQ_NUM    := aBXQ[C_NUM]
	BXQ->BXQ_PARC   := aBXQ[C_PARCELA]
	BXQ->BXQ_TIPO   := aBXQ[C_TIPO]
	BXQ->BXQ_CODINT := cOper
	BXQ->BXQ_CODEMP := aBXQ[C_CODEMP]
	BXQ->BXQ_MATRIC := aBXQ[C_MATRIC]
	BXQ->BXQ_TIPREG := aBXQ[C_TIPREG]
	BXQ->BXQ_DIGITO := aBXQ[C_DIGITO]
	BXQ->BXQ_NUMCON := aBXQ[C_NUMCON]
	BXQ->BXQ_VERCON := aBXQ[C_VERCON]
	BXQ->BXQ_SUBCON := aBXQ[C_SUBCON]
	BXQ->BXQ_VERSUB := aBXQ[C_VERSUB]
	BXQ->BXQ_PAGCOM := cPagCom
	BXQ->BXQ_DATA   := dDataBase
	BXQ->BXQ_SEQBXO := aBXQ[C_SEQBXO]
	BXQ->BXQ_NUMPAR := aBXQ[C_NUMPAR]
	BXQ->BXQ_PERCOM := aBXQ[C_PERCOM]
	BXQ->BXQ_REFERE := cRefere
	if lBXQ_SINIST
	   BXQ->BXQ_SINIST := aBXQ[C_SINIST]
	endif  

	If !lArrend 
	
		If  cPagCom == "1"// Pagamento na Emissao
			BXQ->BXQ_BASCOM := aBXQ[C_BASEMI]
			BXQ->BXQ_PAGPER := aBXQ[C_PEREMI]
			If  aBXQ[C_VALCOM] > 0
				BXQ->BXQ_VLRCOM	:= NoRound(aBXQ[C_VALCOM],nDecimal)
				nVlrComSobra		+= aBXQ[C_VALCOM] - BXQ->BXQ_VLRCOM			
			Else
				nVlrCom				:=	aBXQ[C_BASEMI] * aBXQ[C_PERCOM] / 100
				BXQ->BXQ_VLRCOM	:= NoRound(nVlrCom, nDecimal)
				nVlrComSobra		+= nVlrCom - BXQ->BXQ_VLRCOM
			EndIf
		Else // Pagamento na Baixa
			BXQ->BXQ_BASCOM := aBXQ[C_BASBAI]
			BXQ->BXQ_PAGPER := aBXQ[C_PERBAI]
			If  aBXQ[C_VALCOM] > 0
				BXQ->BXQ_VLRCOM	:=	NoRound(aBXQ[C_VALCOM],nDecimal)
				nVlrComSobra		+= aBXQ[C_VALCOM] - BXQ->BXQ_VLRCOM
			Else
				nVlrCom				:=	aBXQ[C_BASBAI] * aBXQ[C_PERCOM] / 100
				BXQ->BXQ_VLRCOM	:= NoRound(nVlrCom, nDecimal)
				nVlrComSobra		+= nVlrCom - BXQ->BXQ_VLRCOM
			EndIf
		EndIf  
		
		If NoRound(nVlrComSobra,nDecimal) > 0
			BXQ->BXQ_VLRCOM	+= NoRound(nVlrComSobra,nDecimal)
			nVlrComSobra		:=	0
		EndIf
	
	Else

		If  cPagCom == "1"// Pagamento na Emissao
			BXQ->BXQ_BASCOM := aBXQ[C_BASEMI]
			BXQ->BXQ_PAGPER := aBXQ[C_PEREMI]
			If  aBXQ[C_VALCOM] > 0
				BXQ->BXQ_VLRCOM	:= Round(aBXQ[C_VALCOM],nDecimal)	
			Else
				nVlrCom				:=	aBXQ[C_BASEMI] * aBXQ[C_PERCOM] / 100
				BXQ->BXQ_VLRCOM	:= Round(nVlrCom, nDecimal)
			EndIf
		Else // Pagamento na Baixa
			BXQ->BXQ_BASCOM := aBXQ[C_BASBAI]
			BXQ->BXQ_PAGPER := aBXQ[C_PERBAI]
			If  aBXQ[C_VALCOM] > 0
				BXQ->BXQ_VLRCOM	:=	Round(aBXQ[C_VALCOM],nDecimal)
			Else
				nVlrCom				:=	aBXQ[C_BASBAI] * aBXQ[C_PERCOM] / 100
				BXQ->BXQ_VLRCOM	:= Round(nVlrCom, nDecimal)
			EndIf
		EndIf  
		
	Endif
	
	BXQ->(MsUnLock())
	ConfirmSX8()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada executado após a gravação do arquivo BXQ  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ExistBlock("PL151GRV")
	
		Execblock("PL151GRV",.F.,.F.)
	
	Endif 
	
EndIf


Return(NIL)
