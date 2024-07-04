#INCLUDE "APWIZARD.CH" 
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "LOJA804.ch"
#INCLUDE "Report.ch"
//-------------------------------------------------------------------
/*/ {Protheus.doc} LOJA804
Efetua o fechamento para criar um registro único de contas a pagar
para o Instituto Arredondar.
@author Varejo
@since 22/10/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA804()
 
Local lRet := .F.    
Local cPerg   := PadR("LOJA804",10)    //grupo de perguntas no SX1

Local nOpcA     := 0	// sem opção para incluir/alterar/excluir  
Local nValFin   := 0	// valor total dos titulos provisórios apresentado na tela
Local nValPed   := 0	// valor total do pedido de venda referente a prestacao de serviço para administradora financeira
Local nFreeze	:= 0	// sem freeze
Local nMax		:= 999999999 // maximo de itens
Local cLinOk	:= "AllwaysTrue"   // sempre .T.
Local cTudoOk	:= "AllwaysTrue"   // sempre .T.
Local cIniCpos	:= ""              // sem inicializador
Local cFieldOk	:= "AllwaysTrue"  // sempre .T.
Local cSuperDel	:= ""             // sem validação
Local cDelOk	:= "AllwaysTrue"  // sempre .T.
Local aAlter    := {}             //Array para campos que podem ser alterados

Local aColsMfi:= {} // para grid de titulos provisórios 
Local aColsSe2:= {} // para grid do titulo efetivo
Local aColsSc6:= {} // para grid do pedido de venda

Local aHeader1 := LjMtaHeader('1') // serve para aColsMfi
Local aHeader2 := LjMtaHeader('2') // apenas para o aColsSe2

Local aTitles := {STR0024,STR0025} //"Titulos Provisórios"###"Titulo Efetivo Gerado"
Local oReport	//Objeto relatorio TReport (Release 4)

Local oFolder:=Nil

Local oGet1    := Nil
Local oGet2    := Nil
Local oWizard  := Nil
Local oSayPar  := Nil

Local cNat := SuperGetMv("MV_LJNATRE",,"")	// Prefixo do titulo a pagar provisorio /
Local cNumTit   // Número do Título criado para o lançamento novo
Local lOk					:= .F.
Local aArea				:= GetArea()							// Area da Tabela anterior

// Campo verificador se está sendo chamado pelo Robo
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

//Valida se os parametros obrigatórios estão preenchidos
If !Lj804VldSx6()
	Return
EndIf

While !lOk

	If !lAutomato
		If !Pergunte( "LOJA804", .T. )
			exit
		EndIf
	Else
		Pergunte( "LOJA804", .f. )
	EndIf
	
	lOk := Lj804Ok( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04 )
	
	If !lOk
		Loop
	EndIf
	
	cNumTit := Lj804Nota(	MV_PAR01	, MV_PAR02		, MV_PAR03		, MV_PAR04	,;
							@aColsMfi	, @aColsSe2	, @oWizard		, @oGet1	,;
							@oGet2)			

	If Empty(cNumTit)
		exit
	EndIf
	
	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 1³
	//ÀÄÄÄÄÄÄÄÙ
	DEFINE WIZARD oWizard SIZE 0,0,550,800 TITLE STR0001 HEADER STR0002 ;	//"Fechamento Doação Instituto Arredondar"###"Definição do Processo"
			MESSAGE " "; 								
			NEXT {|| .T. } ;
		    FINISH {||  .T. } NOFIRSTPANEL PANEL			
			oWizard:GetPanel(1)	                		

			oFolder := TFolder():New(000,000,aTitles,{"HEADER"},oWizard:GetPanel(1),,,, .T., .F.,315,140)
			oFolder:Align:= CONTROL_ALIGN_ALLCLIENT	  			
			

			oGet1 := MsNewGetDados():New(015,005,100,350,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
				   						nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[1],@aHeader1,@aColsMfi)			
			oGet1:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	   						

			oGet2 := MsNewGetDados():New(115,005,150,350,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
				   						nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[2],@aHeader2,@aColsSe2)			
			oGet2:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	   						

			If !Empty(cNumTit)
				oGet1:SetArray(aColsMfi)
				oGet2:SetArray(aColsSe2)
			Else 
				aColsSc6:= {}
				aColsSe2:= {}
				aColsMfi:= {}
			EndIf
			oGet1:Refresh()
			oGet2:Refresh()
	If !lAutomato			
		ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cNumTit)
		If !lAutomato
			oReport := LOJA804Def(Substr(cNumTit,12,9)) 
			oReport:SetPortrait()
			oReport:PrintDialog()
		EndIf
	EndIf 

EndDo	

RestArea(aArea)

Return(Nil) 
    
//-------------------------------------------------------------------
/*/ {Protheus.doc} Lj804Nota
Funcao que gera a nota fiscal de serviço para administradora financeira.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Lj804Nota(	dDtIni		,	dDtFim		,	cFornec	,	dVencimento	,;
								aColsMfi	,	aColsSe2	,	oWizard	,	oGet1			,;
								oGet2	)

Local cAliasTrb:= GetNextAlias() // Proximo alias disponivel
Local cNumTit  := ''     // Numero do titulo no financeiro
Local nVlrUnit := 0       //Valor unitario 
Local nVlrTot  := 0        // Valor total
Local cPedido  := ''      // Numero do pedido gerado
Local aItem    := {}     // Itens do pedido     de venda
Local aCab     := {}     // Cabecalho do pedido de venda
Local aLinha   := {}    // Itens do pedido      de venda
Local aRecMFI  := {}     //Recno da tabela 	MFI 
Local nItem    := 1      // Contador de itens
Local nPrcVen  := 0     // Preco de venda
Local nSaveSx8 := GetSx8Len()  
Local cProduto := SuperGetMv("MV_LJPRDSC",,"")//produto servico para pedido de venda
Local cDescri  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
Local cTes     := SuperGetMv("MV_LJTESSV",,"")// tes de servico para pedido de venda
Local nI       := 1          // contador
Local nTotReg  := 0          // Total de registros
Local cPrefixo := '' // cPref  // Prefixo do titulo
Local aRet     :=  {}       // Array de retorno para preenchimento do aCols do Wizard
Local lRet     := .T.
Local cLojaArredondar   := SuperGetMv("MV_LJLOJIA",,"")      // Loja do fornecedor para o Instituto Arredondar
Local cPrefArredondar   := SuperGetMv("MV_LJPREIA",,"")		// Prefixo de contas a pagar para o Instituto Arredondar
Local cNatureza		   := SuperGetMv("MV_LJNATIA",,"")		// Natureza 'doação' para o Instituto Arredondar
Local cTipo			   := SuperGetMV("MV_LJTPFIN",,"PRE")	// Título Provisório

DEFAULT dDtIni			:= CTOD("  /  /  ")
DEFAULT dDtFim			:= CTOD("  /  /  ")
DEFAULT cFornec		:= ""
DEFAULT dVencimento	:= CTOD("  /  /  ")
DEFAULT aColsMfi		:= {}
DEFAULT aColsSe2		:= {}
DEFAULT oWizard		:= Nil
DEFAULT oGet1			:= Nil
DEFAULT oGet2			:= Nil

//Efetua a extração dos dados para processamento
nTotReg:= FilDados(	cAliasTrb			, dDtIni			, dDtFim	, cFornec	,;
						cLojaArredondar	, cPrefArredondar	, cTipo		)

ProcRegua(nTotReg)

If (cAliasTrb)->(!EOF())
	
	Begin Transaction
	While (cAliasTrb)->(!EOF()) 
      	nPrcVen+= (cAliasTrb)->E2_VALOR
      	AAdd(aRecMFI,(cAliasTrb)->RECNOSE2)
      	IncProc()
		(cAliasTrb)->(DbSkip())
	EndDo

		//Chama rotina que ira aglutinar os titulos provisório no financeiro e gerar um unico para administradora financeira.
		MsgRun(STR0003,,;
				 { || cNumTit:= Lj804Fin(	aRecMFI			, cLojaArredondar	, cTipo			, cNatureza	,;
				 								cPrefArredondar	, dVencimento		, @aColsMfi	,@aColsSe2) } )//"Aguarde, substituindo os titulos provisórios ..."		
	
	End Transaction
	 
Else
	MsgInfo(STR0004,STR0005)//"Não há dados para processar!"###"Atenção"
EndIf     

Return cNumTit
//-------------------------------------------------------------------
/*/{Protheus.doc} FilDados
Funcao que gera a nota fiscal de serviço para administradora financeira.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function FilDados(	cAliasTrb	,	dDtIni		,	dDtFim		,	cFornec,;
								cLoja		,	cPrefixo	,	cTipo	)

Local cQuery := ''
Local cDtIni := Dtos(dDtIni)//Dt inicial
Local cDtFim := Dtos(dDtFim)//Dt final
Local nRet   := 0 // retorna quantos registros tem na consulta

DEFAULT cAliasTrb		:= ""
DEFAULT dDtIni			:= CTOD("  /  /  ")
DEFAULT dDtFim			:= CTOD("  /  /  ")
DEFAULT cFornec		:= ""
DEFAULT cLoja			:= ""
DEFAULT cPrefixo		:= ""
DEFAULT cTipo			:= "" 

cQuery+= " SELECT E2_FORNECE,E2_LOJA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_HIST,E2_EMISSAO,E2_VALOR,R_E_C_N_O_ RECNOSE2"
cQuery+= "  FROM "+RetSqlName("SE2")+" SE2" +CRLF
cQuery+= " WHERE SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+CRLF
cQuery+= " AND SE2.E2_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "+CRLF
cQuery+= " AND SE2.E2_FORNECE = '" + cFornec + "'  "+CRLF 
cQuery+= " AND SE2.E2_LOJA = '" + cLoja + "'  "+CRLF 
cQuery+= " AND SE2.E2_PREFIXO = '" + cPrefixo + "'  "+CRLF 
cQuery+= " AND SE2.E2_TIPO = '" + cTipo + "'  "+CRLF 
cQuery+= " AND SE2.E2_BAIXA = '' "+CRLF 
cQuery+= " AND SE2.D_E_L_E_T_ <> '*' "+CRLF
cQuery+= " ORDER BY SE2.E2_FILIAL,SE2.E2_NUM,SE2.E2_TIPO,SE2.E2_PREFIXO"+CRLF
cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)

(cAliasTrb)->(DBGotop())
Count To nRet
(cAliasTrb)->(DBGotop())

Return nRet

       
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj804Fin
Aglutina os titulos financeiros provisorio e gera um definitivo
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Lj804Fin(	aRecMFI	,	cLoja			,	cTipo		,	cNatureza	,;
								cPrefixo	,	dVencimento	,	aColsMfi	,	aColsSe2	)

Local aFilTit:={}                            // Array com os titulos ja adicionados
Local nScan  := 0                            // Scan no titulos adicionado 
Local aSe2Prov:= {}                          // Array de titulos provisorios
Local aAux    := {}                          // Array de titulos provisorios
Local nI      := 1                           //Contador
Local nSoma   := 0                           // somatoria dos titulos provisorios 
Local cParcela:= SuperGetMv("MV_1DUP",,"A")  // Define a parcela do titulo efetivo
Local cNatOp  := SuperGetMv("MV_LJNATRE",,"")// Define a natureza do titulo efetivo
Local cRet	  := ''                          // Armazena a chave do titulo efetivo
Local cFornecAnt := ''						// Armazena o fornecedor anterior

DEFAULT aRecMFI		:= {}
DEFAULT cLoja			:= ""
DEFAULT cTipo			:= ""
DEFAULT cNatureza		:= ""
DEFAULT cPrefixo		:= ""
DEFAULT dVencimento	:= CTOD("  /  /  ")
DEFAULT aColsMFI		:= {}
DEFAULT aColsSe2		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array dos titulos provisorios a serem substituidos|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
cFornecAnt := ''
For nI:= 1 To Len(aRecMFI)

	If (SE2->E2_FORNECE <> cFornecAnt).AND. !Empty(cFornecAnt)
		cRet := Lj804Sint(cPrefixo,cParcela,'',cNatureza,cFornecAnt,cLoja,dVencimento,nSoma,aSe2Prov,@aColsSe2)

		aSe2Prov	:= {}
		nSoma		:= 0
	Endif
	
	SE2->(DbGoTo(aRecMFI[nI]))	
	cFornecAnt := SE2->E2_FORNECE
	nScan:= aScan(aFilTit,SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_TIPO+SE2->E2_PREFIXO)
	If nScan == 0
		AAdd(aAux,  { "E2_FILIAL"   ,SE2->E2_FILIAL    , NIL }) 
		AAdd(aAux,  { "E2_PREFIXO"  ,SE2->E2_PREFIXO    , NIL }) 
		AAdd(aAux,	{ "E2_NUM"      , SE2->E2_NUM         , NIL })
		AAdd(aAux,	{ "E2_PARCELA"  , SE2->E2_PARCELA    , NIL })
		AAdd(aAux,	{ "E2_TIPO"     , SE2->E2_TIPO     , NIL })
		AAdd(aAux,	{ "E2_NATUREZ"  , cNatOp            , NIL })
		AAdd(aAux,	{ "E2_FORNECE"  , SE2->E2_FORNECE   , NIL })
		AAdd(aAux,	{ "E2_LOJA"     , SE2->E2_LOJA   , NIL})	

		aAdd(aSe2Prov,aAux)	         
		aAdd(aFilTit,SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_TIPO+SE2->E2_PREFIXO)	         
		//Adiciona no aColsMfi para exibir no Wizard
        Aadd(aColsMfi,{	SE2->E2_FILIAL	,SE2->E2_PREFIXO	,SE2->E2_NUM	,SE2->E2_TIPO,;
        					SE2->E2_EMISSAO	,SE2->E2_HIST		,SE2->E2_VALOR,.F.})
	EndIf	
	nSoma+= SE2->E2_VALOR
	aAux:={}
Next nI                                                                
cRet := Lj804Sint(	cPrefixo	, cParcela	, ''			, cNatureza	,;
						cFornecAnt	, cLoja		, dVencimento	, nSoma			,;
						aSe2Prov	, @aColsSe2 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Gravo o número do título atual dentro do E2_TITORIG dos anteriores
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
For nI := 1 To Len(aRecMFI)

	SE2->(DbGoTo(aRecMFI[nI]))	
	RecLock("SE2",.F.)
	SE2->E2_TITORIG := Substr(cRet,12,9)  // O próprio nome do título
	SE2->(MsUnlock())		

Next nI

Return cRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} Lj804VldSx6
Funcao que valida os parametros na SX6 para o processo de fechamento
da garantia estendida
@author Varejo
@since 28/05/2013
@version P11
*/

//-------------------------------------------------------------------   
Static Function Lj804VldSx6()
Local lRet 		  := .T.         //Variavel para retorno logico
Local cMsg        := ''          // Mensagem de retorno
Local cMVLJINSAR  := SuperGetMv("MV_LJINSAR") 	// Flag para ativar doação para Inst. Arredondar
Local cMVLJFORIA  := SuperGetMv("MV_LJFORIA") 	// Fornecedor
Local cMVLJLOJIA  := SuperGetMv("MV_LJLOJIA") 	// Loja
Local cMVLJPREIA  := SuperGetMv("MV_LJPREIA") 	// Prefixo do titulo a pagar provisorio /
Local cMVLJNATIA  := SuperGetMv("MV_LJNATIA") 	// Natureza

Return lRet

If Empty(cMvLJINSAR) .OR. Empty(cMvLJFORIA) .OR. Empty(cMvLJLOJIA) ;
						.OR. Empty(cMvLJPREIA) .OR. Empty(cMVLJNATIA)
   
	If Empty(cMvLJINSAR)
		cMsg+= STR0006+CRLF	//"Obrigatorio preencher o parametro MV_LJINSAR para continuar. "
	EndIf                                                                           
 
	If Empty(cMvLJFORIA)
		cMsg+= STR0007+CRLF	//"Obrigatorio preencher o parametro MV_LJFORIA para continuar. "
	EndIf                                                                           
 
	If Empty(cMvLJLOJIA)
		cMsg+= STR0008+CRLF//"Obrigatorio preencher o parametro MV_LJLOJIA para continuar. "
	EndIf
 
	If Empty(cMvLJPREIA)
		cMsg+= STR0009+CRLF//"Obrigatorio preencher o parametro MV_LJPREIA para continuar. "
	EndIf	
	
	If Empty(cMVLJNATIA)
		cMsg+= STR0010+CRLF//"Obrigatorio preencher o parametro MV_LJNATIA para continuar. "
	EndIf		
	
	MsgInfo(cMsg,STR0005) //"Atenção"
	lRet:= .F.

EndIf                   

Return lRet                           
                      

//-------------------------------------------------------------------
/* {Protheus.doc} LjMtaHeader
Monta o aHeader para exibir no Wizard
painel corrente.  

@author Varejo
@since 28/05/2013
@version P11
*/
//-------------------------------------------------------------------   
Static Function LjMtaHeader(cOpc)

Local aHeader:= {}
DEFAULT cOpc := '1'

If cOpc == '1'	

	aHeader := {{ STR0011 , "E2_FILIAL" ,PesqPict("SE2","E2_FILIAL") 	,TAMSX3("E2_FILIAL")[1] ,TAMSX3("E2_FILIAL")[2] ,,"AllwaysTrue()","C",, },;//"Filial"
				{ STR0012 , "E2_PREFIXO" ,PesqPict("SE2","E2_PREFIXO" )	,TAMSX3("E2_PREFIXO" )[1],TAMSX3("E2_PREFIXO" )[2],,"AllwaysTrue()","C",, },;//"Prefixo"
	            { STR0013 , "E2_NUM" 		,PesqPict("SE2","E2_NUM" )		,TAMSX3("E2_NUM" )[1],TAMSX3("E2_NUM" )[2],,"AllwaysTrue()","C",, },;//"No.Titulo"
	            { STR0014 , "E2_TIPO"   	,PesqPict("SE2","E2_TIPO")   	,TAMSX3("E2_TIPO")[1]   ,TAMSX3("E2_TIPO")[2]   ,,"AllwaysTrue()","C",, },;//"Tipo"
	            { STR0015 , "E2_EMISSAO" ,PesqPict("SE2","E2_EMISSAO")  	,TAMSX3("E2_EMISSAO")[1]   ,TAMSX3("E2_EMISSAO")[2]   ,,"AllwaysTrue()","D",, },;//"Emissão"
	            { STR0016 , "E2_HIST" ,	PesqPict("SE2","E2_HIST")		,TAMSX3("E2_HIST")[1]   ,TAMSX3("E2_HIST")[2]   ,,"AllwaysTrue()","C",, },;//"Histórico"
 	            { STR0017 , "E2_VALOR" 	,PesqPict("SE2","E2_VALOR" )		,TAMSX3("E2_VALOR" )[1],TAMSX3("E2_VALOR" )[2] ,,"AllwaysTrue()","N",, }}//"Valor"

ElseIf cOpc == '2'  // Após criar o registro único	

	aHeader := {{ STR0011 , "E2_FILIAL" ,PesqPict("SE2","E2_FILIAL") 	,TAMSX3("E2_FILIAL")[1] ,TAMSX3("E2_FILIAL")[2] ,,"AllwaysTrue()","C",, },;//"Filial"
				{ STR0012 , "E2_PREFIXO" ,PesqPict("SE2","E2_PREFIXO" )	,TAMSX3("E2_PREFIXO" )[1],TAMSX3("E2_PREFIXO" )[2],,"AllwaysTrue()","C",, },;//"Prefixo"
	            { STR0013 , "E2_NUM" 		,PesqPict("SE2","E2_NUM" )		,TAMSX3("E2_NUM" )[1],TAMSX3("E2_NUM" )[2],,"AllwaysTrue()","C",, },;//"No.Titulo"
	            { STR0014 , "E2_TIPO"   	,PesqPict("SE2","E2_TIPO")   	,TAMSX3("E2_TIPO")[1]   ,TAMSX3("E2_TIPO")[2]   ,,"AllwaysTrue()","C",, },;//"Tipo"
	            { STR0015 , "E2_EMISSAO" ,PesqPict("SE2","E2_EMISSAO")  	,TAMSX3("E2_EMISSAO")[1]   ,TAMSX3("E2_EMISSAO")[2]   ,,"AllwaysTrue()","D",, },;//"Emissão"
 	            { STR0017 , "E2_VALOR" 	,PesqPict("SE2","E2_VALOR" )		,TAMSX3("E2_VALOR" )[1],TAMSX3("E2_VALOR" )[2] ,,"AllwaysTrue()","N",, }}//"Valor"

EndIf

Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj804Sint  ºAutor  ³Vendas CRM          º Data ³ 17/Dez/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gravação do registro de contas a pagar por fornecedor       	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 																º±±
±±º          ³ 		   													    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA804                                                    	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj804Sint(	cPrefixo	,	cParcela	,	cTipo			,	cNatureza	,;
								cFornece	,	cLoja		,	dVencimento	,	nSoma		,;
								aSe2Prov	,	aColsSe2	)

Local aSe2 			:= {}						// Array para MsExecAuto 
Local cNum 			:= ''						// Número do Título
Local aAreaSE2			:= SE2->(GetArea())		// GetArea para SE2
Local cRet				:= ""							// Parâmetro de Saída

// Campo verificador se está sendo chamado pelo Robo
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

DEFAULT cPrefixo		:= ""
DEFAULT cParcela		:= ""
DEFAULT cTipo			:= ""
DEFAULT cNatureza		:= ""
DEFAULT cFornece		:= ""
DEFAULT cLoja			:= ""
DEFAULT dVencimento	:= CTOD("  /  /  ")
DEFAULT nSoma			:= 0
DEFAULT aSe2Prov		:= {}
DEFAULT aColsSe2		:= {}

Private lMsErroAuto 	:= .F.                   	//Variável de controle do execauto, retornará verdadeiro caso processou com erro.

DBSelectArea("SE2")
DbSetOrder(1)
Dbseek( xFilial("SE2") + cPrefixo + Replicate("Z", TamSX3("E2_NUM")[1]), .T. )
DbSkip(-1) 
If SubStr(SE2->E2_NUM, 1, 1) == "0"
	 cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
Else
 	cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array do titulo|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSe2  := {  { "E2_FILIAL"   ,xFilial("SE2")    , NIL },; 
			{ "E2_PREFIXO"  , cPrefixo          , NIL },;
            { "E2_NUM"      , cNum              , NIL },;
            { "E2_TITORIG"  , cNum              , NIL },;
            { "E2_PARCELA"  , cParcela          , NIL },;
            { "E2_TIPO"     , cTipo             , NIL },;
            { "E2_NATUREZ"  , cNatureza         , NIL },;
            { "E2_FORNECE"  , cFornece          , NIL },;
            { "E2_LOJA"     , cLoja              , NIL },;
            { "E2_EMISSAO"  , dDataBase		 	, NIL },;
            { "E2_VENCTO"   , dVencimento        , NIL },;
            { "E2_VALOR"    , nSoma   		    , NIL },;	
            { "E2_FLUXO"    , "S"   		    , NIL }}

Aadd(aColsSe2,{	xFilial("SE2")	,	cPrefixo	,	cNum	,	cTipo	,;
					dDataBase			,	nSoma		,	.F.		})	            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a inclusao do contas a pagar via ExecAuto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄEÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSExecAuto({|a,b,c,d,e,f,g,h,i,j| Fina050(a,b,c,d,e,f,g,h,i,j)},aSe2,,6,,,,,,aSe2Prov,)
If lMsErroAuto
	If !lAutomato
		MostraErro()
	Else
		MostraErro(GetTempPath())
	EndIf
Else
	cRet:= xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cFornece+'01'
EndIf	

RestArea(aAreaSE2)

Return cRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOJA804Def   ³ Autor ³Vendas Crm          ³ Data ³01/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que define os itens que serao apresentados no relato-³±±
±±³          ³rio de caracteristicas dos produtos no release 4.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA804Def()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Static Function LOJA804Def(cNumTit)
Local oReport	//Objeto relatorio TReport (Release 4)
Local oSection1 //Objeto secao 1 do relatorio (Lista, campos das tabelas SE2 com provisórios) 
Local oSection2 //Objeto secao 2 do relatorio (Lista, campos das tabelas SE2 com título novo criado) 
Local cAlias1 := "ANT"
Local cAlias2 := "NEW"

DEFAULT cNumTit := ""

#IFDEF TOP
	cAlias1		:= GetNextAlias()						
#ENDIF	

DEFINE REPORT oReport NAME "LOJA804" TITLE STR0018 PARAMETER "LOJA804" ACTION {|oReport| Lj804PrtRpt( oReport, cAlias1, cAlias2, cNumTit )} DESCRIPTION STR0019 //"Dados para o Instituto Arredondar"###"Este programa emitirá uma relação de clientes efetuando doação para o Inst. Arredondar"
oReport:SetPortrait()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao1 do relatorio, informando que o arquivo principal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SECTION oSection1 OF oReport TITLE STR0018 TABLES "ANT" //"Dados para o Instituto Arredondar"
DEFINE SECTION oSection2 OF oReport TITLE STR0018 TABLES "NEW" //"Dados para o Instituto Arredondar"
                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE CELL NAME "E2_FILIAL"			OF oSection1 ALIAS "ANT"
DEFINE CELL NAME "E2_PREFIXO"		OF oSection1 ALIAS "ANT"
DEFINE CELL NAME "E2_NUM"			OF oSection1 ALIAS "ANT"
DEFINE CELL NAME "E2_TIPO"			OF oSection1 ALIAS "ANT"
DEFINE CELL NAME "E2_EMISSAO"		OF oSection1 ALIAS "ANT"
DEFINE CELL NAME "E2_HIST"			OF oSection1 ALIAS "ANT"
DEFINE CELL NAME "E2_VALOR"			OF oSection1 ALIAS "ANT"
DEFINE CELL NAME "E2_FILIAL"			OF oSection2 ALIAS "NEW"
DEFINE CELL NAME "E2_PREFIXO"		OF oSection2 ALIAS "NEW"
DEFINE CELL NAME "E2_NUM"			OF oSection2 ALIAS "NEW"
DEFINE CELL NAME "E2_TIPO"			OF oSection2 ALIAS "NEW"
DEFINE CELL NAME "E2_EMISSAO"		OF oSection2 ALIAS "NEW"
DEFINE CELL NAME "E2_HIST"			OF oSection2 ALIAS "NEW"
DEFINE CELL NAME "E2_VALOR"			OF oSection2 ALIAS "NEW"

//Totalizador
DEFINE FUNCTION FROM oSection1:Cell("E2_VALOR") OF oSection1 FUNCTION SUM NO END SECTION TITLE STR0020 //"TOTAL GERAL"

 
Return(oReport)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³lj804PrtRpt  ³ Autor ³Vendas crm          ³ Data ³01/03/2010³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela impressao do relatorio              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ljr7PrtRpt(ExpO1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = objeto relatorio                                   ³±±
±±³          ³ ExpC1 = alias da query atual                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj804PrtRpt(oReport, cAlias1, cAlias2, cNumTit)
Local oSection1 := oReport:Section(1) 		//Objeto secao 1 do relatorio (Lista, campos das tabelas SE2)
Local oSection2 := oReport:Section(2) 		//Objeto secao 2 do relatorio (Lista, campos das tabelas SE2)
Local cFiltro	:= ""   					//String contendo o filtro de busca a ser utilizado com DBF   
Local cTipoPre := SuperGetMV("MV_LJTPFIN",,"PRE")  // Indicação de Título Provisório para o Financeiro
Local cBrancos := ""

DEFAULT oReport := Nil
DEFAULT cAlias1 := ""
DEFAULT cAlias2 := ""
DEFAULT cNumTit := ""

#IFDEF TOP 

	MakeSqlExpr("LOJA804") 
	DbSelectArea("SE2")	
    
	BEGIN REPORT QUERY oSection1
 	BeginSQL alias cAlias1                          	
           SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_TIPO,E2_EMISSAO,E2_HIST,E2_VALOR
           FROM   %table:SE2% ANT
           WHERE  	E2_TITORIG	= %exp:cNumTit% AND
           			E2_TIPO = %exp:cTipoPre% AND
           			ANT.%notDel%
     
           ORDER BY E2_FILIAL, E2_NUM
     EndSql    
	END REPORT QUERY oSection1      

	BEGIN REPORT QUERY oSection2
 	BeginSQL alias cAlias2                          	
           SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_TIPO,E2_EMISSAO,E2_HIST,E2_VALOR
           FROM   %table:SE2% NEW
           WHERE  	E2_TITORIG	= %exp:cNumTit% AND
           			E2_TIPO = %exp:cBrancos% AND
           			NEW.%notDel%
     
           ORDER BY E2_FILIAL, E2_NUM
     EndSql    
	END REPORT QUERY oSection2      

#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quebra a linha, caso existam muitas colunas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetLineBreak()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a impressao dos dados, de acordo com o filtro ou query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Print()

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj804Ok	³ Autor ³ Inovação Varejo          ³ Data ³ 21/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da data na janela.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj804ok()														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ [ <ExpD1> ] - Data inicial	da Pesquisa					  ³±±
±±³          ³ [ <ExpD2> ] - Data final da Pesquisa						  ³±±
±±³          ³ [ <ExpC1> ] - Fornecedor Inicial							  ³±±
±±³          ³ [ <ExpC2> ] - Fornecedor Final								  ³±±
±±³          ³ [ <ExpD3> ] - Data do Vencimento							  ³±±
±±³          ³ [ <ExpC4> ] - Condicao de pagamento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA804													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Origem: lojr140
Static Function Lj804Ok( dDataIni, dDataFim, cFornecPergunte, dVencimento )
Local lRet := .T.
Local cFornecArredondar := SuperGetMv("MV_LJFORIA",,"")		// Fornecedor destinado ao Instituto Arredondar

DEFAULT dDataIni 			:= CTOD("  /  /  ")
DEFAULT dDataFim 			:= CTOD("  /  /  ")
DEFAULT cFornecPergunte	:= ""
DEFAULT dVencimento		:= CTOD("  /  /  ")

Do Case
	Case Empty( dDataIni )
		Help(" ","1","DATINIVAZ")
		lRet := .F.
	Case Empty( dDataFim )
		Help(" ","1","DATFIMVAZ")
		lRet := .F.
	Case dDataIni > dDataFim
		Help(" ","1","DATAMAIOR")
		lRet := .F.
	Case dDataFim < dDataIni
		Help(" ","1","DATAMENOR")
		lRet := .F.
	Case Empty( cFornecPergunte )  
		MsgInfo( OemToAnsi( STR0021 ) ) //"Fornecedor não pode ser deixado em branco."
		lRet := .F.
	Case cFornecPergunte <> cFornecArredondar	
		MsgInfo( OemToAnsi( "O código do fornecedor deve ser igual ao parâmetro MV_LJFORIA." ) ) //STR0022
		lRet := .F.
	Case ( dVencimento < dDatabase )		
		MsgInfo( OemToAnsi( STR0023 ) ) //"Data do Vencimento não pode ser menor que a data corrente."
		lRet := .F.
EndCase

Return( lRet )


