#INCLUDE "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj8AIncXxy ºAutor  ³ Varejo    º Data ³  26/09/2013   	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inlui a tabela XXY PELO MODEL se for lib ou release 118     º±± 
±±º          ³LOJA880A                              					  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function Lj8AIncXxy()

Local 	oModel  	:= Nil   	// Modelo de Dados baseado no ModelDef do fonte informado
Local 	nI			:= 0		// Contador
Local 	aFields 	:= {}		// Array de Funcionalidades
	
If !TCCanOpen("XXY")
	Conout("Tabela XXY não existe")	
EndIF

If Select("XXY") == 0
	FWOpenXXY()
EndIf
	
DbSelectArea("XXY")

AADD( aFields , { 	'STWRECEIPT'		,	'Contigencia do Recebimento'						 		  			,	'STRecProcessContingency'	,	2			} )
AADD( aFields , { 	'STRECLOAD'			,	'Carrega Recebimento'	  		   				   			  			,	'STRecLoad'					,	2			} )
AADD( aFields , { 	'STDROPTITL'		,	'Baixa os titulos'	   			   				   			  			,	'STDropTitles'				,	2			} )
AADD( aFields , { 	'STREVERSED'		,	'Estorno de baixa de titulos'	   				   			   			,	'STReverseDropTitles'		,	2			} )
AADD( aFields , { 	'STGERATITR'		,	'Gera titulos SE1 do recebimentos de titulos'	   				   		,	'STGeraTitRec'				,	2			} )
AADD( aFields , { 	'STBIMPORTR'		,	'Importa Orcamento'		  				   			  					,	'STBImportR'				,	2			} )
AADD( aFields , { 	'STBISGETOP'		,	'Pesquisa Orçamento'		   				   			   				,	'STBISGetOp'				,	2			} )
AADD( aFields , { 	'STDSEARCHC'		,	'Busca o cliente'				  				  			   			,	'STDSearchC'				,	2			} )
AADD( aFields , { 	'STDCUSTOME'		,	'Recebe dados do cliente'		   				  				 		,	'STDCustome'				,	2			} )
AADD( aFields , { 	'STDFINDNCC'		,	'Busca NCC do Cliente'  				  			   					,	'STDFindNCC'				,	2			} )
AADD( aFields , { 	'LJ7SLDEST'			,	'Verifica saldo em estoque'						   				  		,	'Lj7SldEst'					,	2			} )
AADD( aFields , { 	'LJ7GERASC0'		,	'Gera Solicitação de Compra'					  						,	'Lj7GeraSC0'				,	2			} )
AADD( aFields , { 	'LJ7CSRESDB'		,	'Consulta Reserva'					  					 			 	,	'Lj7CsResDB'				,	2			} )
AADD( aFields , { 	'LJ7CANCRES'		,	'Cancela Reserva'					  				   				 	,	'Lj7CancRes'				,	2			} )
AADD( aFields , { 	'GERAL1L2L4'		,	'Gera Venda'					   				   				 		,	'GeraL1L2L4'				,	2			} )
AADD( aFields , { 	'CONFL1L2L4'		,	'Confirma Venda'					  				   					,	'ConfL1L2L4'				,	2			} )
AADD( aFields , { 	'STDCANCREC'		,	'Cancela Venda'					  				   						,	'STDCancRec'				,	2			} )
AADD( aFields , { 	'GERAMBZ'  			,	'Gera Estorno'				 		  				   					,	'GeraMBZ'			   		,	2			} )
AADD( aFields , { 	'CONFMBZ'  			,	'Confirma Estorno'				 		   								,	'ConfMBZ'			 		,	2			} )
AADD( aFields , { 	'CA280CART'  		,	'Valida cartao fidelidade '		   					   			 		,	'Ca280Cart'			 		,	2			} )
AADD( aFields , { 	'CA280ISLD'  		,	'Realiza a inclusao de saldo do cartao fidelidade'	   			 		,	'CA280ISLD'			 		,	2			} )
AADD( aFields , { 	'CA280CALC'  		,	'Realiza consulta para verificar se o cartao tem saldo disponivel'		,	'Ca280Calc'			 		,	2			} )
AADD( aFields , { 	'WSCRD010'  		,	'Realiza a transacao de venda, quando houver integracao com o SIGACRD'	,	'WSCRD010'			 		,	2			} )
AADD( aFields , { 	'WSCRD011'  		,	'Desfaz a transacao de credito, quando houver integracao com o SIGACRD'	,	'WSCRD011'			 		,	2			} )
AADD( aFields , { 	'WSCRD012'  		,	'Confirma a transacao de credito,quando houver integracao com o SIGACRD',	'WSCRD012'			 		,	2			} )
AADD( aFields , { 	'STBNCCINC'  		,	'Rotina de inclusao de NCCs.'											,	'STBNCCInc'			 		,	2			} )
AADD( aFields , { 	'STBINCLUIC'  		,	'Rotina de inclusao de titulo do tipo CR.'								,	'STBIncluiC'		 		,	2			} )
AADD( aFields , { 	'FRTINMOVNC'  		,	'Inclui movimento de compensacao'										,	'FrtInMovNC'		 		,	2			} )
AADD( aFields , { 	'CA280ASLD'  		,	'Atualiza saldo do cartao fidelidade.'									,	'Ca280ASld'		 	 		,	2			} )
AADD( aFields , { 	'GERASFI'  			,	'Gera dados da Redução Z'												,	'GeraSFI'		 	  		,	2			} )
AADD( aFields , { 	'GERAE5'  			,	'Gera dados Financeiro'													,	'GeraE5'		 	  		,	2			} )
AADD( aFields , { 	'GERASLX'  			,	'Gera LOG de Cancelmento'												,	'GeraSLX'		 	  		,	2			} )
AADD( aFields , { 	'FRT020ABR' 		,	'Faz abertura no server'												,	'FRT020ABR'		 	  		,	2			} )
AADD( aFields , { 	'FRT020FCH' 		,	'Faz fechamento no server'												,	'FRT020FCH'		 	  		,	2			} )
AADD( aFields , { 	'GERASZ'	 		,	'Gera movimento por ECF'												,	'GeraSZ'		 	  		,	2			} )
AADD( aFields , { 	'STDRECXDAT' 		,	'Gera tabela genérica'													,	'STDRecXDat'	 	  		,	2			} )
AADD( aFields , { 	'STDCONFREC' 		,	'Confirma recno no Server'												,	'STDConfRec'	 	  		,	2			} )
AADD( aFields , { 	'STFCOMMUOK' 		,	'Realiza teste de comunicacao'											,	'STFCommuOk'	 	  		,	2			} )
AADD( aFields , { 	'LJVLDVP'  			,	'Valida o vale presente '										   		,	'LjVldVP'	 	  	   		,	2			} )
AADD( aFields , { 	'LJVPVALOR'  		,	'Valor do vale presente '										   		,	'LjVPValor'	 	  	   		,	2			} )
AADD( aFields , { 	'LJGRRVP'  			,	'Atualiza vale presente '										   		,	'LjGrRVP'	 	  	   		,	2			} )
AADD( aFields , { 	'FINA040'  			,	'Gravacao da SE1 Recarga de Celular '							   		,	'STDIncSE1'	 	  	   		,	2			} )
AADD( aFields , { 	'LJRECGRVCH'		,	'Gravacao dos dados do cheque '									   		,	'LJRecGrvCH' 	  	   		,	2			} )
AADD( aFields , { 	'FINA070'  			,	'Baixa de titulos a receber '									   		,	'STDBxSE1'	 	  	   		,	2			} )
AADD( aFields , { 	'FR271HARQ'  		,	'Gera Arquivo de controle para nao permitir importar novamente'			,	'FR271HARQ'	 	  	   		,	2			} )
AADD( aFields , { 	'CA280ESLD'  		,	'Estorna o movimento e atualiza o saldo do cartao fidelidade'	   		,	'CA280ESLD'	 	  	   		,	2			} )
AADD( aFields , { 	'GERAA1'  			,	'Recebe o pacote de SA1 do Server Local '						   		,	'GERAA1'	 	  	   		,	2			} )
AADD( aFields , { 	'STBVLDRETC'  		,	'Valida se o cliente que sera cadastrado ja existe na base '	   		,	'STBVLDRETC'	  	   		,	2			} )
AADD( aFields , { 	'LJVPATIVA'  		,	'Volta o status do vale presente, durante o cancelamento da venda '		,	'LJVPATIVA'	  	   			,	2			} )
AADD( aFields , {  	'LJULTMOVAB'  		,	'Verifica o ultimo movimento aberto'  									,	'LjUltMovAb'  		   		,	2			} )
AADD( aFields , {  	'LJTEFGRVCB'  		,	'Grava dados do Correspondente Bancário'  								,	'STBTefGrvCB'  		   		,	2			} )
AADD( aFields , { 	'STDCUSTOMERDATA' 	,	'Cadastro do Cliente'  													,	'STDCustomerData'  	   		,	2			} )
AADD( aFields , { 	'STDSEARCHCOSTUMER' ,	'Busca Cliente' 														,	'STDSearchCostumer'    		,	2			} )
AADD( aFields , {  	'LJGERTITNV'  		,	'Gera Título'  															,	'LJGerTitNV'  		   		,	2			} )
AADD( aFields , { 	'STBVLDRETCLI' 	 	,	'Valida se o Cliente existe na Retaguarda'  							,	'STBVldRETCli'  	   		,	2			} )
AADD( aFields , {  	'STBINCLUIC'  		,	'Gera Crédito'  														,	'STBIncluiCR'  		   		,	2			} )
AADD( aFields , { 	'FRTINMOVNC'  		,	'Incluir movimento de conta a receber'  								,	'FrtInMovNCC'  		   		,	2			} )
AADD( aFields , { 	'STFCOMMUCP'  		,	'Testa comunicação com a Central'  										,	'STFCOMMUCP'  				,	2			} )
AADD( aFields , { 	'LJ600ESTOR'  		,	'Realiza Estorno de Venda'		  										,	'LJ600ESTOR'  				,	2			} )
AADD( aFields , { 	'_GERAL1L2L'  		,	'Sobe venda para Central de PDV'		  					 			,	'_GeraL1L2L'  				,	2			} )
AADD( aFields , { 	'_CONFL1L2L'  		,	'Confirma Venda para Central de PDV'		  			    			,	'_ConfL1L2L'  				,	2			} )
AADD( aFields , { 	'_STDCANCRE'  		,	'Cancelamento de Venda Central de PDV'		  			    			,	'_STDCANCRE'  				,	2			} )
AADD( aFields , { 	'STDRECXDATA'  		,	'Grava tabela Genérica'  												,	'STDRecXData'  				,	2			} )
AADD( aFields , { 	'STFCOMMUCP'  		,	'Testa comunicação com a Central'  										,	'STFCOMMUCP'  				,	2			} )
AADD( aFields , { 	'STBGDATPRE'  		,	'Busca Vale Presente'		  							    			,	'STBGDATPRE'  				,	2			} )
AADD( aFields , { 	'STDIMPPROD'  		,	'Importa dados de produto da retaguarda'  								,	'STDIMPPROD'  				,	2			} )
AADD( aFields , { 	'STDNBFIND'  		,	'Busca NCC na retaguarda a partir de um codigo de barras'		  		,	'STDNBFind'  				,	2			} )
AADD( aFields , { 	'STBBAIXAPR'  		,	'baixa o vale presente depois de vendido'		  						,	'STBBaixaPre'  				,	2			} )
AADD( aFields , { 	'STWBOBXNCC'  		,	'Faz a baixa da NCC'								  					,	'STWBOBXNCC'  				,	2			} )
AADD( aFields , { 	'LJCONPREST'  		,	'Consula de Produto em estoque'		  			    		   			,	'LjConPrEst'  				,	2			} )
AADD( aFields , { 	'MATA940'  			,	'Sintegra'		  			    										,	'MATA940'  					,	2			} )
AADD( aFields , { 	'SPEDFISCAL'  		,	'SPED Fiscal'		  			    									,	'SPEDFISCAL'  				,	2			} )
AADD( aFields , { 	'GETSRVPROF' 		,	'Captura as informações Arquivo configuração do Server'		  			,	'GetSrvProfString'  		,	2			} )
AADD( aFields , { 	'STFSENDSTA' 		,	'Envia Dados para gravar na estação'		  							,	'STFSENDSTA'  				,	2			} )
AADD( aFields , { 	'LJXREADFIL' 		,	'Le o arquivo no server'		  										,	'LjxReadFile'  				,	2			} )
AADD( aFields , { 	'PAFCOT35' 			,	'Ato Cotepe 3505'		  												,	'PafCot35'  				,	2			} )
AADD( aFields , { 	'STDPESQCLI' 		,	'Verifica se o cliente existe na base da retaguarda'		  			,	'STDPesqCli'  				,	2			} )
AADD( aFields , { 	'LJILRPCSERVER' 	,	'Executa a rotina de carga'		  										,	'LJILRPCSERVER'  			,	2			} )
AADD( aFields , { 	'STDESTORVP' 	    ,	'Estorna valor do vale presente'		  								,	'STDESTORVP'  			    ,	2			} )
AADD( aFields , { 	'STDGETMINMAXVP' 	,	'Retorna o valor minimo e maximo do vale presente para venda'		    ,	'STDGetMinMaxVP'  			,	2			} )
AADD( aFields , { 	'FRTNCCEXC' 		,	'Estorna NCC'						  									,	'FRTNCCEXC'  				,	2			} )
AADD( aFields , { 	'LJ845RETD'  		,	'Lista de Eventos - Pesquisa de Dados'		  							,	'LJ845RETD'  				,	2			} )
AADD( aFields , { 	'LJ845PESQC' 		,	'Lista de Eventos - Consulta de listas de presentes'		  			,	'LJ845PESQC'  				,	2			} )
AADD( aFields , { 	'SETSTAT'	 		,	'Seta/Altera Campos da Estacao'				  							,	'SetStat'  					,	2			} )
AADD( aFields , { 	'LSTTABPAF' 		,	'Listagem das tabelas do PAF'				  							,	'LstTabPaf'  				,	2			} )
AADD( aFields , { 	'LSTSUMREG' 		,	'Validação dos valores do PAF'				  							,	'LstSumReg'  				,	2			} )
AADD( aFields , { 	'STBVLDE2PA' 		,	'Valida Registro E2 do PAF'					  							,	'StbVldE2Paf'  				,	2			} )
AADD( aFields , { 	'STBVLDE3PA' 		,	'Valida Registro E3 do PAF'					  							,	'StbVldE3Paf'  				,	2			} )
AADD( aFields , { 	'STDQUERYDB' 		,	'Executa Query no Server'					  							,	'STDQUERYDB'  				,	2			} )
AADD( aFields , { 	'INCTITRCEL' 		,	'Inclui Titulo Recarga Celular'				  							,	'IncTitRCel'  				,	2			} )
AADD( aFields , { 	'LPXXMLASS' 		,	'Assinatura XML'				  										,	'LPXXmlAss'  				,	2			} )
AADD( aFields , { 	'STBS2RPAF' 		,	'Envio de arquivo para a retaguarda'				  					,	'STBS2RPAF'  				,	2			} )
AADD( aFields , { 	'LPXFISCOESTMEN' 	,	'Geracao de XML de Estoque'				  								,	'LPXFiscoEstMen'  			,	2			} )
AADD( aFields , { 	'STESTQXML' 		,	'Gravação dos dados do XML de Estoque'		  							,	'STEstqXML'  				,	2			} )
AADD( aFields , { 	'STBFMGETFILE' 		,	'Captura de arquivos da retaguarda'				  						,	'STBFMGetFile' 				,	2			} )
AADD( aFields , { 	'LJRPREGPAF' 		,	'Geração dos Registros do PAF'				  							,	'LJRPRegPAF' 				,	2			} )
AADD( aFields , { 	'LJRPISGER' 		,	'Verificação da Geração do Registro do PAF'	  							,	'LJRPIsGer' 				,	2			} )
AADD( aFields , { 	'LJRPISEND' 		,	'Verificação da Finalização do Registro do PAF'							,	'LJRPIsEnd' 				,	2			} )
AADD( aFields , { 	'LJXGETPATH' 		,	'Caminho do servidor'													,	'LjxGetPath' 				,	2			} )
AADD( aFields , { 	'STDCONGRVB' 		,	'Consulta de LjGrvBatch Efetuada'										,	'STDConGrvB' 				,	2			} )
AADD( aFields , { 	'LJURLSXML' 		,	'Importa o arquivo com as URLs da NFC-e para o PDV'						,	'LjUrlsXml' 				,	2			} )
AADD( aFields , { 	'LJXGRVMDZ' 		,	'Gravação da Tabela Auxiliar MDZ'										,	'LjxGrvMdz' 				,	2			} )
AADD( aFields , { 	'WSCRD013'  		,	'Consulta o Cartão Cliente, quando houver integracao com o SIGACRD'		,	'WSCRD013'			 		,	2			} )
AADD( aFields , { 	'WSCRD017'  		,	'Retirar Análise de Crédito,quando houver integracao com o SIGACRD'		,	'WSCRD017'			 		,	2			} )
AADD( aFields , { 	'WSCRD110'  		,	'Consulta Status da Análise,quando houver integracao com o SIGACRD'		,	'WSCRD110'			 		,	2			} )
AADD( aFields , { 	'WSCRD113'  		,	'Bloqueia Análise Crédito,  quando houver integracao com o SIGACRD'		,	'WSCRD113'			 		,	2			} )
AADD( aFields , { 	'STDSEARCHP' 		,	'Busca produtos na Retaguarda'											,	'STDSearchP'			 	,	2			} )
AADD( aFields , { 	'STGETSLV' 			,	'Busca registro da SLV na retaguarda'									,	'STGETSLV'			 		,	2			} )
AADD( aFields , { 	'STESTSLV' 			,	'Cancela registro da SLV na retaguarda'									,	'STESTSLV'			 		,	2			} )
AADD( aFields , { 	'LJRGCTRDAV' 		,	'Busca registros para geração do arquivo de controle de DAV'			,	'LJRGCTRDAV'			 	,	2			} )



oModel := FWLoadModel( 'CFGA051' )

For nI := 1 To Len(aFields)
	
	If !(XXY->(DbSeek(AllTrim( SubStr(aFields[nI][1],1,10))))) .OR. ;
		( AllTrim( SubStr(aFields[nI][1],1,10)) == "FINA070" .AND. AllTrim(XXY->XXY_FUNC)  <>  AllTrim( aFields[nI][3]) ) .OR. ;
		( AllTrim( SubStr(aFields[nI][1],1,10)) == "LJTEFGRVCB" .AND. AllTrim(XXY->XXY_FUNC)  <>  AllTrim( aFields[nI][3]) )
		
		oModel:SetOperation( IIF(XXY->(!Found()), 3, 4)) 
		oModel:Activate() 
	
		oModXXY := oModel:GetModel('XXYMASTER')
		
		oModXXY:SetValue('XXY_ID' 		,AllTrim(Upper(SubStr(aFields[nI][1],1,10))))
		oModXXY:SetValue('XXY_DESC' 	,aFields[nI][2])
		oModXXY:SetValue('XXY_FUNC' 	,aFields[nI][3])
		oModXXY:SetValue('XXY_STATUS' 	,aFields[nI][4])
	
		FwFormCommit(oModel)
		oModel:DeActivate() 
	
	EndIf

Next nI

Return
