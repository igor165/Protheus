#INCLUDE "TMKA290.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA290   ºAutor  ³Vendas Clientes     º Data ³  27/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de atualizacao de titulos baixados com negociacao da º±±
±±º          ³Telecobranca, com apontamento do Operador (cobrador).       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMKA290()

Local cLockByName	:= "TMKSK1" + FWCodEmp( "SK1" )

PRIVATE aRotina := MenuDef() 

PRIVATE cCadastro := STR0004 //"Baixa de Cobrancas Recebidas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite a abertura simultanea para o modelo MDI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LockByName( cLockByName, .T., .F. )
	Help("  ",1,"TMKEXCSK1")
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(,,,,"SA1")

UnLockByName( cLockByName, .T., .F. )

Return(.T.) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³11/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= {		{	STR0001,	"AxPesqui",	0, 1, , .F.},;		//"Pesquisar"
						{	STR0002,	"AxVisual",	0, 2, , .T.},;		//"Visualizar"
						{	STR0003,	"Tk290Atu",	0, 3, , .T.} }		//"Baixar"
				
		                                                     
					
							
Return(ARotina)


Function Tk290JobBX( aParam )

Default aParam := {}

If !Empty( aParam )
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "SA1","SK1", "ACG", "ACF", "SE1", "SE5", "SU6"
	Tk290Atu()
	RESET ENVIRONMENT
EndIf
Return Nil 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk290Atu  ºAutor  ³Vendas Clientes     º Data ³  02/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utiliza este recurso para montar a regua de progresso.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk290Atu()

Local lExiste	:= .F.							// Flag para indicar se o usuario esta no cadastro de Operadores
Local cEncerra	:= GetNewPar("MV_TMKENC","")	// Codigo de Encerramento padrao para encerrar atendimentos telecobranca  
Local cMotivo	:= GetNewPar("MV_TMKMEMO","")	// Observacao padrao para motivo de encerramento 
Local lRet		:= .F.							// Retorno dessa funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o usuario no cadastro de operadores					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lExiste := TmkOperador()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao encontrou o usuario no Cadastro de Operadores e ele nao e um SUPERVISOR - Nao processa³
//³Quando rotina for executada por Schedulle, nao realiza essa verificacao.						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IsBlind() 		//Se nao estiver no SCHEDULE
	If !lExiste .OR. SU7->U7_TIPO <> "2"
		Help(" ",1,"TK180NSUPE")
		Return(lRet)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao foram preenchidos os parametros para encerramento do atendimento nao processa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cEncerra)
	If !IsBlind()		//Se nao estiver no SCHEDULE 
		MsgStop(STR0007,STR0008)//"Sera necessario preencher o parametro MV_TMKENC que define o codigo de encerramento, pois será utilizado para encerrar os atendimentos de Telecobrança" 
	Endif
	Return(lRet)
Endif	
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver no SCHEDULE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IsBlind()			//Se nao estiver no SCHEDULE       
	If TMKOK(STR0005)	//"Esta rotina irá baixar as pendencias de cobranças e encerrar os atendimentos cujos títulos foram pagos. Deseja efetuar as baixas das cobrancas de todos os Operadores?"
		Processa( {|| TK290Baixa(cEncerra,cMotivo) }, STR0006) //"Baixando títulos cobrados e pagos..."
		lRet := .T.
	Endif
Else
	BatchProcess(,,, { || TK290Baixa(cEncerra,cMotivo) } )
	lRet := .T.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk290BaixaºAutor  ³Vendas Clientes     º Data ³  02/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de atualizacao de titulos baixados com negociacao da º±±
±±º          ³Telecobranca, com apontamento do Operador (cobrador).       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk290Baixa(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = codigo de encerramento                             ³±±
±±³          ³ ExpC2 = motivo da baixa       		                      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk290Baixa(cEncerra,cMotivo)

Local lRet		:= .T.												// Retorno da funcao
Local cSK1		:= "SK1"											// Alias do SK1 para controle em DBF e TOP
Local cFilOrig	:= ""												// Filial de origem do titulo
Local cBaixa	:= ""  												// Tipo da Baixa
Local cCliente	:= ""												// Codigo do cliente no SK1
Local cLoja	    := ""      											// Codigo da loja no SK1
Local nACG		:= 0 												// Quantidade de registros processados na tabela ACG
Local cNumACF	:= 0     											// Codigo de atendimento do ACF
Local nPos		:= 0  												// Posicao do array
Local aAtend	:= {}												// Array com os codigos de atendimento que devem ser encerrados
Local dUltimo	:= GetNewPar("MV_TMKBXCO", dDatabase) 				// Data da ultima execucao da rotina de baixa de cobranca
Local cPrefixo	:= ""												// Prefixo do titulo no SK1
Local cTitulo	:= ""												// Numero do titulo no SK1
Local cTipo		:= ""												// Tipo do titulo no SK1
Local cParcela	:= ""												// Parcela do titulo no SK1
Local cOperad	:= ""												// Operador relacionado ao titulo no SK1
Local lBaixa	:= .F.												// Identifica se houve baixa para o titulo
Local aAreaPE	:= {}												// Armazena posicionamento antes do ponto de entrada
Local lTk290Grv	:= ExistBlock("TK290GRV")							// Verifica a existencia do ponto de entrada

#IFDEF TOP
	Local cQuery	:= ""
#ENDIF

Dbselectarea("SK1")
DbsetOrder(4)//Cliente+Loja+Vencimento Real		
#IFDEF TOP
	
	Conout(DTOC(dDatabase) + " - " + Time () + STR0010)            //" 1- Inicio da Query para filtrar os titulos pagos ou com baixa ..."

	cSK1	:= "TMPSK1"
	cQuery	:=	" SELECT K1_FILIAL, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_OPERAD, K1_CLIENTE, K1_LOJA, " 
				
	cQuery	+=" K1_FILORIG, "
				
	cQuery  +=	" E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO " +;
				" FROM " +	RetSqlName("SK1") + " SK1 LEFT JOIN " +;
							RetSqlName("SE1") + " SE1 "  +;
				" ON( SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND " 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para filtrar apenas os titulos da filial de origem.  ³
				//³Se o campo nao estiver criado, assumo a filial corrente do SE1. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery+=" SK1.K1_FILORIG = SE1.E1_FILIAL 	AND " 

	cQuery+=	"		SK1.K1_PREFIXO  = SE1.E1_PREFIXO 	AND " +;
				"		SK1.K1_NUM  	= SE1.E1_NUM 		AND " +;
				"		SK1.K1_PARCELA  = SE1.E1_PARCELA 	AND " +;
				"		SK1.K1_TIPO  	= SE1.E1_TIPO 		)	" +;                    
				" WHERE	SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND " +;
				"(SE1.E1_NUM IS NULL OR SE1.D_E_L_E_T_ <> '' OR (( SE1.E1_SALDO 	= 0	 OR  SE1.E1_BAIXA >= '" + DTOS(dUltimo) + "') AND SE1.D_E_L_E_T_ = '')) AND SK1.D_E_L_E_T_ = ''" +;    //Titulos pagos ou que sofreram alguma baixa apos a execucao da rotina				
				" ORDER BY K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO "
		
	cQuery	:= ChangeQuery(cQuery)
	MemoWrite("TK290SK1.SQL", cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSK1, .F., .T.)

	Conout(DTOC(dDatabase) + " - " + Time () + STR0011)		//" 2- Termino da Query para filtrar os titulos pagos ou com baixa ..."

#ELSE
	DbgoTop()
	DbSeek(xFilial("SK1"),.T.)		
#ENDIF


Conout(DTOC(dDatabase)+ " - " +  Time () + STR0012)			//" 3- Processando os relacionamentos da tabela SK1 com os atendimentos ..."

While !Eof() .AND. xFilial("SK1") == (cSK1)->K1_FILIAL
	
	cPrefixo	:= (cSK1)->K1_PREFIXO
	cTitulo		:= (cSK1)->K1_NUM
	cTipo		:= (cSK1)->K1_TIPO 
	cParcela	:= (cSK1)->K1_PARCELA
	cOperad		:= (cSK1)->K1_OPERAD
	lBaixa		:= .F.

	BEGIN TRANSACTION
	
	cCliente:= (cSK1)->K1_CLIENTE
	cLoja   := (cSK1)->K1_LOJA   

	cFilOrig	:= (cSK1)->K1_FILORIG


	DbSelectArea("ACG")
	DbSetOrder(2) //Filial + Prefixo + Titulo + Parcela + Tipo + Filial de origem
	If DbSeek(xFilial("ACG") + (cSK1)->K1_PREFIXO + (cSK1)->K1_NUM + (cSK1)->K1_PARCELA + (cSK1)->K1_TIPO + cFilOrig )
		
		While !Eof() 	.AND. xFilial("ACG")	== ACG->ACG_FILIAL  	.AND.;
						(cSK1)->K1_PREFIXO   	== ACG->ACG_PREFIXO		.AND.;
						(cSK1)->K1_NUM       	== ACG->ACG_TITULO		.AND.;
						(cSK1)->K1_PARCELA   	== ACG->ACG_PARCEL		.AND.;
						(cSK1)->K1_TIPO      	== ACG->ACG_TIPO		.AND.;
						cFilOrig == ACG->ACG_FILORI
						
			cFilOrig	:= ACG->ACG_FILORI

	        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa o atendimento e pega o numero³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Dbselectarea("ACF")
			DbsetOrder(1)
			If DbSeek(xFilial("ACF") + ACG->ACG_CODIGO)
			    
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza a tabela de movimentacao bancaria SE5 e se foi pago totalmente deleta o SK1.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        Tk290Pago(	cFilOrig,		ACG->ACG_PREFIXO,	ACG->ACG_TITULO, ACG->ACG_PARCEL,;
		           			ACG->ACG_TIPO,	ACF->ACF_DATA,		ACF->ACF_OPERAD, @cBaixa,;
		           			ACF->ACF_CLIENT,ACF->ACF_LOJA)
		            
				If !Empty(cBaixa)

					lBaixa	:= .T.

					DbSelectArea("ACG")
					RecLock("ACG", .F.)
					REPLACE ACG->ACG_STATUS WITH cBaixa
					MsUnLock()
	
				    //Se foi baixado totalmente        
					If cBaixa == "1"
				        nACG++
						nPos:= Ascan(aAtend,{|x| x[1] == ACF->ACF_CODIGO})
						If nPos > 0
						    aAtend[nPos][2]+= nACG
						Else	
							Aadd(aAtend,{ACF->ACF_CODIGO, nACG})
						Endif	
			        Endif
			    Endif
					            
			Endif
		
			DbSelectarea("ACG")
			DbSkip()
		    
		    nACG:= 0
    
		End
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao existiu uma negociacao mas foi totalmente pago deleta o SK1. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       	Tk290Pago(	(cSK1)->K1_FILORIG,	(cSK1)->K1_PREFIXO,		(cSK1)->K1_NUM, (cSK1)->K1_PARCELA,;
           	 		(cSK1)->K1_TIPO,	Nil, 					(cSK1)->K1_OPERAD, @cBaixa,;
           	 		(cSK1)->K1_CLIENTE, (cSK1)->K1_LOJA)
	Endif			

    END TRANSACTION

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houve baixa e existir o ponto de entrada TK290GRV³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lTk290Grv .AND. lBaixa
    	aAreaPE	:= GetArea()
    	U_Tk290Grv(	cPrefixo	, cTitulo	, cTipo		, cParcela	,;
    				cFilOrig	, cOperad 	)
    	RestArea(aAreaPE)
    EndIf
    
	Dbselectarea(cSK1)
	Dbskip()
	
End

#IFDEF TOP
	DbSelectArea(cSK1)
	DbCloseArea()
#ENDIF 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encerra os atendimentos e as pendencias do operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aAtend) > 0
	Tk290Encerra(aAtend, cMotivo, cEncerra)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o parametro MV_TMKBXCO que indica quando foi feita a ultima execucao da rotina.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea("SX6")
	DbSetOrder(1)
	If DbSeek(xFilial("SX6") + "MV_TMKBXCO") 
		RecLock("SX6",.F.)
		PutMv("MV_TMKBXCO",DtoC(dDatabase))
		MsUnLock()
	Endif
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se existe algum registro no SK1 que nao existe no SE1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	Tk290ExcSK1()
#ENDIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk290Pago ºAutor  ³Vendas Clientes     º Data ³  07/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica para cada titulo se o mesmo se encontra pago.      º±±
±±º          ³Se possuir baixa parcial, atualiza o codigo do operador.    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk290Pago(ExpC1,ExpC2,ExpC3,ExpC4,						  ³±±
±±|			 |			 ExpC5,ExpD6,ExpC7,ExpC8,ExpC9)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de origem                                   ³±±
±±³          ³ ExpC2 = Codigo do prefixo                                  ³±±
±±³          ³ ExpC3 = Numero do titulo                                   ³±±
±±³          ³ ExpC4 = Numero da parcela                                  ³±±
±±³          ³ ExpC5 = Codigo do tipo                                     ³±±
±±³          ³ ExpD6 = Data da negociacao                                 ³±±
±±³          ³ ExpC7 = Codigo do operador                                 ³±±
±±³          ³ ExpC8 = Codigo da baixa                                    ³±±
±±³          ³ ExpC9 = Codigo do cliente                                  ³±±
±±³          ³ ExpC10= Codigo da loja                                     ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk290Pago(	cFilOrig	,cPrefixo	,cNumero	,cParcela,;
							cTipo		,dData		,cOperador	,cBaixa	,;
							cCliente	,cLoja)	

Local lRet		:= .T.  				// Retorno da funcao
Local aAreaSK1 	:= SK1->(GetArea())	// Salva a area do SK1
Local oModelMov := Nil
Local oSubFK9   := Nil
Local oSubFKA	:= Nil
Local cLog 		:= ''
Local cCamposE5 := ""
Local cIdMovFK5 := ""

DEFAULT	dData	:= Ctod("  /  /  ")		// Data do atendimento de cobranca

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Utilizada atualizar os itens do atendimento de cobranca. ³
//³eh passada como referencia e retorna o status do titulo  ³
//³1- Pago                                                  ³
//³4- Baixa                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBaixa	:= ""

DbSelectarea("SE1")
DbSetOrder(2) //Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
If DbSeek(cFilOrig + cCliente + cLoja + cPrefixo + cNumero + cParcela + cTipo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houve uma baixa verifica se foi TOTAL ou PARCIAL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SE1->E1_BAIXA)
		If (SE1->E1_SALDO > 0)
			cBaixa:= "4" //Baixa
		Endif
		
		If (SE1->E1_SALDO == 0)
			cBaixa:= "1" //Pago
		Endif
    Endif
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a data de negociacao nao estiver vazia, atualiza o codigo do operador que efetuou a cobranca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dData)
		DbSelectArea("SE5")
		DbSetOrder(7)//Prefixo+Numero+Parcela+Tipo+Cliente+Loja+Seq
		If DbSeek(cFilOrig + cPrefixo + cNumero + cParcela + cTipo + cCliente + cLoja)
			
			While	!Eof()						.AND.;
				SE5->E5_FILIAL	== cFilOrig		.AND.;
 				SE5->E5_PREFIXO	== cPrefixo		.AND.;
				SE5->E5_NUMERO	== cNumero		.AND.;
				SE5->E5_PARCELA	== cParcela		.AND.;
				SE5->E5_TIPO	== cTipo 		.AND.;
				SE5->E5_CLIFOR	== cCliente		.AND.;
				SE5->E5_LOJA	== cLoja
				
				If SE5->E5_DATA >= dData .AND. Empty(SE5->E5_OPERAD)

					cIdMovFK5 := FINFK5BUSCA(cFilOrig+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja+SE5->E5_SEQ,"SE5",.F.)
					
					cCamposE5 := "{{'E5_OPERAD' , '"+ cOperador +"' }}"	//Campos que serão gravados na SE5

					//Reestruturação do financeiro.
					oModelMov := FWLoadModel('FINM010') //Model do Baixas a Receber
					oModelMov:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
					oModelMov:Activate()
					oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Informa se vai gravar SE5 ou não
					oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )
					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					oSubFKA := oModelMov:GetModel( 'FKADETAIL' )
					If oSubFKA:SeekLine( { {'FKA_IDORIG', cIdMovFK5 } } )
						
						//Informa valores na FK9
						oSubFK9 := oModelMov:GetModel( 'FK9DETAIL' )
						oSubFK9:SetValue( 'FK9_FILIAL', cFilOrig   )
						oSubFK9:SetValue( 'FK9_OPERAD', cOperador  )
						oSubFK9:SetValue( 'FK9_IDMOV' , cIdMovFK5  )
						
						//Grava os dados.
						If oModelMov:VldData()
							oModelMov:CommitData()
						Else
							lRet := .F.
							cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[6])
							
							CONOUT(cLog)
						Endif
					EndIf			
					oModelMov:DeActivate()
					oModelMov:Destroy()
					oModelMov:= Nil				
				EndIf                      
				
				DbSelectArea("SE5")
				DbSkip()
			End
	    Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se foi pago Totalmente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cBaixa == "1"	
		Tk290DelSK1(cFilOrig , cPrefixo , cNumero , cParcela , cTipo)	
	Endif
Else
	
	Tk290DelSK1(cFilOrig , cPrefixo , cNumero , cParcela , cTipo)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a variavel que identifica se o titulo foi pago. O titulo nao existe mais, por isso³
	//³o relacionamento com as tabelas de atendimento e lista de contato devem ser encerradas.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBaixa:= "1"	
	
Endif

RestArea(aAreaSK1)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk290DelSK1 ºAutor  ³Vendas Clienteº Data ³  07/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta o registro da tabela SK1 que ja se encontra pago.º±±
±±º          ³OU Deleta quando nao existe mais o SE1.                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk290Pago(ExpC1,ExpC2,ExpC3,ExpC4,					  ³±±
±±|			 |			 ExpC5)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de origem                               ³±±
±±³          ³ ExpC2 = Codigo do prefixo                              ³±±
±±³          ³ ExpC3 = Numero do titulo                               ³±±
±±³          ³ ExpC4 = Numero da parcela                              ³±±
±±³          ³ ExpC5 = Codigo do tipo                                 ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk290DelSK1(	cFilOrig , cPrefixo , cNumero , cParcela , ;
								cTipo )

Local aAreaSK1 	:= SK1->(GetArea())	// Salva a area do SK1
Local lRet		:= .F.
	
DbSelectArea("SK1")
DbSetOrder(1)
		
If DbSeek(xFilial("SK1") + cPrefixo + cNumero + cParcela + cTipo + cFilOrig)
	RecLock("SK1", .F., .T.)
	DbDelete()
	MsUnLock()  
	lRet	:= .T. 
Endif

RestArea(aAreaSK1)
Return(lRet)
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk290Encerra ºAutor  ³Vendas Clientes   º Data ³  04/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encerra os atendimentos e as pendencias do operador.        º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk290Encerra(ExpA1,ExpC2,ExpC3)         					  ³±±
±±|			 |			                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Codigos de atendimento                             ³±±
±±³          ³ ExpC2 = Codigo do motivo                                   ³±±
±±³          ³ ExpC3 = Codigo de encerramento                             ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TELECOBRANCA                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk290Encerra(aAtend, cMotivo, cEncerra)

Local nX 		:= 0				// Controle de loop
Local lRet		:= .T. 				// Retorno da funcao
Local nACG		:= 0				// Contador de registros existente na tabela ACG para o atendimento
Local aString	:= {""}    			// Variavel que contem os codigos de atendimento para utilizar na query
Local lPago		:= .T.				// Retorna se o item do atendimento está pago
Local aAreaACG	:= ACG->(GetArea())	// Salva area da tabela ACG

     
#IFDEF TOP
	Local cQuery	:= ""
	Local nY
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta a variavel com os codigos de atendimento para utilizar na query.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:= 1 TO Len(aAtend)
	If (nX%100) == 0
		aString[Len(aString)] := Left(aString[Len(aString)],Len(aString[Len(aString)])-1)	// Tira a ultima virgula da string
		Aadd(aString,"")
	EndIf
	aString[Len(aString)] += aAtend[nX][1]+","
Next nX
aString[Len(aString)] := Left(aString[Len(aString)],Len(aString[Len(aString)])-1) 			// Tira a ultima virgula da string

#IFDEF TOP
	For nY := 1 to Len(aString)	
	
		Conout(DTOC(dDatabase) + " - " + Time () + STR0013)		//" 4- Inicio da Query para filtrar os atendimentos e as pendencias que serao encerradas..."
	
		cACF	:= "TMPACF"
		cQuery	:= "SELECT ACF_CODIGO, ACF_CLIENT, ACF_LOJA,  COUNT (*) ATEND" +;
					" FROM " + RetSqlName("ACF")+ " ACF, " +	RetSqlName("ACG")+ " ACG " +;
					" WHERE ACF.ACF_FILIAL = '" + xFilial("ACF") + "' AND " +;
					"	    ACF.ACF_FILIAL = ACG.ACG_FILIAL AND " +;
					" 		ACG.ACG_CODIGO IN " + FormatIn(aString[nY],",") + " AND " +;
					" 		ACG.ACG_CODIGO 	= ACF_CODIGO AND " +;
					" 	    ACG.D_E_L_E_T_ 	= ''  AND " +;
					"       ACF.D_E_L_E_T_ = '' "+;
	                " GROUP BY ACF_CODIGO, ACF_CLIENT, ACF_LOJA " +;
	                " ORDER BY ACF_CODIGO, ACF_CLIENT, ACF_LOJA "
	
		cQuery	:= ChangeQuery(cQuery)
		MemoWrite("TK290COUNT.SQL", cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cACF, .F., .T.)
	
		Conout(DTOC(dDatabase) + " - " + Time () + STR0014)		//" 5- Termino da Query para filtrar os atendimentos e as pendencias que serao encerradas..."
	
		DbselectArea(cACF)
		While !Eof() 
			
			nPos:= Ascan(aAtend,{|x| x[1] == (cACF)->ACF_CODIGO })
			If nPos == 0
				Dbskip()
				Loop
			Endif	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica todos os itens do atendimento, caso exista algum item que nao esteja pago,³
			//³o sistema nao encerra o atendimento.                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACG")
			DbSetOrder(1)
			DbSeek(xFilial("ACG")+(cACF)->ACF_CODIGO)
			lPago := .T.
			While !Eof() .AND. ACG->ACG_FILIAL == xFilial("ACG") .AND. ACG->ACG_CODIGO == (cACF)->ACF_CODIGO .AND. lPago == .T.
			
				If ACG->ACG_STATUS <> "1" 
					
					DbSelectArea("SE1")
					DbSetOrder(2)
					
					If DbSeek(ACG->ACG_FILORI + (cACF)->ACF_CLIENT + (cACF)->ACF_LOJA + ACG->ACG_PREFIXO + ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO)
					
						//Verifica se o saldo do titulo esta maior que 0, nos casos de titulos ainda não vencidos
						If SE1->E1_SALDO > 0
						 
							lPago := .F.
							
						EndIf
						
					EndIf
					
				EndIf
				
				DbselectArea("ACG")
				DbSkip()
			End
			
			If lPago
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza com status de encerrado os relacionamentos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Tk290AtuStatus(aAtend[nPos][1], cMotivo, cEncerra)
			Endif
	
			DbselectArea(cACF)
			DbSkip()
		End
	
	DbSelectArea(cACF)
	DbCloseArea()
	
	Next nY
#ELSE
	Dbselectarea("ACF") 
	DbsetOrder(1)//Cliente+Loja+Vencimento Real		
	DbSeek(xFilial("ACF"),.T.)
			
	For nX:= 1 to Len(aAtend)
	
		Dbselectarea("ACF") 
		DbsetOrder(1)//Cliente+Loja+Vencimento Real
		If ACF->(DbSeek(xFilial("ACF")+aAtend[nX][1]))
		
			DbselectArea("ACG")
			DbsetOrder(1)
			If ACG->(DbSeek(xFilial("ACG") + aAtend[nX][1]))
				While !Eof() .AND. xFilial("ACG") 	== ACG->ACG_FILIAL .AND.;
									ACG->ACG_CODIGO == aAtend[nX][1]
					nACG++
					Dbselectarea("ACG")
					Dbskip()
				End									
				If 	nACG == aAtend[nX][2]						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza com status de encerrado os relacionamentos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Tk290AtuStatus(aAtend[nX][1], cMotivo, cEncerra)
				Endif
			Endif
		nACG:=0		
	    
	    Endif
	    
	Next nX
#ENDIF

RestArea(aAreaACG)

Return(lRet)     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk290AtuStatusºAutor  ³Vendas Clientes º Data ³  04/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza com o status de encerrado os relacionamentos da    º±±
±±º          ³cobranca efetuada.                                          º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk290AtuStatus(ExpA1,ExpC2,ExpC3)      					  ³±±
±±|			 |			                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Codigos de atendimento                             ³±±
±±³          ³ ExpC2 = Codigo do motivo                                   ³±±
±±³          ³ ExpC3 = Codigo de encerramento                             ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk290AtuStatus(cAtend, cMotivo, cEncerra)
            
Local lRet:= .T.  
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encerra o atendimento e grava o codigo e o motivo de encerramento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Dbselectarea("ACF")
DbSetOrder(1)
If DbSeek(xFilial("ACF")+cAtend)
	Reclock("ACF",.F.)
	REPLACE ACF->ACF_STATUS WITH "3"											// Encerrado
	REPLACE ACF->ACF_CODENC	WITH cEncerra										// Codigo do Encerramento
	If !Empty(AllTrim(cMotivo))
		MSMM(,TamSx3("ACF_OBSMOT")[1],,cMotivo,1,,,"ACF","ACF_CODMOT")// Motivo de Encerramento
	EndIf
	MsUnlock()

	DbSelectArea("SU4")
	DbSetOrder(4)//Codigo da Ligacao
	If DbSeek(xFilial("SU4")+cAtend)
		RecLock("SU4", .F.)
		REPLACE SU4->U4_STATUS	WITH "2"
		REPLACE SU4->U4_DATA	WITH dDataBase	//Data em que foi encerrado
		REPLACE SU4->U4_ROTINA WITH "TK290ATU"

		MsUnLock()
		
		DbSelectArea("SU6") 
		DbSetOrder(1)//Lista
		If DbSeek(xFilial("SU6")+SU4->U4_LISTA)
			RecLock("SU6", .F.)
			REPLACE SU6->U6_STATUS WITH "3"
			REPLACE SU6->U6_DATA   WITH dDataBase 	//Data em que foi encerrado
			REPLACE SU6->U6_ROTINA WITH "TK290ATU"	
			MsUnLock()
		Endif 
	Endif	
Endif

RestArea(aArea)	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk290ExcSK1ºAutor ³Vendas Clientes     º Data ³  06/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao se existe algum registro no SK1 que nao contem no º±±
±±º          ³SE1                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA290                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk290ExcSK1()
Local cQuery	:= ""		// Variavel com o conteudo da Query utilizada para no Select
Local cSK1		:= ""		// Alias do SK1 utilizacao no temporario
Local cSeek		:= ""		// Variavel com o conteudo do Seek
Local lFilOrig	:= .F.		// Valida se o campo K1_FILORIG existe na base

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa somente se estiver no SCHEDULE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsBlind()
	Conout(DTOC(dDatabase) + " - " + Time () + "Tk290ExcSK1 1- Inicio da Query para filtrar os titulos que existem no SK1 e nao existem no SE1 ...")
	cSK1	:= "TMPSK1"
	cQuery	:=	" SELECT K1_FILIAL, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_OPERAD, K1_CLIENTE, K1_LOJA " 
	cQuery	+=" ,K1_FILORIG "
	lFilOrig := .T.

	cQuery  +=	"  FROM " +	RetSqlName("SK1") + " SK1 "
	cQuery  +=	" WHERE SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND "
	cQuery  +=	"   NOT EXISTS ( SELECT SE1.E1_FILIAL "
	cQuery  +=	"                  FROM " +	RetSqlName("SE1") + " SE1 "
	cQuery  +=	"                 WHERE E1_FILIAL	= SK1.K1_FILORIG "
	cQuery  +=	" 	                 AND E1_CLIENTE	= SK1.K1_CLIENTE "
	cQuery  +=	" 	                 AND E1_LOJA		= SK1.K1_LOJA "
	cQuery  +=	" 	                 AND E1_PREFIXO	= SK1.K1_PREFIXO "
	cQuery  +=	" 	                 AND E1_NUM		= SK1.K1_NUM "
	cQuery  +=	" 	                 AND E1_PARCELA	= SK1.K1_PARCELA "
	cQuery  +=	" 	                 AND E1_TIPO		= SK1.K1_TIPO "
	cQuery  +=	" 	                 AND SE1.D_E_L_E_T_	= '' "
	cQuery  +=	"	                 AND SK1.D_E_L_E_T_	= '') "
	cQuery  +=	"   AND SK1.D_E_L_E_T_	= '' "	
	cQuery  +=	" ORDER BY K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO "	

	cQuery	:= ChangeQuery( cQuery )
	MemoWrite( "TK290SK1.SQL", cQuery )
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSK1, .F., .T.)
	Conout(DTOC(dDatabase) + " - " + Time () + "Tk290ExcSK1 2- Termino da Query para filtrar os titulos que existem no SK1 e nao existem no SE1 ...")
	
	DbSelectArea(cSK1)
	(cSK1)->( DbGotop() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre o arquivo temporario gerado na Query, para apagar os registros no SK1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cSK1)->( !Eof() )
		DbSelectArea("SK1")
		DbSetOrder(1)
		
		If lFilOrig
			cSeek := xFilial( "SK1" ) + (cSK1)->K1_PREFIXO + (cSK1)->K1_NUM + (cSK1)->K1_PARCELA + (cSK1)->K1_TIPO + (cSK1)->K1_FILORIG
		Else
			cSeek := xFilial( "SK1" ) + (cSK1)->K1_PREFIXO + (cSK1)->K1_NUM + (cSK1)->K1_PARCELA + (cSK1)->K1_TIPO
		Endif
				
		If DbSeek( cSeek )
			RecLock("SK1", .F.)
			DbDelete()
			MsUnLock()  
		Endif
		
		Dbselectarea( cSK1 )
		(cSK1)->( Dbskip() )
	End

	DbSelectArea(cSK1)
	DbCloseArea() 
Endif
Return()
