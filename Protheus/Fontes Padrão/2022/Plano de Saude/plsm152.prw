#Include "plsm152.ch"
#Include "protheus.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSM152  Ё Autor Ё Cesar Valadao         Ё Data Ё 24/05/04 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Pagamento das Comissoes                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLSM152()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAPLS                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Alteracoes desde sua construcao inicial                               Ё╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё 01/06/06 Ё99557 Ё Sandro H.   Ё Gravacao do SE2 pela rotina padrao do Ё╠╠
╠╠Ё          Ё      Ё             Ё PLS (PLSTOSE2). Ajustes na gravacao   Ё╠╠
╠╠Ё          Ё      Ё             Ё do arquivo de exportacao para a folha Ё╠╠
╠╠Ё          Ё      Ё             Ё de pagamento. Informacao do Codigo de Ё╠╠
╠╠Ё          Ё      Ё             Ё Retencao do IR para PJ e PF.          Ё╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
 
Function PLSM152()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nOpca 		:= 0
Local aSays 		:= {}, aButtons := {}
Private cCadastro 	:= Fundesc() //"Pagamento das ComissУes"
Private cPerg       := "PLM152"
Private cLog		:= ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Vetor utilizado para a integracao com a Folha                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private aRotina     := {{ STR0002, "gp150Pes", 0, 1},; //"Pesquisa"
				     	{ STR0003, "gp150Mnt", 0, 2},; //"Visualizar"
				    	{ STR0004, "gp150Mnt", 0, 4},; //"Incluir"
				     	{ STR0005, "gp150Mnt", 0, 4},; //"Alterar"
				    	{ STR0006, "gp150Imp", 0, 6},; //"Listar"
				    	{ STR0007, "gp150Mnt", 0, 5} } //"Excluir"   
				    	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza SX1                                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
CriaSX1()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta texto para janela de processamento                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aSays,STR0008) //"Efetua o pagamento das comissoes conforme parametros informados."
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta botoes para janela de processamento                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aButtons, {  5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 14,.T.,{|| GPEA200(4) } } )
AADD(aButtons, {  1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, {  2,.T.,{|| FechaBatch() }} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe janela de processamento                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FormBatch( cCadastro, aSays, aButtons,, 160 )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa calculo                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nOpca == 1
	msAguarde( {|| Pls152Calc() }, STR0009,"", .T.) //"Pagando ComissУes ..."
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do programa                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLS152CALCЁ Autor Ё Cesar Valadao         Ё Data Ё 05/05/04 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Paga as comissoes                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLS152CALC()                                               Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function PLS152CALC()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local i, dPerIni, dPerFim
Local cQuery, cSQLExec, lAchou
Local aBXQ := {}
Local lFolha := .T.
Local nVlrComis
Local cFile := ""
Local cMV_PLSSRX := GetNewPar("MV_PLSSRX", "999                    999")
Local nVlrSE2
Local cPrefixo
Local cNumero
Local cTipo  
Local cNatureza := ""
Local aCampos
Local aBasesImp
Local cCodRetPJ
Local cCodRetPF
Local cPGCOMIS
Local cMvFORNCOM := GetMv("MV_FORNCOM")
Local cCodUsr    := "" 
Local aItens     := {} 
Local lOK        := .T. 

Private cArquivo, cCodigo, nTotaliza, nEntreArq, cSituacao	// Usadas na funcao GPEA210()  

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё MV_PAR01 - Mes Base Movimento                                              Ё
//Ё MV_PAR02 - Ano Base Movimento                                              Ё
//Ё MV_PAR03 - Operadora                                                       Ё
//Ё MV_PAR04 - Codigo de Retencao do Imposto de Renda para Pessoa Juridica     Ё
//Ё MV_PAR05 - Codigo de Retencao do Imposto de Renda para Pessoa Fisica       Ё
//  MV_PAR06 - Produto
//  MV_PAR07 - Pedido de compra 
//  MV_PAR08 - Tes. Pedido de compra
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)

cMes      := MV_PAR01
cAno      := MV_PAR02
cOper     := MV_PAR03
cCodRetPJ := MV_PAR04
cCodRetPF := MV_PAR05
cProduto  := MV_PAR06 
cTesAux   := MV_PAR07
cCond	  := MV_PAR08 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a Folha de Pagamento esta configurada corretamente.            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cPrefixo := &(GetMv("MV_3DUPREF"))

If  Empty(GetMV("MV_FOLMES"))
	lFolha := .F.
EndIf
If  lFolha .And. GetMV("MV_FOLMES") <> cAno+cMes
	lFolha := .F.
	If  Aviso(STR0010, STR0011+cAno+cMes+; //"Pagamento de ComissУes"###"A folha de pagamento nЦo estА configurada para o Ano/MЙs "
		STR0012, {"Ok", STR0013},3) == 2 //". Se houver vendedores que recebam na Folha de Pagamento, estes valores NцO SERцO ATUALIZADOS!!!"###"Cancelar"
		Return()
	EndIf
EndIf
SRX->(dbSetOrder(1))
If  lFolha .And. ! SRX->(dbSeek(xFilial("SRX")+"02"+"COD"+Subst(cMV_PLSSRX,1,3)+ "1"))
    lFolha := .F.
	If  Aviso(STR0010, STR0014+Subst(cMV_PLSSRX,1,3)+STR0015+Chr(13)+; //"Pagamento de ComissУes"###"A fСrmula "###" nЦo foi encontrada na importaГЦo de variАveis do GPE."
		STR0016+Chr(13)+; //"Filial - Formula xFilial('SRC')      Matricula - Posicao 1 a 6"
		STR0017+Chr(13)+; //"C.Custo - Posicao 7 a 26      Verba - Posicao 27 a 29"
		STR0018+Chr(13)+; //"Tipo - Formula 'V'      Valor - Posicao 30 a 41. "
		STR0019, {"Ok",STR0013}) == 2 //"Se houver vendedores que recebam na Folha de Pagamento, estes valores NцO SERцO ATUALIZADOS!!!"###"Cancelar"
		Return()
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Realiza a consistencia do processamento                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("BXQ")    

cQuery := " SELECT BXQ.BXQ_CODVEN CODVEN, SUM(BXQ.BXQ_BASCOM) BASCOM, SUM(BXQ.BXQ_VLRCOM) VLRCOM "
cQuery += " FROM " + RetSQLName("BXQ") + " BXQ "
cQuery += " WHERE BXQ.BXQ_FILIAL =  '" + xFilial("BXQ") + "'"
cQuery += "   AND BXQ.BXQ_CODINT =  '" + cOper          + "'"
cQuery += "   AND BXQ.BXQ_ANO    =  '" + cAno           + "'"
cQuery += "   AND BXQ.BXQ_MES    =  '" + cMes           + "'"
cQuery += "   AND BXQ.BXQ_DTGER  =  '        '"
cQuery += "   AND BXQ.BXQ_PAGCOM =  BXQ.BXQ_REFERE"
cQuery += "   AND BXQ.D_E_L_E_T_ <> '*' "
cQuery += "GROUP BY BXQ_CODVEN"


cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"BXQTMP",.T.,.T.)

TCSetField("BXQTMP", "BASCOM","N", 12, 2)
TCSetField("BXQTMP", "VLRCOM","N", 12, 2) 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existem comissoes a serem pagas                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  EOF()
	BXQTMP->( DbCloseArea() )
	Aviso(STR0010, STR0020, {"Ok"}) //"Pagamento de ComissУes"###"Com os parБmetros informados, nЦo foi possМvel pagar comissЦo a nenhum vendedor. Verifique foi realizada a programaГЦo e cАlculo da comissЦo."
	Return()
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera pagamento das comissoes - via Financeiro ou via Folha                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SA3->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SED->(dbSetOrder(1))
SE2->(dbSetOrder(1))

While !EOF()
   BEGIN TRANSACTION
   nVlrComis := BXQTMP->VLRCOM
   SA3->(dbSeek(xFilial("SA3")+BXQTMP->CODVEN))

   // Como o conceito do campo "A3_GERASE2" passou a ser o mesmo conceito do campo
   // "A3_PGCOMIS" criado pelo PLS, para o RELEASE 4, o campo "A3_PGCOMIS" deixou de existir.
   // Para evitar erro nos clientes que ja utilizem a rotina comercial, verifica a existencia
   // do campo "A3_PGCOMIS".
   // Opcoes A3_GERASE2 --> S=Contas a Pagar;F=Folha de Pagamento;N=Sem interface;P=pedido de compra
   // Opcoes A3_PGCOMIS --> 1=Financeiro;2=Folha de Pagamento
   
   If SA3->(FieldPos("A3_PGCOMIS")) > 0 
   	
   		cPGCOMIS := SA3->A3_PGCOMIS
   
   ElseIf SA3->A3_GERASE2 $ "SN "
   		
   		cPGCOMIS := "1"
   
   ElseIf SA3->A3_GERASE2 == "P"
   		
   		cPGCOMIS := "3"
   Else
   		cPGCOMIS := "2"
   EndIf 
   
   If Empty(cPGCOMIS) .Or. cPGCOMIS == "1"
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Verifica se o vendedor existe como fornecedor                    Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If  ! SA2->(dbSeek(xFilial("SA2")+SA3->A3_FORNECE+SA3->A3_LOJA))
           If  ! SA2->(dbSeek(xFilial("SA2")+cMvFORNCOM))
               SA2->(RecLock("SA2",.T.))
               SA2->A2_FILIAL	:= xFilial("SA2")
               SA2->A2_COD		:= SubStr(cMvFORNCOM,1,6)
               SA2->A2_LOJA	    := SubStr(cMvFORNCOM,7,2)
               SA2->A2_NOME	    := STR0021 //"VENDEDOR"
               SA2->A2_NREDUZ	:= STR0021 //"VENDEDOR"
               SA2->A2_BAIRRO	:= "."
               SA2->A2_MUN		:= "."
               SA2->A2_EST		:= "."
               SA2->A2_END		:= "."
               SA2->(MsUnlock())
           EndIf
       EndIf
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Identifica natureza                                              Ё
       //Ё O padrao eh procurar no fornecedor 1o, se nao foi informado procuЁ
       //Ё ro no parametro (que nao tem valor padrao). Sempre valido se exisЁ
       //Ё te no cadastro de naturezas                                      Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If !Empty(SA2->A2_NATUREZ) .And. SED->(dbSeek(xFilial("SED")+SA2->A2_NATUREZ))
           cNatureza := SED->ED_CODIGO
       ElseIf !Empty(GetNewPar("MV_PLNATUR","")) .And. SED->(dbSeek(xFilial("SED")+GetNewPar("MV_PLNATUR","")))
           cNatureza := SED->ED_CODIGO
       EndIf
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Identifica Pfx, Numero, Tipo e Parcela                           Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       cTipo   := If (nVlrComis > 0 , "DP " , left(MV_CPNEG,3) )
       cNumero := P152NUMSE2(cPrefixo)
	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Define dados para inclusao via rotina automatica...                 Ё
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   nVlrSE2 := Abs(nVlrComis)
		  nValorBIR		:=nVlrSE2
		  nValorBCOF	:=nVlrSE2
		  nValorBISS	:=nVlrSE2
		  nValorBCSL	:=nVlrSE2
		  nValorBPIS	:=nVlrSE2
		  nValorBINS	:=nVlrSE2
		  nValorBSES	:=nVlrSE2
		  aCampos :={	{"E2_FILIAL"    ,xFilial("SE2")     ,NIL},;					 					
	                	{"E2_PREFIXO"	,cPrefixo           ,Nil},;
		   			    {"E2_NUM"		,cNumero            ,Nil},;
		   			    {"E2_PARCELA"	," "                ,Nil},;
		   			    {"E2_TIPO"		,cTipo              ,Nil},;			
  					    {"E2_NATUREZ"	,cNatureza          ,Nil},;
				    	{"E2_FORNECE"	,SA2->A2_COD        ,Nil},; 
					    {"E2_LOJA"		,SA2->A2_LOJA       ,Nil},;      
					    {"E2_NOMFOR"    ,SA2->A2_NREDUZ     ,Nil},;      
	    				{"E2_EMIS1"     ,dDataBase          ,NIL},;
	    				{"E2_EMISSAO"	,dDataBase          ,NIL},;
			   			{"E2_VENCTO"	,dDataBase          ,NIL},;					 
			    		{"E2_VENCREA"   ,DataValida(dDataBase,.T.),NIL},;
	    				{"E2_VALOR"		,nVlrSE2			,Nil},;
			   			{"E2_VENCORI"   ,dDataBase          ,NIL},;					 
				    	{"E2_ORIGEM"    ,"PLSMPAG"          ,NIL},;					 					
		   				{"E2_MOEDA"     ,1                  ,NIL},;
		    			{"E2_RATEIO"    ,"N"                ,NIL},;
		    			{"E2_FLUXO",    ,"S"                ,"S"},;
			   			{"E2_DESDOBR"   ,"N"                ,"N"},;
			   			{"E2_DIRF"      ,"1"                ,NIL},;
				    	{"E2_HIST"      ,STR0022            ,NIL} }	//"PAGTO COMISSOES"
					    If  SE2->(FieldPos("E2_SEST")) > 0
					  	    aadd(aCampos,{"E2_SEST" ,0                  ,NIL})
					    Endif
					    If SA2->A2_TIPO == "J"
							aAdd(aCampos,{"E2_CODRET", cCodRetPJ ,Nil})
				        Else
							aAdd(aCampos,{"E2_CODRET", cCodRetPF ,Nil})
					    EndIf
          
          aBasesImp := {nValorBIR,nValorBCOF,nValorBISS,nValorBCSL,nValorBPIS,nValorBINS,nValorBSES, nVlrSE2}  
		  PLStoSE2(aCampos,aBasesImp,,.F.,,"PLSM152")
          
          //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
          //Ё Atualizacao das informacoes sobre a geracao do pagamento Ё
          //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
          dbSelectArea("BXQ")
          BXQ->(dbSetOrder(1))
		  BXQ->(dbSeek(xFilial("BXQ") + cAno + cMes + BXQTMP->CODVEN ))
          
          While !BXQ->(EOF()) .And.	BXQ->BXQ_FILIAL == xFilial("BXQ") .And. ;
		                              	BXQ->BXQ_ANO    == cAno           .And. ;
		                              	BXQ->BXQ_MES    == cMes           .And. ;
		        						BXQ->BXQ_CODVEN == BXQTMP->CODVEN
		                             
                              
             If  BXQ->BXQ_PAGCOM == BXQ->BXQ_REFERE .And.;
             	 Empty(BXQ->(BXQ_E2PREF+BXQ_E2NUM+BXQ_E2PARC+BXQ->BXQ_E2TIPO))
                
                 RecLock("BXQ", .F.)
                 BXQ->BXQ_DTGER  := dDataBase
                 BXQ->BXQ_E2PREF := cPrefixo
                 BXQ->BXQ_E2NUM  := cNumero
                 BXQ->BXQ_E2PARC := " "
                 BXQ->BXQ_E2TIPO := cTipo
                 BXQ->BXQ_E2FORN := SA2->A2_COD
                 BXQ->BXQ_E2LOJA := SA2->A2_LOJA
                 BXQ->(MsUnLock())
             Endif
             BXQ->(dbSkip())
          EndDo
   ElseIf cPGCOMIS == "2" .And. lFolha
          //зддддддддддддддддддддддддддддддддддддддддд©
          //Ё Efetuar pagamento na Folha de Pagamento Ё
          //юддддддддддддддддддддддддддддддддддддддддды
          // <Matricula - 6>+<Centro de Custo - 20>+<Verba - 3>+<Valor - 12>
          cFile += SA3->A3_NUMRA+Subst(cMV_PLSSRX,4,20)+Subst(cMV_PLSSRX,24,3)+StrZero(BXQTMP->VLRCOM*100,12,0)
          cFile += Chr(13)+Chr(10)
          //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
          //Ё Atualizacao das informacoes sobre a geracao do pagamento Ё
          //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
          dbSelectArea("BXQ")
          dbSetOrder(1)
          dbSeek(xFilial("BXQ") + cAno + cMes + BXQTMP->CODVEN)
          While !EOF() .And. BXQ->BXQ_FILIAL == xFilial("BXQ") .And. ;
                              BXQ->BXQ_ANO    == cAno           .And. ;
                              BXQ->BXQ_MES    == cMes           .And. ;
                              BXQ->BXQ_CODVEN == BXQTMP->CODVEN
             If  BXQ->BXQ_PAGCOM == BXQ->BXQ_REFERE
                 RecLock("BXQ", .F.)
                 BXQ->BXQ_DTGER  := dDataBase
                 BXQ->BXQ_MAT    := SA3->A3_NUMRA
                 BXQ->(MsUnLock())
             Endif
             dbSkip()
          End
   Elseif cPGCOMIS == "3" //pedido de compra 
  	 
  	  If  ! SA2->(dbSeek(xFilial("SA2")+SA3->A3_FORNECE+SA3->A3_LOJA))
           If  ! SA2->(dbSeek(xFilial("SA2")+cMvFORNCOM))
               SA2->(RecLock("SA2",.T.))
               SA2->A2_FILIAL	:= xFilial("SA2")
               SA2->A2_COD		:= SubStr(cMvFORNCOM,1,6)
               SA2->A2_LOJA	    := SubStr(cMvFORNCOM,7,2)
               SA2->A2_NOME	    := STR0021 //"VENDEDOR"
               SA2->A2_NREDUZ	:= STR0021 //"VENDEDOR"
               SA2->A2_BAIRRO	:= "."
               SA2->A2_MUN		:= "."
               SA2->A2_EST		:= "."
               SA2->A2_END		:= "."
               SA2->(MsUnlock())
           EndIf
       EndIf
   	   
   	   cCodUsr := RetCodUsr()
   	   
   	   //Verificando o grupo de compras
	   aGrupo := UsrGrComp(cCodUsr)
	   If Len(aGrupo) > 0
	    	cGrupCom := aGrupo[1]
	   Else	
		    cGrupCom := ""
	   Endif
	
	   _cNumPc		:= ""             //procurar no PLSMPAG OU PLSA470
	   nVlrSE2 := Abs(nVlrComis)
	   
	   aCab := {{"C7_NUM"		,_cNumPc									  ,nil},;
				{"C7_EMISSAO"	, Date()									  ,nil},;
				{"C7_FORNECE"	,SA2->A2_COD								  ,nil},;
				{"C7_LOJA"		,SA2->A2_LOJA								  ,nil},;
				{"C7_COND"    	,iIf(!empty(SA2->A2_COND),SA2->A2_COND,cCond) ,nil},;
				{"C7_CONTATO"   ,". "    									  ,nil},;
				{"C7_FILENT"  	,xFilial("SC7")							      ,nil}}
	
	   aAdd(aItens,{{"C7_ITEM"		,StrZero(1,4),Nil},;
					{"C7_PRODUTO"	,cProduto			,Nil},;
					{"C7_QUANT"		,1					,Nil},;
					{"C7_PRECO"		,nVlrSE2			,Nil},;
					{"C7_TOTAL"		,nVlrSE2			,Nil},;
					{"C7_DATPRF"	,dDataBase			,Nil},;
					{"C7_TES"		,cTesAux			,Nil},;
					{"C7_FLUXO"		,"S"				,Nil},;
					{"C7_LOCAL"		,"01"				,Nil},;
					{"C7_ORIGEM"    ,"PLSM152"  		,nil},;
					{"C7_USER"		,cCodUsr			,Nil},;
					{"C7_GRUPCOM"	,cGrupCom			,Nil}})

			
		lMsHelpAuto := .T.
		lMsErroAuto := .F.
		
		MsExecAuto({|X,Y,Z,W| MATA120(X,Y,Z,W)},1, aCab, aItens, 3)
		
		SC7->(ConfirmSX8())

		If lMsErroAuto //SE NAO HOUVE ERRO
			lOK:=.F.
			MostraErro()
		Endif
		
		// ATUALIZANDO O GRUPO DE COMPRAS
		If lOK .and. ! Empty(cGrupCom)
			SC7->(Reclock("SC7",.F.))
			SC7->C7_GRUPCOM := cGrupCom
			SC7->(MsUnlock())
		Endif	
		
		BXQ->(dbSetOrder(1))
		BXQ->(MsSeek(xFilial("BXQ") + cAno + cMes + BXQTMP->CODVEN ))
          
        While !BXQ->(EOF()) .And. BXQ->BXQ_FILIAL == xFilial("BXQ") .And. ;
		                          BXQ->BXQ_ANO    == cAno           .And. ;
		                          BXQ->BXQ_MES    == cMes           .And. ;
		        				  BXQ->BXQ_CODVEN == BXQTMP->CODVEN
		                             
                              
             If  BXQ->BXQ_PAGCOM == BXQ->BXQ_REFERE .And.;
             	 Empty(BXQ->(BXQ_E2PREF+BXQ_E2NUM+BXQ_E2PARC+BXQ->BXQ_E2TIPO))
                
                 RecLock("BXQ", .F.)
                 BXQ->BXQ_DTGER  := dDataBase
                 BXQ->BXQ_PEDCOM := SC7->C7_NUM
                 BXQ->BXQ_E2FORN := SA2->A2_COD
                 BXQ->BXQ_E2LOJA := SA2->A2_LOJA
                 BXQ->(MsUnLock())
             Endif
             BXQ->(dbSkip())
           EndDo
		
   EndIf 

   dbSelectArea("BXQTMP")

   END TRANSACTION

   dbSkip()
End

BXQTMP->( DbCloseArea() )
If  ! Empty(cFile)
    MV_PAR01 := CriaTrab(NIL, .F.)			// Nome do arquivo a ser importado
    MV_PAR02 := Subst(cMV_PLSSRX,1,3)		// Codigo da tabela de importacao de variaveis
    MV_PAR03 := 2							// Nao totaliza por verba
    MV_PAR04 := 2                           // Flag que aponta a condicao no tratamento de um prx arquivo.
    MV_PAR05 := " ADFT"                     // Situacoes

    MemoWrite(MV_PAR01, cFile)
    //??? Precisa tirar o STATIC desta funcao no GPEA210
    //GPA210Processa()
    If File(MV_PAR01)
       fErase(MV_PAR01)
    EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return() 


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁP152NUMSE2Ё Autor Ё Sandro Hoffman Lopes  Ё Data Ё 01/06/06 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Retorna o proximo numero de titulo para o prefixo informa- Ё╠╠
╠╠Ё          Ё do no parametro.                                           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё P152NUMSE2(cPrefixo)                                       Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function P152NUMSE2(cPrefixo)
	
Local cSQL 	:= ""
Local cNum 	:= ""
Local aArea := GetArea()
Default cPrefixo := "   "

DbSelectArea("SE2") // a funcao xFilial() precisa do arquivo aberto
cSQL := " SELECT MAX(E2_NUM) NUMERO FROM " + RetSQLName("SE2")
cSQL += " WHERE E2_FILIAL  = '" + xFilial("SE2") + "' " 
cSQL += "   AND E2_PREFIXO = '" + cPrefixo + "' "
cSQL += "   AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"TrbNumSE2",.T.,.T.)
    
cNum := Soma1(TrbNumSE2->NUMERO)

TrbNumSE2->(DbCloseArea())
    
RestArea(aArea)
	
Return(cNum) 


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё CriaSX1  Ё Autor Ё Sandro Hoffman Lopes  Ё Data Ё 01/06/06 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Atualiza perguntas                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CriaSX1()                                                  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CriaSX1()

Local aRegs	:=	{}

aAdd(aRegs, { cPerg,"04","Cod Retenc IR PJ","","","mv_chd","C",4,0,0,"G",'ExistCpo("SX5","37"+mv_par04)',"mv_par04","" ,"","","","","","","","","","","","","","","","","","","","","","","","37","" })
aAdd(aRegs, { cPerg,"05","Cod Retenc IR PF","","","mv_che","C",4,0,0,"G",'ExistCpo("SX5","37"+mv_par05)',"mv_par05","" ,"","","","","","","","","","","","","","","","","","","","","","","","37","" })

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza SX1                                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PlsVldPerg(aRegs)

Return
