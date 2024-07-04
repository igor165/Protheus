#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "DIRECTRY.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'


Static aResultR06 := {}
Static nPosR06	:= 0
Static cFimArq	:= "FIMREGPAF.txt"
Static cArqRegPaf:= "REGPAF.txt"
Static aLstPDVs	:= {}


//----------------------------------------------------------
/*{Protheus.doc}LJMFRGPaf
Função do Menu Fiscal - Registros do PAF-ECF
@param1		dDataIni - data - Data Inicial
@param2		dDataFim - data - Data Final
@param3		cPDV - caracter - numero do PDV
@param4		lHomolPaf - lógico - É Homologação?
@param7 	lIsPafNfce - lógico - PAF-NFCe
@param8		cArqPNFCe- caracter - retorna o nome do arquivo .txt gravado
@author  	Julio.Nery
@version 	P11.8
@since   	25/10/2017
@return  	NIL 
@obs   
@sample
*/
//--------------------------------------------------------
Function LJMFRGPaf(	lTotvsPdv	, dDataIni	, dDataFim	, cPDV	,;
 					lHomolPaf	, lReducao	,lIsPafNfce, cArqPNFCe )
Local lRet		:= .T.
Local lPesqDados:= .T.
Local lErro		:= .F.
Local aResult	:= {}
Local aLstProd	:= {}
Local aInfoPDVPAF:= {"","","","","",{},""}
Local nTry		:= 0
Local nFimTry	:= 10
Local nX		:= ""
Local cLocalPath:= ""
Local cSrvPath	:= LjxPathSrv()
Local cNameArq	:= ""
Local cSeriePDV	:= ""
Local cCodEcf	:= ""
Local cConteudo := ""
Local cMsg		:= ""
Local aRetR02Red:= {}

Default lIsPafNfce 	:= .F. 


STBFMGerPath( @cLocalPath )
STBGetInfEcf("SERIE",@cSeriePDV)
STBGetInfEcf("40",@cCodECF)

If !lReducao
	aLstProd := LJRPScPrd()
	If Len(aLstProd) > 0 .And. Empty(AllTrim(aLstProd[1][1]))
		aLstProd := {}
	EndIf
EndIf

/*
*************************** ATENÇÃO  ***********************************
É importante o envio dessas informações pois nos testes de homologação
o arquivo eh alterado e esse é gerado no PDV, e a sua alteração
deve ser refletida no arquivo de registros do PAF.  

aInfoPDVPAF[1] := cCnpjTotvs 
aInfoPDVPAF[2] := cNomeComercial
aInfoPDVPAF[3] := cMd5Master
aInfoPDVPAF[4] := cCnpjCliente
aInfoPDVPAF[5] := Versão do PAF
aInfoPDVPAF[6] := Array com as informações do arquivo criptografado (PAFEMP.TXT)
aInfoPDVPAF[7] := Serie do PDV que solicitou a geração do registro do PAF
*************************** ATENÇÃO  ***********************************
*/
STBFMArqIdEmp(@aInfoPDVPAF[1], @aInfoPDVPAF[2], @aInfoPDVPAF[3], @aInfoPDVPAF[4], lTotvsPdv,@aInfoPDVPAF[6])
aInfoPDVPAF[5] := STBVerPAFECF("VERSAOAPLIC")
aInfoPDVPAF[7] := AllTrim(cSeriePDV)

LJRPLogProc("Chamada para geração do Registro do PAF")

cMsg := "Gerando Registros do PAF no Servidor"
If lTotvsPdv
	STFMessage("LJMFRGPaf1", "RUN", cMsg,;
	 			{ || STBRemoteExecute("LJRPRegPAF",;
	 						{dDataIni,dDataFim,cPDV,lHomolPaf,lReducao,aLstProd,aInfoPDVPAF,lIsPafNfce}, NIL, .F.,@aResult) }) //"Gerando Arquivo..."
	STFShowMessage("LJMFRGPaf1")
Else
	LjMsgRun(cMsg,, { || ;
			aResult := FR271CMyCall("LJRPRegPAF",{"SL1","SL2","SL4","SF2","SB0","SB1","MDZ","SLX"},;
									dDataIni,dDataFim,cPDV,lHomolPaf,lReducao,aLstProd,aInfoPDVPAF)})
EndIf

LJRPLogProc(" Retorno - Chamada para geração do Registro do PAF",,aResult)

nTry := STBCrtRegPAF(	dDataIni	,dDataFim	,cPDV			,lReducao	,;
						cSeriePDV	,cCodECF	,Dtos(dDataBase),@cNameArq	)
If nTry > 0
	FClose(nTry)
	FErase(cNameArq)
EndIf

If nTry > 0 
 	If ValType(aResult) == "A" .And. Len(aResult) > 0 .And. ValType(aResult[1]) == "L" 
 	 	If aResult[1]
 	 		ASize(aResult,0)
 	 		
 	 		LJRPLogProc("Inicio da pesquisa do arquivo no servidor função LJRPIsGer")
 	 		cMsg := "Verificando Conclusão da Geração do Registro no Servidor...."
 	 		If lTotvsPdv
 	 			STFMessage("LJMFRGPaf2", "RUN", cMsg,;
 	 					{ || STBRemoteExecute("LJRPIsGer", {cSrvPath}, NIL, .F.,@aResult) }) //"Gerando Arquivo..."
 	 			STFShowMessage("LJMFRGPaf2")
 	 		Else
 	 			LjMsgRun(cMsg,, { || aResult := FR271CMyCall("LJRPIsGer",Nil,cSrvPath)})
 	 		EndIf
 	 		LJRPLogProc("Final da pesquisa do arquivo no servidor função LJRPIsGer - aResult : ", ,aResult)
			
			If ValType(aResult) == "A" .And. Len(aResult) > 0 .And. ValType(aResult[1]) == "L" .And. aResult[1]
				lPesqDados := .T.
				nTry := 1
				While lPesqDados
					ASize(aResult,0)
					
					LJRPLogProc("Verificando se o arquivo foi finalizado na retaguarda ")
					cMsg := "Gerando Arquivo de Registro..."
					If lTotvsPdv
		 	 			STFMessage("LJMFRGPaf3", "RUN",cMsg,;
		 	 					{ || STBRemoteExecute("LJRPIsEnd", {cSrvPath}, NIL, .F.,@aResult) }) //"Gerando Arquivo..."
		 	 			STFShowMessage("LJMFRGPaf3")
		 	 		Else
		 	 			LjMsgRun(cMsg,, { || aResult := FR271CMyCall("LJRPIsEnd",Nil,cSrvPath)})
		 	 		EndIf
		 	 		LJRPLogProc("Final da verificação se o arquivo foi finalizado na retaguarda - aResult ", ,aResult)
		 	 		
					If ValType(aResult) == "A"
						If Len(aResult) > 0 .And. ValType(aResult[1]) == "L"
							If aResult[1]
								lPesqDados := .F.
								
								LJRPLogProc(" Inicio da cópia do arquivo da RET to PDV")
								cMsg := "Copiando arquivos da retaguarda para o PDV....."
								STFMessage("LJMFRGPaf4", "RUN" , "Copiando arquivos da retaguarda para o PDV.....",;
											{|| LjxGetFile(cSrvPath ,cFimArq,cLocalPath,cFimArq,.T.,lTotvsPdv) })
								STFShowMessage("LJMFRGPaf4")
								
								If !File(cLocalPath+cFimArq)
									LJRPLogProc("Arquivo de Registro do PAF não foi gerado no PDV. Verifique permissões das pastas!")
									lErro := .T.
								EndIf
								
								LJRPLogProc("Finalização da cópia do arquivo da RET to PDV")
							Else
								cMsg := "Gerando Arquivo de Registro no Server..... Tentativa " + cValToChar(nTry) + " de " + cValToChar(nFimTry)
								If lTotvsPdv
									STFMessage("LJMFRGPaf5", "RUN", cMsg,{ || Sleep(10000)})
									STFShowMessage("LJMFRGPaf5")
								Else
									LjMsgRun(cMsg,, { || Sleep(10000) } )
								EndIf								
								
								LJRPLogProc(cMsg)
								nTry++
							EndIf
							
							If lPesqDados .And. nTry > nFimTry
								lPesqDados := .F.
								Alert("Erro ao buscar arquivo [" + cFimArq + "] no Servidor. Verifique conexão com a retaguarda!")
								LJRPLogProc("Erro ao buscar arquivo [" + cFimArq + "] no Servidor. Verifique conexão com a retaguarda!")
							EndIf
						Else
							lErro := .T.
							lPesqDados := .F.
						EndIf
					ElseIf ValType(aResult) == "C"
						lPesqDados := .F.
						lErro := .T.
					EndIf
				End
				
				If !lErro 
					If File(cLocalPath+cFimArq)
						LJRPLogProc("- Arquivo de Registro do PAF - Inicio da Cópia")
						__CopyFile(cLocalPath+cFimArq, cNameArq)
						LJRPLogProc("- Arquivo de Registro do PAF - Final da Cópia")
						
						//Deve gerar o R02/R03 no PDV, pois a Redução ainda não desceu para a retaguarda
						If lReducao
							LJRPLogProc("- Geração do R02/R03 no PDV")
							aRetR02Red := LjRPR02PDV(dDataIni, dDataFim, cPDV)
							LJRPLogProc("- Final da Geração do R02/R03 no PDV")
							
							IF Len(aRetR02Red) > 0
								LJRPLogProc("- Convergência dos Registros PDV + Retaguarda")
								LJRPUneR02(@aRetR02Red,cNameArq)
								LJRPLogProc("- Final da Convergência dos Registros PDV + Retaguarda")
							EndIf
						EndIf
						
						If File(cNameArq)
							LJRPLogProc("Arquivo de Registro do PAF [" + cNameArq + "] Gerado com Sucesso")
							STBFMSignPaf(cNameArq)
						Else
							LJRPLogProc("Erro no Arquivo de Registro do PAF [" + cNameArq + "]")
							Alert("Erro no Arquivo de Registro do PAF [" + cNameArq + "]")
						EndIf
						FErase(cLocalPath+cFimArq)
					Else
						Alert("Erro ao copiar arquivo [" + cNameArq + "]. Verifique !!!")
						LJRPLogProc("Erro ao copiar arquivo [" + cNameArq + "]. Verifique !!!")
					EndIf
				EndIf
			Else
				Alert("Erro na busca do arquivo de Registro no Servidor. Verifique Logs")
				LJRPLogProc("Erro na busca do arquivo de Registro no Servidor. Verifique Logs no PDV e Retaguarda")
			EndIf
		Else
			Alert("Erro na rotina de geração do arquivo de Registro no Servidor. Verifique Logs")
			LJRPLogProc("Erro na rotina de geração do arquivo de Registro no Servidor. Verifique Logs")
		EndIf
	Else
		lErro := .T.
	EndIf
Else
	Alert("Arquivo Inicial não foi gerado no PDV. Verifique permissões as pastas")
	LJRPLogProc("Arquivo Inicial não foi gerado no PDV. Verifique permissões as pastas")
EndIf

If lErro 
	STPosMSG( "Arquivo de Registro do PAF-ECF não Gerado!" ,;
	"ATENÇÃO" + CHR(10) + CHR(13) +;
	"Seu arquivo de Registros do PAF-ECF não foi gerado ! " + CHR(10) + CHR(13) +;
	"Verifique em seu ambiente, tanto na Retaguarda quanto PDV: "+ CHR(10) + CHR(13) +;
	"- As permissões de acesso de pastas: system , smartclient, PAF-ECF (todas do ambiente Protheus)" + CHR(10) + CHR(13) +;
	"- Os logs e mensagens: LogLoja , Console.log, Mensagens dos Servers" + CHR(10) + CHR(13) +;
	"- Comunicação entre os servers (PDV com a Retaguarda)" + CHR(10) + CHR(13) +;
	"- Compatibilidade entre os repositórios ( falta de função por pacote não aplicado ou repositório desatualizado ) " + CHR(10) + CHR(13) +;
	IIF(lTotvsPdv ,"- Verifique se as funcionalidades relacionadas a esta execução estão configuradas corretamente","") + CHR(10) + CHR(13) ;
	, .T., .F., .F.)
	
	LJRPLogProc(" Arquivo de PAF-ECF não gerado. Analise permissão de acesso as pastas do "+;
			" Protheus, logs, comunicação entre os ambientes, funcionalidades configuradas corretamente")
	lRet := .F.
EndIf

If lRet .AND. !lErro
	cArqPNFCe:= cNameArq
Endif 

Return lRet

//----------------------------------------------------------
/*{Protheus.doc}LJRPRegPAF
Função para gerar o arquivo de Registro do PAF na retaguarda

@param1		dDataIni - data - Data Inicial
@param2		dDataFim - data - Data Final
@param3		cPDV - caracter - numero do PDV
@param4		lHomolPaf - lógico - É Homologação?
@param8		lIsPafNfce - lógico - PAF-NFCe
@author  	Julio.Nery
@version 	P11.8
@since   	25/10/2017
@return  	NIL 
@obs   
@sample
*/
//--------------------------------------------------------
Function LJRPRegPAF(dDataIni	, dDataFim	, cPDV			, lHomolPaf	,;
					lReducao	, aLstProd	, aInfoPDVPAF   , lIsPafNfce )
Local nHdlArq 	:= 0
Local cConteudo := ""
Local cLocalPath:= LjxGetPath()[1]
Local lRet 		:= .T.
Local lTemIncManu:= .F.
Local lInterroga:= .F.
Local aRet		:= {}
Local cRazaoSoc := ""
Local lLjSimpNac:= SuperGetMV("MV_LJSIMPN",,.F.) //Simples Nacional?

Default lIsPafNfce	:=.F. 

STBSetPAF(aInfoPDVPAF[5]) //Inicializa a variavel aVersaoPAF

If File(cLocalPath+cArqRegPaf)
	LJRPLogProc(" - Apagando o arquivo [" + cLocalPath + cArqRegPaf + "]")
	FErase(cLocalPath+cArqRegPaf)
EndIf

LJRPLogProc(" - Criando arquivo Local [" + cLocalPath + cArqRegPaf + "]")
nHdlArq := FCreate(cLocalPath+cArqRegPaf,0) //Cria o arquivo na system do Protheus
LJRPLogProc(" - Handle Arquivo [" + cLocalPath + cArqRegPaf + "] -> " + cValToChar(nHdlArq))

If nHdlArq > 0
   	cConteudo := Replicate("X",94) + CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	
	//A2
	If lLjSimpNac
		LJRPLogProc("Simples Nacional Ativo (MV_LJSIMPN) - não será gerado o registro A2")
	Else
		LJRPLogProc("Geração do A2")
		LstMePagto( @nHdlArq	,dDataIni	,dDataFim	,cPDV			,;
		 			lHomolPaf	,lHomolPaf	,.F.		,@lTemIncManu	,;
					lIsPafNfce   )
		LJRPLogProc("Fim da Geração do A2")
	EndIf
	
	If lTemIncManu
		lInterroga := .T.
	EndIf
	
	//P2	
	LJRPLogProc("Geração do P2")
	LstProduto( @nHdlArq	,lHomolPaf	,@lTemIncManu, lIsPafNfce	)
	LJRPLogProc("Fim da Geração do P2")
	
	If lTemIncManu
		lInterroga := .T.
	EndIf
	
	//E2
	If lLjSimpNac
		LJRPLogProc("Simples Nacional Ativo (MV_LJSIMPN) - não serão gerados os registros E2 e E3")
	Else
		If !lReducao .Or. LJRGVldE2(dDataFim,aInfoPDVPAF[7])[1]  
			LJRPLogProc("Geração do E2")
			LstEstoque (@nHdlArq	,aLstProd	,lHomolPaf	,@lTemIncManu, dDataFim, lIsPafNfce)		
			LJRPLogProc("Fim da Geração do E2")
		EndIf
		
		If lTemIncManu
			lInterroga := .T.
		EndIf
		
		If !lIsPafNfce
			//E3	
			LJRPLogProc("Geração do E3")
			LstECFAtuSt(@nHdlArq	,lHomolPaf	,@lTemIncManu	,dDataIni	,;
						dDataFim)
			LJRPLogProc("Fim da Geração do E3")
		Endif 

		If lTemIncManu
			lInterroga := .T.
		EndIf
	EndIf
	
	//D2,D3,D4
	If !SuperGetMV("MV_LJPRVEN",,.T.) //Somente quando usa DAV
		LJRPLogProc("Geração do D2/D3/D4")
		LstDavEmit(	@nHdlArq	,dDataIni	,dDataFim	,lHomolPaf	,;
					@lTemIncManu, lIsPafNfce)
		LJRPLogProc("Fim da Geração do D2/D3/D4")
		If lTemIncManu
			lInterroga := .T.
		EndIf
	EndIf
	
	If !lIsPafNfce
		//R01
		LJRPLogProc("Geração do R01")
		LstInfoPDV (@nHdlArq	,dDataIni		,dDataFim	, cPDV		,;
					lHomolPaf	,@lTemIncManu	,aInfoPDVPAF, lReducao	)
		LJRPLogProc("Fim da Geração do R01")
		If lTemIncManu
			lInterroga := .T.
		EndIf
		
		//R02,R03
		If !lReducao
			LJRPLogProc("Geração do R02/R03")
			LstRedZ(@nHdlArq	,dDataIni		,dDataFim	,cPDV		,;
					lHomolPaf	,@lTemIncManu							)
			LJRPLogProc("Fim da Geração do R02/R03")
			If lTemIncManu
				lInterroga := .T.
			EndIf
		EndIf
		
		//R04
		LJRPLogProc("Geração do R04")
		LstVendas(	@nHdlArq	,dDataIni		,dDataFim	,cPDV	,;
					lHomolPaf	,@lTemIncManu	,lReducao			)
		LJRPLogProc("Fim da Geração do R04")
		If lTemIncManu
			lInterroga := .T.
		EndIf
		
		LJRPLogProc("Geração do R04 Cnc")
		LstVndCanc(	@nHdlArq	,dDataIni		,dDataFim	,cPDV	,;
					lHomolPaf	,@lTemIncManu	,lReducao			)
		LJRPLogProc("Fim da Geração do R04 cnc")
		If lTemIncManu
			lInterroga := .T.
		EndIf
		
		//R05
		LJRPLogProc("Geração do R05")
		LstItens(@nHdlArq	,dDataIni		,dDataFim	,cPDV	,;
				lHomolPaf	,@lTemIncManu	,lReducao			)
		LJRPLogProc("Fim da Geração do R05")
		If lTemIncManu
			lInterroga := .T.
		EndIf	
		
		LJRPLogProc("Geração do R05 cnc")
		LstItCanc(	@nHdlArq	,dDataIni		,dDataFim	,cPDV	,;
					lHomolPaf	,@lTemIncManu	,lReducao			)
		LJRPLogProc("Fim da Geração do R05 cnc")
		If lTemIncManu
			lInterroga := .T.
		EndIf	
		
		//R06
		LJRPLogProc("Geração do R06")
		LstDocEmit(	@nHdlArq	,dDataIni	,dDataFim	,lHomolPaf,;
					cPDV		,@lTemIncManu)
		LJRPLogProc("Fim da Geração do R06")
		If lTemIncManu
			lInterroga := .T.
		EndIf	
			
		//R07
		LJRPLogProc("Geração do R07")
		LstMePagto( @nHdlArq	,dDataIni	,dDataFim	,cPDV			,;
					lHomolPaf	,lHomolPaf	,.T.		,@lTemIncManu	)
		LJRPLogProc("Fim da Geração do R07")
		If lTemIncManu
			lInterroga := .T.
		EndIf	
		
		LJRPLogProc("Geração do R07 cnc")
		LstPagCanc(	@nHdlArq	,dDataIni	,dDataFim		,cPDV		,;
					lHomolPaf	,.T.		,@lTemIncManu	,lReducao	)
		LJRPLogProc("Fim da Geração do R07 cnc")
		If lTemIncManu
			lInterroga := .T.
		EndIf

	Endif 
	
	//J1
	LJRPLogProc("Geração do J1")
	LstVndManu(	@nHdlArq	,dDataIni		,dDataFim	,cPDV		,;
				lHomolPaf	,@lTemIncManu, lIsPafNfce	)
	LJRPLogProc("Fim da Geração do J1")
	If lTemIncManu
		lInterroga := .T.
	EndIf
	
	//J2
	LJRPLogProc("Geração do J2")
	LstItVdManu(@nHdlArq	,dDataIni		,dDataFim	,cPDV		,;
				lHomolPaf	,@lTemIncManu, lIsPafNfce	)
	LJRPLogProc("Fim da Geração do J2")
	If lTemIncManu
		lInterroga := .T.
	EndIf
	
	//Final do arquivo
	LJRPLogProc(" Gerando registro U1 ")
	cRazaoSoc := PADR( SM0->M0_NOMECOM, 50 )
	
	If lHomolPaf .And. lInterroga
		cRazaoSoc := StrTran(cRazaoSoc," ","?")
	EndIf
	
	cConteudo := "U1"
	cConteudo += PADR( SM0->M0_CGC, 14 ) 		// CNPJ
	cConteudo += PADR( StrTran(StrTran(SM0->M0_INSC,"-"),"."),14 )	 	// Inscricao Estadual                      
	cConteudo += PADR( StrTran(StrTran(SM0->M0_INSCM,"-"),"."),14 ) 	//Inscricao Municipal
	cConteudo += cRazaoSoc
	cConteudo += CHR(13) + CHR(10)
	FSEEK(nHdlArq, 0, 0)
	FWRITE(nHdlArq, cConteudo, LEN( cConteudo ))
	LJRPLogProc(" Fim da geração do registro U1 ")
	
	LJRPLogProc(" Gravando Arquivo...")
	FCLOSE(nHdlArq)
	LJRPLogProc(" Final da Gravação do Arquivo")
	
	__CopyFile(cLocalPath + cArqRegPaf, cLocalPath + cFimArq)
	LJRPLogProc(" Arquivo de Registro do PAF Finalizado com Sucesso")
Else
	lRet := .F.
	LJRPLogProc("Arquivo não foi gerado. Verifique permissão as pastas")
EndIf

Aadd(aRet,lRet)

Return aRet

//----------------------------------------------------------
/*{Protheus.doc}LJRPIsEnd
Validação se arquivo de Registro do PAF foi encerrado

@param1		cPath , string , caminho do arquivo do PAF
@author  	Julio.Nery
@version 	P11.8
@since   	25/10/2017
@return  	NIL 
@obs   
*/
//--------------------------------------------------------
Function LJRPIsEnd(cPath)
Local lRet := .F.
Local aRet := {}

LJRPLogProc("-> Path:" + cPath)
lRet := File(cPath+cFimArq)
IF !lRet
	LJRPLogProc("Arquivo de Registros do PAF não finalizado no Server")
EndIf

Aadd(aRet,lRet)
Return aRet

//----------------------------------------------------------
/*{Protheus.doc}LJRPIsGer
Valida se arquivo foi gerado

@param1		cPath , string , caminho do arquivo do PAF 
@author  	Julio.Nery
@version 	P11.8
@since   	25/10/2017
@return  	NIL 
@obs   
@sample
*/
//--------------------------------------------------------
Function LJRPIsGer(cPath)
Local lRet := .F.
Local aRet := {}

LJRPLogProc("-> Path:" + cPath)
If File(cPath+cArqRegPaf)
	lRet := .T.
EndIf

Aadd(aRet,lRet)

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstDavEmit³ Autor ³ Venda Clientes        ³ Data ³24/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista os orcamentos (DAVs) emitidas dentro de um periodo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os dados dos DAVs emitidos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstDavEmit(	nHdlArq	, dDataIni	, dDataFim	, lHomolPaf	, ;
							lTemIncManu, lIsPafNfce)
Local cFilSL1	:= ""		// Filial da tabela SL1
Local cAlias	:= ""		// Alias utilizado para consulta dos dados na SL1
Local cTitulo	:= ""  		// Titulo dado ao registro do SL1(orcamento, DAV, Pre-venda, etc.)
Local cTipo		:= ""		// Tipo de registro a ser considerado D-DAV/P-Pre-Venda
Local nPos		:= 0		// Posicao atual no retorno do WebService
Local nPosItem	:= 0		// Posicao atual do item no retorno do WebService
Local nVlrTot	:= 0		// Valor total dos itens da DAV, não pega L1_VLRTOT
Local nX		:= 0		// contador
Local nAux		:= 0 
Local cQuery	:= ""		// Query para selecao de dados no banco de dados
Local cPafMd5	:= ""		// Chave MD5
Local cFilSA1	:= ""      // Filial SA1
Local cModeloECF:= ""
Local cConteudo	:= ""
Local xDtEmissao		
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0       
Local aAux		:=	{}
Local aSL2		:=	{}
Local lIncManual:= .F. //Valida inclusão manual direto no banco
Local lDelManual:= .F.
Local lMFTManual:= .F.
Local lLogDAV	:= .F.
Local lPafMD5OK := .T.
Local lTemPDV	:= .F.
Local lMV_DESCIS:= .F.
Local cTpSolCf  := ""
Local aRetSLG	:= Array(12)
Local aLjExcecao:= {}
Local lExcecaoFcl:= .F.
Local DavListRet:= {}
Local LstItemDav:= {}
Local LstItDavLog:= {}

Default lIsPafNfce	:=.F. 

lLogDAV	:= AliasInDic("MFT")
DbSelectArea("MFT")
DbSelectArea("SL2")
DbSelectArea("SLG")
 
cTpSolCf	:= SuperGetMV("MV_TPSOLCF")
lMV_DESCIS	:= SuperGetMv("MV_DESCISS",,.F.)
cFilSL1		:= xFilial("SL1")		// Filial da tabela SL1
cFilSA1		:= xFilial("SA1")		// Filial da tabela SA1

//Quantidade de casas decimais
nQtdDecQuant	:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit	:= TamSX3("L2_VRUNIT")[2]

//³Verifica qual a opcao considerada para impressao³
If SuperGetMv("MV_LJPRVEN",,.T.) //No teste do bloco VII - ajustar o parametro e o campo L1_TPORC
	cTitulo := "Pre-venda"
	cTipo	:= "P"
Else
	cTitulo := "Orcamento"
	cTipo	:= Iif(lIsPafNfce, "E", "D")
EndIf

//Validação deleção de SL1 e SL2
If lHomolPaf

	SET DELETED OFF  //Habilita deletados para considerar item cancelado	
	DbSelectArea("SL2")
		SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
		SL2->(DbGoTop())
		xDtEmissao := SL2->L2_EMISSAO
		If ValType(xDtEmissao) == "C"
			xDtEmissao := Ctod(xDtEmissao)
		EndIf
	
		//Verifica se foi adicionado/excluido algum registro da SL1 - teste homologação
		While !SL2->(Eof()) .AND. (SL2->L2_FILIAL == xFilial("SL2")) .AND. ( xDtEmissao <= dDataFim )
			If !Empty(SL2->L2_PAFMD5)
				// .And. ! Empty(AllTrim(SL2->L2_PDV))			
				/*
				 Homologação 2017
				 Condição mantida para uso futuro, caso necessário mas visto que o 
				 L2_NUMORIG não é gravado no Loja, afetando o resultado da pesquisa
				
				// .AND. ( Empty(SL2->L2_CONTDOC) .OR. (!Empty(SL2->L2_CONTDOC) .AND. !Empty(SL2->L2_NUMORIG)) )
				*/			 
				Aadd( aSL2 , SL2->L2_FILIAL+SL2->L2_NUM )
			EndIf	
	
			SL2->(DbSkip())
	
			xDtEmissao := SL2->L2_EMISSAO	
			If ValType(xDtEmissao) == "C"
				xDtEmissao := Ctod(xDtEmissao)
			EndIf
		EndDo

	SET DELETED ON 	//Desconsidera deletados

	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))

	For nX := 1 to Len(aSL2)
		If !SL1->(DbSeek(aSL2[nX])) //Se achar L2 e nao tiver o L1, denota L1 deletado manualmente
			lDelManual := .T.
			lTemIncManu := .T.
			Exit
		Else
			lDelManual := .F.
		EndIf
	Next nX
EndIf

cAlias := "SL1TMP"
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= " SELECT L1_FILIAL,L1_EMISSAO,L1_DTLIM,L1_NUMORC,L1_TPORC,L1_VLRTOT,L1_HORA,"
cQuery  += " L1_NUMCFIS,L1_CONTDOC,L1_COODAV,L1_DOC,L1_PAFMD5,L1_SERPDV,L1_STORC,L1_SERIE,L1_CLIENTE,L1_LOJA,L1_NUM, "	
cQuery	+= " L1_COODAV , L1_CGCCLI, L1_DESCONT, L1_VLRLIQ, L1_PDV,L1_VALMERC,L1_ESPECIE, "
cQuery	+= " SA1.A1_NOME,SA1.A1_CGC,SA1.A1_RECISS, SA1.A1_TIPO "
cQuery	+= " FROM " + RetSqlName("SL1") + " SL1 "
cQuery	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery	+= " ON A1_FILIAL='"+cFilSA1+"' AND A1_COD=L1_CLIENTE AND A1_LOJA=L1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= " WHERE "
cQuery	+= " SL1.L1_FILIAL = '" + cFilSL1 + "' "
cQuery	+= " AND SL1.L1_NUMORC 	<>	' ' AND SL1.L1_TPORC  = '" + cTipo + "' "
cQuery	+= " AND SL1.L1_DTLIM 	>=	'" + DtoS(dDataIni)+ "' "
cQuery	+= " AND SL1.L1_DTLIM 	<=	'" + DtoS(dDataFim) + "' "
cQuery	+= " AND SL1.L1_ESPECIE <> 'NFCF' AND SL1.L1_ESPECIE <> 'NFM' "
cQuery	+= " AND SL1.D_E_L_E_T_ = '' "
cQuery	+= " ORDER BY SL1.L1_FILIAL,SL1.L1_DTLIM,SL1.L1_NUMORC"
cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"L1_DTLIM","D")
TcSetField(cAlias,"L1_EMISSAO","D")
(cAlias)->(DbGoTop())

DbSelectArea("SL2")
DbSelectArea("SF4")
DbSelectArea("SB0")
DbSelectArea("SB1")
DbSelectArea("MFT")



SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
SB1->(DbSetOrder(1))
SF4->(DbSetOrder(1))		
MFT->(DbSetOrder(2))  //MFT_FILIAL+MFT_NUM+DTOS(MFT_ALTERA)+MFT_HRALT
		
While !(cAlias)->(Eof())
	
	lPafMD5OK := .T.
	nX := 0
	AAdd(DavListRet,Array(19))
	nPos := Len(DavListRet)
	DavListRet[nPos][1] := AllTrim(SM0->M0_CGC)
	DavListRet[nPos][2] := (cAlias)->L1_NUMORC
	DavListRet[nPos][3]	:= (cAlias)->L1_EMISSAO
	DavListRet[nPos][4]	:= cTitulo 
	DavListRet[nPos][5]	:= (cAlias)->L1_NUMCFIS //COO do Cupom Fiscal da venda concretizada
	DavListRet[nPos][6]	:= (cAlias)->L1_CONTDOC 
	DavListRet[nPos][7]	:= (cAlias)->L1_COODAV  //COO do documento onde a DAV foi impressa pelo ECF, quando impressão por equipamento não fiscal será sinalizado pela String: "0000000"
	DavListRet[nPos][8]	:= AllTrim((cAlias)->L1_SERPDV)
	DavListRet[nPos][9]	:= AllTrim((cAlias)->A1_NOME)
	DavListRet[nPos][10]:= StrTran(StrTran(StrTran(AllTrim((cAlias)->A1_CGC),"-"),"."),"/")
	
	nX := STBRetPDV(DavListRet[nPos][8])[1][2]
	If nX == 0 .And. Empty(AllTrim((cAlias)->L1_PDV))
		DavListRet[nPos][11]:= ""
	Else
		DavListRet[nPos][11] := AllTrim((cAlias)->L1_PDV)
	EndIf
	
	STBDatIECF(nX > 0,@aRetSLG,IIF(nX > 0 , aLstPDVs[nX][2], ""))

	DavListRet[nPos][12]:= aRetSLG[12]
	DavListRet[nPos][13]:= aRetSLG[1]
	DavListRet[nPos][14]:= aRetSLG[8]	
	DavListRet[nPos][15]:= aRetSLG[2]
	If lHomolPaf .And. nX > 0 .And. !LJPRVldLG(aLstPDVs[nX][4],aLstPDVs[nX][2]+aLstPDVs[nX][5])
		DavListRet[nPos][15]:= StrTran(DavListRet[nPos][15]," ","?")
	EndIf
	DavListRet[nPos][19]:= IIf(nX >0 , aLstPDVs[nX][6] , "" )
	
	If nX > 0 //Valida as informações da estação
		lPafMD5OK := LJPRVldLG(aLstPDVs[nX][4],aLstPDVs[nX][2]+aLstPDVs[nX][5])
	EndIf

	/*If lHomolPaf .And. ( AllTrim(cNomCli) <> AllTrim((cAlias)->L1_CLIENTE) .Or. AllTrim(cCGCCli) <> AllTrim((cAlias)->L1_CGCCLI) )
	cNomCli := AllTrim((cAlias)->L1_CLIENTE)
	cCGCCli := AllTrim((cAlias)->L1_CGCCLI)
	lPafMD5OK := .F.
	EndIf*/

	//Gera Chave MD5 dos dados armazenados 
	cPafMd5 := STxPafMd5(cAlias)
	
	/*
	//Trecho para que caso necessario atualize o MD-5
	If lHomolPaf
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
		SL1->(MsSeek(xFilial("SL1")+(cAlias)->L1_NUM))
		RecLock("SL1",.F.)
		REPLACE SL1->L1_PAFMD5 WITH cPafMd5
		SL1->(MsUnlock())
	EndIf
	*/	
	
	lPafMD5OK := lPafMD5OK .And. ((cAlias)->L1_PAFMD5 == cPafMd5 )
	DavListRet[nPos][16]:= lPafMD5OK

	SET DELETED OFF  //Habilita deletados para considerar item cancelado
   
	nPosItem:= 0
	nVlrTot	:= 0

	SL2->(DbSeek(xFilial("SL2")+(cAlias)->L1_NUM))
	While !SL2->(Eof()) .AND. (SL2->(L2_FILIAL+L2_NUM) == xFilial("SL2")+(cAlias)->L1_NUM)

		//Verifica se eh um item do DAV, nao deve trazer itens que foram adicionados no ato da venda
		If (!SL2->(Deleted())  .OR. (SL2->(Deleted()) .AND. SL2->L2_VENDIDO == "N" )) .AND. !Empty(SL2->L2_PAFMD5)
			
			AAdd(LstItemDav,Array(18))
			nPosItem := Len(LstItemDav)

			//Auxiliar para atualizar valor total da DAV
			If AllTrim(SL2->L2_VENDIDO) <> "N" .AND. !SL2->(Deleted())
				nVlrTot += SL2->L2_VLRITEM
			EndIf
			
			LstItemDav[nPosItem][1]		:= AllTrim(SM0->M0_CGC)
			LstItemDav[nPosItem][2]		:= (cAlias)->L1_EMISSAO
			LstItemDav[nPosItem][3]		:= Val(SL2->L2_ITEM)
			LstItemDav[nPosItem][4]		:= SL2->L2_PRODUTO
			LstItemDav[nPosItem][5]		:= SL2->L2_DESCRI
			LstItemDav[nPosItem][6]		:= SL2->L2_QUANT * &("1" + Replicate("0",nQtdDecQuant))
			LstItemDav[nPosItem][7]		:= SL2->L2_UM
			LstItemDav[nPosItem][8]		:= SL2->L2_PRCTAB * &("1" + Replicate("0",nQtdDecVUnit))
			LstItemDav[nPosItem][9]		:= SL2->L2_VALDESC
			LstItemDav[nPosItem][10]	:= 0
			LstItemDav[nPosItem][11]	:= SL2->L2_VLRITEM
			LstItemDav[nPosItem][12]	:= SL2->L2_DECQTD
			LstItemDav[nPosItem][13]	:= SL2->L2_DECVLU

			//deve-se pesquisar a aliquota pois caso haja alteração no banco ela deve aparecer - TESTE BLOCO VII
			If lHomolPaf .OR. Empty(AllTrim(SL2->L2_SITTRIB))
				Aadd( aAux , STBFMSitTrib( SL2->L2_PRODUTO , "" , "SB1" , .F. , cAlias,AllTrim(SL2->L2_TES)) )
				nAux := Len(aAux)
			Else
				AAdd( aAux , AllTrim(SL2->L2_SITTRIB) )
				nAux := Len(aAux)
			EndIf
			
			aAux[nAux] := strtran(aAux[nAux],",")
			aAux[nAux] := strtran(aAux[nAux],".")

			//Verifica a alteração no banco de dados
			If Upper(aAux[nAux]) == AllTrim(Upper(SL2->L2_SITTRIB))
				LstItemDav[nPosItem][14] := aAux[nAux]
			Else
				LstItemDav[nPosItem][14] := StrTran(StrTran(AllTrim(SL2->L2_SITTRIB),","),".")
			EndIf	

			LstItemDav[nPosItem][15] := (AllTrim(SL2->L2_VENDIDO) == "N")

			//O MD5 do SL2 deve ser composto pelo L1_NUMORC para que seja possível validar
			//ao efetuar alteração pelo Banco de Dados. Teste de Homologação do Bloco VII
			cPafMd5 := STxPafMd5("SL2" , AllTrim((cAlias)->L1_NUMORC) )
			
			/*
			//Trecho para possivel e necessaria alteração do MD-5
			If lHomolPaf 
				RecLock("SL2",.F.)
				REPLACE SL2->L2_PAFMD5 WITH cPafMd5
				SL2->(MsUnlock())
			EndIf
			*/	
			
			LstItemDav[nPosItem][16] := .T.
			If ! (AllTrim(SL2->L2_PAFMD5) == AllTrim(cPafMd5) .And. lPafMD5OK)
				LstItemDav[nPosItem][16] := .F.
			EndIf
			
			LstItemDav[nPosItem][17] := DavListRet[nPos][19]
			LstItemDav[nPosItem][18] := AllTrim((cAlias)->L1_NUMORC)
		EndIf
		SL2->(DbSkip())
	End
		
	DavListRet[nPos][17] := nVlrTot
	
	lIncManual := Empty(AllTrim((cAlias)->L1_PAFMD5))
	
	//Valida Inclusão ou Deleção Manual direto no Banco de Dados da Tabela SL2 - Teste Bloco VII - Homologacao PAF-ECF
	If !(nVlrTot == (cAlias)->L1_VLRTOT) .Or. lIncManual
		DavListRet[nPos][18] := .T.
		lTemIncManu := .T.
	Else
		DavListRet[nPos][18] := .F.	
	EndIf

	If !DavListRet[nPos][18] .And. lDelManual
		DavListRet[nPos][18] := .T.
		lDelManual := .F.
		lTemIncManu := .T.
	EndIf
	
	nPosItem := 0
	
	If lLogDAV
		MFT->(DbSeek(xFilial("SL2")+(cAlias)->L1_NUM))
		While !MFT->(Eof()) .AND. (MFT->(MFT_FILIAL+MFT_NUM) == xFilial("SL2")+(cAlias)->L1_NUM)

			AAdd(LstItDavLog,Array(19))
			nPosItem := Len(LstItDavLog)
			
			LstItDavLog[nPosItem][1]		:= MFT->MFT_HRALT
			LstItDavLog[nPosItem][2]		:= MFT->MFT_ALTERA
			LstItDavLog[nPosItem][3]		:= MFT->MFT_PRODUT
			LstItDavLog[nPosItem][4]		:= MFT->MFT_DESCRI
			LstItDavLog[nPosItem][5]		:= MFT->MFT_QUANT * &("1" + Replicate("0",nQtdDecQuant))
			LstItDavLog[nPosItem][6]		:= MFT->MFT_UM
			LstItDavLog[nPosItem][7]		:= MFT->MFT_PRCTAB * &("1" + Replicate("0",nQtdDecVUnit))				
			LstItDavLog[nPosItem][8]		:= MFT->MFT_VALDES
			LstItDavLog[nPosItem][9]		:= 0
			LstItDavLog[nPosItem][10]		:= MFT->MFT_VLRITEM
			LstItDavLog[nPosItem][11]		:= StrTran(StrTran(AllTrim(MFT->MFT_SITTRI),","),".")				
			LstItDavLog[nPosItem][12]		:= (AllTrim(MFT->MFT_VENDID) == "N")					
			LstItDavLog[nPosItem][13]		:= MFT->MFT_SITUA
			LstItDavLog[nPosItem][14]		:= (cAlias)->L1_NUMORC
			LstItDavLog[nPosItem][15]		:= MFT->MFT_DECQTD
			LstItDavLog[nPosItem][16]		:= MFT->MFT_DECVLU
			LstItDavLog[nPosItem][19]		:= .F.
			
			cPafMD5 := STxPafMd5("MFT")
			LstItDavLog[nPosItem][17]	:= (cPafMd5 == AllTrim(MFT->MFT_PAFMD5)) .And. lPafMD5OK
			lMFTManual := .F.
			
			//Valida Exclusão manual
			If MFT->(Deleted()) .And. !Empty(MFT->MFT_PAFMD5) .And. !Empty(AllTrim(MFT->MFT_DOC))//verificar se não precisa de outro campo
				lMFTManual := .T.
				LstItDavLog[nPosItem][19] := .T.

			//Valida inclusão manual
			ElseIf !MFT->(Deleted()) .And. Empty(MFT->MFT_PAFMD5) .And. Empty(AllTrim(MFT->MFT_DOC))
				lMFTManual := .T.
			EndIf

			LstItDavLog[nPosItem][18] := lMFTManual

			MFT->(DbSkip())
		End

		MFT->(DbCloseArea())					 
	EndIf

	SET DELETED ON 	//Desconsidera deletados

	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

If Len(DavListRet) > 0
	LJRPLogProc(" Inicia Geração do arquivo do D2 ")
	
	For nX := 1 to Len(DavListRet)
		/* Quando possui alteração na DAV, conforme legislação PAF, deverá ser evidenciada */
		cModeloECF := DavListRet[nX][15]
		
		cCooDav := DavListRet[nX][7]
		cCOO	:= DavListRet[nX][5]
		lCooDav := If(Empty(AllTrim(cCooDav)) .OR. (cCooDav == "000000   ") .OR. (Val(cCooDav) == 0), .F., .T.)
		
		If lHomolPaf
			If DavListRet[nX][18] .And. !lTemIncManu
				lTemIncManu := .T.
			EndIf
			
			If DavListRet[nX][16]
				cModeloECF := PADR( If(!lCooDav ," ",cModeloECF), 20)			// Modelo do ECF			
			ElseIf lCooDav
				cModeloECF := StrTran(PADR(cModeloECF,20) , " ", "?") // Modelo do ECF quando ocorre modificação nos registros TESTE 103
			ElseIf !DavListRet[nX][16] .AND. !lCooDav
				cModeloECF := REPLICATE("?",20)
			Else
				cModeloECF := REPLICATE(" ",20)   // Modelo do ECF quando ocorre modificação nos registros TESTE 103
			EndIf
		EndIf		
		
		cConteudo := "D2"
		cConteudo += PADL( DavListRet[nX][1], 14 ) 						 	//02- CNPJ
		If !lIsPafNfce
			cConteudo += PADR( IIF(!lCooDav ,"",DavListRet[nX][15]), 20 )		//03- Num. de fabricação do ECF		
			cConteudo += PadR(DavListRet[nX][12],1)					  			//04- Letra indicativa de MF adicional 
			cConteudo += PADR( IIF(!lCooDav ,"",DavListRet[nX][13]), 7)			//05- Tipo do ECF 								
			cConteudo += PADR( IIF(!lCooDav ,"",DavListRet[nX][14]), 20)	  	//06- Marca do ECF
			cConteudo += PADR(cModeloECF,20)									//07- Modelo do ECF
			cConteudo += StrZero( If(Empty(cCOODAV),0,Val(cCOODAV)), 9)			//08- COO DA IMPRESSÃO DA DAV por ECF
		Endif 
		cConteudo += PADR( DavListRet[nX][2], 13)							//09- DAV
		cConteudo += PADR( DtoS(DavListRet[nX][3]),8)						//10- Data da operacao
		cConteudo += PADR( DavListRet[nX][4],30)							//11- Titulo atribuido ao DAV
		cConteudo += PADL( StrTran(StrTran(StrZero(DavListRet[nX][17],9,2),"."),",") ,8)	//12- Valor total do DAV	
		If !lIsPafNfce
			cConteudo += StrZero( If(Empty(cCOO),0,Val(cCOO)), 9)				//13 - Numero do COO
			If Len(DavListRet[nPos][11]) > 3
				cConteudo += StrZero( Val(Substr(DavListRet[nPos][11],2,3)), 3)	//14- Número sequencial do ECF emissor do documento fiscal vinculado
			Else
				cConteudo += StrZero( Val(DavListRet[nPos][11]), 3)				//14- Número sequencial do ECF emissor do documento fiscal vinculado
			EndIf
		Endif 
		cConteudo += PADR( DavListRet[nX][9], 40)							//15- Nome do Cliente 
		cConteudo += StrZero( Val(DavListRet[nX][10]), 14)					//16- CPF ou CNPJ do adquirente			
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq , cConteudo, LEN( cConteudo ) )
	Next nX
	
	ASize(DavListRet,0)
	LJRPLogProc(" Final Geração do arquivo do D2 ")
EndIf

If Len(LstItemDav) > 0
	LJRPLogProc(" Inicia Geração do arquivo do D3 ")

	For nPosItem := 1 to Len(LstItemDav)
		cConteudo := "D3"           								// 01-Tipo
		cConteudo += StrZero( Val(LstItemDav[nPosItem][18]), 13)	// 02-Número do DAV onde está contido este item
		cConteudo += PADR( DtoS(LstItemDav[nPosItem][2]),08)		// 03-Data de inclusão do item							                    
		cConteudo += StrZero( LstItemDav[nPosItem][3], 03)			// 04-Número  sequencial  do  item  registrado no documento 																																	
		cConteudo += PADR(LstItemDav[nPosItem][4], 14) 			 	// 05-Código  do  produto  ou  serviço registrado no documento.
		
		If lHomolPAF .AND. !LstItemDav[nPosItem][16]
			cConteudo += StrTran(PADR(LstItemDav[nPosItem][5], 100)," ","?") // 06-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
		Else
			cConteudo += PADR(LstItemDav[nPosItem][5], 100) 				// 06-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
		EndIf	
			
		cConteudo += StrZero(LstItemDav[nPosItem][6], 07)				// 07-Quantidade,  sem  a  separação  das casas decimais 
		cConteudo += PADR( LstItemDav[nPosItem][7]	,03 )				// 08-Unidade de medida
		
		If lIsPafNfce 													// 09-Valor  unitário  do  produto  ou  serviço, sem a separação das casas decimais. 
			cConteudo += StrZero(LstItemDav[nPosItem][8]	,14 )
		Else
			cConteudo += StrZero(LstItemDav[nPosItem][8]	,08 )
			cConteudo += StrTran(StrZero(LstItemDav[nPosItem][9],9,2),'.')	// 10-Valor  do  desconto  incidente  sobre  o valor  do  item,  com  duas  casas decimais.				
			cConteudo += StrTran(StrZero(LstItemDav[nPosItem][10],9,2),'.')	// 11-Valor  do  acréscimo  incidente  sobre  o valor  do  item,  com  duas  casas decimais. 		
			cConteudo += StrTran(StrZero(LstItemDav[nPosItem][11],15,2),'.')	// 12-Valor  total  líquido  do  item,  com  duas casas decimais. 
		Endif 
		
		cRet := LstItemDav[nPosItem][14]
		If ("S" $ cRet) .OR. ("T" $ cRet)
			cConteudo += PADR( cRet	, 5 )		// 13 e 14-Código  do  totalizador  relativo  ao produto  ou  serviço  conforme  tabela abaixo.					 
		Else                                                                        
			cConteudo += PadR(LstItemDav[nPosItem][14] + "0000", 05)
		EndIf
		
		cConteudo += PADR(IIf(LstItemDav[nPosItem][15],"S","N"), 01 )		// 15-Informar  "S"  ou  "N",  conforme  tenha ocorrido  ou  não,  a  marcação  do cancelamento  do  item  no  documento auxiliar de venda.  
		cConteudo += CVALTOCHAR(LstItemDav[nPosItem][12])					// 16-Casas decimais da qtde
		cConteudo += CVALTOCHAR(LstItemDav[nPosItem][13])					// 17-Casas decimais do valor unitario
		cConteudo += CHR(13) + CHR(10)			
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )	
	Next nPosItem
	
	LJRPLogProc(" Finaliza Geração do arquivo do D3 ")
	ASize(LstItemDav,0)
EndIf

If Len(LstItDavLog) > 0
	LJRPLogProc(" Inicia Geração do arquivo do D4 ")

	For nPosItem := 1 to Len(LstItDavLog)
		
		If lHomolPaf .And. (LstItDavLog[nPosItem][18] .Or. LstItDavLog[nPosItem][19])
			lTemIncManu := .T.
		EndIf

		If (LstItDavLog[nPosItem][19] .AND. !lIsPafNfce) .OR. (AllTrim(LstItDavLog[nPosItem][13]) $"E|A|I" .AND. lIsPafNfce)    //Deleção Manual
			cConteudo := "D4"             										// 01-Tipo
			cConteudo += StrZero( Val(LstItDavLog[nPosItem][14]), 13)			// 02-Número do DAV onde está contido este item
			cConteudo += PADR( DtoS(LstItDavLog[nPosItem][2]),08)				// 03-Data de alteracao do item							                    
			cConteudo += PADR( StrTran(LstItDavLog[nPosItem][1],":"),06)		// 04-Hora de alteracao do item	
			cConteudo += PADR(LstItDavLog[nPosItem][3], 14) 				 	// 06-Código  do  produto  ou  serviço registrado no documento.
			
			If lHomolPaf .And. !LstItDavLog[nPosItem][17]
				cConteudo += StrTran(PADR(LstItDavLog[nPosItem][4], 100)," ","?") 				// 07-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
			Else 		
				cConteudo += PADR(LstItDavLog[nPosItem][4], 100) 				// 07-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
			EndIf			
			cConteudo += StrZero(LstItDavLog[nPosItem][5], 07)				// 08-Quantidade,  sem  a  separação  das casas decimais 
			cConteudo += PADR(LstItDavLog[nPosItem][6]	,03 )				// 09-Unidade de medida
			If lIsPafNfce
				cConteudo += StrZero(LstItDavLog[nPosItem][7]	,14 )				// 10-Valor  unitário  do  produto  ou  serviço, sem a separação das casas decimais.  
			Else 
				cConteudo += StrZero(LstItDavLog[nPosItem][7]	,08 )				// 10-Valor  unitário  do  produto  ou  serviço, sem a separação das casas decimais.  
				cConteudo += StrTran(StrZero(LstItDavLog[nPosItem][8],9,2),'.')	// 11-Valor  do  desconto  incidente  sobre  o valor  do  item,  com  duas  casas decimais.				
				cConteudo += StrTran(StrZero(LstItDavLog[nPosItem][9],9,2),'.')	// 12-Valor  do  acréscimo  incidente  sobre  o valor  do  item,  com  duas  casas decimais. 		
				cConteudo += StrTran(StrZero(LstItDavLog[nPosItem][10],15,2),'.')	// 13-Valor  total  líquido  do  item,  com  duas casas decimais. 
			Endif 

			cRet := LstItDavLog[nPosItem][11]
			If ("S" $ cRet) .OR. ("T" $ cRet)
				cConteudo += PADR( cRet	,05 )		// 14 e 15-Código  do  totalizador  relativo  ao produto  ou  serviço  conforme  tabela abaixo.					 
			Else                                                                        
				cConteudo += PADR(LstItDavLog[nPosItem][11] + "0000", 5)
			EndIf
			
			cConteudo += PADR(If(LstItDavLog[nPosItem][12],"S","N"), 01 )		// 16-Informar  "S"  ou  "N",  conforme  tenha ocorrido  ou  não,  a  marcação  do cancelamento  do  item  no  documento auxiliar de venda.  
			cConteudo += CVALTOCHAR(LstItDavLog[nPosItem][15])	// 17-Casas decimais da qtde
			cConteudo += CVALTOCHAR(LstItDavLog[nPosItem][16])	// 18 - Casas decimais do valor unt
			cConteudo += PADR(LstItDavLog[nPosItem][13], 01 )	//19 - Tipo de Alteracao																				
			cConteudo += CHR(13) + CHR(10)			
			FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
		EndIf
	Next nPosItem
	
	LJRPLogProc(" Finaliza Geração do arquivo do D4 ")
	ASize(LstItDavLog,0)
EndIf

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstMePagto³ Autor ³ Venda Clientes        ³ Data ³13/05/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta meios de pagamento utilizados no PDV em um periodo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os meios de pagamento utilizados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstMePagto(	nHdlArq		, dDataIni		, dDataFim	, cPDV			,;
							lHomolPaf	, lFiltraNFe	, lIsR07	, lTemIncManu 	,;
							lIsPafNfce   )

Local cFilSL1		:= ""					// Filial da tabela SL1
Local cFilSL4		:= ""					// Filial da tabela SL4
Local nPos			:= 0					// Posicao atual no retorno do WebService
Local nCntArr		:= 0					// Contador de elementos no array de retorno
Local dEmisAtu		:= Ctod("")				// Data da emissao atual para quebra
Local aPgtos		:= {{},{}}				// Acumulador de pagamentos para a data
Local cAlias		:= ""					// Alias da tabela SL1
Local cChave		:= ""					// Chave para acumular valores
Local cQuery		:= ""
Local cChaveSX5 	:= ""
Local aDadosPgt 	:= {}
Local aDescTpPag	:= {}					//Array que contera as descricoes das formas de pagamento existentes no X5
Local aAreaSX5		:= {}
Local nX        	:= 0 
Local nY			:= 0
Local cPafMd5		:= ""			        // Chave MD5
Local cFilMDZ 		:= ""					// Filial da tabela MDZ
Local cAliasMDZ		:= "MDZ"				// Alias utilizado para consulta dos dados na MDZ
Local cDescTpPag	:= ""
Local cTipoDoc		:= ""
Local lUsaMDZ		:= .F.	// sinaliza que possui a tabela MDZ
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local cAlias2		:= "SF2"
Local cFilSF2		:= "" 
Local cSerPAF		:= ""
Local cSerPDV		:= ""
Local cNumDoc		:= ""
Local nTamSerie		:= 0
Local nValTroco		:= 0
Local MeiPgtRet		:= {}
Local aPagList		:= Array(11)
Local nPosData		:= 0
Local aTextoImp		:= {}
Local cData			:= ""
Local cForma		:= ""
Local cConteudo 	:= ""
Local cSerNFECF		:= ""
Local aRetSLG		:= {}

Default lFiltraNFe 	:= .F.
Default lIsR07		:= .T.
Default lIsPafNfce	:= .F. 

lUsaMDZ	:= AliasInDic( "MDZ" )
cFilSL1	:= xFilial("SL1")		// Filial da tabela SL1
cFilSL4	:= xFilial("SL4")		// Filial da tabela SL4
cFilSF2	:= xFilial("SF2")		//Filial da Tabela SF2
nTamSerie:= TamSX3("F2_SERIE")[1]
cSerNFECF:= AllTrim(SuperGetMV("MV_LJSNCFP",,"61")) 

DbSelectArea("SX5")
aAreaSX5 := SX5->(GetArea())
SX5->(DbSetOrder(1))
cChaveSX5 := xFilial("SX5")+"24"
SX5->(DbSeek(cChaveSX5))
While !SX5->(Eof()) .AND. (SX5->X5_FILIAL+SX5->X5_TABELA == cChaveSX5)
	Aadd( aDescTpPag , {SX5->X5_CHAVE,SX5->X5_DESCRI} )
	SX5->(DbSkip())
EndDo 
RestArea(aAreaSX5)

/*Pesquisa dos Pagamentos*/
cAlias := "SL1TMP"
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
	
cQuery	:= " SELECT L1_FILIAL,L1_EMISSAO,L1_NUM,L1_PDV,L1_NUMCFIS,L1_PDV," 
cQuery	+= " L1_CONTDOC,L1_CONTONF,L1_STORC, L1_SERPDV, L1_DOC,L1_SERIE,L1_ESPECIE,"
cQuery	+= " L1_TPORC, L1_CGCCLI "
If lIsPafNfce
	cQuery	+= ", L1_KEYNFCE "
Endif 
cQuery	+= " FROM " + RetSqlName("SL1")
cQuery	+= " WHERE "
cQuery	+= " L1_FILIAL = '" + cFilSL1 + "'"
cQuery	+= " AND L1_EMISSAO BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' AND L1_DOC <> ' ' "
If !Empty(cPDV)
	cQuery	+= " AND L1_PDV = '" + cPDV + "' "
EndIf

//No registro R07 não aparece o Nota Fiscal Manual, porem no A2 sim e é usado a mesma pesquisa
If lIsR07
	cQuery += " AND L1_ESPECIE <> 'NFM' "
endIf

cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY L1_EMISSAO "
cQuery	:= ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"L1_EMISSAO","D")	
(cAlias)->(DbGoTop())

DbSelectArea("SL4")
SL4->(DbSetOrder(1))//L4_FILIAL+L4_NUM+L4_ORIGEM

cFilMDZ	:= xFilial("MDZ")
cAliasMDZ := "MDZTMP"

/*
***************************************************************************************************************************
	Para validar Inclusão/Deleção via Banco de Dados - Teste Bloco VII
Inclusão : verifica se o campo do MD5 está em branco e deve ser incluído um registro com mesmo L4_NUM de uma venda valida
Deleção  : verifica no DbSeek se acha o L4 do L1 se nao achar achar eh porque houve a deleção via banco
***************************************************************************************************************************
*/
While !(cAlias)->(Eof())

	If dEmisAtu <> (cAlias)->L1_EMISSAO

		If Len(aPgtos[1]) > 0
		
			Aadd(MeiPgtRet,Array(5))
			nCntArr := Len(MeiPgtRet)
			MeiPgtRet[nCntArr][1]	:= dEmisAtu
			MeiPgtRet[nCntArr][2]	:= aClone(aPgtos[1])
			MeiPgtRet[nCntArr][3]	:= aClone(aPgtos[2])
			MeiPgtRet[nCntArr][4]	:= lIncManual .Or. lDelManual
	        MeiPgtRet[nCntArr][5]	:= {}

			//Carrega Detalhes da Forma de Pagamento
			If Len(aDadosPgt) > 0
				For nX := 1 To Len(aDadosPgt)
					Aadd(MeiPgtRet[nCntArr][5],aClone(aPagList))
					MeiPgtRet[nCntArr][5][nX][1]	:= aDadosPgt[nX][1]
					MeiPgtRet[nCntArr][5][nX][2]	:= aDadosPgt[nX][2]
					MeiPgtRet[nCntArr][5][nX][3]	:= aDadosPgt[nX][3]
					MeiPgtRet[nCntArr][5][nX][4]	:= aDadosPgt[nX][4]
					MeiPgtRet[nCntArr][5][nX][5]	:= aDadosPgt[nX][5]
					MeiPgtRet[nCntArr][5][nX][6]	:= aDadosPgt[nX][6]
					MeiPgtRet[nCntArr][5][nX][7]	:= aDadosPgt[nX][7]
					MeiPgtRet[nCntArr][5][nX][8]	:= aDadosPgt[nX][8]
					MeiPgtRet[nCntArr][5][nX][9]	:= aDadosPgt[nX][9]
					MeiPgtRet[nCntArr][5][nX][10]	:= aDadosPgt[nX][10]
					//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
					MeiPgtRet[nCntArr][5][nX][11]	:= aDadosPgt[nX][11]
				Next nX
			EndIf
		EndIf

		dEmisAtu	:= (cAlias)->L1_EMISSAO
		aPgtos		:= {{},{}}
		aDadosPgt	:= {}

		//Totaliza Suprimentos(R$) via tabela de movimento do ECF para PAF-ECF(MDZ)
		If lUsaMDZ .AND. !lIsPafNfce
			cChave	:= "R$"
			
			If Select(cAliasMDZ) > 0
				(cAliasMDZ)->(DbCloseArea())
			EndIf

			cQuery	:=	"SELECT MDZ_FILIAL,MDZ_COO,MDZ_CDC,MDZ_CCF,MDZ_GNF,MDZ_GRG,MDZ_SIMBOL,MDZ_TIPO,"
			cQuery	+=	"MDZ_VALOR,MDZ_SERPDV,MDZ_DATA,MDZ_HORA,MDZ_PAFMD5,MDZ_PDV "
			cQuery	+=	"FROM " + RetSqlName("MDZ") + " "
			cQuery	+=	"WHERE " 
			cQuery	+= " MDZ_FILIAL = '" + cFilMDZ + "' "
			If !Empty(cPDV)
				cQuery	+=	"AND MDZ_PDV = '" + cPDV + "' "  	
			EndIf
			cQuery	+=	" AND MDZ_DATA = '" + DtoS(dEmisAtu)+ "' "
			cQuery	+=	" AND MDZ_SIMBOL = 'CN' "
			cQuery	+=	" AND MDZ_TIPO NOT IN ('SUPRIMENTO','SANGRIA') " //Não pode aparecer SANGRIA e SUPRIMENTO no A2
			cQuery	+=  " AND D_E_L_E_T_ = ' ' "
			cQuery	:=	ChangeQuery( cQuery )

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasMDZ, .F., .T.)
			TcSetField(cAliasMDZ,"MDZ_DATA","D")
			(cAliasMDZ)->(DbGoTop())

			While !(cAliasMDZ)->(Eof())
				 
				nPos 	:= aScan(aPgtos[1],cChave)

				If nPos == 0
					AAdd(aPgtos[1],cChave)
					AAdd(aPgtos[2],(cAliasMDZ)->MDZ_VALOR)  
				Else
					aPgtos[2][nPos] += (cAliasMDZ)->MDZ_VALOR
				EndIf

				cPafMd5 := STxPafMd5(cAliasMDZ)			

				nY := Ascan(aDescTpPag , { |x| AllTrim(x[1]) == AllTrim(cChave) })
				If nY > 0
					cDescTpPag	 := aDescTpPag[nY][2]
				Else
					cDescTpPag	 := "Dinheiro"
				EndIf
				If Val((cAliasMDZ)->MDZ_GNF) > 0
					cTipoDoc := "Documento Não Fiscal"
				ElseIf Val((cAliasMDZ)->MDZ_CCF) == 0
					cTipoDoc := "Nota Fiscal"
				ElseIf Val((cAliasMDZ)->MDZ_CCF) > 0
					cTipoDoc := "Cupom Fiscal" 
				EndIf  

				lIncManual := Empty((cAliasMDZ)->MDZ_PAFMD5)

				//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco       		
				AAdd(aDadosPgt, {cChave, (cAliasMDZ)->MDZ_VALOR, Val((cAliasMDZ)->MDZ_COO),;
								Val((cAliasMDZ)->MDZ_GNF), Val((cAliasMDZ)->MDZ_CCF), ;
								If(!Empty(AllTrim((cAliasMDZ)->MDZ_SERPDV)), (cAliasMDZ)->MDZ_SERPDV, LjPesqPdv((cAliasMDZ)->MDZ_PDV,"") ),;
								((cAliasMDZ)->MDZ_PAFMD5 == cPafMd5),.F.,;
								cDescTpPag, cTipoDoc, lIncManual })

				(cAliasMDZ)->(DbSkip())
			EndDo
			
			(cAliasMDZ)->(DbCloseArea())
		EndIf
	EndIf

	//Se nao foi encontrado o SL4 da venda, significa que 
	//foi deletado manualmente via banco de dados - Teste Bloco VII
	If !SL4->(DbSeek(cFilSL4+(cAlias)->L1_NUM)) .OR. Empty(SL4->L4_PAFMD5)
		lTemIncManu:= .T.
		lDelManual := .T.
	EndIf
	
	While !SL4->(Eof()) .AND. SL4->L4_NUM == (cAlias)->L1_NUM

		If Empty(SL4->L4_INSTITU)
			cChave	:= AllTrim(SL4->L4_FORMA)
		Else
			cChave	:= AllTrim(SL4->L4_FORMA) + "-" + AllTrim(SL4->L4_INSTITU)
		EndIf

		nPos 	:= aScan(aPgtos[1],cChave)

		If nPos == 0
			AAdd(aPgtos[1],cChave)
			AAdd(aPgtos[2],SL4->L4_VALOR)
		Else
			aPgtos[2][nPos] += SL4->L4_VALOR
		EndIf

		cPafMd5 := STxPafMd5("SL4")

		nY := Ascan(aDescTpPag , { |x| AllTrim(x[1]) == AllTrim(SL4->L4_FORMA) })
		If nY > 0
			cDescTpPag	 := aDescTpPag[nY][2]
		Else
			cDescTpPag	 := "Dinheiro"
		EndIF

		If !Empty(Alltrim(SL4->L4_SERPDV))
			cSerPdv := SL4->L4_SERPDV
		ElseIf !Empty(Alltrim((cAlias)->L1_SERPDV))
			cSerPDV := (cAlias)->L1_SERPDV
		EndIf

		If Empty(AllTrim(cSerPDV))
			cSerPDV := LjPesqPdv((cAlias)->L1_PDV,(cAlias)->L1_SERIE)
		EndIf

		cNumDoc := iif( Val(SL4->L4_DOC) == 0 , Val((cAlias)->L1_DOC) ,Val(SL4->L4_DOC) )
		
		If lIsPafNfce
			If !Empty((cAlias)->L1_KEYNFCE)
				cTipoDoc :="1"
			Else
				cTipoDoc :="3"
			Endif 
		Else 
			If (Val((cAlias)->L1_NUMCFIS) == 0 .AND. Empty(AllTrim((cAlias)->L1_PDV))) .Or.;
				((AllTrim((cAlias)->L1_ESPECIE) == "NFCF") .And. (AllTrim((cAlias)->L1_SERIE) == cSerNFECF))
				
				cTipoDoc := "Nota Fiscal"
				
				If AllTrim((cAlias)->L1_ESPECIE) == "NFCF" //o L1_DOC contem o numero da nota e deve mostrar o COO pois foi impresso um cupom
					cNumDoc := Val((cAlias)->L1_NUMCFIS)
				EndIf
			ElseIf Val((cAlias)->L1_NUMCFIS) > 0 .AND. !Empty(AllTrim((cAlias)->L1_SERPDV))
				
				If ((AllTrim((cAlias)->L1_ESPECIE) == "NFCF") .And. (AllTrim((cAlias)->L1_SERIE) == cSerNFECF))
					cTipoDoc := "Nota Fiscal"
				Else
					cTipoDoc := "Cupom Fiscal"
				EndIf

				If AllTrim((cAlias)->L1_ESPECIE) == "NFCF" //o L1_DOC contem o numero da nota e deve mostrar o COO pois foi impresso um cupom
					cNumDoc := Val((cAlias)->L1_NUMCFIS)
				EndIf
			ElseIf Val((cAlias)->L1_CONTONF) > 0
				cTipoDoc := "Documento Não Fiscal"
			EndIf
		Endif 

		nValTroco := 0

		If SL4->L4_TROCO > 0
			nValTroco := SL4->L4_TROCO
		EndIf

		//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco       		
		AAdd(aDadosPgt, {cChave, SL4->L4_VALOR-nValTroco,  cNumDoc  ,;
						IF ( Val(SL4->L4_CONTDOC)== 0, Val((cAlias)->L1_CONTDOC),Val(SL4->L4_CONTDOC)),;
						IF ( Val(SL4->L4_CONTONF)== 0, Val((cAlias)->L1_CONTONF),Val(SL4->L4_CONTONF)), ;
						cSerPDV ,(SL4->L4_PAFMD5 == cPafMd5) .And. WsLeMD5LG(cSerPDV),((cAlias)->L1_STORC == "C"), cDescTpPag , cTipoDoc,;
						Empty(SL4->L4_PAFMD5)} )

		SL4->(DbSkip())
	End

	(cAlias)->(DbSkip())
EndDo

If Len(aPgtos[1]) > 0
	Aadd(MeiPgtRet,Array(5))
	nCntArr := Len(MeiPgtRet)
	MeiPgtRet[nCntArr][1]	:= dEmisAtu
	MeiPgtRet[nCntArr][2]	:= aClone(aPgtos[1])
	MeiPgtRet[nCntArr][3]	:= aClone(aPgtos[2])
	MeiPgtRet[nCntArr][4]	:= lIncManual .Or. lDelManual  
	MeiPgtRet[nCntArr][5]	:= {}

	//³Carrega Detalhes da Forma de Pagamento.³
    If Len(aDadosPgt) > 0
		For nX := 1 To Len(aDadosPgt)
			Aadd(MeiPgtRet[nCntArr][5],aClone(aPagList))
			MeiPgtRet[nCntArr][5][nX][1]   	:= aDadosPgt[nX][1]
			MeiPgtRet[nCntArr][5][nX][2]    := aDadosPgt[nX][2]
			MeiPgtRet[nCntArr][5][nX][3] 	:= aDadosPgt[nX][3]
			MeiPgtRet[nCntArr][5][nX][4]	:= aDadosPgt[nX][4]
			MeiPgtRet[nCntArr][5][nX][5]	:= aDadosPgt[nX][5]
			MeiPgtRet[nCntArr][5][nX][6]	:= aDadosPgt[nX][6]
			MeiPgtRet[nCntArr][5][nX][7]	:= aDadosPgt[nX][7]
			MeiPgtRet[nCntArr][5][nX][8]	:= aDadosPgt[nX][8]
			MeiPgtRet[nCntArr][5][nX][9]	:= aDadosPgt[nX][9]
			MeiPgtRet[nCntArr][5][nX][10]	:= aDadosPgt[nX][10]
			//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
			MeiPgtRet[nCntArr][5][nX][11]	:= aDadosPgt[nX][11]
        Next nX
    EndIf
EndIf

dEmisAtu	:= CtoD("")
aPgtos		:= {{},{}} 
aDadosPgt	:= {}

If lFiltraNFe

	cSerPAF	:= SuperGetMv("MV_LJSNFEP",,"") //Serie da NF-e no PAF
	
	If Empty(AllTrim(cSerPAF))
		LJRPLogProc(" o parâmetro MV_LJSNFEP está em branco não serão filtradas as notas/vendas (SF2) " +;
					" efetuadas em ambiente PAF-ECF")
	Else
		LJRPLogProc(" Caso haja dados e não sejam mostradas as informações no arquivo de Registro do PAF" +;
					" verifique a configuração do parâmetro MV_LJSNFEP - Conteúdo Atual [" + cSerPAF + "]")
	EndIf

	cAlias2 := "SF2TMP"

	If Select(cAlias2) > 0
		(cAlias2)->(DbCloseArea())
	EndIf
	
	cQuery	:= " SELECT F2_FILIAL, F2_SERIE, F2_EMISSAO,  F2_CHVNFE, F2_VALBRUT " 	
	cQuery	+= " FROM " + RetSqlName("SF2")
	cQuery	+= " WHERE "
	cQuery	+= " F2_FILIAL = '" + cFilSF2 + "'"
	//Tem que ser exatamente a serie de NF-e de venda em PAF senão virão 
	//todas as vendas do Protheus, inclusive vendas da SL1 que já foram acumuladas  
	cQuery	+= " AND F2_SERIE = '" + cSerPAF + "' "
	cQuery	+= " AND F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
	cQuery	+= " AND F2_CHVNFE <> ' ' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY F2_EMISSAO "

	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias2, .F., .T.)
	TcSetField(cAlias2,"F2_EMISSAO","D")
	(cAlias2)->(DbGoTop())
	cChave	:= "DU - DUPLICATA"

	While !(cAlias2)->(Eof())

		lIncManual  := .F.
		If dEmisAtu <> (cAlias2)->F2_EMISSAO

			If Len(aPgtos[1]) > 0

				Aadd(MeiPgtRet,Array(5))
				nCntArr := Len(MeiPgtRet)

				MeiPgtRet[nCntArr][1]	:= dEmisAtu
				MeiPgtRet[nCntArr][2]	:= aClone(aPgtos[1])
				MeiPgtRet[nCntArr][3]	:= aClone(aPgtos[2])
				MeiPgtRet[nCntArr][4]	:= lIncManual .Or. lDelManual 
		        MeiPgtRet[nCntArr][5]	:= {}
		        
				//Carrega Detalhes da Forma de Pagamento
				If Len(aDadosPgt) > 0
					For nX := 1 To Len(aDadosPgt)
						Aadd(MeiPgtRet[nCntArr][5],aClone(aPagList))
						MeiPgtRet[nCntArr][5][nX][1]   	:= aDadosPgt[nX][1]
						MeiPgtRet[nCntArr][5][nX][2]    := aDadosPgt[nX][2]
						MeiPgtRet[nCntArr][5][nX][3]	:= aDadosPgt[nX][3]
						MeiPgtRet[nCntArr][5][nX][4]	:= aDadosPgt[nX][4]
						MeiPgtRet[nCntArr][5][nX][5]	:= aDadosPgt[nX][5]
						MeiPgtRet[nCntArr][5][nX][6]	:= aDadosPgt[nX][6]
						MeiPgtRet[nCntArr][5][nX][7]	:= aDadosPgt[nX][7]
						MeiPgtRet[nCntArr][5][nX][8]	:= aDadosPgt[nX][8]
						MeiPgtRet[nCntArr][5][nX][9]	:= aDadosPgt[nX][9]
						MeiPgtRet[nCntArr][5][nX][10]	:= aDadosPgt[nX][10]
						//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
						MeiPgtRet[nCntArr][5][nX][11]	:= aDadosPgt[nX][11]
					Next nX
				EndIf
			EndIf

			dEmisAtu	:= (cAlias2)->F2_EMISSAO
			aPgtos		:= {{},{}}
			aDadosPgt	:= {}
		EndIf

		nPos 	:= aScan(aPgtos[1],cChave)

		If nPos == 0
			AAdd(aPgtos[1],cChave)
			AAdd(aPgtos[2],(cAlias2)->F2_VALBRUT)
		Else
			aPgtos[2][nPos] += (cAlias2)->F2_VALBRUT
		EndIf

		cDescTpPag := "Duplicata"
		cTipoDoc := "Nota Fiscal"

		//Gera o Registro da NF-e  
		AAdd(aDadosPgt, {"", (cAlias2)->F2_VALBRUT, 0, 0, 0,"",.T.,.F., cDescTpPag , cTipoDoc,.F.} )

		(cAlias2)->(DbSkip())
	EndDo	

	(cAlias2)->(DbCloseArea())
EndIf

If Len(aPgtos[1]) > 0
	Aadd(MeiPgtRet,Array(5))
	nCntArr := Len(MeiPgtRet)
	MeiPgtRet[nCntArr][1]	:= dEmisAtu
	MeiPgtRet[nCntArr][2]	:= aClone(aPgtos[1])
	MeiPgtRet[nCntArr][3]	:= aClone(aPgtos[2])
	MeiPgtRet[nCntArr][4]	:= lIncManual .Or. lDelManual  
	MeiPgtRet[nCntArr][5]	:= {}

	//³Carrega Detalhes da Forma de Pagamento.³
    If Len(aDadosPgt) > 0
		For nX := 1 To Len(aDadosPgt)
			Aadd(MeiPgtRet[nCntArr][5],aClone(aPagList))
			MeiPgtRet[nCntArr][5][nX][1]   	:= aDadosPgt[nX][1]
			MeiPgtRet[nCntArr][5][nX][2]    := aDadosPgt[nX][2]
			MeiPgtRet[nCntArr][5][nX][3] 	:= aDadosPgt[nX][3]
			MeiPgtRet[nCntArr][5][nX][4]	:= aDadosPgt[nX][4]
			MeiPgtRet[nCntArr][5][nX][5]	:= aDadosPgt[nX][5]
			MeiPgtRet[nCntArr][5][nX][6]	:= aDadosPgt[nX][6]
			MeiPgtRet[nCntArr][5][nX][7]	:= aDadosPgt[nX][7]
			MeiPgtRet[nCntArr][5][nX][8]	:= aDadosPgt[nX][8]
			MeiPgtRet[nCntArr][5][nX][9]	:= aDadosPgt[nX][9]
			MeiPgtRet[nCntArr][5][nX][10]	:= aDadosPgt[nX][10]
			//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
			MeiPgtRet[nCntArr][5][nX][11]	:= aDadosPgt[nX][11]
        Next nX
    EndIf
EndIf

(cAlias)->(DbCloseArea())

If Len(MeiPgtRet) > 0 .And. !lIsR07
	For nX := 1 to Len(MeiPgtRet)
		For nY := 1 to Len(MeiPgtRet[nX][5])
			If Len(aTextoImp) > 0
				nPosData := aSCan(aTextoImp,{ |x| AllTrim(x[1]) == AllTrim(DtoC(MeiPgtRet[nX][1])) })
			EndIf
			
			If nPosData == 0
				cTipoDoc := " "
				
				If lIsPafNfce
					cTipoDoc :=MeiPgtRet[nX][5][nY][10]
				Else
					If AllTrim(MeiPgtRet[nX][5][nY][10]) == "Nota Fiscal"
						cTipoDoc := "3"
					ElseIf AllTrim(MeiPgtRet[nX][5][nY][10]) == "Cupom Fiscal"
						cTipoDoc := "1"
					ElseIf AllTrim(MeiPgtRet[nX][5][nY][10]) == "Documento Não Fiscal"
						cTipoDoc := "2"
					EndIf
				Endif 
					
				AAdd( aTextoImp , {	AllTrim(DtoC(MeiPgtRet[nX][1]))		,;
										AllTrim(MeiPgtRet[nX][5][nY][9]),;
										AllTrim(MeiPgtRet[nX][5][nY][10]),;
										MeiPgtRet[nX][5][nY][2]			 ,;
										cTipoDoc,;
										MeiPgtRet[nX][5][nY][11],; //Inclusão-Deleção Manual
										MeiPgtRet[nX][5][nY][7]} ) //Alteração Manual
			Else
				cData	:= AllTrim(DtoC(MeiPgtRet[nX][1]))
				cForma	:= AllTrim(MeiPgtRet[nX][5][nY][9])
				cTipoDoc :=  AllTrim(MeiPgtRet[nX][5][nY][10])
				nPosData := aScan(aTextoImp,{ |x| 	AllTrim(x[1]) == cData .and. AllTrim(x[2]) == cForma .AND. AllTrim(x[3]) == cTipoDoc })
					
				If nPosData > 0
					aTextoImp[nPosData][4] += MeiPgtRet[nX][5][nY][2]  
					aTextoImp[nPosData][6] := aTextoImp[nPosData][6] .AND. MeiPgtRet[nX][5][nY][11]
				Else
					
					If lIsPafNfce
						cTipoDoc :=MeiPgtRet[nX][5][nY][10]
					Else
						If AllTrim(MeiPgtRet[nX][5][nY][10]) == "Nota Fiscal"
							cTipoDoc := "3"
						ElseIf AllTrim(MeiPgtRet[nX][5][nY][10]) == "Cupom Fiscal"
							cTipoDoc := "1"
						ElseIf AllTrim(MeiPgtRet[nX][5][nY][10]) == "Documento Não Fiscal"
							cTipoDoc := "2"
						EndIf
					Endif 

					AAdd( aTextoImp , {	AllTrim(DtoC(MeiPgtRet[nX][1]))		,;
											AllTrim(MeiPgtRet[nX][5][nY][9]),;
											AllTrim(MeiPgtRet[nX][5][nY][10]),;
											MeiPgtRet[nX][5][nY][2]			 ,;
											cTipoDoc,;
											MeiPgtRet[nX][5][nY][11],; //Inclusão-Deleção Manual
											MeiPgtRet[nX][5][nY][7]} ) //Alteração Manual
				EndIf
			EndIf
		Next nY
	Next nX
	
	ASize(MeiPgtRet,0)
EndIf

If !lIsR07
	If Len(aTextoImp) > 0
		LJRPLogProc(" Registro A2 [Em execução...]")
	EndIf
	
	For nX := 1 to Len(aTextoImp)
		If lHomolPaf .And. ( aTextoImp[nX][6] .Or. lDelManual )
			lTemIncManu := .T.
		EndIf
		
		cConteudo := "A2" //Tipo de Registro 02 - 01/02 X
	    cConteudo += DtoS(CtoD(aTextoImp[nX][1]))    //Data 08 - 03/10 YYYYMMDD
	    If lHomolPaf .And. !aTextoImp[nX][7]
	    	cConteudo += StrTran(PadR(aTextoImp[nX][2],25)," ","?")   //Meio de Pagamento 25 - 11/35 X
	    Else 
	    	cConteudo += PadR(aTextoImp[nX][2],25)   //Meio de Pagamento 25 - 11/35 X
	    EndIf
	    cConteudo += aTextoImp[nX][5] //Codigo do Tipo de documento 01 - 36/36 X
	    cConteudo += StrTran(StrZero(aTextoImp[nX][4],13,2),".") + CHR(13) + CHR(10) //Valor 12 - 37/48 N + CRLF    
	    FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	Next nX
	
	If Len(aTextoImp) > 0
		LJRPLogProc(" Registro A2 [Fim]")
	EndIf
Else
	//Geração do R07
	If Len(MeiPgtRet) > 0
		LJRPLogProc( " Registro R07 [Em execução...]")
	EndIf
	
	For nX := 1 to Len(MeiPgtRet)
		For nY := 1 to Len(MeiPgtRet[nX][5])
			If !Empty(MeiPgtRet[nX][5][nY][6])

				If lHomolPaf .And. ( MeiPgtRet[nX][5][nY][11] .Or. lDelManual )
					lTemIncManu := .T.
				EndIf
				
				cForma := AllTrim(MeiPgtRet[nX][5][nY][9])
				nCntArr := STBRetPDV(MeiPgtRet[nX][5][nY][6])[1][2]
				aRetSLG := STBDatIECF(nCntArr > 0,@aRetSLG,IIF(nCntArr > 0 , aLstPDVs[nCntArr][2], ""))
								
				cConteudo := "R07"	//Tipo
				cConteudo += PadR(MeiPgtRet[nX][5][nY][6],20) //02-Numero de Fabricação
				cConteudo += PadR(aRetSLG[12],1) //03- MF ADICional do ECF
				
				If lHomolPaf .And. ( !MeiPgtRet[nX][5][nY][7] .Or. ;
									(nCntArr > 0 .And. !LJPRVldLG(aLstPDVs[nCntArr][4],aLstPDVs[nCntArr][2]+aLstPDVs[nCntArr][5])) )
					cConteudo += StrTran(PadR(aRetSLG[2],20)," ","?") //04-Modelo do ECF
				Else
					cConteudo += PadR(aRetSLG[2],20) //04-Modelo do ECF
				EndIf
				
				If ValType(aRetSLG[10]) == "N"
					cConteudo += StrZero(aRetSLG[10],2) //05-Numero Usuário do ECF
				Else
					cConteudo += StrZero(Val(aRetSLG[10]),2) //05-Numero Usuário do ECF
				EndIf
				cConteudo += StrZero( MeiPgtRet[nX][5][nY][3] , 9 ) // 06 - COO (Contador de Ordem de Operacao) 
				cConteudo += StrZero( MeiPgtRet[nX][5][nY][4] , 9 ) // 07 - Numero do Contador de Cupom Fiscal relativo ao respectivo Cupom Fiscal emitido
				cConteudo += StrZero( MeiPgtRet[nX][5][nY][5] , 6 ) // 08 - Numero do Contador Geral Não Fiscal relativo ao respectivo Comprovante Não Fiscal emitido
				cConteudo += PadR(cForma,15) // 09 - Descricao do totalizador parcial de meio de pagamento
				cConteudo += StrTran(StrZero( MeiPgtRet[nX][5][nY][2], 14, 2),'.') // 10 - Valor do pagamento efetuado, com duas casas decimais
				
				If MeiPgtRet[nX][5][nY][8] //Cancelado ?
					cConteudo += "S"
					cConteudo += StrTran(StrZero( MeiPgtRet[nX][5][nY][2] , 14, 2),'.',"")
				Else
					cConteudo += "N"
					cConteudo += StrZero(0, 13 )
				EndIf
				
				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) ) 
			EndIf
		Next nY
	Next nX
	
	If Len(MeiPgtRet) > 0
		LJRPLogProc( " Registro R07 [Fim]")
	EndIf	
EndIf

ASize(aTextoImp,0)
ASize(MeiPgtRet,0)

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstPagCanc ºAutor  ³Microsiga           º Data ³  03/06/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista os pagamentos           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados dos itens vendidos no periodo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstPagCanc ( nHdlArq , dDataIni,dDataFim,cPDV,;
							lHomolPaf,lIsR07,lTemIncManu,lReducao )
Local nPos			:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nContDoc		:= 0   
Local nCntArr		:= 0
Local nX        	:= 0 
Local nY			:= 0
Local cTotParc		:= "" 
Local cQuery		:= ""
Local cIndex		:= ""
Local cChave		:= ""
Local cNumOrc		:= ""
Local cSLX			:= ""
Local caSL4			:= ""
Local cChaveSX5 	:= ""
Local cDescTpPag	:= ""
Local cTipoDoc		:= ""
Local cSerPDV		:= ""
Local cLX_cupom		:= ""
Local cConteudo		:= ""
Local aPagList		:= Array(11)
Local MeiPgtRet		:= {}
Local aTextoImp		:= {}
Local aRetSLG		:= {}
Local aDadosPgt 	:= {}
Local aDescTpPag	:= {}					//Array que contera as descricoes das formas de pagamento existentes no X5
Local aPgtos		:= {{},{}}				// Acumulador de pagamentos para a data
Local lIncManual	:= .F.
Local lLxDesc		:= .F.
Local dEmisAtu		:= CTOD('')

Default lIsR07		:= .T.

nQtdDecQuant:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit:= TamSX3("L2_VRUNIT")[2]

If !(Select("SX5") > 0)
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1)) 
EndIf

cChaveSX5 := xFilial("SX5")+"24"
SX5->(DbSeek(cChaveSX5))
While !SX5->(Eof()) .AND. (SX5->X5_FILIAL+SX5->X5_TABELA == cChaveSX5)
	Aadd( aDescTpPag , {SX5->X5_CHAVE,SX5->X5_DESCRI} )
	SX5->(DbSkip())
EndDo

//Captura registros da SLX	
cSLX	:= "SLXTMP"

If Select(cSLX) > 0
	(cSLX)->(DbCloseArea())
EndIf

cQuery	:= " SELECT " 
cQuery	+= " SLX.* "
cQuery	+= " FROM " + RetSqlName("SLX") + " SLX "
cQuery	+=  "WHERE SLX.LX_FILIAL='"+xFilial('SLX')+"' "
cQuery	+= " AND SLX.LX_TPCANC <> 'D' AND SLX.LX_TPCANC <> 'I' " //D = Devolucao/I = Item -> não devem aparecer na pesquisa
cQuery	+= " AND SLX.LX_VALOR > 0 " //Vendas que foram canceladas apos serem impressas tem valor maior que 0 

If !Empty(cPDV)
	cQuery	+= " AND SLX.LX_PDV = '" + cPDV + "' "
EndIf

cQuery	+= " AND SLX.LX_DTMOVTO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
cQuery	+= " AND SLX.D_E_L_E_T_ = ' '  "
cQuery	+= " ORDER BY LX_DTMOVTO,LX_CUPOM "

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSLX, .F., .T.)
TcSetField(cSLX,"LX_DTMOVTO","D")
(cSLX)->(DbGoTop())

While !(cSLX)->(Eof())

	If dEmisAtu <> (cSLX)->LX_DTMOVTO
		If Len(aPgtos[1]) > 0
			Aadd(MeiPgtRet,Array(5))
			nCntArr := Len(MeiPgtRet)			
			MeiPgtRet[nCntArr][1]	:= dEmisAtu
			MeiPgtRet[nCntArr][2]	:= aClone(aPgtos[1])
			MeiPgtRet[nCntArr][3]	:= aClone(aPgtos[2])
			MeiPgtRet[nCntArr][4]	:= lIncManual
	        MeiPgtRet[nCntArr][5]	:= {}

			//Carrega Detalhes da Forma de Pagamento
			If Len(aDadosPgt) > 0
				For nX := 1 To Len(aDadosPgt)
					Aadd(MeiPgtRet[nCntArr][5],aClone(aPagList))
					MeiPgtRet[nCntArr][5][nX][1]	:= aDadosPgt[nX][1]
					MeiPgtRet[nCntArr][5][nX][2]	:= aDadosPgt[nX][2]
					MeiPgtRet[nCntArr][5][nX][3]	:= aDadosPgt[nX][3]
					MeiPgtRet[nCntArr][5][nX][4]	:= aDadosPgt[nX][4]
					MeiPgtRet[nCntArr][5][nX][5]	:= aDadosPgt[nX][5]
					MeiPgtRet[nCntArr][5][nX][6]	:= aDadosPgt[nX][6]
					MeiPgtRet[nCntArr][5][nX][7]	:= aDadosPgt[nX][7]
					MeiPgtRet[nCntArr][5][nX][8]	:= aDadosPgt[nX][8]
					MeiPgtRet[nCntArr][5][nX][9]	:= aDadosPgt[nX][9]
					MeiPgtRet[nCntArr][5][nX][10]	:= aDadosPgt[nX][10]					
					//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
					MeiPgtRet[nCntArr][5][nX][11]	:= aDadosPgt[nX][11]
				Next nX
			EndIf
		EndIf

		dEmisAtu:= (cSLX)->LX_DTMOVTO
		aPgtos	:= {{},{}} 
		aDadosPgt:= {}
	EndIf

	If cLX_cupom <> (cSLX)->LX_CUPOM
		caSL4 := "SL4TMP"

		If Select(caSL4) > 0
			(caSL4)->(DbCloseArea())
		EndIf

		//Nesse caso SL4 está deletado e para retornar as informações corretas busco nela
		cQuery	:= " select SL4.*"
		cQuery	+= " FROM " + RetSqlName("SL4") + " SL4 "
		cQuery	+= " WHERE L4_FILIAL = '" + xFilial("SL1") + "' "
		cQuery	+= " AND L4_DOC ='" + (cSLX)->LX_CUPOM + "' "

		cQuery := ChangeQuery( cQuery )
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),caSL4, .F., .T.)
		(caSL4)->(DbGoTop())
	
		While !(caSL4)->(Eof())
			cChave	:= (caSL4)->L4_FORMA
			nPos 	:= aScan(aPgtos[1],cChave)

			If nPos == 0
				AAdd(aPgtos[1],cChave)
				AAdd(aPgtos[2],(caSL4)->L4_VALOR)
			Else
				aPgtos[2][nPos] += (caSL4)->L4_VALOR
			EndIf

			nY := Ascan(aDescTpPag , { |x| AllTrim(x[1]) == AllTrim(cChave) })
			If nY > 0
				cDescTpPag	 := aDescTpPag[nY][2]
			Else
				cDescTpPag	 := "Dinheiro"
			EndIf

			cSerPDV	:= LjPesqPdv((cSLX)->LX_PDV , (cSLX)->LX_SERIE)

			If Val((caSL4)->L4_CONTONF) > 0
				cTipoDoc := "Documento Não Fiscal"
			Else
				cTipoDoc := "Cupom Fiscal"
			EndIf		
       		
			AAdd(aDadosPgt, {cChave, (caSL4)->L4_VALOR, Val((cSLX)->LX_CUPOM),Val((cSLX)->LX_CONTDOC),;
							Val((caSL4)->L4_CONTONF),cSerPDV ,.T.,((cSLX)->LX_TPCANC == "C"), cDescTpPag , cTipoDoc,.F. } )

			(caSL4)->(DbSkip())	
		End
		cLX_cupom := (cSLX)->LX_CUPOM 
	EndIf

	(cSLX)->(DbSkip())
End

If Len(aPgtos[1]) > 0
	Aadd(MeiPgtRet,Array(5))
	nCntArr := Len(MeiPgtRet)
	MeiPgtRet[nCntArr][1]	:= dEmisAtu
	MeiPgtRet[nCntArr][2]	:= aClone(aPgtos[1])
	MeiPgtRet[nCntArr][3]	:= aClone(aPgtos[2])
	MeiPgtRet[nCntArr][4]	:= lIncManual
	MeiPgtRet[nCntArr][5]	:= {}

	//³Carrega Detalhes da Forma de Pagamento.³
    If Len(aDadosPgt) > 0
		For nX := 1 To Len(aDadosPgt)
			Aadd(MeiPgtRet[nCntArr][5],aClone(aPagList))			
			MeiPgtRet[nCntArr][5][nX][1]   	:= aDadosPgt[nX][1]
			MeiPgtRet[nCntArr][5][nX][2]    := aDadosPgt[nX][2]
			MeiPgtRet[nCntArr][5][nX][3] 	:= aDadosPgt[nX][3]
			MeiPgtRet[nCntArr][5][nX][4]	:= aDadosPgt[nX][4]
			MeiPgtRet[nCntArr][5][nX][5]	:= aDadosPgt[nX][5]
			MeiPgtRet[nCntArr][5][nX][6]	:= aDadosPgt[nX][6]
			MeiPgtRet[nCntArr][5][nX][7]	:= aDadosPgt[nX][7]
			MeiPgtRet[nCntArr][5][nX][8]	:= aDadosPgt[nX][8]
			MeiPgtRet[nCntArr][5][nX][9]	:= aDadosPgt[nX][9]
			MeiPgtRet[nCntArr][5][nX][10]	:= aDadosPgt[nX][10]
			//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
			MeiPgtRet[nCntArr][5][nX][11]	:= aDadosPgt[nX][11]
        Next nX
    EndIf
EndIf  

(cSLX)->(DbCloseArea())

If !lIsR07
	If Len(aTextoImp) > 0
		LJRPLogProc(" Registro A2 cnc [Em execução...]")
	EndIf
	
	For nX := 1 to Len(aTextoImp)
		If lHomolPaf .And. aTextoImp[nX][6] 
			lTemIncManu := .T.
		EndIf
		
		cConteudo := "A2" //Tipo de Registro 02 - 01/02 X
	    cConteudo += DtoS(CtoD(aTextoImp[nX][1]))    //Data 08 - 03/10 YYYYMMDD
	    If lHomolPaf .And. !lReducao .And. !aTextoImp[nX][7]
	    	cConteudo += StrTran(PadR(aTextoImp[nX][2],25)," ","?")   //Meio de Pagamento 25 - 11/35 X
	    Else 
	    	cConteudo += PadR(aTextoImp[nX][2],25)   //Meio de Pagamento 25 - 11/35 X
	    EndIf
	    cConteudo += aTextoImp[nX][5] //Codigo do Tipo de documento 01 - 36/36 X
	    cConteudo += StrTran(StrZero(aTextoImp[nX][4],13,2),".") + CHR(13) + CHR(10) //Valor 12 - 37/48 N + CRLF    
	    FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	Next nX

	If Len(aTextoImp) > 0
		LJRPLogProc(" Registro A2 cnc [Fim]")
	EndIf
Else
	//Geração do R07
	If Len(MeiPgtRet) > 0
		LJRPLogProc( " Registro R07 cnc [Em execução...]")
	EndIf
	
	For nX := 1 to Len(MeiPgtRet)
		For nY := 1 to Len(MeiPgtRet[nX][5])
			If !Empty(MeiPgtRet[nX][5][nY][6])

				If lHomolPaf .And. MeiPgtRet[nX][5][nY][11]
					lTemIncManu := .T.
				EndIf
				
				cForma := MeiPgtRet[nX][5][nY][9]
				nCntArr := STBRetPDV(MeiPgtRet[nX][5][nY][6])[1][2]
				aRetSLG := STBDatIECF(nCntArr > 0,@aRetSLG,IIF(nCntArr > 0 , aLstPDVs[nCntArr][2], ""))
								
				cConteudo := "R07"	//Tipo
				cConteudo += PadR(MeiPgtRet[nX][5][nY][6],20) //02-Numero de Fabricação
				cConteudo += PadR(aRetSLG[12],1) //03- MF ADICional do ECF
				
				If lHomolPaf .And. !lReducao .And. ;
					(!MeiPgtRet[nX][5][nY][7] .Or. (nCntArr > 0 .And. !LJPRVldLG(aLstPDVs[nCntArr][4],aLstPDVs[nCntArr][2]+aLstPDVs[nCntArr][5])))

					cConteudo += StrTran(PadR(aRetSLG[2],20)," ","?") //04-Modelo do ECF
				Else
					cConteudo += PadR(aRetSLG[2],20) //04-Modelo do ECF
				EndIf
				
				If ValType(aRetSLG[10]) == "N"
					cConteudo += StrZero(aRetSLG[10],2) //05-Numero Usuário do ECF
				Else
					cConteudo += StrZero(Val(aRetSLG[10]),2) //05-Numero Usuário do ECF
				EndIf
				cConteudo += StrZero( MeiPgtRet[nX][5][nY][3] , 9 ) // 06 - COO (Contador de Ordem de Operacao) 
				cConteudo += StrZero( MeiPgtRet[nX][5][nY][4] , 9 ) // 07 - Numero do Contador de Cupom Fiscal relativo ao respectivo Cupom Fiscal emitido
				cConteudo += StrZero( MeiPgtRet[nX][5][nY][5] , 6 ) // 08 - Numero do Contador Geral Não Fiscal relativo ao respectivo Comprovante Não Fiscal emitido
				cConteudo += PadR(cForma,15) // 09 - Descricao do totalizador parcial de meio de pagamento
				cConteudo += StrTran(StrZero( MeiPgtRet[nX][5][nY][2], 14, 2),'.') // 10 - Valor do pagamento efetuado, com duas casas decimais
				
				If MeiPgtRet[nX][5][nY][8] //Cancelado ?
					cConteudo += "S"
					cConteudo += StrTran(StrZero( MeiPgtRet[nX][5][nY][2] , 14, 2),'.',"")
				Else
					cConteudo += "N"
					cConteudo += StrZero(0, 13 )
				EndIf
				
				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
			EndIf
		Next nY
	Next nX	
EndIf

ASize(aTextoImp,0)
ASize(MeiPgtRet,0)

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstRedZ   ³ Autor ³ Venda Clientes        ³ Data ³18/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Lista os dados de reducoes Z de um PDV                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±³          ³ ExpC3 - Numero do PDV                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com dados das reducoes Z efetuadas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstRedZ ( nHdlArq,dDataIni,dDataFim,cPDV,lHomolPaf,lTemIncManu ) 
Local nPos		:= 0
Local cAlias	:= "SFITMP"
Local cPafMd5	:= ""
Local cQuery	:= ""
Local cIndex	:= ""
Local cChave	:= ""
Local cCond		:= ""
Local cRet		:= ""               
Local nCont     := 1
Local nValISS		:= 0
Local nPosImp		:= 0
Local aAux      	:= {} 
Local nTotOpNFis	:= 0 					//totaliza operação não fiscal                   
Local lUsaMdz		:= .F.					//sinaliza que possui a tabela MDZ
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local nTotalValid	:= 0
Local lAlterado		:= .F.
Local lTrataISS		:= .F.
Local aAreaSX3		:= {}
Local RedZRet		:= {}
Local cConteudo		:= ""
Local lTemPDV		:= .F.
Local aRetSLG		:= Array(12)

//************************************************************************************************/
// 								NOTA SOBRE O CONTEUDO DAS INFORMAÇÕES DA SFI
//
// 1 -	o campo FI_CANCEL é preenchido de acordo com o modelo do ECF, existem ECFs que mandam 
//		somente os valores de cancelamento de ICMS mas outras somam ICMS + ISS
// 2 - o campo FI_DESC também depende do modelo, alguns modelos mandam desconto de ICMS 
//		e outras mandam desconto de ISS + ICMS
//-> Portanto se no processo de homologação houver alguma diferença nos valores acumulados, 
//utilizar FI_CANCEL-FI_CANISS e FI_DESC-FI_DESISS
//
//-> os campos FI_DESISS e FI_CANISS sao criados pelo UPDLOJ72 e utilizados para o sistema em geral
//************************************************************************************************/
lUsaMdz	:= AliasInDic( "MDZ" )
cPDV := AllTrim(cPDV)

aAreaSX3 := SX3->(GetArea())
SX3->(DbSetOrder(1))
SX3->(DbSeek("SFI"))
While SX3->(!Eof()) .And. AllTrim(SX3->X3_ARQUIVO) == "SFI"
	If SubStr(SX3->X3_CAMPO,1,6) == "FI_BIS"
		lTrataISS	:= .T.
		Exit
	EndIf
	SX3->(DbSkip())
End

RestArea(aAreaSX3)

DbSelectArea("SFI")

If lHomolPaf
	/*
	SFI->(DbSeek(xFilial("SFI")+DtoS(dDataIni),.T.))
	SFI->(DbGoTop())
	While !SFI->(Eof())
	RecLock("SFI",.F.)
	REPLACE SFI->FI_MD5TRIB WITH STxPafMd5("SFI","","2")
	Conout("SFI MD5TRIB T")
	SFI->(MsUnlock())
	SFI->(DbSkip())
	End

	SFI->(DbSeek(xFilial("SFI")+DtoS(dDataIni),.T.))
	*/
EndIf


If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery := " SELECT  "
cQuery += " R_E_C_N_O_ NumReg, D_E_L_E_T_ Deleted, SFI.*"
cQuery += " FROM " + RetSqlName("SFI") + " SFI"
cQuery += " WHERE FI_FILIAL = '" + xFilial('SFI') + "'"

If !Empty(cPDV)
	cCond += " AND FI_PDV ='" + cPDV + "'"
EndIf

cQuery += " AND FI_DTREDZ >= '" + Dtos(dDataIni) + "' AND FI_DTREDZ <= '" + Dtos(dDataFim) + "'"

cQuery := ChangeQuery( cQuery )
DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"FI_DTREDZ","D")
TcSetField(cAlias,"FI_DTMOVTO","D")
(cAlias)->(DbGoTop())

While !(cAlias)->(Eof())

    AAdd(RedZRet,Array(15))
	nPos := Len(RedZRet)
	RedZRet[nPos][1]	:= AllTrim((cAlias)->FI_SERPDV)
	RedZRet[nPos][2]	:= Val((cAlias)->FI_NUMREDZ)
	RedZRet[nPos][3]	:= Val((cAlias)->FI_COO)
	RedZRet[nPos][4]	:= Val((cAlias)->FI_CRO)
	RedZRet[nPos][5]	:= (cAlias)->FI_DTMOVTO
	
	nValISS := (cAlias)->(FI_DESISS+FI_CANISS)
	
	RedZRet[nPos][6]	:= (cAlias)->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS+nValISS)
	RedZRet[nPos][7]	:= (cAlias)->FI_DTREDZ
	RedZRet[nPos][8]	:= (cAlias)->FI_HRREDZ
	//O campo FI_CANCEL possui o valor referente ao cancelamento em ISS e ICMS
	RedZRet[nPos][9]	:= (cAlias)->(FI_CANCEL)

	//Valor do cancelamento para ISS
	RedZRet[nPos][10]	:= (cAlias)->FI_CANISS

	//Totaliza Operação não fiscal
	nTotOpNFis := 0
	If lUsaMdz
		DbSelectArea("MDZ")
		MDZ->( DbSetOrder(1) )
		MDZ->(DbSeek(xFilial("MDZ")+DtoS((cAlias)->FI_DTMOVTO)))

		While (!MDZ->( EOF() ) ) .AND. (MDZ->MDZ_DATA == (cAlias)->FI_DTMOVTO)
			If MDZ->MDZ_SIMBOL == "CN"  .AND. ;
			( AllTrim(MDZ->MDZ_PDV) == Alltrim(SFI->FI_PDV) ) 
				nTotOpNFis += MDZ->MDZ_VALOR	
			EndIf

			MDZ->(DbSkip())
		End    
	EndIf

	RedZRet[nPos][11] := nTotOpNFis
	RedZRet[nPos][12] := {} //Impostos para geração do R03

	cPafMd5 := STxPafMd5(cAlias)
	
	//Valida chave
	RedZRet[nPos][13] := (cAlias)->FI_PAFMD5 == cPafMd5 .And. WsLeMD5LG(AllTrim((cAlias)->FI_SERPDV))
	
	//Seta inclusão manual
	RedZRet[nPos][14] := .F.
	If Empty(AllTrim((cAlias)->FI_PAFMD5))
		RedZRet[nPos][14] := .T.
	EndIf
	
	//Seta Deleção Manual
	RedZRet[nPos][15] := !Empty(AllTrim((cAlias)->Deleted)) .And. !Empty(AllTrim(SFI->FI_PAFMD5))

	/*Carrega Aliquotas e Valores de Impostos*/
	aAux := aClone( TotalizSFI((cAlias)->NumReg, .T., .T.) )    //Localizada no SPEDXFUN     

	//Com os dados de aAux serão gerados os R03 do arquivo do Menu Fiscal, para teste do bloco VII 
	//alterar o valor de algum campo que compoe este array 		
	If Len(aAux) > 0

		//Valida se houve alteração dos valores no banco para inclusão ou exclusao de dados do R03
		cPafMD5 := STxPafMd5(cAlias,"","2")
		lAlterado:= Empty(AllTrim((cAlias)->FI_MD5TRIB))
		nPosImp := 0

		For nCont := 1 To Len(aAux)
			//O registro Can-T e Can-S já é acumulado em outro registro, aparecia duas vezes no movimento por ECF
			If !( Upper(aAux[nCont][1]) $ Upper("Can-T|Can-S"))
				Aadd( RedZRet[nPos][12] , Array(5))
				nPosImp := Len(RedZRet[nPos][12])

				RedZRet[nPos][12][nPosImp][1] := aAux[nCont][1]  //Codigo do Impostos
				RedZRet[nPos][12][nPosImp][2] := aAux[nCont][2]  //Valor de Base do Imposto 
				
				If SubStr(aAux[nCont][1],1,2) $ "IS|NS|FS"
					RedZRet[nPos][12][nPosImp][3]   := aAux[nCont][1]
										
				ElseIf SubStr(aAux[nCont][1],1,1) $ "T|S" //Código da base de Alíquota
					If lTrataISS
						RedZRet[nPos][12][nPosImp][3]   := aAux[nCont][4]
					ElseIf !lTrataISS .AND. SubStr(aAux[nCont][1],1,1) == "S"
						RedZRet[nPos][12][nPosImp][3]   := aAux[nCont][1]
					Else
						RedZRet[nPos][12][nPosImp][3]   := aAux[nCont][4]
					EndIf
				Else
					RedZRet[nPos][12][nPosImp][3]   := aAux[nCont][1]
				EndIf

				RedZRet[nPos][12][nPosImp][4] := lAlterado
				RedZRet[nPos][12][nPosImp][5] := RedZRet[nPos][13] .And. (cPafMD5 == (cAlias)->FI_MD5TRIB)
				
				//Valido novamente o MD5 do Registro Pai para que ao alterar o MD5 do filho seja evidenciado no pai
				If !RedZRet[nPos][12][nPosImp][5] 
					RedZRet[nPos][13] := .F.
				EndIf
			EndIf	
		Next nCont			
	EndIf

	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

For nPos := 1 to Len(RedZRet)
	If lHomolPaf
		If !lTemIncManu
			lTemIncManu := RedZRet[nPos][14] .Or. RedZRet[nPos][15]
		EndIf
	EndIf

	//Teste Bloco VII - SFI deletada manualmente D_E_L_E_T_ <> '', deve dar um skip
	If RedZRet[nPos][15]
		Loop
	EndIf	

	nCont := STBRetPDV(RedZRet[nPos][1])[1][2]
	aRetSLG := STBDatIECF(nCont > 0,@aRetSLG,IIF(nCont > 0 , aLstPDVs[nCont][2], ""))
	
	cConteudo := "R02"
	cConteudo += PadR(RedZRet[nPos][1],20)	//2 Série do PDV
	cConteudo += PADR( aRetSLG[12] , 01 )	//3 Letra indicativa de MF adicional
	
	If lHomolPaf .And. ( !RedZRet[nPos][13] .Or. ;
						( nCont > 0 .And. !LJPRVldLG(aLstPDVs[nCont][4],aLstPDVs[nCont][2]+aLstPDVs[nCont][5]) ) )
		cConteudo += StrTran(PadR(aRetSLG[2],20)," ","?") // 4 Modelo do ECF
	Else
		cConteudo += PadR(aRetSLG[2],20) 	// 4 Modelo do ECF
	EndIf
	
	If ValType(aRetSLG[10]) == "N"	
		cConteudo +=  StrZero( aRetSLG[10], 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
	Else
		cConteudo +=  StrZero( Val(aRetSLG[10]), 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
	EndIf
	cConteudo +=  StrZero(RedZRet[nPos][2]	, 06 ) 		// 6 No. do Contador de Reducao Z relativo a respectiva reducao
	cConteudo +=  StrZero(RedZRet[nPos][3]	, 09 ) 		// 7 No. do Contador de Ordem de Operacao relativo a respectiva Reducao Z	
	cConteudo +=  StrZero(RedZRet[nPos][4]	, 06 ) 		// 8 No. do Contador de Reinício de Operacao relativo a respectiva Reducao Z
	cConteudo +=  PADR(DtoS(RedZRet[nPos][5]), 08 ) 		// 9 Data das operacoes relativas a respectiva Reducao Z
	cConteudo +=  PADR(DtoS(RedZRet[nPos][7]), 08 ) 		// 10 Data de emissão da Reducao Z
	cConteudo +=  PADR(StrTran(RedZRet[nPos][8],":"), 06 ) 			// 11 Hora de emissão da Reducao Z 
	cConteudo +=  StrTran(StrZero(RedZRet[nPos][6],15,2),'.')	// 12 Valor acumulado no totalizador relativo a respectiva Reducao Z, com 2 decimais
	cConteudo +=  PADR( "N"	, 01 )	// 13 Parametro do ECF para incidencia de desconto sobre itens sujeitos ao ISSQN conforme item 7.2.1.4 (abaixo) *** DEFINIR
	cConteudo += CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	
	If nPos > 30
		LJRPLogProc( " Registro R02 [Em execução...]")
	EndIf
next nPos

For nPos := 1 to Len(RedZRet)
	
	If nPos == 1
		LJRPLogProc(" Registro R03 [Em execução...]")
	EndIf
	
	If lHomolPaf
		If !lTemIncManu
			lTemIncManu :=  RedZRet[nPos][14] .Or. RedZRet[nPos][15]
		EndIf
	EndIf
	
	//SFI deletada manualmente, deve dar um skip
	If RedZRet[nPos][15]
		Loop
	EndIf
	
	nCont := STBRetPDV(RedZRet[nPos][1])[1][2]
	aRetSLG:= STBDatIECF(nCont > 0,@aRetSLG,IIF(nCont > 0 , aLstPDVs[nCont][2], ""))
	
	For nPosImp := 1 to Len(RedZRet[nPos][12])
		
		cRet := ""
		If nCont > 0
			cRet := LJRPTotEcf(aLstPDVs[nCont][6],RedZRet[nPos][12][nPosImp][1])
		EndIF
		
		If Empty(cRet) 
			cRet := "01"
		EndIf
		cRet += RedZRet[nPos][12][nPosImp][1] //NNCXXXX - NN: numero da alíquota no ECF / C - tipo da aliquota, T=ICMS -S=ISS, etc. / XXXX - aliquota , por exemplo T1800
		
		cConteudo := "R03"  //1
		cConteudo += PadR(RedZRet[nPos][1],20)		     // 2 Numero de fabricacao do ECF
		cConteudo += PADR( aRetSLG[12] 	, 01 )		     // 3 Letra indicativa de MF adicional
		
		If lHomolPaf .And. ( RedZRet[nPos][14] .Or.; 
							!(RedZRet[nPos][12][nPosImp][5] .Or. RedZRet[nPos][12][nPosImp][4]) .Or. ;
		 					( nCont > 0 .And. !LJPRVldLG(aLstPDVs[nCont][4],aLstPDVs[nCont][2]+aLstPDVs[nCont][5])))
			cConteudo += StrTran(PADR( aRetSLG[2], 20 )," ","?") 		     // 4 Modelo do ECF
		Else
			cConteudo += PADR( aRetSLG[2] 	, 20 ) 		     // 4 Modelo do ECF
		EndIf
		
		If ValType(aRetSLG[10]) == "N"	
			cConteudo +=  StrZero( aRetSLG[10], 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		Else
			cConteudo +=  StrZero( Val(aRetSLG[10]), 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		EndIf
		cConteudo += StrZero( RedZRet[nPos][2] , 06 ) 		     //6  No. do Contador de Reducao Z relativo a respectiva reducao
		cConteudo +=  PADR( cRet , 07 )                      //7  Codigo do totalizador
		cConteudo += StrTran(StrZero(RedZRet[nPos][12][nPosImp][2], 14, 2), '.')	  //8  Valor acumulado no totalizador
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	Next nPosImp

	If RedZRet[nPos][10] > 0
		cConteudo := "R03"  //1
		cConteudo += Padr(RedZRet[nPos][1],20)		     // 2 Numero de fabricacao do ECF
		cConteudo += PADR( aRetSLG[12] 		, 01 )		     // 3 Letra indicativa de MF adicional
		
		If lHomolPaf .And. ( !RedZRet[nPos][13] .Or. (nCont > 0 .And. !LJPRVldLG(aLstPDVs[nCont][4],aLstPDVs[nCont][2]+aLstPDVs[nCont][5]) )) 
			cConteudo += StrTran(PADR( aRetSLG[2], 20 )," ","?") 		     // 4 Modelo do ECF
		Else
			cConteudo += PADR( aRetSLG[2] 		, 20 ) 		     // 4 Modelo do ECF
		EndIf
		
		If ValType(aRetSLG[10]) == "N"	
			cConteudo +=  StrZero( aRetSLG[10], 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		Else
			cConteudo +=  StrZero( Val(aRetSLG[10]), 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		EndIf
		cConteudo += StrZero( RedZRet[nPos][2]  , 06 ) 		     //6  No. do Contador de Reducao Z relativo a respectiva reducao
		cConteudo += PADR( 'Can-S' , 07 )                                    // Codigo do totalizador
		cConteudo += StrTran(StrZero(RedZRet[nPos][10] , 14, 2), '.')   // Valor acumulado no totalizador
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )		
	EndIf
		 
    If RedZRet[nPos][9] > 0
		cConteudo := "R03"  //1
		cConteudo += Padr(RedZRet[nPos][1],20)		     // 2 Numero de fabricacao do ECF
		cConteudo += PADR( aRetSLG[12] 		, 01 )		     // 3 Letra indicativa de MF adicional

		If lHomolPaf .And. ( !RedZRet[nPos][13] .Or. (nCont > 0 .And. !LJPRVldLG(aLstPDVs[nCont][4],aLstPDVs[nCont][2]+aLstPDVs[nCont][5]) )) 
			cConteudo += StrTran(PADR( aRetSLG[2], 20 )," ","?") 		     // 4 Modelo do ECF
		Else
			cConteudo += PADR( aRetSLG[2], 20 ) 		     // 4 Modelo do ECF
		EndIf

		If ValType(aRetSLG[10]) == "N"	
			cConteudo +=  StrZero( aRetSLG[10], 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		Else
			cConteudo +=  StrZero( Val(aRetSLG[10]), 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		EndIf
		cConteudo += StrZero( RedZRet[nPos][2]  , 06 ) 		     //6  No. do Contador de Reducao Z relativo a respectiva reducao
		cConteudo += PADR( 'Can-T' , 07 )                                    // Codigo do totalizador
		cConteudo += StrTran(StrZero(RedZRet[nPos][9] , 14, 2), '.')   // Valor acumulado no totalizador
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )		
    EndIf
	      
    If RedZRet[nPos][11] > 0
		cConteudo := "R03"  //1
		cConteudo += Padr(RedZRet[nPos][1],20)		     // 2 Numero de fabricacao do ECF
		cConteudo += PADR( aRetSLG[12] 		, 01 )		     // 3 Letra indicativa de MF adicional
		
		If lHomolPaf .And. ( !RedZRet[nPos][13] .Or. (nCont > 0 .And. !LJPRVldLG(aLstPDVs[nCont][4],aLstPDVs[nCont][2]+aLstPDVs[nCont][5])))  
			cConteudo += StrTran(PADR( aRetSLG[2], 20 )," ","?") 		     // 4 Modelo do ECF
		Else
			cConteudo += PADR( aRetSLG[2] , 20 ) 		     // 4 Modelo do ECF
		EndIf

		If ValType(aRetSLG[10]) == "N"	
			cConteudo +=  StrZero( aRetSLG[10], 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		Else
			cConteudo +=  StrZero( Val(aRetSLG[10]), 02 ) // 5 No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		EndIf
		cConteudo += StrZero( RedZRet[nPos][2]  , 06 ) 		     //6  No. do Contador de Reducao Z relativo a respectiva reducao
		cConteudo += PADR( 'OPNF' , 07 ) 	                                 // Codigo do totalizador
		cConteudo += StrTran(StrZero(RedZRet[nPos][11] , 14, 2), '.')   // Valor acumulado no totalizador
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	EndIf
Next nPos

ASize(RedZRet,0)

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstVendas ºAutor  ³Microsiga           º Data ³  06/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista as vendas de um periodo para um PDV                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados das reducoes Z efetuadas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstVendas(	nHdlArq ,dDataIni,dDataFim,cPDV,;
 							lHomolPaf,lTemIncManu,lReducao)
Local cConteudo		:= ""
Local cFilSL1		:= ""
Local cFilSA1		:= ""
Local cSL1			:= ""
Local cSerie		:= ""
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local nPos			:= 0
Local nAcrescimo	:= 0  
Local nX			:= 0
Local nZ			:= 0 
Local nCount		:= 0     
Local lCancelado	:= .F.
Local LstVdas		:= {}
Local aRetSLG		:= {}
Local aAux			:= {}

cFilSL1	:= xFilial("SL1")
cFilSA1	:= xFilial("SA1")

//Para validar a deleção: excluir SL1 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

		DbSelectArea("SL1")
		SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
		SL1->(DbSeek(cFilSL1+DtoS(dDataIni),.T.))
	
		//Valida Deleção Manual
		While !SL1->(Eof()) .AND. SL1->L1_EMISSAO <= dDataFim
			If ( (Empty(cPDV) .AND. !Empty(SL1->L1_PDV) ) .OR.  AllTrim(SL1->L1_PDV) == cPDV ) .And.;
				!Empty(SL1->L1_NUMCFIS) .AND. SL1->L1_FILIAL == cFilSL1 .AND. SL1->(Deleted())
				lTemIncManu := .T.
				Exit
			EndIf
			SL1->(DbSkip())
		EndDo

	SET DELETED ON
EndIf

cSL1	:= "SL1TMP"

If Select(cSL1) > 0
	(cSL1)->(DbCloseArea())
EndIf

cQuery	:= "SELECT L1_FILIAL,L1_EMISSAO,L1_PDV,L1_DOC,L1_VLRTOT,L1_VALBRUT,"
cQuery	+= "L1_NUMCFIS,L1_EMISNF,L1_HORA,L1_DESCONT,L1_VLRLIQ,L1_CONTONF,L1_CONTRG,"   
cQuery	+= "L1_CONTCDC,L1_CONTDOC,L1_DATATEF,L1_HORATEF,L1_SERPDV,L1_STORC,L1_NUMORC,"
cQuery	+= "L1_PAFMD5,L1_COODAV,L1_SERIE,L1_NUM,L1_VALMERC,L1_ESPECIE,L1_TPORC, L1_DTLIM,"
cQuery  += "L1_CLIENTE,A1_NOME,A1_CGC , L1_CGCCLI "
cQuery	+= " FROM " + RetSqlName("SL1") + " SL1 "
cQuery	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery	+= " ON A1_FILIAL='"+cFilSA1+"' AND A1_COD=L1_CLIENTE AND A1_LOJA=L1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= " WHERE "
cQuery	+= " SL1.L1_FILIAL ='" + cFilSL1 + "' "
cQuery	+= " AND SL1.L1_SITUA <> 'FR' "
If !Empty(cPDV)
	cQuery	+= " AND L1_PDV = '" + AllTrim(cPDV) + "' "
EndIf
cQuery	+= " AND (SL1.L1_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"') "  
cQuery	+= " AND SL1.L1_NUMCFIS <> ' ' "
cQuery	+= " AND SL1.L1_ESPECIE <> 'NFM' " //Nota Manual Gerada pela rotina FRTA080 não aparece aqui
CQuery	+= " AND SL1.D_E_L_E_T_ = ' '  "
cQuery	+= " ORDER BY L1_EMISSAO,L1_NUMCFIS"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
TcSetField(cSL1,"L1_EMISSAO","D")
TcSetField(cSL1,"L1_EMISNF","D")
TcSetField(cSL1,"L1_DTLIM","D")
(cSL1)->(DbGoTop())

While !(cSL1)->(Eof())
	
	Aadd(LstVdas,Array(26))
	nPos := Len(LstVdas)
	nCount++
	
	nAcrescimo	:= (cSL1)->L1_VLRTOT - (cSL1)->L1_VALBRUT
	lCancelado	:= ((cSL1)->L1_STORC == "C")
	
	LstVdas[nPos][1] := "R04"
	
	cSerie := Alltrim((cSL1)->L1_SERPDV)
	If Empty(cSerie)
		cSerie := AllTrim(LjPesqPdv((cSL1)->L1_PDV,(cSL1)->L1_SERIE))
	EndIf
	
	nX := STBRetPDV(cSerie)[1][2]
	aRetSLG:= STBDatIECF(nX > 0,@aRetSLG,IIF(nX > 0 , aLstPDVs[nX][2], ""))
	LstVdas[nPos][2] := PADR(aRetSLG[9], 20)// 02 - Série do ECF
	LstVdas[nPos][3] := PADR(aRetSLG[12], 01)// 03 - Letra indicativa de MF adicional	
	LstVdas[nPos][4] := PADR(aRetSLG[2], 20)// 04 - Modelo de ECF
	
	If lHomolPaf .And. !lReducao .And. (nX > 0 .And. !LJPRVldLG(aLstPDVs[nX][4],aLstPDVs[nX][2]+aLstPDVs[nX][5]))
		LstVdas[nPos][4] := StrTran(LstVdas[nPos][4]," ","?")
	EndIf
	
	If ValType(aRetSLG[10]) == "C"
		aRetSLG[10] := Val(aRetSLG[10])
	EndIf
	LstVdas[nPos][5] := StrZero(aRetSLG[10], 2)// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
	LstVdas[nPos][6] := Val((cSL1)->L1_DOC) //Não utilizado
	LstVdas[nPos][7] := Val((cSL1)->L1_NUMCFIS)
	LstVdas[nPos][8] := (cSL1)->L1_EMISSAO
	LstVdas[nPos][9] := (cSL1)->L1_HORA
	LstVdas[nPos][10] := (cSL1)->L1_VALMERC //(cSL1)->L1_VALBRUT
	LstVdas[nPos][11] := (cSL1)->L1_DESCONT
	LstVdas[nPos][12] := nAcrescimo
	LstVdas[nPos][13] := IIf((cSL1)->L1_DESCONT > 0, "V", " ")
	LstVdas[nPos][14] := IIf(nAcrescimo > 0, "V" , " ")
	LstVdas[nPos][15] := (cSL1)->L1_VLRLIQ
	LstVdas[nPos][16] := lCancelado	//Indicador de Cancelamento
	LstVdas[nPos][17] := If( lCancelado , nAcrescimo , 0 ) //Indicador de cancelamento do acrescimo 
	LstVdas[nPos][18] := IIf(nAcrescimo > 0, "A" , IIf((cSL1)->L1_DESCONT > 0, "D", " "))
	LstVdas[nPos][19] := AllTrim((cSL1)->A1_NOME)
	LstVdas[nPos][20] := AllTrim(StrTran(StrTran(StrTran((cSL1)->L1_CGCCLI,"."),"-"),"/"))
	LstVdas[nPos][21] := Val((cSL1)->L1_CONTONF) 	//16
	LstVdas[nPos][22] := Val((cSL1)->L1_CONTRG ) 	//17
	LstVdas[nPos][23] := Val((cSL1)->L1_CONTCDC) 	//18
	LstVdas[nPos][24] := Val((cSL1)->L1_CONTDOC) 	//19
	LstVdas[nPos][25] := (cSL1)->L1_DATATEF     	//20
	LstVdas[nPos][26] := (cSL1)->L1_HORATEF	  	//21	    

	If lHomolPaf
		/* Gera/Valida chave MD5 dos Registros */
		cPafMd5 := STxPafMd5(cSL1)
		
		/*
		//Trecho para que caso necessario atualize o MD-5
		If lHomolPaf
			DbSelectArea("SL1")
			SL1->(DbSetOrder(1))
			SL1->(MsSeek(cFilSL1+(cSL1)->L1_NUM))
		
			RecLock("SL1",.F.)
			REPLACE SL1->L1_PAFMD5 WITH cPafMd5
			SL1->(MsUnlock())
		EndIf
		*/
			
		If !( ((cSL1)->L1_PAFMD5 == cPafMd5 ) .And. WsLeMD5LG(LstVdas[nPos][2]) )
			LstVdas[nPos][4] := StrTran(LstVdas[nPos][4]," ","?") //4-Modelo do ECF
		EndIf
		
		//************************************************************************************
		//Valida Inclusão/Deleção do registro via Banco de Dados, L1_PAFMD5 em branco - Teste Bloco VII
		//************************************************************************************
		If Empty(AllTrim((cSL1)->L1_PAFMD5))
			lTemIncManu := .T.
		EndIf
	EndIf

	aAux := STBFMTipoDoc( LstVdas , .T. , nPos)
	For nZ := 1 To Len( aAux )
		aAdd(aResultR06, Array(12))
		nPosR06 := Len(aResultR06)
		aResultR06[nPosR06][01] :=  "R06"
		aResultR06[nPosR06][02] :=  PadR(LstVdas[nPos][2],20) 
		aResultR06[nPosR06][03] :=  PadR(aRetSLG[12],1)	   										// 03 - Letra indicativa de MF adicional
		aResultR06[nPosR06][04] :=  PadR(AllTrim(aRetSLG[2]),20)								// 04 - Modelo de ECF
		
		If lHomolPaf .And. nX > 0 .And. !LJPRVldLG(aLstPDVs[nX][4],aLstPDVs[nX][2]+aLstPDVs[nX][5])
			aResultR06[nPosR06][4] := StrTran(aResultR06[nPosR06][4]," ","?")
		EndIf
		
		If ValType(aRetSLG[10]) == "C" 
			aRetSLG[10] := Val(aRetSLG[10]) 									
		EndIf
		aResultR06[nPosR06][5]	:=  StrZero(aRetSLG[10],2)										// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		aResultR06[nPosR06][06] :=  StrZero(LstVdas[nPos][7],9)									// 06 - COO (Contador de Ordem de Operacao)
		aResultR06[nPosR06][07] :=  StrZero(aAux[nZ][1]	, 06 )									// 07 - Número do GNF relativo ao respectivo documento, quando houver
		aResultR06[nPosR06][08] :=  StrZero(aAux[nZ][2] , 06 )									// 08 - Número do GRG relativo ao respectivo documento (vide item 7.6.1.2)
		aResultR06[nPosR06][09] :=  StrZero(aAux[nZ][3]	, 04 )  								// 09 - Número do CDC relativo ao respectivo documento (vide item 7.6.1.3)
		aResultR06[nPosR06][10] :=  PADR( aAux[nZ][4]  	, 02 ) 	  								// 10 - Símbolo referente à denominação do documento fiscal, conforme tabela abaixo
		aResultR06[nPosR06][11] :=  PADR( aAux[nZ][5]  	, 08 ) 	  								// 11 - Data final de emissão (impressa no rodape do documento)
		aResultR06[nPosR06][12] :=  PADR( StrTran(aAux[nZ][6] , ":") , 06, "0" )   				// 12 - Hora final de emissão (impressa no rodape do documento)					
	Next nZ

	//Construção do Arquivo - R04
	cConteudo := LstVdas[nPos][1] // 01 - Tipo
	cConteudo += LstVdas[nPos][2] // 02 - Série do ECF
	cConteudo += LstVdas[nPos][3] // 03 - Letra indicativa de MF adicional
	cConteudo += LstVdas[nPos][4] // 04 - Modelo do ECF
	cConteudo += LstVdas[nPos][5] // 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
	cConteudo += StrZero(LstVdas[nPos][24],9) 			// 06 - CCF, CVC ou CBP, conforme o documento
	cConteudo += StrZero(LstVdas[nPos][7], 9) 			// 07 - COO (Contador de Ordem de Operacao)
	cConteudo += PADR(DtoS(LstVdas[nPos][8]), 8 )	   		// 08 - Data de inicio da emissao
	cConteudo += StrTran(StrZero(LstVdas[nPos][10],15,2),'.')	// 09 - Subtotal do Documento
	cConteudo += StrTran(StrZero(LstVdas[nPos][11],14,2),'.')	// 10 - Desconto sobre subtotal 
	cConteudo += PadR(LstVdas[nPos][13], 01)	   				// 11 - Indicador do Tipo de Desconto sobre subtotal
	cConteudo += StrTran(StrZero(LstVdas[nPos][12],14,2),'.')	// 12 - Acrescimo sobre subtotal 
	cConteudo += PadR(LstVdas[nPos][14],01)	   				// 13 - Indicador do Tipo de Acrescimo sobre subtotal
	cConteudo += StrTran(StrZero(LstVdas[nPos][15],15,2),'.') ///14 - Valor Total Liquido			
	cConteudo += IIF(LstVdas[nPos][16],"S","N")	     // 15 - Indicador de Cancelamento 
	cConteudo += StrTran(StrZero(LstVdas[nPos][17],14,2),'.')		//16 - Cancelamento de Acrescimo no Subtotal 
	cConteudo += PadR(LstVdas[nPos][18],01)				// 17 - Ordem de aplicacao de Desconto e Acrescimo 
	cConteudo += PadR(LstVdas[nPos][19], 40)				// 18 - Nome do adquirente
	cConteudo += StrZero(Val(LstVdas[nPos][20]),14)			// 19 - CPF/CNPJ do adquirente
	cConteudo += CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )	
	aSize(LstVdas,0)
	
	If nCount > 30
		LJRPLogProc( "- [Em Execução] Incluindo Registros R04")
		nCount := 0
	EndIf
	
	(cSL1)->(DbSkip())
End

(cSL1)->(DbCloseArea())

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstVndCanc ºAutor  ³Microsiga           º Data ³  06/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista as vendas de um periodo para um PDV                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados das reducoes Z efetuadas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstVndCanc (nHdlArq		, dDataIni		, dDataFim	, cPDV	,;
							lHomolPaf	, lTemIncManu	, lReducao	)
Local nPos			:= 0
Local nIndex		:= 0
Local nX			:= 0
Local nZ			:= 0
Local nCount		:= 0
Local cSL1			:= ""
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local cNumCup		:= ""
Local lIncManual	:= .F.
Local lDadoCli		:= .F.
Local lLX_CONTDOC	:= .F.
Local cSerPDV		:= ""
Local cNomeCli		:= SuperGetMV('MV_CLIPAD')
Local cFilSL1		:= xFilial("SL1")
Local cSerL1LX		:= ""
Local cPDVL1LX		:= ""
Local LstVdas		:= {}
Local aRetSLG		:= {}
Local aAreaSL1		:= {}
Local aAux			:= {}

DbSelectArea("SLX")
lLX_CONTDOC := .T.

DbSelectArea("SL1")
aAreaSL1 := SL1->(GetArea())
SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM

cSL1 := "SLXTMP"
If Select(cSL1) > 0
	(cSL1)->(DbCloseArea())
EndIf

cQuery	:= " SELECT "
cQuery	+= " SLX.* , "
cQuery	+= " SL4.L4_NUM "
cQuery	+= " FROM " + RetSqlName("SLX") + " SLX "
cQuery	+= " LEFT JOIN " + RetSqlName("SL4") + " SL4 "
cQuery	+= " ON SL4.L4_FILIAL = SLX.LX_FILIAL AND SL4.L4_DOC = SLX.LX_CUPOM "
cQuery	+= " WHERE "
cQuery	+= " SLX.LX_FILIAL='"+xFilial('SLX')+"' "
cQuery	+= " AND SLX.LX_TPCANC <> 'D' AND SLX.LX_TPCANC <> 'I' " //D = Devolucao/I = Item -> não devem aparecer na pesquisa

If !Empty(cPDV)
	cQuery	+= " AND SLX.LX_PDV = '" + cPDV + "' "
EndIf

cQuery	+= " AND SLX.LX_DTMOVTO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
cQuery	+= " AND SLX.D_E_L_E_T_ = ' '  "
cQuery	+= " ORDER BY LX_DTMOVTO,LX_CUPOM "

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
TcSetField(cSL1,"LX_DTMOVTO","D")
(cSL1)->(DbGoTop())	
cNumCup := (cSL1)->LX_CUPOM

//Liga os deletados, pois se houver o SL1 da venda, ele foi apagado
SET DELETED OFF

While !(cSL1)->(Eof())

	nPos := Ascan(LstVdas, {|a| a[7] == Val(AllTrim(cNumCup))})

	If cNumCup == (cSL1)->LX_CUPOM .And. (nPos > 0)
		LstVdas[nPos][10] += (cSL1)->LX_VALOR
		LstVdas[nPos][15] += (cSL1)->LX_VALOR
	Else
		Aadd(LstVdas,Array(28))
		nPos := Len(LstVdas)
		nCount++
				
		LstVdas[nPos][1] := "R04"
		
		If !Empty(AllTrim((cSL1)->L4_NUM))
			SL1->(DbSeek(cFilSL1+SL4->L4_NUM))
			cSerPDV := Alltrim(SL1->L1_SERPDV)
			If Empty(cSerPDV)
				cPDVL1LX := AllTrim(SL1->L1_PDV)
				If Empty(cPDVL1LX)
					cPDVL1LX := AllTrim((cSL1)->LX_PDV)
				EndIf 
				
				cSerL1LX := AllTrim(SL1->L1_SERIE)
				If Empty(cSerL1LX)
					cSerL1LX := AllTrim((cSL1)->LX_SERIE)
				EndIf
				
				cSerPDV := AllTrim(LjPesqPdv(cPDVL1LX,cSerL1LX))
			EndIf		
		Else
			cSerPDV := AllTrim(LjPesqPdv((cSL1)->LX_PDV,(cSL1)->LX_SERIE))
		EndIf
		
		nX := STBRetPDV(cSerPDV)[1][2]
		STBDatIECF(nX > 0,@aRetSLG,IIF(nX > 0 , aLstPDVs[nX][2], ""))
		LstVdas[nPos][2] := PADR(aRetSLG[9], 20)// 02 - Série do ECF
		LstVdas[nPos][3] := PADR(aRetSLG[12], 01)// 03 - Letra indicativa de MF adicional
		LstVdas[nPos][4] := PADR(aRetSLG[2], 20)// 04 - Modelo de ECF
		If ValType(aRetSLG[10]) == "C"
			aRetSLG[10] := Val(aRetSLG[10])
		EndIf
		LstVdas[nPos][5] := StrZero(aRetSLG[10], 2)// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		LstVdas[nPos][6] := Val((cSL1)->LX_CUPOM) //Não utilizado
		LstVdas[nPos][7] := Val((cSL1)->LX_CUPOM)
		LstVdas[nPos][8] := (cSL1)->LX_DTMOVTO
		LstVdas[nPos][9] := (cSL1)->LX_HORA     			
		LstVdas[nPos][10] := (cSL1)->LX_VALOR
		LstVdas[nPos][11] := 0
		LstVdas[nPos][12] := 0
		LstVdas[nPos][13] := " "
		LstVdas[nPos][14] := " "
		LstVdas[nPos][15] := (cSL1)->LX_VALOR
		LstVdas[nPos][16] := .T.	//Indicador de Cancelamento
		LstVdas[nPos][17] := 0 //Indicador de cancelamento do acrescimo 
		LstVdas[nPos][18] := " "
		LstVdas[nPos][19] := cNomeCli
		LstVdas[nPos][20] := " "

		If !Empty(AllTrim((cSL1)->L4_NUM))
			//Pesquisa SL1
			LstVdas[nPos][21] := Val(SL1->L1_CONTONF) 	//16
			LstVdas[nPos][22] := Val(SL1->L1_CONTRG ) 	//17
			LstVdas[nPos][23] := Val(SL1->L1_CONTCDC) 	//18
			LstVdas[nPos][25] := SL1->L1_DATATEF     	//20
			LstVdas[nPos][26] := SL1->L1_HORATEF	  	//21
		Else
			LstVdas[nPos][21] := 0 	//16
			LstVdas[nPos][22] := 0 	//17
			LstVdas[nPos][23] := 0 	//18
			LstVdas[nPos][25] := ''	//20
			LstVdas[nPos][26] := '' //21
		EndIf

		If lLX_CONTDOC
			LstVdas[nPos][24] := Val((cSL1)->LX_CONTDOC)
		Else
			LstVdas[nPos][24] := Val((cSL1)->LX_CUPOM)
		EndIf

		LstVdas[nPos][27]	:= .F.
		LstVdas[nPos][28]	:= .T.
		
		aAux := STBFMTipoDoc( LstVdas , .T. , nPos)
		For nZ := 1 To Len( aAux )
			aAdd(aResultR06, Array(12))
			nPosR06 := Len(aResultR06)
			aResultR06[nPosR06][01] :=  "R06"
			aResultR06[nPosR06][02] :=  PadR(LstVdas[nPos][22],20) 
			aResultR06[nPosR06][03] :=  PadR(aRetSLG[12],1)	   								// 03 - Letra indicativa de MF adicional
			aResultR06[nPosR06][04] :=  PadR(AllTrim(aRetSLG[2]),20)									// 04 - Modelo do ECF
			If lHomolPaf .And. !LJPRVldLG(aLstPDVs[nX][4],aLstPDVs[nX][2]+aLstPDVs[nX][5])
				aResultR06[nPosR06][4] := StrTran(aResultR06[nPosR06][4]," ","?")
			EndIF
			
			If ValType(aRetSLG[10]) == "C"
				aRetSLG[10] := Val(aRetSLG[10])
			EndIf
			aResultR06[nPosR06][5]	:= StrZero(aRetSLG[10],2)										// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
			aResultR06[nPosR06][06] :=  StrZero(LstVdas[nPos][7],9)									// 06 - COO (Contador de Ordem de Operacao)
			aResultR06[nPosR06][07] :=  StrZero(aAux[nZ][1]	, 06 )									// 07 - Número do GNF relativo ao respectivo documento, quando houver
			aResultR06[nPosR06][08] :=  StrZero(aAux[nZ][2] , 06 )									// 08 - Número do GRG relativo ao respectivo documento (vide item 7.6.1.2)
			aResultR06[nPosR06][09] :=  StrZero(aAux[nZ][3]	, 04 )  								// 09 - Número do CDC relativo ao respectivo documento (vide item 7.6.1.3)
			aResultR06[nPosR06][10] :=  PADR( aAux[nZ][4]  	, 02 ) 	  								// 10 - Símbolo referente à denominação do documento fiscal, conforme tabela abaixo
			aResultR06[nPosR06][11] :=  PADR( aAux[nZ][5]  	, 08 ) 	  								// 11 - Data final de emissão (impressa no rodape do documento)
			aResultR06[nPosR06][12] :=  PADR( StrTran(aAux[nZ][6] , ":") , 06, "0" )   				// 12 - Hora final de emissão (impressa no rodape do documento)					
		Next nZ
	EndIf
	(cSL1)->(DbSkip())
	cNumCup := (cSL1)->LX_CUPOM
	
	If nCount > 30
		LJRPLogProc("- [Em Execução] Incluindo Registros R04")
		nCount := 0
	EndIf
EndDo

//Desliga a visão dos deletados
SET DELETED ON

For nPos := 1 to Len(LstVdas)
	//Construção do Arquivo - R04
	cConteudo := LstVdas[nPos][1] // 01 - Tipo	
	cConteudo += LstVdas[nPos][2] //02 - Série do ECF
	cConteudo += LstVdas[nPos][3] // 03 - Letra indicativa de MF adicional
	cConteudo += LstVdas[nPos][4] // 04 - Modelo do ECF
	cConteudo += LstVdas[nPos][5] // 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
	cConteudo += StrZero(LstVdas[nPos][24],9) 			// 06 - CCF, CVC ou CBP, conforme o documento
	cConteudo += StrZero(LstVdas[nPos][7], 9) 			// 07 - COO (Contador de Ordem de Operacao)
	cConteudo += PADR(DtoS(LstVdas[nPos][8]), 8 )	   		// 08 - Data de inicio da emissao
	cConteudo += StrTran(StrZero(LstVdas[nPos][10],15,2),'.')	// 09 - Subtotal do Documento
	cConteudo += StrTran(StrZero(LstVdas[nPos][11],14,2),'.')	// 10 - Desconto sobre subtotal 
	cConteudo += PadR(LstVdas[nPos][13], 01)	   				// 11 - Indicador do Tipo de Desconto sobre subtotal
	cConteudo += StrTran(StrZero(LstVdas[nPos][12],14,2),'.')	// 12 - Acrescimo sobre subtotal 
	cConteudo += PadR(LstVdas[nPos][14],01)	   				// 13 - Indicador do Tipo de Acrescimo sobre subtotal
	cConteudo += StrTran(StrZero(LstVdas[nPos][15],15,2),'.') ///14 - Valor Total Liquido			
	cConteudo += IIF(LstVdas[nPos][16],"S","N")	     // 15 - Indicador de Cancelamento 
	cConteudo += StrTran(StrZero(LstVdas[nPos][17],14,2),'.')		//16 - Cancelamento de Acrescimo no Subtotal 
	cConteudo += PadR(LstVdas[nPos][18],01)				// 17 - Ordem de aplicacao de Desconto e Acrescimo 
	cConteudo += PadR(LstVdas[nPos][19], 40)				// 18 - Nome do adquirente
	cConteudo += StrZero(Val(LstVdas[nPos][20]),14)			// 19 - CPF/CNPJ do adquirente
	cConteudo += CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
Next nPos

aSize(LstVdas,0)
RestArea(aAreaSL1)

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstItens  ºAutor  ³Microsiga           º Data ³  03/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista os itens das vendas por periodo para um PDV           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados dos itens vendidos no periodo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstItens (	nHdlArq, dDataIni,dDataFim,cPDV,;
 							lHomolPaf, lTemIncManu,lReducao )
Local nPos			:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nTamPDV		:= 0
Local nIndex		:= 0
Local nContDoc		:= 0
Local nX			:= 0
Local nCount		:= 0
Local cFilSL2		:= ""
Local cSL2			:= ""
Local cPDVLst		:= ""  
Local cTotParc		:= "" 
Local cAux			:= ""
Local cQuery		:= ""
Local cNumOrc		:= ""
Local cConteudo		:= ""
Local cRet			:= ""
Local aAreaSL2		:= {}		//Guarda a area do SL2 para atualizar o MD5 em homologacao
Local LstIt			:= {}
Local aRetSLG		:= {}
Local lNewFields	:= .F.
Local lPreenPad		:= .F.

cFilSL2		:= xFilial("SL2")
cFilSL1		:= xFilial("SL1") 
nQtdDecQuant:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit:= TamSX3("L2_VRUNIT")[2]
nTamPDV		:= TamSX3("L2_PDV")[1]
cPDVLst		:= cPDV + Space(nTamPDV - Len(cPDV))
lNewFields	:= SL2->(ColumnPos("L2_IAT")) > 0 //Valido somente 1 campo pois um UPD cria todos os campos

//Trecho inserido para em caso de necessidade incluir MD5 nos campos
/*If lHomolPaf
	DbSelectArea("SL1")
	DbSelectArea("SL2")
	SL1->(DbSetOrder(1))
	SL2->(DbSetOrder(1))
	
	While !SL2->(Eof())
		SL1->(DbSeek(SL2->L2_FILIAL+SL2->L2_NUM))
		cNumOrc := AllTrim(SL1->L1_NUMORC)
		
		cPafMd5 := STxPafMd5("SL2",cNumOrc)
		
		RecLock("SL2",.F.)
		REPLACE SL2->L2_PAFMD5 WITH cPafMd5
		SL2->(MsUnlock())
		SL2->(DbSkip())
	EndDo
EndIf*/

//Para validar a deleção: excluir SL2 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF
	DbSelectArea("SL1")
	SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
	SL1->(DbSeek(cFilSL1+DtoS(dDataIni),.T.))

	DbSelectArea("SL2")
	SL2->(dbsetorder(1))

	While !SL1->(Eof()) .AND. SL1->L1_FILIAL == cFilSL1 .and.  SL1->L1_EMISSAO <= dDataFim    

		SL2->(DbSeek(cFilSL2 + SL1->L1_NUM))

		While !SL2->(Eof()) .AND. SL2->(L2_FILIAL+L2_NUM) == SL1->(L1_FILIAL+L1_NUM) .AND.;
		  ( Empty(cPDVLst) .OR.  AllTrim(SL2->L2_PDV) == AllTrim(cPDVLst) )
		   
			If !Empty(SL2->L2_DOC)  .AND. SL2->(deleted())
				lTemIncManu:= .T.
				Exit	
			EndIf
			SL2->(DbSkip())
		EndDo 

		SL1->(DbSkip())
	EndDo
	SET DELETED ON
EndIf

cSL2	:= "SL2TMP"

If Select(cSL2) > 0
	(cSL2)->(DbCloseArea())
EndIf

cQuery	:= "SELECT L2_FILIAL,L2_EMISSAO,L2_PDV,L2_DOC,L2_DESCRI,L2_QUANT,L2_SERIE, "
cQuery	+= "L2_VENDIDO,L2_CONTDOC,L2_SERPDV,L2_SITTRIB,L2_PAFMD5,L2_VRUNIT, "
cQuery	+= "L2_UM,L2_PRCTAB,L2_VALDESC,L2_VLRITEM,L2_ITEM,L2_PRODUTO,L2_DESC,L2_NUM,L2_TES,"

If lNewFields
	cQuery	+= " L2_IAT,L2_IPPT,L2_DECVLU,L2_DECQTD,"
EndIf

cQuery	+= "L1_CONTDOC,L1_NUMORC,L1_SERPDV,L1_ESPECIE,L1_NUMCFIS "	
cQuery	+= "FROM " + RetSqlName("SL2") + " SL2 "      
cQuery	+= "INNER JOIN " + RetSqlName("SL1") + " SL1 "

/*
" AND L2_PDV=L1_PDV " - não inserir essa condição senão 
os registros de nota não aparecem, uma vez que estes não tem o 
campo _PDV preenchido
*/

cQuery	+= "ON L2_FILIAL=L1_FILIAL AND L2_DOC=L1_DOC "	
cQuery	+= " WHERE "
cQuery	+= " SL2.L2_FILIAL = '" + cFilSL2 + "'"

If !Empty(cPDV)
	cQuery	+= 	" AND SL2.L2_PDV = '" + cPDVLst + "' " 
EndIf

cQuery	+= "AND SL2.L2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "	  
cQuery	+= "AND SL2.L2_DOC <> ' ' "

/*Não mostra o Registro gerado pela rotina de contigencia(FRTA080)*/
cQuery	+= " AND SL1.L1_ESPECIE <> 'NFM' "

cQuery	+= " AND SL2.D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY L2_EMISSAO,L2_DOC,L2_ITEM"	

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL2, .F., .T.)
TcSetField(cSL2,"L2_EMISSAO","D")	
(cSL2)->(DbGoTop())

While !(cSL2)->(Eof()) 

	cTotParc := ""
	nContDoc := Val((cSL2)->L1_CONTDOC)

	If !Empty(AllTrim((cSL2)->L2_SITTRIB))
		cTotParc	:=	AllTrim((cSL2)->L2_SITTRIB)
	EndIf

	cNumOrc := (cSL2)->L1_NUMORC
	AAdd(LstIt,Array(25))
	nPos := Len(LstIt)
	nCount++
	
	LstIt[nPos][1]		:= Val((cSL2)->L2_DOC)
	
	If AllTrim((cSL2)->L1_ESPECIE) == "NFCF" //Quando nota+cf o numero do cupom esta no campo L1_NUMCFIS
		LstIt[nPos][2]	:= Val((cSL2)->L1_NUMCFIS)
	Else
		LstIt[nPos][2]	:= Val((cSL2)->L2_DOC)
	EndIf
	LstIt[nPos][3]		:= Val((cSL2)->L2_ITEM)
	LstIt[nPos][4]		:= (cSL2)->L2_PRODUTO
	LstIt[nPos][5]		:= (cSL2)->L2_DESCRI
	LstIt[nPos][6]		:= (cSL2)->L2_QUANT * &("1" + Replicate("0",nQtdDecQuant))
	LstIt[nPos][7]		:= (cSL2)->L2_UM
	LstIt[nPos][8]		:= (cSL2)->L2_PRCTAB * &("1" + Replicate("0",nQtdDecVUnit))
	LstIt[nPos][9]		:= (cSL2)->L2_VALDESC
	LstIt[nPos][10]		:= 0
	LstIt[nPos][11]		:= (cSL2)->L2_VLRITEM
	LstIt[nPos][12]		:= StrTran(StrTran(cTotParc,","),".")
	LstIt[nPos][13]		:= IIF((cSL2)->L2_VENDIDO == "N","S","N")
	LstIt[nPos][14]		:= 0
	LstIt[nPos][15]		:= 0
	LstIt[nPos][16]		:= 0
	
	lPreenPad := .F.
	
	If lNewFields		
		LstIt[nPos][17]	:= (cSL2)->L2_IAT
		LstIt[nPos][18]	:= (cSL2)->L2_IPPT
		LstIt[nPos][19]	:= (cSL2)->L2_DECQTD
		LstIt[nPos][20]	:= (cSL2)->L2_DECVLU
	Else
		LstIt[nPos][17]	:= IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
		LstIt[nPos][18]	:= ""
		LstIt[nPos][19]	:= 2
		LstIt[nPos][20]	:= 2
		lPreenPad := .T.
	EndIf
	
	If !lHomolPaf
		/* Caso os campos estejam em branco no banco, 
		não pode gerar o registro do PAF com eles em branco*/ 
		If Empty( AllTrim(LstIt[nPos][17] ))
			LstIt[nPos][17]	:= IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
		EndIf
		
		If Empty( AllTrim(LstIt[nPos][18])) 
			LstIt[nPos][18] := "T"
		EndIf
		
		If LstIt[nPos][19] == 0
			LstIt[nPos][19]	:= nQtdDecQuant
		EndIf
		
		If LstIt[nPos][20] == 0
			LstIt[nPos][20]	:= nQtdDecVUnit
		EndIf
	ElseIf lPreenPad
		LjGrvLog( Nil, " Homologação PAF-ECF *** Ajuste os campos: L2_ e B1_ - IPPT , IAT / L2_DECQTD / L2_DECVLU")
		Conout("Homologação PAF-ECF *** Ajuste os campos: L2_ e B1_ - IPPT , IAT / L2_DECQTD / L2_DECVLU")
	EndIf
	
	LstIt[nPos][21]	:= IIF(Val((cSL2)->L2_CONTDOC) == 0 , nContDoc, Val((cSL2)->L2_CONTDOC)) 
	LstIt[nPos][22]	:= (cSL2)->L2_SERPDV
	If Empty(LstIt[nPos][22])
		LstIt[nPos][22] := (cSL2)->L1_SERPDV
		
		If Empty(Alltrim(LstIt[nPos][22]))
			LstIt[nPos][22]		:= LjPesqPdv((cSL2)->L2_PDV,(cSL2)->L2_SERIE)
		EndIf
	EndIf

	LstIt[nPos][23]	:= StrTran(StrTran((cSL2)->L2_SITTRIB,","),".")
	LstIt[nPos][24]	:=  .T.
	
	If lHomolPaf
		//Gera Chave MD5 dos dados armazenados    
		cPafMd5 := STxPafMd5(cSL2, cNumOrc) 
		
		/*If lHomolPaf
			aAreaSL2 := GetArea(cSL2)
			DbSelectArea("SL2")
			SL2->(DbSetOrder(1))
			SL2->(DbSeek(cFilSL2+(cSL2)->L2_NUM))
		
			RecLock("SL2",.F.)
			REPLACE SL2->L2_PAFMD5 WITH cPafMd5
			SL2->(MsUnlock())
			RestArea(aAreaSL2)
		EndIf*/
	
		//Valida chave
		LstIt[nPos][24]	:= ( (cSL2)->L2_PAFMD5 == cPafMd5 ) .And. WsLeMD5LG(LstIt[nPos][22])
	
		/*Valida Inclusão do registro via Banco de Dados, L2_PAFMD5 em branco
		Associar o L2_NUM a um SL1 valido - Teste Bloco VII */
		If Empty(AllTrim((cSL2)->L2_PAFMD5))
			lTemIncManu := .T.
		EndIf
	EndIf
 	
 	nX := STBRetPDV(LstIt[nPos][22])[1][2]
	aRetSLG:= STBDatIECF(nX > 0,@aRetSLG,IIF(nX > 0 , aLstPDVs[nX][2], ""))

	cConteudo := "R05"								// 01 - Tipo
 	cConteudo += PADR( LstIt[nPos][22], 20 ) 		// 02 - Numero de fabricacao do ECF 	
	cConteudo +=  PADR(aRetSLG[12], 01)	   			// 03 - Letra indicativa de MF adicional				
	
	If lHomolPaf .And. !lReducao .And. ( !LstIt[nPos][24] .Or. ( nX > 0 .And. !LJPRVldLG(aLstPDVs[nX][4],aLstPDVs[nX][2]+aLstPDVs[nX][5]) ) )
		cConteudo += StrTran(PadR(aRetSLG[2],20)," ","?") // 04 - Modelo do ECF
	Else
		cConteudo += PadR(aRetSLG[2],20)				// 04 - Modelo do ECF
	EndIf
	
	If ValType(aRetSLG[10]) == 'N'
		cConteudo += StrZero(aRetSLG[10],2)			// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
	Else
		cConteudo += StrZero(Val(aRetSLG[10]),2)
	EndIf 			
	cConteudo += StrZero(LstIt[nPos][2],09 )				// 06 - COO (Contador de Ordem de Operacao) 
	cConteudo += StrZero(LstIt[nPos][21],09 )				// 07 - CCF, CVC ou CBP, conforme o documento
	cConteudo += StrZero(LstIt[nPos][3],03 )				// 08 - Numero do item
	cConteudo += PADR( LstIt[nPos][4],14 )				// 09 - Codigo do Produto ou Servico
	cConteudo += PADR( LstIt[nPos][5],100)				// 10 - Descricao
	cConteudo += StrZero(LstIt[nPos][6],07 )				// 11 - Quantidade
	cConteudo += PADR( LstIt[nPos][7],03 )				// 12 - Unidade
	cConteudo += StrZero(LstIt[nPos][8]	,08 )				// 13 - Valor unitario
	cConteudo += StrTran(StrTran(StrZero(LstIt[nPos][9],9,2),'-','0'),'.')	// 14 - Desconto sobre item 
	cConteudo += StrTran(StrTran(StrZero(LstIt[nPos][10],9,2),'-','0'),'.')	// 15 - Acrescimo sobre item 
	cConteudo += StrTran(StrTran(StrZero(LstIt[nPos][11],15,2),'-','0'),'.')		// 16 - Valor total liquido
	
	cRet := ""
	If nX > 0	
		cRet := LJRPTotEcf( aLstPDVs[nX][6],LstIt[nPos][12])
	EndIf
	
	If Empty(cRet)
		cRet := "01"
	EndIf
	cRet += LstIt[nPos][12] //NNCXXXX - NN: numero da alíquota no ECF / C - tipo da aliquota, T=ICMS -S=ISS, etc. / XXXX - aliquota , por exemplo T1800

	cConteudo += PADR( cRet,07 )				// 17 - Totalizador parcial
	cConteudo += LstIt[nPos][13]		// 18 - Indicador de cancelamento 
	cConteudo += StrZero(LstIt[nPos][14],07 )				// 19 - Quantidade cancelada
	cConteudo += StrTran(StrZero(LstIt[nPos][15],14,2),'.')	// 20 - Valor cancelado
	cConteudo += StrTran(StrZero(LstIt[nPos][16],14,2),'.')	// 21 - Cancelamento de acrescimo no item 
	cConteudo += PADR(LstIt[nPos][17],01 )	   			// 22 - Indicador de Arredondamento ou Truncamento(IAT) 
	cConteudo += PADR(LstIt[nPos][18],01 )	   			// 23 - Indicador de Producao Propria ou de Terceiro(IPPT) 
	cConteudo += StrZero(LstIt[nPos][19],01 )				// 24 - Casas decimais da quantidade
	cConteudo += StrZero(LstIt[nPos][20],01 )				// 25 - Casas decimais de valor unitario
	cConteudo += CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	ASize(LstIt,0)
	
	If nCount > 40
		LJRPLogProc("- [Em Execução] Incluindo Registros R05")
		nCount := 0
	EndIf
	
	(cSL2)->(DbSkip())
End

(cSL2)->(DbCloseArea())

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstItCanc ºAutor  ³Microsiga           º Data ³  03/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista os itens das vendas por periodo para um PDV           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados dos itens vendidos no periodo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstItCanc ( nHdlArq		,dDataIni		,dDataFim	,cPDV	,;
 							lHomolPaf	,lTemIncManu	,lReducao 			)
Local nPos			:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nTamPDV		:= 0
Local nIndex		:= 0
Local nContDoc		:= 0 
Local nX			:= 0  
Local nTamB1_COD	:= 0
Local nCount		:= 0
Local cPDVLst		:= ""
Local cTotParc		:= "" 
Local cAux			:= ""
Local cQuery		:= ""
Local cNumOrc		:= ""
Local cDescri		:= ""
Local cSLX			:= ""
Local cConteudo		:= ""
Local lIncManual	:= .F.
Local lUsaSLX		:= .F.
Local lLxDesc		:= .F.
Local lLX_CONTDOC	:= .F.
Local aRetSLG		:= {}
Local LstIt			:= {}

nQtdDecQuant:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit:= TamSX3("L2_VRUNIT")[2]
nTamPDV		:= TamSX3("L2_PDV")[1]
nTamB1_COD	:= TamSx3("B1_COD")[1]
cPDVLst		:= cPDV + Space(nTamPDV - Len(cPDV))
lUsaSLX		:= AliasInDic('SLX')

//Captura registros da SLX
If lUsaSLX
	lLX_CONTDOC	:= SLX->(ColumnPos("LX_CONTDOC")) > 0
	lLxDesc := SLX->(ColumnPos('LX_DESCON')) > 0
	cSLX	:= "SLXTMP"

	If Select(cSLX) > 0
		(cSLX)->(DbCloseArea())
	EndIf

	cQuery	:= " SELECT " 
	cQuery	+= " SLX.*, " 
	cQuery	+= " SB1.B1_DESC,SB1.B1_PICM,SB1.B1_ALIQISS,SB1.B1_CEST,SB1.B1_POSIPI,SB1.B1_UM,SB1.B1_TS "
	cQuery	+= " FROM " + RetSqlName("SLX") + " SLX "
	cQuery	+= " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery	+= " ON LX_PRODUTO = B1_COD AND SLX.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
	cQuery	+= " WHERE LX_FILIAL='"+xFilial('SLX')+"' AND SB1.B1_FILIAL ='" + xFilial('SB1') + "'"
	cQuery	+= " AND LX_TPCANC <> 'D' "
	If !Empty(cPDV)
		cQuery	+= " AND LX_PDV = '" + AllTrim(cPDV) + "' "
	EndIf

	cQuery	+= " AND LX_DTMOVTO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
	cQuery	+= " AND SLX.D_E_L_E_T_ = ' '  "
	cQuery	+= " ORDER BY LX_DTMOVTO,LX_CUPOM "

	cQuery := ChangeQuery( cQuery )
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSLX, .F., .T.)
	TcSetField(cSLX,"LX_DTMOVTO","D")
	(cSLX)->(DbGoTop())

	While !(cSLX)->(Eof())
		nContDoc:= 0
		
		cDescri	:= "#" + AllTrim((cSLX)->B1_CEST) + "#" + AllTrim((cSLX)->B1_POSIPI) + "#" +  AllTrim((cSLX)->B1_DESC)
		If Empty(AllTrim((cSLX)->B1_CEST)) .Or. Empty(AllTrim((cSLX)->B1_POSIPI))
			cDescri := AllTrim((cSLX)->B1_DESC)
		EndIf 
		
		cTotParc:= STBFMSitTrib((cSLX)->LX_PRODUTO,"","SB1",.T.)
		//If ExistFunc("SFMAlqIssI") -- Comentado por hora caso, descomentar não possa mostrar aliquota IS/NS/FS
		//	cTotParc := SFMAlqIssI(cTotParc)
		//EndIF
		
		AAdd(LstIt,Array(23))
		nPos := Len(LstIt)
		nCount++

		LstIt[nPos][1]	:= Val((cSLX)->LX_CUPOM)
		LstIt[nPos][2]	:= Val((cSLX)->LX_CUPOM)
		LstIt[nPos][3]	:= Val((cSLX)->LX_ITEM)
		LstIt[nPos][4]	:= Alltrim((cSLX)->LX_PRODUTO)
		LstIt[nPos][5]	:= cDescri
		LstIt[nPos][6]	:= (cSLX)->LX_QTDE * &("1" + Replicate("0",nQtdDecQuant))
		LstIt[nPos][7]	:= AllTrim((cSLX)->B1_UM)
		LstIt[nPos][8]	:= ((cSLX)->LX_VALOR / (cSLX)->LX_QTDE) * &("1" + Replicate("0",nQtdDecVUnit))

		If lLxDesc 				
			LstIt[nPos][9] := (cSLX)->LX_DESCON
		Else
			LstIt[nPos][9] := 0
		EndIf

		LstIt[nPos][10]	:= 0
		LstIt[nPos][11]	:= (cSLX)->LX_VALOR
		LstIt[nPos][12]	:= StrTran(StrTran(cTotParc,","),".")

		If AllTrim((cSLX)->LX_TPCANC) <> "I"
			LstIt[nPos][13]	:= 0
			LstIt[nPos][14]	:= 0
			LstIt[nPos][15]	:= .F.
		Else
			LstIt[nPos][13]	:= (cSLX)->LX_QTDE * &("1" + Replicate("0",nQtdDecQuant))
			LstIt[nPos][14] := ((cSLX)->LX_VALOR / (cSLX)->LX_QTDE) * &("1" + Replicate("0",nQtdDecVUnit))
			LstIt[nPos][15] := .T.
		EndIf
		LstIt[nPos][16]	:= 0
		LstIt[nPos][17]	:= IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
		LstIt[nPos][18]	:= "T" //Indicador de produção: Propria ou Terceiros - Fixo somente para registros da SLX
		LstIt[nPos][19]	:= nQtdDecQuant
		LstIt[nPos][20]	:= nQtdDecVUnit

		If lLX_CONTDOC
			LstIt[nPos][21]	:= Val((cSLX)->LX_CONTDOC)
		Else
			LstIt[nPos][21] := Val((cSLX)->LX_CUPOM)
		EndIf

		LstIt[nPos][22] := LjPesqPdv(AllTrim((cSLX)->LX_PDV),AllTrim((cSLX)->LX_SERIE))
		LstIt[nPos][23]	:= .T.
		
		If lHomolPaf
			//Gera Chave MD5 dos dados armazenados    
			cPafMd5 := ''//STxPafMd5(cSL2, cNumOrc)
			
			//Valida chave
			LstIt[nPos][23]	:= .T. //( (cSL2)->L2_PAFMD5 == cPafMd5 )
	
			/* Valida Inclusão do registro via Banco de Dados, L2_PAFMD5 em branco
			Associar o L2_NUM a um SL1 valido - Teste Bloco VII */
			//If Empty(AllTrim((cSL2)->L2_PAFMD5))
			//	lIncManual := .T.
			//EndIf
	
			lTemIncManu	:= .F. //lIncManual
		EndIf
		
		(cSLX)->(DbSkip())
		
		nX := STBRetPDV(LstIt[nPos][22])[1][2]
		aRetSLG:= STBDatIECF(nX > 0,@aRetSLG,IIF(nX > 0 , aLstPDVs[nX][2], ""))
		
		cConteudo := "R05"								// 01 - Tipo
	 	cConteudo += PADR( LstIt[nPos][22], 20 ) 		// 02 - Numero de fabricacao do ECF 	
		cConteudo +=  PADR(aRetSLG[12], 01)	   			// 03 - Letra indicativa de MF adicional				
		
		If lHomolPaf .And. !lReducao .And. ( !LstIt[nPos][23] .Or. (nX > 0 .And. !LJPRVldLG(aLstPDVs[nX][4],aLstPDVs[nX][2]+aLstPDVs[nX][5]))) 
			cConteudo += StrTran(PadR(aRetSLG[2],20)," ","?") // 04 - Modelo do ECF
		Else
			cConteudo += PadR(aRetSLG[2],20)				// 04 - Modelo do ECF
		EndIf
		
		If ValType(aRetSLG[10]) == 'C'
			aRetSLG[10] := Val(aRetSLG[10])
		EndIF
		cConteudo += StrZero(aRetSLG[10],2)			// 05 - No. de ordem do usuario do ECF relativo a respectiva Reducao Z
		cConteudo += StrZero(LstIt[nPos][2],09 )				// 06 - COO (Contador de Ordem de Operacao) 
		cConteudo += StrZero(LstIt[nPos][21],09 )				// 07 - CCF, CVC ou CBP, conforme o documento
		cConteudo += StrZero(LstIt[nPos][3],03 )				// 08 - Numero do item
		cConteudo += PADR( LstIt[nPos][4],14 )				// 09 - Codigo do Produto ou Servico
		cConteudo += PADR( LstIt[nPos][5],100)				// 10 - Descricao
		cConteudo += StrZero(LstIt[nPos][6],07 )				// 11 - Quantidade
		cConteudo += PADR( LstIt[nPos][7],03 )				// 12 - Unidade
		cConteudo += StrZero(LstIt[nPos][8]	,08 )				// 13 - Valor unitario
		cConteudo += StrTran(StrTran(StrZero(LstIt[nPos][9],9,2),'-','0'),'.')	// 14 - Desconto sobre item 
		cConteudo += StrTran(StrTran(StrZero(LstIt[nPos][10],9,2),'-','0'),'.')	// 15 - Acrescimo sobre item 
		cConteudo += StrTran(StrTran(StrZero(LstIt[nPos][11],15,2),'-','0'),'.')		// 16 - Valor total liquido
		
		cTotParc := ""
		If nX > 0		
			cTotParc := LJRPTotEcf(aLstPDVs[nX][6],LstIt[nPos][12])			
		EndIF
		
		If Empty(AllTrim(cTotParc))
			cTotParc := "01"
		EndIf
		cTotParc += LstIt[nPos][12] //NNCXXXX - NN: numero da alíquota no ECF / C - tipo da aliquota, T=ICMS -S=ISS, etc. / XXXX - aliquota , por exemplo T1800
		cConteudo += PADR( cTotParc ,07 )				// 17 - Totalizador parcial
		
		cConteudo += IIF(LstIt[nPos][15],"S","N")		// 18 - Indicador de cancelamento 
		cConteudo += StrZero(LstIt[nPos][13],07 )				// 19 - Quantidade cancelada
		cConteudo += StrTran(StrZero(LstIt[nPos][14],14,2),'.')	// 20 - Valor cancelado
		cConteudo += StrTran(StrZero(LstIt[nPos][16],14,2),'.')	// 21 - Cancelamento de acrescimo no item 
		cConteudo += PADR(LstIt[nPos][17],01 )	   			// 22 - Indicador de Arredondamento ou Truncamento(IAT) 
		cConteudo += PADR(LstIt[nPos][18],01 )	   			// 23 - Indicador de Producao Propria ou de Terceiro(IPPT) 
		cConteudo += StrZero(LstIt[nPos][19],01 )				// 24 - Casas decimais da quantidade
		cConteudo += StrZero(LstIt[nPos][20],01 )				// 25 - Casas decimais de valor unitario
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
		ASIZe(LstIt,0)
		
		If nCount > 40
			LJRPLogProc("- [Em Execução] Incluindo Registros R04")
			nCount := 0
		EndIf
	EndDo
EndIf

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstDocEmit³ Autor ³ Venda Clientes        ³ Data ³30/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista de documentos emitidos dentro de um periodo 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os dados dos DOCs emitidos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja												  	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstDocEmit(	nHdlArq	,dDataIni	,dDataFim	,lHomolPaf	,;
 							cPDV	,lTemIncManu)
Local nPos		:= 0		// Posicao atual no retorno do WebService
Local nX		:= 0
Local cFilMDZ 	:= ""		// Filial da tabela MDZ
Local cAlias	:= ""	// Alias utilizado para consulta dos dados na MDZ
Local cQuery	:= ""		// Query para selecao de dados no banco de dados
Local cPafMd5	:= ""		// Chave MD5
Local cSerPDV	:= ""
Local cModelo	:= ""
Local cConteudo	:= ""
Local cTpDocMDZ	:= "R4,RP,NC,PV,XM,M5"
Local cTpQryMDZ := "'R4','RP','NC','PV','XM','M5'"
Local cSimbol	:= ""
Local lMD5PafOk := .T. 
Local aRetSLG	:= {}

Default cPDV := "" 

cFilMDZ := xFilial("MDZ")		// Filial da tabela MDZ
cPDV	:= AllTrim(cPDV)

//Para validar a deleção: excluir MDZ via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

		DbSelectArea("MDZ")
		MDZ->(DbSetOrder(1)) //MDZ_FILIAL+DTOS(MDZ_DATA)
		MDZ->(DbSeek(cFilMDZ+DtoS(dDataIni),.T.))
	
		While !MDZ->(Eof()) .AND. MDZ->MDZ_FILIAL == cFilMDZ .AND. MDZ->MDZ_DATA <= dDataFim    
			If (Empty(cPDV) .and. !Empty(MDZ->MDZ_PDV) ) .OR. (Alltrim(MDZ->MDZ_PDV) == Alltrim(cPDV))
				If !(MDZ->MDZ_SIMBOL $ cTpDocMDZ) .AND. MDZ->(deleted())
					lTemIncManu := .T.
				EndIf 
			EndIf
			MDZ->(DbSkip())
		EndDo
			
	SET DELETED ON

	MDZ->(DbCloseArea())
EndIf

cAlias := "MDZTMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= "SELECT MDZ.* " 
cQuery	+= " FROM " + RetSqlName("MDZ") + " MDZ "
cQuery	+= " WHERE MDZ_FILIAL = '" + cFilMDZ + "' "
cQuery	+= " AND MDZ_DATA >= '" + DtoS(dDataIni)+ "' "
cQuery	+= " AND MDZ_DATA <='" + DtoS(dDataFim) + "' "
If !Empty(cPDV)
	cQuery	+= "AND MDZ_PDV = '" + cPDV + "' "
EndIf

cQuery	+= " AND MDZ_SIMBOL NOT IN ( " + cTpQryMDZ + ")"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= "ORDER BY MDZ_FILIAL,MDZ_DATA"

cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"MDZ_DATA","D")	
(cAlias)->(DbGoTop())

//Armazena os registros validos no retorno do WebService
While !(cAlias)->(Eof())

	If lHomolPaf
		//Gera Chave MD5 dos dados armazenados 
		cPafMd5 := STxPafMd5(cAlias)
	
		/*
		Dbselectarea("MDZ")
		MDZ->(DbSetOrder(1))
	
		RecLock("MDZ",.F.)
		REPLACE MDZ->MDZ_PAFMD5 WITH cPafMD5
		MDZ->(MsUnlock())
		*/
	
		//Valida chave
		lMD5PafOk	:= (cAlias)->MDZ_PAFMD5 == cPafMd5 .And. WsLeMD5LG((cAlias)->MDZ_SERPDV)
	
		//************************************************************************************
		//Valida Inclusão do registro via Banco de Dados, MDZ_PAFMD5 em branco - Teste Bloco VII
		//************************************************************************************
		If Empty(AllTrim((cAlias)->MDZ_PAFMD5))
			lTemIncManu := .T.
		EndIf
	EndIf
		
	cSerPDV := Iif(!Empty(AllTrim((cAlias)->MDZ_SERPDV)),(cAlias)->MDZ_SERPDV , LjPesqPdv((cAlias)->MDZ_PDV,"")) 
	nPos	:= STBRetPDV(cSerPDV)[1][2]
	aRetSLG := STBDatIECF(nPos > 0,@aRetSLG,IIF(nPos > 0 , aLstPDVs[nPos][2], ""))	
	cModelo := PadR(AllTrim(aRetSLG[2]),20)
	
	If lHomolPaf .And. (!lMD5PafOk .Or. ( nPos > 0 .And. !LJPRVldLG(aLstPDVs[nPos][4],aLstPDVs[nPos][2]+aLstPDVs[nPos][5])))
		cModelo := StrTran(cModelo," ","?")
	EndIf
	
	cConteudo := "R06"											// 01 - Tipo
	cConteudo += PADR(cSerPDV , 20 )							// 02 - Numero de fabricação do ECF
	cConteudo += PadR(aRetSLG[12],1) 							// 03 - Informação Adicional do ECF
	cConteudo += cModelo										// 04 - Modelo do ECF
	
	If ValType(aRetSLG[10]) == "C"
		aRetSLG[10] :=  Val(aRetSLG[10])
	EndIf
	
	cConteudo += StrZero( aRetSLG[10], 02 )
	cConteudo += StrZero(Val((cAlias)->MDZ_COO), 09 )			// 06 - COO (Contador de Ordem de Operacao)
	cConteudo += StrZero(Val((cAlias)->MDZ_GNF), 06 )			// 07 - Número do GNF relativo ao respectivo documento, quando houver
	cConteudo += StrZero(Val((cAlias)->MDZ_GRG), 06 )			// 08 - Número do GRG relativo ao respectivo documento (vide item 7.6.1.2)
	cConteudo += StrZero(Val((cAlias)->MDZ_CDC), 04 )  			// 09 - Número do CDC relativo ao respectivo documento (vide item 7.6.1.3)
	
	cSimbol := AllTrim((cAlias)->MDZ_SIMBOL)
	cConteudo += PADR( cSimbol	, 02 ) 	  						// 10 - Símbolo referente à denominação do documento fiscal, conforme tabela abaixo
		
	cConteudo += PADR( DtoS((cAlias)->MDZ_DATA), 08 ) 	  		// 11 - Data final de emissão (impressa no rodape do documento)	
	cConteudo += RTrim(SubStr( StrTran((cAlias)->MDZ_HORA, ":") + "00",1,6))	
	cConteudo += CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )

	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

For nPos := 1 to Len(aResultR06)
	cConteudo := ""
	For nX := 1 to Len(aResultR06[nPos])
		cConteudo += aResultR06[nPos][nX]
	Next nX
	
	If !Empty(AllTrim(cConteudo))
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	EndIf
Next nPos

ASize(aResultR06,0)

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstProduto³ Autor ³ Venda Clientes        ³Data ³14/05/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Lista pontos de venda cadastrados na retaguarda             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com o numero dos PDVs disponiveis            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja										  		  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstProduto (nHdlArq ,lHomolPaf, lTemIncManu, lIsPafNfce)
Local cQuery		:= ""							// Query para selecao de dados no banco de dados
Local cAlias		:= ""							// Alias utilizado para consulta dos dados na SB1                  
Local cPafMd5		:= ""							// Chave MD5
Local cCodBar		:= ""							// codigo de barra
Local cCnpj			:= ""
Local cMV_TABPAD	:= SuperGetMV("MV_TABPAD",,"1")
Local cMV_ARREFAT	:= SuperGetMV("MV_ARREFAT")
Local cB0_PRC		:= ""
Local cConteudo		:= ""
Local cIAT			:= ""
Local cIPPT			:= ""
Local cCest			:= ""
Local cNCM			:= ""
Local cSitTrib		:= ""
Local nPos			:= 0							// Posicao atual no retorno do WebService
Local nTotalB0		:= 0
Local nTotalB1		:= 0
Local nPreco		:= 0
Local lFieldMD5		:= .T.
Local lMD5PafOk		:= .T.
Local cMVLJPAFMP	:= SuperGetMV("MV_LJPAFMP",,"")	// Filtra os tipos de produtos que são considerados como Não Comercializados
Local aMVLJPAFMP    := {}
Local nX            := 0

Default lIsPafNfce	:= .F. 

//Valida inclusão ou exclusão pelo Banco de Dados - TESTE BLOCO VII
If lHomolPaf
	If Select("SB0TMP") > 0
		SB0TMP->(DbCloseArea())
		SB1TMP->(DbCloseArea())
	EndIf	

	cQuery := "select COUNT(B0_COD) TotalB0 from " +RetSqlName("SB0") + " where D_E_L_E_T_ = ' '  and B0_FILIAL = '" + xFilial("SB0") + "'"	
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB0TMP", .F., .T.)
	nTotalB0 := SB0TMP->TotalB0

	cQuery := "select COUNT(B1_COD) TotalB1 from "+RetSqlName("SB1") +" where D_E_L_E_T_ = ' ' and B1_FILIAL = '" + xFilial("SB1") + "'" + " AND B1_MSBLQL <> '1' "	
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB1TMP", .F., .T.)
	nTotalB1 := SB1TMP->TotalB1

	SB0TMP->(DbCloseArea())
	SB1TMP->(DbCloseArea())

	If !(nTotalB0 == nTotalB1)
		lTemIncManu := .T.
	EndIf
EndIf

DbSelectArea("SB1")
lFieldMD5	:= .T.

//Faz a pesquisa para acessar função STBFMSitTrib
DbSelectArea("SA1")
SA1->(DbSeek( xFilial("SA1") + PadR(SuperGetMV("MV_CLIPAD"),TamSX3("A1_COD")[1]) + SuperGetMV("MV_LOJAPAD") ) ) //A1_FILIAL + A1_COD + A1_LOJA

cCnpj :=  StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"."),"/")

cAlias	:= "SB1TMP"
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

LJRPLogProc(" Iniciando Query de Produtos...")
cQuery := " SELECT DISTINCT "
//cQuery += " TOP 10 " //Habilitar só para teste
cQuery += " SB1.B1_FILIAL, SB1.B1_COD , SB1.B1_DESC, SB1.B1_SITTRIB, SB1.B1_ALIQISS, SB1.B1_PICM, "
cQuery += " SB1.B1_UM, SB1.B1_IAT, SB1.B1_IPPT, SB1.B1_PAFMD5, SB1.B1_CODBAR, SB1.B1_PRV1, SB1.B1_TS,"
cQuery += " SB1.B1_ALIQISS, SB1.B1_PICMRET,	SB1.B1_CEST, SB1.B1_POSIPI,"

If SB1->(ColumnPos("B1_QATUPAF")) > 0
	cQuery	+= " SB1.B1_QATUPAF, "
EndIf

//Campos da SB0
If SB0->(ColumnPos("B0_PRV" + cValToChar(Val(cMV_TABPAD)))) > 0
	cB0_PRC := " SB0.B0_PRV" + cValToChar(Val(cMV_TABPAD))
Else
	LJRPLogProc(" Verifique o conteúdo do parâmetro MV_TABPAD [" + cMV_TABPAD + "] que não está coerente " +;
				" com o campo de preço na tabela SB0! " + CHR(10) + CHR(13) +;
				" Será capturado o conteúdo do campo padrão B0_PRV1 - Preço de Venda '1'")
	cB0_PRC := " SB0.B0_PRV1 "
EndIf

cQuery += cB0_PRC + " B0_PRCTAB , SB0.B0_ALIQRED, "

//Campos da SLK
cQuery += " SLK.LK_CODBAR "

cQuery += " FROM " + RetSqlName("SB1") + "  SB1 "
cQuery += " LEFT JOIN " + RetSqlName("SB0") + "  SB0 "
cQuery += " ON SB0.B0_FILIAL = '"+ xFilial("SB0") +"' AND SB0.B0_COD = SB1.B1_COD AND SB0.D_E_L_E_T_ = '' "
cQuery += " LEFT JOIN " + RetSqlName("SLK") + " SLK "
cQuery += " ON SLK.LK_FILIAL = '" + xFilial("SLK") +"' AND SLK.LK_CODIGO = SB1.B1_COD AND SLK.D_E_L_E_T_ = ''"
cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial('SB1') + "' AND SB1.B1_MSBLQL <> '1' "

// Valida o conteudo do Parametro, para não permitir que seja utilizado tipos inadequados
If !Empty(cMVLJPAFMP)
	cMVLJPAFMP := StrTran(cMVLJPAFMP, "'", "")
	aMVLJPAFMP := StrTokArr(cMVLJPAFMP,",")
	cMVLJPAFMP := ""

	For nX := 1 to Len(aMVLJPAFMP)
		cMVLJPAFMP += "'" + aMVLJPAFMP[nX] + "'" + ","
	Next nX

	cMVLJPAFMP := SubStr(cMVLJPAFMP, 1, Len(cMVLJPAFMP)-1)
	
	cQuery += " AND SB1.B1_TIPO NOT IN (" + cMVLJPAFMP + ")"	
EndIf

cQuery += " AND SB1.D_E_L_E_T_= ''"
cQuery += " ORDER BY B1_COD "
 
cQuery	:= ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
(cAlias)->(DbGoTop())
LJRPLogProc(" Retorno da Query de Produtos...")

If !(cAlias)->(Eof())
	LJRPLogProc(" Populando Registros P2... [Inicio]")
EndIf

While !(cAlias)->(Eof())
 	nPos++
	
	If !Empty((cAlias)->LK_CODBAR)
		cCodBar := (cAlias)->LK_CODBAR		 
	ElseIf !Empty((cAlias)->B1_CODBAR)
		cCodBar	:= (cAlias)->B1_CODBAR
	Else
		cCodBar := (cAlias)->B1_COD
	EndIf
	
	LJRPLogProc(" Produto - Código [" + cCodBar +"]")
	
	nPreco := (cAlias)->B0_PRCTAB	
	If nPreco == 0
		nPreco := (cAlias)->B1_PRV1
	EndIf
	
	If lHomolPaf .And. lFieldMD5
		cPafMd5 := STxPafMd5(cAlias)
		lMD5PafOk := (cAlias)->B1_PAFMD5 == cPafMd5
	EndIf
	
	/*
	Montagem do Arquivo
	*/
	cConteudo := "P2"
	cConteudo += PADR(cCnpj, 14 )
	cConteudo += PadR(cCodBar,14)
	
	cCest := AllTrim((cAlias)->B1_CEST)	
	If Empty(cCest)
		cCest := StrZero(0,7)
	EndIf
	cConteudo += PADR( cCest , 7)
	
	cNCM := AllTrim((cAlias)->B1_POSIPI)	
	If Empty(cNCM)
		cNCM := StrZero(0,8)
	EndIf
	cConteudo += PADR( cNCM, 8)
	
	cConteudo += PADR( (cAlias)->B1_DESC , 50 )
	
	If lHomolPaf .And. !lMD5PafOk
		cConteudo += StrTran(PADR( (cAlias)->B1_UM , 6 )," ","?")
	Else
		cConteudo += PADR( (cAlias)->B1_UM , 6 )
	EndIf
	
	cIAT := AllTrim((cAlias)->B1_IAT)
	If Empty(cIAT)
		cIAT := IIf(cMV_ARREFAT=="S","A","T") //Campo não pode ficar em branco
	EndIf
	cConteudo += PADR(cIAT,1)
	
	cIPPT := AllTrim((cAlias)->B1_IPPT)
	If Empty(cIPPT)
		cIPPT := "T" //Campo não pode ficar em branco
	EndIf
	cConteudo += PADR(cIPPT,1)
	
	cSitTrib :=	STBFMSitTrib((cAlias)->B1_COD,"","SB1",.F.)
	//IF ExistFunc("SFMAlqIssI") -- Comentado por hora caso, descomentar não possa mostrar aliquota IS/NS/FS
	//	cSitTrib := SFMAlqIssI(cSitTrib)
	//EndIf
	
	IF SubStr(cSitTrib,1,2) $ "IS|FS|NS"
		cConteudo += PadL( "S" , 1 )
		cConteudo += "0000"
	Else 
		cConteudo += PadL( cSitTrib , 1 )
		
		If SubStr(cSitTrib,1,1) $ "T|S"
			cSitTrib := StrZero(Val(SubStr(cSitTrib,2,5)),5,2)
			cSitTrib := StrTran(cSitTrib,".")
			cSitTrib := StrTran(cSitTrib,",")		
			cConteudo += PadL(cSitTrib, 4 )    	// aliquota
		Else        
			cConteudo += "0000"       			// aliquota                
		EndIf
	EndIf

	If lIsPafNfce //14 posições  
		cConteudo += PadR(StrTran(StrTran(StrZero(nPreco,15,2),","),"."),14)
	Else //12
		cConteudo += PadR(StrTran(StrTran(StrZero(nPreco,13,2),","),"."),12)
	Endif 
	cConteudo += CHR(13) + CHR(10)	
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	
	If nPos > 50
		LJRPLogProc(" - Registro de P2 [Em andamento...Aguarde Final do Processamento]")
		nPos := 0
	EndIf

	If lHomolPaf .And. Empty(AllTrim((cAlias)->B1_PAFMD5))
		lTemIncManu := .T.
	EndIf

	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

LJRPLogProc(" Finalizando Registros P2...")

Return nHdlArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstEstoque³ Autor ³ Venda Clientes        ³ Data ³13/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Lista pontos de venda cadastrados na retaguarda             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com o numero dos PDVs disponiveis           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstEstoque( nHdlArq	, aProdutos	, lHomolPaf	, lTemIncManu, dDataFim, lIsPafNfce )
Local cQuery	:= ""		// Query para selecao de dados no banco de dados
Local cQryProd	:= ""		//Trecho da query contendo os produtos vindo de aProdutos
Local cAlias	:= ""		// Alias utilizado para consulta dos dados na SL1
Local cPafMd5	:= ""		// Chave MD5
Local cCodProd	:= ""		// código do produto
Local nTotalB0 	:= 0		//contador de registros da SB0
Local nTotalB1	:= 0		//contador de registros da SB1
Local nTamSB1	:= 0
Local nPos		:= 0		// Posicao atual no retorno do WebService
Local nX		:= 0		// variavel de contador
Local nConta	:= 0
Local cConteudo	:= ""
Local cQATU		:= ""
Local cCest		:= ""
Local cNCM		:= ""
Local lProdutos	:= .F.
Local lB1_QATUPAF:= .F.		// valida se o campo B1_QATUPAF existe
Local lPafMD5OK	:= .F.
Local lUpdateEtq:= .F.

Default aProdutos	:= {}
Default lIsPafNfce  := .F. 
Default dDataFim	:= CTOD("")

lProdutos := Len(aProdutos) > 0 //Verifica se foi selecionado algum produto especifico

//Permite a validação de adicionado/excluídos no banco somente se for em homologação e qdo selecionado todos os registros.
If lHomolPaf .And. !lProdutos
	If Select("SB0TMP") > 0
		SB0TMP->(DbCloseArea())
		SB1TMP->(DbCloseArea())
	EndIf

	cQuery := "select COUNT(B0_COD) TotalB0 from "+RetSqlName("SB0") +" where D_E_L_E_T_ = ' ' and B0_FILIAL = '" + xFilial("SB0") + "'"		
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB0TMP", .F., .T.)
	nTotalB0 := SB0TMP->TotalB0

	cQuery := "select COUNT(B1_COD) TotalB1 from "+RetSqlName("SB1") +" where D_E_L_E_T_ = ' ' and B1_FILIAL = '" + xFilial("SB1") + "'" + " AND B1_MSBLQL <> '1' "			
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB1TMP", .F., .T.)
	nTotalB1 := SB1TMP->TotalB1

	SB0TMP->(DbCloseArea())
	SB1TMP->(DbCloseArea())		

	If nTotalB0 <> nTotalB1
		lTemIncManu := .T.
	EndIf
EndIf

//Atualiza campo, caso exista pois ele possui a qtde em estoque da SB2 ( B2_QATU ) e tornar mais facil a validação do MD-5
DbSelectArea("SB1")
SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
nTamSB1	:= TamSX3("B1_COD")[1]
lB1_QATUPAF := SB1->(ColumnPos("B1_QATUPAF")) > 0

cAlias	:= "SB1TMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= " SELECT "
cQuery	+= " SB1.B1_COD, SB1.B1_DESC, SB1.B1_SITTRIB, SB1.B1_PICM, SB1.B1_ALIQISS, SB1.B1_PICM, "
cQuery	+= " SB1.B1_PRV1, SB1.B1_PAFMD5, SB1.B1_UM, SB1.B1_IAT, SB1.B1_IPPT,SB1.B1_CODBAR, "
cQuery	+= " SB1.B1_CEST, SB1.B1_POSIPI, SB1.B1_TS, "
cQuery	+= " Max(SB2.B2_USAI) B2_USAI , Sum(SB2.B2_QATU) B2_QATU, "

If lB1_QATUPAF
	cQuery	+= " SB1.B1_QATUPAF, "
EndIf
cQuery	+= " SLK.LK_CODBAR"
cQuery	+= " FROM " + RetSqlName("SB1") + " SB1 "
cQuery	+= " LEFT JOIN " + RetSqlName("SB2") + " SB2 ON SB1.B1_COD = SB2.B2_COD "
cQuery	+= " LEFT JOIN " + RetSqlName("SLK") + " SLK ON SLK.LK_FILIAL = '" + xFilial("SLK") + "' AND SLK.LK_CODIGO = SB1.B1_COD AND SLK.D_E_L_E_T_ = '' "
cQuery	+= " WHERE "
cQuery	+= " SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
cQuery	+= " And SB2.B2_FILIAL = '" + xFilial('SB2') + "'"
cQuery	+= " And SB1.B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ =	' ' "

If lProdutos		
	cQryProd := " AND SB1.B1_COD IN ( "

	For nX := 1 to Len(aProdutos)
		cQryProd += "'" + aProdutos[nX][1] + "'," 
	Next nX
	cQryProd := Substr( cQryProd , 1 , Len(cQryProd)-1 ) //remove a ultima virgula
	cQryProd += " ) "

	cQuery += cQryProd
EndIf

cQuery += " GROUP BY " 
cQuery += " SB1.B1_COD, SB1.B1_DESC, SB1.B1_SITTRIB, SB1.B1_PICM, SB1.B1_CODBAR, "
cQuery += " SB1.B1_PRV1, SB1.B1_PAFMD5, SB1.B1_UM, SB1.B1_IAT, SB1.B1_IPPT, "  
cQuery += " SB1.B1_ALIQISS,SB1.B1_PICM,SB1.B1_CEST, SB1.B1_POSIPI, SB1.B1_TS, "
cQuery += " SLK.LK_CODBAR "

If lB1_QATUPAF
	cQuery	+= ",SB1.B1_QATUPAF "
EndIf

cQuery += " ORDER BY SB1.B1_COD "
cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"B2_USAI","D")
(cAlias)->(DbGoTop())

//Atualiza o campo valor do estoque na B1 de acordo com a B2 e atualiza o MD5
If lB1_QATUPAF 
	lUpdateEtq := !LjxDGerMdz("PV")
	If lUpdateEtq
		LjPafUPEst(cAlias)
		(cAlias)->(DbGoTop()) //a função acima desposiciona o cAlias
		LjxDDelMdz("PV",dDataBase)	
	EndIf
EndIf

While !(cAlias)->(Eof())
	nConta++
	
	//Colocada validação pois no PDV valida se esse campo está <> 0, senão não gera e dá problema no arquivo do PAF
	If lUpdateEtq .And. lB1_QATUPAF .And. (cAlias)->B1_QATUPAF == 0 
		nPos := (cAlias)->B2_QATU
	ElseIf lUpdateEtq .OR. !lB1_QATUPAF
		nPos := (cAlias)->B2_QATU
	Else
		If (cAlias)->B2_QATU == (cAlias)->B1_QATUPAF
			nPos := (cAlias)->B1_QATUPAF
		Else
			nPos := (cAlias)->B2_QATU
			SB1->(DbSeek(xFilial("SB1")+PadR((cAlias)->B1_COD,nTamSB1)))
			RecLock("SB1",.F.)
			REPLACE SB1->B1_QATUPAF WITH nPos
			SB1->(MsUnlock())
			
			cPafMd5	 := STxPafMd5("SB1") 
			RecLock("SB1",.F.)
			REPLACE SB1->B1_PAFMD5 WITH cPafMd5
			SB1->(MsUnlock())
		EndIf
	EndIf
	
	//Só gera o registro se o estoque for diferente de zero
	If nPos <> 0
		cCodProd := ""
		
		If !Empty(AllTrim((cAlias)->LK_CODBAR))
			cCodProd := AllTrim((cAlias)->LK_CODBAR)
		ElseIf !Empty(AllTrim((cAlias)->B1_CODBAR))
			cCodProd := AllTrim((cAlias)->B1_CODBAR)
		Else
			cCodProd := AllTrim((cAlias)->B1_COD)
		EndIf
		
		cConteudo := "E2"
		cConteudo += PadR(AllTrim(StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"."),"/")),14)
		cConteudo += PADR( cCodProd, 14 )

		cCest := AllTrim((cAlias)->B1_CEST)	
		If Empty(cCest)
			cCest := StrZero(0,7)
		EndIf
		cConteudo += PADR( cCest , 7)
		
		cNCM := AllTrim((cAlias)->B1_POSIPI)	
		If Empty(cNCM)
			cNCM := StrZero(0,8)
		EndIf
		cConteudo += PADR( cNCM, 8)
		
		cConteudo += PadR(AllTrim((cAlias)->B1_DESC),50)
		
		If lHomolPaf		
			//Valida Inclusão Manual
			If Empty(AllTrim((cAlias)->B1_PAFMD5)) 
				lTemIncManu := .T. 
			EndIf
			
			cPafMd5	 := STxPafMd5(cAlias)
			lPafMD5OK:= (cPafMd5 == (cAlias)->B1_PAFMD5)
			
			If lPafMD5OK
				cConteudo += PADR( (cAlias)->B1_UM, 6 )
			Else
				cConteudo += StrTran(PADR((cAlias)->B1_UM, 6 ) ," ","?")
			EndIf
		Else
			cConteudo += PADR( (cAlias)->B1_UM, 6 )
		EndIf
		
		// Quantidade em estoque
		cConteudo += IIF(nPos > 0,"+","-")
		cQATU	:= StrZero(Abs(nPos),TamSx3("B2_QATU")[1],3) //Colocado o TamSx3 para impedir vir com '***', qdo qtde maior que 9 caracteres 
		cQATU	:= StrTran(StrTran(cQATU,"."),",")
		If Len(cQATU) > 9
			cConteudo += Substr(cQATU,Len(cQATU)-8,9)
		Else
			cConteudo += PadL(Substr(cQATU,1,9),9,"0")
		EndIf
		

		If lIsPafNfce
			cConteudo += PADR(DtoS(dDatabase),8)	
			cConteudo += PADR(DtoS(IiF(!Empty(dDataFim),dDataFim, dDatabase)),8)
		Endif 
		cConteudo += CHR(13) + CHR(10)
		
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	EndIf
	
	If nConta > 50
		LJRPLogProc(" Registros E2 [Em execução...]")
		nConta := 0
	EndIf

	(cAlias)->(dbSkip())
EndDo

IIf( Select("SB0TMP") > 0 , SB0TMP->(DbCloseArea()) , .F. )
IIf( Select("SB1TMP") > 0 , SB1TMP->(DbCloseArea()) , .F. )

Return nHdlArq

//--------------------------------------------------------
/*/
{Protheus.doc}LstECFAtuSt
Função para gerar o E3 

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function LstECFAtuSt(nHdlArq		,lHomolPaf	,lTemIncManu	,dDataIni	,;
							dDataFim	)
Local aDadosE3	:= {}
Local cConteudo	:= ""
Local cSeriePDV	:= ""
Local cMFAdic	:= ""
Local cTipoEcf	:= ""
Local cMarcaEcf	:= ""
Local cModelEcf	:= "" 
Local cDtEmissao:= ""
Local cHrEmissao:= ""
Local cMd5Pdv	:= ""
Local cAux		:= ""
Local aRetSLG	:= {}

aDadosE3 := LJRPVendEst(lHomolPaf,@lTemIncManu,dDataIni,dDataFim)

If Len(aDadosE3) > 0
	cSeriePDV	:= aDadosE3[1][1]
	cDtEmissao	:= DtoS(aDadosE3[1][3])
	cHrEmissao	:= aDadosE3[1][4]
	cMd5Pdv		:= aDadosE3[1][6]

	cAux	:= LjPesqPdv( aDadosE3[1][2] , "" , "LG_ECFINFO")
	aRetSLG := STBDatIECF(.T.,@aRetSLG,cAux)
	cTipoEcf:= aRetSLG[1]
	cModelEcf:= aRetSLG[2]
	cMarcaEcf:= aRetSLG[8]
	cMFAdic := aRetSLG[12]
	
	aRetVldE3 := LJRPVldE3( aDadosE3[1][3], @cSeriePDV,@cMFAdic,@cTipoEcf,;
							@cMarcaEcf,@cModelEcf, @cDtEmissao,@cHrEmissao,;
							@cMd5Pdv)
	
	If lHomolPaf .And. ( aRetVldE3[1][2] .Or. aRetVldE3[1][3] )
		lTemIncManu := .T.
	EndIf
	
	If !aRetVldE3[1][2] //Deleção Manual
		cConteudo := "E3"
		cConteudo += cSeriePDV				//Numero de fabricação do ECF
		cConteudo += PADR( cMFAdic , 1 )	//Letra indicativa de MF adicional
		cConteudo += PADR( cTipoEcf, 7 )	//Tipo de ECF
		cConteudo += PADR( cMarcaEcf, 20 )	//Marca do ECF
		
		If lHomolPaf
			If !aDadosE3[1][5] .Or. !aRetVldE3[1][1] .OR. aRetVldE3[1][3]
				cConteudo += StrTran(Padr( cModelEcf, 20 )," ","?")	//Modelo do ECF
			Else
				cConteudo += Padr( cModelEcf, 20 )	//Modelo do ECF
			EndIf
		Else
			cConteudo += Padr( cModelEcf, 20 )	//Modelo do ECF
		EndIf

		cConteudo += cDtEmissao // data do estoque
		cHrEmissao := AllTrim(StrTran(cHrEmissao,":"))
		
		If Empty(cHrEmissao)
			cHrEmissao := StrTran(Time(),":")
		EndIf
		
		If Len(cHrEmissao) <> 6
			cHrEmissao := StrTran(Transform( cHrEmissao, "999999"  )," ","0")
		EndIf
		
		cConteudo += cHrEmissao //Hora do estoque
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	EndIf
EndIf

Return nHdlArq

//--------------------------------------------------------
/*/
{Protheus.doc}LJRPVendEst
Validação do Estoque 

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	LsVdESt , array , 
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function LJRPVendEst(lHomolPaf	,lTemIncManu	,dDataIni	,dDataFim)
Local cQuery	:= ""
Local cSL1		:= "SL1TMP"
Local cSB2		:= "SB2TMP"
Local dDtEst	:= CTOD("")
Local LsVdESt	:= {}

If Select(cSL1) > 0
	(cSL1)->(DbCloseArea())
EndIf

If Select(cSB2) > 0
	(cSB2)->(DbCloseArea())
EndIf

//Pesquisa ultima atualização de estoque e considera a venda dessa data como a mais recente
cQuery	:= " SELECT B2_USAI "
cQuery	+= " FROM " + RetSqlName("SB2")
cQuery	+= " WHERE "
cQuery	+= " B2_FILIAL = '" + xFilial("SB2") + "'" 
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY B2_USAI DESC"
cQuery	:= ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSB2, .F., .T.)
TcSetField(cSB2,"B2_USAI","D")
(cSB2)->(DbGoTop())

While !(cSB2)->(Eof()) .And. (Len(LsVdESt) == 0)
	dDtEst := (cSB2)->B2_USAI
	
	//ER 02.06 Item 6.5.1.3 - Deve gerar dentro do período de movimentação selecionado
	If (DtoS(dDtEst) <> DtoS(CTOD(""))) .And. (dDtEst >= dDataIni) .And. (dDtEst <= dDataFim)
		//Pesquisa a venda
		cQuery	:= "SELECT L1_FILIAL,L1_EMISSAO,L1_PDV,L1_DOC,L1_VLRTOT,L1_VALBRUT,"
		cQuery	+= "L1_NUMCFIS,L1_EMISNF,L1_HORA,L1_DESCONT,L1_VLRLIQ,L1_CONTONF,L1_CONTRG,"   
		cQuery	+= "L1_CONTCDC,L1_CONTDOC,L1_DATATEF,L1_HORATEF,L1_SERPDV,L1_STORC,L1_NUMORC,"
		cQuery	+= "L1_PAFMD5,L1_COODAV,L1_SERIE,L1_NUM,L1_CLIENTE ,L1_CGCCLI,L1_VALMERC,L1_ESPECIE, "
		cQuery	+= "L1_TPORC,L1_PDV,L1_DTLIM "
		cQuery	+= " FROM " + RetSqlName("SL1") + " SL1 "
		cQuery	+= " WHERE "
		cQuery	+= " SL1.L1_FILIAL = '" + xFilial("SL1") + "' AND "
		cQuery	+= " SL1.L1_NUMCFIS <> ' ' AND "	
		cQuery	+= " SL1.L1_EMISSAO = '" + Dtos(dDtEst) + "'"
		cQuery	+= " ORDER BY L1_EMISSAO,L1_HORA"
		cQuery := ChangeQuery( cQuery )
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
		TcSetField(cSL1,"L1_EMISSAO","D")	
		TcSetField(cSL1,"L1_EMISNF","D")
		TcSetField(cSL1,"L1_DTLIM","D")
		(cSL1)->(DbGoTop())
		
		If !(cSL1)->(Eof())
			AAdd(LsVdESt,Array(6))
		
			LsVdESt[1][1] 	:=	IF(!Empty(AllTrim((cSL1)->L1_SERPDV)),(cSL1)->L1_SERPDV,LjPesqPdv((cSL1)->L1_PDV,(cSL1)->L1_SERIE))
			LsVdESt[1][2]	:=	(cSL1)->L1_PDV
			LsVdESt[1][3]	:=	(cSL1)->L1_EMISSAO
			LsVdESt[1][4]	:=	(cSL1)->L1_HORA
			
			If lHomolPaf
				//Valida Inclusão/Alteração do registro via Banco de Dados, L1_PAFMD5 em branco - Teste Bloco VII 
				LsVdESt[1][5]	:=	(cSL1)->L1_PAFMD5 == STxPafMd5(cSL1) // Gera e Valida chave MD5 dos Registros
				lTemIncManu		:=	Empty(AllTrim((cSL1)->L1_PAFMD5))
			Else
				LsVdESt[1][5]	:= .T.
			EndIf
			
			LsVdESt[1][6] := AllTrim((cSL1)->L1_PAFMD5)
			
			Loop //Sai do while, venda encontrada
		EndIf
		
		(cSL1)->(DbCloseArea())
	EndIf
	
	(cSB2)->(DbSkip())
End

(cSB2)->(DbCloseArea())

Return LsVdESt

//--------------------------------------------------------
/*/
{Protheus.doc}LJRPVldE3
Função para validar a alteração do E3 

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function LJRPVldE3(	dData		,	cSeriePDV	,	cMFAdic		,	cTipoEcf	,;
							cMarcaEcf	,	cModelEcf	,	cDtEmissao	,	cHrEmissao	,;
							cMd5Pdv		)
Local nTry			:= 0
Local cAux			:= ""
Local cMD5			:= ""
Local cLGPafMd5		:= ""
Local lRet 			:= .T.
Local lExistSale	:= .F.
Local aRet			:= {}
Local dDtPesq		:= CtoD( '' )
Local cRetTipoEcfE	:= ""
Local cRetModeloE	:= ""
Local cRetVerSBE	:= ""
Local cRetDtInsSBE	:= ""
Local cRetHrInsSBE	:= ""
Local cRetIEE		:= ""
Local cRetCGCE		:= ""
Local cRetMarcaEcf	:= ""
Local cRetSerEcf	:= ""
Local cRetPdvEcf 	:= ""
Local cRetCodNacEcf	:= ""
Local cRetMFAdicEcf	:= ""
Local cFilSL1		:= xFilial('SL1')
Local lDelManual	:= .F.
Local lIncManual	:= .F.

Default cSeriePDV	:= ""
Default	cMFAdic		:= ""
Default cTipoEcf	:= ""
Default cMarcaEcf	:= ""
Default cModelEcf	:= ""
Default cDtEmissao	:= "" 
Default cHrEmissao	:= ""

/* Para fazer as validações caso haja alteração do banco altere os dados
do campo LG_ECFINFO */

SET DELETED OFF

DbSelectArea('SL1')
DbSelectArea('SF2')
DbSelectArea('SLG')
SL1->(DbSetOrder(4)) //Filial + Data Emissao
SF2->(DbSetOrder(1))
dDtPesq := dData
nTry	:= 0

//Pesquisa até encontrar uma venda
While !lExistSale .And. nTry <= 90 //Permite voltar 90 dias
	lExistSale := SL1->(DbSeek(cFilSL1 + Dtos(dDtPesq)))
	
	If !lExistSale
		dDtPesq -= 1
		nTry++
		
		If SL1->(Eof())
			nTry := 91
		EndIf
	EndIf
End

If lExistSale
	cAux	:= AllTrim(LjPesqPdv( SL1->L1_PDV , SL1->L1_SERIE , "LG_ECFINFO"))
	cMD5	:= AllTrim(MD5( cAux + Upper(LjPesqPdv( SL1->L1_PDV , SL1->L1_SERIE , "LG_IMPFISC")) ,2))
	cLGPafMd5 := AllTrim(LjPesqPdv( SL1->L1_PDV , SL1->L1_SERIE , "LG_PAFMD5"))
	
	/*Para validar a alteração da data pego um campo diferente de L1_EMISSAO, pois
	o registro será encontrado mas não será validado devido a diferença de data*/
	//as Duas ultimas posições tratam Exclusão Manual / Inclusão Manual
	//Exclusão - deixar como deletado o primeiro movimento
	//Inclusão - incluir um registro de primeiro movimento e deixar o MD5 em branco
	If SL1->(Deleted())
		Aadd(aRet,{"", Dtos(dDtPesq) , Dtos(dDtPesq) , StrTran(Time(),":") , StrTran(Time(),":"), "" , "",.T.,.T.})
	Else
		If (AllTrim(SL1->L1_ESPECIE) == "NFCF" .Or. AllTrim(SL1->L1_ESPECIE) == "NFM") //Quando só tenho nota emitida, ele deve validar o E2/E3
			Aadd(aRet,{"", Dtos(SL1->L1_EMISSAO) , Dtos(SL1->L1_DTLIM) ,;
							 StrTran(SL1->L1_HORA,":") , StrTran(SL1->L1_HORA,":"), "" , "",.F., Empty(SL1->L1_PAFMD5)})
		Else
			If SF2->(DbSeek(cFilSL1+SL1->L1_DOC+SL1->L1_SERIE))		
				Aadd(aRet, {AllTrim(cAux), Dtos(SL1->L1_EMISSAO) , Dtos(SL1->L1_DTLIM) ,;
							StrTran(SL1->L1_HORA,":") , StrTran(SF2->F2_HORA,":") , cMD5, cLGPafMd5, .F., Empty(SL1->L1_PAFMD5)})
			ElseIf !Empty(SL1->L1_DOC)
				Aadd(aRet, {AllTrim(cAux), Dtos(SL1->L1_EMISSAO) , Dtos(SL1->L1_DTLIM) ,;
						 	StrTran(SL1->L1_HORA,":") , StrTran(Time(),":"), cMD5 , cLGPafMd5, .F., Empty(SL1->L1_PAFMD5)})
			Else//Caso não haja venda , não pode retornar que não foi validado (senão serão colocadas interrogações no Registro do PAF) 
				Aadd(aRet,{"", Dtos(dDtPesq) , Dtos(dDtPesq) , StrTran(Time(),":") , StrTran(Time(),":"), "" , "",.F.,.F.})
			EndIf
		EndIf
	EndIf
	
	Conout("Registro E3 - PAF-ECF -> localizado - Recno SL1[" + cValToChar(SL1->(Recno())) +"]")
	LjGrvLog( NIL,"Registro E3 - PAF-ECF -> localizado - Recno SL1[" + cValToChar(SL1->(Recno())) +"]")
Else
	aRet := {}
EndIf

SET DELETED ON
	
If Len(aRet) > 0
	If	(aRet[1][6] <> aRet[1][7]) .Or.;
	 	(aRet[1][2] <> aRet[1][3]) .Or.;
	 	(AllTrim(aRet[1][4]) <> SubStr(AllTrim(aRet[1][5]),1,4))
	 	
		lRet := .F.
		
		STDBusDEst(	aRet[1][1]	, @cRetTipoEcfE, @cRetModeloE, @cRetVerSBE,; 
					@cRetDtInsSBE, @cRetHrInsSBE, @cRetIEE, @cRetCGCE ,;
					@cRetMarcaEcf, @cRetSerEcf  , @cRetPdvEcf , @cRetCodNacEcf,;
					@cRetMFAdicEcf)
				
		cSeriePDV	:= cRetSerEcf			
		cMFAdic		:= cRetMFAdicEcf
		cTipoEcf	:= cRetTipoEcfE
		cMarcaEcf	:= cRetMarcaEcf
		cModelEcf	:= cRetModeloE
		cDtEmissao	:= aRet[1][2]
		cHrEmissao	:= aRet[1][4]
	Else
		lRet := .T.
	EndIf
	
	lDelManual := aRet[1][8]
	lIncManual := aRet[1][9]
Else
	//Se retornar array vazio está OK também
	lRet := .T.
EndIf

aRet := {}
Aadd(aRet,{lRet,lDelManual,lIncManual})

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstInfoPDV³ Autor ³ Venda Clientes        ³ Data ³30/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista de documentos emitidos dentro de um periodo 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os dados dos DOCs emitidos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja												  	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LstInfoPDV( nHdlArq		, dDataIni		, dDataFim		, cPDV		,;
							lHomolPaf	, lTemIncManu	, aInfoArqPAF	, lReducao	)
Local cAlias		:= ""	// Alias utilizado para consulta dos dados na SLG
Local cQuery		:= ""		// Query para selecao de dados no banco de dados
Local cConteudo		:= ""
Local cLG_ECFINFO	:= ""
Local cSIGCnpj		:= ""
Local cSIGInsc		:= ""
Local lPosECFINFO	:= .T.		// Existe LG_ECFINFO ?
Local lPosALQINFO	:= .T.
Local lPosNFCE		:= .T.
Local lAltEst		:= .F.
Local aRetSLG		:= {}

Default lReducao	:= .F.

DbSelectArea("SLG")
lPosECFINFO := SLG->(ColumnPos("LG_ECFINFO")) > 0
lPosALQINFO := SLG->(ColumnPos("LG_ALQINFO")) > 0
lPosNFCE	:= SLG->(ColumnPos("LG_NFCE")) > 0

// usei somente para mudar o CNPJ da impressora pois
// no lobo-guara, no SIGACFG esta sendo validado o CNPJ
// a impressora usa um CNPJ 11111111111 que não é validado
/*RecLock("SM0",.F.) 
REPLACE SM0->M0_CGC WITH aInfoArqPAF[6][4]
REPLACE SM0->M0_INSC WITH aLLtRIM(aInfoArqPAF[6][10])
SM0->(MsUnlock())*/

cSIGCnpj := AllTrim(StrTran(StrTran(StrTran(SM0->M0_CGC,"."),"/"),"-"))
cSIGInsc := AllTrim(StrTran(StrTran(SM0->M0_INSC,"-"),"."))

If lHomolPaf .And.; 
	( cSIGCnpj <> aInfoArqPAF[6][4]  .Or. ;
	_CNPJTOT <> aInfoArqPAF[6][1] .Or. ;
	aInfoArqPAF[6][8] <> _INSCEST .Or. ;
	aInfoArqPAF[6][9] <> _INSCMUN .Or. ;		
	aInfoArqPAF[6][7] <>  _RAZSOC	.Or. ;
	aInfoArqPAF[6][2] <>  AllTrim(STBFMModPaf()) .Or.;
	aInfoArqPAF[6][6] <>  aInfoArqPAF[5] .Or.; 
	aInfoArqPAF[6][3] <>  STBVerPAFECF("MD5MASTER") .Or.;
	AllTrim(aInfoArqPAF[6][10]) <> cSIGInsc )

	lAltEst := .T.
EndIf

cAlias := "SLGTMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery := " SELECT "
cQuery += " LG_FILIAL, LG_CODIGO, LG_PDV, LG_SERIE,"
cQuery += " LG_IMPFISC, LG_SERPDV, LG_PAFMD5 "

If lHomolPaf
	cQuery += ", D_E_L_E_T_ Deletado"
EndIf

If lPosALQINFO
	cQuery += ", LG_ALQINFO "
EndIf

If lPosECFINFO
	cQuery += ",LG_ECFINFO "
Endif

IF lPosNFCE
	cQuery += ", LG_NFCE "
EndIf

cQuery += " FROM "+RetSqlName("SLG")
cQuery += " WHERE "
cQuery += " LG_FILIAL = '" + FwxFilial("SLG") + "'"

If lReducao
	cQuery += " AND LG_PDV = '"+ cPDV + "'"
Else
	cQuery += " AND LG_PDV <> '"+ cPDV +"'"
	If !lHomolPaf
		cQuery += " AND D_E_L_E_T_ = '' "
	EndIf
EndIf

cQuery := ChangeQuery( cQuery )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"LG_NFCE","L")
(cAlias)->(DbGoTop())

While !(cAlias)->(Eof())

	If lPosNFCE .And. (cAlias)->LG_NFCE
		(cAlias)->(DbSkip())
		Loop
	EndIf
	
	cLG_ECFINFO := IIF(lPosECFINFO,(cAlias)->LG_ECFINFO,"")
	STBDatIECF(lPosECFINFO,@aRetSLG,cLG_ECFINFO)
	
	cConteudo := "R01"  //1
	cConteudo += PADR( AllTrim((cAlias)->LG_SERPDV)	, 20 ) // 2 Numero de fabricacao do ECF
	cConteudo += PADR( aRetSLG[12], 01 ) // 3 Letra indicativa de MF adicional 
	cConteudo += PADR( aRetSLG[1], 07 )  // 4 Tipo de ECF
	cConteudo += PADR( IIF(At(" ",aRetSLG[8]) == 0 , "", SubStr(aRetSLG[8],1, At(" ",aRetSLG[8])-1)), 20 ) // 5 Marca do ECF
	If lHomolPaf
		//Inclusão Manual - o LG_PAFMD5 em Branco e LG_PDV Preenchido
		//Deleção Manual - o LG_PAFMD5 preenchido e estação deletada
		If	(Empty(AllTrim((cAlias)->Deletado)) .And. Empty(AllTrim((cAlias)->LG_PAFMD5))) .Or.;
		 	(!Empty(AllTrim((cAlias)->Deletado)) .And. !Empty((cAlias)->LG_PAFMD5) ) 
			
			lTemIncManu := .T.
		EndIF
	
		If (STxPafMd5(cAlias) <> (cAlias)->LG_PAFMD5) .Or. lAltEst .Or. !LJPRVldLG((cAlias)->LG_PAFMD5,AllTrim((cAlias)->LG_ECFINFO)+Upper(AllTrim((cAlias)->LG_IMPFISC)))
			cConteudo += StrTran(PADR( aRetSLG[2],20)," ","?") // 6 Modelo do ECF já validado com o PAFMD5
		Else
			cConteudo += PADR( aRetSLG[2], 20 ) // 6 Modelo do ECF já validado com o PAFMD5
		EndIf
	Else
		cConteudo += PADR( aRetSLG[2], 20 ) // 6 Modelo do ECF já validado com o PAFMD5
	EndIf
	cConteudo += PADR( StrTran(aRetSLG[3],"."), 10 ) // 7 Versão atual do Software Basico do ECF gravada na MF
	cConteudo += PADR( aRetSLG[4], 08 ) // 8 Data de instalacao da versao atual do Software Basico do ECF
	cConteudo += PADR( aRetSLG[5], 06 ) // 9 Horario de instalacao da versao atual do Software Basico do ECF
	If Len((cAlias)->LG_PDV) > 3
		cConteudo += StrZero(Val(Substr((cAlias)->LG_PDV,2,3)), 3)	// 10 No. de ordem sequencial do ECF no estabelecimento usuario - Num do PDV
	Else
		cConteudo += StrZero(Val((cAlias)->LG_PDV), 3) 				// 10 No. de ordem sequencial do ECF no estabelecimento usuario - Num do PDV
	EndIf

	If lAltEst //só fica true em homologacao
		cConteudo += StrZero(Val(aInfoArqPAF[6][4]), 14 ) // 11 CNPJ do estabelecimento usuario do ECF - Sigamat
		cConteudo += PADR( aInfoArqPAF[6][10]	, 14 ) // 12 Inscricao Estadual do estabelecimento usuario - Sigamat
		cConteudo += StrZero(Val(aInfoArqPAF[6][1]), 14 ) // 13 CNPJ da empresa desenvolvedora do PAF-ECF - Totvs
		cConteudo += PADR( aInfoArqPAF[6][8]	, 14 ) // 14 Inscricao Estadual da empresa desenvolvedora do PAF-ECF, se houver - Totvs
		cConteudo += PADR( aInfoArqPAF[6][9]	, 14 ) // 15 Inscricao Municipal da empresa desenvolvedora do PAF-ECF, se houver - Totvs		
		cConteudo += PADR( aInfoArqPAF[6][7]	, 40 ) // 16 Denominacao da empresa desenvolvedora do PAF-ECF - Razao social
		cConteudo += PADR( aInfoArqPAF[6][2]	, 40 ) // 17 Nome Comercial do PAF-ECF - GetVersao
		cConteudo += PADR( aInfoArqPAF[6][6]	, 10 )  //18 Versão atual do PAF-ECF
		cConteudo += PADR( aInfoArqPAF[6][3]	, 32 ) // 19 Codigo MD5 do principal arquivo executavel do PAF-ECF - Lojxecf - Ljxmd5
	Else
		cConteudo += StrZero(Val(cSIGCnpj), 14 ) // 11 CNPJ do estabelecimento usuario do ECF - Sigamat
		cConteudo += PADR( cSIGInsc , 14 ) // 12 Inscricao Estadual do estabelecimento usuario - Sigamat
		cConteudo += StrZero(Val(aInfoArqPAF[1]), 14 ) // 13 CNPJ da empresa desenvolvedora do PAF-ECF - Totvs
		cConteudo += PADR(_INSCEST	, 14 ) // 14 Inscricao Estadual da empresa desenvolvedora do PAF-ECF, se houver - Totvs
		cConteudo += PADR(_INSCMUN	, 14 ) // 15 Inscricao Municipal da empresa desenvolvedora do PAF-ECF, se houver - Totvs
		cConteudo += PADR(_RAZSOC	, 40 ) // 16 Denominacao da empresa desenvolvedora do PAF-ECF - Razao social
		cConteudo += PADR( aInfoArqPAF[2], 40 ) // 17 Nome Comercial do PAF-ECF - GetVersao
		cConteudo += PADR( aInfoArqPAF[5], 10 )  //18 Versão atual do PAF-ECF
		cConteudo += PADR( aInfoArqPAF[3], 32 ) // 19 Codigo MD5 do principal arquivo executavel do PAF-ECF - Lojxecf - Ljxmd5 
	EndIf

	cConteudo += PADR( DtoS(dDataIni)		, 08 ) // 20 Data do inicio do periodo informado no arquivo
	cConteudo += PADR( DtoS(dDataFim)		, 08 ) // 21 Data do fim do periodo informado no arquivo
	cConteudo += PADR( StrTran(STBVerPAFECF( "ERPAFECF" ),"."), 04 ) // 22 Versão da Especificacao de Requisitos do PAF-ECF
	cConteudo += CHR(13) + CHR(10)
	
	If !lHomolPaf .Or. (lHomolPaf .And. Empty(AllTrim((cAlias)->Deletado))) //Se estiver deletado em branco vai pro arquivo 
		FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	EndIf
	
	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

Return nHdlArq

//---------------------------------------------------------------------------
/*/
{Protheus.Doc} LstVndManu
lista de vendas manuais ( NF [manual e nota CF], NFCe e NF-e)

@author Varejo
@version P12
@since   17/05/2017
@return  lRet , Boolean , Retorno
/*/
//---------------------------------------------------------------------------
Static Function LstVndManu (nHdlArq	 , dDataIni  ,dDataFim	 ,cPDV,;
							lHomolPaf,lTemIncManu, lIsPafNfce)
Local cFilSF2		:= ""
Local cFilSA1		:= ""
Local cNomCli		:= ""
Local cCGCCli		:= ""
Local cSF2Tmp		:= ""
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local cConteudo		:= ""
Local lCancelado	:= .F.
Local lDadoCli		:= .F.
Local lNewField		:= .F.
Local lPafMD5Ok		:= .T.
Local nPos			:= 0
Local nAcrescimo	:= 0
Local nTotalValid	:= 0
Local nTotalSF2		:= 0
Local nCount		:= 0
Local LstVndNFMn	:= {}
Local aAreasTab		:= {}

Default lIsPafNfce	:= .F. 

lDadoCli:= .T.

cFilSF2	:= xFilial("SF2")
cFilSA1	:= xFilial("SA1")
cPDV := AllTrim(cPDV)

DbSelectArea("SF2")
DbSelectArea("SF3")
SF3->(DbSetOrder(6)) //F3_FILIAL, F3_NFISCAL, F3_SERIE

aadd(aAreasTab,SF2->(GetArea()))
aadd(aAreasTab,SF3->(GetArea()))
aadd(aAreasTab,SA1->(GetArea()))

lNewField := SF2->(ColumnPos("F2_PAFMD5")) > 0

//Para validar a deleção: excluir SF2 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

		DbSelectArea("SF2")
		SF2->(DbSetOrder(3)) //F2_FILIAL, F2_ECF, F2_EMISSAO, F2_PDV, F2_SERIE, F2_MAPA, F2_DOC
		SF2->(DbSeek(cFilSF2+ Space(TamSx3("F2_ECF")[1]) + DtoS(dDataIni),.T.))
	
		While !SF2->(Eof()) .AND. SF2->F2_EMISSAO <= dDataFim
			If ( (Empty(cPDV) .AND. !Empty(SF2->F2_PDV) ) .OR.  AllTrim(SF2->F2_PDV) == cPDV ) ;
			.AND. !Empty(SF2->F2_DOC) .AND. (AllTrim(SF2->F2_ESPECIE) $ "SPED|NFCE|NFCF|NF|NFM") .And. SF2->F2_FILIAL == cFilSF2
	
				lCancelado := SF3->(DbSeek(xFilial("SF3")+SF2->(F2_DOC+F2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV)) //Notas Canceladas tbm são validas				
	
				If ! Empty(AllTrim(SF2->F2_DOC)) .And. ((!SF2->(Deleted()) .And. !lCancelado) .Or. (SF2->(Deleted()) .And. lCancelado))					
					nTotalValid++				
				EndIf
	
				nTotalSF2++
			EndIf
			SF2->(DbSkip())
		EndDo

	SET DELETED ON

	If nTotalSF2 <> nTotalValid
		lTemIncManu := .T.
	EndIf
EndIf

cSF2Tmp	:= "SF2TMP"
If Select(cSF2Tmp) > 0
	(cSF2Tmp)->(DbCloseArea())
EndIf

cQuery	:= " SELECT "
cQuery	+= " SF2.F2_FILIAL,SF2.F2_CHVNFE,SF2.F2_ESPECIE,SF2.F2_DESCONT,SF2.F2_VALBRUT,SF2.F2_PDV,SF2.F2_ECF, "   
cQuery	+= " SF2.F2_EMISSAO,SF2.F2_VALFAT,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_CGCCLI,SF2.F2_DOC,SF2.F2_SERIE, "
cQuery	+= " SF2.D_E_L_E_T_ as Deletado,"
If lNewField
	cQuery	+= " SF2.F2_PAFMD5,"
EndIf
cQuery 	+= " SA1.A1_NOME, SA1.A1_CGC "
cQuery	+= " FROM " + RetSqlName("SF2") + " SF2 "
cQuery	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery	+= " ON SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= " WHERE "
cQuery	+= " SF2.F2_FILIAL ='" + cFilSF2 + "'"
cQuery	+= " AND SF2.F2_DOC <> ' ' "
cQuery	+= " AND (SF2.F2_ESPECIE IN ('SPED','NFCE','NF','NFCF','NFM') ) " //Modelo 55,65, Nota Manual e Cupom Sobre Nota
cQuery	+= " AND SF2.F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "  

If !Empty(cPDV)
	cQuery	+= " AND F2_PDV = '" + cPDV + "' "
EndIf
/*************************************************************************************************
******* ANOTAÇÃO IMPORTANTE *******
//"SF2.D_E_L_E_T_ = ' '  "
//Não insere o D_E_L_E_T_ aqui pois quando tenho estorno da Danfe ele apaga a SF2 e marca na SF3
*************************************************************************************************/
cQuery	+= "ORDER BY F2_EMISSAO,F2_DOC"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSF2Tmp, .F., .T.)
TcSetField(cSF2Tmp,"F2_EMISSAO","D")
(cSF2Tmp)->(DbGoTop())

While !(cSF2Tmp)->(Eof())
	
	//Se não tiver o numero da DANFE não pode aparecer no registro do PAF
	If Empty(AllTrim((cSF2Tmp)->F2_CHVNFE)) .And. ;
		(AllTrim((cSF2Tmp)->F2_ESPECIE) == "SPED" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCE")
		
		(cSF2Tmp)->(DbSkip())
		Loop
	EndIf

	//Alterar: o F2_CLIENTE para um cliente valido para mostrar no registro 
	cNomCli		:= (cSF2Tmp)->A1_NOME
	cCGCCli		:= StrTran(StrTran(StrTran((cSF2Tmp)->F2_CGCCLI,"-"),"/"),".")
	nAcrescimo	:= (cSF2Tmp)->F2_VALFAT - (cSF2Tmp)->F2_VALBRUT
	lCancelado	:= .F.

	If SF3->(DbSeek(xFilial("SF3")+(cSF2Tmp)->(F2_DOC+F2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV))		
		lCancelado	:= .T.
	EndIf
	
	If !lCancelado .And. !Empty(AllTrim((cSF2Tmp)->Deletado)) .And. !Empty(AllTrim((cSF2Tmp)->F2_PAFMD5)) //Não pode inserir o registro deletado manualmente
		lTemIncManu := .T.
		(cSF2Tmp)->(DbSkip())
		Loop
	EndIf
	
	ASize(LstVndNFMn,0)
	AAdd(LstVndNFMn,Array(18))
	nPos := Len(LstVndNFMn)

	LstVndNFMn[nPos][1]	:= StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"/"),".") 
	LstVndNFMn[nPos][2]	:= (cSF2Tmp)->F2_EMISSAO
	LstVndNFMn[nPos][3]	:= (cSF2Tmp)->F2_VALBRUT
	LstVndNFMn[nPos][4]	:= (cSF2Tmp)->F2_DESCONT
	LstVndNFMn[nPos][5]	:= IIf(nAcrescimo > 0, nAcrescimo , 0)
	LstVndNFMn[nPos][6]	:= IIf((cSF2Tmp)->F2_DESCONT > 0, "V", " ")
	LstVndNFMn[nPos][7]	:= IIf(nAcrescimo > 0, "V" , " ")
	LstVndNFMn[nPos][8]	:= (cSF2Tmp)->F2_VALFAT
	//Para Validar a alteração de cancelamento - Altere o SF3 (F3_OBSERV) e F2_ECF com isso vai validar MD5 em branco e dar erro no registro
	LstVndNFMn[nPos][9]	:= lCancelado	//Indicador de Cancelamento
	LstVndNFMn[nPos][10]:= If( lCancelado , nAcrescimo , 0 ) //Indicador de cancelamento do acrescimo 
	LstVndNFMn[nPos][11]:= IIf(nAcrescimo > 0, "A" , IIf((cSF2Tmp)->F2_DESCONT > 0, "D", " "))
	LstVndNFMn[nPos][12]:= cNomCli
	LstVndNFMn[nPos][13]:= Val(cCGCCli) 
	LstVndNFMn[nPos][14]:= Val((cSF2Tmp)->F2_DOC)
	LstVndNFMn[nPos][15]:= (cSF2Tmp)->F2_SERIE

	If AllTrim((cSF2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCF" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFM" 
		LstVndNFMn[nPos][16]:= StrZero(0,44)
	Else
		LstVndNFMn[nPos][16]:= AllTrim((cSF2Tmp)->F2_CHVNFE)
	EndIf
	
	If Len(LstVndNFMn[nPos][16]) > 44
		LstVndNFMn[nPos][16] := SubStr(LstVndNFMn[nPos][16],1,44)
	EndIf
 
	Do Case
		Case AllTrim((cSF2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCF" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFM"
			LstVndNfMn[nPos][17]:= 1

		Case AllTrim((cSF2Tmp)->F2_ESPECIE) == "SPED"
			LstVndNFMn[nPos][17]:= 2

		Case AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCE"
			LstVndNFMn[nPos][17]:= 3
	EndCase    

	/* Gera/Valida chave MD5 dos Registros */
	cPafMd5 := STxPafMd5(cSF2Tmp)		    

	/*
	If lHomolPaf
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
		SF2->(MsSeek((cSF2Tmp)->(F2_FILIAL+F2_DOC+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
		RecLock("SF2",.F.)
		REPLACE SF2->F2_PAFMD5 WITH cPafMd5
		SF2->(MsUnlock())
	EndIf
	*/
	If lNewField .And. lHomolPaf
		If lCancelado
			If !Empty((cSF2Tmp)->F2_PAFMD5)
				lPafMD5Ok := (cSF2Tmp)->F2_PAFMD5 == cPafMd5
			Else
				lPafMD5Ok := .T.
			EndIf
		Else
			lPafMD5Ok := (cSF2Tmp)->F2_PAFMD5 == cPafMd5
		EndIf
	Else
		lPafMD5Ok := .T.
	EndIf
	
	LstVndNFMn[nPos][18] := lPafMD5Ok
	
	//************************************************************************************
	//Valida Inclusão do registro via Banco de Dados, F2_PAFMD5 em branco - Teste Bloco VII
	//************************************************************************************
	If lNewField .And. lHomolPaf .And. Empty(AllTrim((cSF2Tmp)->F2_PAFMD5)) .And. !lTemIncManu
		lTemIncManu := IIf(lCancelado,.F.,.T.)
	EndIf
	
	//Escreve o arquivo
	cConteudo := "J1" 											//1-Tipo
	cConteudo += LstVndNFMn[nPos][1] 							//2-CNPJ 
	cConteudo += PadR(Dtos(LstVndNFMn[nPos][2]),8) 				//3-Data Emissao
	cConteudo += StrTran(StrZero(LstVndNFMn[nPos][3],15,2),".") //4-Valor do documento
	cConteudo += StrTran(StrZero(LstVndNFMn[nPos][4],14,2),".") //5-Desconto sobre subtotal
	cConteudo += PadR(LstVndNFMn[nPos][6],1)  					//6-Ind. Tipo de Desconto
	cConteudo += StrTran(StrZero(LstVndNFMn[nPos][5],14,2),".") //7-Acrescimo sobre subtotal
	cConteudo += PadR(LstVndNFMn[nPos][7],1) 					//8-Ind. Tipo de Acrescimo 
	cConteudo += StrTran(StrZero(LstVndNFMn[nPos][8],15,2),".") //9-Valor total Liquido
	If lIsPafNfce
		cConteudo += Str(LstVndNFMn[nPos][17],1)						//10-Tipo de emissão (tpEmis)
		cConteudo += LstVndNFMn[nPos][16] 						//11-Chave de acesso da NFC-e
		cConteudo += StrZero(LstVndNFMn[nPos][14],10)			//12-Número da NFC-e
		cConteudo += PadR(LstVndNFMn[nPos][15],3)				//13-Série da NFC-e
		cConteudo += StrZero(LstVndNFMn[nPos][13],14)			//14-CPF/CNPJ do adquirente
	Else 
		cConteudo += IIf(LstVndNFMn[nPos][9],"S","N") 				//10-Indicador de cancelamento
		cConteudo += StrTran(StrZero(LstVndNFMn[nPos][10],14,2),".")//11-Cancelamento de acrescimo no subtotal
		cConteudo += PadR(LstVndNFMn[nPos][11],1) 					//12-Ordem de aplicacao de desc e acresc
		cConteudo += PadR(LstVndNFMn[nPos][12],40)					//13-Nome do adquirente
		cConteudo += StrZero(LstVndNFMn[nPos][13],14)				//14-CPF/CNPJ do Adquirente
		cConteudo += StrZero(LstVndNFMn[nPos][14],10)				//15-Numero da Nota Fiscal
		cConteudo += PadR(LstVndNFMn[nPos][15],3)					//16-Serie da Nota Fiscal
		cConteudo += LstVndNFMn[nPos][16] 							//17-Chave de acesso da NFce/NF-e
		
		//18-Tipo de documento
		If lHomolPaf .And. (!LstVndNFMn[nPos][18] .Or. lTemIncManu)
			cConteudo += "??"
		Else
			cConteudo += StrZero(LstVndNFMn[nPos][17],2)
		EndIf
	Endif 

	cConteudo += CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )
	
	If nCount > 50
		LJRPLogProc(" Registros J1 [Em Execução...]")
		nCount := 0
	EndIf
	
	(cSF2Tmp)->(DbSkip())
End

(cSF2Tmp)->(DbCloseArea())

For nPos := 1 to Len(aAreasTab)
	RestArea(aAreasTab[nPos])
Next nPos

Return nHdlArq

//---------------------------------------------------------------------------
/*/
{Protheus.Doc} LstItVdManu
lista os itens de vendas manuais ( NF [manual e nota CF], NFCe e NF-e)

@author Varejo
@version P12
@since   17/05/2017
@return  lRet , Boolean , Retorno
/*/
//---------------------------------------------------------------------------
Static Function LstItVdManu( nHdlArq	,dDataIni	,dDataFim	,cPDV	,;
							 lHomolPaf	,lTemIncManu, lIsPafNfce )
Local cFilSF2		:= ""
Local cFilSA1		:= ""
Local cNomCli		:= ""
Local cSD2Tmp		:= ""
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local cTotParc		:= ""
Local cConteudo		:= ""
Local nPos			:= 0
Local nAcrescimo	:= 0
Local nSizeFile		:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nVldSd2		:= 0
Local nTotalReg		:= 0
Local nCount		:= 0
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local lCancelado	:= .F.
Local lDadoCli		:= .F.  
Local lPAFSL2MD5	:= .T.
Local lPAFSB1MD5	:= .T.
Local lMd5OK		:= .T.
Local lNewField		:= .F.
Local lSB1Found		:= .F.
Local cPAFSL2MD5	:= ""
Local cPAFSB1MD5	:= ""
Local cCest			:= ""
Local cPosIPI		:= ""
Local LstItVndNFMn	:= {}
Local aAreasTab		:= {}

Default lIsPafNfce	:= .F. 

DbSelectArea("SD2")
DbSelectArea("SF2")
DbSelectArea("SA1")

lDadoCli	:= .T.
nQtdDecQuant:= TamSX3("D2_QUANT")[2]
nQtdDecVUnit:= TamSX3("D2_PRUNIT")[2]
cFilSF2		:= xFilial("SF2")
cFilSA1		:= xFilial("SA1")
cPDV		:= AllTrim(cPDV)

lNewField:= SD2->(ColumnPos("D2_DECQTD")) > 0

/*
//Trecho inserido para em caso de necessidade incluir MD5 nos campos
If lHomolPaf
	DbSelectArea("SF2")
	DbSelectArea("SD2")
	SF2->(DbSetOrder(1))
	SD2->(DbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
	While !SD2->(Eof())
		SF2->(DbSeek(SD2->D2_FILIAL+SD2->D2_DOC))
		cPafMd5 := STxPafMd5("SD2")
		RecLock("SD2",.F.)
		REPLACE SD2->L2_PAFMD5 WITH cPafMd5
		SD2->(MsUnlock())
		SD2->(DbSkip())
	EndDo
EndIf	
*/

DbSelectArea("SF3")
DbSelectArea("SA1")
DbSelectArea("SB1")
DbSelectArea("SL1")
DbSelectArea("SL2")

Aadd(aAreasTab,SF3->(GetArea()))
Aadd(aAreasTab,SA1->(GetArea()))
Aadd(aAreasTab,SB1->(GetArea()))
Aadd(aAreasTab,SL1->(GetArea()))
Aadd(aAreasTab,SL2->(GetArea()))

SF3->(DbSetOrder(6)) //F3_FILIAL, F3_NFISCAL, F3_SERIE
SA1->(DbSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA
SB1->(DbSetOrder(1)) //B1_FILIAL, B1_COD
SL1->(DbSetOrder(2)) //L1_FILIAL, L1_SERIE, L1_DOC, L1_PDV
SL2->(DbSetOrder(1)) //L2_FILIAL, L2_NUM, L2_ITEM, L2_PRODUTO

//Para validar a deleção: excluir SD2 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

		DbSelectArea("SF2")
		DbSelectArea("SD2")
		
		Aadd(aAreasTab,SF2->(GetArea()))
		Aadd(aAreasTab,SD2->(GetArea()))
		
		SD2->(DbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
		SF2->(DbSetOrder(3)) //F2_FILIAL, F2_ECF, F2_EMISSAO, F2_PDV, F2_SERIE, F2_MAPA, F2_DOC
		SF2->(DbSeek(cFilSF2+ Space(TamSx3("F2_ECF")[1]) + DtoS(dDataIni),.T.))
	
		While !SF2->(Eof()) .AND. SF2->F2_EMISSAO <= dDataFim
			SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	
			While SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
	
				lCancelado := SF3->(DbSeek(xFilial("SF3")+SF2->(F2_DOC+F2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV)) //Notas Canceladas tbm são validas
	
				If  ( SD2->(Deleted()) .And. ! Empty(AllTrim(SD2->D2_DOC)) .And. !lCancelado )				
					lTemIncManu := .T.
				EndIf
				SD2->(DbSkip())
			EndDo
			SF2->(DbSkip())
		EndDo

	SET DELETED ON
EndIf

lCancelado := .F.
cSD2Tmp	:= "SD2TMP"
If Select(cSD2Tmp) > 0
	(cSD2Tmp)->(DbCloseArea())
EndIf

cQuery	:= " SELECT "
cQuery	+= " F2_FILIAL,F2_CHVNFE,F2_ESPECIE,F2_CGCCLI,F2_DOC,F2_SERIE,SF2.D_E_L_E_T_ DelSF2,"

If lNewField
	cQuery += "F2_PAFMD5,D2_DECQTD,D2_DECVLU,D2_PAFMD5,"
EndIf

cQuery	+= " D2_ITEM,D2_DOC,D2_DESC,D2_PRCVEN,D2_PDV,D2_EMISSAO, "   
cQuery	+= " D2_QUANT,D2_TOTAL,D2_CLIENTE,D2_LOJA,D2_COD, "
cQuery	+= " D2_UM,D2_PRUNIT,D2_DESCON,D2_VALACRS, D2_PICM,D2_ALIQISS,"
cQuery	+= " D2_SERIE,D2_TES,D2_FILIAL,SD2.D_E_L_E_T_ DelSD2"

cQuery	+= " FROM " + RetSqlName("SD2") + " SD2 "
cQuery	+= " INNER JOIN " + RetSqlName("SF2") + " SF2 "
cQuery	+= " ON F2_FILIAL='"+cFilSF2+"' AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE "
cQuery	+= " AND (F2_ESPECIE = 'SPED' OR F2_ESPECIE = 'NFCE' OR F2_ESPECIE = 'NF' OR F2_ESPECIE = 'NFCF' OR F2_ESPECIE = 'NFM') " //Modelo Manual,55 ou 65

/*Removido o D_E_L_E_T_ pois em notas canceladas os dados são deletados*/
//cQuery	+= " AND SF2.D_E_L_E_T_ = ' ' "
//cQuery	+= " WHERE SD2.D_E_L_E_T_ = ' '  "

cQuery	+= " WHERE D2_EMISSAO BETWEEN '"+ DtoS(dDataIni) +"' AND '"+ Dtos(dDataFim) +"' "  
cQuery	+= "AND D2_DOC <> ' ' "
cQuery	+= "AND D2_FILIAL = '" + cFilSF2 + "'"
If !Empty(cPDV)
	cQuery	+= " AND D2_PDV = '" + cPDV + "' "
EndIf

cQuery	+= " ORDER BY D2_EMISSAO,D2_DOC "

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSD2Tmp, .F., .T.)
TcSetField(cSD2Tmp,"D2_EMISSAO","D")
(cSD2Tmp)->(DbGoTop())

While !(cSD2Tmp)->(Eof())

	//Se não tiver o numero da DANFE não pode aparecer no registro do PAF
	If (Empty(AllTrim((cSD2Tmp)->F2_CHVNFE)) .And. ;
		(AllTrim((cSD2Tmp)->F2_ESPECIE) == "SPED" .Or.  AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCE"))
		(cSD2Tmp)->(DbSkip())
		Loop
	EndIf

	cNomCli := ""
	If SA1->(DbSeek(cFilSA1+(cSD2Tmp)->(D2_CLIENTE+D2_LOJA)))
		cNomCli	:= SA1->A1_NOME
	EndIf

	nAcrescimo	:= (cSD2Tmp)->D2_VALACRS
	lCancelado	:= .F.
	lPAFSL2MD5	:= .T.
	lPAFSB1MD5  := .T.
	cPAFSL2MD5	:= ""
	cPAFSB1MD5  := ""

	If SF3->(DbSeek(xFilial("SF3")+(cSD2Tmp)->(D2_DOC+D2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV))		
		lCancelado	:= .T.
	EndIf
	
	//Não pode mostrar o registro deletado manualmente
	If	(!lCancelado .And. !Empty(AllTrim((cSD2Tmp)->DelSF2)) .And. !Empty(AllTrim((cSD2Tmp)->F2_PAFMD5))) .Or.;
		(!lCancelado .And. !Empty(AllTrim((cSD2Tmp)->DelSD2)) .And. !Empty(AllTrim((cSD2Tmp)->D2_PAFMD5)))
		lTemIncManu := .T.
		(cSD2Tmp)->(DbSkip())
		Loop
	EndIf

	ASize(LstItVndNFMn,0)
	AAdd(LstItVndNFMn,Array(20))
	nPos := Len(LstItVndNFMn)
	nCount++

	LstItVndNFMn[nPos][1]	:= StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"/"),".") 
	LstItVndNFMn[nPos][2]	:= (cSD2Tmp)->D2_EMISSAO
	LstItVndNFMn[nPos][3]	:= Val((cSD2Tmp)->D2_ITEM)
	LstItVndNFMn[nPos][4]	:= (cSD2Tmp)->D2_COD
	
	lSB1Found := SB1->(DbSeek(xFilial("SB1")+(cSD2Tmp)->D2_COD))
	
	//Para validar interrogacoes aqui, altera o SB1 e o SL2
	//efetuo a pesquisa na SL2 pois se houver alteração do SB1 mantem o que foi impresso no cupom
	If AllTrim((cSD2Tmp)->F2_ESPECIE) == 'NF' .OR. AllTrim((cSD2Tmp)->F2_ESPECIE) == 'NFCF' .Or. AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFM"
		SL1->(DbSeek(xFilial("SL1")+(cSD2Tmp)->F2_SERIE+(cSD2Tmp)->F2_DOC+(cSD2Tmp)->D2_PDV))
		SL2->(DbSeek(SL1->(L1_FILIAL+L1_NUM)+(cSD2Tmp)->D2_ITEM))

		LstItVndNFMn[nPos][5]	:= AllTrim(SL2->L2_DESCRI)
		cPAFSL2MD5 := AllTrim(SL2->L2_PAFMD5)
		
	ElseIf lSB1Found
		cCest := Alltrim(SB1->B1_CEST)
		If Empty(cCest)
			cCest := Replicate("0",TamSX3("B1_CEST")[1])
		EndIf
		
		cPosIPI := Alltrim(SB1->B1_POSIPI)
		If Empty(cPosIPI)
			cPosIPI := Replicate("0",TamSX3("B1_POSIPI")[1])
		EndIf
		
		If lIsPafNfce
			LstItVndNFMn[nPos][5] :=  Alltrim(SB1->B1_DESC)
		Else
			LstItVndNFMn[nPos][5] := "#" + cCest + "#" + cPosIPI + "#" + Alltrim(SB1->B1_DESC)
		Endif 
		cPAFSB1MD5 := AllTrim(SB1->B1_PAFMD5)
	Else
		LstItVndNFMn[nPos][5] := "ProdutoPadrao"
		LJRPLogProc("Atenção o produto de código [" + (cSD2Tmp)->D2_COD + "] "+;
					" não consta na SB1, vide se o mesmo foi deletado! Para que ele seja mostrado é necessário recuperar esse produto") 
	EndIf
	
	LstItVndNFMn[nPos][6]	:= (cSD2Tmp)->D2_QUANT * &("1" + Replicate("0",nQtdDecQuant))
	LstItVndNFMn[nPos][7]	:= (cSD2Tmp)->D2_UM
	LstItVndNFMn[nPos][8]	:= (cSD2Tmp)->D2_PRUNIT
	LstItVndNFMn[nPos][9]	:= (cSD2Tmp)->D2_DESCON
	LstItVndNFMn[nPos][10]	:= IIf(nAcrescimo > 0, nAcrescimo , 0)
	LstItVndNFMn[nPos][11]	:= (cSD2Tmp)->D2_TOTAL

	If (cSD2Tmp)->D2_PICM > 0 
		cTotParc := 'T' + StrTran(StrTran(StrZero((cSD2Tmp)->D2_PICM,5,2),","),".")
	ElseIf (cSD2Tmp)->D2_ALIQISS > 0
		cTotParc := 'S' + StrTran(StrTran(StrZero((cSD2Tmp)->D2_ALIQISS,5,2),","),".")
	Else
		cTotParc := 'T' + StrTran(StrTran(StrZero(SuperGetMV("MV_ICMPAD",,18),5,2),","),".")
	EndIf

	LstItVndNFMn[nPos][12]	:= cTotParc
	LstItVndNFMn[nPos][13]	:= .F. //lCancelado	//Indicador de Cancelamento
	
	If lNewField
		// PARA NF-e: os campos são preenchidos somente se eu peço pra imprimir a NF-e, 
		// caso não tenha emitido eu insiro os valores conforme o dicionário 
		LstItVndNFMn[nPos][14]	:= Iif((cSD2Tmp)->D2_DECQTD > 0, (cSD2Tmp)->D2_DECQTD, nQtdDecQuant)
		LstItVndNFMn[nPos][15]	:= Iif((cSD2Tmp)->D2_DECVLU > 0, (cSD2Tmp)->D2_DECVLU, nQtdDecVUnit)
	Else
		LstItVndNFMn[nPos][14]	:= nQtdDecQuant
		LstItVndNFMn[nPos][15]	:= nQtdDecVUnit
	EndIf
	
	LstItVndNFMn[nPos][16]	:= Val((cSD2Tmp)->D2_DOC)
	LstItVndNFMn[nPos][17]	:= (cSD2Tmp)->D2_SERIE

	If AllTrim((cSD2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCF" .Or. AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFM"
		LstItVndNFMn[nPos][18]	:= StrZero(0,44)
	Else
		LstItVndNFMn[nPos][18]	:= (cSD2Tmp)->F2_CHVNFE
	EndIf
	
	If Len(LstItVndNFMn[nPos][18]) > 44
		LstItVndNFMn[nPos][18] := SubStr(LstItVndNFMn[nPos][18],1,44)
	EndIf

	//o teste de alteração deve ser feito no 
	Do Case
		Case AllTrim((cSD2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCF" .Or. AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFM"
		LstItVndNFMn[nPos][19]	:= 1

		Case AllTrim((cSD2Tmp)->F2_ESPECIE) == "SPED"
		LstItVndNFMn[nPos][19]	:= 2

		Case AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCE"
		LstItVndNFMn[nPos][19]	:= 3
	EndCase
	
	If lHomolPaf
		/* Gera/Valida chave MD5 dos Registros */
		cPafMd5 := STxPafMd5(cSD2Tmp,(cSD2Tmp)->(AllTrim(F2_CHVNFE)+AllTrim(F2_ESPECIE)))	    
	
		/*
		If lHomolPaf
			DbSelectArea("SF2")
			SF2->(DbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
			SF2->(MsSeek((cSD2Tmp)->(F2_FILIAL+F2_DOC+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
			RecLock("SF2",.F.)
			REPLACE SF2->F2_PAFMD5 WITH cPafMd5
			SF2->(MsUnlock())
		EndIf
		*/
	
		If !Empty(cPAFSL2MD5)
			lPAFSL2MD5 := STxPafMd5("SL2", SL1->L1_NUMORC) == cPAFSL2MD5
		ElseIf !Empty(cPAFSB1MD5)
			lPAFSB1MD5 := STxPafMd5("SB1") == cPAFSB1MD5
		EndIf
	
		If lNewField
			If lCancelado
				If !Empty((cSD2Tmp)->D2_PAFMD5)
					lMd5OK := (cSD2Tmp)->D2_PAFMD5 == cPafMd5  .And. lPAFSL2MD5 .And. lPAFSB1MD5
				Else
					lMd5OK := .T.
				EndIf
			Else
				lMd5OK := (cSD2Tmp)->D2_PAFMD5 == cPafMd5 .And. lPAFSL2MD5 .And. lPAFSB1MD5
			EndIf
			
			//************************************************************************************
			//Valida Inclusão do registro via Banco de Dados, D2_PAFMD5 em branco - Teste Bloco VII
			//************************************************************************************
			If Empty(AllTrim((cSD2Tmp)->D2_PAFMD5)) .And. !lTemIncManu
				lTemIncManu := IIf(lCancelado,.F.,.T.)
			EndIf
		EndIf
	Else
		lMd5OK := .T.
	EndIf
	
	LstItVndNFMn[nPos][20] := lMd5OK
	
	//Escreve o arquivo
	cConteudo := "J2" //Tipo
	cConteudo += LstItVndNFMn[nPos][1] //2-CNPJ 
	cConteudo += PadR(Dtos(LstItVndNFMn[nPos][2]),8) //3-Data Emissao
	cConteudo += StrZero(LstItVndNFMn[nPos][3],3) //4-Numero do item
	cConteudo += PadR(LstItVndNFMn[nPos][4],14)	// 05- Código do Item
	cConteudo += PadR(LstItVndNFMn[nPos][5],100)		 	// 06- Descrição
	cConteudo += StrZero(LstItVndNFMn[nPos][6],7)		 	// 07- Quantidade
	cConteudo += PadR(LstItVndNFMn[nPos][7],3)		 		// 08- Unidade de Medida
	cConteudo += StrTran(StrZero(LstItVndNFMn[nPos][8],9,2),".") 	//09- Valor Unitário
	cConteudo += StrTran(StrZero(LstItVndNFMn[nPos][9],9,2),'.')	// 10- Desconto sobre item
	cConteudo += StrTran(StrZero(LstItVndNFMn[nPos][10],9,2),'.')	// 11- Acrescimo sobre item
	cConteudo += StrTran(StrZero(LstItVndNFMn[nPos][11],15,2),'.')		// 12- Valor líquido
	cConteudo += PadR(LstItVndNFMn[nPos][12], 07)						// 13- Totalizador Parcial
	cConteudo += StrZero(LstItVndNFMn[nPos][14], 1)			// 14- Casas decimais da quantidade
	cConteudo += StrZero(LstItVndNFMn[nPos][15], 1)			// 15- Casas decimais do valor unitário
	cConteudo += StrZero(LstItVndNFMn[nPos][16],10)			// 16- Numero da Nota Fiscal
	cConteudo += PadR(LstItVndNFMn[nPos][17],3)				// 17- Serie da Nota Fiscal
	cConteudo += LstItVndNFMn[nPos][18] //18-Chave de acesso da NFce/NF-e
	

	If !lIsPafNfce
		//19-Tipo de documento
		If lHomolPaf .And. (!LstItVndNFMn[nPos][20] .Or. lTemIncManu)
			cConteudo += "??"
		Else
			cConteudo += StrZero(LstItVndNFMn[nPos][19],2)
		EndIf
	Endif 

	cConteudo += CHR(13) + CHR(10)
	FWRITE( nHdlArq, cConteudo, LEN( cConteudo ) )	
	
	If nCount > 50
		LJRPLogProc(" Registros J2 [Em Execução...]")
		nCount := 0
	EndIf
	
	(cSD2Tmp)->(DbSkip())
End

(cSD2Tmp)->(DbCloseArea())

For nPos := 1 to Len(aAreasTab)
	RestArea(aAreasTab[nPos])
Next nPos

Return nHdlArq

//--------------------------------------------------------
/*/{Protheus.doc}STBLstPDV
 Captura todos os PDV 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
/*/
//--------------------------------------------------------
Static Function STBLstPDV(nOpc)
Local aRet := {}
Local aArea:= {}
Default nOpc := 0

If nOpc == 1
	ASize(aLstPDVs,0)
EndIf

If Len(aLstPDVs) == 0
	DbSelectArea("SLG")	
	Aadd(aArea,SLG->(GetArea()))	
	SLG->(DbSeek(xFilial("SLG")))
	SLG->(DbGoTop())
	While !SLG->(Eof()) 
		Aadd(aRet,{	AllTrim(Upper(SLG->LG_SERPDV)),;
					AllTrim(SLG->LG_ECFINFO),;
					SLG->(Recno()),;
					AllTrim(SLG->LG_PAFMD5),;
					AllTrim(Upper(SLG->LG_IMPFISC)),;
					AllTrim(SLG->LG_ALQINFO)})
		SLG->(DbSkip())
	End
	
	RestArea(aArea[1])
	aLstPDVs := aClone(aRet)
	LJRPLogProc("Pesquisa da SLG","STBLstPDV",aLstPDVs)
Else
	aRet := aClone(aLstPDVs)
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}STBRetPDV
 Captura todos os PDV 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@sample
/*/
//--------------------------------------------------------
Static Function STBRetPDV(cSerPDV)
Local aRet	:= {}
Local nPos	:= 0

STBLstPDV()

nPos := Ascan(aLstPDVs,{|x| x[1] == AllTrim(Upper(cSerPDV))})
Aadd(aRet,{ nPos > 0 , nPos})

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc}STBDatIECF
 Captura todos os PDV 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@sample
/*/
//--------------------------------------------------------
Static Function STBDatIECF(lTemPDV,aRetSLG,cLG_ECFINFO)
Local nX := 0

ASize(aRetSLG,0)

If Len(aRetSLG) <> 12
	aRetSLG := Array(12)
EndIf

If lTemPDV
	STDBusDEst(	cLG_ECFINFO, @aRetSLG[1], @aRetSLG[2], @aRetSLG[3],; 
			@aRetSLG[4], @aRetSLG[5], @aRetSLG[6], @aRetSLG[7] ,;
			@aRetSLG[8], @aRetSLG[9], @aRetSLG[10] , @aRetSLG[11],;
			@aRetSLG[12])
Else
	For nX := 1 to Len(aRetSLG)
		aRetSLG[nX] := ""
	Next nX
EndIf

Return aRetSLG

//--------------------------------------------------------
/*/{Protheus.doc}LJPRVldLG

@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@sample
/*/
//--------------------------------------------------------
Static Function LJPRVldLG(cMD5Atu,cHashMd5)
Local lMD5EcfOk := .T.
Local cSLGMD5	:= ""

If !Empty(cHashMd5)
	cSLGMD5 := AllTrim(MD5(AllTrim(cHashMd5),2))
	lMD5EcfOk := cMD5Atu == cSLGMD5
EndIf

Return lMD5EcfOk

//-----------------------------------------------------
/*/
{protheus.doc}LJRGVldE2

Valida qual ECF emitiu a Redução Z 
@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample

/*/
//------------------------------------------------------
Static Function LJRGVldE2(dData,cSerPDV)
Local lEmiteE2	:= .F.
Local lAchou	:= .F.
Local lExistSale:= .F.
Local nTry		:= 0
Local nGeralTry := 0
Local aRet		:= {}
Local cRet		:= ""
Local cSeriePDV := ""
Local cSerieRet := ""
Local dDtPesq	:= CtoD( '' )

LJRPLogProc("Inicio da função - LJRGVldE2")
dDtPesq := dData
nTry	:= 1	
DbSelectArea("MDZ")
MDZ->(DbSetOrder(1)) //MDZ_FILIAL + MDZ_DATA

//Pesquisa até encontrar um registro dentro de 32 dias para tras 
While !lAchou .And. nTry <= 32
	lExistSale := MDZ->(DbSeek(xFilial("MDZ") + DtoS(dDtPesq)))
	nGeralTry++
	
	If lExistSale
		While MDZ->(!Eof()) .And. !lAchou
			If MDZ->MDZ_SIMBOL == "RP"
				cRet	:= AllTrim(MDZ->MDZ_SERPDV) //Retorna a série do PDV que emitiu a primeira RedZ 
				lAchou	:= .T.
				Exit
			EndIf
			MDZ->(DbSkip())
		End
	Else
		dDtPesq -= 1
		nTry++
	EndIf
	
	If nGeralTry == 34
		LJRPLogProc("Forcou a saida do Looping")
		LJRPLogProc("Avaliação de LJRGVldE2 - lExistSale",,lExistSale)
		nTry := nGeralTry
		Exit //Para evitar ficar num looping infinito 
	EndIf
End

Aadd(aRet, {lAchou , cRet } )

If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "A"
	cSerieRet := aRet[1][2]
Else
	lRet := .F.
EndIf

LJRPLogProc('LJRGVldE2 -> Serie Ret:' + cSerieRet +' - Serie PDV: ' + cSeriePDV)
lEmiteE2:=  (AllTrim(cSerieRet) == AllTrim(cSeriePDV))		
aRet	:= {}
Aadd( aRet , lEmiteE2 )

LJRPLogProc("Final da função - LJRGVldE2")
Return  aRet

//--------------------------------------------------------
/*{Protheus.doc}LstVndCpf
Lista das vendas identificadas por Cpf/Cnpj
@author  	Varejo
@version 	P11.8
@since   	06/07/2015
@return  	lRet  - função executada com sucesso 
@obs     	ainda não está sendo usada via RPC
@sample
*/
//--------------------------------------------------------
Static Function LstVndCpf( dDataIni,dDataFim,CpfCpnj,lHomolPaf )
Local lRet		:= .F.
Local nPos		:= 0
Local nLstPos	:= 0
Local dFstData	:= Ctod('')
Local dLstData	:= Ctod('')
Local nHdlTxt	:= 0
Local VndsIdentRet := {}
Local cNameFunc	:= ProcName() + " - "
Local cLocalPath:= LjxGetPath()[1]
Local cArqVndId	:= "Arquivo_VndId.txt" 
Local cCpfCnpj	:= ""
Local cSL1		:= 'SL1TMP'
Local cConteudo	:= ""

If File(cLocalPath+cArqVndId)
	LJRPLogProc(" - Apagando o arquivo [" + cLocalPath + cArqVndId + "] - para criar um novo")
	FErase(cLocalPath+cArqVndId)
EndIf

LJRPLogProc(" - Criando arquivo Local [" + cLocalPath + cArqVndId + "]")
nHdlTxt := FCreate(cLocalPath+cArqVndId,0) //Cria o arquivo na system do Protheus
LJRPLogProc(" - Handle Arquivo [" + cLocalPath + cArqVndId + "] -> " + cValToChar(nHdlTxt))

lRet := (nHdlTxt <> -1)

If lRet
	FClose(nHdlTxt)
	
	If Select(cSL1) > 0
		(cSL1)->(DbCloseArea())
	EndIf
	
	cQuery	:= " select Sum(L1_VLRTOT) VlrTotal,L1_FILIAL,L1_EMISSAO,L1_CGCCLI,D_E_L_E_T_ "
	cQuery	+= " FROM " + RetSqlName("SL1")
	cQuery	+= " Where "
	cQuery	+= " L1_FILIAL ='" + xFilial('SL1') + "'"
	
	If Empty(AllTrim(CpfCpnj)) //Pesquisa por Cpf/cnpj, pode ser todos ou especifico
		cQuery	+= " AND L1_CGCCLI <> ' ' "
	Else
		cQuery	+= " AND L1_CGCCLI = '" + CpfCpnj + "' "
	EndIf
	
	cQuery	+= " And L1_STORC <> 'C' "
	cQuery	+= " And L1_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
	cQuery	+= " And D_E_L_E_T_ = ' ' " 	
	cQuery	+= " Group by L1_FILIAL,L1_CGCCLI,L1_EMISSAO,D_E_L_E_T_"
	
	cQuery := ChangeQuery( cQuery )
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
	TcSetField(cSL1,"L1_EMISSAO","D")
	(cSL1)->(DbGoTop())
	
	While !(cSL1)->(Eof())
		nPos := Ascan(VndsIdentRet, {|x| x[1] == AllTrim((cSL1)->L1_CGCCLI)})
	
		If nPos > 0
			VndsIdentRet[nPos][2]	+= (cSL1)->VlrTotal
		Else
			AAdd(VndsIdentRet,Array(5))
			nPos := Len(VndsIdentRet)
			VndsIdentRet[nPos][1]	:= AllTrim((cSL1)->L1_CGCCLI)
			VndsIdentRet[nPos][2]	:= (cSL1)->VlrTotal
			VndsIdentRet[nPos][3]	:= .T.
		EndIf
	
		(cSL1)->(DbSkip())
	End
	
	(cSL1)->(DbGoTop())
	While !(cSL1)->(Eof())
		nPos := Ascan(VndsIdentRet, {|x| x[1] == AllTrim((cSL1)->L1_CGCCLI)})
	
		If nPos > 0
			cCpfCnpj := (cSL1)->L1_CGCCLI
			dLstData := (cSL1)->L1_EMISSAO
	
			If VndsIdentRet[nPos][4] == NIL
				VndsIdentRet[nPos][4] := (cSL1)->L1_EMISSAO
			EndIf
		EndIf
		(cSL1)->(DbSkip())
	
		If (nPos > 0) .And. ( (cSL1)->(Eof()) .Or. (cCpfCnpj <> AllTrim((cSL1)->L1_CGCCLI)) )
			VndsIdentRet[nPos][5]:= dLstData
		EndIf
	End
	
	(cSL1)->(DbCloseArea())
	
	If Len(VndsIdentRet) > 0
		
		nHdlTxt := FOpen(cLocalPath+cArqVndId,2)
		If nHdlTxt > 0
			//Registro "Z1"
			cConteudo := "Z1"							//01 - Tipo de Registro
			cConteudo += PADL( SM0->M0_CGC, 14 )	//02 - CNPJ
			cConteudo += PADR( Upper(SM0->M0_INSC), 14 )	//03 - Incricao Estadual
			cConteudo += PADR( Upper(SM0->M0_INSCM), 14 )	//04 - Incricao Municipal		
			cConteudo += PADR( Upper(NoAcento(SM0->M0_NOMECOM)), 50 )	//05 - Razao Social
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHdlTxt, cConteudo, LEN( cConteudo ) )
			
			//Registro "Z2"
			cConteudo := "Z2"									//01-Tipo do registro
			cConteudo += PADL(_CNPJTOT,14)					//02 - CNPJ da empresa desenvolvedora do PAF-ECF - Totvs
			cConteudo += PADR(Upper(_INSCEST),14)					//03 - Inscricao Estadual da empresa desenvolvedora do PAF-ECF
			cConteudo += PADR(Upper(_INSCMUN),14)					//04 - Inscricao Municipal da empresa desenvolvedora do PAF-ECF
			cConteudo += PADR(Upper(_RAZSOC),50)					//05 - Denominacao da empresa desenvolvedora do PAF-ECF - Razao social
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHdlTxt, cConteudo, LEN( cConteudo ) )
			
			//Registro "Z3"
			cConteudo := "Z3"										//01-Tipo do registro
			cConteudo += PADR(Upper(STBVerPAFECF("NUMLAUDO")),10)	//02 - Número do Laudo de Análise Funcional
			cConteudo += PADR(Upper("PROTHEUS"),50)						//03 - Nome do aplicativo indicado no Laudo de Análise Técnica
			cConteudo += PADR(Upper(STBVerPAFECF("VERSAOAPLIC")),10)//04 - Versão atual do aplicativo indicado no Laudo de Análise Técnica
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHdlTxt, cConteudo, LEN( cConteudo ) )
			
			//Registro "Z4"
			//Criar função para buscar dados na retaguarda
			For nPos := 1 to Len(VndsIdentRet)
				cConteudo := "Z4"											//01-Tipo do registro
				cConteudo += StrZero(Val(VndsIdentRet[nPos][1]),14)				//02 - Número do CPF/CNPJ identificado no campo previsto no item 2 do Requsito VIII
				cConteudo += PADL(StrTran(StrTran(AllTrim(Transform(VndsIdentRet[nPos][2],cPictVal)),","),"."),14,"0") //03 - Total de vendas no mês, com duas casas decimais, ao CPF/CNPJ indicado no campo 02
				cConteudo += PADR(Dtos(dDataIni),8) //PADR(Dtos(VndsIdentRet[nPos][4]),8)		//04 - Primeiro dia do mes do relatorio
				cConteudo += PADR(Dtos(dDataFim),8)  //PADR(Dtos(VndsIdentRet[nPos][5]),8)		//05 - Ultimo dia do mes do relatorio
				
				//caso precise validar alteração -> VndsIdentRet[nI][3]
				cConteudo += PADR(DtoS(dDatabase),8)			//06 - Data da Geração do Relatorio
				cConteudo += PadR( StrTran(Time(),":",""), 6 )	//07 - Hora da Geração do Relatorio
				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHdlTxt, cConteudo, LEN( cConteudo ) )
			Next nI
			
			//Registro "Z9"
			cConteudo := "Z9"									//01-Tipo do registro
			cConteudo += PADL(_CNPJTOT,14)					//02 - CNPJ da empresa desenvolvedora do PAF-ECF - Totvs
			cConteudo += PADR(Upper(_INSCEST),14)			//03 - Inscricao Estadual da empresa desenvolvedora do PAF-ECF
			cConteudo += PADR(AllTrim(StrZero(Len(VndsIdentRet),6)),6)	//04 - Totalizador do Z4
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHdlTxt, cConteudo, LEN( cConteudo ) )
			
			FClose(nHdlTxt)
		EndIf
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LJRPScPrd
tela para pesquisa dos produtos 
@author  	Varejo
@version 	P11.8
@since   	14/12/2017
@return  	lRet  - função executada com sucesso 
@obs     
@sample
*/
//--------------------------------------------------------
Static Function LJRPScPrd()
Local cTabela	:= ""
Local aProdutos	:= {{"",""}}
Local nTpSel 	:= 1
Local oDlg 
Local oGpTela
Local oGpTipo   
Local oCodProd  
Local oProdutos
Local oBtAdd
Local oBtRemov 
Local oRbTpSel 
Local oBtnOK
Local oBtnCancel
Local oSayProd
Local cCodProd 	:= Space( TamSx3("B1_COD")[1] )

LJRPLogProc(" Tela de Pesquisa de Produtos")

If nModulo == 12 .Or. STFIsPOS()
	cTabela := "SB1"
Else
	cTabela := "SBI"
EndIf

oDlg := MSDIALOG():Create()
	oDlg:cName := "oDlg"
	oDlg:cCaption := "Estoque"
	oDlg:nLeft := 0
	oDlg:nTop := 0
	oDlg:nWidth := 700
	oDlg:nHeight := 530
	oDlg:lShowHint := .F.
	oDlg:lCentered := .T.
	
	oGpTela := TGROUP():Create(oDlg)
	oGpTela:cName := "oGpTela"
	oGpTela:cCaption := ""
	oGpTela:nLeft := 2
	oGpTela:nTop := 2
	oGpTela:nWidth := 690
	oGpTela:nHeight := 450
	oGpTela:lShowHint := .F.
	oGpTela:lReadOnly := .F.
	oGpTela:Align := 0
	oGpTela:lVisibleControl := .T.
	
	oGpTipo := TGROUP():Create(oDlg)
	oGpTipo:cName := "oGpTipo"
	oGpTipo:cCaption := "Tipo de Seleção"
	oGpTipo:nLeft := 9
	oGpTipo:nTop := 16
	oGpTipo:nWidth := 115
	oGpTipo:nHeight := 90
	oGpTipo:lShowHint := .F.
	oGpTipo:lReadOnly := .F.
	oGpTipo:Align := 0
	oGpTipo:lVisibleControl := .T.
	
	oRbTpSel := TRADMENU():Create(oDlg)
	oRbTpSel:cName := "oRbTpSel"
	oRbTpSel:nLeft := 18
	oRbTpSel:nTop := 40
	oRbTpSel:nWidth := 100
	oRbTpSel:nHeight := 100
	oRbTpSel:lShowHint := .F.
	oRbTpSel:Align := 0
	oRbTpSel:cVariable := "nTpSel"
	oRbTpSel:bSetGet := {|u| If(PCount()>0,nTpSel:=u,nTpSel) }
	oRbTpSel:lVisibleControl := .T.
	oRbTpSel:aItems  := {"Estoque Total","Estoque Parcial"} //"Estoque Total","Estoque Parcial"
	oRbTpSel:nOption := nTpSel
	oRbTpSel:bChange := {|| LJRPVlProd(nTpSel,@oCodProd,@cCodProd,@oProdutos)}
	
	oSayProd:= TSAY():Create(oDlg)
	oSayProd:cName := "oSayProd"
	oSayProd:cCaption := "Produto:" //"Produto: "
	oSayProd:nLeft := 150
	oSayProd:nTop := 20
	oSayProd:nWidth := 100
	oSayProd:nHeight := 16
	oSayProd:lShowHint := .F.
	oSayProd:lReadOnly := .F.
	oSayProd:Align := 0
	oSayProd:lVisibleControl := .T.
	oSayProd:lWordWrap := .F.
	oSayProd:lTransparent := .F.
	
	oCodProd:= TGET():Create(oDlg)
	oCodProd:cName := "oCodProd"
	oCodProd:nLeft := 195
	oCodProd:nTop := 18
	oCodProd:nWidth := 200
	oCodProd:nHeight := 20
	oCodProd:lShowHint := .F.
	oCodProd:Align := 0
	oCodProd:cVariable := "cCodProd"
	oCodProd:bSetGet := {|u| If(PCount()>0,cCodProd:=u,cCodProd) }
	oCodProd:lVisibleControl := .T.
	oCodProd:lPassword := .F.
	oCodProd:Picture := "@!"
	oCodProd:lHasButton := .F.
	oCodProd:cF3:= cTabela
	oCodProd:bWhen	 := {|| nTpSel == 2 }
	
	oBtAdd	:= TBtnBmp2():New( 18,400, 30, 20, "DOWN"  , /*<cResName2>*/, /*<cBmpFile1>*/, /*<cBmpFile2>*/,;
	 			{|| LJRPAdd(cTabela,@oProdutos,@aProdutos,@cCodProd,@oCodProd) } , oDlg, "Adicionar" /*"Adicionar" <cMsg>*/,{ ||If(nTpSel==2,.T.,.F.) }, /*<.adjust.>*/, /*<.lUpdate.>*/ ) //"Mover para cima"
	 			
	oBtRemov:= TBtnBmp2():New( 18,430, 30, 20, "UP"  , /*<cResName2>*/, /*<cBmpFile1>*/, /*<cBmpFile2>*/,;
	 			{|| LJRPRemov(@oProdutos,@aProdutos) } , oDlg, "Remover"  /*"Remover" <cMsg>*/, { ||If(nTpSel==2,.T.,.F.) }/*{|| oListVar:nAt > 1 }*/ /*<{uWhen}>*/, /*<.adjust.>*/, /*<.lUpdate.>*/ ) //"Mover para cima"
	
	oProdutos := TWBrowse():New( 20/*<nRow>*/, 75/*<nCol>*/, 265 /*<nWidth>*/, 200/*<nHeight>*/, /*[\{|| \{<Flds> \} \}]*/, {"Código","Descrição"} ;
				/*{"Código","Descrição"}*/ /*[\{<aHeaders>\}]*/, {70, 180}/*[\{<aColSizes>\}]*/, oDlg/*<oDlg>*/, /*<(cField)>*/, /*<uValue1>*/, /*<uValue2>*/,;
				/*[<{uChange}>]*/, /*[\{|nRow,nCol,nFlags|<uLDblClick>\}]*/, /*[\{|nRow,nCol,nFlags|<uRClick>\}]*/, /*<oFont>*/, /*<oCursor>*/, /*<nClrFore>*/,;
				 /*<nClrBack>*/, /*<cMsg>*/, /*<.update.>*/, /*<cAlias>*/, .T./*<.pixel.>*/, /*<{uWhen}>*/, /*<.design.>*/, /*<{uValid}>*/, /*<{uLClick}>*/, /*[\{<{uAction}>\}]*/ ) //
	oProdutos :SetArray(aProdutos)
	oProdutos :bLine := {|| { aProdutos[oProdutos:nAt,1], aProdutos[oProdutos:nAt,2] } }
	
	oBtnOK:= TButton():Create(oDlg)
	oBtnOK:cName := "oBtnOK"
	oBtnOK:cCaption := "OK" //"OK"
	oBtnOK:nLeft := 450
	oBtnOK:nTop := 460
	oBtnOK:nWidth := 90
	oBtnOK:nHeight := 25
	oBtnOK:lShowHint := .F.
	oBtnOK:lReadOnly := .F.
	oBtnOK:Align := 0
	oBtnOK:bAction := {|| lRet := .T., oDlg:End() }
	
	oBtnCancel:= TButton():Create(oDlg)
	oBtnCancel:cName := "oBtnCancel"
	oBtnCancel:cCaption := "Cancelar" //"Cancelar"
	oBtnCancel:nLeft := 550
	oBtnCancel:nTop := 460
	oBtnCancel:nWidth := 90
	oBtnCancel:nHeight := 25
	oBtnCancel:lShowHint := .F.
	oBtnCancel:lReadOnly := .F.
	oBtnCancel:Align := 0
	oBtnCancel:bAction := {|| lRet := .F., oDlg:End() }
	oDlg:lEscClose := .F. //Desativa o ESC
oDlg:Activate()

LJRPLogProc(" Fim da Tela de Pesquisa de Produtos",,aProdutos)

Return aProdutos

//--------------------------------------------------------
/*{Protheus.doc}LJRPVlProd
Valid para atualizar o objeto oProdutos.
@author  	Varejo
@version 	P11.8
@since   	14/12/2017
@return  	Nil
@sample
*/
//--------------------------------------------------------
Static Function LJRPVlProd(nTpSel,oCodProd,cCodProd,oProdutos)
Local lRet := .F.

cCodProd  := Space( TamSx3("B1_COD")[1] )
If nTpSel == 1
	oProdutos:SetFocus()
Else
	oCodProd:SetFocus()
EndIf	

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}STBFMAdd
Adiciona o produto selecionado do objeto oProdutos

@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
@obs     	LjxDAdd
@sample
*/
//--------------------------------------------------------
Static Function LJRPAdd(cTabela,oProdutos,aProdutos,cCodProd,oCodProd)
Local lRet := .T.
Local nX
Local aProd  	:= aClone(aProdutos) 
Local lVerif 	:= .F.  
Local cPrefixo 	:= SubStr(cTabela,2,2)

If !Empty(Alltrim(cCodProd))

	If lRet .AND. Len( aProd )== 1 .AND. Empty(aProd[1][1])
		aProd	:=	{}
	EndIf

	If lRet 
		(cTabela)->( DbSetOrder(1) )
		If (cTabela)->( DbSeek(xFilial(cTabela)+cCodProd) )
	
			lVerif :=  Ascan( aProd , {|x| x[1]== cCodProd} ) > 0 		
			If !lVerif
				Aadd( aProd, { cCodProd, (cTabela)->(&(cPrefixo + "_DESC")) } )
			Else
				STFMessage("LJRPAdd", "POPUP","Produto já adicionado")
				STFShowMessage("LJRPAdd")
			EndIf
			aProdutos:=aClone(aProd)
			oProdutos:SetArray(aProdutos)
			oProdutos:bLine := {|| { aProdutos[oProdutos:nAt,1], aProdutos[oProdutos:nAt,2] } }	
			oProdutos:Refresh() 
		
			cCodProd := space(TamSx3("B1_COD")[1])
		   	oCodProd:Refresh()	   
		Else
			STFMessage("LJRPAdd", "POPUP","Produto não encontrado")
			STFShowMessage("LJRPAdd")
		EndIf
	EndIf
Else
	STFMessage("LJRPAdd", "POPUP","Informe um produto.")
	STFShowMessage("LJRPAdd")
	cCodProd := Space(TamSx3("B1_COD")[1])
   	oCodProd:Refresh()	  
Endif

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LJRPRemov
Remove o produto selecionado do objeto oProdutos

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	Nil
@obs     	LjxDRemov
@sample
*/
//--------------------------------------------------------
Static Function LJRPRemov(oProdutos,aProdutos)
Local lRet := .T.
Local aProd := aClone(aProdutos)

If Len( aProd )== 1 .AND. Empty(aProd[oProdutos:nAt,1])
	 lRet := .F.
Endif 

If lRet
	aDel(aProd,oProdutos:nAt)
	aProdutos := {}

	ASize(aProd, Len(aProd)-1)	
	If Len( aProd ) == 0
		aProdutos := { {"",""} }
	Else
		aProdutos := aClone(aProd)	
	Endif
	
	oProdutos :SetArray(aProdutos)
	oProdutos :bLine := {|| { aProdutos[oProdutos:nAt,1], aProdutos[oProdutos:nAt,2] } }	
	oProdutos :Refresh()
EndIf

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LjRPR02PDV
Captura o R02 no PDV

@author  	Varejo
@version 	P11.8
@since   	22/01/2018
@return  	Nil
*/
//--------------------------------------------------------
Static Function LjRPR02PDV(dDataIni, dDataFim, cPDV)
Local bWhile	:= Nil
Local cIndex	:= ""
Local cChave	:= ""
Local cCond		:= ""               
Local nCont     := 1
Local nPosImp	:= 0
Local aAreaSFI	:= {}
Local aAux      := {} 
Local aRedZRet  := {}
Local aImpsSFI  := {}
Local nTotOpNFis:= 0 		//totaliza operação não fiscal                   
Local nX		:= 0
Local dData		:= Ctod('')

cPDV := AllTrim(cPDV)

DbSelectArea("SFI")
aAreaSFI:= SFI->(GetArea())
cIndex	:= CriaTrab(Nil,.F.)
cChave	:= "FI_FILIAL+DTOS(FI_DTREDZ)"
cCond	:= "FI_FILIAL= '"+xFilial("SFI")+"' .AND. Trim(SFI->FI_PDV)='" + cPDV + "'" 
IndRegua("SFI",cIndex,cChave,,cCond,"Selecionando Registros...")

//deve pegar a database pois o FI_DTREDZ guarda a data do dia da redução, que é hoje,
// e o parâmetro passado contém a data do movimento que pode ser menor e com isso nao gera o R02 e R03
dData := dDataBase
SFI->(DbSeek(xFilial("SFI")+DtoS(dData),.T.)) 
bWhile	:= {||SFI->FI_DTREDZ == dData}

DbSelectArea("MDZ")
MDZ->( DbSetOrder(1) )

//************************************************************************************************/
// 								NOTA SOBRE O CONTEUDO DAS INFORMAÇÕES DA SFI
//
// 1 -	o campo FI_CANCEL é preenchido de acordo com o modelo do ECF, existem ECFs que mandam 
//		somente os valores de cancelamento de ICMS mas outras somam ICMS + ISS
// 2 - o campo FI_DESC também depende do modelo, alguns modelos mandam desconto de ICMS 
//		e outras mandam desconto de ISS + ICMS
//-> Portanto se no processo de homologação houver alguma diferença nos valores acumulados, 
//utilizar FI_CANCEL-FI_CANISS e FI_DESC-FI_DESISS
//
//-> os campos FI_DESISS e FI_CANISS sao criados pelo UPDLOJ72 e utilizados para o sistema em geral
//************************************************************************************************/
While !SFI->(Eof()) .AND. Eval(bWhile)
	
	If AllTrim(SFI->FI_PDV) == cPDV .Or. Empty(cPDV)
		Aadd(aRedZRet,Array(12))
		nX := Len(aRedZRet)
		
		aRedZRet[nX][1]	:= Val(SFI->FI_NUMREDZ)
		aRedZRet[nX][2]	:= Val(SFI->FI_COO)
		aRedZRet[nX][3]	:= Val(SFI->FI_CRO)
		aRedZRet[nX][4]	:= SFI->FI_DTMOVTO
		aRedZRet[nX][5]	:= SFI->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS+FI_DESISS+FI_CANISS)
		aRedZRet[nX][6]	:= SFI->FI_DTREDZ
		aRedZRet[nX][7]	:= SFI->FI_HRREDZ
		aRedZRet[nX][8]	:= SFI->FI_CANCEL
		aRedZRet[nX][9]	:= AllTrim(SFI->FI_SERPDV)
		aRedZRet[nX][10]:= SFI->FI_CANISS
		
		nTotOpNFis := 0
		                            
		//Totaliza Op.Nao Fiscal
		MDZ->(DbSeek(xFilial("MDZ")+DtoS(SFI->FI_DTMOVTO)))		
		While (!MDZ->( EOF() ) ) .AND. MDZ->MDZ_DATA == SFI->FI_DTMOVTO
			If (MDZ->MDZ_SIMBOL == "CN") .And. (AllTrim(MDZ->MDZ_PDV) == Alltrim(SFI->FI_PDV))				
				nTotOpNFis += MDZ->MDZ_VALOR
			EndIf
			
			MDZ->(DbSkip())
		End
		
		aRedZRet[nX][11] := nTotOpNFis
		
		/*Carrega Aliquotas e Valores de Impostos*/
		LJRPLogProc(" Chamada da Função TotalizSFI (do Fonte SPEDXFUN)  ")
		aAux := aClone( TotalizSFI(SFI->(Recno()), .T.) )
		LJRPLogProc(" Retorno da Função TotalizSFI (do Fonte SPEDXFUN)  ",,aAux)
		
		If Len(aAux) > 0
			nPosImp := 0
			For nCont := 1 To Len(aAux)
				If !(Upper(aAux[nCont][1]) $ Upper("Can-T|Can-S"))
				    Aadd( aImpsSFI , Array(2) )
				    nPosImp := Len(aImpsSFI)
				    AIMPSSFI[nPosImp][1] := aAux[nCont][1]
				    AIMPSSFI[nPosImp][2] := aAux[nCont][2]
				EndIf
			Next nCont	
		EndIf
		
		aRedZRet[nX][12] := aImpsSFI
	EndIf
	SFI->(DbSkip())
End

If !Empty(cIndex)
	SFI->(DBCloseArea())
	Ferase(cIndex+OrdBagExt())
	DBSelectArea("SFI")
	RestArea(aAreaSFI)
EndIf

Return aRedZRet

//--------------------------------------------------------
/*{Protheus.doc}LJRPUneR02
Une as informações e passa para um unico arquivo

@author  	Varejo
@version 	P11.8
@since   	22/01/2018
@return  	Nil
@sample
*/
//--------------------------------------------------------
Static Function LJRPUneR02(aRetR02Red,cNameArq,aInfoPDVPAF)
Local lRet 		:= .T.
Local lR02R03	:= .T.
Local cArqTMP	:= ExtractPath(cNameArq) + 'ArqTMP.TXT'
Local cLinha	:= ""
Local cLinha2	:= ""
Local cTotECF	:= ""
Local aRetSLG	:= {}
Local nHandle	:= 0
Local nHdlTmp	:= 0
Local nX		:= 0
Local nY		:= 0
Local nCont		:= 0

FErase(cArqTMP)
nHdlTmp := FCreate(cArqTMP,FC_NORMAL)
nHandle := FT_FUse(cNameArq)

If nHandle > 0 .And. nHdlTmp > 0
	
	While !FT_FEof()
		cLinha := FT_FReadLn()
		/*	Valido todos esses registros pois depois do R01, devo inserir o registro do R02	*/
		If (Substr(cLinha,1,3) $ "R03|R04|R06|R07|EAD") .And. lR02R03
			
			For nX:= 1 to Len(aRetR02Red)
				nCont := STBRetPDV(aRetR02Red[nX][9])[1][2]
				aRetSLG := STBDatIECF(nCont > 0,@aRetSLG,IIF(nCont > 0 , aLstPDVs[nCont][2], ""))
							
				cLinha2 := "R02"
				cLinha2 += PadR(aRetR02Red[nX][9],20) //Série do PDV
				cLinha2 += PadR(aRetSLG[12],1) //MF Adicional
				cLinha2 += PadR(aRetSLG[2],20) //Modelo do ECF
				cLinha2 += StrZero(IIf(ValType(aRetSLG[10]) == "N", aRetSLG[10], Val(aRetSLG[10])),2) //Numero de Ordem do ECF
				cLinha2 += StrZero(aRetR02Red[nX][1],6) //Numero do Contador de RedZ
				cLinha2 += StrZero(aRetR02Red[nX][2],9) //Numero do COO
				cLinha2 += StrZero(aRetR02Red[nX][3],6) //Numero do CRO
				cLinha2 += PadR(Dtos(aRetR02Red[nX][4]),8) //Data das Operacoes de RedZ
				cLinha2 += PadR(Dtos(aRetR02Red[nX][6]),8) //Data Da Emissao de RedZ
				cLinha2 += PadR(aRetR02Red[nX][7],6) //Hora Emissão RedZ
				cLinha2 += StrTran(StrZero(aRetR02Red[nX][5],15,2),'.') //Valor acumulado com 2 casas decimais
				cLinha2 += "N" //Parametro do ECF de Incidencia de Desconto no ISS
				cLinha2 += CHR(13)+CHR(10)
				FWrite(nHdlTmp,cLinha2,Len(cLinha2))
			Next nX
			
			For nX := 1 to Len(aRetR02Red)

				nCont := STBRetPDV(aRetR02Red[nX][9])[1][2]
				aRetSLG := STBDatIECF(nCont > 0,@aRetSLG,IIF(nCont > 0 , aLstPDVs[nCont][2], ""))				
				
				For nY := 1 to Len(aRetR02Red[nX][12])
					cTotECF := ""
					If nCont > 0
						cTotECF := LJRPTotEcf(aLstPDVs[nCont][6],aRetR02Red[nX][12][nY][1])
					EndIf
					If Empty(cTotECF)
						cTotECF := "01"
					EndIf
					cTotECF += aRetR02Red[nX][12][nY][1]
					
					cLinha2 := "R03"  //1
					cLinha2 += PadR(aRetR02Red[nX][9],20) //Série do PDV
					cLinha2 += PadR(aRetSLG[12],1) //MF Adicional
					cLinha2 += PadR(aRetSLG[2],20) //Modelo do ECF
					cLinha2 += StrZero(IIf(ValType(aRetSLG[10]) == "N", aRetSLG[10], Val(aRetSLG[10])),2) //Numero de Ordem do ECF
					cLinha2 += StrZero(aRetR02Red[nX][1],6) //Numero do Contador de RedZ
					cLinha2 += PadR(cTotECF,7) //Totalizador 
					cLinha2 += StrTran(StrZero(aRetR02Red[nX][12][nY][2],14,2),".") //Valor acumulado no totalizador
					cLinha2 += CHR(13)+CHR(10)
					FWrite(nHdlTmp,cLinha2,Len(cLinha2))
				Next nY

				If aRetR02Red[nX][8] > 0
					cLinha2 := "R03"  //1
					cLinha2 += PadR(aRetR02Red[nX][9],20) //Série do PDV
					cLinha2 += PadR(aRetSLG[12],1) //MF Adicional
					cLinha2 += PadR(aRetSLG[2],20) //Modelo do ECF
					cLinha2 += StrZero(IIf(ValType(aRetSLG[10]) == "N", aRetSLG[10], Val(aRetSLG[10])),2) //Numero de Ordem do ECF
					cLinha2 += StrZero(aRetR02Red[nX][1],6) //Numero do Contador de RedZ					
					cLinha2 += PadR('Can-T',7)
					cLinha2 += StrTran(StrZero(aRetR02Red[nX][8] , 14, 2), '.') 
					cLinha2 += CHR(13)+CHR(10)
					FWrite(nHdlTmp,cLinha2,Len(cLinha2))
				EndIf
				
				If aRetR02Red[nX][10] > 0
					cLinha2 := "R03"  //1
					cLinha2 += PadR(aRetR02Red[nX][9],20) //Série do PDV
					cLinha2 += PadR(aRetSLG[12],1) //MF Adicional
					cLinha2 += PadR(aRetSLG[2],20) //Modelo do ECF
					cLinha2 += StrZero(IIf(ValType(aRetSLG[10]) == "N", aRetSLG[10], Val(aRetSLG[10])),2) //Numero de Ordem do ECF
					cLinha2 += StrZero(aRetR02Red[nX][1],6) //Numero do Contador de RedZ
					cLinha2 += PadR('Can-S',7) //Totalizador
					cLinha2 += StrTran(StrZero(aRetR02Red[nX][10] , 14, 2), '.') 
					cLinha2 += CHR(13)+CHR(10)
					FWrite(nHdlTmp,cLinha2,Len(cLinha2))
				EndIf
				
				If aRetR02Red[nX][11] > 0
					cLinha2 := "R03"  //1
					cLinha2 += PadR(aRetR02Red[nX][9],20) //Série do PDV
					cLinha2 += PadR(aRetSLG[12],1) //MF Adicional
					cLinha2 += PadR(aRetSLG[2],20) //Modelo do ECF
					cLinha2 += StrZero(IIf(ValType(aRetSLG[10]) == "N", aRetSLG[10], Val(aRetSLG[10])),2) //Numero de Ordem do ECF
					cLinha2 += StrZero(aRetR02Red[nX][1],6) //Numero do Contador de RedZ				
					cLinha2 += PadR('OPNF',7)
					cLinha2 += StrTran(StrZero(aRetR02Red[nX][11] , 14, 2), '.') 
					cLinha2 += CHR(13)+CHR(10)
					FWrite(nHdlTmp,cLinha2,Len(cLinha2))
				EndIf
			Next nX
			
			lR02R03 := .F.		
		EndIf
		
		cLinha += CHR(13)+CHR(10)
		FWrite(nHdlTmp,cLinha,Len(cLinha))
		FT_FSkip()
	End
	
	FT_FUse()
	FClose(nHandle)
	FClose(nHdlTmp)
	
	FErase(cNameArq) //apaga o arquivo antigo
	__CopyFile(cArqTMP, cNameArq) //copia do temporario para o padrão com as informações do R02/R03
	FErase(cArqTMP)//apaga o temporário
Else
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LJRPTotEcf
Trata o AlqInfo

@author  	Varejo
@version 	P11.8
@since   	22/01/2018
@return  	Nil
@sample
*/
//--------------------------------------------------------
Static Function LJRPTotEcf(cAlqInfo,cImposto)
Local nX	:= 0
Local cRet	:= ""
Local aAlq	:= {}

aAlq := StrTokArr( cAlqInfo , "#" )

If Len(aAlq) > 0
	nX := aScan( aAlq , {|x| Upper(cImposto) $ Upper(x)} )
	If nX > 0
		cRet := Substr(aAlq[nX],1,2)
	EndIf
EndIf

Return cRet

//--------------------------------------------------------
/*{Protheus.doc}LJRPLogProc
Gera logs dos processamentos

@author  	Varejo
@version 	P11.8
@since   	22/01/2018
@return  	Nil
@sample
*/
//--------------------------------------------------------
Function LJRPLogProc(cTexto,xNickName,xVerifiVar)
Local cProcName := "" 
Local cDtHra	:= Dtoc(dDatabase) + " " + Time() + " "

Default xNickName	:= NIL
Default xVerifiVar 	:= NIL

If ValType(xNickName) == "C"
	cProcName := AllTrim(xNickName)
Else
	cProcName := ProcName(1)
EndIf

cProcName += " "
Conout(cProcName + cDtHra + cTexto)
LjGrvLog( xNickName, cDtHra + cTexto , xVerifiVar)

Return NIL

//--------------------------------------------------------
/*{Protheus.doc}LjTestePaf
Função para teste de Registros do PAF

@author  	Varejo
@version 	P11.8
@since   	22/01/2018
@return  	Nil
@sample
*/
//--------------------------------------------------------
User Function LJRPTestPAF()

//Trecho para preparar ambiente
Private cEstacao	:="001"

RPCSetType(3)
RpcSetEnv("99","01",Nil,Nil,"LOJA")
nModulo := 12
//LJMFRGPaf(lTotvsPdv,dDataIni, dDataFim, cPDV,lHomolPaf,lReducao)
LJMFRGPaf(.F.,Ctod("01/01/2017"), Ctod("20/10/2017"), "", .F.,.F.)

Return .T.


/*/{Protheus.doc} LJContrDAV
	Gera Arquivo IV de Controle de DAVs Requisito V Inciso IV do PAF-NFC-e
	@type  Function
	@author caio.okamoto
	@since 27/09/2022
	@version 12.1.33
	@param cFilSL1, 	caracter, 	filial
	@param lTotvsPDV, 	lógico, 	Totvs PDV
	@return cPath + cFile, caracter, se foi gerado txt retorna o diretório e nome do arquivo para geração do xml.
	/*/
Function LJGeCtrDAV(cFilSL1, lTotvsPDV)

Local aRegCrtDAV	:= {}
Local nX			:= 0
Local cConteudo		:= ""
Local nHdlTxt		:= 0  
Local cFile			:= ""
Local cPath			:= ""

DEFAULT cFilSL1 	:= xFilial("SLG")
DEFAULT lTotvsPDV 	:= .F.

LJRPLogProc("Inicio rotina LJGeCtrDAV() Geração do Arquivo IV - Controle de DAVS")

If lTotvsPDV
	STBRemoteExecute("LJRgCtrDAV", {cFilSL1}, NIL, .F.,@aRegCrtDAV)
/*Else
	aRegCrtDAV := LJRgCtrDAV(cFilSL1)*/
EndIf

if Len(aRegCrtDAV) > 0

	STBFMGerPath( @cPath )
	cFile := STBFMGerFile("CtrlDAV",lTotvsPDV)
		
	nHdlTxt := FCREATE( cPath + cFile, FC_NORMAL )
	
	If nHdlTxt > 0
	
		LJRPLogProc(" Inicia Geração do Arquivo IV - Controle de DAVS")

		/*6.1. REGISTRO TIPO V1 -IDENTIFICAÇÃO DO ESTABELECIMENTO USUÁRIO DO PAF-NFC-e*/
		cConteudo := "V1"											//01 - Tipo de Registro
		cConteudo += PADL( SM0->M0_CGC, 14 )						//02 - CNPJ
		cConteudo += PADR( Upper(SM0->M0_INSC), 14 )				//03 - Incricao Estadual
		cConteudo += PADR( Upper(SM0->M0_INSCM), 14 )				//04 - Incricao Municipal		
		cConteudo += PADR( Upper(NoAcento(SM0->M0_NOMECOM)), 50 )	//05 - Razao Social
		cConteudo += CHR(13) + CHR(10)

		FWRITE( nHdlTxt ,cConteudo, LEN(cConteudo) )

		/*6.2. REGISTRO TIPO V2 -RELAÇÃO DOS DAV NÃO ENCERRADOS*/
		For nX := 1 to Len(aRegCrtDAV)
			
			If Empty(aRegCrtDAV[nX][3])  
				
				cConteudo := "V2"
				cConteudo += DTOS(aRegCrtDAV[nX][1]) 				//02- DATA DA ABERTURA DO DAV		
				cConteudo += PADR(aRegCrtDAV[nX][2], 13)			//03- NUMERO DO DAV
				cConteudo += CHR(13) + CHR(10)
				
				FWRITE( nHdlTxt ,cConteudo, LEN(cConteudo) )

			Endif 

		Next nX

		/*6.3. REGISTRO TIPO V3 -RELAÇÃO DOS DAV SEM DOCUMENTO FISCAL*/
		For nX := 1 to Len(aRegCrtDAV)
			
			If !Empty(aRegCrtDAV[nX][3])  
				
				cConteudo := "V3"
				cConteudo += DTOS(aRegCrtDAV[nX][1]) 				//02- DATA DA ABERTURA DO DAV		
				cConteudo += PADR(aRegCrtDAV[nX][2], 13)			//03- NUMERO DO DAV
				cConteudo += CHR(13) + CHR(10)

				FWRITE( nHdlTxt ,cConteudo, LEN(cConteudo) )

			Endif 

		Next nX
		
		/*V4- DATA DA GERAÇÃO DO ARQUIVO*/
		cConteudo := "V4"								//01 - Tipo de Registro
		cConteudo += DtoS(dDataBase)					//02 - Data da Geração de Arquivo

		FWRITE( nHdlTxt ,cConteudo, LEN(cConteudo) )

		FCLOSE(nHdlTxt)

		LJRPLogProc(" Final Geração do Arquivo IV - Controle de DAVS")

	Endif

Endif 

Iif(Len(aRegCrtDAV)==0 ,LJRPLogProc(" Sem registros para Geração do Arquivo IV - Controle de DAVS"), nil)
Iif(nHdlTxt==0, LJRPLogProc(" Erro ao cria arquivo " + cPath + cFile + "  Geração do Arquivo IV - Controle de DAVS"), nil)

Return cPath + cFile


/*/{Protheus.doc} LJRgCtrDAV()
	Busca registros na Retaguarda para geração do Arquivo IV de Controle de DAVs Requisito V Inciso IV do PAF-NFC-e
	@type  Function
	@author caio.okamoto
	@since 28/09/2022
	@version 12.1.33
	@param cFilSL1, caracter, 	filial
	@return aRet, 	Array, 		Retorna Registros para geração de arquivo
	/*/
Function LJRgCtrDAV(cFilSL1)

Local aRegCrtDAV	:= {}
Local cQuery		:= ""
Local cAlias		:= "SL1TMP"

Iif (Select(cAlias) > 0, (cAlias)->(DbCloseArea()), Nil)

cQuery	:= " SELECT L1_EMISSAO, L1_NUMORC, L1_EMISNF"
cQuery	+= " FROM " + RetSqlName("SL1") + " SL1 "
cQuery	+= " WHERE "
cQuery	+= " SL1.L1_FILIAL = '" + cFilSL1 + "' "
cQuery	+= " AND SL1.L1_DOC = ' ' "
cQuery	+= " AND SL1.L1_SERIE = ' ' "
cQuery	+= " AND SL1.L1_NUMORC 	<>	' ' " 
cQuery	+= " AND SL1.L1_TPORC IN ('E','D') "
cQuery	+= " AND SL1.L1_DTLIM 	>=	'" + DtoS(dDataBase)+ "' "
cQuery	+= " AND SL1.L1_ESPECIE <> 'NFCF' AND SL1.L1_ESPECIE <> 'NFM' "
cQuery	+= " AND SL1.D_E_L_E_T_ = '' "
cQuery	+= " ORDER BY SL1.L1_EMISSAO"

cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"L1_DTLIM","D")
TcSetField(cAlias,"L1_EMISSAO","D")
(cAlias)->(DbGoTop())

While !(cAlias)->(Eof())

	AAdd(aRegCrtDAV,Array(3))

	nPos := Len(aRegCrtDAV)

	aRegCrtDAV[nPos][1] := (cAlias)->L1_EMISSAO
	aRegCrtDAV[nPos][2] := (cAlias)->L1_NUMORC
	aRegCrtDAV[nPos][3]	:= (cAlias)->L1_EMISNF

	(cAlias)->(DbSkip())

End

(cAlias)->(DbCloseArea())
	
Return aRegCrtDAV
