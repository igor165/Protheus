#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

Static lAutoSt := .F.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSR761   � Autor � Angelo Sperandio   � Data �  23/09/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Emite relatorio com o mapa de faturamento                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PLSR761(lAuto)

//���������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                �
//�����������������������������������������������������������������������
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
//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
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
//���������������������������������������������������������������������Ŀ
//� Atualiza perguntas                                                  �
//�����������������������������������������������������������������������
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
//��������������������������������������������������������������������������Ŀ
//� Devera ser criado um arq. texto com os codigos de servicos Tab BBB       �
//� Devera ser criado um arq. texto com a seguinte forma                     �
//� 1a.posicao ---> devera ser digitado F-Fixa ou V-Variaveis                �
//� 2a.posicao ate o sinal de igualdade (=) --->Titulo da Coluna             �
//� apos sinal de igualdade (=) ---> os codigos de servico separados por "/" �
//����������������������������������������������������������������������������
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
//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
if !lAuto
	RptStatus({|| RunReport(cCabec1,cCabec2,cTitulo) },cTitulo)
else
	RunReport(cCabec1,cCabec2,cTitulo)
endif
//���������������������������������������������������������������������Ŀ
//� Fim do programa                                                     �
//�����������������������������������������������������������������������
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  08/04/05   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(cCabec1,cCabec2,cTitulo)

//���������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                �
//�����������������������������������������������������������������������
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
//��������������������������������������������������������������������������Ŀ
//� Monta Expressao de filtro...                                             �
//����������������������������������������������������������������������������
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
//��������������������������������������������������������������������������Ŀ
//� Seleciona indices                                                        �
//����������������������������������������������������������������������������
SA1->(DbSetOrder(1))
//��������������������������������������������������������������������������Ŀ
//� Filtra e ordena BM1                                                      �
//����������������������������������������������������������������������������
BM1->(DbSetOrder(4))
//��������������������������������������������������������������������������Ŀ
//� Incializa controle de data                                               �
//����������������������������������������������������������������������������
dDatAnt := TRB->E1_EMISSAO
//��������������������������������������������������������������������������Ŀ
//� Processa o arquivo de trabalho                                           �
//����������������������������������������������������������������������������
While !TRB->(EOF())        
	//���������������������������������������������������������������������Ŀ       
	//� Verifica o cancelamento pelo usuario...                             �
	//�����������������������������������������������������������������������
	If !lAutoSt .AND. lAbortPrint
		@nLi,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	//���������������������������������������������������������������������Ŀ
	//� Salta titulos referentes a abatimentos                              �
	//�����������������������������������������������������������������������
    If  TRB->E1_TIPO $ MVABATIM
        sleep(200)
        TRB->(dbSkip())
        Loop
    Endif
	//���������������������������������������������������������������������Ŀ
	//� Verifica se houve quebra de data                                    �
	//�����������������������������������������������������������������������
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
	//���������������������������������������������������������������������Ŀ
	//� Processa BM1-Composicao de Cobranca                                 �
	//�����������������������������������������������������������������������
    aBM1 := {}
	BM1->(msSeek(xFilial("BM1")+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO))
	While ! BM1->(eof()) .and. BM1->(BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT) == ;
                                xFilial("BM1")+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO
   	   //���������������������������������������������������������������������Ŀ
 	   //� Acumula no array                                                    �
	   //�����������������������������������������������������������������������
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
   	   //���������������������������������������������������������������������Ŀ
 	   //� Acessa proximo registro                                             �
	   //�����������������������������������������������������������������������
	   BM1->(dbSkip())	                                     
	EndDo		                                             
    //���������������������������������������������������������������������Ŀ
    //� Monta colunas                                                       �
    //�����������������������������������������������������������������������
    aFill(aCol,0)
    If  len(aBM1) > 0
        For i := 1 to len(aBM1)
            aCol[aBM1[i,2]] += aBM1[i,3]
        Next
    Endif
	//���������������������������������������������������������������������Ŀ       
	//� Posiciona no SA1-Clientes                                           �
	//�����������������������������������������������������������������������
//    If  SA1->(A1_FILIAL+A1_COD+A1_LOJA) <> xFilial("SA1")+TRB->(E1_CLIENTE+E1_LOJA)
//	      SA1->(msSeek(xFilial("SA1")+TRB->(E1_CLIENTE+E1_LOJA)))
//    Endif
	//���������������������������������������������������������������������Ŀ       
	//� Verifica se o total do BM1 bate com o SE1                           �
	//�����������������������������������������������������������������������
    nTotBm1 := 0
    aEval(aCol,{|x| nTotBM1 += x})
    nDif    := TRB->E1_VALOR - nTotBM1
	//���������������������������������������������������������������������Ŀ       
	//� Lista SE1-Contas a Receber                                          �
	//�����������������������������������������������������������������������
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
	//���������������������������������������������������������������������Ŀ
	//� Verifica se total do BM1 = E1_VALOR                                 �
	//�����������������������������������������������������������������������
//    If  nTotBM1 <> TRB->E1_VALOR
//        @ nLi, 117 pSay "Dif SE1 x BM1"
//    Endif
	//���������������������������������������������������������������������Ŀ       
	//� Acumula no total do dia                                             �
	//�����������������������������������������������������������������������
	nTotDia += TRB->E1_VALOR - TRB->E1_IRRF 
	nTotGer += TRB->E1_VALOR - TRB->E1_IRRF
	nIrfDia += TRB->E1_IRRF
	nIrfGer += TRB->E1_IRRF
    dDatAnt := TRB->E1_EMISSAO
    For i := 1 to len(aCol)
        aDat[i] += aCol[i]
        aTot[i] += aCol[i]
    Next
	//���������������������������������������������������������������������Ŀ
	//� Acessa proximo registro                                             �
	//�����������������������������������������������������������������������
	TRB->(dbSkip())
EndDo                                         
//���������������������������������������������������������������������Ŀ
//� Lista total do dia                                                  �
//�����������������������������������������������������������������������
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
//���������������������������������������������������������������������Ŀ
//� Lista total geral                                                   �
//�����������������������������������������������������������������������
cLinha := space(27) + "Total geral     " + space(24) + ;
           Transform(nTotGer,"@E 9,999,999.99") + space(01)
For i := 1 to len(aTot) 
    cLinha += TransForm(aTot[i],"@E 9,999,999.99") + space(01)
Next
cLinha += Transform(nIrfGer,"@E 999,999.99") + space(01)
R677Linha(cLinha,1,0)
cLinha := Replicate("-",nLimite)
R677Linha(cLinha,1,0)
//���������������������������������������������������������������������Ŀ
//� Fecha arquivo de trabalho                                           �
//�����������������������������������������������������������������������
TRB->(DbCloseArea())
BM1->(dbClearFilter())
//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������
if !lAutoSt
	SET DEVICE TO SCREEN
endif
//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������
If !lAutoSt .AND. aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
if !lAutoSt
	MS_FLUSH()
endif
//���������������������������������������������������������������������Ŀ
//� Fim da funcao                                                       �
//�����������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R677Linha � Autor � Angelo Sperandio     � Data � 03.02.05 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime linha de detalhe                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function R677Linha(cLinha,nAntes,nApos)

//��������������������������������������������������������������������������Ŀ
//� Declara variaveis                                                        �
//����������������������������������������������������������������������������
LOCAL i 
//��������������������������������������������������������������������������Ŀ
//� Salta linhas antes                                                       �
//����������������������������������������������������������������������������
For i := 1 to nAntes
    nli++
Next    
//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho                                                        �
//����������������������������������������������������������������������������
If  nli > nLinPag
	// Se o primeiro cabec nao for informado pelo arquivo do usu�rio, trocar o cabec2 para o primeiro
	If Empty(cCabec1)
		cCabec1 := cCabec2
		cCabec2 := ""
	EndIf
    if !lAutoSt
		nli := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
    endif
	nli++
Endif    
//��������������������������������������������������������������������������Ŀ
//� Imprime linha de detalhe                                                 �
//����������������������������������������������������������������������������
@ nLi, 0 pSay cLinha
//��������������������������������������������������������������������������Ŀ
//� Salta linhas apos                                                        �
//����������������������������������������������������������������������������
For i := 1 to nApos
    nli++
Next    
//��������������������������������������������������������������������������Ŀ
//� Fim da funcao                                                            �
//����������������������������������������������������������������������������
Return()

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R761ColRel� Autor � Angelo Sperandio     � Data � 23.09.05 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Busca configuracao do relatorio                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
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
