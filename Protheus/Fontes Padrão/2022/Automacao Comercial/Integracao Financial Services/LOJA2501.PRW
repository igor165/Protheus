#INCLUDE "PROTHEUS.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA2501   ºAutor  ³Microsiga          º Data ³ 12/03/12    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para execução via JOB                               º±±
±±º          ³ Para envio dos títulos baixados para o CAP                 º±±
±±º          ³ na integração com Financial Service                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOJA2501(aParams)
	Local lBat		:= IIF(aParams == NIL, .F., .T.)		// Checa se eh JOB ou execucao manual (lBat = .T. = JOB)
	Local cEmpJob	:= IIF(!lBat, cEmpAnt, aParams[1])		// Se for JOB, pega a empresa do schedule
	Local cFilJob	:= IIF(!lBat, cFilAnt, aParams[2])  	// Se for JOB, pega a filial do schedule
    Local cFilMEQ	:= xFilial("MEQ")
  
	conout( '>->-> Inicio LOJA2501')

	If lBat
		RpcSetType( 3 ) // tipo 3 inicia o processo sem consumir licenca
		RpcSetEnv( cEmpJob, cFilJob,,,"FIN") //Cria o ambiente com base em empresa, filial e modulo
	EndIf		

	// verifica se a integração com Financial Service está habilitada
	If SuperGetMV("MV_LJINTFS", ,.F.) 

		BeginSql Alias "QryTitBaixa"    
		
			COLUMN E1_EMISSAO	AS DATE
			COLUMN E5_DATA		AS DATE

			SELECT	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_PARCELA, E1_SALDO, E1_EMISSAO,E1_VALOR, E5_FILORIG, E5_FORMAPG, E5_MOTBX,
					E5_DATA, E5_VALOR, E5_VLCORRE, E5_VRETIRF, E5_VLJUROS, E5_VLMULTA, E5_VLDESCO, SE5.E5_SEQ, SE5.E5_TIPODOC,
					MEQ_OPERAC, MEQ.R_E_C_N_O_ AS MEQRECNO, SE5.R_E_C_N_O_ AS SE5RECNO, E1_TIPO, SE5.E5_FILIAL,
			        (SELECT COUNT(1)
						FROM %table:SE5% AS SE51
						WHERE  SE51.%notDel%
							AND SE5.E5_FILIAL	= SE51.E5_FILIAL
							AND E1_PREFIXO	= SE51.E5_PREFIXO
							AND	E1_NUM		= SE51.E5_NUMERO
							AND E1_PARCELA	= SE51.E5_PARCELA
							AND E1_TIPO		= SE51.E5_TIPO
							AND SE5.E5_SEQ	= SE51.E5_SEQ
							AND SE5.E5_RECPAG = SE51.E5_RECPAG
			   				AND (SE51.E5_TIPODOC IN ('VL', 'V2', 'BA', 'RA', 'CP', 'LJ')  OR 
			   						(%exp:SuperGetMv("MV_CRNEG",,"FAT")% = 'S' AND SE51.E5_RECPAG = 'R')  OR 
			   						(SE51.E5_TIPODOC = 'ES' AND SE51.E5_RECPAG = 'P') 
			   				    ) ) AS SE5DUP			
				FROM %table:MEQ% AS MEQ			
				JOIN %table:SE1% AS SE1
				ON	%xFilial:SE1% = E1_FILIAL
				AND	SE1.%notDel%
				AND E1_PREFIXO = MEQ_PREFIX
				AND E1_NUM = MEQ_NUM
				AND E1_PARCELA = MEQ_PARCEL			
				AND E1_TIPO = MEQ_TIPO			
				// usando dbSetOrder(7) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
				JOIN %table:SE5% AS SE5
				ON	%xFilial:SE5% = E5_FILIAL
				AND	SE5.%notDel%
				AND E5_PREFIXO		= E1_PREFIXO
				AND	E5_NUMERO		= E1_NUM
				AND	E5_PARCELA		= E1_PARCELA
				AND	E5_TIPO			= E1_TIPO
				AND	E5_CLIFOR		= E1_CLIENTE
				AND	E5_LOJA			= E1_LOJA
					 
			WHERE	%xFilial:MEQ% = MEQ_FILIAL
				AND	MEQ.%notDel%
			
				// selecionar os titulos enviados para cobrança o CAP (MEQ_OPERAC = '1'). 
				AND MEQ_OPERAC = '1'			
				// Data do ultimo envio ao CAP no registro de envio do titulo para cobrança no CAP (MEQ_OPERACA = '1') em branco
				// ou seu saldo (MEQ_SALDO) diferente do saldo do título (E1_SALDO);
				//ou 
				// Existencia de registros de movimentacoes bancarias (SE5), com data maior ou igual à data 
				// do ultimo envio ao CAP (MEQ_DTUTPR) no registro de envio do titulo para cobrança no CAP (MEQ_OPERACA = '1'),  
				//OU SALDO DIFERENTE DO  SALDO DO TITULO
				AND (MEQ_DTUTPR = ' '  	OR ( E5_DATA >= MEQ_DTUTPR OR  MEQ_SALDO <> E1_SALDO ) 	)				
				// selecionando os registros de pagamento de titulos (E5_TIPODOC = "VL /V2 /BA /RA /CP /LJ /" ou conteudo do parametro MV_CRNEG  e E5_RECPAG = 'R')
				// ou cancelamento de pagamento (E5_TIPODOC = 'ES' e E5_RECPAG = 'R');	
				AND (E5_TIPODOC IN ('VL', 'V2', 'BA', 'RA', 'CP', 'LJ')  OR (%exp:SuperGetMv("MV_CRNEG",,"FAT")% = 'S' AND E5_RECPAG = 'R')  OR (E5_TIPODOC = 'ES' AND E5_RECPAG = 'P') )			
				//O registro da movimentação nao ter sido enviado ao CAP (mesmo MEQ_PREFIXO + MEQ_NUM + MEQ_PARCEL + MEQ_TIPO + MEQ_OPERAC + MEQ_SEQ + MEQ_TIPODO).				
				AND ( SELECT COUNT(1)
						FROM %table:MEQ% AS MEQ2
						WHERE  %xFilial:MEQ%	= MEQ2.MEQ_FILIAL
							AND MEQ2.%notDel%
							AND SE5.E5_PREFIXO	= MEQ2.MEQ_PREFIX
							AND	SE5.E5_NUMERO	= MEQ2.MEQ_NUM
							AND SE5.E5_PARCELA	= MEQ2.MEQ_PARCEL
							AND SE5.E5_TIPO		= MEQ2.MEQ_TIPO 
							AND SE5.E5_SEQ		= MEQ2.MEQ_SEQ
						   	AND SE5.E5_TIPODOC	= MEQ2.MEQ_TIPODO
							AND MEQ2.MEQ_OPERAC IN ('2', '3') ) = 0      								
			   ORDER BY SE5.R_E_C_N_O_ 

		EndSql
		
		Lj2501BxCA("QryTitBaixa", cFilMEQ)
		QryTitBaixa->(dbCloseArea())
	EndIf


	If lBat
		RpcClearEnv()
	EndIf


	conout( '>->-> Fim LOJA2501')
	
Return NIL




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |Lj2501BxCA       ºAutor  ³Microsiga            º Data ³  12/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama a IntegDef para cada registro selecionado                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºParametros³ cAlias = Alias da tabela temporaria                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/SigaFRT                                            		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Static Function Lj2501BxCA(cAliasQry, cFilMEQ)
	Local oTitBaixa := NIL	// Objeto responsável por toda a integração EAI   
	Local aArea := GetArea()   //workArea anterior

	conout( '>->-> Inicio  Lj2501BxCA') 
	
	MEQ->(DbSetorder(2)) //MEQ_FILIAL+MEQ_PREFIX+MEQ_NUM+MEQ_PARCEL+MEQ_TIPO+MEQ_OPERAC+MEQ_SEQ 

	oTitBaixa := LJClBxCAP():New(cAliasQry)        

	While (cAliasQry)->(!Eof())
        If (cAliasQry)->SE5DUP == 1  .OR. !MEQ->(DbSeek(cFilMEQ+(cAliasQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+IIF(E5_TIPODOC = "ES", "3", "2")+E5_SEQ)))
			Begin Transaction
			oTitBaixa:GerarXML()		
			End Transaction			
			conout( '>---------- Chamou IntegDef !')  
		EndIf
		(cAliasQry)->(DbSkip())
	End

	If ( oTitBaixa <> NIL )
		FreeObj( oTitBaixa )
		oTitBaixa := NIL
	EndIf
	
	conout( '>->->  Fim Lj2501BxCA')  
	
	RestArea(aArea)
Return NIL

     

