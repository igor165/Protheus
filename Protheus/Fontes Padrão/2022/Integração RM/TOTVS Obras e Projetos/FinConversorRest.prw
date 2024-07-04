#Include "RESTFUL.CH"
#Include "TOTVS.CH"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"  
#Include "COLORS.CH"                                                                                                     
#Include "TBICONN.CH"
#Include "COMMON.CH" 
#Include "XMLXFUN.CH"
#Include "fileio.ch" 
#Include 'FWMVCDEF.CH' 


#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )
/*
{Protheus.doc} 
@Uso    Serviço REST para conversao dos títulos do Protheus de origem imobiliario
@Autor  William.Prado - TOTVS
*/
WSRESTFUL FinConversorRest DESCRIPTION "Serviço REST para conversao dos títulos do Protheus de origem imobiliario"   
  WSMETHOD POST;
  DESCRIPTION "Retorna Informacoes referente a conversao dos títulos convertidos com valores acessorios ";
  WSSYNTAX "/FinConversorRest"
END WSRESTFUL

WSMETHOD POST WSSERVICE FinConversorRest
 
  Local cJson         := Self:GetContent()  
  Local lMetodo		  := .t.

  /*** inicio Auxiliares ****/
  Local nXeai            := 0 
  Local nCont            := 0  
  /*** fim Auxiliares  *****/ 

  /*** inicio Json ****/ 
  Local oJson        As Object
  Local cCatch       As Character  
  Local oReturnJson  As Object
  Local vetjSVA      := {}
  private aLog       := {}
  /*** fim Json  *****/ 

  oJson              := JsonObject():New()
  cCatch             := oJson:FromJSON(cJson)
 
  BEGIN SEQUENCE
    IF cCatch == Nil   
    	FOR nXeai := 1 to LEN(oJson["EAI"])
			cMarca         := oJson["EAI"][nXeai]["sourceApp" ] 
			cEmpre         := oJson["EAI"][nXeai]["companyId" ]
			cBranc         := oJson["EAI"][nXeai]["branchId"  ]	
			cGlobaId       := oJson["EAI"][nXeai]["GlobaId"   ]
			cChaveRM       := oJson["EAI"][nXeai]["ChaveRM"   ]			
			aVetVA         := oJson["EAI"][nXeai]["ITENSVA"   ]
			aVetVABx       := oJson["EAI"][nXeai]["ITENSVABX" ]
			nValorTitulo   := oJson["EAI"][nXeai]["GrossValue"]	
			cIdExterno     := ''
			IF PrePareContexto( cMarca, cEmpre, CBranc)      
               // Obtem De/Para titulo
		       cIntVal := EXTTOINTVAL(cMarca, IF(EMPTY(cGlobaId), cChaveRM, cGlobaId))
 			
			   If Empty(cIntVal)	
		    	   AddLog(cChaveRM , cGlobaId , cIdExterno , .f., "De/Para titulo nao encontrado:" +  cChaveRM  )
		 	   Else  
		    	   cIdExterno :=cIntVal
		 		   aAux:=Separa(cIntVal,'|')
				   cChaveTitulo  := padr(aAux[2],TamSx3("E1_FILIAL")[1])
				   cChaveTitulo  += padr(aAux[3],TamSx3("E1_PREFIXO")[1])
				   cChaveTitulo  += padr(aAux[4],TamSx3("E1_NUM")[1])
				   cChaveTitulo  += padr(aAux[5],TamSx3("E1_PARCELA")[1])
				   cChaveTitulo  += padr(aAux[6],TamSx3("E1_TIPO")[1])
			  	   cChaveFK7:= GetChaveFK7(cChaveTitulo)
				   
				   If (Empty(cChaveFK7))
			   		    AddLog(cChaveRM , cGlobaId, cIdExterno  , .f., "Chave FK7 nao encontrada. Titulo:"+ cChaveTitulo )     
            	   Else
			   		    aValAcessorio := AddValorAcessorio(cMarca,aVetVA)			
						
						If (aValAcessorio == NIL .or. Len(aValAcessorio) == 0)				
							AddLog(cChaveRM ,cGlobaId ,cIdExterno , .t. , "Sem valores acessorios.")
						Else
							//atualiza valores acessorios
							UpsertValorAcessorio(cChaveFK7 , aValAcessorio)
			
							//atualizar o valor do titulo
							UpsertTitulo(nValorTitulo)
		
							IF(LEN(aVetVABx) >0)
								//Se a lista de baixas estï¿½ preenchida, recria os valores acessorios das baixas
						     	GerarBaixa(cMarca,cChaveFK7,aVetVABx)
							Endif					   
							AddLog(cChaveRM ,cGlobaId ,cIdExterno , .T., ""  )				
					   ENDIF 
			    	EndIf    				   
				ENDIF
			Else
			    AddLog(cChaveRM  ,cGlobaId , .f., "Marca/Empresa/Filial Inconsistente"  )
			ENDIF			
	    NEXT
		nCont	 := 0
		For nCont := 1 to len (aLog)	
			jsVA:= JsonObject():new()
			jsVA['CHAVERM'    ] := aLog[nCont][1]   
			jsVA['GLOBALID'   ] := aLog[nCont][2]   
			jsVA['IDEXTERNO'  ] := aLog[nCont][3]   
			jsVA['STATUS'     ] := aLog[nCont][4]   
			jsVA['LOG'        ] := aLog[nCont][5]
			aadd(vetjSVA,jsVA) 
		NEXT

		/*RETORNO REST*/   
   		oReturnJson := JsonObject():new()   	
        oReturnJson['TITULOSVA'] := vetjSVA		   
   		ExportarJson(Self , oReturnJson, "FinancialConversor")
   		/*RETORNO REST*/
    ELSE	
	   lMetodo := .f.
       SetRestFault(400, "Json Invalido!")
	ENDIF
  RECOVER 	
     lMetodo := .F.	          	
	 SetRestFault(400, "Ocorreu um problema na execucao do servico: "+ TAB + oError:Description)			
  END SEQUENCE 

Return lMetodo

static Function AddLog(cChaveRM, cGlobalId ,cIdExterno, status , cMsn) 	
   AAdd(aLog,{ cChaveRM , cGlobalId , alltrim(cIdExterno) ,status , cMsn})
return  .t.

static Function GerarBaixa(cMarca,cChaveFK7,aVetVaBx)
    local lRet            := .F.	
	Local cLog            := ''
	local cIdOrigem       :=''
	Local oModelBx        := Nil	
	Local oSubFKA	      := NIL
	Local oSubFK1         := NIL	  
    dbSelectArea("SE5")
    dbSetOrder(7)
	DBGotop()
    IF dbseek(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO +SE1->E1_CLIENTE + SE1->E1_LOJA)					
	    cIdOrigem :=SE5->E5_IDORIG
		oModelBx := FWLoadModel("FINM010")
		oModelBx:SetOperation(4) 
		oModelBx:Activate()
		oModelBx:SetValue( "MASTER", "E5_GRV", .T. )			
		oSubFKA := oModelBx:GetModel( "FKADETAIL" )
		If oSubFKA:SeekLine( { {"FKA_IDORIG",cIdOrigem } } )		
		  
			oSubFK1 := oModelBx:GetModel( "FK1DETAIL" )

			GerarFK6(@oModelBx,cMarca,aVetVaBx)
			
			If oModelBx:VldData()
			 	oModelBx:CommitData()
			Else				
				cLog :=  "-Erro ao gerar valores acessorios de baixa."
				cLog += oModelBx:GetErrorMessage()[3]
			    cLog += '--' + oModelBx:GetErrorMessage()[5]
			    cLog += '--' + oModelBx:GetErrorMessage()[6]
			    cLog += '--' + oModelBx:GetErrorMessage()[7]				
			EndIf
			oModelBx:DeActivate()
			oModelBx:Destroy()
			oModelBx:= Nil		
		Endif		
    Endif
return lRet

/*
{Protheus.doc} 
@Uso    Gerar valores acessorios de baixa FK6
@Autor  William.Prado - TOTVS
@param  oModelBx -> Modelo
@param  cMarca   -> Produto;
@param  aVetVaBx -> Vetor de Valor Acessorios de baixa
*/
static Function GerarFK6(oModelBx,cMarca,aVetVaBx)  		
 	Local nX       := 0		 	
 	Local oSubFK6  := oModelBx:GetModel( "FK6DETAIL" )	
    Local aValbx   := AddValorAcessorio(cMarca,aVetVaBx)
 	
	For nX := 1 To Len(aValbx)		    				
			If !oSubFK6:IsEmpty()					
				oSubFK6:AddLine()		
				oSubFK6:GoLine( oSubFK6:Length() )
			EndIf								
			oSubFK6:SetValue( 'FK6_FILIAL' , FWxFilial("FK6") )
			oSubFK6:SetValue( 'FK6_IDFK6'	 , GetSxEnum('FK6','FK6_IDFK6') )					
			oSubFK6:SetValue( "FK6_VALMOV" , aValbx[nX,2] )
			oSubFK6:SetValue( "FK6_VALCAL" , aValbx[nX,2] )
			oSubFK6:SetValue( "FK6_TPDESC" , "2" )
			oSubFK6:SetValue( "FK6_TPDOC"  , "VA" )
			oSubFK6:SetValue( "FK6_RECPAG" , "R" )
			oSubFK6:SetValue( "FK6_TABORI" , 'FK1' )
			oSubFK6:SetValue( "FK6_IDORIG" , SE5->E5_IDORIG )
			oSubFK6:SetValue( "FK6_HISTOR" ,"Conversor EAI2.0" )
			oSubFK6:SetValue( "FK6_CODVAL" , aValbx[nX,1] )
			oSubFK6:SetValue( "FK6_ACAO"   , "1" )			
			oSubFK6:SetValue( "FK6_IDFKD"  , SPACE(32) )
 	  Next nX  
 	return .T.


/*
{Protheus.doc} 
@Uso    Retorna o vetor com os valores acessorios 
@Autor  William.Prado - TOTVS
@param  cMarca -> Produto; Vetor de Valor Acessorios
@return	ChaveFK7-> Processo validado; "" -> Nï¿½o encontrou o Tï¿½tulo
*/
static Function AddValorAcessorio(cMarca,aVetVA)
  Local aValAcessorio    := {}    
  Local nCount           := 0 
  For nCount := 1 To Len(aVetVA)	   
 
   aAuxVa := F035GETINT(aVetVA[nCount,"Codigo"],cMarca)
    
   If(aAuxVa[1])   
     aAdd(aValAcessorio,{aAuxVa[2,3], aVetVA[nCount,"Valor"]})
   EndIf
   
  Next nCount
  
return aValAcessorio
/*
{Protheus.doc} 
@Uso    Localiza o titulo informado e retorna a chave da FK7
@Autor  William.Prado - TOTVS
@param  cChaveTitulo
@return	ChaveFK7-> Processo validado; "" -> Nï¿½o encontrou o Tï¿½tulo
*/
static Function GetChaveFK7(cChaveTitulo) 
  Local cChaveTit := ""
  Local cChaveFK7 := ""
 
  DBSelectArea("SE1")
  SE1->(DBSetOrder(1))
 
  If SE1->(dbSeek(cChaveTitulo))
     cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA  
     cChaveFK7 := FINGRVFK7( 'SE1', cChaveTit )     
  EndIf
return cChaveFK7

/*
{Protheus.doc} 
@Uso    Atualiza os valor e saldo do titulo
@Autor  William.Prado - TOTVS
@param  
@return	.T. -> Processo validado ; .F. -> Processo Interrompido
*/
Static Function UpsertTitulo(nValorTitulo)
 	Reclock("SE1")
 	Replace E1_VALOR With  nValorTitulo
 	Replace E1_ACRESC  With 0
 	Replace E1_SDACRES With 0
 	Replace E1_DECRESC With 0
 	Replace E1_SDDECRE With 0
	Replace E1_PORCJUR With 0
 	Replace E1_VALJUR  With 0
 	If (SE1->E1_SALDO != 0)
   		Replace E1_SALDO With nValorTitulo	 
 	EndIf
 	Replace E1_VLCRUZ with nValorTitulo
 	MsUnlock() 

return .t.
/*
{Protheus.doc} 
@Uso    Gerar os valores acessï¿½rios para o titulo informado
@Autor  William.Prado - TOTVS
@param
Nopcao = 1 caddastro de valores acessrios 
Nopcao = 2 cadastro de valores acessorios para baixa
@return	.T. -> Processo validado ; .F. -> Processo Interrompido
*/
Static Function UpsertValorAcessorio(cChaveFK7,aValAcessorio)  
  local lRet      := .t.
  Local nCount    := 0 	   
  Local aVetVA    := {}  
  For nCount := 1 To Len(aValAcessorio)
     AAdd(aVetVA , {aValAcessorio[nCount,1], cValToChar(aValAcessorio[nCount,2])})
     FINGRVFKD(cChaveFK7,aVetVA)     
  Next nX    
  
return lRet			

/*
{Protheus.doc} EXTTOINTVAL
@Uso    Verifica as mensagem recebidas de acordo com a integracao EAI para montagem de DE/PARA
@param  cMarca = Produto de Integracao; cTitulo = Campos recebidos da mensagem REST
@return	Array de informaç?es de DE/PARA
@Autor  William Prado- TOTVS
*/
Static Function EXTTOINTVAL(cMarca,cTitulo)
 Local   aIntegra	:= {}
 Local   cAlias   := 'SE1'
 Local   cField   := 'E1_NUM'

 aIntegra := CFGA070Int(cMarca, cAlias, cField, cTitulo)

 Return (aIntegra)



Static Function PrePareContexto(cSourceApp , cCompanyId , cBrancId)
 LOCAL	lMetodo     := .f.
 LOCAL  cCodEmpresa := ""
 LOCAL  cCodFilial  := ""
 aEmpre := FWEAIEMPFIL(cCompanyId, cBrancId, cSourceApp)
 If Len (aEmpre) < 1
    SetRestFault(400, "Empresa: " + cCompanyId + " Nao existem para o Sistema: " + cSourceApp + " !")
	lMetodo := .f.
 else
    cCodEmpresa  := aEmpre[1]	
	cCodFilial   := aEmpre[2]
    RESET ENVIRONMENT
    RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cCodEmpresa FILIAL cCodFilial TABLES "XX4" MODULO "CFG" 		
	lMetodo := .t.
 ENDIF	
Return lMetodo



 /*/{Protheus.doc} ExportarJson
(Exporta o Json )
@type  Function
@author William.Prado
@since 13/05/2020
@version version
@param Contexto, Contexto, Contexto enviado para API
@return Objeto convertido em Json 
/*/
Static Function ExportarJson(Self , oReturnJson, cApi)
  LOCAL	lMetodo := .t.
  LOCAL oJson  As Object  
  ::SetContentType("application/json")  
  oJson := JsonObject():new()
  oJson := oReturnJson
  IF ValType(oJson) == "J"
	   Conout("Api:" + cApi + "-> Json gerado com sucesso. ")
  else		
       Conout("Api:" + cApi + "-> Falha ao gerar Json. ")   	   
  ENDIF  
  ::SetResponse(oJson:toJson())   
Return lMetodo