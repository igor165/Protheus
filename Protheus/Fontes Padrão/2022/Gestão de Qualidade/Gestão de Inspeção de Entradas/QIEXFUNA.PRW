#INCLUDE "PROTHEUS.CH"
#include "QIEXFUNA.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 ЁQIEXFUNA  Ё Autor Ё Paulo Emidio de BarrosЁ data Ё23/04/2001Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠                        '
╠╠ЁDescri┤└o ЁFuncoes genericas utilizadas na Integracao EST x QIE e movi-Ё╠╠
╠╠Ё			 Ёtacoes referentes ao Estoque.								  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё SIGAQIE													  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSTR 	     Ё Ultimo utilizado -> 00132                                  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁPaulo EmМdioЁ18/05/01ЁMETA  Ё Ordenada a ordem dos parametros nas fun- Ё╠╠
╠╠Ё            Ё        Ё      Ё coes a200CoIn() e a200SkLt().            Ё╠╠
╠╠ЁPaulo EmМdioЁ07/06/01ЁMETA  Ё Implementada parametrizacao, para que se-Ё╠╠
╠╠Ё            Ё        Ё      Ё jam definidos os Tipos de Notas Fiscais  Ё╠╠
╠╠Ё            Ё        Ё      Ё de Entradas a serem enviadas para Inspe- Ё╠╠
╠╠Ё            Ё        Ё      Ё cao, sendo o controle atraves dos parame-Ё╠╠ 
╠╠Ё            Ё        Ё      Ё tros: MV_QNFENOR, MV_QNFEBEN, MV_QNFEDEV Ё╠╠
╠╠ЁCleber SouzaЁ02/07/03Ё      Ё Implementada verificacao na rotina       Ё╠╠
╠╠Ё            Ё        Ё      Ё qAtuMatQie parq gerar inconsistencia     Ё╠╠
╠╠Ё            Ё        Ё      Ё para podutos com especificacoes sem      Ё╠╠
╠╠Ё            Ё        Ё      Ё ensaio na importacao.                    Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 ЁQATUMATQIEЁ Autor Ё Paulo Emidio de BarrosЁ data Ё23/04/2001Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ёrealiza a Integracao MAT x QIE, atualizando os arquivos re- Ё╠╠
╠╠Ё			 Ёferente ao SIGAQIE.										  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ EXPA1 = Array contendo os dados enviados na Integracao	  Ё╠╠
╠╠Ё			 Ё EXPN1 = 1)Inclusao, 2)Exclusao 						 	  Ё╠╠
╠╠Ё			 Ё EXPL2 = Rotina Automatica      						 	  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё EXPA1 = {EXPC1,EXPC2,EXPL1}								  Ё╠╠
╠╠Ё			 Ё 													 		  Ё╠╠
╠╠Ё			 Ё Onde:  EXPC1 = "C" Entrada certificada					  Ё╠╠
╠╠Ё			 Ё 				  "D" Entrada Excluida						  Ё╠╠
╠╠Ё			 Ё 				  "E" Erro na Integracao					  Ё╠╠
╠╠Ё			 Ё Onde:  EXPC2 = "C" Mensagem a ser enviada na acao          Ё╠╠
╠╠Ё			 Ё        EXPL1 = .T. Realizou a Integracao 				  Ё╠╠
╠╠Ё			 Ё 				  .F. Nao realizou a Integracao				  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё qAtuMatQie()												  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function qAtuMatQie(aDados,nOpc,lImportacao,lRotAuto)                                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao das  variaveis de trabalho						 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aAreaAnt   := GetArea()
Local lGrvQEK    := .T.
Local aRetQie    := {}
Local cMsgQie    := ""
Local lDelQie    
Local cKeyQEK    := ""                                                  
Local cRevi      := ""              
Local cMsgLap    := ""
Local cMsgAv     := ""
Local cFatApr    := ""
Local cFatRep    := ""
Local cSeekQEK   := ""      
Local cLotUni    := ""
Local cTamLot    := ""
Local cTamLotOri := ""
Local cCodEnt    := ""
Local cUniMed    := ""
Local cUniAmo    := ""
Local nShelf     := ""
Local cFatCon    := ""
Local cTipCon    := ""
Local nDec       := 0
Local nTam       := 0
Local cTamAmo    := ""
Local cGrupo     := ""
Local nMvDiAtr   := ""
Local cMvCoDia   := ""
Local nDiasAtr   := 0
Local nSklEnt	 := 0
Local nCntEnt	 := 0
Local nCntAte 	 := 0
Local aJustif    := {}
Local nVerifica  := 1
Local lPrimDoc   
Local lAltEsp    
Local cApNBR5426 := GetMv("MV_QNBR542") //define se a NBR5426 sera aplicada na inspecao das Entradas
Local cApSkpTest := GetMv("MV_QSKPTES") //define o tipo de Skip-Teste a ser aplicado
Local cQCerEnt   := GetMv("MV_QCERENT") // Verif. se a Entrada pode ser certificada se existir ensaio a inspecionar pelo skip-teste
Local aEnsInsp   := {}     
Local nX
Local lQtdRep    
Local lCtrSkLSkT := .T.
Local cProduto   := " "
Local cLoteQie   := " "
Local nTamLote   := TamSX3("QEK_LOTE")[1]
Local nOrdQEP    := QIndQEP() //Verifica se o indice 2 do QEP esta definido

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas na gravacao do Plano de amostragem por ensaio Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cAtPlAmo   := GetMv("MV_QATUPAM") // Atualizacao automatica do Plano de Amostragem
Local cAtPlAmIQS := GetMv("MV_QPAMIQS") // Atualizcao do Plano de Amostragem vinculado ao IQS
Local nIQSRep    := GetMv("MV_QIQSREP") // Nota para o IQS reprovado
Local lEmissao   := GetMv("MV_QDTNFIM") //Indica se a Revisao do Produto sera verificada pela data de Emissao da Nota Fiscal
Local lAtuPA          
Local aModVld    := {}
Local cSeekQEP   := ""
Local cSeekSD7   := ""

Local lRetQie 
Local lQeMatIns  := ExistBlock("QEMATINS")
Local lQeMatFin  := ExistBlock("QEMATFIN") 
Local lQeMatDel  := ExistBlock("QEMATDEL")
Local lQeMatFor  := ExistBlock("QEMATFOR")

Local aAreaSD1 
Local aAreaSD7  
Local aAreaSA2
Local aMov       := {}    
Local aCM        := Afill(Array(5),0) 
Local lNewQEP    := .T. 
Local cLoteFor	 := aDados[13]	//D1_LOTEFOR
Local lSa5OK	 := .F.    
Local nCntSA5	 := 0 
Local lPrForFab	  := GETNEWPAR('MV_PRFOFAB',.F.)

Private lInconsistencia := .F. //Indica se houve inconsistencia na Entrada atual

Default lRotAuto := .F. 

dbSelectArea("QEL")
dbSelectArea("QEA")

If (SuperGetMv("MV_INTGIQE", .F., .F.) .And. FindFunction("IntGiqESol"))
	aRetQie := IntGiqESol(aDados, nOpc)
   	Return(aRetQie)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Armazena os programas que realizam integracao com o SIGAQIE  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd(aModVld,"MATA100")
Aadd(aModVld,"MATA103")
Aadd(aModVld,"MATA260")
Aadd(aModVld,"MATA261")
Aadd(aModVld,"MATA101")
Aadd(aModVld,"MATA102")
Aadd(aModVld,"MATA465")
Aadd(aModVld,"MATA466") 
Aadd(aModVld,"MATA101N")
Aadd(aModVld,"MATA340")       // Acerto de Inventario
Aadd(aModVld,"MATA102N")     // Remision
Aadd(aModVld,"MATA462TN")   // Transferencia entre sucursales

If lRotAuto .Or. IsInCallStack("MAAVALSD1") //-- Se a funcao estiver sendo executada via Rotina Automatica
	Aadd(aModVld,aDados[25]) //-- Adiciona o nome do RdMake para possibilitar a integracao com o SIGAQIE
EndIf                                          
                              
//Realiza uma copia do Vetor aDados, que contem o registro de Importacao
Private aDadosQIE := aClone(aDados)

lImportacao := If(lImportacao==NIL,.T.,lImportacao)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se analise do Skip-Lote e/ou Skip-Teste sera aplica-Ё
//Ё da na Entrada a Inspecionar.			   					 Ё 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If (aDadosQie[03] $ "D/B") //Nao considera as Notas referentes a Devolucao e Beneficiamento  
	lCtrSkLSkT := .F.
	
ElseIf (AllTrim(aDadosQie[06]) == "TR") //Verifica se as Trabsferencias serao consideradas
	lQtdRep := If(GetMV("MV_QTRFSKP",.f.,"S")=="S",.T.,.F.)
    If !lQtdRep
		lCtrSkLSkT := .F.
	EndIf	
ElseIf (AllTrim(aDadosQie[06]) == "IN") //Naum considera Skip Lote para movimentaГЦo do inventario.
	lCtrSkLSkT := .F.
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё              Array de Integracao dos dados - (LayOut para Importacao)             Ё 
//цдддддддддддддддддддддддддддддддддддддддддбддддддддддддддддддддддбддддддбдддддбддддд╢
//Ё                 Descricao               Ё   Origem Materiais   Ё TIPO Ё TAM Ё DEC Ё 
//цдддддддддддддддддддддддддддддддддддддддддеддддддддддддддддддддддеддддддедддддеддддд╢
//Ё                							Ё                      Ё	  Ё		Ё     Ё 
//Ё [01] - Numero da Nota Fiscal 	 		Ё D1_DOC               Ё  C   Ё	06	Ё  0  Ё  
//Ё [02] - Serie da Nota Fiscal           	Ё D1_SERIE   	       Ё  C	  Ё	03	Ё  0  Ё 
//Ё [03] - Tipo da Nota Fiscal   		 	Ё D1_TIPO              Ё  C   Ё	01	Ё  0  Ё  
//Ё [04] - Data de Emissao da Nota Fiscal   Ё D1_EMISSAO           Ё  D	  Ё	08	Ё  0  Ё
//Ё [05] - Data de Entrada da Nota Fiscal   Ё D1_DTDIGIT           Ё  D	  Ё	08	Ё  0  Ё
//Ё [06] - Tipo de Documento -> default "NF"Ё "NF" ou "REMITO"     Ё  C	  Ё	06	Ё  0  Ё 
//Ё [07] - Item da Nota Fiscal				Ё D1_ITEM              Ё  C	  Ё	02	Ё  0  Ё 
//Ё [08] - Numero do Remito (Localizacoes)  Ё D1_REMITO            Ё  C	  Ё	12	Ё  0  Ё 
//Ё [09] - Numero do Pedido de Compra       Ё D1_PEDIDO            Ё  C	  Ё	06	Ё  0  Ё
//Ё [10] - Item do Pedido de Compra         Ё D1_ITEMPC            Ё  C	  Ё	02	Ё  0  Ё
//Ё [11] - Codigo Fornecedor/Cliente        Ё D1_FORNECE           Ё  C	  Ё	06	Ё  0  Ё
//Ё [12] - Loja Fornecedor/Cliente          Ё D1_LOJA     	       Ё  C	  Ё	02	Ё  0  Ё
//Ё [13] - Numero do Lote do Fornecedor     Ё D1_LOTEFOR     	   Ё  C	  Ё	18	Ё  0  Ё
//Ё [14] - Codigo do Solicitante            Ё SPACE(6)     		   Ё  C   Ё	06	Ё  0  Ё
//Ё [15] - Codigo do Produto                Ё D1_COD     	       Ё  C	  Ё	06	Ё  0  Ё
//Ё [16] - Local Origem    				    Ё D1_LOCAL   	   	   Ё  C	  Ё	02	Ё  0  Ё
//Ё [17] - Numero do Lote             		Ё D5_LOTECTL 	       Ё  C	  Ё	10	Ё  0  Ё
//Ё [18] - Sequencia do Sub-Lote         	Ё D5_NUMLOTE     	   Ё  C	  Ё	06	Ё  0  Ё
//Ё [19] - Numero Sequencial                Ё D1_NUMSEQ            Ё  C	  Ё	06	Ё  0  Ё 
//Ё [20] - Numero do CQ					    Ё D1_NUMCQ		       Ё  C	  Ё	06	Ё  0  Ё
//Ё [21] - Quantidade             			Ё D1_QUANT		       Ё  N	  Ё 11	Ё  2  Ё
//Ё [22] - Preco             				Ё D1_TOTAL 		       Ё  N	  Ё	14	Ё  2  Ё
//Ё [23] - Dias em atraso				    Ё D1_DTDIGIT-C7_DATPRF Ё  N	  Ё	04	Ё  0  Ё
//Ё [24] - TES (somente Materiais)			Ё D1_TES		       Ё  C	  Ё	03	Ё  0  Ё
//Ё [25] - Origem							Ё FunName()		       Ё  C	  Ё	08	Ё  0  Ё
//Ё [26] - Origem Importacao TXT			Ё 				       Ё  C	  Ё	12	Ё  0  Ё
//Ё [27] - Quantidade do Lote Original      Ё 					   Ё  N	  Ё 11	Ё  2  Ё
//Ё [28] - Hora da Entrada				    Ё 					   Ё  C	  Ё 05	Ё  0  Ё
//Ё                					  	    Ё	      		       Ё	  Ё		Ё     Ё
//юдддддддддддддддддддддддддддддддддддддддддаддддддддддддддддддддддаддддддадддддаддддды

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica os Tipos de Entradas validados na Integracao, somen-Ё
//Ё te Normal, Devolucao e Beneficiamento.						 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If (!(aDadosQie[03] $ " NDB") .And. cPaisLoc == "BRA") .Or.;
	(!(aDadosQie[03] $ " NBCD") .And. cPaisLoc # "BRA")
	    
	cMsgQie := OemToAnsi(STR0017) //"Material liberado do CQ e nao enviado para Inspecao"
	aRetQie := {"L",cMsgQie,.T.}
	Return(aRetQie)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o tratamento de/em  Poder Terceiros na TES 		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRetQie := QieTipoNF(aDadosQie[03],aDadosQie[24])

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se o Tipo da Nota Fiscal nao foi enviado para Inspecao, o Ma-Ё
//Ё terial devera ser liberado no CQ.							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRetQie                   
	cMsgQie := OemToAnsi(STR0018) //"Material liberado do CQ e nao enviado para Inspecao"
	aRetQie := {"L",cMsgQie,.T.}
	RestArea(aAreaAnt)       
	Return(aRetQie)

EndIf	

//Verifica o conteudo da origem Importacao TXT	 
If aDadosQie[26] == NIL
	aDadosQie[26] := " "
EndIf                       

//Verifica a Hora da entrada
If Len(aDadosQie)>27
	aDadosQie[28] :=If(aDadosQie[28]==NIL .Or. Empty(aDadosQie[28]),SubStr(Time(),1,5),aDadosQie[28]) 		 
Else 
	Aadd(aDadosQie,SubStr(Time(),1,5))
EndIf	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Compatibiliza o tamanho do Documento de Entrada (QEK_DOCENTR)Ё 
//Ё com o Lote de Fornecedor (D1_LOTEFOR), para que o controle deЁ 
//Ё Skip-Lote por Doc de Entrada, seja aplicado corretamente na  Ё 
//Ё Integracao com Materiais e EIC.								 Ё 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aDadosQie[13] := SubStr(aDadosQie[13],1,TamSX3("QEK_DOCENT")[1])

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza o tratamento do lote recebido na Entrada			 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cLoteQie := QieTrataLote(aDadosQie[15],@aDadosQie[17],@aDadosQie[18],nOpc)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a Exclusao da  Entrada								 Ё
//Ё 1 = Inclusao 												 Ё
//Ё 2 = Exclusao												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 2             
                         
    //P.E. para alteracao do vetor aDadosQie na  exclusao
	If lQeMatDel 
		ExecBlock("QEMATDEL",.F.,.F.)
	EndIf	

	lDelQie := qDelMatQie(aDadosQie)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Devolve o Status da Integracao 								   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lDelQie
		cMsgQie := OemToAnsi(STR0001) //"Exclusao da Entrada realizada com sucesso"
		aRetQie :=  {"D",cMsgQie,.T.} 
	Else    
		cMsgQie := OemToAnsi(STR0002) //"Houve ocorrencia na exclusao da Entrada do Material"
		aRetQie := {"E",cMsgQie,.F.}
	EndIf           
	  
	Return(aRetQie)

EndIf
             
//Ponto de Entrada, antes da gravacao dos dados
If lQeMatIns .And. lImportacao
	lGrvQEK := ExecBlock("QEMATINS",.F.,.F.)
	If cLoteQie <> AllTrim(aDadosQie[17])+AllTrim(aDadosQie[18])	
		cLoteQie := AllTrim(aDadosQie[17])+AllTrim(aDadosQie[18])
	EndIf
	
	cLoteQie := PadR(cLoteQie,nTamLote)
EndIf	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de Entrada, apos a criacao do Lote da Entrada, caso naoЁ
//Ё haja tratamento de rastreabilidade.							 Ё
//Ё manipula as posicoes referentes ao Lote+SubLote (17 e 18)    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lQeMatFor .And. lImportacao
	lGrvQEK  := ExecBlock("QEMATFOR",.F.,.F.)
	cLoteQie := PadR(AllTrim(aDadosQie[17])+AllTrim(aDadosQie[18]),nTamLote)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica os laudos com categoria Aprovado/Reprovado Total 	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFatApr := Fator("1",.T.) //Aprovado Totalmente
cFatRep := Fator("3",.T.) //Reprovado Totalmente

If Empty(cFatApr)
	Help(" ",1,"A200FATAPR") //"Nao foi cadastrado nenhum Fator Aprovado Total"
	lGrvQEK  := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica a compatibilizacao de tamanho dos campos D1_LOTEFOR x QEK_DOCENT x QEP_DOCENT Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cLoteFor) .And. ;
	( Len(AllTrim(cLoteFor)) > TamSX3("QEK_DOCENT")[1] .Or. Len(AllTrim(cLoteFor)) > TamSX3("QEP_DOCENT")[1] )
	cMsgAv := OemToAnsi(STR0020)+AllTrim(aDadosQie[15])+OemToAnsi(STR0021)+AllTrim(aDadosQie[01])+" / "+AllTrim(aDadosQie[02])
	Aviso(OemToAnsi(STR0022)+cMsgAv,OemToAnsi(STR0040),{"Ok"},3)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se o produto possui especificacoes cadastradas		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
QE6->(dbSetOrder(1))
If !QE6->(MsSeek(xFilial("QE6")+aDadosQie[15]))
	cMsgLap := OemToAnsi(STR0003) //"O produto nao possui especificacao cadastrada"
	qGrvIncEnt(aDadosQie,cMsgLap)
	lGrvQEK := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se o produto possui Revisao disponivel 			 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cRevi := QA_UltRevEsp(aDadosQie[15],If(lEmissao,aDadosQie[04],aDadosQie[05]),.F.,,"QIE") //Produto+Data de Entrada 
If Empty(cRevi)
	cMsgLap := OemToAnsi(STR0004) //"O produto nao possui revisao disponivel"
	qGrvIncEnt(aDadosQie,cMsgLap)
	lGrvQEK := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se o Fornecedor possui amarracao Produto x FornecedorЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lCtrSkLSkT //Nao considera as NFs referentes a Beneficiamento, Devolucao e Transferencias
	SA5->(dbSetOrder(2)) 
	if !lPrForFab
		SA5->(MsSeek(xFilial("SA5")+aDadosQie[15]+aDadosQie[11]+aDadosQie[12]))
		while SA5->A5_FILIAL + SA5->A5_PRODUTO + SA5->A5_FORNECE + SA5->A5_LOJA = xFilial("SA5")+aDadosQie[15]+aDadosQie[11]+aDadosQie[12]
			nCntSA5 += 1
			If empty(SA5->A5_FABR)        
				lSa5OK := .T.
	 			Exit
			EndIF
			SA5->(dbSkip())
		EndDo
	Else			
		If !SA5->(MsSeek(xFilial("SA5")+aDadosQie[15]+aDadosQie[11]+aDadosQie[12]))
			nCntSA5 := 0 
			lSa5OK := .F.		
		else
			lSa5OK := .T.		
		endif
	EndiF 		

	If !lSa5OK
		If nCntSA5 = 0
			cMsgLap := OemToAnsi(STR0005) //"Nao existe amarracao entre o Produto e Fornecedor"
		Else
			cMsgLap := OemToAnsi(STR0041) //'Falta amarracao do Produto X Fornecedor cadastrado pela rotina Mata060'		
		Endif           
		qGrvIncEnt(aDadosQie,cMsgLap)
		lGrvQEK := .F.
	Else
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se a categoria do Fornecedor e igual a nao-recebe 	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		QEG->(dbSetOrder(1))
		QEG->(MsSeek(xFilial("QEG")+SA5->A5_SITU))
		If QEG->QEG_CATEG == "4" //Categoria Nao recebe
			///cMsgLap := OemToAnsi(STR0006) //"A Entrada para este fornecedor possui categoria (Nao-Recebe)"
			///qGrvIncEnt(aDadosQie,cMsgLap)
			///lGrvQEK := .F.

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Forca o envio do material para Inspecao no SIGAQIE, para que Ё
			//Ё o mesmo seja reprovado, devido a situacao de Nao-Habilitado. Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			lCtrSkLSkT := .F. //Forca o controle das Notas Fiscais referentes a Ben/Dev para que a mesma seja inspecionada			

		EndIf  
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se a categoria do Fornecedor e igual a nao-recebe 	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды   
		If !Empty(SA5->A5_SITU)
			QEG->(dbSetOrder(1))
			QEG->(MsSeek(xFilial("QEG")+SA5->A5_SITU))
			If QEG->QEG_CATEG == "4" //Categoria Nao recebe
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Forca o envio do material para Inspecao no SIGAQIE, para que Ё
				//Ё o mesmo seja reprovado, devido a situacao de Nao-Habilitado. Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				lCtrSkLSkT := .F. //Forca o controle das Notas Fiscais referentes a Ben/Dev para que a mesma seja inspecionada			
			EndIf
		Else
			cMsgLap := OemToAnsi(STR0035) //"A situaГЦo do Fornecedor x Produto nЦo foi informado."
			qGrvIncEnt(aDadosQie,cMsgLap)
			lGrvQEK := .F.
		EndIF	  

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica a data de validade do RIAI							 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aDadosQie[05] > SA5->A5_VALRIAI .And. !Empty(SA5->A5_VALRIAI)
			cMsgLap := OemToAnsi(STR0007) //"A data de validade do RIAI do Fornecedor esta expirada"
			qGrvIncEnt(aDadosQie,cMsgLap)
			lGrvQEK := .F.
		EndIf

	EndIf
ElseIf AllTrim(aDadosQie[06])#"TR" .AND. AllTrim(aDadosQie[06])#"IN"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁVerifica se o Fornecedor possui amarracao Produto x Cliente   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    SA7->(dbSetOrder(2))
	If !SA7->(MsSeek(xFilial("SA7")+aDadosQie[15]+aDadosQie[11]+aDadosQie[12]))
		cMsgLap := OemToAnsi(STR0032) //"Nao existe amarracao entre o Produto e Cliente"
		qGrvIncEnt(aDadosQie,cMsgLap)
		lGrvQEK := .F.
	EndIf

EndIf	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe ensaio para especificacao corrente        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cRevi)
	cProduto := aDadosQie[15]+cRevi

	dbSelectArea("QE7")
	dbSetOrder(1)
	If !dbSeek(xFilial("QE7")+cProduto)
		dbSelectArea("QE8")
		dbSetOrder(1)                  
		If !dbSeek(xFilial("QE8")+cProduto)
			cMsgLap := OemToAnsi(STR0033)  //"Nao existem ensaio para ultima revisao do produto"
			qGrvIncEnt(aDadosQie,cMsgLap)
			lGrvQEK := .F.
		EndIf
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se existe Entrada com os mesmos dados cadastrados	 Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSeekQEK := aDadosQie[11]+aDadosQie[12]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+cLoteQie+aDadosQie[19] 

QEK->(dbSetOrder(11))
If QEK->(MsSeek(xFilial("QEK")+cSeekQEK))
	cMsgLap := OemToAnsi(STR0008) //"Ja existe entrada cadastrada com os mesmos dados"
	qGrvIncEnt(aDadosQie,cMsgLap)
	lGrvQEK := .F.
EndIf	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se o Numero do Lote se repete						 Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cLotUni := GetMv("MV_QLOTUNI") 
If cLotUni == "S"
	QEK->(dbSetOrder(6))
	If QEK->(MsSeek(xFilial("QEK")+cLoteQie))
		cMsgLap := OemToAnsi(STR0009) //"O numero do Lote informado na Entrada ja existe"
		qGrvIncEnt(aDadosQie,cMsgLap)
		lGrvQEK := .F.
    EndIf
EndIf
                             
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se o tamanho do Lote e valido						 Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTamLot    := PadR(aDadosQie[21],TamSX3("QEK_TAMAMO")[1]) //Quantidade           
cTamLotOri := PadR(aDadosQie[27],TamSX3("QEK_LOTORI")[1]) //Quantidade do Lote Original          
If !QA_VerNum(@cTamLot)
	cMsglap := OemToAnsi(STR0010) //"O tamanho do Lote informado nao e numerico"
	qGrvIncEnt(aDadosQie,cMsgLap)
	lGrvQEK := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera o codigo Seq. Identificador da Entrada	no QEK           Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodEnt := QA_SEQU("QIE_IDEN",TamSX3("QEK_IDENTE")[1],"A","")
If Empty(cCodEnt)
	cMsgLap := OemToAnsi(STR0011) //"Nao foi possivel gerar o codigo Seq. Identificador da Entrada"
	qGrvIncEnt(aDadosQie,cMsgLap)
	lGrvQEK := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a UM cadastrada no SB1 eh diferente do QE6       Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lGrvQEK
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+aDadosQie[15]))
	If SB1->B1_UM <> QE6->QE6_UNMED1
		cMsgLap := OemToAnsi(STR0034) //"Unidade de Medida esta diferente entre os cadastros de Produtos e EspecificaГЦo do Produto."
		qGrvIncEnt(aDadosQie,cMsgLap)
		lGrvQEK := .F.
	EndIf
EndIf

If lGrvQEK

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica as Unidades de Medida e Amostragem, assume a pri- Ё	
	//Ё meira unidade de Medida associada ao produto.				 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	QE6->(dbSetOrder(1))
	If QE6->(MsSeek(xFilial("QE6")+aDadosQie[15]+Inverte(cRevi)))
		cUniMed	:= QE6->QE6_UNMED1
		cUniAmo	:= QE6->QE6_UNAMO1
		nShelf	:= QE6->QE6_SHLF
		cFatCon	:= QE6->QE6_FATCO1
		cTipCon	:= QE6->QE6_TIPCO1

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calcula o Lote de Amostragem 								 Ё	
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		//Ponto de Entrada para formatar o Tamanho da Amostra
		If ExistBlock("QEMATAMO")
			cTamAmo := ExecBlock("QEMATAMO",.F.,.F.)		
		Else
			If cUniMed == cUniAmo
				cTamAmo	:= cTamLot
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica o numero de casas decimais do Tamanho do Lote 		 Ё	
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nDec := QA_NumDec(cTamLot)
				nTam := TamSX3("QEK_TAMAMO")[1]
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Calcula o Tamanho da Amostra 								 Ё	
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If SuperVal(cFatCon) <> 0
					If cTipCon == "D"
						cTamAmo := Str(SuperVal(cTamLot)/SuperVal(cFatCon),TamSX3("QEK_TAMAMO")[1],nDec)
					Else
						cTamAmo := Str(SuperVal(cTamLot)*SuperVal(cFatCon),TamSX3("QEK_TAMAMO")[1],nDec)
					EndIf
				Else
					cTamAmo := PadR(AllTrim(cTamLot),TamSX3("QEK_TAMAMO")[1])
				EndIf
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Inverte o formato do Valor: ponto -> virgula				 Ё	
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cTamAmo := StrTran(cTamAmo,".",",")
				
			EndIf		
		EndIf
		
	EndIf	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica o grupo do Produto								 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	QEA->(dbSetOrder(2))
	If QEA->(MsSeek(xFilial("QEA")+aDadosQie[15]))
		cGrupo := QEA->QEA_GRUPO
	EndIf	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica o numero maximo de dias em atraso					 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nMvDiAtr := GetMv("MV_QDIAIPO")
			
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se os dias de atraso sera considerado				 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cMvCoDia := GetMv("MV_QCONDIA")
                                
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Considera o menor numero de dias em atraso, entre o parame-  Ё	
	//Ё tro e o informado.							 				 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nDiasAtr := aDadosQie[23]

	If nDiasAtr > 0 .And. DataValida(aDadosQie[5]-nDiasAtr+1) >= aDadosQie[5]   // considera 1 dia final de semana.
		nDiasAtr := 1	
	Else  
		If nDiasAtr < 0
		   nDiasAtr := 0
		Else
			If cMvCoDia == "S"
				nDiasAtr := If(Abs(nDiasAtr)>nMvDiAtr,If(nDiasAtr<0,0-nMvDiAtr,nMvDiAtr),nDiasAtr)
			EndIf
		EndIf 
	EndIf	
		
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica as condicoes para a Inspecao/Certificacao das Entra-Ё	
	//Ё das.														 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nSklEnt	:= GetMv("MV_QSKLENT")	// "No. Entradas iniciais p/ aplicacao skip-lote"
	nCntEnt	:= 0	// Contador Entradas
	nCntAte	:= 0	// Contador Entradas com Plano Atenuado

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define o vetor de justificativas utilizado na QieSkipLote	 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aJustif := {}

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё assume como default a Inspecao 								 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nVerifica := 1	// Inspecionar
		
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a primeira ocorrencia do Skip Teste na Qe200SkTe		 Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lPrimDoc := .T.

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia as consistencias da Inspecao da Entrada, somente para Ё	
	//Ё as Entradas provenientes de Notas Fiscais do tipo Normal.    Ё	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    lAltEsp := .F. //Indica a primeira entrada apos a alteracao da especificacao
           
	If lCtrSkLSkT //Nao considera as NFs referentes a Beneficiamento, Devolucao e Transferencias
	    
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se ┌ a 1a. ocorrencia do Doc. Entrada p/ o Fornecedor/Grupo Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(aDadosQie[13])
	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se ha' skip-teste definido por grupo		 		 Ё	
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			QEI->(dbSetOrder(1))
			If QEI->(MsSeek(xFilial("QEI")+aDadosQie[11]+aDadosQie[12]+cGrupo))
				                       
				cSeekQEK := xFilial("QEK")+aDadosQie[13]+aDadosQie[11]+aDadosQie[12]
				QEK->(dbSetOrder(4))
				QEK->(MsSeek(cSeekQEK))
				While QEK->(!Eof()) .And. (QEK->QEK_FILIAL+QEK->QEK_DOCENT+QEK->QEK_FORNEC+QEK->QEK_LOJFOR) == cSeekQEK
					If QEK->QEK_GRUPO == cGrupo
						lPrimDoc := .F.
						Exit
					EndIf
					QEK->(dbSkip())
				EndDo
			EndIf
		EndIf

		A200COIN(aDadosQie[11],aDadosQie[12],aDadosQie[15],cRevi,aDadosQie[05],cLoteQie,aJustif,@nVerifica,@lAltEsp)
    
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica as categorias Assegurado e qualificado 			 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (QEG->QEG_CATEG == "1" .Or. QEG->QEG_CATEG == "2")
			
			//caso nao haja justificativa para a Inspecao nao Verifica o Skip-Lote
			If Len(aJustif) == 0
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Aplicacao da NBR-5426 no Skip-Lote 				 			 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cSeekQEK := xFilial("QEK")+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]
				QEK->(dbSetOrder(2))
				QEK->(MsSeek(cSeekQEK))
				
				//Aplica a NBR5426
				If cApNBR5426  == "S"
					
					// Checa se as ult. 5 Entradas foram com plano atenuado
					While QEK->(!Eof()) .And.	(QEK->QEK_FILIAL+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT) ==;
						cSeekQEK .And. nCntEnt <= 5
						nCntEnt++
						
						//verifica o tipo de Plano de Amostragem
						QF5->(dbSetOrder(1))
						If QF5->(MsSeek(xFilial("QF5")+QEK->QEK_CHAVE))
							If QEK->QEK_TIPONF $ "Nъ "
								QF4->(dbSetorder(1))
								If QF4->(MsSeek(xFilial("QF4")+QF4->QF4_FORNEC+QF4->QF4_LOJFOR+QF4->QF4_PRODUT+QF4->QF4_REVI))
									While QF4->(!Eof()) .And. QF4->QF4_FILIAL == xFilial("QF4") .And.;
										(QF4->QF4_FORNEC+QF4->QF4_LOJFOR+QF4->QF4_PRODUT+QF4->QF4_REVI) ==;
										(QF5->QF5_FORNEC+QF5->QF5_LOJFOR+QF5->QF5_PRODUT+QF4->QF4_REVI)
										If Right(QF4->QF4_PLAMO,1) == "A"
											nCntAte++
											Exit
										EndIf
										QF4->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
						If nCntEnt >= 5
							Exit
						EndIf
						QEK->(dbSkip())
						
					EndDo
					
					If nCntEnt >= 5 .And. nCntAte == 5
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica o SKIP-LOTE da Entrada                          	 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nVerifica := QieSkipLote(aDadosQie[11],aDadosQie[12],aDadosQie[15],cGrupo,aDadosQie[05],cLoteQie,aDadosQie[13],@aJustif)
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se o Skip-teste sera aplicado						 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If (cApSkpTest == "1")                       .Or.; //Skip-Teste individual
							(cApSkpTest == "2" .And. nVerifica == 1) .Or.; //Somente entradas inspecionadas
							(cApSkpTest == "2" .And. nVerifica == 2)       //As Certificadas em Skip-Lote que poderao ser Inspecionadas
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Calcula o Skip-Teste										 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							aEnsInsp := A200SkTe(aDadosQie[11],aDadosQie[12],aDadosQie[15],lPrimDoc,;
							cFatRep,cRevi,lAltEsp)
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica se a Entrada podera ser certificada, caso exista en-Ё
							//Ё saio a inspecionar pelo Skip-Teste.							 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If nVerifica == 2 .And. cQCerEnt == "N"
								For nX := 1 To Len(aEnsInsp)
									If aEnsInsp[nX,2] == 1
										nVerifica := 1
									EndIf
								Next nX
							EndIf
							
						EndIf
					Else
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Marca para inspecao os ensaios com skip-teste definido     	 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						aEnsInsp := QE200SkTe(cGrupo,lPrimDoc,aDadosQie[11],;
						aDadosQie[12],aDadosQie[15],cRevi)
					EndIf
					
				Else
					
					If nSklEnt > 1
						
						While QEK->(!Eof()) .And. (QEK->QEK_FILIAL+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT) ==;
							cSeekQEK .And. nCntEnt <= nSklEnt
							nCntEnt++
							QEK->(dbSkip())
							
						EndDo
						
						If nCntEnt >= nSklEnt
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica o SKIP-LOTE da Entrada                         	 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							nVerifica := QieSkipLote(aDadosQie[11],aDadosQie[12],aDadosQie[15],cGrupo,aDadosQie[05],cLoteQie,aDadosQie[13],@aJustif)
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica se o Skip-teste sera aplicado						 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If (cApSkpTest == "1")                       .Or.; //Skip-Teste individual
								(cApSkpTest == "2" .And. nVerifica == 1) .Or.; //Somente entradas inspecionadas
								(cApSkpTest == "2" .And. nVerifica == 2)       //As Certificadas em Skip-Lote que poderao ser Inspecionadas
								
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Calcula o Skip-Teste										 Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								aEnsInsp := A200SkTe(aDadosQie[11],aDadosQie[12],aDadosQie[15],lPrimDoc,;
								cFatRep,cRevi,lAltEsp)
								
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Verifica se a Entrada podera ser certificada, caso exista en-Ё
								//Ё saio a inspecionar pelo Skip-Teste.							 Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If nVerifica == 2 .And. cQCerEnt == "N"
									For nX := 1 To Len(aEnsInsp)
										If aEnsInsp[nX,2] == 1
											nVerifica := 1
										EndIf
									Next nX
								EndIf
								
							EndIf
							
						Else
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Marca para inspecao os ensaios com skip-teste definido 		 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							aEnsInsp := QE200SkTe(cGrupo,lPrimDoc,aDadosQie[11],;
							aDadosQie[12],aDadosQie[15],cRevi)
						EndIf
					Else
						dbSelectArea("QEL")
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica o SKIP-LOTE da Entrada                         	 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nVerifica := QieSkipLote(aDadosQie[11],aDadosQie[12],aDadosQie[15],cGrupo,aDadosQie[05],cLoteQie,aDadosQie[13],@aJustif)
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se o Skip-teste sera aplicado						 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If (cApSkpTest == "1")                       .Or.; //Skip-Teste individual
							(cApSkpTest == "2" .And. nVerifica == 1) .Or.; //Somente entradas inspecionadas
							(cApSkpTest == "2" .And. nVerifica == 2)       //As Certificadas em Skip-Lote que poderao ser Inspecionadas
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Calcula o Skip-Teste										 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							aEnsInsp := A200SkTe(aDadosQie[11],aDadosQie[12],aDadosQie[15],lPrimDoc,;
							cFatRep,cRevi,lAltEsp)
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica se a Entrada podera ser certificada, caso exista en-Ё
							//Ё saio a inspecionar pelo Skip-Teste.							 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If nVerifica == 2 .And. cQCerEnt == "N"
								For nX := 1 To Len(aEnsInsp)
									If aEnsInsp[nX,2] == 1
										nVerifica := 1
									EndIf
								Next nX
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Marca para inspecao os ensaios com skip-teste definido  	 Ё	
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aEnsInsp := QE200SkTe(cGrupo,lPrimDoc,aDadosQie[11],aDadosQie[12],aDadosQie[15],cRevi)
				
			EndIf
		Else
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Marca para inspecao os ensaios com skip-teste definido 		 Ё	
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aEnsInsp := QE200SkTe(cGrupo,lPrimDoc,aDadosQie[11],aDadosQie[12],aDadosQie[15],cRevi)
	
		EndIf
	    
	EndIf 
	
EndIf

//Forca o envio do material para Inspecao
If !lCtrSkLSkT  //Nao considera as Notas referentes a Devolucao e Beneficiamento  
	nVerifica := If(nVerifica==1,nVerifica,1)
EndIf               

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a gravacao dO Item da Nota Fiscal no QEK 			 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lGrvQEK 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁVerificar se ja existe pelo menos uma amostra inicial...Ё
        //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды

      /*If lTmAmoIn // O TRATAMENTO DE AMOSTRA INICIAL ESTа SENDO FEITO NO QIEA215 DEVIDO A ESPECIFICAгцO NцO PODER TER SOMENTE AMOSTRA INICIAL
		nQtdEnt := 0
		dbSelectArea("QEK") 
		dbSetOrder(2)
		If dbSeek(xFilial("QEK")+aDadosQie[11]+aDadosQie[12]+aDadosQie[15])         
		    cSeek   := QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI
		    While !Eof() .And. cSeek == (QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI)
		    	If nQtdEnt >= 1		
		    		Exit   
				Else
			  	 	nQtdEnt++             
		  	 	EndIf
			 	dbSkip()
			EndDo    	
		EndIf       
		If nQtdEnt >= 1
			nVerifica := 2
		Endif          
	EndiF*/ 
	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gera a Chave de Ligacao para o QEK							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cKeyQEK := QA_NewChave("QEK",7)

	dbSelectArea("QEK")
	RecLock("QEK",.T.)
	QEK->QEK_FILIAL := xFilial("QEK") 
	QEK->QEK_NTFISC := aDadosQie[01] 				 //Numero da Nota Fiscal 	 		
	QEK->QEK_SERINF := aDadosQie[02] 				 //Serie da Nota Fiscal           	
	QEK->QEK_TIPONF := aDadosQie[03] 				 //Tipo da Nota Fiscal   		 	
	QEK->QEK_DTNFIS := aDadosQie[04] 				 //Data de Emissao da Nota Fiscal  
	QEK->QEK_DTENTR := aDadosQie[05] 				 //Data de Emissao da Nota Fiscal  
	QEK->QEK_ENTINV := Inverte(aDadosQie[05]) 	 	 //Data de Emissao da Nota Fiscal  
	QEK->QEK_HRENTR := aDadosQie[28] 				 //Hora da Entrada
	QEK->QEK_DIASAT := nDiasAtr				 	 	 //Dias de Atraso na Entrada
	QEK->QEK_TIPDOC := aDadosQie[06] 				 //Tipo de Documento -> default "NF"
	QEK->QEK_ITEMNF := aDadosQie[07] 				 //Item da Nota Fiscal				
	QEK->QEK_REMITO := aDadosQie[08] 				 //Numero do Remito (Localizacoes) 
	QEK->QEK_PEDIDO := aDadosQie[09] 				 //Numero do Pedido de Compra       
	QEK->QEK_ITEMPC := aDadosQie[10] 				 //Item do Pedido de Compra         
	QEK->QEK_FORNEC := aDadosQie[11] 				 //Codigo Fornecedor/Cliente        
	QEK->QEK_LOJFOR := aDadosQie[12] 				 //Loja Fornecedor/Cliente          
	QEK->QEK_DOCENT := aDadosQie[13] 			     //Numero do Lote do Fornecedor     
	QEK->QEK_SOLIC  := aDadosQie[14] 				 //Codigo do Solicitante            
	QEK->QEK_PRODUT := aDadosQie[15] 				 //Codigo do Produto                
	QEK->QEK_REVI   := cRevi			           	 //Revisao do Produto
	QEK->QEK_UNIMED := cUniMed                 	 	 //Unidade de Medida
	QEK->QEK_VERIFI := nVerifica                     //Inspeciona/Certifica
	QEK->QEK_GRUPO  := cGrupo                        //Grupo
	QEK->QEK_ALTESP := lAltEsp						 //indica a primeira entrada apos a alteracao da especificacao
	QEK->QEK_SKLDOC := lPrimDoc					 	 // indica a primeira ocorrencia Fornecedor x Grupo
	QEK->QEK_IDENTE := cCodEnt                       // Codigo Sequencial identificador da Entrada
	QEK->QEK_IDEINV := Inverte(cCodEnt)			     // Codigo Sequencial identificador da Entrada invertido
	QEK->QEK_LOCORI := aDadosQie[16] 				 //Local Origem    				   
	QEK->QEK_LOTE   := cLoteQie 					 //Numero do Lote+Sequencia do Sub-Lote                    	
	QEK->QEK_LOTINV := Inverte(cLoteQie) 			 //Numero do Lote invertido
	QEK->QEK_NUMSEQ := aDadosQie[19] 				 //Numero Sequencial           
	QEK->QEK_CERFOR := aDadosQie[20] 				 //Numero do CQ				
	QEK->QEK_TAMLOT := cTamLot						 //Quantidade             	
	QEK->QEK_LOTORI := cTamLotOri					 //Quantidade do Lote Original            	
	QEK->QEK_TAMAMO := cTamAmo 					     //Quantidade             	
	QEK->QEK_PRECO  := aDadosQie[22] 				 //Preco             		
	QEK->QEK_TES    := aDadosQie[24]                //TES da Nota Fiscal de Entrada
	QEK->QEK_ORIGEM := If(Empty(aDadosQie[25]),AllTrim(FunName()),aDadosQie[25]) //Origem					
	QEK->QEK_DTCAEN := dDataBase     				 //Data de Entrada
	QEK->QEK_CODENT := "C"			  				 //Importacao??? 
	QEK->QEK_MOVEST := " " 
	QEK->QEK_IMPORT := aDadosQie[26]				 //Origem Importacao TXT 
	QEK->QEK_SITENT := "1"  						 //Entrada pendente para Inspecao
	QEK->QEK_CHAVE  := cKeyQEK 
	If !Empty(aDadosQie[14]) 				
		QEK->QEK_FILMAT := xFilial('QAA')           //Filial do Usuario logado 
    EndIf
	FkCommit()
	MsUnLock()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza a gravacao do Plano de Amostragem por Ensaio		   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	QAtuPlAmEn(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_REVI,QEK->QEK_CHAVE,QEK->QEK_TAMAMO,QEK->QEK_TIPONF,1)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё  Grava a Certificacao da Entrada, se em Regime de Skip-Lote	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nVerifica == 2		
		lGrvQEK := QieAtuLaudo(nOpc)
		If !lGrvQEK
			cMsgLap := OemToAnsi(STR0012) //"Nao foi possivel gerar o Codigo do Certificado de Qualidade"
			qGrvIncEnt(aDadosQie,cMsgLap)
		EndIf        
	EndIf 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza o Controle do Skip-Teste							   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lCtrSkLSkT //Nao considera as NFs referentes a Beneficiamento, Devolucao e Transferencias
		QieAtuSkpTst(1,aEnsInsp)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualizacao Automatica do Plano de Amostragem             	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cAtPlAmo  == "S"	//Atualizacao automatica do Plano de Amostragem
		
		lAtuPA := .T.
			
		If cAtPlAmIQS == "S" //Atualizacao do Plano de Amostragem vinculado ao IQS
		    If aDadosQie[03] $ ('N ') //Verifica tipo da Nota Fiscal
	 		  	aAreaSA2 := SA2->(GetArea())
				SA2->(dbSetOrder(1))
				SA2->(MsSeek(xFilial("SA2")+aDadosQie[11]+aDadosQie[12]))
				If (SA2->A2_FATAVA == 0 .And. Empty(SA2->A2_DTAVA)) .Or.;
				   (SA2->A2_FATAVA <= nIQSRep)
					lAtuPA := .F.
				EndIf
				RestArea(aAreaSA2)
		    EndIf
		EndIf              
			
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza o Plano de Amostragem a partir da importacao		   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lAtuPA 
			A200AtPA(2)
		EndIf
			
	EndIf
    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza a unidade de medida do SB1, de acordo com a informa-Ё
	//Ё da na revisao do produto.									 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+aDadosQie[15]))
		If SB1->B1_UM # cUniMed .And. !Empty(cUniMed)
			RecLock("SB1",.F.)
			SB1->B1_UM	:= cUniMed
			MsUnLock()
		EndIf
	EndIf
	
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava o registro no QEP para Impressao da Ficha do Produto	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("QEP")
If lGrvQEK   

	If nOrdQEP == 1
		cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+DtoS(aDadosQie[05])+cLoteQie
    Else
		cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+DtoS(aDadosQie[05])+cLoteQie+aDadosQie[19]  	
    EndIf

	QEP->(dbSetOrder(nOrdQEP))
	If !QEP->(dbSeek(cSeekQEP))
		lNewQEP := .T.
	Else       
		lNewQEP := qVerifInc(nOrdQEP,cSeekQEP,aDadosQie[1],aDadosQie[2],cLoteQie) 
	EndIf 
	
	If lNewQEP
		RecLock("QEP",.T.)
		QEP->QEP_FILIAL := xFilial("QEP")
		QEP->QEP_FORNEC := aDadosQie[11]
		QEP->QEP_LOJFOR := aDadosQie[12]
		QEP->QEP_PRODUT := aDadosQie[15]
		QEP->QEP_REVI   := cRevi
		QEP->QEP_DTENTR := aDadosQie[05]
		QEP->QEP_LOTE   := cLoteQie
	Else
		RecLock("QEP",.F.)
	EndIf  
	QEP->QEP_CODTAB := "1" 
	QEP->QEP_HRENTR := QEK->QEK_HRENTR 
	QEP->QEP_TAMLOT := QEK->QEK_TAMLOT
	QEP->QEP_LOTORI := QEK->QEK_LOTORI
	QEP->QEP_TAMAMO := QEK->QEK_TAMAMO 
	QEP->QEP_DOCENT := aDadosQie[13]
	QEP->QEP_NTFISC := aDadosQie[01]
	QEP->QEP_SERINF := aDadosQie[02]
	QEP->QEP_TIPONF := aDadosQie[03] 				 
	QEP->QEP_DTNFIS := aDadosQie[04]
	QEP->QEP_TIPDOC := aDadosQie[06]
	QEP->QEP_ITEMNF := aDadosQie[07] 				 
	QEP->QEP_REMITO := aDadosQie[08] 				 
	QEP->QEP_PEDIDO := aDadosQie[09]
	QEP->QEP_ITEMPC := aDadosQie[10]
	QEP->QEP_LOCORI := aDadosQie[16] 				
	QEP->QEP_NUMSEQ := aDadosQie[19]
	QEP->QEP_CERFOR := aDadosQie[20]
	QEP->QEP_DIASAT := nDiasAtr
	QEP->QEP_PRECO  := aDadosQie[22]
	QEP->QEP_SOLIC  := aDadosQie[14]
	QEP->QEP_ORIGEM := aDadosQie[25]
	QEP->QEP_IMPORT := aDadosQie[26]
	QEP->QEP_ERRO   := If(nVerifica == 2,"A","")
	QEP->QEP_DTIMP  := dDataBase
	QEP->QEP_EXCLUI := "N"
	If !Empty(aDadosQie[14]) 				
		QEP->QEP_FILMAT := xFilial('QAA')        
    EndIf
	If AllTrim(QEP->QEP_ERRO) # "A" 
		QEP->QEP_INSPOB	:= "P"	
	EndIf
	MsUnLock()                                              
	
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Devolve o Status da Integracao 								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lGrvQEK	

	If ( Ascan(aModVld,AllTrim(aDadosQie[25])) > 0 )
		cMsgQie := ""
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Realizou a Certificacao a partir do Skip-Lote				   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nVerifica == 2
			cMsgQie := OemToAnsi(STR0013) //"Certificado a partir da avaliacao do Skip-Lote"
			aRetQie :=  {"C",cMsgQie,.T.} //Realiza a Liberacao do Material no CQ

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava o flag de movimentacao de Estoque, para movimentacao pos-Ё
			//Ё terior quando o fornecedor for certificado.					   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			RecLock("QEK",.F.)
			QEK->QEK_MOVEST := "S"
			QEK->QEK_SITENT := "2" //Entrada Aprovada (FREE-PASS)
			MsUnLock()
		Else    
			cMsgQie := OemToAnsi(STR0014) //"Material enviado para Inspecao no QIE"
			aRetQie := {" ",cMsgQie,.T.}
		EndIf
	Else
		cMsgQie := OemToAnsi(STR0015) //"Material enviado para Inspecao no QIE"
		aRetQie := {" ",cMsgQie,.T.}
	EndIf
Else                  
	cMsgQie := OemToAnsi(STR0016) //"Houve ocorrencia no Envio do Material para Inspecao"
	aRetQie := {"E",cMsgQie,.F.}
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a liberacao do material no CQ, quando for realizada a  Ё
//Ё ReImportacao, apos as correcao das inconsistencias.			   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lGrvQEK	

	If AllTrim(FunName()) $ "QIEA180ъQIEA190ъQIEA183" .And. SubStr(QEK->QEK_ORIGEM,1,4) == "MATA"
	
		dbSelectArea("SD1")
		dbSetOrder(1)
		If MsSeek(xFilial("SD1")+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_FORNEC+;
			QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_ITEMNF)
			cSeekSD7 := (SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)  
		EndIf	
				
		If aRetQIE[1] == "C" .Or. aRetQie[1] == "L" .And. AllTrim(QEK->QEK_TIPDOC) # "NFEIC"
			aAreaSD1 := SD1->(GetArea())
			aAreaSD7 := SD7->(GetArea())
				
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Realiza Automaticamente a Libera┤└o da movimenta┤фo no SD7   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("SD7")
			dbSetOrder(2)
		 	If MsSeek(xFilial("SD7")+cSeekSD7)
		 	
				If SD7->D7_TIPO == 0
				
					Aadd(aMov,Array(11))
					aMov[Len(aMov),01] := 1               //Tipo da Movimentacao (1=libera/2=Rejeita)                                     
					aMov[Len(aMov),02] := SD7->D7_SALDO   //Quantidade a ser movimentada
					aMov[Len(aMov),03] := SD7->D7_LOCDEST //Local de Destino da Movimentacao
					aMov[Len(aMov),04] := SD7->D7_DATA    //Data da Movimentacao
					aMov[Len(aMov),05] := ""              //X = Estornado
					aMov[Len(aMov),06] := ""              //Motivo da Rejeicao
					aMov[Len(aMov),07] := aRetQIE[2]      //Observacao
					aMov[Len(aMov),08] := SD7->D7_QTSEGUM //Quantidade na 2a Unidade de Medida
					aMov[Len(aMov),09] := " "			   //Endereco
					aMov[Len(aMov),10] := " " 			   //Numero de Serie
					aMov[Len(aMov),11] := " " 			   //Servico
					aCM := PegaCMD1()
					fGravaCQ(SD7->D7_PRODUTO,SD7->D7_NUMERO,.F.,aMov,aCM)
						
				EndIf
	        EndIf
			     
			RestArea(aAreaSD1)
			RestArea(aAreaSD7)
	    EndIf
	EndIf
	                             
	//Ponto de Entrada, apos da gravacao dos dados
	If lQeMatFin .And. lImportacao
		ExecBlock("QEMATFIN",.F.,.F.)
	EndIf	

EndIf

//P.E. apos a gravacao da Entrada no QEP (Inconsistencias) ou QEK (Entradas)
If ExistBlock("QEGRVALL")
	ExecBlock("QEGRVALL",.F.,.F.)
EndIf

//Retorna a area corrente
RestArea(aAreaAnt)

Return(aRetQie)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁqGrvIncEntЁ Autor ЁPaulo Emidio de Barros Ё Data Ё23/04/2001Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Grava as inconsistencias encontradas na gravacao da EntradaЁ╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpA1: Array com os dados                                  Ё╠╠
╠╠Ё          Ё ExpC1: Mensagem de erro                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё .T.                                                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё qAtuMatQie												  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function qGrvIncEnt(aDadosQie,cMsgLap)
Local cSeekQEP 
Local cTamLot    := PadR(aDadosQie[21],TamSX3("QEK_TAMAMO")[1]) //Quantidade           
Local cTamLotOri := PadR(aDadosQie[27],TamSX3("QEK_LOTORI")[1]) //Quantidade do Lote Original          
Local cTamAmo
Local cAviso     := ""
Local nTamLote   := TamSX3("QEK_LOTE")[1]
Local cLoteQie   := " "
Local nOrdQEP    := QIndQEP() //Verifica se o indice 2 do QEP esta definido 
Local nMvDiAtr   := 0
Local cMvCoDia   := ""
Local nDiasAtr   := 0 
Local lNewQEP    := .T.                                                                
cLoteQie := PadR(AllTrim(aDadosQie[17])+AllTrim(aDadosQie[18]),nTamLote)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chave de pesquisa da Entrada								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOrdQEP == 1
	cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+DtoS(aDadosQie[05])+cLoteQie
Else
	cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+DtoS(aDadosQie[05])+cLoteQie+aDadosQie[19]
EndIf  

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atribui o tamanho do Lote ao tamanho da Amostra, somente paraЁ
//Ё apontar a inconsistencia, o tamanho da amostra sera calculadoЁ
//Ё de acordo com o Plano de amostragem definido.				 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//Ponto de Entrada para formatar o Tamanho da Amostra na Inconsistencia
If ExistBlock("QEINCAMO")
	cTamAmo := ExecBlock("QEINCAMO",.F.,.F.)
Else
	cTamAmo := cTamLot
EndIf  

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o numero maximo de dias em atraso					 Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nMvDiAtr := GetMv("MV_QDIAIPO")
			
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se os dias de atraso sera considerado				 Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cMvCoDia := GetMv("MV_QCONDIA")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Considera o menor numero de dias em atraso, entre o parame-  Ё	
//Ё tro e o informado.							 				 Ё	
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nDiasAtr := aDadosQie[23]

If DataValida(aDadosQie[5]-nDiasAtr+1) >= aDadosQie[5]
	nDiasAtr := 0	
Else
	If cMvCoDia == "S"
		nDiasAtr := If(Abs(nDiasAtr)>nMvDiAtr,If(nDiasAtr<0,0-nMvDiAtr,nMvDiAtr),nDiasAtr)
	EndIf
EndIf		

QEP->(dbSetOrder(nOrdQEP))
If !QEP->(DBSeek(cSeekQEP))
	lNewQEP := .T.
Else       
	lNewQEP := qVerifInc(nOrdQEP,cSeekQEP,aDadosQie[1],aDadosQie[2],cLoteQie) 
EndIf          

If lNewQEP 
	RecLock("QEP",.T.)
	QEP->QEP_FILIAL := xFilial("QEP")
	QEP->QEP_CODTAB := "2" 
	QEP->QEP_FORNEC := aDadosQie[11]
	QEP->QEP_LOJFOR := aDadosQie[12]
	QEP->QEP_PRODUT := aDadosQie[15]
	QEP->QEP_DTENTR := aDadosQie[05]
	QEP->QEP_LOTE   := cLoteQie
Else
	RecLock("QEP",.F.)
EndIf

QEP->QEP_HRENTR := aDadosQie[28] 
QEP->QEP_TAMLOT := cTamLot
QEP->QEP_LOTORI := cTamLotOri
QEP->QEP_TAMAMO := cTamAmo
QEP->QEP_DOCENT := aDadosQie[13]
QEP->QEP_NTFISC := aDadosQie[01]
QEP->QEP_SERINF := aDadosQie[02]
QEP->QEP_TIPONF := aDadosQie[03] 				 
QEP->QEP_DTNFIS := aDadosQie[04]
QEP->QEP_TIPDOC := aDadosQie[06]
QEP->QEP_ITEMNF := aDadosQie[07] 				 
QEP->QEP_REMITO := aDadosQie[08] 				 
QEP->QEP_PEDIDO := aDadosQie[09]
QEP->QEP_ITEMPC := aDadosQie[10]
QEP->QEP_LOCORI := aDadosQie[16] 				
QEP->QEP_NUMSEQ := aDadosQie[19]
QEP->QEP_CERFOR := aDadosQie[20]
QEP->QEP_DIASAT := nDiasAtr
QEP->QEP_PRECO  := aDadosQie[22]     
QEP->QEP_SOLIC  := aDadosQie[14]
QEP->QEP_TES    := aDadosQie[24]
QEP->QEP_ORIGEM := aDadosQie[25]
QEP->QEP_IMPORT := aDadosQie[26]
QEP->QEP_ERRO   := cMsgLap
QEP->QEP_DTIMP  := dDataBase
QEP->QEP_EXCLUI := "N"
If !Empty(aDadosQie[14]) 				
	QEP->QEP_FILMAT := xFilial('QAA')          
EndIf                    
MsUnLock()
FkCommit()
                                              
                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё P.E. executado apos a gravacao das Inconsistencias			 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("QEGRVINC")
	ExecBlock("QEGRVINC",.F.,.F.)
EndIf
 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe a Mensagem de Inconsistencias registros provenientes   Ё
//Ё da Integracao											 	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If SubStr(cModulo,1,1) # "Q"
	cAviso := STR0020+AllTrim(QEP->QEP_PRODUT)+ STR0021+AllTrim(QEP->QEP_NTFISC)+" / "+AllTrim(QEP->QEP_ITEMNF)  //"Produto : " ### " NF/Item : "
	Aviso(STR0022,cAviso+' => '+AllTrim(QEP->QEP_ERRO),{"Ok"}) //"SIGAQIE - Ocorrencia na Integracao "
EndIf

//Armazena o flag que indica a inconsistencia               
lInconsistencia := If(!lInconsistencia,.T.,lInconsistencia)

Return(NIL)                                           

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁqdelMatQieЁ Autor ЁPaulo Emidio de Barros Ё Data Ё10/05/2001Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Realiza a exclusao das Entradas							  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ EXPA = Array contendo os dados enviados na Integracao	  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё .T. = Realizou a Exclusao, .F. nao Realizou				  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё qAtuMatQie()												  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/             
Function qDelMatQie(aDadosQie)                                 
Local cLoteQie := ""
Local cSeekQEK := ""
Local cSeekQEP := ""
Local lRetDel  := .F.
Local nOrdQEK  := 0
Local nOrdQEP  := QIndQEP() //Verifica se o indice 2 do QEP esta definido
Local nTamLote := TamSX3("QEK_LOTE")[1]

cLoteQie := PadR(AllTrim(aDadosQie[17])+AllTrim(aDadosQie[18]),nTamLote)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona o registro da Entrada no QEK 						 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nOrdQEK  := 6
cSeekQEK := cLoteQie

If !Empty(aDadosQie[24]) //TES
	If !Rastro(aDadosQie[15]) //Produto
		nOrdQEK  := 10
		cSeekQEK := aDadosQie[11]+aDadosQie[12]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+aDadosQie[19] 
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui a Entrada gravada no QEP	(Importada)					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cLoteQie) 
	If nOrdQEP == 1
		cSeekQEP := xFilial("QEP")+"1"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+DtoS(aDadosQie[05])  
		cCpoSeek := "QEP->(QEP_FILIAL+QEP_CODTAB+QEP_FORNEC+QEP_LOJFOR+QEP_PRODUT+dTos(QEP_DTENTR))"
    Else
		cSeekQEP := xFilial("QEP")+"1"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+DtoS(aDadosQie[05])//+cLoteQie+aDadosQie[19]
		cCpoSeek := "QEP->(QEP_FILIAL+QEP_CODTAB+QEP_FORNEC+QEP_LOJFOR+QEP_PRODUT+QEP_NTFISC+QEP_SERINF+QEP_ITEMNF+QEP_TIPONF+DtoS(QEP_DTENTR))"
	EndIf

	QEP->(dbSetOrder(nOrdQEP))
	QEP->(MsSeek(cSeekQEP))
	If AllTrim(QEP->QEP_ORIGEM) $ 'MATA103/MATA101N' //Documento de Entrada
		While QEP->(!Eof()) .And. &cCpoSeek==cSeekQEP
			If AllTrim(aDadosQie[20])==AllTrim(QEP->QEP_CERFOR)
				RecLock("QEP",.F.)
				dbDelete()
				MsUnLock()
			EndIf
			QEP->(dbSkip())
		EndDo
	EndIf
Else
	If nOrdQEP == 1
		cSeekQEP := xFilial("QEP")+"1"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+DtoS(aDadosQie[05])+cLoteQie
    Else
		cSeekQEP := xFilial("QEP")+"1"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+DtoS(aDadosQie[05])//+cLoteQie+aDadosQie[19]
	EndIf

	QEP->(dbSetOrder(nOrdQEP))
	If QEP->(MsSeek(cSeekQEP))
		RecLock("QEP",.F.)
		dbDelete()
		MsUnLock()
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui a inconsistencia da Entrada no QEP (Inconsistencia)	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cLoteQie) 

	If nOrdQEP == 1
		cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+DtoS(aDadosQie[05])
		cCpoSeek := "QEP->(QEP_FILIAL+QEP_CODTAB+QEP_FORNEC+QEP_LOJFOR+QEP_PRODUT+dTos(QEP_DTENTR))"
	Else
		cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+DtoS(aDadosQie[05])//+cLoteQie+aDadosQie[19]
		cCpoSeek := "QEP->(QEP_FILIAL+QEP_CODTAB+QEP_FORNEC+QEP_LOJFOR+QEP_PRODUT+QEP_NTFISC+QEP_SERINF+QEP_ITEMNF+QEP_TIPONF+DtoS(QEP_DTENTR))"
	EndIf
	
	QEP->(dbSetOrder(nOrdQEP))
	QEP->(MsSeek(cSeekQEP))
	If AllTrim(QEP->QEP_ORIGEM) $ 'MATA103/MATA101N' //Documento de Entrada
		While QEP->(!Eof()) .And. &(cCpoSeek) == cSeekQep
			If AllTrim(aDadosQie[20])==AllTrim(QEP->QEP_CERFOR)
				RecLock("QEP",.F.)
				dbDelete()
				MsUnLock()
			EndIf			
			QEP->(dbSkip())
		EndDo
	EndIf
Else
	If nOrdQEP == 1
		cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+DtoS(aDadosQie[05])+cLoteQie
	Else
		cSeekQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+DtoS(aDadosQie[05])//+cLoteQie+aDadosQie[19]
	EndIf

	QEP->(dbSetOrder(nOrdQEP))
	If QEP->(MsSeek(cSeekQEP))
		RecLock("QEP",.F.)
		dbDelete()
		MsUnLock()
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a exclusao da Entrada								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If GetMV("MV_QLOTUNI") == "S"
	If !Empty(AllTrim(cLoteQie))
		nOrdQEK  := 6
		cSeekQEK := cLoteQie
	EndIf
Else
	nOrdQEK  := 14
	cSeekQEK := aDadosQIE[11]+aDadosQIE[12]+aDadosQIE[15]+aDadosQIE[1]+aDadosQIE[2]+DTOS(aDadosQIE[5])//+PADR(aDadosQIE[17]+aDadosQIE[18],16)+aDadosQIE[19]
Endif

QEK->(dbSetOrder(nOrdQEK))
If QEK->(MsSeek(xFilial("QEK")+cSeekQEK)) 
	While !QEK->(Eof()) .and. QEK->QEK_FILIAL+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+DTOS(QEK->QEK_DTENTR) ==;
		xFilial("QEK")+aDadosQIE[11]+aDadosQIE[12]+aDadosQIE[15]+aDadosQIE[1]+aDadosQIE[2]+DTOS(aDadosQIE[5])
		If Alltrim(QEK->QEK_NUMSEQ) == Alltrim(aDadosQIE[19])
			If !Empty(cLoteQie)
				If Alltrim(cLoteQie) == Alltrim(QEK->QEK_LOTE)					
					lRetDel := .T.
					Exit
				Endif
			Else
				lRetDel := .T.
				Exit
			Endif							
		Endif
		QEK->(dbSkip())
	Enddo
	
	If lRetDel
		If Empty(cLoteQie)
			cLoteQie := QEK->QEK_LOTE
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Exclui as amarracoes das Entradas					   		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		A200ExEn()
				
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Exclue as medicoes com todas as suas amarracoes				 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		QieDelMed(QEK->QEK_PRODUT,QEK->QEK_REVI,QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_DTENTR,QEK->QEK_LOTE,QEK->QEK_NTFISC,QEK->QEK_SERINF,QEK->QEK_ITEMNF,QEK->QEK_TIPONF)
					
		RecLock("QEK",.F.)
		QEK->(dbDelete())
		MsUnLock()    
	EndIf  

EndIf	

Return(lRetDel) 

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤ao	 ЁQieDelMed Ё Autor Ё Paulo Emidio de BarrosЁ Data Ё 05/02/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤ao Ё Realiza a exclusao das amarracoes referentes as Entradas   Ё╠╠
╠╠Ё			 Ё inspecionadas.										      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё QieDelMed												  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ EXPC1 = Codigo do Produto						 	      Ё╠╠
╠╠Ё			 Ё EXPC2 = Revicao do Produto   							  Ё╠╠
╠╠Ё			 Ё EXPC3 = Codigo do Fornecedor								  Ё╠╠
╠╠Ё			 Ё EXPC4 = Loja do Fornecedor                      			  Ё╠╠
╠╠Ё			 Ё EXPD1 = Data de Entrada                                    Ё╠╠
╠╠Ё			 Ё EXPC5 = Numero do Lote             						  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё Nenhum													  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAQIE													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QieDelMed(cProduto,cRevi,cFornece,cLoja,dEntrada,cLote,cNota,cSerie,cItem,cTipNF)
Local aOldArea   := GetArea()             
Local cChvMed    := ""
Local cCarEns    := ""
Local aCpoQNC    := {}
Local cChvQEL    := ""
Local cChvQER    := ""
Local l215ExcQNC := ExistBlock("Q215QNCE") 
Local cSeekQEL   :=  ""
Local nSetQER    := 1
Local cSeekQER   := ""
Local lQReinsp   := QieReinsp()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a exclusao das medicoes associadas a Entrada Inspecionada  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cNota	   := cNota+cSerie+cItem
cChvQER    := xFilial("QER")+cProduto+cRevi+cFornece+cLoja+cNota+cTipNF+cLote 
cSeekQER   := "(QER_FILIAL+QER_PRODUT+QER_REVI+QER_FORNEC+QER_LOJFOR+QER_NISERI+QER_TIPONF+QER_LOTE)"
nSetQER    := 5

dbSelectArea("QER")
dbSetOrder(nSetQER)
MsSeek(cChvQER,.T.)
While &cSeekQER == cChvQER

	If lQReinsp
		If QER->QER_NUMSEQ <> QEK->QEK_NUMSEQ
			dbSelectArea("QER")	
		    dbSkip()
		    Loop
		 Endif
	Endif

	cChvMed := QER->QER_CHAVE
	cCarEns := QA_CartEns(QER->QER_ENSAIO)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza a exclusao das medicoes mensuraveis						   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cCarEns # "TXT" 

		dbSelectArea("QES")
		dbSetOrder(1)
		If MsSeek(xFilial("QES")+cChvMed)
			While !Eof() .And. QES->QES_FILIAL+QES->QES_CODMED == xFilial("QES")+cChvMed 
				RecLock("QES",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Realiza a exclusao das medicoes texto							   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("QEQ")
		dbSetOrder(1)
		If MsSeek(xFilial("QEQ")+cChvMed)
			While !Eof() .And. QEQ->QEQ_FILIAL+QEQ->QEQ_CODMED == xFilial("QEQ")+cChvMed
				RecLock("QEQ",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza a exclusao dos Instrumentos associados as medicoes  	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("QET")
	dbSetOrder(1)
	If MsSeek(xFilial("QET")+cChvMed)
		While !Eof() .And. QET->QET_FILIAL+QET->QET_CODMED == xFilial("QET")+cChvMed
			RecLock("QET",.F.)
			dbDelete()
			MsUnLock()
			dbSkip()
		EndDo
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza a exclusao das nao-conformidades associadas as medicoes	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("QEU")
	dbSetOrder(1)
	If MsSeek(xFilial("QEU")+cChvMed)
		While !Eof() .And. QEU->QEU_FILIAL+QEU->QEU_CODMED == xFilial("QEU")+cChvMed
		
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Integracao SIGAQIE x SIGAQNC									   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !l215ExcQNC 
				If !Empty(QEU->QEU_CODNC) .And. !Empty(QEU->QEU_REVNC)
					aCpoQNC := {}
				    Aadd(aCpoQNC,xFilial("QI2"))
					Aadd(aCpoQNC,QEU->QEU_CODNC) 
					Aadd(aCpoQNC,QEU->QEU_REVNC)
					QNCGERA(2,aCpoQNC)
				EndIf	       
			EndIf
			
			RecLock("QEU",.F.)
			dbDelete()
			MsUnLock()
	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Realiza a Exclusao da Cronica das nao-conformidades				   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			QA_DelTxt(QEU->QEU_CHAVE,"QIEA210C")	
	
			dbSelectArea("QEU")
			dbSkip()           
			
		EndDo
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza a Exclusao da medicao									   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("QER")	
	RecLock("QER",.F.)
	dbDelete()
	MsUnLock()
    dbSkip()
    
EndDo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a Exclusao dos Laudos									   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("QEL")
cNota := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
dbSetOrder(3)
cChvQEL := xFilial("QEL")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+cNota+QEK->QEK_TIPONF+;
	dTos(QEK->QEK_DTENTR)+QEK->QEK_LOTE
cSeekQEL   :=  "(QEL_FILIAL+QEL->QEL_FORNEC+QEL->QEL_LOJFOR+QEL->QEL_PRODUT+QEL->QEL_NISERI+QEL->QEL_TIPONF+dTos(QEL->QEL_DTENTR)+QEL->QEL_LOTE)"	

If MsSeek(cChvQEL)
	While !Eof() .And. &(cSeekQEL)==cChvQEL	

		If lQReinsp
			If QEL->QEL_NUMSEQ <> QEK->QEK_NUMSEQ
				dbSelectArea("QEL")	
			    dbSkip()
			    Loop
			 Endif
		Endif
	
		//Exclui o Historico do Laudo
		MsMM(QEL->QEL_CHAVEH,,,,2)
		
		RecLock("QEL",.F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	EndDo
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a exclusao das NNCs vinculadas					   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea('QEM')
dbSetOrder(1)
MsSeek( xFilial("QEM")+QEK->QEK_NNC )
While !EOF() .And. QEM_FILIAL+QEM_NNC == xFilial("QEM")+QEK->QEK_NNC

	//Exclui as observacoes das NNCS das Entradas  
	If !Empty(QEM->QEM_CHAVE)                        
		QA_DelTxt(QEM->QEM_CHAVE,"QIEA220 ")   
	EndIf

	dbSelectArea("QEM")
	RecLock("QEM",.F.,.T.)
	dbDelete()
	MsUnLock()
	dbSkip()
	
EndDo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclue o Numero da Notificacao da Nao-conformidade		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RecLock("QEK",.F.)
QEK->QEK_NNC    := " "
QEK->QEK_NNCINV := " "
MsUnLock()
            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui o texto da Liberacao Urgente								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If QEK->QEK_SITENT $ "14678"
	QA_DelTxt(QEK->QEK_CHAVE1,"QIEA210U") 
EndIf

RestArea(aOldArea)
Return(NIL)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤ao	 ЁQieIntEst Ё Autor Ё Paulo Emidio de BarrosЁ Data Ё 16/04/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤ao Ё Verifica se a Entrada Inspecionada / a Inspecionar possui  Ё╠╠
╠╠Ё			 Ё Integracao com o Materiais (Movimentacao de Estoque).      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё QieIntEst(EXPC1,EXPC2)									  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ EXPC1 = Codigo do Produto						 	      Ё╠╠
╠╠Ё			 Ё EXPC2 = TES utilizada na Entrada Inspecionada			  Ё╠╠
╠╠Ё			 Ё EXPC3 = Tipo do Documento								  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё EXPL1 = .T. possui integracao							  Ё╠╠
╠╠Ё			 Ё 		   .F. nao possui integracao						  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAQIE													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QieIntEst(cProduto,cTes,cTipDoc)
Local lRetorno := .F.
Local aAreaAnt := GetArea()
Local cUser    := QAXUser(__cUserId,5)

cTipDoc := If(cTipDoc==NIL,'',cTipDoc)

If !Empty(cTes)
	SF4->(dbSetOrder(1))
	If SF4->(MsSeek(xFilial("SF4")+cTes))
		If SF4->F4_ESTOQUE == "S"
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+cProduto)) .And. RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q" 
				lRetorno := .T.
			EndIf	
		EndIf
	EndIf                   
Else
	If AllTrim(cTipDoc) == "TR" .OR. AllTrim(cTipDoc) == "IN"
		lRetorno := .T.
	EndIf	
EndIf

If lRetorno .And. Existblock("QE215BCQ")
	lRetorno := ExecBlock("QE215BCQ",.F.,.F.,{cProduto,cTes,cTipDoc,cUser})
Endif
                            
RestArea(aAreaAnt)

Return(lRetorno)

/*                
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё  QieNumLote  Ё Paulo Emidio de Barros    Ё Data Ё01/10/2002Ё╠╠
╠╠цддддддддддеддддддддддддддадддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Gera um Numero Sequencial do Lote sem controle de Rastrea- Ё╠╠
╠╠Ё          Ё bilidade													  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QieNumLote()												  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё GENERICO													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QieNumLote(cProduto)
Local aAreaAnt := GetArea()
Local cLoteCtl := " "
Local cNumLote := " "
                    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Compatibiliza a Numeracao Sequencial do Lote com Materiais		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//Sequencia do Sub-Lote
cNumLote := If(cNumLote==NIL,NextLote(cProduto,"S"),If(Empty(cNumLote),NextLote(cProduto,"S"),cNumLote))

//Sequencia do Lote
cLoteCtl := If(Empty(cLoteCtl),NextLote(cProduto,"L",cNumLote),cLoteCtl)
cLoteCtl := If(Empty(cLoteCtl),"AUTO"+cNumLote,cLoteCtl)

RestArea(aAreaAnt)

Return(cLoteCtl)

/*                
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё   QieTipoNF  Ё Paulo Emidio de Barros    Ё Data Ё01/10/2002Ё╠╠
╠╠цддддддддддеддддддддддддддадддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Verifica se o Tipo da Nota Fiscal sofrea Inspecao pelo	  Ё╠╠
╠╠Ё          Ё Quality													  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QieTipoNF(cTipoNf,cTES)									  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё GENERICO													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QieTipoNF(cTipoNf,cTES)
Local lRetorno   := .F.
Local aAreaSF4

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё	Verifica os Tipos das Notas Fiscais de Entradas e o tratamento de/em Poder  Ё
//Ё de/em Terceiros, indica se os mesmos serao enviados para Inspecao.          Ё
//цддддддддддддддддддддддддддбддддддддддддддддбддддддддддддддддбдддддддддддддддд╢
//Ё     Tipo Nota Fiscal     Ё     Normal     Ё Beneficiamento Ё   Devolucao    Ё
//цддддддддддддддддддддддддддеддддддддддддддддеддддддддддддддддедддддддддддддддд╢
//Ё <N>ao utiliza Poder Terc Ё  	SIM       Ё 	 SIM	   Ё	  SIM	    Ё
//Ё Poder Terc <R>emessa     Ё  	SIM       Ё 	 SIM	   Ё	  SIM	    Ё
//Ё Poder Terc <D>evolucao   Ё      SIM    	  Ё  	 SIM       Ё	  SIM	    Ё
//юддддддддддддддддддддддддддаддддддддддддддддаддддддддддддддддадддддддддддддддды
Local cIntNfeNor := GetMv("MV_QNFENOR") //Tipo da Nota Fiscal Normal a ser considerada
Local cIntNfeBen := GetMv("MV_QNFEBEN") //Tipo da Nota Fiscal Beneficiamento a ser considerada
Local cIntNfeDev := GetMv("MV_QNFEDEV") //Tipo da Nota Fiscal Devolucao a ser considerada

If !Empty(cTES)
	aAreaSF4 := SF4->(GetArea())
	SF4->(dbSetOrder(1))
	If SF4->(MsSeek(xFilial("SF4")+cTES)) 
                                               
		If cTipoNF == "N"
			If (SF4->F4_PODER3=="N" .And. SubStr(cIntNfeNor,1,1)=="N") .Or.;
				(SF4->F4_PODER3=="R" .And. SubStr(cIntNfeNor,2,1)=="N") .Or.;
				(SF4->F4_PODER3=="D" .And. SubStr(cIntNfeNor,3,1)=="N")
				lRetorno := .T.
			EndIf	           
		
		ElseIf cTipoNF == "B"
			If (SF4->F4_PODER3=="N" .And. SubStr(cIntNfeBen,1,1)=="N") .Or.;
				(SF4->F4_PODER3=="R" .And. SubStr(cIntNfeBen,2,1)=="N") .Or.;
				(SF4->F4_PODER3=="D" .And. SubStr(cIntNfeBen,3,1)=="N")
				lRetorno := .T.
			EndIf	

		ElseIf cTipoNF == "D"
			If (SF4->F4_PODER3=="N" .And. SubStr(cIntNfeDev,1,1)=="N") .Or.;
				(SF4->F4_PODER3=="R" .And. SubStr(cIntNfeDev,2,1)=="N") .Or.;
				(SF4->F4_PODER3=="D" .And. SubStr(cIntNfeDev,3,1)=="N")
				lRetorno := .T.
			EndIf	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддp©
		//ЁIgnora notas fiscal de complemento de preco, despesa de importacao, conhecimento de frete e entrada.Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддpы
		ElseIf cTipoNF $ "CIP"
			lRetorno := .T.
		EndIf

	EndIf                         
	RestArea(aAreaSF4)

EndIf

Return(lRetorno)

/*                
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё QieTrataLote Ё Paulo Emidio de Barros    Ё Data Ё30/06/2003Ё╠╠
╠╠цддддддддддеддддддддддддддадддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Realiza o tratamento do Numero do Lote enviando para a 	  Ё╠╠
╠╠Ё          Ё Entrada a Inspecionar.									  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QieTrataLote(cProduto,cLote,cSubLote,nOpc)				  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё GENERICO													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QieTrataLote(cProduto,cLote,cSubLote,nOpc)
Local nTamLote := TamSx3("D3_LOTECTL")[1]+TamSx3("D3_NUMLOTE")[1]
Local cRetorno := " "                                   

If AllTrim(aDadosQie[25]) <> "QIEA183" //nao consiste as importacoes

	//Trata o Numero do Lote sequencialmente, caso o produto possua Rastreabilidade
	If GetMV('MV_PRXLOTE', .T.) .AND. Rastro(cProduto,"L")  
		cSubLote := " "
	EndIf

	//Gera o Numero Sequencial para o Lote sem o controle da Rastreabilidade
	If Empty(cLote) .And. Empty(cSubLote)          
	
		If nOpc <> 2 //Nao gera novo numero na exclusao            
			If !Rastro(cProduto)
				cLote := QieNumLote(cProduto)     
			EndIf
		EndIf
	EndIf                                                          

EndIf

//Retira os espacos em branco do Numero do Lote
cRetorno := PadR(AllTrim(cLote)+AllTrim(cSubLote),nTamLote) 

// Caso o sublote esteja zerado gero um  novo  numero de lote
If GetMV('MV_PRXLOTE', .T.) .AND. Rastro(cProduto,"L") .AND. AllTrim(FunName()) == "MATA340" 
	cRetorno := PadR(NextLote(cProduto,"L"),nTamLote)
EndIf

Return(cRetorno)

/*                
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё QIndQEP		Ё Paulo Emidio de Barros    Ё Data Ё30/06/2003Ё╠╠
╠╠цддддддддддеддддддддддддддадддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Verifica se o indice 2 no QEP esta criado.				  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QIndQEP()												  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё QIEXFUNA													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QIndQEP()
Local nRetorno := 1
SIX->(dbSetOrder(1))
SIX->(dbSeek("QEP2"))
If SIX->(!Eof())
	nRetorno := 2
EndIf
Return(nRetorno) 

/*                
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё qVerifInc    Ё Cleber Souza              Ё Data Ё30/06/2003Ё╠╠
╠╠цддддддддддеддддддддддддддадддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Verifica se existe inconsistencias com mesmo lote mais .	  Ё╠╠
╠╠ЁDescri┤└o Ё com numeto de nota fiscal diferente.						  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё qVerifInc()												  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё QIEXFUNA													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function qVerifInc(nOrdQEP,cSeekQEP,cNota,cSerie,cLoteQie)   

Local cCompQEP  := ""
Local lReturn   := .T.
Local nRecQEP   := QEP->(Recno())    

dbSelectArea("QEP")
dbSetOrder(nOrdQEP)
If !dbSeek(cSeekQEP)
	lReturn := .F.
Else
	If nOrdQEP == 1
		cCompQEP := xFilial("QEP")+"2"+QEP->QEP_FORNEC+QEP->QEP_LOJFOR+QEP->QEP_PRODUT+DtoS(QEP->QEP_DTENTR)+QEP->QEP_LOTE 
	Else
		cCompQEP := xFilial("QEP")+"2"+aDadosQie[11]+aDadosQie[12]+aDadosQie[15]+aDadosQie[01]+aDadosQie[02]+aDadosQie[07]+aDadosQie[03]+DtoS(aDadosQie[05])+cLoteQie+aDadosQie[19]
	EndIf 	                    

	While QEP->(!EOF()) .and. cCompQEP==cSeekQEP
		//Verifica se esta sendo feito recebimento parcial para o mesmo lote no mesmo dia.
		If Alltrim(QEP->QEP_NTFISC)+Alltrim(QEP->QEP_SERINF) == Alltrim(cNota)+Alltrim(cSerie)	
			lReturn := .F.
			nRecQEP   := QEP->(Recno())
			Exit
		EndIf
		QEP->(dbSkip())
	EndDo			            
Endif
QEP->(dbGoTo(nRecQEP))

Return(lReturn)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁQAtuB12QE6    Ё Sergio S. Fuzinaka        Ё Data Ё 07.07.08 Ё╠╠
╠╠цддддддддддеддддддддддддддадддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao ЁAtualizacao dos dados do produto da tabela QE6 pela SB1.    Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGENERICO                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function QAtuB12QE6()

Local aArea			:= GetArea()
Local aAreaQE6		:= QE6->(GetArea())
Local cProdOri		:= SB1->B1_COD		//Produto Origem
Local cUnidOri		:= SB1->B1_UM		//Unidade Origem
Local cRevOri		:= ""				//Revisao Origem
Local cDesPro		:= SB1->B1_DESC		//Descricao Produto

Private cProdDes	:= SB1->B1_COD		//Produto Destino
Private cRevDes		:= ""				//Revisao Destino
Private aItem		:= {STR0036,STR0037,STR0038,STR0039} 	//"Informado" ### "Produto Origem " ### "Produto Destino" ### "Produtos"
Private cOriDes  	:= aItem[2]			//Produto Origem - Padrao

QE6->(dbSetOrder(1))	//Indice de Revisao Invertida
If QE6->(dbSeek(xFilial("QE6")+cProdOri))

	If QE6->QE6_UNMED1 <> cUnidOri
	
		cRevOri := QE6->QE6_REVI
		cRevDes := Soma1(cRevOri)

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o Produto/Revisao possui Entradas Cadastradas          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If A010MePR(cProdOri,cRevOri,.F.,.F.)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gera Nova Revisao                                              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			QIEDupEsp(cProdOri,cRevOri,cProdDes,cRevDes,cDesPro,dDataBase)
			QE6->(dbSetOrder(1))	//Indice de Revisao Invertida
			QE6->(dbSeek(xFilial("QE6")+cProdOri))
		Endif	

		If QE6->QE6_PRODUT == cProdOri
			RecLock("QE6",.F.)
			QE6->QE6_UNMED1 := cUnidOri
			QE6->QE6_UNAMO1 := cUnidOri
			MsUnlock()
		Endif

		If SB1->B1_UM <> cUnidOri
			RecLock("SB1",.F.)
			SB1->B1_UM := cUnidOri
			MsUnlock()
		Endif
		
	Endif

Endif

RestArea(aAreaQE6)
RestArea(aArea)

Return

/*/{Protheus.doc} QIEAtuSB1
	Atualiza o Cadastro de Produtos (SB1), a partir das Especificacoes do Produto
	@author celio.pereira - guilherme.bertoldi
	@since 07/04/2022
	@return lRet se nЦo existir na SB1 o produto ele sera criado
	/*/
Function QIEAtuSB1(lPosicionado,cProd,cRev,cDesc,cRastro,cLocPad)
Local cAlias         := " "
Local lRet           := .T.
Default lPosicionado := .F.

cAlias:= If(lPosicionado,"QE6","M")

SB1->(dbSelectArea("SB1"))
SB1->(dbSetOrder(1))
If !(SB1->(dbSeek(xFilial("SB1")+cProd)))
	QIECRIASB1("DUPLICAR", cProd, cDesc, cAlias,cRastro,cLocPad)
	lRet := .F.
EndIf
Return(lRet)


/*/{Protheus.doc} QIECRIASB1
	Executa o MATA010 via MsExecAuto
	@author celio.Pereira - guilherme.Bertoldi
	@since 07/04/2022
	@return lRet - .T. (gravado com sucesso), ou .F. (ocorreu um erro)
	/*/
Function QIECRIASB1(cOperacao, cProd, cDesc, cAlias,cRastro,cLocPad)
Local aCab          := {}
Local lRet          := .T.
Local lAltProd := If(GetMv("MV_QALTPRO",.F.,"1") == "1",.T.,.F.)
Private lMsErroAuto := .F.


If cOperacao == 'NOVO'
        aCab :={{"B1_FILIAL" , xFilial("SB1")            , NIL},;
                {"B1_COD"    , cProdDes                  , NIL},;
                {"B1_DESC"   , AllTrim(M->QE6_DESCPO)    , NIL},;
                {"B1_UM"     , M->QE6_UNMED1           	 , NIL},;
                {"B1_LOCPAD" , cLocPad                   , NIL},;
                {"B1_TIPO"   , M->QE6_TIPO             	 , NIL},;
                {"B1_DATREF" , dDataBase                 , NIL},;
                {"B1_UREV"   , dDataBase                 , NIL},;
                {"B1_RASTRO" , cRastro                   , NIL},;
                {"B1_MRP"    , "S"                       , NIL},;
                {"B1_TIPOCQ" , If(lAltProd, "Q", cTipoCQ), NIL}}

ElseIf cOperacao == 'DUPLICAR'
        aCab :={{"B1_FILIAL" , xFilial("SB1")            , NIL},;
                {"B1_COD"    , cProdDes                  , NIL},;
                {"B1_DESC"   , AllTrim(cDesPro)          , NIL},;
                {"B1_UM"     ,  &(cAlias+"->QE6_UNMED1") , NIL},;
                {"B1_LOCPAD" , cLocPad                   , NIL},;
                {"B1_TIPO"   , &(cAlias+"->QE6_TIPO")    , NIL},;
                {"B1_DATREF" , dDataBase                 , NIL},;
                {"B1_UREV"   , dDataBase                 , NIL},;
                {"B1_RASTRO" , cRastro                   , NIL},;
                {"B1_MRP"    , "S"                       , NIL},;
                {"B1_TIPOCQ" , If(lAltProd, "Q", cTipoCQ), NIL}}
EndIf

MSExecAuto({ |x,y| MATA010(x, y)}, aCab, 3)

If lMsErroAuto
	Mostraerro()
	lRet := .f.
Else
	If RetArqProd(cProdDes) .AND. !lMsErroAuto
	    aArea := GetArea()
		Reclock("SBZ", .T.)
	   		SBZ->BZ_FILIAL := xFilial("SBZ")            
	        SBZ->BZ_COD     := cProdDes               
	        SBZ->BZ_LOCPAD  := cLocPad                 
	        SBZ->BZ_DATREF  := dDataBase                
	        SBZ->BZ_MRP     := "S"                       
	        SBZ->BZ_TIPOCQ  := If(lAltProd, "Q", "M") 
		MsUnlock("SBZ")
	    RestArea(aArea)
	EndIf
EndIf

Return lRet

