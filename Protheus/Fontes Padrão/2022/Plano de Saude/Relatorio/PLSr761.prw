#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

Static lAutoSt := .F.

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSR761   ╨ Autor Ё Angelo Sperandio   ╨ Data Ё  23/09/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Emite relatorio com o mapa de faturamento                  ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6 IDE                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function PLSR761(lAuto)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cDesc1         := "Este programa tem como objetivo listar o mapa de "
Local cDesc2         := "faturamento, conforme parametros informados."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local aOrd           := {}
Local i

Default lAuto := .F.

Private cTitulo      := "Mapa de Faturamento"
Private cCabec1      := "                                                                         "
Private cCabec2      := "Emissao    Pfx Numero    P Empr Nome Cliente            TC Vencto         Valor"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private cTamanho     := "G"
Private cNomeprog    := "PLSR761" // Coloque aqui o nome do programa para impressao no cabecalho
Private nCaracter    := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag		 := 01
Private wnrel		 := "PLSR761" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nLimite		 := 220
Private cPerg        := "PLR761"
Private cAlias       := "SE1"
Private cSintetico   := ""
Private nLi          := 70
Private nLinPag      := 58

lAutoSt := lAuto
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a interface padrao com o usuario...                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	wnrel := SetPrint(cAlias,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,cTamanho,,.T.)
endif

If !lAuto .AND. nLastKey == 27
	Return
Endif
if !lAuto
	SetDefault(aReturn,cAlias)
endif
If !lAuto .AND. nLastKey == 27
    Return
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza perguntas                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)            
cEmissDe	:= dtos(mv_par01)
cEmissAte   := dtos(mv_par02)
cGrpDe   	:= mv_par03
cGrpAte  	:= mv_par04
cPrefixDe 	:= mv_par05
cPrefixAte	:= mv_par06
cTitDe  	:= mv_par07
cTitAte 	:= mv_par08
cCliDe  	:= mv_par09                                
cCliAte 	:= mv_par10                         
cConfig     := mv_par11
cGrpCob     := mv_par12
nLinPag     := mv_par13
nCaracter   := If(aReturn[4]==1,15,18)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Devera ser criado um arq. texto com os codigos de servicos Tab BBB       Ё
//Ё Devera ser criado um arq. texto com a seguinte forma                     Ё
//Ё 1a.posicao ---> devera ser digitado F-Fixa ou V-Variaveis                Ё
//Ё 2a.posicao ate o sinal de igualdade (=) --->Titulo da Coluna             Ё
//Ё apos sinal de igualdade (=) ---> os codigos de servico separados por "/" Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto .AND. ! File(cConfig)
    MsgStop("Arquivo de Configuracao do Relatorio nao Encontrado")
	Return()
Else
	aRet := R761ColRel()
EndIf
cCabec1 += aRet[1]
aColRel := aRet[2]
For i := 1 to len(aColRel)
    cCabec2 += space(1) + Right(space(12)+aColRel[i,1],12)
Next                       
cCabec2 += space(1) + "      IRRF"
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	RptStatus({|| RunReport(cCabec1,cCabec2,cTitulo) },cTitulo)
else
	RunReport(cCabec1,cCabec2,cTitulo)
endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do programa                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Fun┤└o    ЁRUNREPORT ╨ Autor Ё AP6 IDE            ╨ Data Ё  08/04/05   ╨╠╠
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
Local nTotDia  	:= 0
Local nTotGer  	:= 0
Local nIrfDia  	:= 0
Local nIrfGer  	:= 0
Local nTotBM1
Local nDif
Local dEmissao 	:= CTOD("")
Local cInd   	:= CriaTrab(nil,.F.)
Local cOrdem   	:= ''
Local cFor		:= ''
Local cMatAnt   := ""
Local cCodAnt   := ""
Local cDesAnt   := ""
Local cUsuar    := space(64)
Local aCol      := array(len(aColRel))
Local aDat      := array(len(aColRel))
Local aTot      := array(len(aColRel))
Local i
aFill(aCol,0)
aFill(aDat,0)
aFill(aTot,0)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Expressao de filtro...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuery := " SELECT E1_PREFIXO, E1_NUM,    E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCTO, E1_VALOR, "
cQuery += "        E1_CODEMP,  E1_NOMCLI, E1_IRRF "
cQuery += "  FROM " + RetSqlName("SE1")
If !Empty(cGrpCob)
	cQuery += ","+ RetSqlName("BQC")
EndIf
cQuery += " WHERE E1_FILIAL   = '" + xFilial("SE1") + "' "
cQuery += "   AND E1_PREFIXO >= '" + cPrefixDe + "' AND E1_PREFIXO <= '" + cPrefixAte + "' "
cQuery += "   AND E1_NUM >= '"     + cTitDe    + "' AND E1_NUM <= '"     + cTitAte    + "' "
cQuery += "   AND E1_EMISSAO >= '" + cEmissDe  + "' AND E1_EMISSAO <= '" + cEmissAte  + "' "
cQuery += "   AND E1_CLIENTE >= '" + cCliDe    + "' AND E1_CLIENTE <= '" + cCliAte    + "' "
cQuery += "   AND E1_CODEMP >= '"  + cGrpDe    + "' AND E1_CODEMP <= '"  + cGrpAte    + "' "
cQuery += "   AND SUBSTRING(E1_ORIGEM,1,3) = 'PLS' "
cQuery += "   AND "+RetSqlName("SE1")+".D_E_L_E_T_ = ' ' " 
If !Empty(cGrpCob)
	cQuery += "   AND E1_CODEMP = BQC_CODEMP "
	cQuery += "   AND E1_CONEMP = BQC_NUMCON "
	cQuery += "   AND E1_VERCON = BQC_VERCON "
	cQuery += "   AND E1_SUBCON = BQC_SUBCON "
	cQuery += "   AND E1_VERSUB = BQC_VERSUB "
	cQuery += "   AND BQC_GRPCOB IN "+ FormatIn(cGrpCob,"/")
	cQuery += "   AND "+RetSqlName("BQC")+".D_E_L_E_T_ = ' ' " 
EndIf
cQuery += " ORDER BY E1_EMISSAO, E1_PREFIXO, E1_NUM, E1_PARCELA "
PLSQUERY(cQuery,"TRB")
TRB->(DbGoTop())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona indices                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SA1->(DbSetOrder(1))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Filtra e ordena BM1                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BM1->(DbSetOrder(4))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Incializa controle de data                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dDatAnt := TRB->E1_EMISSAO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa o arquivo de trabalho                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While !TRB->(EOF())        
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
	//Ё Verifica o cancelamento pelo usuario...                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lAutoSt .AND. lAbortPrint
		@nLi,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Salta titulos referentes a abatimentos                              Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  TRB->E1_TIPO $ MVABATIM
        sleep(200)
        TRB->(dbSkip())
        Loop
    Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se houve quebra de data                                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  dDatAnt <> TRB->E1_EMISSAO
        cLinha := dtoc(dDatAnt) + space(01) + ;
                   space(16) + "Total nesta Data" + space(24) + ;
		           Transform(nTotDia,"@E 9,999,999.99") + space(01)
   	    For i := 1 to len(aDat) 
	        cLinha += TransForm(aDat[i],"@E 9,999,999.99") + space(01)
	    Next
        cLinha += Transform(nIrfDia,"@E 999,999.99") + space(01)
        R677Linha(cLinha,2,0)                   
		cLinha := Replicate("-",nLimite)
        R677Linha(cLinha,1,0)
		nTotDia := 0                   
		nIrfDia := 0                   
        aFill(aDat,0)
//	Else
//	    nLi++
	Endif                           
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processa BM1-Composicao de Cobranca                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    aBM1 := {}
	BM1->(msSeek(xFilial("BM1")+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO))
	While ! BM1->(eof()) .and. BM1->(BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT) == ;
                                xFilial("BM1")+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO
   	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
 	   //Ё Acumula no array                                                    Ё
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       nPos := aScan(aBM1,{|x| x[1] == BM1->BM1_CODTIP}) 
       If  nPos == 0
           nPos := aScan(aColRel,{|x| BM1->BM1_CODTIP $ x[2]}) 
           If  nPos > 0
               aadd(aBM1,{BM1->BM1_CODTIP,nPos,0})
               nPos := len(aBM1)
           Endif
       Endif
       If  nPos > 0
           If  BM1->BM1_TIPO == "1"
               aBM1[nPos,3] += BM1->BM1_VALOR
           Else
               aBM1[nPos,3] -= BM1->BM1_VALOR
           Endif
       Endif
   	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
 	   //Ё Acessa proximo registro                                             Ё
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   BM1->(dbSkip())	                                     
	EndDo		                                             
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Monta colunas                                                       Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    aFill(aCol,0)
    If  len(aBM1) > 0
        For i := 1 to len(aBM1)
            aCol[aBM1[i,2]] += aBM1[i,3]
        Next
    Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
	//Ё Posiciona no SA1-Clientes                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//    If  SA1->(A1_FILIAL+A1_COD+A1_LOJA) <> xFilial("SA1")+TRB->(E1_CLIENTE+E1_LOJA)
//	      SA1->(msSeek(xFilial("SA1")+TRB->(E1_CLIENTE+E1_LOJA)))
//    Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
	//Ё Verifica se o total do BM1 bate com o SE1                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    nTotBm1 := 0
    aEval(aCol,{|x| nTotBM1 += x})
    nDif    := TRB->E1_VALOR - nTotBM1
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
	//Ё Lista SE1-Contas a Receber                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    cLinha := dtoc(TRB->E1_EMISSAO) + space(01) + ;
               TRB->E1_PREFIXO + space(01) + ;
               TRB->E1_NUM + space(01) + ;
	           TRB->E1_PARCELA + space(01) + ;
	           TRB->E1_CODEMP  + space(01) + ;
	           TRB->E1_NOMCLI  + space(04) + ;
	           dtoc(TRB->E1_VENCTO) + space(01) + ;
	           TransForm(TRB->E1_VALOR - TRB->E1_IRRF,"@E 9,999,999.99") + space(01) 
	For i := 1 to len(aCol) 
	    cLinha += TransForm(aCol[i],"@E 9,999,999.99") + space(01)
	Next
    cLinha += Transform(TRB->E1_IRRF,"@E 999,999.99") + space(01)
    If  nDif <> 0
        cLinha += "Dif " + Transform(nDif,"@E 999,999.99")
    Endif
    R677Linha(cLinha,1,0)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se total do BM1 = E1_VALOR                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//    If  nTotBM1 <> TRB->E1_VALOR
//        @ nLi, 117 pSay "Dif SE1 x BM1"
//    Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©       
	//Ё Acumula no total do dia                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTotDia += TRB->E1_VALOR - TRB->E1_IRRF 
	nTotGer += TRB->E1_VALOR - TRB->E1_IRRF
	nIrfDia += TRB->E1_IRRF
	nIrfGer += TRB->E1_IRRF
    dDatAnt := TRB->E1_EMISSAO
    For i := 1 to len(aCol)
        aDat[i] += aCol[i]
        aTot[i] += aCol[i]
    Next
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acessa proximo registro                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB->(dbSkip())
EndDo                                         
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lista total do dia                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cLinha := dtoc(dDatAnt) + space(01) + ;
           space(16) + "Total nesta Data" + space(24) + ;
           Transform(nTotDia,"@E 9,999,999.99") + space(01)
For i := 1 to len(aDat) 
    cLinha += TransForm(aDat[i],"@E 9,999,999.99") + space(01)
Next
cLinha += Transform(nIrfDia,"@E 999,999.99") + space(01)
R677Linha(cLinha,2,0)
cLinha := Replicate("-",nLimite)
R677Linha(cLinha,1,0)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lista total geral                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cLinha := space(27) + "Total geral     " + space(24) + ;
           Transform(nTotGer,"@E 9,999,999.99") + space(01)
For i := 1 to len(aTot) 
    cLinha += TransForm(aTot[i],"@E 9,999,999.99") + space(01)
Next
cLinha += Transform(nIrfGer,"@E 999,999.99") + space(01)
R677Linha(cLinha,1,0)
cLinha := Replicate("-",nLimite)
R677Linha(cLinha,1,0)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivo de trabalho                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TRB->(DbCloseArea())
BM1->(dbClearFilter())
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza a execucao do relatorio...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
	SET DEVICE TO SCREEN
endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND. aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
if !lAutoSt
	MS_FLUSH()
endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R677Linha Ё Autor Ё Angelo Sperandio     Ё Data Ё 03.02.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime linha de detalhe                                   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Static Function R677Linha(cLinha,nAntes,nApos)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declara variaveis                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL i 
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
	// Se o primeiro cabec nao for informado pelo arquivo do usuАrio, trocar o cabec2 para o primeiro
	If Empty(cCabec1)
		cCabec1 := cCabec2
		cCabec2 := ""
	EndIf
    if !lAutoSt
		nli := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
    endif
	nli++
Endif    
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

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R761ColRelЁ Autor Ё Angelo Sperandio     Ё Data Ё 23.09.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Busca configuracao do relatorio                            Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Static Function R761ColRel()

Local nX, cFileCfg
Local nTamLin  := 220, nCtdLin 
Local cStrAux, nPosIgual
Local cCabec   := ""
Local aColunas := {}

cFileCfg := MemoRead(cConfig)
nCtdLin  := MLCount(cFileCFG, nTamLin)

For nX := 1 TO nCtdLin
    cStrAux := MemoLine(cFileCFG, nTamLin, nX)
    If  ! Left(cStrAux,2) $ "//,  " .and. (nPosIgual := AT("=",cStrAux)) > 0
        If  Left(cStrAux,5) == "Cabec"
            cCabec := trim(Subs(cStrAux, nPosIgual+1))
        Else
	        cTit := substr(cStrAux, 1, nPosIgual-1)
	        cCod := Alltrim(Subs(cStrAux, nPosIgual+1))
            aAdd(aColunas,{cTit, cCod})
        Endif
    EndIf    
Next   

Return({cCabec,aColunas})
