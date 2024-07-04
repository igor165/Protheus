#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TOPConn.ch'
#INCLUDE 'TMSAE80.ch'
#INCLUDE "FWCOMMAND.CH"     
#INCLUDE "FILEIO.CH"    

Static lTMA050FOB := ExistBlock("TMA050FOB")
Static lTME80NEG  := ExistBlock("TME80NEG")

//----------------------------------------------------------
/*	 Integração Totvs Colaboração Notas Fiscais de Clientes
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		15/06/2012
@return 	Nil														  	  */
//----------------------------------------------------------
Function TMSAE80(aParam,cParEmp,cParFil, aNFs)

Local aFiles  	:= {}
Local nX		:= 0
Local aProc		:= {}
Local aErros	:= {}
Local lErrDir	:= .T.
Local nContErr  := 0 
Local lNewColab := .F.
Local nHandle	:= 0
Local nLength	:= 0
Local cXMLOri	:= ""
Local lConvAsc	:= FindFunction("ConvAsc")
Local lDE5    	:= .F.
Local lCont     := .T.
Local bErrorBkp := ErrorBlock({|e| TMSAE80ERR(e)})
Local cArqAE80  := ""

Default aNFs	:= {}

If IsSrvUnix()
	Private DIRXML    := "XMLNFE/"
	Private DIRALER   := "NEW/"
	Private DIRLIDO   := "OLD/"
	Private DIRERRO   := "ERR/" 
Else
	Private DIRXML    := "XMLNFE\"
	Private DIRALER   := "NEW\"
	Private DIRLIDO   := "OLD\"
	Private DIRERRO   := "ERR\" 
EndIf

Begin Sequence

	If !Empty(cParEmp) .And. !Empty(cParFil)
		aParam := {cParEmp,cParFil}
	ElseIf Empty(cParEmp) .And. Empty(cParFil) ;
	       .And. Type("cEmpAnt") != "U" .And. !Empty(cEmpAnt) ;
	       .And. Type("cFilAnt") != "U" .And. !Empty(cFilAnt)
		aParam := {cEmpAnt,cFilAnt}		
	ElseIf Empty(aParam) .Or. ValType(aParam) != "A" .Or. Len(aParam) < 2
		Break
	EndIf
	
	If IsBlind()
		RpcSetType(3)
		lCont := RpcSetEnv(aParam[1],aParam[2],,,"TMS","TMSAE80")
	EndIf
	
	If lCont
		
		//-- Chamada do Schedule para o TOTVS Colaboração 2.0
		lNewColab := ColUsaColab('6') .Or. ColUsaColab('0')
		If lNewColab .And. AllTrim(SuperGetMv("MV_TCIMP",,"0")) == "1" //0 = Importação Colab / 1 = Importação SIGATMS 
			lNewColab := .F.
		EndIf 
		
		If lNewColab
			SchdTMSCol(aParam)
		Else
			If !ExistDir(DIRXML)     
				MakeDir(DIRXML)
				MakeDir(DIRXML +DIRALER)
				MakeDir(DIRXML +DIRLIDO)
				MakeDir(DIRXML +DIRERRO)
			EndIf
				
			//---------------------------------------------------------
			//³ Busca os documentos NF-e validados pela NEOGRID       ³
			//---------------------------------------------------------
		
			If lNewColab .And. ((!FindFunction("FWLSEnable") .Or. !FWLSEnable(TOTVS_COLAB_ONDEMAND)) .and. !FwEmpTeste())
				TmsLogMsg("WARN",STR0005) //--Este ambiente não está licenciado para uso de TOTVS Colaboração.
			EndIf	
		
			//---------------------------------------------------------
			//³ Processa importacao dos arquivos baixados		      ³
			//---------------------------------------------------------
			If IsSrvUnix()				
				aFiles := Directory("/" +DIRXML +DIRALER +"*.xml")				
				If !len(aFiles) >= 1
                 aFiles := Directory("/" +DIRXML +DIRALER +"*.XML")
				EndIf 
			Else
				aFiles := Directory("\" +DIRXML +DIRALER +"*.xml")             
			EndIf

			If !Empty(aNFs)
				For nX := 1 to Len(aNFs)
					If Ascan(aNFs, { |x| x[1] == Substr(aFiles[nX][1], 1, 44)}) == 0
						 ADel( aFiles, nX )
  						 Asize(aFiles, Len(aFiles) - 1)
					EndIf
				Next nX
			EndIf

			For nX := 1 To Len(aFiles)
				cXml := ""						
				If File(DIRXML + DIRALER +aFiles[nX,1]) .And. LockByName(aFiles[nX,1], .T., .F.)
					cArqAE80 := aFiles[nX,1] //-- utilizado no Recover
					lDE5 := .T.
					nHandle := FOpen(DIRXML + DIRALER +aFiles[nX,1])
					nLength := FSeek(nHandle,0,FS_END)
					FSeek(nHandle,0)
					If nHandle > 0
						FRead(nHandle, cXMLOri, nLength)
						FClose(nHandle)
						
						If !Empty(cXMLOri)
							
							If SubStr(cXMLOri,1,1) != "<"
								nPosPesq := At("<",cXMLOri)
								cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))	// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
							EndIf
							
							cXML := DecodeUTF8(cXMLOri)
							
							If Empty(cXML)
								cXML := cXMLOri
							EndIf
							
							If lConvAsc
								cXML := ConvAsc(cXML) //remove acentuação
							EndIf
							
							cXML := A140IRemASC(cXML)	//remove caracteres especiais não aceitos pelo encode
						
							cXML := EncodeUtf8(cXML)
							
							If Empty(cXML)
								cXML := cXMLOri
							EndIf
						EndIf 
					Endif					
				
					If !Empty(cXML) 
						TmsLogMsg(,"Leitura Arquivo: " + aFiles[nX,1])
						
						nContErr := Len(aErros)
						ImpXML_NFe(aFiles[nX,1],.T.,@aProc,@aErros,lDE5,,,cXml)			

						lErrDir := If(   Len(aErros) = nContErr, .F., .T. )
						If !lNewColab .And. lErrDir 
							//-- Move arquivo para pasta dos erros
							Copy File &(DIRXML+DIRALER+aFiles[nX,1]) To &(DIRXML+DIRERRO+aFiles[nX,1])
							FErase(DIRXML+DIRALER+aFiles[nX,1])													
						ElseIf !lNewColab .And. !lErrDir  
							//-- Move arquivo para pasta dos processados	pelo SIGATMS
							Copy File &(DIRXML+DIRALER+aFiles[nX,1]) To &(DIRXML+DIRLIDO+aFiles[nX,1])
							FErase(DIRXML+DIRALER+aFiles[nX,1])							
						EndIf	
						UnLockByName(aFiles[nX,1], .T., .F.)	
					EndIf
					cArqAE80 := ""
				EndIf							
			Next nX
		EndIf		
		
		//------------------------------------------------------------
		//³ Verifica a existencia de e-mails para o evento 052       ³
		////----------------------------------------------------------
		If !Empty(aErros)
			MEnviaMail("052",aErros)	
		EndIf
		
		//------------------------------------------------------------
		//³ Verifica a existencia de e-mails para o evento 053       ³
		//------------------------------------------------------------
		If !Empty(aProc)
			MEnviaMail("053",aProc)
		EndIf
	
		If IsBlind()
			RpcClearEnv()
		EndIf

	EndIf
Recover
	If !Empty(cArqAE80) .And. File(DIRXML+DIRALER+cArqAE80)
		//-- Move arquivo para pasta dos erros
		Copy File &(DIRXML+DIRALER+cArqAE80) To &(DIRXML+DIRERRO+cArqAE80)
		FErase(DIRXML+DIRALER+cArqAE80)
	EndIf
End Sequence
ErrorBlock(bErrorBkp)

aFiles := aSize(aFiles,0)
aFiles := Nil

Return Nil

//----------------------------------------------------------
/*	 Gravação das Notas Fiscais eletronicas nao importadas
{Protheus.doc} TMSAE85Grv
@author  	Leandro Paulino
@version 	P11 R1.7
@parametros cArquivo = Nome do Arquivo da NFe
				cChvNfe  = Numero da chave da NFe
				cDocto   = Numero da NFe
				cSerie   = Série da NFe
				cCGC  	= CNPJ do Remetente
				cMotivo  = Motivo da Não Integração da NFe
@build		7.00.111010P
@since 		15/06/2012
@return 	Nil										  	  				*/
//----------------------------------------------------------
Function TMSAE80Grv(cArquivo, cChvNfe, cNumDoc, cSerie, cCGCRem, cMotivo,cDetalhe)

Local cHoraBase  := StrTran(Left(Time(),5),':','')

Default cArquivo := ""
Default cChvNfe  := ""
Default cSerie	  := ""
Default cCGCRem  := ""
Default cMotivo  := ""
Default cDetalhe := ""

Begin Transaction
	DEV->(dbSetOrder(1))
	If !DEV->(dbSeek(xFilial("DEV")+cChvNfe))
		RecLock('DEV',.T.)	
		DEV->DEV_FILIAL := xFilial("DEV")
	 	DEV->DEV_ARQUIV := cArquivo
		DEV->DEV_NFEID	:= cChvNfe                
		DEV->DEV_DOC	:= cNumDoc  
		DEV->DEV_SERIE	:= cSerie
		DEV->DEV_CGCREM := cCGCRem
		DEV->DEV_MOTERR := cMotivo
		DEV->DEV_DETERR := cDetalhe
		DEV->DEV_STATUS := '1'	
		DEV->DEV_DATIMP := dDataBase
		DEV->DEV_HORIMP := cHoraBase
		MsUnLock('DEV')	
	Else
	 	RecLock('DEV',.F.)	
		DEV->DEV_STATUS := '1'		
		DEV->DEV_MOTERR := cMotivo
		DEV->DEV_DETERR := cDetalhe 
		DEV->DEV_DATIMP := dDataBase
		DEV->DEV_HORIMP := cHoraBase
		MsUnLock('DEV')	
	EndIf	
End Transaction 

If ExistBlock("TME80ALT")
	ExecBlock("TME80ALT",.F.,.F.,{"DEV",,})
EndIf

Return Nil                             

//------------------------------------------------------------
/*	Monta Array e chama a ExecAuto de Cliente e NotaFiscal-EDi
{Protheus.doc} TMSAE85Inc
@author  	Leandro Paulino
@version 	P11 R1.7                                  

@param 		oAE80XML		Objeto com o Parser do XML da NF do Cliente
@param		nTipo 	Tipo de Cliente que sera cadastrado:
							1 - Destinatário
							2 - Local de Entrega
							3 - EDI Nota Fiscal do Cliente
@param		aProdutos 1ªPosicao : Codigo Produtoo
							 2ªPosicao : Codigo Embalagem (Unidade de Medida)
							 3ªPosicao : Quantidade Volume (Quantidade Produto)
							 4ªPosicao : Valor do Produto
							 5ªPosicao : Unidade de medida utilizada no Produto
@param		cCFoP   	CFOP do Primeiro Produto 
@param		cMotivo 	Motivo do Erro na Importacao da NFe
@param		cSerie   Numero do Detalhe do Erro
@param		cProduto Detalhe do Erro na Importacao da NFe

@build		7.00.111010P
@since 		15/06/2012
@return 	Nil										  	  				*/
//----------------------------------------------------------
Function TMSAE80Inc(oAE80XML,nTipo,aProdutos,cCFOP,cMotivo,nNumDet,cDetalhe,cSeqEnd,cIDEstrang)

Local aArea		:= GetArea()
Local nCount  	:= 0		
Local aHeadSA1	:= {}   
Local aHeadDUL 	:= {}                      
Local aHeadDE5 	:= {}    
Local lRet			:= .T.
Local oXmlDes		:= Nil   
Local oXmlRem		:= Nil 
Local oXmlExp       := Nil //-- Usado quando existir a tag <retirada>
Local oXmlRec       := Nil //-- Usado quando existir a tag <entrega>
Local cCGCRem		:= ""
Local cCGCDes		:= ""
Local cCGCExp       := "" //-- Expedidor
Local cCGCRec       := "" //-- Recebedor
Local oAuxXML		:= Nil  
Local oAE80XMLDes	:= Nil
Local oAINFNFE	:= Nil
Local oAuxEMI		:= Nil
Local oXmlEmi		:= Nil
Local cTpFrete 	:= ""
Local aColsDE5 	:= {}
Local aItemDE5	:= {}
Local nOpcx		:= 3                     
Local nX		   	:= 0
Local nTamProd 	:= 0
Local cCGCDev  	:= ""
Local cCliDev  	:= ""
Local cLojDev		:= ""                                   
Local aItContrat 	:= ''                         
Local cProGen		:= SuperGetMV('MV_PROGEN',.F.,"")
Local cCodPro		:= ''
Local cCodEmb 	:= ''
Local nQtdVol 	:= 0
Local nPosPro		:= 0					
Local nVlrPrd		:= 0
Local nPesoL		:= 0
Local nPesoB		:= 0     
Local aQtdVol		:= {}
Local dEmis		:= CtoD("//")
Local aCli			:= {}
Local lINSCEDI		:= SuperGetMv( "MV_INSCEDI", .F., .F. ) .And. FindFunction("TMS75IEDI")	//-- Parametro da Importação do EDI pela Incrição estadual do Destinatario.
Local cDoc			:= ""
Local cSerie		:= "" 
Local lDE5PESLIQ	:= DE5->(ColumnPos("DE5_PESLIQ")) > 0
Local lIMPEMIT	:= SuperGetMv( "MV_IMPEMIT", .F., .F. ) //--Parametro para cadastro do Emitente via EDI     
Local cCGC		  	:= ""
Local lItePrd 		:= SuperGetMV('MV_PRDITEM',.F.,.F.) //--Considera o valor total da NF quando o PRDDIV esta desativado
Local aAreaSA1		:= {}
Local cCNPJDUL 	 	:= ""
Local cPlaRB1       := "" 
Local cPlaRB2       := "" 
Local cPlaRB3       := "" 
Local aPerfil       := {}
Local cEDIFRX       := "" //-- Frete XML: 1-Sim;2-Não
Local cEDICMP       := "" //-- Componente Frete XML
Local cEDIFrt       := "" //-- Assume frete 
Local oModel
Local cLotEDI       := ""
Local aRet := {}
Local cTipFre := ""

Local cSerTms := ""
Local cTipTra := ""

Local cCliCal := ""
Local cLojCal := ""
Local aRetUsr := {}
Local lChkCliGen  := .T.
Local lDE5_IDESTR := DE5->(ColumnPos('DE5_IDESTR')) > 0

Private lAutoErrNoFile	:= .T.
Private lMsErroAuto		:= .F.
Private INCLUI      := .T. //Variavel necesseria para o ExecAuto identificar que se trata de uma inclusao
Private ALTERA      := .F. //Variavel necesseria para o ExecAuto identificar que se trata de uma inclusao

Default oAE80XML 	:= Nil
Default nTipo 	    := 1
Default cCFOP 	    := ""
Default cMOtivo	    := ""
Default cDetalhe	:= ""                  
Default cSeqEnd	    := ""
Default nNumDet	    := 0
Default aProdutos	:= {}
Default cIDEstrang  := ""

If nTipo == 1	

	//--Informações da Tag INFNFE
	oAINFNFE := oAE80XML
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Emitente				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lIMPEMIT  
		//-- Tags do Emitente
		If XmlChildEx(oAINFNFE,"_EMIT") # Nil		
			
			oXmlEmi := XmlChildEx(oAINFNFE,"_EMIT")
			oAuxEMI := XmlChildEx(oXmlEmi,"_ENDEREMIT")
			
			If XmlChildEx(oXmlEmi,"_CNPJ") # NIL
				cCGC := oXmlEmi:_CNPJ:TEXT
			Elseif XmlChildEx(oXmlEmi:_EMIT,"_CPF") # NIL
				cCGC := oXmlEmi:_CPF:TEXT
			EndIf		
						
			SA1->(dbSetOrder(3))	
			If !SA1->(dbSeek(xFilial('SA1')+AllTrim(cCGC)))		
				TMS80Inc2(oXmlEmi,oAuxEMI,@nNumDet,@cDetalhe,@cMotivo)	
			EndIf	
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Destinatario			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If XmlChildEx(oAE80XML,"_DEST") # Nil 
		oAE80XML := XmlChildEx(oAE80XML,"_DEST")	
		oAuxXml  := XmlChildEx(oAE80XML,"_ENDERDEST")  
		lRet 	 := TMS80Inc2(oAE80XML,oAuxXml,@nNumDet,@cDetalhe,@cMotivo,cIDEstrang)		
	EndIf	

ElseIf nTipo == 2

	oAuxXml		:= XmlChildEx(oAE80XML,"_EMIT")
	oAE80XMLDes	:= XmlChildEx(oAE80XML,"_DEST")
	oAE80XML	:= XmlChildEx(oAE80XML,"_ENTREGA")	

	SA1->(dbSetOrder(3))
	
	If (XmlChildEx(oAE80XMLDes,"_CNPJ") # NIL .And. !Empty(oAE80XMLDes:_CNPJ:TEXT)) .Or. ( XmlChildEx(oAE80XMLDes,"_CPF") # NIL.And. !Empty(oAE80XMLDes:_CPF:TEXT))

		If lINSCEDI .And. DE5->(ColumnPos('DE5_INSCRE')) > 0 .And. DE5->(ColumnPos('DE5_INSDES')) > 0 .And. DE5->(ColumnPos('DE5_INSDEV')) > 0 
			If SA1->(dbSeek(xFilial("SA1")+If(XmlChildEx(oAE80XMLDes,"_CNPJ") # NIL,oAE80XMLDes:_CNPJ:TEXT,oAE80XMLDes:_CPF:TEXT)))
				cCgcDes := oAE80XMLDes:_CNPJ:TEXT
				If XmlChildEx(oAE80XMLDes, "_IE") # Nil 
					cIEDes  := oAE80XMLDes:_IE:TEXT
				Else
					cIEDes  := ""	
				EndIf
				aCli 	 := TMS75IEDI(cCgcDes,cIEDes )
				If !Empty(aCli)
					Aadd(aHeadDUL,{"DUL_CODCLI", aCli[1]	    			 		 			 , Nil })
					Aadd(aHeadDUL,{"DUL_LOJCLI", aCli[2]						 			   	 , Nil })
					Aadd(aHeadDUL,{"DUL_NOME" 	, SA1->A1_NOME    				 				 , Nil })
					Aadd(aHeadDUL,{"DUL_END"	, oAE80XML:_xLgr:Text + ', ' + oAE80XML:_nro:Text, Nil })
					Aadd(aHeadDUL,{"DUL_BAIRRO", oAE80XML:_xBairro:Text							 , Nil })   
					Aadd(aHeadDUL,{"DUL_MUN"	, oAE80XML:_xMun:Text							 , Nil })
					If XmlChildEx(oAE80XML,"_CEP") <> Nil
						Aadd(aHeadDUL,{"DUL_CEP"	, oAE80XML:_CEP:Text						 , Nil })
					EndIf
					Aadd(aHeadDUL,{"DUL_EST", oAE80XML:_UF:Text									 , Nil })   
					Aadd(aHeadDUL,{"DUL_CODMUN", SubsTr(oAE80XML:_cMun:Text,3,5)				 , Nil }) 

					//-- Atualiza o campo ref.ao redespacho já que passou a ser utilizado para o preenchimento do Recebedor na entrada de NF Cliente(TMSA050)
					cCNPJDUL := If(XmlChildEx(oAE80XML,"_CNPJ") <> NIL, oAE80XML:_CNPJ:TEXT, oAE80XML:_CPF:TEXT)
					If !Empty(cCNPJDUL)
						aCli := TMS75IEDI(cCNPJDUL)
						If !Empty(aCli) .And. (cCNPJDUL <> If(XmlChildEx(oAE80XMLDes,"_CNPJ") # NIL,oAE80XMLDes:_CNPJ:TEXT,oAE80XMLDes:_CPF:TEXT))
							Aadd( aHeadDUL, { "DUL_CODRED", aCli[1] , NIL } )
							Aadd( aHeadDUL, { "DUL_LOJRED", aCli[2] , NIL } )
							Aadd( aHeadDUL, { "DUL_CGC"   , cCNPJDUL, NIL } )
							If XmlChildEx( oAE80XML, "_XNOME" ) # NIL
								Aadd( aHeadDUL, { "DUL_NOMRED", PadR(oAE80XML:_xNome:Text, Len(DUL->DUL_NOMRED)), NIL } )
							EndIf
							If XmlChildEx( oAE80XML, "_IE" ) # NIL
								Aadd( aHeadDUL, { "DUL_INSCR"  , PadR(oAE80XML:_IE:Text,   Len(DUL->DUL_INSCR)) , NIL } )
							EndIf
						EndIf
					EndIf
					aCli	:= aSize(aCli, 0)
					cCgcDes := ""
					cIEDes  := "" 				
                EndIf
			EndIf
		Else
			If SA1->(dbSeek(xFilial("SA1")+If(XmlChildEx(oAE80XMLDes,"_CNPJ") # NIL,oAE80XMLDes:_CNPJ:TEXT,oAE80XMLDes:_CPF:TEXT)))
				Aadd(aHeadDUL,{"DUL_CODCLI", SA1->A1_COD				 		 				, Nil })
				Aadd(aHeadDUL,{"DUL_LOJCLI", SA1->A1_LOJA						 				, Nil })
				Aadd(aHeadDUL,{"DUL_NOME"  , SA1->A1_NOME    				 				    , Nil })
				Aadd(aHeadDUL,{"DUL_END"   , oAE80XML:_xLgr:Text + ', ' + oAE80XML:_nro:Text    , Nil })
				Aadd(aHeadDUL,{"DUL_BAIRRO", oAE80XML:_xBairro:Text							    , Nil })   
				Aadd(aHeadDUL,{"DUL_MUN"   , oAE80XML:_xMun:Text								, Nil })
				If XmlChildEx(oAE80XML,"_CEP") <> Nil
					Aadd(aHeadDUL,{"DUL_CEP"   , oAE80XML:_CEP:Text							    , Nil })
				EndIf
				Aadd(aHeadDUL,{"DUL_EST"   , oAE80XML:_UF:Text									, Nil })   
				Aadd(aHeadDUL,{"DUL_CODMUN", SubsTr(oAE80XML:_cMun:Text,3,5)				    , Nil })  
				//-- Atualiza o campo ref.ao redespacho já que passou a ser utilizado para o preenchimento do Recebedor na entrada de NF Cliente(TMSA050)
				cCNPJDUL := If(XmlChildEx(oAE80XML,"_CNPJ") <> NIL, oAE80XML:_CNPJ:TEXT, oAE80XML:_CPF:TEXT)
				If !Empty(cCNPJDUL)
					aCli := TMS75IEDI(cCNPJDUL)
					If !Empty(aCli) .And. (cCNPJDUL <> If(XmlChildEx(oAE80XMLDes,"_CNPJ") # NIL,oAE80XMLDes:_CNPJ:TEXT,oAE80XMLDes:_CPF:TEXT))
						Aadd( aHeadDUL, { "DUL_CODRED", aCli[1] , NIL } )
						Aadd( aHeadDUL, { "DUL_LOJRED", aCli[2] , NIL } )
						Aadd( aHeadDUL, { "DUL_CGC"   , cCNPJDUL, NIL } )
						If XmlChildEx( oAE80XML, "_XNOME" ) # NIL
							Aadd( aHeadDUL, { "DUL_NOMRED", PadR(oAE80XML:_xNome:Text, Len(DUL->DUL_NOMRED)), NIL } )
						EndIf
						If XmlChildEx( oAE80XML, "_IE" ) # NIL
							Aadd( aHeadDUL, { "DUL_INSCR"  , PadR(oAE80XML:_IE:Text,   Len(DUL->DUL_INSCR)) , NIL } )
						EndIf
					EndIf
				EndIf
			EndIf 		
		EndIf
	EndIf
   
    Begin Transaction
        MSExecAuto({|x,y| TMSA450(x,y)},aHeadDUL,3)
    End Transaction
    
    If lMsErroAuto                    
        nNumDet 	+= 1
        cDetalhe += Str(nNumDet,1)+ "º " +STR0001//--"Erro: "
        aErroAuto := GetAutoGRLog()
        For nCount := 1 To Len(aErroAuto)
            cDetalhe += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
        Next nCount	
        cDetalhe += CRLF                   			
        cMotivo := Iif(Empty(cMotivo), STR0003, STR0010)//--"Sequência de Endereço"//--Ocorreram erros na Importacao do XML.
        lRet := .F. 
    Else		
        cSeqEnd := DUL->DUL_SEQEND
    EndIf
	
ElseIf nTipo == 3

	oAuxXml	:= XmlChildEx(oAE80XML,"_INFNFE")
	oXmlRem	:= XmlChildEx(oAuxXml,"_EMIT")
	oXmlDes	:= XmlChildEx(oAuxXml,"_DEST")
    //-- Tags do Recebedor e Expedidor
    oXmlExp := XmlChildEx(oAuxXml,"_RETIRADA")
    oXmlRec := XmlChildEx(oAuxXml,"_ENTREGA")
    //-- Tag do Endereço do Emitente da NF
	oAuxEMI := XmlChildEx(oXmlRem,"_ENDEREMIT")

	If ExistBlock("TME80IMP")
		lRet := ExecBlock("TME80IMP",.F.,.F.,{oAE80XML,aHeadDE5,nOpcx,aColsDE5, "1"})				
	EndIf	

	If Alltrim(oAuxXml:_TRANSP:_modFrete:Text) == '2' .OR. Alltrim(oAuxXml:_TRANSP:_modFrete:Text) == '3' .OR. Alltrim(oAuxXml:_TRANSP:_modFrete:Text) == '4'
		cDetalhe += STR0011 //"Não é possível importar Notas Fiscais de Cliente com a TAG ModFrete igual a 2 (Frete por responsabilidade de terceiros), 3 (Transporte Próprio por conta do Remetente) ou 4 (Transporte Próprio por conta do Destinatário), pois não caracterizam prestações de serviços de transporte efetuada por uma transportadora."
		lRet := .F.
	EndIf 

    If lINSCEDI .And. DE5->(ColumnPos('DE5_INSCRE')) > 0 .And. DE5->(ColumnPos('DE5_INSDES')) > 0 .And. DE5->(ColumnPos('DE5_INSDEV')) > 0 
	    
	    //--Busca CNPJ do remetente                                          
	    If XmlChildEx(oXmlRem,"_CNPJ") # NIL                               
			cCgcRem := oXmlRem:_CNPJ:TEXT
		ElseIf XmlChildEx(oXmlRem,"_CPF") # NIL
			cCgcRem	:= oXmlRem:_CPF:TEXT	
		EndIf

		//--Busca IE do remetente
		IF XmlChildEx(oXmlRem,"_IE") # NIL 
			cIERem  := oXmlRem:_IE:TEXT
		Else
			cIERem  := "ISENTO"
		EndIF
				
		//--Busca CNPJ do destinatario
		If XmlChildEx(oXmlDes,"_CNPJ") # NIL
			cCgcDes := oXmlDes:_CNPJ:TEXT
		ElseIf XmlChildEx(oXmlDes,"_CPF") # NIL
			cCgcDes :=oXmlDes:_CPF:TEXT
		EndIf	
		//--Busca IE do destinatario	
		IF XmlChildEx(oXmlDes,"_IE") # NIL 
			cIEDes  := oXmlDes:_IE:TEXT
		Else
			cIEDes  := "ISENTO"
		EndIF                    
		
		cDoc     := StrZero(Val(AllTrim(oAuxXml:_Ide:_nNF:Text)),TamSx3("F1_DOC")[1])
		cSerie   := AllTrim(oAuxXml:_Ide:_Serie:Text)
		
		//--Busca tipo de frete e define CNPJ e IE do devedor
		cTpFrete := AllTrim(oAuxXml:_TRANSP:_modFrete:Text)
		cCGCDev  :=IIf(cTpFrete =='0' ,cCgcRem,If(cTpFrete=='1',cCgcDes,""))
		cIEDev	 :=IIf(cTpFrete =='0' ,cIERem,If(cTpFrete=='1',cIEDes,""))
		
		//--Busca codigo e loja do devedor pelo CNPJ e IE
		dbSelectArea("SA1")
		SA1->(dbSetOrder(3))
		IF SA1->(dbSeek(xFilial("SA1")+cCGCDev))
			While !SA1->(EOF()) .AND. SA1->A1_CGC = cCGCDev
				IF SA1->A1_INSCR = cIEDev
					cCliDev  	:= SA1->A1_COD
					cLojDev 	:= SA1->A1_LOJA
				    Exit
				EndIF            
				SA1->(dbSkip())
			EndDO
		EndIF 
    Else  
    	//--Busca CNPJ do remetente                                          
	    If XmlChildEx(oXmlRem,"_CNPJ") # NIL                               
			cCgcRem := oXmlRem:_CNPJ:TEXT
		ElseIf XmlChildEx(oXmlRem,"_CPF") # NIL
			cCgcRem	:= oXmlRem:_CPF:TEXT	
		EndIf
		//--Busca CNPJ do destinatario
		If XmlChildEx(oXmlDes,"_CNPJ") # NIL
			cCgcDes := oXmlDes:_CNPJ:TEXT
		ElseIf XmlChildEx(oXmlDes,"_CPF") # NIL
			cCgcDes :=oXmlDes:_CPF:TEXT	
		EndIf
		cDoc     := StrZero(Val(AllTrim(oAuxXml:_Ide:_nNF:Text)),TamSx3("F1_DOC")[1])
		cSerie   := AllTrim(oAuxXml:_Ide:_Serie:Text)
		cTpFrete := AllTrim(oAuxXml:_TRANSP:_modFrete:Text)
		cCGCDev  := IIf(cTpFrete =='0' ,cCgcRem,If(cTpFrete=='1',cCgcDes,""))
		cCliDev  := Posicione('SA1',3,xFilial('SA1')+cCGCDev,'A1_COD')
		cLojDev  := SA1->A1_LOJA
	EndIf

    //-- Busca o CNPJ do Expedidor
    If ValType(oXMLEXP) <> "U"
        If XmlChildEx(oXmlExp,"_CNPJ") <> NIL
            cCGCExp := oXmlExp:_CNPJ:TEXT
        ElseIf XmlChildEx(oXmlExp,"_CPF") <> NIL
            cCGCExp := oXmlExp:_CPF:TEXT
        EndIf
		//Cadastra o Expedidor
		aAreaSA1 := SA1->(GetArea())
		SA1->(dbSetOrder(3))	
		If !SA1->(dbSeek(xFilial('SA1') + AllTrim(cCGCExp)))
			TMS80Inc2(oXmlExp,oXmlExp,@nNumDet,@cDetalhe,@cMotivo)	
		EndIf
		RestArea(aAreaSA1)
    EndIf

    //-- Busca o CNPJ do Recebedor
    If ValType(oXMLREC) <> "U"
        If XmlChildEx(oXmlRec,"_CNPJ") <> NIL
            cCGCRec := oXmlRec:_CNPJ:TEXT
        ElseIf XmlChildEx(oXmlRec,"_CPF") <> NIL
            cCGCRec := oXmlRec:_CPF:TEXT
        EndIf
		//Cadastra o Recebedor
		aAreaSA1 := SA1->(GetArea())
		SA1->(dbSetOrder(3))	
		If !SA1->(dbSeek(xFilial('SA1') + AllTrim(cCGCRec)))
			TMS80Inc2(oXmlRec,oXmlRec,@nNumDet,@cDetalhe,@cMotivo)	
		EndIf
		RestArea(aAreaSA1)
    EndIf
	
	If ValType(XmlChildEx(oAuxXml:_Transp,"_VOL")) == "O"
		aQtdVol := {oAuxXml:_Transp:_Vol}
	ElseIf ValType(XmlChildEx(oAuxXml:_Transp,"_VOL")) == "A"
		aQtdVol := oAuxXml:_Transp:_Vol
	EndIf	
	
	For nX := 1 To Len(aQtdVol)
		If ValType(XmlChildEx(aQtdVol[nX],"_PESOB")) == "O"
			nPesoB += Val(aQtdVol[nX]:_PESOB:TEXT)
		EndIf
		If ValType(XmlChildEx(aQtdVol[nX],"_PESOL")) == "O"
			nPesoL += Val(aQtdVol[nX]:_PESOL:TEXT)
		EndIf
		If ValType(XmlChildEx(aQtdVol[nX],"_QVOL")) == "O"
			nQtdVol += Val(aQtdVol[nX]:_QVol:TEXT)
		EndIf
	Next nX
	
	cTipFre :=  IIf(cTpFrete == '0', '1', IIf(cTpFrete == '1', '2', ''))
	If ExistBlock("TME80FRE")
		cTipFre := ExecBlock("TME80FRE",.F.,.F.,{oAE80XML})
		If ValType(cTipFre) != "C" .Or. !cTipFre $ "123"
			cTipFre := ""
		EndIf
	EndIf

	//-- Define o cliente de cálculo
	DefCliCal(cTipFre,cCGCRem,cCGCDes,cCliDev,cLojDev,@cCliCal,@cLojCal,@lChkCliGen)

	//----------------------------------------------------------------------------------
	//³Pesquisa O Serviço e tipo de transporte contratado pelo Tomador do Serviço
	//----------------------------------------------------------------------------------	
	TMSPesqServ('DE5'/*cAlias*/, cCliCal /*cCodCli*/, cLojCal /*cLojCli*/,    /*cSerTMS*/,  /*cTipTra */,  @aItContrat/*aItContrat*/;
							   ,.F.      /*lMostra*/, cTipFre /*cTipFre*/, .T./*lRotAuto*/, /*cDocTms */,lChkCliGen   /*lChkCliGen*/, /*cTabFre   */;
						       ,         /*cTipTab*/,         /*cVigCon*/, .F./*lHelp   */, /*cCdrOri */,             /*cCdrDes   */, /*lPortalTMS*/;
						       ,         /*lRateio*/,         /*cBACRAT*/,    /*cCRIRAT */, /*cPRORAT */,             /*cTABRAT   */, /*cTIPRAT   */;
						       ,         /*cCodNeg*/,         /*cCampo */, .T./*lEDI*/)   	
						      
	cCodNeg := ""
	cSerVic := ""
	If !Empty(aItContrat)
    	cCodNeg := aItContrat[1,6]
		cSerVic := aItContrat[1,3]
		cSerTms := Posicione ('DC5',1,xFilial('DC5')+aItContrat[1,3],'DC5_SERTMS')
		cTipTra := DC5->DC5_TIPTRA
	EndIf

	If lTME80NEG
		aRetUsr := ExecBlock("TME80NEG",.F.,.F.,{cCliCal,cLojCal,cCliDev,cLojDev,cCGCRem,cCGCDes,cTipFre,cTipTra,cSerTMS,cCodNeg,cServic})
		If ValType(aRetUsr) == "A" .And. Len(aRetUsr) == 6
			cCliCal := aRetUsr[1]
			cLojCal := aRetUsr[2]
			cCodNeg := aRetUsr[3]
			cServic := aRetUsr[4]
			cSerTMS := aRetUsr[5]
			cTipTra := aRetUsr[6]
		EndIf
	EndIf

	If ValType(XmlChildEx(oAE80XML:_InfNfe:_Ide,"_DEMI")) == "O"
		dEmis := StoD(StrTran(AllTrim(oAE80XML:_InfNfe:_Ide:_DEmi:Text),"-",""))
	ElseIf ValType(XmlChildEx(oAE80XML:_InfNfe:_Ide,"_DHEMI")) == "O"
		dEmis := StoD(StrTran(Substr((oAE80XML:_InfNfe:_Ide:_DhEmi:Text),1,10),"-",""))
	EndIf

	//-- Verifica valor do Frete de acordo com o perfil para o devedor
	If lRet	
		//-- Busca o Perfil para verificar se considera o valor do Frete
		aPerfil := TmsPerfil(cCliCal,cLojCal,.F.,.F.)
		If !Empty(aPerfil) .And. Len(aPerfil) >= 63
			cEDIFRX := aPerfil[63] //-- Frete XML: 1-Sim;2-Não
			cEDICMP := aPerfil[64] //-- Componente Frete XML
			cEDIFrt := aPerfil[52] //-- 1 = Assume Frete CIF/FOB ou 2 = Apenas Informativo  ou 3 Assume CIF ou 4 Assume FOB

			//-- Verifica se a TAG de valor do frete existe no XML
			If cEDIFRX == "1" .And. ;
				(cEDIFrt == "1" .Or. (cEDIFrt == "3" .And. cTipFre == "1") .Or.(cEDIFrt == "4" .And. cTipFre == "2") ) .And.;
				(ValType(XmlChildEx(oAE80XML:_InfNfe:_Total:_ICMSTot,"_VFRETE")) != "O" ;
				.Or. Empty(Val(oAE80XML:_InfNfe:_Total:_ICMSTot:_vFrete:Text)) )

				cDetalhe += STR0012 + cCGCDev + STR0013 //"TAG vFrete zerada ou não encontrada - O perfil para o cliente " - " indica a utilização dessa tag - Valor do Frete"
				lRet := .F.
			EndIf

			//-- Verifica se o componente selecionado no Perfil existe
			If lRet .And. cEDIFRX == "1"
				DT3->(DbSetOrder(1)) //-- DT3_FILIAL+DT3_CODPAS
				If Empty(cEDICMP) .Or. !DT3->(DbSeek(xFilial("DT3")+cEDICMP))
					cDetalhe += STR0014 + cCGCDev + " " + STR0015 //"Componente do frete vazio ou não encontrado no perfil do cliente " - "Verique, no perfil, o componente e/ou a opção pelo Valor do frete no XML"
					lRet := .F.
				EndIf
			EndIf

			//-- Tenta Incluir registro na tabela DET e guarda o Lote na DE5
			If lRet .And. cEDIFRX == "1" .And.;
			(ValType(XmlChildEx(oAE80XML:_InfNfe:_Total:_ICMSTot,"_VFRETE")) == "O" ;
			.And. !Empty(Val(oAE80XML:_InfNfe:_Total:_ICMSTot:_vFrete:Text)) )
				oModel := FwLoadModel("TMSAE56")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
					
				oModel:SetValue( "TMSE56IDET", "DET_ITEM"		, StrZero(1,TamSX3("DET_ITEM")[1]) /*uValue*/)
				oModel:SetValue( "TMSE56IDET", "DET_CODPAS"		, cEDICMP /*uValue*/)
				oModel:SetValue( "TMSE56IDET", "DET_VALOR"		, Val(oAE80XML:_InfNfe:_Total:_ICMSTot:_vFrete:Text) /*uValue*/)
				//--Valor Com imposto
				oModel:SetValue( "TMSE56IDET", "DET_TIPVAL"		, "1" /*uValue*/) //-- Valor com Imposto
				If !oModel:VldData() .Or. !oModel:CommitData()
					cDetalhe += STR0016 + oModel:GetErrorMessage()[6]  //"Falha ao Incluir Lote EDI - " 
					lRet := .F.
				Else
					cLotEDI := oModel:GetValue( "TMSE56CDET", "DET_LOTEDI")
				EndIf
				oModel:DeActivate()
				oModel := Nil
			EndIf
		EndIf
	EndIf

	If lRet
		DE5->(DbSetOrder(1))
		If !DE5->(DbSeek(xFilial("DE5") + PadR(cCGCRem, Len(DE5->DE5_CGCREM)) + cDoc + cSerie ) )
		    
			//-- Analisa se o remetente existe pois quando o destinatário existe o programa não passa pela geração do remetente
			If lIMPEMIT
				SA1->(dbSetOrder(3))	
				If !SA1->(dbSeek(xFilial('SA1') + AllTrim(cCGCRem)))
					TMS80Inc2(oXmlRem,oAuxEMI,@nNumDet,@cDetalhe,@cMotivo)	
				EndIf
			EndIf
			
			If !Empty(cIDEstrang) // Quando for EX tem que passar "00000000000000"
				cCgcDes := "00000000000000"
			EndIf
			//-----------------------------------------
			//³Monta Array e chama ExecAuto do TMSAE55³
			//-----------------------------------------
			Aadd(aHeadDE5,{"DE5_CGCREM" ,cCGCRem																						, Nil }) //CGC Remetente
			Aadd(aHeadDE5,{"DE5_DTAEMB"	,dDataBase																						, Nil }) //Data Embarque
			Aadd(aHeadDE5,{"DE5_CGCDES"	,cCGCDes																						, Nil }) //CGC Destinatário
			Aadd(aHeadDE5,{"DE5_CGCDEV"	,cCGCDev																						, Nil }) //CGC Devedor
			Aadd(aHeadDE5,{"DE5_TIPFRE"	,IIf(cTpFrete == "0","1"	 ,If(cTpFrete=='1',"2",""))											, Nil }) //Tipo de Frete (1=CIF,2=FOB)
			Aadd(aHeadDE5,{"DE5_DOC"	,cDoc																							, Nil }) //Numero da Nf-e
			Aadd(aHeadDE5,{"DE5_SERIE"	,cSerie													 										, Nil }) //Serie da NF
			Aadd(aHeadDE5,{"DE5_EMINFC"	,dEmis																							, Nil }) //Emissão Nota Fiscal do Cliente
			Aadd(aHeadDE5,{"DE5_NFEID"	,Right(AllTrim(oAE80XML:_InfNfe:_Id:Text),44)													, Nil }) //CHAVE DA NF-E
			Aadd(aHeadDE5,{"DE5_CFOPNF"	,AllTrim(cCFOP)	 																				, Nil }) //CFOP DO PRODUT*/
			Aadd(aHeadDE5,{"DE5_SEQEND"	,cSeqEnd																						, Nil }) //Sequencia de Endereco
			If !Empty(cTipTra)
				Aadd(aHeadDE5,{"DE5_TIPTRA"	,cTipTra         																				, Nil }) //Tipo de Transporte
			EndIf
			If !Empty(cCGCRem) .And. !Empty(cCGCDes) .And. !Empty(cCGCDev) .And. !Empty(cTipTra) .And. !Empty(cTipFre) .And. !Empty(cSerTMS)
				Aadd(aHeadDE5,{"DE5_SERTMS"	,cSerTms         																				, Nil }) //Servico de Transporte
			EndIf
			Aadd(aHeadDE5,{"DE5_CODNEG"	,cCodNeg         																				, Nil }) //Cód de negociacao

			If !Empty(cCGCRem) .And. !Empty(cCGCDes) .And. !Empty(cCGCDev) .And. !Empty(cTipTra) .And. !Empty(cTipFre)
				Aadd(aHeadDE5,{"DE5_SERVIC"	,cSerVic         																				, Nil }) //Servico de Transporte
			EndIf
			If !Empty(cLotEDI)
				Aadd(aHeadDE5,{"DE5_LOTEDI"	,cLotEDI        																				, Nil }) //Lote Edi
			EndIf
			If lINSCEDI .And. DE5->(ColumnPos('DE5_INSCRE')) > 0 .And. DE5->(ColumnPos('DE5_INSDES')) > 0 .And. DE5->(ColumnPos('DE5_INSDEV')) > 0
				Aadd(aHeadDE5,{"DE5_INSCRE"		,cIERem         																		, Nil}) //Inscricao estadual do remetente
				Aadd(aHeadDE5,{"DE5_INSDES"		,cIEDes        																			, Nil}) //Inscricao estadual do destinatario
				Aadd(aHeadDE5,{"DE5_INSDEV"		,cIEDev  																				, Nil}) //Inscricao estadual do devedor 
			EndIf
			//-- Verifica placa do veículo
			If XmlChildEx(oAuxXml,"_VEICTRANSP") # Nil  .And. DE5->(ColumnPos('DE5_PLACA')) > 0
				Aadd(aHeadDE5,{"DE5_PLACA"		,AllTrim(oAuxXml:_VEICTRANSP:_Placa:Text)     											, Nil}) //Placa veiculo tracionador
			EndIf
			//-- Verifica placa dos Reboques
			If XmlChildEx(oAuxXml,"_REBOQUE") # Nil  

				//-- Primeiro Reboque
				If DE5->(ColumnPos('DE5_PLARB1')) > 0
					cPlaRB1 := ""
					If ValType(XmlChildEx(oAuxXml,"_REBOQUE")) == "O"
						cPlaRB1 := AllTrim(oAuxXml:_REBOQUE:_PLACA:Text)
					ElseIf ValType(XmlChildEx(oAuxXml,"_REBOQUE")) == "A"
						cPlaRB1 := AllTrim(oAuxXml:_REBOQUE[1]:_PLACA:Text)
					EndIf	
					Aadd(aHeadDE5,{"DE5_PLARB1"		,cPlaRB1        																	, Nil}) // 1º Reboque

					//-- Segundo Reboque
					If DE5->(ColumnPos('DE5_PLARB2')) > 0 .And. ValType(XmlChildEx(oAuxXml,"_REBOQUE")) == "A" .And. Len(XmlChildEx(oAuxXml,"_REBOQUE")) >= 2
						cPlaRB2 := AllTrim(oAuxXml:_REBOQUE[2]:_PLACA:Text)
						Aadd(aHeadDE5,{"DE5_PLARB2"		,cPlaRB2        																, Nil}) // 2º Reboque

						//-- Terceiro Reboque
						If DE5->(ColumnPos('DE5_PLARB3')) > 0 .And. ValType(XmlChildEx(oAuxXml,"_REBOQUE")) == "A" .And. Len(XmlChildEx(oAuxXml,"_REBOQUE")) >= 3
							cPlaRB3 := AllTrim(oAuxXml:_REBOQUE[3]:_PLACA:Text)
							Aadd(aHeadDE5,{"DE5_PLARB3"		,cPlaRB3    																, Nil}) // 3º Reboque
						EndIf
					EndIf
				EndIf
			EndIf

			//-- Verifica a Filial da transportadora - utilizado para o TMSAE75S (EDI Automático via Scheduller)
			If XmlChildEx(oAuxXml:_TRANSP,"_TRANSPORTA") # NIL .And.;
			   (XmlChildEx(oAuxXml:_TRANSP:_Transporta,"_CNPJ") # NIL .Or.;
			    XmlChildEx(oAuxXml:_TRANSP:_Transporta,"_CPF") # NIL)
				Aadd(aHeadDE5,{"DE5_FILORI"		,cFilAnt		, Nil}) //Filial para processo automático ae75S
			EndIf

            //-- Adiciona o Expedidor / Recebedor 
            If DE5->(ColumnPos("DE5_CGCEXP")) > 0
                Aadd(aHeadDE5,{"DE5_CGCEXP"	,cCGCExp																					, Nil  })  //CGC Destinatário
				If !Empty(cCGCExp)
					Aadd(aHeadDE5,{"DE5_SELORI"	,"3"																					, Nil  })  //CGC Destinatário
				EndIf
            EndIf
            If DE5->(ColumnPos("DE5_CGCREC")) > 0
                Aadd(aHeadDE5,{"DE5_CGCREC"	,cCGCRec																					, Nil  })  //CGC Destinatário
            EndIf
			
			If lDE5_IDESTR
				Aadd(aHeadDE5,{"DE5_IDESTR"	,cIDEstrang																					, Nil  })  //ID Estrageiro
			EndIf

			nTamProd := Len(aProdutos)			
			
			If !SuperGetMV ('MV_PRDDIV',.F.,.F.) .And. (nTamProd > 1 .Or. lItePrd) //--Se o MV_PRDDIV estiver ativo importa todos os produtos da NF-e, caso contrario importa apenas o primeiro Produto		
				aItemDE5 := {}                			
				Aadd( aItemDE5, {"DE5_CODPRO"	,cProgen																												, Nil	} )  //Produto   
				Aadd( aItemDE5, {"DE5_CODEMB"	,Posicione('SB1',1,xFilial('SB1')+cProgen,IIf (aProdutos[1,5] == '2','B1_SEGUM','B1_UM'))	, Nil	} )  //Embalagem do Primeiro Produto
				Aadd( aItemDE5, {"DE5_VALOR"	,Val(oAE80XML:_InfNfe:_Total:_IcmsTot:_vNF:Text)															 	, Nil	} )  //Valor da NF-e
				Aadd( aItemDE5, {"DE5_QTDVOL"	,nQtdVol, Nil	} )  //Qtde de Volumes
				Aadd( aItemDE5, {"DE5_PESO"  	,Iif(nPesoB >= nPesoL, nPesoB, nPesoL), Nil	} )  //Peso - considera o maior 
				If lDE5PESLIQ
					Aadd( aItemDE5, {"DE5_PESLIQ"  	,nPesoL, Nil	} )  //DLOGTMS01-748 - Armazenamento do Peso Líquido
				EndIf
				Aadd(aColsDE5,aClone(aItemDE5))
				
			Else //--Se o parametro estiver habilitado ou existir apenas um produto pega os dados de todos os produtos existentes no XML
				For nX := 1 To nTamProd
					aItemDE5 := {} 								
					If (Empty(aProdutos[nX,1]))
						cCodPro := cProGen
						cCodEmb := Posicione('SB1',1,xFilial('SB1')+cProgen,IIf (aProdutos[1,5] == '2','B1_SEGUM','B1_UM'))
						If Len(aProdutos) > 1
							nVlrPrd :=  Val(oAE80XML:_InfNfe:_Det[nX]:_PROD:_vPROD:Text)
						Else
							nVlrPrd :=  Val(oAE80XML:_InfNfe:_Det:_PROD:_vPROD:Text)
						EndIf
					Else
						cCodPro := aProdutos[nx,1]
						cCodEmb := aProdutos[nx,2]
						nVlrPrd := aProdutos[nx,4]
					EndIf
					nPosPro := Ascan(aColsDE5,{|x|Alltrim(x[1,2])==AllTrim(cCodPro)})				
					If nPosPro > 0
						aColsDE5[nPosPro,3,2] += nVlrPrd				
					Else	
						Aadd( aItemDE5, {"DE5_CODPRO"	,cCodPro, Nil} )  //Produto   
						Aadd( aItemDE5, {"DE5_CODEMB"	,cCodemb	, Nil} )  //Cod.Embalagem   
						Aadd( aItemDE5, {"DE5_VALOR"	,nVlrPrd , Nil} )  //Valor da NF-e
						If nX == 1  //Executa somente a primeira vez
							Aadd( aItemDE5, {"DE5_QTDVOL"	,nQtdVol , Nil} )  //Qtd Volumes
							Aadd( aItemDE5, {"DE5_PESO"		,Iif(nPesoB >= nPesoL, nPesoB, nPesoL) , Nil} )  //Peso - considera o maior
							If lDE5PESLIQ
								Aadd( aItemDE5, {"DE5_PESLIQ"  	,nPesoL, Nil	} )  //DLOGTMS01-748 - Armazenamento do Peso Líquido
							EndIf
						EndIf	
						Aadd(aColsDE5,aClone(aItemDE5))                             
					EndIf	
					
				Next nX								
			
			EndIf							

			If ExistBlock("TME80ALT")
				aRet := ExecBlock("TME80ALT",.F.,.F.,{"DE5",aHeadDE5, aColsDE5, oAE80XML, aItContrat})
				If Len(aRet) == 2 .And. ValType(aRet[1]) == "A" .And. ValType(aRet[2]) == "A"
					aHeadDE5 := Aclone(aRet[1])
					aColsDE5 := Aclone(aRet[2])
				EndIf
			EndIf
			
			If ExistBlock("TME80IMP")
				lRet := ExecBlock("TME80IMP",.F.,.F.,{oAE80XML,aHeadDE5,nOpcx,aColsDE5, "2"})				
			EndIf						

			If lRet			
				Begin Transaction					
			    	MSExecAuto({|x,y,z| TMSAE55(x,y,z)},aHeadDE5,nOpcx,aColsDE5)					
				End Transaction
			EndIf						
			
			If lMsErroAuto
				nNumDet 	+= 1
				cDetalhe += Str(nNumDet,1)+"º " + STR0001 //--Erro:
				aErroAuto := GetAutoGRLog()
				For nCount := 1 To Len(aErroAuto)
					cDetalhe += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
				Next nCount         		
				cMotivo  := IIf(Empty(cMotivo), STR0004,STR0010)//--""Gravacao EDI"//--Ocorreram erros na Importacao do XML.
				lRet := .F. 				
			EndIf
								
		Else
			nNumDet 	+= 1                                         
			cDetalhe += Str(nNumDet,1)+"º " + STR0001 //--Erro:
			cDetalhe += STR0009  + cCGCDev
			lRet := .F.
			cMotivo  := "NF JA IMPORTADA: " + cCGCRem +"/"+ cDoc +"-"+ cSerie
			TmsLogMsg(, "NF JA IMPORTADA: " + cCGCRem +"/"+ cDoc +"-"+ cSerie)
		EndIf
	EndIf
EndIf	

aHeadSA1	:= aSize(aHeadSA1, 0)
aHeadSA1	:= Nil
aHeadDUL 	:= aSize(aHeadDUL, 0)
aHeadDUL 	:= Nil
aHeadDE5 	:= aSize(aHeadDE5, 0)
aHeadDE5 	:= Nil
aColsDE5 	:= aSize(aColsDE5, 0)
aColsDE5 	:= Nil
aItemDE5	:= aSize(aItemDE5, 0)
aItemDE5	:= Nil
aQtdVol		:= aSize(aQtdVol, 0)
aQtdVol		:= Nil
aProdutos 	:= aSize(aProdutos, 0)
aProdutos 	:= Nil

oAE80XML		:= Nil
oAE80XMLDes	:= Nil
oAuxXml		:= Nil
oXmlRem		:= Nil
oXmlDes		:= Nil

RestArea(aArea)
Return ( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SchdTMSCol ºAutor  ³FABIO MARCHIORI SAMPº Data ³  08/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para ser schedulada e processar a importacao dos     º±±
±±º          ³ arquivos TOTVS Colaboracao 2.0                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aParam: array de parametros recebidos do schedule Protheus. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGATMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SchdTMSCol(aParam)
Local aProc		:= {}
Local aErros	:= {}
Local aXMLs		:= {}
Local aErroERP 	:= {}
Local aDocs		:= {"198"} //Recebimento NF-e do Transportador
Local nX		:= 1
Local nY		:= 1
Local lOk		:= .F.
Local oColab	:= NIL

For nX := 1 To Len(aDocs)    
	oColab 			:= ColaboracaoDocumentos():New()
	oColab:cQueue 	:= aDocs[nX]
	oColab:cModelo 	:= ""
	oColab:cTipoMov := '2'
	oColab:cFlag 	:= '0'
	oColab:cFilProc := cFilAnt
	
	oColab:buscaDocumentosFilial()
	
	If !Empty(oColab:aNomeArq)
		aXMLs := oColab:aNomeArq
				
		For nY := 1 To Len(aXMLs)
			oColab:cNomeArq := aXMLs[nY,1]
			oColab:cFlag := '0'
			oColab:Consultar()
			cXml := oColab:cXmlRet
			oColab:cNomeArq := aXMLs[nY,1]
           	lOk :=  ImpXML_NFe(aXMLs[nY,1],IsBlind(),@aProc,@aErros,.T.,,,cXml,@aErroErp)     
			
			If lOk
				oColab:cFlag := '1'
			Else
				If !Empty(aErros)
					oColab:cFlag := '2'
				Else
					oColab:cFlag := '0'
				Endif
				If !Empty(aErroERP)
					oColab:cCodErrErp := aErroERP[1][2]
					oColab:gravaErroErp()
				Endif
			Endif
			oColab:FlegaDocumento()
		Next nY
	Endif
	
	//-- Dispara M-Messenger para erros (evento 052)
	If !Empty(aErros)
		MEnviaMail("052",aErros)
		aErros	:= {}
	EndIf
	
	//-- Dispara M-Messenger para docs disponiveis (evento 053)
	If !Empty(aProc)
		MEnviaMail("053",aProc)
		aProc	:= {}
	EndIf

	aXMLs 	:= {}
	oColab	:= NIL
Next nX

Return	 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |TMS80Inc2  ºAutor  ³  Alex Amaral    º Data ³  01/06/18      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para ser schedulada e processar a importacao dos     º±±
±±º          ³ do Destinatario e Remetente                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aParam:objetos de parametros recebidos do schedule Protheus.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGATMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMS80Inc2(oAE80XML,oAuxXml,nNumDet,cDetalhe,cMotivo,cIDEstrang)
Local aHeadSA1	:= {} 
Local cCGCDes	:= ""
Local cCdrDes	:= ""      
Local lRet		:= .T.
Local cPais		:= ""
Local cDDD		:= ""
Local cTel		:= ""
Local nCount  	:= 0
Local cErroTag  := ""
Local cCEP      := ""
Local cTipo     := ""
Local cPessoa   := ""

Default cMOtivo		:= ""
Default cDetalhe	:= ""            
Default nNumDet		:= 0
Default oAE80XML 	:= Nil
Default oAuxXml 	:= Nil
Default cIDEstrang  := ""

    //Valida Tags mínimas obrigatórias
    If XmlChildEx(oAE80XML,"_CNPJ") == Nil .And. XmlChildEx(oAE80XML,"_CPF") == Nil
        If Empty(cIDEstrang)
			cErroTag += "TAG <CNPJ> ou <CPF> não encontrada." + CRLF
		EndIf
	EndIf
    If XmlChildEx(oAuxXml,"_CPAIS") == Nil
        cErroTag += "TAG <cPais> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAuxXml,"_UF") == Nil
        cErroTag += "TAG <UF> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAuxXml,"_CMUN") == Nil
        cErroTag += "TAG <cMun> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAuxXml,"_XMUN") == Nil
        cErroTag += "TAG <xMun> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAE80XML,"_XNOME") == Nil
        cErroTag += "TAG <xNome> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAuxXml,"_XLGR") == Nil
        cErroTag += "TAG <xLgr> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAuxXml,"_NRO") == Nil
        cErroTag += "TAG <Nro> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAuxXml,"_XBAIRRO") == Nil
        cErroTag += "TAG <xBairro> não encontrada." + CRLF
    EndIf
    If XmlChildEx(oAuxXml,"_CEP") == Nil
        If Empty(cIDEstrang)
			cErroTag += "TAG <CEP> não encontrada." + CRLF
		EndIf
	EndIf

	If !Empty(cErroTag)
        nNumDet  += 1
        cDetalhe += Str(nNumDet,1)+"º " + STR0001 + CRLF //--Erro
        cDetalhe += cErroTag + CRLF
        cMotivo  := IIf (Empty(cMotivo),STR0002, STR0010) //--"Cliente Destinatário ou Remetente"//--Ocorreram erros na Importacao do XML.
        lRet     := .F. 

    Else
		If ValType(XmlChildEx(oAuxXml,"_CPAIS")) == "O"
			cPais := SubsTr(oAuxXml:_cPais:Text,1,3)
		EndIf	
		
		If XmlChildEx(oAE80XML,"_CNPJ") # Nil
			cCgcDes := oAE80XML:_CNPJ:TEXT
		ElseIf XmlChildEx(oAE80XML,"_CPF") # Nil
			cCgcDes := oAE80XML:_CPF:TEXT
		EndIf
		
		If !Empty(cIDEstrang)
			If XmlChildEx(oAuxXml,"_UF") <> Nil
				If Empty(cCgcDes) .And. oAuxXml:_UF:Text = 'EX'
					cCgcDes := '00000000000000'
				EndIf
			EndIf
		EndIf 

		If XmlChildEx(oAE80XML,"_TELEFONE") # Nil
			cDDD := SubStr(oAE80XML:_TELEFONE:TEXT, 1, 3)
			cTel := SubStr(oAE80XML:_TELEFONE:TEXT, 4, Len( AllTrim( oAE80XML:_TELEFONE:TEXT ) ) )
		Else
			cDDD := "999"
			cTel := "99999999"
		EndIf

		If XmlChildEx(oAuxXml,"_CEP") # Nil
			cCEP := oAuxXml:_Cep:Text
		EndIf

		If XmlChildEx(oAE80XML,"_CNPJ") # NIL
			cTipo := "R"
		ElseIf XmlChildEx(oAE80XML,"_CPF") # NIL
			cTipo := "F"
		Else
			If !Empty(cIDEstrang)
				cTipo := "X"
			EndIf
		EndIf

		If XmlChildEx(oAE80XML,"_CNPJ") # NIL
			cPessoa := "J"
		ElseIf XmlChildEx(oAE80XML,"_CPF") # NIL
			cPessoa := "F"
		Else
			If !Empty(cIDEstrang)
				cPessoa := "J"
			EndIf
		EndIf

		cCdrDes := Posicione("DUY",6,xFilial("DUY")+oAuxXml:_UF:Text+SubsTr(oAuxXml:_cMun:Text,3,5),"DUY_GRPVEN")	
		
		Aadd(aHeadSA1,{"A1_NOME"	, oAE80XML:_xNome:Text															, Nil })
		Aadd(aHeadSA1,{"A1_PESSOA"	, cPessoa							                                        	, Nil })   
		Aadd(aHeadSA1,{"A1_NREDUZ"  , SubStr(oAE80XML:_xNome:Text,1,20) 											, Nil })
		Aadd(aHeadSA1,{"A1_END"  	, oAuxXml:_xLgr:Text + ", " + oAuxXml:_Nro:Text									, Nil })
		Aadd(aHeadSA1,{"A1_TIPO"  	, cTipo								                                            , Nil })   
		Aadd(aHeadSA1,{"A1_EST"  	, oAuxXml:_UF:Text						 										, Nil })
		Aadd(aHeadSA1,{"A1_COD_MUN" , SubsTr(oAuxXml:_cMun:Text,3,5)			  									, Nil })
		Aadd(aHeadSA1,{"A1_MUN"  	, oAuxXml:_xMun:Text															, Nil })
		Aadd(aHeadSA1,{"A1_BAIRRO"  , oAuxXml:_xBairro:Text															, Nil })   
		Aadd(aHeadSA1,{"A1_CEP"  	, cCEP	            															, Nil })   
		Aadd(aHeadSA1,{"A1_DDD"  	, cDDD                          							  					, Nil })   			
		Aadd(aHeadSA1,{"A1_TEL"  	, cTel		                     							  					, Nil })   				                                                                                    		
		Aadd(aHeadSA1,{"A1_PAIS"  	, cPais							  												, Nil })   			
		Aadd(aHeadSA1,{"A1_CGC" 	, cCgcDes																		, Nil })
		Aadd(aHeadSA1,{"A1_INSCR"	, If(XmlChildEx(oAE80XML,"_IE") # NIL, oAE80XML:_IE:TEXT,"ISENTO" )				, NIL })
		Aadd(aHeadSA1,{"A1_CDRDES" 	, cCdrDes	                     							  					, Nil })   				                                                                                    	
		Aadd(aHeadSA1,{"A1_PFISICA" , cIDEstrang	                   							  					, Nil })   				                                                                                    	
		
		MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aHeadSA1, 3)
			
		If lMsErroAuto
			nNumDet   += 1
			cDetalhe  += Str(nNumDet,1)+"º " + STR0001 //--Erro
			aErroAuto := GetAutoGRLog()
			For nCount := 1 To Len(aErroAuto)
				cDetalhe += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
			Next nCount	
			cDetalhe += CRLF
			cMotivo := IIf (Empty(cMotivo),STR0002, STR0010)//--"Cliente Destinatário ou Remetente"//--Ocorreram erros na Importacao do XML.
			lRet := .F. 
		EndIf	
	EndIf

Return lRet

/*{Protheus.doc} TMSAE80A
Executa a função de importação via menu
@type Function
@author Valdemar Roberto Mognon
@since 17/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TMSAE80A()

TMSAE80(,cEmpAnt,cFilAnt)

Return

/*{Protheus.doc} DefCliCal
Define o cliente de cálculo
@type Static Function
@author Valdemar Roberto Mognon
@since 30/06/2021
@version P12 R12.1.29
@param cTipFre = 1-CIF / 2-FOB
@return logico
*/
Static Function DefCliCal(cTipFre,cCGCRem,cCGCDes,cCliDev,cLojDev,cCliCal,cLojCal,lChkCliGen)
Local aPerfil  := {}
Local aContrat := {}
Local aAreas   := {SA1->(GetArea()),GetArea()}
Local lOk      := .T.
Local cCliRem  := ""
Local cLojRem  := ""
Local cCliDes  := ""
Local cLojDes  := ""

Default cTipFre := ""
Default cCGCRem := ""
Default cCGCDes := ""
Default cCliDev := ""
Default cLojDev := ""

//-- Le remetente e destinatario
SA1->(DbSetOrder(3))
If SA1->(DbSeek(xFilial("SA1") + cCGCRem))
	cCliRem := SA1->A1_COD
	cLojRem := SA1->A1_LOJA
EndIf
If SA1->(DbSeek(xFilial("SA1") + cCGCDes))
	cCliDes := SA1->A1_COD
	cLojDes := SA1->A1_LOJA
EndIf

cCliCal := cCliDev
cLojCal := cLojDev

If cTipFre == "2"	//-- FOB
	aPerfil := TmsPerfil(cCliRem,cLojRem,.F.,.F.)

	If	!Empty(aPerfil) .And. aPerfil[4] == StrZero(1,Len(DUO->DUO_FOBDIR))	//-- É FOB Dirigido (Remetente Negocia mas Destinatário Paga)

		lChkCliGen := .F.

		If lTMA050FOB
			lOk := ExecBlock("TMA050FOB",.F.,.F.,{cCliDes,cLojDes,cCliRem,cLojRem})
			If ValType(lOk) <> "L"
				lOk := .T.
			EndIf
		EndIf

		If lOk
			aContrat := {}
			//-- Considera o cliente remetente somente se nao houver contrato para o cliente destinatario
			aContrat := TMSContrat(cCliDes,cLojDes,,,.F.,cTipFre, .F.,,,,,,,,,,,,,,,)
			If Empty(aContrat)
				cCliCal := cCliRem
				cLojCal := cLojRem
			EndIf
		EndIf

	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Fabio Marchiori Sampaio
	@since 04/01/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function RetIDEstrang(cIDEstrang)

Local cAliasSA1  := GetNextAlias()
Local cQuerySA1  := ""
Local aRet       := {}

Default  cIDEstrang := ""
	
	cQuerySA1 := "SELECT A1_COD, A1_LOJA, A1_NOME "
	cQuerySA1 += " FROM " + RetSqlName("SA1")+ " SA1 "
	cQuerySA1 += " WHERE "
	cQuerySA1 += " SA1.A1_FILIAL  = '"+xFilial("SA1")+"' AND "
	cQuerySA1 += " SA1.A1_PFISICA = '"+cIDEstrang+"' AND "
	cQuerySA1 += " SA1.D_E_L_E_T_ = ' ' "
	
	cQuerySA1 := ChangeQuery(cQuerySA1)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySA1),cAliasSA1, .T., .T.)
	
	While (cAliasSA1)->(!Eof())
		aAdd(aRet, (cAliasSA1)->A1_COD)
		aAdd(aRet, (cAliasSA1)->A1_LOJA)
		aAdd(aRet, (cAliasSA1)->A1_NOME)

		(cAliasSA1)->(dbSkip())
	End

	(cAliasSA1)->(dbCloseArea())

Return aRet

/*/{Protheus.doc} TMSAE80ERR
	Grava Log em caso de erro
	@type  Static Function
	@author Daniel Leme
	@since 30/01/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function TMSAE80ERR(e)

If ExistFunc("TmsRepTrac")
	TmsRepTrac(e:ErrorStack ,.T.,DIRXML+DIRERRO+"LOG_TMSAE80_ERR_")
	TmsRepTrac(e:Description,.T.,DIRXML+DIRERRO+"LOG_TMSAE80_ERR_")
	TmsRepTrac(e:ErrorEnv   ,.T.,DIRXML+DIRERRO+"LOG_TMSAE80_ERR_")
	VarInfo('',e:ErrorStack )
	VarInfo('',e:Description)
	VarInfo('',e:ErrorEnv   )
	break
EndIf

Return Nil  
