#INCLUDE "PROTHEUS.CH"
#INCLUDE "LJGRVWS.CH"

#DEFINE __FORMATEF	"CC;CD" //Formas de pagamento que utilizam operação TEF para validação

Static cPdv := '001'	// Numero do PDV

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³GravaSL1  ³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia para webService                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GravaSL1(cEstacaoIni)
Local cTextL1		:= ""	//	Texto L1
Local cTextL2  		:= ""  	// 	Texto L2
Local cTextL4		:= "" 	//	Texto L4
Local lEncontrou 	:= .T.	//	Se encontrou registro
Local cNum        	:= "" 	// 	Numero da estacao

Default cEstacaoIni := "001"

cPdv := cEstacaoIni // Carrega numero do PDV		
                         
while lEncontrou == .T.
	                     
	//Considera registros Deletados para subir cancelamentos
	SET DELETED OFF
	                     
	/////////////Fim SL1////////////////////////
	cTextL1 := GeraStrSL1(@lEncontrou)
	
	/////////////Inicio SL2////////////////////////
	If lEncontrou
		cTextL2 :=  GeraStrSl2 ()
	EndIf
	/////////////Inicio SL4////////////////////////
	If lEncontrou
		cTextL4 :=  GeraStrSl4 ()
	EndIf

	//Desconsidera registros Deletados para subir cancelamentos
	SET DELETED ON

	/////////////Envia Para EX////////////////////////
	If lEncontrou
	   	cNum := EnvVendWs(LjRmvChEs(cTextL1), LjRmvChEs(cTextL2), LjRmvChEs(cTextL4))
		
		// caso nao tiver ws, sai do While
		If !Empty(cNum) .AND. cNum <> "NWS"
			AtuL1(cNum)
		Else
			conout(STR0008+STR0009)	//"Não foi possível gravar o Orçamento " #"na Retaguarda"
			lEncontrou := .F.
		EndIf
	EndIf
End

// Realiza verificação de Titulos NCC em aberto na Tabela MDJ³
// E realiza a inclusão dos mesmos via WebService.           ³
FRTVeTitOf()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³EnvVendWs ³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia para webService                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EnvVendWs(cSL1, cSL2, cSL4, cEstacaoIni)
Local oWs		:= Nil	// Web Service
Local cNum		:= "" 	// Numero de Orcamento

Default cSL1	:= ""	// 	Texto sl1
Default cSL2	:= ""	//	Texto sl2
Default cSL4	:= ""  	//	Texto sl4
Default cEstacaoIni := "001"

//***** Conecta no Web-Service *****//
oWs := LjConectaWS()

oWS:VldLink(cEstacaoIni, cSL1, cSL2, cSL4 )

If oWS:CVldLinkRESULT == "OK"
	Conout("LJGRVWS - " + STR0001) //"Web Service Conectado"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	oWS:PROCESSAR(cEstacaoIni,cSL1,cSL2,cSL4, cFilAnt, cEmpAnt)
	cNum := oWS:CPROCESSARRESULT
Else
	Conout("LJGRVWS - " + STR0002) //"Sem conexao com Web Service, favor verificar Method VldLink"
	cNum := "NWS"
EndIf

Return cNum

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FRTVeTitOf³ Autor ³ 	 Vendas & CRM       ³ Data ³12/01/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia para webService Titulos de NCC abertos na MDJ		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTVeTitOf()
Local cSitua   	:= "NP"		//Adiciona como "NP" para identificar o titulo em aberto.
Local cFilMDJ	:= ""

DbSelectArea("MDJ")
DbSetOrder(2)						//MDJ_FILIAL+MDJ_SITUA
cFilMDJ := xFilial("MDJ")
If DbSeek(cFilMDJ+cSitua) 	// Procura algum registro pendente
	While !EOF() .AND. ( cFilMDJ == MDJ->MDJ_FILIAL) .AND. (MDJ->MDJ_SITUA == cSitua)
		If MDJ->MDJ_OPER == "I"			
			//**** Chama a funcao para a Inclusao do Titulo
			LjSelIncTit( Nil,"MDJ")
		EndIf  
		MDJ->(DbSkip())
		Sleep(300)	
    End
EndIf    

//Efetua a baixa de NCC que nao foi baixada/estornada no momento da venda e vai ser baixada/estornada automaticamente.
FRTCheckNcc()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³AtualizaSL1 ³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera valor dos campos do sl1 sl2 e sl4					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AtuL1(cNum)
Local cConf 	:= ""
Local cEstacao	:= ""
Local aSL1		:= {}
Local cLiMsg	:= ""		// Mensagem para sinalizar Cancelamento da Venda

RecLock( "SL1", .F. )

If ValType( cNum ) == "C"
	If Left( cNum, 2 ) == "OK"
		cConf := Substr( cNum, 4, 6 )
		                                            
		//Verifica se houve o cancelamento da Venda antes de subir para a Retaguarda
		If SL1->L1_STORC == "C"
			aSL1 := {{ "L1_NUMORIG"	, cConf},;
					 { "L1_SITUA"	, "07" } } // "07" - Mantem L1_SITUA padrao para Venda Cancelada

			cLiMsg := cConf + "|" + SL1->L1_DOC + "|" + SL1->L1_PDV  // Monta mensagem para cancelamento na Retaguarda via SLI
		Else
			aSL1 := {{ "L1_NUMORIG"	, cConf},;
		 			 { "L1_SITUA"	, "TX" } } // "TX" - Foi Enviado ao Server
		EndIf

		aEval( aSL1, { |x| FieldPut( ColumnPos( x[1] ), x[2] ) } )

		// "Siga Loja: Orcamento " ### " gravado com sucesso."
		ConOut( STR0003 + SL1->L1_NUM + STR0004 )
	Else
		If Left( cNum, 2 ) == "BX"
			aSL1 := { { "L1_SITUA", "DU" } } // "DU" - Orcamento duplicado na Retaguarda
			aEval( aSL1, { |x| FieldPut( ColumnPos( x[1] ), x[2] ) } )
			//"O Orcamento "##" ja foi gravado na Retaguarda."
			ConOut( STR0005 + SL1->L1_NUM + STR0006 )
			//"Verifique o L1_SITUA='DU' na estacao."
			ConOut( STR0007  )
		EndIf
	EndIf
Else
	// "Nao foi possivel gravar o Orcamento " ### " na Retaguarda." ### " Registro(RecNo):"  ### " Será reprocessado."
	ConOut( STR0008 + SL1->L1_NUM + STR0009 + STR0021 + cValToChar(SL1->(Recno())) + STR0022 )
EndIf

DbCommit()
MsUnLock()

//Verifica se subindo venda cancelada e gera SLI
If !Empty(cLiMsg)
   	FR271BGerSLI("    ", "CAN", cLiMsg, "NOVO")	
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³GerValCam ³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera valor dos campos do sl1 sl2 e sl4					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GerValCam(xText, lComma, lTrimText, cTipo)
Local cType := ValType(xText)
Local cText

If !Empty(cTipo)
	cType := cTipo
EndIf

// Trata tipo de caracter
If cType == 'C'
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³E preciso usar StrTran para "'" porque o vertor não esceita esse caracter³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cText := "'" + If(lTrimText,Alltrim(StrTran(xText, "'", "")),Text)+ "'"
	
ElseIf cType == 'N'
	
	cText := AllTrim(Str(xText))
	
ElseIf cType == 'L'
	
	cText := If(xText,'.T.','.F.')
	
ElseIf cType == 'D'
	
	cText := "StoD('" +DtoS(xText)+ "')"
	
ElseIf cType == 'M'	 //Memo
	//Converte uma string ASCII para uma nova na base 64 bytes.
	//Este tratamento eh necessario, pois o campo pode conter caracteres que nao tem conversao para UTF-8, o que causaria erro no WS
	cText := "'" + Encode64(xText) + "'"
ElseIf cType == 'U'
	
	cText     := "''"
Endif

cText += If(lComma,',','')

Return cText

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³GeraStrSl1³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria string para array do SL1							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraStrSl1 (lEncontrou)
Local nCampos := 0
Local aSL1
Local cTextL1
Local i
Local cNome
Local cValor

DbSelectArea("SL1")
SL1->( DbSetOrder(9) )	//L1_FILIAL + L1_SITUA + L1_PDV + L1_DOC

lEncontrou := SL1->(DbSeek(xFilial("SL1")+"00"))

nCampos := FCount()

If lEncontrou
	
	aSL1 := Array(nCampos)
	cTextL1 :=  "{"
	
	For i := 1 To FCount()
		
		If i <= FCount()  .and. !(i == 1)
			cTextL1 := cTextL1 + ", "
		EndIf
		
		cNome	:= "{'" + FieldName(i) + "', "
		
		If FieldName(i) == 'L1_USERLGI' .OR. FieldName(i) == 'L1_USERLGA'
			cValor	:= GerValCam(' ', .F., .T.)
		Else
		    cValor	:= GerValCam(FieldGet(i), .F., .T.)
		Endif
		
		cTextL1 := cTextL1 + cNome   + cValor  + "}"
		
	Next
	
	cTextL1 := cTextL1 + "}"
	aSL1 := &(cTextL1)
	
Else
	SL1->(DbSkip(-1))
	SL1->(DbGoTop())	
EndIf

Return cTextL1

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³GeraStrSl1³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria string para array do SL2							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraStrSl2()
Local nCampos := 0
Local aSL2
Local cTextL2
Local i
Local cNome
Local cValor
Local cFName := ""

DbSelectArea("SL2")
DbSetOrder(1)
DbSeek(xFilial()+SL1->L1_NUM)
aSL2 := {Array(FCount())}

nCampos := FCount()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o SL2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL2")
DbSetOrder(1)
DbSeek(xFilial()+SL1->L1_NUM)

aSL2 := Array(nCampos)
cTextL2 :=  "{{"

For i := 1 To FCount()
	
	If i < nCampos
		cValor	:=  "'" + FieldName(i) + "', "
	Else
		cValor	:= "'" +FieldName(i) + "' "
	EndIF
	
	cTextL2 := cTextL2 + cValor
	
Next

cTextL2 := cTextL2 + "}"


While L2_FILIAL+L2_NUM == xFilial()+SL1->L1_NUM .AND. !EOF()
	               
	//Traz registros deletados, porem so considera itens L2_VENDIDO = "S"
	If SL2->L2_VENDIDO == "S"
	
		cTextL2 := cTextL2 + ", {"
		
		For i := 1 To FCount()      
	
			cFName := FieldName(i)
			
			If i < nCampos						
				If cFName == 'L2_USERLGI' .OR. cFName == 'L2_USERLGA'
					cValor	:= GerValCam(' ', .T., .T.)
				ElseIf cFName == 'L2_VDOBS' //Tratamento Campo MEMO
					cValor	:= GerValCam(FieldGet(i), .T., .T., "M")
				Else		
					cValor	:= GerValCam(FieldGet(i), .T., .T.)
				Endif	
			Else
				If cFName == 'L2_USERLGI' .OR. cFName == 'L2_USERLGA'
					cValor	:= GerValCam(' ', .F., .T.)
				ElseIf cFName == 'L2_VDOBS' //Tratamento Campo MEMO
					cValor	:= GerValCam(FieldGet(i), .F., .T., "M")

				Else				
					cValor	:= GerValCam(FieldGet(i), .F., .T.)
				Endif	
			EndIF  
			
			cTextL2 := cTextL2 + cValor
		Next i
		
		cTextL2 := cTextL2 + "}"
	EndIf
		
	DbSkip()
	
End

cTextL2 := cTextL2 + "}"
aSL2 := &(cTextL2)

Return cTextL2

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³GeraStrSl4³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria string para array do SL4							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraStrSl4()
Local nCampos := 0
Local aSL4    := {}
Local cTextL4 := ""
Local i       := 0
Local cNome   := ""
Local cValor  := ""   
Local cStrAux := ""
Local oLJCConWS	:= LJCConexaoWS():LJRemCharEsp() //Chama função do loja LOJA1115 para remover caracteres especiais.

DbSelectArea("SL4")
DbSetOrder(1)
DbSeek(xFilial()+SL1->L1_NUM)

aSL4 := {Array(FCount())}

nCampos := FCount()
//*** Monta o SL4 ***//
aSL4 := Array(nCampos)
cTextL4 :=  "{{"

For i := 1 To FCount()
	
	If i < nCampos
		cValor	:=  "'" + FieldName(i) + "', "
	Else
		cValor	:= "'" +FieldName(i) + "' "
	EndIF
	
	cTextL4 := cTextL4 + cValor
	
Next

cTextL4 := cTextL4 + "}"

While L4_FILIAL+L4_NUM == xFilial()+SL1->L1_NUM .AND. !EOF()
	//Verifica se o registro tem a marca (**) no campo L4_SITUA identificando que este estah como "registro deletado", pois nao deve ser gravado na retaguarda
	If SL4->L4_SITUA == "**" .OR. ( SL4->(Deleted()) .AND. SL4->L4_FORMA $ __FORMATEF .AND. Empty(SL4->L4_ADMINIS) ) // Incluido esse OR pois estava pegando o SL4 deletado quando a venda nao era comcomitante
		SL4->( DbSkip() )
		Loop
	EndIf
	
	cTextL4 := cTextL4 + ", {"
	
	For i := 1 To FCount()
		If i < nCampos                                                                         
			If FieldName(i) == 'L4_USERLGI' .OR. FieldName(i) == 'L4_USERLGA'
				cValor	:= GerValCam(' ', .T., .T.)
			ElseIf (FieldName(i) == 'L4_NUMCART' .AND. Upper(ALLTRIM(SL4->L4_FORMA)) $ __FORMATEF) 
				cStrAux	:= oLJCConWS:LJRemCharEsp(FieldGet(i))
				cValor	:= GerValCam(cStrAux, .T., .T.)
			Else	
				cValor	:= GerValCam(FieldGet(i), .T., .T.)
		    EndIf
		Else
			If FieldName(i) == 'L4_USERLGI' .OR. FieldName(i) == 'L4_USERLGA'
				cValor	:= GerValCam(' ', .F., .T.)
			ElseIf FieldName(i) == 'L4_NUMCART' .AND. Upper(ALLTRIM(SL4->L4_FORMA)) $ __FORMATEF
				cStrAux	:= oLJCConWS:LJRemCharEsp(FieldGet(i))
				cValor	:= GerValCam(cStrAux, .F., .T.)			
			Else			
				cValor	:= GerValCam(FieldGet(i), .F., .T.)
			Endif	
		EndIF  
		cTextL4 := cTextL4 + cValor
	Next i
	
	cTextL4 := cTextL4 + "}"
	DbSkip()
End

cTextL4 := cTextL4 + "}"
aSL4 := &(cTextL4)

Return cTextL4

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LjGrvCanWs³ Autor ³ Vendas Clientes       ³ Data ³23/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o Cancelamento na Retaguarda.				    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrvCanWs(cEstacaoIni)
Local oWs       := Nil
Local cOrcamentos:= ""                 
Local cNumOrig	:= ""
Local nOrcs     := 1
Local cEstacao  := Space(TamSX3("LI_ESTACAO")[1])
Local cChave	:= ""
Local aOrcs		:= {}
Local aSLX		:= {}
Local cFilSLI	:= ""
Local lRet		:= .T.
Local lProssegue := .T.

DbSelectArea("SLI")
SLI->( DbSetOrder(1) )	//LI_FILIAL + LI_ESTACAO + LI_TIPO
cFilSLI := xFilial()

cPdv := cEstacaoIni // Carrega numero do PDV na variavel Statica

SLI->(DbGotop())

While !SLI->(Eof())
	If ((SLI->(LI_FILIAL + LI_TIPO)) == (cFilSLI+"LOG")) .And. !Empty(AllTrim(SLI->LI_ESTACAO))
		//Envia para a retaguarda a tabela de Log de cancelamento
		LjGrvPesqLX( @aSLX )
	EndIf
	
	SLI->(DbSkip())
EndDo

//Conecta no Web-Service
oWs := LjConectaWs()
LjGrvSLX( aSLX , oWs )

cChave := xFilial() + cEstacao + "CAN"
If lRet .AND. SLI->(DbSeek( cChave ))
	
	While (SLI->LI_FILIAL + SLI->LI_ESTACAO + SLI->LI_TIPO == cChave) .AND. !SLI->(EOF())
		
		If !Empty(SLI->LI_MSG)
			          
			//Insere caracter separador para montar Array
			If nOrcs > 1
				cOrcamentos += "|"
			EndIf     
			
			cNumOrig	:= Subst(SLI->LI_MSG,1,TamSX3("L1_NUMORIG")[1])
					
			cOrcamentos += cNumOrig
			
			//---
			//Adiciona Recno na primeira posicao para atualizacao do SLI e Numero do Orcamento na Segunda
			//---
			AADD(aOrcs,{SLI->(Recno()),cNumOrig} )
			
			nOrcs++
		EndIf
		
		SLI->( DbSkip() )
	End 		
	
	If nOrcs > 1
		// Conecta no Web-Service
		If oWs == NIL
			oWs := LjConectaWs()
		EndIf
		
		//³Efetua a gravacao na Retaguarda.
		lRet := oWs:GrvCancel(cOrcamentos, cEmpAnt, cFilAnt )
		
		If (lRet == Nil) .OR. (!lRet)
			LjLogCons(STR0011) //"Erro na execução do WebService"
			lProssegue := .F.
		Else
			                       				
			For nOrcs := 1 to Len(aOrcs)
			       
				//Verifica se foi cancelado
				If Ascan(oWs:oWsGrvCancelResult:cString,aOrcs[nOrcs][2]) > 0
				
					//Remove Registro de pedido de Cancelamento
					SLI->( DbGoto(aOrcs[nOrcs][1]) )
					RecLock("SLI",.F.)
						SLI->( DbDelete() )
					SLI->(MsUnlock())	       
					
					LjLogCons("Orcamento: " + aOrcs[nOrcs][2] + " cancelado na Retaguarda.")			
				Else 
					LjLogCons("Orcamento: " + aOrcs[nOrcs][2] + " aguardando processar GravaBatch para realizar Cancelamento na Retaguarda.")			
				EndIf
			Next nOrcs
		EndIf
	EndIf
EndIf

//Transporta os cancelamentos de TEF para a retaguarda
cChave		:= xFilial() + cEstacao + "TEF"
nOrcs 		:= 0
cNumOrig	:= ""
cOrcamentos := ""
aOrcs		:= {}
If lProssegue .And. lRet .AND. SLI->(DbSeek( cChave ))
	
	While (SLI->LI_FILIAL + SLI->LI_ESTACAO + SLI->LI_TIPO == cChave) .AND. !SLI->(EOF())
		If !Empty(SLI->LI_MSG)
			//Insere caracter separador para montar Array
			If nOrcs > 0
				cOrcamentos += ";"
			EndIf

			cNumOrig	:= SubStr(AllTrim(SLI->LI_MSG),1, At("|",SLI->LI_MSG)-1)
			cOrcamentos += AllTrim(SLI->LI_MSG)
			AADD(aOrcs,{SLI->(Recno()),cNumOrig} )
			nOrcs++
		EndIf
		SLI->(DbSkip())
	End
	
	If nOrcs > 0
		If oWs == NIL // Conecta no Web-Service
			oWs := LjConectaWs()
		EndIf	
		
		//³Efetua a gravacao na Retaguarda.
		lRet := oWs:GrvCanTEF(cOrcamentos, cEmpAnt, cFilAnt )
		
		If (lRet == Nil) .OR. (!lRet)
			LjLogCons(STR0011) //"Erro na execução do WebService"
			lProssegue := .F.
		Else
			For nOrcs := 1 to Len(aOrcs)
				//Verifica se foi cancelado
				If Ascan(oWs:oWsGrvCanTEFResult:cString,aOrcs[nOrcs][2]) > 0
					SLI->(DbGoto(aOrcs[nOrcs][1]))
					RecLock("SLI",.F.)
					SLI->(DbDelete())
					SLI->(MsUnlock())
					LjGrvLog("",ProcName(0) + "-> Chave: " + aOrcs[nOrcs][2] + " -> Campos de TEF Cancelado Gravado na Retaguarda.")
				Else 
					LjGrvLog("",ProcName(0) + "-> Chave: " + aOrcs[nOrcs][2] + " -> aguardando processar GravaBatch para realizar " +;
										"a gravação dos campos do Cancelamento do TEF na Retaguarda.")
				EndIf
			Next nOrcs
		EndIf
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LjGrvRegWs³ Autor ³ Vendas Clientes       ³ Data ³17/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava SFI SE5... na Retaguarda.					    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cAlias - Alias que sera usado                             ³±±
±±³		     ³  nOrder - Codigo de ordenacao                              ³±±
±±³		     ³  cChave - Campos de busca                                  ³±±
±±³		     ³  cBusca - Conteudo de busca	  						      ³±±
±±³			 ³	cConfirme - String de confirmacao de gravacao do campo	  ³±±
±±³			 ³	            "XX_SITUA" local                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrvRegWs(cAlias, nOrder, cChave, cBusca, cConfLocal, cConfServer, cEstacaoIni, cFunc)
Local cRegistros := ""
Local aRecnos    := {}
Local nCont      := 0
Local cNomeCamp  := ""
Local oWs        := Nil
Local lRet		 := .F. 

Default cFunc 	 := ""

//Formata campo NOMETABELA_SITUA, Exemplo: Iniciando com "S": SL1->L1_SITUA, caso contrário MDZ->MDZ_SITUA
If Substr(Upper(cAlias), 1, 1) == "S"
	cNomeCamp := Substr(cAlias, 2, 2) + "_SITUA"        
Else
	cNomeCamp := cAlias + "_SITUA"        
EndIf

cPdv := cEstacaoIni // Carrega numero do PDV na variavel Statica

cRegistros := LjGeraStrX(cAlias, nOrder, cChave, cBusca, @aRecnos)

If Empty(cRegistros)
	Return Nil
EndIf   

//*** Conecta no Web-Service ***//
oWs := LjConectaWs()

//*** Efetua a gravacao na Retaguarda ***//
lRet := oWs:GrvDadosX(cRegistros, cAlias, cConfServer, cEmpAnt, cFilAnt, cFunc, .T.)

//*** Apos a execucao do WS limpa a variavel ***//
cFunc := ""

If (lRet == Nil) .OR. (!lRet)
	LjLogCons(STR0014 ) //"Erro na execução do WebService"
	Return Nil
Else
	If oWs:lGrvDadosXResult
		
		LjLogCons(cAlias + STR0015) //" gravado na Retaguarda."
		
		For nCont:=1 To Len(aRecnos)
			&(cAlias)->(DbGoto(aRecnos[nCont]))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza campo XX_SITUA como enviado para retaguarda. EX: "TX" "OK"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FRTGeraSL(cAlias, {{cNomeCamp, cConfLocal}})
				LjLogCons(cAlias + STR0016 + cNomeCamp + ": " + cConfLocal + STR0016 + cValToChar(aRecnos[nCont])) //" atualizado. -> Recno: "         
			EndIf
			
		Next nCont
	Else
		LjLogCons(STR0018  + cAlias + STR0019)  //Nao foi possivel gravar "  //" na Retaguarda."
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LjGeraStrX³ Autor ³ Vendas Clientes       ³ Data ³17/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria string para SFI SE5...								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - Alias que sera usado                              ³±±
±±³		     ³  nOrder - Codigo de ordenacao                              ³±±
±±³		     ³  cChave - Campos de busca                                  ³±±
±±³		     ³  cBusca - Conteudo de busca				   				  ³±±
±±³		     ³ aRecnos - Recno dos registros selecionados				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ cRegistros - String com dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjGeraStrX(cAlias, nOrder, cChave, cBusca, aRecnos)
Local nCampo    := 1
Local nCampos   := 0
Local nQuant    := 1
Local cRegistros:= ""
Local xConteudo	:= Nil
Local cFieldAux := ""
Local lCnv32To64:= .T.

DEFAULT aRecnos := {}

DbSelectArea(cAlias)
DbSetOrder( nOrder )

If DbSeek( cBusca )
	nCampos := FCount()
	
	cRegistros := "{"
	
	While &(cChave) == cBusca .AND. !EOF()
		
		If nQuant > 1
			cRegistros += ","
		EndIf
		
		cRegistros += "{"
		
		While nCampo <= nCampos
			If nCampo <> 1
				cRegistros += ", "
			EndIf
			
			cFieldAux := Right(FieldName(nCampo),8)
			
			//Verifica se eh campo de log de inclusao ou alteracao
			If	cFieldAux == "_USERLGI" .Or. cFieldAux == "_USERLGA"
				//Converte uma string ASCII para uma nova na base 64 bytes.
				//Este tratamento eh necessario, pois o campo pode conter caracteres que nao tem conversao para UTF-8, o que causaria erro no WS
				xConteudo := Encode64(FieldGet(nCampo))
			Else
		    	xConteudo := FieldGet(nCampo)
			EndIf
			
			If cFieldAux == "_XMLEPAF" .Or. cFieldAux == "_XMLRPAF" .Or.;
				cFieldAux == "_XMLEPA" .Or. cFieldAux == "_XMLRPA"
				
				cRegistros += "{'" + FieldName(nCampo) + "', " + GerValCam(xConteudo, .F., .T., "M") + "}"
			Else
				cRegistros += "{'" + FieldName(nCampo) + "', " + GerValCam(xConteudo, .F., .T.) + "}"
			EndIf
			nCampo++
		End
		
		cRegistros += "}"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona Recnos para atualizacao do campo XX_SITUA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aRecnos, &(cAlias)->(Recno()) )
		
		nCampo:=1
		nQuant++
		DbSkip()
	End
	
	cRegistros += "}"
	
EndIf

Return cRegistros

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjLogCons ºAutor  ³Microsiga           º Data ³  19/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Enviado o Log para o Console                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjLogCons(cMensagem)
Conout("[FUNCTION " + ProcName(1) + "] -> " + cMensagem)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjConectaWsºAutor  ³Microsiga           º Data ³  23/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Conecta no Web-Service.                                      º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjConectaWs()

Local oWs := Nil
Local cWSServer := '001' 	// Numero da estacao
Local aArea := GetArea()   // Backup da area

// Respeita parametro informado no JOB
DbSelectArea("SLG")
If DbSeek(xFilial()+cPDV)
	cWSServer := AllTrim(SLG->LG_WSSRVMT)	
	If Empty(cWSServer)
		cWSServer := AllTrim(SLG->LG_WSSRV)
	EndIf
Else
	cWSServer := AllTrim(LJGetStation("WSSRVMT"))	
	If Empty(cWSServer)
		cWSServer := AllTrim(LJGetStation("WSSRV"))
	EndIf
EndIf

oWS      := WSLjGrvDados():New()
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
oWs:_URL := "http://"+cWSServer+"/LjGrvDados.apw"
oWs:ccEmp := cEmpAnt
oWs:ccFil := cFilAnt

RestArea(aArea)

Return oWs

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LjGrvEstWs³ Autor ³ Vendas Clientes       ³ Data ³30/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o Estorno da Venda na Retaguarda.			    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrvEstWs() 
Local aArea      := GetArea()
Local oWs        := Nil
Local aRecnos    := {}
Local cCupom	 := ""
Local cSerie     := ""  
Local cChave	 := ""
Local cBusca	 := ""	
Local cAlias     := "MBZ"  
Local nCont		 := 0

If !AliasInDic(cAlias)
	Return
EndIf

DbSelectArea(cAlias)
DbSetOrder( 2 )  //MBZ_FILIAL + MBZ_SITUA + MBZ_CUPOM + MBZ_SERIE

If DbSeek( xFilial() + "00" )
	
	While MBZ_FILIAL + MBZ_SITUA  == xFilial() + "00" .AND. !EOF()
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Conecta no Web-Service.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWs := LjConectaWs()	
			cChave := "MBZ_FILIAL + MBZ_SITUA + MBZ_CUPOM + MBZ_SERIE"
			cBusca := xFilial() + "00" + MBZ_CUPOM + MBZ_SERIE
			cCupom := MBZ_CUPOM
			cSerie := MBZ_SERIE 
			aRecnos := {}
	
		While  &(cChave) == cBusca
			DbSkip(1)
		End
		
		cRegistros := LjGeraStrX(cAlias, 2, cChave, cBusca, @aRecnos)
		
		If !Empty(cRegistros)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a gravacao na Retaguarda.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := oWs:GrvEstorn(cRegistros, cEmpAnt,cFilAnt)
			
			If (lRet == Nil) .OR. (!lRet)
				LjLogCons(STR0014 ) //"Erro na execução do WebService"
				Return Nil
			Else
				If oWs:lGrvEstornResult
					
					LjLogCons(cAlias + STR0015) //" gravado na Retaguarda."
					
					For nCont:=1 To Len(aRecnos)
						MBZ->(DbGoto(aRecnos[nCont]))
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza campo XX_SITUA como enviado para retaguarda. EX: "TX" "OK"³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FRTGeraSL(cAlias, {{cAlias+"_SITUA", "OK"}})
							LjLogCons(cAlias + STR0016 + cAlias+"_SITUA" + ": " + "OK" + STR0016 + cValToChar(aRecnos[nCont])) //" atualizado. -> Recno: "         
						EndIf
						
					Next nCont
				Else
					LjLogCons(STR0018  + cAlias + STR0019)  //Nao foi possivel gravar "  //" na Retaguarda."
				EndIf
			EndIf
		EndIf  //Registros MBZ String
    End    
EndIf  

RestArea(aArea)

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} LjGrvPesqLX
Captura os dados da SLX do PDV e envia para gravação na retaguarda

@aSLX 			: array com os dados da SLX


/*/
//--------------------------------------------------------------------
Function LjGrvPesqLX( aSLX )
Local i    	:= 0
Local nCountSLX:= 0

Default aSLX		:= {}

//Neste momento o SLI já está posicionada
If !Empty(Left(SLI->LI_MSG,17))

	DbSelectArea("SLX")
	SLX->(DbGoto(Val(Left(SLI->LI_MSG,17))))
	If AllTrim(SLX->LX_SITUACA) == "00"
		//---- Monta a lista aSLX ----
		nCountSLX := SLX->(FCount())
									
		Aadd(aSLX , { Array(nCountSLX+1) } )
		For i := 1 To nCountSLX
			aSLX[Len(aSLX)][1][i] := {SLX->(FieldName(i)), SLX->(FieldGet(i))} 
		Next i
		
		aSLX[Len(aSLX)][1][nCountSLX+1] := {"R_E_C_N_O_",SLX->(Recno())} //Inclui recno na ultima posição para dar update na tabela
	EndIf
EndIf

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} LjGrvSLX
Captura os dados da SLX do PDV e envia para gravação na retaguarda

@aSLX 			: array com os dados da SLX
oLjConectaWs	: objeto com o WebService ativo no momento

/*/
//--------------------------------------------------------------------
Function LjGrvSLX(aSLX,oLjConectaWs)
Local SLXFilial := ""
Local SLXLocal  := ''
Local SLXPdv	:= ''
Local SLXOperador := ''
Local SLXDtMvto := ''
Local SLXHora	:= ''
Local SLXCupom  := ''
Local SLXSerie  := '' 
Local SLXItem	:= ''
Local SLXValor  := 0
Local SLXProduto:= ''
Local SLXQtde   := 0
Local SLXSupervi:= ''
Local SLXSitua  := ''
Local SLXTpCanc := ''
Local SLXDescont:= 0
Local SLXAliqIcm:= 0
Local SLXLegenda:= ''
Local SLXVlrUnt := 0
Local SLXContDoc:= ""
Local SLXSitTrib:= ""
Local i    		:= 0
Local nPos		:= 0
Local lRet		:= .F.

Default aSLX	:= {}
Default oLjConectaWs := NIL

//Neste momento o SLI já está posicionada
If (Len(aSLX) > 0) .And. (oLjConectaWs <> NIL)
	
	For i:= 1 to Len(aSLX)
		SLXFilial	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_FILIAL" } )][2]
		SLXLocal	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_LOCAL" } )][2]
   		SLXPdv		:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_PDV" } )][2]
   		SLXOperador	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_OPERADO" } )][2]
   		SLXDtMvto	:= DtoS(aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_DTMOVTO" } )][2])
   		SLXHora		:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_HORA" } )][2]
   		SLXCupom	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_CUPOM" } )][2]
   		SLXSerie	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_SERIE" } )][2]
   		SLXItem		:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_ITEM" } )][2]
   		SLXValor	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_VALOR" } )][2]
   		SLXProduto	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_PRODUTO" } )][2]
   		SLXQtde		:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_QTDE" } )][2]
   		SLXSupervi	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_SUPERVI" } )][2]
   		SLXSitua	:= "OK"//aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_SITUACA" } )][2] - manda padrão 'OK' que é gravado
   		SLXTpCanc	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_TPCANC" } )][2]
   		SLXDescont	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_DESCON" } )][2]
   		SLXAliqIcm	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_ALIQICM" } )][2]
   		SLXLegenda	:= aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "LX_LEGENDA" } )][2]
   		
   		nPos := AScan(aSLX[i][1], { |x| x[1] == "LX_CONTDOC" } )
   		If nPos > 0
   			SLXContDoc	:= aSLX[i][1][nPos][2]
   		Else
   			SLXContDoc	:= ""
   		EndIf
   		
   		nPos := AScan(aSLX[i][1], { |x| x[1] == "LX_VRUNIT" } )
   		If nPos > 0
   			SLXVlrUnt := aSLX[i][1][nPos][2]
   		Else
   			SLXVlrUnt := 0
   		EndIf
   		
   		nPos := AScan(aSLX[i][1], { |x| x[1] == "LX_SITTRIB" } )
   		If nPos > 0
   			SLXSitTrib := aSLX[i][1][nPos][2]
   		Else
   			SLXSitTrib := ""
   		EndIf
	
		lRet :=	oLjConectaWs:GrvLogCanc( cEmpAnt, cFilAnt,SLXFilial, SLXLocal, SLXPdv,;
					SLXOperador, SLXDtMvto, SLXHora, SLXCupom, SLXSerie, SLXItem, SLXValor,;
					SLXProduto, SLXQtde, SLXSupervi, SLXSitua, SLXTpCanc, SLXDescont,;
					SLXAliqIcm, SLXLegenda , SLXVlrUnt ,SLXContDoc, SLXSitTrib)
					
		If ValType(lRet) == "L" .And. lRet
			SLX->(DbGoto(aSLX[i][1][AScan(aSLX[i][1], { |x| x[1] == "R_E_C_N_O_" } )][2]))
			RecLock("SLX",.F.)
			REPLACE LX_SITUACA WITH "OK"
			SLX->(MsUnlock())
		Else
			lRet := .F.
			Conout(STR0023) //'LJGRVWS - Tabela de Log de Cancelamentos (SLX) , não gravada na retaguarda'
			LjGrvLog( NIL, STR0023)	
		EndIf
	Next i
EndIf

Return lRet
