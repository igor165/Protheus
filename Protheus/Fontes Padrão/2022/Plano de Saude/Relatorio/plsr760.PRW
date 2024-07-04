#INCLUDE "rwmake.ch"
#include "PROTHEUS.CH"

Static lautoSt := .F.

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё PLSR760  ╨ Autor Ё Angelo Sperandio   ╨ Data Ё  10/09/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Emite relatorio de mapa de pagamento                       ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6 IDE                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSR760(lAuto)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de Variaveis                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local   cDesc1       := "Este programa tem como objetivo listar a relacao de"
Local   cDesc2       := "pagamentos da rede de atendimento, conforme parametros"
Local   cDesc3       := "informados."
Local   cPict        := ""
Local   imprime      := .T.
Local   aOrd         := {"Emissao","Lote+Emissao"}

Private cTitulo      := "Mapa de Pagamento"
Private cCabec1      := "Emissao  Vencto   Pfx Numero Fornec.   Nome Fornecedor                          Codigo / Descricao                                         Valor       Irrf       Inss        Pis     Cofins       Csll        Liquido"
Private cCabec2      := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private cTamanho     := "G"
Private cNomeprog    := "PLSR760" // Coloque aqui o nome do programa para impressao no cabecalho
Private nCaracter    := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private nLimite	     := 220
Private wnrel        := "PLSR760" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg        := "PLR760"
Private cAlias       := "SE2"
Private nLi          := 70
Private nLinPag      := 58   

Default lAuto := .F.

lautoSt := lAuto
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a interface padrao com o usuario...                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto
    wnrel := SetPrint(cAlias,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,cTamanho,,.T.)
    If  nLastKey == 27
        Return
    EndIf
    SetDefault(aReturn,cAlias)
    If  nLastKey == 27
        Return
    EndIf
endIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza perguntas                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)            
cLotDe  	:= mv_par01
cLotAte     := mv_par02
cEmissDe	:= DTOS(mv_par03)
cEmissAte   := DTOS(mv_par04)
cRDAde   	:= mv_par05
cRDAate  	:= mv_par06
cPrefixDe 	:= mv_par07
cPrefixAte	:= mv_par08
cTitDe  	:= mv_par09
cTitAte 	:= mv_par10
cForDe  	:= mv_par11                                
cForAte 	:= mv_par12                         
cClaPre     := mv_par13
nTipRel     := 2 //mv_par14
nTotais     := 1 //mv_par15
nCaracter   := If(aReturn[4]==1,15,18)
If lAuto
    cLotDe  	:= " "
    cLotAte     := "ZZ"
    cEmissDe	:= "20200101"
    cEmissAte   := "20210101"
    cRDAde   	:= "  "
    cRDAate  	:= "ZZ"
    cPrefixDe 	:= "  "
    cPrefixAte	:= "ZZ"
    cTitDe  	:= "  "
    cTitAte 	:= "ZZ"
    cForDe  	:= "  "                                
    cForAte 	:= "ZZ"
endIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto
    RptStatus({|| RunReport(cCabec1,cCabec2,cTitulo) },cTitulo)
else
    RunReport(cCabec1,cCabec2,cTitulo)
endIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do programa                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Fun┤└o    ЁRUNREPORT ╨ Autor Ё AP6 IDE            ╨ Data Ё  14/04/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descri┤└o Ё Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ╨╠╠
╠╠╨          Ё monta a janela com a regua de processamento.               ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Programa principal                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function RunReport(cCabec1,cCabec2,cTitulo)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nOrdem    := aReturn[8] 
Local cCod  	:= ""
Local cDesc 	:= "" 
Local nTotDia  	:= 0
Local nTotLot  	:= 0
Local nTotGer 	:= 0
Local dEmissao 	:= CTOD("")
Local nVlDia	:= 0
Local nTotSE2   := 0
Local aTotGer   := {}
Local nPos
Local i
Local cLotAnt
Local dDatAnt
Local cPfxAnt
Local cNumAnt
Local nValor
Local nIrrf
Local nInss
Local nPis
Local nCofins
Local nCsl  
Local nDiaVlr   := 0
Local nDiaIrf   := 0
Local nDiaIns   := 0
Local nDiaPis   := 0
Local nDiaCof   := 0
Local nDiaCsl   := 0
Local nLotVlr   := 0
Local nLotIrf   := 0
Local nLotIns   := 0
Local nLotPis   := 0
Local nLotCof   := 0
Local nLotCsl   := 0
Local nTotVlr   := 0
Local nTotIrf   := 0
Local nTotIns   := 0
Local nTotPis   := 0
Local nTotCof   := 0
Local nTotCsl   := 0
Local aTitulos  := {}
Local lTemTit
Local lTemDia
Local LtemLot         
Local aStruSE2 := SE2->(DbStruct())   
Local nCntFor
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta query                                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuery := " SELECT E2_PREFIXO, E2_NUM,  E2_PARCELA, E2_TIPO,    E2_EMISSAO, E2_VENCREA, E2_PLLOTE, E2_CODRDA, E2_NATUREZ, "
cQuery += "        E2_FORNECE,E2_LOJA, E2_VALOR,   E2_IRRF, E2_INSS,    E2_VRETPIS, E2_VRETCOF, E2_VRETCSL, R_E_C_N_O_ AS E2_RECNO"
cQuery += " FROM " + RetSqlName("SE2") 
cQuery += " WHERE E2_FILIAL  =  '" + xFilial("SE2") + "' "
cQuery += "   AND E2_PREFIXO >= '" + cPrefixDe + "' AND E2_PREFIXO <= '" + cPrefixAte + "' "
cQuery += "   AND E2_NUM     >= '" + cTitDe    + "' AND E2_NUM     <= '" + cTitAte    + "' "
cQuery += "   AND E2_EMISSAO >= '" + cEmissDe  + "' AND E2_EMISSAO <= '" + cEmissAte  + "' "
cQuery += "   AND E2_FORNECE >= '" + cForDe    + "' AND E2_FORNECE <= '" + cForAte    + "' "
cQuery += "   AND E2_CODRDA  >= '" + cRDAde    + "' AND E2_CODRDA  <= '" + cRDAate    + "' "
If AllTrim(TCGetDB()) == "ORACLE/POSTGRES"
    cQuery += "   AND SUBSTR(E2_ORIGEM,1,4) = 'PLSM' "
Else
    cQuery += "   AND SUBSTRING(E2_ORIGEM,1,4) = 'PLSM' "
Endif
If  ! Empty(aReturn[7])
	cQuery += " AND (" + PLSParSQL(aReturn[7]) + ") "
EndIf
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY E2_PREFIXO, E2_NUM, E2_PARCELA "

cQuery:=ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)    
For nCntFor := 1 To Len(aStruSE2)
	If ( aStruSE2[nCntFor,2]<>"C" )
			TcSetField("TRB",aStruSE2[nCntFor,1],aStruSE2[nCntFor,2],aStruSE2[nCntFor,3],aStruSE2[nCntFor,4])
	EndIf
Next nCntFor   

TRB->(DbGoTop())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona indices                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BMS->(DbSetOrder(1))
SA2->(DbSetOrder(1))
BLR->(DbSetOrder(1))
BI3->(DbSetOrder(1))
BBB->(DbSetOrder(1))   
BAU->(DbSetOrder(1))   
BLR->(DbSetOrder(1))   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Incializa VARIAVEIS                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nTotDia := 0
nTotLot := 0
nPosLot := 1
nPosPfx := 2
nPosNum := 3
nPosTip := 4
nPosEmi := 5
nPosVlr := 6
nPosIrf := 7
nPosIns := 8
nPosPis := 9
nPosCof := 10
nPosCsl := 11
nPosRda := 12
nPosRec := 13
nPosVen := 14  
nPosFor	:= 15
nPosLoj := 16
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa o arquivo de trabalho                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! TRB->(EOF())
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
   //Ё VerIfica o cancelamento pelo usuario...                             Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  lAbortPrint
       @nLi,00 PSAY "*** CANCELADO PELO OPERADOR ***"
       Exit
   EndIf
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Inicializa variaveis                                                     Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cPfxAnt := TRB->E2_PREFIXO
   cNumAnt := TRB->E2_NUM    
   nVlrIrf := 0
   nVlrInss := 0
   nVlrpis  := 0
   nVlrCof  := 0
   nVlrCsl  := 0
         
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Processa o titulo (Prefixo+Num)                                          Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   While ! TRB->(EOF()) .and. TRB->E2_PREFIXO == cPfxAnt ;
                         .and. TRB->E2_NUM     == cNumAnt
  	  //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Seleciona lote                                                      Ё
	  //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If !Empty(TRB->E2_PLLOTE) .and. ;
         ( AllTrim(Subs(TRB->E2_PLLOTE,7,4)) < AllTrim(cLotDe) .or. AllTrim(Subs(TRB->E2_PLLOTE,7,4)) > AllTrim(cLotAte)) //.and. empty(TRB->E2_PARCELA)
          TRB->(dbSkip())
          Loop
      EndIf       
  	  //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Salta titulos referentes a abatimentos                              Ё
	  //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If  TRB->E2_TIPO $ MVABATIM .or. ;
          TRB->E2_TIPO $ "TXA,TX ,INS,ISS" .or. ;
          TRB->E2_TIPO == MVINSS .or. ;
          TRB->E2_TIPO == MVTAXA     
          TRB->(dbSkip())
          Loop
      EndIf       
      
     

	  //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Acessa BAU-Cadastro de RDA                                          Ё
	  //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If  Trb->E2_CODRDA <> BAU->BAU_CODIGO
          BAU->(msSeek(xFilial("BAU")+Trb->E2_CODRDA))
      EndIf
      If  ! empty(cClaPre) .and. ! BAU->BAU_TIPPRE $ cClaPre
          TRB->(dbSkip())
          Loop
      EndIf
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Salva titulo no array aTitulos                                           Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды      
      
      nTotDia := 0
      nTotLot := 0
      nPosLot := 1
      nPosPfx := 2
      nPosNum := 3
      nPosTip := 4
      nPosEmi := 5
      nPosVlr := 6
      nPosIrf := 7
      nPosIns := 8
      nPosPis := 9
      nPosCof := 10
      nPosCsl := 11
      nPosRda := 12
      nPosRec := 13
      nPosVen := 14  
      nPosFor := 15
      nPosLoj := 16   
      nPosPar := 17

      nPos := aScan(aTitulos,{|x| x[nPosPfx]+x[nPosNum]+x[nPosFor]+x[nPosLoj]  == TRB->(E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA)}) 
      If  nPos == 0
          If  empty(TRB->E2_PARCELA)
              aadd(aTitulos,{space(10),TRB->E2_PREFIXO,TRB->E2_NUM,"",ctod(""),0,0,0,0,0,0,"","",ctod(""),TRB->E2_FORNECE,TRB->E2_LOJA,TRB->E2_PARCELA})
              nPos := len(aTitulos)
          Else
              TRB->(dbSkip()) // se nao estava no array e temn parcela, eh porque refere-se a impostos de um titulo nao selecionado
              Loop
          EndIf
      EndIf
  	  //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Salva valores                                                       Ё
	  //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      nValor := Trb->E2_VALOR
      If  empty(Trb->E2_PARCELA) // indica que eh o titulo principal
          If  Trb->E2_TIPO == "NDF"
              nValor := nValor * -1
          EndIf
          If  nOrdem == 2
              aTitulos[nPos,nPosLot] := Trb->E2_PLLOTE
          EndIf
          aTitulos[nPos,nPosTip] := Trb->E2_TIPO
          aTitulos[nPos,nPosEmi] := Trb->E2_EMISSAO
          aTitulos[nPos,nPosVlr] := nValor  
          If Trb->E2_TIPO != "NDF"
	          aTitulos[nPos,nPosIrf] := Trb->E2_IRRF
	          aTitulos[nPos,nPosIns] := Trb->E2_INSS
	          aTitulos[nPos,nPosPis] := Trb->E2_VRETPIS
	          aTitulos[nPos,nPosCof] := Trb->E2_VRETCOF
	          aTitulos[nPos,nPosCsl] := Trb->E2_VRETCSL
          Endif
          aTitulos[nPos,nPosRda] := Trb->E2_CODRDA
          aTitulos[nPos,nPosRec] := Trb->E2_RECNO
          aTitulos[nPos,nPosVen] := Trb->E2_VENCREA
      Else
          If  Alltrim(Trb->E2_PARCELA) $ StrZero(1, TamSX3("E2_PARCELA")[1])
              aTitulos[nPos,nPosIns] := nValor
          Else
              aTitulos[nPos,nPosIrf] := nValor
          EndIf
      EndIf
 	  
 	  If BAU->BAU_TIPPE =='F'.and. BAU->BAU_CALIMP =='3'    // Pessoa fМsica com pagamento em folha
	
		cQry := " SELECT E2_TIPO, E2_NATUREZ, E2_VALOR, R_E_C_N_O_ AS E2_RECNO "
		cQry += " FROM " + RetSqlName("SE2") 
		cQry += " WHERE E2_FILIAL  =  '" + xFilial("SE2") + "' "
		cQry += "   AND E2_TITPAI = '" +TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA+ "' "
        If AllTrim(TCGetDB()) == "ORACLE/POSTGRES"
            cQry += "   AND SUBSTR(E2_ORIGEM,1,4) = 'PLSM' "
        Else
            cQry += "   AND SUBSTRING(E2_ORIGEM,1,4) = 'PLSM' "
        Endif
		cQry += "   AND D_E_L_E_T_ = ' ' "
	    
		cQry:=ChangeQuery(cQry) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBIMP",.F.,.T.)    
		
		For nCntFor := 1 To Len(aStruSE2)
		If ( aStruSE2[nCntFor,2]<>"C" )
			TcSetField("TRBIMP",aStruSE2[nCntFor,1],aStruSE2[nCntFor,2],aStruSE2[nCntFor,3],aStruSE2[nCntFor,4])
		EndIf
		Next nCntFor
		
		TRBIMP->(DbGoTop())                    
		While TRBIMP->(!EOF())
		 
          If Alltrim(TRBIMP->E2_NATUREZ) == &(GetNewPar('MV_IRF','"IRF"'))
         	 nVlrIrf  := TRBIMP->E2_VALOR
          Elseif Alltrim(TRBIMP->E2_NATUREZ) == GetNewPar('MV_PISNAT','PIS')
             nVlrpis := TRBIMP->E2_VALOR
          ElseIf Alltrim(TRBIMP->E2_NATUREZ) == GetNewPar('MV_COFINS','COFINS')
          	nVlrCof  := TRBIMP->E2_VALOR   
          ElseIf Alltrim(TRBIMP->E2_NATUREZ) == GetNewPar('MV_CSLL','CSLL')
          	nVlrCsl  :=   TRBIMP->E2_VALOR     
          ElseIf Alltrim(TRBIMP->E2_TIPO) =='INS'	
    	     nVlrInss := TRBIMP->E2_VALOR
	      Endif
	      
		
		TRBIMP->(Dbskip())
	    Enddo
	    TRBIMP->(DbCloseArea())
	 Endif
 	  
 	  //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Acessa proximo registro                                             Ё
	  //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  TRB->(dbSkip())
   EndDo 
   //Grava impostos pessoa fМsica
	If nVlrIrf + nVlrInss+ nVlrPis+nVlrCof+nVlrCsl > 0
		nPos := aScan(aTitulos,{|x| x[nPosPfx]+x[nPosNum] == cPfxAnt+cNumAnt}) 
		If nPos > 0
			aTitulos[nPos,nPosIrf] := nVlrIrf
	 		aTitulos[nPos,nPosIns] := nVlrInss
	        aTitulos[nPos,nPosPis] := nVlrPis
	        aTitulos[nPos,nPosCof] := nVlrCof
	        aTitulos[nPos,nPosCsl] := nVlrCsl
		Endif                                           
   	Endif                                         
EndDo                                         
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivo de trabalho                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TRB->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Incializa VARIAVEIS                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  len(aTitulos) > 0
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Ordena array aTitulos                                               Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  nOrdem == 1
		aTitulos := aSort(aTitulos,,, { |x, y| dtos(x[nPosEmi])+x[nPosPfx]+x[nPosNum] < dtos(y[nPosEmi])+y[nPosPfx]+y[nPosNum]})
    Else  
		aTitulos := aSort(aTitulos,,, { |x, y| x[nPosLot]+dtos(x[nPosEmi])+x[nPosPfx]+x[nPosNum] < y[nPosLot]+dtos(y[nPosEmi])+y[nPosPfx]+y[nPosNum]})
    EndIf
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Inicializa variaveis                                                Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    cLotAnt := aTitulos[1,nPosLot]
    dDatAnt := aTitulos[1,nPosEmi]
    cPfxAnt := aTitulos[1,nPosPfx]
    cNumAnt := aTitulos[1,nPosNum]
    lTemTit := .F.
    lTemDia := .F.
    lTemLot := .F.
    If  nTotais == 1 .and. nOrdem == 2 // lote
        cLinha := "Lote: " + aTitulos[1,nPosLot] + " - " + Posicione("BAF",1,xFilial("BAF")+PlsIntPad()+aTitulos[1,nPosLot],"BAF_HISTIT")
        R760Linha(cLinha,1,0)                   
    EndIf
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Processa array aTitulos                                             Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    For nPos := 1 to len(aTitulos)
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
    	//Ё Posiciona no SE2-Contas a Pagar                                     Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        SE2->(dbGoTo(aTitulos[nPos,nPosRec]))
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	//Ё VerIfica se houve quebra de data                                    Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        If  nTotais == 1
            If     nOrdem == 1 // emissao
        	       If  dDatAnt <> aTitulos[nPos,nPosEmi] .and. lTemDia
                       nLiq   := nDiaVlr - nDiaIrf - nDiaIns - nDiaPis - nDiaCof - nDiaCsl
                       cLinha := dtoc(dDatAnt) + space(72) + ;
                                  "Total nesta data" + space(34) + ;
                                  transform(nDiaVlr,"@E 999,999,999.99") + space(01) + ;
                                  transform(nDiaIrf,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaIns,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaPis,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaCof,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaCsl,"@E 999,999.99") + space(01) + ;
                                  transform(nLiq   ,"@E 999,999,999.99")
                       R760Linha(cLinha,2,0)                   
                       nDiaVlr := 0
                       nDiaIrf := 0
                       nDiaIns := 0
                       nDiaPis := 0
                       nDiaCof := 0
                       nDiaCsl := 0
                       lTemDia := .F.
    	           Else
    	               nLi++
    	           EndIf
            ElseIf nOrdem == 2 // lote+emissao
        	       If  cLotAnt+dtos(dDatAnt) <> aTitulos[nPos,nPosLot]+dtos(aTitulos[nPos,nPosEmi]) .and. lTemDia
                       nLiq   := nDiaVlr - nDiaIrf - nDiaIns - nDiaPis - nDiaCof - nDiaCsl
                       cLinha := dtoc(dDatAnt) + space(72) + ;
                                  "Total nesta data" + space(34) + ;
                                  transform(nDiaVlr,"@E 999,999,999.99") + space(01) + ;
                                  transform(nDiaIrf,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaIns,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaPis,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaCof,"@E 999,999.99") + space(01) + ;
                                  transform(nDiaCsl,"@E 999,999.99") + space(01) + ;
                                  transform(nLiq   ,"@E 999,999,999.99")
                       R760Linha(cLinha,2,0)                   
                       nDiaVlr := 0
                       nDiaIrf := 0
                       nDiaIns := 0
                       nDiaPis := 0
                       nDiaCof := 0
                       nDiaCsl := 0
                       lTemDia := .F.
    	           Else
    	               nLi++
    	           EndIf
        	       If  cLotAnt <> aTitulos[nPos,nPosLot] .and. lTemLot
                       nLiq   := nLotVlr - nLotIrf - nLotIns - nLotPis - nLotCof - nLotCsl
                       cLinha := space(8) + space(72) + ;
                                  "Total neste lote" + space(34) + ;
                                  transform(nLotVlr,"@E 999,999,999.99") + space(01) + ;
                                  transform(nLotIrf,"@E 999,999.99") + space(01) + ;
                                  transform(nLotIns,"@E 999,999.99") + space(01) + ;
                                  transform(nLotPis,"@E 999,999.99") + space(01) + ;
                                  transform(nLotCof,"@E 999,999.99") + space(01) + ;
                                  transform(nLotCsl,"@E 999,999.99") + space(01) + ;
                                  transform(nLiq   ,"@E 999,999,999.99")
                       R760Linha(cLinha,2,0)                   
    		           cLinha := Replicate("-",nLimite)
                       R760Linha(cLinha,1,0)
                       cLinha := "Lote: " + aTitulos[nPos,nPosLot] + " - " + Posicione("BAF",1,xFilial("BAF")+PlsIntPad()+aTitulos[nPosLot,nPosLot],"BAF_HISTIT")
                       R760Linha(cLinha,1,0)                   
                       nLotVlr := 0
                       nLotIrf := 0
                       nLotIns := 0
                       nLotPis := 0
                       nLotCof := 0
                       nLotCsl := 0
                       lTemLot := .F.
    	           Else
    	               nLi++
    	           EndIf
    	    EndIf
    	EndIf                           
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
    	//Ё Posiciona no SA2-Fornecedores                                       Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        If  SA2->(A2_FILIAL+A2_COD+A2_LOJA) <> xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)
    	    SA2->(msSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
    	EndIf
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
    	//Ё Lista SE2-Contas a Pagar                                            Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	    cLinTit := dtoc(aTitulos[nPos,nPosEmi]) + space(1) + ;
   	               dtoc(aTitulos[nPos,nPosVen]) + space(1) + ;
   	               aTitulos[nPos,nPosPfx] + space(01) + ;
   	               aTitulos[nPos,nPosNum] + space(01) + ;
   	               SE2->E2_FORNECE+"-"+SE2->E2_LOJA + space(01) + ;
   	               substr(SA2->A2_NOME,1,40) + space(01)
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	//Ё Processa BMS-Composicao do Pagamento                                Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        cQuery := fBuscaBMS(SE2->E2_PLLOTE, SE2->E2_PLOPELT,SE2->E2_CODRDA,SE2->E2_TIPO,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_EMIS1)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,, ChangeQuery(cQuery)  ),"TRBBMS",.F.,.T.) 

        cCodAnt := ""
        nTotBMS := 0
        nTotLin := 0
        lTemTit := .F.
        cOpeAnt := TRBBMS->BMS_OPERDA
        cLanAnt := TRBBMS->BMS_CODLAN
        cSerAnt := TRBBMS->BMS_CODSER
    	While ! TRBBMS->(eof())
       	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	   //Ё Lista BMS                                                           Ё
    	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           If  cCodAnt <> TRBBMS->BMS_CODLAN
    	       BLR->(msSeek(xFilial("BLR")+TRBBMS->BMS_OPERDA+TRBBMS->BMS_CODLAN))
               cLinCod := TRBBMS->BMS_CODLAN + space(01) //+ ;
    	   EndIf
           If  BLR->BLR_DEBCRE == "3"
    	       TRBBMS->(DbSkip())
               Loop
           EndIf               
    	   If  nTipRel == 1 // analitico - lista cada produto
        	   If  ! Empty(TRBBMS->BMS_CODPLA)
        	       BI3->(msSeek(xFilial("BI3")+TRBBMS->BMS_OPERDA+TRBBMS->BMS_CODPLA))//POSICIONA PRODUTO SAUDE
    	    	   cLinDeb := TRBBMS->BMS_CODPLA + space(01) + ;
    		                  substr(BI3->BI3_DESCRI+space(40),1,40) + space(01)
      		       cCod    := TRBBMS->BMS_CODPLA		
	    	       cDesc   := substr(BI3->BI3_DESCRI+space(20),1,40)
    	       Else
    		       BBB->(msSeek(xFilial("BBB")+TRBBMS->BMS_CODSER))//POSICIONA SERVICOS		
    		       clinDeb := TRBBMS->BMS_CODSER + " " + space(01) + ;
    	                      substr(BBB->BBB_DESCRI+space(40),1,40) + space(01)
    		       cCod    := TRBBMS->BMS_CODSER + " "
	               cDesc   := substr(BBB->BBB_DESCRI+space(20),1,40)
    	       EndIf
    	   Else
    	       If  TRBBMS->BMS_CODLAN+TRBBMS->BMS_CODSER <> cLanAnt+cSerAnt
   		           cCod    := cSerAnt + " "
                   If  cLanAnt == "101"
        	           BLR->(msSeek(xFilial("BLR")+cOpeAnt+cLanAnt))
	                   cDesc   := substr(BLR->BLR_DESCRI+space(20),1,40)
                   Else
    		           BBB->(msSeek(xFilial("BBB")+cSerAnt))//POSICIONA SERVICOS		
	                   cDesc   := substr(BBB->BBB_DESCRI+space(20),1,40)
    		       EndIf
       	           cLinha := cLinTit + ;
       	                     cLanAnt + space(01) + ;
   		                     cSerAnt + " " + space(01) + ;
   	                         cDesc   + space(01) + ;
   		                     transform(nTotLin,"@E 999,999,999.99")
                   R760Linha(cLinha,1,0)
                   nTotLin := 0
                   cLinTit := space(80)
    	       Else
   		           cCod    := TRBBMS->BMS_CODSER
                   If  TRBBMS->BMS_CODLAN == "101"
        	           BLR->(msSeek(xFilial("BLR")+TRBBMS->BMS_OPERDA+TRBBMS->BMS_CODLAN))
	                   cDesc   := substr(BLR->BLR_DESCRI+space(20),1,40)
                   Else
    		           BBB->(msSeek(xFilial("BBB")+cCod))//POSICIONA SERVICOS		
	                   cDesc   := substr(BBB->BBB_DESCRI+space(20),1,40)
    		       EndIf
    	       EndIf
    	   EndIf
           If  nTotais == 1
    	       If  nTipRel == 1
        	       cLinha := cLinTit + ;
        	                 cLinCod + ;
    	                     cLinDeb + ;
    		                 transform(TRBBMS->BMS_VLRPAG,"@E 999,999,999.99")
                   R760Linha(cLinha,1,0)
                   cLinTit := space(80)
               EndIf
           EndIf
       	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	   //Ё Posiciona BLR                                                       Ё
    	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           If  BLR->BLR_PROPRI+BLR->BLR_CODLAN <> TRBBMS->BMS_CODLAN
    	       BLR->(msSeek(xFilial("BLR")+TRBBMS->BMS_OPERDA+TRBBMS->BMS_CODLAN))
    	   EndIf
       	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	   //Ё Acumula para o resumo total                                         Ё
    	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           If  empty(TRBBMS->BMS_CODSER)
               i := aScan(aTotGer,{ |x| x[1] == TRBBMS->BMS_CODLAN})
           Else
               i := aScan(aTotGer,{ |x| x[1] == TRBBMS->BMS_CODLAN .and. x[3] == TRBBMS->BMS_CODSER+" "})
           EndIf
           If  i == 0
    	       BLR->(msSeek(xFilial("BLR")+TRBBMS->BMS_OPERDA+TRBBMS->BMS_CODLAN))
               If  empty(TRBBMS->BMS_CODSER)
                   aadd(aTotGer,{TRBBMS->BMS_CODLAN,"",space(4)           ,substr(BLR->BLR_DESCRI,1,40)          ,TRBBMS->BMS_VLRPAG})
               Else
    		       BBB->(msSeek(xFilial("BBB")+TRBBMS->BMS_CODSER))//POSICIONA SERVICOS		
                   aadd(aTotGer,{TRBBMS->BMS_CODLAN,"",TRBBMS->BMS_CODSER+" ",substr(BBB->BBB_DESCRI+space(20),1,40),TRBBMS->BMS_VLRPAG})
               EndIf
           Else
               aTotGer[i,5] += TRBBMS->BMS_VLRPAG
           EndIf
           If      BLR->BLR_DEBCRE == "1" // debito
                   nTotBMS -= TRBBMS->BMS_VLRPAG                            
           ElseIf  BLR->BLR_DEBCRE == "2" // credito
                   nTotBMS += TRBBMS->BMS_VLRPAG                            
           EndIf
           nTotLin += TRBBMS->BMS_VLRPAG                            
           cCodAnt := TRBBMS->BMS_CODLAN
           cOpeAnt := TRBBMS->BMS_OPERDA
           cLanAnt := TRBBMS->BMS_CODLAN
           cSerAnt := TRBBMS->BMS_CODSER
           lTemTit := .T.
           lTemDia := .T.
           lTemLot := .T.
       	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     	   //Ё Acessa proximo registro                                             Ё
    	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    	   TRBBMS->(DbSkip())
    	EndDo	
        TRBBMS->(DbCloseArea())
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	//Ё Lista ultimo total                                                  Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        If  nTipRel == 2 // sintetico - lista apenas totais com cod de pagamento
            cCod    := cSerAnt + " "
    		BBB->(msSeek(xFilial("BBB")+cSerAnt))//POSICIONA SERVICOS		
            If  cLanAnt == "101"
        	    BLR->(msSeek(xFilial("BLR")+cOpeAnt+cLanAnt))
	            cDesc   := substr(BLR->BLR_DESCRI+space(20),1,40)
            Else
                clinDeb := cSerAnt + " " + space(01) + ;
        	               substr(BBB->BBB_DESCRI+space(40),1,40) + space(01)
    		    cCod    := cSerAnt + " "
	            cDesc   := substr(BBB->BBB_DESCRI+space(20),1,40)
    		EndIf
            cLinha := cLinTit + ;
       	              cLanAnt + space(01) + ;
   		              cSerAnt + " " + space(01) + ;
   	                  cDesc   + space(01) + ;
   		              transform(nTotLin,"@E 999,999,999.99")
            R760Linha(cLinha,1,0)
            cLinTit := space(80)
    	EndIf
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	//Ё VerIfica se total do BMS = E2_VALOR                                 Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        If  nTotais == 1 .and. lTemTit
            nLiq   := nTotBMS - aTitulos[nPos,nPosIrf] - aTitulos[nPos,nPosIns] - aTitulos[nPos,nPosPis] - aTitulos[nPos,nPosCof] - aTitulos[nPos,nPosCsl]
            cLinha := space(80) + "Total" + space(49) + ;
                      transform(nTotBMS               ,"@E 999,999.99") + space(01) + ;
                      transform(aTitulos[nPos,nPosIrf],"@E 999,999.99") + space(01) + ;
                      transform(aTitulos[nPos,nPosIns],"@E 999,999.99") + space(01) + ;
                      transform(aTitulos[nPos,nPosPis],"@E 999,999.99") + space(01) + ;
                      transform(aTitulos[nPos,nPosCof],"@E 999,999.99") + space(01) + ;
                      transform(aTitulos[nPos,nPosCsl],"@E 999,999.99") + space(01) + ;
                      transform(nLiq                  ,"@E 999,999,999.99")
            R760Linha(cLinha,1,0)
        EndIf
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
    	//Ё Acumula no total do dia                                             Ё
    	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        nDiaVlr += nTotBMS
        nDiaIrf += aTitulos[nPos,nPosIrf]
        nDiaIns += aTitulos[nPos,nPosIns]
        nDiaPis += aTitulos[nPos,nPosPis]
        nDiaCof += aTitulos[nPos,nPosCof]
        nDiaCsl += aTitulos[nPos,nPosCsl]
        dDatAnt := aTitulos[nPos,nPosEmi]
        nLotVlr += nTotBMS
        nLotIrf += aTitulos[nPos,nPosIrf]
        nLotIns += aTitulos[nPos,nPosIns]
        nLotPis += aTitulos[nPos,nPosPis]
        nLotCof += aTitulos[nPos,nPosCof]
        nLotCsl += aTitulos[nPos,nPosCsl]
        nTotVlr += nTotBMS
        nTotIrf += aTitulos[nPos,nPosIrf]
        nTotIns += aTitulos[nPos,nPosIns]
        nTotPis += aTitulos[nPos,nPosPis]
        nTotCof += aTitulos[nPos,nPosCof]
        nTotCsl += aTitulos[nPos,nPosCsl]
        dDatAnt := aTitulos[nPos,nPosEmi]
    Next
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Lista total do dia                                                  Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  nTotais == 1 .and. lTemDia
        nLiq   := nDiaVlr - nDiaIrf - nDiaIns - nDiaPis - nDiaCof - nDiaCsl
        cLinha := dtoc(dDatAnt) + space(72) + ;
                   "Total nesta data" + space(34) + ;
                   transform(nDiaVlr,"@E 999,999,999.99") + space(01) + ;
                   transform(nDiaIrf,"@E 999,999.99") + space(01) + ;
                   transform(nDiaIns,"@E 999,999.99") + space(01) + ;
                   transform(nDiaPis,"@E 999,999.99") + space(01) + ;
                   transform(nDiaCof,"@E 999,999.99") + space(01) + ;
                   transform(nDiaCsl,"@E 999,999.99") + space(01) + ;
                   transform(nLiq   ,"@E 999,999,999.99")
        R760Linha(cLinha,2,0)                   
    EndIf    
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Lista total do lote                                                 Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  nTotais == 1 .and. nOrdem == 2 .and. lTemLot
        nLiq   := nLotVlr - nLotIrf - nLotIns - nLotPis - nLotCof - nLotCsl
        cLinha := space(80) + ;
                   "Total neste lote" + space(34) + ;
                   transform(nLotVlr,"@E 999,999,999.99") + space(01) + ;
                   transform(nLotIrf,"@E 999,999.99") + space(01) + ;
                   transform(nLotIns,"@E 999,999.99") + space(01) + ;
                   transform(nLotPis,"@E 999,999.99") + space(01) + ;
                   transform(nLotCof,"@E 999,999.99") + space(01) + ;
                   transform(nLotCsl,"@E 999,999.99") + space(01) + ;
                   transform(nLiq   ,"@E 999,999,999.99")
        R760Linha(cLinha,2,0)                   
        cLinha := Replicate("-",nLimite)
        R760Linha(cLinha,1,0)
    EndIf    
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Lista total geral                                                   Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    nLiq   := nTotVlr - nTotIrf - nTotIns - nTotPis - nTotCof - nTotCsl
    cLinha := space(80) + ;
               "Total geral     " + space(34) + ;
               transform(nTotVlr,"@E 999,999,999.99") + space(01) + ;
               transform(nTotIrf,"@E 999,999.99") + space(01) + ;
               transform(nTotIns,"@E 999,999.99") + space(01) + ;
               transform(nTotPis,"@E 999,999.99") + space(01) + ;
               transform(nTotCof,"@E 999,999.99") + space(01) + ;
               transform(nTotCsl,"@E 999,999.99") + space(01) + ;
               transform(nLiq   ,"@E 999,999,999.99")
    If  nOrdem == 1
        R760Linha(cLinha,2,0)                   
    Else
        R760Linha(cLinha,1,0)                   
    EndIf
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Lista resumo final                                                  Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  nLi > (nLinPag - len(aTotGer) - 7)
        nLin := 80
    EndIf
    cLinha := "Resumo final:"
    R760Linha(cLinha,1,0)
    aSort(aTotGer,,, { |x, y| x[1]+x[3] < y[1]+y[3] })
    For i := 1 to len(aTotGer)
        cLinha := space(80) + ;
                  aTotGer[i,1] + space(1) + ;
                  aTotGer[i,3] + space(1)  + ;
                  aTotGer[i,4] + space(1)  + ;
                  Transform(aTotGer[i,5],"@E 999,999,999.99")
        R760Linha(cLinha,1,0)
    Next
    cLinha := space(80) + ;
               "Total geral     " + space(34) + ;
               transform(nTotVlr,"@E 999,999,999.99") 
    R760Linha(cLinha,1,0)                   
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza a execucao do relatorio...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET DEVICE TO SCREEN
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt
    If aReturn[5]==1
        dbCommitAll()
        SET PRINTER TO
        OurSpool(wnrel)
    EndIf
    MS_FLUSH()
endIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R760Linha Ё Autor Ё Angelo Sperandio     Ё Data Ё 03.02.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime linha de detalhe                                   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Static Function R760Linha(cLinha,nAntes,nApos)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declara variaveis                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local i 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salta linhas antes                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For i := 1 to nAntes
    nli++
Next    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nli > nLinPag
    nli := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
    nli++
EndIf    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime linha de detalhe                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ nLi, 0 pSay cLinha
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salta linhas apos                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For i := 1 to nApos
    nli++
Next    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

Static function fBuscaBMS(cE2_PLLOTE, cE2_PLOPELT,cE2_CODRDA,cE2_TIPO,cE2_NUM,cE2_PREFIXO,cE2_FORNECE,cE2_LOJA,dE2_EMIS1)
Local cSQL          := ""
Default cE2_PLLOTE  := ""
Default cE2_PLOPELT := ""
Default cE2_CODRDA  := ""
Default cE2_TIPO    := ""
Default cE2_NUM     := ""
Default cE2_PREFIXO := ""
Default cE2_FORNECE := ""
Default cE2_LOJA    := ""
Default dE2_EMIS1   := dDataBase

    If !Empty(cE2_PLLOTE)
        //BMS->(msSeek(xFilial("BMS")+SE2->(E2_PLOPELT+E2_CODRDA+E2_PLOPELT+E2_PLLOTE)))
        cSQL := " SELECT "
        cSQL += " BMS.BMS_FILIAL, "
        cSQL += " BMS.BMS_OPERDA, "
        cSQL += " BMS.BMS_CODRDA, "
        cSQL += " BMS.BMS_OPELOT, "
        cSQL += " BMS.BMS_ANOLOT, "
        cSQL += " BMS.BMS_MESLOT, "
        cSQL += " BMS.BMS_NUMLOT, "
        cSQL += " BMS.BMS_CODPLA, "
        cSQL += " BMS.BMS_CODLAN, "
        cSQL += " BMS.BMS_CODSER, "
        cSQL += " BMS.BMS_VLRPAG  "

        cSQL += " FROM " + RetSqlName("BMS") + " BMS "
        cSQL += " WHERE BMS_FILIAL   = '" + xFilial("BMS")  + "' "
        cSQL += " AND BMS.BMS_OPERDA = '" + cE2_PLOPELT + "' "
        cSQL += " AND BMS.BMS_CODRDA = '" + cE2_CODRDA  + "' "
        cSQL += " AND BMS.BMS_OPELOT = '" + cE2_PLOPELT + "' "
        cSQL += " AND BMS.BMS_ANOLOT = '" + SUBSTR(cE2_PLLOTE,1,4) + "' "
        cSQL += " AND BMS.BMS_MESLOT = '" + SUBSTR(cE2_PLLOTE,5,2) + "' "
        cSQL += " AND BMS.BMS_NUMLOT = '" + SUBSTR(cE2_PLLOTE,7,4) + "' "
        If SE2->E2_TIPO == "NDF" /* titulo de DИbito gerado pelo PLS ao gerar o Lote de pagamento..*/
            cSQL += "  AND BMS.BMS_DEBCRE = '1'   "
        Else
            cSQL += "  AND BMS.BMS_DEBCRE <> '1'  "
        EndIf
        cSQL += "  AND BMS.D_E_L_E_T_ = ' ' "
    Else
        // Se TRB->E2_PLLOTE И vazio, significa que veio do Pedido de Compra (Lote de Pagamento gerado e Nota de Entrda vinculada)
        cSQL := "SELECT "
        cSQL += "  BMS.BMS_FILIAL, "
        cSQL += "  BMS.BMS_OPERDA, "
        cSQL += "  BMS.BMS_CODRDA, "
        cSQL += "  BMS.BMS_OPELOT, "
        cSQL += "  BMS.BMS_ANOLOT, "
        cSQL += "  BMS.BMS_MESLOT, "
        cSQL += "  BMS.BMS_NUMLOT, "
        cSQL += "  BMS.BMS_CODPLA, "
        cSQL += "  BMS.BMS_CODLAN, "
        cSQL += "  BMS.BMS_CODSER, "
        cSQL += "  BMS.BMS_VLRPAG, "
        cSQL += "  SC7.C7_PLOPELT, "
        cSQL += "  SC7.C7_LOTPLS "

        cSQL += "  FROM " + RetSqlName("SD1") + " SD1 "
        cSQL += " INNER JOIN " + RetSqlName("SC7") + " SC7  "
        cSQL += "    ON SC7.C7_FILIAL   = '" + xFilial("SC7") + "' "
        cSQL += "   AND SC7.C7_NUM      = SD1.D1_PEDIDO "
        cSQL += "   AND SC7.C7_ITEM     = SD1.D1_ITEMPC "
        cSQL += "   AND SC7.D_E_L_E_T_  = ' ' "

        cSQL += " INNER JOIN " + RetSqlName("BMS") + " BMS "
        cSQL += "    ON BMS.BMS_FILIAL  =	'" + xFilial("BMS") + "' " 
        cSQL += "   AND BMS.BMS_OPELOT  =	SC7.C7_PLOPELT "
        cSQL += "   AND BMS.BMS_CODRDA  =   SC7.C7_CODRDA "
        If AllTrim(TCGetDB()) == "ORACLE/POSTGRES"
            cSQL += "   AND BMS.BMS_ANOLOT  =	SUBSTR(SC7.C7_LOTPLS,1,4) "
            cSQL += "   AND BMS.BMS_MESLOT  =	SUBSTR(SC7.C7_LOTPLS,5,2) "
            cSQL += "   AND BMS.BMS_NUMLOT  =	SUBSTR(SC7.C7_LOTPLS,7,4) "
        Else
            cSQL += "   AND BMS.BMS_ANOLOT  =	SUBSTRING(SC7.C7_LOTPLS,1,4) "
            cSQL += "   AND BMS.BMS_MESLOT  =	SUBSTRING(SC7.C7_LOTPLS,5,2) "
            cSQL += "   AND BMS.BMS_NUMLOT  =	SUBSTRING(SC7.C7_LOTPLS,7,4) "
        Endif
        cSQL += "   AND BMS.BMS_DEBCRE  <> '1' "
        cSQL += "   AND BMS.D_E_L_E_T_  = ' ' "

        cSQL += " WHERE SD1.D1_FILIAL   = '" + xFilial("SD1") + "' "
        cSQL += "   AND SD1.D1_DOC      = '" + cE2_NUM + "' "
        cSQL += "   AND SD1.D1_SERIE    = '" + cE2_PREFIXO + "' "
        cSQL += "   AND SD1.D1_FORNECE  = '" + cE2_FORNECE + "' "
        cSQL += "   AND SD1.D1_LOJA     = '" + cE2_LOJA + "' "
        cSQL += "   AND SD1.D1_DTDIGIT  = '" + DTOS(dE2_EMIS1) + "' "
        cSQL += "   AND SD1.D_E_L_E_T_  = ' ' "
        cSQL += " GROUP BY "
        cSQL += "   BMS_FILIAL, "
        cSQL += "   BMS_OPERDA, "
        cSQL += "   BMS_CODRDA, "
        cSQL += "   BMS_OPELOT, "
        cSQL += "   BMS_ANOLOT, "
        cSQL += "   BMS_MESLOT, "
        cSQL += "   BMS_NUMLOT, "
        cSQL += "   BMS_CODPLA, "
        cSQL += "   BMS_CODLAN, "
        cSQL += "   BMS_CODSER, "
        cSQL += "   BMS_VLRPAG ,"
        cSQL += "   SC7.C7_PLOPELT, "
        cSQL += "   SC7.C7_LOTPLS "

    EndIf
Return cSQL
