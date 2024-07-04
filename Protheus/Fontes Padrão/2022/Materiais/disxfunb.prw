#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � D225QTDUP� Autor �Andrea Marques Federson� Data � 30/06/99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DESTA06  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializador Padrao Qtde Embalagem Padrao                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D225QTDUP(cCampo)                             

IF INCLUI
	nRetCpo  := 0
ELSE
	//��������������������������������������������������������������Ŀ
	//� Inicializa Variaveis                                         �
	//����������������������������������������������������������������
	//cCampo   := PARAMIXB						  Parametro ExecBlock (Campo)
	cProduto := cCampo+"COD"   		 		 // Produto
	cCod     := &(cProduto) 	 	
	cQTDUPAD := "SB1->B1_QTDUPAD"			 // Qtde Embalagem Padrao
	nRetCpo  := 0
	
	//��������������������������������������������������������������Ŀ
	//� Posiciona Cadastro de Produtos                               �
	//����������������������������������������������������������������
	dbselectarea ("SB1")
	dbsetorder(1)
	dbseek(xFilial("SB1") + cCod)	
	If eof()
		HELP(" ",1,"REGNOIS")	
	ELSE              
		nRetCpo := &(cQTDUPAD)
	ENDIF
ENDIF
//��������������������������������������������������������������Ŀ
//� Retorna Qtde Embalagem Padrao                                �
//����������������������������������������������������������������
Return(nRetCpo)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � D225CUSEM� Autor �Andrea Marques Federson� Data � 30/06/99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DESTA05  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializador Padrao Custo Unidade  x Custo Embalagem      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D225CUSEM(cCampo)
IF INCLUI
	nCusEMB := 0
ELSE	
	//��������������������������������������������������������������Ŀ
	//� Inicializa Variaveis                                         �
	//����������������������������������������������������������������
	//cCampo  := PARAMIXB						  Parametro ExecBlock (Campo)
	cProduto:= SUBST(cCampo,1,8)+"COD"
	cCod    := &(cProduto)                // Produto
	nCusto  := &(cCAMPO)						// Custo
	nCusEMB := 0

	//��������������������������������������������������������������Ŀ
	//� Posiciona Cadastro de Produtos                               �
	//����������������������������������������������������������������
	dbselectarea ("SB1")
	dbsetorder(1)
	dbseek(xFilial("SB1") + cCod)	
	If eof()
		HELP(" ",1,"REGNOIS")	
	ELSE
		//��������������������������������������������������������������Ŀ
		//� Verifica o Tipo de Produto e Calcula Custo da Embalagem      �
		//����������������������������������������������������������������
		IF SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD)
			nCUSEMB  := nCusto * SB1->B1_QTDUPAD
		ENDIF
	ENDIF
ENDIF
//��������������������������������������������������������������Ŀ
//� Retorna Custo da Embalagem                                   �
//����������������������������������������������������������������
Return(nCUSEMB)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DVLVISIT � Autor � Marcos Eduardo Rocha  � Data �28.11.95  ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DESTA63  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ExecBlock para alteracao na sequencia de visita ao preen-  ���
���          � chimento.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Distribuidoras Antarctica                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DVLVISIT()

Local nX := 0

cOld := BuscaCols("DA7_VISITA")
cNew := &(ReadVar())

If cOld <> cNew

   For nX := 1 To Len(ACols)
      If Acols[nX,4] >= cNew .And. (Acols[nX,4] < cOld .Or. Empty(cOld))
         Acols[nX,4] := StrZero(Val(Acols[nX,4])+1,6)
      ElseIf Acols[nX,4] <= cNew .And. Acols[nX,4] > cOld .And. !Empty(cOld)
         Acols[nX,4] := StrZero(Val(Acols[nX,4])-1,6)
      EndIf
   Next

EndIf

Return(.T.)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   � DVLCONTE � Autor �Andrea Marques Federson� Data � 09/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� DESTA13  �                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Descricao� Validacao Controle Embalagem - Cadastro de Produtos          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao                           � Responsavel �   Data   ���
���������������������������������������������������������������������������Ĵ��
��� Adapta��o para uso tamb�m em campo para segunda� Waldemiro   � 26/07/99 ���
��� Embalagem de Produtos e corre��es.             �             �          ���
���������������������������������������������������������������������������Ĵ��
���                                                �             �          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DVLCONTE(cCODEMBA)
//cCODEMBA := PARAMIXB                       Codigo da Embalagem
Local lRet

lRet       := .T.                           // Retorno de Validacao
cCONTEMB  := &(READVAR())                  // Controla Embalagem (S/N)

IF cCONTEMB == "S"
   IF EMPTY(&cCODEMBA)
      If cCODEMBA == "M->B1_CODEMBA"
         HELP(" ",1,"DSCDEMB131")
      ElseIf  cCODEMBA == "M->B1_CODEMB2"
         HELP(" ",1,"DSCDEMB132")
      EndIf
      lRet := .F.
   ELSE
		lRet := .T.							
	ENDIF		
ENDIF	

If cCODEMBA == "M->B1_CODEMB2" .And. cCONTEMB == "S"
   If Empty(M->B1_UNI2EMB)
      Help(" ",1,"DSCDEMB133")
      lRet := .F.
   EndIf
EndIf

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D080VLTES � Autor � Karla                 � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA32  �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Tes Ipi Aliquota Padrao x IPI Pauta           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function D080VLTES()
Local lRet  	  := .T.											// Retorno de Validacao
Local cIPI,cPAUTA

IF M->F4_CODIGO < "500"
   //��������������������������������������������������������������Ŀ
   //� Validacao (VALIDUSER) Campo F4_IPI e F4_PAUTA                �
   //����������������������������������������������������������������
   IF READVAR() == "M->F4_IPI"                  // Se Calculo IPI estiver
      cPAUTA  := M->F4_PAUTA                   // sim, nao pode calcular
      IF &(READVAR()) == "S"                    // IPI de pauta.
         IF cPAUTA == "S"
            HELP(" ",1,"DSFATA062")             // Caso contrario, utiliza
            lRet   := .F.                       // Calculo de IPI de Pauta
         ELSE                                   // como Padrao
            lRet   := .T.
         ENDIF
      ELSE
         lRet   := .T.
      ENDIF
   ELSE
      cIPI := M->F4_IPI
      IF &(READVAR()) == "S"
         IF cIPI == "S"
            HELP(" ",1,"DSFATA062")
            lRet   := .F.
         ELSE
            lRet   := .T.
         ENDIF
      ELSE
         lRet   := .T.
      ENDIF
   ENDIF
ENDIF

Return(lRet)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 � D225QTEMB� Autor � Octavio Moreira       � Data � 22/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� DESTA156 �                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Descricao� Execblock que monta a quantidade em mascara para o SB6       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Solicit. � Nerimar Mendes                                               ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Objetivos� Monta a quantidade com mascara especificamente para tratamen-���
���          � to do SB6, que possui apenas rotinas Modelo 3 para manutencao���
���������������������������������������������������������������������������Ĵ��
��� Observ.  �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao                           � Responsavel �   Data   ���
���������������������������������������������������������������������������Ĵ��
��� Conversao Protheus( D225QTEMB )                �             �          ���
���������������������������������������������������������������������������Ĵ��
���                                                �             �          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D225QTEMB(cCampo)
//��������������������������������������������������������������Ŀ
//� QUALQUER ALTERA��O NOS C�LCULOS ABAIXO RELACIONADOS PRECISA  �
//� SER REPLICADA NO PROGRAMA DESTA12.PRW !!!                    �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Inicializa Variaveis                                         �
//����������������������������������������������������������������
//cCampo  := PARAMIXB						  Parametro ExecBlock (Campo)
cProduto:= SUBST(cCampo,1,8)+If(Subs(cCampo,6,2)=="B6","PRODUTO","COD")
cCod    := &(cProduto)                // Produto
nQuant  := &(cCampo)						 // Quantidade
cQTDEMB := ""

//��������������������������������������������������������������Ŀ
//� Posiciona Cadastro de Produtos                               �
//����������������������������������������������������������������
dbselectarea ("SB1")
dbsetorder(1)
dbseek(xFilial("SB1") + cCod)	
If eof()
   HELP(" ",1,"REGNOIS")	
ELSE
   //��������������������������������������������������������������Ŀ
   //� Verifica o Tipo de Produto e Calcula Qtde.em Embalagens      �
   //����������������������������������������������������������������
   IF SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD)
	  cBusca   := ALLTRIM(SUBST(cCAMPO,6,3))+"QTEMB"
      dbSelectArea("SX3")
      dbSetOrder(2)
      dbSeek(cBusca)
      If EOF()
         Help(" ",1,"DS220AX3")
      ENDIF
      cPict 	 := ALLTRIM(X3_PICTURE)
      nPOS1    := AT("/",cPict)-3
      nPOS2    := LEN(cPict)-3
      nPOS3    := nPOS2 - nPOS1
      nQTD1    := INT(nQuant / SB1->B1_QTDUPAD)
      nQTD2    := INT(nQuant % SB1->B1_QTDUPAD)
      cQTDEMB  := STRZERO(nQTD1,nPOS1-1)+"/"+STRZERO(nQTD2,nPOS3)
   ENDIF
ENDIF

//��������������������������������������������������������������Ŀ
//� Retorna Quantidade em Formato Embalagem "9999/999"           �
//����������������������������������������������������������������
Return(cQTDEMB)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D630DiaFat| Autor � Silvio Cazela         � Data �15.03.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica data do faturamento                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���Revis�o	 � 													  � Data �			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function D630DiaFat()

Local dDataFat := Getmv("MV_DTFATUR")
Local lRet := .T.

If !Empty(dDataFat)
	If DtoS(dDataFat) != DtoS(dDataBase)
		Help(" ",1,"DFATINVAL",,"Data de faturamento nao liberada.",3,1)
		lRet := .F.
	Endif
Endif			

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ds460Pod3 �Autor  �Henry Fila          � Data �  09/15/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula poder de terceiros de embalagens                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamada na rotina DS460MSD2                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Ds460Pod3(c460Emb,n460Quant,cCargaOri)

Local awArea := {}
Local cTabEmb    := GetMv("MV_TABEMB")
Local nC         := 0
Local nPrcVen    := 0

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SD1")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SB2")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SB6")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SB1")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSetOrder(1)

dbSeek(xFilial()+c460Emb)

dbSelectArea("SB6")
RecLock("SB6",.T.)
SB6->B6_FILIAL  := xFilial("SB6")
SB6->B6_CLIFOR  := SD2->D2_CLIENTE
SB6->B6_LOJA    := SD2->D2_LOJA
SB6->B6_PRODUTO := c460Emb
SB6->B6_LOCAL   := RetFldProd(SB1->B1_COD,"B1_LOCPAD")         // SD2->D2_LOCAL

If !Empty(cTabEmb)
   //���������������������Ŀ
   //� Posiciona na Tabela �
   //�����������������������
   

   dbSelectArea("DA1")
  	dbSetOrder(1)
   dbSeek(xFilial()+cTabEmb+c460Emb)
  	If DA1->DA1_ATIVO == "1"
     	nPrcVen := DA1->DA1_PRCLIQ
   EndIf
   
EndIf

//����������������������������������������Ŀ
//� Caso nao seja informado a Tabela ou    �
//� nao exista o preco na tabela informada �
//� usa o custo Standard                   �
//������������������������������������������
If nPrcVen == 0
   SB6->B6_PRUNIT  := RetFldProd(SB1->B1_COD,"B1_CUSTD")   
Else                                  
   SB6->B6_PRUNIT  := nPrcVen
EndIf

SB6->B6_DOC     := SD2->D2_DOC
//SB6->B6_SERIE   := SD2->D2_SERIE
SerieNfId ("SB6",1,"B6_SERIE",,,,SD2->D2_SERIE)
SB6->B6_EMISSAO := SD2->D2_EMISSAO
SB6->B6_DTDIGIT := SD2->D2_EMISSAO
SB6->B6_QUANT   := n460Quant
SB6->B6_SALDO   := n460Quant

SB6->B6_UM      := SB1->B1_UM         
SB6->B6_SEGUM   := SB1->B1_SEGUM      
If !Empty(SB1->B1_CONV)              
   If SB1->B1_TIPCONV == "M"
      SB6->B6_QTSEGUM := n460Quant * SB1->B1_CONV
   Else
      SB6->B6_QTSEGUM := n460Quant / SB1->B1_CONV
   EndIf
EndIf

If SB6->(FieldPos("B6_CARGA")) > 0										
	SB6->B6_CARGA   := cCargaOri
Endif		
SB6->B6_ORIGLAN := "NS"

If SC5->C5_TIPO == "N"
   SB6->B6_TIPO   := "E"
   SB6->B6_TPCF   := "C"
   SB6->B6_PODER3 := "R"
   SB6->B6_IDENT  := SD2->D2_NUMSEQ
   SB6->B6_TES    := GetMV("MV_TES"+SB6->B6_TIPO+SB6->B6_PODER3)
   //����������������������������Ŀ
   //� Grava Identificador em SD2 �
   //������������������������������
   dbSelectArea("SD2")
   SD2->D2_IDENTB6 := SB6->B6_IDENT
Else
   SB6->B6_TIPO   := "D"
   SB6->B6_TPCF   := "F"
   SB6->B6_PODER3 := "D"
   SB6->B6_IDENT  := SD2->D2_IDENTB6
   SB6->B6_TES    := GetMV("MV_TES"+SB6->B6_TIPO+SB6->B6_PODER3)
   //��������������������������������Ŀ
   //� Grava IdentB6 da Nota Original �
   //����������������������������������
   dbSelectArea("SD1")
   dbSetOrder(1)
   dbSeek(xFilial()+SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD)
   If !EOF()
      dbSelectArea("SD2")
      SD2->D2_IDENTB6 := SD1->D1_IDENTB6
   ENDIF
   dbSelectArea ("SB6")
   SB6->B6_IDENT   := SD1->D1_IDENTB6
EndIf

//��������������������������������������Ŀ
//� Atualiza Saldo em Poder de Terceiros �
//����������������������������������������
dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(xFilial()+c460Emb+SB6->B6_LOCAL)
   RecLock("SB2",.F.)
Else
   CriaSB2(c460Emb,SB6->B6_LOCAL)
EndIf
If SB6->B6_TIPO == "E"
   SB2->B2_QNPT := SB2->B2_QNPT + n460Quant
Else
   SB2->B2_QTNP := SB2->B2_QTNP - n460Quant
EndIf
If SC5->C5_TIPO <> "N"
   dbSelectArea("SB6")
   dbSetOrder(3)
   If dbSeek(xFilial()+SB6->B6_IDENT+SB6->B6_PRODUTO+"R")
      RecLock("SB6",.F.)
      SB6->B6_SALDO := SB6->B6_SALDO - n460Quant
      If DtoS(B6_UENT) < DtoS(SD2->D2_EMISSAO)
         SB6->B6_UENT := SD2->D2_EMISSAO
      EndIf
      If SB6->B6_SALDO <= 0
         SB6->B6_ATEND := "S"
      Else
         SB6->B6_ATEND := "N"
      EndIf
   EndIf
   
EndIf

//����������������������������������������������������������������������������Ŀ
//�Verifica se o TES do item da nota em questao  controla estoque da embalagem �
//�do produto                                                                  �
//������������������������������������������������������������������������������

If SF4->F4_CTREMBA == "S" 
                                                
	aCustoMed := PegaCMAtu(SD2->D2_COD, SD2->D2_LOCAL)
	nQtSegun := ConvUm(SB1->B1_COD,n460Quant,0,2)
	
	RecLock("SD3",.T.)
	
		SD3->D3_FILIAL  := xFilial()
		SD3->D3_COD     := SB1->B1_COD
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_TIPO    := SB1->B1_TIPO
		SD3->D3_CC      := SB1->B1_CC
		SD3->D3_CF      := "RE0"
		SD3->D3_TM      := "999"		
		SD3->D3_USUARIO := CUSERNAME
		SD3->D3_CHAVE   := SubStr(SD3->D3_CF,2,1)+IIF(AllTrim(SD3->D3_CF)=="DE4","9","0")
		SD3->D3_DOC     := SF2->F2_DOC
		SD3->D3_NUMSEQ  := ProxNum()
		SD3->D3_UM      := SB1->B1_UM
		SD3->D3_SEGUM   := SB1->B1_SEGUM
		SD3->D3_CONTA   := SB1->B1_CONTA
		SD3->D3_QUANT   := n460Quant
		SD3->D3_CUSTO1  := aCustoMed[1]
		SD3->D3_CUSTO2  := aCustoMed[2]
		SD3->D3_CUSTO3  := aCustoMed[3]
		SD3->D3_CUSTO4  := aCustoMed[4]
		SD3->D3_CUSTO5  := aCustoMed[5]
		SD3->D3_PARCTOT:= "T"
		SD3->D3_EMISSAO:= dDataBase
		SD3->D3_SEGUM   := SB1->B1_SEGUM     
		SD3->D3_QTSEGUM := nQtSegun

		If Rastro(SD3->D3_COD)
			If Rastro(SD3->D3_COD,"S")
				SD3->D3_NUMLOTE := NextLote(SD3->D3_COD,"S")
			EndIf
			SD3->D3_LOTECTL := NextLote(SD3->D3_COD,"L",SD3->D3_NUMLOTE)
		EndIf

	MsUnlock()		

	//������������������������������������������������������������������Ŀ
	//� Atualiza arquivo de demandas se for movimento de material direto �
	//��������������������������������������������������������������������
	
	cMes := "B3_Q"+StrZero(Month(SD3->D3_EMISSAO),2)
	dbSelectArea("SB3")
	If !dbSeek(xFilial()+SD3->D3_COD)
		RecLock("SB3",.T.)
		SB3->B3_FILIAL := xFilial()
		SB3->B3_COD    := SD3->D3_COD
	Else
		RecLock("SB3",.F.)
	EndIf
	Replace &(cMes) With &(cMes) + SD3->D3_QUANT
   MsUnlock()

	//��������������������������������������������Ŀ
	//� Grava o custo da movimentacao              �
	//����������������������������������������������

	aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)	
	aCusto := GravaCusD3(aCM)
	B2AtuComD3(aCusto)
	
Endif

dbSelectArea("SB2")
MsUnLock()

dbSelectArea("SB6")
MsUnLock()

For nC := Len(awArea) to 1 Step -1
   dbSelectArea(awArea[nC][1])
   dbSetOrder(awArea[nC][2])
   If Recno() != awArea[nC][3]
      dbGoto(awArea[nC][3])
   EndIf
Next nC

Return NIL


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Fun��o   � A460GRAV � Autor � Waldemiro L. Lustosa  � Data � 09/07/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descri��o� Ponto de Entrada na Grava��o do C9_NFISCAL (MATA460)         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function D460Grav()

Local awArea := { Alias(), IndexOrd(), Recno() }

If !Empty(C9_CARGA)

   // �����������������������������������������������������������������Ŀ
   // � Posiciono o DAI e o DAK para uso destas informa��es no Ponto de �
   // � Entrada MSD2460.PRX ���������������������������������������������
   // �����������������������
   dbSelectArea("DAK")
   dbSetOrder(1)
   If dbSeek(xFilial("DAK")+SC9->C9_CARGA+SC9->C9_SEQCAR)
      dbSelectArea("DAI")
      dbSetOrder(1)
      dbSeek(xFilial("DAI")+SC9->C9_CARGA+SC9->C9_SEQCAR+SC9->C9_PEDIDO)
   EndIf

Else
   // �������������������������������������������Ŀ
   // � For�o o desposicionamento (por precau��o) �
   // ���������������������������������������������
   dbSelectArea("DAK")
   dbGoBottom()
   dbSkip()
   dbSelectArea("DAI")
   dbGoBottom()
   dbSkip()
EndIf

dbSelectArea(awArea[1])
dbSetOrder(awArea[2])
If Recno() != awArea[3]
   dbGoto(awArea[3])
EndIf

Return
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DFata332     � Autor � Marcos Cesar      � Data � 09/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Recalcula o Valor dos Impostos (ICMS e IPI).                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpA1 := DFata332(ExpN1,ExpN2)                               ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 : Quantidade                                           ���
���          � ExpN2 : Valor Total                                          ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ExpA1 : Array contendo os Valores dos Impostos.              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFata332                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DFata332(nQuantidade, nValor)

//����������������������������������������������������������������������Ŀ
//� Array com os Valores dos Impostos. Estrutura :                       �
//�                                                                      �
//� aArray[1] : Valor do IPI                                             �
//� aArray[2] : Valor do ICMS                                            �
//� aArray[3] : Valor do ICMS Retido                                     �
//� aArray[4] : Base de Calculo do ICMS Retido                           �
//� aArray[5] : Base de Calculo do ICMS                                  �
//� aArray[6] : Base de Calculo do IPI                                   �
//������������������������������������������������������������������������
Local aVlrImpostos := { 0, 0, 0, 0, 0, 0 }

//����������������������������������������������������������������������Ŀ
//� Pesquisa o Arquivo SF4 (Tipos de Entrada e Saida).                   �
//������������������������������������������������������������������������
dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial() + cTesDev)

//����������������������������������������������������������������������Ŀ
//� Calcula a Base de IPI.                                               �
//������������������������������������������������������������������������
//nBaseIPI := (SD2->D2_TOTAL + Iif(GetMv("MV_IPIBRUT") == "N", 0, SD2->D2_DESCON + SD2->D2_DESCZFR)) * _nValor / SD2->D2_TOTAL
//nBaseIPI := (SD2->D2_TOTAL + Iif(GetMv("MV_IPIBRUT") == "N", 0, SD2->D2_DESCON + SD2->D2_DESCZFR)) * If(_nQuantidade <> SD2->D2_QUANT,_nQuantidade <> SD2->D2_QUANT,1)
nBaseIPI := (SD2->D2_TOTAL + Iif(GetMv("MV_IPIBRUT") == "N", 0, SD2->D2_DESCON + SD2->D2_DESCZFR)) * If(nQuantidade <> SD2->D2_QUANT,nQuantidade / SD2->D2_QUANT,1)

If !Empty(SF4->F4_BASEIPI)
	nBaseIPI := nBaseIPI * (SF4->F4_BASEIPI / 100)
EndIf

//����������������������������������������������������������������������Ŀ
//� Verifica se a Devolucao foi integral.                                �
//������������������������������������������������������������������������
If nQuantidade == SD2->D2_QUANT
	nVlrIPI      := SD2->D2_VALIPI
	nVlrICMS     := SD2->D2_VALICM
	nVlrICMSRet  := SD2->D2_ICMSRET
	nBaseICMS    := SD2->D2_BASEICM
	nBaseICMSRet := SD2->D2_BRICMS
Else
	//����������������������������������������������������������������������Ŀ
	//� Calcula os impostos utilizando uma regra de tres com os valores da   �
	//� Nota Fiscal de Saida.                                                �
	//������������������������������������������������������������������������
	nVlrIPI      := (nValor * SD2->D2_VALIPI)  / SD2->D2_TOTAL
	nVlrICMS     := (nValor * SD2->D2_VALICM)  / SD2->D2_TOTAL
	nVlrICMSRet  := (nValor * SD2->D2_ICMSRET) / SD2->D2_TOTAL
	nBaseICMS    := (nValor * SD2->D2_BASEICM) / SD2->D2_TOTAL
	nBaseICMSRet := (nValor * SD2->D2_BRICMS)  / SD2->D2_TOTAL
EndIf

//����������������������������������������������������������������������Ŀ
//� Array com os Valores dos Impostos.                                   �
//������������������������������������������������������������������������
aVlrImpostos := { nVlrIPI, nVlrICMS, nVlrICMSRet, nBaseICMSRet, nBaseICMS, nBaseIPI }

Return(aVlrImpostos)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DFata333 � Autor � Marcos Cesar          � Data � 09/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rdmake p/ Abatimento da Devolucao e/ou da Quebra no Valor do ���
���          � Titulo a Receber do Cliente.                                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DFata333(ExpA1)                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1[1] : Codigo do Cliente                                 ���
���          � ExpA1[2] : Loja do Cliente                                   ���
���          � ExpA1[3] : Serie da Nota Fiscal Original                     ���
���          � ExpA1[4] : Numero do Documento Original                      ���
���          � ExpA1[5] : Valor do Abatimento                               ���
���          � ExpA1[6] : Serie da nota fiscal de entrada                   ���
���          � ExpA1[7] : Valor do frete para rateio                        ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Especifico p/ Distribuidora Antarctica.                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Almir Bandina�27.11.99�      � Rateia o valor do frete                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function DFata333(aDados)

cCliente  := aDados[1]
cLoja     := aDados[2]
cSerieOri := aDados[3]
cDocOri   := aDados[4]
nVlrAbat  := aDados[5]
cPrefixo   := aDados[6]
nFrete    := aDados[7]

//����������������������������������������������������������Ŀ
//� Verifica se o Titulo a Receber foi baixado.              �
//������������������������������������������������������������
dbSelectArea("SE1")
dbSetOrder(2)
dbSeek(xFilial() + cCliente + cLoja + cSerieOri + cDocOri)

If Found()
	lBaixa   := .T.
	lBxFatura := .F.

	//����������������������������������������������������������Ŀ
	//� Verifica se existe Fatura p/ esse Titulo.                �
	//������������������������������������������������������������
	If !Empty(SE1->E1_FATPREF) .And. !Empty(SE1->E1_FATURA)
		dbSelectArea("SE1")
		dbSeek(xFilial() + cCliente + cLoja + SE1->E1_FATPREF + SE1->E1_FATURA)

		If !Found()
			lBaixa := .F.
		EndIf
	EndIf

   dbSelectArea("SE1")

	If lBaixa
      //����������������������������������������������������������Ŀ
      //� Verifica se o titulo ja foi enviado ao banco             �
      //������������������������������������������������������������
      dbSelectArea("SEA")
      dbSetOrder(2)
      dbSeek(xFilial() + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA)

		If NoRound(SE1->E1_SALDO, 2) < NoRound(nVlrAbat, 2) .Or. ;
         SEA->EA_TRANSF == "S"
			//����������������������������������������������������������Ŀ
			//� Gera Titulo de Credito (NCC) p/ o Cliente.               �
			//������������������������������������������������������������
			A333DupCred(nVlrAbat, SF4->F4_CODIGO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_COND, SE1->E1_NATUREZ)

			//����������������������������������������������������������Ŀ
			//� Atualiza o Campo de Origem do Titulo.                    �
			//������������������������������������������������������������
			dbSelectArea("SE1")
			RecLock("SE1", .F.)

			SE1->E1_ORIGEM := "DFATA33"
			SE1->E1_CARGA  := SF2->F2_CARGA
			SE1->E1_ACEROK := dDataBase

			MsUnLock()
		Else
			//����������������������������������������������������������Ŀ
			//� Atualiza o Arquivo SE1 (Titulos a Receber) e Gera Movi-  �
			//� mentacao Bancaria.                                       �
			//������������������������������������������������������������
			A333AtuTit()
		EndIf
	EndIf
EndIf

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � A333DupCred  � Autor � Marcos Cesar      � Data � 01/09/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Gera Titulo de Credito (NCC) p/ o Cliente.                   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � A333DupCred(ExpN1,ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 : Valor do Titulo NF                                   ���
���          � ExpC1 : Codigo do Tes NF                                     ���
���          � ExpC2 : Codigo do Cliente NF                                 ���
���          � ExpC3 : Loja do Cliente NF                                   ���
���          � ExpC4 : Serie do Titulo NF                                   ���
���          � ExpC5 : Numero do Titulo NF                                  ���
���          � ExpC6 : Condicao de Pagamento NF                             ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFata333                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A333DupCred(nValTot, cTes, cCliente, cLoja, cPrefixo, cNumero, cCondPag, cNaturez)

Local cSaveAlias := Alias()
Local nSaveOrd   := IndexOrd()
Local nMoeda     := 1

//����������������������������������������������������������Ŀ
//� Pesquisa o Arquivo SA1 (Cadastro de Clientes).           �
//������������������������������������������������������������
dbSelectArea("SA1")
dbSeek(cFilial + cCliente + cLoja)

//����������������������������������������������������������Ŀ
//� Grava o Titulo NCC.                                      �
//������������������������������������������������������������
dbSelectArea("SE1")
RecLock("SE1", .T.)

SE1->E1_FILIAL  := cFilial
SE1->E1_PREFIXO := cPrefixo   //&(GetMV("mv_2dupref"))
SE1->E1_NUM     := cNumero
SE1->E1_PARCELA := (GetMV("mv_1dup"))
SE1->E1_NATUREZ := If(cNaturez==NIL,Space(10),cNaturez)
SE1->E1_TIPO    := "NCC"
SE1->E1_EMISSAO := dDataBase
SE1->E1_VALOR   := nValTot + nFrete
SE1->E1_VENCREA := dDataBase
SE1->E1_SALDO   := nValTot + nFrete
SE1->E1_VENCTO  := dDataBase
SE1->E1_VENCORI := ddataBase
SE1->E1_EMIS1   := dDataBase
SE1->E1_CLIENTE := cCliente
SE1->E1_LOJA    := cLoja
SE1->E1_NOMCLI  := SA1->A1_NREDUZ
SE1->E1_COND    := cCondPag
SE1->E1_MOEDA   := 1
SE1->E1_VLCRUZ  := xMoeda(SE1->E1_VALOR,nMoeda,1,SE1->E1_EMISSAO)
SE1->E1_STATUS  := Iif(SE1->E1_SALDO>0.01,"A","B")
SE1->E1_SITUACA := "0"
SE1->E1_ORIGEM  := "DFATA333"
SE1->E1_ACEROK  := dDataBase
MsUnLock()

nValForte := ConvMoeda(E1_EMISSAO,E1_VENCTO,E1_VALOR,GetMv("mv_mcusto"))

dbSelectArea( "SA1" )
RecLock("SA1")

SA1->A1_SALDUP  := SA1->A1_SALDUP  - xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO)
SA1->A1_SALDUPM := SA1->A1_SALDUPM - xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,Val(GetMv("MV_MCUSTO")),SE1->E1_EMISSAO)

dbSelectArea(cSaveAlias)
dbSetOrder(nSaveOrd)

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � A333AtuTit   � Autor � Marcos Cesar      � Data � 07/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o Titulo a Receber e Gera Movimentacao Bancaria.    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � A333AtuTit()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFata333                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Almir Bandina�27.11.99�      � Rateia o valor do frete                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A333AtuTit()

Local nB := 0

nSaldoSE1 := SE1->E1_SALDO - nVlrAbat - nFrete

//����������������������������������������������������������Ŀ
//� Deleta o Bordero do Arquivo SEA (Titulos enviados ao     �
//� Banco).                                                  �
//������������������������������������������������������������
dbSelectArea("SEA")
dbSetOrder(1)
dbSeek(xFilial() + SE1->E1_NUMBOR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)

While !Eof() .And. SEA->EA_FILIAL+SEA->EA_NUMBOR+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO ;
		== xFilial()+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO

	If SEA->EA_CART == "R"
		dbSelectArea("SEA")
		RecLock("SEA", .F.)
      SEA->EA_CART := "X"
		MsUnLock()
	EndIf

	dbSelectArea("SEA")
	dbSkip()
End

//����������������������������������������������������������Ŀ
//� Atualiza o Titulo a Receber.                             �
//������������������������������������������������������������
dbSelectArea("SE1")
RecLock("SE1", .F.)

SE1->E1_SALDO   := Iif(nSaldoSE1 < 0, 0, nSaldoSE1)
SE1->E1_BAIXA   := DAK->DAK_DTACCA										//dDataBase
SE1->E1_MOVIMEN := DAK->DAK_DTACCA										//dDataBase
SE1->E1_STATUS  := Iif(SE1->E1_SALDO > 0.01, "A", "B")
SE1->E1_NUMBOR  := Space(6)
SE1->E1_SITUACA := "0"
MsUnLock()

//��������������������������������������������������������������Ŀ
//� Atualiza o Cadastro de Clientes.                             �
//����������������������������������������������������������������
dbSelectArea("SA1")
RecLock("SA1", .F.)

If nVlrAbat + nFrete >= SA1->A1_SALDUP
	nSalDup := 0
Else
	nSalDup := SA1->A1_SALDUP - nVlrAbat - nFrete
EndIf

SA1->A1_SALDUP  := nSalDup
SA1->A1_SALDUPM := SA1->A1_SALDUPM - xMoeda(nVlrAbat+nFrete,SE1->E1_MOEDA,Val(GetMv("MV_MCUSTO")),SE1->E1_EMISSAO)

If (SE1->E1_BAIXA - SE1->E1_VENCREA) > SA1->A1_MATR
	SA1->A1_MATR := SE1->E1_BAIXA - SE1->E1_VENCREA
EndIf

//��������������������������������������������������������������Ŀ
//� Atualiza Atraso Medio.                                       �
//����������������������������������������������������������������
If (SE1->E1_BAIXA - SE1->E1_VENCREA) > 0
	SA1->A1_PAGATR := SA1->A1_PAGATR + SE1->E1_VALLIQ
	SA1->A1_ATR    := Iif(SA1->A1_ATR == 0, 0, Iif(SA1->A1_ATR < SE1->E1_VALLIQ, 0, SA1->A1_ATR - SE1->E1_VALLIQ))
EndIf

SA1->A1_METR := (SA1->A1_METR * (SA1->A1_NROPAG - 1) + (SE1->E1_BAIXA - SE1->E1_VENCREA)) / (SA1->A1_NROPAG)

MsUnLock()

//��������������������������������������������������������������Ŀ
//� Gera Movimentacao Bancaria.                                  �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis p/ Localizacao da Sequencia da Baixa.              �
//����������������������������������������������������������������
aTipoBx    := { "CHP", "BA", "CL" }
nSequencia := 0

//��������������������������������������������������������������Ŀ
//� Localiza a Sequencia da Baixa.                               �
//����������������������������������������������������������������
For nB := 1 To Len(aTipoBx)
	dbSelectArea("SE5")
   dbSetOrder(2)
	dbSeek(xFilial() + aTipoBx[nB] + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)

	While SE5->E5_FILIAL  == xFilial()       .And. SE5->E5_TIPODOC == aTipoBx[nB] .And.;
			SE5->E5_PREFIXO == SE1->E1_PREFIXO .And. SE5->E5_NUMERO  == SE1->E1_NUM   .And.;
			SE5->E5_PARCELA == SE1->E1_PARCELA .And. SE5->E5_TIPO    == SE1->E1_TIPO  .And. !Eof()
		nSequencia := Max( Val(SE5->E5_SEQ), nSequencia)

		dbSkip()
	End
Next nB

nSequencia := nSequencia + 1

//��������������������������������������������������������������Ŀ
//� Atualiza a Movimentacao Bancaria.                            �
//����������������������������������������������������������������
dbSelectArea("SE5")
RecLock("SE5", .T.)

SE5->E5_FILIAL  := xFilial()
SE5->E5_DATA    := SE1->E1_BAIXA
SE5->E5_TIPO    := SE1->E1_TIPO
SE5->E5_VALOR   := nVlrAbat + nFrete
SE5->E5_NATUREZ := SE1->E1_NATUREZ
SE5->E5_RECPAG  := "R"
SE5->E5_BENEF   := SE1->E1_NOMCLI
SE5->E5_HISTOR  := "Devolucao de Venda (Carga "+DAK->DAK_COD+")"
SE5->E5_TIPODOC := "BA"   // "VL"
SE5->E5_VLMOED2 := nVlrAbat + nFrete
SE5->E5_LA      := "N"
SE5->E5_PREFIXO := SE1->E1_PREFIXO
SE5->E5_NUMERO  := SE1->E1_NUM
SE5->E5_PARCELA := SE1->E1_PARCELA
SE5->E5_CLIFOR  := SE1->E1_CLIENTE
SE5->E5_LOJA    := SE1->E1_LOJA
SE5->E5_DTDIGIT := DAK->DAK_DTACCA										//dDataBase
SE5->E5_DTDISPO := DAK->DAK_DTACCA										//dDataBase
SE5->E5_MOTBX   := "DEV"
SE5->E5_SEQ     := StrZero(nSequencia, 2)

MsUnLock()

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D410C6Prd� Autor � Henry Fila            � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � C6_PRODUTO                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D410C6Prd()
Local nIdxOk :=SF4->(IndexOrd())
Local cAlias := Alias()
Local nReg   := Recno()

Local nPosProd   := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PRODUTO"})
Local nPosPrcVen := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PRCVEN"})
Local nPosPrcUni := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PRUNIT"})
Local nPosTpMov  := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_TPMOV"})
Local nQtEmb     := Ascan(aHeader,{|x|AllTrim(x[2])  == "C6_QTEMB"})
Local nUnsVe     := Ascan(aHeader,{|x|AllTrim(x[2])  == "C6_UNSVEN"})
Local nValor     := Ascan(aHeader,{|x|AllTrim(x[2])  == "C6_VALOR"})
Local nPosDesc   := Ascan(aHeader,{|x|AllTrim(x[2])  == "C6_DESCONT"})
Local cCampo     := ReadVar()
Local nDesconto  := 0

//���������������������������������������������������������Ŀ
//�Verifica se o parametro de Tabela Relacionada esta ativo.�
//�����������������������������������������������������������

If !(SB1->(EOF()))


	If cCampo == "M->C6_PRODUTO"

		dbSelectArea("DA1")
		dbSetOrder(1)
		If dbSeek(xFilial("DA1")+M->C5_TABELA+M->C6_PRODUTO)
	
		
			//����������������������������������������������Ŀ
			//�Atualiza variaveis no aCols do pedido de venda�
			//������������������������������������������������
	
			If nPosPrcVen > 0
				aCols[n][nPosPrcVen]   := DA1->DA1_PRCVEN
			Endif
			If nPosPrcUni > 0
				aCols[n][nPosPrcUni]   := DA1->DA1_PRCVEN
			Endif
		
			If nPosTpMov > 0
				aCols[n][nPosTpMov] := M->C5_TPMOV
			Endif			       
			
			SF4->(DbSetOrder(nIdxOk))
			
		Endif			
	ElseIf cCampo =="M->C6_QTDVEN"

		dbSelectArea("DA1")
		dbSetOrder(1)
		If dbSeek(xFilial("DA1")+M->C5_TABELA+aCols[n][nPosProd])
	
			While !Eof() .And. ( DA1_FILIAL+DA1_CODTAB+DA1_CODPRO == xFilial("DA1")+M->C5_TABELA+aCols[n][nPosProd] )
					
				//����������������������������������������������
				//�Busca o preco correspondente a qtde digitada�
				//����������������������������������������������
				
				If M->C6_QTDVEN <= DA1_QTDLOT
					aCols[n][nPosPrcVen]   := DA1->DA1_PRCVEN
					aCols[n][nPosPrcUni]   := DA1->DA1_PRCVEN
					Exit
				Endif					
			
				dbSelectarea("DA1")		
				dbSkip()
				Loop				
				
			Enddo	

			//����������������������������������������������������������Ŀ
			//�Converto para 3 unidade de medida se o campo estiver ativo�
			//������������������������������������������������������������
		
			SB1->(DbSetOrder(1))
			If	SB1->(DbSeek(xFilial("SB1")+aCols[n][nPosProd]))
				If nQtEmb > 0
					aCols[n,nQtEmb] := FUnitoEmb(M->C6_QTDVEN)
				Endif		
			EndIf

			//��������������������Ŀ
			//�Atualiza valor total�
			//����������������������
	
			aCols[n,nValor] := M->C6_QTDVEN*aCols[n,nPosPrcVen]
			
		Endif
						
	Endif
	
Endif

//�������������������������Ŀ
//�Restaura posicao da base �
//���������������������������

dbSelectarea(cAlias)
dbGoto(nReg)
	
Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D630Bonif | Autor � Silvio Cazela         � Data �04.04.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verificacao de Verba Para Bonificacao                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���Revis�o	 � 													  � Data �			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D630Bonif()
Local lRet   := .t.
Local cTpTes := Posicione("SF4",1,xFilial("SF4")+aCols[n][Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_TES"})],"F4_TPMOV")
Local cVerba := Upper(AllTrim(GetMv("MV_VERBABN")))
Local nVerba := 0
Local nValor := aCols[n][Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_VALOR"})]


If GetNewPar("MV_VERBABN","N") == "S" .and. ;// Verba de Bonificacao Ativada
	GetNewPar("MV_FATDIST","N") == "S" .and. ;// Apenas quando utilizado pelo modulo de Distribuicao
	cTpTes == "B"

	DbSelectArea("DB6")
	DbSetOrder(3)
	DbGoTop()
	While !eof()
		If DToS(DB6->DB6_DATAI) <= DToS(ddatabase) .and. DtoS(DB6->DB6_DATAF) >= DtoS(ddatabase)
			nVerba := DB6->DB6_SALDO
			Exit
		Endif
		DbSkip()
	End
	
	If nValor > nVerba
		lRet := .f.
		Help(" ",1,"VERBABNINS")
	Endif

Endif

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D020CODCID� Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� E1DISA02 �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � A1_CODCID                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D030CodCid()
Local nIdxOk:=DAS->(IndexOrd())
DAS->(DbSetOrder(2))
If	DAS->(DbSeek(xFilial("DAS")+M->A1_CODCID))
	M->A1_MUN := DAS->DAS_CIDADE
	M->A1_EST := DAS->DAS_SIGLA
EndIf
DAS->(DbSetOrder(nIdxOk))
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D030NOME � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� E1DISA04 �                                                   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � A1_NOME                                                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D030Nome()
If	Empty(M->A1_NREDUZ)
	M->A1_NREDUZ := Left(M->A1_NOME,20)
EndIf
Return(.T.)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D010Desc � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o ����
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � B1_DESC                                                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D010Desc()
SX3->(DbSetOrder(2))
SX3->(DbSeek("B1_VM_P"))
If	X3USO(SX3->X3_USADO)
	M->B1_VM_P := M->B1_DESC
	M->B1_VM_GI:= M->B1_DESC
EndIf
SX3->(DbSetOrder(1))
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �D100DELETA�Autor  �Henry Fila          � Data �  05/09/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Chacagem para exclusao de Nota de Entrada. Tem a mesma     ���
���          � funcionalidade que o P.E. A100Del                          ���
�������������������������������������������������������������������������͹��
���Uso       � Distribuicao (Chamada no MATA100 - Exclusao)               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function  D100Deleta()

Local lRet := .T.

//���������������������������������������������������������Ŀ
//�Verifica se existe uma carga nesta nota, caso exista nao �
//�deixa excluir.                                           �
//�����������������������������������������������������������

If !Empty(SF1->F1_CARGAGE)
	Help(" ",1,"DS100NEXCL")
	lRet := .F.
Endif
			 
Return(lRet) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � DisxPesq � Autor � Robson Alves     	  � Data � 24/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisas genericas em arquivos filtrados.                 ���
���			 � 																			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DisxPesq(aOrdens, bCond )		                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 																			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � DISTRIBUICAO      													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DisxPesq( aOrd , bCond )

*����������������������������������������������������������������������Ŀ
*� Define variaveis Locais especificas desta funcao.                    �
*������������������������������������������������������������������������
Local nReg, oDlg, nOpca:=0, bSav12 := SetKey(VK_F12)
Local oCbx,nQtdInd
Local nOpt1  := 1
Local cOrd	 := aOrd[1]
Local cCampo := Space(40)

*����������������������������������������������������������������������Ŀ
*�Salva a Integridade dos Dados														�
*������������������������������������������������������������������������
Local cAlias := Alias()
Local nOrder := IndexOrd()

SetKey(VK_F12,{||NIL})

*����������������������������������������������������������������������Ŀ
*� Obtem o numero de indices abertos do alias corrente.             		�
*������������������������������������������������������������������������
SIX->(DbSeek(cAlias+"Z",.T.))
SIX->(DbSkip(-1))
If SIX->INDICE != cAlias
	nQtdInd := 0
Else
	nQtdInd := Val(SIX->ORDEM)
EndIf

*����������������������������������������������������������������������Ŀ
*� Obtem o indice corrente.                                       		�
*������������������������������������������������������������������������
If IndexOrd() >= Len(aOrd)
	cOrd	:= aOrd[Len(aOrd)]
	nOpt1 := Len(aOrd)
ElseIf IndexOrd() <= 1
	cOrd := aOrd[1]
	nOpt1 := 1
Else
	cOrd	:= aOrd[IndexOrd()]
	nOpt1 := IndexOrd()
EndIf

*����������������������������������������������������������������������Ŀ
*� Define Dialog.                                                 		�
*������������������������������������������������������������������������
DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE "Pesquisa"

	@ 0.6,1.3 COMBOBOX oCBX VAR cOrd ITEMS aOrd	SIZE 165,44  ON CHANGE (nOpt1:=oCbx:nAt)	OF oDlg FONT oDlg:oFont
	@ 2.1,1.3 MSGET cCampo SIZE 165,10

	DEFINE SBUTTON FROM 055,122	TYPE 1 ACTION ( nOpca := 1  ,oDlg:End() ) ENABLE OF oDlg
	DEFINE SBUTTON FROM 055,149.1 TYPE 2 ACTION ( oDlg  :End() ) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

*����������������������������������������������������������������������Ŀ
*� Pesquisa cancelada.                                             		�
*������������������������������������������������������������������������
If nOpca == 0
	SetKey(VK_F12,bSav12)
	Return 0
EndIf

nReg := RecNo()

dbSetOrder(nOpt1)

*����������������������������������������������������������������������Ŀ
*� Se for usado na chave DTOC/DTOS e convertido para caracter.      		�
*������������������������������������������������������������������������
IF ( ("DTOS" $ Upper(IndexKey(nOpt1))) .Or. ("DTOC" $ Upper(IndexKey(nOpt1))) )
	cCampo := ConvData(IndexKey(nOpt1),cCampo)
Endif

lWhile := .T.

DbSeek(xFilial()+AllTrim(cCampo),.F.)
If Found() .AND. !EMPTY( bCond )
	While xFilial()+AllTrim(cCampo) == Subs(&(IndexKey()),1,Len(xFilial()+AllTrim(cCampo))) .AND. .NOT. Eof()
		
		If Eval(bCond)
			*����������������������������������������������������������������������Ŀ
			*� Restaura a Integridade dos Dados.          									�
			*������������������������������������������������������������������������
			dbSelectArea(cAlias)
			dbSetOrder(nOrder)
			
			Return 1
		End
		
		DbSkip()
	End
	lWhile := .F.
End

*����������������������������������������������������������������������Ŀ
*� Registro nao encontrado.                   									�
*������������������������������������������������������������������������
If Eof() .OR. !lWhile
	DbGoTo(nReg)
	Help(" ",1,"PESQ01")
EndIf

*����������������������������������������������������������������������Ŀ
*� Restaura a Integridade dos Dados.          									�
*������������������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(nOrder)

SetKey(VK_F12,bSav12)

Return 1

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   � D410ALOK � Autor � Waldemiro L. Lustosa  � Data � 22/07/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Ponto de Entrada na Altera��o de Pedidos de Venda            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Projetos     �19.05.00�      �Conversao PROTHEUS m410alok               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D410ALOK()

Local awArea := {}
Local lRt    := .T.
Local wi     := 0
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SC9")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSetOrder(1)

If dbSeek(xFilial()+SC5->C5_NUM)
   While !Eof() .And. C9_FILIAL+C9_PEDIDO == xFilial()+SC5->C5_NUM
      If !Empty(C9_CARGA)
         Help(" ",1,"DS410ALOK")
         lRt := .F.
         Exit
      EndIf
      dbSkip()
   End
EndIf

For wi := Len(awArea) to 1 Step -1
   dbSelectArea(awArea[wi][1])
   dbSetOrder(awArea[wi][2])
   If Recno() != awArea[wi][3]
      dbGoto(awArea[wi][3])
   EndIf
Next wi

Return(lRt)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   � DS520VLD � Autor �Octavio Moreira Batista� Data � 14/07/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Ponto de Entrada na Exclusao da NF de Saida para validacao   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Solicit. �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Objetivos� Verificar se a nota fiscal posicionada ainda nao sofreu acer-���
���          � to de carga. Nesse caso, nao e possivel mais cancelar-se a   ���
���          � nota fiscal em questao.                                      ���
���������������������������������������������������������������������������Ĵ��
��� Observ.  �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Projetos     �19.05.00�      �Conversao PROTHEUS MS520VLD               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DS520VLD()
//��������������������������������������������������������������Ŀ
//� Guarda registro original                                     �
//����������������������������������������������������������������
Local cAlias   := Alias()
Local nOrder   := IndexOrd()
Local nRecno   := Recno()
Local lRet     := .t.
//��������������������������������������������������������������Ŀ
//� Faz a consistencia da nota quanto ao acerto de cargas        �
//����������������������������������������������������������������
If !Empty(SF2->F2_CARGA) .And. SF2->F2_ACERTOK == "S"
   Help(" ",1,"DS520VLD")
   lRet := .f.
EndIf

//��������������������������������������������������������������Ŀ
//� Retorna ao registro original                                 �
//����������������������������������������������������������������
dbSelectArea(cALIAS)
dbSetOrder(nOrder)
dbGoto(nRecno)

Return(lRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 � Ds100SD1I� Autor � Karla Leite Fonseca   � Data � 09.09.1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Ponto Entrada - Gravacao do SB8 - Conta Contabil             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (ANTARCTICA)                                      ���
���������������������������������������������������������������������������Ĵ��
��� Solicit. �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Objetivos�A partir da Origem do Movimento/Local Padrao direciona contas ���
���          �de estoque e custo (Tabela D3).                               ���
���������������������������������������������������������������������������Ĵ��
��� Observ.  �Este tratamento e necessario nas movimentacoes de saida para  ���
���          �diferenciar CFO e Contabil  de produtos Filial,Matriz e Terc. ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Waldemiro    �26/07/99�      �Adequa��o para tratamento de segunda      ���
���              �        �      �embalagem e corre��es.                    ���
���������������������������������������������������������������������������Ĵ��
��� Projetos     �19/05/00�      �Conversao PROTHEUS SD1100I                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DS100SD1I()
//��������������������������������������������������������������Ŀ
//� Guarda registro original                                     �
//����������������������������������������������������������������
Local cAlias   := Alias()			
Local nOrder   := IndexOrd()
Local nRecno   := Recno()
Local c100Vasil,n100Quant
//���������������������������������������������������Ŀ
//� Gera Controle de Embalagem (Poder Terceiros SB6)  �
//�����������������������������������������������������
IF SF1->F1_TIPO $ 'NBD' .AND. SF4->F4_CONTEMB == "S"

   IF SB1->(FieldPos("B1_CONTEMB")) .And. SB1->B1_CONTEMB == "S"

      c100Vasil := SB1->B1_CODEMBA
      n100Quant := SD1->D1_QUANT
      D100GerSB6(c100Vasil,n100Quant)

   ENDIF

   IF SB1->(FieldPos("B1_CONTEM2")) > 0 .And. SB1->B1_CONTEM2 == "S"

      c100Vasil := SB1->B1_CODEMB2
      n100Quant := Int( SD1->D1_QUANT / SB1->B1_UNI2EMB ) + IIf( SD1->D1_QUANT % SB1->B1_UNI2EMB > 0, 1, 0 )
      D100GerSB6(c100Vasil,n100Quant)

   ENDIF

ENDIF


//��������������������������������������������������������������Ŀ
//� Retorna ao registro original                                 �
//����������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRECNO)
Return(.T.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �D100GerSB6� Autor � Robson Alves          � Data � 13/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.�FGeraSB6  � Autor � Waldemiro L. Lustosa  � Data � 26/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera SB6.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function D100GerSB6(c100Vasil,n100Quant)

Local awArea := {}
Local nI     := 0

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SB1")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SB6")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SD2")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SD3")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("DAI")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SB2")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )

//���������������������������������������������������Ŀ
//� Pesquisa o Arquivo SB1 (Cadastro de Produtos) p/  �
//� obter os dados da Embalagem.                      �
//�����������������������������������������������������
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial() + c100Vasil)

dbSelectArea("SB6")
RecLock("SB6",.T.)
SB6->B6_FILIAL    := SD1->D1_FILIAL
SB6->B6_CLIFOR    := SD1->D1_FORNECE
SB6->B6_LOJA      := SD1->D1_LOJA
SB6->B6_PRODUTO   := c100Vasil
SB6->B6_LOCAL     := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
SB6->B6_PRUNIT    := RetFldProd(SB1->B1_COD,"B1_CUSTD")
SB6->B6_DOC       := SD1->D1_DOC
//SB6->B6_SERIE     := SD1->D1_SERIE
SerieNfId ("SB6",1,"B6_SERIE",,,,SD1->D1_SERIE)
SB6->B6_EMISSAO   := SD1->D1_EMISSAO
SB6->B6_DTDIGIT   := SD1->D1_EMISSAO
SB6->B6_QUANT     := n100Quant
SB6->B6_SALDO     := n100Quant
SB6->B6_UM        := SB1->B1_UM
SB6->B6_SEGUM     := SB1->B1_SEGUM
If !Empty(SB1->B1_CONV)
   If SB1->B1_TIPCONV == "M"
      SB6->B6_QTSEGUM := n100Quant * SB1->B1_CONV
   Else
      SB6->B6_QTSEGUM := n100Quant / SB1->B1_CONV
   EndIf
EndIf
SB6->B6_ORIGLAN := "NE"
IF SF1->F1_TIPO == "N"
   SB6->B6_TIPO   := "E"
   SB6->B6_TPCF   := "F"
   SB6->B6_PODER3 := "D"
   SB6->B6_IDENT  := SD1->D1_NUMSEQ
   SB6->B6_TES    := GetMV("MV_TES"+SB6->B6_TIPO+SB6->B6_PODER3)

   //���������������������������������������������������Ŀ
   //� Grava Identificador em SD1                        �
   //�����������������������������������������������������
   dbSelectArea("SD1")
   RecLock("SD1",.F.)
   SD1->D1_IDENTB6 := SB6->B6_IDENT
ELSE
   SB6->B6_TIPO   := "D"
   SB6->B6_TPCF   := "C"
   SB6->B6_PODER3 := "R"
   SB6->B6_IDENT  := SD1->D1_IDENTB6
   SB6->B6_TES    := GetMV("MV_TES"+SB6->B6_TIPO+SB6->B6_PODER3)

   //���������������������������������������������������Ŀ
   //� Grava IdentB6 da Nota Original                    �
   //�����������������������������������������������������
   dbSelectArea("SD2")
   dbSetOrder(3)
   dbSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD)
   IF !EOF()
      dbSelectArea("SD1")
      RecLock("SD1",.F.)
      SD1->D1_IDENTB6 := SD2->D2_IDENTB6
   ENDIF

   dbSelectarea("SB6")
   SB6->B6_IDENT := SD2->D2_IDENTB6

   //���������������������������������������������������Ŀ
   //� Busca Informacoes da Carga                        �
   //�����������������������������������������������������
   dbSelectArea("DAI")
   dbSetOrder(3)
   dbSeek(XFILIAL()+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA)
   IF !EOF()            
		If SB6->(FieldPos("B6_CARGA")) > 0										
    	  RecLock("SB6",.F.)
	      SB6->B6_CARGA  := DAI->DAI_COD
	   ENDIF
	Endif	   
ENDIF

//���������������������������������������������������Ŀ
//� Atualiza Saldo em Poder de Terceiros              �
//�����������������������������������������������������
dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(XFILIAL()+c100Vasil+SD1->D1_LOCAL)
   RecLock("SB2",.F.)
Else
   CriaSB2(c100Vasil,SD1->D1_LOCAL)
EndIf
IF SB6->B6_TIPO == "E"
   SB2->B2_QNPT := SB2->B2_QNPT - n100Quant
ELSE
   SB2->B2_QTNP := SB2->B2_QTNP + n100Quant
ENDIF
IF SF1->F1_TIPO <> "N"
   dbSelectArea("SB6")
   dbSetOrder(3)
   dbSeek(XFILIAL()+SB6->B6_IDENT+SB6->B6_PRODUTO+"R")
   IF !EOF()
      RecLock("SB6",.F.)
      SB6->B6_SALDO := SB6->B6_SALDO - n100Quant
      SB6->B6_UENT  := SD1->D1_EMISSAO
      IF SB6->B6_SALDO <= 0
         SB6->B6_ATEND := "S"
      ELSE
         SB6->B6_ATEND := "N"
      ENDIF
   ENDIF

   //���������������������������������������������������Ŀ
   //� Obtem os 05 Custos Medios atuais.                 �
   //�����������������������������������������������������
   aCustoMed := PegaCMAtu(SD1->D1_COD, SD1->D1_LOCAL)

   //���������������������������������������������������Ŀ
   //� Grava no Arquivo SD3 (Movimentacoes Internas) um  �
   //� Registro DE0 (Devolucao).                         �
   //�����������������������������������������������������
   dbSelectArea("SD3")
   RecLock("SD3", .T.)

   SD3->D3_FILIAL  := xFilial()
   SD3->D3_TM      := "999"
   SD3->D3_COD     := SB6->B6_PRODUTO
   SD3->D3_UM      := SB1->B1_UM
   SD3->D3_LOCAL   := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
   SD3->D3_EMISSAO := dDataBase
   SD3->D3_DOC     := SD1->D1_DOC
   SD3->D3_QUANT   := n100Quant
   SD3->D3_CF      := "DE0"
   SD3->D3_GRUPO   := SB1->B1_GRUPO
   SD3->D3_PARCTOT := SB6->B6_ATEND
   SD3->D3_NUMSEQ  := SB6->B6_IDENT
   SD3->D3_SEGUM   := SB1->B1_SEGUM
   SD3->D3_TIPO    := "PA"
   SD3->D3_CUSTO1  := aCustoMed[1]
   SD3->D3_CUSTO2  := aCustoMed[2]
   SD3->D3_CUSTO3  := aCustoMed[3]
   SD3->D3_CUSTO4  := aCustoMed[4]
   SD3->D3_CUSTO5  := aCustoMed[5]
   MsUnLock()

   //���������������������������������������������������Ŀ
   //� Grava no Arquivo SB2 os 05 Custos Medios.         �
   //�����������������������������������������������������
   B2AtuComD3(aCustoMed, SD1->D1_LOCAL)
ENDIF

For nI := Len(awArea) to 1 Step -1
   dbSelectArea(awArea[nI][1])
   dbSetOrder(awArea[nI][2])
   If Recno() != awArea[nI][3]
      dbGoto(awArea[nI][3])
   EndIf
Next nI

Return NIL
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 �ConvQtde  � Autor � Robson Alves          � Data � 08.06.2000 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Fun��o de Convers�o - Quantidade em duzias/Quantidade em Hec-���
���			 � tolitros.      															 ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Especifico (DISTRIBUIDORES)											 ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � ConvQtde(ExpN1,ExpC1,ExpC1)											 ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� ExpN1 - Quantidade em Unidades										 ���
���			 � ExpC1 - C�digo do Produto a ser pesquisado.						 ���
���			 � ExpC2 - Tipo de conversao p/ D = Duzias/H = Hectolitros. 	 ���
���������������������������������������������������������������������������Ĵ��
��� Retorno  � ExpN2 - Quantidade em duzias/Hectolitros              		 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao									� Responsavel �	Data	 ���
���������������������������������������������������������������������������Ĵ��
���																�				  �	/	/	 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ConvQtde(nQtde, cCodProd, cTipConv)

//�����������������������������������������������������������������Ŀ
//� Salva o ambiente em uso.                                        �
//�������������������������������������������������������������������
Local aAmb := { Alias(), IndexOrd() }
Local nRet := 0
cTipConv   := Upper(cTipConv)

//�����������������������������������������������������������������Ŀ
//� Verifica se quantidade foi informada.                           �
//�������������������������������������������������������������������
If ValType(nQtde) == "N" .And. nQtde > 0
	//�����������������������������������������������������������������Ŀ
	//� Verifica se produto informado esta em branco.                   �
	//�������������������������������������������������������������������
	If ValType(cCodProd) == "C" .And. Empty(cCodProd)
		Aviso("Atencao","Produto n�o informado",{"OK"}) // Produto n�o informado
	Else
		//�����������������������������������������������������������������Ŀ
		//� Verifica se tipo de conversao nao informado,ou se esta diferente�
		//� de D = Duzias/H = Hectolitros.                                  �
		//�������������������������������������������������������������������
		If ValType(cTipConv) == "U" .Or. !( cTipConv $ "C/H" )
			Aviso("Atencao","Informe o tipo de conversao( C=Unid.Controle/H=Hectolitros )",{"OK"})
		Else
			//�����������������������������������������������������������������Ŀ
			//� Posiciona o produto caso ele tenha sido informado.              �
			//�������������������������������������������������������������������
			dbSelectArea("SB1")
			dbSetOrder(1)

			If !Empty(cCodProd)
				dbSeek(xFilial("SB1") + cCodProd )
			EndIf			
      	
			//�����������������������������������������������������������������Ŀ
			//� Converte de quantidade para unidade de controle                 �
			//�������������������������������������������������������������������
			
			nUndFtr := Getmv("MV_FTRCONT")
			
			If cTipConv == "C"
				If SB1->B1_CONVDUZ == 0		
					nRet := nQtde / nUndFtr
			   Else
					nRet := nQtde * SB1->B1_CONVDUZ
			   EndIf
			//�����������������������������������������������������������������Ŀ
			//� Converte de quantidade para hectolitros.                        �
			//�������������������������������������������������������������������
			ElseIf cTipConv == "H"
				If SB1->B1_TIPCONV == "M"
					nRet := nQtde * SB1->B1_CONV
				Else
					nRet := nQtde / SB1->B1_CONV
				EndIf
			EndIf
		EndIf
	EndIf
Else
	Aviso("Atencao","Quantidade nao informada",{"OK"})
EndIf
//�����������������������������������������������������������������Ŀ
//� Restaura o ambiente em uso.                                     �
//�������������������������������������������������������������������
dbSelectArea(aAmb[1])
dbSetOrder(aAmb[2])

Return( nRet )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �D010CODBAS� Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o ����
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � B1_CODBAS                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D010CODBAS()
Local nIdxOk:=DAJ->(IndexOrd())

DAJ->(DbSetOrder(1))
If	DAJ->(DbSeek(xFilial("DAJ")+M->B1_CODBAS))
	If SB1->(FieldPos("B1_CODGRP")) > 0
		M->B1_CODGRP := DAJ->DAJ_CODGRP
	Endif		
	M->B1_CODCAT := DAJ->DAJ_CODCAT
	M->B1_CODMAR := DAJ->DAJ_CODMAR
	M->B1_CODEMB := DAJ->DAJ_CODEMB
	M->B1_CAPNOM := DAJ->DAJ_CAPNOM
	M->B1_CAPREA := DAJ->DAJ_CAPREA
	M->B1_PESO   := DAJ->DAJ_PESO
	M->B1_PESBRU := DAJ->DAJ_PESBRU
	M->B1_GRUPO  := SUBSTR(M->B1_CODGRP,5,2)+SUBSTR(M->B1_CODEMB,5,2)
EndIf
DAJ->(DbSetOrder(nIdxOk))
Return(.T.)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DC7VCALC � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o ����
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � C7_VCALC                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DC7VCALC()
Local nIdxOk:=SB1->(IndexOrd())
SB1->(DbSetOrder(1))
If	SB1->(DbSeek(xFilial("SB1")+M->C7_PRODUTO))
	M->C7_PRECO := Iif(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),ROUND(M->C7_VCALC/SB1->B1_QTDUPAD,6),M->C7_VCALC)
EndIf
M->C7_TOTAL := M->C7_PRECO*M->C7_QUANT
SB1->(DbSetOrder(nIdxOk))
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D225COD  � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� E1DISA06 �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � B2_COD                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D225COD()
Local nIdxOk:=SB1->(IndexOrd())

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

SX3->(DbSetOrder(2))
SB1->(DbSetOrder(1))
If	SB1->(DbSeek(XFILIAL("SB1")+M->B2_COD))
	SX3->(DbSeek("B2_TERUM"))
	If	X3USO(SX3->X3_USADO)
		M->B2_TERUM   := SB1->B1_TERUM
	EndIf
	SX3->(DbSeek("B2_QTDUPAD"))
	If	X3USO(SX3->X3_USADO)
		M->B2_QTDUPAD := SB1->B1_QTDUPAD
	EndIf
	M->B2_LOCAL   := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
EndIf
SB1->(DbSetOrder(nIdxOk))
Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Fun��o   � D460SF2  � Autor � Waldemiro L. Lustosa  � Data � 01/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� D460SF2  �                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Ponto de Entrada na Grava��o do SF2 (MATA460)                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Revis�o  � Jesus Pedro                              � Data � 16/07/1999 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function D460SF2()

Local aWArea := {}
Local nC     := 0

//��������������������������������������������������������������Ŀ
//� Define variaveis proprias da rotina                          �
//����������������������������������������������������������������
lF3     := .F.
cCFPQ   := "573" // - Venda de Produtos de Terceiros

//��������������������������������������������������������������Ŀ
//� Salva o posicionamento original das areas                    �
//����������������������������������������������������������������
awArea := {}
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("DA5")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("DA7")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSelectArea("SD2")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSetOrder(3) // DOC+SERIE+CLIENTE+LOJA+DOC
dbSelectArea("SE1")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )
dbSetOrder(2) // CLIENTE+LOJA+PREFIXO+DOC
dbSelectArea("SF3")
Aadd( awArea, { Alias(), IndexOrd(), Recno() } )

//��������������������������������������������������������������Ŀ
//� Atualiza DAK (posicionado no A460GRAV), DAI e SF2            �
//����������������������������������������������������������������
dbSelectArea("DAK")
dbSetOrder(1)
If dbSeek(xFilial("DAK")+SC9->C9_CARGA) .And. !Empty(DAK->DAK_COD)

   dbSelectArea("DAI")

   If Found() .And. DAI_FILIAL+DAI_COD == xFilial("DAI")+DAK->DAK_COD
      RecLock("DAI",.F.)
      DAI->DAI_NFISCA := SF2->F2_DOC
      //DAI->DAI_SERIE  := SF2->F2_SERIE
	  SerieNfId("DAI",1,"DAI_SERIE",,,,SF2->F2_SERIE)
      MsUnLock()
      dbSelectArea("DAK")
      RecLock("DAK",.F.)
      DAK->DAK_FEZNF := "S"
      MsUnLock()
      dbSelectArea("SF2")
      RecLock("SF2",.F.)
      SF2->F2_CARGA := DAI->DAI_COD+DAI->DAI_SEQUEN
      MsUnLock()
   EndIf
EndIf

dbSelectarea("SE1")
DbSetOrder(1)
If dbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC)

	While !Eof() .And. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == ;
				xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC

		RecLock("SE1",.f.)
		If SE1->(FieldPos("E1_FORMAPG") > 0 )
			SE1->E1_FORMAPG := SC5->C5_FORMAPG
		Endif
		If SE1->(FieldPos("E1_CARGA") > 0 )		
			SE1->E1_CARGA   := SubStr(SF2->F2_CARGA,1,6)
		Endif	      
		
		If SE1->(FieldPos("E1_COND") > 0 )		
			SE1->E1_COND   := SF2->F2_COND
		Endif	      
		
		
		MsUnLock()
		dbSkip()
	Enddo		
	
Endif	

//��������������������������������������������������������������Ŀ
//� Atualiza o cadastro de clientes x rotas, caso haja percurso  �
//������������������������������������������������������Octavio���
dbSelectArea("DA7")
dbSetOrder(2)
dbSeek(xFilial("DA7")+SF2->F2_CLIENTE+SF2->F2_LOJA)

If Eof()
   dbSelectArea("DA5")
   dbSetOrder(2)
   dbSeek(xFilial("DA5")+SF2->F2_VEND1)

   If !Eof()
      dbSelectArea("DA7")
      Reclock("DA7",.t.)
      DA7->DA7_FILIAL  := xFilial("DA7")
      DA7->DA7_PERCUR  := DA5->DA5_COD
      DA7->DA7_ROTA    := "999999"
      DA7->DA7_SEQUEN  := "999999"
      DA7->DA7_CLIENT  := SF2->F2_CLIENTE
      DA7->DA7_LOJA    := SF2->F2_LOJA
      MsUnlock()
   EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Restaura as situacoes originais das areas                    �
//����������������������������������������������������������������
For nC := Len(awArea) to 1 Step -1
   dbSelectArea(awArea[nC][1])
   dbSetOrder(awArea[nC][2])
   If Recno() != awArea[nC][3]
      dbGoto(awArea[nC][3])
   EndIf
Next nC

Return( NIL )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DS460FRETE�Autor  �Henry Fila          � Data �  07/28/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula frete da tabela de precos do modulo de Distribuicao ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function DS460Frete(aRateio,nRotina)

Local nCount := 0

If nRotina == 2 //Se estiver chamando pelo MATA461
	For nCount := 1 to Len(aRateio)
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+aRateio[nCount][1]+aRateio[nCount][2]))
			aRateio[nCount][4] += SC6->C6_FRETE
			aRateio[nCount][5] += SC6->C6_SEGURO
			aRateio[nCount][6] += SC6->C6_DESPESA
		Endif
	Next
Else
Endif


Return(aRateio)	


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao	 � M460MSD2 � Autor � Andreia Marques       � Data � 07.08.1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� MSD2460  �                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Descricao� Ponto Entrada -na Nota Fiscal de Saida                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (ANTARCTICA)                                      ���
���������������������������������������������������������������������������Ĵ��
��� Solicit. �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Objetivos�Controle de Poder em Terceiros para Vasilhames                ���
���          �Identificar CFO com base na origem do produto.                ���
���������������������������������������������������������������������������Ĵ��
��� Observ.  �A diferenciacao da origem do produto depende do almoxarifado  ���
���          �do produto (Tabela D3)                                        ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao                           � Responsavel �   Data   ���
���������������������������������������������������������������������������Ĵ��
���                                                � Jesus Pedro � 15/07/99 ���
���������������������������������������������������������������������������Ĵ��
��� Uso de par�metros para defini��o da TES utili- � Waldemiro   � 23/07/99 ���
��� zada na Gera��o de dados no SB6.               �             �          ���
��� (s� para Embalagens)                           �             �          ���
���������������������������������������������������������������������������Ĵ��
��� Adequa��o ao tratamento da Segunda Embalagem e � Waldemiro   � 26/07/99 ���
��� Corre��es.                                     �             �          ���
���������������������������������������������������������������������������Ĵ��
��� Alteracao para utilizacao de contas  contabeis � Andreia     � 28/07/99 ���
��� ref. a Estoque/Custo/Receitas (em comentario)  �             �          ���
���������������������������������������������������������������������������Ĵ��
��� Corre��o de problema na Gera��o de Notas Fis-  � Waldemiro   � 12/08/99 ���
��� cais sem Carga, a Rotina estava gravando um    �             �          ���
��� n�mero de Carga no SD2 e no SB6 indiscrimina-  �             �          ���
��� damente.                                       �             �          ���
���������������������������������������������������������������������������Ĵ��
��� Corre��o no preenchimento de diversos campos   � Octavio     � 13/08/99 ���
��� no SB6 e nas atualizacoes do SB2               �             �          ���
���������������������������������������������������������������������������Ĵ��
��� Gravacao da Condicao de Pagamento              � Karla       � 23/09/99 ���
���������������������������������������������������������������������������Ĵ��
��� Grava o campo D2_FRETE quando existir          � Almir       � 28.11.99 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
*/
Function D460MSD2()

//��������������������������Ŀ
//� Guarda registro original �
//����������������������������
Local cAlias      := Alias()			
Local nOrder      := IndexOrd()
Local nRecno      := Recno()
Local c460Emb := ""
Local n460Quant := 0

Local cCargaOri := ""

//�������������������������������������������������������������Ŀ
//� Grava Cond. Pagamento para utilizacao nas regras contabeis, �
//� e o valor do frete/carreto contido na tabela de pre�o.      �
//���������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("D2_FRETE")
If !Eof()
	dbSelectArea("DA1")
	dbSetOrder(1)
	dbSeek(xFilial("DA1")+SC5->C5_TABELA+SC6->C6_PRODUTO)

	If !Empty(DA1->DA1_FRETE)
		dbSelectArea("SD2")
		RecLock("SD2",.F.)
		SD2->D2_FRETE := Round((DA1->DA1_FRETE / If(!Empty(SB1->B1_QTDUPAD),SB1->B1_QTDUPAD,1)) * SD2->D2_QUANT,2)
		MsUnLock()
	EndIf
EndIf
dbSelectArea("SX3")
dbSetOrder(1)

// ���������������������������������������������������������������Ŀ
// � Detecto se esta Nota Fiscal faz parte em uma Carga atrav�s do �
// � posicionamento dos arquivos DAI e DAK atrav�s do Ponto de �����
// � Entrada A460GRAV.PRX ��������������������������������������
// ������������������������
// ����������������������������������������������������������������Ŀ
// � Note que eu n�o posso simplesmente buscar o c�digo da Carga no �
// � DAI a partir do n�mero do Pedido, pois o Siga e estas  Rotinas �
// � s�o muito flex�veis na Gera��o de Cargas/Notas a partir de Pe- �
// � didos atendidos parcialmente (esta busca n�o � confi�vel) ������
// �������������������������������������������������������������

dbSelectArea("SD2")
RecLock("SD2",.F.)
SD2->D2_COND   := SC5->C5_CONDPAG   
If SD2->(FieldPos("D2_TPBNQB")) > 0
	SD2->D2_TPBNQB := SC6->C6_TPBNQB   && Tipo Bonificacao/Quebra
Endif		
MsUnlock()

cCargaOri := Space(6)
dbSelectArea("DAI")
If Found() .And. DAK->DAK_COD == DAI->DAI_COD .And. DAI->DAI_PEDIDO == SC6->C6_NUM
   cCargaOri := DAI->DAI_COD
EndIf

//�������������������������������������������������������������Ŀ
//� Grava informacoes de IPI,QUANTIDADES,UNIDADE (SC6 para SD2) �
//���������������������������������������������������������������
dbSelectArea("SD2")				
RecLock("SD2",.F.)
SD2->D2_QTEMB := FUnitoEmb(SD2->D2_QUANT,SD2->D2_COD	 )// Qtde Embalagem
SD2->D2_PAUTA := SC6->C6_PAUTA		// Pauta IPI                 
If SD2->(FieldPos("D2_TERUM")) > 0 .And. SC6->(FieldPos("C6_TERUM"))
	SD2->D2_TERUM := SC6->C6_TERUM		// Terceira Unidade de Medida
Endif	
SD2->D2_CARGA := cCargaOri

//��������������������������������������������������Ŀ
//� Gera Controle de Embalagem (Poder Terceiros SB6) �
//����������������������������������������������������
If SC5->C5_TIPO $ "NBD" .AND. SF4->F4_CONTEMB == "S"

   If SB1->(FieldPos("B1_CONTEMB")) .And. SB1->B1_CONTEMB == "S"

      c460Emb := SB1->B1_CODEMBA
      n460Quant := SD2->D2_QUANT
      Ds460Pod3(c460Emb,n460Quant,cCargaOri)

   EndIf

   If SB1->(FieldPos("B1_CODEMB2")) > 0 .And. SB1->B1_CONTEM2 == "S"
      c460Emb := SB1->B1_CODEMB2
      n460Quant := Int( SD2->D2_QUANT / SB1->B1_UNI2EMB ) + IIf( SD2->D2_QUANT % SB1->B1_UNI2EMB > 0, 1, 0 )
      Ds460Pod3(c460Emb,n460Quant,cCargaOri)
   EndIf

EndIf

dbSelectArea("SD2")
MsUnLock()

//������������������������������Ŀ
//� Retorna ao registro original �
//��������������������������������
dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoTo(nRecno)

Return(.T.)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DD1QTEMB � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o ����
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � D1_QTEMB                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DD1QTEMB()
Local nIdxOk:=SB1->(IndexOrd())
SB1->(DbSetOrder(1))
If	SB1->(DbSeek(xFilial("SB1")+M->D1_COD))
	M->D1_QUANT := Iif( SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD) , FEmbtoUni(M->D1_QTEMB) , M->D1_QUANT )
	M->D1_QTEMB := Iif( SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD) , FUnitoEmb(BuscaCols("D1_QUANT")) , M->D1_QTEMB )
EndIf
SB1->(DbSetOrder(nIdxOk))
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DC7QTEMB � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � C7_QTEMB                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DC7QTEMB()
Local nIdxOk:=SB1->(IndexOrd())
Local nNrPro:=aScan(aHeader,{|x|AllTrim(x[2])=="C7_PRODUTO"})
Local nNrQtd:=aScan(aHeader,{|x|AllTrim(x[2])=="C7_QUANT"})
SB1->(DbSetOrder(1))
If	SB1->(DbSeek(xFilial("SB1")+aCols[n][nNrPro]))
	M->C7_QUANT   := Iif(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FEmbtoUni(M->C7_QTEMB),M->C7_QUANT)
	M->C7_QTEMB   := Iif(SB1->(FieldPos("B1_QTDUPAD"))>0 .And. !Empty(SB1->B1_QTDUPAD),FUnitoEmb(BuscaCols("C7_QUANT")),M->C7_QTEMB)
	M->C7_QTSEGUM := aCols[n][nNrQtd]*SB1->B1_CONV
EndIf
M->C7_TOTAL   := M->C7_QUANT*M->C7_PRECO
SB1->(DbSetOrder(nIdxOk))
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DS160Grava� Autor �Andrea Marques Federson� Data � 22/06/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada na inclus�o do Pedido de Compras          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                     ���
�������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                   ���
�������������������������������������������������������������������������Ĵ��
��� Projetos     �19/05/00�      �Conversao PROTHEUS MTA160G              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DS160Grava()
//��������������������������������������������������������������Ŀ
//� Guarda registro original                                     �
//����������������������������������������������������������������
Local cALIAS   := ALIAS()			
Local nORDER   := INDEXORD()
Local nRECNO   := RECNO()

//��������������������������������������������������������������Ŀ
//� Grava informacoes de PRECO DA NF E UNIDADE (SC7)             �
//����������������������������������������������������������������
SC7->C7_TERUM   := SB1->B1_TERUM			// Terceira Unidade de Medida (DZ/CX)
SC7->C7_VCALC   := SC7->C7_PRECO			// Preco Unitario Calculado (Embalagem)

//��������������������������������������������������������������Ŀ
//� Retorna ao registro original                                 �
//����������������������������������������������������������������
DBSELECTAREA(cALIAS)
DBSETORDER(nORDER)
DbGoTo(nRECNO)
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � D410Tes  � Autor � Alex Egydio           � Data � 16/03/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o ����
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � C6_TES                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function D410Tes()
Local nIdxOk:=SF4->(IndexOrd())
Local nNrTes:=aScan(aHeader,{|x|Alltrim(x[2])=="C6_TES"})
Local nPauta:=aScan(aHeader,{|x|Alltrim(x[2])=="C6_PAUTA"})
SF4->(DbSetOrder(1))
If	SF4->(DbSeek(xFilial("SF4")+aCols[n][nNrTes]))
	aCols[n,nPauta]:=Iif(SF4->F4_PAUTA == "N",0,SB1->B1_VLR_IPI)
//	M->C6_TES   := ExecBlock("RESTA02",.f.,.f.)
EndIf
SF4->(DbSetOrder(nIdxOk))
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DVldConPg �Autor  �Henry Fila          � Data �  07/06/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca forma de pagto da condicao de pagamento              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
                               
Function DVldConPg()

Local lRet := .T.

//�������������������������������������������������Ŀ
//�Verifica se  condicao de pagamento e diferente da�
//�tabela de preco                                  �
//���������������������������������������������������

DA0->(dbSetOrder(1))
If DA0->(dbSeek(xFilial("DA0")+M->C5_TABELA))
	If !Empty(DA0->DA0_CONDPG) //Se nao for uma tabela generica 
		M->C5_CONDPAG := DA0->DA0_CONDPG
	Endif					
Endif		

//���������������������������������������������Ŀ
//�Coloca  a forma de pagamento padrao conforme �
//�a condicao de pagamento                      �
//�����������������������������������������������

If lRet
	SE4->(dbSetOrder(1))
	If	SE4->(dbSeek(xFilial("SE4")+M->C5_CONDPAG)).And. ValType(M->C5_FORMAPG) <> "U"
		M->C5_FORMAPG := SE4->E4_FORMA                      
		M->C5_ACRSFIN := SE4->E4_ACRSFIN
	Endif	
Endif	

Return(lRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � A333ACEROK   � Autor � Alex Egydio       � Data � 08/02/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o Campo E1_ACEROK.                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � A333ACEROK(ExpL1)                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 : .T. Grava data em branco, .F. Grava dDataBase        ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � DFATA333(),A333DupCred(),A333AtuTit(),A354Proc(),A355Proc()  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A333ACEROK(lLimpa)
Local nCntFor
For nCntFor := 1 To FCount()
	If	AllTrim(FieldName(nCntFor))=="E1_ACEROK"
		If	lLimpa
			SE1->E1_ACEROK := Ctod("")
		Else
			SE1->E1_ACEROK := dDataBase
   		EndIf
		Exit
	EndIf
Next
Return NIL
