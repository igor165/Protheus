#INCLUDE "LOJA420.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "AUTODEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLOJA420   บAutor ณEdney Soares de Souzaบ Data ณ  06/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o arquivo criptografado contendo serie do ECF         บฑฑ
ฑฑบ          ณ Conforme Convenio ICMS 50/00 Clausula 80a alineas c e d    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja - Venda Balcao - Venda Rapida - LojxECF - SCRFIS  บฑฑ
ฑฑฬออออออออออุออออออออัออออออออัออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบ DATA     ณ BOPS   ณPrograd.ณALTERACAO                                 บฑฑ
ฑฑฬออออออออออุออออออออุออออออออุออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ23/11/06  ณ113.981 ณMarcio LณAdequacoes para a legislacao Sefaz - AM   บฑฑ
ฑฑบ30/11/06  ณ114.407 ณMarcio LณQuando for AM sistema emitira a mensagem  บฑฑ
ฑฑบ          ณ        ณ        ณpadrao da legislacao para qualquer incon- บฑฑ
ฑฑบ          ณ        ณ        ณsistencia.                                บฑฑ
ฑฑบ13/02/07  ณ117.210 ณMarcio LณInclusao da criacao do arquivo de cripto- บฑฑ
ฑฑบ          ณ        ณ        ณgrafia no frontloja.                      บฑฑ 
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Loja420()
Local cSerie 		:= Space(20)				// Buffer para captura do numero de serie
Local cImpressora	:= ""						// Impressora fiscal
Local cPorta		:= ""						// Porta configurada
Local nRet 			:= 0           				// Retorno da funcao IFPegSerie: 0 = OK | 1 = Erro
Local nHandle 		:= 0 						// Handle para tratamento do arquivo criptografado a ser criado
Local lRet      	:= .T.         				// Retorno da funcao 
Local lLjfPaf		:= LjNfPafEcf(SM0->M0_CGC)	// Ambiente PAF-ECF
Local lContinua		:= .T.
Local lHomolPAF		:= STBHomolPaf() 			// Sinaliza rotinas de processo de homologacao
                                          
If (cModulo == 'FAT')
	cPorta		:= GetMv("MV_PORTFIS")
	cImpressora := GetMv("MV_IMPFIS")
	lFiscal 	:= .T.
EndIf

If !lLjfPaf .And. !LjAnalisaLeg(23)[1] .And. ( !SuperGetMV("MV_LJNSECF") .OR. !lFiscal )
	// Esta rotina ้ utilizada para gerar o arquivo criptografado conforme Conv๊nio ICMS 50/00 - 
	//clแusula 80a - alํneas c e d. Caso a sua UF utilize esta rotina, verifique com a Microsiga como ativแ-la.
	MsgStop(STR0001)
	lContinua := .F.
	lRet	:= .F.
EndIf

If lContinua .And. (nModulo == 23) .And. STFIsPOS()
	MsgStop("Esta rotina LOJA420 nใo pode ser executada pelo m๓dulo TotvsPDV" + CHR(10) + CHR(13) +;
			" - Utilize a fun็ใo STWCripArq")
	lContinua := .F.
	lRet := .F.
EndIf

If lContinua
	If nModulo == 23 .OR. cModulo == 'FAT'
		If Type("oAutocom") == "U"
			Public oAutocom
		EndIf
		nHdlECF := IFAbrir( cImpressora,cPorta )
	EndIf
	
	nRet := IfPegSerie(nHdlECF,@cSerie)
	
	cImpressora	:= LjGetStation("IMPFISC")	// Impressora fiscal
	cPorta		:= LjGetStation("PORTIF")	// Porta configurada
	
	If nRet == 0
		// Gera o arquivo no diretorio do Remote (BIN)
		fErase(GetClientDir()+"SIGALOJA.BIN")
		nHandle := fCreate(GetClientDir()+"SIGALOJA.BIN")
		fWrite(nHandle,Encript(AllTrim(cSerie),0)) // Criptografa
		fClose(nHandle)   
		If lLjfPaf
			LJGrvGT("SIGALOJA.VLD") 
		EndIf                                      
		
		// Nao existe regra no Ato Cotepe 0608 para nao permitir aparecer essa mensagem de arquivo gerado, mas durante o processo de homologacao eh solicitado que nao apareca
		If !lHomolPAF
			MsgInfo(STR0003)		// O arquivo criptografado com o numero de s้rie do ECF foi gerado com sucesso.
		EndIf
	Else                                                                                                                                    
		//Ocorreu um erro ao ler o n๚mero de s้rie do ECF ou a fun็ใo de leitura de s้rie nใo estแ disponํvel para este modelo de Impressora.
		MsgStop(STR0002)
		lRet := .F.
	EndIf
	
	If nModulo == 23 .OR. cModulo == 'FAT'
		IFFechar( nHdlECF, cPorta )
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJVldSerieบAutor ณEdney Soares de Souzaบ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a consistencia do arquivo criptografado                บฑฑ
ฑฑบ          ณ Conforme Convenio ICMS 50/00 Clausula 80a alineas c e d    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja - Venda Balcao - Venda Rapida - LojxECF - SCRFIS  บฑฑ
ฑฑฬออออออออออุออออออออัออออออออัออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบ DATA     ณ BOPS   ณPrograd.ณALTERACAO                                 บฑฑ
ฑฑฬออออออออออุออออออออุออออออออุออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ07/02/07  ณ117.893 ณMarcos RณCorrecao de error.log, pois na chamada da บฑฑ
ฑฑบ          ณ        ณ        ณfuncao LJMsgLeg nao estava sendo passado oบฑฑ
ฑฑบ          ณ        ณ        ณesperado.                                 บฑฑ
ฑฑบ07/02/07  ณ120.764 ณMarcio LณValida se o cliente e fical, para checar  บฑฑ
ฑฑบ          ณ        ณ        ณse numero de serie do ECF.                บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjVldSerie()
Local cSerie 		:= Space(20)				// Buffer para captura do numero de serie atraves da impressora
Local cBuffer		:= Space(20)				// Buffer para captura do numero de serie atraves do arquivo
Local nRet 			:= 0           				// Retorno da funcao IFPegSerie: 0 = OK | 1 = Erro
Local nHandle 		:= 0 						// Handle para tratamento do arquivo criptografado a ser lido
Local nPos			:= 0
Local nSize 		:= 0						// Tamanho do arquivo a ser lido
Local aAnalisaLeg	:= {}						// Retorno do Array AnalisaLeg
Local lLjfPaf		:= LjNfPafEcf(SM0->M0_CGC)	// Ambiente PAF-ECF
Local cBufferL1		:= Space(20)
Local cCript		:= Space(20)
Local cVendaBruta	:= Space(20)
Local cGT			:= Space(20)
Local cMD5Arq		:= ""
Local cClientDir	:= ""
Local cArqLista		:= ""
Local lRet			:= .T.
Local lContinua		:= .T.
Local lEmitNfce		:= LjEmitNFCe()				// Sinaliza se utiliza NFC-e
Local lHomolPaf		:= LjHomolPaf()
Local lSTBPafNfce	:= STBPafNfce()
Local aLinhasArq	:= {}

/*Nao deve realizar validacao do arquivo criptografado quando:
- SAT 
- NFCE
- nใo for homologa็ใo do PAF*/
If !lHomolPaf .OR. lEmitNfce .Or. lSTBPafNfce
	lRet := .T.
	lContinua := .F.
EndIf

If ExistFunc("STBPEInFld")
	STBPEInFld()
EndIf

If lContinua .And. !lLjfPaf
	aAnalisaLeg := LjAnalisaLeg(23)	 // Retorno da funcao de legislacao
	
	If !aAnalisaLeg[1] 
		If !SuperGetMV("MV_LJNSECF") .OR. !lFiscal
			lRet := .T.
			lContinua := .F.
		EndIf
	Else
		If !lFiscal
			lRet := .T.
			lContinua := .F.
		EndIf
	EndIf
EndIf

If lContinua
	cClientDir := GetClientDir()
	nRet := IfPegSerie(nHdlECF,@cSerie)
	cSerie:= SubStr(cSerie,1,20)

	cArqLista := cClientDir + "paflista.txt"

	If nRet == 0
		//Deve-se verificar a Venda Bruta
		nRet := IFStatus( nHdlECF,'17',@cVendaBruta )
		cCript := cVendaBruta
		
		If nRet == 0 .And. Val( cVendaBruta )== 0   
			nRet := IFStatus( nHdlECF,'18',@cGT )
			cCript := cGT		
		Endif
	Else
		lRet := .F.
		lContinua := .F.
	EndIf
EndIf

If lContinua .And. nRet <> 0
	
	If !lLjfPaf .AND. aAnalisaLeg[1]
		LJMsgLeg( aAnalisaLeg )
	Else
		//Ocorreu um erro ao ler o n๚mero de s้rie do ECF ou a fun็ใo de leitura de s้rie nใo estแ disponํvel para este modelo de Impressora.
		MsgStop(STR0002)
	EndIf
	lRet := .F.
	lContinua := .F.
EndIF

If lContinua .And. lRet
	//PAF-ECF: Salva N๚mero de S้rie/GT no mesmo arquivo
	If lLjfPaf
		nHandle := fOpen(cClientDir+"SIGALOJA.VLD")
	Else 
		nHandle := fOpen(cClientDir+"SIGALOJA.BIN")
	EndIF
	
	If nHandle == -1
		If !lLjfPaf .AND. aAnalisaLeg[1]
			LJMsgLeg( aAnalisaLeg )
		Else
			// Ocorreu um ero ao ler o arquivo criptografado.
			MsgStop(STR0005)
		EndIf
		lRet := .F.
		lContinua := .F.
	EndIf
EndIf	
	
If lContinua .And. lRet
	//Le o arquivo criptografado
	nSize 	:= FSeek( nHandle, 0, 2 )
	FSeek( nHandle, 0 )
	cBuffer := Space( nSize )
	FRead( nHandle, @cBuffer, nSize )
	cBkLinha:= cBuffer
	fClose(nHandle)

	//GT criptografado
	//Serie Criptografado
	//Razao Social 
	//CNPJ
	//IE
	//IM
	//Nome do PAF
	//Versao do PAF
    //MD5 PafLista.txt
	aLinhasArq := {}
	If lLjfPaf
		nPos := At(chr(10),cBuffer)
		While nPos > 0
			Aadd(aLinhasArq,Encript(SubStr(cBuffer,1,nPos-1),1))
			cBuffer	:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)
			nPos := At(chr(10),cBuffer)
		end
	EndIf
	
	//Deve ser o MD5 do PAFLista,constante na ultima linha
	If !Empty(cBuffer)
		If lLjfPaf
			Aadd(aLinhasArq,Decode64(SubStr(cBuffer,1,Len(cBuffer)))) //o Encript estava mudando o MD-5 por isso uso Decode64
		Else
			Aadd(aLinhasArq,Encript(cBuffer,1,Len(cBuffer),1))
		EndIf
	EndIf
	
	If lLjfPaf
		cBuffer := aLinhasArq[2]
		cBufferL1:= aLinhasArq[1]
		cMD5Arq := aLinhasArq[Len(aLinhasArq)]
	Else
		cBuffer := aLinhasArq[1]
	EndIf
	
	// Se o numero lido do arquivo for o mesmo lido da impressora entao retorna .T.
	If (AllTrim(cBuffer) == AllTrim(cSerie)) .AND.;
		(!lLjfPaf .Or. ((AllTrim(cBufferL1) == AllTrim(cCript)) .And. (cMD5Arq == STBMd5File( cArqLista ))))
		
		lRet := .T.	
	Else
		If lLjfPaf .OR. !aAnalisaLeg[1]
			// O n๚mero de s้rie gravado no arquivo ้ diferente do n๚mero de s้rie da impressora.		
			MsgStop(STR0004)
			
			If LjVassConc(1) 
				lRet := LJValGT(.T.)
			EndIf
		Else
			LJMsgLeg(aAnalisaLeg)
		EndIf
	EndIf
EndIf	
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJGrvGT	บAutor ณMauro Sano           บ Data ณ  28/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o arquivo criptografado do GT                         บฑฑ
ฑฑบ          ณ Conforme Anexo 09 do RICMS 01 - Santa Catarina             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Recebe o nome do arquivo a ser gravado             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpL1 - Retorna se o arquivo e' valido ou nao              บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja - Venda Balcao - Venda Rapida - LojxECF - SCRFIS  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
Function LJGrvGT( cArquivo , lTotvsPdv )
Local cGT 			:= Space( 20 )			  				// Armazena GT do ECF
Local cVendaBruta	:= Space( 20 ) 			  				// Armazena Venda Bruta do ECF
Local nRet			:= 0					   				// Retorno dos comandos da impressora          
Local nHandle		:= 0					   				// Manipula o arquivo que sera criptografado
Local cCript 		:= Space( 20 ) 							// Guarda o GT ou a Venda Bruta a ser criptografada
Local lRet 			:= .F.		   				   			// Retorno da funcao      
Local lGrava 		:= SuperGetMV( "MV_LJGRVVB", ,.F. )		// Verifica se faz a gravacao da venda bruta diaria em arquivo criptografado
Local cSerie 		:= Space(20)							// Buffer para captura do numero de serie atraves da impressora
Local cConteudo 	:= ""                   
Local cChaveMd5		:= ""
Local lLjfPaf		:= LjNfPafEcf(SM0->M0_CGC)	// Ambiente PAF-ECF
Local cClientDir	:= GetClientDir()
Local cArqLista		:= cClientDir + "PAFLISTA.TXT"

Default lTotvsPdv	:= .F.
                                 
If !lTotvsPdv .And. (lLjfPaf .OR. LJAnalisaLeg(20)[1] .OR. lGrava) 
	// Captura o GT da impressora	
	nRet := IFStatus( nHdlECF,'17',@cVendaBruta )
	cCript := cVendaBruta
	
	If Val( cVendaBruta )== 0 .AND. nRet == 0
 		nRet := IFStatus( nHdlECF,'18',@cGT )
 		cCript := cGT
	Endif
	
	//PAF-ECF: Salva no mesmo arquivo o n๚mero de s้rie do ECF e o MD5 do arquivo PafLista.txt, nao utilizar nesse ponto a rotina LjGrvMd5Ls, devido a performance!!! 
	If lLjfPaf
		nRet := IfPegSerie(nHdlECF,@cSerie)
		
		If File(cArqLista)
			cChaveMd5	:= 'MD5FILE('+"'"+cArqLista+"'"+')'
			cChaveMd5 	:= &(cChaveMd5)
			cChaveMd5 	:= Upper(cChaveMd5)          
		EndIf
	EndIf
			
	If nRet == 0	
		fErase(cClientDir+cArquivo)
		nHandle := fCreate(cClientDir+cArquivo)

		If lLjfPaf			
			//GT criptografado
			cConteudo := Encript(AllTrim( cCript ),0) + Chr(10)
			
			//Serie Criptografado
			cConteudo += Encript(AllTrim( cSerie ),0) + Chr(10)

			//Razao Social 
			cConteudo += Encript(AllTrim( _RAZSOC ),0) + Chr(10)
			
			//CNPJ
			cConteudo += Encript(AllTrim( _CNPJTOT ),0) + Chr(10)
			
			//IE
			cConteudo += Encript(AllTrim( _INSCEST ),0) + Chr(10)
			
			//IM
			cConteudo += Encript(AllTrim( _INSCMUN ),0) + Chr(10)
			
			//Nome do PAF
			cConteudo += Encript(AllTrim( STBFMModPaf() ),0) + Chr(10)
			
			//Versao do PAF
			cConteudo += Encript(AllTrim(STBVerPAFECF("VERSAOAPLIC")),0) + Chr(10)
			
			/*
			Deixar MD5 sempre por ultimo devido a fun็ใo STBGrvMd5Ls
			Nใo inserir a quebra aqui pra seja desconsiderada e ajustada na fun็ใo 
			*/
	        //MD5 PafLista.txt
			cConteudo += Encode64(AllTrim( cChaveMd5 ))
			  
			fWrite(nHandle,cConteudo) // Criptografa			
		Else                             
			fWrite(nHandle,Encript(AllTrim( cCript ),0)) // Criptografa
		EndIf
		
		fClose(nHandle)
		lRet := .T.
	Else     
		If lLjfPaf
			lRet := .F.
		EndIf

		MsgInfo( STR0006 ) //"Houve erro na grava็ใo do arquivo criptografado da Venda Bruta."
	EndIf
	   
ElseIf lTotvsPdv
	lRet := STWGrvGT(cArquivo)
Else
	lRet := .T.
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJGrvCCGT	บAutor ณMauro Sano           บ Data ณ  28/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o arquivo criptografado do GT                         บฑฑ
ฑฑบ          ณ Conforme Anexo 09 do RICMS 01 - Santa Catarina             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Recebe o nome do arquivo a ser gravado             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpL1 - Retorna se o arquivo e' valido ou nao              บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja - Venda Balcao - Venda Rapida - LojxECF - SCRFIS  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
Function LJGrvCCGT( cArquivo , lTotvsPdv )
Local cGT 			:= Space( 20 )			  				// Armazena GT do ECF
Local cVendaBruta	:= Space( 20 ) 			  				// Armazena Venda Bruta do ECF
Local nRet			:= 0					   				// Retorno dos comandos da impressora          
Local nHandle		:= 0					   				// Manipula o arquivo que sera criptografado
Local cCript 		:= Space( 20 ) 							// Guarda o GT ou a Venda Bruta a ser criptografada
Local lRet 			:= .F.		   				   			// Retorno da funcao      
Local lGrava 		:= SuperGetMV( "MV_LJGRVVB", ,.F. )		// Verifica se faz a gravacao da venda bruta diaria em arquivo criptografado
Local cSerie 		:= Space( 20 )							// Buffer para captura do numero de serie atraves da impressora
Local cConteudo 	:= ""                   
Local cChaveMd5		:= ""
Local lLjfPaf		:= LjNfPafEcf(SM0->M0_CGC)				// Ambiente PAF-ECF
Local cBuffer		:= ""
Local cClientDir	:= ""
Local nPos			:= 0

Default lTotvsPdv	:= .F.
                                  
If !lTotvsPdv .And. (lLjfPaf .OR. LJAnalisaLeg(20)[1] .OR. lGrava) 
	// Captura o GT da impressora	
	nRet := IFStatus( nHdlECF,'17',@cVendaBruta )
	cCript := cVendaBruta
	
	If Val( cVendaBruta )== 0 .AND. nRet == 0
		nRet := IFStatus( nHdlECF,'18',@cGT )
	 	cCript := cGT
	Endif
	
	//PAF-ECF: Salva no mesmo arquivo o n๚mero de s้rie do ECF e o MD5 do arquivo PafLista.txt, nao utilizar nesse ponto a rotina LjGrvMd5Ls, devido a performance!!! 
	If lLjfPaf
		nRet := IfPegSerie(nHdlECF,@cSerie)
	EndIf
			
	If nRet == 0
		cClientDir := GetClientDir()
		nHandle := fOpen(cClientDir+cArquivo)
		nSize 	:= FSeek( nHandle, 0, 2 )
		FSeek( nHandle, 0 )
		cBuffer := Space( nSize )
		FRead( nHandle, @cBuffer, nSize )
		fClose(nHandle)
		
		//Com a mudan็a o MD5 ficou na ultima posi็ใo do arquivo e sem o CHR(10)
		nPos := At(chr(10),cBuffer)
		While nPos > 0
			cBuffer	:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)
			nPos := At(chr(10),cBuffer)
		end
		
		cBuffer := Substr(cBuffer,1,Len(cBuffer)) //Linha do MD-5
		cChaveMd5:= Decode64(cBuffer) 	// Descriptografa
		
		fErase(cClientDir+cArquivo)
		nHandle := fCreate(cClientDir+cArquivo)

		If lLjfPaf
			//GT criptografado
			cConteudo := Encript(AllTrim( cCript ),0) + Chr(10)
			
			//Serie Criptografado
			cConteudo += Encript(AllTrim( cSerie ),0) + Chr(10)

			//Razao Social 
			cConteudo += Encript(AllTrim( _RAZSOC ),0) + Chr(10)
			
			//CNPJ
			cConteudo += Encript(AllTrim( _CNPJTOT ),0) + Chr(10)
			
			//IE
			cConteudo += Encript(AllTrim( _INSCEST ),0) + Chr(10)
			
			//IM
			cConteudo += Encript(AllTrim( _INSCMUN ),0) + Chr(10)
			
			//Nome do PAF
			cConteudo += Encript(AllTrim( STBFMModPaf() ),0) + Chr(10)
			
			//Versao do PAF
			cConteudo += Encript(AllTrim(STBVerPAFECF("VERSAOAPLIC")),0) + Chr(10)
			
			/*
			Deixar MD5 sempre por ultimo devido a fun็ใo STBGrvMd5Ls
			Nใo inserir a quebra aqui pra seja desconsiderada e ajustada na fun็ใo 
			*/
	        //MD5 PafLista.txt
			cConteudo += Encode64(AllTrim( cChaveMd5 ))
			  
			fWrite(nHandle,cConteudo) // Criptografa			
		Else                             
			fWrite(nHandle,Encript(AllTrim( cCript ),0)) // Criptografa
		EndIf
		
		fClose(nHandle)
		lRet := .T.
	Else     
		If lLjfPaf
			lRet := .F.
		EndIf

		MsgAlert( STR0006 , "Criptografia" ) //"Houve erro na grava็ใo do arquivo criptografado da Venda Bruta."
	Endif   
ElseIf lTotvsPdv
	lRet := STWGrvCCGT( cArquivo )
Else
	lRet := .T.
EndIf

Return lRet
                                                                                           
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJValGT	บAutor ณMauro Sano           บ Data ณ  28/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o arquivo criptografado do GT                       บฑฑ
ฑฑบ          ณ Conforme Anexo 09 do RICMS 01 - Santa Catarina             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpL1 - Retorna se conseguiu fazer a gravacao              บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja - Venda Balcao - Venda Rapida - LojxECF - SCRFIS  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
Function LJValGT(lRecria)		
Local nRet 		:= 0							 		// Retorno dos comandos enviados a impressora
Local cVendaBruta:= Space( 20 )			 		 		// Valor da Venda Bruta
Local cGT 		:= Space( 20 )			  		 		// Valor do Grante Total
Local cCript 	:= Space( 20 )			   		 		// Valor a ser criptografado
Local cCriptL2	:= Space( 20 )			   		 		// Valor da Venda Bruta
Local cBuffer 	:= Space( 20 )					 		// Armazena os valores criptografados
Local cBufferL2	:= Space( 20 )							// Valor a ser criptografado da VB
Local lRet 		:= .F.  						 		// Retorno da funcao
Local nSize 	:= 0						  	   		// Tamanho do arquivo criptografado
Local nHandle 	:= 0									// Variavel de manipulacao do arquivo
Local lGrava 	:= SuperGetMV( "MV_LJGRVVB", ,.F. )		// Verifica se grava a venda bruta criptografada
Local cArq		:= "SIGALOJA.VLD"						// Nome do arquivo
Local nPos		:= 0
Local cSerie	:= ""
Local cBkLinha	:= ""
Local cArqLista	:=  GetClientDir() + "paflista.txt" 
Local lLjNfPafEcf:= LjNfPafEcf(SM0->M0_CGC)
Local lDifGrdTot:= .F.
Local lDifNumSer:= .F.
Local lDifMD5	:= .F.
Local aLinhasArq:= {}

DEFAULT lRecria		:= .T.	// Verifique se ira permitir recriar o arquivo criptografado, A partir do Ato Cotepe 01.11 permite recriar o arquivo em qualquer momento e nao apenas na inicializacao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se existe legislacao ou se o MV_LJGRVVB esta como .T.ณ
//ณPor enquanto essa validacao serve apenas para SC.             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lLjNfPafEcf .OR. (LJAnalisaLeg(20)[1] .OR. lGrava)
	nRet := IFStatus( nHdlECF,'17',@cVendaBruta )
	cCript := cVendaBruta
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se a venda bruta esta zerada (nao foi feito venda no dia corrente) ณ
	//ณe grava o sigaloja.vld com o GT.                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	// faz a gravacao do arquivo inicial 
	If !File( "SIGALOJA.FST" ) .AND. GetPvProfString( "MICROSIGA", "GRV. INICIAL", "N", GetClientDir() + "SIGALOJA.INI" ) <> "S"
		WritePProString( "MICROSIGA", "GRV. INICIAL", "S", GetClientDir() + "SIGALOJA.INI" )		
		LJGrvGT("SIGALOJA.FST")
		LJGrvGt(cArq)
	Endif		
	
	If Val( cVendaBruta ) == 0 .AND. nRet == 0
		LJGrvGT( cArq )
		nRet := IFStatus( nHdlECF,'18',@cGT )
		cCript := cGT
	Endif
	
	If File(GetClientDir()+"SIGALOJA.VLD")
		nHandle := fOpen(GetClientDir()+"SIGALOJA.VLD")
		
		If nHandle == -1
			// Ocorreu um erro ao ler o arquivo criptografado.
			MsgStop(STR0005)
		EndIf
		
		//Le o arquivo criptografado
		nSize 	:= FSeek( nHandle, 0, 2 )
		FSeek( nHandle, 0 )
		cBuffer := Space( nSize )
		FRead( nHandle, @cBuffer, nSize )
		cBkLinha:= cBuffer
		fClose(nHandle)
		
		//Quando Ambiente PAF-ECF, possui mais linhas
		If lLjNfPafEcf
			nRet 		:= IfPegSerie(nHdlECF,@cSerie)
			cCriptL2	:= cSerie
			
			nPos := At(chr(10),cBuffer)
			
			While nPos > 0
				Aadd(aLinhasArq,Encript(SubStr(cBuffer,1,nPos-1),1))
				cBuffer	:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)
				nPos := At(chr(10),cBuffer)
			end
		EndIf
		
		//Linha do MD5
		If !Empty(cBuffer)
			If lLjNfPafEcf
				Aadd(aLinhasArq,Decode64(SubStr(cBuffer,1,Len(cBuffer))))
			Else
				Aadd(aLinhasArq,Encript(SubStr(cBuffer,1,Len(cBuffer)),1))
			EndIf
		EndIf
		
		cBuffer := aLinhasArq[1]
		
		If Len(aLinhasArq) >= 2 .AND. lLjNfPafEcf
			cBufferL2 := aLinhasArq[2]
			lDifMD5 := aLinhasArq[Len(aLinhasArq)] == STBMd5File( cArqLista )
		Else
			lDifMD5 := .T.
		EndIf
		
		lDifGrdTot:= (AllTrim(cBuffer) == AllTrim(cCript))
		lDifNumSer:= (AllTrim(cBufferL2) == AllTrim(cCriptL2))	
					
		If lDifGrdTot .AND. lDifNumSer .And. lDifMD5
			lRet := .T.
		Else
			If lDifMD5 .And. lRecria .AND. LJLastRedZ()
				Loja420()
				lRet := .T.
			Else 
				MsgStop(STR0007)	// Ocorreu um erro ao ler o arquivo criptografado.	
				If lLjNfPafEcf
					lRet := .F.
				EndIf				
			EndIf			
		EndIf
	Else
		MsgStop(STR0005)	// Ocorreu um erro ao ler o arquivo criptografado.
		lRet := .F.
	Endif		
Else
	lRet := .T.
EndIf

Return lRet
	  
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJLastRedZ	บAutor ณVendas Cliente   บ Data ณ  23/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se conteudo da ultima reducao Z nใo foi modificado บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpL1 - Retorna se ultima reducao Z esta correta           บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja \ FrontLoja										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
Static Function LJLastRedZ()
Local lRet			:= .T.
Local lMVLJVLCRO	:= SuperGetMV( "MV_LJVLCRO",, .F. )	// Sinaliza se permite recriar arquivo mesmo com incremento de CRO
Local cPDV			:= LjGetStation("PDV")
Local dDataRedZ		:= CTOD("")
Local oWS			:= WsFrtPafEcf():New()
Local cWSServer		:= AllTrim(LJGetStation("WSSRV"))
Local lCrz			:= .F.
Local lCro			:= .F.
Local lVendaBrut	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤTฟ
//ณRequisito XXII(Item 7 e 8):											   ณ
//ณComparar os n๚meros do CRZ e do CRO e o valor da Venda Bruta Diแria,    ณ
//ณreferentes a ultima Reducao Z gravada na Memoria Fiscal com os n๚meros  ณ
//ณe valor correspondentes no banco de dados.   						   ณ
//ณA crit้rio da UF, permite recriar quando houver incremento do CRO.      ณ
//ณObs.: Armazena dados RedZ da memoria fiscal na tabela SFI local, utilizaณ
//ณSFI da Retaguarda como base nos arquivos do PAF-ECF.                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤTู                                
//Posiciona na ultima RedZ armazenada em banco local capturada da Memoria Fiscal
DBSelectArea("SFI")
SFI->(DbSetOrder(1)) //FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ
SFI->(dbGoBottom()) //Posiciona no ultimo registro
dDataRedZ := SFI->FI_DTREDZ //SFI->FI_DTMOVTO

//Busca na Retaguarda dados da ultima RedZ utilizados nos arquivos do PAF-ECF
oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw" //Ajusta o caminho do servico
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWs),Nil) //Monta o Header de Autentica็ใo do Web Service
LJMsgRun(STR0008,,{||lRet := oWs:LstRedZ(dDataRedZ, dDataRedZ, cPDV, cEmpAnt,cFilAnt,,.T.)}) // "Executando consulta na retaguarda"

If (lRet == Nil) .OR. (!lRet)
	MsgStop(STR0009) //"Erro na execu็ใo do WebService M้todo: LstRedZ"
	lRet := .F.
Else
	aRetWs := aClone(oWs:oWsLstRedZResult:oWsRedZList)
	oWs:RESET()
	oWs := Nil
	
	LjGrvLog(Nil,"Conteudo do Array aRetWS",aRetWs)
	                                                     
	//Compara CRZ, CRO e Venda Bruta( Memoria(SFI Local) x Banco(Consulta WS Retaguarda) )
	If Len(aRetWs) > 0 
		lCrz 		:= IIF(Val(SFI->FI_NUMREDZ) == aRetWs[01]:nContRedZ,.T.,.F.)					//CRZ - Contador de Reducoes Z
		lCro 		:= IIF(Val(SFI->FI_CRO) == aRetWs[01]:nContReinic .OR.;							//CRO - Contador de Reinicio de Operacoes,
						  (Val(SFI->FI_CRO) > aRetWs[01]:nContReinic) .AND. lMVLJVLCRO, .T.,.F.)	//quando habilitado permite Recriar mesmo com incremento do CRO na Memoria do ECF
		
		lVendaBrut 	:= IIF(SFI->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS+FI_DESISS+FI_CANISS) == aRetWs[01]:nTotBrutDia,.T.,.F.)  	//Venda Bruta
	EndIf
		
	lRet := IIF(lCrz .AND. lCro .AND. lVendaBrut,.T.,.F.)
EndIf      		

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJGrvMd5Ls	บAutor ณVendas Cliente   บ Data ณ  28/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava MD5 da Lista de Arquivos do PAF - Requisito IX 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpL1 - Retorna se rotina foi executada			          บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja \ FrontLoja										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
Function LJGrvMd5Ls
STBGrvMd5Ls(.F.)	
Return Nil
