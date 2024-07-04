#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#INCLUDE 'PLSUA525E.CH'

#define CRLF chr( 13 ) + chr( 10 )
#define F_BLOCK  512



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSTISSNWL
Gerador do arquivo XML - Retorno da Importação

@author    Michel Montoro
@version   1.xx
@since     05/10/2018
/*/
//------------------------------------------------------------------------------------------
Function PLSTISSNWL(oLote, aGuias, aCriticas, cSoapXml, lLoteOdonto)
Local cRet := "" //Retorna a string do xml ou erro gerado

Default aCriticas 	:= {}
Default aGuias	 	:= {}
Default	cSoapXml	:= ""
Default lLoteOdonto := .F.

cRet := geraArquivo(oLote, aGuias, aCriticas, cSoapXml, lLoteOdonto)

Return(cRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraArquivo
Gerador do arquivo Aviso Lote Guia - Processamento dos dados

@author    Michel Montoro
@version   1.xx
@since     05/10/2018
/*/
//------------------------------------------------------------------------------------------
Static Function geraArquivo( oLote, aGuias, aCriticas, cSoapXml, lLoteOdonto )
Local cCodInt	:= PlsIntPad()
Local cNumIdent	:= "" // Numero de Identificação ou Sequencial
Local cFileXML	:= ""
Local cFileHASH := ""
Local cPathXML	:= ""
Local nCabXml	:= 0
Local nArqFull	:= 0
Local nBytes	:= 0
Local cCabTMP	:= ""
Local cDetTMP	:= ""
Local cXmlTMP	:= ""
Local cBuffer	:= ""
Local lFinal	:= .F.
Local cRet		:= ""
Local cSusep	:= ""

Private nArqHash := 0

Default lLoteOdonto := .F.

cNumIdent	:= oLote:cSEQTRAN
cFileXML	:= cCodInt +"_"+ dtos(date()) + strTran(allTrim(time()),":","") +"_"+ cNumIdent + ".tmp"
cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" )

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := STR0013+cPathXML //"Não foi possível criar o diretorio no servidor:"
		Return(cRet)
	EndIf
EndIf
		
nArqFull := fCreate( cPathXML+cFileXML,FC_NORMAL,,.F. )

If nArqFull > 0
	
	cSusep := Posicione("BA0",1,xFilial("BA0")+cCodInt,"BA0_SUSEP")
	
	nArqHash := fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )
	
	//--< Append cabecalho TMP >--
	cCabTMP := geraCabec( cPathXML, cFileXML, oLote, aCriticas, cNumIdent, cSusep )					
	nCabXml := fOpen( cCabTMP,FO_READ )
	If( nCabXml <= 0 )
		cRet := STR0014 + cCabTMP //"Não foi possível abrir o arquivo: "
		FErase(cPathXML+cFileXML)
		Return(cRet)
	Else
		lFinal	:= .F.
		nBytes	:= 0
		cBuffer	:= ""
	
		Do While !lFinal
			nBytes := fRead( nCabXml,@cBuffer,F_BLOCK )
			
			If( fWrite( nArqFull,cBuffer,nBytes ) < nBytes )
				lFinal := .T.
			Else
				lFinal := ( nBytes == 0 )
			EndIf
		EndDo

		fClose( nCabXml )
		fErase( cCabTMP )
	EndIf
	
	//--< Append detalhes TMP >--
	cDetTMP := geraGuias( cPathXML, cFileXML, oLote, aGuias, aCriticas, cSusep, cSoapXml, lLoteOdonto )
	nTmpXml := fOpen( cDetTMP,FO_READ )

	If( nTmpXml <= 0 )
		cRet := STR0014 + cDetTMP //"Não foi possível abrir o arquivo: "
		FErase(cPathXML+cFileXML)
		Return(cRet)
	Else
		lFinal	:= .F.
		nBytes	:= 0
		cBuffer	:= ""
			
		Do While !lFinal
			nBytes := fRead( nTmpXml,@cBuffer,F_BLOCK )
			If( fWrite( nArqFull,cBuffer,nBytes ) < nBytes )
				lFinal := .T.
			Else
				lFinal := ( nBytes == 0 )
			EndIf
		EndDo
	
		fClose( nTmpXml )
		fErase( cDetTMP )
	EndIf
	
	//--< Calculo e inclusao do HASH no arquivo >--					
	fClose( nArqHash )
						
	cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
	
	cXmlTMP += A270Tag( 2,"ans:hash"				,lower( cHash )			,.T.,.T.,.T. )
	
	fWrite( nArqFull,cXmlTMP )
	fClose( nArqFull )
	
	//--< Append GERAL para retorno >--
	cBuffer	:= ""
	cRet 	:= ""	
	nBytes := FT_FUse( cPathXML+cFileXML )
	FT_FGotop()
	While ( !FT_FEof() )
	    cBuffer := FT_FREADLN()
		cRet 	+= cBuffer
		FT_FSkip()
		If !FT_FEof()
			cRet 	+= CRLF
		EndIf
	EndDo
		
	// Fecha o arquivo
	FT_FUse()
	
	fClose( nTmpXml )
	fErase( cPathXML+cFileXML )
	
Else
	cRet := STR0016 + AllTrim( cFileXML ) //"Nao foi possivel criar o arquivo: "
EndIf

Return(cRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraCabec
Compoe os dados do cabecalho do arquivo

@author    Michel Montoro
@version   1.xx
@since     05/10/2018

@param     cPathXML = caminho do arquivo
@param     cFileXML = nome do arquivo
@Return    cFileCAB = nome do arquivo
/*/
//------------------------------------------------------------------------------------------
Static Function geraCabec( cPathXML, cFileXML, oLote, aCriticas, cNumIdent, cSusep )
Local cXML 		:= ""
Local cHorComp	:= AllTrim( time() )
Local cFileCAB	:= cPathXML + criatrab( nil,.F. ) + ".tmp"
Local nArqCab	:= fCreate( cFileCAB,FC_NORMAL,,.F. )
Local cVerTiss	:= oLote:cVERTISS	

If( nArqCab <> -1 )
					
	cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 2,"ans:identificacaoTransacao" ,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 3,"ans:tipoTransacao"			,'PROTOCOLO_RECEBIMENTO' ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 3,"ans:sequencialTransacao"	,cNumIdent				 ,.T.,.T.,.T. )
	cXML += A270Tag( 3,"ans:dataRegistroTransacao"	,convDataXML( dDataBase ),.T.,.T.,.T. )
	cXML += A270Tag( 3,"ans:horaRegistroTransacao"	,cHorComp				 ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T. )
	
	If !EMPTY(cSusep)
		cXML += A270Tag( 2,"ans:origem"					,''						 ,.T.,.F.,.T. )
		cXML += A270Tag( 3,"ans:registroANS"			,cSusep                  ,.T.,.T.,.T. )
		cXML += A270Tag( 2,"ans:origem"					,''						 ,.F.,.T.,.T. )
	ElseIf !EMPTY(oLote:cCGCORI) .OR. !EMPTY(oLote:cCodRDA)
		cXML += A270Tag( 2,"ans:origem"					,''						 ,.T.,.F.,.T. )
		cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''						 ,.T.,.F.,.T. )
		If Len(AllTrim(oLote:cCGCORI)) == 11 //CPF
			cXML += A270Tag( 4,"ans:CPF"				,oLote:cCGCORI           ,.T.,.T.,.T. )
		Elseif Len(AllTrim(oLote:cCGCORI)) == 14 //CNPJ
			cXML += A270Tag( 4,"ans:CNPJ"				,oLote:cCGCORI           ,.T.,.T.,.T. )
		ElseIf !EMPTY(oLote:cCodRDA)
			cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	,oLote:cCodRDA   ,.T.,.T.,.T. )
		EndIf
		cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''						 ,.F.,.T.,.T. )
		cXML += A270Tag( 2,"ans:origem"					,''						 ,.F.,.T.,.T. )
	EndIf
	
	If !EMPTY(oLote:cREGANS)
		cXML += A270Tag( 2,"ans:destino"				,''						 ,.T.,.F.,.T. )
		cXML += A270Tag( 3,"ans:registroANS"			,oLote:cREGANS           ,.T.,.T.,.T. )
		cXML += A270Tag( 2,"ans:destino"				,''					 	 ,.F.,.T.,.T. )
	ElseIf !EMPTY(oLote:cCgcOri) .OR. !EMPTY(oLote:cCodRDA)
		cXML += A270Tag( 2,"ans:destino"				,''						 ,.T.,.F.,.T. )
		cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''						 ,.T.,.F.,.T. )
		If Len(AllTrim(oLote:cCGCORI)) == 11 //CPF
			cXML += A270Tag( 4,"ans:CPF"				,oLote:cCgcOri           ,.T.,.T.,.T. )
		Elseif Len(AllTrim(oLote:cCGCORI)) == 14 //CNPJ
			cXML += A270Tag( 4,"ans:CNPJ"				,oLote:cCgcOri           ,.T.,.T.,.T. )
		ElseIf !EMPTY(oLote:cCodRDA)
			cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	,oLote:cCodRDA   ,.T.,.T.,.T. )
		EndIf
		cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''						 ,.F.,.T.,.T. )
		cXML += A270Tag( 2,"ans:destino"				,''					 	 ,.F.,.T.,.T. )
	EndIf
	
	cXML += A270Tag( 2,"ans:Padrao"					,cVerTiss				 ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.F.,.T.,.T. )
	
	fWrite( nArqCab,cXML )
	fClose( nArqCab )
EndIf

Return(cFileCAB)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraGuias
Grava o protocolo de recebimento.

@author    Michel Montoro
@version   1.xx
@since     05/10/2018

@Return    cFileGUI = Nome do arquivo
/*/
//------------------------------------------------------------------------------------------
Static Function geraGuias( cPathXML, cFileXML, oLote, aGuias, aCriticas, cSusep, cSoapXml, lLoteOdonto ) 
Local cFileGUI	:= cPathXML + criaTrab( nil,.F. ) + ".tmp"
Local nArqGui	:= fCreate( cFileGUI,FC_NORMAL,,.F. )
Local cCnpjDes	:= AllTrim(oLote:cCGCORI) // A origem vira destino
Local cCodRDA	:= AllTrim(oLote:cCodRDA)
Local cNomeDes	:= ""
Local cXMLAux	:= ""
Local cCodPad 	:= ""
Local cCodPro 	:= ""
Local cDescri 	:= ""
Local cProCri	:= ""
Local cProtocol	:= ""
Local nGuias	:= 0
Local nTotGuias	:= 0
Local nGuiCri	:= 0
Local nFor		:= 0
Local nPro		:= 0
Local nCriOpc	:= 0

default lLoteOdonto := .F.

If Len(aCriticas) > 0
	// Define se existe crítica de arquivo
	If aScan(aCriticas,{|x| x[1] == 1 }) > 0
		nCriOpc := 1
	EndIf
EndIf

If ! Empty(cCnpjDes)
	cNomeDes := AllTrim(Posicione("BAU", 4, xFilial("BAU") + cCnpjDes, "BAU_NOME"))
ElseIf ! Empty(cCodRDA)
	cNomeDes := AllTrim(Posicione("BAU", 1, xFilial("BAU") +  cCodRDA, "BAU_NOME"))
EndIf

If( nArqGui == -1 )
	msgAlert( STR0016 + cFileGUI ) //"Nao foi possivel criar o arquivo: "
Else	

	cXMLAux += A270Tag( 1,"ans:recebimentoLote"			,''	,.T.,.F.,.T. )
	
	// Cria BXX e BCI se não houver nenhuma crítica
	If Empty(aCriticas)
		cProtocol := PLTOnGrBXX(cPathXML,cFileXML,oLote,aGuias,dDataBase,cSoapXml)
	Else
		cProtocol := AllTrim( oLote:cNUMLOTE )
	EndIf
	
	If nCriOpc <> 1 //Glosa do ARQUIVO ou RDA
		
		nGuias := Len(aGuias)
		
		ProcRegua( nGuias )
		
		cXMLAux += A270Tag( 2,"ans:protocoloRecebimento"	,''									,.T.,.F.,.T. )
	    cXMLAux += A270Tag( 3,"ans:registroANS"				,AllTrim(cSusep)					,.T.,.T.,.T. )
	    cXMLAux += A270Tag( 3,"ans:dadosPrestador"			,''									,.T.,.F.,.T. )
	    If Len(cCnpjDes) == 11 //CPF
			cXMLAux += A270Tag( 4,"ans:cpfContratado"				, cCnpjDes ,.T.,.T.,.T. )
		Elseif Len(cCnpjDes) == 14 //CNPJ
			cXMLAux += A270Tag( 4,"ans:cnpjContratado"				, cCnpjDes ,.T.,.T.,.T. )
		ElseIf !EMPTY(cCodRDA)
			cXMLAux += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA  ,.T.,.T.,.T. )
		EndIf
		
		cXMLAux += A270Tag( 4,"ans:nomeContratado"			, cNomeDes 							,.T.,.T.,.T. )
	    cXMLAux += A270Tag( 3,"ans:dadosPrestador"			,''									,.F.,.T.,.T. )
	    cXMLAux += A270Tag( 3,"ans:numeroLote"				,AllTrim( oLote:cNUMLOTE )			,.T.,.T.,.T. )
	    cXMLAux += A270Tag( 3,"ans:dataEnvioLote"			,convDataXML( dDataBase )			,.T.,.T.,.T. )
	    
	    cXMLAux += A270Tag( 3,"ans:detalheProtocolo"		,''									,.T.,.F.,.T. )
	    cXMLAux += A270Tag( 4,"ans:numeroProtocolo"			,cProtocol							,.T.,.T.,.T. )
	    cXMLAux += A270Tag( 4,"ans:valorTotalProtocolo"		,AllTrim(str(round(nTotGuias,2)))	,.T.,.T.,.T.,.F. )
	    
	    cXMLAux += A270Tag( 4,"ans:dadosGuiasProtocolo"		,''									,.T.,.F.,.T. )
	    
	    fWrite( nArqGui,cXMLAux )
		cXMLAux := ""
		
		if lLoteOdonto

			For nFor := 1 To Len(aGuias)
				
				cXMLAux += A270Tag( 5,"ans:dadosGuiasOdonto"			,''										,.T.,.F.,.T. )

				cXMLAux += A270Tag( 6,"ans:numeroGuiaPrestador"	,AllTrim( aGuias[nFor]:cNUMGUIPRE )		,.T.,.T.,.T. )
				If !Empty(aGuias[nFor]:cNUMGUIOPE)
					cXMLAux += A270Tag( 6,"ans:numeroGuiaOperadora"	,AllTrim( aGuias[nFor]:cNUMGUIOPE )	,.T.,.T.,.T. ) //Opcional
				EndIf

				cXMLAux += A270Tag( 6,"ans:numeroCarteira"		,AllTrim( aGuias[nFor]:oBENEF:cCARTEIRINHA ),.T.,.T.,.T. )
				cXMLAux += A270Tag( 6,"ans:atendimentoRN"		,AllTrim( aGuias[nFor]:oBENEF:cATENDRN )	,.T.,.T.,.T. )
				cXMLAux += A270Tag( 6,"ans:nomeBeneficiario"	,AllTrim( aGuias[nFor]:oBENEF:cNOME )		,.T.,.T.,.T. )
				If !Empty(aGuias[nFor]:oBENEF:cCNS) 
					cXMLAux += A270Tag( 6,"ans:numeroCNS"		,AllTrim( aGuias[nFor]:oBENEF:cCNS )		,.T.,.T.,.T. ) //Opcional
				EndIf
							
				cXMLAux += A270Tag( 5,"ans:dadosGuiasOdonto"				,''									,.F.,.T.,.T. )
				
				fWrite( nArqGui,cXMLAux )
				cXMLAux := ""
					
			Next nFor
		else
			For nFor := 1 To Len(aGuias)
				
				cXMLAux += A270Tag( 5,"ans:dadosGuias"			,''										,.T.,.F.,.T. )
				cXMLAux += A270Tag( 6,"ans:numeroGuiaPrestador"	,AllTrim( aGuias[nFor]:cNUMGUIPRE )		,.T.,.T.,.T. )
				If !Empty(aGuias[nFor]:cNUMGUIOPE)
					cXMLAux += A270Tag( 6,"ans:numeroGuiaOperadora"	,AllTrim( aGuias[nFor]:cNUMGUIOPE )	,.T.,.T.,.T. ) //Opcional
				EndIf
				cXMLAux += A270Tag( 6,"ans:dadosBeneficiario"	,''											,.T.,.F.,.T. )
				cXMLAux += A270Tag( 7,"ans:numeroCarteira"		,AllTrim( aGuias[nFor]:oBENEF:cCARTEIRINHA ),.T.,.T.,.T. )
				cXMLAux += A270Tag( 7,"ans:atendimentoRN"		,AllTrim( aGuias[nFor]:oBENEF:cATENDRN )	,.T.,.T.,.T. )
				cXMLAux += A270Tag( 7,"ans:nomeBeneficiario"	,AllTrim( aGuias[nFor]:oBENEF:cNOME )		,.T.,.T.,.T. )
				If !Empty(aGuias[nFor]:oBENEF:cCNS) 
					cXMLAux += A270Tag( 7,"ans:numeroCNS"		,AllTrim( aGuias[nFor]:oBENEF:cCNS )		,.T.,.T.,.T. ) //Opcional
				EndIf
				cXMLAux += A270Tag( 6,"ans:dadosBeneficiario"	,''									,.F.,.T.,.T. )
				
				fWrite( nArqGui,cXMLAux )
				cXMLAux := ""
				
				nGuiCri := 0
				If Len(aCriticas) > 0
					nGuiCri := aScan(aCriticas,{|x| x[1] == 2 .AND. x[2] == nFor})
					If nGuiCri > 0
						nCriOpc := 2
					EndIf
				EndIf
				If nCriOpc == 2 .AND. nGuiCri > 0// Glosa da Guia
					//====================================== TAG - glosaGuia é OPCIONAL ======================================
					cXMLAux += A270Tag( 6,"ans:glosaGuia"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 7,"ans:motivoGlosa"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 8,"ans:codigoGlosa"			,aCriticas[nGuiCri][04]					,.T.,.T.,.T. )
					cXMLAux += A270Tag( 8,"ans:descricaoGlosa"		,aCriticas[nGuiCri][05]					,.T.,.T.,.T. ) //Opcional
					cXMLAux += A270Tag( 7,"ans:motivoGlosa"			,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:glosaGuia"			,''										,.F.,.T.,.T. )
					//=======================================================================================================
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""	
				Else
					cXMLAux += A270Tag( 6,"ans:procedimentosRealizados"		,''								,.T.,.F.,.T. )
					
					//Alterar forma para quando não for Consulta e tiver mais de um Procedimento na Guia
					if oLote:cTipoGuia == "01"
						
						cXMLAux += A270Tag( 7,"ans:procedimentoRealizado"	, ''							,.T.,.F.,.T. )
						if oLote:cVERTISS >= "3.04.00"
							cXMLAux += A270Tag( 8,"ans:sequencialItem"		,aGuias[nFor]:OPROCED:CSEQITEM	,.T.,.T.,.T. )
						endif
						cXMLAux += A270Tag( 8,"ans:dataExecucao"			,aGuias[nFor]:cDATAATEND		,.T.,.T.,.F. )
						cXMLAux += A270Tag( 8,"ans:procedimento"			,''								,.T.,.F.,.T. )
						
						cCodPad := aGuias[nFor]:oPROCED:cCODTAB
						cXMLAux += A270Tag( 9,"ans:codigoTabela"			,cCodPad						,.T.,.T.,.T. )
						cCodPro := aGuias[nFor]:oPROCED:cCODPRO
						cXMLAux += A270Tag( 9,"ans:codigoProcedimento"		,cCodPro						,.T.,.T.,.T. )
						
						cCodPad	:= AllTrim(PLSGETVINC( "BTU_VLRBUS", "BR4", .F., "87"	, cCodPad,	 		.T. ))
						cCodPro := AllTrim(PLSGETVINC( "BTU_VLRBUS", "BR8", .F., cCodPad, cCodPad+cCodPro, 	.T. ))
					
						cDescri := PLSIMPVINC("BR8",aGuias[nFor]:oPROCED:cCODTAB	,	cCodPro	,.T.)
						If Empty(cDescri)
							cDescri := AllTrim(Posicione("BR8",1,xFilial("BR8")+cCodPro,"BR8_DESCRI"))
						EndIf
						cXMLAux += A270Tag( 9,"ans:descricaoProcedimento"	,AllTrim( cDescri )				,.T.,.T.,.T. )
						cXMLAux += A270Tag( 8,"ans:procedimento"			,''								,.F.,.T.,.T. )							
						cXMLAux += A270Tag( 8,"ans:quantidadeExecutada"		,AllTrim(str(round(1,2)))		,.T.,.T.,.T. )
						cXMLAux += A270Tag( 8,"ans:valorUnitario"			,AllTrim(str(round(aGuias[nFor]:oPROCED:nVLRPRO,2))),.T.,.T.,.T.,.F. )
						cXMLAux += A270Tag( 8,"ans:valorTotal"				,AllTrim(str(round(aGuias[nFor]:oPROCED:nVLRPRO,2))),.T.,.T.,.T.,.F. )
						
						nGuiCri := 0
						cProCri	:= ""
						cProCri := aGuias[nFor]:oPROCED:cCODPRO
						If Len(aCriticas) > 0
							nGuiCri := aScan(aCriticas,{|x| x[1] == 3 .AND. x[2] == nFor .AND. x[3] == cProCri})
							If nGuiCri > 0
								nCriOpc := 3
							EndIf
						EndIf
						If nCriOpc == 3
							//================================= TAG - glosasProcedimento é OPCIONAL =================================
							cXMLAux += A270Tag( 8,"ans:glosasProcedimento"		,''								,.T.,.F.,.T. )
							cXMLAux += A270Tag( 9,"ans:motivoGlosa"				,''								,.T.,.F.,.T. )
							cXMLAux += A270Tag(10,"ans:codigoGlosa"				,aCriticas[nGuiCri][04]			,.T.,.T.,.T. )
							cXMLAux += A270Tag(10,"ans:descricaoGlosa"			,aCriticas[nGuiCri][05]			,.T.,.T.,.T. ) //Opcional
							cXMLAux += A270Tag( 9,"ans:motivoGlosa"				,''								,.F.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:glosasProcedimento"		,''								,.F.,.T.,.T. )
							//======================================================================================================
						EndIf
						
						cXMLAux += A270Tag( 7,"ans:procedimentoRealizado"	, ''							,.F.,.T.,.T. )
						
						fWrite( nArqGui,cXMLAux )
						cXMLAux := ""
						
					//Next nPro
					else
					
						For nPro := 1 To LEN(aGuias[nFor]:aProcImp)
							
							cXMLAux += A270Tag( 7,"ans:procedimentoRealizado"	, ''							,.T.,.F.,.T. )
							if oLote:cVERTISS >= "3.04.00"
								cXMLAux += A270Tag( 8,"ans:sequencialItem"		,aGuias[nFor]:OPROCED:CSEQITEM	,.T.,.T.,.T. )
							endif
							cXMLAux += A270Tag( 8,"ans:dataExecucao"			,aGuias[nFor]:aProcImp[nPro,1]	,.T.,.T.,.F. )
							cXMLAux += A270Tag( 8,"ans:procedimento"			,''								,.T.,.F.,.T. )
							
							cCodPad := aGuias[nFor]:aProcImp[nPro,4]
							cXMLAux += A270Tag( 9,"ans:codigoTabela"			,cCodPad						,.T.,.T.,.T. )
							cCodPro := aGuias[nFor]:aProcImp[nPro,5]
							cXMLAux += A270Tag( 9,"ans:codigoProcedimento"		,cCodPro						,.T.,.T.,.T. )
							
							cCodPad	:= AllTrim(PLSGETVINC( "BTU_VLRBUS", "BR4", .F., "87"	, cCodPad,	 		.T. ))
							cCodPro := AllTrim(PLSGETVINC( "BTU_VLRBUS", "BR8", .F., cCodPad, cCodPad+cCodPro, 	.T. ))
						
							cDescri := PLSIMPVINC("BR8",aGuias[nFor]:aProcImp[nPro,4]	,	cCodPro	,.T.)
							If Empty(cDescri)
								cDescri := AllTrim(Posicione("BR8",1,xFilial("BR8")+cCodPro,"BR8_DESCRI"))
							EndIf
							cXMLAux += A270Tag( 9,"ans:descricaoProcedimento"	,AllTrim( cDescri )				,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:procedimento"			,''								,.F.,.T.,.T. )							
							cXMLAux += A270Tag( 8,"ans:quantidadeExecutada"		,AllTrim(str(round(val(aGuias[nFor]:aProcImp[nPro,7]),2)))		,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:valorUnitario"			,AllTrim(str(round(aGuias[nFor]:aProcImp[nPro,11],2))),.T.,.T.,.T.,.F. )
							cXMLAux += A270Tag( 8,"ans:valorTotal"				,AllTrim(str(round(aGuias[nFor]:aProcImp[nPro,12],2))),.T.,.T.,.T.,.F. )
							
							nGuiCri := 0
							nCriOpc := 0
							cProCri := ""
							cProCri := aGuias[nFor]:aProcImp[nPro,5]
							If Len(aCriticas) > 0
								nGuiCri := aScan(aCriticas,{|x| x[1] == 3 .AND. x[2] == nFor .AND. x[3] == cProCri})
								If nGuiCri > 0
									nCriOpc := 3
								EndIf
							EndIf
							If nCriOpc == 3
								//================================= TAG - glosasProcedimento é OPCIONAL =================================
								cXMLAux += A270Tag( 8,"ans:glosasProcedimento"		,''								,.T.,.F.,.T. )
								cXMLAux += A270Tag( 9,"ans:motivoGlosa"				,''								,.T.,.F.,.T. )
								cXMLAux += A270Tag(10,"ans:codigoGlosa"				,aCriticas[nGuiCri][04]			,.T.,.T.,.T. )
								cXMLAux += A270Tag(10,"ans:descricaoGlosa"			,aCriticas[nGuiCri][05]			,.T.,.T.,.T. ) //Opcional
								cXMLAux += A270Tag( 9,"ans:motivoGlosa"				,''								,.F.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:glosasProcedimento"		,''								,.F.,.T.,.T. )
								//======================================================================================================
							EndIf
							
							cXMLAux += A270Tag( 7,"ans:procedimentoRealizado"	, ''							,.F.,.T.,.T. )
							
							fWrite( nArqGui,cXMLAux )
							cXMLAux := ""
							
						Next nPro
					
					endif
					
					cXMLAux += A270Tag( 6,"ans:procedimentosRealizados"		,''								,.F.,.T.,.T. )
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
				
					//================================== Fim da TAG - procedimentosExecutados =======================================
				
				EndIf
				
				cXMLAux += A270Tag( 5,"ans:dadosGuias"				,''									,.F.,.T.,.T. )
				
				fWrite( nArqGui,cXMLAux )
				cXMLAux := ""
					
			Next nFor
	   	endif
	    cXMLAux += A270Tag( 4,"ans:dadosGuiasProtocolo"		,''									,.F.,.T.,.T. )
	    cXMLAux += A270Tag( 3,"ans:detalheProtocolo"		,''									,.F.,.T.,.T. )
	    cXMLAux += A270Tag( 2,"ans:protocoloRecebimento"	,''									,.F.,.T.,.T. )
	    
	Else //mensagemErro 
		
		cXMLAux += A270Tag( 2,"ans:mensagemErro"		,''							,.T.,.F.,.T. )
	    If Len(aCriticas) > 0
		    cXMLAux += A270Tag( 3,"ans:codigoGlosa"		,aCriticas[01][04]			,.T.,.T.,.T. )
		    If !EMPTY(aCriticas[01][05])
		    cXMLAux += A270Tag( 3,"ans:descricaoGlosa"	,aCriticas[01][05]			,.T.,.T.,.T. ) //Opcional
		    EndIf
		Else
			cXMLAux += A270Tag( 3,"ans:codigoGlosa"		,"1011"						,.T.,.T.,.T. )
		EndIf
		cXMLAux += A270Tag( 2,"ans:mensagemErro"		,''							,.F.,.T.,.T. )
		
	EndIf
	
	cXMLAux += A270Tag( 1,"ans:recebimentoLote"			,''	,.F.,.T.,.T. )
	
	fWrite( nArqGui,cXMLAux )
	fClose( nArqGui )
	
EndIf

Return cFileGUI

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A270Tag
Formata a TAG XML a ser escrita no arquivo

@author    Jonatas Almeida
@version   1.xx
@since     02/09/2016

@param nSpc    = quantidade de tabulacao para identar o arquivo
@param cTag    = nome da tab
@param cVal    = valor da tag
@param lIni    = abertura de tag
@param lFin    = fechamento de tag
@param lPerNul = permitido nulo na tag
@param lRetPto = retira caracteres especiais
@param lEnvTag = retorna o conteudo da tag

@Return cRetTag= tag ou vazio
/*/
//------------------------------------------------------------------------------------------
Static Function A270Tag( nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag )
	Local	cRetTag := "" // Tag a ser gravada no arquivo texto
	
	Default lRetPto	:= .T.
	Default lEnvTag	:= .T.

	If( !empty( cVal ) .or. lPerNul )
		If( lIni ) // Inicializa a tag ?
			cRetTag += '<' + cTag + '>'
			cRetTag += AllTrim( iIf( lRetPto,PlRetponto( cVal ),cVal ) )
		EndIf

		If( lFin ) // Finaliza a tag ?
			cRetTag += '</' + cTag + '>'
		EndIf
		
		If lEnvTag .And. ( nArqHash > 0 ) // Escreve conteudo da tag no temporario pra calculo do hash
			FWrite(nArqHash,AllTrim(IIf(lRetPto,PlRetponto(cVal),cVal))) 
		EndIf

		cRetTag := replicate( "	", nSpc ) + cRetTag + CRLF // Identa o arquivo
	EndIf
Return iIf( lEnvTag,cRetTag,"" )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A270Hash
Calculo do hash

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016
@param     cHashFile	= nome do arquivo
@param     nArqFull		= Arquivo de hash
@Return    cRetHash		= Codigo Hash

/*/
//------------------------------------------------------------------------------------------
Static Function A270Hash( cHashFile,nArqFull )
	Local cRetHash    := ""			// Hash calculado do arquivo SBX
	Local cBuffer	  := ""			// Buffer lido
	Local cHashBuffer := ""			// Buffer do hash calculado
	Local cFnHash     := "MD5File"	// Definicao da função MD5File
	Local nBytesRead  := 0			// Quantidade de bytes lidos no arquivo
	Local nTamArq	  := 0			// Tamanho do arquivo em bytes
	Local nFileHash	  := nArqFull	// Arquivo de hash
	Local aPatch      := { }		// Conteudo do diretorio

	aPatch := directory( cHashFile,"F" )

	If( len( aPatch ) > 0 )
		nTamArq := aPatch[1,2]/1048576

		If( nTamArq > 0.9 )
			// Utilizado a macro-execucao por solicitacao da tecnologia, para evitar  
			// erro na funcao MD5File decorrente a utilizacao de binarios mais antigos
			cRetHash := &( cFnHash + "('" + cHashFile + "')" )
		Else
			cBuffer   := space( F_BLOCK )
			nFileHash := fOpen( lower( cHashFile),FO_READ )
			nTamArq   := aPatch[ 1,2 ]	//Tamanho em bytes

			do while nTamArq > 0
				nBytesRead	:= fRead( nFileHash,@cBuffer,F_BLOCK )
				nTamArq		-= nBytesRead
				cHashBuffer	+= cBuffer
			endDo
			
			fClose( nFileHash )
			fErase( lower( cHashFile ) )
			cRetHash := md5( cHashBuffer,2 )
		EndIf
	Else
		msgInfo( STR0018 + cHashFile + CRLF + STR0019 ) //"O arquivo não foi encontrado ou não está acessível: " # "Hash do arquivo não pode ser calculado!"
	EndIf
Return cRetHash

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} convDataXML
Formatador de datas para o arquivo XML

@author    Jonatas Almeida
@version   1.xx
@since     5/09/2016
@param     cDataAnt	= Data nao formatada
@Return    cNovaData = Data formatada para o XML

/*/
//------------------------------------------------------------------------------------------
Static Function convDataXML( cDataAnt )
	Local cNovaData := ""
	
	If( cDataAnt <> nil )
		If( valType( cDataAnt ) == "D" )
			cDataAnt := DtoS( cDataAnt )
		Else
			cDataAnt := AllTrim( cDataAnt )
		EndIf
		
		If(! empty( cDataAnt ))
			cNovaData := subStr( cDataAnt,1,4 ) + "-"
			cNovaData += subStr( cDataAnt,5,2 ) + "-"
			cNovaData += subStr( cDataAnt,7,2 )
		EndIf
	EndIf
Return cNovaData

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validXML
Validador do arquivo XML em cima do arquivo XSD

@author    Jonatas Almeida
@version   1.xx
@since     5/09/2016
@param     cDataAnt	= Data nao formatada
@Return    [lRet], lógica 

/*/
//------------------------------------------------------------------------------------------
Static Function validXML( cXML,cXSD )
	Local cError	:= ""
	Local cWarning	:= ""
	Local lRet		:= .F.

	//--< Valida um arquivo XML com o XSD >--
	If( xmlFVldSch( cXML,cXSD,@cError,@cWarning ) )
		lRet := .T.
	EndIf

	If( !lRet )
		If( msgYesNo( STR0020 ) ) //"Existem erros na validação do arquivo XML. Deseja salvar o arquivo de LOG?"
			geraLogErro( cError )
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraLogErro
Grava arquivo de log

@author    Jonatas Almeida
@version   1.xx
@since     8/09/2016
@param     cError = lista de erros encontrados

/*/
//------------------------------------------------------------------------------------------
Static Function geraLogErro( cError )
	Local cMascara	:= STR0021 + " .LOG | *.log" //"Arquivos"
	Local cTitulo	:= STR0022 //"Selecione o Local"
	Local nMascpad	:= 0
	Local cRootPath	:= ""
	Local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	Local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	Local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	Local cFileLOG	:= AllTrim( B2T->B2T_SEQLOT ) + "_" + dtos( date() ) + "_" + strTran( AllTrim( time() ),":","" ) + ".log"
	Local cPathLOG	:= ""	
	Local nArqLog	:= 0	

	cPathLOG	:= cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL,,.F. )
	
	fWrite( nArqLog,cError )
	fClose( nArqLog )
Return

/*/{Protheus.doc} PLTOnGrBXX
Submete arquivo
@author TOTVS
@since 17/07/12
@version 1.0
/*/
Static Function PLTOnGrBXX(cDirOri,cNomeArq,oLote,aGuias,dDtBsBXX,cSoapXml)
LOCAL cCodRda		:= oLote:cCODRDA
LOCAL cTipGui		:= oLote:cTipoGuia
LOCAL cLotGui		:= oLote:cNUMLOTE
LOCAL nTotEve		:= oLote:nQTDGUIAS
LOCAL nTotGui		:= oLote:nQTDGUIAS
LOCAL nValTot		:= oLote:nVALTOTAL
LOCAL cTissVer		:= oLote:cVERTISS
LOCAL cIdXML		:= oLote:cNUMLOTE

LOCAL aRet			:= {}
LOCAL cRet			:= ""
LOCAL cSeqBXX		:= ""
LOCAL aArq			:= {}
LOCAL aAreaXX		:= BXX->(GetArea())

DEFAULT dDtBsBXX	:= dDataBase

aArq := PlgeraXML(cSoapXml, oLote)

If cTipGui == "13"
	cTipGui := "07" //altera para gravação do BXX de odonto
endif
// Grava na BXX
PLSMANBXX(cCodRda,aArq[02],cTipGui,cLotGui,nTotEve,nTotGui,nValTot,/*nOpc*/,/*nRecno*/,/*lProcOk*/,aRet, @cSeqBXX, dDtBsBXX, "2", cTissVer, cIdXML)
cRet := BXX->BXX_CODPEG
// Grava na Banco de Conhecimento
PLSINCONH(aArq[01]+aArq[02], "BXX", xFilial("BXX") + cSeqBXX)
    
BXX->(RestArea(aAreaXX))

return cRet

/*/{Protheus.doc} PLTisOnBXX
Retorna o status do BXX quando encontrado
@author TOTVS
@since 17/07/12
@version 1.0
/*/
Function PLTisOnBXX(oLote, cCodRDA)
Local aAreaXX 	:= BXX->(GetArea())
Local cRet		:= ""
Local cCodInt	:= PlsIntPad()
Local cIdXML	:= oLote:cNUMLOTE

BXX->(DbSetOrder(8)) //BXX_FILIAL+BXX_CODINT+BXX_CODRDA+BXX_IDXML 
If BXX->(MsSeek(xFilial("BXX") + cCodInt + cCodRda + cIdXML))
	cRet := PLSTISSNWL( oLote, {}, {{1, 0, "", "5053" ,"IDENTIFICADOR JÁ INFORMADO - N.Lote: " + cIdXML}} )
EndIf					

BXX->(RestArea(aAreaXX))

Return(cRet)


/*/{Protheus.doc} PLDempgOnl
Função para direcionamento dos web services tissonline:
- Demonstrativo de pagamento
- Demonstrativo de análise de conta
- demonstrativo de pagamento Odonto (implementação futura)
@author Oscar
@since 08/02/2019
@version 1.0
/*/
function PLDempgOnl(lPortal, lControl, aDadDemons, lAutoma)

Local cRet		:= ""
Local cSeqTran	:= ""
Local cCodRDA	:= ""
Local cCdRdabody:= ""
Local aRdaOrig	:= {,,} //Identificação Prestador no cabeçalho {código,cpf,cnpj}
Local aRdaCorpo	:= {,,} //Identificação Prestador no corpo {código,cpf,cnpj}
Local cCPFCNPJR	:= ""
Local cRegANSOpe:= ""
local cCodope	:= ""
Local cNomeOpe	:= ""
local cCNPJOpe	:= ""
Local cNomeRDA	:= ""
Local adadPag	:= {}
local cTipoDemo := ""
Local cSql		:= ""
local cXml		:= HttpOtherContent()
Local oXml		:= nil
Local cSoapXML	:= ""
Local aRetObj	:= {}
Local cdatPag	:= ""
Local adadDebCre:= {}
Local aDadDC	:= {}
Local cCnes		:= ""
Local lPorData	:= .F.
Local cCompeten	:= ""
Local lDemoACT	:= .F.
Local aProtoc	:= {}
Local nProcs	:= 0
Local nJ		:= 1
Local cNewPath	:= ""
Local cPEGinSql	:= ""
Local aDadBD6	:= {}
Local cForPGt	:= ""
Local aDadBan	:= {"", "", ""}
Local cfornec	:= ""
Local cPathLogin:= ""
Local cLogin	:= ""
Local cSenha	:= ""
Local lMV_PLLGSN:= GetNewPar("MV_PLLGSN", .F.)
Local aCritARQ	:= {.F., "", ""}
Local cVerArq	:= ""
Local nK		:= 1
Local lPLSUNI	:= getNewPar("MV_PLSUNI", "0") == "1"
Local cPathTagCb:= ""
Local cPathTagBd:= ""

Default lPortal  	:= .F.
default lControl 	:= .T.
default aDadDemons  := {}
default lAutoma 	:= .F.

private cNS     := ""

//solicitação enviada sem mensagem, retorna a definição do web service
If empTy(cXml) .and. !lAutoma
	return ProcOnLine("solicitacaodemonstrativoretorno", "")
endIf

If !lPortal
	
	cVerArq	:= Substr(cXml,At("Padrao>", cXml) + Len("Padrao>"),7)
		
	HttpCtType( "text/xml; charset="+'UTF-8' )
		
	aRetObj := VldWSdemoP(cXml,"tissWebServicesV" + StrTran(cVerArq, ".", "_") + ".xsd")

	//conout( "2" + CHR(13)+CHR(10)+Str(Seconds())+CHR(13)+CHR(10) )
	If aRetObj[1]
		cSoapXML := aRetObj[3]
		
		oXML := TXmlManager():New()
		if empty(cNS)
		    // Removo da tag loteGuiasWS os URL's pois estava dando falha no parse.
		    nPos := At(">",Upper(cSoapXml))      
		    cSoapPt1 := Substr(cSoapXml,1,nPos-1)
		    cSoapPt2 := Substr(cSoapXml,nPos,len(cSoapXml))
		    cSoapXml := "      <solicitacaoDemonstrativoRetornoWS" + cSoapPt2
		endif
		
		//conout( "3" + CHR(13)+CHR(10)+Str(Seconds())+CHR(13)+CHR(10) )
		
		lRet := oXML:Parse(cSoapXml)
		
		//conout( "4" + CHR(13)+CHR(10)+Str(Seconds())+CHR(13)+CHR(10) )
		
		if lRet 	
		    aNS := oXML:XPathGetRootNsList()
		    nPos := ascan(aNS,{|x| upper(alltrim(x[1])) == upper(cNS) })
		    If nPos > 0
				oXML:XPathRegisterNs( aNS[ nPos ][ 1 ],aNS[ nPos ][ 2 ] )		
			EndIf
		EndIf
		
		//conout( "5" + CHR(13)+CHR(10)+Str(Seconds())+CHR(13)+CHR(10) )
		
		//Seto o patch
		cPathTagCb:= addNS("/solicitacaoDemonstrativoRetornoWS/cabecalho")

		if( oXml:XPathHasNode( cPathTagCb ) )

			//sequencialTransacao
		    cSeqTran := oXML:XPathGetNodeValue( cPathTagCb + addNS("/identificacaoTransacao/sequencialTransacao"))
			
			//Bloco de validação do Prestador - Início
			aRdaOrig[1] :=	oXML:XPathGetNodeValue( cPathTagCb + addNs ("/origem/identificacaoPrestador/codigoPrestadorNaOperadora" ))
			aRdaOrig[2] :=	oXML:XPathGetNodeValue( cPathTagCb + addNs ("/origem/identificacaoPrestador/CPF" ))
			aRdaOrig[3] :=	oXML:XPathGetNodeValue( cPathTagCb + addNs ("/origem/identificacaoPrestador/CNPJ" ))
			cCodRda		:= buscaCRede(aRdaOrig[3],aRdaOrig[2],aRdaOrig[1])
			cCodRda := iif(cCodRda == "prestadorInvalido","000000",) //retirar na versão com validação
			if /*(cCodRda == cCdRdabody) .and.*/ cCodRda != "prestadorInvalido"
				//BAU é seekada na function buscaCRede() 
				cNomeRDA 	:= BAU->BAU_NOME
				cForPGt 	:= BAU->BAU_FORPGT
				cfornec 	:= BAU->BAU_CODSA2
				cCPFCNPJR 	:= alltrim(BAU->BAU_CPFCGC)
			else
			/*	aCritARQ[1] := .T.
			   	aCritARQ[2] := "CÓDIGO PRESTADOR INVÁLIDO"
			   	aCritARQ[3] := "1203"*/
			endif
			//Bloco de validação do Prestador - Fim
		   
		   cRegANSOpe := oXML:XPathGetNodeValue( cPathTagCb + addNs("/destino/registroANS" ))
		   
		   BA0->(dbSetOrder(5))
		   If BA0->(MsSeek(xfilial("BA0") + alltrim(cRegANSOpe)))
				cCodOpe := BA0->BA0_CODIDE + BA0->BA0_CODINT
				cNomeOpe := BA0->BA0_NOMINT
				cCNPJOpe := BA0->BA0_CGC
		   EndIf
		   
		   BB8->(dbsetOrder(1))
		   If BB8->(MsSeek(xfilial("BB8") + cCodRDA + cCodOpe))
				While !(BB8->(EoF())) .AND. BB8->(BB8_CODIGO+BB8_CODINT) == cCodRDA + cCodOpe .AND. (empTy(BB8->BB8_CNES) .OR. BB8->BB8_CNES == '9999999')
					BB8->(DbSkip())
				EndDo
				If BB8->(BB8_CODIGO+BB8_CODINT) == cCodRDA + cCodOpe .AND. !(empTy(BB8->BB8_CNES) .OR. BB8->BB8_CNES == '9999999')
					ccnes := BB8->BB8_CNES
				else
					ccnes := '9999999'
				EndIF
		   else
				ccnes := '9999999'
		   endIf
		   
		   If lMV_PLLGSN
		   		//3100	PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM
		   		//3111	CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO
			   cPathLogin := cPathTagCb + addNs("/loginSenhaPrestador" )
			   If ( oXml:XPathHasNode( cPathLogin ) )
					cLogin	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/loginPrestador" ))
					cSenha	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/senhaPrestador" ))
					BSW->(dbSetOrder(1))
					If BSW->(MsSeek(xfilial("BSW") + Upper(cLogin) + Space( tamsx3("BSW_LOGUSR")[1] - Len(cLogin) ) ))
						If !( cSenha == BSW->BSW_SENHA )
							//Senha inválida
							aCritARQ[1] := .T.
							aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"Senha inválida"
							aCritARQ[3] := "3111"
						endIF
					else
						//Login não existe -> login inválido
						aCritARQ[1] := .T.
						aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"login inválido"
						aCritARQ[3] := "3111"
					endIf
			   else
			   		//Não foi enviada a tag
			   		aCritARQ[1] := .T.
			   		aCritARQ[2] := "PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM"//"Não foi enviada a tag"
			   		aCritARQ[3] := "3100"
			   endIf
		   endIf
		endif
		
		//conout( "6" + CHR(13)+CHR(10)+Str(Seconds())+CHR(13)+CHR(10) )
		
		cPathTagBd  := addNS("/solicitacaoDemonstrativoRetornoWS/solicitacaoDemonstrativoRetorno/demonstrativoPagamento")
		cTipoDemo := oXML:XPathGetNodeValue(cPathTagBd + addNS("/tipoDemonstrativo"))
		if( oXml:XPathHasNode( cPathTagBd ) )
			cTipoDemo := iif(cTipoDemo == "1", "1", "2")
			If oXml:XPathHasNode( cPathTagBd + addNs("/periodo/dataPagamento" ))
				cdatPag := oXML:XPathGetNodeValue( cPathTagBd + addNs("/periodo/dataPagamento" ))
				lPorData := .T.
			else
				cCompeten := oXML:XPathGetNodeValue( cPathTagBd + addNs("/periodo/competencia" ))
			endIf
		Else //demonstrativo Analise

			//Seto Patch para demonstrativoAnalise
			cPathTagBd := addNS("/solicitacaoDemonstrativoRetornoWS/solicitacaoDemonstrativoRetorno/demonstrativoAnalise")

			//Validação Prestador Corpo da mensagem
			aRdaCorpo[1]:=	oXML:XPathGetNodeValue( cPathTagBd + addNs("/dadosPrestador/codigoPrestadorNaOperadora" ))
			aRdaCorpo[2]:=	oXML:XPathGetNodeValue( cPathTagBd + addNs("/dadosPrestador/cpfContratado" ))
			aRdaCorpo[3]:=	oXML:XPathGetNodeValue( cPathTagBd + addNs("/dadosPrestador/cnpjContratado" ))
			//cCdRdabody	:= buscaCRede(aRdaCorpo[3],aRdaCorpo[2],aRdaCorpo[1])
			/*if (cCodRda != cCdRdabody)
				aCritARQ[1] := .T.
			   	aCritARQ[2] := "CÓDIGO PRESTADOR INVÁLIDO"
			   	aCritARQ[3] := "1203"
			endif*/
			
			If ( oXml:XPathHasNode( cPathTagBd ) )
			 	nProcs := oXML:XPathChildCount(cPathTagBd + addNS("/protocolos") )
				for nJ := 1 to nProcs
					cNewPath := cPathTagBd + addNS("/protocolos/numeroProtocolo")
					if nProcs > 1
					    cNewPath += "["+ allTrim( str( nJ ) ) +"]"
					endif
					aadd( aProtoc, oXML:XPathGetNodeValue( cNewPath ) )
					cPEGinSql += aProtoc[Len(aProtoc)] + ","
				next
				lDemoACT := .T.
			endIf
		endif
	else
		return "Erro ao carregar a mensagem: " + aRetObj[2] 
	EndIf
else
	cVerArq	:= PGETTISVER()
	If adadDemons[2] == "1"
		cTipoDemo := "1"
		lDemoACT := .F.
		cSeqTran := "0000001"
		cCodRDA := adadDemons[1]		
	
		if adadDemons[3] == '1'
			cdatPag := strtran(adadDemons[4], "/", "")
			cdatPag := substr(cdatPag, 5,4) + substr(cdatPag, 3,2) + substr(cdatPag, 1,2)
			lPorData := .T.
		else
			cCompeten := strtran(adadDemons[4], "/", "")
			cCompeten := SubStr(cCompeten, 3, 4) + substr(cCompeten, 1, 2)
		endIf
	elseif adadDemons[2] == "2"
		cTipoDemo := "2"
		lDemoACT := .F.
		cSeqTran := "00001"
		cCodRDA := adadDemons[1]
		if adadDemons[3] == '1'
			cdatPag := strtran(adadDemons[4], "/", "")
			cdatPag := substr(cdatPag, 5,4) + substr(cdatPag, 3,2) + substr(cdatPag, 1,2)
			lPorData := .T.
		else
			cCompeten := strtran(adadDemons[4], "/", "")
			cCompeten := SubStr(cCompeten, 3, 4) + substr(cCompeten, 1, 2)
		endIf
	elseif adadDemons[2] == "4"
		cTipoDemo := "4"
		lDemoACT := .T.
		cSeqTran := "0000001"
		cCodRDA := adadDemons[1]
		cPEGinSql := adadDemons[5]
		aProtoc := StrTokArr(cPEGinSql, ",")	
		cPEGinSql := ""
		for nK := 1 To Len(aProtoc)
			If ChkProtBlq(aProtoc[nK])
				cPEGinSql += aProtoc[nK] + ","
			endIf
		next
		If empty(cPEGinSql)
			lcontrol := .f.
			return cPEGinSql
		endIf
	endIf

	BAU->(DbSetOrder(1))
	If BAU->(MsSeek(xFilial("BAU") + alltrim(cCodRDA)))
		cNomeRDA := BAU->BAU_NOME
		cForPGt := BAU->BAU_FORPGT
		cfornec := BAU->BAU_CODSA2
		cCPFCNPJR := alltrim(BAU->BAU_CPFCGC)
	endIf

	BA0->(dbSetOrder(1))
	cCodOpe := PLSINTPAD()	   

	If BA0->(MsSeek(xfilial("BA0") + cCodOpe))
		cRegANSOpe := BA0->BA0_SUSEP
		cNomeOpe := BA0->BA0_NOMINT
		cCNPJOpe := BA0->BA0_CGC
	EndIf
	
	BB8->(dbsetOrder(1))
	If BB8->(MsSeek(xfilial("BB8") + cCodRDA + cCodOpe))
		While !(BB8->(EoF())) .AND. BB8->(BB8_CODIGO+BB8_CODINT) == cCodRDA + cCodOpe .AND. (empTy(BB8->BB8_CNES) .OR. BB8->BB8_CNES == '9999999')
			BB8->(DbSkip())
		EndDo
		If BB8->(BB8_CODIGO+BB8_CODINT) == cCodRDA + cCodOpe .AND. !(empTy(BB8->BB8_CNES) .OR. BB8->BB8_CNES == '9999999')
			ccnes := BB8->BB8_CNES
		else
			ccnes := '9999999'
		EndIF
	else
		ccnes := '9999999'
	endIf

EndIf

//conout( "7" + CHR(13)+CHR(10)+Str(Seconds())+CHR(13)+CHR(10) )
If aCritARQ[1]
	cRet += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">'
	cRet +=   '<soapenv:Header/>'
	cRet +=   '<soapenv:Body>'
	cRet +=      '<ans:demonstrativoRetornoWS>'
	cRet +=			'<ans:mensagemErro>'
	cRet +=				'<ans:codigoGlosa>' + aCritARQ[3] + '</ans:codigoGlosa>'
	cRet +=				'<ans:descricaoGlosa>' + EncodeUTF8(aCritARQ[2]) + '</ans:descricaoGlosa>'
	cRet +=			'</ans:mensagemErro>'
	cRet +=      '</ans:demonstrativoRetornoWS>'
	cRet +=   '</soapenv:Body>'
	cRet += '</soapenv:Envelope>'	
elseIf lDemoACT
		
	cSql := " Select BD6_CODPEG, BD6_SEQUEN, BD6_MATANT, BD6_OPEORI, "
	cSql += " BD6_NUMERO, BD6_NOMUSR, BD6_CODOPE, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, "
	cSql += " BD6_DATPRO, BD6_CODPAD, BD6_CODPRO, BD6_VALORI, "
	cSql += " BD6_VLRAPR, BD6_QTDPRO, BD6_VLRMAN, BD6_VLRPAG, BD6_VLRGLO, BD6_VLRGTX, BD6_CODLDP, BX6_SQTISS "
	
	//If cVerArq >= "3.04.00"
	//	cSql += ", (CASE WHEN (COALESCE(BX6_SQTISS,' ') = ' ') THEN BD6_SEQUEN ELSE BX6_SQTISS END) SEQUEN "
	//else
	//	cSql += ", '1' SEQUEN
	//endIf
	
	cSql += " from " + RetsqlName("BCI") + " BCI "
 
	cSql += " Inner Join " + RetsqlName('BD6') + " BD6 "
	csql += " On "
	cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
	cSql += " BD6_CODOPE = BCI_CODOPE AND "
	csql += " BD6_CODLDP = BCI_CODLDP AND "
	cSql += " BD6_CODPEG = BCI_CODPEG AND "
	cSql += " BD6.D_E_L_E_T_ =  ' ' "	
	
	If cVerArq >= "3.04.00"
		cSql += " Left Join " + RetSqlName("BX6") + " BX6 "
		cSql += " On "
		cSql += " BX6_FILIAL = '" + xfilial("BX6") + "' AND "
		cSql += " BX6_CODOPE = BD6.BD6_CODOPE AND "
		cSql += " BX6_CODLDP = BD6.BD6_CODLDP AND "
		cSql += " BX6_CODPEG = BD6.BD6_CODPEG AND "
		cSql += " BX6_NUMERO = BD6.BD6_NUMERO AND "
		cSql += " BX6_ORIMOV = BD6.BD6_ORIMOV AND "
		cSql += " BX6_SEQUEN = BD6.BD6_SEQUEN AND "
		cSql += " BX6.D_E_L_E_T_ = ' ' " 
	endIf
	cSql += " where "
	csql += " BCI_FILIAL = '" + xfilial('BCI') + "' AND "
	cSql += " BCI_CODPEG IN " + FormatIn( SubStr(cPEGinSql, 1, Len(cPEGinSql) - 1), ',') + " AND "
	If !lPLSUNI
		cSql += " BCI_CODRDA = '" + cCodRDA + "' AND "
	endIf
	cSql += " BCI.D_E_L_E_T_ =  ' ' "
	cSql += " ORDER BY BD6.BD6_CODPEG, BD6.BD6_NUMERO"

	if ExistBlock("PLQRYTISS")
		cSql := ExecBlock("PLQRYTISS",.F.,.F.,{"4", cSql, cCodRDA, cdatPag, cCompeten, cPEGinSql })
	endif

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"DemoAnali",.F.,.T.)

	While !(DemoAnali->(EoF()))
		aadd(aDadBD6, { DemoAnali->(BD6_CODPEG), DemoAnali->(BD6_NUMERO), DemoAnali->(BD6_SEQUEN), DemoAnali->(BD6_NOMUSR), DemoAnali->(BD6_CODOPE), DemoAnali->(BD6_CODEMP), ; // 6
							DemoAnali->(BD6_MATRIC), DemoAnali->(BD6_TIPREG), DemoAnali->(BD6_DIGITO), DemoAnali->(BD6_DATPRO), DemoAnali->(BD6_CODPAD), ; // 11
							DemoAnali->(BD6_CODPRO), DemoAnali->(BD6_VALORI), DemoAnali->(BD6_VLRAPR), DemoAnali->(BD6_QTDPRO), DemoAnali->(BD6_VLRMAN), ; // 16
							DemoAnali->(BD6_VLRPAG), DemoAnali->(BD6_VLRGLO)+DemoAnali->(BD6_VLRGTX), DemoAnali->(BD6_CODLDP), cSequenBX6(cVerArq), ; // 20
							DemoAnali->(BD6_OPEORI), DemoAnali->(BD6_MATANT) }) // 22
		DemoAnali->(dbskip())
	EndDo
	
	DemoAnali->(DbCloseArea())

	// ordena pegs para combinar com os valores do aDadBD6 (ordenado pelo order by da query)
	ASORT(aProtoc, , , { | x,y | x < y } )

	
	if !lPortal
		cRet += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">'
		cRet +=   '<soapenv:Header/>'
		cRet +=   '<soapenv:Body>'
		cRet +=      '<ans:demonstrativoRetornoWS>'
		cRet += 	montaRetDA(cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, ccnes, aProtoc, aDadBD6, lPortal, cCPFCNPJR, cVerArq )
		cRet +=      '</ans:demonstrativoRetornoWS>'
		cRet +=   '</soapenv:Body>'
		cRet += '</soapenv:Envelope>'
	else
    	cRet := Encode64(montRetDA2(cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, ccnes, aProtoc, aDadBD6, lPortal, cCPFCNPJR ))
	endif
			
elseIf cTipoDemo == '1'

	adadPag := QDemoPag(lPordata,cdatPag,cCompeten,cCodRDA)
	adadDebCre := QDemoPagCD(lPordata,cdatPag,cCompeten,cCodRDA)

	If cForPGt == "1"
		SA2->(dbSetOrder(1))
		If SA2->(MsSeek(xfilial("SA2") + cfornec))
			aDadBan[1] := SA2->A2_BANCO
			aDadBan[2] := SA2->A2_AGENCIA
			aDadBan[3] := SA2->A2_NUMCON
		endIf
	endIf
	cRet += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">'
	cRet +=   '<soapenv:Header/>'
	cRet +=   '<soapenv:Body>'
	cRet +=      '<ans:demonstrativoRetornoWS>'
	cRet += 			montaRetDP(cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, ccnes, cdatPag, adadPag, adadDebCre, cForPGt, aDadBan, @lControl, lPortal, cCPFCNPJR, cVerArq )
	cRet +=      '</ans:demonstrativoRetornoWS>'
	cRet +=   '</soapenv:Body>'
	cRet += '</soapenv:Envelope>'
	
elseIf cTipoDemo == '2'
	cSeqTran := "0001"

	if BAU->BAU_CALIMP == "1"
		// pesquisa pelos valores faturados da SE2 e BD7
		// utiliza BD6/B05 para exibir dente/região
		// utiliza BB0 para exibir nome do profissional
		cSql += " SELECT BD7_VALORI A, BD7_VLRMAN M, BD7_VLRPAG P, BD7_VLRGLO G, "
		cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, SUM(E2_IRRF) / count(1) IR, SUM(E2_ISS) / count(1) ISS, SUM(E2_INSS) / count(1) INSS, "
		cSql += " SUM(E2_PIS) / count(1) PIS, SUM(E2_COFINS) / count(1) COF, E2_NUM, SUM(E2_CSLL) / count(1) CSLL, "
		cSql += " BD7_CODOPE, BD7_CODLDP, BD7_NUMERO, COALESCE( BD6_DENREG, ' ') AS DENREG, BD6_FADENT, BD6_NOMUSR, COALESCE( BB0_NOME, ' ') AS NOMEXE, "
		cSql += " BD6_OPEUSR||BD6_CODEMP||BD6_MATRIC||BD6_TIPREG||BD6_DIGITO MATRICULA, COALESCE( B05_TIPO, ' ') AS TIPO, "
		CsQL += " BD6_DATPRO, BD6_QTDPRO, BD6_F_VFRA, BD6_CODPAD, BD6_CODPRO, ' ' BD6_DESPRO, E2_EMISSAO, BD6_SEQUEN "
		cSql += " from " + retSqlName("SE2") + " E2 "

		cSql += " INNER JOIN " + retSqlName("SD1") + " SD1 "
		cSql += " ON D1_FILIAL = '" + xFilial("SD1") + "' "
		cSql += " AND D1_DOC   = E2_NUM "
		cSql += " AND D1_FORNECE = E2_FORNECE "
		cSql += " AND D1_LOJA    = E2_LOJA "
		cSql += " AND SD1.D_E_L_E_T_ = ' ' "

		cSql += " INNER JOIN " + retSqlName("SC7") + " SC7 "
		cSql += " ON C7_FILIAL  = '" + xFilial("SC7") + "' "
		cSql += " AND C7_NUM    = D1_PEDIDO "
		cSql += " AND C7_ITEM   = D1_ITEMPC "
		cSql += " AND SC7.D_E_L_E_T_ = ' ' "

		cSql += " INNER JOIN " + retSqlName("BD7") + " BD7  "
		cSql += " ON BD7_FILIAL  = '" + xFilial("BD7") + "' "
		cSql += " AND BD7_CODOPE = C7_PLOPELT "
		cSql += " AND BD7_OPELOT = C7_PLOPELT "
		cSql += " AND BD7_NUMLOT = C7_LOTPLS "
		cSql += " AND BD7_CODRDA = C7_CODRDA "
		cSql += " AND BD7.D_E_L_E_T_ = ' ' "

		cSql += " INNER JOIN " + retSqlName("BR8") + " BR8 "
		cSql += " ON BR8_FILIAL  = '" + xFilial("BR8") + "' "
		cSql += " AND BR8_CODPAD = BD7_CODPAD "
		cSql += " AND BR8_CODPSA = BD7_CODPRO "
		cSql += " AND BR8_ODONTO = '1' "
		cSql += " AND BR8.D_E_L_E_T_ = ' ' "

		cSql += " INNER JOIN " + RetsqlName('BD6') + " BD6 "
		cSql += " On "
		cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
		cSql += " BD6_CODOPE = BD7_CODOPE AND "
		cSql += " BD6_CODLDP = BD7_CODLDP AND "
		cSql += " BD6_CODPEG = BD7_CODPEG AND "
		cSql += " BD6_NUMERO = BD7_NUMERO AND "
		cSql += " BD6_ORIMOV = BD7_ORIMOV AND "
		cSql += " BD6_SEQUEN = BD7_SEQUEN AND "
		cSql += " BD6.D_E_L_E_T_ =  ' ' "

		cSql += " LEFT JOIN " + RetsqlName('B05') + " B05 "
		cSql += " ON B05_FILIAL = '" + xFilial("B05") + "' AND "
		cSql += " B05_CODPAD = BD6_CODPAD AND "
		cSql += " B05_CODPSA = BD6_CODPRO AND "
		cSql += " B05_CODIGO = BD6_DENREG AND " 
		cSql += " B05.D_E_L_E_T_ =  ' ' "

		cSql += " LEFT JOIN " + RetsqlName('BB0') + " BB0 "
		cSql += " ON BB0_FILIAL = '" + xFilial("BB0") + "' AND "
		cSql += " BB0_ESTADO = BD6_ESTEXE AND "
		cSql += " BB0_NUMCR  = BD6_REGEXE AND "
		cSql += " BB0_CODSIG = BD6_SIGEXE AND "
		cSql += " BB0_CODOPE = BD6_CODOPE AND "
		cSql += " BB0.D_E_L_E_T_ =  ' ' "

		cSql += " WHERE "
		cSql += " E2_FILIAL = '" + xfilial("SE2") + "' "
		If lPordata
			cSql += " AND E2_VENCREA = '" + allTrim(StrTran(cdatPag, "-", "")) + "' "
		else
			cSql += " AND E2_VENCREA >= '" + allTrim(cCompeten) + "01" + "' "
			cSql += " AND E2_VENCREA <= '" + allTrim(cCompeten) + "31" + "' "
		endIf
		cSql += " AND E2_CODRDA = '" + cCodRDA + "' "
		cSql += " AND E2.D_E_L_E_T_ =  ' ' "
		cSql += " GROUP BY "
		cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, E2_NUM, BD7_VALORI, BD7_VLRMAN, BD7_VLRPAG, BD7_VLRGLO, E2_VENCREA, BD7_CODOPE, BD7_CODLDP, "
		cSql += " BD7_NUMERO, BD6_DENREG, BD6_FADENT, BD6_NOMUSR, BB0_NOME, BD6_OPEUSR ||BD6_CODEMP ||BD6_MATRIC ||BD6_TIPREG ||BD6_DIGITO, B05_TIPO, BD6_DATPRO, BD6_QTDPRO, BD6_F_VFRA, "
		cSql += " BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, E2_EMISSAO, BD6_SEQUEN "
		cSql += " ORDER BY "
		cSql += " E2_VENCREA, E2_NUM "

	else
		// pesquisa pelo título(SE2) vinculado a BD7 faturada através do BD7_CHKSE2
		cSql += " SELECT BD7_VALORI A, BD7_VLRMAN M, BD7_VLRPAG P, BD7_VLRGLO G, "
		cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, SUM(E2_IRRF) / count(1) IR, SUM(E2_ISS) / count(1) ISS, SUM(E2_INSS) / count(1) INSS, "
		cSql += " SUM(E2_PIS) / count(1) PIS, SUM(E2_COFINS) / count(1) COF, E2_NUM, SUM(E2_CSLL) / count(1) CSLL, "
		cSql += " BD7_CODOPE, BD7_CODLDP, BD7_NUMERO, COALESCE( BD6_DENREG, ' ') AS DENREG, BD6_FADENT, BD6_NOMUSR, COALESCE( BB0_NOME, ' ') AS NOMEXE, "
		cSql += " BD6_OPEUSR||BD6_CODEMP||BD6_MATRIC||BD6_TIPREG||BD6_DIGITO MATRICULA, COALESCE( B05_TIPO, ' ') AS TIPO, "
		CsQL += " BD6_DATPRO, BD6_QTDPRO, BD6_F_VFRA, BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, E2_EMISSAO, BD6_SEQUEN "
		cSql += " from " + retSqlName("SE2") + " E2 "

		cSql += " INNER JOIN " + RetSqlName("BD7") + " BD7 "
		cSql += " On "
		cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
		cSql += " BD7_CHKSE2 = E2_FILIAL || '|' || E2_PREFIXO || '|' || E2_NUM || '|' || E2_PARCELA || '|' || E2_TIPO || '|' || E2_FORNECE || '|' || E2_LOJA AND "
		cSql += " BD7_CODRDA = '" + cCodRDA + "' AND "
		csql += " BD7.D_E_L_E_T_ =  ' ' "
		// br8 utilizada para filtrar apenas procedimentos odonto
		cSql += " INNER JOIN " + RetsqlName('BR8') + " BR8 "
		csql += " On "
		cSql += " BR8_FILIAL = '" + xFilial("BR8") + "' AND "
		cSql += " BR8_CODPAD = BD7_CODPAD AND "
		csql += " BR8_CODPSA = BD7_CODPRO AND "
		csql += " BR8_ODONTO = '1' AND "
		cSql += " BR8.D_E_L_E_T_ =  ' ' "   

		cSql += " INNER JOIN " + RetsqlName('BD6') + " BD6 "
		csql += " On "
		cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
		cSql += " BD6_CODOPE = BD7_CODOPE AND "
		csql += " BD6_CODLDP = BD7_CODLDP AND "
		csql += " BD6_CODPEG = BD7_CODPEG AND "
		csql += " BD6_NUMERO = BD7_NUMERO AND "
		csql += " BD6_ORIMOV = BD7_ORIMOV AND "
		csql += " BD6_SEQUEN = BD7_SEQUEN AND "
		cSql += " BD6.D_E_L_E_T_ =  ' ' "
		
		cSql += " LEFT JOIN " + RetsqlName('B05') + " B05 "
		csql += " On "
		cSql += " B05_FILIAL = '" + xFilial("B05") + "' AND "
		cSql += " B05_CODPAD = BD6_CODPAD AND "
		cSql += " B05_CODPSA = BD6_CODPRO AND "
		cSql += " B05_CODIGO = BD6_DENREG AND "	
		cSql += " B05.D_E_L_E_T_ =  ' ' "

		cSql += " LEFT JOIN " + RetsqlName('BB0') + " BB0 "
		csql += " On "
		cSql += " BB0_FILIAL = '" + xFilial("BB0") + "' AND "
		cSql += " BB0_ESTADO = BD6_ESTEXE AND "
		csql += " BB0_NUMCR  = BD6_REGEXE AND "
		csql += " BB0_CODSIG = BD6_SIGEXE AND "
		cSql += " BB0_CODOPE = BD6_CODOPE AND "
		cSql += " BB0.D_E_L_E_T_ =  ' ' "

		cSql += " WHERE "
		cSql += " E2_FILIAL = '" + xfilial("SE2") + "' "
		If lPordata
			cSql += " AND E2_VENCREA = '" + allTrim(StrTran(cdatPag, "-", "")) + "' "
		else
			cSql += " AND E2_VENCREA >= '" + allTrim(cCompeten) + "01" + "' "
			cSql += " AND E2_VENCREA <= '" + allTrim(cCompeten) + "31" + "' "
		endIf
		cSql += " AND E2_CODRDA = '" + cCodRDA + "' "
		cSql += " AND E2.D_E_L_E_T_ =  ' ' "
		cSql += " GROUP BY "
		cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, E2_NUM, BD7_VALORI, BD7_VLRMAN, BD7_VLRPAG, BD7_VLRGLO, E2_VENCREA, BD7_CODOPE, BD7_CODLDP, "
		cSql += " BD7_NUMERO, BD6_DENREG, BD6_FADENT, BD6_NOMUSR, BB0_NOME, BD6_OPEUSR ||BD6_CODEMP ||BD6_MATRIC ||BD6_TIPREG ||BD6_DIGITO, B05_TIPO, BD6_DATPRO, BD6_QTDPRO, BD6_F_VFRA, "
		cSql += " BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, E2_EMISSAO, BD6_SEQUEN "
		cSql += " ORDER BY "
		cSql += " E2_VENCREA, E2_NUM "
	endif

	if ExistBlock("PLQRYTISS")
		cSql := ExecBlock("PLQRYTISS",.F.,.F.,{"1", cSql, cCodRDA, cdatPag, cCompeten, cPEGinSql })
	endif
			 
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"DemoPag",.F.,.T.)
	
	While !(DemoPag->(EoF()))
		aadd(adadPag, { round(DemoPag->(A),2), round(DemoPag->(M),2), Round(DemoPag->(P),2), Round(DemoPag->(G),2), DemoPag->(BD7_DTDIGI), DemoPag->(BD7_CODPEG), DemoPag->(E2_VENCREA), round(DemoPag->(IR),2),; //8
						 round(DemoPag->(ISS),2), round(DemoPag->(INSS),2), Round(DemoPag->(PIS),2), round(DemoPag->(COF),2), round(DemoPag->(CSLL), 2), DemoPag->E2_NUM,; // 14
                         DemoPag->BD7_CODOPE, DemoPag->BD7_CODLDP, DemoPag->BD7_NUMERO, DemoPag->DENREG, DemoPag->BD6_FADENT, DemoPag->NOMEXE,; //20
                         DemoPag->MATRICULA, DemoPag->BD6_NOMUSR, DemoPag->TIPO, DemoPag->BD6_DATPRO, DemoPag->BD6_QTDPRO, DemoPag->BD6_F_VFRA,; //26
                         DemoPag->BD6_CODPAD, DemoPag->BD6_CODPRO, DemoPag->BD6_DESPRO, DemoPag->E2_EMISSAO, DemoPag->BD6_SEQUEN }) //31
		DemoPag->(dbskip())
	EndDo
	
	DemoPag->(DbCloseArea())
	
	cSql := " select DISTINCT BGQ_CODSEQ, BGQ_VALOR P, BGQ_TIPO T, BGQ_CODLAN C, E2_VENCREA V "
	cSql += " from " + RetsqlName("BGQ") + " BGQ "
	cSql += " Inner join " + retSqlName("SE2") + " E2 "
	cSql += " On "
	cSql += " E2_FILIAL = '" + xfilial("SE2") + "' "
	cSql += " AND E2_PLOPELT = BGQ_CODOPE "
	cSql += " AND E2_PLLOTE = BGQ_NUMLOT " 
	If lPordata
		cSql += " AND E2_VENCREA = '" + allTrim(StrTran(cdatPag, "-", "")) + "' "
	else
		cSql += " AND E2_VENCREA >= '" + allTrim(cCompeten) + "01" + "' "
		cSql += " AND E2_VENCREA <= '" + allTrim(cCompeten) + "31" + "' "
	endIf
	cSql += " AND E2.D_E_L_E_T_ = ' ' "
	cSql += " Where "
	cSql += " BGQ_FILIAL = '" + xfilial("BGQ") + "' "
	cSql += " AND BGQ_CODIGO =  '" + cCodRDA + "' "
	cSql += " AND BGQ_NUMLOT <> ' ' "
	cSql += " AND BGQ.D_E_L_E_T_ = ' ' "
	cSql += " Order By "
	cSql += " E2_VENCREA "
	
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"DemoPagCD",.F.,.T.)
	
	While !(DemoPagCD->(EoF()))
		aadd(adadDebCre, { DemoPagCD->(P), DemoPagCD->(T), DemoPagCD->(C), DemoPagCD->(V) })
		DemoPagCD->(dbskip())
	EndDo
	
	DemoPagCD->(DbCloseArea())
	
	cSql := " SELECT DISTINCT BGQ_CODSEQ, BGQ_VALOR P, BGQ_TIPO T, BGQ_CODLAN C, E2_VENCREA V, SUM(e2_irrf) / COUNT(1) IR, SUM(e2_iss) / COUNT(1) ISS, " 
	cSql += " SUM(e2_inss) / COUNT(1) INSS, SUM(e2_pis) / COUNT(1) PIS, SUM(e2_cofins) / COUNT(1) COF, SUM(e2_csll) / COUNT(1) CSLL "
	cSql += " from " + RetsqlName("SE2") + " E2 "
	cSql += " INNER JOIN " + retSqlName("BGQ") + " BGQ "
	cSql += " On "
	cSql += " E2_FILIAL = '" + xfilial("SE2") + "' "
	cSql += " AND E2_PLOPELT = BGQ_CODOPE "
	cSql += " AND E2_PLLOTE  = BGQ_NUMLOT " 	
	cSql += " AND BGQ_CODIGO =  '" + cCodRDA + "' "
	cSql += " AND BGQ_NUMLOT <> ' ' "
	cSql += " AND BGQ.D_E_L_E_T_ = ' ' "
	cSql += " Where "
	cSql += " BGQ_FILIAL = '" + xfilial("BGQ") + "' "
	If lPordata
		cSql += " AND E2_VENCREA = '" + allTrim(StrTran(cdatPag, "-", "")) + "' "
	else
		cSql += " AND E2_VENCREA >= '" + allTrim(cCompeten) + "01" + "' "
		cSql += " AND E2_VENCREA <= '" + allTrim(cCompeten) + "31" + "' "
	endIf
	cSql += " AND E2.D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY BGQ_CODSEQ, BGQ_VALOR, BGQ_TIPO, BGQ_CODLAN, E2_VENCREA "
	cSql += " ORDER BY "
	cSql += " E2_VENCREA "
	
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"DemoPagCD",.F.,.T.)
	
	While !(DemoPagCD->(EoF()))
		aadd(aDadDC, { DemoPagCD->(T), DemoPagCD->(C), round(DemoPagCD->(IR),2), round(DemoPagCD->(ISS),2),;
		round(DemoPagCD->(INSS),2), Round(DemoPagCD->(PIS),2), round(DemoPagCD->(COF),2), round(DemoPagCD->(CSLL), 2) })
		DemoPagCD->(dbskip())
	EndDo
	
	DemoPagCD->(DbCloseArea())
	
	If cForPGt == "1"
		SA2->(dbSetOrder(1))
		If SA2->(MsSeek(xfilial("SA2") + cfornec))
			aDadBan[1] := SA2->A2_BANCO
			aDadBan[2] := SA2->A2_AGENCIA
			aDadBan[3] := SA2->A2_NUMCON
		endIf
	endIf

	cRet += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">'
	cRet +=   '<soapenv:Header/>'
	cRet +=   '<soapenv:Body>'
	cRet +=      '<ans:demonstrativoRetornoWS>'
	cRet += 			montaRetDO(cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, ccnes, cdatPag, adadPag, adadDebCre, cForPGt, aDadBan, @lControl, lPortal, cCPFCNPJR, aDadDC, cVerArq )
	cRet +=      '</ans:demonstrativoRetornoWS>'
	cRet +=   '</soapenv:Body>'
	cRet += '</soapenv:Envelope>'

elseIf cTipoDemo == '3'
	ProcOnLine("solicitacaodemonstrativoretorno", "")
EndIf


Return cRet


/*/{Protheus.doc} VldWSdemoP
Função pra validação e preparação da mensagem recebida para processamento
@author Oscar
@since 08/02/2019
@version 1.0
/*/
static function VldWSdemoP(cSoap,cSchema)
local cSoapAux   := ""   
local cMsg       := ""
local cErro      := ""
local cAviso     := ""
local cNameSpace := ""
local nPos       := 0
local nX         := 0
local lRet       := .T. 
Local nPos2		:= 0
Local cXmlns		:= ""
Local nPos1		:= 0

nPos := At("BODY",Upper(cSoap))
cSoapAux := Substr(cSoap,nPos+4,len(cSoap))    
nPos := At(">",Upper(cSoapAux))
cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))  

nPos := At("BODY",Upper(cSoapAux)) 
for nX := 1 to nPos 
	if Substr(cSoapAux,nPos-nX,1) == "<"
		cSoapAux := Substr(cSoapAux,1,nPos-(nX+1))
		Exit
	endif   
next

nPos1 := At("XMLNS",Upper(cSoap))
If nPos1 > 0
	nPos2 := At(">",Upper(cSoap),nPos1) 
	cXmlns := subString(cSoap, nPos1, nPos2 - nPos1)
	nPos1 := At(">",Upper(cSoapAux))
	cSoapPt1 := Substr(cSoapAux,1,nPos1-1)
	cSoapPt2 := Substr(cSoapAux,nPos1,len(cSoapAux))
	cSoapAux := cSoapPt1 + " " + cXmlns + cSoapPt2
endIf

if nPos == 0 .Or. empty(cSoap)
	cErro := "Erro com o pacote Soap recebido" 
endif

// Se houve erro fatal finaliza 
if !empty(cErro)
	return {.F.,cErro}
endif

nPos := At("SOLICITACAODEMONSTRATIVORETORNOWS",Upper(cSoapAux))
If Substr(cSoapAux,nPos-1,1) == ":"
	nPosNamSpc := nPos-2
	For nX := 1 to nPosNamSpc
		If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"     
			cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
			cNS := cNameSpace
			Exit
		EndIf   
	next
EndIf

nPos := At("CANCELAGUIAWS",Upper(cSoapAux))
If Substr(cSoapAux,nPos-1,1) == ":"
	nPosNamSpc := nPos-2
	For nX := 1 to nPosNamSpc
		If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"     
			cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
			cNS := cNameSpace
			Exit
		EndIf   
	next
EndIf

nPos := At("SOLICITACAOSTATUSPROTOCOLOWS",Upper(cSoapAux))
If Substr(cSoapAux,nPos-1,1) == ":"
	nPosNamSpc := nPos-2
	For nX := 1 to nPosNamSpc
		If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"     
			cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
			cNS := cNameSpace
			Exit
		EndIf   
	next
EndIf
// Monta texto para montagem do arquivo para validacao
cSoapXml := EncodeUTF8(cSoapAux)

// Faz a validacao do XML com o XSD
if !XmlSVldSch( cSoapXml, "\tiss\schemas\" + cSchema, @cErro,@cAviso)
	cMsg := Iif( !empty(cErro),"Erro: " +cErro,"") 
	cMsg += Iif( !empty(cAviso),"Aviso: "+cAviso,"") 
 	lRet := .F.
endif

return {lRet,cMsg,cSoapXml,cNameSpace}


/*/{Protheus.doc} addNS
adiciona namespace nos caminhos das tags
@author Oscar
@since 08/02/2019
@version 1.0
/*/
static function addNS(cTag)

if !empty(cNS)
    cTag := strtran(cTag, "/", "/" + cNS + ":")
endif

return cTag


/*/{Protheus.doc} montaRetDP
Monta o miolo do retorno do demonstrativo de pagamento
@author Oscar
@since 08/02/2019
@version 1.0
/*/
Static function montaRetDP( cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, cCnes, cdatPag, adadPag, adadDebCre, cForPGt, aDadBan, lControl, lPortal, cCpfCnpjR, cVerArq )
Local cXML 			:= ""
Local cDataAtu 		:= DtoS(DatE())
Local nI 			:= 1
local aSomadat 		:= {0, 0, 0, 0}
Local nZ 			:= 0
Local lOkPorData 	:= .F.
Local aSomatot 		:= {0, 0, 0, 0, 0, 0}
Local aDebCreDat 	:= {0, 0}
Local nIni			:= 1
Local lZera 		:= .F.
Local aDebCreTot 	:= {0, 0}
Local nY 			:= 0
Local aDebCrZ		:= {}
Local ctempterm 	:= ""
Local aE2Num 		:= {}
Local cNumProt 		:= ""
local aRetFun		:= {}		 
Local cXMLEx1		:= ""
Local cTabCabEx		:= ""
Local adadEx1		:= {}
local cDataPgEx		:= ""

//Pesquisa Hash
local oHashDP27	:= HMNew()
local oHashDesc :=HMNew()

Private nArqHash := 0

Default cCnes := '9999999'
default lControl := .T.
default cCpfCnpjR := ""

BCI->(DbsetOrder(14))

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" )

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML //"Não foi possível criar o diretorio no servidor:"
		Return(cRet)
	EndIf
EndIf

nArqHash := fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )

cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao" ,''						 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:tipoTransacao"			,'DEMONSTRATIVO_PAGAMENTO' ,.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:sequencialTransacao"	,cSeqTran				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:horaRegistroTransacao"	,time()				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	,''				 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:registroANS"	,cRegANSOpe				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	,''				 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''				 ,.T.,.F.,.T., .F. )
if lPortal
	cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA  ,.T.,.T.,.T., .F. )
elseIf Len(cCpfCnpjR) == 11 //CPF
	cXML += A270Tag( 4,"ans:CPF"				, cCpfCnpjR ,.T.,.T.,.T., .F. )
Elseif Len(cCpfCnpjR) == 14 //CNPJ
	cXML += A270Tag( 4,"ans:CNPJ"				, cCpfCnpjR ,.T.,.T.,.T., .F. )
else
	cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA  ,.T.,.T.,.T., .F. )
EndIf
cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:Padrao"	,cVerArq				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 1,"ans:cabecalho"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:demonstrativoRetorno"	,''				 ,.T.,.F.,.T., .F. )

nZ := Len(adadPag)
if nZ > 0

	cXML += A270Tag( 4,"ans:demonstrativoPagamento"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 5,"ans:cabecalhoDemonstrativo"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 6,"ans:registroANS"	,cRegANSOpe				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 6,"ans:numeroDemonstrativo"	,cDataAtu + cSeqTran			 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 6,"ans:nomeOperadora"	,cNomeOpe				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 6,"ans:numeroCNPJ"	,cCNPJOpe				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 6,"ans:dataEmissao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2)				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 5,"ans:cabecalhoDemonstrativo"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 4,"ans:dadosContratado"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 3,"ans:dadosPrestador"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 3,"ans:codigoPrestadorNaOperadora"	,cCodRDA				 ,.T.,.T.,.T., .F. )
	if cVerArq < "4.00.00"
		cXML += A270Tag( 3,"ans:nomeContratado"	,cNomeRDA				 ,.T.,.T.,.T., .F. )
	endif
	cXML += A270Tag( 3,"ans:dadosPrestador"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:CNES"	,cCnes				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:dadosContratado"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 4,"ans:pagamentos"	,''				 ,.T.,.F.,.T., .F. )


	while !lOkPorData 
		cXML += A270Tag( 5,"ans:pagamentosPorData"	,''				 ,.T.,.F.,.T., .F. )
		cXML += A270Tag( 6,"ans:dadosPagamento"	,''				 ,.T.,.F.,.T., .F. )
		
		cDataPgEx := iif( !empty(adadPag[nIni][15]), adadPag[nIni][15], adadPag[nIni][7])
		cXML += A270Tag( 7,"ans:dataPagamento"	,substr(cDataPgEx, 1, 4) + "-" + substr(cDataPgEx, 5, 2) + "-" + substr(cDataPgEx, 7, 2),.T.,.T.,.T., .F. )
	
		cXML += A270Tag( 7,"ans:formaPagamento"	,cForPGt	 ,.T.,.T.,.T., .F. )
		If alltrim(cForPGt) == "1"
			cXML += A270Tag( 7,"ans:banco"			,aDadBan[1]				 ,.T.,.T.,.F., .F. )
			cXML += A270Tag( 7,"ans:agencia"		,aDadBan[2]				 ,.T.,.T.,.F., .F. )
			cXML += A270Tag( 7,"ans:nrContaCheque"	,aDadBan[3]				 ,.T.,.T.,.F., .F. )
		endIf
		cXML += A270Tag( 6,"ans:dadosPagamento"	,''				 ,.F.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:dadosResumo"	,''				 ,.T.,.F.,.T., .F. )
		for nI := nIni To nZ
			
			cXML += A270Tag( 4,"ans:relacaoProtocolos"	,''				 ,.T.,.F.,.T., .F. )
			cXML += A270Tag( 3,"ans:dataProtocolo"	,substr(adadPag[nI][5], 1, 4) + "-" + substr(adadPag[nI][5], 5, 2) + "-" + substr(adadPag[nI][5], 7, 2)	,.T.,.T.,.T., .F. )
			cXML += A270Tag( 3,"ans:numeroProtocolo"	,adadPag[nI][6]				 ,.T.,.T.,.T., .F. )
			
			cNumProt := retNumLote(adadPag[nI][6]) //Retorna
			
			cXML += A270Tag( 3,"ans:numeroLote"	,cNumProt				 ,.T.,.T.,.T., .F. )
			cNumProt := ""
			cXML += A270Tag( 3,"ans:valorInformado"	,Str(adadPag[nI][1])				 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 3,"ans:valorProcessado"	,Str(adadPag[nI][2])				 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 3,"ans:valorLiberado"	,str(adadPag[nI][3])				 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 3,"ans:valorGlosa"	,Str(adadPag[nI][4])				 ,.T.,.T.,.T., .F. )

			cXMLEx1 := ""
			if cVerArq >= "4.00.00"
				//Já posiciona no BCI na função que retorna o protocolo, esse if só vai dar .F. em caso de problema
				//de integridade na base, já que não tem como pagar um PEG sem guias/que não existe
				if BCI->BCI_CODPEG == adadPag[nI][6]

					cTabCabEx := ""
					cTabCabEx := PLDemoCab()

					While PLDemoWhi(cTabCabEx)
						if PLDemoSit(cTabCabEx)
							adadEx1 := PLDemoDad(cTabCabEx)
							cXMLEx1 += A270Tag( 3,"ans:guiasDoLote"	,''			,.T.,.F.,.T., .F. )
							cXMLEx1 += A270Tag( 4,"ans:numeroGuiaPrestador"	,adadEx1[1]			,.T.,.T.,.T., .F. )
							cXMLEx1 += A270Tag( 4,"ans:numeroGuiaOperadora"	,adadEx1[2]			,.T.,.T.,.T., .F. )
							if !empty(adadEx1[3])
								cXMLEx1 += A270Tag( 4,"ans:senha"			,adadEx1[3]			,.T.,.T.,.T., .F. )
							endif
							cXMLEx1 += A270Tag( 4,"ans:tipoPagamento"		,adadEx1[4]			,.T.,.T.,.T., .F. )
							cXMLEx1 += A270Tag( 4,"ans:valorProcessadoGuia"	,Str(adadEx1[5])	,.T.,.T.,.T., .F. )
							cXMLEx1 += A270Tag( 4,"ans:valorLiberadoGuia"	,Str(adadEx1[6])	,.T.,.T.,.T., .F. )
							if !empTy(adadEx1[7])
								cXMLEx1 += A270Tag( 4,"ans:valorGlosaGuia"	,Str(adadEx1[7])	,.T.,.T.,.T., .F. )
							endIF
							cXMLEx1 += A270Tag( 3,"ans:guiasDoLote"	,''			,.F.,.T.,.T., .F. )
						endif
						PLDemoSki(cTabCabEx)
					endDo
				endIF
			endif

			cXML += cXMLEx1

			cXML += A270Tag( 3,"ans:relacaoProtocolos"	,''				 ,.F.,.T.,.T., .F. )
	
			aSomadat[1] += adadPag[nI][1]
			aSomadat[2] += adadPag[nI][2]
			aSomadat[3] += adadPag[nI][3]
			aSomadat[4] += adadPag[nI][4]
			
			If nI == Len(adadPag) .OR. adadPag[nI][7] <> adadPag[nI+1][7]
			
				cXML += A270Tag( 4,"ans:dadosResumo"	,''				 ,.F.,.T.,.T., .F. )
				cXML += A270Tag( 5,"ans:totaisBrutosPorData"	,''				 ,.T.,.F.,.T., .F. )
				cXML += A270Tag( 6,"ans:totalInformadoPorData"	, Str(aSomadat[1])			 ,.T.,.T.,.T., .F. )	
				cXML += A270Tag( 6,"ans:totalProcessadoPorData"	, Str(aSomadat[2])		 ,.T.,.T.,.T., .F. )
				cXML += A270Tag( 6,"ans:totaLiberadoPorData"	,Str(aSomadat[3])				 ,.T.,.T.,.T., .F. )	
				cXML += A270Tag( 6,"ans:totalGlosaPorData"	,Str(aSomadat[4])				 ,.T.,.T.,.T., .F. )
				cXML += A270Tag( 5,"ans:totaisBrutosPorData"	,''				 ,.F.,.T.,.T., .F. )
				
				aSomatot[1] += aSomadat[1]
				aSomatot[2] += aSomadat[2]
				aSomatot[3] += aSomadat[3]
				aSomatot[4] += aSomadat[4]
				
				lZera := .T.
				nZ := nI + 1
				Exit
			EndIf
		next
	
		If !lZera
			nZ := nZ + 1
		endIf
		
		aDebCrZ := {} // zeramos a cada passagem, porque trata-se de diferentes datas
		For nI := nIni To nZ - 1
			If ascan(aE2Num, adadPag[nI][14]) == 0
				aadd(aE2Num, adadPag[nI][14])
				For nY := 8 To Len(adadPag[nI]) - 2 //penúltima posição é o título e a útlima é data de baixa
					If adadPag[nI][nY] > 0
						aadd(aDebCrZ, {'1', ;
							IIF(nY == 8, "01", IIF( nY == 9, "02", IIF( nY == 10, "03", IIF( nY == 11, "04", IIF( nY == 12, "05", "06"))))), ;
							IIF(nY == 8, "IRRF", IIF( nY == 9, "ISS", IIF( nY == 10, "INSS", IIF( nY == 11, "PIS", IIF( nY == 12, "COF", "CSLL"))))), ;
							adadPag[nI][nY]})
					endIf
				Next
			EndIf
		Next
		
		//Se tem débito/crédito, só abre as tags pra fazer o resto no for, se não tem só cria a estrutura
		If Len(aDebCrZ) > 0
			cXML += A270Tag( 4,"ans:debitosCreditosPorData"	,''				 ,.T.,.F.,.T., .F. )
		else
			cXML += A270Tag( 4,"ans:totaisLiquidosPorData"	,''				 ,.T.,.F.,.T., .F. )
			cXML += A270Tag( 5,"ans:totalDebitosPorData"	,'0'				 ,.T.,.T.,.T., .F. )	
			cXML += A270Tag( 5,"ans:totalCreditosPorData"	,'0'				 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 5,"ans:liquidoPorData"	, Str( aSomadat[3] + 0 - 0 ) ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 4,"ans:totaisLiquidosPorData"	,''				 ,.F.,.T.,.T., .F. )
		EndIf
		
		For nI := 1 To Len(aDebCrZ)
			
			cXML += A270Tag( 3,"ans:debitosCreditos"	,''				 ,.T.,.F.,.T., .F. )	
			cXML += A270Tag( 3,"ans:indicador"	,aDebCrZ[nI][1]				 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 3,"ans:tipoDebitoCredito"	,aDebCrZ[nI][2]				 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 3,"ans:descricaoDbCr"	,descTissSp('27', aDebCrZ[nI][2],,@oHashDesc)		 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 3,"ans:valorDbCr"	,Str(aDebCrZ[nI][4])				 ,.T.,.T.,.T., .F. )	
			cXML += A270Tag( 3,"ans:debitosCreditos"	,''				 ,.F.,.T.,.T., .F. )
			
			aDebCreDat[1] += aDebCrZ[nI][4] //valor do débito
			
			If nI == Len(aDebCrZ)
				cXML += A270Tag( 3,"ans:debitosCreditosPorData"	,''				 ,.F.,.T.,.T., .F. )	
				cXML += A270Tag( 4,"ans:totaisLiquidosPorData"	,''				 ,.T.,.F.,.T., .F. )
				cXML += A270Tag( 5,"ans:totalDebitosPorData"	,Str(aDebCreDat[1])				 ,.T.,.T.,.T., .F. )	
				cXML += A270Tag( 5,"ans:totalCreditosPorData"	,Str(aDebCreDat[2])				 ,.T.,.T.,.T., .F. )
				cXML += A270Tag( 5,"ans:liquidoPorData"	, Str( aSomadat[3] + aDebCreDat[2] - aDebCreDat[1] ) ,.T.,.T.,.T., .F. )
				cXML += A270Tag( 4,"ans:totaisLiquidosPorData"	,''				 ,.F.,.T.,.T., .F. )
				
				aDebCreTot[1] += aDebCreDat[1]
				aDebCreTot[2] += aDebCreDat[2]
			endIf
		Next
		
		If lzera
			lZera := .F.
			aSomadat := { 0, 0, 0, 0 }
			aDebCreDat := { 0, 0 }
		endIf
		If nZ > Len(adadPag)
			lOkPorData := .T.
		else
			nIni := nZ
			nZ := Len(adadPag)
		endIf
		cXML += A270Tag( 3,"ans:pagamentosPorData"	,''				 ,.F.,.T.,.T., .F. )
	EndDo

	cXML += A270Tag( 3,"ans:pagamentos"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:totaisDemonstrativo"	,''				 ,.T.,.F.,.T., .F. )	
	cXML += A270Tag( 3,"ans:totaisBrutosDemonstrativo"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 3,"ans:valorInformadoBruto"	, Str(aSomatot[1])			 ,.T.,.T.,.T., .F. )	
	cXML += A270Tag( 3,"ans:valorProcessadoBruto"	, str(aSomatot[2])				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:valorLiberadoBruto"	, Str(aSomatot[3])				 ,.T.,.T.,.T., .F. )	
	cXML += A270Tag( 3,"ans:valorGlosaBruto"	, Str(aSomatot[4])			 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:totaisBrutosDemonstrativo"	,''				 ,.F.,.T.,.T., .F. )
	//{ DemoPag->(P), DemoPag->(T), DemoPag->(C), DemoPag->(E2_VENCREA) }
	For nI := 1 To Len(adadDebCre)
		cXML += A270Tag( 3,"ans:debitosCreditosDemonstrativo"	,''				 ,.T.,.F.,.T., .F. )
		cXML += A270Tag( 3,"ans:indicador"	,adadDebCre[nI][2]				 ,.T.,.T.,.T., .F. )
		ctempterm := deParaSimpl('27', adadDebCre[nI][3],,@oHashDP27)
		cXML += A270Tag( 3,"ans:tipoDebitoCredito"	, ctempterm ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 3,"ans:descricaoDbCr"	,descTissSp('27', ctempterm,,@oHashDesc)	 ,.T.,.T.,.T., .F. )	
		cXML += A270Tag( 3,"ans:valorDbCr"	, Str(adadDebCre[nI][1])				 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 3,"ans:debitosCreditosDemonstrativo"	,''				 ,.F.,.T.,.T., .F. )
		
		If adadDebCre[nI][2] == "2"
			aDebCreTot[2] += adadDebCre[nI][1]
		else
			aDebCreTot[1] += adadDebCre[nI][1]
		EndIf
	Next
	cXML += A270Tag( 3,"ans:totaisLiquidosDemonstrativo"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 3,"ans:totalDebitosDemonstrativo"	,Str(aDebCreTot[1])				 ,.T.,.T.,.T., .F. )	
	cXML += A270Tag( 3,"ans:totalCreditosdemonstrativo"	,str(aDebCreTot[2])				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:valorLiberadoDemonstrativo"	,Str( aDebCreTot[2] - aDebCreTot[1] + aSomatot[3])	 ,.T.,.T.,.T., .F. )	
	cXML += A270Tag( 3,"ans:totaisLiquidosDemonstrativo"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:totaisDemonstrativo"	,''				 ,.F.,.T.,.T., .F. )	
	cXML += A270Tag( 3,"ans:demonstrativoPagamento"	,''				 ,.F.,.T.,.T., .F. )

else	
	aRetFun := PlsRtCgloRet()
	cXML += A270Tag( 3,"ans:mensagemErro"	,''				,.T.,.F.,.T., .F. )
    cXML += A270Tag( 3,"ans:codigoGlosa"	, aRetFun[1]	,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:descricaoGlosa"	, aRetFun[2] 	,.T.,.T.,.T., .F. )
    cXML += A270Tag( 3,"ans:mensagemErro"	,''				,.F.,.T.,.T., .F. )
	lControl := .F.
endif

cXML += A270Tag( 3,"ans:demonstrativoRetorno"	,''				 ,.F.,.T.,.T., .F. )

//--< Calculo e inclusao do HASH no arquivo >--					
fClose( nArqHash )
					
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
	
cXML += A270Tag( 3,"ans:hash"	,cHash				 ,.T.,.T.,.T., .F. )


HMClean(oHashDP27)
HMClean(oHashDesc)
return cXML


/*/{Protheus.doc} deParaSimpl
De-para simplificado pros web services de demonstrativos
@author Oscar
@since 08/02/2019
@version 1.0
/*/
function deParaSimpl(cTabTIss, cValor, cTabPLS,oHashDP,lvalidFun,aDadPro)
local aRetDP      := {}
Local cRet		  := ""
Local aRetGetP    := {}
default lvalidFun := .F.
default cTabPLS   := ""
default oHashDP   := nil
default aDadPro   := {}

cRet := cValor

if lvalidFun 
	if oHashDP <> nil .And. HMGet( oHashDP, aDadPro[1]+aDadPro[2], @aRetDP ) .and. len(aRetDP) > 0
		aRetGetP := aRetDP[1,2]
	else	
		aRetGetP:= PLGETPROC(aDadPro[1],aDadPro[2])
		if oHashDP <> nil
			HmAdd(oHashDP, {aDadPro[1]+ aDadPro[2], aRetGetP})
		endif	
	endif
else 
	if oHashDP <> nil .And. HMGet( oHashDP, cTabTIss+cValor, @aRetDP ) .and. len(aRetDP) > 0
		cRet := aRetDP[1,2]
	else
		If empTy(cTabPLS)
			BTU->(dbSetOrder(4))
			If BTU->(MsSeek(xfilial("BTU") + cTabTIss + cValor))
				cRet := AllTrim(BTU->BTU_CDTERM)
			endIf
		else
			BTU->(dbSetOrder(1))
			If BTU->(Msseek(	xfilial('BTU') + ctabtiss + cTabPLS + cvalor))
				cRet := AllTrim(BTU->BTU_CDTERM)
			else
				BTU->(dbsetOrder(2))
				If BTU->(MsSeek(xfilial("BTU") + cTabTIss + cTabPLS + xfilial(cTabPLS) + cValor))
					cRet := AllTrim(BTU->BTU_CDTERM)
				endIf
			endIf
		endIf
		if oHashDP <> nil
			HmAdd(oHashDP, {cTabTIss+cValor, cRet})
		endif
	endif
endif	
return (iif(!lvalidFun,cRet,aRetGetP))


/*/{Protheus.doc} descTissSp
Traz a descrição conforme a BTQ
@author Oscar
@since 08/02/2019
@version 1.0
/*/
function descTissSp(cTabTiss, cterm, cDefault,oHashDesc)
local aRetDscDP    := {}
Local cRet         := ""
Default oHashDesc  :=nil
Default cDefault   := ""

If !(EmpTy(cDefault))
	cRet := cDefault
else
	cRet := cterm
endIf

if oHashDesc <> nil .And. HMGet( oHashDesc, cTabTiss+cterm, @aRetDscDP ) .and. len(aRetDscDP) > 0
	cRet := aRetDscDP[1,2]
else
	cSql := " SELECT BTQ_DESTER FROM " + RetSqlName("BTQ")
	cSql += " WHERE BTQ_FILIAL = '" + xfilial("BTQ") + "'"
	cSql += " AND BTQ_CODTAB = '" + cTabTiss + "'"
	cSql += " AND BTQ_CDTERM = '" + cterm + "'"
	cSql += " AND D_E_L_E_T_ = ' '
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBTQ",.F.,.T.)
	if !TrbBTQ->(eof())
		cRet := Alltrim(TrbBTQ->BTQ_DESTER)
	endif
	TrbBTQ->(dbclosearea())

	if oHashDesc <> nil
		HmAdd(oHashDesc, {cTabTiss+cterm, cRet})
	endif
endif	
return cRet


/*/{Protheus.doc} montaRetDA
Monta o miolo do retorno do demonstrativo de análise de conta
@author Oscar
@since 08/02/2019
@version 1.0
/*/
Static function montaRetDA( cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, cCnes, aProtoc, aDadPEG, lPortal, cCpfCnpjR, cVerArq )
Local cXML := ""
Local cDataAtu := DtoS(DatE())
Local nI := 1
local aSomaGui := {0, 0, 0, 0}
Local nZ := 0
Local aSomatot := {0, 0, 0, 0}
Local nIni	:= 1
Local cguiAtu := ""
Local cGloTiss := ""
Local lBE4 := .F.
Local cOrimov := ""
Local lvalor := .T.
Local nValGlo := 0
Local nOk := 0
Local lExitPeg := .F.
Local aSomaGer := {0, 0, 0, 0}
local cNumProt := ""
local cSenha   := ""
local cNumImp  := ""
local cMatric  := ""
local aProced  := {}
local cDataIniZ := ""
local cDataFimZ := ""
Local lPLSUNI	:= getNewPar("MV_PLSUNI", "0") == "1"
local aRetFun	:= {}
//pesquisa hash
local oHashDP	:= HMNew()
local oHashDesc :=HMNew()

Private nArqHash := 0

Default cCnes := '9999999'
default cCpfCnpjR := ""
Default cVerArq := PGETTISVER()

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" )

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML //"Não foi possível criar o diretorio no servidor:"
		Return(cRet)
	EndIf
EndIf

nArqHash := fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )

cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao" ,''						 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:tipoTransacao"			,'DEMONSTRATIVO_ANALISE_CONTA' ,.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:sequencialTransacao"	,cSeqTran				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:horaRegistroTransacao"	,time()				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	,''				 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:registroANS"	,cRegANSOpe				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	,''				 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''				 ,.T.,.F.,.T., .F. )

if lPortal
	cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA  ,.T.,.T.,.T., .F. )
elseIf Len(cCpfCnpjR) == 11 //CPF
	cXML += A270Tag( 4,"ans:CPF"				, cCpfCnpjR ,.T.,.T.,.T., .F. )
Elseif Len(cCpfCnpjR) == 14 //CNPJ
	cXML += A270Tag( 4,"ans:CNPJ"				, cCpfCnpjR ,.T.,.T.,.T., .F. )
else
	cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA  ,.T.,.T.,.T., .F. )
EndIf

cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:Padrao"	,cVerArq			 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 1,"ans:cabecalho"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:demonstrativoRetorno"	,''				 ,.T.,.F.,.T., .F. )

if len(aDadPEG) > 0
	BDX->(DbSetOrder(4))
	//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN+BDX_CODPAD+BDX_CODPRO+BDX_TIPGLO
	BD7->(DbSetOrder(1))

	cXML += A270Tag( 4,"ans:demonstrativoAnaliseConta"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 5,"ans:cabecalhoDemonstrativo"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 6,"ans:registroANS"	,cRegANSOpe				 ,.T.,.T.,.T., .F. ) //1 - Registro ANS
	cXML += A270Tag( 6,"ans:numeroDemonstrativo"	, cDataAtu + cSeqTran	 ,.T.,.T.,.T., .F. ) //2
	cXML += A270Tag( 6,"ans:nomeOperadora"	,cNomeOpe				 ,.T.,.T.,.T., .F. ) //3 - Nome da Operadora
	cXML += A270Tag( 6,"ans:numeroCNPJ"	,cCNPJOpe				 ,.T.,.T.,.T., .F. ) //4 - CNPJ Operadora
	cXML += A270Tag( 6,"ans:dataEmissao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2)  ,.T.,.T.,.T., .F. ) //5 - Data de Emissao
	cXML += A270Tag( 5,"ans:cabecalhoDemonstrativo"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 4,"ans:dadosPrestador"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 3,"ans:dadosContratado"	,''				 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 3,"ans:codigoPrestadorNaOperadora"	,cCodRDA				 ,.T.,.T.,.T., .F. ) //6 - Código na Operadora
	if cVerArq < "4.00.00"
		cXML += A270Tag( 3,"ans:nomeContratado"	,cNomeRDA				 ,.T.,.T.,.T., .F. ) //7 - Nome do Contratado
	endif
	cXML += A270Tag( 3,"ans:dadosContratado"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:CNES"	,cCnes				 ,.T.,.T.,.T., .F. ) //8 - Código CNES
	cXML += A270Tag( 3,"ans:dadosPrestador"	,''				 ,.F.,.T.,.T., .F. )

	cXML += A270Tag( 4,"ans:dadosConta"	,''				 ,.T.,.F.,.T., .F. )
	for nI := 1 To Len(aProtoc)
		
		BCI->(dbSetOrder(14))
		If ! BCI->(Msseek( xfilial("BCI") + aProtoc[nI])) .OR. (BCI->BCI_CODRDA != cCodRDA .AND. !lPLSUNI) //Sem protocolo, sem relatório
			Loop
		endIf
		nOk++
		cXML += A270Tag( 4,"ans:dadosProtocolo"	,''				 ,.T.,.F.,.T., .F. )	

		If !(EmpTy(BCI->BCI_LOTGUI))
			cNumProt := BCI->BCI_LOTGUI
		elseIf !(EmpTy(BCI->BCI_IDXML))
			cNumProt := BCI->BCI_IDXML
		else
			cNumProt := aProtoc[nI]
		endIf
		cXML += A270Tag( 3,"ans:numeroLotePrestador"	,cNumProt				 ,.T.,.T.,.T., .F. ) //9 - Número do Lote
		cNumProt := ""
		cXML += A270Tag( 3,"ans:numeroProtocolo"	, BCI->BCI_CODPEG				 ,.T.,.T.,.T., .F. ) //10 - Número do Protocolo
		cData := DtoS(BCI->BCI_DTDIGI)
		cXML += A270Tag( 3,"ans:dataProtocolo"	, substr(cData, 1, 4) + "-" + substr(cData, 5, 2) + "-" + substr(cData, 7, 2)	 ,.T.,.T.,.T., .F. ) //11 - Data do Protocolo
		
		If !(empTy(BCI->BCI_CODGLO))
			cGloTiss := ""
			cXML += A270Tag( 4,"ans:GlosaProtocolo"	,''				 ,.T.,.F.,.T., .F. )
			cGloTiss := deParaSimpl('38', BCI->BCI_CODGLO, 'BCT',@oHashDP)
			if(empty(allTrim(cGloTiss)))
				cGloTiss := retCodGlo(BCI->BCI_CODOPE, BCI->BCI_CODGLO)
			endif
			cXML += A270Tag( 3,"ans:codigoGlosa"	, cGloTiss ,.T.,.T.,.T., .F. ) //12 - Código da Glosa do Protocolo
			cXML += A270Tag( 3,"ans:descricaoGlosa"	,descTissSp('38', cGloTiss,,@oHashDesc)				 ,.T.,.T.,.T., .F. )
			cXML += A270Tag( 4,"ans:GlosaProtocolo"	,''				 ,.F.,.T.,.T., .F. )
		endIf
		cXML += A270Tag( 3,"ans:situacaoProtocolo"	,BCI->BCI_STTISS				 ,.T.,.T.,.T., .F. ) //13 - Código da Situação do Protocolo

		for nZ := nIni To Len(aDadPEG)
			cguiAtu := aDadPEG[nZ][1] + aDadPEG[nZ][2]
			cSenha  := ""
			cNumImp := ""

			if BCI->BCI_TIPGUI != "05"
				BD5->(DbSetOrder(2))
				BD5->(MsSeek(xFilial("BD5")+aDadPEG[nZ][5]+aDadPEG[nZ][19]+aDadPEG[nZ][1]+aDadPEG[nZ][2]))
				cSenha  := BD5->BD5_SENHA
				cNumImp := BD5->BD5_NUMIMP
			else
				BE4->(DbSetOrder(1))
				BE4->(MsSeek(xFilial("BE4")+aDadPEG[nZ][5]+aDadPEG[nZ][19]+aDadPEG[nZ][1]+aDadPEG[nZ][2]))
				cSenha  := BE4->BE4_SENHA
				cNumImp := BE4->BE4_NUMIMP
			endif

			cXML += A270Tag( 4,"ans:relacaoGuias"	,''				 ,.T.,.F.,.T., .F. )
			cXML += A270Tag( 3,"ans:numeroGuiaPrestador"	,iif(!empty(cNumImp),cNumImp,aDadPEG[nZ][1]+aDadPEG[nZ][2])	 ,.T.,.T.,.T., .F. ) //14 - Número da Guia no Prestador
			cXML += A270Tag( 3,"ans:numeroGuiaOperadora"	,aDadPEG[nZ][1]+aDadPEG[nZ][2]				 ,.T.,.T.,.T., .F. ) //15 - Número da Guia Atribuído pela Operadora

			cXML += A270Tag( 3,"ans:senha"	, cSenha				 ,.T.,.T.,.f., .F. ) //16 - Senha
			
			if cVerArq < "4.00.00"
				cXML += A270Tag( 3,"ans:nomeBeneficiario"	,aDadPEG[nZ][4]				 ,.T.,.T.,.T., .F. ) //17 - Nome do Beneficiário
			endif

			if aDadPEG[nZ][5] <> aDadPEG[nZ][21] .and. !empty(aDadPEG[nZ][22])
				cMatric := aDadPEG[nZ][22]
			else
				cMatric := aDadPEG[nZ][5]+aDadPEG[nZ][6]+aDadPEG[nZ][7]+aDadPEG[nZ][8]+aDadPEG[nZ][9]
			endif
			cXML += A270Tag( 3,"ans:numeroCarteira"	,cMatric ,.T.,.T.,.T., .F. ) //18 - Número da Carteira
			
			If BCI->BCI_TIPGUI == "05"
				BE4->(dbSetOrder(1))
				If BE4->(MsSeek(xfilial('BE4') + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2]))
					cDataIniZ := ""
					cDataFimZ := ""
					
					If !(EmpTy(BE4->BE4_DTINIF))
						cDataIniZ := DtoS(BE4->BE4_DTINIF)
						cXML += A270Tag( 3,"ans:dataInicioFat"	,substr(cDataIniZ, 1, 4) + "-" + substr(cDataIniZ, 5, 2) + "-" + substr(cDataIniZ, 7, 2)	 ,.T.,.T.,.T., .F. ) //19 - Data do Início do Faturamento
					endif

					cXML += A270Tag( 3,"ans:horaInicioFat"	, MskHoraZ(BE4->BE4_HRINIF)		,.T.,.T.,.T., .F. ) //20 - Hora do Início do Faturamento
					
					If !(EmpTy(BE4->BE4_DTFIMF))
						cDataFimZ := DtoS(BE4->BE4_DTFIMF)
						cXML += A270Tag( 3,"ans:dataFimFat"	,substr(cDataFimZ, 1, 4) + "-" + substr(cDataFimZ, 5, 2) + "-" + substr(cDataFimZ, 7, 2)		,.T.,.T.,.T., .F. ) //21 - Data do Fim do Faturamento
					endIf
					
					cXML += A270Tag( 3,"ans:horaFimFat"	, MskHoraZ(BE4->BE4_HRFIMF)		,.T.,.T.,.T., .F. ) //22 - Hora do Fim do Faturamento
					
					lBE4 := .T.
					cOrimov := BE4->BE4_ORIMOV
				endIf
			else
				BD5->(DbSetOrder(1))
				BD5->(MsSeek(xfilial("BD5") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2]))
				cOrimov := BD5->BD5_ORIMOV
				cDataIniZ := ""
				cDataIniZ := PlDataProc(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, aDadPEG[nZ][2])[1,1] //menor data
				cXML += A270Tag( 3,"ans:dataInicioFat", substr(cDataIniZ, 1, 4) + "-" + substr(cDataIniZ, 5, 2) + "-" + substr(cDataIniZ, 7, 2), .T., .T., .T., .F. ) //19 - Data do Início do Faturamento
			endIf
			
			If (lBE4 .AND. !(empTy(BE4->BE4_CODGLO))) .OR. (!lBE4 .AND. !(empTy(BD5->BD5_CODGLO)))
				cGloTiss := ""
				cXML += A270Tag( 4,"ans:motivoGlosaGuia"	,''				 ,.T.,.F.,.T., .F. )
				
				cGloTiss := deParaSimpl('38', IIF(lBE4, BE4->BE4_CODGLO, BD5->BD5_CODGLO), 'BCT',@oHashDP )
				if(empty(allTrim(cGloTiss)))
					cGloTiss := retCodGlo(BCI->BCI_CODOPE, IIF(lBE4, BE4->BE4_CODGLO, BD5->BD5_CODGLO))
				endif

				cXML += A270Tag( 3,"ans:codigoGlosa"	,cGloTiss				 ,.T.,.T.,.T., .F. ) //23 - Código da Glosa da Guia
				cXML += A270Tag( 3,"ans:descricaoGlosa"	,descTissSp('38', cGloTiss, 'BCT',@oHashDesc)		 ,.T.,.T.,.T., .F. )
				cXML += A270Tag( 4,"ans:motivoGlosaGuia"	,''				 ,.F.,.T.,.T., .F. )
			endIF
			
			cXML += A270Tag( 3,"ans:situacaoGuia"	,BCI->BCI_STTISS		 ,.T.,.T.,.T., .F. ) //Tem que ser revisto isso.. 24 - Código da Situação da Guia
				
			While nZ <= Len(aDadPEG)
							
				cXML += A270Tag( 4,"ans:detalhesGuia"	,''				 ,.T.,.F.,.T., .F. )
				If cVerArq >= '3.04.00'
					cXML += A270Tag( 3,"ans:sequencialItem"	, StrZero( Val(aDadPEG[nZ][20]), 4)	 ,.T.,.T.,.T., .F. ) // Novo (em 10/12/2019 era novo), sequnecial do item
				EndIf
				cXML += A270Tag( 3,"ans:dataRealizacao"	,substr(aDadPEG[nZ][10], 1, 4) + "-" + substr(aDadPEG[nZ][10], 5, 2) + "-" + substr(aDadPEG[nZ][10], 7, 2)				 ,.T.,.T.,.T., .F. ) //25 - Data de realização
				cXML += A270Tag( 4,"ans:procedimento"	,''				 ,.T.,.F.,.T., .F. )
				aProced	:= deParaSimpl(nil,nil,nil,@oHashDP,.T.,{aDadPEG[nZ][11],aDadPEG[nZ][12]})
				
				cXML += A270Tag( 3,"ans:codigoTabela"			, aProced[2]		 ,.T.,.T.,.T., .F. ) //26 - Tabela
				cXML += A270Tag( 3,"ans:codigoProcedimento"		, aProced[3]	 ,.T.,.T.,.T., .F. ) //27 - Cod. proc./Item assistencial
				cXML += A270Tag( 3,"ans:descricaoProcedimento"	, descTissSp(aProced[2], aProced[3],,@oHashDesc)	,.T.,.T.,.T., .F. ) //28 - Descrição
				cXML += A270Tag( 4,"ans:procedimento"			,''				 ,.F.,.T.,.T., .F. )
				
				If BCI->BCI_TIPGUI == "06"
					If BD7->(MsSeek( xfilial("BD7") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3] ))
						while !(BD7->(eoF())) .AND. BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3] == BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEg+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
							If !(empTy(BD7->BD7_CODTPA))
								cXML += A270Tag( 3,"ans:grauParticipacao"	,deParaSimpl('35', AllTrim(BD7->BD7_CODTPA), 'BWT',@oHashDP)		 ,.T.,.T.,.T., .F. ) //29 - Grau Part.
							endIf
							BD7->(Dbskip())
						endDo
					EndIf
				endIf
				
				cXML += A270Tag( 3,"ans:valorInformado"	, Str(aDadPEG[nZ][13])				 ,.T.,.T.,.T., .F. ) //30 - Valor Informado
				cXML += A270Tag( 3,"ans:qtdExecutada"	, Str(aDadPEG[nZ][15])				 ,.T.,.T.,.T., .F. ) //31 - Qtd. Executada
				cXML += A270Tag( 3,"ans:valorProcessado"	, Str(aDadPEG[nZ][16])				 ,.T.,.T.,.T., .F. ) //32 - Valor Processado
				cXML += A270Tag( 3,"ans:valorLiberado"	, Str(aDadPEG[nZ][17])				 ,.T.,.T.,.T., .F. ) //33 - Valor Liberado
				//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN
				If aDadPEG[nZ][18] > 0
					If BDX->(MsSeek( xFilial("BDX") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3]))
						While BDX->(BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN) == BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3] .AND. !(BDX->(eoF()))
							
							If BDX->BDX_TIPREG == "1"
								cGloTiss := ""
								cXML += A270Tag( 4,"ans:relacaoGlosa"	,''				 ,.T.,.F.,.T., .F. )
								nValGlo := IIF(lvalor, aDadPEG[nZ][18], 0)
								cXML += A270Tag( 3,"ans:valorGlosa"	, Str(nValGlo)	 ,.T.,.T.,.T., .F. ) //34 - Valor Glosa

								cGloTiss := deParaSimpl('38', BDX->BDX_CODGLO, 'BCT',@oHashDP  )
								if(empty(allTrim(cGloTiss)))
									cGloTiss := retCodGlo(BDX->BDX_CODOPE, BDX->BDX_CODGLO)
								endif
								cXML += A270Tag( 3,"ans:tipoGlosa"	, cGloTiss	 ,.T.,.T.,.T., .F. ) //35 - Cód. da Glosa
								cXML += A270Tag( 4,"ans:relacaoGlosa"	,''				 ,.F.,.T.,.T., .F. )
								lvalor := .F.
							endIf
							BDX->(Dbskip())
						EndDo
						lvalor := .T.
					EndIf
				EndIf
				
				cXML += A270Tag( 4,"ans:detalhesGuia"	,''		 ,.F.,.T.,.T., .F. )
				
				aSomaGui[1] += aDadPEG[nZ][13] //apr
				aSomaGui[2] += aDadPEG[nZ][16] //man
				aSomaGui[3] += aDadPEG[nZ][17] //pag
				aSomaGui[4] += aDadPEG[nZ][18] //glo
				nValGlo := 0
				
				
				If nZ == Len(aDadPEG) .OR. aDadPEG[nZ][1] != aDadPEG[nZ+1][1]
					lExitPeg := .T.
				EndIf
				If nZ == Len(aDadPEG) .OR. aDadPEG[nZ][1] + aDadPEG[nZ][2] != aDadPEG[nZ+1][1] + aDadPEG[nZ+1][2]
					Exit
				EndIf
				
				nZ++
			EndDo
					
			cXML += A270Tag( 3,"ans:valorInformadoGuia"	, Str(aSomaGui[1])			 ,.T.,.T.,.T., .F. ) //36 - Valor Informado da Guia (R$)
			cXML += A270Tag( 3,"ans:valorProcessadoGuia"	, Str(aSomaGui[2])				 ,.T.,.T.,.T., .F. ) //37 - Valor Processado da Guia (R$)
			cXML += A270Tag( 3,"ans:valorLiberadoGuia"	, str(aSomaGui[3])				 ,.T.,.T.,.T., .F. ) //38 - Valor Liberado da Guia (R$)
			cXML += A270Tag( 3,"ans:valorGlosaGuia"	, str(aSomaGui[4])				 ,.T.,.T.,.T., .F. ) //39 - Valor Glosa da Guia (R$)
			cXML += A270Tag( 4,"ans:relacaoGuias"	,''				 ,.F.,.T.,.T., .F. )
			
			nIni := nZ + 1
			aSomatot[1] += aSomaGui[1]
			aSomatot[2] += aSomaGui[2]
			aSomatot[3] += aSomaGui[3]
			aSomatot[4] += aSomaGui[4]
			aSomaGui := {0, 0, 0, 0}
			
			if lExitPeg
				Exit
			endIf 
		next
		
		lExitPeg := .F.
		
		cXML += A270Tag( 3,"ans:valorInformadoProtocolo"	, Str(aSomatot[1])				 ,.T.,.T.,.T., .F. ) //40 - Valor Informado do Protocolo (R$)
		cXML += A270Tag( 3,"ans:valorProcessadoProtocolo"	, Str(aSomatot[2])				 ,.T.,.T.,.T., .F. ) //41 - Valor Processado do Protocolo (R$)
		cXML += A270Tag( 3,"ans:valorLiberadoProtocolo"	, Str(aSomatot[3])				 ,.T.,.T.,.T., .F. ) //42 - Valor Liberado do Protocolo (R$)
		cXML += A270Tag( 3,"ans:valorGlosaProtocolo"	, Str(aSomatot[4])				 ,.T.,.T.,.T., .F. ) //43 - Valor Glosa do Protocolo (R$)
		cXML += A270Tag( 4,"ans:dadosProtocolo"	,''				 ,.F.,.T.,.T., .F. )

		aSomaGer[1] += aSomatot[1]
		aSomaGer[2] += aSomatot[2]
		aSomaGer[3] += aSomatot[3]
		aSomaGer[4] += aSomatot[4]
		
		aSomatot := {0, 0, 0, 0}
		
	next

	cXML += A270Tag( 4,"ans:dadosConta"	,''				 ,.F.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:valorInformadoGeral"	, Str(aSomaGer[1])				 ,.T.,.T.,.T., .F. ) //44 - Valor Informado Geral (R$)
	cXML += A270Tag( 3,"ans:valorProcessadoGeral"	, Str(aSomaGer[2])				 ,.T.,.T.,.T., .F. ) //45 - Valor Processado Geral (R$)
	cXML += A270Tag( 3,"ans:valorLiberadoGeral"	, Str(aSomaGer[3]	)			 ,.T.,.T.,.T., .F. ) //46 - Valor Liberado Geral (R$)
	cXML += A270Tag( 3,"ans:valorGlosaGeral"	, Str(aSomaGer[4])				 ,.T.,.T.,.T., .F. ) //47 - Valor Glosa Geral (R$)
	cXML += A270Tag( 4,"ans:demonstrativoAnaliseConta"	,''				 ,.F.,.T.,.T., .F. )

else
	aRetFun := PlsRtCgloRet()
	cXML += A270Tag( 3,"ans:mensagemErro"	, ''			,.T.,.F.,.T., .F. )
	cXML += A270Tag( 3,"ans:codigoGlosa"	, aRetFun[1]	,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:descricaoGlosa"	, aRetFun[2] 	,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:mensagemErro"	, ''			,.F.,.T.,.T., .F. )
endIf

cXML += A270Tag( 3,"ans:demonstrativoRetorno"	,''				 ,.F.,.T.,.T., .F. )

//--< Calculo e inclusao do HASH no arquivo >--					
fClose( nArqHash )
					
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
	
cXML += A270Tag( 3,"ans:hash"	,cHash				 ,.T.,.T.,.T., .F. )

HMClean(oHashDP)
HMClean(oHashDesc)
return cXML


/*/{Protheus.doc} MskHoraZ
Põe a máscara de hora nas horas do XML de demonstrativos
@author Oscar
@since 14/02/2019
@version 1.0
/*/
static function MskHoraZ(cHora)

Local cRet := ""
Default cHora := ""

If !(EmpTy(cHora))
	cRet := AllTrim(StrTran(cHora, ":", ""))
	cRet := cRet + Replicate("0", 6 - Len(cRet))
	cRet := subStr(cRet, 1, 2) + ":" +  subStr(cRet, 3, 2) + ":" + subStr(cRet, 5, 2)
EndIF

return cret

//função para chamada da STATIC no caso de teste automatizado
function WsDemoV01(cSoap,cSchema)

xRet := VldWSdemoP(cSoap,cSchema)

return xRet


/*/{Protheus.doc} montaRetDO
Monta o retorno do demonstrativo odonto
@author Pablo Alipio
@since 17/04/2019
@version 1.0
/*/
Static function montaRetDO (cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, cCnes, cDatPag, aDadPag, aDadDebCre, cForPGt, aDadBan, lControl, lPortal, cCPFCNPJR, aDadDC, cVerArq)
local cXml    	 := ""
local cDataAtu 	 := DtoS(DatE())
local aSomaDat   := {0, 0, 0, 0, 0}
local aSomaGui   := {0, 0, 0, 0, 0}
local aSomaProt  := {0, 0, 0, 0, 0}
local aSomaTot   := {0, 0, 0, 0, 0}
local aGuias	 := {}
local aProt 	 := {}
local aData 	 := {}
local aDadDC2 	 := {}
local aDebCreDat := {0, 0}
local nA 		 := 1
local nZ 		 := 1
local nI 		 := 1
local nY 		 := 1
local nX		 := 1
local nW		 := 1
local nProt 	 := 1
local nDat 		 := 1
local nCont 	 := 1
local nENum 	 := 1
local nDad 		 := 1
local aDebCreTot := {0, 0}
local aDebCrZ	 := {}
local ctempterm  := ""
local aE2Num 	 := {}
local cNumImp    := ""
local cNumProt 	 := ""
local cNumOpe	 := ""
local cNomOpe    := ""
local aDadOpe	 := {}
local cOrimov    := ""
local cPegGui	 := ""
local cDenReg 	 := ""
local nInformado := 0
local nProcess   := 0
local nGlosa     := 0
local nLiberado  := 0
local aRetFun	 := {}
//Pesquisa hash
local oHashDP:= HMNew()
local oHashDesc :=HMNew()


Private nArqHash := 0

BCI->(DbsetOrder(14))
BA1->(DbSetOrder(2))

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" )

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML //"Não foi possível criar o diretorio no servidor:"
		Return(cRet)
	EndIf
EndIf

nArqHash := fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )

cXML += A270Tag( 1,"ans:cabecalho"				,''						 	  ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao" ,''						 	  ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:tipoTransacao"			,'DEMONSTRATIVO_ODONTOLOGIA'  ,.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:sequencialTransacao"	,cSeqTran				 	  ,.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:horaRegistroTransacao"	,time()				     ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	                ,''				         ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:registroANS"	        ,cRegANSOpe				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	                ,''				         ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	            ,''				         ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''				         ,.T.,.F.,.T., .F. )
if lPortal
	cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA        ,.T.,.T.,.T., .F. )
elseIf Len(cCpfCnpjR) == 11 //CPF
	cXML += A270Tag( 4,"ans:CPF"				        , cCpfCnpjR      ,.T.,.T.,.T., .F. )
Elseif Len(cCpfCnpjR) == 14 //CNPJ
	cXML += A270Tag( 4,"ans:CNPJ"				        , cCpfCnpjR      ,.T.,.T.,.T., .F. )
else
	cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA        ,.T.,.T.,.T., .F. )
EndIf
cXML += A270Tag( 3,"ans:identificacaoPrestador"	        ,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	                    ,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:Padrao"	                        ,cVerArq	     ,.T.,.T.,.T., .F. )
cXML += A270Tag( 1,"ans:cabecalho"	                    ,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:demonstrativoRetorno"	        ,''				 ,.T.,.F.,.T., .F. )

nZ := Len(adadPag)
if nZ > 0
	// preenche o aDadOpe com as diferentes operadoras
	while aScan(aDadPag, {|x| x[15] != cNumOpe} ) > 0
		nPos := aScan(aDadPag, {|x| x[15] != cNumOpe} )
		cNumOpe := aDadPag[nPos][15]
		BA0->(dbSetOrder(1))
		If BA0->(MsSeek(xfilial("BA0") + cNumOpe))
			cNomOpe  := BA0->BA0_NOMINT
			cCNPJOpe := BA0->BA0_CGC
		endif
		aadd(aDadOpe, {cNomOpe,cCNPJOpe})
	enddo
	
	for nA := 1 to len(aDadOpe)
	
		cXML += A270Tag( 4,"ans:demonstrativoPagamentoOdonto"	,''				 	 ,.T.,.F.,.T., .F. )
		cXML += A270Tag( 5,"ans:cabecalhoDemonstrativoOdonto"	,''				 	 ,.T.,.F.,.T., .F. )
		cXML += A270Tag( 6,"ans:registroANS"					,cRegANSOpe			 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 6,"ans:numeroDemonstrativo"			,cDataAtu + cSeqTran ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 6,"ans:nomeOperadora"					,aDadOpe[nA][1]		 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 6,"ans:cnpjOper"						,aDadOpe[nA][2]		 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:periodoProc"					,''				 	 ,.T.,.F.,.T., .F. )
		cXML += A270Tag( 6,"ans:datainicio"	,substr(adadPag[nA][5], 1, 4) + "-" + substr(adadPag[nA][5], 5, 2) + "-" + substr(adadPag[nA][5], 7, 2)				 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 6,"ans:datafim"	,substr(adadPag[nA][30], 1, 4) + "-" + substr(adadPag[nA][30], 5, 2) + "-" + substr(adadPag[nA][30], 7, 2)				 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:periodoProc"					,''				 	 ,.F.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:cabecalhoDemonstrativoOdonto"	,''				 	 ,.F.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:dadosPrestador"					,''					 ,.T.,.F.,.T., .F. )
		cXML += A270Tag( 6,"ans:codigoPrestador"				,cCodRDA			 ,.T.,.T.,.T., .F. )
		if cVerArq < "4.00.00"
			cXML += A270Tag( 6,"ans:nomePrestador"					,cNomeRDA			 ,.T.,.T.,.T., .F. )
		endif
		cXML += A270Tag( 6,"ans:cpfCNPJContratado"				,''				 	 ,.T.,.F.,.T., .F. )
		if Len(cCpfCnpjR) == 14 //CNPJ
			cXML += A270Tag( 7,"ans:cnpjPrestador"				,cCpfCnpjR			 ,.T.,.T.,.T., .F. )
		elseif Len(cCpfCnpjR) == 11 //CPF
			cXML += A270Tag( 7,"ans:cpfContratado"				,cCpfCnpjR			 ,.T.,.T.,.T., .F. )
		endif
		cXML += A270Tag( 6,"ans:cpfCNPJContratado"				,''				 ,.F.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:dadosPrestador"					,''				 ,.F.,.T.,.T., .F. )	
	
		for nDat := 1 To nZ		
			if len(aData) == 0 .OR. aScan(aData, {|x| x == adadPag[nDat][7]} ) == 0 
				aadd(aData, adadPag[nDat][7])
		        aSomaDat  := {0, 0, 0, 0, 0}
		        aDebCreDat := { 0, 0 }
		
				cXML += A270Tag( 4,"ans:dadosPagamentoPorData"	,''				 ,.T.,.F.,.T., .F. )
				cXML += A270Tag( 5,"ans:dadosPagamento"			,''				 ,.T.,.F.,.T., .F. )
				cXML += A270Tag( 6,"ans:dataPagamento"			,substr(adadPag[nDat][7], 1, 4) + "-" + substr(adadPag[nDat][7], 5, 2) + "-" + substr(adadPag[nDat][7], 7, 2)	,.T.,.T.,.T., .F. )
		
				If alltrim(cForPGt) == "1"
					cXML += A270Tag( 7,"ans:banco"		,aDadBan[1]		,.T.,.T.,.T., .F. )
					cXML += A270Tag( 7,"ans:agencia"	,aDadBan[2]		,.T.,.T.,.T., .F. )
					cXML += A270Tag( 7,"ans:conta"		,aDadBan[3]		,.T.,.T.,.T., .F. )
				endIf
				cXML += A270Tag( 6,"ans:dadosPagamento"	,''				 ,.F.,.T.,.T., .F. )		
				for nI := nProt To nZ	
					// zera array dos valores totais do protocolo
					aSomaProt := {0, 0, 0, 0, 0}
					// if len(aProt) == 0 .OR. aScan(aProt, adadPag[nI][6]) == 0           		            	
			            cXML += A270Tag( 5,"ans:protocolos"	,''				 ,.T.,.F.,.T., .F. )
						If BCI->(MsSeek(xFilial("BCI") + adadPag[nI][6]))
							If !(EmpTy(BCI->BCI_LOTGUI))
								cNumLot := BCI->BCI_LOTGUI
							elseIf !(EmpTy(BCI->BCI_IDXML))
								cNumLot := BCI->BCI_IDXML
							else
								cNumLot := adadPag[nI][6]
							endIf
						else
							cNumLot := adadPag[nI][6]
						endIf		
						cXML += A270Tag( 3,"ans:numeroLote"	,cNumLot				 	,.T.,.T.,.T., .F. )
						cXML += A270Tag( 3,"ans:numeroProtocolo"	,adadPag[nI][6]		,.T.,.T.,.T., .F. )			
						cNumLot := ""			
			            
						if BCI->BCI_TIPGUI != "05"
							BD5->(DbSetOrder(2))
							BD5->(MsSeek(xFilial("BD5")+adadPag[nI][15]+adadPag[nI][16]+adadPag[nI][6]+adadPag[nI][17]))
							cNumImp  := BD5->BD5_NUMIMP
			                cNumProt := BD5->BD5_CODPEG
			                cOrimov  := BD5->BD5_ORIMOV		                
						else
							BE4->(DbSetOrder(1))
							BE4->(MsSeek(xFilial("BE4")+adadPag[nI][15]+adadPag[nI][16]+adadPag[nI][6]+adadPag[nI][17]))
							cNumImp  := BE4->BE4_NUMIMP
			                cNumProt := BE4->BE4_CODPEG
			                cOrimov  := BE4->BE4_ORIMOV
						endif
			
			            for nY := nProt to nZ 		
			            	aSomaGui  := {0, 0, 0, 0, 0}   
			            
			                if BCI->BCI_TIPGUI != "05"
								BD5->(DbSetOrder(2))
								BD5->(MsSeek(xFilial("BD5")+adadPag[nY][15]+adadPag[nY][16]+adadPag[nY][6]+adadPag[nY][17]))
				                cPegGui  := BD5->BD5_CODPEG+BD5->BD5_NUMERO
							else
								BE4->(DbSetOrder(1))
								BE4->(MsSeek(xFilial("BE4")+adadPag[nY][15]+adadPag[nY][16]+adadPag[nY][6]+adadPag[nY][17]))
								cPegGui  := BE4->BE4_CODPEG+BE4->BE4_NUMERO
							endif
			            	
			                if adadPag[nY][6] == cNumProt	    
			                	if len(aGuias) == 0 .OR. aScan(aGuias, adadPag[nY][6]+adadPag[nY][17]) == 0
			                		cXML += A270Tag( 3,"ans:dadosPagamentoGuia"	    ,''				 				 ,.T.,.F.,.T., .F. )
				                    cXML += A270Tag( 3,"ans:numeroGuiaPrestador"	,iif(!empty(cNumImp),cNumImp,adadPag[nY][6]+adadPag[nY][17])	 ,.T.,.T.,.T., .F. )
				                    cXML += A270Tag( 3,"ans:numeroGuiaOperadora"	,adadPag[nY][6]+adadPag[nY][17]	 ,.T.,.T.,.T., .F. )
				                    cXML += A270Tag( 3,"ans:recurso"	            ,'N'				             ,.T.,.T.,.T., .F. )
				                    cXML += A270Tag( 3,"ans:nomeExecutante"	        ,adadPag[nY][20]				 ,.T.,.T.,.T., .F. )
				                    cXML += A270Tag( 3,"ans:carteiraBeneficiario"	,adadPag[nY][21]				 ,.T.,.T.,.T., .F. )
				                    if cVerArq < "4.00.00" .OR. lPortal
										cXML += A270Tag( 3,"ans:nomeBeneficiario"	    ,adadPag[nY][22]				 ,.T.,.T.,.T., .F. )
										if lPortal
											//Esa tag NÃO faz parte da estrutura padrão da resposta do web service, apenas incluímos ela para a impressão via portal
											//pq a ANS deixou informações no impresso que não existem na resposta do web service.
											if BA1->(MsSeek(xfilial("BA1") + adadPag[nY][21]))
												cXML += A270Tag( 3,"ans:nomeSocial"	    ,Alltrim(BA1->BA1_NOMSOC)				 ,.T.,.T.,.T., .F. )
											endif
										endif
									endif
				                    for nX := 1 to nZ
				                        if cPegGui == adadPag[nX][6]+adadPag[nX][17]
											// verifica se no proximo loop se trata do mesmo procedimento (devido a query utilizar o BD7)
											if nX < len(adadPag) .and. adadPag[nX][6]+adadPag[nX][17]+adadPag[nX][27]+adadPag[nX][28]+adadPag[nX][31] == adadPag[nX+1][6]+adadPag[nX+1][17]+adadPag[nX+1][27]+adadPag[nX+1][28]+adadPag[nX+1][31]
												nInformado += adadPag[nX][1]
												nProcess   += adadPag[nX][2]
												nGlosa     += adadPag[nX][4]												
												nLiberado  += adadPag[nX][3]
												loop
											else
												nInformado += adadPag[nX][1]
												nProcess   += adadPag[nX][2]
												nGlosa     += adadPag[nX][4]												
												nLiberado  += adadPag[nX][3]
											endif
				                            cXML += A270Tag( 3,"ans:dadosPagamento"	        ,''				    ,.T.,.F.,.T., .F. )
											if cVerArq >= '3.04.00'
												cXML += A270Tag( 4,"ans:sequencialItem"	, strZero( Val(adadPag[nX][31]), 4)	 ,.T.,.T.,.T., .F. ) 
											endif
				                            cXML += A270Tag( 4,"ans:procedimento"	        ,''				    ,.T.,.F.,.T., .F. )
				                           // cCodPadT := deParaSimpl('87', adadPag[nX][27], 'BR4',@oHashDP)	
										   	aProced	:= deParaSimpl(nil,nil,nil,@oHashDP,.T.,{adadPag[nX][27],adadPag[nX][28]}) 
								
				                            cXML += A270Tag( 5,"ans:codigoTabela"	        ,aProced[2]	,.T.,.T.,.T., .F. )
				                            cXML += A270Tag( 5,"ans:codigoProcedimento"	    ,aProced[3]	,.T.,.T.,.T., .F. )
				                            cXML += A270Tag( 5,"ans:descricaoProcedimento"	,allTrim(descTissSp(aProced[2], aProced[3],,@oHashDesc))	,.T.,.T.,.T., .F. )
				                            cXML += A270Tag( 4,"ans:procedimento"	        ,''				    ,.F.,.T.,.T., .F. )											
				                            if !empty(adadPag[nX][18])
				                                cXML += A270Tag( 4,"ans:denteRegiao"	    ,''				    ,.T.,.F.,.T., .F. )
				                                if adadPag[nX][23] == "1"
													cDenReg := deParaSimpl('28', adadPag[nX][27], 'B04',@oHashDP)
				                                    cXML += A270Tag( 5,"ans:codDente"	    ,cDenReg	,.T.,.T.,.T., .F. )
				                                else
													cDenReg := deParaSimpl('42', adadPag[nX][27], 'B04',@oHashDP)
				                                    cXML += A270Tag( 5,"ans:codRegiao"	    ,cDenReg	,.T.,.T.,.T., .F. )
				                                endif
				                                cXML += A270Tag( 4,"ans:denteRegiao"	    ,''				    ,.F.,.T.,.T., .F. )
				                            endif
				                            if !empty(adadPag[nX][19])
				                                cXML += A270Tag( 4,"ans:denteFace"	    ,adadPag[nX][19]	    ,.T.,.T.,.T., .F. )
				                            endif
				
				                            cXML += A270Tag( 4,"ans:dataRealizacao"	    ,substr(adadPag[nX][24], 1, 4) + "-" + substr(adadPag[nX][24], 5, 2) + "-" + substr(adadPag[nX][24], 7, 2)  ,.T.,.T.,.T.,.F.)
				                            cXML += A270Tag( 4,"ans:qtdProc"	        ,Str(adadPag[nX][25])   ,.T.,.T.,.T.,.F.)
				                            cXML += A270Tag( 4,"ans:valorInformado"	    ,Str(nInformado)    ,.T.,.T.,.T.,.F.)
				                            cXML += A270Tag( 4,"ans:valorProcessado"	,Str(nProcess)	,.T.,.T.,.T.,.F.)
				                            cXML += A270Tag( 4,"ans:valorGlosaEstorno"	,str(nGlosa)	,.T.,.T.,.T.,.F.)
				                            cXML += A270Tag( 4,"ans:valorFranquia"	    ,Str(adadPag[nX][26])	,.T.,.T.,.T.,.F.)
				                            cXML += A270Tag( 4,"ans:valorLiberado"	    ,Str(nLiberado)	,.T.,.T.,.T.,.F.)
				                            
				                            //BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN
											If adadPag[nX][4] > 0
												BDX->(DbSetOrder(4))
												If BDX->(MsSeek( xFilial("BDX") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + adadPag[nX][17] + cOrimov + adadPag[nX][31]))																																
													If BDX->BDX_TIPREG == "1"
														cGloTiss := deParaSimpl('38', BDX->BDX_CODGLO, 'BCT',@oHashDP )
														cXML += A270Tag( 4,"ans:codigosGlosa"	    ,cGloTiss	,.T.,.T.,.T.,.F.)
													endIf													
												EndIf
											EndIf
				                            
				                            cXML += A270Tag( 3,"ans:dadosPagamento"	    ,''				        ,.F.,.T.,.T.,.F.)
				
				                            aSomaGui[1] += nInformado
				                            aSomaGui[2] += nProcess
				                            aSomaGui[3] += nLiberado
				                            aSomaGui[4] += nGlosa
				                            aSomaGui[5] += adadPag[nX][26]

											nInformado := 0
											nProcess   := 0
											nLiberado  := 0
											nGlosa 	   := 0                			                            
				                        endif                                                                                    
				                    next   
				
				                    // cXML += A270Tag( 3,"ans:observacaoGuia"	    		,''                 ,.T.,.T.,.T.,.F.)
				                    cXML += A270Tag( 3,"ans:valorTotalInformadoGuia"	,Str(aSomaGui[1])   ,.T.,.T.,.T.,.F.)
				                    cXML += A270Tag( 3,"ans:valorTotalProcessadoGuia"	,Str(aSomaGui[2])	,.T.,.T.,.T.,.F.)
				                    cXML += A270Tag( 3,"ans:valorTotalGlosaGuia"	    ,str(aSomaGui[4])	,.T.,.T.,.T.,.F.)
				                    cXML += A270Tag( 3,"ans:valorTotalFranquiaGuia"	    ,Str(aSomaGui[5])	,.T.,.T.,.T.,.F.)
				                    cXML += A270Tag( 3,"ans:valorTotalLiberadoGuia"	    ,Str(aSomaGui[3])	,.T.,.T.,.T.,.F.)
				                    
				                    cXML += A270Tag( 3,"ans:dadosPagamentoGuia"	    	,''				 	,.F.,.T.,.T., .F. )
				                     
				                    aadd(aGuias, adadPag[nY][6]+adadPag[nY][17])
				                    
				                    aSomaProt[1] += aSomaGui[1]
						            aSomaProt[2] += aSomaGui[2]
						            aSomaProt[3] += aSomaGui[3]
						            aSomaProt[4] += aSomaGui[4]
						            aSomaProt[5] += aSomaGui[5]
			                	endif
			                    
			                else
			                	nProt := nY
			                	exit	                	
			                endif                
			                
			            next		            		            
			
			            cXML += A270Tag( 3,"ans:totaisPorProtocolo"	              ,''				    ,.T.,.F.,.T., .F. )
			            cXML += A270Tag( 4,"ans:valorTotalInformadoPorProtocolo"  ,Str(aSomaProt[1])	,.T.,.T.,.T., .F. )
			            cXML += A270Tag( 4,"ans:valorTotalProcessadoPorProtocolo" ,Str(aSomaProt[2])	,.T.,.T.,.T., .F. )
			            cXML += A270Tag( 4,"ans:valorTotalGlosaPorProtocolo"      ,Str(aSomaProt[4])	,.T.,.T.,.T., .F. )
			            cXML += A270Tag( 4,"ans:valorTotalFranquiaPorProtocolo"   ,Str(aSomaProt[5])	,.T.,.T.,.T., .F. )
			            cXML += A270Tag( 4,"ans:valorTotalLiberadoPorProtocolo"   ,Str(aSomaProt[3])	,.T.,.T.,.T., .F. )
			            cXML += A270Tag( 3,"ans:totaisPorProtocolo"	              ,''				    ,.F.,.T.,.T., .F. )
			
			            aSomaDat[1] += aSomaProt[1]
			            aSomaDat[2] += aSomaProt[2]
			            aSomaDat[3] += aSomaProt[3]
			            aSomaDat[4] += aSomaProt[4]
			            aSomaDat[5] += aSomaProt[5]
			
			            
			            cXML += A270Tag( 3,"ans:protocolos"	    ,''				 ,.F.,.T.,.T., .F. )
			            if nY >= Len(adadPag) .OR. adadPag[nY-1][7] <> adadPag[nY][7]
			                cXML += A270Tag( 4,"ans:totaisPorData"	                ,''				    ,.T.,.F.,.T., .F. )
			                cXML += A270Tag( 5,"ans:valorBrutonformadoPorData"	    ,Str(aSomaDat[1])	,.T.,.T.,.T., .F. )
			                cXML += A270Tag( 6,"ans:valorBrutoProcessadoPorData"	,Str(aSomaDat[2])   ,.T.,.T.,.T., .F. )	
			                cXML += A270Tag( 6,"ans:valorBrutoGlosaPorData"	        ,Str(aSomaDat[4])   ,.T.,.T.,.T., .F. )
			                cXML += A270Tag( 6,"ans:valorBrutoFranquiaPorData"	    ,Str(aSomaDat[5])	,.T.,.T.,.T., .F. )	
			                cXML += A270Tag( 6,"ans:valorBrutoLiberadoPorData"	    ,Str(aSomaDat[3])	,.T.,.T.,.T., .F. )
			                cXML += A270Tag( 5,"ans:totaisPorData"	                ,''				    ,.F.,.T.,.T., .F. )
			
			                aSomaTot[1] += aSomaDat[1]
			                aSomaTot[2] += aSomaDat[2]
			                aSomaTot[3] += aSomaDat[3]
			                aSomaTot[4] += aSomaDat[4]
			                aSomaTot[5] += aSomaDat[5]
			
							nZ := nY
			                exit
			            endif
			            aadd(aProt, adadPag[nI][6])
		            // endif
				next                                                
				aDebCrZ := {}
				For nCont := nENum To nZ - 1
					If ascan(aE2Num, adadPag[nCont][14]) == 0
						aadd(aE2Num, adadPag[nCont][14])
						For nW := 8 To 13
							If adadPag[nCont][nW] > 0
								aadd(aDebCrZ, {'1', ;
									IIF(nW == 8, "01", IIF( nW == 9, "02", IIF( nW == 10, "03", IIF( nW == 11, "04", IIF( nW == 12, "05", "06"))))), ;
									IIF(nW == 8, "IRRF", IIF( nW == 9, "ISS", IIF( nW == 10, "INSS", IIF( nW == 11, "PIS", IIF( nW == 12, "COF", "CSLL"))))), ;
									adadPag[nCont][nW]})
							endIf
						Next
					EndIf
				Next
				nENum := nCont
				
				//Se tem débito/crédito, só abre as tags pra fazer o resto no for, se não tem só cria a estrutura
				If Len(aDebCrZ) > 0
					cXML += A270Tag( 4,"ans:debCredPorDataPagamento"	,''				             ,.T.,.F.,.T., .F. )
				else
					cXML += A270Tag( 4,"ans:totalLiquidoPorData"	    ,''				             ,.T.,.F.,.T., .F. )
					cXML += A270Tag( 5,"ans:valorTotalDebitosPorData"	,'0'				         ,.T.,.T.,.T., .F. )	
					cXML += A270Tag( 5,"ans:valorTotalCreditosPorData"	,'0'	 					 ,.T.,.T.,.T., .F. )
					cXML += A270Tag( 5,"ans:valorFinalAReceberPorData"	, Str( aSomadat[3])          ,.T.,.T.,.T., .F. )
					cXML += A270Tag( 4,"ans:totalLiquidoPorData"	    ,''				             ,.F.,.T.,.T., .F. )
				EndIf
				
				For nI := 1 To Len(aDebCrZ)
					cTempTerm := deParaSimpl('27', aDebCrZ[nI][2],,@oHashDP)
					cXML += A270Tag( 3,"ans:descontos"	        ,''				                    ,.T.,.F.,.T.,.F.)	
					cXML += A270Tag( 3,"ans:indicador"	        ,aDebCrZ[nI][1]				        ,.T.,.T.,.T.,.F.)
					cXML += A270Tag( 3,"ans:tipoDebitoCredito"	,cTempTerm				        ,.T.,.T.,.T.,.F.)
					cXML += A270Tag( 3,"ans:descricaoDbCr"	    ,substr(descTissSp('27', cTempTerm,,@oHashDesc), 1, 40)	,.T.,.T.,.T.,.F.)
					cXML += A270Tag( 3,"ans:valorDbCr"	        ,Str(aDebCrZ[nI][4])				,.T.,.T.,.T.,.F.)	
					cXML += A270Tag( 3,"ans:descontos"	        ,''				                    ,.F.,.T.,.T.,.F.)
					
					aDebCreDat[1] += aDebCrZ[nI][4] //valor do débito
					
					If nI == Len(aDebCrZ)
						cXML += A270Tag( 3,"ans:debCredPorDataPagamento"	,''				            ,.F.,.T.,.T.,.F.)	
						cXML += A270Tag( 4,"ans:totalLiquidoPorData"	    ,''				            ,.T.,.F.,.T.,.F.)
						cXML += A270Tag( 5,"ans:valorTotalDebitosPorData"	    ,Str(aDebCreDat[1])	    ,.T.,.T.,.T.,.F.)	
						cXML += A270Tag( 5,"ans:valorTotalCreditosPorData"	    ,Str(aDebCreDat[2])	    ,.T.,.T.,.T.,.F.)
						cXML += A270Tag( 5,"ans:valorFinalAReceberPorData"	    ,Str( aSomadat[3] + aDebCreDat[2] - aDebCreDat[1] ) ,.T.,.T.,.T.,.F.)
						cXML += A270Tag( 4,"ans:totalLiquidoPorData"	    ,''				            ,.F.,.T.,.T.,.F.)
						
						aDebCreTot[1] += aDebCreDat[1]
						aDebCreTot[2] += aDebCreDat[2]
					endIf
				Next
							
				If nZ < Len(adadPag)
					nZ := Len(adadPag)
				endIf
				cXML += A270Tag( 3,"ans:dadosPagamentoPorData"	,''				 ,.F.,.T.,.T., .F. )
			endif
		next
	
		cXML += A270Tag( 3,"ans:totaisBrutoDemonstrativo"	        ,''				        ,.T.,.F.,.T., .F. )
		cXML += A270Tag( 3,"ans:valorInformadoPorDemonstrativoData"	, Str(aSomaTot[1])		,.T.,.T.,.T., .F. )	
		cXML += A270Tag( 3,"ans:valorlProcessadoPorDemonstrativo"	, str(aSomaTot[2])		,.T.,.T.,.T., .F. )
		cXML += A270Tag( 3,"ans:valorlGlosaPorDemonstrativo"	    , Str(aSomaTot[4])		,.T.,.T.,.T., .F. )	
		cXML += A270Tag( 3,"ans:valoFranquiaPorDemonstrativo"	    , Str(aSomaTot[5])		,.T.,.T.,.T., .F. )
	    cXML += A270Tag( 3,"ans:valorLiberadoPorDemonstrativo"	    , Str(aSomaTot[3])	    ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 3,"ans:totaisBrutoDemonstrativo"	        ,''				        ,.F.,.T.,.T., .F. )
		
	    if Len(adadDebCre) > 0
	        cXML += A270Tag( 3,"ans:debCredDemonstrativo"	,''				 ,.T.,.F.,.T., .F. )
	        For nDad := 1 To Len(adadDebCre)	        	
	            cTempTerm := deParaSimpl('27', adadDebCre[nDad][3],,@oHashDP)
	            cXML += A270Tag( 3,"ans:descontos"	            ,''				                ,.T.,.F.,.T., .F. )
	            cXML += A270Tag( 3,"ans:indicador"	            ,adadDebCre[nDad][2]				,.T.,.T.,.T., .F. )		
	            cXML += A270Tag( 3,"ans:tipoDebitoCredito"	    , cTempTerm                     ,.T.,.T.,.T., .F. )
	            cXML += A270Tag( 3,"ans:descricaoDbCr"	        ,substr(descTissSp('27', cTempTerm,,@oHashDesc), 1, 40)	,.T.,.T.,.T., .F. )	
	            cXML += A270Tag( 3,"ans:valorDbCr"	            ,Str(adadDebCre[nDad][1])		    ,.T.,.T.,.T., .F. )
	            cXML += A270Tag( 3,"ans:descontos"	,''				                            ,.F.,.T.,.T., .F. )
	            
	            If adadDebCre[nDad][2] == "2"
	                aDebCreTot[2] += adadDebCre[nDad][1]
	            else
	                aDebCreTot[1] += adadDebCre[nDad][1]
	            EndIf
	        Next
	        for nDad := 1 to len(aDadDC)
		        For nW := 3 To 8
	            	If aDadDC[nDad][nW] > 0
						aadd(aDadDC2, {"1",;
							IIF(nW == 3, "01", IIF( nW == 4, "02", IIF( nW == 5, "03", IIF( nW == 6, "04", IIF( nW == 7, "05", "06"))))),;
							IIF(nW == 3, "IRRF", IIF( nW == 4, "ISS", IIF( nW == 5, "INSS", IIF( nW == 6, "PIS", IIF( nW == 7, "COF", "CSLL"))))),;
							aDadDC[nDad][nW] })
					endIf
				Next
			next
	        For nDad := 1 To Len(aDadDC2)
				cTempTerm := deParaSimpl('27', aDadDC2[nDad][2],,@oHashDP)	 	            	            
	            cXML += A270Tag( 3,"ans:descontos"	            ,''				                ,.T.,.F.,.T., .F. )
	            cXML += A270Tag( 3,"ans:indicador"	            , aDadDC2[nDad][1]				,.T.,.T.,.T., .F. )		
	            cXML += A270Tag( 3,"ans:tipoDebitoCredito"	    , cTempTerm                     ,.T.,.T.,.T., .F. )
	            cXML += A270Tag( 3,"ans:descricaoDbCr"	        ,substr(descTissSp('27', cTempTerm,,@oHashDesc), 1, 40)	,.T.,.T.,.T., .F. )	
	            cXML += A270Tag( 3,"ans:valorDbCr"	            ,Str(aDadDC2[nDad][4])		    ,.T.,.T.,.T., .F. )
	            cXML += A270Tag( 3,"ans:descontos"	,''				                            ,.F.,.T.,.T., .F. )
	            
	            If aDadDC2[nDad][1] == "2"
	                aDebCreTot[2] += aDadDC2[nDad][4]
	            else
	                aDebCreTot[1] += aDadDC2[nDad][4]
	            EndIf
	        Next	        
	        cXML += A270Tag( 3,"ans:debCredDemonstrativo"	,''				 ,.F.,.T.,.T., .F. )
	    endif	
		cXML += A270Tag( 3,"ans:totalDebitosDemonstativo"	,Str(aDebCreTot[1])				 ,.T.,.T.,.T., .F. )	
		cXML += A270Tag( 3,"ans:totalCreditosDemonstrativo"	,str(aDebCreTot[2])				 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 3,"ans:valorRecebidoDemonstrativo"	,Str( aDebCreTot[2] - aDebCreTot[1] + aSomatot[3])	 ,.T.,.T.,.T., .F. )
	
	    // cXML += A270Tag( 3,"ans:observacao"	,''			 ,.T.,.T.,.T., .F. )
		cXML += A270Tag( 3,"ans:demonstrativoPagamentoOdonto"	,''				 ,.F.,.T.,.T., .F. )
	
	next 
	

else
	aRetFun := PlsRtCgloRet()	
	cXML += A270Tag( 3,"ans:mensagemErro"	, ''			,.T.,.F.,.T., .F. )
    cXML += A270Tag( 3,"ans:codigoGlosa"	, aRetFun[1]	,.T.,.T.,.T., .F. )
	cXML += A270Tag( 3,"ans:descricaoGlosa"	, aRetFun[2] 	,.T.,.T.,.T., .F. )
    cXML += A270Tag( 3,"ans:mensagemErro"	, ''			,.F.,.T.,.T., .F. )
	lControl := .F.
endif

cXML += A270Tag( 3,"ans:demonstrativoRetorno"	,''				 ,.F.,.T.,.T., .F. )

//--< Calculo e inclusao do HASH no arquivo >--					
fClose( nArqHash )
					
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
	
cXML += A270Tag( 3,"ans:hash"	,cHash				 ,.T.,.T.,.T., .F. )

HMClean(oHashDP)
HMClean(oHashDesc)
return cXml

/*/{Protheus.doc} montRetDA2
Monta o corpo do retorno do demonstrativo de análise de conta em formato json
@author Oscar
@since 08/02/2019
@version 1.0
/*/
Static function montRetDA2( cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, cCnes, aProtoc, aDadPEG, lPortal, cCpfCnpjR )
Local cJson := ""
Local cDataAtu := DtoS(DatE())
Local nI := 1
local aSomaGui := {0, 0, 0, 0}
Local nZ := 0
Local aSomatot := {0, 0, 0, 0}
Local nIni	:= 1
Local cguiAtu := ""
Local cGloTiss := ""
Local lBE4 := .F.
Local cOrimov := ""
Local nValGlo := 0
Local nOk := 0
Local lExitPeg := .F.
Local aSomaGer := {0, 0, 0, 0}
local cNumProt := ""
local cSenha   := ""
local cNumImp  := ""
local nGui 	   := 1
local nProc    := 1
local nGuiProc   := 1
local oJson
local oJsonGen // objeto generico utilizado durante a inclusão das informações
local aJsonPeg  := {} // dados do protocolo
local aJsonGuia := {} // dados da guia
local aJsonProc := {} // dados dos procedimentos
local cDataIniZ := ""
local cDataFimZ := ""
local nProcGlo  := 1
local nArrGlo 	:= 1
local aJsonGlos := {} // glosas do procedimento
local aProced := {}
Local cNomsocial := ""

//Pesquisa hash
local oHashDP   := HMNew()
local oHashDesc   := HMNew()

Private nArqHash := 0

Default cCnes := '9999999'
default cCpfCnpjR := ""

BDX->(DbSetOrder(4))
//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN+BDX_CODPAD+BDX_CODPRO+BDX_TIPGLO
BD7->(DbSetOrder(1))
BA1->(DbsetOrder(2))
// objeto json que vai possuir todas as informações
oJson := JsonObject():new()

// cabecalho
oJson['cabecalho'] := JsonObject():new()

// identificacaoTransacao
oJsonGen := JsonObject():new()
oJsonGen['tipoTransacao'] := "DEMONSTRATIVO_ANALISE_CONTA"
oJsonGen['sequencialTransacao'] := cSeqTran
oJsonGen['dataRegistroTransacao'] := substr(cDataAtu, 1, 4) + '-' + substr(cDataAtu, 5, 2) + '-' + substr(cDataAtu, 7, 2)
oJsonGen['tipoTransacao'] := time()

oJson['cabecalho']['identificacaoTransacao'] := oJsonGen
// -identificacaoTransacao

// origem
oJsonGen := JsonObject():new()
oJsonGen['registroANS'] := cRegANSOpe

oJson['cabecalho']['origem'] := oJsonGen
// -origem

// destino
oJsonGen := JsonObject():new()
oJsonGen['identificacaoPrestador'] := JsonObject():new()
oJsonGen['identificacaoPrestador']['codigoPrestadorNaOperadora'] := cCodRDA

oJson['cabecalho']['destino'] := oJsonGen
// -destino

// Padrao
oJson['cabecalho']['Padrao'] := "3.03.03"
// -Padrao

// -cabecalho

// demonstrativoRetorno / demonstrativoAnaliseConta
oJson['demonstrativoRetorno'] := JsonObject():new()
oJson['demonstrativoRetorno']['demonstrativoAnaliseConta'] := JsonObject():new()

// cabecalhoDemonstrativo
oJsonGen := JsonObject():new()
oJsonGen['registroANS'] := cRegANSOpe
oJsonGen['numeroDemonstrativo'] := cDataAtu + cSeqTran 
oJsonGen['nomeOperadora'] := allTrim(cNomeOpe)
oJsonGen['numeroCNPJ'] := cCNPJOpe
oJsonGen['dataEmissao'] := substr(cDataAtu, 1, 4) + '-' + substr(cDataAtu, 5, 2) + '-' + substr(cDataAtu, 7, 2)

oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['cabecalhoDemonstrativo'] := oJsonGen
// -cabecalhoDemonstrativo

// dadosPrestador
oJsonGen := JsonObject():new()
oJsonGen['codigoPrestadorNaOperadora'] := cCodRDA
oJsonGen['nomeContratado'] := Alltrim(cNomeRDA)

oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['dadosPrestador'] := JsonObject():new()
oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['dadosPrestador']['dadosContratado'] := oJsonGen

// CNES
oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['dadosPrestador']['CNES'] := cCnes
// -CNES

// -dadosPrestador

for nI := 1 To Len(aProtoc)
	
	BCI->(dbSetOrder(14))
	If ! BCI->(Msseek( xfilial("BCI") + aProtoc[nI])) .OR. BCI->BCI_CODRDA != cCodRDA //Sem protocolo, sem relatório
		Loop
	endIf
	nOk++

	// dadosProtocolo
	aadd(aJsonPeg, JsonObject():new())
	oJsonGen := JsonObject():new()

	If !(EmpTy(BCI->BCI_LOTGUI))
		cNumProt := BCI->BCI_LOTGUI
	elseIf !(EmpTy(BCI->BCI_IDXML))
		cNumProt := BCI->BCI_IDXML
	else
		cNumProt := aProtoc[nI]
	endIf
	
	aJsonPeg[nI]['numeroLotePrestador'] := cNumProt	
	cNumProt := ""
	aJsonPeg[nI]['numeroProtocolo'] := BCI->BCI_CODPEG
	cData := DtoS(BCI->BCI_DTDIGI)
	aJsonPeg[nI]['dataProtocolo'] := substr(cData, 1, 4) + '-' + substr(cData, 5, 2) + '-' + substr(cData, 7, 2)

	If !(empTy(BCI->BCI_CODGLO))
		cGloTiss := deParaSimpl("38", BCI->BCI_CODGLO, "BCT",@oHashDP)
		if(empty(allTrim(cGloTiss)))
			cGloTiss := retCodGlo(BCI->BCI_CODOPE, BCI->BCI_CODGLO)
		endif
		aJsonPeg[nI]['GlosaProtocolo'] := JsonObject():new()
		aJsonPeg[nI]['GlosaProtocolo']['codigoGlosa'] := cGloTiss
		aJsonPeg[nI]['GlosaProtocolo']['descricaoGlosa'] := descTissSp("38", cGloTiss,,@oHashDesc)
	endIf

	aJsonPeg[nI]['situacaoProtocolo'] := BCI->BCI_STTISS	

	nGui := 1
	for nZ := nIni To Len(aDadPEG)
		cGuiAtu := aDadPEG[nZ][1] + aDadPEG[nZ][2]
		cSenha  := ""
		cNumImp := ""
		cNomsocial := ""

		if BCI->BCI_TIPGUI != "05"
			BD5->(DbSetOrder(2))
			BD5->(MsSeek(xFilial("BD5")+aDadPEG[nZ][5]+aDadPEG[nZ][19]+aDadPEG[nZ][1]+aDadPEG[nZ][2]))
			cSenha  := BD5->BD5_SENHA
			cNumImp := BD5->BD5_NUMIMP
		else
			BE4->(DbSetOrder(1))
			BE4->(MsSeek(xFilial("BE4")+aDadPEG[nZ][5]+aDadPEG[nZ][19]+aDadPEG[nZ][1]+aDadPEG[nZ][2]))
			cSenha  := BE4->BE4_SENHA
			cNumImp := BE4->BE4_NUMIMP
		endif

		// relacaoGuias
		aadd(aJsonGuia,{})
		aadd(aJsonGuia[nI],JsonObject():new())

		if BA1->(MsSeek(xFilial("BA1") + aDadPEG[nZ][5]+aDadPEG[nZ][6]+aDadPEG[nZ][7]+aDadPEG[nZ][8]+aDadPEG[nZ][9]))
			cNomsocial := BA1->BA1_NOMSOC
		endif
		aJsonGuia[nI][nGui]['numeroGuiaPrestador'] := Alltrim(iif(!empty(cNumImp),cNumImp,aDadPEG[nZ][1]+aDadPEG[nZ][2]))
		aJsonGuia[nI][nGui]['numeroGuiaOperadora'] := Alltrim(aDadPEG[nZ][1]+aDadPEG[nZ][2])
		aJsonGuia[nI][nGui]['senha'] := Alltrim(cSenha)
		aJsonGuia[nI][nGui]['nomeBeneficiario'] := allTrim(aDadPEG[nZ][4])
		aJsonGuia[nI][nGui]['numeroCarteira'] := aDadPEG[nZ][5]+aDadPEG[nZ][6]+aDadPEG[nZ][7]+aDadPEG[nZ][8]+aDadPEG[nZ][9]
		aJsonGuia[nI][nGui]['nomeSocial'] := allTrim(cNomsocial)

		If BCI->BCI_TIPGUI == "05"
			BE4->(dbSetOrder(1))
			If BE4->(MsSeek(xfilial("BE4") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2]))
				cDataIniZ := ""
				cDataFimZ := ""
				
				If !(EmpTy(BE4->BE4_DTINIF))
					cDataIniZ := DtoS(BE4->BE4_DTINIF)
					aJsonGuia[nI][nGui]['dataInicioFat'] := substr(cDataIniZ, 1, 4) + '-' + substr(cDataIniZ, 5, 2) + '-' + substr(cDataIniZ, 7, 2)
				endif
				
				aJsonGuia[nI][nGui]['horaInicioFat'] := MskHoraZ(BE4->BE4_HRINIF)
												
				If !(EmpTy(BE4->BE4_DTFIMF))
					cDataFimZ := DtoS(BE4->BE4_DTFIMF)
					aJsonGuia[nI][nGui]['dataFimFat'] := substr(cDataFimZ, 1, 4) + '-' + substr(cDataFimZ, 5, 2) + '-' + substr(cDataFimZ, 7, 2)					
				endIf

				aJsonGuia[nI][nGui]['horaFimFat'] := MskHoraZ(BE4->BE4_HRFIMF)								
				
				lBE4 := .T.
				cOrimov := BE4->BE4_ORIMOV
			endIf
		else
			BD5->(DbSetOrder(1))
			BD5->(MsSeek(xfilial("BD5") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2]))
			cOrimov := BD5->BD5_ORIMOV
			cDataIniZ := ""
			cDataIniZ := PlDataProc(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, aDadPEG[nZ][2])[1,1] //menor data
			aJsonGuia[nI][nGui]['dataInicioFat'] := substr(cDataIniZ, 1, 4) + '-' + substr(cDataIniZ, 5, 2) + '-' + substr(cDataIniZ, 7, 2)
		endIf
		
		If (lBE4 .AND. !(empTy(BE4->BE4_CODGLO))) .OR. (!lBE4 .AND. !(empTy(BD5->BD5_CODGLO)))
			cGloTiss := deParaSimpl("38", IIF(lBE4, BE4->BE4_CODGLO, BD5->BD5_CODGLO), "BCT",@oHashDP)
			if(empty(allTrim(cGloTiss)))
				cGloTiss := retCodGlo(BCI->BCI_CODOPE, IIF(lBE4, BE4->BE4_CODGLO, BD5->BD5_CODGLO))
			endif
			aJsonGuia[nI][nGui]['motivoGlosaGuia'] := JsonObject():new()
			aJsonGuia[nI][nGui]['motivoGlosaGuia']['codigoGlosa'] := cGloTiss
			aJsonGuia[nI][nGui]['motivoGlosaGuia']['descricaoGlosa'] := descTissSp("38", cGloTiss, "BCT",@oHashDesc)
		endIF

		aJsonGuia[nI][nGui]['situacaoGuia'] := BCI->BCI_STTISS

		nProc := 1				
		While nZ <= Len(aDadPEG)
			
			// detalhesGuia			
			aadd(aJsonProc,{})
			aadd(aJsonProc[nGuiProc],JsonObject():new())
//			cCodPadtiss := deParaSimpl("87", aDadPEG[nZ][11], "BR4",@oHashDP)
			
			aJsonProc[nGuiProc][nProc]['dataRealizacao'] := substr(aDadPEG[nZ][10], 1, 4) + '-' + substr(aDadPEG[nZ][10], 5, 2) + '-' + substr(aDadPEG[nZ][10], 7, 2)
			
			aProced	:= deParaSimpl(nil,nil,nil,@oHashDP,.T.,{aDadPEG[nZ][11],aDadPEG[nZ][12]}) 

			// procedimento
			aJsonProc[nGuiProc][nProc]['procedimento'] := JsonObject():new()
			aJsonProc[nGuiProc][nProc]['procedimento']['codigoTabela'] := alltrim(aProced[2])
			aJsonProc[nGuiProc][nProc]['procedimento']['codigoProcedimento'] := alltrim(aProced[3])//allTrim(deParaSimpl(cCodPadtiss, aDadPEG[nZ][12], "BR8",@oHashDP))
			aJsonProc[nGuiProc][nProc]['procedimento']['descricaoProcedimento'] := allTrim(descTissSp(aProced[2], aProced[3],,@oHashDesc))
			// -procedimento			
					
			If BCI->BCI_TIPGUI == "06"
				If BD7->(MsSeek( xfilial("BD7") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3] ))
					while !(BD7->(eoF())) .AND. BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3] == BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEg+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
						If !(empTy(BD7->BD7_CODTPA))
							aJsonProc[nGuiProc][nProc]['grauParticipacao'] := deParaSimpl("35", AllTrim(BD7->BD7_CODTPA), "BWT",@oHashDP)												
						endIf
						BD7->(Dbskip())
					endDo
				EndIf
			endIf

			aJsonProc[nGuiProc][nProc]['valorInformado'] := allTrim(Str(aDadPEG[nZ][13]))
			aJsonProc[nGuiProc][nProc]['qtdExecutada'] := allTrim(Str(aDadPEG[nZ][15]))
			aJsonProc[nGuiProc][nProc]['valorProcessado'] := allTrim(Str(aDadPEG[nZ][16]))
			aJsonProc[nGuiProc][nProc]['valorLiberado'] := allTrim(Str(aDadPEG[nZ][17]))

			//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN
			If aDadPEG[nZ][18] > 0				
				If BDX->(MsSeek( xFilial("BDX") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3]))
					nProcGlo := 1

					While BDX->(BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN) == BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + aDadPEG[nZ][2] + cOrimov + aDadPEG[nZ][3] .AND. !(BDX->(eoF()))
						If BDX->BDX_TIPREG == "1"
							// relacaoGlosa
							aadd(aJsonGlos,{})
							aadd(aJsonGlos[nArrGlo],JsonObject():new())
							aJsonGlos[nArrGlo][nProcGlo]['relacaoGlosa'] := JsonObject():new()
														
							nValGlo := aDadPEG[nZ][18]
							aJsonGlos[nArrGlo][nProcGlo]['relacaoGlosa']['valorGlosa'] := allTrim(Str(nValGlo))
							
							cGloTiss := ""
							cGloTiss := deParaSimpl("38", BDX->BDX_CODGLO, "BCT",@oHashDP)
							if(empty(allTrim(cGloTiss)))
								cGloTiss := retCodGlo(BDX->BDX_CODOPE, BDX->BDX_CODGLO)
							endif
							aJsonGlos[nArrGlo][nProcGlo]['relacaoGlosa']['tipoGlosa'] := allTrim(cGloTiss)
													
							// -relacaoGlosa

							nProcGlo++
						endIf
						BDX->(Dbskip())
					EndDo
					aJsonProc[nGuiProc][nProc]['relacaoGlosas'] := aJsonGlos[nArrGlo]
					nArrGlo++
				EndIf
				
			EndIf		
				
			
			aSomaGui[1] += aDadPEG[nZ][13] //apr
			aSomaGui[2] += aDadPEG[nZ][16] //man
			aSomaGui[3] += aDadPEG[nZ][17] //pag
			aSomaGui[4] += aDadPEG[nZ][18] //glo
			nValGlo := 0			
			
			If nZ == Len(aDadPEG) .OR. aDadPEG[nZ][1] != aDadPEG[nZ+1][1]
				lExitPeg := .T.
			EndIf
			If nZ == Len(aDadPEG) .OR. aDadPEG[nZ][1] + aDadPEG[nZ][2] != aDadPEG[nZ+1][1] + aDadPEG[nZ+1][2]
				Exit				
			EndIf
			
			nZ++
			nProc++
		EndDo

		
		aJsonGuia[nI][nGui]['detalhesGuia'] := aJsonProc[nGuiProc]		
		// -detalhesGuia

		aJsonGuia[nI][nGui]['valorInformadoGuia'] := allTrim(Str(aSomaGui[1]))
		aJsonGuia[nI][nGui]['valorProcessadoGuia'] := allTrim(Str(aSomaGui[2]))
		aJsonGuia[nI][nGui]['valorLiberadoGuia'] := allTrim(Str(aSomaGui[3]))
		aJsonGuia[nI][nGui]['valorGlosaGuia'] := allTrim(Str(aSomaGui[4]))

		nIni := nZ + 1
		aSomatot[1] += aSomaGui[1]
		aSomatot[2] += aSomaGui[2]
		aSomatot[3] += aSomaGui[3]
		aSomatot[4] += aSomaGui[4]
		aSomaGui := {0, 0, 0, 0}

		nGuiProc++
		nGui++
		if lExitPeg
			Exit
		endIf 
	next
	
	aJsonPeg[nI]['relacaoGuias'] := aJsonGuia[nI]
	// -relacaoGuias
	
	lExitPeg := .F.

	aJsonPeg[nI]['valorInformadoProtocolo'] := allTrim(Str(aSomatot[1]))
	aJsonPeg[nI]['valorProcessadoProtocolo'] := allTrim(Str(aSomatot[2]))
	aJsonPeg[nI]['valorLiberadoProtocolo'] := allTrim(Str(aSomatot[3]))
	aJsonPeg[nI]['valorGlosaProtocolo'] := allTrim(Str(aSomatot[4]))
	// -dadosProtocolo	

	aSomaGer[1] += aSomatot[1]
	aSomaGer[2] += aSomatot[2]
	aSomaGer[3] += aSomatot[3]
	aSomaGer[4] += aSomatot[4]
	
	aSomatot := {0, 0, 0, 0}
	
next

oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['dadosConta'] := JsonObject():new()
oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['dadosConta']['dadosProtocolo'] := aJsonPeg
// -dadosConta

oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['valorInformadoGeral'] := allTrim(Str(aSomaGer[1]))
oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['valorProcessadoGeral'] := allTrim(Str(aSomaGer[2]))
oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['valorLiberadoGeral'] := allTrim(Str(aSomaGer[3]))
oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['valorGlosaGeral'] := allTrim(Str(aSomaGer[4]))


If nOk == 0
	oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['mensagemErro'] := JsonObject():new()
	oJson['demonstrativoRetorno']['demonstrativoAnaliseConta']['mensagemErro']['codigoGlosa'] := "1323"
endIf

//-demonstrativoRetorno/demonstrativoAnaliseConta

// converte o objeto json em string para retornar
cJson := oJson:toJson()

HMClean(oHashDP)
HMClean(oHashDesc)
return cJson

//-------------------------------------------------------
/*/{Protheus.doc} QDemoPagCD
Situacao do Protocolo
@author Eduardo Bento
@since 03.02.20
@version 1.0
/*///-----------------------------------------------------
Function QDemoPagCD(lPordata,cdatPag,cCompeten,cCodRDA)

local cSql		 := ""
local adadDebCre := {}
default lPordata 	:= .F.
default cdatPag	 	:= ""
default cCompeten	:= ""
default cCodRDA		:= ""

cSql := " select DISTINCT BGQ_CODSEQ, BGQ_VALOR P, BGQ_TIPO T, BGQ_CODLAN C, E2_VENCREA V "
cSql += " from " + RetsqlName("BGQ") + " BGQ "
cSql += " Inner join " + retSqlName("SE2") + " E2 "
cSql += " On "
cSql += " E2_FILIAL = '" + xfilial("SE2") + "' "
cSql += " AND E2_PLOPELT = BGQ_CODOPE "
csql += " AND ( E2_CODRDA = BGQ_CODIGO OR E2_CODRDA = '      ') "
cSql += " AND E2_PLLOTE = BGQ_NUMLOT " 
If lPordata
	cSql += " AND (E2_VENCREA = '"  + allTrim(StrTran(cdatPag, "-", "")) + "' "
	cSql += "      OR E2_BAIXA = '" + allTrim(StrTran(cdatPag, "-", "")) + "') "
else
	cSql += " AND E2_VENCREA >= '" + allTrim(cCompeten) + "01" + "' "
	cSql += " AND E2_VENCREA <= '" + allTrim(cCompeten) + "31" + "' "
endIf
cSql += " AND E2.D_E_L_E_T_ = ' ' "
cSql += " Where "
cSql += " BGQ_FILIAL = '" + xfilial("BGQ") + "' "
cSql += " AND BGQ_CODIGO =  '" + cCodRDA + "' "
cSql += " AND BGQ_NUMLOT <> ' ' "
cSql += " AND BGQ_TIPO <> '3' "
cSql += " AND BGQ.D_E_L_E_T_ = ' ' "
cSql += " Order By "
cSql += " E2_VENCREA "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"DemoPagCD",.F.,.T.)

While !(DemoPagCD->(EoF()))
	aadd(adadDebCre, { DemoPagCD->(P), DemoPagCD->(T), DemoPagCD->(C), DemoPagCD->(V) })

	DemoPagCD->(dbskip())
EndDo

DemoPagCD->(DbCloseArea())

Return adadDebCre

//-------------------------------------------------------
/*/{Protheus.doc} QDemoPag
Retorna valores referentes a demonstração de pagamento
@author Eduardo Bento
@since 03.02.20
@version 1.0
/*///-----------------------------------------------------
Function QDemoPag(lPordata,cdatPag,cCompeten,cCodRDA)

local cSql		:= ""
local adadPag	:= {}
local cPEGinSql := ""
default lPordata 	:= .F.
default cdatPag	 	:= ""
default cCompeten	:= ""
default cCodRDA		:= ""

BAU->(DbSetOrder(1))
BAU->(MsSeek(xFilial("BAU") + alltrim(cCodRDA)))

if BAU->BAU_CALIMP == "1"
	// pesquisa pelos valores faturados da SE2 e BD7 
	cSql += " SELECT Sum(BD7_VALORI) A, SUM(BD7_VLRMAN) M, Sum(BD7_VLRPAG) P, Sum(BD7_VLRGLO)+Sum(BD7_VLRGTX) G, "
	cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, SUM(E2_IRRF) / count(1) IR, SUM(E2_ISS) / count(1) ISS, SUM(E2_INSS) / count(1) INSS, "
	cSql += " SUM(E2_PIS) / count(1) PIS, SUM(E2_COFINS) / count(1) COF, E2_NUM, SUM(E2_CSLL) / count(1) CSLL, E2_BAIXA DTBAIXA "
	cSql += " from " + retSqlName("SE2") + " E2 "

	cSql += " INNER JOIN " + retSqlName("SD1") + " SD1 "
	cSql += " ON D1_FILIAL = '" + xFilial("SD1") + "' "
	cSql += " AND D1_DOC   = E2_NUM "
	cSql += " AND D1_FORNECE = E2_FORNECE "
	cSql += " AND D1_LOJA    = E2_LOJA "
	cSql += " AND SD1.D_E_L_E_T_ = ' ' "

	cSql += " INNER JOIN " + retSqlName("SC7") + " SC7 "
	cSql += " ON C7_FILIAL  = '" + xFilial("SC7") + "' "
	cSql += " AND C7_NUM    = D1_PEDIDO "
	cSql += " AND C7_ITEM   = D1_ITEMPC "
	cSql += " AND SC7.D_E_L_E_T_ = ' ' "

	cSql += " INNER JOIN " + retSqlName("BD7") + " BD7  "
	cSql += " ON BD7_FILIAL  = '" + xFilial("BD7") + "' "
	cSql += " AND BD7_CODOPE = C7_PLOPELT "
	cSql += " AND BD7_OPELOT = C7_PLOPELT "
	cSql += " AND BD7_NUMLOT = C7_LOTPLS "
	cSql += " AND BD7_CODRDA = C7_CODRDA "
	cSql += " AND BD7.D_E_L_E_T_ = ' ' "

	cSql += " INNER JOIN " + retSqlName("BR8") + " BR8 "
	cSql += " ON BR8_FILIAL  = '" + xFilial("BR8") + "' "
	cSql += " AND BR8_CODPAD = BD7_CODPAD "
	cSql += " AND BR8_CODPSA = BD7_CODPRO "
	cSql += " AND BR8_ODONTO != '1' "
	cSql += " AND BR8.D_E_L_E_T_ = ' ' "
	cSql += " Where "
	cSql += " E2_FILIAL = '" + xfilial("SE2") + "' "
	If lPordata
		cSql += " AND (E2_VENCREA = '"  + allTrim(StrTran(cdatPag, "-", "")) + "' "
		cSql += "      OR E2_BAIXA = '" + allTrim(StrTran(cdatPag, "-", "")) + "') "
	else
		cSql += " AND E2_VENCREA >= '" + allTrim(cCompeten) + "01" + "' "
		cSql += " AND E2_VENCREA <= '" + allTrim(cCompeten) + "31" + "' "
	endIf
	cSql += " AND E2_CODRDA = '" + cCodRDA + "' "
	cSql += " AND E2.D_E_L_E_T_ =  ' ' "
	cSql += " Group By "
	cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, E2_NUM, E2_BAIXA "
	cSql += " Order By "
	cSql += " E2_VENCREA, E2_NUM "

else
	// pesquisa pelo título(SE2) vinculado a BD7 faturada através do BD7_CHKSE2
	cSql += " SELECT Sum(BD7_VALORI) A, SUM(BD7_VLRMAN) M, Sum(BD7_VLRPAG) P, Sum(BD7_VLRGLO)+Sum(BD7_VLRGTX) G, "
	cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, SUM(E2_IRRF) / count(1) IR, SUM(E2_ISS) / count(1) ISS, SUM(E2_INSS) / count(1) INSS, "
	cSql += " SUM(E2_PIS) / count(1) PIS, SUM(E2_COFINS) / count(1) COF, E2_NUM, SUM(E2_CSLL) / count(1) CSLL, E2_BAIXA DTBAIXA "
	cSql += " from " + retSqlName("SE2") + " E2 "
	cSql += " Inner join " + RetSqlName("BD7") + " BD7 "
	cSql += " On "
	cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
	cSql += " BD7_CHKSE2 = E2_FILIAL || '|' || E2_PREFIXO || '|' || E2_NUM || '|' || E2_PARCELA || '|' || E2_TIPO || '|' || E2_FORNECE || '|' || E2_LOJA AND "
	cSql += " BD7_CODRDA = '" + cCodRDA + "' AND "
	csql += " BD7.D_E_L_E_T_ =  ' ' "
	cSql += " Inner Join " + RetsqlName('BR8') + " BR8 "
	csql += " On "
	cSql += " BR8_FILIAL = '" + xFilial("BR8") + "' AND "
	cSql += " BR8_CODPAD = BD7_CODPAD AND "
	csql += " BR8_CODPSA = BD7_CODPRO AND "
	csql += " BR8_ODONTO != '1' AND "
	cSql += " BR8.D_E_L_E_T_ =  ' ' "
	cSql += " Where "
	cSql += " E2_FILIAL = '" + xfilial("SE2") + "' "
	If lPordata
		cSql += " AND (E2_VENCREA = '"  + allTrim(StrTran(cdatPag, "-", "")) + "' "
		cSql += "      OR E2_BAIXA = '" + allTrim(StrTran(cdatPag, "-", "")) + "') "
	else
		cSql += " AND E2_VENCREA >= '" + allTrim(cCompeten) + "01" + "' "
		cSql += " AND E2_VENCREA <= '" + allTrim(cCompeten) + "31" + "' "
	endIf
	cSql += " AND E2_CODRDA = '" + cCodRDA + "' "
	cSql += " AND E2.D_E_L_E_T_ =  ' ' "
	cSql += " Group By "
	cSql += " BD7_DTDIGI, BD7_CODPEG, E2_VENCREA, E2_NUM, E2_BAIXA "
	cSql += " Order By "
	cSql += " E2_VENCREA, E2_NUM "
endif

if ExistBlock("PLQRYTISS")
	cSql := ExecBlock("PLQRYTISS",.F.,.F.,{"1", cSql, cCodRDA, cdatPag, cCompeten, cPEGinSql })
endif
		 
dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"DemoPag",.F.,.T.)

While !(DemoPag->(EoF()))
	aadd(adadPag, { round(DemoPag->(A),2), round(DemoPag->(M),2), Round(DemoPag->(P),2), Round(DemoPag->(G),2), DemoPag->(BD7_DTDIGI), DemoPag->(BD7_CODPEG), DemoPag->(E2_VENCREA), round(DemoPag->(IR),2),;
					 round(DemoPag->(ISS),2), round(DemoPag->(INSS),2), Round(DemoPag->(PIS),2), round(DemoPag->(COF),2), round(DemoPag->(CSLL), 2), DemoPag->E2_NUM, DemoPag->DTBAIXA })
	DemoPag->(dbskip())
EndDo

DemoPag->(DbCloseArea())

Return adadPag

//-------------------------------------------------------
/*/{Protheus.doc} retNumLote
Retorna numero do lote
@author Eduardo Bento
@since 05.02.20
@version 1.0
/*///-----------------------------------------------------
function retNumLote(cCodpeg)
local cNumProt := ""
default cCodpeg:= ""

BCI->(DbsetOrder(14))
If BCI->(MsSeek(xFilial("BCI") + cCodpeg))
	If !(EmpTy(BCI->BCI_LOTGUI))
		cNumProt := BCI->BCI_LOTGUI
	elseIf !(EmpTy(BCI->BCI_IDXML))
		cNumProt := BCI->BCI_IDXML
	else
		cNumProt := cCodpeg
	endIf
else
	cNumProt := cCodpeg
endIf

Return cNumProt


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkProtBlq

@author    PLS TEAM
@version   1.xx
@since     05/10/2018
/*/
static function ChkProtBlq(cProtoc)
Local lRet := .T.
Local csql := ""

csql += " Select 1 From " + RetSqlName("BCI") + " BCI "
csql += " Where "
cSql += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
cSql += " BCI_CODPEG = '" + cProtoc + "' AND "
csql += " BCI_SITUAC = '2' AND "
csql += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,(cSQL)),"chkBlqPrt",.F.,.T.)

lRet := chkBlqPrt->(eoF())

chkBlqPrt->(dbclosearea())
return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLStaReGlo
Retorno da Solicitação de Status de Recurso de Glosa via WS
@since 07/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLStaReGlo()

Local cRet 			:= ""
Local cSeqTran 		:= ""
Local cCodRDA 		:= ""
Local cCPFCNPJR 	:= ""
Local cRegANSOpe 	:= ""
local cCodope		:= ""
Local cNomeOpe 		:= ""
local cCNPJOpe 		:= ""
Local cNomeRDA 		:= ""
local cXml      	:= HttpOtherContent()
Local oXml 			:= nil
Local cSoapXML 		:= ""
Local aRetObj 		:= {}
Local cForPGt 		:= ""
Local cfornec 		:= ""
Local cPathLogin	:= ""
Local cLogin		:= ""
Local cSenha		:= ""
Local lMV_PLLGSN	:= GetNewPar("MV_PLLGSN", .F.)
Local aCritARQ		:= {.F., "", ""}
Local cVerArq		:= ""
Local cProtoc 		:= ""
Local lrecfind 		:= .F.
Local cStatProt 	:= ""
local aAreaB4D		:= BD4->(GetArea())
local aAreaBCI		:= BCI->(GetArea())

private cNS     	:= ""

cVerArq	:= Substr(cXml,At("Padrao>", cXml) + Len("Padrao>"),7)
	
HttpCtType( "text/xml; charset="+'UTF-8' )
	
if empty(cXml)
    return ProcOnLine("situacaoProtocoloRecurso")
endif 

aRetObj := VldWSRecS(cXml,"tissWebServicesV" + StrTran(cVerArq, ".", "_") + ".xsd")

If aRetObj[1]
	cSoapXML := aRetObj[3]
	
	oXML := TXmlManager():New()
	if empty(cNS)
		// Removo da tag loteGuiasWS os URL's pois estava dando falha no parse.
		nPos := At(">",Upper(cSoapXml))      
		cSoapPt1 := Substr(cSoapXml,1,nPos-1)
		cSoapPt2 := Substr(cSoapXml,nPos,len(cSoapXml))
		cSoapXml := "      <solicitacaoStatusRecursoGlosaWS" + cSoapPt2
	endif
	
	lRet := oXML:Parse(cSoapXml)

	if lRet 	
		aNS := oXML:XPathGetRootNsList()
		nPos := ascan(aNS,{|x| upper(alltrim(x[1])) == upper(cNS) })
		If nPos > 0
			oXML:XPathRegisterNs( aNS[ nPos ][ 1 ],aNS[ nPos ][ 2 ] )		
		EndIf
	EndIf
	
	cPathTag := addNS("/solicitacaoStatusRecursoGlosaWS/cabecalho")
	if( oXml:XPathHasNode( cPathTag ) )
	
		cSeqTran := oXML:XPathGetNodeValue( cPathTag + addNS("/identificacaoTransacao/sequencialTransacao"))
		
		If ( oXml:XPathHasNode( cPathTag + addNS("/origem/identificacaoPrestador/codigoPrestadorNaOperadora" )))
			cCodRDA := oXML:XPathGetNodeValue( cPathTag + addNS("/origem/identificacaoPrestador/codigoPrestadorNaOperadora" ))
			BAU->(DbSetOrder(1))
			If BAU->(MsSeek(xFilial("BAU") + alltrim(cCodRDA)))
				cNomeRDA := BAU->BAU_NOME
				cForPGt := BAU->BAU_FORPGT
				cfornec := BAU->BAU_CODSA2
			endIf
		else
			if( oXml:XPathHasNode( cPathTag + addNS("/origem/identificacaoPrestador/CNPJ" )))
				cCPFCNPJR := oXML:XPathGetNodeValue( cPathTag + addNS("/origem/identificacaoPrestador/CNPJ" ))
			elseif( oXml:XPathHasNode( cPathTag + addNS("/origem/identificacaoPrestador/CPF" )))
				cCPFCNPJR := oXML:XPathGetNodeValue( cPathTag + addNS("/origem/identificacaoPrestador/CPF" ))
			endif
			BAU->(dbSetOrder(4))
			If BAU->(MsSeek(xfilial("BAU") + alltrim(cCPFCNPJR)))
				cCodRDA := BAU->BAU_CODIGO
				cNomeRDA := BAU->BAU_NOME
				cForPGt := BAU->BAU_FORPGT
				cfornec := BAU->BAU_CODSA2
			EndIf
		endIf
		
		cRegANSOpe := oXML:XPathGetNodeValue( cPathTag + addNs("/destino/registroANS" ))
		
		BA0->(dbSetOrder(5))
		If BA0->(MsSeek(xfilial("BA0") + alltrim(cRegANSOpe)))
			cCodOpe := BA0->BA0_CODIDE + BA0->BA0_CODINT
			cNomeOpe := BA0->BA0_NOMINT
			cCNPJOpe := BA0->BA0_CGC
		EndIf
		
		If lMV_PLLGSN
			//3100	PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM
			//3111	CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO
			cPathLogin := cPathTag + addNs("/loginSenhaPrestador" )
			If ( oXml:XPathHasNode( cPathLogin ) )
				cLogin	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/loginPrestador" ))
				cSenha	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/senhaPrestador" ))
				BSW->(dbSetOrder(1))
				If BSW->(MsSeek(xfilial("BSW") + Upper(cLogin) + Space( tamsx3("BSW_LOGUSR")[1] - Len(cLogin) ) ))
					If !( cSenha == BSW->BSW_SENHA )
						//Senha inválida
						aCritARQ[1] := .T.
						aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"Senha inválida"
						aCritARQ[3] := "3111"
					endIF
				else
					//Login não existe -> login inválido
					aCritARQ[1] := .T.
					aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"login inválido"
					aCritARQ[3] := "3111"
				endIf
			else
				//Não foi enviada a tag
				aCritARQ[1] := .T.
				aCritARQ[2] := "PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM"//"Não foi enviada a tag"
				aCritARQ[3] := "3100"
			endIf
		endIf
	endif
	
	cPathTag := addNS("/solicitacaoStatusRecursoGlosaWS/solicitacaoStatusProtocoloRecurso")
	cProtoc := oXML:XPathGetNodeValue( cPathTag + addNS("/numeroProtocolo"))

else
	return "Erro ao carregar a mensagem: " + aRetObj[2] 
EndIf

If !(empty(cProtoc))
	B4D->(dBsetOrder(8)) //B4D_FILIAL+B4D_PROTOC
	B4D->(dbgotop())
	If B4D->(DbSeek(xfilial("B4D") + cProtoc))
		lrecfind := cCodRDA == B4D->B4D_CODRDA
		
		If lrecfind
			If B4D->B4D_STATUS == "1"
				cStatProt := "1"
			elseIF B4D->B4D_STATUS $ "0/2"
				cStatProt := "2"
			elseIf B4D->B4D_STATUS $ "3/5"
				cStatProt := "5"
				BCI->(dbsetOrder(1))
				IF BCI->(MsSeek(xfilial("BCI") + B4D->B4D_OPEMOV + B4D->B4D_DCDDLP + B4D->B4D_DCDPEG ))
					If BCI->BCI_STTISS == "6"
						cStatProt := "6"
					elseif BCI->BCI_STTISS == "3"
						cStatProt := "3"
					endIf
				endIf
			elseIf B4D->B4D_STATUS == "4"
				cStatProt := "4"
			endIf
		endIf
	endIf
endIf

/*
<!-- 1 - Recebido --> Protocolado ok
<!-- 2 - Em análise --> Protocolado ok
<!-- 3 - Liberado para pagamento --> Status acatado ou acatado parcialmente
<!-- 4 - Encerrado sem pagamento --> não acatado ok
<!-- 5 - Analisado e aguardando liberação para pagamento --> Status acatado ou acatado parcialmente
<!-- 6 - Pagamento Efetuado --> checar lote + chkse2
<!-- 7 - Não Localizado --> Protocolo errado + ou - ok
<!-- 8 - Aguardando informação complementar --> não temos 
*/
//		0=Rec Glosa Edição;1=Rec Glosa Protocolado;2=Rec Glosa Em Analise;3=Rec Glosa Autorizado;4=Rec Glosa Negado;5=Aut Parcial   

cRet += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#">'
cRet +=   '<soapenv:Header/>'
cRet +=   '<soapenv:Body>'
cRet +=      '<ans:situacaoProtocoloRecursoWS>'
cRet += 		montaRetSG( cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, cCpfCnpjR, lrecfind, cStatProt, cVerArq, aCritARQ )
cRet +=      '</ans:situacaoProtocoloRecursoWS>'
cRet +=   '</soapenv:Body>'
cRet += '</soapenv:Envelope>'

RestArea(aAreaBCI)
RestArea(aAreaB4D)
return cRet

static function VldWSRecS(cSoap,cSchema)
local cSoapAux   := ""   
local cMsg       := ""
local cErro      := ""
local cAviso     := ""
local cNameSpace := ""
local nPos       := 0
local nX         := 0
local lRet       := .T. 
Local nPos2		:= 0
Local cXmlns		:= ""
Local nPos1		:= 0

nPos := At("BODY",Upper(cSoap))
cSoapAux := Substr(cSoap,nPos+4,len(cSoap))    
nPos := At(">",Upper(cSoapAux))
cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))  

nPos := At("BODY",Upper(cSoapAux)) 
for nX := 1 to nPos 
	if Substr(cSoapAux,nPos-nX,1) == "<"
		cSoapAux := Substr(cSoapAux,1,nPos-(nX+1))
		Exit
	endif   
next

nPos1 := At("XMLNS",Upper(cSoap))
If nPos1 > 0
	nPos2 := At(">",Upper(cSoap),nPos1) 
	cXmlns := subString(cSoap, nPos1, nPos2 - nPos1)
	nPos1 := At(">",Upper(cSoapAux))
	cSoapPt1 := Substr(cSoapAux,1,nPos1-1)
	cSoapPt2 := Substr(cSoapAux,nPos1,len(cSoapAux))
	cSoapAux := cSoapPt1 + " " + cXmlns + cSoapPt2
endIf

if nPos == 0 .Or. empty(cSoap)
	cErro := "Erro com o pacote Soap recebido" 
endif

// Se houve erro fatal finaliza 
if !empty(cErro)
	return {.F.,cErro}
endif

nPos := At("SOLICITACAOSTATUSRECURSOGLOSAWS",Upper(cSoapAux))
If Substr(cSoapAux,nPos-1,1) == ":"
	nPosNamSpc := nPos-2
	For nX := 1 to nPosNamSpc
		If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"     
			cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
			cNS := cNameSpace
			Exit
		EndIf   
	next
EndIf

nPos := At("SOLICITACAOSTATUSRECURSOGLOSAWS",Upper(cSoapAux))
If Substr(cSoapAux,nPos-1,1) == ":"
	nPosNamSpc := nPos-2
	For nX := 1 to nPosNamSpc
		If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"     
			cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
			cNS := cNameSpace
			Exit
		EndIf   
	next
EndIf
// Monta texto para montagem do arquivo para validacao
cSoapXml := EncodeUTF8(cSoapAux)

// Faz a validacao do XML com o XSD
if !XmlSVldSch( cSoapXml, "\tiss\schemas\" + cSchema, @cErro,@cAviso)
	cMsg := Iif( !empty(cErro),"Erro: " +cErro,"") 
	cMsg += Iif( !empty(cAviso),"Aviso: "+cAviso,"") 
 	lRet := .F.
endif

return {lRet,cMsg,cSoapXml,cNameSpace}


Static function montaRetSG( cSeqTran, cRegANSOpe, cCodRDA, cNomeOpe, cCNPJOpe, cNomeRDA, cCpfCnpjR, lrecfind, cStatProt, cVerArq, aCritARQ )
Local cXML := ""
Local cDataAtu := DtoS(DatE())

Private nArqHash := 0

default cCpfCnpjR := ""

BCI->(DbsetOrder(14))

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" )

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML //"Não foi possível criar o diretorio no servidor:"
		Return(cRet)
	EndIf
EndIf

nArqHash := fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )

cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao" ,''						 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:tipoTransacao"			,'RESPOSTA_RECURSO_GLOSA' ,.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:sequencialTransacao"	,cSeqTran				 ,.T.,.T.,.T., .F. ) //Aqui pod entrar o B1R
cXML += A270Tag( 3,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:horaRegistroTransacao"	,time()				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	,''				 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:registroANS"	,cRegANSOpe				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:origem"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	,''				 ,.T.,.F.,.T., .F. )
cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''				 ,.T.,.F.,.T., .F. )

If Len(cCpfCnpjR) == 11 //CPF
	cXML += A270Tag( 4,"ans:CPF"				, cCpfCnpjR ,.T.,.T.,.T., .F. )
Elseif Len(cCpfCnpjR) == 14 //CNPJ
	cXML += A270Tag( 4,"ans:CNPJ"				, cCpfCnpjR ,.T.,.T.,.T., .F. )
else
	cXML += A270Tag( 4,"ans:codigoPrestadorNaOperadora"	, cCodRDA  ,.T.,.T.,.T., .F. )
EndIf

cXML += A270Tag( 3,"ans:identificacaoPrestador"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:destino"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 2,"ans:Padrao"	,cVerArq				 ,.T.,.T.,.T., .F. )
cXML += A270Tag( 1,"ans:cabecalho"	,''				 ,.F.,.T.,.T., .F. )
cXML += A270Tag( 3,"ans:situacaoProtocoloRecurso"	,''				 ,.T.,.F.,.T., .F. )

if aCritARQ[1]
	cXML += A270Tag( 3,"ans:mensagemErro"	,''				 			 ,.T.,.F.,.T., .F. )
    cXML += A270Tag( 4,"ans:codigoGlosa"	,aCritARQ[3]				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 4,"ans:descricaoGlosa"	,EncodeUTF8(aCritARQ[2])	 ,.T.,.T.,.T., .F. )
    cXML += A270Tag( 3,"ans:mensagemErro"	,''				 			 ,.F.,.T.,.T., .F. )

elseif lrecfind
	cXML += A270Tag( 4,"ans:reciboGlosaStatus"	,''		 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 5,"ans:nrProtocoloRecursoGlosa"	,B4D->B4D_PROTOC	 ,.T.,.T.,.T., .F. )

	cDataX := DtoS(B4D->B4D_DATSOL)
	cDataML := substr(cDataX, 1, 4) + "-" + substr(cDataX, 5, 2) + "-" + substr(cDataX, 7, 2)
	cXML += A270Tag( 5,"ans:dataEnvioRecurso"	,cDataML				 ,.T.,.T.,.T., .F. )

	cDataX := DtoS(B4D->B4D_DATREC)
	cDataML := substr(cDataX, 1, 4) + "-" + substr(cDataX, 5, 2) + "-" + substr(cDataX, 7, 2)
	cXML += A270Tag( 5,"ans:dataRecebimentoRecurso"	,cDataML				 ,.T.,.T.,.T., .F. )

	cXML += A270Tag( 5,"ans:numeroLote"	,B4D->B4D_CODPEG				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 5,"ans:registroANS"	,cRegANSOpe				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 6,"ans:dadosPrestador"	,''		 ,.T.,.F.,.T., .F. )
	cXML += A270Tag( 7,"ans:codigoPrestadorNaOperadora"	,cCodRDA				 ,.T.,.T.,.T., .F. )
	if cVerArq < "4.00.00"
		cXML += A270Tag( 7,"ans:nomeContratado"	,cNomeRDA				 ,.T.,.T.,.T., .F. )
	endif
	cXML += A270Tag( 6,"ans:dadosPrestador"	,''		 ,.F.,.T.,.T., .F. )
	
	cnumB1R := GetSXeNum("B1R","B1R_PROTOC")

	B1R->(recLock("B1R", .T.))
		B1R->B1R_FILIAL := xfilial("B1R")
		B1R->B1R_PROTOC := cnumB1R
		B1R->B1R_PROTOG := B4D->B4D_PROTOC
		B1R->B1R_STATUS := 'P'
	B1R->(MsUnLock())

	cXML += A270Tag( 5,"ans:nrProtocoloSituacaoRecursoGlosa"	,cnumB1R ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 5,"ans:dataSituacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2)	 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 5,"ans:situacaoProtocolo"	,cStatProt	 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 5,"ans:reciboGlosaStatus"	,''		 ,.F.,.T.,.T., .F. )
else	
	cXML += A270Tag( 3,"ans:mensagemErro"	,''				 ,.T.,.F.,.T., .F. )
    cXML += A270Tag( 4,"ans:codigoGlosa"	,'2906'				 ,.T.,.T.,.T., .F. )
	cXML += A270Tag( 4,"ans:descricaoGlosa"	,EncodeUTF8('Protocolo não encontrado')		 ,.T.,.T.,.T., .F. )
    cXML += A270Tag( 3,"ans:mensagemErro"	,''				 ,.F.,.T.,.T., .F. )
	lControl := .F.
endif

cXML += A270Tag( 3,"ans:situacaoProtocoloRecurso"	,''				 ,.F.,.T.,.T., .F. )

//--< Calculo e inclusao do HASH no arquivo >--					
fClose( nArqHash )
					
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
	
cXML += A270Tag( 3,"ans:hash"	,cHash				 ,.T.,.T.,.T., .F. )

return cXML

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PGetSeqTISS
Converte o soma1 para numérico(BD6_SEQUEN)

@author    Lucas Nonato
@version   P12
@since     03/03/2020
/*/
function PGetSeqTISS()
local cRet as char
local cSql as char

cSql := " SELECT BX6_SQTISS FROM " + retSqlName("BX6") 
cSql += " WHERE BX6_FILIAL = '" + xfilial("BX6") + "' "
cSql += " AND BX6_CODOPE = '" + BD6->BD6_CODOPE + "' "
cSql += " AND BX6_CODLDP = '" + BD6->BD6_CODLDP + "' "
cSql += " AND BX6_CODPEG = '" + BD6->BD6_CODPEG + "' "
cSql += " AND BX6_NUMERO = '" + BD6->BD6_NUMERO + "' "
cSql += " AND BX6_ORIMOV = '" + BD6->BD6_ORIMOV + "' "
cSql += " AND BX6_SEQUEN = '" + BD6->BD6_SEQUEN + "' "
cSql += " AND BX6_SQTISS <> ' ' "
cSql += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TMPBX6',.F.,.T.)

if !TMPBX6->(eof()) 
	cRet :=  TMPBX6->BX6_SQTISS
else
	if BD6->BD6_SEQUEN > "999"
		cRet := strZero(PConvSoma1(BD6->BD6_SEQUEN),4)
	else
		cRet := '0'+BD6->BD6_SEQUEN
	endif
endif

TMPBX6->(dbclosearea())

return cRet


//-------------------------------------------------------
/*/{Protheus.doc} PlsRtCgloRet
Função que busca o código da glosa desejado para retorno, nos casos que tem dados de retorno dos demonstrativos. A crítica pode ser personalizada:
- Se passar 1234@Teste Crítica, será colocado direto essas informações. Caso informe o código BCT de uma crítica, faz o de/para.
- Se branco ou não existe parâmetro, retorna o código 5016 e o texto padrão
@since 08/21.
/*///----------------------------------------------------- 
static function PlsRtCgloRet()
local aTmpSepa	:= {}
local cCodGlo	:= ''
local cDescri	:= "SEM NENHUMA OCORRENCIA DE MOVIMENTO NA COMPETENCIA PARA ENVIO A ANS"
local cCodParam	:= GetNewPar("MV_PLCGDMR","5016")

if ("@" $ cCodParam)
	aTmpSepa := separa(cCodParam, "@")
	cCodGlo  := aTmpSepa[1]
	cDescri	 := aTmpSepa[2]
else 
	cCodGlo := deParaSimpl('38', cCodParam, 'BCT')
	cDescri := descTissSp('38', cCodGlo, cDescri)
endif

//Evita retorno em branco
iif(empty(cCodGlo),"5016",)
iif(empty(cDescri),"SEM NENHUMA OCORRENCIA DE MOVIMENTO NA COMPETENCIA PARA ENVIO A ANS",)

return ({cCodGlo,cDescri })

Static function PLDemoCab()
Local cret := ""

if BCI->BCI_TIPGUI == "05" //somente resumo
	BE4->(dbsetOrder(1))
//	BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO
	if BE4->(MsSeek(xfilial("BE4")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
		cret := "BE4"
	endif
else
	BD5->(dbSetOrder(1))
//	BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO
	if BD5->(MsSeek(xfilial("BD5")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
		cRet := "BD5"
	endif
endif

Return cret

Static function PLDemoWhi(cTabcab)
Local lRet := .F.

if cTabcab == "BE4"
	lRet := xfilial("BE4")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) == BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG)
else
	lRet := xfilial("BD5")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) == BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG)
endif

return lRet

Static function PLDemoSit(cTabcab)
Local lRet := .F.

if cTabcab == "BE4"
	lRet := BE4->BE4_SITUAC == "1"
else
	lRet := BD5->BD5_SITUAC == "1"
endif

return lRet

Static Function PLDemoSki(cTabcab)

if cTabcab == "BE4"
	BE4->(DbSkip())
else
	BD5->(dbskip())
endif

return

Static Function PLDemoDad(cTabcab)
Local aret := {"","","","",0,0,0}

if cTabcab == 'BE4'
	aRet[1] := IIF( empty(BE4->BE4_NUMIMP), BE4->(BE4_CODPEG+BE4_NUMERO), BE4->BE4_NUMIMP)
	aRet[2] := BE4->(BE4_CODPEG+BE4_NUMERO)
	aRet[3] := BE4->BE4_SENHA
	aRet[4] := "1" //nunca é recurso de glosa, por isso 1 fixo
	aRet[5] := BE4->BE4_VLRMAN
	aRet[6] := BE4->BE4_VLRPAG
	aRet[7] := BE4->BE4_VLRGLO
else
	aRet[1] := IIF(empty(BD5->BD5_NUMIMP), BD5->(BD5_CODPEG+BD5_NUMERO), BD5->BD5_NUMIMP)
	aRet[2] := BD5->(BD5_CODPEG+BD5_NUMERO)
	aRet[3] := BD5->BD5_SENHA
	aRet[4] := IIF( BD5->BD5_TIPGUI == "10", "2", "1") //2 significa recurso de glosa
	aRet[5] := BD5->BD5_VLRMAN
	aRet[6] := BD5->BD5_VLRPAG
	aRet[7] := BD5->BD5_VLRGLO
endif

return aRet

function PLDemoFun()

Local aRet := {}
Local aGui := {}
Local cCab := ""

cCab := PLDemoCab()
While PLDemoWhi(cCab)
	aGui := {}
	if PLDemoSit(cCab)
		aGui := PLDemoDad(cCab)
		aadd(aRet, aclone(aGui))
	endif
	PLDemoSki(cCab)
EndDo

return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLStaProtoc
Função "main" responsável pelo webservice de solicitação de status de protocolo 

@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

Function PLStaProto()

local cXml      	:= HttpOtherContent()
local cVerArq		:= ""
local aRetObj 		:= {}
Local aCritARQ		:= {.F., "", ""}
local cNumProtoc	:= ""
local cNomeContr 	:= ""
local cAliasGuia	:= ""
local cAliasSoma 	:= ""
local cLogin		:= ""
local cSenha 		:= ""
local cRet 			:= ""
local lMV_PLLGSN	:= GetNewPar("MV_PLLGSN", .F.)
local cNumB1R 		:= GetSXeNum("B1R","B1R_PROTOC")
local cOrigem		:= "" // PODE SER DO TIPO CNPJ, CPF OU COD DO PRESTADOR NA OPERADORA
local cRegisANS		:= ""
local valCpfCnpj	:= {}
local lProtval		:= .F.


private cNS     	:= ""

cVerArq	:= Substr(cXml,At("Padrao>", cXml) + Len("Padrao>"),7)

HttpCtType( "text/xml; charset="+'UTF-8' )

aRetObj := VldWSdemoP(cXml,"tissWebServicesV" + StrTran(cVerArq, ".", "_") + ".xsd")

If aRetObj[1]

	cSoapXML := aRetObj[3]
	oXML := TXmlManager():New()

	if empty(cNS)
		// Removo da tag loteGuiasWS os URL's pois estava dando falha no parse.
		nPos := At(">",Upper(cSoapXml))      
		cSoapPt1 := Substr(cSoapXml,1,nPos-1)
		cSoapPt2 := Substr(cSoapXml,nPos,len(cSoapXml))
		cSoapXml := "      <solicitacaoStatusProtocoloWS" + cSoapPt2
	endif
	
	lRet := oXML:Parse(cSoapXml)

	if lRet 	
		aNS := oXML:XPathGetRootNsList()
		nPos := ascan(aNS,{|x| upper(alltrim(x[1])) == upper(cNS) })
		If nPos > 0
			oXML:XPathRegisterNs( aNS[ nPos ][ 1 ],aNS[ nPos ][ 2 ] )		
		EndIf
	EndIf

	cPathTag := addNS("/solicitacaoStatusProtocoloWS")

	if( oXml:XPathHasNode( cPathTag ) )
		
		grvB1R(@cNumB1R,cSoapXml,"C") // GRAVA REQUEST NA B1R / STATUS "C" -> REQUEST RECEBIDO MAS AINDA NÃO PROCESSADO

		cNomeContr := oXML:XPathGetNodeValue( cPathTag + addNS("/solicitacaoStatusProtocolo/dadosPrestador/nomeContratado"))
		cNumProtoc := oXML:XPathGetNodeValue( cPathTag + addNS("/solicitacaoStatusProtocolo/numeroProtocolo"))
		cRegisANS  := oXML:XPathGetNodeValue( cPathTag + addNS("/cabecalho/destino/registroANS" ))

		if( oXml:XPathHasNode( cPathTag + addNS("/cabecalho/origem/identificacaoPrestador/CNPJ" )))
			cOrigem := oXML:XPathGetNodeValue( cPathTag + addNS("/cabecalho/origem/identificacaoPrestador/CNPJ" ))
		elseif( oXml:XPathHasNode( cPathTag + addNS("/cabecalho/origem/identificacaoPrestador/CPF" )))
			cOrigem := oXML:XPathGetNodeValue( cPathTag + addNS("/cabecalho/origem/identificacaoPrestador/CPF" ))
		elseif( oXml:XPathHasNode( cPathTag + addNS("/cabecalho/origem/identificacaoPrestador/codigoPrestadorNaOperadora" )))
			cOrigem := oXML:XPathGetNodeValue( cPathTag + addNS("/cabecalho/origem/identificacaoPrestador/codigoPrestadorNaOperadora" ))
		endif
		
		cAliasBCI  := QryStProto(cNumProtoc)

		if (cAliasBCI)->BCI_TIPGUI != "05" // caso o BCI_TIPGUI retornado for diferente de 5 pegar dos dados da bd5, caso não pegar da bd4 para montar o xml depois
			cAliasGuia := QryStBD5((cAliasBCI)->BCI_CODOPE,(cAliasBCI)->BCI_CODLDP,(cAliasBCI)->BCI_CODPEG)
			cAliasSoma := cAliasSum((cAliasBCI)->BCI_CODOPE,(cAliasBCI)->BCI_CODLDP,(cAliasBCI)->BCI_CODPEG,1)
		else
			cAliasGuia := QryStBE4((cAliasBCI)->BCI_CODOPE,(cAliasBCI)->BCI_CODLDP,(cAliasBCI)->BCI_CODPEG)
			cAliasSoma := cAliasSum((cAliasBCI)->BCI_CODOPE,(cAliasBCI)->BCI_CODLDP,(cAliasBCI)->BCI_CODPEG,2)
		endif 
	endif 

		If lMV_PLLGSN
			//3100	PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM
			//3111	CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO
			cPathLogin := cPathTag + addNs("/cabecalho/loginSenhaPrestador" )
			If ( oXml:XPathHasNode( cPathLogin ) )
				cLogin	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/loginPrestador" ))
				cSenha	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/senhaPrestador" ))
				BSW->(dbSetOrder(1))
				If BSW->(MsSeek(xfilial("BSW") + Upper(cLogin) + Space( tamsx3("BSW_LOGUSR")[1] - Len(cLogin) ) ))
					If !( cSenha == BSW->BSW_SENHA )
						//Senha inválida
						aCritARQ[1] := .T.
						aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"Senha inválida"
						aCritARQ[3] := "3111"
					endIF
				else
					//Login não existe -> login inválido
					aCritARQ[1] := .T.
					aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"login inválido"
					aCritARQ[3] := "3111"
				endIf
			else
				//Não foi enviada a tag
				aCritARQ[1] := .T.
				aCritARQ[2] := "PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM"//"Não foi enviada a tag"
				aCritARQ[3] := "3100"
			endIf
		endIf

	If !aCritARQ[1]
													//posição 1 = cCodRda, posição 2 = cCodope
		valCpfCnpj := vldCpfCnpj(cOrigem,cRegisANS) // valida se o cpf, cnpj ou codigoPrestadorNaOperadora existem (BAU), e se o registroANS existe (BA0)

		If PLSAliasEx("B1R")
			//Verificarmos a B1R pra ver qual o PEG do PLS, caso esse código seja o Protocolo da B1R
			B1R->(dbSetOrder(1))
			If B1R->(MsSeek(xfilial("B1R") + alltrim(cNumProtoc))) .AND. B1R->B1R_ORIGEM == alltrim(valCpfCnpj[1])
				cSqlXX := " Select BXX_CODPEG from " + RetsqlName("BXX")
				csqlXX += " Where "
				cSqlXX += " BXX_FILIAL = '" + xfilial("BXX") + "' AND "
				cSqlXX += " BXX_CODINT = '" + valCpfCnpj[2] + "' AND "
				cSqlXX += " BXX_PLSHAT = '" + B1R->B1R_PROTOG + "' AND "
				csqlXX += " BXX_CODRDA = '" + B1R->B1R_ORIGEM + "' AND "
				cSqlXX += " D_E_L_E_T_ = ' ' "
				
				dbUseArea(.T.,"TOPCONN",tcGenQry(,,(cSqlXX)),"PRSS",.F.,.T.)
		
				If !(PRSS->(EoF()))
					cNumProtoc := PRSS->BXX_CODPEG
					lProtval := .T.
				endIf
				
				PRSS->(dbcloseArea())
			endIf
		endIf
		
		If !lProtval
			cSqlXX := " Select R_E_C_N_O_ RECBCI from " + RetsqlName("BCI")
			csqlXX += " Where "
			cSqlXX += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
			cSqlXX += " BCI_CODOPE = '" + valCpfCnpj[2] + "' AND "
			cSqlXX += " BCI_CODPEG = '" + Alltrim(cNumProtoc) + "' AND "
			csqlXX += " BCI_CODRDA = '" + Alltrim(valCpfCnpj[1]) + "' AND "
			cSqlXX += " D_E_L_E_T_ = ' ' "
			
			dbUseArea(.T.,"TOPCONN",tcGenQry(,,(cSqlXX)),"PRSS",.F.,.T.)
			
			If !(PRSS->(EoF()))
				lProtval := .T.
			endIf
			PRSS->(dbcloseArea())
		endIf
		
		If !lProtval //PEG não existe
			//1713	FATURAMENTO INVÁLIDO
			aCritARQ[1] := .T.
			aCritARQ[2] := "FATURAMENTO INVALIDO"
			aCritARQ[3] := "1713"
		endIf
	endIf
  else
	return "Erro ao carregar a mensagem: " + aRetObj[2] 
EndIf

	If !aCritARQ[1]
		cRet := montaXmlSP(cAliasBCI, cAliasGuia,cAliasSoma,cNumB1R,cOrigem,cRegisANS,cVerArq,cNomeContr) // monta xml status de protoloco
	else 
		cRet := msgErro(aCritARQ[3],aCritARQ[2],cNumB1R,cOrigem,cRegisANS,cVerArq,"situacaoProtocoloWS","situacaoProtocolo","SITUACAO_PROTOCOLO")
	endif


	DbSelectArea('B1R')
	B1R->(DbSetOrder(1))
	If B1R->(DbSeek(xFilial('B1R') + cNumB1R))   // GRAVA RESPONSE NA B1R / STATUS "D" -> REQUEST RECEBIDO E PROCESSADO
    	RecLock('B1R', .F.)
		B1R->B1R_RESPON := cRet 
		B1R->B1R_STATUS	:= "D"
		B1R->(MsUnLock())
	endif 

return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryStProto
Posiciona na bci correta a partir do número de do número de protocolo passado no request 

@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

static Function QryStProto(cCodPeg)

local oFwQuery  := FWPreparedStatement():New()
local cSql 		:= ""
local cAlias 	:= ""

cSql := "SELECT BCI_STATUS,BCI_CODPEG,BCI_IDXML,BCI_DTDIGI,BCI_VLRGLO,BCI_TIPGUI,BCI_CODOPE,BCI_CODLDP "
cSql += "FROM " + RetSqlName("BCI") + " BCI "
cSql += "WHERE BCI_FILIAL = ? " 
cSql += "AND BCI_CODPEG = ? "
cSql += "AND  D_E_L_E_T_ = ? "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial("BCI"))
oFwQuery:SetString(2, cCodPeg)
oFwQuery:SetString(3, ' ')
cSql := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

return cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryStBD5
@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

static Function QryStBD5(cCodOpe,cCodLdp,cCodPeg)

local oFwQuery  := FWPreparedStatement():New()
local cSql      := ""
local cAlias 	:= ""


cSql := "SELECT BD5_NUMIMP NUMIMP, BD5_CODPEG CODPEG, BD5_NUMERO NUMERO, BD5_ATERNA ATENDIRN, BD5_CODOPE CODOPE, BD5_CODLDP CODLDP, " 
cSql += "BD5_OPEUSR OPEUSR, BD5_CODEMP CODEMP, BD5_MATRIC MATRIC, BD5_TIPREG TIPREG, BD5_DIGITO DIGITO, BD5_DATPRO DATPRO, BD5_VLRBPR VLRBPR, BD5_VLRGLO VLRGLO, BD5_VLRPAG VLRPAG "
cSql += "FROM " + RetSqlName("BD5") + " BD5 "
cSql += "WHERE BD5_FILIAL = ? "
cSql += "AND BD5_CODOPE = ? "
cSql += "AND BD5_CODLDP = ? " 
cSql += "AND BD5_CODPEG = ? "
cSql += "AND D_E_L_E_T_ = ? "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial("BD5"))
oFwQuery:SetString(2, cCodOpe)
oFwQuery:SetString(3, cCodLdp)
oFwQuery:SetString(4, cCodPeg)
oFwQuery:SetString(5, ' ')
cSql := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

return cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryStBE4
@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

static Function QryStBE4(cCodOpe,cCodLdp,cCodPeg)

local oFwQuery  := FWPreparedStatement():New()
local cSql 		:= ""
local cAlias 	:= ""

cSql := "SELECT BE4_NUMIMP NUMIMP, BE4_CODPEG CODPEG, BE4_NUMERO NUMERO, BE4_ATERNA ATENDIRN, BE4_CODOPE CODOPE, BE4_CODLDP CODLDP, " 	
cSql += "BE4_OPEUSR OPEUSR, BE4_CODEMP CODEMP, BE4_MATRIC MATRIC, BE4_TIPREG TIPREG, BE4_DIGITO DIGITO, BE4_DATPRO DATPRO, BE4_VLRBPR VLRBPR, BE4_VLRGLO VLRGLO, BE4_VLRPAG VLRPAG "
cSql += "FROM " + RetSqlName("BE4") + " BE4 "
cSql += "WHERE BE4_FILIAL = ? "
cSql += "AND BE4_CODOPE = ? "
cSql += "AND BE4_CODLDP = ? " 
cSql += "AND BE4_CODPEG = ? "
cSql += "AND D_E_L_E_T_ = ? "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial("BE4"))
oFwQuery:SetString(2, cCodOpe)
oFwQuery:SetString(3, cCodLdp)
oFwQuery:SetString(4, cCodPeg)
oFwQuery:SetString(5, ' ')
cSql := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

return cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} cAliasSum

Soma dos valores dos campos de procedimento e valor pago, dependendo do tipo de guia pegando da BD5 ou BE4

@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

static function cAliasSum(cCodOpe,cCodLdp,cCodPeg,cTabela)

local oFwQuery  := FWPreparedStatement():New()
local cSql      := ""
local cAlias 	:= ""

iif(cTabela == 1, cTabela := "BD5",cTabela :="BE4" )
	
cSql := "SELECT SUM("+cTabela+"_VLRMAN) VLR_PROCEDI, SUM("+cTabela+"_VLRPAG) VLR_PAGO "
cSql += "FROM " + RetSqlName(cTabela) + " "+cTabela+" "
cSql += "WHERE "+cTabela+"_FILIAL = ? "
cSql += "AND   "+cTabela+"_CODOPE = ? "
cSql += "AND   "+cTabela+"_CODLDP = ? " 
cSql += "AND   "+cTabela+"_CODPEG = ? "


cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial(cTabela))
oFwQuery:SetString(2, cCodOpe)
oFwQuery:SetString(3, cCodLdp)
oFwQuery:SetString(4, cCodPeg)
cSql   := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

return cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} msgErro
//Caso o login e senha forem inválidos
//Caso o CPF, CNPJ OU CÓDIGO DO PRESTADOR NA OPEDORA FOREM INVÁLIDOS

@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

static function msgErro(cCodGlo, cDescGlo, cSeqTran, cOrigem, cRegisANS, cVerArq,nomeWs1,nomeWs2,tipTransac)

local cRet      := ""
local cFileHASH := ""
local cPathXML  := ""
local cHash 	:= ""
local cDataAtu 	:= DtoS(DatE())


Private nArqHash := 0

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" ) //formatação

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML
		Return(cRet)
	EndIf
EndIf

nArqHash 	:= fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F.)

cXml := A270Tag( 1,'soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#"',''	,.T.,.F.,.T., .F. )
cXml += A270Tag( 2,"soapenv:Header/"			,''						    ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'soapenv:Body'	       		,''	   						,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'ans:'+nomeWs1				,''	   						,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			    ,''						    ,.T.,.F.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao" ,''						 	,.T.,.F.,.T., .F. )
cXml += A270Tag( 5,"ans:tipoTransacao"			,tipTransac					,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:sequencialTransacao"	,cSeqTran				 	,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:horaRegistroTransacao"	,time()				 		,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao"	,''							,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:origem"	                ,''					        ,.T.,.F.,.T., .F. ) // origem recebe destino
cXML += A270Tag( 5,"ans:registroANS"	        ,cRegisANS	                ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:origem"	                ,''	                        ,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	            ,''					        ,.T.,.F.,.T., .F. ) // destino recebe origem 
cXml += A270Tag( 5,"ans:identificacaoPrestador"	,''					        ,.T.,.F.,.T., .F. )

If Len(cOrigem) == 11 //CPF
	cXml += A270Tag( 5,"ans:CPF"				       ,cOrigem ,.T.,.T.,.T., .F. )
elseif Len(cOrigem) == 14 //CNPJ
	cXml += A270Tag( 5,"ans:CNPJ"				       ,cOrigem ,.T.,.T.,.T., .F. )
else 
	cXml += A270Tag( 5,"ans:codigoPrestadorNaOperadora",cOrigem ,.T.,.T.,.T., .F. )
endif

cXml += A270Tag( 5,"ans:identificacaoPrestador",''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	           ,''	    		,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:Padrao"	           	   ,cVerArq	        ,.T.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			   ,''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,'ans:'+nomeWs2     ,''	   			,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,"ans:mensagemErro"	       ,''				,.T.,.F.,.T., .F. )
cXml += A270Tag( 4,"ans:codigoGlosa"	   	   ,cCodGlo	        ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:descricaoGlosa"	   	   ,cDescGlo	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:mensagemErro"		   ,''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:"+nomeWs2	   ,''	   			,.F.,.T.,.T., .F. )
fClose( nArqHash )
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
cXML += A270Tag( 2,"ans:hash"				   ,cHash			,.T.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:"+nomeWs1  ,''     			,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Body"			   ,''     			,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Envelope"		   ,''     			,.F.,.T.,.T., .F. )

return cXml

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvB1R

GRAVA REQUEST B1R

@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/


static function grvB1R(cNumB1R,request,cStatus)

	B1R->(confirmSX8())
	B1R->(dbsetOrder(1))

	while B1R->(MsSeek(xFilial("B1R") + cNumB1R)) // para garantir que não vai gerar um sequencial de transação duplicado
		cNumB1R := GetSXeNum("B1R","B1R_PROTOC")
		B1R->(confirmSX8())
	Enddo

	B1R->(RecLock("B1R", .T.)) // GRAVAÇÃO Request B1R
	B1R->B1R_FILIAL := xfilial("B1R")
	B1R->B1R_REQUES := request
	B1R->B1R_STATUS	:= cStatus 
	B1R->B1R_PROTOC := cNumB1R
	B1R->B1R_DATSUB := Date()

	B1R->(MsUnlock())
return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaXmlSP
monta response status de protocolo

@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

static function montaXmlSP(cAliasBCI,cAliasGuia,cAliasSoma,cSeqTran,cOrigem,cRegisANS,cVerArq,cNomeContr)

local cXml		 := ""
Local cPathXML	 := "" 
local cFileHASH  := ""
local cDataAtu 	 := DtoS(DatE())
local cTipGuiTis := "" // guia medica ou odontologica dependendo do BCI_TIPGUI
local atendiRN   := ""
local cHash 	 := ""
local oFwQuery 	 := FWPreparedStatement():New()
local cAliasBD6  := ""
local cAliasBDX  := ""
local oHashDP:= HMNew()

Private nArqHash := 0

qryBD6(@oFwQuery)

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" ) //formatação

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML
		Return(cRet)
	EndIf
EndIf

nArqHash 	:= fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F.)

cXml := A270Tag( 1,'soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#"',''	,.T.,.F.,.T., .F. )
cXml += A270Tag( 2,"soapenv:Header/"			,''						    ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'soapenv:Body'	       		,''	   						,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'ans:situacaoProtocoloWS'	,''	   						,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			    ,''						    ,.T.,.F.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao" ,''						 	,.T.,.F.,.T., .F. )
cXml += A270Tag( 5,"ans:tipoTransacao"			,'SITUACAO_PROTOCOLO'		,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:sequencialTransacao"	,cSeqTran				 	,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:horaRegistroTransacao"	,time()				 		,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao"	,''							,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:origem"	                ,''					        ,.T.,.F.,.T., .F. ) // origem recebe destino
cXML += A270Tag( 5,"ans:registroANS"	        ,cRegisANS	                ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:origem"	                ,''	                        ,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	            ,''					        ,.T.,.F.,.T., .F. ) // destino recebe origem 
cXml += A270Tag( 5,"ans:identificacaoPrestador"	,''					        ,.T.,.F.,.T., .F. )

If Len(cOrigem) == 11 //CPF
	cXml += A270Tag( 5,"ans:CPF"				       ,cOrigem ,.T.,.T.,.T., .F. )
elseif Len(cOrigem) == 14 //CNPJ
	cXml += A270Tag( 5,"ans:CNPJ"				       ,cOrigem ,.T.,.T.,.T., .F. )
else 
	cXml += A270Tag( 5,"ans:codigoPrestadorNaOperadora",cOrigem ,.T.,.T.,.T., .F. )
endif

cXml += A270Tag( 5,"ans:identificacaoPrestador",''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	           ,''	    		,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:Padrao"	           	   ,cVerArq	        ,.T.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			   ,''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,'ans:situacaoProtocolo'     ,''	   			,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,'ans:situacaoDoProtocolo'   ,''	   			,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,"ans:identificacaoOperadora",cRegisANS	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 3,'ans:dadosPrestador'        ,''	   			,.T.,.F.,.T., .F. )

If Len(cOrigem) == 11 //CPF
	cXml += A270Tag( 4,"ans:cpfContratado"				       ,cOrigem ,.T.,.T.,.T., .F. )
elseif Len(cOrigem) == 14 //CNPJ
	cXml += A270Tag( 4,"ans:cnpjContratado"				       ,cOrigem ,.T.,.T.,.T., .F. )
else 
	cXml += A270Tag( 4,"ans:codigoPrestadorNaOperadora"		   ,cOrigem ,.T.,.T.,.T., .F. )
endif

if cVerArq < "4.00.00"
	cXml += A270Tag( 4,"ans:nomeContratado"				   	   ,cNomeContr					,.T.,.T.,.T., .F. )
endif

cXml += A270Tag( 3,"ans:dadosPrestador"			,''     									,.F.,.T.,.T., .F. )
cXml += A270Tag( 3,'ans:lote'       			,''	   										,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,'ans:detalheLote'       		,''	   										,.T.,.F.,.T., .F. )
cXml += A270Tag( 4,"ans:statusProtocolo"		,(cAliasBCI)->BCI_STATUS	    			,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:numeroProtocolo"		,(cAliasBCI)->BCI_CODPEG	    			,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:numeroLote"				,iif(empty((cAliasBCI)->BCI_IDXML),(cAliasBCI)->BCI_CODPEG, (cAliasBCI)->BCI_IDXML)   ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:dataEnvioLote"			,substr((cAliasBCI)->BCI_DTDIGI, 1, 4) + "-" + substr((cAliasBCI)->BCI_DTDIGI, 5, 2) + "-" + substr((cAliasBCI)->BCI_DTDIGI, 7, 2)	,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:valorTotalLote"	        ,''	                						,.T.,.F.,.T., .F. )
cXml += A270Tag( 5,"ans:valorProcessado"		,cValToChar((cAliasSoma)->VLR_PROCEDI)	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:valorGlosa"				,cValToChar((cAliasBCI)->BCI_VLRGLO)	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:valorLiberado"			,cValToChar((cAliasSoma)->VLR_PAGO)	    	,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:valorTotalLote"			,''	   										,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:guiasTISS"	        	,''	                						,.T.,.F.,.T., .F. )

iif((cAliasBCI)->BCI_TIPGUI == "13", cTipGuiTis := "guiasOdonto",cTipGuiTis := "guiasMedicas")

while !(cAliasGuia)->(eof())

	cXml += A270Tag( 4,"ans:"+cTipGuiTis	        			,''	                		,.T.,.F.,.T., .F. )
	cXml += A270Tag( 4,"ans:guias"	                			,''					        ,.T.,.F.,.T., .F. )
	cXml += A270Tag( 5,"ans:numeroGuiaPrestador"				,iif(empty((cAliasGuia)->NUMIMP),(cAliasBCI)->BCI_CODPEG+(cAliasGuia)->NUMERO,(cAliasGuia)->NUMIMP)	   ,.T.,.T.,.T., .F. )
	cXml += A270Tag( 5,"ans:numeroGuiaOperadora"				,(cAliasBCI)->BCI_CODPEG+(cAliasGuia)->NUMERO	,.T.,.T.,.T., .F. )

	if (cAliasBCI)->BCI_TIPGUI != "13"
		cXml += A270Tag( 5,"ans:dadosBeneficiario"	            ,''					        ,.T.,.F.,.T., .F. )
	endif
	
	cXml += A270Tag( 5,"ans:numeroCarteira"						,(cAliasGuia)->(OPEUSR+CODEMP+MATRIC+TIPREG+DIGITO)									,.T.,.T.,.T., .F. )
	cXml += A270Tag( 5,"ans:atendimentoRN"						,iif((cAliasGuia)->ATENDIRN == "0", atendiRN := "N",atendiRN:="S") 					,.T.,.T.,.T., .F. )

	if cVerArq < "4.00.00"
	cXml += A270Tag( 5,"ans:nomeBeneficiario"					,cNomeContr   				,.T.,.T.,.T., .F. )
	endif

 	if (cAliasBCI)->BCI_TIPGUI != "13"
	cXml += A270Tag( 5,"ans:dadosBeneficiario"					,''     					,.F.,.T.,.T., .F. )
	endif 

	cXml += A270Tag( 5,"ans:dataRealizacao"				,substr((cAliasGuia)->DATPRO, 1, 4) + "-" + substr((cAliasGuia)->DATPRO, 5, 2) + "-" + substr((cAliasGuia)->DATPRO, 7, 2)	,.T.,.T.,.T., .F. )
	cXml += A270Tag( 5,"ans:vlInformadoGuia"      		,''	   				    				,.T.,.F.,.T., .F. )
	cXml += A270Tag( 6,"ans:valorProcessado"			,cvaltochar((cAliasGuia)->VLRBPR)		,.T.,.T.,.T., .F. )
	cXml += A270Tag( 6,"ans:valorGlosa"				    ,cvaltochar((cAliasGuia)->VLRGLO)		,.T.,.T.,.T., .F. )
	cXml += A270Tag( 6,"ans:valorLiberado"				,cvaltochar((cAliasGuia)->VLRPAG)		,.T.,.T.,.T., .F. )
	cXml += A270Tag( 5,"ans:vlInformadoGuia"			,''     								,.F.,.T.,.T., .F. )

	oFwQuery:SetString(1, xFilial("BD6"))
    oFwQuery:SetString(2, (cAliasGuia)->CODOPE)
	oFwQuery:SetString(3, (cAliasGuia)->CODLDP)
	oFwQuery:SetString(4, (cAliasGuia)->CODPEG)
	oFwQuery:SetString(5, (cAliasGuia)->NUMERO)
	cAliasBD6 := MpSysOpenQuery(oFwQuery:GetFixQuery())

	cXml += A270Tag( 5,"ans:procedimentosRealizados"      		,''	   				    ,.T.,.F.,.T., .F. )

	while !(cAliasBD6)->(eof())
			
		cXml += A270Tag( 5,"ans:procedimentoRealizado"      		,''	   				    ,.T.,.F.,.T., .F. )

		BX6->(dbSetOrder(1))
		If BX6->(DbSeek(xfilial("BX6") + (cAliasGuia)->CODOPE + (cAliasGuia)->CODLDP + (cAliasGuia)->CODPEG + (cAliasGuia)->NUMERO + (cAliasBD6)->BD6_ORIMOV + (cAliasBD6)->BD6_SEQUEN ))
			cXml += A270Tag( 5,"ans:sequencialItem"  ,iif(empty(BX6->BX6_SQTISS),(cAliasBD6)->BD6_SEQUEN,BX6->BX6_SQTISS)   ,.T.,.T.,.T., .F. ) 
		else
			cXml += A270Tag( 5,"ans:sequencialItem"  ,(cAliasBD6)->BD6_SEQUEN   											,.T.,.T.,.T., .F. )
		EndIf

		cXml += A270Tag( 5,"ans:dataExecucao"                    ,substr((cAliasBD6)->BD6_DATPRO, 1, 4) + "-" + substr((cAliasBD6)->BD6_DATPRO, 5, 2) + "-" + substr((cAliasBD6)->BD6_DATPRO, 7, 2)    ,.T.,.T.,.T., .F. ) 
		iif(!empty((cAliasBD6)->BD6_HORPRO), cXml += A270Tag( 5,"ans:horaInicial"                     ,substr((cAliasBD6)->BD6_HORPRO, 1,2) + ":" + substr((cAliasBD6)->BD6_HORPRO, 3,2) + ":00"       ,.T.,.T.,.T., .F. ),'')
		iif(!empty((cAliasBD6)->BD6_HORFIM), cXml += A270Tag( 5,"ans:horaFinal"                       ,substr((cAliasBD6)->BD6_HORFIM, 1,2) + ":" + substr((cAliasBD6)->BD6_HORFIM, 3,4) + ":00"       ,.T.,.T.,.T., .F. ),'') 

		cXml += A270Tag( 5,"ans:procedimento"      					 ,''	   				         						   ,.T.,.F.,.T., .F. )
		cXml += A270Tag( 6,"ans:codigoTabela"                    	 ,deParaSimpl('87',(cAliasBD6)->BD6_CODPAD, 'BR4')         ,.T.,.T.,.T., .F. )
		cXml += A270Tag( 6,"ans:codigoProcedimento"                  ,(cAliasBD6)->BD6_CODPRO       						   ,.T.,.T.,.T., .F. )
		cXml += A270Tag( 6,"ans:descricaoProcedimento"               ,(cAliasBD6)->BD6_DESPRO       						   ,.T.,.T.,.T., .F. )
		cXml += A270Tag( 5,"ans:procedimento"						 ,''     			    	    						   ,.F.,.T.,.T., .F. )

		cXml += A270Tag( 5,"ans:quantidadeExecutada"               ,cvaltochar((cAliasBD6)->BD6_QTDPRO)        ,.T.,.T.,.T., .F. )
		iif( !empty((cAliasBD6)->BD6_VIA),     cXml += A270Tag( 5,"ans:viaAcesso"               		  ,deParaSimpl('61', (cAliasBD6)->BD6_VIA, 'BGR',@oHashDP)         ,.T.,.T.,.T., .F. ), '') 
		iif( !empty((cAliasBD6)->BD6_TECUTI),  cXml += A270Tag( 5,"ans:tecnicaUtilizada"                  ,(cAliasBD6)->BD6_TECUTI        								   ,.T.,.T.,.T., .F. ), '')
		cXml += A270Tag( 5,"ans:valorUnitario"                     ,cvaltochar((cAliasBD6)->BD6_VLRAPR)        ,.T.,.T.,.T., .F. )
		cXml += A270Tag( 5,"ans:valorTotal"                        ,cvaltochar((cAliasBD6)->BD6_VALORI)        ,.T.,.T.,.T., .F. )
		cXml += A270Tag( 5,"ans:fatorReducaoAcrescimo"             ,cvaltochar((cAliasBD6)->BD6_FATMUL)        ,.T.,.T.,.T., .F. )

		cAliasBDX := qryBDX((cAliasGuia)->CODOPE , (cAliasGuia)->CODLDP , (cAliasGuia)->CODPEG , (cAliasGuia)->NUMERO, (cAliasBD6)->BD6_SEQUEN ) 

		IF !(cAliasBDX)->(eof())
			cXml += A270Tag( 5,"ans:glosasProcedimento"      				,''	   				            ,.T.,.F.,.T., .F. )

			while !(cAliasBDX)->(eof())
				cXml += A270Tag( 5,"ans:motivoGlosa"      					,''	   				            ,.T.,.F.,.T., .F. )
				cXml += A270Tag( 5,"ans:codigoGlosa"                     	,deParaSimpl('38', (cAliasBDX)->BDX_CODGLO, 'BCT',@oHashDP)        ,.T.,.T.,.T., .F. )
				cXml += A270Tag( 5,"ans:descricaoGlosa"                     ,(cAliasBDX)->BDX_DESGLO        ,.T.,.T.,.T., .F. )
				cXml += A270Tag( 5,"ans:motivoGlosa"						,''     			    	    ,.F.,.T.,.T., .F. )
				(cAliasBDX)->(DbSkip())	
			enddo
			
			cXml += A270Tag( 5,"ans:valorGlosaProcedimento"                  ,cvaltochar((cAliasBD6)->BD6_VLRGLO)      ,.T.,.T.,.T., .F. ) 
			cXml += A270Tag( 5,"ans:glosasProcedimento"						 ,''     			    	   			   ,.F.,.T.,.T., .F. )
		endif 

		cXml += A270Tag( 5,"ans:procedimentoRealizado"					     ,''     			    	   			   ,.F.,.T.,.T., .F. )
		(cAliasBDX)->(DbCloseArea())	
		(cAliasBD6)->(DbSkip())	
	enddo

	cXml += A270Tag( 5,"ans:procedimentosRealizados"			,''     			        ,.F.,.T.,.T., .F. )
	cXml += A270Tag( 4,"ans:guias"	                			,''	                        ,.F.,.T.,.T., .F. )
	cXml += A270Tag( 4,"ans:"+cTipGuiTis	               	 	,''	                        ,.F.,.T.,.T., .F. )

	(cAliasBD6)->(DbCloseArea())
	(cAliasGuia)->(DbSkip())	
enddo

(cAliasGuia)->(DbCloseArea())
(cAliasSoma)->(DbCloseArea())
(cAliasBCI)->(DbCloseArea())

cXml += A270Tag( 4,"ans:guiasTISS"						,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:detalheLote"					,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:lote"							,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:situacaoDoProtocolo"			,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:situacaoProtocolo"				,''     					,.F.,.T.,.T., .F. )
fClose( nArqHash )
HMClean(oHashDP)
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
cXml += A270Tag( 2,"ans:hash"						    ,cHash				 		,.T.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:situacaoProtocoloWS"			,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Body"						,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Envelope"					,''     					,.F.,.T.,.T., .F. )

return cXml

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qryBDX
@author    Daniel Silva 
@version   P12
@since     19/09/2022
/*/

static function qryBDX(cCodOpe, cCodLdp, cCodPeg, cNumero, cSequen)

local oFwQuery  := FWPreparedStatement():New()
local cSql 		:= ""
local cAlias 	:= ""

	cSql := "SELECT BDX_CODGLO, BDX_DESGLO, BDX_VLRGLO " 	
	cSql += "FROM " + RetSqlName("BDX") + " BDX "
	cSql += "WHERE BDX_FILIAL = ? "
	cSql += "AND BDX_CODOPE = ? "
	cSql += "AND BDX_CODLDP = ? " 
	cSql += "AND BDX_CODPEG = ? "
	cSql += "AND BDX_NUMERO = ? "
	cSql += "AND BDX_SEQUEN = ? "
	cSql += "AND BDX_NIVEL <> ' ' "
	cSql += "AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1, xFilial("BDX"))
	oFwQuery:SetString(2, cCodOpe)
	oFwQuery:SetString(3, cCodLdp)
	oFwQuery:SetString(4, cCodPeg)
	oFwQuery:SetString(5, cNumero)
	oFwQuery:SetString(6, cSequen)
	cSql := oFwQuery:GetFixQuery()
	cAlias := MpSysOpenQuery(cSql)

return cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qryBD6
@author    Daniel Silva 
@version   P12
@since     19/09/2022
/*/

static function qryBD6(oFwQuery)

local cSql 	   := ""

cSql := "SELECT BD6_DATPRO, BD6_HORPRO, BD6_HORFIM, BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, BD6_QTDPRO, " 	
cSql += "BD6_VIA, BD6_TECUTI, BD6_VLRAPR, BD6_VALORI, BD6_FATMUL, BD6_VLRGLO, BD6_SEQUEN, BD6_ORIMOV" // ADICIONAR O VLRGLO
cSql += "FROM " + RetSqlName("BD6") + " BD6 "
cSql += "WHERE BD6_FILIAL = ? "
cSql += "AND BD6_CODOPE = ? "
cSql += "AND BD6_CODLDP = ? " 
cSql += "AND BD6_CODPEG = ? "
cSql += "AND BD6_NUMERO = ? "
cSql += "AND D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)

return oFwQuery 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldCpfCnpj
posiciona no cpf, cnpnj ou codigoPrestadorNaOperadora caso existirem 

@author    Daniel Silva 
@version   P12
@since     10/05/2022
/*/

static function vldCpfCnpj(cOrigem, cRegisANS)

local aRet := {"",""}

if (Len(cOrigem) == 11 .or. Len(cOrigem ) == 14) // cpf ou cnpj
	BAU->(dbSetOrder(4))
	If BAU->(DbSeek(xfilial("BAU") + alltrim(cOrigem)))
	    aRet[1] := BAU->BAU_CODIGO
	EndIf
	else 
		BAU->(DbSetOrder(1))
		If BAU->(DbSeek(xFilial("BAU") + alltrim(cOrigem))) // codigoPrestadorNaOperadora
			aRet[1] := BAU->BAU_CODIGO
		endif
endif

 	BA0->(dbSetOrder(5))
	   If BA0->(DbSeek(xfilial("BA0") + alltrim(cRegisANS)))
			aRet[2] := (BA0->BA0_CODIDE + BA0->BA0_CODINT)
	   EndIf

return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCanceGui
Função "main" responsável pelo webservice -> Solicitação de cancelamento de guias
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/

Function PLSCanceGui()

local cXml      	:= HttpOtherContent()
local cVerArq		:= ""
local aRetObj 		:= {}
Local aCritARQ		:= {.F., "", ""}
local cNomeContr 	:= ""
local cLogin		:= ""
local cSenha 		:= ""
local cRet 			:= ""
local lMV_PLLGSN	:= GetNewPar("MV_PLLGSN", .F.) 
local cNumB1R 		:= GetSXeNum("B1R","B1R_PROTOC")
local cRegisANS		:= ""
local valCpfCnpj	:= {}
local cTipCancel 	:= ""  
local cNumGui 		:= ""
local cNumGuiPre	:= ""	
local cNumGuiOpe	:= ""
local cTipGui 		:= ""
local lLoteGuia		:= .f.
local cCodPeg 		:= ""
local cNumLote		:= ""
local nY			:= 1
local aRet 			:= {}
local cTag			:= ""
local aCodIdent		:= Array(2)

private cNS     	:= ""

cVerArq	:= Substr(cXml,At("Padrao>", cXml) + Len("Padrao>"),7)

HttpCtType( "text/xml; charset="+'UTF-8' )

aRetObj := VldWSdemoP(cXml,"tissWebServicesV" + StrTran(cVerArq, ".", "_") + ".xsd")

If aRetObj[1]

	cSoapXML := aRetObj[3]
	oXML := TXmlManager():New()

	if empty(cNS)
		// Removo da tag loteGuiasWS os URL's pois estava dando falha no parse.
		nPos := At(">",Upper(cSoapXml))      
		cSoapPt1 := Substr(cSoapXml,1,nPos-1)
		cSoapPt2 := Substr(cSoapXml,nPos,len(cSoapXml))
		cSoapXml := "      <cancelaGuiaWS" + cSoapPt2
	endif
	
	lRet := oXML:Parse(cSoapXml)

	if lRet 	
		aNS := oXML:XPathGetRootNsList()
		nPos := ascan(aNS,{|x| upper(alltrim(x[1])) == upper(cNS) })
		If nPos > 0
			oXML:XPathRegisterNs( aNS[ nPos ][ 1 ],aNS[ nPos ][ 2 ] )		
		EndIf
	EndIf

	cPathTag := addNS("/cancelaGuiaWS")

	if( oXml:XPathHasNode( cPathTag ) )
		
		grvB1R(@cNumB1R,cSoapXml,"E") // GRAVA REQUEST NA B1R / STATUS "E" -> REQUEST RECEBIDO MAS AINDA NÃO PROCESSADO
		//Vamos verificar a versão do TISS e ajustar o XML de entrada e retorno

		//Vamos verificar a Origem do Prestador (RDA) 
		aCodIdent[1] := getIdentPrest(oXml, cPathTag + addNS("/cabecalho/origem/"))
		if empty(aCodIdent[1]) .OR. empty(aCodIdent[1,1,1])
			aCritARQ[1] := .T.
			aCritARQ[2] := "CÓDIGO PRESTADOR INVÁLIDO"
			aCritARQ[3] := "1203"
		endif
		//Vamos verificar o destino do Prestador (OPERADORA DE SAUDE)
		aCodIdent[2] := getIdentPrest(oXml, cPathTag + addNS("/cabecalho/destino/"))
		if empty(aCodIdent[2]) .OR. empty(aCodIdent[2,1,1])
			aCritARQ[1] := .T.
			aCritARQ[2] := "CÓDIGO DA OPERADORA INVÁLIDO"
			aCritARQ[3] := "5027"
		endif

		if cVerArq < "4"
			
			If lMV_PLLGSN .and. !aCritARQ[1]
				//3100	PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM
				//3111	CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO
				cPathLogin := cPathTag + addNs("/cabecalho/loginSenhaPrestador" )
				If ( oXml:XPathHasNode( cPathLogin ) )
					cLogin	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/loginPrestador" ))
					cSenha	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/senhaPrestador" ))
					BSW->(dbSetOrder(1))
					If BSW->(MsSeek(xfilial("BSW") + Upper(cLogin) + Space( tamsx3("BSW_LOGUSR")[1] - Len(cLogin) ) ))
						If !( cSenha == BSW->BSW_SENHA )
							//Senha inválida
							aCritARQ[1] := .T.
							aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"Senha inválida"
							aCritARQ[3] := "3111"
						endIF
					else
						//Login não existe -> login inválido
						aCritARQ[1] := .T.
						aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"login inválido"
						aCritARQ[3] := "3111"
					endIf
				else
					//Não foi enviada a tag
					aCritARQ[1] := .T.
					aCritARQ[2] := "PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM"//"Não foi enviada a tag"
					aCritARQ[3] := "3100"
				endIf
			endIf

			if !aCritARQ[1]
				cTag 	   := cPathTag + addNS("/cancelaGuia" ) 
				cTipGui    := oXML:XPathGetNodeValue( cTag + addNS("/tipoGuia" )) 
				//cDadPrest := oXML:XPathGetNodeValue( cTag + addNS("/dadosPrestador/codigoPrestadorNaOperadora" ))
				//cDadPrest := oXML:XPathGetNodeValue( cTag + addNS("/dadosPrestador/cpfContratado" ))
				//cDadPrest := oXML:XPathGetNodeValue( cTag + addNS("/dadosPrestador/cnpjContratado" ))
				cNomeContr := oXML:XPathGetNodeValue( cTag + addNS("/dadosPrestador/nomeContratado" ))
				cNumGuiPre := oXML:XPathGetNodeValue( cTag + addNS("/guiasCancelamento/numeroGuiaPrestador" ))
				cNumGuiOpe := oXML:XPathGetNodeValue( cTag + addNS("/guiasCancelamento/numeroGuiaOperadora" ))
				cNumProtoc := oXML:XPathGetNodeValue( cTag + addNS("/numeroProtocolo" ))
				cCodpeg	   := SubStr(cNumGuiOpe,1,8)
				cNumGui    := SubStr(cNumGuiOpe,9,17)	
				cAliasBCI  := QryStProto(cCodpeg)
														
				if (cTipGui == "1") 
					cTipCancel := canGuiSol(aCodIdent[1,1,1],aCodIdent[2,1,1],cNumGuiOpe) 
				endif

				aadd(aRet, {cTipGui,cNumGuiPre,cNumGuiOpe,cCodpeg,cTipCancel})
				nY++ 
				(cAliasBCI)->(dbcloseArea())

			endif

			If !aCritARQ[1]
				cRet :=  montaXmlGui(cNumB1R,aCodIdent[2,1,2],aCodIdent[1,2],cVerArq,aRet,cNomeContr) 
			else 
				cRet := msgErro(aCritARQ[3],aCritARQ[2],cNumB1R,aCodIdent[1,2],iif(!empty(aCodIdent[2,1,2]),aCodIdent[2,1,2],aCodIdent[2,2]),cVerArq,"reciboCancelaGuiaWS","reciboCancelaGuia","CANCELA_GUIA")
			endif
		Else
			cNomeContr := oXML:XPathGetNodeValue( cPathTag + addNS("/cancelaGuiaWS/dadosPrestador/nomeContratado"))
			cRegisANS  := oXML:XPathGetNodeValue( cPathTag + addNS("/cabecalho/destino/registroANS" ))

			//posição 1 = cCodRda, posição 2 = cCodope
			valCpfCnpj := vldCpfCnpj(aCodIdent[1,2], aCodIdent[2,1,2]) // valida se o registroANS - cpf/cnpj existem 

			if empty(valCpfCnpj[1])
				aCritARQ[1] := .T.
				aCritARQ[2] := "CÓDIGO PRESTADOR INVÁLIDO"
				aCritARQ[3] := "1203"
			elseif empty(valCpfCnpj[2])
				aCritARQ[1] := .T.
				aCritARQ[2] := "REGISTRO ANS DA OPERADORA INVÁLIDO"
				aCritARQ[3] := "5027"
			endif

			If lMV_PLLGSN .and. !aCritARQ[1]
				//3100	PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM
				//3111	CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO
				cPathLogin := cPathTag + addNs("/cabecalho/loginSenhaPrestador" )
				If ( oXml:XPathHasNode( cPathLogin ) )
					cLogin	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/loginPrestador" ))
					cSenha	:= oXML:XPathGetNodeValue( cPathLogin + addNS("/senhaPrestador" ))
					BSW->(dbSetOrder(1))
					If BSW->(MsSeek(xfilial("BSW") + Upper(cLogin) + Space( tamsx3("BSW_LOGUSR")[1] - Len(cLogin) ) ))
						If !( cSenha == BSW->BSW_SENHA )
							//Senha inválida
							aCritARQ[1] := .T.
							aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"Senha inválida"
							aCritARQ[3] := "3111"
						endIF
					else
						//Login não existe -> login inválido
						aCritARQ[1] := .T.
						aCritARQ[2] := "CAMPO CONDICIONADO NÃO PREENCHIDO OU INCORRETO"//"login inválido"
						aCritARQ[3] := "3111"
					endIf
				else
					//Não foi enviada a tag
					aCritARQ[1] := .T.
					aCritARQ[2] := "PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CÓDIGO DE ORIGEM"//"Não foi enviada a tag"
					aCritARQ[3] := "3100"
				endIf
			endIf
			
			if !aCritARQ[1]

				if( oXml:XPathHasNode( cPathTag + addNS("/cancelaGuia/tipoCancelamento/tipoCancelamentoLote" )))
					lLoteGuia  := .t.
					cNumLote   := oXML:XPathGetNodeValue( cPathTag + addNS("/cancelaGuia/tipoCancelamento/tipoCancelamentoLote/numeroLote" ))
					cCodpeg	   := oXML:XPathGetNodeValue( cPathTag + addNS("/cancelaGuia/tipoCancelamento/tipoCancelamentoLote/numeroProtocolo" ))
					cAliasBCI  := QryStProto(cCodpeg)

					if(len(cCodpeg) == 8)
						cTipCancel := canLoteGui(cAliasBCI,valCpfCnpj,cCodpeg,"",lLoteGuia)
					else
						cTipCancel := cancelGlosa(cCodpeg,lLoteGuia)
					endif

					(cAliasBCI)->(dbcloseArea())

				elseif( oXml:XPathHasNode( cPathTag + addNS("/cancelaGuia/tipoCancelamento/tipoCancelamentoGuia" ) + "[" + cvaltochar(nY) + "]")) 

					while(oXML:XPathHasNode( cPathTag + addNS("/cancelaGuia/tipoCancelamento/tipoCancelamentoGuia" ) + "[" + cvaltochar(nY) + "]" ))
						
						cTag 	   := cPathTag + addNS("/cancelaGuia/tipoCancelamento/tipoCancelamentoGuia" ) + "[" + cvaltochar(nY) + "]"
						cTipGui    := oXML:XPathGetNodeValue( cTag + addNS("/tipoGuia" )) 
						cNumGuiPre := oXML:XPathGetNodeValue( cTag + addNS("/numeroGuiaPrestador" ))
						cNumGuiOpe := oXML:XPathGetNodeValue( cTag + addNS("/numeroGuiaOperadora" ))
						cNumProtoc := oXML:XPathGetNodeValue( cTag + addNS("/numeroProtocolo" ))
						cCodpeg	   := SubStr(cNumGuiOpe,1,8)
						cNumGui    := SubStr(cNumGuiOpe,9,17)	
						cAliasBCI  := QryStProto(cCodpeg)
																
						if (cTipGui == "1") 
							cTipCancel := canGuiSol(valCpfCnpj[1],valCpfCnpj[2],cNumGuiOpe) 
						elseif (cTipGui == "2") 
							cTipCancel := canLoteGui(cAliasBCI,valCpfCnpj,cCodpeg,cNumGui,lLoteGuia) 
						elseif (cTipGui == "3")
							cTipCancel := cancelGlosa(cNumProtoc,lLoteGuia)
							cCodpeg    := cNumProtoc
						endif

						aadd(aRet, {cTipGui,cNumGuiPre,cNumGuiOpe,cCodpeg,cTipCancel})
						nY++ 
					enddo 
					(cAliasBCI)->(dbcloseArea())
				endif
			endif

			If !aCritARQ[1]
				if (lLoteGuia) 			 
					cRet :=  montaXmlLot(cNumB1R,aCodIdent[2,1,2],aCodIdent[1,2],cVerArq,cNumLote,cCodpeg,cTipCancel)
				elseif (!lLoteGuia)
					cRet :=  montaXmlGui(cNumB1R,aCodIdent[2,1,2],aCodIdent[1,2],cVerArq,aRet) 
				endif 	
			else 
				cRet := msgErro(aCritARQ[3],aCritARQ[2],cNumB1R,aCodIdent[1,2],iif(!empty(aCodIdent[2,1,2]),aCodIdent[2,1,2],aCodIdent[2,2]),cVerArq,"reciboCancelaGuiaWS","reciboCancelaGuia","CANCELA_GUIA")
			endif
		endif //Fim da verificação da Versao do TISS		 		
	endif
endif

	DbSelectArea('B1R')
	B1R->(DbSetOrder(1))
	If B1R->(DbSeek(xFilial('B1R') + cNumB1R))   // GRAVA RESPONSE NA B1R / STATUS "F" -> REQUEST RECEBIDO E PROCESSADO
    	RecLock('B1R', .F.)
		B1R->B1R_RESPON := cRet 
		B1R->B1R_STATUS	:= "F"
		B1R->(MsUnLock())
	endif 

return cRet

 /*/{Protheus.doc} getIdentPrest
	pega a identificação do prestador no XML pela tag IdentificacaoPrestador ou Registro ANS
	@type  Static Function
	@author Gabriel Mucciolo
	@since 17/08/2022
	@version P12
	/*/
Static Function getIdentPrest(oXml, cPathTag)
	local cIndentificacao 	:= ""
	local lRegAns			:= .f.
	local cTipo				:= ""
	local aRet				:= Array(4)
	default oXml			:= nil
	default cPathTag		:= ""

	if !empty(oXml) .AND. !empty(cPathTag)
		if( oXml:XPathHasNode( cPathTag + addNS("registroANS" )))
			cIndentificacao := oXML:XPathGetNodeValue( cPathTag + addNS("registroANS" ))
			lRegAns := .t.
		elseif( oXml:XPathHasNode( cPathTag + addNS("identificacaoPrestador/CNPJ" )))
			cIndentificacao := oXML:XPathGetNodeValue( cPathTag + addNS("identificacaoPrestador/CNPJ" ))
		elseif( oXml:XPathHasNode( cPathTag + addNS("identificacaoPrestador/CPF" )))
			cIndentificacao := oXML:XPathGetNodeValue( cPathTag + addNS("identificacaoPrestador/CPF" ))
		elseif( oXml:XPathHasNode( cPathTag + addNS("identificacaoPrestador/codigoPrestadorNaOperadora" )))
			cIndentificacao := oXML:XPathGetNodeValue( cPathTag + addNS("identificacaoPrestador/codigoPrestadorNaOperadora" ))
		endif

		//Vamos verificar se é origem ou destino
		if "origem" $ cPathTag
			cTipo := "origem"
		endif
		if "destino" $ cPathTag
			cTipo := "destino"
		endif

		if !empty(cTipo)
			//Retorna o codigo da rda/operadora e o registro da ans quando for operadora de saude
			aRet[1] := vldIdent(cTipo, cIndentificacao, lRegAns)
			aRet[2] := cIndentificacao //
			aRet[3] := lRegAns
			aRet[4] := cTipo
				
		endif
	endif
Return aRet

static function vldIdent(cTipo, cIndentificacao, lRegAns)
	local 	aRet				:= Array(2)
	default cTipo 				:= ""
	default cIndentificacao		:= ""
	default lRegAns				:= .f.
	

	//Retorna o codigo da Rede de Atendimento quando for origem
	if cTipo == "origem"
		if lRegAns //Registro ANS
			cAliasTemp := GetNextAlias()
			cQuery := " SELECT BAU.BAU_CODIGO FROM "+RetSqlName("BAU")+" BAU "
			cQuery += " WHERE BAU.BAU_FILIAL = '"+xFilial("BAU")+"'"
			cQuery += "   AND BAU.BAU_ANSOPI = '"+cIndentificacao+"'"
			cQuery += "   AND BAU.D_E_L_E_T_ = ' ' "

			dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

			aRet[1] := (cAliasTemp)->BAU_CODIGO

			(cAliasTemp)->(DbCloseArea())

		else //CPF, CNPJ ou Código da operadora
			if (Len(cIndentificacao) == 11 .or. Len(cIndentificacao ) == 14) // cpf ou cnpj
				BAU->(dbSetOrder(4))
				If BAU->(DbSeek(xfilial("BAU") + alltrim(cIndentificacao)))
					aRet[1] := BAU->BAU_CODIGO
				EndIf
			else 
				BAU->(DbSetOrder(1))
				If BAU->(DbSeek(xFilial("BAU") + alltrim(cIndentificacao))) // codigoPrestadorNaOperadora
					aRet[1] := BAU->BAU_CODIGO
				endif
			endif
		Endif
	Endif

	//Retorna o codigo da Operadoras de Saúde 
	if cTipo == "destino"
		if lRegAns //Registro ANS
			BA0->(dbSetOrder(5))
			If BA0->(DbSeek(xfilial("BA0") + alltrim(cIndentificacao)))
				aRet[1] := (BA0->BA0_CODIDE + BA0->BA0_CODINT)
				aRet[2] := (BA0->BA0_SUSEP)
			EndIf
		else //CPF, CNPJ ou Código da operadora
			if (Len(cIndentificacao) == 11 .or. Len(cIndentificacao ) == 14) // cpf ou cnpj
				BA0->(dbSetOrder(4))
				If BA0->(DbSeek(xfilial("BA0") + alltrim(cIndentificacao)))
					aRet[1] := (BA0->BA0_CODIDE + BA0->BA0_CODINT)
					aRet[2] := (BA0->BA0_SUSEP)
				EndIf
			else 
				BA0->(DbSetOrder(1))
				If BA0->(DbSeek(xFilial("BA0") + alltrim(cIndentificacao))) // codigoPrestadorNaOperadora
					aRet[1] := (BA0->BA0_CODIDE + BA0->BA0_CODINT)
					aRet[2] := (BA0->BA0_SUSEP)
				endif
			endif
		endif	
	Endif
 	
return aRet

/*/{Protheus.doc} canGuiSol
	Função que executa o cancelamento de guia de solicitação
	@type  Static Function
	@author Gabriel Mucciolo
	@since 04/07/2022
	@version P12
	@param cCodRda, Caracter, Codigo da RDA (BAU) 
	@param cCodope, Caracter, Codigo da operadora (BA0)
	@param cNumGuiOpe, Caracter, Numero da guia na operadora
	@return nStatusTiss, Numerico, Retorna a critica para a funcao principal
		1 Cancelado com sucesso
		2 Não cancelado
		3 Guia inexistente
		4 Em processamento
		5 Lote inexistente

	/*/
Static Function canGuiSol(cCodRda, cCodope, cNumGuiOpe)
	local lret 			:= .T.
	local nStatusTiss	:= 0
	default cCodRda 	:= ''
	default cCodope 	:= ''
	default cNumGuiOpe 	:= ''
	
	//Posiciona na BEA e pega os dados da Guia, se não houver resultado vamos posicionar na B4A e na B4Q
	BEA->(DbSetOrder(1))
	B4A->(DbSetOrder(1))
	B4Q->(DbSetOrder(1))

	Do Case
        Case BEA->( MsSeek( xFilial("BEA")+cNumGuiOpe) )
			//Vamos comparar os dados da Guia (BEA) com os dados da Rda e operadora que vieram do XML.
			If (cCodRda != BEA->BEA_CODRDA .OR. cCodope != BEA->BEA_OPERDA) .AND. lret
				lret := .F.
				nStatusTiss := 3
			EndIf

			PLSA090CAN(.T.,, BEA->(RecNo()), .F., @nStatusTiss) //CANCELA NA BEA 
			if BEA->BEA_TIPGUI == '11' //GUIA DE SOL.PRORROGACAO DE INT  
				if B4Q->( MsSeek( xFilial("B4Q")+cNumGuiOpe) )
					PLSA09PCAN(.F.,.F.,,,,,,.T., @nStatusTiss) //CANCELA NA B4Q
				EndIf				
			EndIf
        Case B4A->( MsSeek( xFilial("B4A")+cNumGuiOpe) )
			PLSA09ACAN(.F.,.F.,,,,,.T., @nStatusTiss) 
        Otherwise
			lret := .F.
			nStatusTiss := 3
    EndCase 

return AllTrim(str(nStatusTiss))

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} canLoteGui
Função responsável pelo cancelamento por guia/lote
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/
																						// .t. lote - .f. guia 
static function canLoteGui(cAliasBCI,valCpfCnpj,cCodpeg,cNumGui,lLoteGuia)

local cValRda 	 := "" 
local lValGui	 := .f. 
local cCritica 	 := ""
local lAttStatus := .t.

	if (lLoteGuia)
		cValRda := vldRdaLote(valCpfCnpj[1],cCodpeg)
	else 
		cValRda := vldRdaGui(valCpfCnpj[1],(cAliasBCI)->BCI_TIPGUI,cCodpeg,cNumGui) 
	endif 

	If !( (cValRda)->(eOf()) ) // verifico se guia ou lote existe 

		lValGui := valGui((cValRda)->FASE,cCodpeg,cNumGui,valCpfCnpj[1],lLoteGuia)

		if(!lValGui)
			cCritica := "2"	//Não cancelado
		else 
			lAttStatus := attStatus((cAliasBCI)->BCI_TIPGUI,cCodpeg,(cAliasBCI)->BCI_CODLDP,valCpfCnpj[2],cNumGui,lLoteGuia)
		endif
		
		iif(!lAttStatus,cCritica := "1",cCritica := "2") // 1 cancelado com sucesso / 2 caso der algum erro no update

	else 

		if(lLoteGuia)
			cCritica := "5" // lote enexistente 
		else
			cCritica := "3" // guia inexistente 
		endif

	endIf

	(cValRda)->(dbcloseArea())
	
return cCritica

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldRdaGui
Função que valida se a RDA solicitando cancelamento é diferente da RDA que enviou a cobrança -> guia 
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/

static function vldRdaGui(cCodRda,cTipGui,cCodpeg,cNumGui)

local cTabela 	:= ""
local oFwQuery  := FWPreparedStatement():New()
local cSql      := ""
local cAlias 	:= ""

iif(cTipGui != "05", cTabela := "BD5",cTabela :="BE4" )
	
cSql := "SELECT "+cTabela+"_CODPEG CODPEG," +cTabela+"_NUMERO NUMERO," +cTabela+"_CODRDA CODRDA," +cTabela+"_FASE FASE"
cSql += "FROM " + RetSqlName(cTabela) + " "+cTabela+" "
cSql += "WHERE "+cTabela+"_FILIAL = ? "
cSql += "AND   "+cTabela+"_CODPEG = ? "
cSql += "AND   "+cTabela+"_NUMERO = ? " 
cSql += "AND   "+cTabela+"_CODRDA = ? "
cSql += "AND  D_E_L_E_T_ = ? "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial(cTabela))
oFwQuery:SetString(2, cCodpeg)
oFwQuery:SetString(3, cNumGui)
oFwQuery:SetString(4, cCodRda)
oFwQuery:SetString(5, ' ')
cSql := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

return cAlias


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldRdaLote
Função que valida se a RDA solicitando cancelamento é diferente da RDA que enviou a cobrança -> lote 
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/

static function vldRdaLote(cCodRda,cCodPeg)

local oFwQuery  := FWPreparedStatement():New()
local cSql      := ""
local cAlias 	:= ""
	 
cSql := " SELECT BCI_CODPEG CODPEG, BCI_CODRDA CODRDA, BCI_FASE FASE, BCI_CODLDP CODLDP" // inverter cod peg e cod rda 
cSql += " FROM " + RetSqlName("BCI") + " BCI "
cSql += " WHERE BCI_FILIAL = ? "
cSql += " AND   BCI_CODPEG = ? "
cSql += " AND   BCI_CODRDA = ? " 
cSql += " AND   D_E_L_E_T_ = ? "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial("BCI"))
oFwQuery:SetString(2, cCodpeg)
oFwQuery:SetString(3, cCodRda)
oFwQuery:SetString(4, ' ')
cSql   := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

return cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valGui
valida se alguma guia foi faturada/consolidade/cobrada/contabilizada
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/

static function valGui(cFase,cCodpeg,cNumGui,cCodRda,lLoteGuia)

local lret := .F.
local cSql := ""

	if cFase != "4"

		cSql := " SELECT 1 FROM " + RetsqlName("BD6") // 
		cSql += " WHERE "
		cSql += " BD6_FILIAL = '" + xfilial("BD6") + "' AND "
		cSql += " BD6_CODPEG = '" + cCodpeg + "' AND "
		if (!lLoteGuia)
			cSql += " BD6_NUMERO = '" + cNumGui+ "' AND "
		endif
		cSql += " BD6_CODRDA = '" + cCodRda + "' AND "
		cSql += " BD6_SEQPF <> ' ' AND"
		cSql += " D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"cAliasBD6",.F.,.T.)

		IF (cAliasBD6->(EOF()))

			cSql := " SELECT 1 FROM " + RetsqlName("BD7") // 
			cSql += " WHERE "
			cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
			cSql += " BD7_CODPEG = '" + cCodpeg + "' AND "
			if (!lLoteGuia)
				cSql += " BD7_NUMERO = '" + cNumGui+ "' AND "
			endif
			cSql += " BD7_CODRDA = '" + cCodRda + "' AND "
			cSql += " BD7_LA <> ' ' AND "
			cSql += " BD7_LAPRO <> ' ' AND "
			cSql += " D_E_L_E_T_ = ' ' "

			dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"cAliasBD7",.F.,.T.)	

			if (cAliasBD7->(EOF()))
				lret := .t.
			endif 

			cAliasBD7->(dbcloseArea())
		endif
		cAliasBD6->(dbcloseArea())
	endif

return lret 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} attStatus
Se todas validações estiverem ok para o cancelamento da guia/lote.
-  BD5/BE4, BD6 e BD7 para 2 - Status
-  BCI_SITUAC = '2', BCI_STTISS = '4' (LOTE/CANELADO)
-  valor de pagamento (campos _VLRPAG) para zero
-  valor de coparticipação (campos _VLTTPF/_VLRPF) para zero
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/

static function attStatus(cTipGui, cCodpeg,cCodLDP,cCodOpe,cNumGui,lLoteGuia)

local cBd5Be4   := ""
local cSql      := ""
local cAliasBD6 := ""
local cAliasBD7 := ""
local cAliasBCI := ""
local lErro 	:= .t. // verifica se não deu erro em nenhum update.

 BEGIN TRANSACTION

	iif(cTipGui != "05",cBd5Be4 := "BD5",cBd5Be4 := "BE4") // se o tipo de guia for != 5, pegar bd5 se não be4

		cSql := " UPDATE " + retSQLName(cBd5Be4)
		cSql += " SET "+cBd5Be4+"_SITUAC = '2', "+cBd5Be4+"_VLRPAG = 0, "+cBd5Be4+"_VLRTPF = 0, "+cBd5Be4+"_VLRPF = 0 "
		cSql += " WHERE "
		cSql += cBd5Be4+"_FILIAL = '" +xfilial(cBd5Be4) + "' AND "
		cSql += cBd5Be4+"_CODOPE = '" + cCodOpe + "' AND "
		cSql += cBd5Be4+"_CODLDP = '" + cCodLDP + "' AND "
		cSql += cBd5Be4+"_CODPEG = '" + cCodpeg + "' AND "
		if (!lLoteGuia)
			cSql += cBd5Be4+"_NUMERO = '" + cNumGui + "' AND "
		endif
		cSql += " D_E_L_E_T_ = ' ' "


		lErro := tcSqlExec( cSql ) < 0
 
	if(!lErro)

		cAliasBD6 := " UPDATE " + retSQLName("BD6")
		cAliasBD6 += " SET BD6_SITUAC = '2', BD6_VLRPAG = 0, BD6_VLRTPF= 0, BD6_VLRPF = 0 "
		cAliasBD6 += " WHERE "
		cAliasBD6 += " BD6_FILIAL = '" + xfilial("BD6") + "' AND "
		cAliasBD6 += " BD6_CODOPE = '" + cCodOpe + "' AND "
		cAliasBD6 += " BD6_CODLDP = '" + cCodLDP+ "'  AND "
		cAliasBD6 += " BD6_CODPEG = '" + cCodpeg + "' AND " 
		if (!lLoteGuia)
			cAliasBD6 += " BD6_NUMERO = '" + cNumGui + "' AND "
		endif
		cAliasBD6 += " D_E_L_E_T_ = ' ' "

		lErro := tcSqlExec( cAliasBD6 ) < 0

		if(!lErro)

			cAliasBD7 := " UPDATE " + retSQLName("BD7")
			cAliasBD7 += " SET BD7_SITUAC = '2', BD7_VLRPAG = 0, BD7_VLRTPF= 0 "
			cAliasBD7 += " WHERE "
			cAliasBD7 += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
			cAliasBD7 += " BD7_CODOPE = '" + cCodOpe + "' AND "
			cAliasBD7 += " BD7_CODLDP = '" + cCodLDP+ "'  AND "
			cAliasBD7 += " BD7_CODPEG = '" + cCodpeg + "' AND " 
			if (!lLoteGuia)
				cAliasBD7 += " BD7_NUMERO = '" + cNumGui + "' AND "
			endif
			cAliasBD7 += " D_E_L_E_T_ = ' ' "

			lErro := tcSqlExec( cAliasBD7 ) < 0
   			
			if (!lErro .and. lLoteGuia) // caso for cancelamento por lote 

				cAliasBCI := " UPDATE " + retSQLName("BCI")
				cAliasBCI += " SET BCI_SITUAC = '2', BCI_STTISS = '4' "
				cAliasBCI += " WHERE "
				cAliasBCI += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
				cAliasBCI += " BCI_CODOPE = '" + cCodOpe + "' AND "
				cAliasBCI += " BCI_CODLDP = '" + cCodLDP+ "'  AND "
				cAliasBCI += " BCI_CODPEG = '" + cCodpeg + "' AND " 
				cAliasBCI += " D_E_L_E_T_ = ' ' "

				lErro := tcSqlExec( cAliasBCI ) < 0

			endif
		endif 
	endif

	iif(lErro,disarmTransaction(),PLPEGTOT()) // se algum update der erro, não irá atualizar nenhuma das tabelas. Caso não der erro irá atualizar os campos da BCI baseado na(s) guia(s) canceladas.

END TRANSACTION

return lErro

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaXmlLot
Monta xml de cancelamento de lote 
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/

static function montaXmlLot(cSeqTran,cRegisANS,cOrigem,cVerArq,cNumLote,cNumProtoc,cStatusCan) 

local cXml		 := ""
Local cPathXML	 := "" 
local cFileHASH  := ""
local cDataAtu 	 := DtoS(DatE())
local cHash 	 := ""

Private nArqHash := 0

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" ) //formatação

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML
		Return(cRet)
	EndIf
EndIf

nArqHash 	:= fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F.)

cXml := A270Tag( 1,'soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#"',''	,.T.,.F.,.T., .F. )
cXml += A270Tag( 2,"soapenv:Header/"			,''						    ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'soapenv:Body'	       		,''	   						,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'ans:reciboCancelaGuiaWS'	,''	   						,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			    ,''						    ,.T.,.F.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao" ,''						 	,.T.,.F.,.T., .F. )
cXml += A270Tag( 5,"ans:tipoTransacao"			,'CANCELAMENTO_GUIA_RECIBO' ,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:sequencialTransacao"	,cSeqTran				 	,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:horaRegistroTransacao"	,time()				 		,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao"	,''							,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:origem"	                ,''					        ,.T.,.F.,.T., .F. ) // origem recebe destino
cXML += A270Tag( 5,"ans:registroANS"	        ,cRegisANS	                ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:origem"	                ,''	                        ,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	            ,''					        ,.T.,.F.,.T., .F. ) // destino recebe origem 
cXml += A270Tag( 5,"ans:identificacaoPrestador"	,''					        ,.T.,.F.,.T., .F. )

If Len(cOrigem) == 11 //CPF
	cXml += A270Tag( 5,"ans:CPF"				       ,cOrigem ,.T.,.T.,.T., .F. )
elseif Len(cOrigem) == 14 //CNPJ
	cXml += A270Tag( 5,"ans:CNPJ"				       ,cOrigem ,.T.,.T.,.T., .F. )
else 
	cXml += A270Tag( 5,"ans:codigoPrestadorNaOperadora",cOrigem ,.T.,.T.,.T., .F. )
endif

cXml += A270Tag( 5,"ans:identificacaoPrestador",''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	           ,''	    		,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:Padrao"	           	   ,cVerArq	        ,.T.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			   ,''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,'ans:reciboCancelaGuia'     ,''	   			,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,'ans:reciboCancelaGuia'     ,''	   			,.T.,.F.,.T., .F. )
cXML += A270Tag( 4,"ans:registroANS"	       ,cRegisANS	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,'ans:dadosPrestador'        ,''	   			,.T.,.F.,.T., .F. )

If Len(cOrigem) == 11 //CPF
	cXml += A270Tag( 5,"ans:cpfContratado"				       ,cOrigem ,.T.,.T.,.T., .F. )
elseif Len(cOrigem) == 14 //CNPJ
	cXml += A270Tag( 5,"ans:cnpjContratado"				       ,cOrigem ,.T.,.T.,.T., .F. )
else 
	cXml += A270Tag( 5,"ans:codigoPrestadorNaOperadora"		   ,cOrigem ,.T.,.T.,.T., .F. )
endif

cXml += A270Tag( 4,"ans:dadosPrestador"			,''     	    ,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,'ans:retornoStatus'          ,''	   			,.T.,.F.,.T., .F. )
cXml += A270Tag( 5,'ans:loteCancelado'          ,''	   			,.T.,.F.,.T., .F. )
cXML += A270Tag( 5,"ans:numeroLote"	            ,cNumLote	    ,.T.,.T.,.T., .F. )
cXML += A270Tag( 5,"ans:numeroprotocolo"	    ,cNumProtoc	    ,.T.,.T.,.T., .F. )
cXML += A270Tag( 5,"ans:statusCancelamento"	    ,cStatusCan	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:loteCancelado"	        ,''	            ,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:retornoStatus"	        ,''	            ,.F.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:reciboCancelaGuia"	    ,''	            ,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:reciboCancelaGuia"	    ,''	            ,.F.,.T.,.T., .F. )
fClose( nArqHash )
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
cXml += A270Tag( 2,"ans:hash"						    ,cHash				 		,.T.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:reciboCancelaGuiaWS"			,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Body"						,''     					,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Envelope"					,''     					,.F.,.T.,.T., .F. )

return cXml


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaXmlGui
Monta xml de cancelamento de guia 
@author    Daniel Silva 
@version   P12
@since     24/06/2022
/*/

static function montaXmlGui(cSeqTran,cRegisANS,cOrigem,cVerArq,aRet,cNomeContr)


local cXml		 := ""
Local cPathXML	 := "" 
local cFileHASH  := ""
local cDataAtu 	 := DtoS(DatE())
local cHash 	 := ""
local nx 		 := 1 
Private nArqHash := 0
default cSeqTran 	:= ""	
default cRegisANS 	:= ""	
default cOrigem 	:= ""	
default cVerArq 	:= ""	
default aRet 		:= {}
default cNomeContr 	:= ""

cFileHASH 	:= CriaTrab(NIL,.F.) + ".tmp"
cPathXML 	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\")+"online\TEMP\" ) //formatação

If( !existDir( cPathXML ) )
	If( MakeDir( cPathXML ) <> 0 )
		cRet := "Não foi possível criar o diretorio no servidor:"+cPathXML
		Return(cRet)
	EndIf
EndIf

nArqHash 	:= fCreate( Lower( cPathXML+cFileHASH ),FC_NORMAL,,.F.)

cXml := A270Tag( 1,'soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xd="http://www.w3.org/2000/09/xmldsig#"',''	,.T.,.F.,.T., .F. )
cXml += A270Tag( 2,"soapenv:Header/"			,''						    ,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'soapenv:Body'	       		,''	   						,.T.,.F.,.T., .F. )
cXML += A270Tag( 2,'ans:reciboCancelaGuiaWS'	,''	   						,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			    ,''						    ,.T.,.F.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao" ,''						 	,.T.,.F.,.T., .F. )
cXml += A270Tag( 5,"ans:tipoTransacao"			,'CANCELAMENTO_GUIA_RECIBO' ,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:sequencialTransacao"	,cSeqTran				 	,.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:dataRegistroTransacao"	,substr(cDataAtu, 1, 4) + "-" + substr(cDataAtu, 5, 2) + "-" + substr(cDataAtu, 7, 2),.T.,.T.,.T., .F. )
cXml += A270Tag( 5,"ans:horaRegistroTransacao"	,time()				 		,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:identificacaoTransacao"	,''							,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:origem"	                ,''					        ,.T.,.F.,.T., .F. ) // origem recebe destino
cXML += A270Tag( 5,"ans:registroANS"	        ,cRegisANS	                ,.T.,.T.,.T., .F. )

cXml += A270Tag( 4,"ans:origem"	                ,''	                        ,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	            ,''					        ,.T.,.F.,.T., .F. ) // destino recebe origem 
cXml += A270Tag( 5,"ans:identificacaoPrestador"	,''					        ,.T.,.F.,.T., .F. )

If Len(cOrigem) == 11 //CPF
	cXml += A270Tag( 5,"ans:CPF"				       ,cOrigem ,.T.,.T.,.T., .F. )
elseif Len(cOrigem) == 14 //CNPJ
	cXml += A270Tag( 5,"ans:CNPJ"				       ,cOrigem ,.T.,.T.,.T., .F. )
else 
	cXml += A270Tag( 5,"ans:codigoPrestadorNaOperadora",cOrigem ,.T.,.T.,.T., .F. )
endif

cXml += A270Tag( 5,"ans:identificacaoPrestador",''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:destino"	           ,''	    		,.F.,.T.,.T., .F. )
cXml += A270Tag( 4,"ans:Padrao"	           	   ,cVerArq	        ,.T.,.T.,.T., .F. )
cXml += A270Tag( 3,"ans:cabecalho"			   ,''	   			,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,'ans:reciboCancelaGuia'     ,''	   			,.T.,.F.,.T., .F. )
cXml += A270Tag( 3,'ans:reciboCancelaGuia'     ,''	   			,.T.,.F.,.T., .F. )
cXML += A270Tag( 4,"ans:registroANS"	       ,cRegisANS	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 4,'ans:dadosPrestador'        ,''	   			,.T.,.F.,.T., .F. )

If Len(cOrigem) == 11 //CPF
	cXml += A270Tag( 5,"ans:cpfContratado"				       ,cOrigem ,.T.,.T.,.T., .F. )
elseif Len(cOrigem) == 14 //CNPJ
	cXml += A270Tag( 5,"ans:cnpjContratado"				       ,cOrigem ,.T.,.T.,.T., .F. )
else 
	cXml += A270Tag( 5,"ans:codigoPrestadorNaOperadora"		   ,cOrigem ,.T.,.T.,.T., .F. )
endif
if cVerArq < "4"
	cXml += A270Tag( 5,"ans:nomeContratado"				       	,cNomeContr ,.T.,.T.,.T., .F. )
endif
cXml += A270Tag( 4,"ans:dadosPrestador"			,''     	    ,.F.,.T.,.T., .F. )
if cVerArq < "4"
	cXml += A270Tag( 4,"ans:guiasCanceladas"        ,''	   		,.T.,.F.,.T., .F. )
	For nX := 1 to len(aRet)

		cXml += A270Tag( 5,'ans:dadosGuia'             	    ,''	   			,.T.,.F.,.T., .F. )
		cXML += A270Tag( 5,"ans:numeroGuiaPrestador"		,aRet[nX][2]	,.T.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:tipoGuia"					,aRet[nX][1]	,.T.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:statusCancelamento"	    	,aRet[nX][5]	,.T.,.T.,.T., .F. )
		cXml += A270Tag( 5,"ans:dadosGuia"			    	,''	   			,.F.,.T.,.T., .F. )
	next
	cXml += A270Tag( 4,"ans:guiasCanceladas"		,''	   		,.F.,.T.,.T., .F. )
else
	cXml += A270Tag( 4,'ans:retornoStatus'          ,''	   			,.T.,.F.,.T., .F. )
	cXml += A270Tag( 4,'ans:guiasCanceladas'        ,''	   			,.T.,.F.,.T., .F. )

	For nX := 1 to len(aRet)

		cXml += A270Tag( 5,'ans:dadosGuia'             	    ,''	   			,.T.,.F.,.T., .F. )
		cXML += A270Tag( 5,"ans:tipoGuia"					,aRet[nX][1]	,.T.,.T.,.T., .F. )
		cXML += A270Tag( 5,"ans:numeroGuiaPrestador"		,aRet[nX][2]	,.T.,.T.,.T., .F. )

		if(!empty(aRet[nX][3]))
			cXML += A270Tag( 5,"ans:numeroGuiaOperadora"	,aRet[nX][3]	,.T.,.T.,.T., .F. )
		endif

		if(aRet[nX][1] != "1" .and. !empty(aRet[nX][4]))
			cXML += A270Tag( 5,"ans:numeroProtocolo"	    ,aRet[nX][4]	,.T.,.T.,.T., .F. )
		endif

		cXML += A270Tag( 5,"ans:statusCancelamento"	    	,aRet[nX][5]	,.T.,.T.,.T., .F. )
		cXml += A270Tag( 5,"ans:dadosGuia"			    	,''	   			,.F.,.T.,.T., .F. )

	next

	cXml += A270Tag( 4,"ans:guiasCanceladas"			    ,''	   		,.F.,.T.,.T., .F. )
	cXml += A270Tag( 4,"ans:retornoStatus"	        		,''	        ,.F.,.T.,.T., .F. )
endif	
cXml += A270Tag( 3,"ans:reciboCancelaGuia"	    	    ,''	        ,.F.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:reciboCancelaGuia"	   	        ,''	        ,.F.,.T.,.T., .F. )
fClose( nArqHash )
cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
cXml += A270Tag( 2,"ans:hash"						    ,cHash	    ,.T.,.T.,.T., .F. )
cXml += A270Tag( 2,"ans:reciboCancelaGuiaWS"			,''         ,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Body"						,''         ,.F.,.T.,.T., .F. )
cXml += A270Tag( 1,"soapenv:Envelope"					,''     	,.F.,.T.,.T., .F. )


return cXml

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} cancelGlosa
realiza o cancelamento de glosa, e suas devidas validações.
@author    Daniel Silva 
@version   P12
@since     124/06/2022
/*/

static function cancelGlosa (cNumProtoc,lLote)

Local oModel 	:= nil
local lUltimo 	:= .f.
Local lStatusok := .F.

B4D->(DbSetOrder(8))
If B4D->(MsSeek(xFilial("B4D") + cNumProtoc))
	lStatusok := !(B4D->B4D_STATUS $ '3,4,5')
	if lStatusok
		lUltimo	:= StaticCall(PLSRECGLO2,UltRecPegGui,B4D->B4D_OPEMOV, B4D->B4D_CODLDP, B4D->B4D_CODPEG, alltrim(B4D->B4D_NUMAUT), iif(B4D->B4D_OBJREC == "1", .t., .f.), .t., B4D->(recno()))
		if(lUltimo)

			oModel := FWLoadModel( 'PLSRECGLO2' )
			oModel:SetOperation( 5 )
			oModel:Activate()

			If (oModel:VldData() )
				cCritica := "1" // cencelado com sucesso 
				oModel:CommitData()
			else  
				cCritica := "2" //NÃO CANCELADO
			endif
		endif
	endif

	if !lStatusok .OR. !lUltimo
		cCritica := "2" // NÃO CANCELADO
	endif
else 
	if(lLote)
		cCritica := "5" //Lote inexistente
	else 
		cCritica := "3" // guia inexistente 
	ENDIF
endif 

return cCritica

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} cSequenBX6
Tratamento para enviar o BX6_SEQUEN
@author    Eduardo Bento
@version   P12
@since     21/09/2022
/*/

static function cSequenBX6 (cVerArq)

local cSEQUEN	:= ""
default cVerArq := "3.04.00"

if cVerArq >= "3.04.00"
	if empty(Demoanali->(BX6_SQTISS)) 
		cSEQUEN := DemoAnali->(BD6_SEQUEN)
	else
		cSEQUEN := Demoanali->(BX6_SQTISS)
	endif
else
	cSEQUEN := "1"
endIf

return cSEQUEN
