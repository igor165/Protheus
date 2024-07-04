#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MATR325.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MATR325  บ Autor ณ 	Vendas Clientes  บ Data ณ  19/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Historico de alteracoes de preco.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs - Protheus                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function MATR325()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cPerg			:= "MATR325"    // Variavel utilizada para a exibicao das perguntas.
Local cDesc1        := STR0001      // Variavel para primeira linha de descri็ao  //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002      // Variavel para segunda linha de descri็ao   //"de hist๓rico de altera็๕es de pre็os."
Local cDesc3        := ""           // Variavel para terceira linha de descri็ao
Local cTitulo      	:= STR0003      // Titulo do relatorio   //"Relat๓rio de Hist๓rico de Altera็๕es de Pre็o"

Local nLin         	:= 80           // Tamanho maximo de linhas em um relatorio

Local cCabec1      	:= STR0004      // Cabecalho 1   //"  Grupo/Filiais   Data Alteracao     Hora Alteracao      Pre-Tabela       Grupo         Descricao 		Cod.Produto      Descricao             	Pre็o Vigente(altera็ใo)        Pre็o Estabelecido      "
Local cCabec2      	:= ""           // Cabecalho 2
Local aOrd 			:= {}           // Variavel utilizada pela funcao setprint
Local nCount1 		:= 0			// Variavel utilizada para laco no For
Local nCount2 		:= 0			// Variavel utilizada para laco no For
Local nCount3 		:= 0            // Variavel utilizada para laco no For
Local nLen    		:= 0            // Variavel utilizada para armazenar quantidade de itens de uma query
Local cAliasQry						// Variavel utilizada para guardar o nome da area que ira armazenar resultado de query
Local cAliasQry1					// Variavel utilizada para guardar o nome da area que ira armazenar resultado de query
      
Local cString   	:= ""           // Variavel utilizada pela funcao setprint
Local aAcvItens     := {}           // Array que contera itens filtrados na tabela ACV
Local aAcuCateg     := {}			// Array que contera itens filtrados na tabela ACU

Local cSAXQry                       // Variavel utilizada para guardar o nome da area que ira armazenar resultado de query
Local tamanho     	:= "G"          // Tamanho definido pela folha de impressao
Local nomeprog    	:= "MATR325"    // Nome do programa para impressao no cabecalho
Local nTipo       	:= 18			// Variavel utilizada pela funcao setprint

Local cFilACU       := xFilial("ACU")
Local cFilACV       := xFilial("ACV")

Private nLastKey    := 0			// Variavel utilizada pela funcao setprint
Private wnrel      	:= "MATR325"    // Nome do arquivo usado para impressao em disco
Private cbtxt       := Space(10)    // Variavel utilizada pela funcao cabec
Private cbcont      := 00		    // Variavel utilizada pela funcao cabec
Private CONTFL      := 01           // Variavel utilizada pela funcao cabec
Private m_pag       := 01           // Variavel utilizada pela funcao cabec

Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}  // Variavel utilizada pela funcao setprint

While .T.
	If !( Pergunte("MATR325",.T.) )
		MsgInfo(STR0005) 				//"Impressใo abortada."
		Return .F.
	Endif
	
	If !Empty(MV_PAR02) .and. !Empty(MV_PAR03)
    	MsgInfo(STR0010,STR0011) //"Informe apenas Categoria ou Produto nos filtros."###"Efetue novo acesso"
    Else
    	Exit
    EndIf
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

If !empty(MV_PAR02) .and. empty(MV_PAR03)
	// informou categoria e nao o produto
	cAliasQry   := GetNextAlias()
	cQry := "SELECT ACU.ACU_FILIAL, ACU.ACU_COD, ACU.ACU_DESC, ACU.ACU_CODPAI "
	cQry +=   "FROM " + RetSqlName("ACU") + " ACU "
    cQry +=  "WHERE ACU.ACU_FILIAL = '" + cFilACU + "' "
    cQry +=    "AND ACU.D_E_L_E_T_ = ' ' "
	cQry +=    "AND (ACU.ACU_COD = '" + AllTrim(MV_PAR02) + "' OR ACU.ACU_CODPAI = '" + AllTrim(MV_PAR02) + "')"
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cAliasQry, .F., .T.)
	While (cAliasQry)->(!Eof())
		Aadd(aAcuCateg,{(cAliasQry)->ACU_COD,(cAliasQry)->ACU_DESC})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	While nLen <> Len(aAcuCateg)
		nLen := Len(aAcuCateg)
		For nCount1 := 1 To nLen
			cAliasQry   := GetNextAlias()
			cQry := "SELECT ACU.ACU_FILIAL, ACU.ACU_COD, ACU.ACU_DESC, ACU.ACU_CODPAI "
			cQry +=   "FROM " + RetSqlName("ACU") + " ACU "
            cQry +=  "WHERE ACU.ACU_FILIAL = '" + cFilACU + "' "
            cQry +=    "AND ACU.D_E_L_E_T_ = ' ' "
			cQry +=    "AND ACU.ACU_CODPAI = '" + AllTrim(aAcuCateg[nCount1][1]) + "'"
			dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cAliasQry, .F., .T.)
			While (cAliasQry)->(!Eof())
				If !(nT := ascan(aAcuCateg,{|x| x[1]=(cAliasQry)->ACU_COD})) > 0
					Aadd(aAcuCateg,{(cAliasQry)->ACU_COD,(cAliasQry)->ACU_DESC})
				Endif
				(cAliasQry)->(DbSkip())
			Enddo
			(cAliasQry)->(DbCloseArea())
		Next nCount1
	Enddo
	
	For nCount2 := 1 To Len(aAcuCateg)
		cAliasQry1:= GetNextAlias()
		cQry := "SELECT ACV.ACV_FILIAL, ACV.ACV_CATEGO, ACV.ACV_GRUPO, ACV.ACV_CODPRO, ACV.ACV_REFGRD "
        cQry +=   "FROM " + RetSqlName("ACV") + " ACV "
		cQry +=  "WHERE ACV.ACV_FILIAL = '" + cFilACV + "' "
        cQry +=    "AND ACV.D_E_L_E_T_ = ' ' "
        cQry +=    "AND ACV.ACV_CATEGO = '" + AllTrim(aAcuCateg[nCount2][1]) + "'"
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cAliasQry1, .F., .T.)
		While (cAliasQry1)->(!Eof())
			If !(nT := ascan(aAcuCateg,{|x| x[1]=(cAliasQry1)->ACV_CODPRO})) > 0
				Aadd(aAcvItens,{(cAliasQry1)->ACV_CODPRO,(cAliasQry1)->ACV_CATEGO})
			Endif
			(cAliasQry1)->(DbSkip())
		Enddo
		(cAliasQry1)->(DbCloseArea())
	Next nCount2
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSAXQry := GetNextAlias()
cQry := "SELECT SAX.AX_FILIAL AXFILIAL, SAX.AX_CODIGO AXCODIGO, SAX.AX_DESCRI AXDESCRICAO, SAX.AX_DATAINI AXDATAINI, "
cQry +=        "SAX.AX_HORAINI AXHORAINI, SAX.AX_GRUPFIL AXGRUPFIL, SAX.AX_ATIVO AXATIVO, "
cQry +=        "SAY.AY_FILIAL AYFILIAL, SAY.AY_CODIGO AYCODIGO, SAY.AY_ITEM AYITEM, SAY.AY_PRODUTO AYPRODUTO, SAY.AY_PRCATU AYPRCATU, "
cQry +=        "SAY.AY_PRCSUG AYPRCSUG "
cQry +=   "FROM "+RetSqlName("SAX")+" SAX, "+RetSqlName("SAY")+" SAY "
cQry +=  "WHERE SAX.AX_FILIAL = '" + xFilial("SAX") + "' "
cQry +=    "AND SAX.AX_FILIAL = SAY.AY_FILIAL "
cQry +=    "AND SAX.AX_CODIGO = SAY.AY_CODIGO AND "
If !empty(MV_PAR01)
	cQry += "SAX.AX_GRUPFIL = '" + AllTrim(MV_PAR01) + "' AND "
Endif
If !empty(MV_PAR03)
	cQry += "SAY.AY_PRODUTO = '" + AllTrim(MV_PAR03) + "' AND "
ElseIf Len(aAcvItens) > 0
	cQry += "( "
	For nCount3:=1 To Len(aAcvItens)
		cQry += "SAY.AY_PRODUTO = '" + AllTrim(aAcvItens[nCount3][1]) + "' "
		If nCount3 < Len(aAcvItens)
			cQry += "OR "
		Endif
	Next nCount3
	cQry += ") AND "
Endif
If !empty(MV_PAR04)
	cQry += "SAX.AX_DATAINI = "+DTOS(MV_PAR04)+" AND "
Endif
cQry +=        "SAX.D_E_L_E_T_ = ' ' AND SAY.D_E_L_E_T_ = ' ' "
cQry +=  "ORDER BY SAX.AX_GRUPFIL, SAX.AX_FILIAL, SAX.AX_DATAINI, SAX.AX_HORAINI, SAX.AX_CODIGO "

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cSAXQry, .F., .T.) 

RptStatus({|| RunReport(cCabec1,cCabec2,cTitulo,nLin,cSAXQry,NomeProg,Tamanho,nTipo,aAcvItens,aAcuCateg) })
(cSAXQry)->(DbCloseArea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ  	Vendas Clientes  บ Data ณ  22/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Totvs                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(cCabec1,cCabec2,cTitulo,nLin,cSAXQry,NomeProg,Tamanho,nTipo,aAcvItens,aAcuCateg)

Local nCount        := 0         // Variavel utilizada no contador For
Local lRetCat       := .F.      // Variavel que verifica se foi encontrada Categoria do Produto
Local cFilACU       := ""
Local cFilACV       := ""
Local cFilSB1       := ""
Local cPctPRCATU    := ""
Local cPctPRCSUG    := ""

SetRegua(RecCount())

If (cSAXQry)->(! Eof())
    cFilACU       := xFilial("ACU")
    cFilACV       := xFilial("ACV")
    cFilSB1       := xFilial("SB1")
    cPctPRCATU    := PesqPict("SAY","AY_PRCATU")
    cPctPRCSUG    := PesqPict("SAY","AY_PRCSUG")
    ACU->(DbSetOrder(1))
    ACV->(DbSetOrder(5))
    While (cSAXQry)->(! Eof())
    	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    	//ณ Verifica o cancelamento pelo usuario...                             ณ
    	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    	If lAbortPrint
    		@nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
    		Exit
    	Endif
    	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    	//ณ Impressao do cabecalho do relatorio. . .                            ณ
    	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
    		nLin  := Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
    		nLin  += 2
    	Endif
    	@nLin,04 PSAY (cSAXQry)->AXGRUPFIL
    	@nLin,22 PSAY SubStr((cSAXQry)->AXDATAINI,7,2)+"/"+SubStr((cSAXQry)->AXDATAINI,5,2)+"/"+SubStr((cSAXQry)->AXDATAINI,1,4)
    	@nLin,40 PSAY (cSAXQry)->AXHORAINI
    	@nLin,60 PSAY (cSAXQry)->AXCODIGO
    	If !empty(MV_PAR02)
    		For nCount := 1 To Len(aAcvItens)
    			if (cSAXQry)->AYPRODUTO == aAcvItens[nCount][1]
    				If ACU->(DbSeek(cFilACU+aAcvItens[nCount][2]))
    					@nLin,74 PSAY AllTrim(ACU->ACU_COD)
    					@nLin,88 PSAY SubStr(AllTrim(ACU->ACU_DESC),1,20)
    					lRetCat := .F.
    					Exit
    				Endif
    			Endif
    		Next nCount
    	Else
    		If ACV->(DbSeek(cFilACV+(cSAXQry)->AYPRODUTO))
    			If ACU->(DbSeek(cFilACU+ACV->ACV_CATEGO))
    				@nLin,74 PSAY AllTrim(ACU->ACU_COD)
    				@nLin,88 PSAY SubStr(AllTrim(ACU->ACU_DESC),1,20)
    				lRetCat := .F.
    			Endif
    		Endif
    	Endif
    	If lRetCat
    		@nLin,88 PSAY STR0008 //"Nใo localizado."
    		lRetCat := .T.
    	Endif
    	@nLin,115 PSAY (cSAXQry)->AYPRODUTO
    	@nLin,132 PSAY Posicione("SB1", 1, cFilSB1 + (cSAXQry)->AYPRODUTO, "B1_DESC")
    	@nLin,166 PSAY STR0009+AllTrim(TransForm((cSAXQry)->AYPRCATU, cPctPRCATU) ) //"R$ "
    	@nLin,196 PSAY STR0009+AllTrim(TransForm((cSAXQry)->AYPRCSUG, cPctPRCSUG) ) //"R$ "
	    nLin++
    	(cSAXQry)->(DbSkip())
    Enddo
Else
	MsgInfo(STR0006) //"Filtro nใo realizado, verifique parโmetros."
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return