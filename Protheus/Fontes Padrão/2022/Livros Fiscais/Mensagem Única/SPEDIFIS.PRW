#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#include 'SPEDIFIS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI940
Mensagem unica de exportacao da instrucao normatica SPED fiscal - EXPORTSPEDFISCAL

@param cXml Xml passado para a rotina
@param nType Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg Tipo de mensagem ( EAI_MESSAGE_WHOIS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_BUSINESS)

@return lRet indica se a mensagem foi processada com sucesso
@return cXmlRet Xml de retorno da funcao

@author Fabio Vessoni Santana
@since 01/06/2015
@version MP12 
/*/
//-------------------------------------------------------------------
Function SPEDIFIS( cXml, nType, cTypeMsg ) 
Local cXmlRet		:= 	''
Local cErroXml	:= 	""
Local cWarnXml	:= 	""
Local aWizard		:=	{}
Local oXmlSped	:=	''
Local nPorta		:=	0
Local nPonto		:=	0
Local nPos		:= 	0
Local cAdress		:=	''
Local cUser		:=	''
Local cPassw		:=	''
Local cFile		:=	''
Local lRet		:=	.T.
Local cMarca 		:= 	""
Local cAuxDePara := ""

Do Case 
	// verificação do tipo de transação
	Case  nType == TRANS_RECEIVE 
		If (cTypeMsg == EAI_MESSAGE_WHOIS )
				cXmlRet := '1.000'
		ElseIF ( cTypeMsg == EAI_MESSAGE_BUSINESS )
			oXmlSped := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
			If oXmlSped <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FTPADRESS') != Nil
					nPonto:=AT(":",oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPAdress:Text)//vem IP:Porta
					nPorta:=Val(SubSTR(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPAdress:Text,nPonto+1))
					cAdress:=SubSTR(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPAdress:Text,1,nPonto-1)
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FTPUSER') != Nil
						cUser:=oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPUser:Text
						If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FTPPASSWORD') != Nil
							cPassw:=oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPPassWord:Text
						Else
							cXmlRet+='<Message type="ERROR" code="c2">'+STR0001+'</Message>'//É obrigatório informar a senha do  usuario FTP para gravação do arquivo TXT.
							lRet:=.F.
						Endif
					Else
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0002+'</Message>'//É obrigatório informar o usuario FTP para gravação do arquivo TXT.
						lRet:=.F.
					Endif
				Else
					cXmlRet+='<Message type="ERROR" code="c2">'+STR0003+'</Message>'//É obrigatório informar o endereço FTP para gravação do arquivo TXT.
					lRet:=.F.
				Endif
				If lRet							
					If Type("oXmlSped:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
						cMarca := oXmlSped:_TotvsMessage:_MessageInformation:_Product:_Name:Text
					EndIf    
				  
				  	//--------------\\
				  	// Primeira Aba \\
				  	//--------------\\ 	
				  	aAdd(aWizard, {})				  
				  	nPos	:=	Len (aWizard)
					
					//Data Inicial    					  
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_INITIALDATE') != Nil
						aAdd(aWizard[nPos],STRTran(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_InitialDate:Text,'-'))
					Else
						aAdd(aWizard[nPos],"")
					Endif

					//Data Final    
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FINALDATE') != Nil
						aAdd(aWizard[nPos],STRTran(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FinalDate:Text,'-'))
					Else
						aAdd(aWizard[nPos],"")
					Endif

					//Numero do Livro 
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TAXRECORD') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_TaxRecord:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif

					//Diretorio do Arquivo Desino
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TARGETDIRECTORY') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_TargetDirectory:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif

					//Arquivo Destino  
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TARGETFILE') != Nil
						cFile := oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_TargetFile:Text
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_TargetFile:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif

					//Gera Inventario 
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATEINVENTORY') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_GenerateInventory:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif

					//Gera Registros Complementares de Frete
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATEFREIGHT') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_GenerateFreight:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif
				
					//Data de Fechamento
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CLOSINGDATE') != Nil
						aAdd(aWizard[nPos],STRTran(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ClosingDate:Text,'-'))
					Else
						aAdd(aWizard[nPos],"")
					Endif				
					
					//Gera registro ECF		
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATEECF') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_GenerateECF:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif							

					//Arq. Periodo anterior
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PREVIOUSFILE') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_PreviousFile:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif

					//Imprime credito ST
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRINTCREDITST') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_PrintCreditST:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif
																										
					//Seleciona Filiais
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_SELECTBRANCHES') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_SelectBranches:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif

					//Periodo de Apuração
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CALCULATIONPERIOD') != Nil
						aAdd(aWizard[nPos],Val(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_CalculationPeriod:Text))
					Else
						aAdd(aWizard[nPos],0)
					Endif

					//Inicio Obrigação Escrituração CIAP
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CIAPBOOKKEEPING') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_CIAPBookkeeping:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif

					//Considera Valores de PIS/COFINS
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CONSIDERPISCOFINS') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ConsiderPISCOFINS:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif

					//Gera Bloco K
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATEK') != Nil						
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_GenerateK:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif

				  	//--------------\\
				  	// Segunda Aba  \\
				  	//--------------\\
					aAdd(aWizard, {})
					nPos	:=	Len (aWizard)
					
					//Produto De
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CODPURPOSE') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_CodPurpose:Text)
					Else
						aAdd(aWizard[nPos],"0")
					Endif							

					//Filial de
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FROMBRANCHINTERNALID') != Nil
						If !Empty(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranchInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', PAdr(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranchInternalId:Text,Len(cFilAnt)))
							aAdd(aWizard[nPos],cAuxDePara)
						Else
						 	If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FROMBRANCH') != Nil
						 		aAdd(aWizard[nPos],PAdr(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranch:Text,Len(cFilAnt)))
						 	Endif
						Endif
					ElseIf XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FROMBRANCH') != Nil
					  	aAdd(aWizard[nPos],PAdr(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranch:Text,Len(cFilAnt)))
					Else
						aAdd(aWizard[nPos],"")												  	
					Endif	

					//Filial Ate
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TOBRANCHINTERNALID') != Nil
						If !Empty(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranchInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', PAdr(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranchInternalId:Text,Len(cFilAnt)))
							aAdd(aWizard[nPos],cAuxDePara)
						Else
						 	If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TOBRANCH') != Nil
						 		aAdd(aWizard[nPos],PAdr(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranch:Text,Len(cFilAnt)))
						 	Endif
						Endif
					ElseIf XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TOBRANCH') != Nil
					  	aAdd(aWizard[nPos],PAdr(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranch:Text,Len(cFilAnt)))
					Else
						aAdd(aWizard[nPos],"")												  	
					Endif	

					//Perfil de Apresentação
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PROFILE') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_Profile:Text)
					Else
						aAdd(aWizard[nPos],"A")
					Endif	

					//Tipo de Atividade
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACTIVITY') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_Activity:Text)
					Else
						aAdd(aWizard[nPos],"0")
					Endif	

					//Aglutina por CNPJ+IE
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_AGGLUTSELECTION') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AgglutSelection:Text)
					Else
						aAdd(aWizard[nPos],"2")
					Endif	

					//E-mail
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_CommunicationInformation,'_EMAIL') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_CommunicationInformation:_Email:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	

				  	//--------------\\
				  	// Terceira Aba \\
				  	//--------------\\
					aAdd(aWizard, {})
					nPos	:=	Len (aWizard)						
					
					//Nome Contabilista
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANT') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_Accountant:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif							

					//CNPJ
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantGovernmentalInformation,'_CNPJ') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantGovernmentalInformation:_CNPJ:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//CPF
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantGovernmentalInformation,'_CPF') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantGovernmentalInformation:_CPF:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	

					//CRC
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CRC') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_CRC:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//CEP
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress,'_ZIPCODE') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress:_ZIPCode:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Cod Municipio
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress:_City,'_CODE') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress:_City:_Code:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Endereço
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress,'_ADDRESS') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress:_Address:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Número
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress,'_NUMBER') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress:_Number:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Complemento
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress,'_COMPLEMENT') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress:_Complement:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Bairro
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress,'_DISTRICT') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAddress:_District:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Fone
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantCommunicationInformation,'_PHONENUMBER') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantCommunicationInformation:_PhoneNumber:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Fax
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantCommunicationInformation,'_FAXNUMBER') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantCommunicationInformation:_FaxNumber:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//E-mail Contabilista
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantCommunicationInformation,'_EMAIL') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantCommunicationInformation:_Email:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif																																																																			

				  	//------------\\
				  	// Quarta Aba \\
				  	//------------\\
					aAdd(aWizard, {})
					nPos	:=	Len (aWizard)	
					
					//Produto Inicial
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTFROM') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductFrom:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Produto Final
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTTO') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductTo:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Armazem Inicial
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_WAREHOUSEFROM') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseFrom:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Armazem Final
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_WAREHOUSETO') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseTo:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif	
					
					//Considera o saldo em poder de terceiros
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_POWERBALANCE') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_PowerBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Considera saldo em processos
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PROCESSBALANCE') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Lista MOD em processo
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_LISTPROCESSMOD') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListProcessMOD:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif																																					

					//Nome arquivo gerado no reg Inventario Mod. 7
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FILEMODEL7') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_FileModel7:Text)
					Else
						aAdd(aWizard[nPos],"")
					Endif

					//Motivo do inventário
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_REASONINVENTORY') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReasonInventory:Text)
					Else
						aAdd(aWizard[nPos],"01")
					Endif

				  	//------------\\
				  	// Quinta Aba \\
				  	//------------\\
					aAdd(aWizard, {})
					nPos	:=	Len (aWizard)	

					//Gera Registro 1100 - Exportação
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1100') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1200 - Créditos fiscais
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1200') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1300 - Combustiveis
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1300') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1390 - Usina de açúcar/alcool
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1390') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1400 - Valores Agregados
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1400') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1500 - Energia Eletrica
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1500') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1600 - Cartão de crédito/débito
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1600') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1700 - Documentos Fiscais
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1700') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif	
					
					//Gera Registro 1800 - Transporte Aéreo
					If XmlChildEx(oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE1800') != Nil
						aAdd(aWizard[nPos],oXmlSped:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)
					Else
						aAdd(aWizard[nPos],"1")
					Endif							
																																															
					//Chamo a funcao do SPEDFISCAL, para gerar o arquivo												
					SPEDFISCAL(aWizard)
						
					If FTPCONNECT(cAdress ,nPorta ,cUser , cPassw )
						cArqu:=GetSrvProfString("STARTPATH","")  
						cArqu+= cFile //arquivo sem o diretorio. Para o upload, é necessario estar dentro do \System.
						
						FTPSETPASV(.F.)		
						IF !FTPUPLOAD(cArqu,cFile)
							IF !FTPUPLOAD(cArqu,cFile)//forço a entrada, tentando duas vezes
								lRet:=.F.
								cXmlRet+='<Message type="ERROR" code="c2">'+STR0004+'</Message>'//Não foi possível a carga do arquivo no FTP. Verifique as permissões e tente novamente.
							Endif
						Endif
						
						If lRet
						
							//Apago o arquivo gerado na pasta system e mantenho somente o arquivo gerado no FTP
							If File(cArqu)
								FErase(cArqu)
							EndIF

							cXmlRet+= "<File>"+_noTags(cAdress + ":"+cValtoChar(nPorta) + "/" + cFile)+"</File>"
						EndIf
							
						FTPDisconnect()
					Else
						lRet:=.F.
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0005+'</Message>'//Não foi possível a conexão com o servidor FTP informado. Verifique.
					Endif			

				Endif
			Else
				cXmlRet+='<Message type="ERROR" code="c2">'+STR0006+'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
				lRet:=.F.
			Endif
		Endif
EndCase

cXmlRet:=EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet }
